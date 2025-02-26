if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[172] = true
LuaGlobalCommandLinks[113] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Guerrilla_Controller.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Guerrilla_Controller.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGVectorMath")
require("PGGoalController")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------
local SUBGOAL_UNIQUE_ID = 1				-- gets incremented each time we spawn a sub-goal
local MAX_CONCURRENT_SUBGOALS = 2		-- can't have more than this number of sub-goals active at a time

function Definitions()
	SUBGOAL_UNIQUE_ID = 1
	MAX_CONCURRENT_SUBGOALS = 2
	ACTIVE_SUBGOALS = {}

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIGuerrillaLog.txt"
end


---------------------- Goal Events and Queries ----------------------

-- The Generic Guerrilla Controller Goal only has one instance, which is
-- activated as a sub-goal of the Master_Unit_Goal_Controller.
-- It spawns sub-goals (of the various guerrilla types) to actually
-- execute its specific guerrilla plans.
function Compute_Desire()

	if Player.Get_Player_Is_Crippled() then
		return 0.0
	end

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
	log("Generic_Guerrilla_Controller activated. Guerrilla_Opponents thread created.")
	Create_Thread("Guerrilla_Opponents")
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
-- to launch various kinds of guerrillas against enemy forces.
function Guerrilla_Opponents()

	-- Keep looping forever.
	while true do

		if Player.Get_Difficulty() == "Difficulty_Easy" then
			MAX_CONCURRENT_SUBGOALS = 1
			
			if GetCurrentTime() < 180.0 then
				Sleep(180.0-GetCurrentTime())
			end
		elseif Player.Get_Difficulty() ~= "Difficulty_Hard" then
			if GetCurrentTime() < 120.0 then
				Sleep(120.0-GetCurrentTime())
			end
		end

		-- Can we actually create a new subgoal and stay under our limit
		-- for the max number of instances?
		local num_active_subgoals = Goal.Get_Sub_Goal_Count()
		if num_active_subgoals < MAX_CONCURRENT_SUBGOALS then
			-- Try to activate a new guerrilla sub-goal. This may take
			-- many seconds to complete. Returns nil if no new sub-goal
			-- could be created, or a blocking object for that sub-goal
			-- if successful.
			local subgoal_block = Start_New_Guerrilla_Goal()
			if subgoal_block then
				log("New guerrilla sub-goal created!")
			else
				log("Failed to create a new guerrilla sub-goal.")
				Sleep(2.0)
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

	log("Guerrilla_Opponents thread is exiting!!")
end


-- Score the given AITarget, in order to figure out what we should be guerrillaing.
function Score_Guerrilla_Target(ai_target)

	if not ai_target then
		return 0.0
	end

	--log( "Score_Guerrilla_Targets : Trying to score %s", Describe_Target(ai_target) )
	
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

	-- Ignore all AITargets that are already the targets of a sub-goal.
	if Target_Is_Already_Used(ai_target) == true then
		--log("Score_Guerrilla_Targets(%s) called, rejecting target because it is already claimed by another sub-goal", Describe_Target(ai_target))
		return 0.0
	end

	-- Ignore all individual Game Objects that are not base structures.
	-- We need to guerrilla enemy units via object groups.
	if target_type == "Game_Object"  then
		target_unit = ai_target.Get_Game_Object()
		
		if not TestValid( target_unit ) then
			return 0.0
		end
		
		-- don't target units that are garrisoned
		if TestValid(target_unit.Get_Garrison()) then
			return 0.0
		end
		
		if target_unit.Is_Category("Insignificant + Stationary | Resource | Resource_INST | Bridge") then
			return 0.0
		end
		
		if target_unit.Is_Cloaked() then
			return 0.0
		end
		
		-- go after ground targets first
		score = score * 2.0

		local unit_type = target_unit.Get_Type()
		if not unit_type then
			return 0.0
		end

		if unit_type.Get_Type_Value("Is_Resource_Collector") then
			-- kill their resource collectors
			score = score * 2.0
		end

		if target_unit.Is_Category("Huge + CanAttack") then
			-- go after walkers
			score = score * 2.0
		end
		
		local player=target_unit.Get_Owner()
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
	
	-- Ignore empty Groups (since that means they're hidden in the fog of war).
	if target_type == "Object_Group" then
		if ai_target.Get_Group_Target_Size() <= 0 then
			return 0.0
		end

		score = score / ai_target.Get_Group_Target_Size()
		
	end
	
	-- High Priority: Enemy objects close to my base (or leave these for the Defense scripts?)
	-- High Priority: Undefended enemy structures.
	-- High Priority: Visible enemy gatherers.
	-- High Priority: Visible enemy heroes.

	score = 0.01 + GameRandom.Get_Float(0.0,score)

	--log("Score_Guerrilla_Target(%s) called, returning %g", Describe_Target(ai_target), score)
	return score
end



-- Start_New_Guerrilla_Goal - Choose a sensible target to guerrilla, and start
-- a new sub-goal to go hit it.
--
-- Returns a BlockingObject representing the spawned sub-goal, or nil
-- if the sub-goal was not created.
function Start_New_Guerrilla_Goal()
	log("Start_New_Guerrilla_Goal")
	
	-- Search for the best target to guerrilla. This will call the scoring function
	-- for each possible target, so most of the target selection logic is in
	-- that function.
	local best_guerrilla_target = Find_Best_Target(Player, Score_Guerrilla_Target)
	if not best_guerrilla_target then
		log("No suitable guerrilla target found.")
		return nil
	end

	-- Spawn a sub-goal to go guerrilla that target!
	Sleep(0.5)
	
	if not TestValid(best_guerrilla_target) then
		log("Guerrilla target died.")
		return nil
	end
	
	local script_name = "Generic_Guerrilla"
	local target = best_guerrilla_target
	local user_data = SUBGOAL_UNIQUE_ID
	SUBGOAL_UNIQUE_ID = SUBGOAL_UNIQUE_ID + 1.0
	
	log("Activating new %s sub-goal with target: %s and user data: %s", script_name, Describe_Target(target), tostring(user_data))
	local blocking_object = Goal.Activate_Sub_Goal(script_name, target, user_data)
	if blocking_object then
		Record_New_Active_Subgoal(user_data, blocking_object, script_name, target, user_data)
	end
	return blocking_object
end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Burn_All_Objects = nil
	Calculate_Task_Force_Speed = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	Get_Distance_Based_Unit_Score = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	PG_Vector_Add = nil
	PG_Vector_Multiply_Scalar = nil
	PG_Vector_Normalize = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
