if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[20] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MarkerSpawner.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MarkerSpawner.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}


local function Behavior_Init()
	ServiceRate = 0.001
	LastService = nil
end


local function Behavior_Service()

end


local function Behavior_Object_In_Range(prox_object, object)

end

local function Behavior_First_Service()
	new_unit = Spawn_Unit(Find_Object_Type(MARKER_SPAWNER_TYPE), Object, Object.Get_Owner())
	new_unit.Set_Hint(Object.Get_Hint())
	new_unit.Set_Object_Context_ID(Object.Get_Object_Context_ID())
	new_unit.Teleport_And_Face(Object)
	Object.Despawn()
end 

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
--my_behavior.Object_In_Range = Behavior_Object_In_Range
--my_behavior.Artillery_In_Range = Artillery_In_Range
--my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
my_behavior.First_Service = Behavior_First_Service
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
