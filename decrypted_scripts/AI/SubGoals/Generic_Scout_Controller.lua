-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Scout_Controller.lua#20 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Scout_Controller.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 83822 $
--
--          $DateTime: 2007/09/14 12:04:18 $
--
--          $Revision: #20 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGVectorMath")
require("PGGoalController")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------
local MAP_BOUNDS_MIN = { x=0, y=0, z=0 }
local MAP_BOUNDS_MAX = { x=0, y=0, z=0 }
local SUBGOAL_UNIQUE_ID = 1				-- gets incremented each time we spawn a sub-goal
local MAX_CONCURRENT_SUBGOALS = 3		-- can't have more than this number of sub-goals active at a time

function Definitions()
	SUBGOAL_UNIQUE_ID = 1
	MAX_CONCURRENT_SUBGOALS = 3

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIScoutLog.txt"
end



---------------------- Goal Events and Queries ----------------------

-- The Generic Scout Controller Goal only has one instance, which is
-- activated as a sub-goal of the Master_Unit_Goal_Controller.
-- It spawns sub-goals (of the Generic_Scout script type) to actually
-- execute its specific scouting plans.
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
	-- Once, on startup, we get the map bounds and save them to global tables with x,y,z members.
	local min_pos_wrapper, max_pos_wrapper
	min_pos_wrapper, max_pos_wrapper = Get_Map_Bounds()
	MAP_BOUNDS_MIN = { x = min_pos_wrapper.Get_Position_X(), y = min_pos_wrapper.Get_Position_Y(), z = min_pos_wrapper.Get_Position_Z() }
	MAP_BOUNDS_MAX = { x = max_pos_wrapper.Get_Position_X(), y = max_pos_wrapper.Get_Position_Y(), z = max_pos_wrapper.Get_Position_Z() }
	log("Map Bounds: min(" .. tostring(min_pos_wrapper) .. "), max(" .. tostring(max_pos_wrapper) .. ")")
	
	-- Initialize our max concurrent sub-goals value from the UserData we were given.
	local user_data = Goal.Get_User_Data()
	if user_data ~= nil and user_data.MaxConcurrentSubgoals ~= nil then
		MAX_CONCURRENT_SUBGOALS = user_data.MaxConcurrentSubgoals
		log("MAX_CONCURRENT_SUBGOALS initialized to %g", MAX_CONCURRENT_SUBGOALS)
	end

	-- Launch the thread we use to do all the work.
	log("Generic_Scout_Controller activated. Scout_The_Map thread created.")
	Create_Thread("Scout_The_Map")
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
-- to explore parts of the map we deem interesting.
function Scout_The_Map()

	-- All times in seconds
	local current_time = 0
	local last_analysis_time = 0
	local min_time_between_analysis_runs = 71
	local last_subgoal_creation_time = 0
	local min_time_between_subgoal_creations = 23
	
	local already_known_locations = {}

	-- Keep looping forever.
	while true do
	
		if Player.Get_Difficulty() == "Difficulty_Easy" then
			MAX_CONCURRENT_SUBGOALS = 1
			
			if GetCurrentTime() < 180.0 then
				Sleep(180.0-GetCurrentTime())
			end
		elseif Player.Get_Difficulty() ~= "Difficulty_Hard" then
			if GetCurrentTime() < 90.0 then
				Sleep(90.0-GetCurrentTime())
			end
		end
	
		-- Is it time to update our view of the map?
		current_time = GetCurrentTime()
		if ( last_analysis_time == 0) or (current_time - last_analysis_time > min_time_between_analysis_runs) then
			-- Analyze the map (this may take multiple seconds to perform).
			already_known_locations = Analyze_Map()
			
			-- Record the current time as the last time we did this process.
			current_time = GetCurrentTime()
			last_analysis_time = current_time
		end
		
		-- Is it time to try to start a new scouting sub-goal?
		if (last_subgoal_creation_time == 0) or (current_time - last_subgoal_creation_time > min_time_between_subgoal_creations) then
			-- Can we actually create a new subgoal and stay under our limit
			-- for the max number of instances?
			local num_active_subgoals = Goal.Get_Sub_Goal_Count()
			if num_active_subgoals < MAX_CONCURRENT_SUBGOALS then
				-- Try to activate a new scouting sub-goal. This may take
				-- many seconds to complete. Returns nil if no new sub-goal
				-- could be created, or a blocking object for that sub-goal
				-- if successful.
				local subgoal_block = Start_New_Scouting_Task(already_known_locations)
				if subgoal_block then
					log("New scouting sub-goal created!")
					
					-- Record this as the time we spawned our last scouting sub-goal.
					current_time = GetCurrentTime()
					last_subgoal_creation_time = current_time
				else
					log("Failed to create a new scouting sub-goal.")
				end
			end
		end
		
		-- Wait at least one second before looping.
		Sleep(1)
	end

	log("Scout_The_Map thread is exiting!!")
end


-- Score the given AITarget, in order to figure out what we should be scouting
function Score_Scout_Target(ai_target)

	if not ai_target then
		return 0.0
	end

	--log( "Score_scout_Targets : Trying to score %s", Describe_Target(ai_target) )
	
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
		--log("Score_Scout_Targets(%s) called, rejecting target because it is already claimed by another sub-goal", Describe_Target(ai_target))
		return 0.0
	end

	local hi_score = 1.0

	-- Ignore all individual Game Objects that are not base structures.
	if target_type == "Game_Object"  then
		target_unit = ai_target.Get_Game_Object()
		
		if not TestValid( target_unit ) then
			return 0.0
		end
		
		local unit_type = target_unit.Get_Type()
		if not unit_type then
			return 0.0
		end
		
		if target_unit.Is_Category("Insignificant + Stationary | Resource | Resource_INST | Bridge") then
			return 0.0
		end
		
		if target_unit.Is_Cloaked() then
			return 0.0
		end
		
		-- don't target units that are garrisoned
		if TestValid(target_unit.Get_Garrison()) then
			return 0.0
		end
	
		-- 5x chance to scout structures
		hi_score = hi_score * 3.0 
		
		if target_unit.Is_Category("Huge + CanAttack") then
			-- go after walkers
			hi_score = hi_score * 3.0
		end
		
		if unit_type.Get_Type_Value("Is_Command_Center") then
				-- scout command centers more often
				hi_score = hi_score * 2.0
			if TestValid(SwObject) then
				-- increase chance to scout command center when SW is ready
				hi_score = hi_score * 10.0
			end
		end
		
		if unit_type.Get_Type_Value("Is_Resource_Collector") then
			-- scout their resource collectors more often
			hi_score = hi_score * 1.5
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
			
				hi_score = hi_score * dif_mod
			end
		end
	
	else
		-- if nothing in the group is visible then don't target it
		if ai_target.Get_Group_Target_Size() < 1 then
			return 0.0
		end
	end

	-- randomize the score
	local score = 0.1 + GameRandom.Get_Float( 0.0, hi_score )
	
	--log("Score_Scout_Target(%s) called, returning %g", Describe_Target(ai_target), score)
	return score
end


-- Analyze_map - Analyze the positions of friendly objects and break them
-- down into clusters to help us pick sensible locations to explore. We'd
-- want to explore areas of the map that are distant from current friendly
-- objects. This analysis is conducted repeatedly, but infrequently.
--
-- Returns a table containing PositionWrappers (result of Find_Clusters())
-- that identify locations of the map of which we already have knowledge.
function Analyze_Map()
	log("Analyze_Map")
	
	local player_base_clusters = {}
	local player_unit_clusters = {}

	-- Find all allied base structures. We want to scout areas of the map
	-- away from these objects.
	local base_structures = Find_Objects_With_Behavior(BEHAVIOR_GROUND_STRUCTURE, Player)
	if base_structures then
		--log("Base Structures:")
		--table.foreach(base_structures, show_table)
		Sleep(1)
		
		-- Break the found objects up into clusters.
		local base_clusters = Find_Clusters(base_structures)
		if base_clusters then
			player_base_clusters = base_clusters
			--log("Base Clusters:")
			--table.foreach(base_clusters, show_table)
		else
			--log("Base Clusters: none")
		end
	else
		--log("Base Structures: none")
	end
	
	Sleep(1)

	player_unit_clusters = {}

	-- Collate the various known locations into one table.
	local final_results = {}
	for _,v in pairs(player_base_clusters) do
		table.insert(final_results, v)
	end
	for _,v in pairs(player_unit_clusters) do
		table.insert(final_results, v)
	end
	--log("Final Result Clusters:")
	--table.foreach(final_results, show_table)
	return final_results
end


-- Start_New_Scouting_Task - Choose a sensible location on the map to
-- explore, and start a new sub-goal to go explore it.
--
-- Returns a BlockingObject representing the spawned sub-goal, or nil
-- if the sub-goal was not created.
function Start_New_Scouting_Task(already_known_locations)
	log("Start_New_Scouting_Task")

	-- First as the human will have an idea of where to scout so will we at 80% of the time (reduce by difficulty)
	local find_enemy = GameRandom.Get_Float(0,1.0)
	
	local scout_target = nil
	SwObject = nil
	
	if find_enemy <= 0.7 then
	
		local player_script = Player.Get_Script()
		if player_script ~= nil then
			SwObject = player_script.Call_Function("SW_Get_Ready_Weapon",nil)
		end
	
		scout_target = Find_Best_Target(Player, Score_Scout_Target, true )	-- last parameter tells it to look at even hidden objects
		
	else
	
		-- Try to choose a sensible location to scout. If we do not find a
		-- good location, we're done. We'll try again soon.
		local scout_location_pt = Choose_Location_To_Scout(already_known_locations)
		if not scout_location_pt then
			log("Choose_Location_To_Scout() returned nil, waiting to try again.")
			return nil
		end
		
		-- Wrap the chosen location in a PositionWrapper.
		local scout_position = Create_Position(scout_location_pt.x, scout_location_pt.y, scout_location_pt.z)
		if not scout_position then
			log("ERROR: Create_Position() returned nil!")
			return nil
		end

		-- Create an AITarget for the new scouting goal.
		scout_target = Goal.Create_Custom_Target(scout_position)
		if not scout_target then
			log("ERROR: Goal.Create_Custom_Target() returned nil!")
			return nil
		end
	end
	
	if not scout_target then
		return nil
	end

	-- Spawn a sub-goal to go explore that location!
	Sleep(0.5)
	local subgoal_name = Choose_Scouting_Subgoal(scout_target)
	local userdata = SUBGOAL_UNIQUE_ID
	SUBGOAL_UNIQUE_ID = SUBGOAL_UNIQUE_ID + 1.0
	log("Activating new %s sub-goal with target: %s and userdata: %s", subgoal_name, Describe_Target(scout_target), tostring(userdata))
	
	local enforce_fog = true
	local enforce_chance = 50
	
	if Player.Get_Difficulty() == "Difficulty_Easy" then
		enforce_chance = 20
	elseif Player.Get_Difficulty() == "Difficulty_Hard" then
		enforce_chance = 90
	end
	
	if GameRandom(0,100) <= enforce_chance then
		enforce_fog = false
	end
	
	local block = Goal.Activate_Sub_Goal(subgoal_name, scout_target, userdata, true, enforce_fog )
	return block
end

--
-- Choose_Scouting_Subgoal - Choose a goal to go explore the given target area.
-- Returns the name of the chosen scouting script.
--
function Choose_Scouting_Subgoal(scout_target)
	return "Generic_Scout"
end


-- Choose_Location_To_Scout - Choose a sensible location on the map that
-- we want to go explore. This should be a point that is distant from
-- nearby friendly objects (defined by the locations_to_avoid parameter).
--
-- Returns a table with x,y,z members defining the point to go scout.
function Choose_Location_To_Scout(locations_to_avoid)

	-- Choose a random location within the boundaries of the map as
	-- a starting point. We will refine it below.
	local random_point = {}
	random_point.x = GameRandom.Get_Float(MAP_BOUNDS_MIN.x, MAP_BOUNDS_MAX.x)
	random_point.y = GameRandom.Get_Float(MAP_BOUNDS_MIN.y, MAP_BOUNDS_MAX.y)
	random_point.z = 0.0		-- z doesn't really matter, should be based on terrain height at that point ideally
	--log("Generated random map point (%f,%f,%f)", random_point.x, random_point.y, random_point.z)
	
	-- 'Push' the random point based on its proximity to each of the points
	-- in the locations_to_avoid. Strongers push from close locations.
	local pushed_point = Repel_Position_From_Given_Locations(random_point, locations_to_avoid)
	if not pushed_point then return nil end
	
	-- If the pushed point is outside the map, it's a bad location.
	if pushed_point.x < MAP_BOUNDS_MIN.x or pushed_point.x > MAP_BOUNDS_MAX.x or
		pushed_point.y < MAP_BOUNDS_MIN.y or pushed_point.y > MAP_BOUNDS_MAX.y then
		--log("Rejecting pushed point (%f,%f,%f) because it is outside the map boundaries", pushed_point.x, pushed_point.y, pushed_point.z)
		return nil
	end
	
	-- Push the point towards the interior of the map if it's too close
	-- to a map edge.
	local edge_padding = 400.0
	if pushed_point.x < MAP_BOUNDS_MIN.x + edge_padding then
		pushed_point.x = pushed_point.x + edge_padding
		--log("Adjusted pushed point X coordinate by +%f to stay away from map edges", edge_padding)
	elseif pushed_point.x > MAP_BOUNDS_MAX.x - edge_padding then
		pushed_point.x = pushed_point.x - edge_padding
		--log("Adjusted pushed point X coordinate by -%f to stay away from map edges", edge_padding)
	end
	if pushed_point.y < MAP_BOUNDS_MIN.y + edge_padding then
		pushed_point.y = pushed_point.y + edge_padding
		--log("Adjusted pushed point Y coordinate by +%f to stay away from map edges", edge_padding)
	elseif pushed_point.y > MAP_BOUNDS_MAX.y - edge_padding then
		pushed_point.y = pushed_point.y - edge_padding
		--log("Adjusted pushed point Y coordinate by -%f to stay away from map edges", edge_padding)
	end
	
	--log("Returning final scout location of (%f,%f,%f)", pushed_point.x, pushed_point.y, pushed_point.z)
	return pushed_point
end


-- Repel_Position_From_Given_Locations - Given a position (table with x,y,z
-- numeric members) and a table of locations (PositionWrappers), push the
-- position away from each location by a magnitude that depends on their
-- proximity (closer is pushed harder) and a direction directly away from
-- that location.
--
-- Returns the adjusted position (table with x,y,z members).
function Repel_Position_From_Given_Locations(position, locations)
	local total_push_vector = { x=0, y=0, z=0 }
	
	local REPULSION_MIN_DISTANCE = 100.0		-- if position is this distance or closer to a location, it gets pushed away as hard as possible
	local REPULSION_MAX_DISTANCE = 500.0		-- if position farther than this distance from a location, it doesn't get pushed at all
	local REPULSION_AT_MIN_DISTANCE = 500.0	-- hardest pushing force (at <= REPULSION_MIN_DISTANCE)
	local REPULSION_AT_MAX_DISTANCE = 20.0	-- softest pushing force (at REPULSION_MAX_DISTANCE)
	
	local REPULSION_MIN_DISTANCE_SQ = REPULSION_MIN_DISTANCE * REPULSION_MIN_DISTANCE
	local REPULSION_MAX_DISTANCE_SQ = REPULSION_MAX_DISTANCE * REPULSION_MAX_DISTANCE
	
	-- Calculate a 'push_vector' for each location, and sum them together in 'total_push_vector'.
	local push_vector = { x=0, y=0, z=0 }
	local loc_x = 0.0
	local loc_y = 0.0
	for _,loc in pairs(locations) do
		push_vector.x = 0.0
		push_vector.y = 0.0
		push_vector.z = 0.0
		loc_x = loc.Get_Position_X()
		loc_y = loc.Get_Position_Y()
		
		-- Calculate the direction vector from loc to position (this is the direction we want to push).
		local direction_vector = { x=(position.x - loc_x), y=(position.x - loc_y), z=0.0 }
		
		-- Calculate the distance (squared) from 'position' to 'loc'.
		local distance_squared = direction_vector.x * direction_vector.x + direction_vector.y * direction_vector.y
		
		-- Normalize the direction vector for ease of push magnitude application.
		direction_vector = PG_Vector_Normalize(direction_vector)
		
		-- Close enough to apply maximum push?
		if distance_squared <= REPULSION_MIN_DISTANCE_SQ then
		
			push_vector = PG_Vector_Multiply_Scalar(direction_vector, REPULSION_AT_MIN_DISTANCE)
			--log("push_vector below is a DirectionVector(%f,%f,%f) with magnitude(%f)",
			--	direction_vector.x, direction_vector.y, direction_vector.z, REPULSION_AT_MIN_DISTANCE)
				
		-- Close enough to apply any push?
		elseif distance_squared <= REPULSION_MAX_DISTANCE_SQ then
		
			-- How far into the range is it?
			local percentage = (distance_squared - REPULSION_MIN_DISTANCE_SQ) / (REPULSION_MAX_DISTANCE_SQ - REPULSION_MIN_DISTANCE_SQ)
			local repulsion_magnitude = (REPULSION_AT_MAX_DISTANCE - REPULSION_AT_MIN_DISTANCE) * percentage + REPULSION_AT_MIN_DISTANCE
			push_vector = PG_Vector_Multiply_Scalar(direction_vector, repulsion_magnitude)
			--log("push_vector below is a DirectionVector(%f,%f,%f) with magnitude(%f)",
			--	direction_vector.x, direction_vector.y, direction_vector.z, repulsion_magnitude)
				
		end
		
		-- Push has been calculated, add it to the vector total.
		--log("Position(%f,%f,%f) repelled by Location(%f,%f,%f) with a push_vector of (%f,%f,%f)",
		--	position.x, position.y, position.z, loc_x, loc_y, 0.0, push_vector.x, push_vector.y, push_vector.z)
		total_push_vector = PG_Vector_Add(push_vector, total_push_vector)
	end

	-- Adjust the position by the total push vector to get the final adjusted position.
	local final_position = PG_Vector_Add(position, total_push_vector)
--	log("Position(%f,%f,%f) was pushed by (%f,%f,%f) to a final adjusted position of (%f,%f,%f)",
--		position.x, position.y, position.z, total_push_vector.x, total_push_vector.y, total_push_vector.z,
--		final_position.x, final_position.y, final_position.z)
	return final_position
end

