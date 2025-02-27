if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Live_Profile_Game_Dialog.lua#47 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Live_Profile_Game_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 97577 $
--
--          $DateTime: 2008/04/25 15:51:26 $
--
--          $Revision: #47 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("Common_Live_Profile_Game_Dialog")


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GUI_Init()
	CMCommon_GUI_Init()
	NetworkMessageProcessors[MESSAGE_TYPE_CLIENT_HAS_MAP]							= NMP_Client_Has_Map
	NetworkMessageProcessors[MESSAGE_TYPE_DOWNLOAD_PROGRESS]						= NMP_Download_Progress
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Register_Event_Handlers()

	CMCommon_Register_Event_Handlers()
	Live_Profile_Game_Dialog.Register_Event_Handler("Key_Focus_Lost", Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat, On_Chat_Input_Focus_Lost)
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Constants_Init()

	CMCommon_Constants_Init()
	
	LISTPLAY_SESSIONS_REFRESH_PERIOD = 60
	
	STAGING_VIEW_STATE_SETTINGS = Declare_Enum(1)
	STAGING_VIEW_STATE_CHAT = Declare_Enum()
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Variables_Init()

	CMCommon_Variables_Init()

	StagingViewState = STAGING_VIEW_STATE_CHAT
	Set_Staging_View(STAGING_VIEW_STATE_CHAT)
	
end

-------------------------------------------------------------------------------
-- This function may be called multiple times in order to reset all variables.
-------------------------------------------------------------------------------
function Variables_Reset()

	CMCommon_Variables_Reset()
	MapTransfers = {}
	
	MatchingState = Get_Profile_Value(PP_LOBBY_MATCHING_STATE, MATCHING_STATE_PLAYER_MATCH)
	if (Net.Requires_Locator_Service()) then
		MatchingState = MATCHING_STATE_LIST_PLAY
	end
	Set_Matching_State()

end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
--
-- NOTE:::  By default, yes/no, on/off, enabled/disabled combos are populated
-- first with the off option.
-------------------------------------------------------------------------------
function Initialize_Components()

	CMCommon_Initialize_Components()

	-- Initialize the Chat box
	CHAT_LIST_COLUMN = Create_Wide_String("CHAT_LIST_COLUMN")
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_Header_Style("NONE")
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Add_Column(CHAT_LIST_COLUMN, JUSTIFY_LEFT, true)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_Maximum_Rows(1000)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_List_Entry_Font("Chat_White")
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Enable_Selection_Highlight(false)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_Line_Wrapping_Enabled(true)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Refresh()

	-- XStringVerify has a max string size of 512 (including the NULL terminator)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Set_Text_Limit(511)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_Filters()

	-- --------------------------
	-- GAME FILTERS PANEL
	-- --------------------------
	local handle = nil
	local text_handle = nil
	
	ViewFilterComponents = {}
	
	-- Initialize the Map combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Map
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Map
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end

	local new_row = -1
	local player_count = Network_Get_Client_Table_Count(true)
	for _, dao in pairs(MPMapModel) do
		local display = Create_Wide_String()
		display.assign(dao.display_name)
		display.append(" (" .. dao.num_players .. ")")
		new_row = handle.Add_Item(display)
		if HostingGame and (player_count > dao.num_players) then
			handle.Set_Item_Color(new_row, 0.25, 0.25, 0.25, 1)
		else
			handle.Set_Item_Color(new_row, 1, 1, 1, 1)
		end
	end
	handle.Set_Selected_Index(0)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Map, Play_Option_Select_SFX)
	
	--Initialize the victory condition combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Win_Condition
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Win_Condition
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	for _, condition in pairs(VictoryConditionNames) do
		handle.Add_Item(condition)
	end
	handle.Set_Selected_Index(HostGameDefaults.VictoryCondition)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Win_Condition, Play_Option_Select_SFX)

	-- Initialize the DEFCON combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_DEFCON_Active
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_DEFCON_Active
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(HostGameDefaults.DEFCON)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_DEFCON_Active, Play_Option_Select_SFX)
	
	-- Initialize the alliances combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Alliances
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Alliances
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(HostGameDefaults.Alliances)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Alliances, Play_Option_Select_SFX)

	-- Initialize the medals combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Medals
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Medals
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(HostGameDefaults.Medals)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Medals, Play_Option_Select_SFX)

	-- Initialize the hero respawn combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Hero_Respawn
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Hero_Respawn
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(HostGameDefaults.HeroRespawn)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Hero_Respawn, Play_Option_Select_SFX)

	-- Initialize the starting credits combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Starting_Credits
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Starting_Credits
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	for _, value in ipairs(STARTING_CASH_VALUES) do
		handle.Add_Item(value.display)
	end
	--[[handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_SMALL])
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_MEDIUM])
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_LARGE])--]]
	handle.Set_Selected_Index(HostGameDefaults.StartingCredits)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Starting_Credits, Play_Option_Select_SFX)
	
	-- Initialize the population cap combo
	text_handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Unit_Population_Limit
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Unit_Population_Limit
	handle.Clear()
	handle.Enable(true)
	text_handle.Set_Tint(1, 1, 1, 1)
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
		if (Net.Requires_Locator_Service()) then
			handle.Enable(false)
			text_handle.Set_Tint(0.5, 0.5, 0.5, 0.5)
		end
	end
	for _, value in ipairs(POP_CAP_VALUES) do
		handle.Add_Item(value.display)
	end
	handle.Set_Selected_Index(HostGameDefaults.PopCap)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Unit_Population_Limit, Play_Option_Select_SFX)
	
	-- Initialize the gold only combo
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only
	handle.Clear()
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(HostGameDefaults.GoldOnly)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Gold_Only, Play_Option_Select_SFX)

	if ViewState == VIEW_STATE_GAME_OPTIONS_HOST then
	
		-- Initialize the private game combo
		handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Private_Game
		handle.Clear()
		handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
		handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
		handle.Set_Selected_Index(HostGameDefaults.Private)
		table.insert(ViewFilterComponents, handle)
		this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Private_Game, Play_Option_Select_SFX)

	end

	-- Initialize the Show Games in Progress Combo
	handle = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress
	handle.Clear()
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(0)
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Display_State_Changed", this.Panel_Game_Filters.Combo_Show_In_Progress, Play_Option_Select_SFX)
	
		
	CMCommon_Capture_Filter_Settings()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Host_Defaults()

	CMCommon_Set_Host_Defaults()
	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	panel.Combo_Gold_Only.Set_Selected_Index(HostGameDefaults.GoldOnly)
	panel.Combo_Alliances.Set_Selected_Index(HostGameDefaults.Alliances)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Join_Filter_Defaults()

	CMCommon_Set_Join_Filter_Defaults()
	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	panel.Combo_Gold_Only.Set_Selected_Index(HostGameDefaults.GoldOnly)
	panel.Combo_Alliances.Set_Selected_Index(JoinFilterDefaults.Alliances)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_Traversal()

	-- TAB ORDER --

	-- Custom Lobby Panel
	panel = Live_Profile_Game_Dialog.Panel_Custom_Lobby
	panel.List_Available_Games.Set_Tab_Order(Declare_Enum())
	panel.Button_Host_Game.Set_Tab_Order(Declare_Enum())
	panel.Button_Join_Game.Set_Tab_Order(Declare_Enum())
	panel.Button_Quickmatch.Set_Tab_Order(Declare_Enum())
	panel.Button_Gamer_Card.Set_Tab_Order(Declare_Enum())
	panel.Button_Filters.Set_Tab_Order(Declare_Enum())
	panel.Button_Medal_Chest.Set_Tab_Order(Declare_Enum())
		
	-- Filters Panel
	panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	panel.Combo_Map.Set_Tab_Order(Declare_Enum())
	panel.Combo_Win_Condition.Set_Tab_Order(Declare_Enum())
	panel.Combo_DEFCON_Active.Set_Tab_Order(Declare_Enum())
	panel.Combo_Alliances.Set_Tab_Order(Declare_Enum())
	panel.Combo_Medals.Set_Tab_Order(Declare_Enum())
	panel.Combo_Hero_Respawn.Set_Tab_Order(Declare_Enum())
	panel.Combo_Starting_Credits.Set_Tab_Order(Declare_Enum())
	panel.Combo_Unit_Population_Limit.Set_Tab_Order(Declare_Enum())
	panel.Combo_Private_Game.Set_Tab_Order(Declare_Enum())
	panel.Combo_Gold_Only.Set_Tab_Order(Declare_Enum())
	panel.Combo_Show_In_Progress.Set_Tab_Order(Declare_Enum())
	panel.Button_Accept.Set_Tab_Order(Declare_Enum())
	
	-- Game Staging Panel
	panel = Live_Profile_Game_Dialog.Panel_Game_Staging
	panel.Button_Cancel_Countdown.Set_Tab_Order(Declare_Enum())
	panel.Button_Tab_Settings.Set_Tab_Order(Declare_Enum())
	panel.Button_Tab_Chat.Set_Tab_Order(Declare_Enum())
	panel.Panel_Chat.Edit_Chat.Set_Tab_Order(Declare_Enum())
	panel.Button_Launch_Game.Set_Tab_Order(Declare_Enum())
	panel.Button_Edit_Settings.Set_Tab_Order(Declare_Enum())
	panel.Button_Kick_Player.Set_Tab_Order(Declare_Enum())
	panel.Button_Gamer_Card.Set_Tab_Order(Declare_Enum())
	panel.Button_Ready_Launch.Set_Tab_Order(Declare_Enum())
	panel.Button_Exit.Set_Tab_Order(Declare_Enum())
	
	-- Base Panel
	panel = Live_Profile_Game_Dialog
	panel.Button_Back.Set_Tab_Order(Declare_Enum(0))
	
	Live_Profile_Game_Dialog.Focus_First()
	
end
	
------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	CMCommon_Play_Mouse_Over_Button_SFX(event, source)
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	CMCommon_Play_Button_Select_SFX(event, source)
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	CMCommon_Play_Option_Select_SFX(event, source)
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Option_SFX(event, source)
	CMCommon_Play_Mouse_Over_Option_SFX(event, source)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Update_Selected_Player_View()

	local color_dao = CMCommon_Update_Selected_Player_View()

	if (color_dao ~= nil) then
	
		if (CurrentlySelectedClient.common_addr == LocalClient.common_addr) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Set_Color(color_dao["r"], 
																												color_dao["g"], 
																												color_dao["b"], 
																												color_dao["a"])
		end
			
	end
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- V I E W   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Chat_Input_Focus_Lost(event, source)

	-- If the chat edit box is visible, it should always have keyboard input focus
	if (StagingViewState == STAGING_VIEW_STATE_CHAT) then

		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Set_Key_Focus()

	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()

	CMCommon_On_Update()

	-- Check file transfers
	local completed_transfers = {}
	for common_addr, fto in pairs(MapTransfers) do
		if fto.file_transfer ~= nil then
			fto.file_transfer.Update()
			if fto.file_transfer.Is_Complete() then
				fto.file_transfer.Release_Resources()

				-- We send the map preivew before the map
				if HostingGame then
					if (not fto.preview_transfer_complete) then
						local map_dao = MPMapLookup[GameOptions.map_filename_only]
						fto.file_transfer = Net.Send_File(common_addr, map_dao.full_path)

						fto.preview_transfer_complete = true
						DebugMessage("LUA_LOBBY: Map preview upload complete")
					elseif (not fto.map_transfer_complete) then
						table.insert(completed_transfers, common_addr)

						fto.map_transfer_complete = true
						DebugMessage("LUA_LOBBY: Map upload complete")
					end
				else
					if (not fto.preview_transfer_complete) then
						-- Start receiving the map
						fto.file_transfer = Net.Receive_File(CurrentlyJoinedSession.common_addr, MapManager.Get_Custom_Map_Path())

						fto.preview_transfer_complete = true
						DebugMessage("LUA_LOBBY: Map preview download complete")
					elseif (not fto.map_transfer_complete) then
						fto.file_transfer = nil

						fto.map_transfer_complete = true
						DebugMessage("LUA_LOBBY: Map download complete")

						-- Update the list of multiplayer maps
						MapManager.Refresh_Map_List()
						MPMapModel = PGLobby_Generate_Map_Selection_Model()

						-- Refresh the settings
						Update_New_Game_Script_Data(GameScriptData)
						Refresh_Game_Settings_View()
					end
				end

				-- Download has completed
				Network_Broadcast(MESSAGE_TYPE_DOWNLOAD_PROGRESS, 100)
			elseif fto.file_transfer.Is_Failed() then
				fto.file_transfer.Release_Resources()
				table.insert(completed_transfers, common_addr)
			else
				local percent_complete = fto.file_transfer.Get_Progress_Percent()
				DebugMessage("LUA_LOBBY: File transfer progress: " .. tostring(percent_complete))

				if (not HostingGame) then
					Network_Broadcast(MESSAGE_TYPE_DOWNLOAD_PROGRESS, percent_complete)
				end
			end
		end
	end

	-- Kill off the completed map transfers
	for idx, common_addr in pairs(completed_transfers) do
		MapTransfers[common_addr] = nil
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Mouse_Move(event, source)
	CMCommon_On_Mouse_Move(event, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	CMCommon_On_Component_Shown()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Close_Dialog()

	CMCommon_Close_Dialog()
	FileTransferObject = nil -- clear out any map transfers that are in progress

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function View_Back_Out()
	CMCommon_View_Back_Out()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function View_Back_To_Start()
	CMCommon_View_Back_To_Start()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Empty_Space_Clicked()
	CMCommon_On_Empty_Space_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Back_Clicked()

	if (ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) then
		Populate_UI_From_Profile()
	end
	Persist_UI_To_Profile()
	CMCommon_On_Back_Clicked()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_My_Online_Profile_Clicked()
	CMCommon_On_My_Online_Profile_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Join_Game_Clicked()
	CMCommon_On_Join_Game_Clicked()
end

-------------------------------------------------------------------------------
-- The actual function which kicks off game hosting is CMCommon_Do_Host_Game()
-------------------------------------------------------------------------------
function On_Host_Game_Clicked()
	CMCommon_On_Host_Game_Clicked()
end

-------------------------------------------------------------------------------
-- This is the Edit Settings button you see in the staging screen when you
-- are the host.  We pop you into the host settings screen and then hide the 
-- Go button so all you can do is back out of it.
-------------------------------------------------------------------------------
function On_Edit_Settings_Clicked()
	CMCommon_On_Edit_Settings_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Button_Quickmatch_Clicked()
	CMCommon_On_Button_Quickmatch_Clicked()
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Button_Gamer_Card_Clicked()
	CMCommon_On_Button_Gamer_Card_Clicked()
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Lobby_Filters_Clicked()
	CMCommon_On_Lobby_Filters_Clicked()
end

-------------------------------------------------------------------------------
-- War Chest Button
-------------------------------------------------------------------------------
function On_Button_Medal_Chest_Clicked()
	CMCommon_On_Button_Medal_Chest_Clicked()
end
	
-------------------------------------------------------------------------------
-- If we're hosting a game, this screen is for changing the settings of the
-- existing game, otherwise we're just filtering the games we want to see
-- in the available games list.
-------------------------------------------------------------------------------
function On_Button_Filters_Accept_Clicked()
	CMCommon_On_Button_Filters_Accept_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()
	CMCommon_On_YesNoOk_Yes_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_No_Clicked()
	CMCommon_On_YesNoOk_No_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_Ok_Clicked()
	CMCommon_On_YesNoOk_Ok_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Set_Default_Clicked()
	CMCommon_On_Set_Default_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Medal_Mouse_On(event, source, achievement_id)
	CMCommon_On_Medal_Mouse_On(event, source, achievement_id)
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Medal_Mouse_Off(event, source)
	CMCommon_On_Medal_Mouse_Off(event, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Matching_Type_Mouse_On(event, source)
	CMCommon_On_Matching_Type_Mouse_On(event, source)
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Matching_Type_Mouse_Off(event, source)
	CMCommon_On_Matching_Type_Mouse_Off(event, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Name_Mouse_On(event, source, common_addr)
	CMCommon_On_Player_Name_Mouse_On(event, source, common_addr)
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Name_Mouse_Off(event, source)
	CMCommon_On_Player_Name_Mouse_Off(event, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Filters_Exit_Clicked()
	CMCommon_On_Filters_Exit_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Staging_Launch_Game_Clicked()
	CMCommon_On_Staging_Launch_Game_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Closing_All_Displays(event, source, suppress_prompts)

	if (ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) then
		Populate_UI_From_Profile()
	end
	CMCommon_On_Closing_All_Displays(event, source, suppress_prompts)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Staging_Exit_Clicked()
	CMCommon_On_Staging_Exit_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Lobby_Refresh_Clicked()
	CMCommon_On_Lobby_Refresh_Clicked()
end

-------------------------------------------------------------------------------
-- Just detects when the user presses "Enter" in his chat box and sends his
-- chat.
-------------------------------------------------------------------------------
function On_Chat_Input_Key_Press(event, source, key)

	-- If the user presses Enter, send the chat message!
	if (string.byte(key, 1) == 13) then
		local edit_text = Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Get_Text()
		if ((edit_text ~= nil) and (edit_text.length() > 0)) then
			Network_Broadcast(MESSAGE_TYPE_CHAT, edit_text)
			Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Set_Text("")
		end
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Start_Game_Countdown()
	CMCommon_Start_Game_Countdown()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_Countdown()
	CMCommon_Update_Countdown()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_AI_Player_Added(event, source, seat)
	CMCommon_On_AI_Player_Added(event, source, seat)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_AI_Player_Removed(event, source, common_addr)
	CMCommon_On_AI_Player_Removed(event, source, common_addr)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Settings_Tab_Clicked()
	Set_Staging_View(STAGING_VIEW_STATE_SETTINGS)
	CMCommon_Refresh_UI()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Chat_Tab_Clicked()
	Set_Staging_View(STAGING_VIEW_STATE_CHAT)
	CMCommon_Refresh_UI()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Match_Tab_Clicked()
	if (MatchingState == MATCHING_STATE_PLAYER_MATCH) then
		return
	end
	Set_Matching_State(MATCHING_STATE_PLAYER_MATCH)
	CMCommon_Set_Currently_Selected_Session(nil)
	CMCommon_Do_Manual_Refresh()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_List_Play_Tab_Clicked()
	if (MatchingState == MATCHING_STATE_LIST_PLAY) then
		return
	end
	Set_Matching_State(MATCHING_STATE_LIST_PLAY)
	CMCommon_Set_Currently_Selected_Session(nil)
	CMCommon_Do_Manual_Refresh()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Focused_Client_For_Edit()
	return CMCommon_Get_Focused_Client_For_Edit()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Staging_View(value)

	StagingViewState = value
	
	if (StagingViewState == STAGING_VIEW_STATE_SETTINGS) then
		this.Panel_Game_Staging.Quad_Settings_Highlight.Set_Hidden(false)
		this.Panel_Game_Staging.Quad_Chat_Highlight.Set_Hidden(true)
	elseif (StagingViewState == STAGING_VIEW_STATE_CHAT) then
		this.Panel_Game_Staging.Quad_Settings_Highlight.Set_Hidden(true)
		this.Panel_Game_Staging.Quad_Chat_Highlight.Set_Hidden(false)
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Faction_Up_Clicked()
	CMCommon_On_Player_Faction_Up_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Faction_Down_Clicked()
	CMCommon_On_Player_Faction_Down_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Team_Up_Clicked()
	CMCommon_On_Player_Team_Up_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Team_Down_Clicked()
	CMCommon_On_Player_Team_Down_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Color_Up_Clicked()
	CMCommon_On_Player_Color_Up_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Color_Down_Clicked()
	CMCommon_On_Player_Color_Down_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Difficulty_Up_Clicked()
	CMCommon_On_Player_Difficulty_Up_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Difficulty_Down_Clicked()
	CMCommon_On_Player_Difficulty_Down_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Ready_Clicked(event, source, is_ready)
	CMCommon_On_Ready_Clicked(event, source, is_ready)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Combo_Map_Selection_Changed()
	CMCommon_On_Combo_Map_Selection_Changed()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Combo_Starting_Credits_Changed()
	CMCommon_On_Combo_Starting_Credits_Changed()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Cluster_Clicked(event_label, _, common_addr)
	CMCommon_On_Player_Cluster_Clicked(event_label, _, common_addr)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Cancel_Countdown_Clicked()
	CMCommon_On_Cancel_Countdown_Clicked()
end

-------------------------------------------------------------------------------
-- Kick Player Button
-------------------------------------------------------------------------------
function On_Kick_Player_Clicked(event_name, source)
	CMCommon_On_Kick_Player_Clicked(event_name, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Available_Games_Selection_Changed()
	CMCommon_On_Available_Games_Selection_Changed()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_On_Start_Marker_Clicked(source)

	-- If we're the host, we want to check which client is currently selected.
	local target_client = CurrentlySelectedClient
	
	-- If we're the guest, our target client is ALWAYS ourselves.
	if (JoinedGame and (not HostingGame)) then
		target_client = LocalClient
	end
	
	CMCommon_PGMO_On_Start_Marker_Clicked(source, target_client)

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_View_State(state)
	CMCommon_Set_View_State(state)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Matching_State(state)

	if ((MatchingState == nil) and (state == nil)) then
		MatchingState = MATCHING_STATE_LIST_PLAY
		state = MATCHING_STATE_LIST_PLAY
	end

	if (state == nil) then
		state = MatchingState
	else
		MatchingState = state
	end
	
	if (MatchingState == nil) then
		MatchingState = state
	end
	
	if (MatchingState == MATCHING_STATE_PLAYER_MATCH) then
		this.Panel_Custom_Lobby.Panel_Matching_State.Quad_List_Play_Highlight.Set_Hidden(true)
		this.Panel_Custom_Lobby.Panel_Matching_State.Quad_Player_Match_Highlight.Set_Hidden(false)
		AVAILABLE_SESSIONS_REFRESH_PERIOD = INTERNET_SESSIONS_REFRESH_PERIOD
	elseif (MatchingState == MATCHING_STATE_LIST_PLAY) then
		this.Panel_Custom_Lobby.Panel_Matching_State.Quad_List_Play_Highlight.Set_Hidden(false)
		this.Panel_Custom_Lobby.Panel_Matching_State.Quad_Player_Match_Highlight.Set_Hidden(true)
		AVAILABLE_SESSIONS_REFRESH_PERIOD = LISTPLAY_SESSIONS_REFRESH_PERIOD
	end
	
	Set_Profile_Value(PP_LOBBY_MATCHING_STATE, MatchingState)
	
end

-------------------------------------------------------------------------------
-- This function is the central locus of presentation for the entire lobby.
-- All code related to showing/hiding UI elements, population and configuration
-- of UI elements, or any view-layer functionality related to a view state 
-- change should be implemented here.
-------------------------------------------------------------------------------
function Refresh_UI()
	CMCommon_Refresh_UI()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Options()

	CMCommon_Refresh_Options()
	
	Live_Profile_Game_Dialog.Button_Back.Set_Hidden(false)
	
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or (ViewState == VIEW_STATE_GAME_FILTERS_JOIN)) then
		Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Set_Default.Set_Hidden(false)
	else
		Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Set_Default.Set_Hidden(true)
	end
				
	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		if (JoinState == JOIN_STATE_GUEST) then
		
			-- Unfortunately we cannot show games in progress in player match!!
			if (MatchingState == MATCHING_STATE_PLAYER_MATCH) then
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Gold_Only.Set_Hidden(true)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Set_Hidden(true)
			else
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Gold_Only.Set_Hidden(false)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Set_Hidden(false)
			end 
			
		elseif (JoinState == JOIN_STATE_HOST) then
		
			if (MatchingState == MATCHING_STATE_PLAYER_MATCH) then
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Gold_Only.Set_Hidden(true)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Set_Hidden(true)
			else
				if ((not Net.Requires_Locator_Service()) and (ViewState == VIEW_STATE_GAME_OPTIONS_HOST)) then
					Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Gold_Only.Set_Hidden(false)
					Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Set_Hidden(false)
				else
					Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Gold_Only.Set_Hidden(true)
					Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Set_Hidden(true)
				end
			end
			
		end
		
	else
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Gold_Only.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Set_Hidden(true)
		
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Quickmatch()
	CMCommon_Refresh_Quickmatch()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Custom_Lobby()

	CMCommon_Refresh_Custom_Lobby()
	
	Live_Profile_Game_Dialog.Button_Back.Set_Hidden(false)

		
	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Panel_Matching_State.Set_Hidden(false)
		-- Gold / Silver / List Play / Player Match
		if (Net.Requires_Locator_Service()) then
			-- Silver
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Panel_Matching_State.Button_Player_Match.Enable(false)
		else
			-- Silver
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Panel_Matching_State.Button_Player_Match.Enable(true)
		end
		
	else
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Panel_Matching_State.Set_Hidden(true)
	end
	
	-- Filters and profile don't apply to LAN gaming.
	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Gamer_Card.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Medal_Chest.Set_Hidden(false)

		if Net.Requires_Locator_Service() then
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Quickmatch.Set_Hidden(true)
		else
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Quickmatch.Set_Hidden(false)
		end
		
	end
	
	-- Is there a session selected?
	local session = CMCommon_Get_Currently_Selected_Session()
	if ((session == nil) or (not session.is_joinable)) then
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Enable(false)
	else
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Enable(true)
	end
	
	-- Show server count?
	if ((NetworkState == NETWORK_STATE_INTERNET) and (MatchingState == MATCHING_STATE_LIST_PLAY)) then
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Server_Count.Set_Hidden(false)
	else
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Server_Count.Set_Hidden(true)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Staging()

	CMCommon_Refresh_Staging()
		
	-- Deal with internet-only buttons
	if (NetworkState == NETWORK_STATE_INTERNET) then
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Gamer_Card.Set_Hidden(false)
	elseif (NetworkState == NETWORK_STATE_LAN) then
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Gamer_Card.Set_Hidden(true)
	end
	
	-- General buttons
	Live_Profile_Game_Dialog.Button_Back.Set_Hidden(true)
	
	if (ValidMapSelection) then
		PGMO_Set_Interactive(true)
	end
		
	-- Deal with host-only buttons.
	if (JoinState == JOIN_STATE_HOST) then
		-- The host sees a "Launch Game" button...
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Launch_Game.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Edit_Settings.Set_Hidden(false)
	elseif (JoinState == JOIN_STATE_GUEST) then
		-- Guests see a "Ready" button...
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Launch_Game.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Edit_Settings.Set_Hidden(true)
	end

	Refresh_Start_Conditions_View()

	-- Countdown in progress?
	if (JoinState == JOIN_STATE_GUEST) then
	
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Cancel_Countdown.Set_Hidden(true)
		
	elseif (JoinState == JOIN_STATE_HOST) then
	
		if (StartGameCountdown >= 0) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Cancel_Countdown.Set_Hidden(false)
		else
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Cancel_Countdown.Set_Hidden(true)
		end

	end
	if (GameIsStarting) or ((StartGameCountdown ~= -1)) then
		-- If a game is starting, you can't exit out.
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Exit.Enable(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Edit_Settings.Enable(false)
	else
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Exit.Enable(true)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Edit_Settings.Enable(true)
	end

	Refresh_Game_Settings_View()
		
	-- ------------------------------------------------------------------------
	-- Handle visibility of the tier 2 panels
	-- ------------------------------------------------------------------------
	if (StagingViewState == STAGING_VIEW_STATE_SETTINGS) then
	
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Set_Hidden(true)
		
	elseif (StagingViewState == STAGING_VIEW_STATE_CHAT) then
	
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Set_Key_Focus()
		
	end
	
end

-------------------------------------------------------------------------------
-- Any UI elements which may be holding data that shouldn't persist when 
-- the lobby is backed out of should be cleared here.
-------------------------------------------------------------------------------
function Clear_UI()

	CMCommon_Clear_UI()
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Clear()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Enable_Settings_Accept_UI(enable)
	CMCommon_Enable_Settings_Accept_UI(enable)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Hide_Lobby_Session_Settings(hidden)

	CMCommon_Hide_Lobby_Session_Settings(hidden)

	if (MatchingState == MATCHING_STATE_LIST_PLAY) then
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Gold_Only.Set_Hidden(hidden)
	else
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Gold_Only.Set_Hidden(true)
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Lobby_Session_Settings(session)

	CMCommon_Set_Lobby_Session_Settings(session)

	-- Gold Only
	label = Get_Game_Text("TEXT_GOLD_ONLY").append(": ")
	value = session.gold_only
	if value ~= nil then
		if value == true then
			label = label.append(TEXT_YES)
		else
			label = label.append(TEXT_NO)
		end
	else
		label = label.append(Get_Game_Text("TEXT_NOT_AVAILABLE"))
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Gold_Only.Set_Text(label)

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Game_Is_Starting(game_is_starting)
	CMCommon_Set_Game_Is_Starting(game_is_starting)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Game_Settings_View()

	-- Can't refresh the view until we know the data!
	if JoinState == JOIN_STATE_GUEST and not Recieved_Game_Settings then return end

	-- Map
	local map = NO_MAP_PREVIEW_TEXTURE 
	local valid_map = false
	if (GameOptions.map_filename_only ~= nil) then
		valid_map = true
		map = GameOptions.map_filename_only
	end
	
	local map_preview = map .. ".tga" 
	Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Text(map)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Texture(tostring(map_preview))
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Render_Mode(0)
	
	-- Starting Cash
	local starting_cash = GameOptions.starting_credit_level
	if (starting_cash == nil) then
		starting_cash = PG_FACTION_CASH_MEDIUM
	end
	starting_cash = Get_Game_Text(GAME_CREDITS_LEVEL_VIEW[starting_cash])
	
	-- DEFCON
	local defcon = TEXT_NO
	if (GameScriptData.is_defcon_game) then
		defcon = TEXT_YES
	end
	
	-- Win Condition
	local win_condition = VictoryConditionNames[GameScriptData.victory_condition]
	
	-- Medals
	local medals = TEXT_NO
	if ((NetworkState == NETWORK_STATE_INTERNET) and (GameScriptData.medals_enabled)) then
		medals = TEXT_YES
	end
	
	-- Alliances
	local alliances = TEXT_NO
	if GameOptions.alliances_enabled then
		alliances = TEXT_YES
	end
	
	-- Hero Respawn
	local hero_respawn = TEXT_NO
	if GameOptions.hero_respawn then
		hero_respawn = TEXT_YES
	end

	-- Pop Cap
	local pop_cap = tostring(GameOptions.pop_cap_override)
	
	-- AI Slots
	local ai_slots = tostring(Network_Get_AI_Player_Count())
	
	-- Prepare the complete labels
	if (GameOptions.map_display_name == nil) then
		GameOptions.map_display_name = "INVALID"
	end
	local map_label = Get_Game_Text("TEXT_INTERNET_MAP_NAME").append(" ").append(GameOptions.map_display_name)
	local starting_cash_label = Get_Game_Text("TEXT_MULTIPLAYER_STARTING_CASH").append(": ").append(starting_cash)
	local defcon_label = Get_Game_Text("TEXT_MULTIPLAYER_DEFCON").append(": ").append(defcon)
	local win_condition_label = Get_Game_Text("TEXT_WIN_CONDITION").append(": ").append(win_condition)
	local medals_label = Get_Game_Text("TEXT_MULTIPLAYER_ALLOW_MEDALS").append(": ").append(medals)
	local alliances_label = Get_Game_Text("TEXT_MULTIPLAYER_ALLIANCES").append(": ").append(alliances)
	local hero_respawn_label = Get_Game_Text("TEXT_MULTIPLAYER_HERO_RESPAWN").append(": ").append(hero_respawn)
	local pop_cap_label = Get_Game_Text("TEXT_MULTIPLAYER_UNIT_POP_CAP").append(": ").append(pop_cap)
	local ai_slots_label = Get_Game_Text("TEXT_MULTIPLAYER_AI_SLOTS").append(": ").append(ai_slots)
	

	-- Display!
	Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Text(map_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Texture(tostring(map_preview))
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Render_Mode(0)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_Starting_Cash.Set_Text(starting_cash_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_DEFCON.Set_Text(defcon_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_Win_Condition.Set_Text(win_condition_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_Medals.Set_Text(medals_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_Alliances.Set_Text(alliances_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_Hero_Respawn.Set_Text(hero_respawn_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_Pop_Cap.Set_Text(pop_cap_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Settings.Text_AI_Slots.Set_Text(ai_slots_label)
	
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Persist_Host_UI_To_Profile()

	CMCommon_Persist_Host_UI_To_Profile()
	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	Set_Profile_Value(PP_LOBBY_HOST_ALLIANCES, panel.Combo_Alliances.Get_Selected_Index())
	
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Persist_Filters_To_Profile()

	CMCommon_Persist_Filters_To_Profile()
	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	Set_Profile_Value(PP_LOBBY_FILTER_ALLIANCES, panel.Combo_Alliances.Get_Selected_Index())
	
end

------------------------------------------------------------------------------
-- Persist pertinent UI elements to the profile.
------------------------------------------------------------------------------
function Persist_UI_To_Profile()

	-- Player identity options
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		CMCommon_Persist_Staging_UI_To_Profile()
	end
	
	-- Game hosting options
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		Persist_Host_UI_To_Profile()
		Set_Profile_Value(PP_LOBBY_HOST_GOLD_ONLY, Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Get_Selected_Index())
	end
		
	-- Game filters
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		Persist_Filters_To_Profile()
		Set_Profile_Value(PP_LOBBY_FILTER_GOLD_ONLY, Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Get_Selected_Index())
	end

end

------------------------------------------------------------------------------
-- Persist pertinent UI elements to the profile.
------------------------------------------------------------------------------
function Populate_UI_From_Profile()

	local index = -1
	
	LocalClient.faction = Get_Profile_Value(PP_LOBBY_PLAYER_FACTION, LOBBY_DEFAULT_FACTION)
	LocalClient.team = Get_Profile_Value(PP_LOBBY_PLAYER_TEAM, LOBBY_DEFAULT_TEAM)
	LocalClient.color = PGLobby_Get_Preferred_Color()

	LocalClient.faction = CMCommon_Validate_Client_Faction(LocalClient.faction)
		
	-- Now that the local client's preferences have been loaded, make sure we
	-- update everything else to do with the LocalClient.
	CMCommon_Update_Local_Client()
		
	-- Game hosting options
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		
		local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
		
		index = Get_Profile_Value(PP_LOBBY_HOST_MAP, 0)
		if ((index >= 0) and (index < #MPMapModel)) then
			panel.Combo_Map.Set_Selected_Index(index)
		else
			panel.Combo_Map.Set_Selected_Index(0)
		end
		
		index = Get_Profile_Value(PP_LOBBY_HOST_WIN_CONDITION, HostGameDefaults.VictoryCondition)
		panel.Combo_Win_Condition.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_DEFCON, HostGameDefaults.DEFCON)
		panel.Combo_DEFCON_Active.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_ALLIANCES, HostGameDefaults.Alliances)
		panel.Combo_Alliances.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_ACHIEVEMENTS, HostGameDefaults.Medals)
		panel.Combo_Medals.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_HERO_RESPAWN, HostGameDefaults.HeroRespawn)
		panel.Combo_Hero_Respawn.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_STARTING_CREDITS, HostGameDefaults.StartingCredits)
		panel.Combo_Starting_Credits.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_POP_CAP, HostGameDefaults.PopCap)
		panel.Combo_Unit_Population_Limit.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_PRIVATE_GAME, HostGameDefaults.Private)
		panel.Combo_Private_Game.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_HOST_GOLD_ONLY, HostGameDefaults.GoldOnly)
		panel.Combo_Gold_Only.Set_Selected_Index(index)

		Refresh_Game_Settings_Model()
	end

	-- Game filters
	if ((ViewState == VIEW_STATE_GAME_FILTERS_QUICKMATCH_JOIN) or
		(ViewState == VIEW_STATE_GAME_FILTERS_JOIN)) then
		
		local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
		
		index = Get_Profile_Value(PP_LOBBY_FILTER_MAP, JoinFilterDefaults.Map)
		panel.Combo_Map.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_WIN_CONDITION, JoinFilterDefaults.VictoryCondition)
		panel.Combo_Win_Condition.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_DEFCON, JoinFilterDefaults.DEFCON)
		panel.Combo_DEFCON_Active.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_ALLIANCES, JoinFilterDefaults.Alliances)
		panel.Combo_Alliances.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_ACHIEVEMENTS, JoinFilterDefaults.Medals)
		panel.Combo_Medals.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_HERO_RESPAWN, JoinFilterDefaults.HeroRespawn)
		panel.Combo_Hero_Respawn.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_STARTING_CREDITS, JoinFilterDefaults.StartingCredits)
		panel.Combo_Starting_Credits.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_POP_CAP, JoinFilterDefaults.PopCap)
		panel.Combo_Unit_Population_Limit.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_SHOW_GAMES_IN_PROGRESS, JoinFilterDefaults.ShowInProgress)
		panel.Combo_Show_In_Progress.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_LOBBY_FILTER_GOLD_ONLY, JoinFilterDefaults.GoldOnly)
		panel.Combo_Gold_Only.Set_Selected_Index(index)

	end
	
end

------------------------------------------------------------------------------
-- Update the chat window.
------------------------------------------------------------------------------
function Append_To_Chat_Window(text, color)

	if (color == nil) then
		color = CHAT_GRAY
	end
	local new_row = Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Add_Row()
	if (color == SYSTEM_CHAT_COLOR) then
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_Row_Color(new_row, tonumber(color))
	else
		local label = ({ [1] = "WHITE", [2] = "RED", [3] = "ORANGE", [4] = "YELLOW", [5] = "GREEN", [6] = "CYAN", [7] = "BLUE", [8] = "PURPLE", [9] = "GRAY", })[tonumber(color)]
		local dao = ({ YELLOW = { a = 1, b = 0.18, g = 0.87, r = 0.89, }, CYAN = { a = 1, b = 0.88, g = 0.85, r = 0.44, }, RED = { a = 1, b = 0.09, g = 0.09, r = 1, }, BLUE = { a = 1, b = 1, g = 0.59, r = 0.31, }, WHITE = { a = 1, b = 1, g = 1, r = 1, }, PURPLE = { a = 1, b = 0.82, g = 0.44, r = 1, }, ORANGE = { a = 1, b = 0.09, g = 0.58, r = 1, }, GREEN = { a = 1, b = 0.31, g = 1, r = 0.47, }, GRAY = { a = 1, b = 0.12, g = 0.12, r = 0.12, }, })[label]
		Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_Row_Color(new_row, dao["r"], dao["g"], dao["b"], dao["a"])
	end
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Set_Text_Data(CHAT_LIST_COLUMN, new_row, Create_Wide_String(text))
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Scroll_To_Bottom()
	
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Report_System_Event(text, color)
	Append_To_Chat_Window(text, color)
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Set_Currently_Selected_Client(client)
	CMCommon_Set_Currently_Selected_Client(client)
end
	
---------------------------------------
--
---------------------------------------
function Refresh_Start_Conditions_View()

	local can_start, messages, only_awaiting_acceptance = CMCommon_Refresh_Start_Conditions_View()
	
	-- Start game?
	if (HostingGame) then
	
		-- If we're the host, our Launch Game button only lights up if everyone else in the session has accepted settings.
		if (can_start and HostingGame and (StartGameCountdown == -1) and (not GameIsStarting)) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Launch_Game.Enable(true)
		else
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Launch_Game.Enable(false)
		end
		
	else
	
		-- If we're the guest our ready button only lights up if all the conditions for a valid game launch are met.
		if (only_awaiting_acceptance) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Enable(true)
		else
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Enable(false)
		end
		
	end
	
end
	
-------------------------------------------------------------------------------
-- This event is raised whenever the menu system is awakened after a game mode.
-- We're only interested in it if we have spawned a multiplayer game here, so
-- if that flag is not set, we ignore the event.
-------------------------------------------------------------------------------
function On_Menu_System_Activated()
	 CMCommon_On_Menu_System_Activated()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Join_Attempt_Cancelled()
	On_Lobby_Refresh_Clicked()
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- N E T W O R K I N G   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Called when someone issues a join/leave request for our game.
-------------------------------------------------------------------------------
function Network_On_Connection_Status(event)

	CMCommon_Network_On_Connection_Status(event)
	
	if event.status == "connected" then

		if (JoinedGame == false) then 
		
			Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Clear()
			local wstr_joined = Get_Game_Text("TEXT_PLAYER_JOINED_STRING")
			Replace_Token(wstr_joined, LocalClient.name, 0)
			Append_To_Chat_Window(wstr_joined, SYSTEM_CHAT_COLOR)
			
		end

	elseif (event.status == "session_disconnect" and (not GameHasStarted)) then
	
		if ((HostingGame == false) and JoinedGame and host_disconnected) then
		
			-- We are a guest and the host left the game.
			-- Currently do nothing.
			
		else
		
			-- We are host or guest and a guest left the game.
			local client = Network_Get_Client(event.common_addr)
			
			-- Indicate in the chat window that a player has left the game.
			if (client ~= nil) then
				-- It can be possible that a player leaves a session before having transmitted their name.
				local name = Get_Game_Text("TEXT_UNKNOWN")
				if (client.name ~= nil) then
					name = client.name
				end
				local wstr_left = Get_Game_Text("TEXT_PLAYER_LEFT_STRING")
				Replace_Token(wstr_left, name, 0)
				Append_To_Chat_Window(wstr_left, SYSTEM_CHAT_COLOR)
			end
			
		end

	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Internet_On_MM_Create_Session()
	CMCommon_Internet_On_MM_Create_Session()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_On_Find_Internet_Session(event)

	CMCommon_Network_On_Find_Internet_Session(event)
	if (NetworkState == NETWORK_STATE_INTERNET) then
		if (MatchingState == MATCHING_STATE_LIST_PLAY) then
			Net.Request_Locator_Server_Count()
		end
	end
	
	if (ShowNATInfo) then
		ShowNATInfo = false
		PGLobby_Display_NAT_Information(Live_Profile_Game_Dialog.Text_NAT_Type)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_On_Find_LAN_Session(event)
	CMCommon_Network_On_Find_LAN_Session(event)
end

-------------------------------------------------------------------------------
-- Central message processor.
-- All the NMP_* functions are called from here.
-------------------------------------------------------------------------------
function Network_On_Message(event)
	CMCommon_Network_On_Message(event)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Client_Has_Map(event, client)

	local has_map = event.message
	if ((HostingGame) and (not has_map)) then
		-- This is safe to do because the filters page will hold the last map that was selected by the host
		-- before accepting the settings. Grabbing the texture path from the custom lobby though could have
		-- some timing dependencies.
		local map_preview_path = Live_Profile_Game_Dialog.Panel_Game_Filters.Quad_Map_Preview.Get_Full_Texture_Name()

		local fto = {}
		fto.file_transfer = Net.Send_File(client.common_addr, map_preview_path)

		MapTransfers[client.common_addr] = fto
	end
	CMCommon_Set_Client_Map_Validity(client.common_addr, has_map)
	ValidMapSelection = CMCommon_Check_Client_Map_Validity()
	CMCommon_Check_Game_Start_Conditions()
	return true

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Download_Progress(event, client)

	local progress = event.message
	if ((progress < 0) or (progress >= 100)) then
		client.download_progress = nil
	else
		client.download_progress = progress / 100
	end

	CMCommon_Update_Player_List()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_On_Text_Verified(event)

	if (event.rejected) then
	
		local message = Create_Wide_String(WIDE_OPEN_BRACE)
		message = message.append(Get_Game_Text("TEXT_CHAT_REJECTED"))
		message = message.append(WIDE_CLOSE_BRACE)
		message = Replace_Token(message, event.sender, 1)
		Append_To_Chat_Window(message, SYSTEM_CHAT_COLOR)

	else
		Append_To_Chat_Window(event.message, event.color)
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Internet_On_Lobby_Init()
	CMCommon_Internet_On_Lobby_Init()
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function On_Enumerate_Achievements(event)
	CMCommon_On_Enumerate_Achievements(event)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Query_Medals_Progress_Stats(event)
	CMCommon_On_Query_Medals_Progress_Stats(event)
end	

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function Network_On_Live_Connection_Changed(event)
	CMCommon_Network_On_Live_Connection_Changed(event)
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function Network_On_Locator_Server_Count(event)
	CMCommon_Network_On_Locator_Server_Count(event)
end

-------------------------------------------------------------------------------
-- Called when the backend has retrieved a gamer picture for us.
-------------------------------------------------------------------------------
function Network_On_Gamer_Picture_Retrieved(event)
	-- Do nothing
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Leave_Game(clear_session_selection)
	CMCommon_Leave_Game(clear_session_selection)

	Stop_All_Map_Transfers()

	-- Re-enable the map preview in case it was hidden because you did not have the map
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Hidden(false)

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Initialize_Game_Hosting()

	CMCommon_Initialize_Game_Hosting()
	
	-- Chat
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.List_Chat.Clear()
	Live_Profile_Game_Dialog.Panel_Game_Staging.Panel_Chat.Edit_Chat.Set_Text("")
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Reinitialize_Game_Hosting()
	CMCommon_Reinitialize_Game_Hosting()
end

-------------------------------------------------------------------------------
-- The host calls this to collect all the game settings from the setup screen
-- into the various data structures that will be used to broadcast the
-- settings to other players and to start the game.  The host IGNORES game
-- settings broadcasts altogether.
-------------------------------------------------------------------------------
function Refresh_Game_Settings_Model(full_reset)

	-- Let the player know if this is a gold only list play game or not
	if (MatchingState == MATCHING_STATE_LIST_PLAY and not Net.Requires_Locator_Service()) then
		index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Get_Selected_Index()
		if index == COMBO_SELECTION_YES then
			GameOptions.gold_only = true
		else
			GameOptions.gold_only = false
		end
	end
	
	CMCommon_Refresh_Game_Settings_Model(full_reset)
	
	-- Alliances
	if (GameAdvertiseData ~= nil) then
	
		GameOptions.alliances_enabled = false
		if (Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Alliances.Get_Selected_Index() == COMBO_SELECTION_YES) then
			GameOptions.alliances_enabled = true
		end
		if GameOptions.alliances_enabled then
			GameAdvertiseData[PROPERTY_ALLIANCES_ENABLED] = 1
		else
			GameAdvertiseData[PROPERTY_ALLIANCES_ENABLED] = 0
		end
	
	end
	
end

-------------------------------------------------------------------------------
-- A client calls this to collect all the game filters from the setup screen
-- into the data structure that will be used to search for available games
-------------------------------------------------------------------------------
function Refresh_Game_Filtering()
	
	local game_search_params = {}
	
	-- Gold Only
	if (MatchingState == MATCHING_STATE_LIST_PLAY) then
		index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Gold_Only.Get_Selected_Index()
		if (index ~= COMBO_SELECTION_FILTER_ANY) then
			if (index == COMBO_SELECTION_FILTER_YES) then
				game_search_params.gold_only = true
			else
				game_search_params.gold_only = false
			end
		end
	end

	CMCommon_Refresh_Game_Filtering(game_search_params)
	
end
	    
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_New_Game_Script_Data(game_script_data)
	
	-- If the map has changed, clear out start positions.
	if (GameOptions.map_crc ~= game_script_data.GameOptions.map_crc) then
		PGNetwork_Clear_Start_Positions()
		PGMO_Clear_Start_Positions() 
	end

	-- Set our new game settings
	Recieved_Game_Settings = true
	GameScriptData = game_script_data
	GameOptions = GameScriptData.GameOptions
	local map_dao = PGLobby_Lookup_Map_DAO(GameOptions.map_filename_only)
	
	if (map_dao == nil) then
	
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Play()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Hidden(true)
		PGMO_Hide()
		ValidMapSelection = false
		CMCommon_Check_Game_Start_Conditions()

		if (Net.Allow_User_Created_Content(CurrentlyJoinedSession.xuid) == false) then
			ForceSessionLeave = true
			PGLobby_Display_Modal_Message("TEXT_USER_CREATED_CONTENT_NOT_ALLOWED")
		else
			local file_transfer_object = {}
			file_transfer_object.file_transfer = Net.Receive_File(CurrentlyJoinedSession.common_addr, MapManager.Get_Custom_Map_Path())
			MapTransfers[LocalClient.common_addr] = file_transfer_object
			Network_Broadcast(MESSAGE_TYPE_CLIENT_HAS_MAP, false)
		end
		
	else
	
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Hidden(false)
		PGMO_Show()
		
		ValidMapSelection = true
		GameOptions.map_name = MAP_DIRECTORY .. tostring(map_dao.file_name)
		GameOptions.map_display_name = map_dao.display_name
		GameOptions.map_preview = GameOptions.map_filename_only .. ".tga"
		GameOptions.map_crc = map_dao.map_crc
		DebugMessage("LUA_LOBBY: GAME SETTING: Map: " .. tostring(GameOptions.map_filename_only))
		if (map_dao.incomplete) then
			PGMO_Set_Enabled(false)
		else
			PGMO_Set_Enabled(true)
			PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
			local status, errors = PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions)
			if (not status) then
				PGMO_Set_Enabled(false)
				PGLobby_Display_Modal_Message(errors)
			end
		end

		Network_Calculate_Initial_Max_Player_Count()
		Network_Broadcast(MESSAGE_TYPE_CLIENT_HAS_MAP, true)
		
	end
		
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- M I S C 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Preferred_Color()

	local color = Get_Profile_Value(PP_COLOR_INDEX, ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[0])
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[color]
	if (color == nil or index == nil) then
		color = 17
	else
		color = tonumber(color)
	end
	
	return color
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Chest_Closing()
	CMCommon_On_Medal_Chest_Closing()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Heavyweight_Child_Scene_Closing()
	CMCommon_Heavyweight_Child_Scene_Closing()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Staging_Map_Overlay()
	CMCommon_Refresh_Staging_Map_Overlay()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Stop_All_Map_Transfers()

	for _, fto in pairs(MapTransfers) do
		if fto.file_transfer ~= nil then
			fto.file_transfer.Release_Resources()
		end
	end

	MapTransfers = {}

	if LocalClient ~= nil then
		LocalClient.download_progress = nil
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Quickmatching_State()

	QuickMatchRequested = true
	PGLobby_Display_Custom_Modal_Message("TEXT_MULTIPLAYER_QUICK_MATCH_SEARCHING", "", "TEXT_BUTTON_CANCEL", "")
	this.Button_Back.Enable(false)
	this.Panel_Custom_Lobby.Button_Filters.Enable(false)
	this.Panel_Custom_Lobby.Button_Medal_Chest.Enable(false)
	this.Panel_Custom_Lobby.Button_Quickmatch.Enable(false)
	this.Panel_Custom_Lobby.Button_Join_Game.Enable(false)
	this.Panel_Custom_Lobby.Button_Host_Game.Enable(false)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function End_Quickmatching_State()

	QuickMatchRequested = false
	this.Button_Back.Enable(true)
	this.Panel_Custom_Lobby.Button_Filters.Enable(true)
	this.Panel_Custom_Lobby.Button_Medal_Chest.Enable(true)
	this.Panel_Custom_Lobby.Button_Quickmatch.Enable(true)
	this.Panel_Custom_Lobby.Button_Host_Game.Enable(true)
	
	local session = CMCommon_Get_Currently_Selected_Session()
	if ((session == nil) or (not session.is_joinable)) then
		this.Panel_Custom_Lobby.Button_Join_Game.Enable(false)
	else
		this.Panel_Custom_Lobby.Button_Join_Game.Enable(true)
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Finished_Invitation()
	CMCommon_Set_Finished_Invitation()
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	CMCommon_Verify_Guest_Join_Attempt = nil
	Check_Accept_Status = nil
	Check_Unique_Teams = nil
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
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Get_Preferred_Color = nil
	Is_Player_Of_Faction = nil
	Min = nil
	Network_Add_Reserved_Players = nil
	Network_Broadcast_Reset_Start_Positions = nil
	Network_Get_Client_By_ID = nil
	Network_Get_Client_From_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	On_Filters_Exit_Clicked = nil
	OutputDebug = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Request_All_Medals_Progress_Stats = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Request_Global_Conquest_Properties = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Player_Solid_Color = nil
	PGMO_Assign_Random_Start_Position = nil
	PGMO_Disable_Neutral_Structure = nil
	PGMO_Enable_Neutral_Structure = nil
	PGMO_Get_First_Empty_Start_Position = nil
	PGMO_Get_Reverse_First_Empty_Start_Position = nil
	PGMO_Is_Seat_Assigned = nil
	PGMO_Restore_Start_Position_Assignments = nil
	PGMO_Set_Marker_Size = nil
	PGOfflineAchievementDefs_Init = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_Local_User_Applied_Medals = nil
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
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	Kill_Unused_Global_Functions = nil
end

