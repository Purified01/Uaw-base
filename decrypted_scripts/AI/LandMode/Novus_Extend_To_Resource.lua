if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[161] = true
LuaGlobalCommandLinks[18] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Novus_Extend_To_Resource.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Novus_Extend_To_Resource.lua $
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

ScriptShouldCRC = true

command_center = nil
building_a_tower = false
build_position = nil
tower_type = nil
collector_type = nil

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AINovusTower.txt"
end

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "NOVUS") then
		--Goal.Suppress_Goal()
		return -2.0
	end

	if Player.Get_Player_Is_Crippled() then
		return -2.0
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
				if object.Get_Owner() == Player and object.Has_Behavior(99) then
					return
				end
				
				local resource_amt = Get_Resource_Value( object )
				
				if object.Is_Enemy(Player) and not object.Is_Category("Resource_INST | Resource") and not object.Has_Behavior( 37 ) and
					(object.Has_Behavior( 99 ) or object.Has_Behavior( 9 )) then
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

--	if tower_list then
--		for _, position in pairs( tower_list ) do
--			if target_obj.Get_Distance( position ) <= 200.0 then
--				-- we are building a tower here abort
--				return
--			end
--		end
--	end

	if TestValid(LastTowerPosition) and LastTowerPosition.Get_Distance(target_position) < 200.0 then
		return
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
				
--					if tower_list then
--						for _, position in pairs( tower_list ) do
--							if final_position.Get_Distance( position ) <= 200.0 then
--								-- we will be building a tower here abort
--								build_position = nil
--								return
--							end
--						end
--					end
				
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
--	tower_list = {}
	LastTowerPosition = nil

	resource_list = {}
	Find_Resources()

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
			else
				-- check a random resource for building
				Check_To_Extend()
			end
	
		end
		
		Sleep(2.5)
		
	end

end

-- check to extend resources
function Check_To_Extend()

	if resource_list == nil or #resource_list < 1 then
		return
	end

	local trys = 0
	local target_resource = nil
	local best_distance = 999999.0
	local index = 0
	
	while trys < 5 do
		local idx = GameRandom(1,#resource_list)
		trys = trys + 1
		local resource = resource_list[idx]
		if TestValid(resource) then
			local distance = command_center.Get_Distance(resource)
			if distance < 1750.0 and distance < best_distance then
				best_distance = distance
				target_resource = resource
				index = idx
			end
		end
	end	

	if not TestValid(target_resource) then
		return
	end

	log("Novus_Extend_To_Resource Trying resource at index %g.",index)
	
	local close_struct = Find_All_Objects_Of_Type(Player, target_resource, 525.0, "Stationary")
	if close_struct and #close_struct > 0 then
		Set_Tower_Position(target_resource)
	end
	
end

-- find the starting resources
function	Find_Resources()
	resource_list = Find_All_Objects_Of_Type( "Resource | Resource_INST" )
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

--	if tower_list then
--		for _, position in pairs( tower_list ) do
--			if final_build_position.Get_Distance( position ) <= 200.0 then
--				-- we are building a tower here abort
--				final_build_position = nil
--				break
--			end
--		end
--	end

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
	
	-- record our last build so we have less of a chance to 'stack towers'
	LastTowerPosition = final_build_position
	
	-- This is safe to use now as it will time out (the sub goal)
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, tower_type))

	--Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", goal_build_target, tower_type)

--	if tower_list ~= nil then
--		table.insert(tower_list, final_build_position)
--	end
	
	building_a_tower = false
	build_position	= nil
	
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
