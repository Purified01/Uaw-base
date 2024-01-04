-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Quit_DialogBox.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Quit_DialogBox.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Mike_Lytle $
--
--            $Change: 87506 $
--
--          $DateTime: 2007/11/07 15:33:38 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()

	Dialog_Box_Common_Init()

	DialogBox.Register_Event_Handler("Button_Clicked", DialogBox.Controls.Button_1, Button1_Clicked)
	DialogBox.Register_Event_Handler("Button_Clicked", DialogBox.Controls.Button_2, Button2_Clicked)

	DialogBox.Controls.Button_1.Set_Tab_Order(Declare_Enum(0))
	DialogBox.Controls.Button_2.Set_Tab_Order(Declare_Enum())

	if Is_Replay() then
		DialogBox.Controls.Text_Block_1.Set_Hidden(true);
	end

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
end

Interface = {}
Interface.Dialog_Box_Init = Dialog_Box_Init
