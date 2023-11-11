-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Masari_Turret_Manager.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Masari_Turret_Manager.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 83328 $
--
--          $DateTime: 2007/09/10 15:11:41 $
--
--          $Revision: #10 $
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
local	ground_turret_type = nil
local	ground_turret_construction = nil
local	ground_turret_beacon = nil
local enemy_command_center = nil
local turret_positions = {}

local check_time = 30.0

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIMasariTurret.txt"
end

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "MASARI") then
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

	air_turret_type = Find_Object_Type("Masari_Sky_Guardian")
	air_turret_construction = Find_Object_Type("Masari_Sky_Guardian_Construction")
	air_turret_beacon = Find_Object_Type("Masari_Sky_Guardian_Beacon")
	ground_turret_type = Find_Object_Type("Masari_Guardian")
	ground_turret_construction = Find_Object_Type("Masari_Guardian_Construction")
	ground_turret_beacon = Find_Object_Type("Masari_Guardian_Beacon")

	turret_positions[1] = 0.0
	turret_positions[2] = 20.0
	turret_positions[3] = -20.0
	turret_positions[4] = 40.0
	turret_positions[5] = -40.0
	turret_positions[6] = 60.0
	turret_positions[7] = -60.0
	turret_positions[8] = 90.0
	turret_positions[9] = -90.0
	turret_positions[10] = 10.0
	turret_positions[11] = -10.0

	-- ok we can start
	command_center = nil
	build_target = nil
	build_position = nil
	building_a_turret = false
	building_turrets = true
	build_type = nil

	if Player.Get_Credits() < 500.0 then
		-- low cash start !
		check_time = 120.0
	elseif Player.Get_Credits() < 800.0 then
		-- low cash start !
		check_time = 90.0
	end

	log("Masari_Turret_Manager activated.")
	Create_Thread("Building_Turrets_Ground")
	Create_Thread("Building_Turrets_Air")
	
end

function Building_Turrets_Ground()

	log("Masari_Turret_Manager Building_Turrets_Ground started.")
	local thread_id = -1

	while GetCurrentTime() < check_time do
		Sleep(5.0)
	end

	-- Keep looping forever.
	while true do
	
		if thread_id >= 0 and not Thread.Is_Thread_Active(thread_id) then
			thread_id = -1
			Sleep(2.0)
		end

		if thread_id < 0 then
			build_position = Look_For_Turret_Placement()
			
			if build_position ~= nil then
				log("Masari_Turret_Manager: (Ground) Starting Build_Turret Thread")
				building_a_turret = true
				thread_id = Create_Thread("Build_Turret", ground_turret_type )
			end
		end
		
		Sleep(1.0)
	end

end

function Building_Turrets_Air()

	log("Masari_Turret_Manager Building_Turrets_Air started.")
	local thread_id = -1

	while GetCurrentTime() < check_time do
		Sleep(5.0)
	end

	-- Keep looping forever.
	while true do
	
		if thread_id >= 0 and not Thread.Is_Thread_Active(thread_id) then
			thread_id = -1
			Sleep(5.0)
		end
			
		if thread_id < 0 and not Player.Is_Object_Type_Locked( air_turret_type ) then
			build_position = Look_For_Turret_Placement()
			
			if build_position ~= nil then
				log("Masari_Turret_Manager: (Air) Starting Build_Turret Thread")
				building_a_turret = true
				thread_id = Create_Thread("Build_Turret", air_turret_type )
			end
		end
			
		Sleep(2.0)
	end

end

function Look_For_Turret_Placement()

	if not TestValid( command_center ) then
		return nil
	end
	
	return command_center.Get_Position()
	
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

function Find_Pre_Planned_Position( turret_type )

	for _, angle in pairs (turret_positions) do
		
		if not TestValid(enemy_command_center) then
			return nil
		end
		
		local pos = Project_Position( build_position, enemy_command_center, 340.0, angle )
		if pos ~= nil then
		
			local obj_list = Find_All_Objects_Of_Type( "Stationary + CanAttack", pos, 130.0, Player )
			Sleep(0.25)
			
			if obj_list == nil then
				return pos
			end

			local found = false		
			for _, unit in pairs (obj_list) do
				if TestValid( unit ) then
					local type = unit.Get_Type()
					if TestValid( type ) then
						local base_type = type.Get_Base_Type()
						if base_type == turret_type then
							found = true
							break
						end
					end
				end
			end
		end
		
		if not found then
			return pos
		end
		
	end
	
	return nil
	
end

function Build_Turret( turret_type )

	if not TestValid( turret_type ) then
		return
	end

	local final_build_position

	Look_For_Enemy_Command_Center()
	
	-- don't even try to build if we have less than 100 as it can block structure building
	while Player.Get_Credits() < 200.0 do
		Sleep(2.0)
	end
	
	if TestValid( enemy_command_center ) and GameRandom( 0.0 , 100.0) < 75.0 then
		-- build near the front
		local turret_position
		
		turret_position = Find_Pre_Planned_Position( turret_type )
		
		if turret_position == nil then
			turret_position = Project_Position( build_position, enemy_command_center, 340.0, 90.0 - GameRandom(0.0,180.0) )
		end
		if turret_position == nil then
			turret_position = build_position
		end
		final_build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( turret_position , turret_type, Player ))
	else
	
		turret_position = Project_Position( command_center, command_center, 250.0 + GameRandom(0.0, 150.0), GameRandom(0.0,360.0) )
		
		if turret_position == nil then
			turret_position = build_position
		end
		final_build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( turret_position , turret_type, Player ))
	end

	if not final_build_position then
		building_a_turret = false
		log("Masari_Turret_Manager: Build_Turret is a failure.")
		return
	end

	-- Check for too many turrets of type
	if Too_Many_Turrets(turret_type,final_build_position) then
		log("Masari_Turret_Manager: Build_Turret aborted as too many turrets.")
		building_a_turret = false
		--ScriptExit()
		return
	end		

	log("Masari_Turret_Manager: Build_Turret is a go.")
	
	building_a_turret = true
	
	local goal_build_target = Goal.Create_Custom_Target(final_build_position)
	Sleep(0.25)
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, turret_type))
	
	Sleep(1.0)
	
	building_a_turret = false
	--ScriptExit()
	
end

function Too_Many_Turrets( turret_type, build_position )

	local obj_list = Find_All_Objects_Of_Type( "Stationary | TacticalBuildableStructure", build_position, 140.0, Player )
	Sleep(0.25)
	
	if obj_list == nil then
		return false
	end

	local count = 0

	for _, unit in pairs (obj_list) do
		if TestValid( unit ) then
			local type = unit.Get_Type()
			if TestValid( type ) then
				local base_type = type.Get_Base_Type()
				if base_type == turret_type then
					count = count + 1
				end
			end
		end
	end
	
	if turret_type == air_turret_type and count > 1 then
		return true
	end

	if turret_type == ground_turret_type and count > 2 then
		return true
	end

	return false	
	
end