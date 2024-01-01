-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/In_Scene_Dialog.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/In_Scene_Dialog.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 60533 $
--
--          $DateTime: 2007/01/12 11:41:06 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

function On_Init()
	In_Scene_Dialog.YesButton.Set_Button_Name("Yes")
	In_Scene_Dialog.NoButton.Set_Button_Name("No")
	In_Scene_Dialog.Register_Event_Handler("Mainmenu_Button_Clicked", In_Scene_Dialog.YesButton, Yes_Clicked)
	In_Scene_Dialog.Register_Event_Handler("Mainmenu_Button_Clicked", In_Scene_Dialog.NoButton, No_Clicked)
end

function Yes_Clicked(event, source)
	In_Scene_Dialog.End_Modal(true)
	In_Scene_Dialog.Set_Hidden(true)
end

function No_Clicked(event, source)
	In_Scene_Dialog.End_Modal(false)
	In_Scene_Dialog.Set_Hidden(true)
end

function Set_Question(question)
	In_Scene_Dialog.Question.Set_Text(question)
end

Interface = {}
Interface.Set_Question = Set_Question