-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienMaterialUplink.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienMaterialUplink.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Hayes $
--
--            $Change: 62842 $
--
--          $DateTime: 2007/02/13 17:43:32 $
--
--          $Revision: #5 $
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
		MessageBox("Alien_Material_Uplink couldn't find some parameters")
	end
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	
	--MessageBox("Alien Material Uplink On-Line!");
	
	-- Make one free drone
	Create_Thread("Alien_Uplink_Launch_Drone", resource_depot_seconds_between_drone_launch)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Launch_Drone()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Alien_Uplink_Launch_Drone(sleep_time)

	Sleep(sleep_time)
	-- MessageBox("Launching Drone")
	
	-- Get the Drone object type
	ref_type = Find_Object_Type("Alien_Collector")
	if ref_type == nil then
		MessageBox("Couldn't find Alien_Gatherer ref_type.")
	end
	
	-- Spawn a new drone
	new_drone = Spawn_Unit(ref_type, Object, Object.Get_Owner())
	
	--Default to auto-gather for AI
	if not new_drone.Get_Owner().Is_Human() then
		new_drone.Activate_Ability("Auto_Gather_Resources", true)
	end
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- These lines must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service

Register_Behavior(my_behavior)
