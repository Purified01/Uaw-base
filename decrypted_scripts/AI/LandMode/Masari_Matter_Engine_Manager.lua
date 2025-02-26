if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[161] = true
LuaGlobalCommandLinks[51] = true
LuaGlobalCommandLinks[18] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Masari_Matter_Engine_Manager.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Masari_Matter_Engine_Manager.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
ScriptShouldCRC = true

local command_center = nil
local enemy_command_center = nil
local build_position = nil
local building_engine = false
local matter_engine_grid_valid = {}
local total_placement_tries = 0
local doing_build = 0
local dead_angle = {}
local hi_range = 0
local reject_distance = 240.0

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIMasariMatterEngine.txt"
end

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "MASARI") then
		--Goal.Suppress_Goal()
		return -2.0
	end

	-- Only start the goal with the nil object
	if Target then
		--Goal.Suppress_Goal()
		return -1.0
	end

	if Player.Get_Player_Is_Crippled() then
		return -2.0
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

	matter_type = Find_Object_Type("Masari_Elemental_collector")

	-- ok we can start
	command_center = nil
	build_position = nil
	building_engine = false
	matter_engine_grid_valid = {}
	total_placement_tries = 0
	doing_build = 0
	dead_angle = {}
	hi_range = 0

	log("Masari_Matter_Engine_Manager activated.")
	Create_Thread("Building_Matter_Engine")
	
end

function Building_Matter_Engine()

	log("Masari_Eninge_Manager Building_Matter_Engine started.")

	-- Keep looping forever.
	while true do
	
		if Total_Matter_Engines() < 5 and not Player.Is_Object_Type_Locked( matter_type ) then

			Search_for_Matter_Engine_Placement( matter_type )
			
			if doing_build < 2 then
				build_position = Look_For_Engine_Placement()
					
				if build_position ~= nil then
					log("Masari_Matter_Engine_Manager: Starting Build_Matter_Engine Thread")
					Create_Thread("Build_Matter_Engine",matter_type)
				end
			end
		end
	
		Sleep(1.5)
	end

end


function Search_for_Matter_Engine_Placement( build_type )

	if not TestValid( command_center ) then
		return
	end
	
	if #matter_engine_grid_valid < 10 then
		
		-- start a search
		for build_index = 1, 5 do
			Find_Good_Location( build_type )
		end
	end
end

function Get_Angle()
	local count = 0
	local ret_angle = 0
	
	while true do
		ret_angle = GameRandom(0,359)
		count = count + 1
		if count > 100 or not dead_angle[ret_angle] then
			break
		end
	end
	
	return ret_angle
end

function Find_Good_Location( build_type )
	local random_distance = 0
	local random_distance_min = 0
	
	if total_placement_tries > 250 and #matter_engine_grid_valid < 1 then
		random_distance = 400.0
		random_distance_min = 0.0
		-- no dead angles here
		dead_angle = {}
	elseif total_placement_tries > 100 and #matter_engine_grid_valid < 1 then
		random_distance = 200.0
		random_distance_min = 125.0
		if 200.0 > hi_range then
			local old_dead = dead_angle	-- for debugging
			dead_angle = {}
		end
		hi_range = 200.0
	end

	local project_angle = Get_Angle()
	if dead_angle[project_angle] then
		total_placement_tries = total_placement_tries + 1
		return
	end
		
	local position = Project_Position( command_center,command_center, 605.0 + GameRandom(random_distance_min,random_distance+1), project_angle )
		
	if not position or command_center.Get_Distance(position) < 600.0 then
		total_placement_tries = total_placement_tries + 1
		dead_angle[project_angle] = true
		return
	end

	for _,pos in pairs (matter_engine_grid_valid) do
	
		if TestValid(pos) then
			local pos_distance = position.Get_Distance(pos)
			
			if pos_distance < reject_distance then
				total_placement_tries = total_placement_tries + 1
				dead_angle[project_angle] = true
				return
			end
		end
		
	end
	
	local final_build_position = Player.Fast_Find_Structure_Placement( build_type, position, 25.0 )
	Sleep(0.1)
	
	if not final_build_position then
		total_placement_tries = total_placement_tries + 1
		dead_angle[project_angle] = true
		return
	end
	
	local obj_list = Find_All_Objects_Of_Type( final_build_position, "CanAttack | TacticalBuildableStructure | Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST", reject_distance )
	
	local ok = true
	local dead = false
	
	if obj_list then
		for _, unit in pairs (obj_list) do
			if TestValid( unit ) then
				if unit.Is_Enemy(Player) then
					if unit.Is_Category("Stationary") then
						dead = true
					end
					ok = false
					break
				elseif Player.Is_Ally(unit.Get_Owner()) and unit.Is_Category("Stationary") then
					ok = false
					dead = true
					break
				end
			end
		end
	end
		
	if ok then
		table.insert(matter_engine_grid_valid,final_build_position)
	else
		if dead then
			dead_angle[project_angle] = true
		end
		total_placement_tries = total_placement_tries + 1
	end
end

function Look_For_Engine_Placement()

	if not TestValid( command_center ) then
		return nil
	end

	if #matter_engine_grid_valid > 0 then
		local index = GameRandom(1,#matter_engine_grid_valid)
		
		local pos = matter_engine_grid_valid[index]
		table.remove(matter_engine_grid_valid,index)
		return pos
	end

	return nil
	
end


function Build_Matter_Engine( engine_type )

	if not TestValid( engine_type ) then
		return
	end

	doing_build = doing_build + 1

	final_build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( build_position , engine_type, Player ))

	if not final_build_position then
		log("Masari_Matter_Engine_Manager: Build_Matter_Engine is a failure.")
		doing_build = doing_build - 1
		return
	end

	log("Masari_Matter_Engine_Manager: Build_Turret is a go.")
	
	local goal_build_target = Goal.Create_Custom_Target(final_build_position)
	Sleep(0.25)
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, engine_type))
	
	Sleep(1.0)
	doing_build = doing_build - 1
	
	--ScriptExit()
	
end

function Total_Matter_Engines()

	local total_matter_engines = 0

	local script = Player.Get_Script()
	if script == nil then
		return 0
	end
	
	matter_owners = script.Get_Async_Data("MatterEngineOwners")
	
	if matter_owners and matter_owners[Player] and matter_owners[Player].Count ~= nil then
		total_matter_engines = matter_owners[Player].Count
	end
	
	return total_matter_engines
	
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
	Describe_Target = nil
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
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
