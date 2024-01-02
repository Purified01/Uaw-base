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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/UnitInTransit.lua 
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
		-- data used only if the unit is a reinforcement unit
		IsReinforcement = false
		FleetOfOrigin = nil
		TotalTravelTime = 0.0
		StartTravelTime = 0.0
		-- ------------------------------------------------------
		
		RealFleetUnitID = nil
		TransportingFleet = nil
		UnitType = nil
		TimeToArrival = 1.0
	end
end


-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Service
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	-- check for the status of the FleetOfOrigin and DestinationFleet to see if the fleet in transit 
	-- becomes an orphan
end



-- --------------------------------------------------------------------------------------------------------------------
-- Get_Real_Fleet_Unit
-- --------------------------------------------------------------------------------------------------------------------
function Get_Real_Fleet_Unit_ID()
	return RealFleetUnitID
end


-- --------------------------------------------------------------------------------------------------------------------
-- Get_Unit_Type
-- --------------------------------------------------------------------------------------------------------------------
function Get_Unit_Type()
	if UnitType == nil then
		MessageBox("Unit type is Nil!!!!")
		return
	end
	return UnitType
end


-- --------------------------------------------------------------------------------------------------------------------
-- Get_Time_To_Arrival
-- --------------------------------------------------------------------------------------------------------------------
function Get_Time_To_Arrival()
	if TransportingFleet ~= nil then
		local fleet_script = TransportingFleet.Get_Script()
		if fleet_script ~= nil then
			return(fleet_script.Call_Function("Get_Time_To_Arrival") )
		end
	elseif IsReinforcement == true then
		local progress = (TotalTravelTime + StartTravelTime) - GetCurrentTime.Frame()
		return progress/TotalTravelTime
	else
		return 1.0
	end
end


-- --------------------------------------------------------------------------------------------------------------------
-- Get_Destination_Fleet
-- --------------------------------------------------------------------------------------------------------------------
function Get_Destination_Fleet()
	if TransportingFleet ~= nil then
		local fleet_script = TransportingFleet.Get_Script()
		if fleet_script ~= nil then
			return(fleet_script.Call_Function("Get_Destination_Fleet") )
		end
	end
end


-- --------------------------------------------------------------------------------------------------------------------
-- Get_Fleet_Of_Origin
-- --------------------------------------------------------------------------------------------------------------------
function Get_Fleet_Of_Origin()
	if TransportingFleet ~= nil then
		local fleet_script = TransportingFleet.Get_Script()
		if fleet_script ~= nil then
			return(fleet_script.Call_Function("Get_Fleet_Of_Origin") )
		end
	elseif IsReinforcement == true then
		return FleetOfOrigin	
	end
end

-- --------------------------------------------------------------------------------------------------------------------
-- This line must be at the bottom of the file.
--my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
my_behavior.Init = Behavior_Init
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
