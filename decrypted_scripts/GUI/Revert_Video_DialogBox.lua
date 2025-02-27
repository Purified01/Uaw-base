if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Revert_Video_DialogBox.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Revert_Video_DialogBox.lua $
--
--    Original Author: $
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

	-- Constants
	DIALOG_WAIT_TIME = 15

	Dialog_Box_Common_Init()

	this.Register_Event_Handler("Button_Clicked", this.Controls.Button_1, Button1_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.Button_2, Button2_Clicked)
	this.Register_Event_Handler("Component_Hidden", this, Button2_Clicked)

	this.Controls.Button_1.Set_Tab_Order(Declare_Enum(0))
	this.Controls.Button_2.Set_Tab_Order(Declare_Enum())

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

function Dialog_Box_Init(params)
	this.Focus_First()

	Dialog_Open = true
	if params then
		Callback = params.callback
		Target_Script = params.script

		if params.caption then
			this.Controls.Caption.Set_Text(params.caption)
		end
	end
	Register_Net_Commands()
	Dialog_Start_Time = Net.Get_Time()
end

function Return_Result(result)
	if Dialog_Open then
		Dialog_Open = false
		GUI_Dialog_Raise_Parent()
		if Callback and Target_Script then
			Target_Script.Call_Function(Callback, result)
		end
	end
end

function Button1_Clicked(event_name, source)
	Return_Result(1)
end

function Button2_Clicked(event_name, source)
	Return_Result(3)
end

function On_Update()
	if Dialog_Open then
		local delta = DIALOG_WAIT_TIME + Dialog_Start_Time - Net.Get_Time()
		if delta <= 0 then
			Return_Result(3)
		else
			local wstr = Get_Game_Text("TEXT_REVERTING_IN_X_SECONDS")
			Replace_Token(wstr, Get_Localized_Formatted_Number(delta), 0)
			this.Controls.Text_Reverting.Set_Text(wstr)
		end
	end
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
