-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Extend_To_Resource.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Extend_To_Resource.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 83065 $
--
--          $DateTime: 2007/09/07 10:57:57 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

command_center = nil
building_a_tower = false
build_position = nil
tower_type = nil
collector_type = nil
tower_list = {}

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AINovusTower.txt"
end

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "NOVUS") then
		Goal.Suppress_Goal()
		return 0.0
	end

	-- Only start the goal with the nil object
	if Target then
	
		local target_type = Target.Get_Target_Type()
	
		Goal.Suppress_Goal()
		return 0.0
	end

	-- must keep desire up
	return 1.0
	
end

function Score_Unit(unit)

	if building_a_tower or build_position ~= nil then
		return 0.0
	end

	if not TestValid(unit) then
		return 0.0
	end
	
	if unit.Get_Owner() ~= Player then
		return 0.0
	end	

	-- Get the unit's object type.
	local unit_type = unit.Get_Type()
	if not unit_type then
		return 0.0
	end

	-- this is who we return to
	if unit_type.Get_Type_Value("Is_Command_Center") then
		command_center = unit
		return 0.0
	end
	
	if unit_type == collector_type then
	
		local script = unit.Get_Script()
		local resource_drone_target = nil
		
		if script ~= nil then
			resource_drone_target = script.Get_Variable("resource_drone_target")
		end
		
		if unit.Is_Ability_Active("Gather_Resources_Visual_Ability") then
			Set_Tower_Position( unit )
			return 0.0
		end
		
		if TestValid( resource_drone_target ) then
			Set_Tower_Position( resource_drone_target )
		end
	end
	
	return 0.0

end

function Set_Tower_Position( unit )

	if TestValid(build_position) then
		return
	end

	local close_list = Find_All_Objects_Of_Type( unit, 210.0, "CanAttack | Stationary + ~Insignificant + ~Bridge | Resource | Resource_INST" )	
	
	local resources = 0
	local resource_obj = nil
	local resource_qty_best = 0.0
	
	if close_list then
		for _, object in pairs( close_list ) do
			if TestValid( object ) then
				if object.Get_Owner() == Player and object.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) then
					return
				end
				
				local resource_amt = Get_Resource_Value( object )
				
				if object.Is_Enemy(Player) and not object.Is_Category("Resource_INST | Resource") and not object.Has_Behavior( BEHAVIOR_DEBRIS ) and
					(object.Has_Behavior( BEHAVIOR_GROUND_STRUCTURE ) or object.Has_Behavior( BEHAVIOR_TARGETING )) then
					return
				end
				
				resources = resources + resource_amt
				
				if resource_amt > resource_qty_best then
					resource_qty_best = resource_amt
					resource_obj = object 
				end
			end
		end
	end

	if resources < 1500.0 then
		return
	end

	local target_position
	local target_obj
	if TestValid( resource_obj ) then
		target_position = resource_obj.Get_Position()
		target_obj = resource_obj
	else
		target_position = unit.Get_Position()
		target_obj = unit
	end

	if tower_list then
		for _, position in pairs( tower_list ) do
			if target_obj.Get_Distance( position ) <= 200.0 then
				-- we are building a tower here abort
				return
			end
		end
	end

	build_position = target_position

	-- to prevent destruction of the resource
	if TestValid(target_obj) and TestValid(command_center) then
		local target_type = target_obj.Get_Type()
		if TestValid(target_type) then
			local size = target_type.Get_Hard_Coord_Radius()
			local com_range = command_center.Get_Distance(target_position)
			if com_range - size - 75.0 > 150.0 then
				local final_position = Project_Position(command_center,target_position,	com_range-size-tower_type.Get_Hard_Coord_Radius() - 75.0 )
				if TestValid(final_position) then
				
					if tower_list then
						for _, position in pairs( tower_list ) do
							if final_position.Get_Distance( position ) <= 200.0 then
								-- we will be building a tower here abort
								build_position = nil
								return
							end
						end
					end
				
					build_position = final_position
				end
			end
		end
	end
	
end

function On_Activate()


	-- ok we can start
	command_center = nil
	building_a_tower = false
	build_position = nil
	tower_type = Find_Object_Type("Novus_AI_Signal_Tower")
	collector_type = Find_Object_Type("Novus_Collector")
	tower_list = {}

	log("Novus_Extend_To_Resource activated.")
	Create_Thread("Building_Towers")
	

end

function Building_Towers()

	log("Novus_Extend_To_Resource Building_Towers started.")

	-- Keep looping forever.
	while true do
	
		if not building_a_tower and TestValid(command_center) then
			
			if build_position ~= nil then
				log("Novus_Extend_To_Resource: Starting Build_Tower Thread")
				building_a_tower = true
				Create_Thread("Build_Tower")
			end
	
		end
		
		Sleep(1.0)
		
	end

end

function Get_Resource_Value( object )

	if not TestValid( object ) then
		return 0.0
	end
	
	local value = object.Resource_Get_Resource_Units()
	
	if value == nil then
		return 0.0
	end
	
	local object_type = object.Get_Type()
	
	if object_type == nil or not object_type.Resource_Is_Valid_For_Faction("Novus") then
		return 0.0
	end

	if object.Is_Category("Resource_INST") then
		value = value / 4.0
	end
	
	return value

end

function Build_Tower()

	if not TestValid(command_center) then
		building_a_tower = false
		build_position	= nil
		return
	end

	local final_build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( build_position , tower_type, Player ))

	if tower_list then
		for _, position in pairs( tower_list ) do
			if final_build_position.Get_Distance( position ) <= 200.0 then
				-- we are building a tower here abort
				final_build_position = nil
				break
			end
		end
	end

	if not TestValid(final_build_position) then
		building_a_tower = false
		build_position	= nil
		log("Novus_Extend_To_Resource: Build_Tower is a failure or we already have a build scheduled nearby.")
		return
	end

	log("Novus_Extend_To_Resource: Build_Tower is a go.")
	
	building_a_tower = true
	
	local goal_build_target = Goal.Create_Custom_Target(final_build_position)
	Sleep(0.5)
--	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, tower_type))

	Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, tower_type)

	if tower_list ~= nil then
		table.insert(tower_list, final_build_position)
	end
	
	building_a_tower = false
	build_position	= nil
	
end

