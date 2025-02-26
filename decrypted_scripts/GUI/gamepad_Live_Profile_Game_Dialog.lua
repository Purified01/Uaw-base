if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Live_Profile_Game_Dialog.lua#77 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Live_Profile_Game_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 97577 $
--
--          $DateTime: 2008/04/25 15:51:26 $
--
--          $Revision: #77 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("Common_Live_Profile_Game_Dialog")

ScriptPoolCount = 0

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
	Initialize_Gamepad_Interaction()
	
	--Only register for sfx handlers once everything is setup, otherwise there will be a flurry of sound when the dialog starts
	Register_SFX_Event_Handlers()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Register_Event_Handlers()

	CMCommon_Register_Event_Handlers()

	this.Register_Event_Handler("Player_Difficulty_Set", nil, On_Player_Difficulty_Set)
	this.Register_Event_Handler("Spawn_Location_Up", nil, On_Spawn_Location_Up)
	this.Register_Event_Handler("Spawn_Location_Down", nil, On_Spawn_Location_Down)
	this.Register_Event_Handler("Cluster_Claiming_Focus", nil, On_Cluster_Claiming_Focus)
	
	-- [JLH 12/03/2007]:  New embedded staging settings events.
	this.Register_Event_Handler("Exit_Staging_Settings", nil, Exit_Staging_Settings)
	this.Register_Event_Handler(
		"Staging_Settings_Combo_Map_Changed", 
		nil, 
		On_Staging_Settings_Combo_Map_Changed)

end

function Register_SFX_Event_Handlers()
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Map, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Map, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Win_Condition, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Win_Condition, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_DEFCON_Active, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_DEFCON_Active, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Medals, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Medals, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Hero_Respawn, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Hero_Respawn, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Starting_Credits, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Starting_Credits, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Unit_Population_Limit, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Unit_Population_Limit, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Private_Game, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Private_Game, Play_Mouse_Over_Option_SFX)
	if TestValid(this.Panel_Game_Filters.Combo_Show_In_Progress) then
		this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Show_In_Progress, Play_Option_Select_SFX)
		this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Show_In_Progress, Play_Mouse_Over_Option_SFX)
	end
end


-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Constants_Init()

	CMCommon_Constants_Init()
	CLUSTER_FOCUS_NUM = 2
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Variables_Init()

	CMCommon_Variables_Init()
	MatchingState = MATCHING_STATE_PLAYER_MATCH
	StagingEditState = false
	
end

-------------------------------------------------------------------------------
-- This function may be called multiple times in order to reset all variables.
-------------------------------------------------------------------------------
function Variables_Reset()

	CMCommon_Variables_Reset()
	MatchingState = MATCHING_STATE_PLAYER_MATCH
	StagingEditState = false
	
end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
--
-- NOTE:::  By default, yes/no, on/off, enabled/disabled combos are populated
-- first with the off option.
-------------------------------------------------------------------------------
function Initialize_Components()
	CMCommon_Initialize_Components()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_Filters()

	--JSY: removed sfx event handler registration from this function sicne it's called multiple times

	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters

	-- --------------------------
	-- GAME FILTERS PANEL
	-- --------------------------
	local handle = nil
	
	ViewFilterComponents = {}
	local settings_edit_view_model = {}		-- This model will drive the staging area session settings panel.
	
	-- Initialize the Map combo
	handle = panel.Combo_Map
	handle.Clear()
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end

	local new_row = -1
	local player_count = Network_Get_Client_Table_Count(true)
	settings_edit_view_model.MPMapModel = MPMapModel
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
	table.insert(ViewFilterComponents, handle)
	
	--Initialize the victory condition combo
	handle = panel.Combo_Win_Condition
	handle.Clear()
	settings_edit_view_model.VictoryConditionModel = VictoryConditionNames
	settings_edit_view_model.VictoryConditionValue = GameScriptData.victory_condition
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	for _, condition in pairs(VictoryConditionNames) do
		handle.Add_Item(condition)
	end
	table.insert(ViewFilterComponents, handle)

	-- Initialize the DEFCON combo
	handle = panel.Combo_DEFCON_Active
	handle.Clear()
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	table.insert(ViewFilterComponents, handle)
	
	-- Initialize the alliances combo
	-- [JLH 2/12/2008]: Alliances are cancelled for 360.
	--[[handle = panel.Combo_Alliances
	handle.Clear()
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	table.insert(ViewFilterComponents, handle)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Filters.Combo_Alliances, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Filters.Combo_Alliances, Play_Mouse_Over_Option_SFX)--]]
	
	-- Initialize the medals combo
	handle = panel.Combo_Medals
	handle.Clear()
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	table.insert(ViewFilterComponents, handle)

	-- Initialize the hero respawn combo
	handle = panel.Combo_Hero_Respawn
	handle.Clear()
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	table.insert(ViewFilterComponents, handle)

	-- Initialize the starting credits combo
	handle = panel.Combo_Starting_Credits
	handle.Clear()
	settings_edit_view_model.StartingCreditsModel = STARTING_CASH_VALUES
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	for _, value in ipairs(STARTING_CASH_VALUES) do
		handle.Add_Item(value.display)
	end
	--[[handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_SMALL])
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_MEDIUM])
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_LARGE])]]--
	table.insert(ViewFilterComponents, handle)
	
	-- Initialize the population cap combo
	handle = panel.Combo_Unit_Population_Limit
	handle.Clear()
	settings_edit_view_model.PopCapModel = POP_CAP_VALUES
	if ViewState == VIEW_STATE_GAME_FILTERS_JOIN then
		handle.Add_Item(TEXT_FILTER_ALL)
	end
	for _, value in ipairs(POP_CAP_VALUES) do
		handle.Add_Item(value.display)
	end
	table.insert(ViewFilterComponents, handle)

	if ViewState == VIEW_STATE_GAME_OPTIONS_HOST then
	
		-- Initialize the private game combo
		handle = panel.Combo_Private_Game
		handle.Clear()
		handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
		handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
		table.insert(ViewFilterComponents, handle)
		
	end

	-- Initialize the Show Games in Progress Combo
	handle = panel.Combo_Show_In_Progress
	if (TestValid(handle)) then
	
		handle.Clear()
		if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
			handle.Add_Item(TEXT_FILTER_ALL)
		end
		handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
		handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
		table.insert(ViewFilterComponents, handle)
		
	end
	
	CMCommon_Capture_Filter_Settings()
	
	SettingsEditViewModel = settings_edit_view_model
	this.Panel_Game_Staging.Staging_Settings_Panel.Set_Player_Count(player_count)
	this.Panel_Game_Staging.Staging_Settings_Panel.Set_Edit_Model(SettingsEditViewModel)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Host_Defaults()
	CMCommon_Set_Host_Defaults()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Join_Filter_Defaults()
	CMCommon_Set_Join_Filter_Defaults()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_Traversal()

	-- TAB ORDER --
	-- Custom Lobby Panel
	panel = Live_Profile_Game_Dialog.Panel_Custom_Lobby
	panel.List_Available_Games.Set_Tab_Order(Declare_Enum())
		
	-- Filters Panel
	panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	panel.Combo_Map.Set_Tab_Order(Declare_Enum())
	panel.Combo_Win_Condition.Set_Tab_Order(Declare_Enum())
	panel.Combo_DEFCON_Active.Set_Tab_Order(Declare_Enum())
	-- [JLH 2/12/2008]: Alliances are cancelled for 360.
	--panel.Combo_Alliances.Set_Tab_Order(Declare_Enum())
	panel.Combo_Medals.Set_Tab_Order(Declare_Enum())
	panel.Combo_Hero_Respawn.Set_Tab_Order(Declare_Enum())
	panel.Combo_Starting_Credits.Set_Tab_Order(Declare_Enum())
	panel.Combo_Unit_Population_Limit.Set_Tab_Order(Declare_Enum())
	panel.Combo_Private_Game.Set_Tab_Order(Declare_Enum())
	panel.Combo_Show_In_Progress.Set_Tab_Order(Declare_Enum())
	
	-- Base Panel
	panel = Live_Profile_Game_Dialog

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
	CMCommon_Update_Selected_Player_View()
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- V I E W   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()
	CMCommon_On_Update()
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
	Hide_Navigation_Buttons(false)
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

	if (ViewState == VIEW_STATE_GAME_STAGING) then		-- If we're in staging confirm the exit.
		Leave_Staging_Area()
	else
		Persist_UI_To_Profile()
		CMCommon_On_Back_Clicked()
	end
	
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
	
	if (ViewState == VIEW_STATE_GAME_OPTIONS_HOST) then
		this.Panel_Game_Staging.Player_Cluster_1.Set_Focus_First()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()

	Hide_Navigation_Buttons(false)
	CMCommon_On_YesNoOk_Yes_Clicked()
	
	-- Show the settings edit nav again.
	if (JoinedGame and SessionLeavePending) then
		Hide_Settings_Panel_Navigation(false)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_No_Clicked()

	Hide_Navigation_Buttons(false)
	CMCommon_On_YesNoOk_No_Clicked()
	
	-- Show the settings edit nav again.
	if (JoinedGame and SessionLeavePending) then
		Hide_Settings_Panel_Navigation(false)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_Ok_Clicked()

	Hide_Navigation_Buttons(false)
	CMCommon_On_YesNoOk_Ok_Clicked()
	
	-- Show the settings edit nav again.
	if (JoinedGame and SessionLeavePending) then
		Hide_Settings_Panel_Navigation(false)
	end
		
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
-- When the staging area settings edit combo changes, we need to update 
-- the map preview and overlay here.
-------------------------------------------------------------------------------
function On_Staging_Settings_Combo_Map_Changed(event, source, data)

	-- Early-out if we are not in the staging state.
	if (not (ViewState == VIEW_STATE_GAME_STAGING)) then
		return
	end

	local index = data
	index = index + 1		-- 1-based model, 0-based combo box.
	local map_dao = PGLobby_Get_Map_By_Index(index)
		
	-- If the dao is nil, show the spinning globe.  Otherwise show the map and overlay
	if ((map_dao == nil) or map_dao.incomplete) then
	
		PGMO_Set_Enabled(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Play()
		PGMO_Hide()
		
	else
		
		Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		PGMO_Show()
		
		CMCommon_Setup_Map_Preview(map_dao, Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview, true)
		
		local map_label = Get_Game_Text("TEXT_INTERNET_MAP_NAME").append(" ").append(map_dao.display_name)
		Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Text(map_label)
			
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
	-- [JLH 2/20/2008]:
	-- Now that adding and removing players can result in a pop cap change (down to 60
	-- in a 4-player game), we will need to refresh some views and models.
	Refresh_Game_Settings_Model(true)
 	Refresh_Game_Settings_View()	
	Broadcast_Game_Settings() 
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_AI_Player_Removed(event, source, common_addr)

	CMCommon_On_AI_Player_Removed(event, source, common_addr)
	-- [JLH 2/20/2008]:
	-- Now that adding and removing players can result in a pop cap change (down to 60
	-- in a 4-player game), we will need to refresh some views and models.
	Refresh_Game_Settings_Model(true)
 	Refresh_Game_Settings_View()
	Broadcast_Game_Settings() 
	
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
	CMCommon_Set_Staging_View(value)
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

	-- Get the target client for editing (if available).
	local target_client = Get_Focused_Client_For_Edit()
	if (target_client == nil) then
		return
	end

	CMCommon_PGMO_On_Start_Marker_Clicked(source, target_client)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_View_State(state)

	CMCommon_Set_View_State(state)

	-- If we're going to the staging state, we need to setup the map overlay.
	if (state == VIEW_STATE_GAME_STAGING) then
	
		-- Make sure the staging area host settings panel is populated properly.
		if (JoinState == JOIN_STATE_HOST) then
			Populate_UI_From_Profile()
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- This function is the central locus of presentation for the entire lobby.
-- All code related to showing/hiding UI elements, population and configuration
-- of UI elements, or any view-layer functionality related to a view state 
-- change should be implemented here.
-------------------------------------------------------------------------------
function Refresh_UI()

	if ( ( HostingGame or Recieved_Game_Settings ) and NeedClusterFocus and NeedClusterFocus > 0 ) then

		local seat = Network_Get_Seat(LocalClient)
		local handle = ViewPlayerInfoClusters[seat]
		if TestValid(handle) then
			handle.Set_Focus_First()
			NeedClusterFocus = NeedClusterFocus - 1
		else
			--somethin' wrong here
		end
	end
	
	CMCommon_Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Options()
	CMCommon_Refresh_Options()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Quickmatch()

	CMCommon_Refresh_Quickmatch()
	Live_Profile_Game_Dialog.Button_Back.Set_Text("TEXT_BUTTON_BACK_LOWER")
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Custom_Lobby()

	CMCommon_Refresh_Custom_Lobby()
	Live_Profile_Game_Dialog.Button_Back.Set_Text("TEXT_BUTTON_BACK_LOWER")
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Staging()

	CMCommon_Refresh_Staging()
	
	-- Deal with internet-only buttons
	if (not NavigationButtonsHidden) then
	
		if (NetworkState == NETWORK_STATE_INTERNET) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Gamer_Card.Set_Hidden(false)
		elseif (NetworkState == NETWORK_STATE_LAN) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Gamer_Card.Set_Hidden(true)
		end
		
	end
	
	-- General buttons
--	Live_Profile_Game_Dialog.Button_Back.Set_Hidden(false)
	
	if (ValidMapSelection) then
		if (StagingEditState) then
			PGMO_Set_Interactive(false)
		else
			PGMO_Set_Interactive(true)
		end
	end
		
	-- Deal with host-only buttons.
	if (not NavigationButtonsHidden) then
	
		if (JoinState == JOIN_STATE_HOST) then
			-- The host sees a "Launch Game" button...
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Set_Text("TEXT_MULTIPLAYER_BUTTON_LAUNCH_GAME")
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Edit_Settings.Set_Hidden(false)
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_A.Set_Hidden(false)
		elseif (JoinState == JOIN_STATE_GUEST) then
			-- Guests see a "Ready" button...
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Set_Text("TEXT_MULTIPLAYER_BUTTON_READY")
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Edit_Settings.Set_Hidden(true)
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_A.Set_Hidden(true)
		end
		
	end

	Refresh_Start_Conditions_View()

	-- Countdown in progress?
	if (JoinState == JOIN_STATE_GUEST) then
	
		Live_Profile_Game_Dialog.Button_Back.Set_Text("TEXT_BUTTON_BACK_LOWER")
		
	elseif (JoinState == JOIN_STATE_HOST) then
	
		if (StartGameCountdown >= 0) then
			Live_Profile_Game_Dialog.Button_Back.Set_Text("TEXT_BUTTON_CANCEL")
		else
			Live_Profile_Game_Dialog.Button_Back.Set_Text("TEXT_BUTTON_BACK_LOWER")
		end

	end
	
	-- We don't want to mess with the game settings view if the host is currently editing them.
	if (not StagingEditState) then
		Refresh_Game_Settings_View()
	end
			
	-- ------------------------------------------------------------------------
	-- Handle visibility of the tier 2 panels
	-- ------------------------------------------------------------------------
	if (JoinState == JOIN_STATE_GUEST) then
		Live_Profile_Game_Dialog.Panel_Game_Staging.Staging_Settings_Panel.Set_Unmutable_State()
	elseif (JoinState == JOIN_STATE_HOST) then
		Live_Profile_Game_Dialog.Panel_Game_Staging.Staging_Settings_Panel.Set_Mutable_State()
	end
	
end

-------------------------------------------------------------------------------
-- Any UI elements which may be holding data that shouldn't persist when 
-- the lobby is backed out of should be cleared here.
-------------------------------------------------------------------------------
function Clear_UI()
	CMCommon_Clear_UI()
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
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Lobby_Session_Settings(session)
	CMCommon_Set_Lobby_Session_Settings(session)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Game_Is_Starting(game_is_starting)

	CMCommon_Set_Game_Is_Starting(game_is_starting)
		
	for _, map in ipairs(ViewPlayerInfoClusters) do 
		map.Handle.Set_Lockdown(GameIsStarting)
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Game_Settings_View()

	-- Can't refresh the view until we know the data!
	if JoinState == JOIN_STATE_GUEST and not Recieved_Game_Settings then return end
	
	-- This model will drive the unmutable panel of the staging area session settings panel.
	-- Start with the existing value model which will be in terms of indices if we're in a mutable state
	local value_model = Live_Profile_Game_Dialog.Panel_Game_Staging.Staging_Settings_Panel.Get_Value_Model()		
	if not value_model then
		value_model = {}
	end

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
	value_model.StartingCreditsValue = starting_cash
	
	-- DEFCON
	local defcon = TEXT_NO
	if (GameScriptData.is_defcon_game) then
		defcon = TEXT_YES
	end
	value_model.DEFCONValue = defcon
	
	-- Win Condition
	local win_condition = VictoryConditionNames[GameScriptData.victory_condition]
	value_model.WinConditionValue = win_condition
	
	-- Medals
	local medals = TEXT_NO
	if ((NetworkState == NETWORK_STATE_INTERNET) and (GameScriptData.medals_enabled)) then
		medals = TEXT_YES
	end
	value_model.MedalsValue = medals
	
	-- Alliances
	-- [JLH 2/12/2008]: Alliances are cancelled for 360.
	--[[local alliances = TEXT_NO
	if GameOptions.alliances_enabled then
		alliances = TEXT_YES
	end
	value_model.AlliancesValue = alliances--]]
	
	-- Hero Respawn
	local hero_respawn = TEXT_NO
	if GameOptions.hero_respawn then
		hero_respawn = TEXT_YES
	end
	value_model.HeroRespawnValue = hero_respawn

	-- Pop Cap
	local pop_cap = tostring(GameOptions.pop_cap_override)
	value_model.PopCapValue = pop_cap
	if Network_Get_Client_Table_Count(true) >= 4 then
		value_model.PopCapMax = 60
	else
		value_model.PopCapMax = nil
	end
	
	-- AI Slots
	local ai_slots = tostring(Network_Get_AI_Player_Count())
	
	-- Prepare the complete labels
	if (GameOptions.map_display_name == nil) then
		GameOptions.map_display_name = "INVALID"
	end
	local map_label = Get_Game_Text("TEXT_INTERNET_MAP_NAME").append(" ").append(GameOptions.map_display_name)
	local starting_cash_label = starting_cash
	local defcon_label = defcon
	local win_condition_label = win_condition
	local medals_label = medals
	local alliances_label = alliances
	local hero_respawn_label = hero_respawn
	local pop_cap_label = pop_cap
	

	-- Display!
	Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Text(map_label)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Texture(tostring(map_preview))
	Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Render_Mode(0)
	
	this.Panel_Game_Staging.Staging_Settings_Panel.Set_Value_Model(value_model)
		
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Persist_Host_UI_To_Profile()
	CMCommon_Persist_Host_UI_To_Profile()
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Persist_Filters_To_Profile()
	CMCommon_Persist_Filters_To_Profile()
end

------------------------------------------------------------------------------
-- Persist pertinent UI elements to the profile.
------------------------------------------------------------------------------
function Persist_UI_To_Profile()

	-- Player identity options
	if (ViewState == VIEW_STATE_GAME_STAGING) then
  		local faction = CMCommon_Validate_Client_Faction(LocalClient.faction)

		Set_Profile_Value(PP_LOBBY_PLAYER_FACTION, faction)
		Set_Profile_Value(PP_LOBBY_PLAYER_TEAM, LocalClient.team)
		Set_Profile_Value(PP_COLOR_INDEX, LocalClient.color)
		Commit_Profile_Values()
	end
	
	-- Game hosting options
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) or
		StagingEditState) then
		Persist_Host_UI_To_Profile()
		Commit_Profile_Values()
	end
		
	-- Game filters
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
		Persist_Filters_To_Profile()
		Commit_Profile_Values()
	end

end

------------------------------------------------------------------------------
-- Persist pertinent UI elements to the profile.
------------------------------------------------------------------------------
function Populate_UI_From_Profile()

	local index = -1
	
	-- This model will drive the mutable panel of the staging area session settings panel.
	local settings_value_model = this.Panel_Game_Staging.Staging_Settings_Panel.Get_Value_Model()

  	LocalClient.faction = Get_Profile_Value(PP_LOBBY_PLAYER_FACTION, LOBBY_DEFAULT_FACTION)
	LocalClient.team = Get_Profile_Value(PP_LOBBY_PLAYER_TEAM, LOBBY_DEFAULT_TEAM)
	LocalClient.color = PGLobby_Get_Preferred_Color()

	LocalClient.faction = CMCommon_Validate_Client_Faction(LocalClient.faction)
		
	-- Now that the local client's preferences have been loaded, make sure we
	-- update everything else to do with the LocalClient.
	CMCommon_Update_Local_Client()
		
	--Prevent audio from playing any time we're editing settings from script
	SuppressSFX = true		
		
	-- Game hosting options
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) or
		(ViewState == VIEW_STATE_GAME_STAGING and JoinState == JOIN_STATE_HOST)) then
		
		local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
		
		index = Get_Profile_Value(PP_LOBBY_HOST_MAP, 0)
		if ((index >= 0) and (index < #MPMapModel)) then
			panel.Combo_Map.Set_Selected_Index(index)
			settings_value_model.MPMapModelIndex = index
		else
			panel.Combo_Map.Set_Selected_Index(0)
			settings_value_model.MPMapModelIndex = 0
		end
		
		index = Get_Profile_Value(PP_LOBBY_HOST_WIN_CONDITION, HostGameDefaults.VictoryCondition)
		panel.Combo_Win_Condition.Set_Selected_Index(index)
		settings_value_model.WinConditionIndex = index

		index = Get_Profile_Value(PP_LOBBY_HOST_DEFCON, HostGameDefaults.DEFCON)
		panel.Combo_DEFCON_Active.Set_Selected_Index(index)
		settings_value_model.DEFCONIndex = index

		-- [JLH 2/12/2008]: Alliances are cancelled for 360.
		--[[index = Get_Profile_Value(PP_LOBBY_HOST_ALLIANCES, HostGameDefaults.Alliances)
		panel.Combo_Alliances.Set_Selected_Index(index)
		settings_value_model.AlliancesIndex = index--]]

		index = Get_Profile_Value(PP_LOBBY_HOST_ACHIEVEMENTS, HostGameDefaults.Medals)
		panel.Combo_Medals.Set_Selected_Index(index)
		settings_value_model.MedalsIndex = index

		index = Get_Profile_Value(PP_LOBBY_HOST_HERO_RESPAWN, HostGameDefaults.HeroRespawn)
		panel.Combo_Hero_Respawn.Set_Selected_Index(index)
		settings_value_model.HeroRespawnIndex = index

		index = Get_Profile_Value(PP_LOBBY_HOST_STARTING_CREDITS, HostGameDefaults.StartingCredits)
		panel.Combo_Starting_Credits.Set_Selected_Index(index)
		settings_value_model.StartingCreditsIndex = index

		index = Get_Profile_Value(PP_LOBBY_HOST_POP_CAP, HostGameDefaults.PopCap)
		panel.Combo_Unit_Population_Limit.Set_Selected_Index(index)
		settings_value_model.PopCapIndex = index

		index = Get_Profile_Value(PP_LOBBY_HOST_PRIVATE_GAME, HostGameDefaults.Private)
		panel.Combo_Private_Game.Set_Selected_Index(index)

		Refresh_Game_Settings_Model()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Staging_Settings_Panel.Set_Mutable_State()
		this.Panel_Game_Staging.Staging_Settings_Panel.Set_Value_Model(settings_value_model)
		
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

		-- [JLH 2/12/2008]: Alliances are cancelled for 360.
		--[[index = Get_Profile_Value(PP_LOBBY_FILTER_ALLIANCES, JoinFilterDefaults.Alliances)
		panel.Combo_Alliances.Set_Selected_Index(index)--]]

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

	end
	
	SuppressSFX = false
	
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Report_System_Event(text, color)
	-- JOE TODO:  Report system events on the 360 (probably not required).
	--Append_To_Chat_Window(text, color)
end

---------------------------------------
--
---------------------------------------
function Set_Currently_Selected_Client(client)

	CMCommon_Set_Currently_Selected_Client(client)

	if (HostingGame) then
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_X.Set_Hidden(false)
	else
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_X.Set_Hidden(true)
	end
	
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
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Enable(true)
		else
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Enable(false)
		end
		
	else
	
		-- If we're the guest our ready button only lights up if all the conditions for a valid game launch are met.
		if (only_awaiting_acceptance and LocalClient.AcceptsGameSettings == false) then
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

	local game_has_started = GameHasStarted

	CMCommon_On_Menu_System_Activated()

	if game_has_started then
		-- Restart modality so this scene captures input
		this.Start_Modal()
		this.Focus_First()
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Join_Attempt_Cancelled()
	On_Left_Trigger_Up()
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
	
		-- Raised when we join a game.
		-- During invites it's possible that the navigation will be hidden because of the
		-- auto-dismissal of certain dialog boxes.
		Hide_Navigation_Buttons(false)
		Hide_Settings_Panel_Navigation(false)
		
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
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(0)
	-- We have to pretend that the selection has changed in case the session 
	-- at the top changes.
	On_Available_Games_Selection_Changed()
	if (ShowNATInfo) then
		ShowNATInfo = false
		if (PGLobby_Display_NAT_Information(Live_Profile_Game_Dialog.Text_NAT_Type)) then
			-- If we ended up displaying the warning that the user is on a strict NAT, 
			-- hide navigation for the duration of the dialog display.
			Hide_Navigation_Buttons(true)
		end
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_On_Find_LAN_Session(event)
	CMCommon_Network_On_Find_LAN_Session(event)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(0)
	-- We have to pretend that the selection has changed in case the session 
	-- at the top changes.
	On_Available_Games_Selection_Changed()
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

	local client = Network_Get_Client(event.common_addr)
	local seat = Network_Get_Seat(client)
	local cluster_handle = ViewPlayerInfoClusters[seat].Handle
	cluster_handle.On_Gamer_Picture_Retrieved(event)

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
	
	for key, map in ipairs(ViewPlayerInfoClusters) do 
		map.Handle.Set_Model()
		map.Handle.Set_Editing_Enabled(true)
		map.Handle.Set_Is_Host(false)
		map.Handle.Set_Is_Local_Client(false)
		map.Handle.Set_Cluster_State(CLUSTER_STATE_CLOSED)
		map.Handle.Set_Cluster_State(CLUSTER_STATE_OPEN)
	end
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Initialize_Game_Hosting()
	CMCommon_Initialize_Game_Hosting()
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

	CMCommon_Refresh_Game_Settings_Model(full_reset)
	
	-- [JLH 2/12/2008]: Alliances are cancelled for 360.
	GameOptions.alliances_enabled = false
	
	--Must limit pop cap in 4 player games for 360
	if Network_Get_Client_Table_Count(true) >= 4 and GameOptions.pop_cap_override > 60 then
 		GameOptions.pop_cap_override = 60
 		GameAdvertiseData[PROPERTY_POP_CAP] = GameOptions.pop_cap_override
 	end		
	
	Refresh_Game_Settings_View()
end

-------------------------------------------------------------------------------
-- A client calls this to collect all the game filters from the setup screen
-- into the data structure that will be used to search for available games
-------------------------------------------------------------------------------
function Refresh_Game_Filtering()
	CMCommon_Refresh_Game_Filtering()
end
	    
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_New_Game_Script_Data(game_script_data)
	
	-- If the map has changed, clear out start positions.
	if (GameOptions.map_name ~= game_script_data.GameOptions) then
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
		Network_Broadcast(MESSAGE_TYPE_CLIENT_HAS_MAP, false)
		
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
			local status, errors = PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions, true)
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

	-- If we're in staging edit state, do NOT clobber the map.
	if (StagingEditState) then
		return
	end

	CMCommon_Refresh_Staging_Map_Overlay()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Enter_Settings_Edit_State()

	if (not HostingGame) then
		return
	end

	Hide_Navigation_Buttons(true)
	
	StagingEditState = true
	local player_count = Network_Get_Client_Table_Count(true)
	this.Panel_Game_Staging.Staging_Settings_Panel.Set_Player_Count(player_count)
	this.Panel_Game_Staging.Staging_Settings_Panel.Start_Modal()
	this.Panel_Game_Staging.Staging_Settings_Panel.Set_Interactive(true)
		
	PGMO_Set_Interactive(false)
	PGMO_Set_Use_Labels(false)
	this.Panel_Game_Staging.Button_Edit_Settings.Set_Text(Get_Game_Text("TEXT_MULTIPLAYER_BUTTON_ACCEPT"))
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Exit_Staging_Settings(event, source, data)

	if (not HostingGame) then
		return
	end

	-- Shut down the edit panel.
	local value_model = this.Panel_Game_Staging.Staging_Settings_Panel.Get_Value_Model()
	this.Panel_Game_Staging.Staging_Settings_Panel.Set_Interactive(false)
	this.Panel_Game_Staging.Player_Cluster_1.Set_Focus_First()
	

	-- Update the local model.
	-- HACK ALERT::: Unfortunately the "model" which stores the authoritative view of the current game settings
	-- is the set of combo boxes in the Panel_Game_Filters.  TERRIBLE and I want to refactor that if I get the time!!!
	
	--Prevent audio from playing any time we're editing settings from script
	SuppressSFX = true
	
	-- Map
	local index = value_model.MPMapModelIndex
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Map.Set_Selected_Index(index) 
	local map_dao = PGLobby_Get_Map_By_Index(index + 1)	-- 1-based model, 0-based combo box.
	
	-- Win Condition
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Win_Condition.Set_Selected_Index(value_model.WinConditionIndex)
	
	-- DEFCON
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_DEFCON_Active.Set_Selected_Index(value_model.DEFCONIndex)
	
	-- Alliances
	-- [JLH 2/12/2008]: Alliances are cancelled for 360.
	--Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Alliances.Set_Selected_Index(value_model.AlliancesIndex)
	
	-- Hero Respawn
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Hero_Respawn.Set_Selected_Index(value_model.HeroRespawnIndex)
	
	-- Starting Credits
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Starting_Credits.Set_Selected_Index(value_model.StartingCreditsIndex)
	
	-- Population Cap
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Unit_Population_Limit.Set_Selected_Index(value_model.PopCapIndex)
	
	-- Medals
	Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Medals.Set_Selected_Index(value_model.MedalsIndex)
	
	SuppressSFX = false
	
	Persist_UI_To_Profile()
	Refresh_Game_Settings_Model(false)
	Refresh_Game_Settings_View()
	CMCommon_Update_Player_List()
	

	-- Restore the map overlay.
	PGMO_Set_Interactive(true)
	CMCommon_Setup_Map_Preview(map_dao, Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview, true)
	this.Panel_Game_Staging.Button_Edit_Settings.Set_Text(Get_Game_Text("TEXT_MULTIPLAYER_EDIT_SETTINGS"))
	Refresh_Staging_Map_Overlay()
	
	Broadcast_Game_Settings() 
		
	Hide_Navigation_Buttons(false)
	
	StagingEditState = false
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Leave_Staging_Area()
		
	-- Remove the highlight on the first cluster so we don't accidentally
	-- change the faction when the cluster gets focus after the dialog is dismissed.
	this.Panel_Game_Staging.Player_Cluster_1.Clear_Highlight() 
	CMCommon_Confirm_User_Exit_Staging()
	Hide_Navigation_Buttons(true)
	Hide_Settings_Panel_Navigation(true)
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Quickmatching_State()
	-- Quickmatching in the lobby is only done on the PC side.	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function End_Quickmatching_State()
	-- Quickmatching in the lobby is only done on the PC side.	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Is_Accepting_Invitation()
	InvitationAccepted = Net.Get_Time()
	CMCommon_Set_Join_State(JOIN_STATE_GUEST)
	PGLobby_Display_Custom_Modal_Message("TEXT_SEARCHING", "", "TEXT_BUTTON_CANCEL", "")
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Finished_Invitation()
	CMCommon_Set_Finished_Invitation()
end

-------------------------------------------------------------------------------
-- JAB
-------------------------------------------------------------------------------
function Initialize_Gamepad_Interaction()

--	this.Register_Event_Handler("Controller_Right_Bumper_Up", nil, On_List_Play_Tab_Clicked)
--	this.Register_Event_Handler("Controller_Left_Bumper_Up", nil, On_Player_Match_Tab_Clicked)
	
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_B_Button_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Back_Clicked)
	
	this.Register_Event_Handler("Cluster_A_Button_up", nil, On_A_Button_Clicked)
	this.Register_Event_Handler("Controller_A_Button_up", nil, On_A_Button_Clicked)
	this.Register_Event_Handler("Controller_X_Button_up", nil, On_X_Button_Clicked)
	this.Register_Event_Handler("Controller_Y_Button_up", nil, On_Y_Button_Clicked)
--	this.Register_Event_Handler("Controller_Left_Bumper_Up", nil, On_Left_Bumper_Up)
--	this.Register_Event_Handler("Controller_Right_Bumper_Up", nil, On_Right_Bumper_Up)
	this.Register_Event_Handler("Controller_Left_Trigger_Release", nil, On_Left_Trigger_Up)
	this.Register_Event_Handler("Controller_Right_Trigger_Release", nil, On_Right_Bumper_Up)
	
	this.Register_Event_Handler("Controller_Start_Button_up", nil, On_Start_Button_Clicked)

	-- Maria 10.17.2007
	-- This function has been removed from the PC Version so I'm removing this handler!.
	-- NOTE: in the PC version the handler gets registered from the GUIEditor but there's no handler in the script.
	--this.Register_Event_Handler("Button_Clicked", this.Panel_Main.Button_Profile_Quickmatch, On_Profile_Quickmatch_Clicked)
	
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Filters.Button_Accept, On_Button_Filters_Accept_Clicked)

	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Refresh, On_Lobby_Refresh_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Host_Game, On_Host_Game_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Join_Game, On_Join_Game_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Quickmatch, On_Button_Quickmatch_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Gamer_Card, On_Button_Gamer_Card_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Filters, On_Lobby_Filters_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Custom_Lobby.Button_Medal_Chest, On_Button_Medal_Chest_Clicked)
	
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Staging.Button_Cancel_Countdown, On_Cancel_Countdown_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Staging.Button_Kick_Player, On_Kick_Player_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Staging.Button_Edit_Settings, On_Edit_Settings_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Staging.Button_Ready_Launch, On_Start_Button_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Staging.Button_Gamer_Card, On_Button_Gamer_Card_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Game_Staging.Button_Exit, On_Staging_Exit_Clicked)
	
end

-------------------------------------------------------------------------------
-- JAB
-------------------------------------------------------------------------------
function On_A_Button_Clicked()

	if ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		
		-- viewing Panel_Game_Filters
		On_Button_Filters_Accept_Clicked()
		
	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
	
		-- viewing Panel_Custom_Lobby
		On_Join_Game_Clicked()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		-- viewing Panel_Game_Staging
		-- If we're the host, hitting A either allows us to edit current game settings or commits them.
		if (JoinState == JOIN_STATE_HOST) then
		
			if (not StagingEditState) then
				Enter_Settings_Edit_State()
			end

		end
		
	else
	
	end
	
end

-------------------------------------------------------------------------------
-- JLH
-------------------------------------------------------------------------------
function On_B_Button_Clicked()

	if (ViewState == VIEW_STATE_GAME_STAGING) then		-- If we're in staging confirm the exit.
		if (GameIsStarting and HostingGame) then
			CMCommon_On_Cancel_Countdown_Clicked()
		elseif (not StagingEditState) then
			Leave_Staging_Area()
		end
	else
		On_Back_Clicked()
	end
	
end

-------------------------------------------------------------------------------
-- JAB
-------------------------------------------------------------------------------
function On_X_Button_Clicked()

	if ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		
		-- viewing Panel_Game_Filters
		On_Set_Default_Clicked()
		
	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
	
		-- viewing Panel_Custom_Lobby
		On_Host_Game_Clicked()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		if (not StagingEditState) then
			-- viewing Panel_Game_Staging
			On_Kick_Player_Clicked()
		end
		
	else
	
	end
	
end

-------------------------------------------------------------------------------
-- JAB
-------------------------------------------------------------------------------
function On_Y_Button_Clicked()
	if ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		-- viewing Panel_Game_Filters
		
	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		-- viewing Panel_Custom_Lobby
		On_Lobby_Filters_Clicked()
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
		if (not StagingEditState) then
			-- viewing Panel_Game_Staging
			On_Button_Gamer_Card_Clicked()
		end
	else
	
	end
end

-------------------------------------------------------------------------------
-- JAB
-------------------------------------------------------------------------------
function On_Left_Bumper_Up()
	if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		On_Button_Medal_Chest_Clicked()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Right_Bumper_Up()
	if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		On_Button_Medal_Chest_Clicked()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Left_Trigger_Up()
	if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		if ( this.Panel_Custom_Lobby.Button_Refresh.Is_Enabled() ) then
			CMCommon_Do_Manual_Refresh()
		end
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Right_Trigger_Up()
	if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		if ( this.Panel_Custom_Lobby.Button_Refresh.Is_Enabled() ) then
			CMCommon_Do_Manual_Refresh()
		end
	end
end

-------------------------------------------------------------------------------
-- JAB
-------------------------------------------------------------------------------
function On_Start_Button_Clicked()

	if (ViewState == VIEW_STATE_GAME_STAGING) then
	
		-- viewing Panel_Game_Staging
		if ( (not StagingEditState) and this.Panel_Game_Staging.Button_Ready_Launch.Is_Enabled() ) then
		
			Commit_Profile_Values()
		
			-- If we're the host, launch the game, otherwise indicate readiness.
			if (HostingGame) then
				On_Staging_Launch_Game_Clicked()
			else
				On_Ready_Clicked()
			end
			
		end
		
	else
	
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Difficulty_Set(event, source, new_level)

	local client = CurrentlySelectedClient

	client.ai_difficulty = new_level
	if (client.ai_difficulty < Difficulty_Easy) then
		client.ai_difficulty = Difficulty_Hard
	end
	if (client.ai_difficulty > Difficulty_Hard) then
		client.ai_difficulty = Difficulty_Easy
	end

	client.name = Network_Get_AI_Name(client.ai_difficulty)
	
	Update_Selected_Player_View()
	CMCommon_Update_Player_List()
	Refresh_Start_Conditions_View()
	CMCommon_Refresh_UI()

	-- Broadcast the difficulty change.
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	end
	
end		

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Spawn_Location_Up(event, source, seat)

	Advance_Next_Spawn_Position(seat, false)		-- False means advance incrementally.
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Spawn_Location_Down(event, source, seat)

	Advance_Next_Spawn_Position(seat, true)		-- True means advance decrementally.

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Advance_Next_Spawn_Position(seat, reverse)

	-- You must be allowed to edit the selected client
	if Client_Editing_Enabled == false then
		return
	end

	-- Make sure there's a client selected.
	local target_client = CurrentlySelectedClient
	if (target_client == nil) then
		DebugMessage("LUA_LOBBY: ERROR: Unable to process start marker selection because the currently selected client is invalid.")
		return
	end
	
	if (reverse == nil) then
		reverse = false
	end
	
	-- Use the currently selected start marker (if any) to figure out what the new one should be.
	local cur_start_marker_id = PGMO_Get_Start_Marker_ID_From_Seat(seat)	-- this returns 1-8 (index number)
	local new_start_marker_id = -1
		
	if ( PGMO_Is_Seat_Assigned(seat) ) then
	
		-- seat is given a spawn, move to next
		if (reverse) then
			new_start_marker_id = PGMO_Get_Reverse_First_Empty_Start_Position(seat, cur_start_marker_id - 1)
		else
			new_start_marker_id = PGMO_Get_First_Empty_Start_Position(seat, cur_start_marker_id + 1)
		end
		
	else
	
		-- seat is free
		if (reverse) then
			new_start_marker_id = PGMO_Get_Reverse_First_Empty_Start_Position(seat)
		else
			new_start_marker_id = PGMO_Get_First_Empty_Start_Position(seat)
		end
		
	end
		
	-- If there's a new marker available, attempt to claim it, otherwise clear the current one.
	if ( new_start_marker_id ~= nil and new_start_marker_id ~= -1 ) then
	
		-- new seat was found
		Network_Request_Start_Position(target_client, new_start_marker_id)
		-- If we're the host and the target was an AI, the request will be processed and assigned.
		PGMO_Assign_Start_Position(new_start_marker_id, seat, target_client.color)
		
	else
	
		-- new seat not found above, clear for random start
		Network_Request_Clear_Start_Position(cur_start_marker_id)
		
	end

end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Cluster_Claiming_Focus(event, scene, seat_num)
	for _, map in pairs(ViewPlayerInfoClusters) do
		map.Handle.Focus_Claimed_By(seat_num)
	end
end

function Hide_Navigation_Buttons(val)
	this.Frame_1.Set_Hidden(val)
	this.Button_Back.Set_Hidden(val)
	this.Button_B.Set_Hidden(val)
	this.Panel_Game_Filters.Button_X.Set_Hidden(val)
	this.Panel_Game_Filters.Button_Set_Default.Set_Hidden(val)
	this.Panel_Game_Filters.Button_A.Set_Hidden(val)
	this.Panel_Game_Filters.Button_Accept.Set_Hidden(val)
	this.Panel_Custom_Lobby.Button_X.Set_Hidden(val)
	this.Panel_Custom_Lobby.Button_Host_Game.Set_Hidden(val)
	this.Panel_Custom_Lobby.Button_Y.Set_Hidden(val)
	this.Panel_Custom_Lobby.Button_Filters.Set_Hidden(val)
	this.Panel_Custom_Lobby.Button_A.Set_Hidden(val)
	this.Panel_Custom_Lobby.Button_Join_Game.Set_Hidden(val)
	this.Panel_Game_Staging.Button_X.Set_Hidden(val)
	this.Panel_Game_Staging.Button_Kick_Player.Set_Hidden(val)
	this.Panel_Game_Staging.Button_Y.Set_Hidden(val)
	this.Panel_Game_Staging.Button_Gamer_Card.Set_Hidden(val)
	this.Panel_Game_Staging.Button_Start.Set_Hidden(val)
	this.Panel_Game_Staging.Button_Ready_Launch.Set_Hidden(val)
	NavigationButtonsHidden = val
end

function Hide_Settings_Panel_Navigation(val)

	if (not HostingGame) then
		return
	end

	this.Panel_Game_Staging.Button_Edit_Settings.Set_Hidden(val)
	this.Panel_Game_Staging.Button_A.Set_Hidden(val)
	
end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	CMCommon_Persist_Staging_UI_To_Profile = nil
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
	Is_Player_Of_Faction = nil
	Min = nil
	Network_Add_Reserved_Players = nil
	Network_Broadcast_Reset_Start_Positions = nil
	Network_Get_Client_By_ID = nil
	Network_Get_Client_From_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	On_Filters_Exit_Clicked = nil
	On_Left_Bumper_Up = nil
	On_Right_Trigger_Up = nil
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
	Set_Staging_View = nil
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

