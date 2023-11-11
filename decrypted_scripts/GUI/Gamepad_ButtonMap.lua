-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_ButtonMap.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_ButtonMap.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Jonathan_Burgess $
--
--            $Change: 77694 $
--
--          $DateTime: 2007/07/20 16:50:58 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")


function On_Init()
	Gamepad_ButtonMap.Register_Event_Handler("Button_Clicked", Gamepad_ButtonMap.Exit_Button, Hide_Dialog)
	Gamepad_ButtonMap.Register_Event_Handler("Controller_Button_As_Back", nil, Hide_Dialog)
	
	Gamepad_ButtonMap.Exit_Button.Set_Tab_Order(Declare_Enum(0))
	
	Gamepad_ButtonMap.Exit_Button.Set_Key_Focus()

end

function Hide_Dialog()

	GUI_Dialog_Raise_Parent()
	
end

