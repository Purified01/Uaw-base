if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[116] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Common_Global_Conquest_Lobby.lua#35 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Common_Global_Conquest_Lobby.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 99361 $
--
--          $DateTime: 2008/05/30 14:48:03 $
--
--          $Revision: #35 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGNetwork")
require("PGColors")
require("PGPlayerProfile")
require("PGOnlineAchievementDefs")
require("PGOfflineAchievementDefs")
require("PGGlobalConquestDefs")
require("Lobby_Network_Logic")
require("PGFactions")
require("PGCrontab")
require("PGMapOverlayManager")


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Init()

	Global_Conquest_Lobby.Start_Modal()

	-- Library inits.
	PGNetwork_Init()
	PGColors_Init()
	PGPlayerProfile_Init()
	PGFactions_Init()
	PGGlobalConquestDefs_Init()
	Register_Game_Scoring_Commands()
	PGOnlineAchievementDefs_Init()
	PGLobby_Vars_Init()
	PGCrontab_Init()
	PGMO_Initialize()

	-- Network Message Processors
	NetworkMessageProcessors = {}
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_SETTINGS]					= NMP_Player_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_ALL_GAME_SETTINGS]					= NMP_All_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_START_GAME]							= NMP_Start_Game
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_NAME]							= NMP_Player_Name
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_FACTION]						= NMP_Player_Faction
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_COLOR]						= NMP_Player_Color
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_TEAM]							= NMP_Player_Team
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS_ACCEPT]				= NMP_Player_Accepts
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_APPLIED_MEDALS]			= NMP_Player_Applied_Medals
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_RESET_GLOBE]				= NMP_Player_Reset_Globe
	NetworkMessageProcessors[MESSAGE_TYPE_STATS_REGISTRATION_BEGIN]		= NMP_Stats_Registration_Begin
	NetworkMessageProcessors[MESSAGE_TYPE_STATS_CLIENT_REGISTERED]			= NMP_Stats_Client_Registered
	NetworkMessageProcessors[MESSAGE_TYPE_HEARTBEAT]							= NMP_Heartbeat
	NetworkMessageProcessors[MESSAGE_TYPE_REBROADCAST_USER_SETTINGS]		= NMP_Rebroadcast_User_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_REBROADCAST_GAME_SETTINGS]		= NMP_Rebroadcast_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_UPDATE_SESSION]						= NMP_Update_Session
	
	PGLobby_Init_Modal_Message(Global_Conquest_Lobby)
	PGLobby_Set_Dialog_Is_Hidden(false)
	
	-- Constants
	Constants_Init()
	
	-- Vars
	Variables_Init()

	-- Components
	Initialize_Components()

	-- Event handlers
	Register_Event_Handlers()
	
	local win = GCCommon_Is_Global_Conquest_Won()
	if (win) then
		GCCommon_Display_Win_Dialog()
	end

	GCCommon_Create_Status_Dialog()
	Bind_Global_Conquest_Lobby_Manager()
	GCCommon_Setup_GC_Lobby_Manager()
	
	-- Networking:  Global Conquest is an internet-only feature!
	PGLobby_Restart_Networking(NETWORK_STATE_INTERNET)
	
	GCCommon_Update_Local_Client()
	
	GCCommon_Start_Available_Game_Polling()
	
	GCCommon_Init_UI()
	Refresh_UI()
	GCCommon_Update_Region_Tooltip()
	PGLobby_Post_Hosted_Session_Data()
	GCCommon_Enable_GC_Scene_Input(true)

	GCCommon_Do_Modal_Globe_Refresh()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_GLOBAL_CONQUEST })
	
	this.Focus_First()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Register_Event_Handlers()

	Global_Conquest_Lobby.Register_Event_Handler("Closing_All_Displays", nil, GCCommon_On_Back_Clicked)
	Global_Conquest_Lobby.Register_Event_Handler("On_Back_Out", nil, GCCommon_Back_Out)
	Global_Conquest_Lobby.Register_Event_Handler("On_Go", nil, GCCommon_Launch_Game)
	Global_Conquest_Lobby.Register_Event_Handler("On_Quickmatch", nil, On_Net_Status_Quickmatch)
	Global_Conquest_Lobby.Register_Event_Handler("On_Leave_Globe_Conquered", nil, GCCommon_Leave_Globe_Conquered)
	Global_Conquest_Lobby.Register_Event_Handler("On_Reset_Global_Conquest", nil, GCCommon_Reset_Global_Conquest)
	Global_Conquest_Lobby.Register_Event_Handler("On_Menu_System_Activated", nil, GCCommon_On_Menu_System_Activated)

	-- [JLH 08/06/2007]:  Register for heavyweight embedded scenes closing so that we can start and stop our movies.
	Global_Conquest_Lobby.Register_Event_Handler("Heavyweight_Child_Scene_Closing", nil, GCCommon_Heavyweight_Child_Scene_Closing)
	
	-- [JLH 10/06/2007]:  Currently only used by the "Downloading..." dialog when cancelled.
	Global_Conquest_Lobby.Register_Event_Handler("On_YesNoOk_Ok_Clicked", nil, On_Download_Dialog_Cancelled)
	

end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
-------------------------------------------------------------------------------
function GCCommon_Initialize_Components()

	PGMO_Set_Marker_Size(PGMO_MARKER_SIZE_SMALL)

	Net.Get_Gamer_Picture(Global_Conquest_Lobby.Quad_Avatar)

	-- Text Fields
	Global_Conquest_Lobby.Scriptable_Region_Details.Text_Region_Name.Set_Text(EMPTY)
	Global_Conquest_Lobby.Scriptable_Region_Details.Text_Players_Contesting.Set_Text(EMPTY)
	Global_Conquest_Lobby.Scriptable_Region_Details.Set_Hidden(true)
	Global_Conquest_Lobby.Text_Profile_Name.Set_Text(EMPTY)
	
	-- Put some tab orders in place so we have focus to latch onto.
	this.Button_Novus.Set_Tab_Order(Declare_Enum(1))
	this.Button_Alien.Set_Tab_Order(Declare_Enum())
	this.Button_Masari.Set_Tab_Order(Declare_Enum())
	this.Button_Military.Set_Tab_Order(Declare_Enum())

	Global_Conquest_Lobby.Focus_First()
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function GCCommon_Constants_Init()

	GARY_DEBUG = false
	SIMULATE_MODE = false				-- In simulate mode, matches aren't actually fought, but rather the outcomes are random.
	DIALOG_X_POS = 0.5					-- Positioning for the net and win dialogs.
	DIALOG_Y_POS = 0.5
	MAX_FIND_JOINABLE_ATTEMPT_COUNT = 1			-- Number of times we attempt to find a game in a region before going to host mode.
	GAME_SEARCH_INTERVAL_SLOW = 15.0		   	-- Number of seconds between existing game searches in a region.
	GAME_SEARCH_INTERVAL_FAST = 15.0				-- Number of seconds between existing game searches in a region.
	NO_MAP_PREVIEW_IMAGE = "No_Map_Preview"		-- JOE TODO:  Proper "no preview available" image.
	FACTION_ICON_UNHIGHLIGHT_SCALE = 0.75
	
	MATCHING_STATE_NONE = Declare_Enum(0)
	MATCHING_STATE_SEARCHING_FOR_OPPONENT = Declare_Enum()
	MATCHING_STATE_WAITING_FOR_OPPONENT = Declare_Enum()
	MATCHING_STATE_QUICKMATCHING = Declare_Enum()
	MATCHING_STATE_FOUND_OPPONENT = Declare_Enum()
	MATCHING_STATE_READY_TO_START = Declare_Enum()
	MATCHING_STATE_STARTED_GAME = Declare_Enum()
	
	GLOBE_RESET_STATE_HAS_NOT_MADE_CHOICE = Declare_Enum(0)
	GLOBE_RESET_STATE_HAS_MADE_CHOICE_RESET = Declare_Enum()
	GLOBE_RESET_STATE_HAS_MADE_CHOICE_LEAVE_CONQUERED = Declare_Enum()
	
	WIDE_EMPTY_STRING = Create_Wide_String("")

	GameAdvertiseData = { }
	GameAdvertiseData[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
	GameAdvertiseData[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_GLOBAL_CONQUEST
	GameAdvertiseData[PROPERTY_PG_NAT_TYPE] = Net.Get_NAT_Type_Constant()
	
	GameSearchData = { }
	GameSearchData[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
	GameSearchData[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_GLOBAL_CONQUEST
		
	QUICKMATCH_OPEN_SEARCH_THRESHOLD = 3	-- After three quickmatch searches, open up to any and all regions.
	
	GAME_NEGOTIATION_TIMEOUT = 30		-- Maximum number of seconds we're willing to wait for negotiation after a join.
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function GCCommon_Variables_Init()

	Variables_Reset()
	
	RegionIcons = {}
	RegionIcons[PG_FACTION_NOVUS] = "region_label_novus"
	RegionIcons[PG_FACTION_ALIEN] = "region_label_alien"
	RegionIcons[PG_FACTION_MASARI] = "region_label_masari"
	RegionIcons[PG_FACTION_MILITARY] = "region_label_novus"
	NonzeroPopulationIcon = "region_label_dude"
	NonzeroPopulationIconScale = 2.0
	
	FactionTextures = {}
	FactionTextures[PG_FACTION_NOVUS] = "i_logo_novus.tga"
	FactionTextures[PG_FACTION_ALIEN] = "i_logo_aliens.tga"
	FactionTextures[PG_FACTION_MASARI] = "i_logo_masari.tga"
	FactionTextures[PG_FACTION_MILITARY] = "i_logo_military.tga"
	
	RefreshFunctions = {
		[PG_FACTION_NOVUS]	= GCCommon_Refresh_UI_Novus,
		[PG_FACTION_ALIEN]	= GCCommon_Refresh_UI_Alien,
		[PG_FACTION_MASARI]	= GCCommon_Refresh_UI_Masari,
		[PG_FACTION_MILITARY] = GCCommon_Refresh_UI_Military
	}

	MPMapModel = PGLobby_Generate_Map_Selection_Model()	-- List of multiplayer maps.
  
	PGMO_Clear()
	PGMO_Bind_To_Quad(Global_Conquest_Lobby.Scriptable_Region_Details.Quad_Map_Preview)
	PGMO_Set_Justification(SCREEN_JUSTIFY_RIGHT)

	AtCursorRegion = nil
	
end

-------------------------------------------------------------------------------
-- This function should be called any time the lobby is to be re-initialized.
-------------------------------------------------------------------------------
function GCCommon_Variables_Reset()

	ClientTable = {}
	LocalClient = {}
	RootStateMap = nil					-- The 3-member map which stores the state lists for all 3 factions.
	CurrentFactionStateList = nil		-- An array of all the regions and their current state, for the current faction.
	CurrentFactionMetaData = nil		-- A map of meta data about the current faction's global conquest.
	CurrentFactionStateLookup = nil		-- A map of the above array, keyed by label.
	SelectedRegionGames = {}
	SelectedRegion = nil
	FindJoinableAttemptCount = -1
	MatchingState = MATCHING_STATE_NONE
	CurrentFaction = GCCommon_Get_Last_Current_Faction()
	AvailableGamePolling = false
	GameHasStarted = false
	GameSearchInterval = GAME_SEARCH_INTERVAL_SLOW
	GameArbitrationReady = false
	MaxPlayerCount = 2					-- CtW is 1v1, so this is ALWAYS a two-player situation.
	GCSceneInputEnabled = true
	HostingGame = false
	JoinedGame = false
	MedalProgressStatsRetrieved = false
	HostStatsRegistration = false
	HostStatsRegistrationComplete = false
	StartGameCalled = false
	DoingModalGlobeRefresh = false
	
	GCCommon_Set_Game_Started_Mode(false)
	
	GCCommon_Reset_Game_Script_Data()
	ProfileAchievements = {}
	ClientRegionData = nil			-- MUST be nil on init.
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Do_Modal_Globe_Refresh(delay_message_display)

	if (delay_message_display == nil) then
		delay_message_display = false
	end

	GCCommon_Clear_Region_Ownership_View()
	
	SupressProfileDownloadingMessage = false
	if (delay_message_display) then
		PGCrontab_Schedule(GCCommon_Display_Profile_Downloading_Message, 0, 2)
	else
		GCCommon_Display_Profile_Downloading_Message()
	end
	
	GCCommon_Request_Region_Data(CurrentFaction)
	DoingModalGlobeRefresh = true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Display_Profile_Downloading_Message()

	if (SupressProfileDownloadingMessage) then
		return
	end
	PGLobby_Display_Custom_Modal_Message("TEXT_MULTIPLAYER_DOWNLOADING_PROFILE_DATA", "", "TEXT_BUTTON_CANCEL", "")
	ProfileDownloadMessageUp = true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_End_Modal_Globe_Refresh()

	if (ProfileDownloadMessageUp) then
		ProfileDownloadMessageUp = false
		PGLobby_Hide_Modal_Message()
	end
	DoingModalGlobeRefresh = false
	
end
		
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Reset_Game_Script_Data()
	GameScriptData = {}
	GameScriptData.victory_condition = VICTORY_CONQUER
	GameScriptData.is_defcon_game = false
	GameScriptData.medals_enabled = true
end

-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Setup_GC_Lobby_Manager()
	GCLobbyManager.Set_Star_Model(Global_Conquest_Lobby.Model_Stars)
	GCLobbyManager.Set_Globe_Model(Global_Conquest_Lobby.Model_Globe)
	GCLobbyManager.Setup_Model(PGGlobalConquestRegionLabels)
	GCLobbyManager.Set_Base_Model("Earth")
	GCLobbyManager.Set_Lobby_Active(true)
	local desc = Create_Wide_String()
	local username = Network_Get_Local_Username()
	desc.assign(username)
	Global_Conquest_Lobby.Text_Profile_Name.Set_Text(desc)
end

function GCCommon_Are_Any_Dialogs_Showing()
	if PGLobby_Is_Modal_Message_Showing() then
		return true
	end

	if TestValid(Global_Conquest_Lobby.Global_Conquest_Net_Dialog) and
		(Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Get_Hidden() == false) then
		return true
	end

	if TestValid(Global_Conquest_Lobby.Global_Conquest_Win_Dialog) and
		(Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Get_Hidden() == false) then
		return true
	end

	if TestValid(Global_Conquest_Lobby.Achievement_Chest) and 
		(Global_Conquest_Lobby.Achievement_Chest.Get_Hidden() == false) then
		return true
	end

	return false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_On_Update()

	if (this.Get_Hidden()) then
		return false
	end

	PGCrontab_Update()

	if (GCCommon_Are_Any_Dialogs_Showing()) then
		GCLobbyManager.Suspend_Input_Processing()
	else
		GCLobbyManager.Resume_Input_Processing()
	end

	return true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_On_Component_Shown()

	GCCommon_Setup_GC_Lobby_Manager()
	Variables_Reset()
	GCCommon_Enable_GC_Scene_Input(true)
	LocalClient = {}
	Global_Conquest_Lobby.Start_Modal()
	PGLobby_Set_Dialog_Is_Hidden(false)
	-- Networking:  Global Conquest is an internet-only feature!
	PGLobby_Restart_Networking(NETWORK_STATE_INTERNET)
	GCCommon_Update_Local_Client()
	GCCommon_Do_Modal_Globe_Refresh()
	GCCommon_Update_Region_Tooltip()
	GCCommon_Start_Available_Game_Polling()
	PGLobby_Start_Heartbeat()
	GCCommon_Init_UI()
	Refresh_UI()
	PGLobby_Post_Hosted_Session_Data()
	GCCommon_Refresh_Region_Ownership_View()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_GLOBAL_CONQUEST })
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Start_Available_Game_Polling()
	if (AvailableGamePolling) then
		return
	end
	DebugMessage("LUA_GLOBAL_CONQUEST: POLLING: Starting available game polling.")
	PGCrontab_Kill_Scheduled_Functions(_GCCommon_Update_Available_Game_Polling)
	AvailableGamePolling = true
	_GCCommon_Update_Available_Game_Polling()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _GCCommon_Update_Available_Game_Polling()

	if (MatchingState == MATCHING_STATE_SEARCHING_FOR_OPPONENT) then
		DebugMessage("LUA_GLOBAL_CONQUEST: POLLING: Currently searching for opponent so suspending game search...")
		return
	end

	-- Only search for sessions if polling is on and we're not searching for an opponent in a specific region.
	if (AvailableGamePolling) then
	
		-- Pump the keepalive system
		PGLobby_Keepalive_Open_Bracket()
		DebugMessage("LUA_GLOBAL_CONQUEST: POLLING: Querying available games.  Next query in " .. tostring(GameSearchInterval))
		GCCommon_Wipe_Region_Populations(CurrentFactionStateList)
		PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_GLOBAL_CONQUEST_QUERY, GameSearchData, true)
		PGCrontab_Schedule(_GCCommon_Update_Available_Game_Polling, 0, GameSearchInterval)
			
	else
		DebugMessage("LUA_GLOBAL_CONQUEST: POLLING: Polling has been disabled.  Discontinuing...")
	end
	
end

-------------------------------------------------------------------------------
-- Does a one-off session refresh outside of the auto-search system.
-- This does not affect the auto-search system in any way so if it will have
-- a negative impact on that system it is up to the caller to manage that.
-------------------------------------------------------------------------------
function GCCommon_Manual_Session_Refresh()
	PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_GLOBAL_CONQUEST_QUERY, GameSearchData, true)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Stop_Available_Game_Polling()
	DebugMessage("LUA_GLOBAL_CONQUEST: *** POLLING *** Turning off available game polling.")
	PGCrontab_Kill_Scheduled_Functions(_GCCommon_Update_Available_Game_Polling)
	AvailableGamePolling = false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Start_Client_Validation_Checking()
	if (ClientValidationChecking) then
		return
	end
	ClientValidationChecking = true
	-- Unlike session polling, we don't want to do this right away, so
	-- schedule it out in the future.
	PGCrontab_Schedule(GCCommon_Do_Client_Validation, 0, CLIENT_VALIDATION_PERIOD, 1)	-- Call once, in n seconds.
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Do_Client_Validation()
	if (ClientValidationChecking) then
		GCCommon_Update_Negotiation_Status(title, true)
		PGLobby_Validate_Local_Session_Data(nil, true, true)
		PGCrontab_Schedule(GCCommon_Do_Client_Validation, 0, CLIENT_VALIDATION_PERIOD, 1)	-- Call once, in n seconds.
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Stop_Client_Validation_Checking()
	ClientValidationChecking = false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Component_Hidden()
	-- Networking
	PGLobby_Hide_Modal_Message()
	GCCommon_Leave_Game(true)
	Unregister_For_Network_Events()
	Global_Conquest_Lobby.End_Modal()
	GCCommon_Stop_Available_Game_Polling()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Back_Clicked()

	if (GCCommon_Is_Status_Dialog_Showing()) then
		-- Do exactly what we do when the "Cancel" button is clicked on the status dialog.
		GCCommon_Back_Out()
		GCCommon_Hide_Status_Dialog()
	end
	GCCommon_Leave_Game()
	GCCommon_Close_Dialog()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Closing_All_Displays()
	if (GCCommon_Is_Status_Dialog_Showing()) then
		-- Do exactly what we do when the "Cancel" button is clicked on the status dialog.
		GCCommon_Back_Out()
		GCCommon_Hide_Status_Dialog()
	else
		GCCommon_Close_Dialog()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Close_Dialog()

	GCCommon_Stop_Available_Game_Polling()
	GCLobbyManager.Cleanup();
	
	-- If the achievement chest is showing hide it.
	if (GCCommon_Is_Medal_Chest_Showing()) then
		Global_Conquest_Lobby.Achievement_Chest.Set_Hidden(true)
	end
	
	if (HostingGame or JoinedGame) then
		GCCommon_Leave_Game()
	end
	
	GCLobbyManager.Set_Lobby_Active(false)
    if (Global_Conquest_Lobby ~= nil) then
        Global_Conquest_Lobby.Get_Containing_Component().Set_Hidden(true)
    end
	
	Unregister_For_Network_Events()
	Global_Conquest_Lobby.End_Modal()
	
	PGLobby_Set_Dialog_Is_Hidden(true)
	this.Get_Containing_Scene().Raise_Event_Immediate("Heavyweight_Child_Scene_Closing", nil, {"Global_Conquest_Lobby"})
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Download_Dialog_Cancelled()
	if (DoingModalGlobeRefresh) then
		On_Back_Clicked()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Novus_Clicked(event_name, source)
	if (GameHasStarted or (not GCSceneInputEnabled)) then
		return
	end
	if (GCCommon_Is_Status_Dialog_Showing()) then 
		return
	end
	GCCommon_Request_Region_Data(PG_FACTION_NOVUS)
	GCCommon_Update_Local_Client()
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Military_Clicked(event_name, source)
	if (GameHasStarted or (not GCSceneInputEnabled)) then
		return
	end
	if (GCCommon_Is_Status_Dialog_Showing()) then 
		return
	end
	GCCommon_Request_Region_Data(PG_FACTION_MILITARY)
	GCCommon_Update_Local_Client()
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Alien_Clicked(event_name, source)
	if (GameHasStarted or (not GCSceneInputEnabled)) then
		return
	end
	if (GCCommon_Is_Status_Dialog_Showing()) then 
		return
	end
	GCCommon_Request_Region_Data(PG_FACTION_ALIEN)
	GCCommon_Update_Local_Client()
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Masari_Clicked(event_name, source)
	if (GameHasStarted or (not GCSceneInputEnabled)) then
		return
	end
	if (GCCommon_Is_Status_Dialog_Showing()) then 
		return
	end
	GCCommon_Request_Region_Data(PG_FACTION_MASARI)
	GCCommon_Update_Local_Client()
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Launch_Game_Clicked()

	-- Early-out if there's no region selected.
	if (SelectedRegion == nil) then
		DebugMessage("LUA_GLOBAL_CONQUEST: Lauch game clicked with no region selected.")
		return
	end
  
	-- Early-out if the launch game button is not enabled.
	if (not Global_Conquest_Lobby.Button_Launch_Game.Is_Enabled()) then
		return
	end

	Global_Conquest_Lobby.Button_Launch_Game.Enable(false)
		
	local dao = MPMapLookup[string.upper(SelectedRegion.Map)]
	GameOptions.map_crc = dao.map_crc
	GameOptions.map_filename_only = SelectedRegion.Map .. ".ted"
	
	-- Validate the user's player name.
	if (LocalClient == nil or LocalClient.name == nil) then
		MessageBox("We currently take your player name from your online profile.\n" ..
					"Please create a LAN session once to simulate.\n" ..
					"Talk to Joe Howes if you have questions.")
		return
	end
	
	-- Set our user info
	GameAdvertiseData[PROPERTY_MAP_NAME_CRC] = SelectedRegion.Index
	PGLobby_Post_Hosted_Session_Data()
	PGCrontab_Kill_Scheduled_Functions(GCCommon_Check_Join_After_Timeout)
	PGCrontab_Schedule(GCCommon_Check_Join_After_Timeout, 0, 5)

	GCCommon_Begin_Opponent_Search()
	
end

-------------------------------------------------------------------------------
-- The logic here is separated out because the quickmatching system needs to
-- be able to call it independently of the launch button being clicked.
-------------------------------------------------------------------------------
function GCCommon_Begin_Opponent_Search()

	GCCommon_Display_Status_Dialog()
	GCCommon_Set_Matching_State(MATCHING_STATE_SEARCHING_FOR_OPPONENT)

	-- User is now searching for an opponent in a specific territory.
	FindJoinableAttemptCount = MAX_FIND_JOINABLE_ATTEMPT_COUNT
	GCCommon_Update_Negotiation_Status(SelectedRegion.Name)
	-- Until we fall into host mode (in 5 seconds) we poll every second.
	DebugMessage("LUA_GLOBAL_CONQUEST: Ramping up available session searching.")
	GameSearchInterval = GAME_SEARCH_INTERVAL_FAST
	GCCommon_Manual_Session_Refresh()
	
end

-------------------------------------------------------------------------------
-- Make sure any text or default decoration is in a presentable state.
-------------------------------------------------------------------------------
function GCCommon_Init_UI()

	-- Percent Conquered
	local text = Get_Game_Text("TEXT_PERCENT_CONQUERED")
	Replace_Token(text, Get_Localized_Formatted_Number(0), 0)
	Global_Conquest_Lobby.Text_Conquer_Percentage.Set_Text(text)
	
	-- Conquer Count
	text = Get_Game_Text("TEXT_MULTIPLAYER_GC_CONQUER_COUNT")
	Replace_Token(text, Get_Localized_Formatted_Number(0), 1)
	Global_Conquest_Lobby.Text_Conquer_Count.Set_Text(text)
	
	-- Region Tint
	local region_set = Get_Default_Global_Conquest_Regions()
	local regions = region_set[CurrentFaction]
	local shade_set = PG_GLOBAL_CONQUEST_SHADE_SETS[CurrentFaction]
	local tint = shade_set.UnconqueredTint
	for _, region in ipairs(regions) do
		GCLobbyManager.Set_Region_Tint(region.Label, tint[1], tint[2], tint[3], tint[4])
	end
			
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_UI()

	local refresh_function = RefreshFunctions[CurrentFaction]
	if (refresh_function ~= nil) then
		refresh_function()
	else
		DebugMessage("LUA_GLOBAL_CONQUEST: ERROR: No refresh function defined for faction: " .. tostring(CurrentFaction))
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_UI_Novus()

	-- Base UI
	this.Novus.Set_Hidden(false)
	this.Military.Set_Hidden(true)
	this.Hierarchy.Set_Hidden(true)
	this.Masari.Set_Hidden(true)

	this.Novus_Highlight.Set_Hidden(false)
	this.Military_Highlight.Set_Hidden(true)
	this.Alien_Highlight.Set_Hidden(true)
	this.Masari_Highlight.Set_Hidden(true)
	
	-- Region Preview UI
	this.Scriptable_Region_Details.Novus_Overlay.Set_Hidden(false)
	this.Scriptable_Region_Details.Military_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Hierarchy_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Masari_Overlay.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_UI_Military()

	-- Base UI
	this.Military.Set_Hidden(false)
	this.Novus.Set_Hidden(true)
	this.Hierarchy.Set_Hidden(true)
	this.Masari.Set_Hidden(true)
	
	this.Military_Highlight.Set_Hidden(false)
	this.Novus_Highlight.Set_Hidden(true)
	this.Alien_Highlight.Set_Hidden(true)
	this.Masari_Highlight.Set_Hidden(true)
	
	-- Region Preview UI
	this.Scriptable_Region_Details.Military_Overlay.Set_Hidden(false)
	this.Scriptable_Region_Details.Novus_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Hierarchy_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Masari_Overlay.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_UI_Alien()

	-- Base UI	
	this.Hierarchy.Set_Hidden(false)
	this.Military.Set_Hidden(true)
	this.Novus.Set_Hidden(true)
	this.Masari.Set_Hidden(true)

	this.Alien_Highlight.Set_Hidden(false)
	this.Military_Highlight.Set_Hidden(true)
	this.Novus_Highlight.Set_Hidden(true)
	this.Masari_Highlight.Set_Hidden(true)
	
	-- Region Preview UI
	this.Scriptable_Region_Details.Hierarchy_Overlay.Set_Hidden(false)
	this.Scriptable_Region_Details.Military_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Novus_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Masari_Overlay.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_UI_Masari()

	-- Base UI
	this.Masari.Set_Hidden(false)
	this.Military.Set_Hidden(true)
	this.Novus.Set_Hidden(true)
	this.Hierarchy.Set_Hidden(true)

	this.Masari_Highlight.Set_Hidden(false)
	this.Military_Highlight.Set_Hidden(true)
	this.Novus_Highlight.Set_Hidden(true)
	this.Alien_Highlight.Set_Hidden(true)
	
	-- Region Preview UI
	this.Scriptable_Region_Details.Masari_Overlay.Set_Hidden(false)
	this.Scriptable_Region_Details.Military_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Novus_Overlay.Set_Hidden(true)
	this.Scriptable_Region_Details.Hierarchy_Overlay.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Scene_Mouse_Move(event, source, key)

	local net_dialog = Global_Conquest_Lobby.Global_Conquest_Net_Dialog

	if (TestValid(net_dialog) and net_dialog.Is_Showing()) then
		return
	end

	GCCommon_Update_Region_At_Cursor()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_Scene_Mouse_Up()

	-- If we're already in a game or are forced to ignore input, don't do anything.
	if (HostingGame or JoinedGame or (not GCSceneInputEnabled)) then
		return
	end
	
	-- If SelectedRegion becomes nil, that means no regions are selected.
	SelectedRegion = AtCursorRegion
	
	GCCommon_Update_Region_Tooltip()
	GCCommon_Refresh_Region_Ownership_View()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_On_My_Online_Profile_Clicked()

	if not TestValid(Global_Conquest_Lobby.Achievement_Chest) then
		local handle = Create_Embedded_Scene("Achievement_Chest", Global_Conquest_Lobby, "Achievement_Chest")
	else
		Global_Conquest_Lobby.Achievement_Chest.Set_Hidden(false)
	end
	Global_Conquest_Lobby.Achievement_Chest.Bring_To_Front()
	GCLobbyManager.Suspend_Input_Processing()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Play_Click() 
	Play_SFX_Event("GUI_Generic_Button_Select")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Play_Alien_Steam() 
	Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Prepare_Fadeout()
	-- We can't call mapped functions from the GUI we have to go through this.
	Prepare_Fades()
end

-------------------------------------------------------------------------------
-- This event is raised whenever the menu system is awakened after a game mode.
-- We're only interested in it if we have spawned a multiplayer game here, so
-- if that flag is not set, we ignore the event.
-------------------------------------------------------------------------------
function GCCommon_On_Menu_System_Activated()

	DebugMessage("LUA_GLOBAL_CONQUEST: Menu system reactivated.")
	local gc_game_was_started = GameHasStarted
	
	GCCommon_Clear_Available_Games()
	GCCommon_Leave_Game()
	GCCommon_Set_Game_Started_Mode(false)
	GCCommon_Enable_GC_Scene_Input(true)
	
	-- If we are no longer connected to XLive, or are now signed in to a silver account, back out to the main menu.
	if ((Net.Get_Signin_State() ~= "online") or (Net.Requires_Locator_Service())) then
		DebugMessage("LUA_GLOBAL_CONQUEST: We are no longer connected to live, or switched to silver account.  Early out...")
		GCCommon_Close_Dialog() 
		return
	end
	
	if (not gc_game_was_started) then
		DebugMessage("LUA_GLOBAL_CONQUEST: Menu system was reactivated but no global conquest game was started.  Early out...")
		return
	end
	
	DebugMessage("LUA_GLOBAL_CONQUEST: Resetting the lobby and re-requesting our globe state.")
	StartGameCalled = false
	Global_Conquest_Lobby.Start_Modal()
	if (SelectedRegion ~= nil) then
		SelectedRegion.ConquerAttempts = SelectedRegion.ConquerAttempts + 1
	end
	GCLobbyManager.Set_Lobby_Active(true)
	
	GCCommon_Do_Modal_Globe_Refresh(true)
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_GLOBAL_CONQUEST })
	
end	

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_On_Mouse_Move(event, source)
	PGMO_Mouse_Move()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_On_Mouse_Right_Down(event, source)
	this.Set_Mouse_Pointer(4)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_On_Mouse_Right_Up(event, source)
	this.Set_Mouse_Pointer(0)
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Is_Medal_Chest_Showing()

	if (TestValid(Global_Conquest_Lobby.Achievement_Chest) and Global_Conquest_Lobby.Achievement_Chest.Is_Showing()) then
		return true
	end
	return false
	
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Create_Status_Dialog()
	if (not TestValid(Global_Conquest_Lobby.Global_Conquest_Net_Dialog)) then
		handle = Create_Embedded_Scene("Global_Conquest_Net_Dialog", Global_Conquest_Lobby , "Global_Conquest_Net_Dialog")
		handle.Set_Screen_Position(DIALOG_X_POS, DIALOG_Y_POS)
		handle.Set_Hidden(true)
	end
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Display_Status_Dialog()
	GCLobbyManager.Suspend_Input_Processing()
	Set_Main_Navigation_Visible(false)
	if (GCCommon_Is_Status_Dialog_Showing()) then
		return
	end
	Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Set_Hidden(false)
	Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Start_Modal()
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Is_Status_Dialog_Showing()
	if (not TestValid(Global_Conquest_Lobby.Global_Conquest_Net_Dialog)) then
		return false
	end
	return (Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Get_Hidden() == false)
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Hide_Status_Dialog()
	Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Set_Hidden(true)
	Global_Conquest_Lobby.Global_Conquest_Net_Dialog.End_Modal()
	GCLobbyManager.Resume_Input_Processing()
	Set_Main_Navigation_Visible(true)
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Display_Win_Dialog()
	GCLobbyManager.Suspend_Input_Processing()
	Set_Main_Navigation_Visible(false)
	if (TestValid(Global_Conquest_Lobby.Global_Conquest_Win_Dialog)) then
		Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Set_Hidden(false)
	else
		local handle = Create_Embedded_Scene("Global_Conquest_Win_Dialog", Global_Conquest_Lobby , "Global_Conquest_Win_Dialog")
		Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Set_Screen_Position(DIALOG_X_POS, DIALOG_Y_POS)
	end
	Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Start_Modal()
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Hide_Win_Dialog()
	Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Set_Hidden(true)
	GCLobbyManager.Resume_Input_Processing()
	Set_Main_Navigation_Visible(true)
end

------------------------------------------------------------------------------
-- Update the region tooltip with the data specific to the SelectedRegion.
------------------------------------------------------------------------------
function GCCommon_Update_Region_Tooltip()

	if (SelectedRegion == nil) then
		-- The cursor is NOT over a region.
		Global_Conquest_Lobby.Scriptable_Region_Details.Text_Region_Name.Set_Text(EMPTY)
		Global_Conquest_Lobby.Scriptable_Region_Details.Text_Players_Contesting.Set_Text(EMPTY)
		Global_Conquest_Lobby.Scriptable_Region_Details.Set_Hidden(true)
		PGMO_Clear()
		PGMO_Set_Enabled(false)
		Global_Conquest_Lobby.Scriptable_Region_Details.Set_Hidden(true)
		Global_Conquest_Lobby.Button_Launch_Game.Enable(false)
		return
	end

	Global_Conquest_Lobby.Scriptable_Region_Details.Set_Hidden(false)
	if (GCCommon_Is_Status_Dialog_Showing()) then
		Global_Conquest_Lobby.Button_Launch_Game.Enable(false)
	else
		Global_Conquest_Lobby.Button_Launch_Game.Enable(true)
	end
		
	-- The cursor is over a region.
	if (GARY_DEBUG) then
		local gary = tostring(SelectedRegion.Name) .. ": " .. tostring(SelectedRegion.Label)
		Global_Conquest_Lobby.Scriptable_Region_Details.Text_Region_Name.Set_Text(gary)
	else
		Global_Conquest_Lobby.Scriptable_Region_Details.Text_Region_Name.Set_Text(SelectedRegion.Name)
	end

	-- JLH 1/10/2008:  Conquer attempts may or may not be implemented.  For now it is disabled.
	--[[local wstr_conquer = Get_Game_Text("TEXT_REGION_CONQUER_ATTEMPTS")
	Replace_Token(wstr_conquer, Get_Localized_Formatted_Number(SelectedRegion.ConquerAttempts), 0)
	Global_Conquest_Lobby.Scriptable_Region_Details.Text_Conquer_Attempts.Set_Text(wstr_conquer)--]]

	local wstr_contesting = Get_Game_Text("TEXT_REGION_NUM_CONTESTING")
	local player_count = 0
	if (SelectedRegion.PlayerCount ~= nil) then
		player_count = SelectedRegion.PlayerCount
	end
	Replace_Token(wstr_contesting, Get_Localized_Formatted_Number(player_count), 0)
	Global_Conquest_Lobby.Scriptable_Region_Details.Text_Players_Contesting.Set_Text(wstr_contesting)

	local texture_name = SelectedRegion.Map
	if (Global_Conquest_Lobby.Scriptable_Region_Details.Quad_Map_Preview.Set_Texture(texture_name) == false) then
		Global_Conquest_Lobby.Scriptable_Region_Details.Quad_Map_Preview.Set_Texture(NO_MAP_PREVIEW_IMAGE)
	end
	Global_Conquest_Lobby.Scriptable_Region_Details.Quad_Map_Preview.Set_Render_Mode(0)

	Global_Conquest_Lobby.Scriptable_Region_Details.Set_Hidden(false)

	-- Map Overlay
	local map_dao = MPMapLookup[string.upper(texture_name)]
	if (map_dao) then
		PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions)
		PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
		PGMO_Set_Enabled(true)
	end
	
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Update_Region_At_Cursor(force)

	if (force == nil) then
		force = false
	end
	
	local new_label = GCLobbyManager.Update_Subobject_At_Cursor()

	-- No change in the under cursor region.
	if ((not force) and (new_label == nil)) then
		return
	end

	local shade_set = PG_GLOBAL_CONQUEST_SHADE_SETS[CurrentFaction]
	local tint

	-- There is an under-cursor change, so reset the tint of the current region.
	if (AtCursorRegion ~= nil) then
	
		tint = Get_At_Cursor_Region_Tint(AtCursorRegion, SelectedRegion, shade_set)
		GCLobbyManager.Set_Region_Tint(AtCursorRegion.Label, tint[1], tint[2], tint[3], tint[4])
		
	end

	if (new_label == nil) then
	
		-- The object under the cursor has not changed since the last call, so
		-- make no change to the AtCursorRegion.
		
	elseif (new_label == "") then
	
		-- There is now NO region under the cursor.
		AtCursorRegion = nil
		
	else
	
		-- There is a NEW region under the cursor.
		if (CurrentFactionStateLookup ~= nil) then
			AtCursorRegion = CurrentFactionStateLookup[new_label]
		end
		
	end

	if (AtCursorRegion ~= nil) then
		tint = shade_set.SelectTint
		GCLobbyManager.Set_Region_Tint(AtCursorRegion.Label, tint[1], tint[2], tint[3], tint[4])
	end
			
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Update_Negotiation_Status(title, request_rebroadcast)

	-- If the dialog isn't showing, don't do anything.
	if (not GCCommon_Is_Status_Dialog_Showing()) then
		return
	end
	
	-- Set the title
	if (title ~= nil) then
		Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Set_Title(title)
	end
	
	-- Set button visibility based on matching state
	local can_start = false
	local can_quickmatch = false
	if (request_rebroadcast == nil) then
		request_rebroadcast = false
	end
	
	-- Can we start?
	local can_start, messages = GCCommon_Check_Game_Start_Conditions(request_rebroadcast)
	if (can_start) then
		Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Set_Message(Get_Game_Text("TEXT_READY_WAITING_FOR_OPPONENT"))
		DebugMessage("LUA_GLOBAL_CONQUEST: ***** GAME READY TO START ... LAUNCHING *****")
		GCCommon_Launch_Game()
	else
		Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Set_Message(messages[1])
	end
	
	-- Quickmatch?
	if (MatchingState == MATCHING_STATE_WAITING_FOR_OPPONENT) then
		can_quickmatch = true
	end
	Global_Conquest_Lobby.Global_Conquest_Net_Dialog.Set_Quickmatch_Button_Visible(can_quickmatch)

end

------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
function GCCommon_Check_Game_Start_Conditions(request_rebroadcast)

	local can_start = true
	local tmp = false
	local messages = {}
	
	if (request_rebroadcast == nil) then
		request_rebroadcast = false
	end
	
	-- Searching for opponents
	if ((MatchingState == MATCHING_STATE_SEARCHING_FOR_OPPONENT) or
		(MatchingState == MATCHING_STATE_QUICKMATCHING)) then
		can_start = false
		local wstr_search = Get_Game_Text("TEXT_SEARCHING_FOR_OPPONENT")
		Replace_Token(wstr_search, WIDE_EMPTY_STRING, 0)
		table.insert(messages, wstr_search)
	end
		
	-- Search failed and we're hosting and still waiting for an opponent to join.
	if (MatchingState == MATCHING_STATE_WAITING_FOR_OPPONENT) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_WAITING_FOR_OPPONENTS"))
	end
		
	-- Data required from the backend.
	local client_data_valid, game_data_valid, server_data_valid = PGLobby_Validate_Local_Session_Data(nil, false, true)
	
	-- Achievement enumeration per player for medals verification.
	if (ENABLE_ACHIEVEMENT_VERIFICATION) then
	
		if (not server_data_valid) then
			can_start = false
			table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
			if (request_rebroadcast) then
				DebugMessage("LUA_GLOBAL_CONQUEST: Achievement data for all players is incomplete.  Re-requesting.")
				PGLobby_Request_All_Profile_Achievements()
			end
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
	
	-- Medal progress stats need to come back before we can start.
	if (ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION and (not MedalProgressStatsRetrieved)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
		if (request_rebroadcast) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Medals progress for all players is incomplete.  Re-requesting.")
			PGLobby_Request_All_Medals_Progress_Stats()
		end
	end
	
	-- Region data required from the backend.
	for common_addr, client in pairs(ClientTable) do
	
		if ((ClientRegionData == nil) or
			(ClientRegionData.player_models == nil) or
			(ClientRegionData.player_models[common_addr] == nil) or
			(ClientRegionData.player_models[common_addr].region_data == nil)) then
			can_start = false
			table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
			if (request_rebroadcast) then
				DebugMessage("LUA_GLOBAL_CONQUEST: GC properties for all players is incomplete.  Re-requesting.")
				PGLobby_Request_Global_Conquest_Properties(common_addr)
			end
			break
		end
		
	end
	
	-- Arbitration data required from the backend.
	if (HostingGame and (not GameArbitrationReady)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
		if (request_rebroadcast) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Host's game arbitration is not ready.  Re-requesting.")
			PGLobby_Begin_Stats_Registration()
		end
	end
	
	-- Local player has clicked the "Start" button indicating they're ready to go.
	-- We're just waiting for the remote player to do the same.
	if (MatchingState == MATCHING_STATE_READY_TO_START) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_READY_WAITING_FOR_OPPONENT"))
	end

	-- Quickmatching
	if (MatchingState == MATCHING_STATE_QUICKMATCHING) then
		can_start = false 
		table.insert(messages, Get_Game_Text("TEXT_SEARCHING_OPPONENTS_IN_UNCONQUERED_TERRITORY"))
	end

	return can_start, messages

end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Refresh_Faction_View(new_faction)

	if (new_faction ~= nil) then
		CurrentFaction = new_faction
		Set_Profile_Value(PP_LAST_GLOBAL_CONQUEST_FACTION, CurrentFaction)
	end

	GCCommon_Do_Faction_Icon_Highlight()
	GCCommon_Refresh_Region_Ownership_View()
	GCCommon_Refresh_Global_Conquer_Count()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Do_Faction_Icon_Highlight()
	Global_Conquest_Lobby.Faction_Icon.Set_Texture(FactionTextures[CurrentFaction])
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- N E T W O R K   E V E N T S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Central message processor.
-- All the NMP_* functions are called from here.
-------------------------------------------------------------------------------
function GCCommon_Network_On_Message(event)

	-- If we're in a game, ignore all messages.
	if (GameHasStarted) then
		return
	end

	local clear_accepts = false
	local client = Network_Get_Client(event.common_addr)
	if (client == nil) then
		DebugMessage("LUA_NET: ERROR: Recieved a message from an unknown client at address: " .. tostring(event.common_addr))
		return
	end
	
	local message_processor = NetworkMessageProcessors[event.message_type]
	if (message_processor == nil) then
		DebugMessage("LUA_GLOBAL_CONQUEST:  WARNING: No network message processor registered for event: " .. tostring(event.message_type))
		return
	else
		local result = message_processor(event, client)
		if (result) then
			clear_accepts = true
		end
	end
	
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Validate_All_Client_Info()

	local player_count = 0

	for _, client in pairs(ClientTable) do
		player_count = player_count + 1
		if (client.name == nil or
			client.faction == nil or
			client.color == nil or
			client.team == nil or
			client.AcceptsGameSettings == nil or
			client.AcceptsGameSettings == false) then
			return false
		end
	end

	if (player_count ~= 2) then
		return false
	end

	return true

end

-------------------------------------------------------------------------------
-- Called when someone issues a join/leave request for our game.
-------------------------------------------------------------------------------
function GCCommon_Network_On_Connection_Status(event)

	DebugMessage("Network_On_Connection_Status -- status: " .. tostring(event.status))

	if event.status == "join_accepted" then

	elseif event.status == "connected" then

		-- Raised when we join a game.
		if (JoinedGame == false) then
		
			if (not HostingGame) then
				PGCrontab_Kill_Scheduled_Functions(GCCommon_Confirm_Game_Has_Started)
				PGCrontab_Schedule(GCCommon_Confirm_Game_Has_Started, 0, GAME_NEGOTIATION_TIMEOUT)
			end
	
			JoinedGame = true
			
			Set_Client_Table(event.clients)
			GCCommon_Update_Local_Client()
			-- If we're hosting, then we're going to wait for someone to join.  If not, then we've joined someone's game and
			-- we're ready to rock.
			if (HostingGame) then
				GCCommon_Set_Matching_State(MATCHING_STATE_WAITING_FOR_OPPONENT)
				GCCommon_Update_Negotiation_Status(SelectedRegion.Name)
				CurrentlyJoinedSession.common_addr = LocalClient.common_addr
				PGLobby_Set_Local_Session_Open(true)
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
			else
				local region = CurrentFactionStateList[Net.Get_Number_From_64Bit_String(CurrentlyJoinedSession.map_crc)]
				GCCommon_Set_Matching_State(MATCHING_STATE_FOUND_OPPONENT)
				GCCommon_Update_Negotiation_Status(region.Name)
				-- We're the guest, it's 1v1, so request both player's data.
			end
			
			PGLobby_Request_All_Profile_Achievements()
			GCCommon_Request_Required_Global_Conquest_Data()
			
			-- Now, give everybody a moment to receive our join notification, and then spam our settings.
			PGCrontab_Schedule(Send_User_Settings, 0, 1)
			if (HostingGame) then
				PGCrontab_Schedule(Broadcast_Game_Settings, 0, 1)
			end
		
			-- Every few seconds, we are going to check our ClientTable and make sure we know everything
			-- about everyone and all the game settings.
			if (not HostingGame) then
				GCCommon_Start_Client_Validation_Checking()
			end
			
			-- If we're the host, we've just joined our own game and there's no need yet to request medal stats.
			-- If we're not the host, then joining is going to cause the game to start and we need medal stats
			-- for both players.
			if ((not HostingGame) and ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then PGLobby_Request_All_Medals_Progress_Stats() end
				
		end

	elseif event.status == "join_failed" then
	
		-- Raised if we failed to join a session.
		DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ---->  ERROR: Join attempt failed.  Restarting search...")
		
		local game = GCCommon_Get_Best_Joinable_Foreign_Game()		-- Try to join the next game in the region.
		if (game ~= nil) then
			DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ---->  There are more games in this region.  Attempting to join the next one: " .. tostring(game.name))
			GCCommon_Leave_Game(false)
			local ok = GCCommon_Join_Global_Conquest_Game(game)
			if (not ok) then
				DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ERROR!!!  Fast fail ... switching to host.")
				Network_Leave_Game()
				GCCommon_Host_Global_Conquest_Game()
			end
		else
			-- JOE TODO : Flip to hosting.
			DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ---->  No more games in this region to attempt joining.  Switch to hosting...")
			Network_Leave_Game()
			GCCommon_Host_Global_Conquest_Game()
		end
		
	elseif event.status == "session_connect" then

		-- Raised when someone else joins our game.
		
		-- If the session is closed, players should ignore new joiners and the host should boot them.
		if (PGLobbyLocalSessionOpen == false) then
		
			if (HostingGame) then
				Network_Refuse_Player(event.common_addr)
			end

		else
		
			PGCrontab_Kill_Scheduled_Functions(GCCommon_Confirm_Game_Has_Started)
			PGCrontab_Schedule(GCCommon_Confirm_Game_Has_Started, 0, GAME_NEGOTIATION_TIMEOUT)
	
			-- We can't report the player to the chat window yet because we don't know the name,
			-- so we queue this player for reporting later when we recieve the name.
			ClientTable[event.common_addr] = { ["common_addr"] = event.common_addr }
			Network_Add_Client(event.common_addr)
			
			GCCommon_Stop_Available_Game_Polling()
			
			if (ENABLE_ACHIEVEMENT_VERIFICATION) then PGLobby_Request_Profile_Achievements(event.common_addr) end
			
			-- Now, give everybody a moment to receive this player's join notification and then spam our settings.
			PGCrontab_Schedule(Send_User_Settings, 0, 1)
			GCCommon_Request_Required_Global_Conquest_Data()
			
			if (HostingGame) then
			
				-- Check our player count.  For Global Conquest it should always be 2, but
				-- we'll make it an N count for when Global Conquest becomes N players :) .
				if (Network_Get_Client_Table_Count() >= CurrentlyJoinedSession.max_players) then
					PGLobby_Set_Local_Session_Open(false)
				end
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
				
				GCCommon_Set_Matching_State(MATCHING_STATE_FOUND_OPPONENT)
				GCCommon_Update_Negotiation_Status(SelectedRegion.Name)
				PGLobby_Begin_Stats_Registration()
				PGCrontab_Schedule(Broadcast_Game_Settings, 0, 1)
				GCCommon_Start_Client_Validation_Checking()
				-- We're the host, it's 1v1, so request both player's data.
				PGLobby_Request_All_Profile_Achievements()
				
				-- Our guest will already be asking the backend for medal stats, now it's the host's turn.
				if (ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then PGLobby_Request_All_Medals_Progress_Stats() end
				
			end
		
		end

	elseif event.status == "session_disconnect" then
	
		GCCommon_Handle_Session_Disconnect(event)

	else

	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Handle_Session_Disconnect(event)

	if (not GameHasStarted) then
	
		if (event ~= nil) then
		
			-- ** Wipe out this player's presence. **
			if (ProfileAchievements ~= nil) then
				ProfileAchievements[event.common_addr] = nil
			end
			if (ClientRegionData ~= nil) then
				ClientRegionData.player_models[event.common_addr] = nil
			end
			
		end
			
		GCCommon_Hide_Status_Dialog()
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_GC_OTHER_PLAYER_HAS_LEFT"))
		GCCommon_Set_Matching_State(MATCHING_STATE_NONE)
		GCCommon_Leave_Game()
		if (SelectedRegion ~= nil) then
			Global_Conquest_Lobby.Button_Launch_Game.Enable(true)
		end
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Confirm_Game_Has_Started()

	DebugMessage("LUA_GLOBAL_CONQUEST: Confirm game has started!!!!")
	
	if (GameHasStarted) then
		DebugMessage("LUA_GLOBAL_CONQUEST: YES ... game has started.  No need to D/C.")
		return
	end
	DebugMessage("LUA_GLOBAL_CONQUEST: NO ... game has not started.  D/C coming...")
	GCCommon_Handle_Session_Disconnect()
	
end
	
-------------------------------------------------------------------------------
-- Network_On_Find_Session - Called on a successful Net.X_Find_All() operation.
-------------------------------------------------------------------------------
function GCCommon_Network_On_Find_Internet_Session(event)

	DebugMessage("LUA_GLOBAL_CONQUEST: POLLING: Received session list.")
	
	PGLobby_Keepalive_Close_Bracket()
	
	BusyFindingSessions = false
	GCCommon_Build_Available_Games(event.sessions)
	GCCommon_Refresh_Region_List_Model(CurrentFactionStateList)
	GCCommon_Update_Region_Tooltip()
	GCCommon_Refresh_Region_Ownership_View()

	if ((not AvailableGamePolling) or (JoinedGame)) then
		return
	end
	
	-- Act depending on our current state.
	if (MatchingState == MATCHING_STATE_QUICKMATCHING) then
	
		-- Quickmatching:  Look through all the regions in our current faction view.
		-- The first time we find an open session in a region we have not yet conquered,
		-- we attempt a join there.
		local conquered_region_sessions = {}
		local unconquered_region_sessions = {}
		for _, region in ipairs(CurrentFactionStateList) do
		
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Looking in region " .. tostring(region.Name) .. " [" .. tostring(region.ConqueredStatus) .. "]")
				
			-- If there are no games in this region we cannot join any.
			local joinable = (region.PlayerCount > 0)
			
			-- The first few searches we look only in unconquered regions.
			if ((QuickmatchRequestCounter < QUICKMATCH_OPEN_SEARCH_THRESHOLD) and region.ConqueredStatus) then
				joinable = false
			end
		
			if (joinable) then
			
				local dao = {}
				dao.game = region.Games[1]
				dao.region = region
			
				if (region.ConqueredStatus) then
					DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Adding possible conquered region session...")
					table.insert(conquered_region_sessions, dao)
				else
					DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Adding possible unconquered region session...")
					table.insert(unconquered_region_sessions, dao)
				end
				
			end
			
		end
		
		-- The first few searches we look only in unconquered regions.
		if (QuickmatchRequestCounter < QUICKMATCH_OPEN_SEARCH_THRESHOLD) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Below open search threshold.")
		else
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Above open search threshold.")
		end
			
		-- Narrow down to one session, preference given to unconquered regions.
		local target_dao = nil
		if (#unconquered_region_sessions > 0) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Found an unconquered session!!!")
			target_dao = unconquered_region_sessions[1]
		elseif (#conquered_region_sessions > 0) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Found a conquered session!!!")
			target_dao = conquered_region_sessions[1]
		else
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> No valid sessions found.  Waiting for next round...")
		end
		
		-- If we've finally found a valid session, join it!!
		if (target_dao ~= nil) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Quickmatch Status -> Joining session!!!!!")
			SelectedRegion = target_dao.region 
			GCCommon_Join_Global_Conquest_Game(target_dao.game)
		end
				
		QuickmatchRequestCounter = QuickmatchRequestCounter + 1

	elseif (MatchingState == MATCHING_STATE_SEARCHING_FOR_OPPONENT) then
	
		DebugMessage("LUA_GLOBAL_CONQUEST: Searching for an opponent...")
			
		-- If the user wants to join a region, we're either going to join an existing game
		-- (if we've found one), or we'll host one and wait for another player.
		if (SelectedRegion ~= nil and FindJoinableAttemptCount >= 0) then
	
			-- Increment the joinable attempt count only if the query is completely done.
			if (event.more_results == false) then
				FindJoinableAttemptCount = FindJoinableAttemptCount - 1
			end
			GCCommon_Update_Negotiation_Status(SelectedRegion.Name)
			local game = GCCommon_Get_Best_Joinable_Foreign_Game(true)		-- True means reset the counter for the current region.
			if (game ~= nil) then
	
				DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ---->  Attempting to join game: " .. tostring(game.name))
				GCCommon_Leave_Game(false)
				local ok = GCCommon_Join_Global_Conquest_Game(game)
				if (not ok) then
					DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ERROR!!!  Fast fail ... switching to host.")
					Network_Leave_Game()
					GCCommon_Host_Global_Conquest_Game()
				end
	
			elseif (game == nil and FindJoinableAttemptCount <= 0) then
	
				-- No joinable games found, so host your own!
				DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ---->  FINISHED: Unable to find any sessions....hosting...")
				FindJoinableAttemptCount = -1
				Network_Leave_Game()
				GCCommon_Host_Global_Conquest_Game()
		
			end
			
		else
	
			DebugMessage("LUA_GLOBAL_CONQUEST: JOIN ATTEMPT ---->  Not attempting a join: SelectedRegion: '" .. tostring(SelectedRegion) .. "',  FindJoinableAttemptCount: '" .. tostring(FindJoinableAttemptCount) .. "'")
				
		end
		
	end

end

-------------------------------------------------------------------------------
-- When the GC stats are recieved
-------------------------------------------------------------------------------
function GCCommon_On_Query_GC_Stats(event)

	-- We shouldn't get this callback without an address set so we know whose data we're getting.
	local client = Network_Get_Client(event.common_addr)
	local local_common_addr = Net.Get_Local_Addr()
	if ((client == nil) and (event.common_addr ~= local_common_addr)) then 
		DebugMessage("LUA_GLOBAL_CONQUEST: Received global conquest stats for a client not joined to session or local.  Ignoring...")
		return
	end
	
	SupressProfileDownloadingMessage = true
				
	if (event.type == NETWORK_EVENT_TASK_COMPLETE) then
	
		local label = event.common_addr
		if ((client ~= nil) and (client.name ~= nil)) then
			label = client.name
		end
		DebugMessage("LUA_GLOBAL_CONQUEST: COMPLETE---------------> Recieve global conquest data for: " .. tostring(label))
		GCCommon_Process_Region_Data(event.gc_data, event.common_addr)
		
	end
	
	GCCommon_Update_Negotiation_Status()
	Refresh_UI()
	GCCommon_Refresh_Region_Ownership_View()
		
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function GCCommon_On_Enumerate_Achievements(event)

	if (GCCommon_Is_Medal_Chest_Showing()) then
		return
	end

	-- We shouldn't get this callback without an address set so we know whose data we're getting.
	local client = Network_Get_Client(event.common_addr)
	local local_common_addr = Net.Get_Local_Addr()
	if ((client == nil) and (event.common_addr ~= local_common_addr)) then 
		DebugMessage("LUA_GLOBAL_CONQUEST: Received achievement enumeration for a client not joined to this session.  Ignoring...")
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
			DebugMessage("LUA_GLOBAL_CONQUEST: COMPLETE---------------> Recieve profile achievements for: " .. tostring(label))
			ProfileAchievements[client.common_addr] = event.achievements
		end
		
	end
	
	GCCommon_Update_Negotiation_Status()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_On_Query_Medals_Progress_Stats(event)

	if (GCCommon_Is_Medal_Chest_Showing()) then
		return
	end

	-- We're not interested in the results of a medal progress query because code intercepts it
	-- and does what it needs to do.  At this level we just need to know that the stats roundtrip
	-- happened successfully.  Since it's an aggregated query, if we get one set of stats we know 
	-- we have them all.
	if (event.type == NETWORK_EVENT_TASK_COMPLETE) then
		MedalProgressStatsRetrieved = true
	end
		
end	

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function GCCommon_Network_On_Live_Connection_Changed(event)

	-- If we're in a game, let the game logic handle the disaster.  We will respond here
	-- when the menu system is reawakened.
	if (GameHasStarted) then
		return
	end

	DebugMessage("LUA_GLOBAL_CONQUEST: Live connection changed.")
	
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
		DebugMessage("LUA_GLOBAL_CONQUEST: Live connection has become unrecoverable.  Quitting to main menu.")
		GCCommon_Hide_Status_Dialog()
		PGCrontab_Schedule(GCCommon_Leave_Game, 0, 2)
		PGCrontab_Schedule(GCCommon_Close_Dialog, 0, 3)
	end

	-- On Xbox, silver players cannot play multiplayer games
	if Is_Xbox() and Net.Requires_Locator_Service() then
		PGCrontab_Schedule(GCCommon_Leave_Game, 0, 2)
		PGCrontab_Schedule(GCCommon_Close_Dialog, 0, 3)
	end
					
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

	client.name = dao.name
	client.platform = dao.platform
	client.faction = tonumber(dao.faction)
	client.team = tonumber(dao.team)
	client.color = tonumber(dao.color)
	if (dao.applied_medals ~= nil) then
		client.applied_medals = dao.applied_medals
	end
	client.reset_globe = dao.reset_globe
	-- NAT type is irrelevant in CtW, so we don't check it at all.
	
	DebugMessage("LUA_GLOBAL_CONQUEST: Received user settings for player '" .. tostring(client.name) .. "'")

	return true
		
end

-------------------------------------------------------------------------------
-- All game settings at once.
-------------------------------------------------------------------------------
function NMP_All_Game_Settings(event, client)

	-- Ignore these if they're not from the host.
	if (event.common_addr ~= CurrentlyJoinedSession.common_addr) then
		DebugMessage("LUA_GLOBAL_CONQUEST::  Game settings change request from someone other than the host!")
	end
	
	if (HostingGame) then
		return
	end
	
	local dao = event.message
	
	-- Update general flags and settings
	GCCommon_Update_New_Game_Script_Data(dao.game_script_data)
	
	GameOptions.seed = dao.seed
	DebugMessage("LUA_GLOBAL_CONQUEST: Host seed for this session: " .. tostring(GameOptions.seed))
	
	-- Update general flags and settings
	GameScriptData = dao.game_script_data
	
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Start_Game(event, client)

	GCCommon_Enable_GC_Scene_Input(false)
	GCCommon_Hide_Status_Dialog()
	PGCrontab_Schedule(Do_Start_Game, 0, 1)
	
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function GCCommon_Do_Start_Game()

	PGCrontab_Kill_Scheduled_Functions(GCCommon_Check_Join_After_Timeout)
	PGCrontab_Kill_Scheduled_Functions(GCCommon_Confirm_Game_Has_Started)
	GCCommon_Stop_Client_Validation_Checking()
	
	-- Do we have the synchronized region data?
	if (ClientRegionData == nil) then
		local message = Get_Game_Text("TEXT_COMMS_ERROR_CODE_GENERIC_02")
		Replace_Token(message, GENERIC_NETWORK_ERROR_001, 1)
		PGLobby_Display_Modal_Message(message)
		DebugMessage("LUA_GLOBAL_CONQUEST: ERROR: Attempt to start a global conquest game without region data available.")
		return false
	end

	Global_Conquest_Lobby.End_Modal()
	
	-- Convert faction IDs to string constants
	PGLobby_Convert_Faction_IDs_To_Strings()

	Network_On_Start_Game()

	-- Now that the game is started, update the ClientTable with all the newly-assigned
	-- player IDs.
	Update_Clients_With_Player_IDs()

	if (not GCCommon_Finalize_Sync_Region_Data()) then
		local message = Get_Game_Text("TEXT_COMMS_ERROR_CODE_GENERIC_02")
		Replace_Token(message, GENERIC_NETWORK_ERROR_002, 1)
		PGLobby_Display_Modal_Message(message)
		DebugMessage("LUA_GLOBAL_CONQUEST: ERROR: Unable to finalize synced region data.")
		return false
	end
	
	-- Hand off the client table to the game scoring script.
	-- Need to store off the game options
	GameScriptData.GameOptions = GameOptions
	GameScriptData.profile_achievements = ProfileAchievements
	GameScriptData.client_region_data = ClientRegionData

	--JOE DBG YOU HAVE TO INCLUDE THE FUNCTIONALITY FROM ACHIEVEMENTS FOR SET_PLAYER_INFO_TABLE()!!!!!!
	Set_Player_Info_Table(ClientTable)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
	local ranked = GameOptions.ranked
	if (ranked == nil) then
		ranked = false
	end
	GameScoringManager.Set_Is_Global_Conquest_Game(true)
	GameScoringManager.Set_Is_Ranked_Game(ranked)
	GameScoringManager.Set_Is_Custom_Multiplayer_Game(false)
	GameScoringManager.Set_Is_Disconnect_Detected(false)

	GCCommon_Set_Game_Started_Mode(true)
	SelectedRegion = nil
	
	return false

end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Player_Name(event, client)
	client.name = event.message
	return false
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Player_Faction(event, client)
	client.faction = event.message
	return false
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Player_Color(event, client)
	client.color = tonumber(event.message)
	return false
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Player_Team(event, client)
	client.team = tonumber(event.message)
	return false
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Player_Accepts(event, client)

	local client_addr = event.message
	local foreign_client = Network_Get_Client(client_addr)

	if (foreign_client == nil) then
		DebugMessage("ERROR:  No local copy of the settings-accepting client.  Cannot set acceptance.")
	else
		foreign_client.AcceptsGameSettings = true
		if (HostingGame and GCCommon_Validate_All_Client_Info()) then
			Network_Broadcast_Start_Game_Signal()
		end
	end
	
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Applied_Medals(event, client)
	client.applied_medals = event.message
	GCCommon_Update_Negotiation_Status()
	return false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Reset_Globe(event, client)
	client.reset_globe = event.message
	GCCommon_Update_Negotiation_Status()
	return false
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Stats_Registration_Begin(event, client)

	local nonce = event.message

	if HostingGame == false then
		DebugMessage("LUA_ARBITRATION: GUEST: Recieved nonce from host: " .. tostring(nonce))
		PGLobby_Request_Stats_Registration(nonce)
	else
		DebugMessage("LUA_ARBITRATION: HOST: Recieved my nonce broadcast back: " .. tostring(nonce))
		Network_Broadcast(MESSAGE_TYPE_STATS_CLIENT_REGISTERED, "")
	end
	
	GCCommon_Update_Negotiation_Status()
	
	return false
	
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Stats_Client_Registered(event, client)

	DebugMessage("LUA_ARBITRATION: GUEST [%s] -- client.StatsRegistered = true.", tostring(client.name))
	client.StatsRegistered = true

	if HostingGame and Check_Stats_Registration_Status() == true and HostStatsRegistration == false then
		DebugMessage("LUA_ARBITRATION: HOST: PGLobby_Request_Stats_Registration")
		HostStatsRegistration = true
		GameArbitrationReady = true
		PGLobby_Request_Stats_Registration("0")
	end
	
	GCCommon_Update_Negotiation_Status()
	
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Heartbeat(event, client)

	if (HostingGame) then
	
		local dao = event.message
		local local_count = Network_Get_Client_Table_Count()
		if (dao.client_count ~= local_count) then
			local message = Get_Game_Text("TEXT_LOBBY_CLIENT_COUNT_OOS")
			Replace_Token(message, client.name, 1)
			PGLobby_Display_Modal_Message(message)
		end
	
	end
	
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
		Network_Broadcast(MESSAGE_TYPE_STATS_CLIENT_REGISTERED, "")
	end
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

	CurrentlyJoinedSession = session
	Network_Update_Session(CurrentlyJoinedSession)

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- M I S C 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Update_New_Game_Script_Data(game_script_data)
	
	-- Set our new game settings
	GameScriptData = game_script_data
	GameOptions = GameScriptData.GameOptions
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Join_Global_Conquest_Game(game)

	GCCommon_Stop_Available_Game_Polling()
	PGLobby_Start_Heartbeat()
	GameSearchInterval = GAME_SEARCH_INTERVAL_SLOW
	-- Found a joinable game, so join it!
	FindJoinableAttemptCount = -1
	StartGameCalled = false
	GameArbitrationReady = false
	JoinedGame = false
	HostingGame = false
	ClientTable = {}
	GCCommon_Reset_Game_Script_Data()
	ProfileAchievements = {}
	ClientRegionData = nil 				-- MUST be nil on init
	MedalProgressStatsRetrieved = false
	GCCommon_Set_Global_Conquest_Game_Options()
	LocalClient = {}
	LocalClient.color = 15
	LocalClient.team = 2
	GCCommon_Update_Local_Client()
	CurrentlyJoinedSession = game
	PGCrontab_Kill_Scheduled_Functions(GCCommon_Check_Join_After_Timeout)
	PGCrontab_Schedule(GCCommon_Check_Join_After_Timeout, 0, 5)
	return Network_Join_Game(game)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Check_Join_After_Timeout()

	DebugMessage("LUA_GLOBAL_CONQUEST: GCCommon_Check_Join_After_Timeout")
	
	local proper_matching_state = ((MatchingState == MATCHING_STATE_SEARCHING_FOR_OPPONENT) or (MatchingState == MATCHING_STATE_QUICKMATCHING))
		
	if (proper_matching_state and (JoinedGame == false) and (HostingGame == false)) then
	
		-- If we're searching in a specific region, we force hosting.  If we're quickmatching, we "reboot" quickmatch search.
		if (MatchingState == MATCHING_STATE_SEARCHING_FOR_OPPONENT) then
	
			-- Force hosting.
			DebugMessage("LUA_GLOBAL_CONQUEST: Timeout after Find Opponent clicked.  Forcing host mode...")
			GCCommon_Leave_Game(false)
			GCCommon_Host_Global_Conquest_Game()
		
		elseif (MatchingState == MATCHING_STATE_QUICKMATCHING) then
		
			-- "Reboot" quickmatch search.
			DebugMessage("LUA_GLOBAL_CONQUEST: Timeout after failed quickmatch join.  Restarting quickmatch...")
			On_Net_Status_Quickmatch()
			
		end
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Host_Global_Conquest_Game(game)

	GCCommon_Stop_Available_Game_Polling()
	PGLobby_Start_Heartbeat()
	GameSearchInterval = GAME_SEARCH_INTERVAL_SLOW
	
	--local game_name = Generate_Game_Name(SelectedRegion.Label)
	StartGameCalled = false
	GameArbitrationReady = false
	JoinedGame = false
	HostingGame = false
	ClientTable = {}
	GCCommon_Reset_Game_Script_Data()
	ProfileAchievements = {}
	ClientRegionData = nil 					-- MUST be nil on init
	GCCommon_Set_Global_Conquest_Game_Options()
	MedalProgressStatsRetrieved = false
	
	-- GameOptions
	GameOptions.seed = GameRandom.Free_Random(RANDOM_MIN, RANDOM_MAX)
	DebugMessage("LUA_LOBBY: Generating new host seed: " .. tostring(GameOptions.seed))
	GameScriptData.GameOptions = GameOptions

	-- Hardcode color and team.
	LocalClient = {}
	LocalClient.color = 5
	LocalClient.team = 1
	GCCommon_Update_Local_Client()
	
	local session_data = {}
	session_data.name = LocalClient.name
	session_data.map_crc = SelectedRegion.Index
	session_data.max_players = 2
	session_data.ranked = true
	local result = PGLobby_Create_Session(session_data)
	if (result == nil or result == false) then
		MessageBox("INTERNAL ERROR: Unable to create session.")
		DebugMessage("Unable to create a Global Conquest session: " .. tostring(game_name))
	else
		HostingGame = true
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Set_Global_Conquest_Game_Options()

	-- Game Options
	GameOptions.ranked = true
	GameOptions.starting_credit_level = PG_FACTION_CASH_MEDIUM
	GameOptions.pop_cap_override = DEFAULT_POPULATION_CAP
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Update_Local_Client()

	-- GCCommon Address
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
	LocalClient.faction = CurrentFaction

	-- Color
	LocalClient.color = 2
	if (JoinedGame) then
		if (HostingGame) then
			LocalClient.color = 7
		else
			LocalClient.color = 2
		end
	end

	-- Team
	LocalClient.team = -99
	if (JoinedGame) then
		if (HostingGame) then
			LocalClient.team = 1
		else
			LocalClient.team = 2
		end
	end

	-- Medals
	LocalClient.applied_medals = Get_Locally_Applied_Medals(LocalClient.faction)

	-- Reset Globe?
	-- If the world has been conquered (indicated by a negative global conquer count) and the user wants
	-- their local view of the globe to reset as well, we need to indicate that in-game so that can be
	-- written to the arbitrated leaderboard.
	LocalClient.reset_globe = false
	local globe_reset_state = Get_Conquered_Globe_Reset_Flag()
	if ((CurrentFactionMetaData ~= nil) and						-- Faction hasn't been specified yet.
		(CurrentFactionMetaData.GlobalConquerCount < 0) and 	-- Backend says globe is not reset.
		(globe_reset_state == GLOBE_RESET_STATE_HAS_MADE_CHOICE_RESET)) then					-- User wants globe reset.
		LocalClient.reset_globe = true
	end

	-- SEND IT!
	if (JoinedGame) then
		Send_User_Settings()
	end
	
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  Name: " .. tostring(LocalClient.name))
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  Faction: " .. tostring(LocalClient.faction))
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  Team: " .. tostring(LocalClient.team))
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  Color: " .. tostring(LocalClient.color))
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  Color: " .. tostring(LocalClient.color))
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  # of Offline Achievements: " .. tostring(LocalClient.TotalOfflineAchievements))
	DebugMessage("LUA_GLOBAL_CONQUEST: Local Client:  # of Online Achievements: " .. tostring(LocalClient.TotalOnlineAchievements))


end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Leave_Game(for_dialog_close)

	PGCrontab_Kill_Scheduled_Functions(GCCommon_Check_Join_After_Timeout)
	PGCrontab_Kill_Scheduled_Functions(GCCommon_Confirm_Game_Has_Started)
	GCCommon_Stop_Client_Validation_Checking()
	PGLobby_Stop_Heartbeat()
	
	Network_Leave_Game()
	if (HostingGame) then
		Network_Stop_Session()
	end
	JoinedGame = false
	HostingGame = false
	StartGameCalled = false
	GameArbitrationReady = false
	ClientTable = {}
	
	if (not for_dialog_close) then
		GCCommon_Start_Available_Game_Polling()
	end
	
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Launch_Game()

	local name = nil
	if (SelectedRegion ~= nil) then
		name = SelectedRegion.Name
	end
	GCCommon_Set_Matching_State(MATCHING_STATE_READY_TO_START)
	GCCommon_Update_Negotiation_Status(name, Get_Game_Text("TEXT_READY_WAITING_FOR_OPPONENT"))
	Broadcast_Game_Settings_Accept(true, true)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function GCCommon_Back_Out()

	PGCrontab_Kill_Scheduled_Functions(GCCommon_Check_Join_After_Timeout)
	GCCommon_Set_Matching_State(MATCHING_STATE_NONE)
	GCCommon_Leave_Game()
	if (SelectedRegion ~= nil) then
		Global_Conquest_Lobby.Button_Launch_Game.Enable(true)
	end
	GCLobbyManager.Resume_Input_Processing()
	Set_Main_Navigation_Visible(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Reset_Global_Conquest()

	Set_Conquered_Globe_Reset_Flag(GLOBE_RESET_STATE_HAS_MADE_CHOICE_RESET)
	GCCommon_Refresh_Region_Ownership_View()
	GCCommon_Update_Region_Tooltip()
	this.Focus_First()
	GCLobbyManager.Resume_Input_Processing()
	Set_Main_Navigation_Visible(true)
	
end

-------------------------------------------------------------------------------
-- User wants his view of the globe to stay "conquered-looking".
-------------------------------------------------------------------------------
function GCCommon_Leave_Globe_Conquered()

	Set_Conquered_Globe_Reset_Flag(GLOBE_RESET_STATE_HAS_MADE_CHOICE_LEAVE_CONQUERED)
	GCCommon_Refresh_Region_Ownership_View()
	GCCommon_Update_Region_Tooltip()
	this.Focus_First()
	GCLobbyManager.Resume_Input_Processing()
	Set_Main_Navigation_Visible(true)
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Heavyweight_Child_Scene_Closing()
	PGLobby_Activate_Movies()
	GCLobbyManager.Resume_Input_Processing()
	Set_Main_Navigation_Visible(true)
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- When the game is done and the region is to be awarded, both players should
-- have identical views otherwise the territory will not be awarded to the 
-- winner.
--
-- To start this off, we just request our local region data from the server, 
-- and the callback on response in GCCommon_Process_Region_Data() will detect we are in 
-- a session and request the data for the other player.
-------------------------------------------------------------------------------
function GCCommon_Request_Required_Global_Conquest_Data()

	GCCommon_Update_Local_Client()
	
	if (ClientRegionData == nil) then
		ClientRegionData = {}
		ClientRegionData.player_models = {}
	end
			
	-- Get only the data we're missing.
	for client_addr, client in pairs(ClientTable) do
		if (ClientRegionData.player_models[client_addr] == nil) then
			PGLobby_Request_Global_Conquest_Properties(client_addr)
		end
	end
	
end

-------------------------------------------------------------------------------
-- To be called after players have been assigned IDs
-------------------------------------------------------------------------------
function GCCommon_Finalize_Sync_Region_Data()

	ClientRegionData.contested_region_id = SelectedRegion.Index
	
	-- Put ALL the data we know about every client into the player models
	for common_addr, player_data in pairs(ClientRegionData.player_models) do
		local client = Network_Get_Client(common_addr)
		player_data.client_data = client
	end
	
	return true
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Begin_Quickmatch(refresh_immediate)

	PGCrontab_Kill_Scheduled_Functions(GCCommon_Check_Join_After_Timeout)
	PGCrontab_Kill_Scheduled_Functions(GCCommon_Confirm_Game_Has_Started)
	QuickmatchRequestCounter = 0
	GCCommon_Set_Matching_State(MATCHING_STATE_QUICKMATCHING)
	GCCommon_Display_Status_Dialog()
	GCCommon_Update_Negotiation_Status(Get_Game_Text("TEXT_SEARCHING"))
	if (refresh_immediate) then
		GCCommon_Wipe_Region_Populations(CurrentFactionStateList)
		PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_GLOBAL_CONQUEST_QUERY, GameSearchData, true)
	end
	
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Set_Matching_State(state)

	if (MatchingState == state) then
		-- No change...do nothing...
		return
	end
	
	MatchingState = state
	
	if (MatchingState == MATCHING_STATE_SEARCHING_FOR_OPPONENT) then
	
		if (SelectedRegion == nil) then
			MessageBox("STATE MACHINE ERROR\nSearching for opponent but SelectedRegion is nil...")
			return
		end

	end
	

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Clear_Available_Games()

	GCCommon_Wipe_Region_Populations(CurrentFactionStateList)
	
	if not CurrentFactionStateList then
		return
	end
	
	-- Clear the region populations.
	for i, region in ipairs(CurrentFactionStateList) do
		region.PlayerCount = 0
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Build_Available_Games(sessions_list)

	local found_hosted_game = false

	-- Refresh the list of available games, taking note of either the game we've hosted
	-- or Global Conquest games that are viable for us to join.
	if (sessions_list) then

		for i, session in ipairs(sessions_list) do
		
			local is_joinable = PGLobby_Is_Game_Joinable(session)
			if (is_joinable) then
		
				--AvailableGames[i] = session
				table.insert(AvailableGames, session)
	
				if ((session.common_addr == LocalClient.common_addr) and HostingGame) then
	
					-- If the common_addr of the game is our own, store it as a local hosted game.
					found_hosted_game = true
	
				elseif (SelectedRegion ~= nil) then
	
					-- If the user has selected a region to play in and we find a valid open
					-- session for that region, we'll store it.
					-- TODO:  When we have access to ping times, we'll take the min.
					local is_gc, region_label = GCCommon_Check_GC_Session(session)
					if (is_gc and region_label == SelectedRegion.Label) then
						table.insert(SelectedRegionGames, session)
					end

				end
				
			end
			
		end

	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Get_Best_Joinable_Foreign_Game(reset)

	if (reset) then
		JoinableForeignGameIndex = 1
	else
		JoinableForeignGameIndex = JoinableForeignGameIndex + 1
	end
	
	-- Check some base cases.
	if (SelectedRegionGames == nil or SelectedRegionGames[JoinableForeignGameIndex] == nil) then
		-- There ARE no games for the selected region
		return nil
	end
	
	local limit = #SelectedRegionGames
	local result = nil
	
	-- Loop through the remaining sessions until we find an acceptable one.
	while (JoinableForeignGameIndex <= limit) do
	
		local game = SelectedRegionGames[JoinableForeignGameIndex]
		if (game.common_addr ~= LocalClient.common_addr) then			-- Don't join your own game.
			result = game
			break
		end
		JoinableForeignGameIndex = JoinableForeignGameIndex + 1
		
	end
	
	return result
	
end

-------------------------------------------------------------------------------
-- Given a faction id, returns the user's conquest data married with the 
-- data for each region.
-------------------------------------------------------------------------------
function GCCommon_Request_Region_Data(faction_id)

	DebugMessage("LUA_GLOBAL_CONQUEST: Requesting global conquest state from backend...")
	PGLobby_Request_Global_Conquest_Properties()
	GCCommon_Set_Current_Faction(faction_id)

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Process_Region_Data(raw_props, region_data_addr)

	DebugMessage("LUA_GLOBAL_CONQUEST: Received global conquest data from the backend!")
	
	local full_props = nil
	
	if (not JoinedGame) then
	
		GCCommon_End_Modal_Globe_Refresh()
		DebugMessage("LUA_GLOBAL_CONQUEST: Refreshing local region view.")
		
		-- We are just refreshing our local display data.
		if (raw_props == nil) then
			DebugMessage("LUA_GLOBAL_CONQUEST: This player has no global conquest stats, creating base stats.")
			full_props = Get_Default_Global_Conquest_Regions()
		else
			DebugMessage("LUA_GLOBAL_CONQUEST: Merging player's backend stats with display data.")
			full_props = PG_GC_Merge_Regions_From_Load(raw_props)
		end
		
		RootStateMap = full_props
		GCCommon_Set_Current_Faction()
		
		return
		
	end
	
	-- If we are in a game and this callback is being invoked, it is because 
	-- we need to put together all the region data for both players in the
	-- game.  
	if (JoinedGame) then
	
		-- If we get here then we need to make sure we're assembling totally clean 
		-- copies of the region set.
		if (raw_props == nil) then
			full_props = PG_GC_Create_Clean_Region_Set()
		else
			full_props = PG_GC_Merge_Regions_From_Load(raw_props)
		end
		
		ClientRegionData.player_models[region_data_addr] = {}
		ClientRegionData.player_models[region_data_addr].region_data = full_props
	
	end
	
	GCCommon_Update_Negotiation_Status()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Set_Current_Faction(faction_id)

	DebugMessage("LUA_GLOBAL_CONQUEST: Setting new faction view: " .. tostring(faction_id))

	if (faction_id ~= nil) then
		CurrentFaction = faction_id
	end
	
	-- When this function is called from the request, the RootStateMap will still be nil.
	if (RootStateMap == nil) then
		return
	end

	-- Get the list for the specified faction and update it with currently known available games.
	CurrentFactionStateList = RootStateMap[CurrentFaction]
	GCCommon_Refresh_Region_List_Model(CurrentFactionStateList)

	-- Create a lookup keyed by label.
	CurrentFactionStateLookup = {}
	for _, region in ipairs(CurrentFactionStateList) do
		CurrentFactionStateLookup[region.Label] = region
	end
	
	-- Get the meta data for the specified faction.
	CurrentFactionMetaData = RootStateMap[CurrentFaction].MetaData
	
	-- If the global conquer flag on the backend is cleared, make sure to clear the
	-- local reset-the-globe flag (ask Joe Howes....it's a real pain).
	-- The global conquer flag on the backend is actually not a flag, we just check the sign
	-- of the global conquer count.  If it's negative, the globe has been conquered but
	-- not reset, if it's positive, it hasn't been conquered.
	local globe_reset_state = Get_Conquered_Globe_Reset_Flag()
	if ((CurrentFactionMetaData.GlobalConquerCount >= 0) and
		(globe_reset_state ~= GLOBE_RESET_STATE_HAS_MADE_CHOICE_LEAVE_CONQUERED)) then
		Set_Conquered_Globe_Reset_Flag(GLOBE_RESET_STATE_HAS_NOT_MADE_CHOICE)
	end

	GCCommon_Refresh_Faction_View(CurrentFaction)
	GCCommon_Update_Region_At_Cursor(true)
	
	local win = GCCommon_Is_Global_Conquest_Won()
	if (win) then
		GCCommon_Display_Win_Dialog()
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Is_Global_Conquest_Won()

	if (CurrentFactionStateList == nil) then
		DebugMessage("ERROR:  Unable to determine win state of global conquest because there is no state list.")
		return false
	end

	-- SEVERE COMPLICATION:
	-- Since we can only write to the backend in an arbitrated session, we will get into a
	-- state of "global conquer limbo" where the user has conquered the globe, all the regions have
	-- had their conquered status set to false, but the user may or may not want to be showing the
	-- globe as "conquered".  This aesthetic is supported by several flags which are explained when used.
	local globe_reset_state = Get_Conquered_Globe_Reset_Flag()
	local all_regions_conquered = GCCommon_Check_All_Regions_Conquered()
	
	-- If the conquer count is negative, that indicates that the user has recently conquered the globe.
	-- The positive-and-all-territories-won check is a paranoia check that should never happen.
	if ((CurrentFactionMetaData.GlobalConquerCount < 0) or
		((CurrentFactionMetaData.GlobalConquerCount >= 0) and (all_regions_conquered))) then
	
		if (globe_reset_state == GLOBE_RESET_STATE_HAS_MADE_CHOICE_RESET) then
			-- The user wants the globe reset.
			return false
		else
			-- The user wants to see all the conquered regions.
			return true
		end

	end

	-- If we have no result yet, just tabulate the territories
	for _, region in ipairs(CurrentFactionStateList) do
		if (region.ConqueredStatus == false) then
			return false
		end
	end
	
	return result

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_Region_List_Model(source_region_list)
	if (source_region_list == nil) then
		return nil
	end
	local model = GCCommon_Fill_Region_Populations(source_region_list)
	return model
end

-------------------------------------------------------------------------------
-- Iterates through ALL regions and sets shading according to conquered
-- status.
-------------------------------------------------------------------------------
function GCCommon_Refresh_Region_Ownership_View()

	if (CurrentFactionStateList == nil) then
		return
	end
	
	DebugMessage("LUA_GLOBAL_CONQUEST: *** Refreshing Region Ownership View ***")
	
	local shade_set = PG_GLOBAL_CONQUEST_SHADE_SETS[CurrentFaction]
	local total = 0
	local conquered = 0
	
	-- SEVERE COMPLICATION:
	-- Since we can only write to the backend in an arbitrated session, we will get into a
	-- state of "global conquer limbo" where the user has conquered the globe, all the regions have
	-- had their conquered status set to false, but the user may or may not want to be showing the
	-- globe as "conquered".  This aesthetic is supported by several flags which are explained when used.
	local regions_conquered_override = GCCommon_Get_Regions_Conquered_Override()
	
	DebugMessage("LUA_GLOBAL_CONQUEST: Regions Conquered Override: " .. tostring(regions_conquered_override))
	
	GCLobbyManager.Clear_All_Icons()
	
	-- Set up the region display data.
	for _, region in ipairs(CurrentFactionStateList) do

		total = total + 1
		local tint = shade_set.UnconqueredTint
		local conquered_flag = region.ConqueredStatus
		if (regions_conquered_override ~= nil) then
			conquered_flag = regions_conquered_override
		end
		
		-- Place faction icon on conquered regions.
		if (conquered_flag) then
			conquered = conquered + 1
			tint = shade_set.ConqueredTint
			if (not GARY_DEBUG) then
				GCLobbyManager.Add_Region_Icon(region.Label, RegionIcons[CurrentFaction])
			end
			GCLobbyManager.Set_Region_Texture(region.Label, CurrentFaction)
		else
			if (not GARY_DEBUG) then
				GCLobbyManager.Add_Region_Icon(region.Label, nil)
			end
			GCLobbyManager.Set_Region_Texture(region.Label, nil)
		end

		-- Place dude icon on unconquered regions with players waiting for matches.
		if ((region.PlayerCount ~= nil) and (region.PlayerCount > 0)) then
		
			-- Don't place a dude if we are hosting a game in this region.
			if (SelectedRegion ~= nil and
				HostingGame and
				(SelectedRegion.Label == region.Label)) then
				-- Don't place an icon.
			else
				-- Place an icon
				GCLobbyManager.Add_Region_Icon(region.Label, NonzeroPopulationIcon, NonzeroPopulationIconScale)
			end

		end
				
		if (GARY_DEBUG) then
			GCLobbyManager.Add_Region_Icon(region.Label, NonzeroPopulationIcon)
		end
		
		-- Reset the tint for all regions except the one the mouse is currently over.
		local update_tint = true
		if ((AtCursorRegion ~= nil) and (AtCursorRegion.Index == region.Index)) then
			update_tint = false
		end
		if ((SelectedRegion ~= nil) and (SelectedRegion.Index == region.Index)) then
			update_tint = false
		end
		if (update_tint) then
			GCLobbyManager.Set_Region_Tint(region.Label, tint[1], tint[2], tint[3], tint[4])
		end

	end
	
	local percentage = (conquered / total) * 100.0
	percentage = Simple_Round(percentage, 0)
	if ((percentage == nil) or (percentage < 0)) then
		percentage = 0
	end
	local text = Get_Game_Text("TEXT_PERCENT_CONQUERED")
	Replace_Token(text, Get_Localized_Formatted_Number(percentage), 0)
	Global_Conquest_Lobby.Text_Conquer_Percentage.Set_Text(text)

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Get_Regions_Conquered_Override()
	
	-- Early out if we don't have any data back from the server yet.
	if (CurrentFactionMetaData == nil) then
		return false
	end
	
	local globe_reset_state = Get_Conquered_Globe_Reset_Flag()
	local all_regions_conquered = GCCommon_Check_All_Regions_Conquered()
	local regions_conquered_override = nil 
	
	-- If the conquer count is negative, that indicates that the user has recently conquered the globe.
	-- The positive-and-all-territories-won check is a paranoia check that should never happen.
	if ((CurrentFactionMetaData.GlobalConquerCount < 0) or
		((CurrentFactionMetaData.GlobalConquerCount >= 0) and (all_regions_conquered))) then
	
		if (globe_reset_state == GLOBE_RESET_STATE_HAS_MADE_CHOICE_RESET) then
			-- The user wants the globe reset.
			regions_conquered_override = false
		else
			-- The user wants to see all the conquered regions.
			regions_conquered_override = true
		end

	end
	
	return regions_conquered_override
	
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Clear_Region_Ownership_View()
	GCLobbyManager.Clear_All_Icons()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Refresh_Global_Conquer_Count()

	local conquer_count = 0
	if (CurrentFactionMetaData ~= nil and CurrentFactionMetaData.GlobalConquerCount ~= nil) then
		conquer_count = CurrentFactionMetaData.GlobalConquerCount
	end
	
	if (conquer_count < 0) then
		conquer_count = conquer_count * -1
	end
	local message = Get_Game_Text("TEXT_MULTIPLAYER_GC_CONQUER_COUNT")
	Replace_Token(message, Get_Localized_Formatted_Number(conquer_count), 1)
	Global_Conquest_Lobby.Text_Conquer_Count.Set_Text(message)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Wipe_Region_Populations(region_list)

	DebugMessage("LUA_GLOBAL_CONQUEST: Wiping region populations...")

	AvailableGames = {}
	SelectedRegionGames = {}
	if (region_list ~= nil) then
		for i, region in ipairs(region_list) do
			region.PlayerCount = 0
			region.Games = nil
		end
	end
	GCCommon_Refresh_Region_Ownership_View()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Fill_Region_Populations(region_list)

	local pop_map = {}

	-- Go through the games we've received back from the net layer.
	for i, game in ipairs(AvailableGames) do
	
		-- Ignore my games for population count.
		if (game.common_addr ~= LocalClient.common_addr) then

			local name = tostring(game.name)
			local len = string.len(name)
			local is_gc, region_label = GCCommon_Check_GC_Session(game)
			if (is_gc) then
			
				local map = nil
				if (pop_map[region_label] == nil) then
					map = {}
					map.Population = 0
					map.Games = {}
					pop_map[region_label] = map
				else
					map = pop_map[region_label]
				end

				if (PGLobby_Is_Session_Open(game)) then
					map.Population = map.Population + 1
					table.insert(map.Games, game)
				end
	
			end
			
		end

	end

	-- Populate the region_list with the population counts we've found,
	-- and place icons in the regions where games are available.
	for i, region in ipairs(region_list) do

		-- Update the region structure
		local map = pop_map[region.Label]
		if (map ~= nil) then
			region.PlayerCount = map.Population
			region.Games = map.Games
		else
			region.PlayerCount = 0
			region.Games = nil
		end

	end

	return region_list

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Check_GC_Session(session)
	if ((session == nil) or (session.name == nil)) then
		return false, nil, nil
	end
	local region = CurrentFactionStateList[Net.Get_Number_From_64Bit_String(session.map_crc)]
	if (region == nil) then
		return false, nil, nil
	end
	local region_label = region.Label
	return true, region_label
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Get_Last_Current_Faction()

	local faction = Get_Profile_Value(PP_LAST_GLOBAL_CONQUEST_FACTION, PG_FACTION_NOVUS)
	
	-- Make sure the value is good.
	if ((faction ~= PG_FACTION_NOVUS) and
		(faction ~= PG_FACTION_ALIEN) and
		(faction ~= PG_FACTION_MILITARY) and
		(faction ~= PG_FACTION_MASARI)) then
		faction = PG_FACTION_NOVUS
	end
	
	return faction
	
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Check_All_Regions_Conquered()

	if (CurrentFactionStateList == nil) then
		return false
	end
	for key, region in ipairs(CurrentFactionStateList) do
		if ((type(key) == "number")  and			-- HACKY:  MetaData field is stored in this table ... ignore it!
			(region.ConqueredStatus ~= nil) and		-- At this point the ConqueredStatus should NEVER be nil.
			(not region.ConqueredStatus)) then
			return false
		end
	end
	return true
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Set_Game_Started_Mode(value)
	GameHasStarted = value
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GCCommon_Enable_GC_Scene_Input(value)

	GCSceneInputEnabled = value
	
	this.Button_Back.Enable(GCSceneInputEnabled)
	this.Button_Tmp_My_Online_Profile.Enable(GCSceneInputEnabled)
	this.Button_Quickmatch.Enable(GCSceneInputEnabled)
	this.Button_Launch_Game.Enable(GCSceneInputEnabled)
	this.Button_Novus.Enable(GCSceneInputEnabled)
	this.Button_Military.Enable(GCSceneInputEnabled)
	this.Button_Alien.Enable(GCSceneInputEnabled)
	this.Button_Masari.Enable(GCSceneInputEnabled)

end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
--Interface = {}


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_Game_Kill_Countdown = nil
	Broadcast_Game_Start_Countdown = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GCCommon_Begin_Quickmatch = nil
	GCCommon_Constants_Init = nil
	GCCommon_Do_Start_Game = nil
	GCCommon_Hide_Win_Dialog = nil
	GCCommon_Initialize_Components = nil
	GCCommon_Network_On_Connection_Status = nil
	GCCommon_Network_On_Find_Internet_Session = nil
	GCCommon_Network_On_Live_Connection_Changed = nil
	GCCommon_Network_On_Message = nil
	GCCommon_On_Alien_Clicked = nil
	GCCommon_On_Back_Clicked = nil
	GCCommon_On_Closing_All_Displays = nil
	GCCommon_On_Component_Hidden = nil
	GCCommon_On_Component_Shown = nil
	GCCommon_On_Download_Dialog_Cancelled = nil
	GCCommon_On_Enumerate_Achievements = nil
	GCCommon_On_Init = nil
	GCCommon_On_Launch_Game_Clicked = nil
	GCCommon_On_Masari_Clicked = nil
	GCCommon_On_Mouse_Move = nil
	GCCommon_On_Mouse_Right_Down = nil
	GCCommon_On_Mouse_Right_Up = nil
	GCCommon_On_My_Online_Profile_Clicked = nil
	GCCommon_On_Novus_Clicked = nil
	GCCommon_On_Military_Clicked = nil
	GCCommon_On_Query_GC_Stats = nil
	GCCommon_On_Query_Medals_Progress_Stats = nil
	GCCommon_On_Scene_Mouse_Move = nil
	GCCommon_On_Scene_Mouse_Up = nil
	GCCommon_On_Update = nil
	GCCommon_Play_Alien_Steam = nil
	GCCommon_Play_Click = nil
	GCCommon_Prepare_Fadeout = nil
	GCCommon_Refresh_UI = nil
	GCCommon_Register_Event_Handlers = nil
	GCCommon_Variables_Init = nil
	GCCommon_Variables_Reset = nil
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
	Network_Add_AI_Player = nil
	Network_Add_Reserved_Players = nil
	Network_Assign_Host_Seat = nil
	Network_Broadcast_Reset_Start_Positions = nil
	Network_Calculate_Initial_Max_Player_Count = nil
	Network_Clear_All_Clients = nil
	Network_Do_Seat_Assignment = nil
	Network_Edit_AI_Player = nil
	Network_Get_Client_By_ID = nil
	Network_Get_Client_From_Seat = nil
	Network_Get_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	Network_Kick_Player = nil
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	OutputDebug = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Get_Preferred_Color = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Mouse_Move = nil
	PGLobby_Passivate_Movies = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Reset = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Player_Solid_Color = nil
	PGLobby_Set_Tooltip_Model = nil
	PGLobby_Update_NAT_Warning_State = nil
	PGLobby_Update_Player_Count = nil
	PGLobby_Validate_NAT_Type = nil
	PGMO_Assign_Random_Start_Position = nil
	PGMO_Assign_Start_Position = nil
	PGMO_Clear_Start_Position_By_Seat = nil
	PGMO_Clear_Start_Positions = nil
	PGMO_Disable_Neutral_Structure = nil
	PGMO_Enable_Neutral_Structure = nil
	PGMO_Get_Assignment_Count = nil
	PGMO_Get_Enabled = nil
	PGMO_Get_First_Empty_Start_Position = nil
	PGMO_Get_Reverse_First_Empty_Start_Position = nil
	PGMO_Get_Saved_Start_Pos_User_Data = nil
	PGMO_Get_Seat_Assignment = nil
	PGMO_Get_Start_Marker_ID = nil
	PGMO_Hide = nil
	PGMO_Is_Seat_Assigned = nil
	PGMO_Restore_Start_Position_Assignments = nil
	PGMO_Save_Start_Position_Assignments = nil
	PGMO_Set_Interactive = nil
	PGMO_Set_Seat_Color = nil
	PGMO_Show = nil
	PGNetwork_Clear_Start_Positions = nil
	PGOfflineAchievementDefs_Init = nil
	PG_GC_Create_Props_From_Lobby = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Local_User_Applied_Medals = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
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
	Validate_Region_Definitions = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	defined = nil
	Kill_Unused_Global_Functions = nil
end

