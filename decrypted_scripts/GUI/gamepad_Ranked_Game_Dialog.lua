if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Ranked_Game_Dialog.lua#29 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Ranked_Game_Dialog.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Joe_Howes $
--
--            $Change: 96947 $
--
--          $DateTime: 2008/04/14 16:25:21 $
--
--          $Revision: #29 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGCrontab")
require("Lobby_Network_Logic")
require("PGOnlineAchievementDefs")
require("PGOfflineAchievementDefs")

ScriptPoolCount = 0


function GUI_Init()

	PGCrontab_Init()
	PGNetwork_Init()
	PGLobby_Vars_Init()
	
	JOIN_STATE_HOST = Declare_Enum(1)
	JOIN_STATE_SEARCHING = Declare_Enum()
	JOIN_STATE_JOIN = Declare_Enum()
	JOIN_STATE_WAITING = Declare_Enum()
	JOIN_STATE_STATS_BROADCAST = Declare_Enum()
	JOIN_STATE_LAUNCHING = Declare_Enum()
	JOIN_STATE_SELECT_FACTION = Declare_Enum()

	MATCH_MODE_RANKED_MATCH	= 0
	MATCH_MODE_QUICK_MATCH_PLAYER = 1 
	MATCH_MODE_QUICK_MATCH_RANKED = 2

	STATE_CHANGE_TIME = 25
	SEARCH_REFRESH = 7

	MEDALS_PROGRESS_REQUEST_TIMEOUT = 10
	
	-- Network Message Processors
	NetworkMessageProcessors = {}
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_PLATFORM]						= NMP_Player_Platform
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_NAME]						= NMP_Player_Name
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_FACTION]					= NMP_Player_Faction
	--NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_TEAM]						= NMP_Player_Team
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_COLOR]						= NMP_Player_Color
	NetworkMessageProcessors[MESSAGE_TYPE_RANKED_SEED]						= NMP_Ranked_Seed
	--NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_SEAT_ASSIGNMENT]			= NMP_Player_Seat_Assignment
	--NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_REQUEST_START_POSITION]	= NMP_Player_Req_Start_Pos
	--NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_ASSIGN_START_POSITION]		= NMP_Player_Assign_Start_Pos
	--NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_CLEAR_START_POSITION]		= NMP_Player_Clear_Start_Pos
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS_ACCEPT]				= NMP_Player_Accepts
	--NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS_DECLINE]			= NMP_Player_Declines
	NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_APPLIED_MEDALS]			= NMP_Player_Applied_Medals
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_START_COUNTDOWN]				= NMP_Game_Start_Countdown
	--NetworkMessageProcessors[MESSAGE_TYPE_GAME_KILL_COUNTDOWN]				= NMP_Game_Kill_Countdown
	NetworkMessageProcessors[MESSAGE_TYPE_GAME_SETTINGS]					= NMP_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_START_GAME]						= NMP_Start_Game
	--NetworkMessageProcessors[MESSAGE_TYPE_RESERVED_PLAYER]					= NMP_Reserved_Player
	--NetworkMessageProcessors[MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS]			= NMP_AI_Player_Details
	--NetworkMessageProcessors[MESSAGE_TYPE_CHAT]								= NMP_Chat_Message
	--NetworkMessageProcessors[MESSAGE_TYPE_REFUSE_PLAYER]					= NMP_Refuse_Player
	--NetworkMessageProcessors[MESSAGE_TYPE_KICK_PLAYER]						= NMP_Kick_Player
	--NetworkMessageProcessors[MESSAGE_TYPE_KICK_AI_PLAYER]					= NMP_Kick_AI_Player
	--NetworkMessageProcessors[MESSAGE_TYPE_KICK_RESERVED_PLAYER]				= NMP_Kick_Reserved_Player
	NetworkMessageProcessors[MESSAGE_TYPE_REBROADCAST_USER_SETTINGS]		= NMP_Rebroadcast_User_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_REBROADCAST_GAME_SETTINGS]		= NMP_Rebroadcast_Game_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_STATS_REGISTRATION_BEGIN]			= NMP_Stats_Registration_Begin
	NetworkMessageProcessors[MESSAGE_TYPE_STATS_CLIENT_REGISTERED]			= NMP_Stats_Client_Registered
	--NetworkMessageProcessors[MESSAGE_TYPE_HOST_RECOMMENDED_SETTINGS]		= NMP_Host_Recommended_Settings
	NetworkMessageProcessors[MESSAGE_TYPE_HEARTBEAT]						= NMP_Heartbeat
	NetworkMessageProcessors[MESSAGE_TYPE_UPDATE_SESSION]						= NMP_Update_Session

	Ranked_Game_Dialog.Register_Event_Handler("On_Menu_System_Activated", nil, On_Menu_System_Activated)
	Ranked_Game_Dialog.Register_Event_Handler("Network_Progress_Bar_Cancelled", nil, On_Back_Clicked)
	Ranked_Game_Dialog.Register_Event_Handler("On_YesNoOk_Yes_Clicked", nil, On_YesNoOk_Yes_Clicked)
	Ranked_Game_Dialog.Register_Event_Handler("On_YesNoOk_No_Clicked", nil, On_YesNoOk_No_Clicked)
	Ranked_Game_Dialog.Register_Event_Handler("On_YesNoOk_Ok_Clicked", nil, On_YesNoOk_Ok_Clicked)
	
	PGLobby_Init_Modal_Message(this)
	PGLobby_Set_Dialog_Is_Hidden(false)
	
	Gamepad_Compatability_Init()

	On_Component_Shown()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Button_Alien()
	Hide_Faction_Selector()
	CustomFaction = PG_FACTION_ALIEN
	Start_Ranked_Game()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Button_Novus()
	Hide_Faction_Selector()
	CustomFaction = PG_FACTION_NOVUS
	Start_Ranked_Game()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Button_Masari()
	Hide_Faction_Selector()
	CustomFaction = PG_FACTION_MASARI
	Start_Ranked_Game()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Alien_Focus()
	this.Panel_Select_Faction.Button_Alien.Set_Tint(1, 1, 1, 1)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Novus_Focus()
	this.Panel_Select_Faction.Button_Novus.Set_Tint(1, 1, 1, 1)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Masari_Focus()
	this.Panel_Select_Faction.Button_Masari.Set_Tint(1, 1, 1, 1)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Alien_Blur()
	this.Panel_Select_Faction.Button_Alien.Set_Tint(1, 1, 1, 0.5)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Novus_Blur()
	this.Panel_Select_Faction.Button_Novus.Set_Tint(1, 1, 1, 0.5)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Masari_Blur()
	this.Panel_Select_Faction.Button_Masari.Set_Tint(1, 1, 1, 0.5)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()
	Close_Dialog()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_No_Clicked()
	Close_Dialog()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_YesNoOk_Ok_Clicked()
	Close_Dialog()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Reset_Faction_Tint()
	this.Panel_Select_Faction.Button_Alien.Set_Tint(1, 1, 1, 1)
	this.Panel_Select_Faction.Button_Novus.Set_Tint(1, 1, 1, 0.5)
	this.Panel_Select_Faction.Button_Masari.Set_Tint(1, 1, 1, 0.5)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Button_Random()
	Start_Quick_Match_Mode(MATCH_MODE_QUICK_MATCH_RANKED)
	Hide_Faction_Selector()
	CustomFaction = PG_FACTION_ALL
	Start_Ranked_Game()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Start_Faction_Select()
	Update_Progress_Text()
	JoinState = JOIN_STATE_SELECT_FACTION
	Show_Faction_Selector()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Match_Mode_Display_String()
	local message = nil
	if (QuickMatchMode == MATCH_MODE_RANKED_MATCH) then
		message = Get_Game_Text("TEXT_MULTIPLAYER_CUSTOM_RANKED_MATCH_SEARCHING")
	elseif (QuickMatchMode == MATCH_MODE_QUICK_MATCH_RANKED) then
		message = Get_Game_Text("TEXT_GAMEPAD_MULTIPLAYER_RANKED_MATCH_SEARCHING")
	else
		message = Get_Game_Text("TEXT_MULTIPLAYER_QUICK_MATCH_SEARCHING")
	end
	return message
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Start_Ranked_Game()
	local message = Get_Match_Mode_Display_String()
	Update_Progress_Text(message)
	Reset_Ranked_Game()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Start_Quick_Match_Mode(mode)
	QuickMatchMode = mode
	PGLobby_Restart_Networking(NETWORK_STATE_INTERNET)
	Reset_Ranked_Game()
	StateStartTime = 0
	MPMapModel = PGLobby_Generate_Map_Selection_Model()	-- List of multiplayer maps.
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER })
	CustomFaction = PG_FACTION_ALL
	if QuickMatchMode == 0 then
		Start_Faction_Select()
	else
		Hide_Faction_Selector()
		Start_Ranked_Game()
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

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	Net.MM_Leave()
	EarlyTerminate = false
	MedalsProgressRequestTimer = nil
	ReadyToLaunch = false
	Reset_Faction_Tint()
end


-------------------------------------------------------------------------------
-- This event is raised whenever the menu system is awakened after a game mode.
-- We're only interested in it if we have spawned a multiplayer game here, so
-- if that flag is not set, we ignore the event.
-------------------------------------------------------------------------------
function On_Menu_System_Activated()

	if (not GameHasStarted) then
		return
	end

	On_Back_Clicked()
end	

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()

	PGCrontab_Update()

	if Ranked_Game_Dialog.Get_Hidden() then return end

	-- Only update the gamepad if the dialog is visible
	-- Though update it regardless of JoinState
	Gamepad_Update()

	if JoinState == JOIN_STATE_SELECT_FACTION then return end

	local cur_time = Net.Get_Time()
	if JoinState == nil then
		if Math.mod(cur_time*1000, 10) > 5 then
			SearchState = 1
			StateStartTime = Net.Get_Time()
			JoinState = JOIN_STATE_SEARCHING
			Search_For_Games()
		else
			Do_Host_Game()
		end
	end

	if JoinState == JOIN_STATE_HOST and IsLeaving ~= true and cur_time - StateStartTime > (FuzzySearchTime - 2) then
		IsLeaving = true
		Net.MM_Leave()
	elseif JoinState == JOIN_STATE_HOST and cur_time - StateStartTime > FuzzySearchTime then
		IsLeaving = nil
		Reset_Ranked_Game()
		SearchState = 1
		StateStartTime = Net.Get_Time()
		JoinState = JOIN_STATE_SEARCHING
		Search_For_Games()
	elseif JoinState == JOIN_STATE_SEARCHING then
		if cur_time - LastSearchTime > SEARCH_REFRESH then
			Search_For_Games()
		elseif cur_time - StateStartTime > FuzzySearchTime then
			Reset_Ranked_Game()
			Do_Host_Game()
		end
	end
	
	if (JoinedGame and (MedalsProgressRequestTimer ~= nil)) then
	
		local request_rebroadcast = false
		local curr = Net.Get_Time()
		if ((curr - MedalsProgressRequestTimer) > MEDALS_PROGRESS_REQUEST_TIMEOUT) then
			request_rebroadcast = true
			MedalsProgressRequestTimer = curr
		end
	
		local can_start, messages = Check_Game_Start_Conditions(request_rebroadcast)
		if (can_start) then
			Broadcast_Game_Settings_Accept(true, true)
		else
			DebugMessage("LUA_RANKED_MATCH: WARNING: Cannot start game: " .. tostring(messages[1]))
		end
	
	end

	if HostingGame == true and JoinState == JOIN_STATE_WAITING and cur_time - StateStartTime > 5 then
		if QuickMatchMode == 1 then
			Set_Ranked_Seed(RankedSeed)
			JoinState = JOIN_STATE_LAUNCHING
			-- Start the game.
			Network_Broadcast_Start_Game_Signal()
		elseif cur_time - StateStartTime > 5 then
			Set_Ranked_Seed(RankedSeed)
			JoinState = JOIN_STATE_STATS_BROADCAST
			PGLobby_Begin_Stats_Registration()
		end
	end
	
	if HostingGame == true and 								-- We're the host
		JoinState == JOIN_STATE_STATS_BROADCAST and 		-- We're in the stats registration state
		HostStatsRegistrationComplete and 					-- Stats registration has completed successfully
		ReadyToLaunch then										-- All required backend data is gathered
		
		DebugMessage("LUA_RANKED_MATCH: All conditions are ready for game launch!!  Broadcasting start signal!!")
		JoinState = JOIN_STATE_LAUNCHING
		-- Start the game.
		Network_Broadcast_Start_Game_Signal()
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Search_For_Games()
	LastSearchTime = Net.Get_Time()
	if Game_Search_Parameters == nil then
		Game_Search_Parameters = { }
		if (GameOptions.ranked) then
			Game_Search_Parameters[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
			Game_Search_Parameters[PROPERTY_GAME_JOINABLE] = 2
		else
			Game_Search_Parameters[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_STANDARD
			Game_Search_Parameters[PROPERTY_GAME_JOINABLE] = 3
		end
		Game_Search_Parameters[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER
	end

	PGLobby_Refresh_Available_Games(SESSION_MATCH_QUERY_RANKED_QUERY, Game_Search_Parameters, true)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Reset_Ranked_Game()

	GameScriptData = {}
	GameScriptData.victory_condition = VICTORY_CONQUER
	GameScriptData.is_defcon_game = false

	Game_Search_Parameters = nil
	FuzzySearchTime = STATE_CHANGE_TIME - (Math.mod(Net.Get_Time()*1000, 3.14159))

	if GameOptions == nil then GameOptions = {} end

	if QuickMatchMode == 1 then
		GameOptions.ranked = false
	else
		GameOptions.ranked = true
	end
	GameScriptData.GameOptions = GameOptions

	StartGameCountdown = -1
	GameHasStarted = false
	LastSearchTime = 0
	JoinState = nil
	CountdownShowing = false
	CurrentlyJoinedSession = nil
	GameIsStarting = false
	HostingGame = false
	JoinedGame = false
	Recieved_Game_Settings = false
	StartGameCalled = false
	HostStatsRegistration = false
	HostStatsRegistrationComplete = false
	MatchingState = -1
	MedalProgressStatsRetrieved = false

	local endnum = Math.mod(Net.Get_Time()*1000, 100) + 100
	for i = 0, endnum do
		MyRandom_Get()
	end
	RankedSeed = MyRandomSeed
	
	LocalClient = {}
	Update_Local_Client()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Close_Dialog()

	IsPrivateGame = false
	IsPollingAvailableSessions = false
	MedalsProgressRequestTimer = nil
	ReadyToLaunch = false
	Net.MM_Leave()
	Unregister_For_Network_Events()
	last_visibility = nil

	Update_Progress_Text()
	Ranked_Game_Dialog.End_Modal()
	Ranked_Game_Dialog.Get_Containing_Component().Set_Hidden(true)
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Ranked_Game_Dialog"})
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Back_Clicked()
	Close_Dialog()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Broadcast_User_Settings()

	Network_Broadcast(MESSAGE_TYPE_PLAYER_PLATFORM, LocalClient.platform)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_NAME, LocalClient.name)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_FACTION, tostring(LocalClient.faction))
	Network_Broadcast(MESSAGE_TYPE_PLAYER_COLOR, tostring(LocalClient.color))
	-- Network_Broadcast(MESSAGE_TYPE_PLAYER_TEAM, tostring(user_table.team))
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Hide_Faction_Selector()

	this.Panel_Select_Faction.Button_Alien.Set_Tab_Order(-1)
	this.Panel_Select_Faction.Button_Novus.Set_Tab_Order(-1)
	this.Panel_Select_Faction.Button_Masari.Set_Tab_Order(-1)
	this.Panel_Select_Faction.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Show_Faction_Selector()

	this.Panel_Select_Faction.Button_Alien.Set_Tab_Order(Declare_Enum(0))
	this.Panel_Select_Faction.Button_Novus.Set_Tab_Order(Declare_Enum())
	this.Panel_Select_Faction.Button_Masari.Set_Tab_Order(Declare_Enum())
	this.Panel_Select_Faction.Button_Alien.Set_Key_Focus()
	this.Panel_Select_Faction.Set_Hidden(false)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Hide_Progress_Bar()

	Network_Progress_Bar_Active = false
	Ranked_Game_Dialog.Network_Progress_Bar.Stop()
	Ranked_Game_Dialog.Network_Progress_Bar.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Show_Progress_Bar()

	Network_Progress_Bar_Active = true
	Ranked_Game_Dialog.Network_Progress_Bar.Start_Modal()
	Ranked_Game_Dialog.Network_Progress_Bar.Start()
	Ranked_Game_Dialog.Network_Progress_Bar.Set_Hidden(false)
	Ranked_Game_Dialog.Network_Progress_Bar.Claim_Focus()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Query_Medals_Progress_Stats(event)

	-- We're not interested in the results of a medal progress query because code intercepts it
	-- and does what it needs to do.  At this level we just need to know that the stats roundtrip
	-- happened successfully.  Since it's an aggregated query, if we get one set of stats we know 
	-- we have them all.
	MedalProgressStatsRetrieved = true
	DebugMessage("LUA_RANKED_MATCH: Medals progress received for ranked match.")
	
end

-------------------------------------------------------------------------------
-- Called when someone issues a join/leave request for our game.
-------------------------------------------------------------------------------
function Network_On_Connection_Status(event)

	-- Do not handle events if the dialog is not visible because the game has started
	if GameHasStarted then return end

	-- Always update our local client settings first (mainly to ensure our common_addr is up to date).
	Update_Local_Client()
			
	if event.status == "join_accepted" then

	elseif event.status == "connected" then

		-- Raised when we join a game.
		if (JoinedGame == false) then 
		
			JoinedGame = true
			PGLobbyLastHostHeartbeat = nil
			Set_Client_Table(event.clients)

			-- Update status here...
			if (JoinState == JOIN_STATE_HOST) then
				HostingGame = true
				Network_Assign_Host_Seat(LocalClient)
				Ranked_Set_Local_Session_Open(true)
				CurrentlyJoinedSession = event.session
			elseif (JoinState == JOIN_STATE_JOIN) then
				JoinState = JOIN_STATE_WAITING
				if (QuickMatchMode == MATCH_MODE_RANKED_MATCH) then
					Update_Progress_Text(Get_Game_Text("TEXT_MULTIPLAYER_RANKED_MATCH_LAUNCH"))
				else
					Update_Progress_Text(Get_Game_Text("TEXT_MULTIPLAYER_QUICK_MATCH_LAUNCHING"))
				end
			end

			PGLobby_Request_All_Profile_Achievements()
			
			-- Now, give everybody a moment to receive our join notification, and then spam our settings.
			PGCrontab_Schedule(Broadcast_User_Settings, 0, 1)
			if (HostingGame) then
			
				-- Currently we do not differenitate between public and private slots
				CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count()

				-- Check our player count.
				if (CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players) then
					Ranked_Set_Local_Session_Open(false)
				end
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
			end
			
			-- If we're the host, we've just joined our own game and there's no need yet to request medal stats.
			-- If we're not the host, then joining is going to cause the game to start and we need medal stats
			-- for both players.
			if ((not HostingGame) and GameOptions.ranked and ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then 
				DebugMessage("LUA_RANKED_MATCH: Requesting medals progress for this ranked match.")
				ReadyToLaunch = false
				MedalProgressStatsRetrieved = false
				PGLobby_Request_All_Medals_Progress_Stats() 
				MedalsProgressRequestTimer = Net.Get_Time()
			end
		end

	elseif event.status == "session_connect" then

		-- Raised when someone else joins our game.
		
		-- If the session is closed, players should ignore new joiners and the host should boot them.
		if (PGLobbyLocalSessionOpen == false) then
		
			if (HostingGame) then
				Network_Refuse_Player(event.common_addr)
			end

		else

			if (QuickMatchMode == MATCH_MODE_RANKED_MATCH) then
				Update_Progress_Text(Get_Game_Text("TEXT_MULTIPLAYER_RANKED_MATCH_LAUNCH"))
			else
				Update_Progress_Text(Get_Game_Text("TEXT_MULTIPLAYER_QUICK_MATCH_LAUNCHING"))
			end
			JoinState = JOIN_STATE_WAITING
			StateStartTime = Net.Get_Time()
			Network_Add_Client(event.common_addr)
			
			-- Now, give everybody a moment to receive this player's join notification and then spam our settings.
			PGCrontab_Schedule(Broadcast_User_Settings, 0, 1)
			if (HostingGame) then
			
				-- Currently we do not differenitate between public and private slots
				CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count()

				-- Check our player count.
				if (CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players) then
					Ranked_Set_Local_Session_Open(false)
				end
				Network_Update_Session(CurrentlyJoinedSession)
				PGLobby_Post_Hosted_Session_Data()
				PGLobby_Request_All_Profile_Achievements()
				
				-- Our guest will already be asking the backend for medal stats, now it's the host's turn.
				if (GameOptions.ranked and ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then 
					DebugMessage("LUA_RANKED_MATCH: Requesting medals progress for this ranked match.")
					ReadyToLaunch = false
					MedalProgressStatsRetrieved = false
					PGLobby_Request_All_Medals_Progress_Stats()
					MedalsProgressRequestTimer = Net.Get_Time()
				end
			
			end
			
		end
		
	elseif event.status == "session_disconnect" then
	
		EarlyTerminate = true
		Hide_Progress_Bar()
		PGLobby_Display_Modal_Message("TEXT_GC_OTHER_PLAYER_HAS_LEFT")

		
	end

	if (HostingGame) then
		Set_All_Client_Accepts(false)
	end
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_On_Find_Internet_Session(event)

	if JoinState ~= JOIN_STATE_SEARCHING then return end

	if event.sessions then
		for i, session in ipairs(event.sessions) do
			-- Join the first returned game
			JoinState = JOIN_STATE_JOIN
			CurrentlyJoinedSession = session
			MedalProgressStatsRetrieved = false
			Network_Join_Game(session)
		end
	end

end


function Do_Host_Game()

	JoinState = JOIN_STATE_HOST
	SearchState = 2
	StateStartTime = Net.Get_Time()
	ClientTable = {}
	Network_Reset_Seat_Assignments()
	Reset_Local_Client()
	Update_Local_Client()
	local game_name = LocalClient.name
	
	if ((tostring(game_name) == nil) or (tostring(game_name) == "")) then
		DebugMessage("LIVE_PROFILE_GAME_DIALOG: Unable to determine local player name.  Cannot host.")
		PGLobby_Display_Modal_Message(Get_Game_Text("TEXT_CANNOT_HOST_PLAYER_NAME"))
		return
	end

	JoinedGame = false
	HostingGame = false
	MedalProgressStatsRetrieved = false

	local session_data = {}
	session_data.name = game_name
	if QuickMatchMode == 1 then
		session_data.ranked = false
	else
		session_data.ranked = true
	end
	session_data.max_players = 2
	session_data.use_locator = false
	-- Need to add flag to the session data so we can tell the difference
	-- between global conquest and ranked games.

	Set_Host_Game_Settings()
	PGLobby_Create_Session(session_data)
	CurrentlyJoinedSession = session_data

end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function Network_On_Live_Connection_Changed(event)

	-- If we're in a game, let the game logic handle the disaster.  We will respond here
	-- when the menu system is reawakened.
	if (GameHasStarted) then
		return
	end
	
	DebugMessage("LUA_LOBBY: Live connection changed.")
	
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
		DebugMessage("LUA_LOBBY: Live connection has become unrecoverable.  Quitting to main menu.")
		PGCrontab_Schedule(Close_Dialog, 0, 2)
	end

	-- On Xbox, silver players cannot play multiplayer games
	if Is_Xbox() and Net.Requires_Locator_Service() then
		PGCrontab_Schedule(Close_Dialog, 0, 2)
	end
					
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Reset_Local_Client()

	-- Start position
	LocalClient.start_marker_id = nil
	
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Update_Local_Client()

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
	LocalClient.faction = CustomFaction
	
	-- Team
	if (LocalClient.team == nil) then
		LocalClient.team = 1
	end

	-- Color
	if (LocalClient.color == nil) then
		LocalClient.color = 3
	end
	
	-- Medals
-- 	if (NetworkState == NETWORK_STATE_INTERNET) then
-- 		LocalClient.applied_medals = Get_Locally_Applied_Medals(LocalClient.faction)
-- 	else
		LocalClient.applied_medals = nil
--	end
	
	-- Accepts
	if (LocalClient.AcceptsGameSettings == nil) then
		LocalClient.AcceptsGameSettings = false
	end
	
-- 	if (JoinedGame) then
-- 		Broadcast_User_Settings()
-- 	end
--
-- 	DebugMessage("LOCAL_CLIENT:  Name: " .. tostring(LocalClient.name))
-- 	DebugMessage("LOCAL_CLIENT:  Player_ID: " .. tostring(LocalClient.PlayerID))
-- 	DebugMessage("LOCAL_CLIENT:  Faction: " .. tostring(LocalClient.faction))
-- 	DebugMessage("LOCAL_CLIENT:  Team: " .. tostring(LocalClient.team))
-- 	DebugMessage("LOCAL_CLIENT:  Color: " .. tostring(LocalClient.color))
	--DebugMessage("LOCAL_CLIENT:  # of Offline Achievements: " .. tostring(#LocalClient.TotalOfflineAchievements))
	--DebugMessage("LOCAL_CLIENT:  # of Online Achievements: " .. tostring(#LocalClient.TotalOnlineAchievements))

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Preferred_Faction()

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
function Get_Preferred_Team()

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


function Set_Host_Game_Settings()

	if (JoinState ~= JOIN_STATE_HOST) then
		return
	end
	
	local game_settings_data = { }

	-- This is a multiplayer game
	game_settings_data[X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_MULTIPLAYER

	if QuickMatchMode == 1 then
		game_settings_data[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_STANDARD
		game_settings_data[PROPERTY_GAME_JOINABLE] = 3
	else
		game_settings_data[X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_RANKED
		game_settings_data[PROPERTY_GAME_JOINABLE] = 2
	end

	-- Alliances
	GameOptions.alliances_enabled = false
	game_settings_data[PROPERTY_ALLIANCES_ENABLED] = 0
	
	-- Achievements
	GameScriptData.medals_enabled = false
	game_settings_data[PROPERTY_ACHIEVEMENTS_ENABLED] = 0

	-- Victory Condition
	GameScriptData.victory_condition = VICTORY_CONQUER
	game_settings_data[PROPERTY_WIN_CONDITION] = GameScriptData.victory_condition

	-- DEFCON
	GameScriptData.is_defcon_game = false
	game_settings_data[PROPERTY_DEFCON_ENABLED] = 0

	-- Hero Respawn
	GameOptions.hero_respawn = false
	game_settings_data[PROPERTY_HERO_RESPAWN_ENABLED] = 1
	
	-- AI Players
	game_settings_data[PROPERTY_AI_SLOTS] = 0

	local map_dao = MPMapModel[1]		-- MPMapModel is 1-based
	GameOptions.map_crc = map_dao.map_crc
	GameOptions.map_display_name = map_dao.display_name
	GameOptions.map_filename_only = map_dao.file_name_no_extension
	GameOptions.map_preview = map_dao.file_name_no_extension .. ".tga"

	if (CurrentlyJoinedSession ~= nil) then
		CurrentlyJoinedSession.max_players = map_dao.num_players - AIPlayerCount
	end

	-- Starting Credits
	GameOptions.starting_credit_level = PG_FACTION_CASH_MEDIUM
	game_settings_data[PROPERTY_STARTING_CREDITS] = GameOptions.starting_credit_level

	-- Pop Cap Override
	GameOptions.pop_cap_override = 90 
	game_settings_data[PROPERTY_POP_CAP] = GameOptions.pop_cap_override

	-- Make sure that the game is set as joinable
	game_settings_data[CONTEXT_GAME_STATE] = CONTEXT_GAME_STATE_X_GAME_STATE_PUBLIC
	IsGoldOnly = true

	-- Check our player count.
	if JoinedGame then

		-- Currently we do not differenitate between public and private slots
		CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count()

		if (CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players) then
			Ranked_Set_Local_Session_Open(false)
		else
			Ranked_Set_Local_Session_Open(true)
		end

		Network_Update_Session(CurrentlyJoinedSession)

	end

	GameScriptData.GameOptions = GameOptions
	GameAdvertiseData = game_settings_data
	GameAdvertiseData[PROPERTY_PG_NAT_TYPE] = Net.Get_NAT_Type_Constant()

	PGLobby_Post_Hosted_Session_Data()
	
end

------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
function Check_Game_Start_Conditions(request_rebroadcast)

	local can_start = true
	local tmp = false
	local messages = {}
	
	if (request_rebroadcast == nil) then
		request_rebroadcast = false
	end
	
	-- Medal progress stats need to come back before we can start.
	if (GameOptions.ranked and ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION and (not MedalProgressStatsRetrieved)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_SERVER_DATA"))
		if (request_rebroadcast) then
			DebugMessage("LUA_GLOBAL_CONQUEST: Medals progress for all players is incomplete.  Re-requesting.")
			PGLobby_Request_All_Medals_Progress_Stats()
		end
	end
	
	return can_start, messages

end

-------------------------------------------------------------------------------
-- Central message processor.
-- All the NMP_* functions are called from here.
-------------------------------------------------------------------------------
function Network_On_Message(event)

	local clear_accepts = false
	local client = Network_Get_Client(event.common_addr)
	if (client == nil) then
		DebugMessage("LUA_NET: ERROR: Recieved a message from an unknown client at address: " .. tostring(event.common_addr))
		return
	end
	
	local message_processor = NetworkMessageProcessors[event.message_type]
	if (message_processor == nil) then
		DebugMessage("LUA_LOBBY:  WARNING: No network message processor registered for event: " .. tostring(event.message_type))
		return
	else
		message_processor(event, client)
	end
	
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
	client.name = event.message
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Faction(event, client)
	local faction = event.message
	client.faction = tonumber(faction)
	DebugMessage("LUA_NET: I have player " .. tostring(client.name) .. " as faction " .. tostring(client.faction).. "\n")
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Color(event, client)
	client.color = tonumber(event.message)
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Player_Applied_Medals(event, client)
	if (NetworkState == NETWORK_STATE_INTERNET) then
		client.applied_medals = event.message
		return true
	end
	return false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Rebroadcast_User_Settings(event, client)
	Broadcast_User_Settings()
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
		PGLobby_Request_Stats_Registration(event.message)
	else
		Network_Broadcast(MESSAGE_TYPE_STATS_CLIENT_REGISTERED, "")
	end
	
	return false

end


function Update_Progress_Text(value)

	if not TestValid(Ranked_Game_Dialog.Network_Progress_Bar) then
		local handle = Create_Embedded_Scene("Network_Progress_Bar", Ranked_Game_Dialog, "Network_Progress_Bar")
	end
	
	if Network_Progress_Bar_Active == nil then
		Hide_Progress_Bar()
	end

	if value == nil then
		if Network_Progress_Bar_Active then
			Hide_Progress_Bar()
		end
	elseif Network_Progress_Bar_Active ~= true then
		Show_Progress_Bar()
	end


	if value then Ranked_Game_Dialog.Network_Progress_Bar.Set_Message(value) end
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
		PGLobby_Request_Stats_Registration("0")
	end
	
	return false

end


function MyRandom_Get()
	local ret = Math.rand(MyRandomSeed)
	MyRandomSeed = ret[1]
	--OutputDebug("MyRandom_Get -- %s:%f\n", tostring(MyRandomSeed), ret[2])
	return ret[2]
end

function MyRandom_Seed(value)
	OutputDebug("MyRandom_Seed -- %s\n", tostring(value))
	MyRandomSeed = value
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function NMP_Start_Game(event, client)

	-- Check for early termination.
	if (EarlyTerminate) then
		return
	end
	
	Update_Local_Client()
	GameIsStarting = false
	Ranked_Game_Dialog.End_Modal()
	MyRandom_Seed(RankedSeed)

	local valid_map_list = {}
	table.insert(valid_map_list, "M03_WESTERN_EUROPE")
	table.insert(valid_map_list, "M04_EASTERN_EUROPE")
	table.insert(valid_map_list, "M07_TURKESTAN")
	table.insert(valid_map_list, "M08_EASTERN_SIBERIA")
	table.insert(valid_map_list, "M11_KAMCHATKA")
	table.insert(valid_map_list, "M13_INDOCHINA")
	table.insert(valid_map_list, "M16_SAHARA")
	table.insert(valid_map_list, "M17_EAST_AFRICA")
	table.insert(valid_map_list, "M18_NORTH_AFRICA")
	table.insert(valid_map_list, "M20_CONGO")
	table.insert(valid_map_list, "M21_SOUTH_AFRICA")
	table.insert(valid_map_list, "M22_APPALACHIA")
	table.insert(valid_map_list, "M23_GULF_COAST")
	table.insert(valid_map_list, "M26_PACIFIC_NORTHWEST")
	table.insert(valid_map_list, "M29_BRAZILLIAN_HIGHLANDS")
	table.insert(valid_map_list, "M30_ALTIPLANO")
	table.insert(valid_map_list, "M31_AMAZON_BASIN")
	table.insert(valid_map_list, "M33_GUIANA")
	table.insert(valid_map_list, "M34_ANAHUAC")
	table.insert(valid_map_list, "M35_CENTRAL_AMERICA")
	table.insert(valid_map_list, "M45_WASHINGTONDC")
	table.insert(valid_map_list, "M46_ATLATEA")
	table.insert(valid_map_list, "M47_ARECIBO_ASSAULT")

	local available_factions = {}
	table.insert(available_factions, PG_FACTION_NOVUS)
	table.insert(available_factions, PG_FACTION_ALIEN)
	table.insert(available_factions, PG_FACTION_MASARI)

	local available_colors = {}
	table.insert(available_colors, 7)
	table.insert(available_colors, 2)

	-- Check for early termination.
	if (EarlyTerminate) then
		return
	end
	
	local idx
	local icount = 1
	for addr, tclient in pairs(ClientTable) do
		if tclient.faction == PG_FACTION_ALL then 
			idx = Math.floor(Math.mod(MyRandom_Get(), #available_factions)) + 1
			tclient.faction = available_factions[idx]
			-- table.remove(available_factions, idx)
		end

		idx = Math.floor(Math.mod(MyRandom_Get(), #available_colors)) + 1
		tclient.color = available_colors[idx]
		table.remove(available_colors, idx)

		OutputDebug("NMP_Start_Game -- Client: %s, Faction: %d, Color: %d\n", tostring(tclient.name), tclient.faction, tclient.color)
		OutputDebug("NMP_Start_Game -- Client: %s, Addr: %s\n", tostring(tclient.name), tostring(addr))
		OutputDebug("NMP_Start_Game -- Client: %s, Common_Addr: %s\n", tostring(tclient.name), tostring(tclient.common_addr))

		tclient.AcceptsGameSettings = true
		tclient.team = icount
		icount = icount + 1
	end

	-- Check for early termination.
	if (EarlyTerminate) then
		return
	end
	
	local play_maps = {}
	for _, name in ipairs(valid_map_list) do
		for idx, map_info in pairs(MPMapModel) do
			local upper_str = string.upper(map_info.file_name_no_extension)
			if upper_str == name then
				table.insert(play_maps, idx)
			end
		end
	end

	-- Check for early termination.
	if (EarlyTerminate) then
		return
	end
	
	idx = Math.floor(Math.mod(MyRandom_Get(), #play_maps)) + 1
	local map_dao = MPMapModel[play_maps[idx]]		-- MPMapModel is 1-based
	GameOptions.map_crc = map_dao.map_crc
	GameOptions.map_display_name = map_dao.display_name
	GameOptions.map_filename_only = map_dao.file_name_no_extension
	GameOptions.map_preview = map_dao.file_name_no_extension .. ".tga"

	-- Alliances
	GameOptions.alliances_enabled = false
	GameScriptData.medals_enabled = false
	GameScriptData.victory_condition = VICTORY_CONQUER
	GameScriptData.is_defcon_game = false
	GameOptions.hero_respawn = false
	GameOptions.starting_credit_level = PG_FACTION_CASH_MEDIUM
	GameOptions.pop_cap_override = 90 
	GameOptions.seed = MyRandom_Get()
	
	-- Convert faction IDs to string constants
	PGLobby_Convert_Faction_IDs_To_Strings()

	-- Check for early termination.
	if (EarlyTerminate) then
		return
	end
	
	Update_Progress_Text()
	Network_On_Start_Game()

	-- Now that the game is started, update the ClientTable with all the newly-assigned
	-- player IDs.
	Update_Clients_With_Player_IDs()
	
	-- Assign start positions
	GameScriptData.start_positions = nil
    
	-- Hand off the client table to the game scoring script.
	-- Need to store off the game options
	GameScriptData.GameOptions = GameOptions

	Set_Player_Info_Table(ClientTable)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
	local ranked = GameOptions.ranked
	if (ranked == nil) then
		ranked = false
	end
	GameScoringManager.Set_Is_Ranked_Game(ranked)
	GameScoringManager.Set_Is_Global_Conquest_Game(false)
	GameScoringManager.Set_Is_Custom_Multiplayer_Game(false)
	GameScoringManager.Set_Is_Disconnect_Detected(false)
	PGLobby_Save_Vanity_Game_Start_Data(ranked)
	
	GameHasStarted = true
	return true
		
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

function NMP_Ranked_Seed(event, client)
	RankedSeed = event.message
	OutputDebug("NMP_Ranked_Seed -- Client: %s, Set Seed to: %s\n", tostring(client.name), tostring(RankedSeed))
	return true
end

function Set_Ranked_Seed(value)
	Network_Broadcast(MESSAGE_TYPE_RANKED_SEED, value)
end

function Ranked_Set_Local_Session_Open(val)
	PGLobby_Set_Local_Session_Open(val)

	if QuickMatchMode == 1 then
		GameAdvertiseData[PROPERTY_GAME_JOINABLE] = 3
	else
		GameAdvertiseData[PROPERTY_GAME_JOINABLE] = 2
	end

	if val then
		GameAdvertiseData[CONTEXT_GAME_STATE] = CONTEXT_GAME_STATE_X_GAME_STATE_PUBLIC
	else
		GameAdvertiseData[CONTEXT_GAME_STATE] = CONTEXT_GAME_STATE_X_GAME_STATE_PRIVATE
	end
end

-------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function NMP_Player_Accepts(event, client)

	if (not HostingGame) then
		return false
	end

	local client_addr = event.message
	local foreign_client = Network_Get_Client(client_addr)

	if (foreign_client == nil) then
		DebugMessage("LUA_RANKED_MATCH: ERROR:  No local copy of the settings-accepting client.  Cannot set acceptance.")
	else
	
		local launch_game = true
		foreign_client.AcceptsGameSettings = true
		DebugMessage("LUA_RANKED_MATCH: Ready-to-launch indication from player: " .. tostring(foreign_client.name))
		for _, client in pairs(ClientTable) do
			if ((client.AcceptsGameSettings == nil) or (client.AcceptsGameSettings == false)) then
				DebugMessage("LUA_RANKED_MATCH: Still waiting for player '" .. tostring(client.name) .. "' to indicate ready.")
				launch_game = false
				break
			end
		end
		
		if (launch_game) then
			DebugMessage("LUA_RANKED_MATCH: ------------->  All players ready to launch!")
			ReadyToLaunch = true
		end
		
	end
	
	return false
	
end

function Gamepad_Compatability_Init()
	this.Register_Event_Handler("Button_Clicked", this.Panel_Select_Faction.Button_Alien, On_Button_Alien)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Select_Faction.Button_Novus, On_Button_Novus)
	this.Register_Event_Handler("Button_Clicked", this.Panel_Select_Faction.Button_Masari, On_Button_Masari)

	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, On_Button_Random)	
end

function Gamepad_Update()
	if ( this.Panel_Select_Faction.Get_Hidden() ~= last_visibility ) then
		if ( this.Panel_Select_Faction.Get_Hidden() ) then
			this.Panel_Select_Faction.Button_Alien.Set_Tab_Order(-1)
			this.Panel_Select_Faction.Button_Novus.Set_Tab_Order(-1)
			this.Panel_Select_Faction.Button_Masari.Set_Tab_Order(-1)
			this.Network_Progress_Bar.Set_Tab_Order(Declare_Enum())
			this.Focus_First()
		else
			this.Panel_Select_Faction.Button_Alien.Set_Tab_Order(Declare_Enum())
			this.Panel_Select_Faction.Button_Novus.Set_Tab_Order(Declare_Enum())
			this.Panel_Select_Faction.Button_Masari.Set_Tab_Order(Declare_Enum())
			this.Network_Progress_Bar.Set_Tab_Order(-1)
			this.Focus_First()
		end
	end
	
	last_visibility = this.Panel_Select_Faction.Get_Hidden()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Start_Quick_Match_Mode = Start_Quick_Match_Mode


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
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Get_Preferred_Color = nil
	Get_Preferred_Faction = nil
	Get_Preferred_Team = nil
	Is_Player_Of_Faction = nil
	Min = nil
	Network_Add_AI_Player = nil
	Network_Add_Reserved_Players = nil
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
	PGLobby_Activate_Movies = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Display_Custom_Modal_Message = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Get_Preferred_Color = nil
	PGLobby_Hide_Modal_Message = nil
	PGLobby_Is_Game_Joinable = nil
	PGLobby_Keepalive_Close_Bracket = nil
	PGLobby_Keepalive_Open_Bracket = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Mouse_Move = nil
	PGLobby_Passivate_Movies = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Request_Global_Conquest_Properties = nil
	PGLobby_Reset = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Player_Solid_Color = nil
	PGLobby_Set_Tooltip_Model = nil
	PGLobby_Start_Heartbeat = nil
	PGLobby_Stop_Heartbeat = nil
	PGLobby_Update_NAT_Warning_State = nil
	PGLobby_Update_Player_Count = nil
	PGLobby_Validate_Client_Medals = nil
	PGLobby_Validate_Local_Session_Data = nil
	PGLobby_Validate_NAT_Type = nil
	PGNetwork_Clear_Start_Positions = nil
	PGOfflineAchievementDefs_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
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

