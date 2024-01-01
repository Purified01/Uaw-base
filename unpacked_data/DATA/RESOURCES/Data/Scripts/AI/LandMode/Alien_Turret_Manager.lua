-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Alien_Turret_Manager.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Alien_Turret_Manager.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 83065 $
--
--          $DateTime: 2007/09/07 10:57:57 $
--
--          $Revision: #6 $
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
local build_type = nil

local air_turret_type = nil
local	air_turret_construction = nil
local	air_turret_beacon = nil
local	rad_turret_type = nil
local	rad_turret_construction = nil
local	rad_turret_beacon = nil
local enemy_command_center = nil

local check_time = 60.0

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIAlienTurret.txt"
end

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "ALIEN") and not Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		Goal.Suppress_Goal()
		return 0.0
	end

	-- Only start the goal with the nil object
	if Target then
	
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

	air_turret_type = Find_Object_Type("Alien_Gravitic_Manipulator")
	air_turret_construction = Find_Object_Type("Alien_Gravitic_Manipulator_Construction")
	air_turret_beacon = Find_Object_Type("Alien_Gravitic_Manipulator_Beacon")
	rad_turret_type = Find_Object_Type("Alien_Radiation_Spitter")
	rad_turret_construction = Find_Object_Type("Alien_Radiation_Spitter_Construction")
	rad_turret_beacon = Find_Object_Type("Alien_Radiation_Spitter_Beacon")

	-- ok we can start
	command_center = nil
	build_target = nil
	build_position = nil
	building_a_turret = false
	building_turrets = true
	build_type = nil

	if Player.Get_Credits() < 5000.0 then
		-- low cash start !
		check_time = 180.0
	elseif Player.Get_Credits() < 8000.0 then
		-- low cash start !
		check_time = 120.0
	end

	log("Alien_Turret_Manager activated.")
	Create_Thread("Building_Turrets")
	
end

function Building_Turrets()

	log("Alien_Turret_Manager Building_Turrets started.")

	-- Keep looping forever.
	while true do
	
		if building_turrets and not building_a_turret and GetCurrentTime() > check_time then
			
			build_position = Look_For_Turret_Placement()
			
			if build_position ~= nil then
				log("Alien_Turret_Manager: Starting Build_Turret Thread")
				building_a_turret = true
				Create_Thread("Build_Turret")
			end
			
			check_time = GetCurrentTime() + 5.0
		end
	
		Sleep(2.5)
	end

end

function Look_For_Turret_Placement()

	if not TestValid( command_center ) then
		return nil
	end
	
	local object_list = Find_All_Objects_Of_Type( command_center, 750.0, Player )	
	Sleep(0.5)
	
	if not TestValid( command_center ) then
		return nil
	end

	if object_list ~= nil then
	
		local target_list =  {}
		local air_turret_list = {}
		local rad_turret_list = {}

		table.insert(target_list, command_center)

		for _, object in pairs(object_list) do
			if TestValid(object) then
				if object.Get_Owner() == Player then
					local object_type = object.Get_Type()
					if object_type ~= nil then
						if object_type == air_turret_type or object_type == air_turret_construction or object_type == air_turret_beacon then
							table.insert(air_turret_list, object)
							table.insert(target_list, object)
						elseif object_type == rad_turret_type or object_type == rad_turret_construction or object_type == rad_turret_beacon then
							table.insert(rad_turret_list, object)
						end
					end
				end
			end
		end
		Sleep(0.5)
		
		-- all targets and turrets listed
		-- go through targets and eliminate them if there is a turrent nearby

		if not TestValid( command_center ) then
			return nil
		end
		
		local final_list = {}
		
		for index, object in pairs(target_list) do
			local found = false
			local count = 0
			
			if TestValid( object ) then
				if object == command_center then
				
					for _, turret in pairs(air_turret_list) do
						if TestValid( turret ) and object.Get_Distance( turret ) <= 350.0 then
							found = true
							break
						end
					end
					
				else
				
					for _, turret in pairs(rad_turret_list) do
						if TestValid( turret ) and object.Get_Distance( turret ) <= 350.0 then
							count = count + 1
							if count >= 1 then
								found = true
								break
							end
						end
					end
					
				end
					
				if not found then
					table.insert( final_list, object )
				end
			end
		end
		
		-- get a random object from the table
		if #final_list > 0 then
			local index = GameRandom( 1, #final_list )
			
			local final_object = final_list[index]
			
			if final_object == command_center then
				build_type = air_turret_type
			else
				build_type = rad_turret_type
			end
			
			if TestValid(final_object) then
				log("Alien_Turret_Manager: Our build next to target is %s.", final_object.Get_Type().Get_Name() )
				return final_list[index].Get_Position()
			end
			
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
	
	if TestValid( enemy_command_center ) and GameRandom( 0.0 , 100.0) < 90.0 and build_type == air_turret_type then
	
		local turret_position = Project_Position( build_position, enemy_command_center, 150.0, 5.0 - GameRandom(0.0,10.0) )
		
		if turret_position == nil then
			turret_position = build_position
		end
	
		final_build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( turret_position , build_type, Player ))
	else
		final_build_position = BlockOnCommand(Find_Constrained_Build_Position( build_position, build_type, Player, build_position, 200.0 ))
	end

	if not final_build_position then
		building_a_turret = false
		log("Alien_Turret_Manager: Build_Turret is a failure.")
		return
	end

	log("Alien_Turret_Manager: Build_Turret is a go.")
	
	building_a_turret = true
	
	local goal_build_target = Goal.Create_Custom_Target(final_build_position)
	Sleep(0.5)
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, build_type))
	
	Sleep(5.0)
	
	building_a_turret = false
	
end

