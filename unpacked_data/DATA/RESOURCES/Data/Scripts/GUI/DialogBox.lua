-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/DialogBox.lua#20 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/DialogBox.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Nader_Akoury $
--
--            $Change: 84504 $
--
--          $DateTime: 2007/09/21 09:55:33 $
--
--          $Revision: #20 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	Dialog_Box_Common_Init()

	local start_enum = Declare_Enum(0)
	if TestValid(this.Controls.Button_1) then
		this.Register_Event_Handler("Button_Clicked", this.Controls.Button_1, Button1_Clicked)
		this.Controls.Button_1.Set_Tab_Order(Declare_Enum())
	end
	if TestValid(this.Controls.Button_2) then
		this.Register_Event_Handler("Button_Clicked", this.Controls.Button_2, Button2_Clicked)
		this.Controls.Button_2.Set_Tab_Order(Declare_Enum())
	end
	if TestValid(this.Controls.Button_3) then
		this.Register_Event_Handler("Button_Clicked", this.Controls.Button_3, Button3_Clicked)
		this.Controls.Button_3.Set_Tab_Order(Declare_Enum())
	end
	if TestValid(this.Controls.Button_4) then
		this.Register_Event_Handler("Button_Clicked", this.Controls.Button_4, Button4_Clicked)
		this.Controls.Button_4.Set_Tab_Order(Declare_Enum())
	end
end

-- 	LuaMap::Pointer cmap;
-- 	cmap = LUA_BUILD_MAP(cmap, "caption", caption);
-- 	cmap = LUA_BUILD_MAP(cmap, "left_button", left_button);
-- 	cmap = LUA_BUILD_MAP(cmap, "middle_button", middle_button);
-- 	cmap = LUA_BUILD_MAP(cmap, "right_button", right_button);
-- 	if (user_string_1) cmap = LUA_BUILD_MAP(cmap, "user_string_1", *user_string_1);
-- 	if (user_string_2) cmap = LUA_BUILD_MAP(cmap, "user_string_2", *user_string_2);
-- 	if (user_string_3) cmap = LUA_BUILD_MAP(cmap, "user_string_3", *user_string_3);
-- 	LuaTable::Pointer params = LUA_SINGLE_PARAM(cmap);
-- 	DialogBoxComponent->Get_GUI_Scene()->Get_Script()->Call_Function("Dialog_Box_Init", params, true);
function Dialog_Box_Init(params)

	if TestValid(this.Controls.Text_Block_1) then
		this.Controls.Text_Block_1.Set_Hidden(true)
	end
	if TestValid(this.Controls.Text_Block_2) then
		this.Controls.Text_Block_2.Set_Hidden(true)
	end
	if TestValid(this.Controls.Text_Block_3) then
		this.Controls.Text_Block_3.Set_Hidden(true)
	end
	if TestValid(this.Controls.Caption) then
		this.Controls.Caption.Set_Hidden(true)
	end

	if TestValid(this.Controls.Caption) and params.caption then
		this.Controls.Caption.Set_Hidden(false)
		this.Controls.Caption.Set_Text(params.caption)
	end

	-- inner function to reduce code duplication 4/18/2007 11:44:57 AM -- NSA
	local empty_wstring = Create_Wide_String("")
	function Set_Button_Text(button, text)
		if text == nil or text == empty_wstring then
			button.Set_Hidden(true)
		else
			button.Set_Hidden(false)
			button.Set_Text(text)
		end
	end

	if TestValid(this.Controls.Button_1) then
		if params.left_button then
			this.Controls.Button_1.Set_Hidden(false)
			Set_Button_Text(this.Controls.Button_1, params.left_button)
		elseif params.use_bui_buttons ~= true then
			this.Controls.Button_1.Set_Hidden(true)
		end
	end
	if TestValid(this.Controls.Button_2) then
		if params.middle_button then
			this.Controls.Button_2.Set_Hidden(false)
			Set_Button_Text(this.Controls.Button_2, params.middle_button)
		elseif params.use_bui_buttons ~= true then
			this.Controls.Button_2.Set_Hidden(true)
		end		
	end
	if TestValid(this.Controls.Button_3) then 
		if params.right_button then
			this.Controls.Button_3.Set_Hidden(false)
			Set_Button_Text(this.Controls.Button_3, params.right_button)
		elseif params.use_bui_buttons ~= true then
			this.Controls.Button_3.Set_Hidden(true)
		end		
	end
	if TestValid(this.Controls.Button_4) then 
		if params.button_4 then
			this.Controls.Button_4.Set_Hidden(false)
			Set_Button_Text(this.Controls.Button_4, params.button_4)
		elseif params.use_bui_buttons ~= true then
			this.Controls.Button_4.Set_Hidden(true)
		end
	end

	if params.user_string_1 and TestValid(this.Controls.Text_Block_1) then
		this.Controls.Text_Block_1.Set_Hidden(false)
		this.Controls.Text_Block_1.Set_Text(params.user_string_1)
	end
	if params.user_string_2 and TestValid(this.Controls.Text_Block_2) then
		this.Controls.Text_Block_2.Set_Hidden(false)
		this.Controls.Text_Block_2.Set_Text(params.user_string_2)
	end
	if params.user_string_3 and TestValid(this.Controls.Text_Block_3) then
		this.Controls.Text_Block_3.Set_Hidden(false)
		this.Controls.Text_Block_3.Set_Text(params.user_string_3)
	end

	-- Added support for spawning from script 4/18/2007 11:45:17 AM -- NSA
	Spawned_From_Script = params.spawned_from_script
	if Spawned_From_Script then
		Callback = params.callback
		Target_Script = params.script
	else
		GUIDialogComponent.Set_Result(DIALOG_RESULT_NONE)
	end
	this.Set_Hidden(false)
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


function Dialog_Box_Shutdown()
	GUIDialogComponent.Set_Active(false)
end

function Return_Result(result)
	if Spawned_From_Script then
		GUI_Dialog_Raise_Parent()
		if Callback then
			Target_Script.Call_Function(Callback, result)
		end
	else
		GUIDialogComponent.Set_Result(result)
		GUIDialogComponent.Set_Active(false)
	end
end

function Button1_Clicked(event_name, source)
	Return_Result(DIALOG_RESULT_LEFT)
end

function Button2_Clicked(event_name, source)
	Return_Result(DIALOG_RESULT_MIDDLE)
end

function Button3_Clicked(event_name, source)
	Return_Result(DIALOG_RESULT_RIGHT)
end

function Button4_Clicked(event_name, source)
	Return_Result(DIALOG_RESULT_BUTTON_4)
end

function On_Update()
	-- GUIDialogComponent.Set_Render_Priority(500)
end

Interface = {}
Interface.Dialog_Box_Init = Dialog_Box_Init
