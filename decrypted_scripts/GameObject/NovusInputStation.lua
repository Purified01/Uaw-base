if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/NovusInputStation.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/NovusInputStation.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Kircher $
--
--            $Change: 93391 $
--
--          $DateTime: 2008/02/14 16:09:21 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	
	-- Get the XML settings
	resource_depot_active_drones						= Object.Get_Type().Get_Type_Value("Resource_Depot_Active_Drones")
	resource_depot_seconds_to_build_drone			= Object.Get_Type().Get_Type_Value("Resource_Depot_Seconds_To_Build_Drone")
	resource_depot_seconds_between_drone_launch	= Object.Get_Type().Get_Type_Value("Resource_Depot_Seconds_Between_Drone_Launch")
	resource_depot_collection_radius					= Object.Get_Type().Get_Type_Value("Resource_Depot_Collection_Radius")
	
	drone_count = 0
		
	if resource_depot_active_drones == nil or resource_depot_seconds_to_build_drone == nil or resource_depot_seconds_between_drone_launch == nil or resource_depot_collection_radius == nil then
		MessageBox("Novus_Input_Station couldn't find some parameters")
	end
		
		
	Object.Register_Signal_Handler(Destroy_Attached_Drones, "OBJECT_SOLD")
	
	drone_list = {}
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	
	--MessageBox("Novus Input Station On-Line!");
	
	-- General Init
	drone_list = {}
	
	-- Start spawning drones
	--DebugBreak()
	drone_count =  1
	ref_type = Find_Object_Type("Novus_Collector")
	-- Get the Drone object type
	if ref_type == nil then
		MessageBox("Couldn't find Novus_Collector ref_type.")
		return
	end

	local spawn_bone_names = Object.Get_Type().Get_Type_Value("Tactical_Enabler_Bones")
	if table.getn( spawn_bone_names ) > 0 then
		spawn_position = Object.Get_Bone_Position( spawn_bone_names[ 1 ] )
	else
		spawn_position = Object
	end
	
	Create_Thread("Novus_Input_Station_Launch_Drone", resource_depot_seconds_between_drone_launch)

end

-- ------------------------------------------------------------------------------------------------------------------
-- Object_Has_Power
-- ------------------------------------------------------------------------------------------------------------------
function Station_Object_Has_Power( object )
	if TestValid( object ) then
		if object.Has_Behavior( 161 ) then
			if object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
				return false
			end
		end
	end
	
	return true
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Launch_Drone()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Novus_Input_Station_Launch_Drone(sleep_time)

	while not Station_Object_Has_Power( Object ) do
		Sleep(1.0)
	end

	Sleep(sleep_time)
	-- MessageBox("Launching Drone")

	new_drone = Create_Generic_Object( ref_type, spawn_position, Object.Get_Owner(), false )

--	new_drone.Get_Script().Set_Variable("resource_drone_depot",Object)
--	new_drone.Get_Script().Set_Variable("resource_drone_search_radius",resource_depot_collection_radius)
	new_drone.Set_Depot(Object)
	new_drone.Set_Drone_Search_Radius(resource_depot_collection_radius)
	table.insert(drone_list,new_drone)
	
	if  drone_count < resource_depot_active_drones then
		drone_count = drone_count + 1
		Create_Thread("Novus_Input_Station_Launch_Drone", resource_depot_seconds_between_drone_launch)
	end
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Zero Health handler
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Destroy_Attached_Drones()

	-- If the depot is destroyed, destroy all the drones
	for _, kill_drone in pairs(drone_list) do
		if TestValid(kill_drone) and kill_drone.Get_Script() then
			kill_drone.Get_Script().Call_Function("Novus_Input_Station_Destroyed", Object)
		end
	end
	
	drone_list = {}

end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Zero Health handler
-- --------------------------------------------------------------------------------------------------------------------------------------------------

local function Behavior_Health_At_Zero()

	--DebugBreak()
	Destroy_Attached_Drones();
	

end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Drone Destroyed
-- --------------------------------------------------------------------------------------------------------------------------------------------------

function Novus_Collector_Destroyed(killed_drone)

	--DebugBreak()
	
	-- Remove the drone from the list
	local i
	local drone
	for i,drone in pairs(drone_list) do
		if drone == killed_drone then
			table.remove(drone_list,i)
			break
		end
	end
	
	-- Spawn a replacement
	Create_Thread("Novus_Input_Station_Launch_Drone", resource_depot_seconds_to_build_drone)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
--local function Behavior_Service()

	-- Double check to make sure drones are still alive, the drone's zero health 
	-- handler does not always fire.
	--local i
	--local drone
	--for i,drone in pairs(drone_list) do
	--	if not TestValid(drone) then
	--		Novus_Collector_Destroyed(drone)
	--		break
	--	end
	--end

--end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- These lines must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero

Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	Novus_Collector_Destroyed = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
