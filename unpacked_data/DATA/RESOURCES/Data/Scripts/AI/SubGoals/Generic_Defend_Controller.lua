-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Defend_Controller.lua#8 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Defend_Controller.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 80347 $
--
--          $DateTime: 2007/08/09 10:22:59 $
--
--          $Revision: #8 $
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
local MAX_BASE_RESPONSE_SUBGOALS = 1	-- can't have more than this number of sub-goals reserved for responding to attacks against our base(s)
local PLAYER_BASE_CLUSTERS = {}			-- table of PositionWrappers(results of a Find_Clusters() call) representing clusters of the player's immobile base structures
local LAST_MAP_ANALYSIS_TIME = 0.0		-- last time (GetCurrentTime return value) we called Analyze_Map()

function Definitions()
	SUBGOAL_UNIQUE_ID = 1
	MAX_CONCURRENT_SUBGOALS = 3
	MAX_CONCURRENT_SUBGOALS = 1
	PLAYER_BASE_CLUSTERS = {}
	ACTIVE_SUBGOALS = {}
	LAST_MAP_ANALYSIS_TIME = 0.0
	
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIDefendLog.txt"
end


---------------------- Goal Events and Queries ----------------------

-- The Generic Defend Controller Goal only has one instance, which is
-- activated as a sub-goal of the Master_Unit_Goal_Controller.
-- It spawns sub-goals (of the various defense types) to actually
-- execute its specific attack plans.
function Compute_Desire()

	-- If we were created as a sub-goal of the Master_Unit_Goal_Controller
	-- then that's ok.
	-- TODO? With the new organization it may be easier to always return
	-- 1.0, since we have to be explicitly activated from another script
	-- anyway.
	local user_data = Goal.Get_User_Data()
	if (user_data ~= nil) and (user_data.ParentScriptName == "Master_Unit_Goal_Controller") then
		-- KDB obsolete
		--return 1.0
		Goal.Suppress_Goal()
		return 0.0
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
		Update_Max_Concurrent_Subgoals(user_data.MaxConcurrentSubgoals)
	end

	-- Launch the thread we use to do all the work.
	log("Generic_Defend_Controller activated. Defend_Base thread created.")
	Create_Thread("Defend_Base")
end


-- Update_Max_Concurrent_Subgoals - This function is called from our parent script
-- when it decides to change the number of concurrent sub-goals we're allowed to
-- create.
function Update_Max_Concurrent_Subgoals(new_max_subgoals)
	if new_max_subgoals ~= nil then
		-- Use 40% of our sub-goals to respond to base attacks, with a minimum of 1.
		MAX_CONCURRENT_SUBGOALS = new_max_subgoals
		if MAX_CONCURRENT_SUBGOALS <= 0.0 then
			MAX_BASE_RESPONSE_SUBGOALS = 0.0
		else
			MAX_BASE_RESPONSE_SUBGOALS = Max(tonumber(Dirty_Floor(MAX_CONCURRENT_SUBGOALS * 0.40)), 1.0)
		end
	end
	log("MAX_CONCURRENT_SUBGOALS updated to %g, MAX_BASE_RESPONSE_SUBGOALS=%g", MAX_CONCURRENT_SUBGOALS, MAX_BASE_RESPONSE_SUBGOALS)
end



---------------------- Goal-specific Functions ----------------------

-- Until this game mode ends, we'll be periodically spawning sub-goals
-- to try to protect our base structures (and heroes?).
function Defend_Base()

	-- Keep looping forever.
	while true do

		-- Can we actually create a new subgoal and stay under our limit
		-- for the max number of instances?
		local num_active_subgoals = Goal.Get_Sub_Goal_Count()
		if num_active_subgoals < MAX_CONCURRENT_SUBGOALS then
			-- Try to activate a new attack sub-goal. This may take
			-- many seconds to complete. Returns nil if no new sub-goal
			-- could be created, or a blocking object for that sub-goal
			-- if successful.
			local subgoal_block = Start_New_Defense_Goal()
			if subgoal_block then
				log("New defense sub-goal created!")
			else
				--log("Failed to create a new attack sub-goal.")
				Sleep(4)
			end
		else
			-- Wait until we're below the MAX_CONCURRENT_SUBGOALS cap again.
			Wait_For_Any_Subgoal()
		end

		-- Wait at least one second before looping.
		Sleep(1)
		Clean_Active_Subgoal_Table()
	end

	log("Defend_Base thread is exiting!!")
end


-- Score all immobile player base structures highly. We want to send
-- units to protect them at regular intervals.
function Score_Defense_Target(ai_target)
	if not ai_target then
		return 0.0
	end
	
	-- Reject anything that isn't friendly.
	if not ai_target.Is_Ally(Player) then
		return 0.0
	end
	
	-- Only accept non-mobile allied base structures as targets.
	local target_type = ai_target.Get_Target_Type()
	if (target_type == "Game_Object") and (ai_target.Get_Game_Object().Has_Behavior(BEHAVIOR_GROUND_STRUCTURE)) and (not ai_target.Get_Game_Object().Can_Move()) then
		if target_type.Get_Health() < 1.0 then
			local score = 1.0
			log("\tScore_Defense_Target(%s) called, returning %g", Describe_Target(ai_target), score)
			return score
		end
	end
	
	return 0.0
end


-- Score any enemy object group visible near our base structures highly.
function Score_Base_Response_Target(ai_target)
	if not ai_target then
		return 0.0
	end
	
	local score = 1.0
	local target_type = ai_target.Get_Target_Type()

	-- Ignore all enemy targets except non-empty object groups and individual game objects.
	if ai_target.Is_Enemy(Player) then
		if target_type == "Object_Group" then
			if ai_target.Get_Group_Target_Size() <= 0 then
				return 0.0
			end
		elseif target_type == "Game_Object" then
			-- Don't attack resource objects!
			if ai_target.Get_Game_Object().Has_Behavior(BEHAVIOR_RESOURCE) or ai_target.Get_Game_Object().Has_Behavior(BEHAVIOR_PHASED) then
				return 0.0
			end
			score = score * 0.8		-- we'd rather attack groups
		else
			return 0.0
		end
		
		-- If we already have an active sub-goal with that target, don't score it.
		if Target_Is_Already_Used(ai_target) then
			return 0.0
		end
		
		-- Only accept enemy targets that are within a certain distance of our base.
		local too_far_away = true
		local defensive_response_distance = 800.0
		for _,v in pairs(PLAYER_BASE_CLUSTERS) do
			local actual_distance = ai_target.Get_Distance(v)
			if actual_distance < defensive_response_distance then
				-- High Priority: Enemy objects close to my base.
				score = score * 1.5
				log("\tIncreased priority due to being %g units from base structure cluster at %s.", actual_distance, tostring(v))
				too_far_away = false
			end
		end
		if too_far_away then
			log("\tScore_Base_Response_Target(%s) returning 0.0 because it is too far away from any cluster of immobile base structures.", Describe_Target(ai_target))
			return 0.0
		end
	
	-- Ignore all non-enemy targets.
	else
		return 0.0
	end
	
	log("\tScore_Base_Response_Target(%s) called, returning %g", Describe_Target(ai_target), score)
	return score
end



-- Start_New_Defense_Goal -
--
-- Returns a BlockingObject representing the spawned sub-goal, or nil
-- if the sub-goal was not created.
function Start_New_Defense_Goal()
	log("Start_New_Defense_Goal")
	
	-- Default parameters we'll use to spawn our sub-goals.
	local subgoal_script_name = "Generic_Defend"
	local subgoal_target = nil
	local subgoal_user_data = SUBGOAL_UNIQUE_ID
	local arbitrary_data = {}		-- arbitrary data stuffed in the ACTIVE_SUBGOALS table that lets us remember things about specific sub-goals
	
	-- Should we look for enemies actively attacking our base?
	local num_active_base_response_subgoals = Count_Num_Active_Base_Response_Subgoals()
	if num_active_base_response_subgoals < MAX_BASE_RESPONSE_SUBGOALS then
		--
		-- See if there are any enemy units near our base structures.
		--

		-- Before we try to score our targets, we need to make sure we have an up-to-date view
		-- view of the map. Only really necessary for computing clusters of immobile base structures,
		-- which is only needed for reacting to base assaults.
		local rescan_time_in_secs = 30.0
		if (GetCurrentTime() - LAST_MAP_ANALYSIS_TIME  >= rescan_time_in_secs) or (LAST_MAP_ANALYSIS_TIME <= 0.0) then
			PLAYER_BASE_CLUSTERS = Analyze_Map()
		end
	
		-- Score all known AI targets to see if any of them represent visible enemy objects that are
		-- within striking distance of our base structures.
		local enemy_target = Find_Best_Target(Player, Score_Base_Response_Target)
		if enemy_target ~= nil then
			-- We'll fire off a sub-goal to attack that target!
			-- TODO: Different sub-goal other than Generic_Defend for this purpose?
			subgoal_target = enemy_target
			arbitrary_data = { SubgoalCategory="BaseResponse" }
		else
			--log("No suitable base response target found.")
			Sleep(0.7)
		end
	end
	
	-- If we weren't allowed to (or couldn't) formulate a plan to respond to a base assault,
	-- go for the standard defense plan.
	if subgoal_target == nil then
	
		-- Should we create a new standard defense plan or reserve a slot in our allowance
		-- for reacting to base assaults?
		local num_allowed_generics = MAX_CONCURRENT_SUBGOALS - MAX_BASE_RESPONSE_SUBGOALS
		local num_current_generics = Goal.Get_Sub_Goal_Count() - num_active_base_response_subgoals
		if num_current_generics >= num_allowed_generics then
			return nil
		end
	
		-- Search for a base structure to go protect for a little while.
		local defense_target = Find_Best_Target(Player, Score_Defense_Target)
		if defense_target then
			subgoal_target = defense_target
			arbitrary_data = { SubgoalCategory="BaseDefense" }
		else
			log("No suitable defense target found.")
		end
	end
	
	-- Any valid goals formulated out of that process?
	if subgoal_target == nil then
		return nil
	end

	-- Spawn a sub-goal to go protect (or assault) that target!
	log("Activating new %s sub-goal with target: %s and user data: %s", subgoal_script_name, Describe_Target(subgoal_target), tostring(subgoal_user_data))
	local blocking_object = Goal.Activate_Sub_Goal(subgoal_script_name, subgoal_target, subgoal_user_data)
	if blocking_object then
		Record_New_Active_Subgoal(subgoal_user_data, blocking_object, subgoal_script_name, subgoal_target, subgoal_user_data, arbitrary_data)
		SUBGOAL_UNIQUE_ID = SUBGOAL_UNIQUE_ID + 1.0
	end
	return blocking_object
end


-- Analyze_map - Analyze the positions of immobile base structures and break
-- them down into clusters, to help us prioritize attacking enemy forces (we
-- want to attack enemy forces that are close to our base structures). This
-- analysis is conducted repeatedly, but infrequently.
--
-- Returns a table containing PositionWrappers (result of Find_Clusters())
-- that identify locations of the map of which we already have knowledge.
function Analyze_Map()
	log("Analyze_Map")
	
	local player_base_clusters = {}

	-- Find all immobile allied base structures.
	local base_structures = Find_Objects_With_Behavior(BEHAVIOR_GROUND_STRUCTURE, Player)
	if base_structures then
		local remove_keys = {}
		for k,v in pairs(base_structures) do
			if v.Can_Move() then
				table.insert(remove_keys, k)
			end
		end
		for _,v in pairs(remove_keys) do
			--log("\tRemoving base_structures[%s] = %s because it is mobile.", tostring(v), tostring(base_structures[v]))
			base_structures[v] = nil
		end
		log("\tImmobile Base Structures:")
		--table.foreach(base_structures, show_table)
		Sleep(0.1)
		
		-- Break the found objects up into clusters.
		local base_clusters = Find_Clusters(base_structures)
		if base_clusters then
			player_base_clusters = base_clusters
			--log("\tBase Clusters:")
			--table.foreach(base_clusters, show_table)
		else
			--log("\tBase Clusters: none")
		end
	else
		--log("\tBase Structures: none")
	end
	
	LAST_MAP_ANALYSIS_TIME = GetCurrentTime()
	return player_base_clusters
end


-- Count_Num_Active_Base_Response_Subgoals - Count the number of currently
-- active "base response" subgoals. Those are the goals that wait for enemy
-- units to come into range of our base, and then attack.
function Count_Num_Active_Base_Response_Subgoals()
	if ACTIVE_SUBGOALS == nil then
		return 0
	end
	local active_base_response_subgoals = 0
	for _,subgoal in pairs(ACTIVE_SUBGOALS) do
		if subgoal.ArbitraryData ~= nil then
			if subgoal.ArbitraryData.SubgoalCategory == "BaseResponse" then
				active_base_response_subgoals = active_base_response_subgoals + 1
			end
		end
	end
	log("%d active base response subgoals.", active_base_response_subgoals)
	return active_base_response_subgoals
end
