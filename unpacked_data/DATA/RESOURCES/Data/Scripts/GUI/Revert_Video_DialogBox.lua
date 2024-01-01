-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Revert_Video_DialogBox.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Revert_Video_DialogBox.lua $
--
--    Original Author: $
--
--            $Author: Nader_Akoury $
--
--            $Change: 85147 $
--
--          $DateTime: 2007/09/29 16:35:01 $
--
--          $Revision: #3 $
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
	Return_Result(DIALOG_RESULT_LEFT)
end

function Button2_Clicked(event_name, source)
	Return_Result(DIALOG_RESULT_RIGHT)
end

function On_Update()
	if Dialog_Open then
		local delta = DIALOG_WAIT_TIME + Dialog_Start_Time - Net.Get_Time()
		if delta <= 0 then
			Return_Result(DIALOG_RESULT_RIGHT)
		else
			local wstr = Get_Game_Text("TEXT_REVERTING_IN_X_SECONDS")
			Replace_Token(wstr, Get_Localized_Formatted_Number(delta), 0)
			this.Controls.Text_Reverting.Set_Text(wstr)
		end
	end
end

Interface = {}
Interface.Dialog_Box_Init = Dialog_Box_Init
