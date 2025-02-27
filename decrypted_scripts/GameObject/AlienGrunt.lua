if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[12] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/AlienGrunt.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/AlienGrunt.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- States: [Inactive], Active
local state = "Inactive"

local function Behavior_Init()
	if Object then 
		Object.Event_Object_In_Range(my_behavior.Object_In_Range, CIVILIAN_TRIGGER_RANGE, "CIVILIAN_URBAN_A") 
	end
end

local function Behavior_Service()

end

local function Behavior_Object_In_Range(prox_object, object)
	if (state == "Active") then
		MessageBox("Attacking Civilian")
		target_civilian = Find_First_Object("CIVILIAN_URBAN_A")
		Object.Attack_Move(target_civilian)
	end
end

local function Activate() 
	state = "Active"
end 

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Object_In_Range = Behavior_Object_In_Range
my_behavior.Service = Behavior_Service
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
