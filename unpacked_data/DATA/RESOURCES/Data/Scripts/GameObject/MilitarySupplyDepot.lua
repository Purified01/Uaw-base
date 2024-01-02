-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/MilitarySupplyDepot.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/MilitarySupplyDepot.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Hayes $
--
--            $Change: 62842 $
--
--          $DateTime: 2007/02/13 17:43:32 $
--
--          $Revision: #7 $
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
	if resource_depot_active_drones == nil or resource_depot_seconds_to_build_drone == nil or resource_depot_seconds_between_drone_launch == nil or resource_depot_collection_radius == nil then
		MessageBox("Military_Supply_Depot couldn't find some parameters")
	end
		
	drone_list = {}
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	
	--MessageBox("Military_Supply_Depot On-Line!");
	
	-- General Init
	drone_list = {}
	
	-- Start spawning drones
	--DebugBreak()
	Create_Thread("Supply_Depot_Launch_Drone", resource_depot_seconds_between_drone_launch)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Launch_Drone()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Supply_Depot_Launch_Drone(sleep_time)

	Sleep(sleep_time)
	-- MessageBox("Launching Drone")
	
	-- Get the Drone object type
	ref_type = Find_Object_Type("Military_Supply_Drone")
	if ref_type == nil then
		MessageBox("Couldn't find Military_Supply_Drone ref_type.")
	end
	
	-- Spawn a new drone
	new_drone = Spawn_Unit(ref_type, Object, Object.Get_Owner())
	new_drone.Get_Script().Set_Variable("resource_drone_depot",Object)
	new_drone.Get_Script().Set_Variable("resource_drone_search_radius",resource_depot_collection_radius)
	table.insert(drone_list,new_drone)
	
	if table.getn(drone_list) < resource_depot_active_drones then
		Create_Thread("Supply_Depot_Launch_Drone", resource_depot_seconds_between_drone_launch)
	end
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Zero Health handler
-- --------------------------------------------------------------------------------------------------------------------------------------------------

local function Behavior_Health_At_Zero()

	--DebugBreak()
	
	-- If the depot is destroyed, destroy all the drones
	local kill_drone
	for _, kill_drone in pairs(drone_list) do
		if TestValid(kill_drone) then
			kill_drone.Take_Damage(10000)
		end
	end
	
	drone_list = {}

end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Drone Destroyed
-- --------------------------------------------------------------------------------------------------------------------------------------------------

function Military_Supply_Depot_Drone_Destroyed(killed_drone)

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
	Create_Thread("Supply_Depot_Launch_Drone", resource_depot_seconds_to_build_drone)
	
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
	--		Military_Supply_Depot_Drone_Destroyed(drone)
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
--my_behavior.Service = Behavior_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero

Register_Behavior(my_behavior)
