if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Common_Live_Profile_Game_Dialog.lua#43 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Common_Live_Profile_Game_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 97577 $
--
--          $DateTime: 2008/04/25 15:51:26 $
--
--          $Revision: #43 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGNetwork")
require("PGColors")
require("PGCrontab")
require("PGPlayerProfile")
require("PGOnlineAchievementDefs")
require("PGOfflineAchievementDefs")
require("PGFactions")
require("Lobby_Network_Logic")
require("PGMapOverlayManager")


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function CMCommon_GUI_Init()

	
	-- Library init
	PGColors_Init()
	PGNetwork_Init()
	PGFactions_Init()
	PGPlayerProfile_Init()
	PGCrontab_Init()
	PGOnlineAchievementDefs_Init()
	PGLobby_Vars_Init()
	PGMO_Initialize()
	Register_Game_Scoring_Commands()

	-- Network Message Processors
	NetworkMessageProcessors = {}
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_SETTINGS]						= NMP_Player_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_ALL_GAME_SETTINGS]						= NMP_All_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_PLATFORM]						= NMP_Player_Platform
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_NAME]								= NMP_Player_Name
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_FACTION]							= NMP_Player_Faction
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_TEAM]								= NMP_Player_Team
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_COLOR]							= NMP_Player_Color
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_SEAT_ASSIGNMENT]				= NMP_Player_Seat_Assignment
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_REQUEST_START_POSITION]		= NMP_Player_Req_Start_Pos
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_ASSIGN_START_POSITION]		= NMP_Player_Assign_Start_Pos
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_CLEAR_START_POSITION]		= NMP_Player_Clear_Start_Pos
	NetworkMessageProcessors[MESSAGE_TYPE_HOST_CLEAR_START_POSITIONS]			= NMP_Host_Clear_Start_Pos
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS_ACCEPT]					= NMP_Player_Accepts
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS_DECLINE]				= NMP_Player_Declines
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_APPLIED_MEDALS]				= NMP_Player_Applied_Medals
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_NAT_TYPE]						= NMP_Player_NAT_Type
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_START_COUNTDOWN]					= NMP_Game_Start_Countdown
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_KILL_COUNTDOWN]					= NMP_Game_Kill_Countdown
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS]							= NMP_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SEED]								= NMP_Game_Seed
	NetworkMessageProcessors[MESSAGE_TYPE_START_GAME]								= NMP_Start_Game
	NetworkMessageProcessors[MESSAGE_TYPE_RESERVED_PLAYER]						= NMP_Reserved_Player
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS]			= NMP_AI_Player_Details
	NetworkMessageProcessors[MESSAGE_TYPE_CHAT]										= NMP_Chat_Message
	NetworkMessageProcessors[MESSAGE_TYPE_REFUSE_PLAYER]							= NMP_Refuse_Player
	NetworkMessageProcessors[MESSAGE_TYPE_KICK_PLAYER]								= NMP_Kick_Player
	NetworkMessageProcessors[MESSAGE_TYPE_KICK_AI_PLAYER]							= NMP_Kick_AI_Player
	NetworkMessageProcessors[MESSAGE_TYPE_KICK_RESERVED_PLAYER]					= NMP_Kick_Reserved_Player
	NetworkMessageProcessors[MESSAGE_TYPE_REBROADCAST_USER_SETTINGS]			= NMP_Rebroadcast_User_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_REBROADCAST_GAME_SETTINGS]			= NMP_Rebroadcast_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_STATS_REGISTRATION_BEGIN]			= NMP_Stats_Registration_Begin
	NetworkMessageProcessors[MESSAGE_TYPE_STATS_CLIENT_REGISTERED]				= NMP_Stats_Client_Registered
	NetworkMessageProcessors[MESSAGE_TYPE_HOST_RECOMMENDED_SETTINGS]			= NMP_Host_Recommended_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_HEARTBEAT]								= NMP_Heartbeat
	NetworkMessageProcessors[MESSAGE_TYPE_UPDATE_SESSION]							= NMP_Update_Session
	
	-- Constants
	Constants_Init()
	
	-- Variables
	Variables_Init()
	
	-- Event handlers
	Register_Event_Handlers()
	
	-- Components
	Initialize_Components()
	Initialize_Traversal()
	Set_Currently_Selected_Client(LocalClient)
	Update_Selected_Player_View()
	
	CMCommon_Initialize_View_State(StartingViewState)
	CMCommon_Initialize_Game_Filtering()

	this.Panel_Custom_Lobby.Globe_Movie.Stop()
	this.Panel_Game_Filters.Globe_Movie.Stop()
	this.Panel_Game_Staging.Globe_Movie.Stop()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER })
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Register_Event_Handlers()

	Live_Profile_Game_Dialog.Register_Event_Handler("Closing_All_Displays", nil, On_Closing_All_Displays)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_Player_Cluster_Clicked", nil, On_Player_Cluster_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_Menu_System_Activated", nil, On_Menu_System_Activated)
	Live_Profile_Game_Dialog.Register_Event_Handler("Key_Focus_Lost", nil, On_Focus_Lost)
	Live_Profile_Game_Dialog.Register_Event_Handler("Key_Focus_Gained", nil, On_Focus_Gained)

	Live_Profile_Game_Dialog.Register_Event_Handler("Ready_Clicked", nil, On_Ready_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Faction_Up_Clicked", nil, On_Player_Faction_Up_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Faction_Down_Clicked", nil, On_Player_Faction_Down_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Team_Up_Clicked", nil, On_Player_Team_Up_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Team_Down_Clicked", nil, On_Player_Team_Down_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Color_Up_Clicked", nil, On_Player_Color_Up_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Color_Down_Clicked", nil, On_Player_Color_Down_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Difficulty_Up_Clicked", nil, On_Player_Difficulty_Up_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Player_Difficulty_Down_Clicked", nil, On_Player_Difficulty_Down_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("Info_Cluster_State_Changed", nil, CMCommon_On_Info_Cluster_State_Changed)
	Live_Profile_Game_Dialog.Register_Event_Handler("AI_Player_Added", nil, On_AI_Player_Added)
	Live_Profile_Game_Dialog.Register_Event_Handler("AI_Player_Removed", nil, On_AI_Player_Removed)

	Live_Profile_Game_Dialog.Register_Event_Handler("On_YesNoOk_Yes_Clicked", nil, On_YesNoOk_Yes_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_YesNoOk_No_Clicked", nil, On_YesNoOk_No_Clicked)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_YesNoOk_Ok_Clicked", nil, On_YesNoOk_Ok_Clicked)
	
	Live_Profile_Game_Dialog.Register_Event_Handler("Mouse_Move", nil, On_Mouse_Move)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_Medal_Mouse_On", nil, On_Medal_Mouse_On)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_Medal_Mouse_Off", nil, On_Medal_Mouse_Off)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_Player_Name_Mouse_On", nil, On_Player_Name_Mouse_On)
	Live_Profile_Game_Dialog.Register_Event_Handler("On_Player_Name_Mouse_Off", nil, On_Player_Name_Mouse_Off)
	
	Live_Profile_Game_Dialog.Register_Event_Handler("Mouse_Left_Up", Live_Profile_Game_Dialog, On_Empty_Space_Clicked)

	-- [JLH 08/06/2007]:  Register for heavyweight embedded scenes closing so that we can start and stop our movies.
	Live_Profile_Game_Dialog.Register_Event_Handler("Heavyweight_Child_Scene_Closing", nil, Heavyweight_Child_Scene_Closing)
	Live_Profile_Game_Dialog.Register_Event_Handler("Medal_Chest_Closing", nil, On_Medal_Chest_Closing)
	
	-- JOE TODO: GAMES_IN_PROGRESS
	--this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Panel_Custom_Lobby.Checkbox_Show_Games_In_Progress, Toggle_Show_Games_In_Progress)
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function CMCommon_Constants_Init()

	SIMULATE_REAL_LOAD = false
	
	VIEW_STATE_GAME_FILTERS_JOIN = Declare_Enum(1)
	VIEW_STATE_GAME_OPTIONS_HOST = Declare_Enum()
	VIEW_STATE_GAME_OPTIONS_HOST_STAGING = Declare_Enum()
	VIEW_STATE_GAME_FILTERS_QUICKMATCH_JOIN = Declare_Enum()
	VIEW_STATE_GAME_CUSTOM_LOBBY = Declare_Enum()
	VIEW_STATE_GAME_STAGING = Declare_Enum()
	
	SYSTEM_CHAT_COLOR = 1
	
	JOIN_STATE_HOST = Declare_Enum(1)
	JOIN_STATE_GUEST = Declare_Enum()
	
	MATCHING_STATE_PLAYER_MATCH = Declare_Enum(1)
	MATCHING_STATE_LIST_PLAY = Declare_Enum()

	JOIN_PHASE_IDLE = Declare_Enum(1)
	JOIN_PHASE_ATTEMPTING = Declare_Enum()
	JOIN_PHASE_CANCELLED = Declare_Enum()
	JOIN_PHASE_GATHERING_DATA = Declare_Enum()
	JOIN_PHASE_JOINED = Declare_Enum()
	
	GUEST_JOIN_AUTOCANCEL_PERIOD = 10				-- Autocancel a join attempt after 10 seconds.
	
	VIEW_MAX_TEAM = MAX_TEAMS
	
	VIEW_GAME_START_COUNTDOWN = 5
	
	AVAILABLE_SESSIONS_REFRESH_PERIOD = 15
	INTERNET_SESSIONS_REFRESH_PERIOD = 15
	LAN_SESSIONS_REFRESH_PERIOD = 3
	MAX_VISIBLE_SESSIONS = 1000
	MANUAL_SESSION_REFRESH_THROTTLE_PERIOD = 2	-- Seconds the Refresh button stays dark after being clicked.
	
	LOBBY_DEFAULT_FACTION = PG_FACTION_NOVUS
	LOBBY_DEFAULT_TEAM = 1
	LOBBY_DEFAULT_COLOR = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[0]
	
	NO_MAP_PREVIEW_TEXTURE = "i_no_button.tga"
	SPINNER_UP_NORMAL = "i_combobox_small_up.tga"
	SPINNER_DOWN_NORMAL = "i_combobox_small_down.tga"
	SPINNER_UP_HIGHLIGHT = "i_combobox_small_up_mouse_over.tga"
	SPINNER_DOWN_HIGHLIGHT = "i_combobox_small_down_mouse_over.tga"
	
	TEXT_FILTER_ALL = Get_Game_Text("TEXT_GAME_TYPE_FILTER_ALL")
	TEXT_NO = Get_Game_Text("TEXT_NO")
	TEXT_YES = Get_Game_Text("TEXT_YES")

	COMBO_SELECTION_NO	= 0
	COMBO_SELECTION_YES	= 1

	COMBO_SELECTION_FILTER_ANY	= 0
	COMBO_SELECTION_FILTER_NO	= 1
	COMBO_SELECTION_FILTER_YES	= 2
	
	WIDE_OPEN_BRACE = Create_Wide_String("[")
	WIDE_CLOSE_BRACE = Create_Wide_String("]")
	
	-- UI Refresh Handlers
	UIRefreshHandlers = {}
	UIRefreshHandlers[VIEW_STATE_GAME_FILTERS_JOIN]						= Refresh_Options
	UIRefreshHandlers[VIEW_STATE_GAME_OPTIONS_HOST]						= Refresh_Options
	UIRefreshHandlers[VIEW_STATE_GAME_OPTIONS_HOST_STAGING]			= Refresh_Options
	UIRefreshHandlers[VIEW_STATE_GAME_FILTERS_QUICKMATCH_JOIN]		= Refresh_Quickmatch
	UIRefreshHandlers[VIEW_STATE_GAME_CUSTOM_LOBBY]						= Refresh_Custom_Lobby
	UIRefreshHandlers[VIEW_STATE_GAME_STAGING]							= Refresh_Staging

	-- Game setup / Filtering Values
	
	STARTING_CASH_VALUES = {}
	if (BETA_BUILD) then
	
		local value = GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_MEDIUM]
		table.insert(STARTING_CASH_VALUES, { data = PG_FACTION_CASH_MEDIUM, display = value })
		
	else
	
		local value = GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_SMALL]
		table.insert(STARTING_CASH_VALUES, { data = PG_FACTION_CASH_SMALL, display = value })
		
		value = GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_MEDIUM]
		table.insert(STARTING_CASH_VALUES, { data = PG_FACTION_CASH_MEDIUM, display = value })
		
		value = GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_LARGE]
		table.insert(STARTING_CASH_VALUES, { data = PG_FACTION_CASH_LARGE, display = value })
		
	end
	
	-- Population cap
	POP_CAP_VALUES = {}
	if (BETA_BUILD) then
		table.insert(POP_CAP_VALUES, { data = 90, display = Get_Localized_Formatted_Number(90), default = true })
	else
		table.insert(POP_CAP_VALUES, { data = 40, display = Get_Localized_Formatted_Number(40) })
		table.insert(POP_CAP_VALUES, { data = 50, display = Get_Localized_Formatted_Number(50) })
		table.insert(POP_CAP_VALUES, { data = 60, display = Get_Localized_Formatted_Number(60) })
		table.insert(POP_CAP_VALUES, { data = 70, display = Get_Localized_Formatted_Number(70) })
		table.insert(POP_CAP_VALUES, { data = 80, display = Get_Localized_Formatted_Number(80) })
		table.insert(POP_CAP_VALUES, { data = 90, display = Get_Localized_Formatted_Number(90), default = true })
	end
	
	GAME_COUNTDOWN_SECONDS = 5
	
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function CMCommon_Variables_Init()
	
	-- View Layer Variables
	StartingViewState = VIEW_STATE_GAME_CUSTOM_LOBBY
	ViewPlayerInfoClusters = {}
	MPMapModel = PGLobby_Generate_Map_Selection_Model()	-- List of multiplayer maps.
	ViewStateStack = {}
	PGMO_Clear()
	PGMO_Set_Justification(SCREEN_JUSTIFY_CENTER)

	-- Data Layer Variables
	Variables_Reset()
	JoinNotificationStore = {}	-- Used to queue up joiners so their join events can be reported in chat.
	MapValidityLookup = {}
	
	-- Set up some defaults.
	HostGameDefaults = CMCommon_Init_Host_Defaults()
	JoinFilterDefaults = CMCommon_Init_Join_Filter_Defaults()
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function CMCommon_Init_Host_Defaults()

	host_game_defaults = {}
	host_game_defaults.VictoryCondition = 1
	host_game_defaults.DEFCON = 0
	host_game_defaults.Alliances = 0
	host_game_defaults.Medals = 1
	host_game_defaults.HeroRespawn = 0
	host_game_defaults.StartingCredits = 1
	host_game_defaults.PopCap = 5
	host_game_defaults.Private = 0
	host_game_defaults.GoldOnly = 0
	return host_game_defaults
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function CMCommon_Init_Join_Filter_Defaults()
	
	join_filter_defaults = {}
	join_filter_defaults.Map = 0
	join_filter_defaults.VictoryCondition = 0
	join_filter_defaults.DEFCON = 0
	join_filter_defaults.Alliances = 0
	join_filter_defaults.Medals = 0
	join_filter_defaults.HeroRespawn = 0
	join_filter_defaults.StartingCredits = 0
	join_filter_defaults.PopCap = 0
	join_filter_defaults.ShowInProgress = 0
	join_filter_defaults.GoldOnly = 0
	return join_filter_defaults
	
end

-------------------------------------------------------------------------------
-- This function may be called multiple times in order to reset all variables.
-------------------------------------------------------------------------------
function CMCommon_Variables_Reset()

	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(-1)
	
	ClientTable = {}
	GameScriptData = {}
	GameScriptData.victory_condition = VICTORY_CONQUER
	GameScriptData.is_defcon_game = false
	
	ProfileAchievements = {}			-- Will store all the profile achievements for everyone else in the game
										-- to be added to GameScriptData once the game is ready to start.

	if GameOptions == nil then GameOptions = {} end
	GameOptions.ranked = false
	GameScriptData.GameOptions = GameOptions

	QuickMatchRequested = false
	AllowGameCountdown = false
	StartGameCountdown = -1
	CurrentlySelectedClient = nil
	CMCommon_Set_Currently_Selected_Session(nil)
	GameHasStarted = false
	JoinState = JOIN_STATE_GUEST
	ViewFiltersSettings = nil
	IsShowing = true
	CountdownShowing = false
	CurrentlyJoinedSession = nil
	GameIsStarting = false
	JoinedGame = false
	Recieved_Game_Settings = false
	StartGameCalled = false
	ManualRefreshInitiated = true
	JoinPhase = JOIN_PHASE_IDLE
	GuestJoinVerifyID = 0
	HostStatsRegistration = false
	HostStatsRegistrationComplete = false
	GameAdvertiseData = nil
	SessionLeavePending = false
	ForceSessionLeave = false
	LastSessionRefresh = nil
	IsPollingAvailableSessions = false
	ShowGamesInProgress = true
	ValidMapSelection = true
	MapValidityLookup = {}
	SuppressSFX = false
	
	LocalClient = {}
	CMCommon_Update_Local_Client()
			
end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
--
-- NOTE:::  By default, yes/no, on/off, enabled/disabled combos are populated
-- first with the off option.
-------------------------------------------------------------------------------
function CMCommon_Initialize_Components()

	PGLobby_Init_Modal_Message(Live_Profile_Game_Dialog)
	PGLobby_Set_Dialog_Is_Hidden(false)

	-- --------------------------
	-- GAME FILTERS PANEL
	-- --------------------------
	Initialize_Filters()

	-- --------------------------
	-- CUSTOM LOBBY PANEL
	-- --------------------------
	
	-- Initialize the available sessions box
	AVAILABLE_SESSIONS_COLUMN_NAME = Get_Game_Text("TEXT_MULTIPLAYER_HOST_NAME")
	AVAILABLE_SESSIONS_COLUMN_PLAYERS = Get_Game_Text("TEXT_INTERNET_PLAYERS")
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Header_Style("TEXT") 
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Add_Column(AVAILABLE_SESSIONS_COLUMN_NAME, JUSTIFY_LEFT)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Add_Column(AVAILABLE_SESSIONS_COLUMN_PLAYERS, JUSTIFY_RIGHT)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Column_Width(AVAILABLE_SESSIONS_COLUMN_NAME, 0.75)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_List_Entry_Font("Chat_White")
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Refresh()
	
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Quad_Map_Preview.Set_Render_Mode(0)

	-- --------------------------
	-- GAME STAGING PANEL
	-- --------------------------
   
	-- Set up the player clusters so they can be procedurally iterated over.
	local panel = Live_Profile_Game_Dialog.Panel_Game_Staging
	local clusters = Find_GUI_Components(panel, "Player_Cluster_")
	
	for index, cluster in ipairs(clusters) do
	
		local map = {}
		map.Handle = cluster
		map.Handle.Set_Hidden(true)
		map.Handle.Set_Seat(index)
		table.insert(ViewPlayerInfoClusters, map)
	
	end
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function CMCommon_Set_Host_Defaults()

	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	
	--Prevent audio from playing any time we're editing settings from script
	SuppressSFX = true
	panel.Combo_Win_Condition.Set_Selected_Index(HostGameDefaults.VictoryCondition)
	panel.Combo_DEFCON_Active.Set_Selected_Index(HostGameDefaults.DEFCON)
	panel.Combo_Hero_Respawn.Set_Selected_Index(HostGameDefaults.HeroRespawn)
	panel.Combo_Starting_Credits.Set_Selected_Index(HostGameDefaults.StartingCredits)
	panel.Combo_Unit_Population_Limit.Set_Selected_Index(HostGameDefaults.PopCap)
	panel.Combo_Private_Game.Set_Selected_Index(HostGameDefaults.Private)
	panel.Combo_Medals.Set_Selected_Index(HostGameDefaults.Medals)
	SuppressSFX = false
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function CMCommon_Set_Join_Filter_Defaults()

	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters

	--Prevent audio from playing any time we're editing settings from script
	SuppressSFX = true
	panel.Combo_Map.Set_Selected_Index(JoinFilterDefaults.Map)
	panel.Combo_Win_Condition.Set_Selected_Index(JoinFilterDefaults.VictoryCondition)
	panel.Combo_DEFCON_Active.Set_Selected_Index(JoinFilterDefaults.DEFCON)
	panel.Combo_Hero_Respawn.Set_Selected_Index(JoinFilterDefaults.HeroRespawn)
	panel.Combo_Starting_Credits.Set_Selected_Index(JoinFilterDefaults.StartingCredits)
	panel.Combo_Unit_Population_Limit.Set_Selected_Index(JoinFilterDefaults.PopCap)
	panel.Combo_Medals.Set_Selected_Index(JoinFilterDefaults.Medals)
	SuppressSFX = false
	
end

------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function CMCommon_Play_Mouse_Over_Button_SFX(event, source)
	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
		end
	end
	
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function CMCommon_Play_Button_Select_SFX(event, source)

	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			if source == this.Button_Back then
				Play_SFX_Event("GUI_Main_Menu_Back_Select")
			else
				Play_SFX_Event("GUI_Main_Menu_Button_Select")
			end
		end
	end
	
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function CMCommon_Play_Option_Select_SFX(event, source)

	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			Play_SFX_Event("GUI_Main_Menu_Options_Select")
		end
	end
	
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function CMCommon_Play_Mouse_Over_Option_SFX(event, source)

	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
		end
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Update_Selected_Player_View()

	if (CurrentlySelectedClient == nil) then
		return nil
	end

	local label = ({ [1] = "WHITE", [2] = "RED", [3] = "ORANGE", [4] = "YELLOW", [5] = "GREEN", [6] = "CYAN", [7] = "BLUE", [8] = "PURPLE", [9] = "GRAY", })[CurrentlySelectedClient.color] 
	local dao = ({ YELLOW = { a = 1, b = 0.18, g = 0.87, r = 0.89, }, CYAN = { a = 1, b = 0.88, g = 0.85, r = 0.44, }, RED = { a = 1, b = 0.09, g = 0.09, r = 1, }, BLUE = { a = 1, b = 1, g = 0.59, r = 0.31, }, WHITE = { a = 1, b = 1, g = 1, r = 1, }, PURPLE = { a = 1, b = 0.82, g = 0.44, r = 1, }, ORANGE = { a = 1, b = 0.09, g = 0.58, r = 1, }, GREEN = { a = 1, b = 0.31, g = 1, r = 0.47, }, GRAY = { a = 1, b = 0.12, g = 0.12, r = 0.12, }, })[label]
	
	local seat = Network_Get_Seat(CurrentlySelectedClient)
	PGMO_Set_Seat_Color(seat, CurrentlySelectedClient.color)
	
	return dao
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- V I E W   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Focus_Lost(event, source)

--[[
	DebugMessage("LUA_LOBBY:::  Focus Loss: " .. tostring(source.Get_Name()))
]]
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Focus_Gained(event, source)

--[[
	DebugMessage("LUA_LOBBY:::  Focus Gain: " .. tostring(source.Get_Name()))
]]
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Update()

	-- Update the scheduler.
	PGCrontab_Update()
	
	-- Update voices.
	CMCommon_Update_Player_Voice_States()

	if InvitationAccepted and Net.Get_Time() - InvitationAccepted > 30 then
		PGLobby_Display_Modal_Message("TEXT_GAME_INVITE_JOIN_FAILED")
		Set_Finished_Invitation()
		Leave_Game()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Mouse_Move(event, source)
	PGLobby_Mouse_Move()
	PGMO_Mouse_Move()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Component_Shown()
	this.Start_Modal()
	this.Focus_First()
	Variables_Reset()
	View_Back_To_Start()
	PGLobby_Set_Dialog_Is_Hidden(false)
	Set_Currently_Selected_Client(LocalClient)
	Update_Selected_Player_View()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER })
	PGLobby_Activate_Movies()
	CMCommon_Refresh_Selected_Session_View()
	CMCommon_Start_Available_Session_Polling()
	CMCommon_Initialize_Game_Filtering()
	
	-- Schedule NAT Info Display
	ShowNATInfo = true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Close_Dialog()

	if (TestValid(Live_Profile_Game_Dialog.Achievement_Chest)) then
		Live_Profile_Game_Dialog.Achievement_Chest.Set_Hidden(true)
		Live_Profile_Game_Dialog.Achievement_Chest.End_Modal()
	end
	End_Quickmatching_State()
	CMCommon_Stop_Available_Session_Polling()
	if (NetworkState == NETWORK_STATE_LAN) then
		Net.LAN_Stop()
	elseif (NetworkState == NETWORK_STATE_INTERNET) then
		Net.MM_Leave()
	end
	Unregister_For_Network_Events()
	DebugMessage("LUA_LOBBY:  Shutting down networking...")
	Clear_UI()
	PGLobby_Hide_Modal_Message()
	Live_Profile_Game_Dialog.End_Modal()
	Live_Profile_Game_Dialog.Get_Containing_Component().Set_Hidden(true)
	PGLobby_Passivate_Movies()
	PGLobby_Set_Dialog_Is_Hidden(true)
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Live_Profile_Game_Dialog"})

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_View_Back_Out()

	-- If the achievement chest is showing hide it.
	if (TestValid(Live_Profile_Game_Dialog.Achievement_Chest) and Live_Profile_Game_Dialog.Achievement_Chest.Is_Showing()) then
		Live_Profile_Game_Dialog.Achievement_Chest.Set_Hidden(true)
		return
	end
	
	-- Cleanup backouts.
	if (ViewState == VIEW_STATE_GAME_STAGING) then
	
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Clear()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(-1)
		Leave_Game()
			
	elseif ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then

		if (ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) then
			Set_Currently_Selected_Client(LocalClient)
		end

		CMCommon_Populate_Filter_Settings()
	end
	
	-- Get the last view state off the stack.
	local state = CMCommon_Pop_View_State()
	
	-- If there is no last view state, we go back to the main menu.
	if (state == nil) then
		Leave_Game()
		Close_Dialog()
		return
	end
	
	-- Set the view state (not with Set_View_State() ... would mess up the stack.)
	ViewState = state
	PGLobby_Set_Tooltip_Visible(false)

	if ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		
		Initialize_Filters()
		Populate_UI_From_Profile()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		CMCommon_Update_Player_List()
		CMCommon_Setup_Staging_Map_Overlay()
		
	end

	CMCommon_Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_View_Back_To_Start()

	-- If the achievement chest is showing hide it.
	if (TestValid(Live_Profile_Game_Dialog.Achievement_Chest) and Live_Profile_Game_Dialog.Achievement_Chest.Is_Showing()) then
		Live_Profile_Game_Dialog.Achievement_Chest.Set_Hidden(true)
		return
	end
	
	-- Cleanup backouts.
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Clear()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(-1)
		Leave_Game()
	end
	
	CMCommon_Clear_View_Stack()
	CMCommon_Initialize_View_State(StartingViewState)
	CMCommon_Do_Available_Sessions_Refresh()
	CMCommon_Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Empty_Space_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Back_Clicked()

	View_Back_Out()
	
	if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		CMCommon_Do_Available_Sessions_Refresh()
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
		-- The host has gone to change settings for the game and clicked "Back" instead of "accept",
		-- so we restore the original start position view.
	  	Refresh_Staging_Map_Overlay()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_My_Online_Profile_Clicked()
	if not TestValid(Live_Profile_Game_Dialog.Achievement_Chest) then
		local handle = Create_Embedded_Scene("Achievement_Chest", Live_Profile_Game_Dialog, "Achievement_Chest")
	else
		Live_Profile_Game_Dialog.Achievement_Chest.Set_Hidden(false)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Join_Game_Clicked()

	-- Early out if there is no selected session.
	if (CurrentlySelectedSession == nil) then
		return
	end

	-- Early out if the selected session is fake
	if ((CurrentlySelectedSession.fake) or (not Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Is_Enabled())) then
		return
	end
	
	-- Early out if the Join Game button is already disabled
	if (Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Is_Enabled() == false) then
		return
	end

	PGLobby_Reset()
	Set_Game_Is_Starting(false)
	Received_Game_Settings = false
	CMCommon_Set_Join_State(JOIN_STATE_GUEST)
	
	-- The actual state change does not occur here.  If the join
	-- is successful, then the state change will occur when the 
	-- join operation completes and we're in the game.
	local result = CMCommon_Attempt_Join_Game()
	if (result) then
		-- The join is successful...hide the Go button so it doesn't get mashed.
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Enable(false)
		CMCommon_Set_Join_Phase(JOIN_PHASE_ATTEMPTING)
		NeedClusterFocus = CLUSTER_FOCUS_NUM
	end
	   
end

-------------------------------------------------------------------------------
-- The actual function which kicks off game hosting is CMCommon_Do_Host_Game()
-------------------------------------------------------------------------------
function CMCommon_On_Host_Game_Clicked()

	PGLobby_Reset()
	Set_Game_Is_Starting(false)
	Set_View_State(VIEW_STATE_GAME_OPTIONS_HOST)
	Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Accept.Enable(true)
	CMCommon_Set_Join_State(JOIN_STATE_HOST)
	Initialize_Filters()
	PGMO_Clear() 
	CMCommon_Refresh_UI()
	Populate_UI_From_Profile()
	
end

-------------------------------------------------------------------------------
-- This is the Edit Settings button you see in the staging screen when you
-- are the host.  We pop you into the host settings screen and then hide the 
-- Go button so all you can do is back out of it.
-------------------------------------------------------------------------------
function CMCommon_On_Edit_Settings_Clicked()

	Persist_UI_To_Profile()
	Set_View_State(VIEW_STATE_GAME_OPTIONS_HOST_STAGING)
	Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Accept.Enable(true)
	PGMO_Save_Start_Position_Assignments(GameOptions.map_filename_only)		-- VIEW ONLY:  Stores them off in case the user hits "Back".
	PGMO_Clear() 
	Initialize_Filters()
	CMCommon_Refresh_UI()
	Populate_UI_From_Profile()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Button_Quickmatch_Clicked()

	Start_Quickmatching_State()
	CMCommon_Set_Join_State(JOIN_STATE_GUEST)
	if not IsPollingAvailableSessions then
		CMCommon_Start_Available_Session_Polling()
	else
		CMCommon_Update_Available_Sessions(true)
	end
	PGLobby_Display_Custom_Modal_Message("TEXT_MULTIPLAYER_QUICK_MATCH_SEARCHING", "", "TEXT_BUTTON_CANCEL", "")
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Button_Gamer_Card_Clicked()

	if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
		if CurrentlySelectedSession ~= nil then
			local xuid = CurrentlySelectedSession.xuid
			if xuid ~= nil then
				Net.Show_Gamer_Card_UI(xuid)
			end
		end
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
		if not CurrentlySelectedClient.is_ai then
			local xuid = Net.Get_XUID_By_Network_Address(CurrentlySelectedClient.common_addr)
			Net.Show_Gamer_Card_UI(xuid)
		end
	end

end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Lobby_Filters_Clicked()

	Set_View_State(VIEW_STATE_GAME_FILTERS_JOIN)
	Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Accept.Enable(true)
	CMCommon_Set_Join_State(JOIN_STATE_GUEST)
	Initialize_Filters()
	PGMO_Clear()
	CMCommon_Refresh_UI()
	Populate_UI_From_Profile()
	
end

-------------------------------------------------------------------------------
-- War Chest Button
-------------------------------------------------------------------------------
function CMCommon_On_Button_Medal_Chest_Clicked()

	if not TestValid(Live_Profile_Game_Dialog.Achievement_Chest) then
		local handle = Create_Embedded_Scene("Achievement_Chest", Live_Profile_Game_Dialog, "Achievement_Chest")
	else
		Live_Profile_Game_Dialog.Achievement_Chest.Set_Hidden(false)
	end
	
	PGMO_Hide()
	PGLobby_Passivate_Movies()
	
end
	
-------------------------------------------------------------------------------
-- If we're hosting a game, this screen is for changing the settings of the
-- existing game, otherwise we're just filtering the games we want to see
-- in the available games list.
-------------------------------------------------------------------------------
function CMCommon_On_Button_Filters_Accept_Clicked()

	Persist_UI_To_Profile()
	
	if (ViewState == VIEW_STATE_GAME_FILTERS_JOIN) then
	
		CMCommon_Capture_Filter_Settings()
		Refresh_Game_Filtering()
		View_Back_Out()
		
	elseif (ViewState == VIEW_STATE_GAME_OPTIONS_HOST) then
	
		CMCommon_Capture_Filter_Settings()
		Initialize_Game_Hosting()
		CMCommon_Do_Host_Game()
	
		NeedClusterFocus = CLUSTER_FOCUS_NUM
		
	elseif (ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) then
	
		CMCommon_Capture_Filter_Settings()
		Reinitialize_Game_Hosting()
		View_Back_Out()
		CMCommon_Update_Player_List()
		CMCommon_Setup_Staging_Map_Overlay()
		
		-- If the map selection didn't change, restore the view of the start position
		-- selections since they will still be the same in the network data model.
		local curr_user_data = GameOptions.map_filename_only
		local prev_user_data = PGMO_Get_Saved_Start_Pos_User_Data()
		if (curr_user_data == prev_user_data) then
			Refresh_Staging_Map_Overlay()
		end
		
	end
	
	CMCommon_Refresh_UI()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_YesNoOk_Yes_Clicked()

	-- Quickmatch failed?
	if (QuickMatchFailed) then
		QuickMatchFailed = nil
		PGCrontab_Schedule(On_Button_Quickmatch_Clicked, 0, 1)
	end
	
	-- Host wants to quit?
	if (JoinedGame and SessionLeavePending) then
		SessionLeavePending = false
		ForceSessionLeave = true
		CMCommon_Confirm_User_Exit_Staging()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_YesNoOk_No_Clicked()

	if (QuickMatchFailed) then
		QuickMatchFailed = nil
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_YesNoOk_Ok_Clicked()

	-- If we were attempting to join a game, this click means the user cancelled.
	if (JoinPhase == JOIN_PHASE_ATTEMPTING) then
	
		DebugMessage("LUA_LOBBY:  User has cancelled a join request.")
		CMCommon_Set_Join_Phase(JOIN_PHASE_CANCELLED)
		Leave_Game(false)
		PGLobby_Hide_Modal_Message()
		CMCommon_Refresh_UI()
		On_Join_Attempt_Cancelled()

	end
	
	-- When we've first joined a session and we're initially waiting for 
	-- data from other players, give the player a chance to leave the session.
	if (JoinPhase == JOIN_PHASE_GATHERING_DATA) then
	
		DebugMessage("LUA_LOBBY:  User has cancelled a join request.")
		CMCommon_Set_Join_Phase(JOIN_PHASE_IDLE)
		Leave_Game(false)
		PGLobby_Hide_Modal_Message()
		View_Back_To_Start()
		On_Join_Attempt_Cancelled()
		
	end

	-- The user was in the middle of a quickmatch request
	if (QuickMatchRequested) then

		End_Quickmatching_State()

	end

	if (InvitationAccepted) then

		Set_Finished_Invitation()
		Leave_Game()

	end

	if (ForceSessionLeave) then

		ForceSessionLeave = false
		View_Back_To_Start()

	end
	
	-- Update the NAT warning stuff.
	PGLobby_Update_NAT_Warning_State()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Medal_Mouse_On(event, source, achievement_id)

	local achievement = OnlineAchievementMap[achievement_id]
	if (achievement ~= nil) then
		local model = {}
		model.text_title = Get_Game_Text(achievement.Name)
		model.text_body = Get_Game_Text(achievement.BuffDesc)
		model.icon_texture = achievement.Texture
		
		PGLobby_Set_Tooltip_Model(model)
		PGLobby_Set_Tooltip_Visible(true)
	end
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Medal_Mouse_Off(event, source)
	PGLobby_Set_Tooltip_Visible(false)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Matching_Type_Mouse_On(event, source)

	Play_Mouse_Over_Button_SFX(event, source)

	local message = nil
	if (source == Live_Profile_Game_Dialog.Panel_Custom_Lobby.Panel_Matching_State.Button_Player_Match) then
		message = Get_Game_Text("TEXT_MULTIPLAYER_PLAYER_MATCH_TOOLTIP")
	elseif (source == Live_Profile_Game_Dialog.Panel_Custom_Lobby.Panel_Matching_State.Button_List_Play) then
		message = Get_Game_Text("TEXT_MULTIPLAYER_LIST_PLAY_TOOLTIP")
	end

	local model = {}
	model.text_body = message
		
	PGLobby_Set_Tooltip_Model(model)
	PGLobby_Set_Tooltip_Visible(true)
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Matching_Type_Mouse_Off(event, source)
	PGLobby_Set_Tooltip_Visible(false)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Name_Mouse_On(event, source, common_addr)

	local model = {}
	--local ping = GameRandom.Get_Float() * 500	-- TESTING
	local ping = Net.Get_Ping_Time(common_addr)
	local ping_localized = Get_Localized_Formatted_Number(ping)
	local message = Get_Game_Text("TEXT_MULTIPLAYER_PING_READING")
	Replace_Token(message, ping_localized, 1)
	model.text_body = message
	model.icon_texture = PGLOBBY_PING_GOOD_TEXTURE
	if (ping <= PGLOBBY_PING_GOOD_MEDIUM_THRESHOLD) then
		model.icon_texture = PGLOBBY_PING_GOOD_TEXTURE
		model.text_body_color = 5
	elseif (ping <= PGLOBBY_PING_MEDIUM_BAD_THRESHOLD) then
		model.icon_texture = PGLOBBY_PING_MEDIUM_TEXTURE
		model.text_body_color = 4
	else
		model.icon_texture = PGLOBBY_PING_BAD_TEXTURE
		model.text_body_color = 2
	end
	
	--[[JOE DELETE:::  Example
	local model = {}
	model.text_title = Create_Wide_String("This is the Big Fat Greek Title")
	model.text_body = Create_Wide_String("On the occasion of Bilbo Baggins' eleventy-first birthday...")--]]
	
	PGLobby_Set_Tooltip_Model(model)
	PGLobby_Set_Tooltip_Visible(true)
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Name_Mouse_Off(event, source)
	PGLobby_Set_Tooltip_Visible(false)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Filters_Exit_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Staging_Launch_Game_Clicked()
	if (HostingGame) then
		Persist_UI_To_Profile()
		CMCommon_Set_Game_Is_Starting(true)
		Start_Game_Countdown()
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Closing_All_Displays(event, source, suppress_prompts)

	if (ViewState == VIEW_STATE_GAME_STAGING) then
		if suppress_prompts then
			ForceSessionLeave = true
		end
		CMCommon_Confirm_User_Exit_Staging()
	else
		View_Back_Out()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Staging_Exit_Clicked()
	Persist_UI_To_Profile()
	CMCommon_Confirm_User_Exit_Staging()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Confirm_User_Exit_Staging()

	-- If the player wants to leave, we need to present them a warning first.
	local num_human_players = Network_Get_Client_Table_Count(false)
	if (not ForceSessionLeave) then
		local message = "TEXT_MULTIPLAYER_GUEST_LEAVE_WARNING" 
		if (HostingGame) then
			message = "TEXT_MULTIPLAYER_HOST_LEAVE_WARNING" 
		elseif (JoinedGame) then
			message = "TEXT_MULTIPLAYER_GUEST_LEAVE_WARNING" 
		end
		PGLobby_Display_Custom_Modal_Message(message, "TEXT_NO", "", "TEXT_YES")
		SessionLeavePending = true
		return
	end
	
	ForceSessionLeave = false
	SessionLeavePending = false

	View_Back_To_Start()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Lobby_Refresh_Clicked()
	CMCommon_Do_Manual_Refresh()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Do_Manual_Refresh()

	ManualRefreshInitiated = true
	CMCommon_Throttle_Session_Refresh_Button()
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(-1)
	CMCommon_Do_Available_Sessions_Refresh()
	CMCommon_Refresh_UI()
	this.Focus_First()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Set_Default_Clicked()

	if (ViewState == VIEW_STATE_GAME_OPTIONS_HOST) then
		Set_Host_Defaults()
	elseif ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or (ViewState == VIEW_STATE_GAME_FILTERS_QUICKMATCH_JOIN)) then
		Set_Join_Filter_Defaults()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Throttle_Session_Refresh_Button()
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Refresh.Enable(false)
	PGCrontab_Schedule(_CMCommon_End_Session_Refresh_Throttle, 0, MANUAL_SESSION_REFRESH_THROTTLE_PERIOD)
end

-------------------------------------------------------------------------------
-- Should only be called as a scheduled function in 
-- Throttle_Session_Refresh_Button()
-------------------------------------------------------------------------------
function _CMCommon_End_Session_Refresh_Throttle()
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Refresh.Enable(true)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Start_Game_Countdown()

	if ((JoinState ~= JOIN_STATE_HOST) or (not HostingGame)) then
		return
	end

	PGLobby_Set_Local_Session_Open(false) -- Close the session to new joiners.
	PGLobby_Post_Hosted_Session_Data()
	StartGameCalled = false
	StartGameCountdown = VIEW_GAME_START_COUNTDOWN
	local countdown_label = Get_Game_Text("TEXT_MULTIPLAYER_MATCH_BEGINS_IN").append(": ").append(Get_Localized_Formatted_Number(StartGameCountdown))
	CMCommon_Set_Staging_System_Message(countdown_label)
	
	AllowGameCountdown = false
	PGLobby_Begin_Stats_Registration()
	PGCrontab_Schedule(Update_Countdown, 0, 1)
	CMCommon_Update_Player_List()
	CMCommon_Refresh_UI()
			
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Update_Countdown()

	if (StartGameCountdown < 0) then
		return
	end
	
	local host_override_settings = {}
	
	-- Tell everybody this is what their start positions should be.
	host_override_settings.start_positions = CMCommon_Prepare_Host_Start_Position_Override()
	
	Broadcast_Game_Start_Countdown(StartGameCountdown, host_override_settings)
	StartGameCountdown = StartGameCountdown - 1
	if (StartGameCountdown < 0) then
		CMCommon_Kill_Game_Countdown()
	else
		PGCrontab_Schedule(Update_Countdown, 0, 1)
	end
	CMCommon_Refresh_UI()
	
end

------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
function CMCommon_Kill_Game_Countdown()
	StartGameCountdown = -1
	PGCrontab_Schedule(CMCommon_Allow_Game_Countdown, 0, 2)
end

------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
function CMCommon_Allow_Game_Countdown()
	AllowGameCountdown = true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Info_Cluster_State_Changed(event, source, state, seat)

	if (not HostingGame) then return end

	local triple = { }
	if state == CLUSTER_STATE_OPEN then
		local client = ClientSeatAssignments[seat]
		if client ~= nil and client.common_addr ~= nil then
			Network_Remove_Client(client)
		end
		triple.is_closed = false
		ClientSeatAssignments[seat] = triple
	elseif state == CLUSTER_STATE_CLOSED then
		local client = ClientSeatAssignments[seat]
		if client ~= nil and client.common_addr ~= nil then
			Network_Remove_Client(client)
		end
		triple.is_closed = true
		ClientSeatAssignments[seat] = triple
--	elseif state == CLUSTER_STATE_RESERVED then
	end

	PGLobby_Update_Player_Count()

	triple.seat = seat
	Network_Broadcast(MESSAGE_TYPE_PLAYER_SEAT_ASSIGNMENT, triple)
	CMCommon_Update_Player_List()
	-- Player cluster changes can change the number of seats open/closed and we need
	-- to advertise that to people browsing for games.
	CMCommon_Refresh_Advertised_Player_Count()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_AI_Player_Added(event, source, seat)

	if (not HostingGame) then return end

	local ai_player = Network_Add_AI_Player(true)
	Network_Assign_Guest_Seat(ai_player, seat)

	local triple = {}
	triple.seat = seat
	triple.client_addr = ai_player.common_addr
	Network_Broadcast(MESSAGE_TYPE_PLAYER_SEAT_ASSIGNMENT, triple)

	PGLobby_Update_Player_Count()

	CMCommon_Update_Player_List()
	-- Player cluster changes can change the number of seats open/closed and we need
	-- to advertise that to people browsing for games.
	CMCommon_Refresh_Advertised_Player_Count()
	Refresh_Game_Settings_Model()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_AI_Player_Removed(event, source, common_addr)

	if (not HostingGame) then return end

	local client = Network_Get_Client(common_addr)
	
	if client == nil then
		return
	end
	
	Network_Kick_AI_Player(client)

	PGLobby_Update_Player_Count()

	CMCommon_Update_Player_List()
	-- Player cluster changes can change the number of seats open/closed and we need
	-- to advertise that to people browsing for games.
	CMCommon_Refresh_Advertised_Player_Count()
	Refresh_Game_Settings_Model()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Get_Focused_Client_For_Edit()

	-- If you're the host you must be allowed to edit the selected client.
	if (HostingGame and (Client_Editing_Enabled == false)) then
		return nil
	end
	
	local target = LocalClient
	-- If you're the host you can edit yourself plus AI clusters.
	if (HostingGame) then
		target = CurrentlySelectedClient
	end
	
	return target

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Faction_Up_Clicked()

	-- Get the target client for editing (if available).
	local client = Get_Focused_Client_For_Edit()
	if (client == nil) then
		return
	end
	
	client.faction = client.faction - 1
	if (client.faction < PG_SELECTABLE_FACTION_MIN) then
		client.faction = PG_SELECTABLE_FACTION_MAX
	end
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.faction = client.faction
	end
	
	CMCommon_Update_Local_Client()	
	Update_Selected_Player_View()
	
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	else
		Send_User_Settings(client)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Faction_Down_Clicked()

	-- Get the target client for editing (if available).
	local client = Get_Focused_Client_For_Edit()
	if (client == nil) then
		return
	end
	
	client.faction = client.faction + 1
	if (client.faction > PG_SELECTABLE_FACTION_MAX) then
		client.faction = PG_SELECTABLE_FACTION_MIN
	end
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.faction = client.faction
	end
	
	CMCommon_Update_Local_Client()	
	Update_Selected_Player_View()
	
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	else
		Send_User_Settings(client)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Team_Up_Clicked()

	-- Get the target client for editing (if available).
	local client = Get_Focused_Client_For_Edit()
	if (client == nil) then
		return
	end
	
	local team = client.team + 1
	if (team > VIEW_MAX_TEAM) then
		team = 1
	end
	client.team = team

	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.team = client.team
	end
	
	CMCommon_Update_Local_Client()
	Update_Selected_Player_View()
	
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	else
		Send_User_Settings(client)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Team_Down_Clicked()

	-- Get the target client for editing (if available).
	local client = Get_Focused_Client_For_Edit()
	if (client == nil) then
		return
	end
	
	local team = client.team - 1
	if (team < 1) then
		team = VIEW_MAX_TEAM
	end
	client.team = team
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.team = client.team
	end
	
	CMCommon_Update_Local_Client()
	Update_Selected_Player_View()
	
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	else
		Send_User_Settings(client)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Color_Up_Clicked()

	-- Get the target client for editing (if available).
	local client = Get_Focused_Client_For_Edit()
	if (client == nil) then
		return
	end
	
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[client.color]
	index = index - 1
	if (index < 0) then
		index = 7
	end
	client.color = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[index]
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.color = client.color
	end
	
	CMCommon_Update_Local_Client()
	Update_Selected_Player_View()
	
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	else
		Send_User_Settings(client)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Color_Down_Clicked()

	-- Get the target client for editing (if available).
	local client = Get_Focused_Client_For_Edit()
	if (client == nil) then
		return
	end
	
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[client.color]
	index = index + 1
	if (index > 7) then
		index = 0
	end
	client.color = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[index]
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.color = client.color
	end
	
	CMCommon_Update_Local_Client()
	Update_Selected_Player_View()
	
	if (HostingGame and client.is_ai) then
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	else
		Send_User_Settings(client)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Difficulty_Up_Clicked()

	-- You must be allowed to edit the selected client
	if Client_Editing_Enabled == false then
		return
	end

	-- Only the host can do this, because this is guaranteed to be an AI
	if not HostingGame then
		return
	end

	local client = CurrentlySelectedClient

	client.ai_difficulty = client.ai_difficulty + 1
	if (client.ai_difficulty > Difficulty_Hard) then
		client.ai_difficulty = Difficulty_Easy
	end
	client.name = Network_Get_AI_Name(client.ai_difficulty)
	
	CMCommon_Update_Local_Client()	
	Update_Selected_Player_View()
	
	Network_Edit_AI_Player(client)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Difficulty_Down_Clicked()

	-- You must be allowed to edit the selected client
	if Client_Editing_Enabled == false then
		return
	end

	-- Only the host can do this, because this is guaranteed to be an AI
	if not HostingGame then
		return
	end

	local client = CurrentlySelectedClient

	client.ai_difficulty = client.ai_difficulty - 1
	if (client.ai_difficulty < Difficulty_Easy) then
		client.ai_difficulty = Difficulty_Hard
	end
	client.name = Network_Get_AI_Name(client.ai_difficulty)
	
	CMCommon_Update_Local_Client()	
	Update_Selected_Player_View()
	
	Network_Edit_AI_Player(client)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Ready_Clicked(event, source, is_ready)

	if (JoinedGame == false) then
		return
	end
	Persist_UI_To_Profile()
	Enable_Settings_Accept_UI(false)
	Broadcast_Game_Settings_Accept(is_ready, true)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Combo_Map_Selection_Changed()

	if ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then

		-- Get all the details of the map.
		local index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Map.Get_Selected_Index() 
		
		-- If we are filtering the available games query, we leave the index pure to account for the
		-- "Show All" item.  Otherwise we add 1 for the 0-based/1-based discrepancy.
		if (ViewState ~= VIEW_STATE_GAME_FILTERS_JOIN) then
			index = index + 1
		end
		
		local map_dao = PGLobby_Get_Map_By_Index(index)
		
		-- If the dao is nil, show the spinning globe.  Otherwise show the map and overlay
		if ((map_dao == nil) or map_dao.incomplete) then
		
			PGMO_Set_Enabled(false)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Quad_Map_Preview.Set_Hidden(true)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Play()
			PGMO_Hide()
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Player_Count.Set_Text("")
			
		else
			
			Live_Profile_Game_Dialog.Panel_Game_Filters.Quad_Map_Preview.Set_Hidden(false)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
			PGMO_Show()
				
			CMCommon_Setup_Map_Preview(map_dao, Live_Profile_Game_Dialog.Panel_Game_Filters.Quad_Map_Preview, false)

			local player_count_text = Get_Game_Text("TEXT_GAMEPAD_MULTIPLAYER_MAP_PLAYER_COUNT")
			local localized_player_count = Get_Localized_Formatted_Number(map_dao.num_players)
			Replace_Token(player_count_text, localized_player_count, 1)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Player_Count.Set_Text(player_count_text)
			
		end
		
		CMCommon_Validate_Map_Selection(map_dao)
		
		PGMO_Clear_Start_Positions() 
		
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Setup_Map_Preview(map_dao, quad, use_labels)

	-- Preview quad texture
	local map_preview = map_dao.file_name_no_extension
	map_preview = map_preview .. ".tga"

	-- Map Overlay
	PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions, use_labels)
	PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)

	-- Update the preview textures.
	quad.Set_Texture(tostring(map_preview))
	quad.Set_Render_Mode(0)
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Validate_Map_Selection(map_dao)

	if (not HostingGame) then
		return
	end
	
	if (map_dao == nil) then
		local index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Map.Get_Selected_Index() 
		map_dao = PGLobby_Get_Map_By_Index(index + 1)
	end
	
	local player_count = Network_Get_Client_Table_Count(true)
	if player_count > map_dao.num_players then
		Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Accept.Enable(false)
	else
		Live_Profile_Game_Dialog.Panel_Game_Filters.Button_Accept.Enable(true)
	end
		
end
		
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Combo_Starting_Credits_Changed()
	-- Currently do nothing...
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Player_Cluster_Clicked(event_label, _, common_addr)

	if ( common_addr == nil ) then
		Update_Selected_Player_View()
		CMCommon_Update_Player_List()
	end

	local client = Network_Get_Client(common_addr)
	
	if (client == nil) then
		return
	end
	
	Set_Currently_Selected_Client(client)
	Update_Selected_Player_View()
	CMCommon_Update_Player_List()
	
	CMCommon_Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Cancel_Countdown_Clicked()

	if (not HostingGame) then
		return
	end

	CMCommon_Kill_Game_Countdown()
	Broadcast_Game_Kill_Countdown()
	
	-- Starting the countdown forces the game to ignore join requests.  If the host cancels
	-- that and we are not at capacity, we need to clear it.  If the number of players in the game
	-- changes, that is handled automatically in code by the appropriate handler.
	if (CurrentlyJoinedSession.player_count < CurrentlyJoinedSession.max_players) then
		Net.Force_Refuse_Joiners(false)
	end
	
end

-------------------------------------------------------------------------------
-- Kick Player Button
-------------------------------------------------------------------------------
function CMCommon_On_Kick_Player_Clicked(event_name, source)

	-- Early out if we're not the host or the kick button is not enabled.
	if ((not HostingGame) or
		(not this.Panel_Game_Staging.Button_Kick_Player.Is_Enabled())) then
		return
	end	

	if (HostingGame) then
	
		local client = CMCommon_Get_Selected_Client()
		if (client ~= nil) then
		
			if (client.is_ai) then
				Network_Kick_AI_Player(client)
			else
				Network_Kick_Player(client.common_addr)
			end
			Set_Currently_Selected_Client(LocalClient)
			Update_Selected_Player_View()
			CMCommon_Update_Player_List()
			
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Available_Games_Selection_Changed()

	-- If the user is manually refreshing with a session selected, don't clear the session.
	if (ManualRefreshInitiated) then
		return
	end

	-- If there are no other sessions available, just clear the selection and bail.
	if (table.getn(AvailableGames) <= 0) then
		CMCommon_Set_Currently_Selected_Session(nil)
		CMCommon_Refresh_Selected_Session_View()
		CMCommon_Refresh_UI()
		return
	end
	
	-- If the user has nothing selected, clear selection and bail.
	local row_index = Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Get_Selected_Row_Index()
	if (row_index == -1) then
		CMCommon_Set_Currently_Selected_Session(nil)
		CMCommon_Refresh_Selected_Session_View()
		CMCommon_Refresh_UI()
		return
	end
	
	local session = AvailableGames[row_index + 1]	-- Table is 1-indexed, rows are 0-indexed.
	CMCommon_Set_Currently_Selected_Session(session)
	CMCommon_Refresh_Selected_Session_View()
	CMCommon_Refresh_UI()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Setup_Staging_Map_Overlay()

	-- The gamepad version's start markers use labelled markers.
	local use_marker_labels = Is_Gamepad_Active()
	
	local map_dao = MPMapLookup[GameOptions.map_filename_only]
	if (map_dao ~= nil) then
		PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions, use_marker_labels)
		PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
	end
	PGMO_Set_Interactive(true)
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_PGMO_On_Start_Marker_Clicked(source, target_client)

	-- If you're the host, You must be allowed to edit the selected client
	if (HostingGame and (Client_Editing_Enabled == false)) then
		return
	end

	-- Early out if a game is starting...
	if (GameIsStarting) then
		return
	end

	-- Early out if the target client is invalid.
	if (target_client == nil) then
		DebugMessage("LUA_LOBBY: ERROR: Unable to process start marker selection because the currently selected client is invalid.")
		return
	end

	-- If we haven't been assigned a seat yet, we can't choose a marker.
	local target_client_seat = Network_Get_Seat(target_client)
	if (target_client_seat == nil) then
		DebugMessage("LUA_LOBBY: User attempted to select a start position before seat assignment.")
		return
	end

	-- Is the start marker free?
	local start_marker_id = PGMO_Get_Start_Marker_ID(source)
	local start_marker_seat = PGMO_Get_Seat_Assignment(start_marker_id)
	
	-- Is this marker already taken?
	if (start_marker_seat ~= -1) then
	
		if (target_client_seat == start_marker_seat) then
			-- The user is giving up his start marker.
			DebugMessage("LUA_LOBBY: User is clearing their start marker.")
			Network_Request_Clear_Start_Position(start_marker_id)
			return
		else
			DebugMessage("LUA_LOBBY: User selected a start marker which is already taken by someone else.")
			return
		end
		
	end
	
	DebugMessage("LUA_LOBBY: User '" .. tostring(target_client.name) .. "' is requesting a start marker: " .. tostring(start_marker_id))
	Network_Request_Start_Position(target_client, start_marker_id)
	
	-- If we're the host and the target was an AI, the request will be processed and assigned.
	PGMO_Assign_Start_Position(start_marker_id, target_client_seat, target_client.color)
	
end

-------------------------------------------------------------------------------
-- The first call to set the view state needs to avoid the traversal stack.
-------------------------------------------------------------------------------
function CMCommon_Initialize_View_State(state)
	ViewState = state
	PGLobby_Set_Tooltip_Visible(false)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_View_State(state)

	-- The gamepad version's start markers use labelled markers.
	local use_marker_labels = Is_Gamepad_Active()
	
	CMCommon_Push_View_State(ViewState)
	ViewState = state
	PGLobby_Set_Tooltip_Visible(false)
	
	-- If we're going to the staging state, we need to setup the map overlay.
	if (state == VIEW_STATE_GAME_STAGING) then
		local map_dao = MPMapLookup[GameOptions.map_filename_only]
		if (map_dao ~= nil) then
			PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions, use_marker_labels)
			PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
		end
	end
	
	this.Focus_First()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Push_View_State(state)
	if (state ~= nil) then
		table.insert(ViewStateStack, state)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Pop_View_State()

	if (#ViewStateStack <= 0) then
		return nil
	end

	local result = table.remove(ViewStateStack)
	return result
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Clear_View_Stack()
	ViewStateStack = {}
end

-------------------------------------------------------------------------------
-- Used to discriminate between host and guest state at the view layer.
--
-- One of:
--   JOIN_STATE_HOST
--   JOIN_STATE_GUEST
-------------------------------------------------------------------------------
function CMCommon_Set_Join_State(state)
	JoinState = state
end

-------------------------------------------------------------------------------
-- Used to attach behavior to the various phases of joining a session.
--
-- One of:
--   JOIN_PHASE_IDLE
--   JOIN_PHASE_ATTEMPTING
--   JOIN_PHASE_CANCELLED
--   JOIN_PHASE_GATHERING_DATA
--   JOIN_PHASE_JOINED
-------------------------------------------------------------------------------
function CMCommon_Set_Join_Phase(phase)

	JoinPhase = phase

	-- Display messages
	if (JoinPhase == JOIN_PHASE_IDLE) then
	
	elseif (JoinPhase == JOIN_PHASE_ATTEMPTING) then
	
		PGLobby_Display_Custom_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_JOINING_GAME"), "", Get_Game_Text("TEXT_BUTTON_CANCEL"), "")
		
	elseif (JoinPhase == JOIN_PHASE_CANCELLED) then
	
	elseif (JoinPhase == JOIN_PHASE_GATHERING_DATA) then
	
		PGLobby_Display_Custom_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_PLAYER_DATA"), "", Get_Game_Text("TEXT_BUTTON_CANCEL"), "")
				
	elseif (JoinPhase == JOIN_PHASE_JOINED) then
	
	end
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_Currently_Selected_Session(session)
	CurrentlySelectedSession = session	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Get_Currently_Selected_Session()
	return CurrentlySelectedSession
end

-------------------------------------------------------------------------------
-- This function is the central locus of presentation for the entire lobby.
-- All code related to showing/hiding UI elements, population and configuration
-- of UI elements, or any view-layer functionality related to a view state 
-- change should be implemented here.
-------------------------------------------------------------------------------
function CMCommon_Refresh_UI()

	-- Lobby Title
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Live_Profile_Game_Dialog.Text_Lobby_Title.Set_Text(Get_Game_Text("TEXT_BUTTON_MP_CUSTOM_MATCH"))
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		Live_Profile_Game_Dialog.Text_Lobby_Title.Set_Text(Get_Game_Text("TEXT_BUTTON_MP_LOCAL_AREA_NETWORK"))
	end
	

	-- EXECUTE!
	local refresh_func = UIRefreshHandlers[ViewState]
	refresh_func()


	-- Make sure that movies that are NOT visible are stopped.
	if (ViewState == VIEW_STATE_MAIN) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		
	elseif ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
	
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		
	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		
	end
	

	-- ------------------------------------------------------------------------
	-- Handle services.
	-- ------------------------------------------------------------------------
	if InvitationAccepted == nil then
		if (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
			CMCommon_Start_Available_Session_Polling()
		else
			CMCommon_Stop_Available_Session_Polling()
		end
	end
	
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		PGLobby_Start_Heartbeat()
	else
		PGLobby_Stop_Heartbeat()
	end

	if ( ViewState ~= VIEW_STATE_GAME_STAGING ) then
		this.Focus_First()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Refresh_Options()
			
	Live_Profile_Game_Dialog.Panel_Main.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Game_Filters.Set_Hidden(false)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Set_Hidden(true)
	PGMO_Bind_To_Quad(Live_Profile_Game_Dialog.Panel_Game_Filters.Quad_Map_Preview)
	PGMO_Set_Enabled(true)
	PGMO_Set_Interactive(false)
	
	if (NetworkState == NETWORK_STATE_INTERNET) then
		Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Medals.Set_Hidden(false)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Medals.Set_Hidden(false)
		if (JoinState == JOIN_STATE_GUEST) then
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Title.Set_Text(Get_Game_Text("TEXT_FILTER_GAME_LIST_HEADER"))
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Private_Game.Set_Hidden(true)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Private_Game.Set_Hidden(true)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Show_In_Progress.Set_Hidden(false)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress.Set_Hidden(false)
			-- Unfortunately we cannot show games in progress in player match!!
			if (MatchingState == MATCHING_STATE_PLAYER_MATCH) then
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Show_In_Progress.Set_Hidden(true)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress.Set_Hidden(true)
			else
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Show_In_Progress.Set_Hidden(false)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress.Set_Hidden(false)
			end 
		elseif (JoinState == JOIN_STATE_HOST) then
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Title.Set_Text(Get_Game_Text("TEXT_INTERNET_HOST_GAME_OPTIONS"))
			if ((MatchingState == MATCHING_STATE_PLAYER_MATCH) and (ViewState ~= VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Private_Game.Set_Hidden(false)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Private_Game.Set_Hidden(false)
			else
				Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Private_Game.Set_Hidden(true)
				Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Private_Game.Set_Hidden(true)
			end
			Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Show_In_Progress.Set_Hidden(true)
			Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress.Set_Hidden(true)
		end
	else
		Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Medals.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Medals.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Private_Game.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Private_Game.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Text_Show_In_Progress.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress.Set_Hidden(true)
	end

	CMCommon_Set_Player_Clusters_Visible(false)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Refresh_Quickmatch()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Refresh_Custom_Lobby()
	
	Live_Profile_Game_Dialog.Panel_Main.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Game_Filters.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Set_Hidden(false)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Set_Hidden(true)
	PGMO_Bind_To_Quad(Live_Profile_Game_Dialog.Panel_Custom_Lobby.Quad_Map_Preview)
	PGMO_Set_Enabled(true)
	PGMO_Set_Interactive(false)
	
	-- Filters and profile don't apply to LAN gaming.
	if (NetworkState == NETWORK_STATE_LAN) then
	
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Gamer_Card.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Medal_Chest.Set_Hidden(true)
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Filters.Set_Hidden(true)

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
	
	CMCommon_Refresh_Selected_Session_View()
	CMCommon_Set_Player_Clusters_Visible(false)
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Refresh_Staging()
	
	-- General buttons
	Live_Profile_Game_Dialog.Panel_Main.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Game_Filters.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Set_Hidden(true)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Set_Hidden(false)
	if (GameIsStarting) then
		PGMO_Set_Interactive(false)
	else
		PGMO_Set_Interactive(true)
	end
	if (ValidMapSelection) then
		PGMO_Bind_To_Quad(Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview)
		PGMO_Set_Enabled(true)
		PGMO_Show()
	else
		PGMO_Hide()
	end
		
	-- Can we edit the selected client?
	if ((CurrentlySelectedClient == nil) or GameIsStarting) then
	
		CMCommon_Set_Selected_Client_Editing_Enabled(false)
		
	elseif (JoinState == JOIN_STATE_GUEST) then
	
		-- Guests can select anyone (in order to display their gamer card)
		if (CurrentlySelectedClient.common_addr == LocalClient.common_addr) then
			CMCommon_Set_Selected_Client_Editing_Enabled(true)
		else
			CMCommon_Set_Selected_Client_Editing_Enabled(false)
		end
		
	else
	
		-- We're host.  We can select anyone in the game, but can only edit
		-- ourself or AIs.
		if (CurrentlySelectedClient.is_ai or (CurrentlySelectedClient.common_addr == LocalClient.common_addr)) then
			CMCommon_Set_Selected_Client_Editing_Enabled(true)
		else
			CMCommon_Set_Selected_Client_Editing_Enabled(false)
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

end

-------------------------------------------------------------------------------
-- Any UI elements which may be holding data that shouldn't persist when 
-- the lobby is backed out of should be cleared here.
-------------------------------------------------------------------------------
function CMCommon_Clear_UI()

	AvailableGames = {}
	ClearAvailableGames = true
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Clear()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Enable_Settings_Accept_UI(enable)

	Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Ready_Launch.Enable(enable)
	
	for _, map in ipairs(ViewPlayerInfoClusters) do
		local handle = map.Handle
		if (handle ~= nil) then
			handle.Enable_Settings_Accept(enable)
		end
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Switch_Guest_To_Staging_View()
	CMCommon_Update_Player_List()
	Set_View_State(VIEW_STATE_GAME_STAGING)
	PGMO_Clear()
	Populate_UI_From_Profile()
	Update_Selected_Player_View()
	Net.Set_User_Info( { [CONTEXT_GAME_STATE] = CurrentlyJoinedSession[CONTEXT_GAME_STATE] } )
	CMCommon_Refresh_UI()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_Player_Clusters_Visible(value)

	local hidden = not value
	
	for _, map in ipairs(ViewPlayerInfoClusters) do
		map.Handle.Set_Hidden(hidden)
		if ( value ) then
			map.Handle.Set_Tab_Order(Declare_Enum())
		else
			map.Handle.Set_Tab_Order(-1)
		end
	end
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Capture_Filter_Settings()

	if (ViewFilterComponents == nil) then
		return
	end

	ViewFiltersSettings = {}
	
	for _, handle in ipairs(ViewFilterComponents) do
		ViewFiltersSettings[handle.Get_Name()] = handle.Get_Selected_Index()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Populate_Filter_Settings()

	if ((ViewFiltersSettings == nil) or (ViewFilterComponents == nil)) then
		return
	end

	--Prevent audio from playing any time we're editing settings from script
	SuppressSFX = true

	for _, handle in ipairs(ViewFilterComponents) do
		local index = ViewFiltersSettings[handle.Get_Name()]
		handle.Set_Selected_Index(index)
	end
    
   SuppressSFX = false
    
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Hide_Lobby_Session_Settings(hidden)

	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Win_Condition.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_DEFCON.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Alliances.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Achievements.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Hero_Respawn.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Starting_Cash.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Pop_Cap.Set_Hidden(hidden)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_AI_Slots.Set_Hidden(hidden)

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_Lobby_Session_Settings(session)

	-- Default the values to unavailable in case we cannot get the data
	local text_na = Get_Game_Text("TEXT_NOT_AVAILABLE")

	-- Win Condition
	local label = Get_Game_Text("TEXT_WIN_CONDITION").append(": ")
	local value = session[PROPERTY_WIN_CONDITION]
	if value then
		label = label.append(VictoryConditionNames[value])
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Win_Condition.Set_Text(label)

	-- DEFCON
	label = Get_Game_Text("TEXT_MULTIPLAYER_DEFCON").append(": ")
	value = session[PROPERTY_DEFCON_ENABLED]
	if value then
		if value == 0 then
			label = label.append(TEXT_NO)
		else
			label = label.append(TEXT_YES)
		end
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_DEFCON.Set_Text(label)

	-- Alliances
	label = Get_Game_Text("TEXT_MULTIPLAYER_ALLIANCES").append(": ")
	value = session[PROPERTY_ALLIANCES_ENABLED]
	if value then
		if value == 0 then
			label = label.append(TEXT_NO)
		else
			label = label.append(TEXT_YES)
		end
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Alliances.Set_Text(label)

	-- Achievements
	label = Get_Game_Text("TEXT_MULTIPLAYER_ALLOW_MEDALS").append(": ")
	value = session[PROPERTY_ACHIEVEMENTS_ENABLED]
	if value then
		if value == 0 then
			label = label.append(TEXT_NO)
		else
			label = label.append(TEXT_YES)
		end
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Achievements.Set_Text(label)

	-- Hero Respawn
	label = Get_Game_Text("TEXT_MULTIPLAYER_HERO_RESPAWN").append(": ")
	value = session[PROPERTY_HERO_RESPAWN_ENABLED]
	if value then
		if value == 0 then
			label = label.append(TEXT_NO)
		else
			label = label.append(TEXT_YES)
		end
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Hero_Respawn.Set_Text(label)

	-- Starting Cash
	label = Get_Game_Text("TEXT_MULTIPLAYER_STARTING_CASH").append(": ")
	value = session[PROPERTY_STARTING_CREDITS]
	if value then
		label = label.append(Get_Game_Text(GAME_CREDITS_LEVEL_VIEW[value]))
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Starting_Cash.Set_Text(label)

	-- Pop Cap
	label = Get_Game_Text("TEXT_MULTIPLAYER_UNIT_POP_CAP").append(": ")
	value = session[PROPERTY_POP_CAP]
	if value then
		label = label.append(Get_Localized_Formatted_Number(value))
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Pop_Cap.Set_Text(label)

	-- AI Slots
	label = Get_Game_Text("TEXT_MULTIPLAYER_AI_SLOTS").append(": ")
	value = session[PROPERTY_AI_SLOTS]
	if value then
		label = label.append(Get_Localized_Formatted_Number(value))
	else
		label = label.append(text_na)
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_AI_Slots.Set_Text(label)

	label = Get_Game_Text("TEXT_INTERNET_MAP_NAME")
	value = _PGLobby_Get_Map_Index_From_CRC(session[PROPERTY_MAP_NAME_CRC])
	if value then
		local map_dao = MPMapModel[value]
		if map_dao ~= nil and map_dao.file_name ~= nil then
			label = label.append(tostring(map_dao.file_name))
		else
			label = Get_Game_Text("TEXT_INTERNET_MAP_NAME_BUTTON")
		end
	else
		label = Get_Game_Text("TEXT_INTERNET_MAP_NAME_BUTTON")
	end
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Map.Set_Text(label)

	Hide_Lobby_Session_Settings(false)

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Refresh_Selected_Session_View()

	local session = CMCommon_Get_Currently_Selected_Session()
	
	if ((not ManualRefreshInitiated) and
		(Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Get_Selected_Row_Index() == -1)) then
		session = nil
	end

	if (session == nil) then
	
		Hide_Lobby_Session_Settings(true)
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Quad_Map_Preview.Set_Hidden(true)
		PGMO_Set_Enabled(false)
		if (PGLobbyMoviesActive) then
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Play()
		else
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		end
		
	else
	
		local map_dao = nil
		
		if (session.map_crc ~= nil) then
			local idx = _PGLobby_Get_Map_Index_From_CRC(session.map_crc)
			if idx then
				map_dao = MPMapModel[idx]		-- MPMapModel is 1-based
			end
		end
	
		if(map_dao == nil) then
		
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Quad_Map_Preview.Set_Hidden(true)
			PGMO_Set_Enabled(false)
			if (PGLobbyMoviesActive) then
				Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Play()
			else
				Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
			end
			
		else
		
			-- Shut off the globe
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
			
			-- Lobby area map texture
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Quad_Map_Preview.Set_Hidden(false)
			local map_preview = map_dao.file_name_no_extension
			map_preview = map_preview .. ".tga"
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.Quad_Map_Preview.Set_Texture(tostring(map_preview))
			
			-- Map Overlay
			PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions)
			PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
			
			-- Staging area map texture
			Live_Profile_Game_Dialog.Panel_Game_Staging.Text_Map.Set_Text(map_dao.file_name_no_extension)
			Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Texture(tostring(map_preview))
			Live_Profile_Game_Dialog.Panel_Game_Staging.Quad_Map_Preview.Set_Render_Mode(0)
	
			
		end

		-- Only show the settings if we are connected to the live backend
		if (NetworkState ~= NETWORK_STATE_INTERNET) then
			Hide_Lobby_Session_Settings(true)
			return
		end

		Set_Lobby_Session_Settings(session)

	end

end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function CMCommon_Persist_Staging_UI_To_Profile()

  	local faction = CMCommon_Validate_Client_Faction(LocalClient.faction)

	Set_Profile_Value(PP_LOBBY_PLAYER_FACTION, faction)
	Set_Profile_Value(PP_LOBBY_PLAYER_TEAM, LocalClient.team)
	Set_Profile_Value(PP_COLOR_INDEX, LocalClient.color)
		
end
	
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function CMCommon_Persist_Host_UI_To_Profile()
		
	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	Set_Profile_Value(PP_LOBBY_HOST_MAP, panel.Combo_Map.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_WIN_CONDITION, panel.Combo_Win_Condition.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_DEFCON, panel.Combo_DEFCON_Active.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_ACHIEVEMENTS, panel.Combo_Medals.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_HERO_RESPAWN, panel.Combo_Hero_Respawn.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_STARTING_CREDITS, panel.Combo_Starting_Credits.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_POP_CAP, panel.Combo_Unit_Population_Limit.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_HOST_PRIVATE_GAME, panel.Combo_Private_Game.Get_Selected_Index())
		
end
		
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function CMCommon_Persist_Filters_To_Profile()

	local panel = Live_Profile_Game_Dialog.Panel_Game_Filters
	Set_Profile_Value(PP_LOBBY_FILTER_MAP, panel.Combo_Map.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_FILTER_WIN_CONDITION, panel.Combo_Win_Condition.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_FILTER_DEFCON, panel.Combo_DEFCON_Active.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_FILTER_ACHIEVEMENTS, panel.Combo_Medals.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_FILTER_HERO_RESPAWN, panel.Combo_Hero_Respawn.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_FILTER_STARTING_CREDITS, panel.Combo_Starting_Credits.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_FILTER_POP_CAP, panel.Combo_Unit_Population_Limit.Get_Selected_Index())
	Set_Profile_Value(PP_LOBBY_SHOW_GAMES_IN_PROGRESS, panel.Combo_Show_In_Progress.Get_Selected_Index())
	
end

-------------------------------------------------------------------------------
-- Populates the available sessions list box
-------------------------------------------------------------------------------
function CMCommon_Update_Available_Sessions_View()

	local list_box = Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games

	list_box.Clear()
	local num_games = 0
	if (AvailableGames ~= nil) then
		num_games = table.getn(AvailableGames)
	end

	if (num_games <= 0) then
		local new_row = list_box.Add_Row()
		local message = Get_Game_Text("TEXT_MULTIPLAYER_NO_GAMES_FOUND")
		list_box.Set_Text_Data(AVAILABLE_SESSIONS_COLUMN_NAME, 0, message)
		list_box.Set_Row_Color(0, tonumber(SYSTEM_CHAT_COLOR))
	end

	-- Sort by joinability.
	local auto_select_index = -1

	for i, session in ipairs(AvailableGames) do

		local name = Create_Wide_String(session.name)

		local version = AvailableGames[i].version_string
		local row = list_box.Add_Row()
		local is_joinable, version_matches = PGLobby_Is_Game_Joinable(session)
		if (is_joinable) then
			list_box.Set_Text_Data(AVAILABLE_SESSIONS_COLUMN_NAME, row, name)
			list_box.Set_Row_Color(row, tonumber(21))
		else
			local game_label
			if (version_matches) then
				game_label = name
			else
				game_label = Create_Wide_String("").append(name).append(" <").append(version).append(">")
			end
			list_box.Set_Text_Data(AVAILABLE_SESSIONS_COLUMN_NAME, row, game_label)
			list_box.Set_Row_Color(row, tonumber(18))
		end
		session.is_joinable = is_joinable

		local max_players = 8
		local num_filled = 0

		if NetworkState == NETWORK_STATE_LAN then
			max_players = session.max_players
			num_filled = session.player_count
		elseif NetworkState == NETWORK_STATE_INTERNET then
			max_players = session.public_open + session.public_filled
			num_filled = session.public_filled
		end
		
		if (max_players == nil) then
			max_players = 0
		end
		if (num_filled == nil) then
			num_filled = 0
		end

		local wstr_num_players = Get_Game_Text("TEXT_FRACTION")
		Replace_Token(wstr_num_players, Get_Localized_Formatted_Number(num_filled), 0)
		Replace_Token(wstr_num_players, Get_Localized_Formatted_Number(max_players), 1)
		list_box.Set_Text_Data(AVAILABLE_SESSIONS_COLUMN_PLAYERS, row, wstr_num_players)
		
		-- If the user had a session selected before this refresh, make sure that session
		-- gets reselected.
		if (CurrentlySelectedSession ~= nil) then
			if (session.name == CurrentlySelectedSession.name) then
				auto_select_index = row
				CMCommon_Set_Currently_Selected_Session(session)
			end
		end

	end
	
	if (CurrentlySelectedSession ~= nil) then
	
		if (auto_select_index == -1) then
			-- JOE DELETE:
			-- This message causes more confusion than it helps.  The expected functionality should probably be that
			-- if a session you had selected goes away, it should just be deselected.  No need for a message.
			--[[-- The game the user had selected has gone away.
			PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_GAME_IN_PROGRESS"), false)
			CMCommon_Set_Currently_Selected_Session(nil)--]]
		else
			Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Set_Selected_Row_Index(auto_select_index)
		end
	
	end
	
	list_box.Refresh()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Update_Player_List()

	CMCommon_Set_Player_Clusters_Visible(false)

	if (ClientTable == nil) then
		return
	end

	local has_players = false
	local num_info_clusters = MapPlayerLimit
	if num_info_clusters == nil then
		num_info_clusters = VIEW_PLAYER_INFO_CLUSTER_COUNT
	end

	for seat = 1, num_info_clusters do
		local handle = ViewPlayerInfoClusters[seat].Handle
		handle.Set_Is_Host(HostingGame)
		handle.Clear_UI()
--		handle.Set_Model()
		handle.Set_Hidden(false)
		handle.Set_Tab_Order(Declare_Enum())
	end

	local client_selected = false
	for seat, client in pairs(ClientSeatAssignments) do

		has_players = true

		if client and (seat <= #ViewPlayerInfoClusters) then
			local handle = ViewPlayerInfoClusters[seat].Handle

			if client.is_closed == true then
				handle.Set_Cluster_State(CLUSTER_STATE_CLOSED)
				handle.Set_Model()
			elseif client.is_closed == false then
				handle.Set_Cluster_State(CLUSTER_STATE_OPEN)
				handle.Set_Model()
			else
		
				local model = {}
				local display_valid = true

				if Is_Reserved_Player(client.common_addr) then
					handle.Clear_UI()
					handle.Set_Is_Reserved(true)
					handle.Set_Hidden(false)
				else
					-- Get the latest data from the client table
					client = Network_Get_Client(client.common_addr)

					-- Address
					model.common_addr = client.common_addr

					local is_local = LocalClient.common_addr == client.common_addr
					handle.Set_Is_Local_Client(is_local)

					-- Name
					model.name = "UNKNOWN"
					if (client.name ~= nil) then
						model.name = client.name
					else
						display_valid = false
					end

					-- Faction
					model.faction = "UNKNOWN"
					if (client.faction ~= nil) then
						model.faction = client.faction
					else
						display_valid = false
					end

					-- Team
					model.team = -1
					if (client.team ~= nil) then
						model.team = client.team
					else
						display_valid = false
					end

					-- Color
					model.color = -1
					model.color_valid = false
					if (client.color ~= nil) then
						model.color = client.color

						if (Check_Color_Is_Taken(client)) then
							display_valid = false
						else
							model.color_valid = true
						end
					else
						display_valid = false
					end

					-- Medals
					if ((client.applied_medals ~= nil) and 
						(GameScriptData.medals_enabled) and
						NetworkState == NETWORK_STATE_INTERNET) then
						model.applied_medals = client.applied_medals
					end
					
					-- Start marker
					model.start_marker_id = client.start_marker_id

					-- Accepts
					model.AcceptsGameSettings = false
					if (client.AcceptsGameSettings ~= nil) then
						model.AcceptsGameSettings = client.AcceptsGameSettings
					else
						display_valid = false
					end

					-- Is it an AI?
					model.is_ai = false
					if client.is_ai then
						model.is_ai = true
						model.name = Network_Get_AI_Name(client.ai_difficulty)
					end

					if (not Is_Gamepad_Active()) then
						-- Download Progress
						model.download_progress = client.download_progress
					end

					-- Bad Connection?
					-- If the bad client list is nil, it means we don't have enough
					-- information yet to properly determine if the connection web
					-- is sound, so we default to displaying a "good" connection.
					if (PGLobbyBadClientList ~= nil) then
						local value = PGLobbyBadClientList[client.common_addr] 
						if (value == true) then
							model.is_bad_connection = true
						else
							-- False if false OR nil.
							model.is_bad_connection = false
						end
					else
						model.is_bad_connection = false
					end
					
					-- Are alliances enabled?
					model.alliances = false
					if GameOptions.alliances_enabled then
						model.alliances = true
					end

					-- DISPLAY IT!
					--			if (not display_valid) then
					--				model = nil
					--			end
					handle.Clear_UI()
					handle.Set_Model(model)
					handle.Set_Hidden(false)
				end

				-- Selected?
				if (CurrentlySelectedClient ~= nil) and (client.common_addr == CurrentlySelectedClient.common_addr) then
					client_selected = true
					handle.Set_Selected_State(true)
				else
					handle.Set_Selected_State(false)
				end
			end

		end

	end

	if not client_selected then

		Set_Currently_Selected_Client(LocalClient)
		local seat = Network_Get_Seat(LocalClient)

		if seat ~= nil then
			local handle = ViewPlayerInfoClusters[seat].Handle
			if handle ~= nil then
				handle.Set_Selected_State(true)
				handle.Set_Editing_Enabled(not GameIsStarting)
			end
		end

	end

	-- Finally loop through the clusters and set the game is starting flag
	for seat = 1, num_info_clusters do
		local handle = ViewPlayerInfoClusters[seat].Handle
		handle.Set_Game_Is_Starting(GameIsStarting)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Update_Player_Voice_States()

	for seat, client in pairs(ClientSeatAssignments) do

		if (client ~= nil and client.is_closed == nil) then
		
			local handle = ViewPlayerInfoClusters[seat].Handle
			if (Net.Voice_Is_Peer_Talking(client.common_addr)) then
				handle.Set_Voice_Active(true)
			else
				handle.Set_Voice_Active(false)
			end
	
		end
		
	end
	
end

---------------------------------------
--
---------------------------------------
function CMCommon_Set_Currently_Selected_Client(client)

	if (HostingGame) then
	
		-- Stop editing the current client then start editing the new one
		CMCommon_Set_Selected_Client_Editing_Enabled(false)

		CurrentlySelectedClient = client
		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Kick_Player.Set_Hidden(false)
		-- You can't kick if there's no one selected, you can't kick yourself, and you can't kick an AI.
		if ((CurrentlySelectedClient == nil) or 
			(CurrentlySelectedClient.common_addr == LocalClient.common_addr) or
			CurrentlySelectedClient.is_ai) then
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Kick_Player.Enable(false)
		else
			Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Kick_Player.Enable(true)
		end

	else
	
		if ((client ~= nil) and (not client.is_ai)) then
			CurrentlySelectedClient = client
		end

		Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Kick_Player.Set_Hidden(true)

		if (CurrentlySelectedClient ~= nil) and (CurrentlySelectedClient.common_addr == LocalClient.common_addr) then
			CMCommon_Set_Selected_Client_Editing_Enabled(true)
		else
			CMCommon_Set_Selected_Client_Editing_Enabled(false)
		end
		
	end
	
end
	
---------------------------------------
--
---------------------------------------
function CMCommon_Set_Selected_Client_Editing_Enabled(enabled)

	if CurrentlySelectedClient == nil then return end

	Client_Editing_Enabled = enabled
	
	-- Ensure that at any time one and only one cluster is editable.
	for _, map in ipairs(ViewPlayerInfoClusters) do
		map.Handle.Set_Editing_Enabled(false)
	end
	
	-- If we're enabling editing, find the seat and turn on editing.
	if (Client_Editing_Enabled) then
	
		local seat = Network_Get_Seat(CurrentlySelectedClient)
		if seat then
			local handle = ViewPlayerInfoClusters[seat].Handle
			if TestValid(handle) then
				handle.Set_Editing_Enabled(enabled)
			end
		end
	
	end
	
	-- If we're a guest, we can ALWAYS edit our own settings (unless a countdown is happening).
	if (JoinedGame and (not HostingGame)) then
		local seat = Network_Get_Seat(LocalClient)
		if seat then
			local handle = ViewPlayerInfoClusters[seat].Handle
			if TestValid(handle) then
				handle.Set_Editing_Enabled(not GameIsStarting)
			end
		end
	end
	
end
				
---------------------------------------
--
---------------------------------------
function CMCommon_Get_Selected_Client()
	if (not HostingGame) then
		return LocalClient
	end
	return CurrentlySelectedClient
end
	
---------------------------------------
--
---------------------------------------
function CMCommon_Set_Staging_System_Message(message)
	Live_Profile_Game_Dialog.Panel_Game_Staging.Text_System_Message.Set_Text(message)
end

---------------------------------------
--
---------------------------------------
function CMCommon_Refresh_Start_Conditions_View()

	-- Start game?
	local can_start, messages, only_awaiting_acceptance = CMCommon_Check_Game_Start_Conditions()
	local messages_valid = ((messages ~= nil) and (messages[1] ~= nil))
	if (can_start and (not GameIsStarting)) then
		
		CMCommon_Set_Staging_System_Message(Get_Game_Text("TEXT_MULTIPLAYER_READY_TO_START"))
			
	elseif ((not can_start) and messages_valid) then
		
		-- If the game isn't ready to start, display the first error message.
		CMCommon_Set_Staging_System_Message(messages[1])
			
	end
	
	return can_start, messages, only_awaiting_acceptance

end
	
-------------------------------------------------------------------------------
-- This event is raised whenever the menu system is awakened after a game mode.
-- We're only interested in it if we have spawned a multiplayer game here, so
-- if that flag is not set, we ignore the event.
-------------------------------------------------------------------------------
function CMCommon_On_Menu_System_Activated()

	PGLobby_Set_Tooltip_Visible(false)

	-- If we are no longer connected to XLive, back out to the main menu.
	if ((NetworkState == NETWORK_STATE_INTERNET) and
		(Net.Get_Signin_State() ~= "online")) then
		Leave_Game()
		Close_Dialog() 
		return
	end
	
	if (not GameHasStarted) then
		return
	end
	
	View_Back_Out()
	-- Paranoia check...View_Back_Out() will call Leave_Game() for us, but just in
	-- case we'll make sure it happened.
	-- Make sure leave game gets called before JoinedGame is set to false
	Leave_Game()
	GameHasStarted = false
	Variables_Reset()
	Initialize_Filters()
	Populate_UI_From_Profile()
	View_Back_To_Start()
	Set_Currently_Selected_Client(LocalClient)
	Update_Selected_Player_View()

	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER })

end

-------------------------------------------------------------------------------
-- Placed this in a logical call because sometimes it is impossible for us
-- to determine if we were disconnected from a session because the host left
-- or we lost connection to Live.  In the latter case, we will bail to the
-- main menu eventually so the ability to call this function in a crontab
-- delay should prevent it from being shown.
-------------------------------------------------------------------------------
function CMCommon_Show_Host_Left_Message()
	PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_HOST_LEFT_GAME"))
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- N E T W O R K I N G   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Called when someone issues a join/leave request for our game.
-------------------------------------------------------------------------------
function CMCommon_Network_On_Connection_Status(event)

	-- Do not handle events if the dialog is not visible because the game has started
	if GameHasStarted then return end

	DebugMessage("LUA_LOBBY:  Network_On_Connection_Status -- status: " .. tostring(event.status))
	DebugMessage("LUA_LOBBY:  Local Common Address: " .. tostring(LocalClient.common_addr))

	-- Always update our local client settings first (mainly to ensure our common_addr is up to date).
	CMCommon_Update_Local_Client(false)
			
	if event.status == "join_accepted" then
	
	elseif event.status == "connected" then

		-- Raised when we join a game.
		if (JoinPhase == JOIN_PHASE_CANCELLED) then
		
			-- User chose to join a game, but then cancelled.
			DebugMessage("LUA_LOBBY:  User cancelled join request.")
			CMCommon_Set_Join_Phase(JOIN_PHASE_IDLE)
			Leave_Game()

		elseif (JoinedGame == false) then 
		
			JoinedGame = true
			CMCommon_Set_Join_Phase(JOIN_PHASE_GATHERING_DATA)
			PGLobbyLastHostHeartbeat = nil
			Set_Client_Table(event.clients)
			if (JoinState == JOIN_STATE_HOST) then
				HostingGame = true
				Network_Assign_Host_Seat(LocalClient)
				PGLobby_Set_Local_Session_Open(true)
				PGLobby_Post_Hosted_Session_Data()
				CurrentlyJoinedSession = event.session
				-- Now that we have a valid session, refresh the game settings model.
				Refresh_Game_Settings_Model()
			end
			Set_Currently_Selected_Client(LocalClient)
			Update_Selected_Player_View()
			
			-- We can now switch to the staging screen.  We discriminate between guests and hosts
			-- here because we have more work to do when we're a joining guest.
			if (JoinState == JOIN_STATE_GUEST) then
				CMCommon_Switch_Guest_To_Staging_View()
			elseif (JoinState == JOIN_STATE_HOST) then
				Set_View_State(VIEW_STATE_GAME_STAGING)
			end
			
			DebugMessage("LUA_LOBBY:  We are now connected to the game at address: " .. tostring(CurrentlyJoinedSession.common_addr))
			
			PGLobby_Request_All_Profile_Achievements()
			
			-- Now, give everybody a moment to receive our join notification, and then spam our settings.
			PGCrontab_Schedule(Send_User_Settings, 0, 1)
			if (HostingGame) then
			
				-- Currently we do not differenitate between public and private slots
				CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count(false)

				-- Check our player count.
				if (CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players) then
					PGLobby_Set_Local_Session_Open(false)
				end
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
				PGCrontab_Schedule(Broadcast_Game_Settings, 0, 1)
				
			end
				
		end

	elseif event.status == "join_failed" then
	
		-- Raised if we failed to join a session.
		DebugMessage("LUA_LOBBY: ERROR: Join attempt failed.  Notifying user....")
		CMCommon_Set_Join_Phase(JOIN_PHASE_IDLE)
		Leave_Game()
		CMCommon_Set_Currently_Selected_Session(nil)
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_GAME_IN_PROGRESS"), false)

	elseif event.status == "session_connect" then

		-- Raised when someone else joins our game.
		
		-- If the session is closed, players should ignore new joiners and the host should boot them.
		if (PGLobbyLocalSessionOpen == false) then
		
			if (HostingGame) then
				Network_Refuse_Player(event.common_addr)
			end

		else

			-- We can't report the player to the chat window yet because we don't know the name,
			-- so we queue this player for reporting later when we recieve the name.
			JoinNotificationStore[event.common_addr] = event.common_addr
			Network_Add_Client(event.common_addr)
			
			-- Request this player's achievement stats from the backend.
			if (NetworkState == NETWORK_STATE_INTERNET) then
				if (ENABLE_ACHIEVEMENT_VERIFICATION) then PGLobby_Request_Profile_Achievements(event.common_addr) end
			end
			
			-- Now, give everybody a moment to receive this player's join notification and then spam our settings.
			--PGCrontab_Schedule(Send_User_Settings, 0, 2)
			Send_User_Settings(LocalClient, event.common_addr)
			if (HostingGame) then
			
				-- Currently we do not differenitate between public and private slots
				CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count(false)

				-- Check our player count.
				if (CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players) then
					PGLobby_Set_Local_Session_Open(false)
				end
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
				
				--Update game settings so that pop cap can be clamped based on player count
				Refresh_Game_Settings_Model()				
				
				local client = Network_Get_Client(event.common_addr)
				Network_Assign_Guest_Seat(client)
				Network_Send_Recommended_Settings(client)
				PGCrontab_Schedule(Broadcast_Game_Settings, 0, 1)
				
				-- If the host is looking at changing settings, they need to be notified
				-- that someone joined and we don't want them to change any settings.
				if (ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) then 
					PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_WARNING_GUEST_JOINED"), false)
					CMCommon_Validate_Map_Selection()
				end
				
			end
			
		end
		
	elseif (event.status == "session_disconnect" and (not GameHasStarted)) then
	
		-- If the host disconnects, and we are not the host, the session is done and we need to leave.
		
		DebugMessage("LUA_LOBBY: *** DISCONNECT DETECTED ***")

		local host_disconnected = false
		if (CurrentlyJoinedSession ~= nil) then
			host_disconnected = (event.common_addr == CurrentlyJoinedSession.common_addr)
		end
		
		if ((HostingGame == false) and JoinedGame and host_disconnected) then
		
			-- We are a guest and the host left the game.
			DebugMessage("LUA_LOBBY: Host disconnected and we are guest.  Bailing...")
			Network_Clear_All_Clients()
			PGCrontab_Schedule(CMCommon_Show_Host_Left_Message, 0, 1)
			View_Back_Out()		-- View_Back_Out handles leaving the game as well
			
		else
		
			-- We are host or guest and a guest left the game.
			local client = Network_Get_Client(event.common_addr)

			-- Check for the client in the kicked players list
			if client == nil then
				client = KickedPlayers[event.common_addr]
				if client ~= nil then
					KickedPlayers[event.common_addr] = nil
				end
			end

			-- Indicate in the chat window that a player has left the game.
			if (client ~= nil) then
				-- It can be possible that a player leaves a session before having transmitted their name.
				local name = Get_Game_Text("TEXT_UNKNOWN")
				if (client.name ~= nil) then
					name = client.name
				end
				DebugMessage("LUA_LOBBY: Player disconnected: " .. tostring(name))
			end
			
			if (HostingGame) then
			
				-- If there is a countdown in progress, stop it.
				if (StartGameCountdown ~= -1) then
					CMCommon_Kill_Game_Countdown()
					Broadcast_Game_Kill_Countdown()
				end
			
				
				-- ** Wipe out this player's presence. **
				-- If the player has chosen a start position, clear it.
				local seat = Network_Get_Seat(client)
				local start_marker_id = PGMO_Get_Start_Marker_ID_From_Seat(seat)
				if (start_marker_id ~= nil) then
					DebugMessage("LUA_LOBBY: Clearing disconnector's start position :" .. tostring(start_marker_id))
					Network_Request_Clear_Start_Position(start_marker_id, client.common_addr)
				end

			end
			
			-- ** Wipe out this player's presence. **
			ProfileAchievements[event.common_addr] = nil
			PGLobbyBadClientList[event.common_addr] = nil
			MapValidityLookup[event.common_addr] = nil
			CMCommon_Set_Client_Map_Validity(event.common_addr, nil)
			ValidMapSelection = CMCommon_Check_Client_Map_Validity()
			CMCommon_Check_Game_Start_Conditions()
			--[[if (GameScriptData.achievement_stats ~= nil) then
				GameScriptData.achievement_stats[event.common_addr] = nil
			end--]]
			
			Network_Remove_Client(event.common_addr)
			
			if (HostingGame) then
			
				-- Currently we do not differenitate between public and private slots
				CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count(false)
			
				-- Check our player count.
				if (CurrentlyJoinedSession.player_count < CurrentlyJoinedSession.max_players) then
					PGLobby_Set_Local_Session_Open(true)
				end
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
				
			end
			
		end

	elseif (event.status == "session_disconnect" and GameHasStarted) then
	
		Leave_Game()

	end

	CMCommon_Update_Player_List()
	if (HostingGame) then
		Set_All_Client_Accepts(false)
	end
	Broadcast_Game_Settings_Accept(false)
	Refresh_Start_Conditions_View()
	CMCommon_Refresh_UI()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Internet_On_MM_Create_Session()
	DebugMessage("LUA_LOBBY:  Internet_On_MM_Create_Session -- status: " .. tostring(event.status))
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Network_On_Find_Internet_Session(event)

	if (NetworkState == NETWORK_STATE_INTERNET) then
		CMCommon_Network_On_Find_Session(event)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Network_On_Find_LAN_Session(event)

	if (NetworkState == NETWORK_STATE_LAN) then
		CMCommon_Network_On_Find_Session(event)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Network_On_Find_Session(event)
	
	PGLobby_Keepalive_Close_Bracket()
	ManualRefreshInitiated = false
		
	DebugMessage("LUA_LOBBY:  Network_On_Find_Session")

	if ClearAvailableGames then
		AvailableGames = {}
	end

	-- If there are no more results on this query, then
	-- the next time we get a list of sessions, clear
	-- out the available games list
	ClearAvailableGames = not event.more_results

	-- Limit the number of visible games
	if (table.getn(AvailableGames) >= MAX_VISIBLE_SESSIONS) then
		return
	end

	if event.sessions then
		for i, session in ipairs(event.sessions) do
			session.ranked = false
			table.insert(AvailableGames, session)
		end
	end
	
	if (SIMULATE_REAL_LOAD) then
		for i = 1, 50 do
			local fake_name = PGLobby_Create_Random_Game_Name()
			local fake_session = {}
			fake_session.name = fake_name
			fake_session.fake = true
			fake_session.version_string = "FAKE"
			fake_session.public_open = 99
			fake_session.public_filled = 0
			fake_session.player_count = 0
			fake_session.max_players = 99
			table.insert(AvailableGames, fake_session)
		end
	end

	if InvitationAccepted then

		PGLobby_Hide_Modal_Message()

		if event.invited then

			Set_Finished_Invitation()
			if (table.getn(AvailableGames) <= 0) then
				PGLobby_Display_Modal_Message("TEXT_GAME_INVITE_JOIN_FAILED")
				return
			end

			CMCommon_Set_Currently_Selected_Session(AvailableGames[1])

			CurrentlySelectedSession.SessionOpen = true
			Received_Game_Settings = false
			CMCommon_Set_Join_State(JOIN_STATE_GUEST)

			-- The actual state change does not occur here.  If the join
			-- is successful, then the state change will occur when the 
			-- join operation completes and we're in the game.
			local result = CMCommon_Attempt_Join_Game()
			if (result) then
				-- The join is successful...hide the Go button so it doesn't get mashed.
				Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Enable(false)
			end
		end
		
	elseif QuickMatchRequested then
	
		End_Quickmatching_State()

		if (table.getn(AvailableGames) <= 0) then
			QuickMatchFailed = true
			-- Ask the user if they want to retry.  If the user chooses retry, we're telling the modal message to STAY
			-- modal because we're going to put up another one and we don't want any input going through to the parent scene.
			PGLobby_Display_Custom_Modal_Message("TEXT_GAME_NOT_FOUND", "TEXT_BUTTON_CANCEL", "", "TEXT_RETRY", "TEXT_RETRY")
			return
		end

		local result = false
		for i, session in ipairs(AvailableGames) do

			CMCommon_Set_Currently_Selected_Session(session)

			Received_Game_Settings = false
			CMCommon_Set_Join_State(JOIN_STATE_GUEST)
	
			-- The actual state change does not occur here.  If the join
			-- is successful, then the state change will occur when the 
			-- join operation completes and we're in the game.
			result = CMCommon_Attempt_Join_Game(true)
			if (result) then
				-- The join is successful...hide the Go button so it doesn't get mashed.
				Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Join_Game.Enable(false)
			end

		end

		if not result then
			QuickMatchFailed = true
			-- Ask the user if they want to retry.  If the user chooses retry, we're telling the modal message to STAY
			-- modal because we're going to put up another one and we don't want any input going through to the parent scene.
			PGLobby_Display_Custom_Modal_Message("TEXT_GAME_NOT_FOUND", "TEXT_BUTTON_CANCEL", "", "TEXT_RETRY", "TEXT_RETRY")
			return
		end
		
	else
		CMCommon_Update_Available_Sessions_View()
		CMCommon_Refresh_UI()
	end

end

-------------------------------------------------------------------------------
-- Central message processor.
-- All the NMP_* functions are called from here.
-------------------------------------------------------------------------------
function CMCommon_Network_On_Message(event)

	-- If we're in a game, ignore all messages.
	if (GameHasStarted) then
		return
	end

	local clear_accepts = false
	local client = Network_Get_Client(event.common_addr)
	if (client == nil) then
		DebugMessage("LUA_LOBBY: ERROR: Recieved a message from an unknown client at address: " .. tostring(event.common_addr))
		return
	end
	
	--DebugMessage("JOE DBG::::::  Recieved a message!! : " .. tostring(event.message_type))
		
	local message_processor = NetworkMessageProcessors[event.message_type]
	if (message_processor == nil) then
		DebugMessage("LUA_LOBBY:  WARNING: No network message processor registered for event: " .. tostring(event.message_type))
		return
	else
		local result = message_processor(event, client)
		if (result) then
			clear_accepts = true
		end
	end
	
	if (clear_accepts and HostingGame) then
		Set_All_Client_Accepts(false)
	end

	-- If we are a guest joining there can sometimes be a LARGE lag between joining and getting everybody's data, so we've
	-- put up a message that needs to be hidden once we have everything.
	if (JoinPhase == JOIN_PHASE_GATHERING_DATA) then
		
		local client_data_valid = PGLobby_Validate_Local_Session_Data(PGLOBBY_VALIDATE_CLIENTS_ONLY)
		if (client_data_valid) then
			CMCommon_Set_Join_Phase(JOIN_PHASE_IDLE)
			PGLobby_Hide_Modal_Message()
			CMCommon_Update_Player_List()
		end
		
	end
	
	Refresh_Start_Conditions_View()
	CMCommon_Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Internet_On_Lobby_Init()
	DebugMessage("LUA_LOBBY:  Internet_On_Lobby_Init -- status: " .. tostring(event.status))
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function CMCommon_On_Enumerate_Achievements(event)

	if (not JoinedGame) then
		DebugMessage("LUA_LOBBY: Received achievement enumeration while not in a session.  Ignoring...")
		return
	end

	-- We shouldn't get this callback without an address set so we know whose data we're getting.
	local client = Network_Get_Client(event.common_addr)
	if (client == nil) then 
		DebugMessage("LUA_LOBBY: Received achievement enumeration for a client not joined to this session.  Ignoring...")
		return
	end
		
	if (not ENABLE_ACHIEVEMENT_VERIFICATION) then
		return
	end

	if (event.type == NETWORK_EVENT_TASK_COMPLETE) then
	
		if (JoinedGame) then
			local label = client.name
			if (label == nil) then
				label = client.common_addr
			end
			DebugMessage("LUA_LOBBY: COMPLETE---------------> Recieve profile achievements for: " .. tostring(label))
			ProfileAchievements[client.common_addr] = event.achievements
		end
		
	end
	
	CMCommon_Refresh_UI()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_On_Query_Medals_Progress_Stats(event)

	--[[ JOE DELETE:  We may or may not need this.
	-- We shouldn't get this callback without an address set so we know whose data we're getting.
	local dao = PGLobby_Get_Request_Queue_DAO()
	if (dao == nil) then 
		DebugMessage("LUA_LOBBY: ERROR: Received Medals_Progress stats reply with no query apparently made.")
		return
	end
	PGLobby_Unlock_Request_System()
		
	if (not ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then
		return
	end

	if (event.type == NETWORK_EVENT_TASK_COMPLETE) then
	
		if (JoinedGame) then
			local name = Network_Get_Client(dao.mutex).name
			DebugMessage("LUA_LOBBY: COMPLETE---------------> Recieve achievement stats for: " .. tostring(name))
			GameScriptData.achievement_stats[dao.mutex] = event.stats
			-- JOE DELETE: PGLobby_Hide_Modal_Message()
		end
		
	end
	
	CMCommon_Refresh_UI()--]]

end	

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function CMCommon_Network_On_Live_Connection_Changed(event)

	-- If we're in a game, let the game logic handle the disaster.  We will respond here
	-- when the menu system is reawakened.
	if (GameHasStarted) then
		return
	end
	
	DebugMessage("LUA_LOBBY: Live connection changed: " .. tostring(event.connection_change_id))
	
	-- If we are in an internet session and any of the following are true, we
	-- need to dump to the main menu ASAP.
	if ((event.connection_change_id == XONLINE_S_LOGON_DISCONNECTED) or
		(event.connection_change_id == XONLINE_E_LOGON_NO_NETWORK_CONNECTION) or
		(event.connection_change_id == XONLINE_E_LOGON_CANNOT_ACCESS_SERVICE) or 
		(event.connection_change_id == XONLINE_E_LOGON_UPDATE_REQUIRED) or
		(event.connection_change_id == XONLINE_E_LOGON_SERVERS_TOO_BUSY) or
		(event.connection_change_id == XONLINE_E_LOGON_CONNECTION_LOST) or
		(event.connection_change_id == XONLINE_E_LOGON_KICKED_BY_DUPLICATE_LOGON) or
		(event.connection_change_id == XONLINE_E_LOGON_INVALID_USER)) then
	
		if (NetworkState == NETWORK_STATE_INTERNET) then
			DebugMessage("LUA_LOBBY: Live connection has become unrecoverable.  Quitting to main menu.")
			-- 10/09/2007 JLH
			-- There is a bug in XLIVE where it is possible to cause a thread lock when deleting a session
			-- too soon after a signout.  Microsoft's recommended workaround is to delay the session
			-- deletion.
			PGCrontab_Schedule(Leave_Game, 0, 2)
			PGCrontab_Schedule(Close_Dialog, 0, 3)
		end
		
	end

	-- On Xbox, silver players cannot play multiplayer games
	if Is_Xbox() and Net.Requires_Locator_Service() then
		PGCrontab_Schedule(Leave_Game, 0, 2)
		PGCrontab_Schedule(Close_Dialog, 0, 3)
	end
	
	-- If we're in a LAN situation, just update the local player name so it doesn't show the gamertag.
	if (NetworkState == NETWORK_STATE_LAN) then
		LocalClient.name = nil
		CMCommon_Update_Local_Client()
		if (ViewState == VIEW_STATE_GAME_STAGING) then
			CMCommon_Update_Player_List()
		end
	end
					
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function CMCommon_Network_On_Locator_Server_Count(event)

	local value = Get_Localized_Formatted_Number(event.value)
	
	-- JOE L10N:  TEXT_MULTIPLAYER_SERVERS_AVAILABLE
	local message = Get_Game_Text("TEXT_MULTIPLAYER_SERVERS_AVAILABLE")
	message = Replace_Token(message, value, 1)
	Live_Profile_Game_Dialog.Panel_Custom_Lobby.Text_Server_Count.Set_Text(message) 

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- N E T W O R K I N G   M E S S A G E   P R O C E S S O R S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- ALL player settings at once.
-------------------------------------------------------------------------------
function NMP_Player_Settings(event, client)

	local dao = event.message

	client.platform = dao.platform
	client.name = dao.name
	client.faction = tonumber(dao.faction)
	client.team = tonumber(dao.team)
	client.color = tonumber(dao.color)
	if ((NetworkState == NETWORK_STATE_INTERNET) and (dao.applied_medals ~= nil)) then
		client.applied_medals = dao.applied_medals
	end
	-- Don't muck with NAT type yet because we need to check it's current setting later.
	
	DebugMessage("LUA_LOBBY: Received user settings for player '" .. tostring(client.name) .. "'")

	-- Now we have this player's name, we can report it into the chat window.
	if (JoinNotificationStore[event.common_addr] ~= nil) then
		JoinNotificationStore[event.common_addr] = nil
		local wstr_joined = Get_Game_Text("TEXT_PLAYER_JOINED_STRING")
		Replace_Token(wstr_joined, client.name, 0)
		Report_System_Event(wstr_joined, SYSTEM_CHAT_COLOR)
	end

	-- Set up this player's seat color.
	local seat = Network_Get_Seat(client)
	PGMO_Set_Seat_Color(seat, client.color)
	
	-- Handle NAT type
	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		-- If this client's NAT type has changed, we want to place a message into the chat log.
		local nat_type = dao.nat_type
		if (nat_type == nil) then
			DebugMessage("LUA_LOBBY: ERROR: No NAT type from player: " .. tostring(client.name))
		elseif (nat_type ~= client.nat_type) then
			client.nat_type = nat_type
			local nat_is_ok, message = PGLobby_Validate_NAT_Type(client)
			if (not nat_is_ok) then
				local chat_message = Create_Wide_String("")
				chat_message = chat_message.append(WIDE_OPEN_BRACE).append(message).append(WIDE_CLOSE_BRACE)
				Report_System_Event(chat_message, SYSTEM_CHAT_COLOR)
			end
		end
		
	end
	
	Refresh_Staging_Map_Overlay()
	Refresh_Start_Conditions_View()	-- Make sure this guy's medals are still valid.
	CMCommon_Update_Player_List()
	
	return true
		
end

-------------------------------------------------------------------------------
-- All game settings at once.
-------------------------------------------------------------------------------
function NMP_All_Game_Settings(event, client)

	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		DebugMessage("LUA_LOBBY::  Game settings change request from someone other than the host!")
		-- JOE L10N
		--Append_To_Chat_Window("[SPOOF WARNING:  Player '" .. tostring(client.name) .. "' attempted to change the settings of an AI player on behalf of the host.]", SYSTEM_CHAT_COLOR)
		return false
	end
	
	if (HostingGame) then
		return
	end
	
	local dao = event.message
	
	GameOptions.seed = dao.seed
	DebugMessage("LUA_LOBBY: Host seed for this session: " .. tostring(GameOptions.seed))
	
	-- Update general flags and settings
	Update_New_Game_Script_Data(dao.game_script_data)
	
	-- Process AI players.
	for common_addr, ai_player in pairs(dao.ai_players) do
		ClientTable[common_addr] = ai_player
	end
	
	-- Process seat assignments.
	for _, triple in ipairs(dao.seat_assignments) do
		Network_Do_Seat_Assignment(triple)
	end
	
	-- Process start positions.
	for common_addr, duple in pairs(dao.start_positions) do
		CMCommon_Do_Guest_Assign_Start_Position(duple)
	end

	Refresh_Staging_Map_Overlay()
	CMCommon_Update_Player_List()

	return true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Platform(event, client)
	client.platform = event.message
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Name(event, client)

	local name = event.message

	-- Now we have this player's name, we can report it into the chat window.
	if (JoinNotificationStore[event.common_addr] ~= nil) then
		JoinNotificationStore[event.common_addr] = nil
		local wstr_joined = Get_Game_Text("TEXT_PLAYER_JOINED_STRING")
		Replace_Token(wstr_joined, name, 0)
		Report_System_Event(wstr_joined, SYSTEM_CHAT_COLOR)
	end

	client.name = name
	CMCommon_Update_Player_List()
	
	return true
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Faction(event, client)

	local faction = event.message
   	client.faction = tonumber(faction)
	DebugMessage("LUA_NET: I have player " .. tostring(client.name) .. " as faction " .. tostring(client.faction).. "\n")
	CMCommon_Update_Player_List()
	Refresh_Start_Conditions_View()	-- Make sure this guy's medals are still valid.
	return true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Team(event, client)

	client.team = tonumber(event.message)
	CMCommon_Update_Player_List()
	return true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Color(event, client)
	client.color = tonumber(event.message)

	local seat = Network_Get_Seat(client)
	PGMO_Set_Seat_Color(seat, client.color)

	CMCommon_Update_Player_List()
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Seat_Assignment(event, client)

	-- If we're the host, we've already updated our seat assignment, don't
	-- let a network message clobber that.
	if (HostingGame) then
		return false
	end

	-- Ignore these if they're not from the host.
	if (event.common_addr == CurrentlyJoinedSession.common_addr) then
		Network_Do_Seat_Assignment(event.message)
		CMCommon_Update_Player_List()
	end

	return true
	
end

-------------------------------------------------------------------------------
-- HOST ONLY: When a player requests a start position, only the host can vet
-- it.
-------------------------------------------------------------------------------
function NMP_Player_Req_Start_Pos(event, client)

	-- Only the host processes this message
	if (not HostingGame) then
		return false
	end
	
	local start_marker_id = event.message
	
	-- Is the start marker free?
	local is_free = CMCommon_Is_Start_Marker_Free(start_marker_id)
	
	if (not is_free) then
		DebugMessage("LUA_LOBBY: A guest requested a start position which is already taken.")
		return false
	end
	
	seat = Network_Get_Seat(client)
	PGMO_Assign_Start_Position(start_marker_id, seat, client.color)
	client.start_marker_id = start_marker_id
	
	Network_Assign_Start_Position(client, start_marker_id)
	
	return false

end

-------------------------------------------------------------------------------
-- GUEST ONLY:  When the host sends out a start position assignment, only
-- guests process it because the host will already have updated their local
-- store.
-------------------------------------------------------------------------------
function NMP_Player_Assign_Start_Pos(event, client)

	-- Only guests process this message
	if (HostingGame) then
		return true
	end
	
	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		return true
	end
	
	local duple = event.message
	CMCommon_Do_Guest_Assign_Start_Position(duple)
	Refresh_Staging_Map_Overlay()
	
	return true
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Clear_Start_Pos(event, client)

	-- If the request is not coming from the person for whom the clear is intended or the host, complain.
	local duple = event.message
	
	if ((duple.client_addr ~= client.common_addr) and (client.common_addr ~= CurrentlyJoinedSession.common_addr)) then
	
		local victim_name = Get_Game_Text("TEXT_UNKNOWN") 
		if ((duple ~= nil) and
			(duple.client_addr ~= nil)) then
			local victim_client = Network_Get_Client(duple.client_addr)
			-- If the client specified has disconnected from the session, then the host is just clearing
			-- the start position on their behalf.  This isn't a spoof.
			if (victim_client == nil) then
				-- Host is clearing on behalf of a disconnector.
				victim_name = nil
			else
				victim_name = victim_client.name
			end
		end
		
		-- Only report a spoof if this isn't the host clearing on behalf of a disconnector.
		if (victim_name ~= nil) then
			local message = Get_Game_Text("TEXT_MULTIPLAYER_SPOOF_WARNING_START_POSITION_CLEAR")
			ReplaceToken(message, client.name, 1)
			ReplaceToken(message, victim_name, 1)
			Report_System_Event(message, SYSTEM_CHAT_COLOR)
			return false
		end
		
	end
	
	local target_client = Network_Get_Client(duple.client_addr)
	
	-- If the target is not in the client table, they have disconnected.
	if (target_client ~= nil) then
		target_client.start_marker_id = nil
		DebugMessage("LUA_LOBBY: Clearing start position '" .. tostring(duple.start_marker_id) .. "' for player '" .. tostring(target_client.name) .. "'")
	else
		DebugMessage("LUA_LOBBY: Host is clearing start position '" .. tostring(duple.start_marker_id) .. "' on behalf of a disconnecter.")
	end
	
	Refresh_Staging_Map_Overlay()
	
	return true

end

-------------------------------------------------------------------------------
-- The host has performed an action that requires everybody to clear all start
-- positions (such as change the map).
-------------------------------------------------------------------------------
function NMP_Host_Clear_Start_Pos(event, client)

	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		DebugMessage("LUA_LOBBY::  Clear start positions from someone other than the host!")
		Report_System_Event("[SPOOF WARNING:  Player '" .. tostring(client.name) .. "' attempted to clear all start positions on behalf of the host.]", SYSTEM_CHAT_COLOR)
		return false
	end
	
	if (HostingGame) then
		return true
	end
	
	PGNetwork_Clear_Start_Positions()
	PGMO_Clear_Start_Positions() 
	return true
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Accepts(event, client)

	-- Host accepts on behalf of all AIs -- always TRUE.
	if (event.common_addr == CurrentlyJoinedSession.common_addr) then
		Set_All_AI_Accepts(true)
	end
	
	-- Determine who is accepting and attempt to validate.  If this message is not 
	-- from the person accepting or the host, it could be a spoof attempt.
	local addr = event.message
	local accepting_client = Network_Get_Client(addr)
	
	if (accepting_client == nil) then
		-- It's possible the accept is for an AI client we haven't received yet.  That's fine...
		return false
	end
	
	if ((addr ~= client.common_addr) and (event.common_addr ~= CurrentlyJoinedSession.common_addr)) then
		Report_System_Event("[SPOOF WARNING:  Player '" .. tostring(client.name) .. "' attempted to accept game settings on behalf of '" .. tostring(accepting_client.name) .. "'.]", SYSTEM_CHAT_COLOR)
		return false
	end

	accepting_client.AcceptsGameSettings = true
	CMCommon_Update_Player_List()
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Declines(event, client)

	-- Host declines on behalf of all AIs -- always TRUE.
	if (event.common_addr == CurrentlyJoinedSession.common_addr) then
		Set_All_AI_Accepts(true)
	end
	
	-- Determine who is declining and attempt to validate.  If this message is not 
	-- from the person declining or the host, it could be a spoof attempt.
	local addr = event.message
	local declining_client = Network_Get_Client(addr)
	
	if (declining_client == nil) then
		-- It's possible the accept is for an AI client we haven't received yet.  That's fine...
		return false
	end
	
	if ((addr ~= client.common_addr) and (event.common_addr ~= CurrentlyJoinedSession.common_addr)) then
		Report_System_Event("[SPOOF WARNING:  Player '" .. tostring(client.name) .. "' attempted to decline game settings on behalf of '" .. tostring(declining_client.name) .. "'.]", SYSTEM_CHAT_COLOR)
		return false
	end

	-- The host is *ALWAYS* considered "accepting".
	if (addr == CurrentlyJoinedSession.common_addr) then
		declining_client.AcceptsGameSettings = true
	else
		declining_client.AcceptsGameSettings = false
	end
	
	if (not HostingGame) then
		Enable_Settings_Accept_UI(true)
	end

	CMCommon_Update_Player_List()
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_AI_Player_Details(event, client)

	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		DebugMessage("LUA_LOBBY::  AI player change request from someone other than the host!")
		Report_System_Event("[SPOOF WARNING:  Player '" .. tostring(client.name) .. "' attempted to change the settings of an AI player on behalf of the host.]", SYSTEM_CHAT_COLOR)
		return false
	end
	
	-- Host has already registered AI players.
	if (HostingGame) then
		return true
	end
	
	local ai_player = event.message
	ClientTable[ai_player.common_addr] = ai_player
	local seat = Network_Get_Seat(ai_player)
	PGMO_Set_Seat_Color(seat, ai_player.color)
	CMCommon_Update_Player_List()
	return true
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Game_Start_Countdown(event, client)

	local dao = event.message
	Set_Game_Is_Starting(true)
	
	-- ** HOST OVERRIDES **
	-- These messages may contain data that the host wants to make sure is in sync between all clients,
	-- even if that means overwriting what a guest sees as the state of things.  This will avoid
	-- out-of-syncs and make bugs more noticeable in the lobby.
	if ((not HostingGame) and (dao.host_override_settings ~= nil)) then
	
		-- Start positions
		local start_positions = dao.host_override_settings.start_positions
		if (start_positions ~= nil) then
			CMCommon_Process_Host_Start_Position_Override(start_positions)
		end

	end 


	-- ** COUNTDOWN TICK **
	local count_num = tonumber(dao.tick_value)
	local count_wstr = Get_Localized_Formatted_Number(count_num)
	
	local countdown_label = Get_Game_Text("TEXT_MULTIPLAYER_MATCH_BEGINS_IN").append(": ").append(count_wstr)
	CMCommon_Set_Staging_System_Message(countdown_label)
	
	-- If the countdown is at zero, START THE GAME!!
	if (count_num == 0) then

		if HostingGame == true and GameOptions.ranked and HostStatsRegistrationComplete == false then
			CMCommon_Kill_Game_Countdown()
			Broadcast_Game_Kill_Countdown()
			DebugMessage("LUA_LOBBY: ERROR: Killed the countdown because stats registration failed.")
		else
			-- Start the game
			CMCommon_Set_Staging_System_Message(Get_Game_Text("TEXT_MULTIPLAYER_START_EXCLAIM"))
			--[[ NADER DELETE: Obsolete
			PGLobby_Request_All_Required_Backend_Data()
			]]
			if (HostingGame) then
				Network_Broadcast_Start_Game_Signal()
			end
		end
		
	else
		
		-- We're not at 0 ... just go bleep.
		Play_SFX_Event("GUI_Timer")

	end

	CMCommon_Update_Player_List()
	
	return false

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Game_Kill_Countdown(event, client)

	Set_Game_Is_Starting(false)
	CMCommon_Set_Staging_System_Message(Get_Game_Text("TEXT_WAITING"))
		
	Report_System_Event(Get_Game_Text("TEXT_MESSAGE_COUNTDOWN_CANCELLED"), SYSTEM_CHAT_COLOR)
	if (HostingGame) then
		PGLobby_Set_Local_Session_Open(true)	-- Open the session for others to join again.
		PGLobby_Post_Hosted_Session_Data()
	else
		Play_SFX_Event("GUI_Main_Menu_Back_Select")
	end

	CMCommon_Update_Player_List()
	
	return false
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Start_Game(event, client)

	Set_Game_Is_Starting(false)
	Live_Profile_Game_Dialog.End_Modal()
	
	-- Remove all voice peers who are not on your team.
	local num_human_players = Network_Get_Client_Table_Count(false)
	if (num_human_players > 2) then		-- Enforce team chat in all games with more than 2 human players.
		Network_Prune_Voice_Peers()
	end
	
	-- Convert faction IDs to string constants
	PGLobby_Convert_Faction_IDs_To_Strings()
	
	-- Unfortunately we have a chicken & egg situation here.  Network_On_Start_Game()
	-- requires the GameScriptData be available in the GameScoringManager so certian
	-- in-game UI elements can be initialized.  We also require the player IDs that are
	-- generated by the call to Network_On_Start_Game(), so we have to set the 
	-- GameScriptData twice.
	GameScriptData.GameOptions = GameOptions
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
	  
	Network_On_Start_Game()

	-- Now that the game is started, update the ClientTable with all the newly-assigned
	-- player IDs.
	Update_Clients_With_Player_IDs()
	
	-- Assign start positions
	GameScriptData.start_positions = CMCommon_Build_Game_Start_Positions()
    
	-- Hand off the client table to the game scoring script.
	-- Need to store off the game options
	if (not GameScriptData.medals_enabled) then
		CMCommon_Strip_Applied_Medals(ClientTable)
	end
	Set_Player_Info_Table(ClientTable)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	local ranked = GameOptions.ranked
	if (ranked == nil) then
		ranked = false
	end
	GameScoringManager.Set_Is_Ranked_Game(ranked)
	GameScoringManager.Set_Is_Global_Conquest_Game(false)
	GameScoringManager.Set_Is_Custom_Multiplayer_Game(true)
	GameScoringManager.Set_Is_Disconnect_Detected(false)
	
	-- Chicken & Egg: We must set the GameScriptDataTable again now that all our data
	-- structures are built given the player IDs generated from Network_On_Start_Game().
	if (GameScriptData.medals_enabled) then
		GameScriptData.profile_achievements = ProfileAchievements
	end
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
	
	GameHasStarted = true
	return true
		
end

-------------------------------------------------------------------------------
-- Game Setting:  The host ignores game settings broadcasts
-- (see Refresh_Game_Settings_Model())
-------------------------------------------------------------------------------
function NMP_Game_Settings(event, client)

	if (HostingGame == false) then
		Update_New_Game_Script_Data(event.message)
		Refresh_Game_Settings_View()
	end
	
	return true
	
end
    
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function NMP_Game_Seed(event, client)

	if (HostingGame == false) then
		GameOptions.seed = tonumber(event.message)
		DebugMessage("LUA_LOBBY: Host seed for this session: " .. tostring(GameOptions.seed))
	end
	
	return false
	
end
    
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function NMP_Chat_Message(event, client)

	-- Do nothing on the gamepad version.
	if (Is_Gamepad_Active()) then
		return
	end

	if Net.Is_Gamer_Muted(client.common_addr) then return end

	local name = Get_Game_Text("TEXT_UNKNOWN")
	if (client.name ~= nil) then
		name = client.name
	end
	local color = SYSTEM_CHAT_COLOR
	if (client.color ~= nil) then
		color = tonumber(client.color)
	end

	local chat_line = Create_Wide_String("[")
	chat_line = chat_line.append(name).append("] ").append(event.message)

	Append_To_Chat_Window(chat_line, color)
	
	return false
	
end

-------------------------------------------------------------------------------
-- A player has tried to join the game after it has started.  The host will
-- already have dealt with them, the guest job is just to make sure that player
-- doesn't exist in our client table.  If we're the refused player, just
-- display a modal message and put us back in the lobby.
-------------------------------------------------------------------------------
function NMP_Refuse_Player(event, client)

	local refused_addr = event.message
	
	Network_Remove_Client(refused_addr)
	
	-- If I am the idiot, I quit the session.
	local idiot_addr = event.message
	if (idiot_addr == LocalClient.common_addr) then
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_GAME_IN_PROGRESS"))
		View_Back_Out()		-- View_Back_Out handles leaving the game as well
		return false
	end

	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Kick_Player(event, client)
	
	-- If I am the idiot, I quit the session.
	local idiot_addr = event.message
	if (JoinedGame and (HostingGame == false) and (idiot_addr == LocalClient.common_addr)) then
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_INTERNET_PLAYER_KICKED"))
		View_Back_Out()		-- View_Back_Out handles leaving the game as well
		return false
	end

	-- If the idiot is an AI player, just kill the AI player
	client = Network_Get_Client(idiot_addr)
	if (client ~= nil) then
		if (client.is_ai) then
			Network_Remove_Client(client.common_addr)
		end

		local message = Get_Game_Text("TEXT_MULTIPLAYER_HAS_BEEN_KICKED")
		message = Replace_Token(message, Create_Wide_String(client.name), 1)
		Report_System_Event(message, SYSTEM_CHAT_COLOR)
	end
	
	CMCommon_Update_Player_List()
	
	return true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Kick_AI_Player(event, client)

	local common_addr = event.message
	local ai = AIPlayers[common_addr]

	if (ai ~= nil) then
		local message = Get_Game_Text("TEXT_MULTIPLAYER_AI_HAS_BEEN_KICKED")
		message = Replace_Token(message, Create_Wide_String(ai.name), 1)
		--Append_To_Chat_Window(message, SYSTEM_CHAT_COLOR)
	end
	
	AIPlayers[common_addr] = nil
	Network_Remove_Client(common_addr)
	Update_Selected_Player_View()
	CMCommon_Update_Player_List()
	
	return true
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Kick_Reserved_Player(event, client)

	local common_addr = event.message
	local ai = ReservedPlayers[common_addr]

	ReservedPlayers[common_addr] = nil
	Network_Remove_Client(common_addr)
	Update_Selected_Player_View()
	CMCommon_Update_Player_List()
	
	return true
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Reserved_Player(event, client)

	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		DebugMessage("LUA_LOBBY::  Reserved player change request from someone other than the host!")
		return false
	end
	
	-- Host has already registered AI players.
	if (HostingGame) then
		return true
	end
	
	local reserved_player = event.message
	ReservedPlayers[reserved_player.common_addr] = reserved_player
	CMCommon_Update_Player_List()
	return true
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Applied_Medals(event, client)
	if (NetworkState == NETWORK_STATE_INTERNET) then
		client.applied_medals = event.message
		CMCommon_Update_Player_List()
		Refresh_Start_Conditions_View()	-- Make sure this guy's medals are still valid.
		return true
	end
	return false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_NAT_Type(event, client)

	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		-- If this client's NAT type has changed, we want to place a message into the chat log.
		local nat_type = event.message
		if (nat_type ~= client.nat_type) then
			client.nat_type = nat_type
			local nat_is_ok, message = PGLobby_Validate_NAT_Type(client)
			if (not nat_is_ok) then
				local chat_message = Create_Wide_String("")
				chat_message = chat_message.append(WIDE_OPEN_BRACE).append(message).append(WIDE_CLOSE_BRACE)
				Report_System_Event(chat_message, SYSTEM_CHAT_COLOR)
			end
		end
		return true
		
	end
	
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Rebroadcast_User_Settings(event, client)
	Send_User_Settings()
	return false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Rebroadcast_Game_Settings(event, client)
	if (HostingGame) then
	   Broadcast_Game_Settings() 
	end
	return false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Stats_Registration_Begin(event, client)

	if HostingGame == false then
		DebugMessage("LUA_LOBBY: Client -- Network_Begin_Stats_Registration.")
		-- JOE DELETE:: Network_Begin_Stats_Registration(event.message)
		PGLobby_Request_Stats_Registration(event.message)
	else
		Network_Broadcast(MESSAGE_TYPE_STATS_CLIENT_REGISTERED, "")
	end
	
	return false

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Stats_Client_Registered(event, client)

	DebugMessage("LUA_LOBBY: Client [%s] -- client.StatsRegistered = true.", tostring(client.name))
	client.StatsRegistered = true

	if HostingGame and Check_Stats_Registration_Status() == true and HostStatsRegistration == false then
		DebugMessage("LUA_LOBBY: Host -- Network_Begin_Stats_Registration")
		HostStatsRegistration = true
		-- JOE DELETE:: Network_Begin_Stats_Registration("0")
		PGLobby_Request_Stats_Registration("0")
	end
	
	return false

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Host_Recommended_Settings(event, client)

	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		DebugMessage("LUA_LOBBY::  Recommended settings request from someone other than the host!")
		Report_System_Event("[SPOOF WARNING:  Player '" .. tostring(client.name) .. "' attempted to recommend player settings on behalf of the host.]", SYSTEM_CHAT_COLOR)
		return false
	end
	
	local dao = event.message
		
	if (HostingGame) then
	
		-- Host manages the AI players.
		local target_client = Network_Get_Client(dao.common_addr)
		if (not target_client.is_ai) then
			return false
		end
		
		target_client.team = dao.team
		--target_client.color = dao.color
		Network_Edit_AI_Player(client)
		Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, client)
		
	else
	
		-- Is this message for us?
		if (dao.common_addr ~= LocalClient.common_addr) then
			return false
		end
		
		-- We're a guest, so just take the host's recommendation.
		LocalClient.team = dao.team
		
		-- The host has sent us all the unused colors.  Look for our preferred one first,
		-- otherwise just pick one.  If there are no free colors (shouldn't happen),
		-- just use our preferred.
		local preferred_color = PGLobby_Get_Preferred_Color()
		local color = preferred_color
		for _, available_color in pairs(dao.colors) do
			color = available_color
			if (color == preferred_color) then
				break
			end
		end
		
		--[[if (dao.colors[color] == nil) then
			-- Someone is using our beloved color.
			color = table.remove(dao.colors) 
			if (color == nil) then
				-- All colors are taken?
				DebugMessage("LUA_LOBBY::  WARNING: Host says all colors are taken??")
				color = PGLobby_Get_Preferred_Color()
			end
		end--]]
		LocalClient.color = color
		
		Update_Selected_Player_View()
		Send_User_Settings()
	
	end
	
	CMCommon_Update_Player_List()
	
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Heartbeat(event, client)

	local dao = event.message
	if ((dao == nil) or (dao.common_addr == nil) or (dao.client_count == nil)) then
		PGLobbyBadClientList = nil
		return false
	end
	
	-- Record the host's view of it.
	if (HostingGame) then
		PGLobbyLastHostHeartbeat = Network_Get_Client_Table_Count()
	elseif (event.common_addr == CurrentlyJoinedSession.common_addr) then
		PGLobbyLastHostHeartbeat = dao.client_count
	end
	
	-- If we don't have the host's count yet, no point in continuing.
	if (PGLobbyLastHostHeartbeat == nil) then
		PGLobbyBadClientList = nil
		return false
	end
	
	-- If all the information is in place, we can finally perform the actual validation.
	if (PGLobbyBadClientList == nil) then
		PGLobbyBadClientList = {}
	end
	 
	if (dao.client_count ~= PGLobbyLastHostHeartbeat) then
		PGLobbyBadClientList[client.common_addr] = true
	else
		PGLobbyBadClientList[client.common_addr] = false
	end
	
	CMCommon_Update_Player_List()
	
	-- Lastly, if we are missing any player, server or game data, request rebroadcast.
	PGLobby_Validate_Local_Session_Data(nil, true)
	
	Refresh_Staging_Map_Overlay()
	
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Update_Session(event, client)
	
	-- The host does not need to proccess this because the host has processed it
	-- before sending the message.
	if (HostingGame) then return end

	local session = event.message
	if (session == nil) then return end

	if (Is_Gamepad_Active()) then
	
		CurrentlyJoinedSession = session
		
	else
	
		-- If the client joined through player match, the use_locator flag will not be set
		-- even if the host has use_locator. We need to preserve this flag for the client,
		-- so save off the current flag and set it with the new session info map
		local is_using_locator = CurrentlyJoinedSession.use_locator
		CurrentlyJoinedSession = session
		CurrentlyJoinedSession.use_locator = is_using_locator
	
	end

	Network_Update_Session(CurrentlyJoinedSession)

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- This function should be called to actually join a game.
-------------------------------------------------------------------------------
function CMCommon_Attempt_Join_Game(dont_display_message)

	DebugMessage("LUA_NET: Join button clicked.  JoinGame = " .. tostring(JoinedGame))

	ClientTable = {}
	ProfileAchievements = {}
	MapValidityLookup = {}
	CMCommon_Reset_Local_Client()
	CMCommon_Update_Local_Client()
	PGMO_Clear()

	-- Validate
	if (CurrentlySelectedSession == nil) then
		MessageBox(Get_Game_Text("TEXT_NO_SESSIONS_SELECTED"))
		return false
	end
	
	CurrentlyJoinedSession = CurrentlySelectedSession
	CMCommon_Set_Currently_Selected_Session(nil)
	
	-- Attempt to join
	DebugMessage("LUA_NET: Found a game.  Checking version...")
	
	-- Only join games with an identical version and build details
	local is_joinable, version_matches, is_open = PGLobby_Is_Game_Joinable(CurrentlyJoinedSession)
	if (is_joinable) then
	
		-- At this point, we have a joinable game, but we cannot immediately join it
		-- because the networking system might be busy doing a Find_All_Sessions.
		-- Instead we stop session polling and schedule the join for 1 second in the future.
		CMCommon_Stop_Available_Session_Polling()
		DebugMessage("LUA_NET: Version check successful.  Calling LAN_Join...")
		PGCrontab_Schedule(_CMCommon_Do_Join_Game, 0, 1)
		
	elseif not version_matches then
	
		if (dont_display_message == nil) or (dont_display_message == false) then
			local msg = Get_Game_Text("TEXT_VERSION_MISMATCH_DETAILED")
			Replace_Token(msg, LocalVersionString, 1)
			Replace_Token(msg, CurrentlyJoinedSession.version_string, 2)
			PGLobby_Display_Modal_Message(msg)
		end
		return false

	elseif not is_open then
	
		if (dont_display_message == nil) or (dont_display_message == false) then
			PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_GAME_IN_PROGRESS"))
		end
		return false
		
	end
	
	return true

end

-------------------------------------------------------------------------------
-- This function should ONLY be called by CMCommon_Attempt_Join_Game() when it
-- determines the CurrentlyJoinedSession is valid and has stopped polling
-- for available games.
-------------------------------------------------------------------------------
function _CMCommon_Do_Join_Game()

	local session = CurrentlyJoinedSession
	
	--[[JOE TODO:  Uncomment this if required.
	-- We want to check after a certain amount of time to see if the join attempt succeeded.
	GuestJoinVerifyID = GuestJoinVerifyID + 1
	PGCrontab_Schedule(CMCommon_Verify_Guest_Join_Attempt, 0, AVAILABLE_SESSIONS_REFRESH_PERIOD, 1)
	--]]
	
	JoinedGame = false
	HostingGame = false
	ClientTable = {}
	Network_Reset_Seat_Assignments()
	if (session ~= nil) then
		DebugMessage("LUA_LOBBY: Joining session with address: " .. tostring(session.common_addr))
		Network_Join_Game(session)
	end
	
end

-------------------------------------------------------------------------------
-- If this function is called 
-------------------------------------------------------------------------------
function CMCommon_Verify_Guest_Join_Attempt()

	-- Every join attempt bumps up this counter.  Because this is a scheduled function, we are not
	-- interested in responding to scheduled checks that the user has cancelled.
	--[[JOE TODO:  Uncomment this if required.
	GuestJoinVerifyID = GuestJoinVerifyID - 1
	if (GuestJoinVerifyID <= 0) then
		GuestJoinVerifyID = 0
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_MULTIPLAYER_GAME_IN_PROGRESS"), false)
	end--]]
	
end

-------------------------------------------------------------------------------
-- If the host has specified an AI players, they will be added after we
-- recieve the host joined notification.
-------------------------------------------------------------------------------
function CMCommon_Do_Host_Game()

	if (JoinState == JOIN_STATE_GUEST) then
		return
	end

	ClientTable = {}
	ProfileAchievements = {}
	MapValidityLookup = {}
	PGMO_Clear()
	Network_Reset_Seat_Assignments()
	CMCommon_Reset_Local_Client()
	CMCommon_Update_Local_Client()
	Update_Selected_Player_View()
	ValidMapSelection = true
	local game_name = LocalClient.name
	
	if ((tostring(game_name) == nil) or (tostring(game_name) == "")) then
		DebugMessage("LIVE_PROFILE_GAME_DIALOG: Unable to determine local player name.  Cannot host.")
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_CANNOT_HOST_PLAYER_NAME"))
		return
	end

	CMCommon_Set_Join_Phase(JOIN_PHASE_ATTEMPTING)
		
	JoinedGame = false
	HostingGame = false

	local session_data = {}
	session_data.name = game_name
	session_data.ranked = GameOptions.ranked
	session_data.map_crc = GameOptions.map_crc
	session_data.gold_only = GameOptions.gold_only				-- Will be utterly ignored in the gamepad build.
	session_data.private_game = GameOptions.private_game
	
	GameOptions.seed = GameRandom.Free_Random(RANDOM_MIN, RANDOM_MAX)
	DebugMessage("LUA_LOBBY: Generating new host seed: " .. tostring(GameOptions.seed))

	-- For lan games, we need to keep track of the player count ourselves.
	-- We start off with only one player, the host.
	if (NetworkState == NETWORKS_STATE_LAN) then
		session_data.player_count = 1
	end

	Network_Calculate_Initial_Max_Player_Count()
	session_data.max_players = MaxPlayerCount
	
	if ((MatchingState == MATCHING_STATE_LIST_PLAY) or
		Net.Requires_Locator_Service()) then
		-- JOE DELETE:: Obsolete:  (not IsGoldOnly)) then
		
		session_data.use_locator = true
		
	else
	
		session_data.use_locator = false
		
	end
	
	AllowGameCountdown = true
	PGLobby_Create_Session(session_data)
	
	if (Is_Gamepad_Active()) then
		this.Panel_Game_Staging.Player_Cluster_1.Set_Focus_First()
	end

end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Reset_Local_Client()

	-- Start position
	LocalClient.start_marker_id = nil
	
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Update_Local_Client(send_settings)

	-- By default we *DO* want to broadcast our settings
	if (send_settings == nil) then
		send_settings = true
	end
	
	-- Common Address
	Network_Update_Local_Common_Addr(Net.Get_Local_Addr())
	
	-- Platform
	if (Is_Xbox()) then
		LocalClient.platform = PLATFORM_360
	else
		LocalClient.platform = PLATFORM_PC
	end
	
	-- Name
	if (LocalClient.name == nil) then
		LocalClient.name = Network_Get_Local_Username()		-- Will never return nil.
	end
	
	-- Faction
	if (LocalClient.faction == nil) then
		LocalClient.faction = CMCommon_Get_Preferred_Faction()
	end
	
	-- Team
	if (LocalClient.team == nil) then
		LocalClient.team = CMCommon_Get_Preferred_Team()
	end

	-- Color
	if (LocalClient.color == nil) then
		LocalClient.color = PGLobby_Get_Preferred_Color()
	end
	
	-- Medals
	if (NetworkState == NETWORK_STATE_INTERNET) then
		LocalClient.applied_medals = Get_Locally_Applied_Medals(LocalClient.faction)
	else
		LocalClient.applied_medals = nil
	end
	
	-- Accepts
	if (LocalClient.AcceptsGameSettings == nil) then
		LocalClient.AcceptsGameSettings = false
	end
	if (HostingGame) then
		LocalClient.AcceptsGameSettings = true
	end
	
	-- NAT Type
	if (NetworkState == NETWORK_STATE_INTERNET) then
		LocalClient.nat_type = Net.Get_NAT_Type()
	end
	
	if (JoinedGame and send_settings) then
		Send_User_Settings()
	end

	DebugMessage("LOCAL_CLIENT:  Name: " .. tostring(LocalClient.name))
	DebugMessage("LOCAL_CLIENT:  Common Address: " .. tostring(LocalClient.common_addr))
	DebugMessage("LOCAL_CLIENT:  Player_ID: " .. tostring(LocalClient.PlayerID))
	DebugMessage("LOCAL_CLIENT:  Faction: " .. tostring(LocalClient.faction))
	DebugMessage("LOCAL_CLIENT:  Team: " .. tostring(LocalClient.team))
	DebugMessage("LOCAL_CLIENT:  Color: " .. tostring(LocalClient.color))
	--DebugMessage("LOCAL_CLIENT:  # of Offline Achievements: " .. tostring(#LocalClient.TotalOfflineAchievements))
	--DebugMessage("LOCAL_CLIENT:  # of Online Achievements: " .. tostring(#LocalClient.TotalOnlineAchievements))

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Leave_Game(clear_session_selection)

	DebugMessage("LUA_LOBBY:  Leaving the game...")
	Network_Leave_Game()
	if (HostingGame) then
		DebugMessage("LUA_LOBBY:  Host, so broadcasting host DC and stopping session...")
		Broadcast_Host_Disconnected()
		Network_Stop_Session()
	end
	
	if (clear_session_selection == nil) then
		clear_session_selection = false
	end
	if (clear_session_selection) then
		CMCommon_Set_Currently_Selected_Session()
	end
	
	JoinedGame = false
	HostingGame = false
	Set_Game_Is_Starting(false)
	StartGameCountdown = -1
	CurrentlyJoinedSession = nil
	JoinNotificationStore = {}
	PGLobbyBadClientList = {}
	ClientTable = {}
	Network_Clear_All_Clients()
		
	PGMO_Clear()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Initialize_Game_Hosting()

	if (JoinState ~= JOIN_STATE_HOST) then
		return
	end
	
	Refresh_Game_Settings_Model(true)
	Refresh_Game_Settings_View()
	
	-- Kick button
	Live_Profile_Game_Dialog.Panel_Game_Staging.Button_Kick_Player.Enable(false)
	
	Set_Currently_Selected_Client(LocalClient)
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Reinitialize_Game_Hosting()

	if ((JoinState ~= JOIN_STATE_HOST) or (not HostingGame)) then
		return
	end
	
	Refresh_Game_Settings_Model(false)
	Refresh_Game_Settings_View()

	Broadcast_Game_Settings()
		
end

-------------------------------------------------------------------------------
-- The host calls this to collect all the game settings from the setup screen
-- into the various data structures that will be used to broadcast the
-- settings to other players and to start the game.  The host IGNORES game
-- settings broadcasts altogether.
-------------------------------------------------------------------------------
function CMCommon_Refresh_Game_Settings_Model(full_reset)

	if (JoinState ~= JOIN_STATE_HOST) then
		return
	end
	
	GameAdvertiseData = { }

	-- JOE INTEROP:
	-- Comment back in when the new XLive is posted.
	-- Platform
	if (Is_Xbox()) then
		GameAdvertiseData[PROPERTY_PG_PLATFORM_TYPE] = PLATFORM_360
	else
		GameAdvertiseData[PROPERTY_PG_PLATFORM_TYPE] = PLATFORM_PC
	end
	
	-- NAT
	GameAdvertiseData[PROPERTY_PG_NAT_TYPE] = Net.Get_NAT_Type_Constant()
	
	-- This is a multiplayer game
	GameAdvertiseData[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER

	-- Determine whether the game is ranked or not
	if (GameOptions.ranked) then
		GameAdvertiseData[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
	else
		GameAdvertiseData[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_STANDARD
	end

	-- AI Players
	local ai_count = Network_Get_AI_Player_Count()
	GameAdvertiseData[PROPERTY_AI_SLOTS] = ai_count
	
	-- Medals
	GameScriptData.medals_enabled = false
	if (NetworkState == NETWORK_STATE_INTERNET) then
		if (Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Medals.Get_Selected_Index() == COMBO_SELECTION_YES) then
			GameScriptData.medals_enabled = true
		end
	end
	if GameScriptData.medals_enabled then
		GameAdvertiseData[PROPERTY_ACHIEVEMENTS_ENABLED] = 1
	else
		GameAdvertiseData[PROPERTY_ACHIEVEMENTS_ENABLED] = 0
	end

	-- Victory Condition
	GameScriptData.victory_condition = nil
	local condition = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Win_Condition.Get_Selected_Text_Data()
	for condition_name, condition_constant in pairs(VictoryConditionConstants) do
		if condition_name == condition then
			GameScriptData.victory_condition = condition_constant
		end
	end
	GameAdvertiseData[PROPERTY_WIN_CONDITION] = GameScriptData.victory_condition

	-- DEFCON
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_DEFCON_Active.Get_Selected_Index()
	GameScriptData.is_defcon_game = (COMBO_SELECTION_YES == index)
	if GameScriptData.is_defcon_game then
		GameAdvertiseData[PROPERTY_DEFCON_ENABLED] = 1
	else
		GameAdvertiseData[PROPERTY_DEFCON_ENABLED] = 0
	end

	-- Hero Respawn
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Hero_Respawn.Get_Selected_Index()
	GameOptions.hero_respawn = (COMBO_SELECTION_YES == index)
	if GameOptions.hero_respawn then
		GameAdvertiseData[PROPERTY_HERO_RESPAWN_ENABLED] = 1
	else
		GameAdvertiseData[PROPERTY_HERO_RESPAWN_ENABLED] = 0
	end
	
	-- Map
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Map.Get_Selected_Index() 
	index = index + 1							-- MPMapModel is 1-based
	local map_dao = MPMapModel[index]		
	
	-- If we are hosting and the map has changed, we want everybody to clear their start position data.
	if ((HostingGame) and (GameOptions.map_crc ~= map_dao.map_crc)) then
		CMCommon_Reseat_Players()
		PGNetwork_Clear_Start_Positions()
	end
		
	GameOptions.map_name = MAP_DIRECTORY .. tostring(map_dao.file_name)
	GameOptions.map_display_name = map_dao.display_name
	GameOptions.map_filename_only = map_dao.file_name_no_extension
	GameOptions.map_preview = map_dao.file_name_no_extension .. ".tga"
	GameOptions.map_crc = map_dao.map_crc

	GameAdvertiseData[PROPERTY_MAP_NAME_CRC] = GameOptions.map_crc
		
	-- Reset the start markers overlay if the map has changed.
	if (full_reset or PrevMapIndex ~= GameOptions.map_crc) then
		PrevMapIndex = GameOptions.map_crc
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
	end

	if (CurrentlyJoinedSession ~= nil) then
		CurrentlyJoinedSession.map_crc = GameOptions.map_crc
		CurrentlyJoinedSession.max_players = MaxPlayerCount
	end

	-- Starting Credits
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Starting_Credits.Get_Selected_Index()
	-- Add 1 to index because the table is 0-based and the combo is 1-based.
	GameOptions.starting_credit_level = STARTING_CASH_VALUES[index + 1].data
	GameAdvertiseData[PROPERTY_STARTING_CREDITS] = GameOptions.starting_credit_level
	
	-- Pop Cap Override
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Unit_Population_Limit.Get_Selected_Index()
	-- Add 1 to index because the table is 0-based and the combo is 1-based
	GameOptions.pop_cap_override = POP_CAP_VALUES[index + 1].data
	GameAdvertiseData[PROPERTY_POP_CAP] = GameOptions.pop_cap_override

	-- Make sure that the game is set as joinable
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Private_Game.Get_Selected_Index()
	if index == COMBO_SELECTION_YES then
		GameOptions.private_game = true
		GameAdvertiseData[CONTEXT_GAME_STATE] = CONTEXT_GAME_STATE_X_GAME_STATE_PRIVATE
	else
		GameOptions.private_game = false
		GameAdvertiseData[CONTEXT_GAME_STATE] = CONTEXT_GAME_STATE_X_GAME_STATE_PUBLIC
	end

	CMCommon_Refresh_Advertised_Player_Count()
	
	GameScriptData.GameOptions = GameOptions
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Refresh_Advertised_Player_Count()

	-- Check our player count.
	if JoinedGame then

		-- Currently we do not differenitate between public and private slots
		CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count(false)

		if (CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players) then
			PGLobby_Set_Local_Session_Open(false)
		else
			PGLobby_Set_Local_Session_Open(true)
		end

		-- Call PGLobby_Update_Player_Count which in turn calls PGLobby_Post_Hosted_Session_Data
		PGLobby_Update_Player_Count()

	else

		PGLobby_Post_Hosted_Session_Data()

	end
	
end

-------------------------------------------------------------------------------
-- Set up the very basic game search parameters.
-------------------------------------------------------------------------------
function CMCommon_Initialize_Game_Filtering()

	if (Game_Search_Parameters == nil) then
		Game_Search_Parameters = { }
	end
	
	-- JOE INTEROP:
	-- Comment back in when the new XLive is posted.
	-- Platform
	if (Is_Xbox()) then
		Game_Search_Parameters[PROPERTY_PG_PLATFORM_TYPE] = PLATFORM_360
	else
		Game_Search_Parameters[PROPERTY_PG_PLATFORM_TYPE] = PLATFORM_PC
	end
	
	-- Parameter is ALWAYS 1...only the comparator will change (==, <=) based on ShowGamesInProgress
	Game_Search_Parameters[PROPERTY_GAME_JOINABLE] = 1
	
	if (GameOptions.ranked) then
		Game_Search_Parameters[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
	else
		Game_Search_Parameters[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_STANDARD
	end
	Game_Search_Parameters[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER
	
end

-------------------------------------------------------------------------------
-- A client calls this to collect all the game filters from the setup screen
-- into the data structure that will be used to search for available games
-------------------------------------------------------------------------------
function CMCommon_Refresh_Game_Filtering(game_search_parameters)
	
	if (game_search_parameters == nil) then
		Game_Search_Parameters = { }
	else
		Game_Search_Parameters = game_search_parameters
	end

	CMCommon_Initialize_Game_Filtering()

	-- Alliances
	local index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Alliances.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		if (index == COMBO_SELECTION_FILTER_YES) then
			Game_Search_Parameters[PROPERTY_ALLIANCES_ENABLED] = 1
		else
			Game_Search_Parameters[PROPERTY_ALLIANCES_ENABLED] = 0
		end
	end

	-- Medals
	local index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Medals.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		if (index == COMBO_SELECTION_FILTER_YES) then
			Game_Search_Parameters[PROPERTY_ACHIEVEMENTS_ENABLED] = 1
		else
			Game_Search_Parameters[PROPERTY_ACHIEVEMENTS_ENABLED] = 0
		end
	end
	
	-- Victory Condition
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Win_Condition.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		local condition = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Win_Condition.Get_Selected_Text_Data()
		for condition_name, condition_constant in pairs(VictoryConditionConstants) do
			if condition_name == condition then
				Game_Search_Parameters[PROPERTY_WIN_CONDITION] = condition_constant
			end
		end
	end

	-- DEFCON
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_DEFCON_Active.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		if (index == COMBO_SELECTION_FILTER_YES) then
			Game_Search_Parameters[PROPERTY_DEFCON_ENABLED] = 1
		else
			Game_Search_Parameters[PROPERTY_DEFCON_ENABLED] = 0
		end
	end

	-- Hero Respawn
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Hero_Respawn.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		if (index == COMBO_SELECTION_FILTER_YES) then
			Game_Search_Parameters[PROPERTY_HERO_RESPAWN_ENABLED] = 1
		else
			Game_Search_Parameters[PROPERTY_HERO_RESPAWN_ENABLED] = 0
		end
	end
	
	-- Map
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Map.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		Game_Search_Parameters[PROPERTY_MAP_NAME_CRC] = MPMapModel[index].map_crc
	end
	
	-- Starting Credits
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Starting_Credits.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		Game_Search_Parameters[PROPERTY_STARTING_CREDITS] = index-1
	end
	
	-- Pop Cap Override
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Unit_Population_Limit.Get_Selected_Index()
	if (index ~= COMBO_SELECTION_FILTER_ANY) then
		-- Here we don't add 1 to the index because in filtering we have stuffed a "Show All" item in each combo.
		pop_cap = POP_CAP_VALUES[index].data
		Game_Search_Parameters[PROPERTY_POP_CAP] = pop_cap
	end

	-- In Progress
	index = Live_Profile_Game_Dialog.Panel_Game_Filters.Combo_Show_In_Progress.Get_Selected_Index()
	if (index == COMBO_SELECTION_FILTER_ANY) then
		ShowGamesInProgress = true
	else
		if (index == COMBO_SELECTION_FILTER_YES) then
			ShowGamesInProgress = true
		else
			ShowGamesInProgress = false
		end
	end
	
end
	    
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Start_Available_Session_Polling()
	if (IsPollingAvailableSessions) then
		return
	end
	IsPollingAvailableSessions = true
	CMCommon_Update_Available_Sessions()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Update_Available_Sessions(force_refresh)

	if (IsPollingAvailableSessions) then
	
		-- Because there's both an automatic refresh and a manual refresh via a button,
		-- we need to make sure an automatic refresh doesn't happen right after a manual one.
		local curr = tonumber(Dirty_Floor(Net.Get_Time()))
		if (LastSessionRefresh == nil) then
			LastSessionRefresh = 0
		end
		
		local row_selected = (Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games.Get_Selected_Row_Index() ~= -1)
		local delta = curr - LastSessionRefresh
		if (force_refresh or ((delta >= AVAILABLE_SESSIONS_REFRESH_PERIOD) and (not row_selected)) and ClearAvailableGames) then
			-- Only perform the auto refresh if enough time has passed and there is no session selected.
			CMCommon_Do_Available_Sessions_Refresh()
		end

		-- Schedule the next auto refresh.
		PGCrontab_Schedule(CMCommon_Update_Available_Sessions, 0, AVAILABLE_SESSIONS_REFRESH_PERIOD)	-- Call once, in n seconds.
		
		-- Make sure the refresh button is enabled in case the backend got stuck or something.
		--Live_Profile_Game_Dialog.Panel_Custom_Lobby.Button_Refresh.Enable(true)
	
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Do_Available_Sessions_Refresh()

	-- Pump the keepalive system
	PGLobby_Keepalive_Open_Bracket()
	
	-- Timestamp each request so we don't have requests running into each other.
	LastSessionRefresh = tonumber(Dirty_Floor(Net.Get_Time()))
	
	local list_box = Live_Profile_Game_Dialog.Panel_Custom_Lobby.List_Available_Games
	list_box.Clear()
	local new_row = list_box.Add_Row()
	local message = Get_Game_Text("TEXT_MULTIPLAYER_REFRESHING_GAMES_LIST")
	list_box.Set_Text_Data(AVAILABLE_SESSIONS_COLUMN_NAME, 0, message)
	list_box.Set_Row_Color(0, tonumber(SYSTEM_CHAT_COLOR))

	if Game_Search_Parameters == nil then
		Game_Search_Parameters = { }
		if (GameOptions.ranked) then
			Game_Search_Parameters[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
		else
			Game_Search_Parameters[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_STANDARD
		end
		Game_Search_Parameters[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER
	end
	
	local player_match = (MatchingState == MATCHING_STATE_PLAYER_MATCH)
	-- TODO: Do not ship with debug query
	--local DEBUG_MATCHING_QUERY = true
	if (DEBUG_MATCHING_QUERY) then
		PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_DEBUG_GAME_QUERY, Game_Search_Parameters, player_match)
	else
		-- PUBLIC_QUERY looks for only one type of game (in that case we're interested in GAME_JOINABLE == 1).
		-- So use PUBLIC_QUERY to filter OUT games in progress. 
		-- GAME_QUERY looks for <= the GAME_JOINABLE flag (in that case we're interested in GAME_JOINABLE <= 1).
		-- So use GAME_QUERY to show all games.
		if (ShowGamesInProgress) then
			PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_GAME_QUERY, Game_Search_Parameters, player_match)
		else
			PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_PUBLIC_QUERY, Game_Search_Parameters, player_match)
		end
	end
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Stop_Available_Session_Polling()
	IsPollingAvailableSessions = false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Reseat_Players()

	if (not HostingGame) then
		return
	end
	
	Network_Reseat_Guests()
	Broadcast_Seat_Assignments()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Do_Guest_Assign_Start_Position(duple)

	local target_client = Network_Get_Client(duple.client_addr)
	local seat = Network_Get_Seat(target_client)
	target_client.start_marker_id = duple.start_marker_id
	
end

-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- M I S C 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
	
------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
function CMCommon_Check_Game_Start_Conditions()

	local can_start = true
	local tmp = false
	local messages = {}
	local num_human_players = Network_Get_Client_Table_Count(false)
	
	local client_data_valid, game_data_valid, server_data_valid = PGLobby_Validate_Local_Session_Data(nil, false)

	-- Nobody to play with?
	if ((ClientTable == nil) or 
		(ClientTable[LocalClient.common_addr] == nil) or
		(num_human_players < 2)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_PLAYERS_TO_JOIN"))
	end
	
	
	-- Data required from the backend.
	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		-- Achievement enumeration per player for medals verification.
		if (ENABLE_ACHIEVEMENT_VERIFICATION) then
		
			if (not server_data_valid) then
				can_start = false
				table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
			end
		
			-- If we DO have all the backend data, we want to verify each player's
			-- applied medals.
			if (can_start and (GameScriptData.medals_enabled)) then
			
				local status, offenders = PGLobby_Validate_Client_Medals()
				
				if (not status) then
				
					can_start = false
					if (offenders ~= nil) then
						local message = Get_Game_Text("TEXT_MULTIPLAYER_BAD_MEDALS_FROM_PLAYER")
						Replace_Token(message, offenders[1], 1)
						table.insert(messages, message)
					else
						table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
					end
					
				end
				
			end
			
		end
	
	end

	-- Data required from other players
	if (not client_data_valid) then
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_PLAYER_DATA"))
	end
	
	-- Data required about the game
	if (not game_data_valid) then
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_GAME_DATA"))
	end
	
	-- Verify the connection web.
	if (PGLobbyBadClientList ~= nil) then
	
		-- If a player with a bad-connection joined in the past but somehow managed to hang around
		-- in the bad connection list, make sure he's gone.
		local prune_list = {}
		local bad_clients = 0
		for common_addr, value in pairs(PGLobbyBadClientList) do
			if (ClientTable[common_addr] == nil) then
				table.insert(prune_list, common_addr)
			elseif (value) then
				bad_clients = bad_clients + 1
			end
		end
		for _, old_addr in ipairs(prune_list) do
			PGLobbyBadClientList[old_addr] = nil
		end
		if (bad_clients > 0) then
			can_start = false
			table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_CLIENT_BAD_CONNECTION"))
		end
		
	end
		
	-- Unique Colors
	tmp = Check_Unique_Colors()
	can_start = (can_start and tmp)
	if (tmp == false) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_START_COND_COLORS"))
	end
	
	-- At least two teams if there is more than one human player.
	local team_tally = {}
	local unique_team_count = 0
	local player_count = 0
	for _, client in pairs(ClientTable) do
	
		if (client.team ~= nil) then
	
			local tally = team_tally[client.team]
		
			if (tally == nil) then
				unique_team_count = unique_team_count + 1
				team_tally[client.team] = 1
			else
				team_tally[client.team] = tally + 1
			end
			
			player_count = player_count + 1
			
		end
		
	end

	if ((not GameOptions.alliances_enabled) and (player_count > 1) and (unique_team_count <= 1)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_UNIQUE_TEAMS"))
	end
	
	-- Check if the game countdown is allowed to start.
	if (HostingGame and (not AllowGameCountdown)) then
		can_start = false
	end
	
	-- Valid map selection?
	if (not ValidMapSelection) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_BAD_MAP_SELECTION"))
	end
	
	-- NOTE:  Make sure accept status is LAST!!!  We can only display one status
	-- message at a time, and acceptance should come after all the other conditions
	-- are met.
	tmp = false
	if (CurrentlyJoinedSession ~= nil) then
		tmp = Check_Guest_Accept_Status(CurrentlyJoinedSession.common_addr)
	end
	local only_awaiting_acceptance = (can_start and (not tmp))
	can_start = (can_start and tmp)
	if (tmp == false) then
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_START_COND_ACCEPTS"))
	end

	return can_start, messages, only_awaiting_acceptance

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Validate_Client_Faction(faction)

	if type(faction) == "string" then
		faction = Get_Faction_Numeric_Form(faction)
	end

	if (type(faction) ~= "number") or
		(faction < PG_SELECTABLE_FACTION_MIN) or
		(faction > PG_SELECTABLE_FACTION_MAX) then
		faction = PG_SELECTABLE_FACTION_MIN
	end

	return faction

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Get_Preferred_Faction()

	local faction = Get_Profile_Value(PP_LAST_FACTION, PG_FACTION_NOVUS)
	
	if ((faction ~= PG_FACTION_NOVUS) and
		(faction ~= PG_FACTION_ALIEN) and
		(faction ~= PG_FACTION_MASARI)) then
		faction = PG_FACTION_NOVUS
	end
	
	return faction
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Get_Preferred_Team()

	local team = tostring(Get_Profile_Value(PP_TEAM, 1))
	if ((team == nil) or (team == "-1") or (team == "")) then
		team = 1
	else
		team = tonumber(team)
	end
	
	return team
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Build_Game_Start_Positions()

	if (not PGMO_Get_Enabled()) then
		return nil
	end

	if (PGMO_Get_Assignment_Count() <= 0) then
		return nil
	end
 
	local result = {}
	for _, client in pairs(ClientTable) do
		if (client.start_marker_id == nil) then
			client.start_marker_id = -99		-- Just make sure it's less than zero.  DefaultLandScript will handle the rest.
		end
		client.start_marker_id = client.start_marker_id - 1
		result[client.PlayerID] = client.start_marker_id 
	end
	
	return result

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_On_Medal_Chest_Closing()

	if (CurrentlySelectedSession ~= nil) then
		PGMO_Show()
	end
	Live_Profile_Game_Dialog.Focus_First()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Heavyweight_Child_Scene_Closing()

	PGLobby_Activate_Movies()
	
	-- Special Case:  Kick off the globe movies.
	if (ViewState == VIEW_STATE_MAIN) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		
	elseif ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Play()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		
	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Play()
		Live_Profile_Game_Dialog.Panel_Game_Staging.Globe_Movie.Stop()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		Live_Profile_Game_Dialog.Panel_Game_Filters.Globe_Movie.Stop()
		Live_Profile_Game_Dialog.Panel_Custom_Lobby.Globe_Movie.Stop()
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Strip_Applied_Medals(client_table)
	
	if (client_table == nil) then
		return
	end
	
	for _, client in pairs(client_table) do
		if (client.applied_medals ~= nil) then
			client.applied_medals = nil
		end
	end
	
end
		
-------------------------------------------------------------------------------
-- Host calls this to prepare an override.
-------------------------------------------------------------------------------
function CMCommon_Prepare_Host_Start_Position_Override()

	local result = {}
	for _, client in pairs(ClientTable) do
		result[client.common_addr] = client.start_marker_id 
	end
	return result
	
end

-------------------------------------------------------------------------------
-- Guest calls this to process a host override.
-------------------------------------------------------------------------------
function CMCommon_Process_Host_Start_Position_Override(start_positions)
		
	-- Verify
	local result = {}
	for _, client in pairs(ClientTable) do
	
		local guest_marker_id = client.start_marker_id
		local host_marker_id = start_positions[client.common_addr]
		
		-- Are they different?
		if (guest_marker_id ~= host_marker_id) then
		
			-- Report
			DebugMessage("LUA_LOBBY: WARNING: Guest start position clash.")
			DebugMessage("LUA_LOBBY: WARNING:   HOST : " .. tostring(client.name) .. "->" .. tostring(host_marker_id))
			DebugMessage("LUA_LOBBY: WARNING:   GUEST: " .. tostring(client.name) .. "->" .. tostring(guest_marker_id))
			DebugMessage("LUA_LOBBY: WARNING: Overriding guest position with host position.")
			
			-- Override
			if (host_marker_id == nil) then
				-- If the host says this client hasn't chosen a start position, then make sure that's the case.
				client.start_marker_id = nil
				PGMO_Clear_Start_Position_By_Seat(seat) 
			else 
				-- If the host says this client has chosen a start position, then make sure it's chosen.
				local start_pos_dao = {}
				start_pos_dao.client_addr = client.common_addr
				start_pos_dao.start_marker_id = host_marker_id
				CMCommon_Do_Guest_Assign_Start_Position(start_pos_dao)
			end
			
		end
		
	end
			
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Refresh_Staging_Map_Overlay()

	PGMO_Clear_Start_Positions() 

	for _, client in pairs(ClientTable) do
	
		local start_marker_id = client.start_marker_id
		if ((start_marker_id ~= nil) and (start_marker_id >= 0)) then
		
			local seat = Network_Get_Seat(client)
			local color = client.color
			PGMO_Assign_Start_Position(start_marker_id, seat, color)
		
		end
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Is_Start_Marker_Free(start_marker_id)

	for _, client in pairs(ClientTable) do
		if (client.start_marker_id == start_marker_id) then
			return false
		end
	end
	return true
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Set_Client_Map_Validity(key, valid)
	MapValidityLookup[key] = valid
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Check_Client_Map_Validity()

	local valid_map_selection = true
	for _, client_valid in pairs(MapValidityLookup) do
		if (client_valid ~= true) then
			valid_map_selection = false
		end
	end
	
	return valid_map_selection
	
end



-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Set_Network_State_Internet()

	-- Paranoia check.  Somehow LAN_Stop() is being skipped over under certain conditions
	-- when users leave the LAN dialog.
	Net.LAN_Stop()
	PGLobby_Restart_Networking(NETWORK_STATE_INTERNET)
	GameOptions.ranked = false
	AVAILABLE_SESSIONS_REFRESH_PERIOD = INTERNET_SESSIONS_REFRESH_PERIOD
	CMCommon_Refresh_UI()
	
	-- NAT Warning
	Live_Profile_Game_Dialog.Text_NAT_Type.Set_Hidden(false)
	-- TEMP removed for interoperability testing. ST - 9/17/2007 3:54PM
	-- PGLobby_Display_NAT_Information(Live_Profile_Game_Dialog.Text_NAT_Type)
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function CMCommon_Set_Network_State_LAN()

	PGLobby_Restart_Networking(NETWORK_STATE_LAN)
	GameOptions.ranked = false
	AVAILABLE_SESSIONS_REFRESH_PERIOD = LAN_SESSIONS_REFRESH_PERIOD
	CMCommon_Refresh_UI()
	
	-- NAT Warning
	Live_Profile_Game_Dialog.Text_NAT_Type.Set_Hidden(true)
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_Is_Accepting_Invitation()
	InvitationAccepted = Net.Get_Time()
	CMCommon_Set_Join_State(JOIN_STATE_GUEST)
	PGLobby_Display_Custom_Modal_Message("TEXT_SEARCHING", "", "TEXT_BUTTON_CANCEL", "")
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_Finished_Invitation()
	InvitationAccepted = nil
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function CMCommon_Set_Game_Is_Starting(game_is_starting)
	GameIsStarting = game_is_starting
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Network_State_Internet = CMCommon_Set_Network_State_Internet
Interface.Set_Network_State_LAN = CMCommon_Set_Network_State_LAN
Interface.Set_Is_Accepting_Invitation = CMCommon_Set_Is_Accepting_Invitation

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	CMCommon_Clear_UI = nil
	CMCommon_Close_Dialog = nil
	CMCommon_Constants_Init = nil
	CMCommon_Enable_Settings_Accept_UI = nil
	CMCommon_GUI_Init = nil
	CMCommon_Get_Focused_Client_For_Edit = nil
	CMCommon_Heavyweight_Child_Scene_Closing = nil
	CMCommon_Hide_Lobby_Session_Settings = nil
	CMCommon_Initialize_Components = nil
	CMCommon_Initialize_Game_Hosting = nil
	CMCommon_Internet_On_Lobby_Init = nil
	CMCommon_Internet_On_MM_Create_Session = nil
	CMCommon_Leave_Game = nil
	CMCommon_Network_On_Connection_Status = nil
	CMCommon_Network_On_Find_Internet_Session = nil
	CMCommon_Network_On_Find_LAN_Session = nil
	CMCommon_Network_On_Live_Connection_Changed = nil
	CMCommon_Network_On_Locator_Server_Count = nil
	CMCommon_Network_On_Message = nil
	CMCommon_On_AI_Player_Added = nil
	CMCommon_On_AI_Player_Removed = nil
	CMCommon_On_Available_Games_Selection_Changed = nil
	CMCommon_On_Back_Clicked = nil
	CMCommon_On_Button_Filters_Accept_Clicked = nil
	CMCommon_On_Button_Gamer_Card_Clicked = nil
	CMCommon_On_Button_Medal_Chest_Clicked = nil
	CMCommon_On_Button_Quickmatch_Clicked = nil
	CMCommon_On_Cancel_Countdown_Clicked = nil
	CMCommon_On_Closing_All_Displays = nil
	CMCommon_On_Combo_Map_Selection_Changed = nil
	CMCommon_On_Combo_Starting_Credits_Changed = nil
	CMCommon_On_Component_Shown = nil
	CMCommon_On_Edit_Settings_Clicked = nil
	CMCommon_On_Empty_Space_Clicked = nil
	CMCommon_On_Enumerate_Achievements = nil
	CMCommon_On_Filters_Exit_Clicked = nil
	CMCommon_On_Host_Game_Clicked = nil
	CMCommon_On_Join_Game_Clicked = nil
	CMCommon_On_Kick_Player_Clicked = nil
	CMCommon_On_Lobby_Filters_Clicked = nil
	CMCommon_On_Lobby_Refresh_Clicked = nil
	CMCommon_On_Matching_Type_Mouse_Off = nil
	CMCommon_On_Matching_Type_Mouse_On = nil
	CMCommon_On_Medal_Chest_Closing = nil
	CMCommon_On_Medal_Mouse_Off = nil
	CMCommon_On_Medal_Mouse_On = nil
	CMCommon_On_Menu_System_Activated = nil
	CMCommon_On_Mouse_Move = nil
	CMCommon_On_My_Online_Profile_Clicked = nil
	CMCommon_On_Player_Cluster_Clicked = nil
	CMCommon_On_Player_Color_Down_Clicked = nil
	CMCommon_On_Player_Color_Up_Clicked = nil
	CMCommon_On_Player_Difficulty_Down_Clicked = nil
	CMCommon_On_Player_Difficulty_Up_Clicked = nil
	CMCommon_On_Player_Faction_Down_Clicked = nil
	CMCommon_On_Player_Faction_Up_Clicked = nil
	CMCommon_On_Player_Name_Mouse_Off = nil
	CMCommon_On_Player_Name_Mouse_On = nil
	CMCommon_On_Player_Team_Down_Clicked = nil
	CMCommon_On_Player_Team_Up_Clicked = nil
	CMCommon_On_Query_Medals_Progress_Stats = nil
	CMCommon_On_Ready_Clicked = nil
	CMCommon_On_Set_Default_Clicked = nil
	CMCommon_On_Staging_Exit_Clicked = nil
	CMCommon_On_Staging_Launch_Game_Clicked = nil
	CMCommon_On_Update = nil
	CMCommon_On_YesNoOk_No_Clicked = nil
	CMCommon_On_YesNoOk_Ok_Clicked = nil
	CMCommon_On_YesNoOk_Yes_Clicked = nil
	CMCommon_PGMO_On_Start_Marker_Clicked = nil
	CMCommon_Persist_Filters_To_Profile = nil
	CMCommon_Persist_Host_UI_To_Profile = nil
	CMCommon_Persist_Staging_UI_To_Profile = nil
	CMCommon_Play_Button_Select_SFX = nil
	CMCommon_Play_Mouse_Over_Button_SFX = nil
	CMCommon_Play_Mouse_Over_Option_SFX = nil
	CMCommon_Play_Option_Select_SFX = nil
	CMCommon_Refresh_Custom_Lobby = nil
	CMCommon_Refresh_Game_Filtering = nil
	CMCommon_Refresh_Game_Settings_Model = nil
	CMCommon_Refresh_Options = nil
	CMCommon_Refresh_Quickmatch = nil
	CMCommon_Refresh_Staging = nil
	CMCommon_Refresh_Staging_Map_Overlay = nil
	CMCommon_Refresh_Start_Conditions_View = nil
	CMCommon_Register_Event_Handlers = nil
	CMCommon_Reinitialize_Game_Hosting = nil
	CMCommon_Set_Currently_Selected_Client = nil
	CMCommon_Set_Finished_Invitation = nil
	CMCommon_Set_Host_Defaults = nil
	CMCommon_Set_Join_Filter_Defaults = nil
	CMCommon_Set_Lobby_Session_Settings = nil
	CMCommon_Set_View_State = nil
	CMCommon_Start_Game_Countdown = nil
	CMCommon_Update_Countdown = nil
	CMCommon_Update_Selected_Player_View = nil
	CMCommon_Variables_Init = nil
	CMCommon_Variables_Reset = nil
	CMCommon_Verify_Guest_Join_Attempt = nil
	CMCommon_View_Back_Out = nil
	CMCommon_View_Back_To_Start = nil
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
	OutputDebug = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Lookup_Map_DAO = nil
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

