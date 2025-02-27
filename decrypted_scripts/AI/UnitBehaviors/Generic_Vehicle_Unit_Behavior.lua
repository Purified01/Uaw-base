LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Generic_Vehicle_Unit_Behavior.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Generic_Vehicle_Unit_Behavior.lua $
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

require("PGBase")
require("Anti_Crush_Unit_Behavior")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	-- required globals
	-- GenericVehicle.SearchRange
	-- GenericVehicle.KiteRange

	OurType = Object.Get_Type()
	
	if not TestValid(OurType) then
		ScriptExit()	
	end
	
	CrushDefense = OurType.Get_Type_Value("Crush_Defense")
	if CrushDefense == nil then
		CrushDefense = 999.0	-- bad value
	end
	
	if GenericVehicle == nil then
		GenericVehicle = {}
	end
	
	if GenericVehicle.SearchRange == nil then
		GenericVehicle.SearchRange = 150.0
	end

	if GenericVehicle.KiteRange == nil then
		GenericVehicle.KiteRange = 100.0
	end

	if GenericVehicle.CrushRange == nil then
		GenericVehicle.CrushRange = 100.0
	end

	CrushPower = OurType.Get_Type_Value("Crush_Power")
	if CrushPower == nil then
		CrushPower = 0.0
	end

	if GenericVehicle.MoveThroughDistance == nil then
		GenericVehicle.MoveThroughDistance = 0.0
	end

	CrushTarget = nil
	CrushTargetPosition = nil
	GenericVehicleThreadID = nil

end

local function Behavior_Service()


	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not GenericVehicleThreadID then
			GenericVehicleThreadID = Create_Thread("Generic_Vehicle_Thread")
		end
	elseif GenericVehicleThreadID then
		Create_Thread.Kill(GenericVehicleThreadID)
		GenericVehicleThreadID = nil
	end

end

function Generic_Vehicle_Thread()
	while true do
		local crusher, obj_list = Check_For_Crushers(Object,GenericVehicle.SearchRange,GenericVehicle.KiteRange,CrushDefense)
		
		-- Note that we want to leave the default service rate at least at 1.0 as
		-- All scripts on an object use the same service rate it turns out ...
		if crusher then
			ServiceRate = 0.5
			Sleep(0.5)
		elseif Check_To_Crush(Object, obj_list, GenericVehicle.CrushRange, CrushPower ) then
			ServiceRate = 1.0
			Sleep(1.0)
		else
			ServiceRate = 1.0
			Sleep(1.68)
		end
	end
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
