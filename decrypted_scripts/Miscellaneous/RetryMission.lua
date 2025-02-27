if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[72] = true
LuaGlobalCommandLinks[32] = true
LuaGlobalCommandLinks[130] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/RetryMission.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/RetryMission.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 93153 $
--
--          $DateTime: 2008/02/12 11:04:35 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

--Any script that makes use of retry functionality should not be pooled, since a retry will restart it and
--managing all the variables so that they're set correctly post pooling is just far too big a pain.
ScriptPoolCount = 0

function Define_Retry_State()
	RetryMission = nil
	Define_State("State_Retry_Mission", State_Retry_Mission)
end

function State_Retry_Mission(message)
	if message == OnEnter then
		Set_Next_State(RetryMission)
		RetryMission = nil
	end
end

function Retry_Current_Mission()
	RetryMission = CurrentState
	Set_Next_State("State_Retry_Mission")	
end

function Show_Retry_Dialog()
	--Fade_Screen_Out(1) 
	
	-- Maria 01.24.2008
	-- We need the game to pause because we are out of the tactical game.
	-- Otherwise we will hear all the action going on behind the blackout screen.
	Pause_Game(false)
	
	--[[
	local retry_dialog = nil
	local game_scene = Get_Game_Mode_GUI_Scene()
	if TestValid(game_scene.RetryDialog) then
		retry_dialog = game_scene.RetryDialog
		retry_dialog.Set_Hidden(false)
	else
		retry_dialog = game_scene.Create_Embedded_Scene("Retry_Dialog", "RetryDialog")
	end
	retry_dialog.Set_Screen_Position(0.5, 0.5)
	retry_dialog.Start_Modal(On_Retry_Response)
	]]--
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Show_Retry_Mission_Screen", nil, { "Retry_Dialog", "RetryDialog" })
end

-- SKY 2/8/07 - different version of function called from load dialog end_modal that doesn't pause
function Show_Retry_Dialog_From_Load_Dialog()
	Get_Game_Mode_GUI_Scene().Raise_Event("Show_Retry_Mission_Screen", nil, { "Retry_Dialog", "RetryDialog" })
end

function Show_Load_Dialog()
	local load_game_dialog = nil
	local game_scene = Get_Game_Mode_GUI_Scene()
	if TestValid(game_scene.Load_Game_Dialog) then
		load_game_dialog = game_scene.Load_Game_Dialog
	else
		load_game_dialog = game_scene.Create_Embedded_Scene("Load_Game_Dialog", "Load_Game_Dialog")
	end

	-- MLL: Let the save game dialog know that it was called from retry so that it won't show the load confirm dialog box.
	load_game_dialog.Set_In_Retry_Dialog()

	-- Needed so we can get the SAVE_LOAD_MODE_* constants
	if SaveLoadManager == nil then
		Register_Save_Load_Commands()
	end

	if Is_Single_Player_Skirmish() then
		load_game_dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	else
		load_game_dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	end
	load_game_dialog.Start_Modal(Show_Retry_Dialog_From_Load_Dialog)
	load_game_dialog.Display_Dialog()
end

function On_Retry_Response(dialog, response)
	if response == "Load" then
		Get_Game_Mode_GUI_Scene().RetryDialog.Set_Hidden(true)
		Show_Load_Dialog()
	elseif response == "Retry" then
		Restart_Tactical_Battle()
	else
		--Quit to main menu
		Quit_Game_Now(Find_Player("local").Get_Enemy(), true, true, false)
	end
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Define_Retry_State = nil
	On_Retry_Response = nil
	Retry_Current_Mission = nil
	Show_Retry_Dialog = nil
	Kill_Unused_Global_Functions = nil
end
