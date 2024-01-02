-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Ingame_Global_Dialog_Wrapper.lua#13 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Ingame_Global_Dialog_Wrapper.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: James_Yarrow $
--
--            $Change: 85424 $
--
--          $DateTime: 2007/10/03 17:52:05 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGCrontab")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	IsClosing = false
	Current_Modal_Dialog = nil

	Register_User_Event("Set_Current_Modal_Dialog")
	this.Register_Event_Handler("Request_Hide", nil, Hide_Dialog)
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Set_Current_Modal_Dialog", nil, Set_Current_Modal_Dialog)
	this.Register_Event_Handler("Multiplayer_Match_Completed", nil, Hide_Dialog)

	--Need to register net commands so that crontab can use a global timer
	--rather than a mode-dependent one
	Register_Net_Commands()
	PGCrontab_Init()
end

function Hide_Dialog(source, event)
	if not CloseHuds or IsClosing then
		return
	end

	if not Is_Multiplayer_Skirmish() or Is_Replay() then
		Ingame_Global_Dialog_Interface.Pause_Game(false)
	end

	-- Kill the current modal dialog
	Current_Modal_Dialog.End_Modal()
	Current_Modal_Dialog.Set_Hidden(true)
	Current_Modal_Dialog = nil

	IsClosing = true
	CloseHuds = false
	PGCrontab_Schedule(Finish_Closing, 0, 1)
end

function Display_Dialog()
	if not IsClosing then
		CloseHuds = true
		if not Is_Multiplayer_Skirmish() or Is_Replay() then
			Ingame_Global_Dialog_Interface.Pause_Game(true)
		end
		Spawn_Dialog("Game_Options_Dialog")
	end
end

function Set_Current_Modal_Dialog(event_name, source, dialog)
	if IsClosing then
		dialog.End_Modal()
		dialog.Set_Hidden(true)
	else
		Current_Modal_Dialog = dialog
	end
end

function On_Update()
	PGCrontab_Update()
end

function Finish_Closing()
	IsClosing = false
	GUIDialogComponent.Set_Active(false)
end
