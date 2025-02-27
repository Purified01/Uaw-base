LUA_PREP = true

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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/FleetInTransit.lua 
--
--           Author: Maria_Teruel 
--
--     	  DateTime: 2006/05/02 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Init
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	if Object then
		FleetOfOrigin = nil
		DestinationFleet = nil
		DistanceTraveled = 0.0
		TotalDistance = 0.0
		
		Object.Register_Signal_Handler(On_Fleet_Is_Orphan, "FLEET_ORPHANED")
	end
end

-- --------------------------------------------------------------------------------------------------------------------
-- Get_Fleet_Of_Origin
-- --------------------------------------------------------------------------------------------------------------------
function Get_Fleet_Of_Origin()
	return FleetOfOrigin
end


-- --------------------------------------------------------------------------------------------------------------------
-- Get_Destination_Fleet
-- --------------------------------------------------------------------------------------------------------------------
function Get_Destination_Fleet()
	return DestinationFleet
end



-- --------------------------------------------------------------------------------------------------------------------
-- Get_Time_To_Arrival
-- --------------------------------------------------------------------------------------------------------------------
function Get_Time_To_Arrival()
	
	if TotalDistance == 0.0 then
		return(0.0)
	end
	
	return (1.0 - DistanceTraveled/TotalDistance)
end



-- --------------------------------------------------------------------------------------------------------------------
-- On_Fleet_Is_Orphaned
-- --------------------------------------------------------------------------------------------------------------------
function On_Fleet_Is_Orphan()
	-- The fleet in transit has lost its Source and Destination fleets.  Hence, it will be destroyed!
	-- MessageBox("Fleet in transit is now an orphan fleet!. It will be destroyed!")
	
	--PLACEHOLDER FOR GAME MODE SCRIPT FEEDBACK!.
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- This line must be at the bottom of the file.
--my_behavior.First_Service = Behavior_First_Service
--my_behavior.Service = Behavior_Service
my_behavior.Init = Behavior_Init
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
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
	Get_Destination_Fleet = nil
	Get_Fleet_Of_Origin = nil
	Get_Time_To_Arrival = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
