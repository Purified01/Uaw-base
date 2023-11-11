-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Turret_manager.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Turret_manager.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 86515 $
--
--          $DateTime: 2007/10/24 11:49:35 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

local command_center = nil
local build_target = nil
local build_position = nil
local building_a_turret = false
local building_turrets = false

local	turret_type = nil
local	turret_construction = nil
local	turret_beacon = nil
local power_type = nil
local command_type = nil
local air_type = nil
local enemy_command_center = nil

local check_time = 200.0

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AINovusTurret.txt"
end

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "NOVUS") then
		Goal.Suppress_Goal()
		return 0.0
	end

	-- Only start the goal with the nil object
	if Target then
	
		local target_type = Target.Get_Target_Type()
		if target_type and target_type == "Game_Object" then
			local unit = Target.Get_Game_Object()
			if TestValid( unit ) and unit.Is_Enemy(Player) then
				local unit_type = unit.Get_Type()
				if TestValid(unit_type) and unit_type.Get_Type_Value("Is_Command_Center") then
					enemy_command_center = unit
				end
			end
		end
		
		Goal.Suppress_Goal()
		return 0.0
	end

	-- must keep desire up
	return 1.0
	
end

function Score_Unit(unit)

	if not TestValid(unit) then
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
	end

	return 0.0

end

function On_Activate()

	turret_type = Find_Object_Type("Novus_Redirection_Turret")
	turret_construction = Find_Object_Type("Novus_Redirection_Turret_Construction")
	turret_beacon = Find_Object_Type("Novus_Redirection_Turret_Beacon")
	power_type = Find_Object_Type("Novus_Power_Router")
	command_type = Find_Object_Type("Novus_Remote_Terminal")
	air_type = Find_Object_Type("Novus_Aircraft_Assembly")
	science_type = Find_Object_Type("Novus_Science_Lab")
	vehicle_type = Find_Object_Type("Novus_Vehicle_Assembly")

	-- ok we can start
	command_center = nil
	build_target = nil
	build_position = nil
	building_a_turret = false
	building_turrets = true

	if Player.Get_Credits() < 5000.0 then
		-- low cash start !
		check_time = 300.0
	elseif Player.Get_Credits() < 8000.0 then
		-- low cash start !
		check_time = 240.0
	end

	log("Novus_Turret_Manager activated.")
	Create_Thread("Building_Turrets")
	

end

function Building_Turrets()

	log("Novus_Turret_Manager Building_Turrets started.")

	-- Keep looping forever.
	while true do
	
		if building_turrets and not building_a_turret and GetCurrentTime() > check_time then
			
			build_position = Look_For_Turret_Placement()
			
			if TestValid(build_position) then
				log("Novus_Turret_Manager: Starting Build_Turret Thread")
				building_a_turret = true
				Create_Thread("Build_Turret")
			end
			
			check_time = GetCurrentTime() + 5.0
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
	
	return value

end

function Look_For_Turret_Placement()

	if not TestValid( command_center ) then
		return nil
	end
	
	local object_list = Find_All_Objects_Of_Type( command_center, 750.0, Player )	
	Sleep(0.5)
	if object_list ~= nil then
	
		local target_list =  {}		
		local turret_list = {}

		for _, object in pairs(object_list) do
			if TestValid(object) then
				if object.Get_Owner() == Player then
					local object_type = object.Get_Type()
					if object_type ~= nil then
						if object_type == turret_type or object_type ==  turret_construction or object_type == turret_beacon then
							table.insert(turret_list, object)
						elseif object_type == power_type or object_type.Get_Type_Value("Is_Command_Center") or object_type == air_type or object_type == science_type or object_type == vehicle_type then
							table.insert(target_list, object)
						elseif object.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) and object.Get_Health() < 0.9 then
							table.insert(target_list, object)
						end
					end
				end
			end
		end
		Sleep(0.5)
		
		-- all targets and turrets listed
		-- go through targets and eliminate them if there is a turrent nearby

		local final_list = {}
		for index, object in pairs(target_list) do
			local found = false
			local count = 0
			
			for _, turret in pairs(turret_list) do
				if object.Get_Distance( turret ) <= 200.0 then
					count = count + 1
					if object.Get_Type() ~= power_type or count >= 2 then
						found = true
						break
					end
				end
			end
			
			if not found then
				table.insert( final_list, object )
			end
		end
		
		-- check for command center if its in the list return it first
		for _, cmd_object in pairs(final_list) do
			if TestValid( cmd_object ) then
				if command_center == cmd_object then
					return cmd_object.Get_Position()
				end
			end
		end
		
		-- get a random object from the table
		if #final_list > 0 then
			local index = GameRandom( 1, #final_list )
			
			log("Novus_Turret_Manager: Our build next to target is %s.", final_list[index].Get_Type().Get_Name() )
			
			return final_list[index].Get_Position()
		end
		
	end
	
	return nil
	
end

function Look_For_Enemy_Command_Center()
	
	if TestValid( enemy_command_center ) then
		return
	end
	
	local unit_list = Find_All_Objects_Of_Type("Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST")
	Sleep(0.25)
	if unit_list ~= nil then
		for _, unit in pairs (unit_list) do
			if TestValid( unit ) then
				if unit.Is_Enemy(Player) then
					local unit_type = unit.Get_Type()
					if TestValid( unit_type ) then
						if unit_type.Get_Type_Value("Is_Command_Center") then
							enemy_command_center = unit
							return
						end
					end
				end
			end
		end
	end	
	
end

function Build_Turret()

	local final_build_position
	
	Look_For_Enemy_Command_Center()
	
	if not TestValid(build_position) then
		building_a_turret = false
		return
	end
	
	if TestValid( enemy_command_center ) and GameRandom( 0.0, 100.0 ) < 90.0 then
		local turret_position = Project_Position( build_position, enemy_command_center, 150.0 )
		if turret_position == nil then
			turret_position = build_position
		end
		final_build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( turret_position , turret_type, Player ))
	else
		final_build_position = BlockOnCommand(Find_Constrained_Build_Position( build_position, turret_type, Player, build_position, 200.0 ))
	end

	if not TestValid(final_build_position) then
		building_a_turret = false
		log("Novus_Turret_Manager: Build_Turret is a failure.")
		return
	end

	log("Novus_Turret_Manager: Build_Turret is a go.")
	
	building_a_turret = true
	
	-- don't even try to build if we have less than 500 as it can block structure building
	while Player.Get_Credits() < 500.0 do
		Sleep(2.0)
	end
	
	local goal_build_target = Goal.Create_Custom_Target(final_build_position)
	Sleep(0.5)
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, turret_type))
	
	building_a_turret = false
	
end

