if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[9] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Number_Edit_Box.lua#5 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Number_Edit_Box.lua $
--
--    Original Author: Nader Akoury
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

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	Register_User_Event("Number_Edit_Box_Changed")
	this.Register_Event_Handler("Button_Clicked", this.ButtonUp, Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.ButtonDown, Down_Clicked)
	this.NumberDisplay.Set_Editable(false)

	-- Setup the tab ordering
	this.ButtonUp.Set_Tab_Order(Declare_Enum(0))
	this.ButtonDown.Set_Tab_Order(Declare_Enum())

	Max_Value = 0
	Min_Value = 0
	Current_Value = 0

	Update_Value()
end

function Initialize(min_value, max_value)
	Min_Value = min_value
	Max_Value = max_value
	Current_Value = min_value

	Update_Value()
end

function Up_Clicked(event_name, source)
	if Current_Value < Max_Value then
		Current_Value = Current_Value + 1
	end
	Update_Value()
end

function Down_Clicked(event_name, source)
	if Current_Value > Min_Value then
		Current_Value = Current_Value - 1
	end
	Update_Value()
end

function Set_Value(value)
	Current_Value = value
	Update_Value()
end

function Update_Value()
	this.NumberDisplay.Set_Text(Get_Localized_Formatted_Number(Current_Value))
	this.Get_Containing_Scene().Raise_Event("Number_Edit_Box_Changed", this.Get_Containing_Component(), {Current_Value})
end

function Get_Value()
	return Current_Value
end

Interface = {}
Interface.Get_Value = Get_Value
Interface.Set_Value = Set_Value
Interface.Initialize = Initialize
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_GUI_Variable = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
