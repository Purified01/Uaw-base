if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Quit_DialogBox.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Quit_DialogBox.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Joe_Howes $
--
--            $Change: 92970 $
--
--          $DateTime: 2008/02/08 16:20:47 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()

	Dialog_Box_Common_Init()

	DialogBox.Register_Event_Handler("Button_Clicked", DialogBox.Controls.Button_1, Button1_Clicked)
	DialogBox.Register_Event_Handler("Button_Clicked", DialogBox.Controls.Button_2, Button2_Clicked)

--	DialogBox.Controls.Button_1.Set_Tab_Order(Declare_Enum(0))
--	DialogBox.Controls.Button_2.Set_Tab_Order(Declare_Enum())
	DialogBox.Controls.Set_Tab_Order(Declare_Enum(0))
	
	DialogBox.Register_Event_Handler("Controller_A_Button_Up", nil, Button1_Clicked)
	DialogBox.Register_Event_Handler("Controller_B_Button_Up", nil, Button2_Clicked)
	DialogBox.Register_Event_Handler("Controller_Back_Button_Up", nil, Button2_Clicked)

	this.Focus_First()
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end



function Dialog_Box_Init()
	this.Focus_First()
end

function Button1_Clicked(event_name, source)
	this.Set_Hidden(true)
	this.End_Modal()
	Ingame_Global_Dialog_Interface.Quit_Game()
end

function Button2_Clicked(event_name, source)
	this.Set_Hidden(true)
	this.End_Modal()
	GUI_Dialog_Raise_Parent()
end

function On_Update()
	-- GUIDialogComponent.Set_Render_Priority(500)
	this.Focus_First()
end

Interface = {}
Interface.Dialog_Box_Init = Dialog_Box_Init
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
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
