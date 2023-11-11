-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGAICommands.lua#29 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGAICommands.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 80625 $
--
--          $DateTime: 2007/08/10 15:58:31 $
--
--          $Revision: #29 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGLogging")

--[[
function Fix_Dependencies(player, goal, type)

	missing_dependencies = player.Get_Missing_Build_Dependencies(type)
	if not missing_dependencies then
		return
	end
	
	if #missing_dependencies == 0 then
		return
	end
	
	for _, builder in pairs(missing_dependencies) do
		if TestValid(builder.Get_Type_Value("Tactical_Buildable_Beacon_Type")) then
			goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", nil, builder)
		elseif builder.Has_Behavior(BEHAVIOR_HARD_POINT, "Land") then
			goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", nil, builder)
		end
	end
	BlockOnCommand(goal.Wait_For_All_Sub_Goals())
end
]]--

-- Fix_Tactical_Dependencies - Figure out which (if any) tactical structures/units need to
-- be build in order for us to build the given 'object_type'. Given that list, activate
-- some production subgoals to go build them, and wait for those subgoals to finish.
function Fix_Tactical_Dependencies(player, goal, object_type)

	-- What are we missing in order to build that object type? We only care about things
	-- we can build in tactical mode.
	-- This will return two values: table, bool
	-- The bool is 'true' if we can 
	-- The table is formatted like so:
	-- {
	--   { { type1, missing_count1 }, { type2, missing_count2 } }	-- you need missing_count1 of type1 AND missing_count2 of type2
	--   { { type3, missing_count3 }, { type4, missing_count4 } }	-- OR both missing_count3 of type3 AND missing_count4 of type4
	--   { { type5, missing_count5 } }										-- OR missing_count5 of type5
	-- }
	-- Any type defined as requirements in XML that the player has already built are not
	-- returned (so we don't double-build them). When we are given a table with multiple
	-- possibilities (many OR entries), we'll just choose randomly between them.
	local missing_dependencies, currently_buildable = player.Get_Missing_Tactical_Build_Dependencies(object_type)
	if currently_buildable == false then
		log("Fix_Tactical_Dependencies - Type %s is not currently buildable and its prereqs cannot be met.", tostring(object_type))
		return
	end
	
	-- currently_buildable == true and no missing dependencies? Then nothing to fix up!
	if (not missing_dependencies) or (#missing_dependencies == 0) then
		return
	end

	-- KDB if there is a table that has the least number of entries do that one 1st
	-- This should cure building of extra command centers etc
	local low_count = 999999.0
	local best_index = 1
	for index,missing_table in pairs(missing_dependencies) do
		if #missing_table < low_count then
			low_count = #missing_table
			best_index = index
		end
	end
	
--	log("List of missing types we will construct in order to build %s:", tostring(object_type))
--	table.foreach(missing_dependencies[random_index], show_table)
	
	-- Activate a subgoal for each required type in the chosen entry.
	for _,required_type_table in pairs(missing_dependencies[best_index]) do
		if TestValid(required_type_table[1].Get_Type_Value("Tactical_Buildable_Beacon_Type")) then
			if required_type_table[2] < 2 then
				goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", nil, required_type_table[1])
			else
				goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", nil, required_type_table)
			end				
		elseif required_type_table[1].Has_Behavior(BEHAVIOR_HARD_POINT, "Land") then
			--Verify that this is a buildable type
			if TestValid(required_type_table[1].Get_Type_Value("Tactical_Under_Construction_Object_Type")) then
				if required_type_table[2] < 2 then
					goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", nil, required_type_table[1])
				else
					goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", nil, required_type_table)
				end
			end
		else
			--Verify this is a buildable type
			if required_type_table[1].Get_Type_Value("Tactical_Build_Time_Seconds") > 0 then
				if required_type_table[2] < 2 then
					goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Unit", nil, required_type_table[1])
				else
					goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Unit", nil, required_type_table)
				end
			end			
		end
	end
	BlockOnCommand(goal.Wait_For_All_Sub_Goals())
end


function Place_And_Build_Structure(player, tf, structure, build_position)
	local build_angle = 0.0

	if not build_position then
		build_position, build_angle = player.Find_Recommended_Structure_Position_And_Angle(structure)
		if not build_position then
			build_position = tf.Get_Centroid()
		end
	end
	
	if not build_angle then
		build_angle = 0.0
	end
	
	build_position = BlockOnCommand(Find_Nearest_Open_Build_Position(build_position, structure, player, build_angle))
	if build_position then
		if player.Can_Produce_Object(structure) then
			local block = tf.Build_Structure(structure, build_position, build_angle)
			if block ~= nil then
				BlockOnCommand(block)
			else
				log("Place_And_Build_Structure - Type %s can not be placed, trying random area close to target.", tostring(structure))
				build_angle = 0.0
				build_position.Set_Position_X( build_position.Get_Position_X() + 20.0 - GameRandom(0.0, 40.0) )
				build_position = BlockOnCommand(Find_Nearest_Open_Build_Position(build_position, structure, player, build_angle))
				if build_position then
					if player.Can_Produce_Object(structure) then
						BlockOnCommand(tf.Build_Structure(structure, build_position, build_angle))
					end
				end
			end
		end
	end
	
end

function Get_Distance_Based_Unit_Score(tf, unit)
	
	local centroid = nil
	if #tf.Get_Unit_Table() > 0 then
		centroid = tf.Get_Centroid()
	elseif #tf.Get_Potential_Unit_Table() then
		centroid = tf.Get_Potential_Centroid()
	else
		return 1.0
	end
	
	local distance = unit.Get_Distance(centroid)
	if distance > 0.0 then
		return 1.0 / distance
	else
		return 1.0
	end
	
end

function Calculate_Task_Force_Speed(tf)

	local avg_speed = 0.0
	for _, unit in pairs(tf.Get_Unit_Table()) do
		avg_speed = avg_speed + unit.Get_Type().Get_Type_Value("Max_Speed")
	end
	
	for _, unit in pairs(tf.Get_Potential_Unit_Table()) do
		avg_speed = avg_speed + unit.Get_Type().Get_Type_Value("Max_Speed")
	end
	
	local total_units = #tf.Get_Unit_Table() + #tf.Get_Potential_Unit_Table()
	if total_units > 0 then
		return avg_speed / total_units
	else
		return nil
	end
	
end

function Find_Builder_Hard_Point(parent, uc_type)

	local all_hard_points = parent.Get_All_Hard_Points()
	if not all_hard_points then
		return nil
	end
	
	for _, hp in pairs(all_hard_points) do
		if Can_Build_Hard_Point(hp, uc_type) then
			return hp
		end
	end
	
	return nil
	
end

function Can_Build_Hard_Point(socket, uc_type)
	
	if TestValid(socket.Get_Build_Pad_Contents()) then
		return false
	end

--	local buildable_hp_types = socket.Get_Type().Get_Tactical_Buildable_Objects()
	local buildable_hp_types = socket.Get_Tactical_Hardpoint_Upgrades()
	if not buildable_hp_types then
		return false
	end
	
	for _, hp_type in pairs(buildable_hp_types) do
		if hp_type == uc_type then
			return true
		end
	end	
	
	return false
end

function Suppress_Nearby_Goals(origin, radius, script_name, duration)

	local nearby_targets = Goal.Find_Targets_Within_Radius(origin, radius)
	for _, other_target in pairs(nearby_targets) do
		if other_target ~= Target then
			Goal.Suppress_Goal(other_target, script_name, duration)
		end
	end

end

-- AJA 12/09/2006 - Returns a formatting string describing the given AITarget.
function Describe_Target(ai_target)
	if not TestValid(ai_target) then
		return "Nil Target"
	end
	if not ai_target.Is_Valid() then
		return "Invalid Target"
	end

	local target_type_string = ai_target.Get_Target_Type()
	
	-- If it's an Object Group, add the size of the group to the string.
	if target_type_string == "Object_Group" then
		target_type_string = target_type_string .. "(" .. ai_target.Get_Group_Target_Size() .. ")"
	end

	-- Format the string, including the target name, type and position.
	local target_position = ai_target.Get_Target_Position()
	local target_string = string.format("AITarget[%s, %s, (%f,%f,%f)]", tostring(ai_target), target_type_string, tostring(target_position.Get_Position_X()), tostring(target_position.Get_Position_Y()), tostring(target_position.Get_Position_Z()))

	return target_string
end


--
-- AJA 01/25/2007
-- Verify_Resource_Object - Checks if the given object is an alien harvestable resource, and if so
-- it returns a number of descriptive things about that resource.
-- Usage: is_valid_resource, is_single_use, is_reserved = Verify_Resource_Object(obj)
--
function Verify_Resource_Object(resource_object, player)
	local is_valid_resource = false
	local is_single_use = false
	local is_reserved = false
	
	-- Valid object?
	if not TestValid(resource_object) or not TestValid(player) then
		return is_valid_resource, is_single_use, is_reserved
	end

	-- Check if the object is a valid resource for the given player.
	if not resource_object.Get_Type().Resource_Is_Valid_For_Faction(player) then
		return is_valid_resource, is_single_use, is_reserved
	else
		is_valid_resource = true
	end
	
	-- Is this resource empty?
	local resource_units = resource_object.Resource_Get_Resource_Units()
	if resource_units <= 0 then
		is_valid_resource = false
	end

	-- We now know it's a valid resource object. Is it a single-use resource (like a cow or a tree)?
	is_single_use = resource_object.Get_Type().Get_Type_Value("Is_Single_Resource")

	-- Does a gatherer already have it reserved for harvesting?
	local reserved_table = resource_object.Resource_Get_Reserved_For_Harvesting()
	if reserved_table then
		if reserved_table[player.Get_ID()] then
			if reserved_table[player.Get_ID()].Used then
				is_reserved = reserved_table[player.Get_ID()].Used
			end
		end
	end

	-- Return what we know!
	return is_valid_resource, is_single_use, is_reserved
end


