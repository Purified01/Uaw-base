-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Attack_Controller.lua#12 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Attack_Controller.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 82141 $
--
--          $DateTime: 2007/08/28 18:44:46 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGVectorMath")
require("PGGoalController")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------
local SUBGOAL_UNIQUE_ID = 1				-- gets incremented each time we spawn a sub-goal
local MAX_CONCURRENT_SUBGOALS = 3		-- can't have more than this number of sub-goals active at a time

function Definitions()
	SUBGOAL_UNIQUE_ID = 1
	MAX_CONCURRENT_SUBGOALS = 3
	ACTIVE_SUBGOALS = {}

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIAttackLog.txt"
end


---------------------- Goal Events and Queries ----------------------

-- The Generic Attack Controller Goal only has one instance, which is
-- activated as a sub-goal of the Master_Unit_Goal_Controller.
-- It spawns sub-goals (of the various attack types) to actually
-- execute its specific attack plans.
function Compute_Desire()

	-- If we were created as a sub-goal of the Master_Unit_Goal_Controller
	-- then that's ok.
	-- TODO? With the new organization it may be easier to always return
	-- 1.0, since we have to be explicitly activated from another script
	-- anyway.
	local user_data = Goal.Get_User_Data()
	if (user_data ~= nil) and (user_data.ParentScriptName == "Master_Unit_Goal_Controller") then
		return 1.0
	end
	
	-- Otherwise we will not execute.
	Goal.Suppress_Goal()
	return 0.0
end


-- This controller script never claims units directly.
function Score_Unit(unit)
	return 0.0
end


-- We do all of our work in the scouting thread, which starts when we
-- activate (on the nil target).
function On_Activate()
	-- Initialize our max concurrent sub-goals value from the UserData we were given.
	local user_data = Goal.Get_User_Data()
	if user_data ~= nil and user_data.MaxConcurrentSubgoals ~= nil then
		MAX_CONCURRENT_SUBGOALS = user_data.MaxConcurrentSubgoals
		log("MAX_CONCURRENT_SUBGOALS initialized to %g", MAX_CONCURRENT_SUBGOALS)
	end

	-- Launch the thread we use to do all the work.
	log("Generic_Attack_Controller activated. Attack_Opponents thread created.")
	Create_Thread("Attack_Opponents")
end


-- Update_Max_Concurrent_Subgoals - This function is called from our parent script
-- when it decides to change the number of concurrent sub-goals we're allowed to
-- create.
function Update_Max_Concurrent_Subgoals(new_max_subgoals)
	log("MAX_CONCURRENT_SUBGOALS updated to %g", new_max_subgoals)
	if new_max_subgoals ~= nil then
		MAX_CONCURRENT_SUBGOALS = new_max_subgoals
	end
end



---------------------- Goal-specific Functions ----------------------

-- Until this game mode ends, we'll be periodically spawning sub-goals
-- to launch various kinds of attacks against enemy forces.
function Attack_Opponents()

	-- Keep looping forever.
	while true do

		if Player.Get_Difficulty() == "Difficulty_Easy" then
		
			if GetCurrentTime() < 300.0 then
				Sleep(300.0-GetCurrentTime())
			end
			
		elseif Player.Get_Difficulty() ~= "Difficulty_Hard" then
			if GetCurrentTime() < 180.0 then
				Sleep(180.0-GetCurrentTime())
			end
		end

		-- Can we actually create a new subgoal and stay under our limit
		-- for the max number of instances?
		local num_active_subgoals = Goal.Get_Sub_Goal_Count()
		if num_active_subgoals < MAX_CONCURRENT_SUBGOALS then
			-- Try to activate a new attack sub-goal. This may take
			-- many seconds to complete. Returns nil if no new sub-goal
			-- could be created, or a blocking object for that sub-goal
			-- if successful.
			local subgoal_block = Start_New_Attack_Goal()
			if subgoal_block then
				log("New attack sub-goal created!")
			else
				--log("Failed to create a new attack sub-goal.")
				Sleep(4)
			end
		else
			-- Wait until we're below the MAX_CONCURRENT_SUBGOALS cap again.
			Wait_For_Any_Subgoal()
		end

		-- Wait at least one second before looping.
		if Player.Get_Difficulty() == "Difficulty_Easy" then
			Sleep(30.0)
		elseif Player.Get_Difficulty() ~= "Difficulty_Hard" then
			Sleep(15.0)
		end
		
		Sleep(1)
	end

	log("Attack_Opponents thread is exiting!!")
end


-- Score the given AITarget, in order to figure out what we should be attacking.
function Score_Attack_Target(ai_target)
	if not ai_target then
		return 0.0
	end
	
	local score = 1.0

	-- Ignore all non-enemy AITargets. (This also eliminates position targets.)
	if not ai_target.Is_Enemy(Player) then
		return 0.0
	end
	
	-- Ignore all AITargets except Game Objects and Groups.
	local target_type = ai_target.Get_Target_Type()
	if (target_type ~= "Game_Object") and (target_type ~= "Object_Group") then
		return 0.0
	end
	
	-- Ignore empty Groups (since that means they're hidden in the fog of war).
	if (target_type == "Object_Group") and (ai_target.Get_Group_Target_Size() <= 0) then
		return 0.0
	end
	
	-- Ignore all AITargets that are already the targets of a sub-goal.
	if Target_Is_Already_Used(ai_target) == true then
		log("Score_Attack_Targets(%s) called, rejecting target because it is already claimed by another sub-goal", Describe_Target(ai_target))
		return 0.0
	end
	
	-- target walkers 1st
	if (target_type == "Game_Object") then
		-- stationary targets are higher priority (i.e. not a group)
		score = score * 2.0
		
		local object = ai_target.Get_Game_Object()
		
		if not TestValid(object) then
			return 0.0
		end
		
		if object and object.Is_Category("Huge + CanAttack") then
			-- go after walkers
			score = score * 5.0
		end

		if object.Is_Category("Insignificant + Stationary | Resource | Resource_INST | Bridge") then
			return 0.0
		end
		
		local player=object.Get_Owner()
		if TestValid(player) then
			-- check for human
			if not player.Is_AI_Player() then
			
				local dif_mod = 1.0
				if Player.Get_Difficulty() == "Difficulty_Easy" then
					dif_mod = 0.8
				elseif Player.Get_Difficulty() == "Difficulty_Hard" then
					dif_mod = 1.5
				end
			
				score = score * dif_mod
			end
		end
	end
	
	-- High Priority: Enemy objects close to my base (or leave these for the Defense scripts?)
	-- High Priority: Undefended enemy structures.
	-- High Priority: Visible enemy gatherers.
	-- High Priority: Visible enemy heroes.

	score = 0.01 + GameRandom.Get_Float(0.0,score)

	log("Score_Attack_Target(%s) called, returning %g", Describe_Target(ai_target), score)
	return score
end



-- Start_New_Attack_Goal - Choose a sensible target to attack, and start
-- a new sub-goal to go hit it.
--
-- Returns a BlockingObject representing the spawned sub-goal, or nil
-- if the sub-goal was not created.
function Start_New_Attack_Goal()
	--log("Start_New_Attack_Goal")

	-- easy fail to activate 50% of the time
	if Player.Get_Difficulty() == "Difficulty_Easy" and GameRandom(0,100) < 50 then
		return nil
	end
	
	-- Search for the best target to attack. This will call the scoring function
	-- for each possible target, so most of the target selection logic is in
	-- that function.
	local best_attack_target = Find_Best_Target(Player, Score_Attack_Target)
	if not best_attack_target then
		--log("No suitable attack target found.")
		return nil
	end

	-- Spawn a sub-goal to go attack that target!
	Sleep(0.5)
	local script_name = "Generic_Attack"
	local target = best_attack_target
	local user_data = SUBGOAL_UNIQUE_ID
	SUBGOAL_UNIQUE_ID = SUBGOAL_UNIQUE_ID + 1.0
	
	log("Activating new %s sub-goal with target: %s and user data: %s", script_name, Describe_Target(target), tostring(user_data))
	local blocking_object = Goal.Activate_Sub_Goal(script_name, target, user_data)
	if blocking_object then
		Record_New_Active_Subgoal(user_data, blocking_object, script_name, target, user_data)
	end
	return blocking_object
end


