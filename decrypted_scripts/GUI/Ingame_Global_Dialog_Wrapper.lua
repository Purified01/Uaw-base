if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[33] = true
LuaGlobalCommandLinks[72] = true
LuaGlobalCommandLinks[195] = true
LuaGlobalCommandLinks[75] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Ingame_Global_Dialog_Wrapper.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Ingame_Global_Dialog_Wrapper.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
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
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
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
