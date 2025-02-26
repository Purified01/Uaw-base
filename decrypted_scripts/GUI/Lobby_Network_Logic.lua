if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[7] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Lobby_Network_Logic.lua#36 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Lobby_Network_Logic.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 95141 $
--
--          $DateTime: 2008/03/12 16:56:44 $
--
--          $Revision: #36 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGNetwork")
require("PGPlayerProfile")
require("GUI_Tooltip")


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- T O P   I N I T I A L I Z A T I O N
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Called when this script is initialized by either first entry or coming
-- out of hidden state.
--
-- Call this function once, on creation of the script.
-------------------------------------------------------------------------------
function PGLobby_Vars_Init()

	PGPlayerProfile_Init()
	
	-- ----------------------------------------------------------------------------------------------------------------
	-- Internet network event table.  On event call associated handler.
	-- ----------------------------------------------------------------------------------------------------------------
	Internet_Event_Table = 
	{
		["TASK_MM_CREATE_SESSION"]						= Internet_On_MM_Create_Session,
		["TASK_MM_FIND_SESSION"] 						= Network_On_Find_Internet_Session,
		["TASK_CONNECTION_STATUS"]						= Network_On_Connection_Status,
		["TASK_MM_MESSAGE"]								= Network_On_Message,
		["TASK_MM_STATS_TOKEN_REGISTERED"]			= PGLobby_On_Stats_Registration,
		["TASK_LOBBY_INIT"] 								= Internet_On_Lobby_Init,
		["TASK_MM_QUERY_GC_STATS"]						= On_Query_GC_Stats,
		["TASK_MM_QUERY_MEDALS_PROGRESS_STATS"]	= On_Query_Medals_Progress_Stats,
		["TASK_MM_ENUMERATE_ACHIEVEMENTS"]			= On_Enumerate_Achievements,
		["TASK_VERIFY_CHAT_TEXT"]						= Network_On_Text_Verified,
		["TASK_LIVE_CONNECTION_CHANGED"]				= Network_On_Live_Connection_Changed,
		["TASK_MM_LOCATOR_SERVER_COUNT"]				= Network_On_Locator_Server_Count,
		["TASK_MM_GAMER_PICTURE_RETRIEVED"]			= Network_On_Gamer_Picture_Retrieved,
	}

	-- ----------------------------------------------------------------------------------------------------------------
	-- LAN network event table.  On event call associated handler.
	-- ----------------------------------------------------------------------------------------------------------------
	LAN_Event_Table = 
	{
		["TASK_CONNECTION_STATUS"]						= Network_On_Connection_Status,
		["TASK_MM_MESSAGE"]								= Network_On_Message,
		["TASK_LAN_FIND_SESSION"]						= Network_On_Find_LAN_Session,
		["TASK_LIVE_CONNECTION_CHANGED"]				= Network_On_Live_Connection_Changed,
	}

	PGLobby_Constants_Init()

	-- *** TOOLTIP ***
	GUI_Tooltip_Constants()
	_PGLobbyTooltipHandle = nil
	if (not TestValid(this.GUI_Tooltip)) then
		_PGLobbyTooltipHandle = Create_Embedded_Scene("GUI_Tooltip", this, "GUI_Tooltip")
	end
	_PGLobbyTooltipHandle.Set_Wrapper_Handle(_PGLobbyTooltipHandle)
	PGLobby_Set_Tooltip_Visible(false)
	
	-- *** VARIABLES ***
	NetworkState = nil
	LocalVersionString = Get_Network_Version_Info_String()
	AvailableGames = {}
	PlayerListSelectModel = {}
	if (LocalClient == nil) then
		LocalClient = {}
	end
	LocalClient.team = 1		-- Everyone starts out on team 1.
	HostedGameName = ""
	JoinedGame = false
	if (GameOptions == nil) then
		GameOptions = {}
	end
	GameOptions.seed = 12345
	GameOptions.map_name = MAP_DIRECTORY .. "BMH_Multi_Test.ted"
	GameOptions.map_filename_only = "BMH_Multi_Test.ted"
	GameOptions.is_campaign = false
	FoundGame = nil
	BusyFindingSessions = false
	ColorStore = nil			-- Helps store used player colors to uniqueness can be guaranteed.
	IsPollingAvailableSessions = false
	MPMapModel = {}
	MPMapLookup = {}
	MPCRCLookup = {}
	HostStatsRegistration = false
	HostStatsRegistrationComplete = false
	_PGLobbyThrottledRequestSystemRunning = false
	_PGLobbyThrottledRequestQueue = {}
	_PGLobbyThrottledRequestQueueDAO = nil
	PGLobbyLocalSessionOpen = true
	PGLobbyHeartbeating = false
	PGLobbyBadClientList = {}
	PGLobbyLastHostHeartbeat = nil
	PGLobbyClientDataValid = false
	PGLobbyGameDataValid = false
	_PGLobbyKeepaliveBrackets = 0
	PGLobbyMoviesActive = true
	_PGLobbyLastRebroadcastTimestamp = nil
	PGLobbyDialogIsHidden = true

end

function PGLobby_Constants_Init()

	-- *** CONSTANTS ***
	ENABLE_ACHIEVEMENT_VERIFICATION = (not BETA_BUILD)	-- If BETA_BUILD, disable.
	ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION = (not BETA_BUILD)	-- If BETA_BUILD, disable.
	--ENABLE_ACHIEVEMENT_VERIFICATION = false	-- If BETA_BUILD, disable.
	--ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION = false	-- If BETA_BUILD, disable.
	
	MAX_KEEPALIVE_BRACKET_DELTA = 3
	
	MEDALS_BETA_FLAG = BETA_BUILD 
	NETWORK_STATE_INTERNET = Declare_Enum(1)
	NETWORK_STATE_LAN = Declare_Enum()
	
	GAME_CREDITS_LEVEL_VIEW = {}
	GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_SMALL] = "TEXT_SMALL"
	GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_MEDIUM] = "TEXT_MEDIUM"
	GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_LARGE] = "TEXT_LARGE"
	
	EMPTY = Create_Wide_String("")						-- For clearing out text blocks and edit boxes.
	MISSING = Create_Wide_String("[MISSING]")						-- For clearing out text blocks and edit boxes.
	MAP_DIRECTORY = ".\\Data\\Art\\Maps\\"				-- JOE TODO::  Properly implement multiplayer map enumeration.
	HOST_SEAT_POSITION = 1
	if ( Is_Xbox() ) then
		CLIENT_SEATS_MAX = 4
		DEFAULT_PLAYER_CAP = 4
	else
		CLIENT_SEATS_MAX = 8
		DEFAULT_PLAYER_CAP = 8
	end
	DEFAULT_POPULATION_CAP = 90
	CLIENT_VALIDATION_PERIOD = 10
	HEARTBEAT_INTERVAL = 10
	MINIMUM_REBROADCAST_INTERVAL = 7					-- Clients should only request rebrodcasts every n seconds.
	THROTTLED_REQUEST_QUEUE_PERIOD = 1

	CLUSTER_STATE_FIRST = Declare_Enum(0)
	CLUSTER_STATE_OPEN = CLUSTER_STATE_FIRST
	CLUSTER_STATE_CLOSED = Declare_Enum()
--	CLUSTER_STATE_RESERVED = Declare_Enum()
--	CLUSTER_STATE_LAST = CLUSTER_STATE_RESERVED
	CLUSTER_STATE_LAST = CLUSTER_STATE_CLOSED
	
	PGLOBBY_VALIDATE_CLIENTS_ONLY = Declare_Enum(1)
	
	PGLOBBY_PING_GOOD_MEDIUM_THRESHOLD		= 100
	PGLOBBY_PING_MEDIUM_BAD_THRESHOLD		= 300
	PGLOBBY_PING_GOOD_TEXTURE				= "i_ping_high.tga"
	PGLOBBY_PING_MEDIUM_TEXTURE				= "i_ping_med.tga"
	PGLOBBY_PING_BAD_TEXTURE				= "i_ping_low.tga"
	
	XONLINE_NAT_OPEN						= "XONLINE_NAT_OPEN"
	XONLINE_NAT_MODERATE					= "XONLINE_NAT_MODERATE"
	XONLINE_NAT_STRICT						= "XONLINE_NAT_STRICT"
	
	RANDOM_MIN								= 0
	RANDOM_MAX								= 32766
	
	GENERIC_NETWORK_ERROR_001				= "101"		-- Attempt to start a GC game without region data available. 
	GENERIC_NETWORK_ERROR_002				= "102"		-- Unable to finalize synced region data.
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Reset()
	PGLobbyLocalSessionOpen = true
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Create_Session(session_data)

	-- Occasionally the create session flag will be set before the game name is determined.  
	-- We'll pick it up on the next refresh.
	if (session_data == nil or session_data.name == nil) then
		DebugMessage("LUA_NET: Unable to create a session.  The session data is nil or has no name set.")
		return false
	end
	
	DebugMessage("LUA_LOBBY:  Creating a session: '" .. tostring(session_data.name) .. "'")

	if (ConnectionType == CONNECTION_TYPE_LAN) then
		session_data.SessionOpen = true
	end
	
	local result = Network_Create_Session(session_data)
	_PGLobbyNATWarningFlags = {}
	
	Network_Update_Local_Common_Addr(Net.Get_Local_Addr())
	session_data.common_addr = LocalClient.common_addr
	DebugMessage("LUA_LOBBY:  Session common_addr is: " .. tostring(session_data.common_addr))

	HostingGame = true
	HostedGameName = session_data.name		-- JOE DELETE:  Legacy support for old lobbies.
	CurrentlyJoinedSession = session_data 
	
	return result
	
end

-------------------------------------------------------------------------------
-- This function tests if we have all the neccessary data from each of the
-- other clients, and about the game settings.  If we are missing any data,
-- it requests a rebroadcast.
-------------------------------------------------------------------------------
function PGLobby_Validate_Local_Session_Data(filter, request_rebroadcasts, is_global_conquest)

	local client_data_valid = true
	local game_data_valid = true
	local server_data_valid = true
	if (request_rebroadcasts == nil) then
		request_rebroadcasts = false
	end
	
	-- We need to throttle rebroadcast requests to give slower computers / connections a chance
	-- to catch up.  20 seconds should catch the majority of cases.  We don't want rebroadcasts coming
	-- in before machines have a chance to fully respond to the last rebroadcast.
	if (request_rebroadcasts) then
	
		-- Init
		local curr = Net.Get_Time()
		if (_PGLobbyLastRebroadcastTimestamp == nil) then
			_PGLobbyLastRebroadcastTimestamp = curr
		end
		
		local delta = curr - _PGLobbyLastRebroadcastTimestamp
		
		-- If enough time has passed, allow rebroadcasts, otherwise force them off.
		if (delta >= MINIMUM_REBROADCAST_INTERVAL) then
			_PGLobbyLastRebroadcastTimestamp = curr
		else
			request_rebroadcasts = false
		end
		
	end
	
	-- Check all clients
	local num_clients = 0
	for _, client in pairs(ClientTable) do
		
		num_clients = num_clients + 1
	
		-- Address
		if (client.common_addr == nil) then
			client_data_valid = false
			break
		end
		
		-- Name
		if (client.name == nil) then
			client_data_valid = false
			break
		end
		
		-- Faction
		if (client.faction == nil) then
			client_data_valid = false
			break
		end
		
		-- Color
		if (client.color == nil) then
			client_data_valid = false
			break
		end
		
		-- Team
		if (client.team == nil) then
			client_data_valid = false
			break
		end
		
		-- Human-only stuff
		if (not client.is_ai) then
		
			-- Platform
			if (client.platform == nil) then
				client_data_valid = false
				break
			end
		
			-- Applied medals
			if ((NetworkState == NETWORK_STATE_INTERNET) and 
				(ENABLE_ACHIEVEMENT_VERIFICATION) and 
				(GameScriptData.medals_enabled)) then
				if (client.applied_medals == nil) then
					client_data_valid = false
				end
			end
			
			-- NAT
			if ((NetworkState == NETWORK_STATE_INTERNET) and
				(not is_global_conquest)) then
				if (client.nat_type == nil) then
					client_data_valid = false
				end
			end

		end
		
	end
	
	-- Seat Assignments
	if (client_data_valid and (not is_global_conquest)) then
	
		if (ClientSeatAssignments == nil) then
			client_data_valid = false
		else
	
			local num_seat_assignments = 0
			for _, client in pairs(ClientSeatAssignments) do
				if (client.common_addr ~= nil) then
					num_seat_assignments = num_seat_assignments + 1
				end
			end
			
			if (num_seat_assignments < num_clients) then
				client_data_valid = false
			end
		
		end

	end
	
	if (filter == PGLOBBY_VALIDATE_CLIENTS_ONLY) then
		return client_data_valid
	end
	

	-- Check game settings
	
	-- Map
	if (GameOptions.map_filename_only == nil) then
		game_data_valid = false
	end
	
	-- Victory Conditions
	if (GameScriptData.victory_condition == nil) then
		game_data_valid = false
	end
	
	-- DEFCON
	if (GameScriptData.is_defcon_game == nil) then
		game_data_valid = false
	end
	
	-- Starting Credits
	if (GameOptions.starting_credit_level == nil) then
		game_data_valid = false
	end
	

	-- If there was a problem, request rebroadcast.
	if (not client_data_valid) then
		if (request_rebroadcasts) then
			DebugMessage("LUA_LOBBY:  Client data is incomplete.  Requesting rebroadcast...")
			Network_Broadcast(MESSAGE_TYPE_REBROADCAST_USER_SETTINGS, LocalClient.common_addr)
		else
			DebugMessage("LUA_LOBBY:  Client data is incomplete.")
		end
	end
	
	if (not game_data_valid) then
		if (request_rebroadcasts) then
			DebugMessage("LUA_LOBBY:  Game data is incomplete.  Requesting rebroadcast...")
			Network_Broadcast(MESSAGE_TYPE_REBROADCAST_GAME_SETTINGS, LocalClient.common_addr)
		else
			DebugMessage("LUA_LOBBY:  Game data is incomplete.")
		end
	end
	

	-- Make sure we have all the required backend data.
	if (NetworkState == NETWORK_STATE_INTERNET) then
	
		local client_count = Network_Get_Client_Table_Count(false)
			
		if (ENABLE_ACHIEVEMENT_VERIFICATION and GameScriptData.medals_enabled) then
			local status, missing = PGLobby_Validate_Profile_Achievements(client_count)
			if (not status) then
				server_data_valid = false
				if (request_rebroadcasts) then
					DebugMessage("LUA_LOBBY:  We are missing profile achievements for some players.  Re-requesting...")
					for _, client in ipairs(missing) do
						PGLobby_Request_Profile_Achievements(client.common_addr)
					end
				end
			end
		end
	
		--[[if (ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then
			if (not PGLobby_Validate_Achievement_Stats(client_count)) then
				server_data_valid = false
				if (request_rebroadcasts) then
					DebugMessage("LUA_LOBBY:  We are missing medals progress for some players.  Re-requesting...")
					PGLobby_Request_All_Achievement_Stats()
				end
			end
		end--]]
	
	end
	
	return client_data_valid, game_data_valid, server_data_valid
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Validate_Profile_Achievements(client_count)

	local status = true
	local missing = {}

	-- Go through each client
	for _, client in pairs(ClientTable) do
	
		-- Ignore AI.
		if ((client.is_ai == nil) or (client.is_ai == false)) then
			if ((ProfileAchievements == nil) or
				(ProfileAchievements[client.common_addr] == nil)) then
				status = false
				table.insert(missing, client)
			end
		end
		
	end
	
	return status, missing
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Validate_Client_Medals()

	if (MEDALS_BETA_FLAG) then
		return true
	end
	
	if ((GameScriptData == nil) or (ProfileAchievements == nil)) then
		return false
	end
	
	local result = true
	local offenders = {}

	-- Go through each client
	for _, client in pairs(ClientTable) do
	
		-- Ignore AI.
		if ((client.is_ai == nil) or (client.is_ai == false)) then
		
			local server_achievements = ProfileAchievements[client.common_addr]
			if (server_achievements == nil) then
				return false
			end
			local claimed_medals = client.applied_medals
			
			if (claimed_medals ~= nil) then
				for _, id in ipairs(claimed_medals) do
					-- If the server data says this achievement IS NOT awarded, and it IS NOT
					-- one of the medals everyone gets for free, we have a problem.
					local achieved = false
					if (server_achievements[id] ~= nil) then
						achieved = server_achievements[id].achieved
					end
					if (not achieved and (id < NonAchievementMedalsStart)) then
						result = false
						table.insert(offenders, client.name)
					end
				end
			end
			
		end
		
	end
			
	return result, offenders

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Update_Player_Count()

	if (CurrentlyJoinedSession == nil) then
		return
	end
	
	local map_max = VIEW_PLAYER_INFO_CLUSTER_COUNT 
	if (CurrentlyJoinedSession.map_crc ~= nil) then
		local idx = _PGLobby_Get_Map_Index_From_CRC(CurrentlyJoinedSession.map_crc)
		if idx then
			local map_dao = MPMapModel[idx]		-- MPMapModel is 1-based
			map_max = map_dao.num_players
		end
	end

	local count = 0
	local cluster_idx = 0
	for _, dao in pairs(ClientSeatAssignments) do
	
		cluster_idx = cluster_idx + 1
		if (cluster_idx > map_max) then
			break
		end
	
		local occupied = dao.common_addr ~= nil
		if ((occupied and (dao.is_ai == nil)) or 						-- The spot is occupied by a human or...
			((not occupied) and (dao.is_closed == false))) then	-- ...the spot is not occupied but open.
			count = count + 1
		end
		
	end
	MaxPlayerCount = count

	CurrentlyJoinedSession.max_players = MaxPlayerCount
	CurrentlyJoinedSession.player_count = Network_Get_Client_Table_Count(false)
	
	-- Make sure that the max_players is greater than or equal to the number of players in the actual game.
	if (CurrentlyJoinedSession.max_players < CurrentlyJoinedSession.player_count) then
		CurrentlyJoinedSession.max_players = CurrentlyJoinedSession.player_count
	end

	local player_count = Network_Get_Client_Table_Count(false)
	if player_count >= MaxPlayerCount then
		PGLobby_Set_Local_Session_Open(false)
	else
		PGLobby_Set_Local_Session_Open(true)
	end

	if HostingGame and (CurrentlyJoinedSession ~= nil) then
		Network_Update_Session(CurrentlyJoinedSession)
	end

	PGLobby_Post_Hosted_Session_Data()
	
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Determines if a game should be considered joinable or not.
-------------------------------------------------------------------------------
function PGLobby_Is_Game_Joinable(game)

	if (game == nil or game.name == nil) then
		return false
	end
	
	-- Load simulation?
	if (game.fake) then
		return false
	end

	local is_open = PGLobby_Is_Session_Open(game)
	
	local version_matches = (game.version_string.compare(LocalVersionString) == 0)
	-- [JLH 6/7/2007]: Relaxing the version match rule now so it's easier to test up to 8-player games.
	--local version_matches = true

	local result = true
	result = (result and version_matches)
	result = (result and is_open)

	if (game.gold_only) then
		result = (result and not Net.Requires_Locator_Service())
	end

	return result, version_matches, is_open

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Set_Player_BG_Gradient(quad, triple)

	if (quad == nil) then
		return
	end
	quad.Set_Vertex_Color(0, 0, 0, 0, 1)
	quad.Set_Vertex_Color(1, triple["r"], triple["g"], triple["b"], 1)
	quad.Set_Vertex_Color(2, 0, 0, 0, 1)
	quad.Set_Vertex_Color(3, triple["r"], triple["g"], triple["b"], 1)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Set_Player_Solid_Color(quad, triple)

	if (quad == nil) then
		return
	end
	quad.Set_Vertex_Color(0, triple["r"], triple["g"], triple["b"], 1)
	quad.Set_Vertex_Color(1, triple["r"], triple["g"], triple["b"], 1)
	quad.Set_Vertex_Color(2, triple["r"], triple["g"], triple["b"], 1)
	quad.Set_Vertex_Color(3, triple["r"], triple["g"], triple["b"], 1)
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- This function restarts networking for us based upon the current connection
-- type, LAN or Internet.
-------------------------------------------------------------------------------
function PGLobby_Restart_Networking(new_state)

	DebugMessage("LUA_LOBBY:  Shutting down networking...")
		
	-- If we were in LAN state before, make ABSOLUTELY sure it's turned off.
	if (NetworkState == NETWORK_STATE_LAN) then
		Net.LAN_Stop()
	end

	NetworkState = new_state
	
	-- Initialize!
	if (NetworkState == NETWORK_STATE_INTERNET) then
		DebugMessage("LUA_LOBBY::  Restarting networking under INTERNET context.")
		PGNetwork_Internet_Init()
	elseif (NetworkState == NETWORK_STATE_LAN) then
		DebugMessage("LUA_LOBBY::  Restarting networking under LAN context.")
		PGNetwork_LAN_Init()
	else
		DebugMessage("LUA_LOBBY::  ERROR:  Invalid NetworkState: " .. tostring(NetworkState))
		return
	end
	
	if (NetworkState == NETWORK_STATE_LAN) then
		Net.LAN_Start()
	end
	
	GameSearchTimer = Net.Get_Time()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Begin_Stats_Registration()

	HostStatsRegistration = false
	HostStatsRegistrationComplete = false
	
	if (not HostingGame) then
		return
	end

	local nonce = Net.MM_Get_Stats_Token()
	DebugMessage("LUA_ARBITRATION: HOST: Beginning stats registration.  Nonce: " .. tostring(nonce))
	Broadcast_Stats_Registration_Begin(nonce)
	
end
			
-------------------------------------------------------------------------------
-- Called on successful stats arbitration registration.
------------------------------------------------------------------------------
function PGLobby_On_Stats_Registration(event)

	if HostingGame then
		DebugMessage("LUA_ARBITRATION: HOST: XLive has registered my nonce!")
		HostStatsRegistrationComplete = true
	else
		DebugMessage("LUA_ARBITRATION: GUEST: XLive has registered my nonce!")
		Network_Broadcast(MESSAGE_TYPE_STATS_CLIENT_REGISTERED, "")
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Create_Random_Game_Name()

	local name = Create_Wide_String("")

	for i = 1, 15 do
	
		local char_index = GameRandom.Get_Float() * 26
		local case_offset = 65
		if (GameRandom.Get_Float() < 0.5) then
			case_offset = 97
		end
		local index = char_index + case_offset
		local char = string.char(index) 
		name.append(char)

	end
	
	name.append("_FAKE")
	return name

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Refresh_Available_Games(internet_game_type, filters, player_match)
	BusyFindingSessions = true
	-- Do a queued request.
	local dao = {}
	dao.internet_game_type = internet_game_type
	dao.filters = filters
	dao.player_match = player_match
	PGLobby_Request_Find_Sessions(dao)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Print_Client_Table()
	-- JOE   DEBUGGING!!!
	for _, client in pairs(ClientTable) do
		DebugMessage("JOE DBG:::::  --------------- CLIENT " .. tostring(_) .. " ---------------------")
		for k, v in pairs(client) do
			DebugMessage("JOE DBG:::::      TEST->  k[" .. tostring(k) .. "] -> v[" .. tostring(v) .. "]")
		end
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Set_Local_Session_Open(value)

	if (not HostingGame) then
		return
	end

	if (CurrentlyJoinedSession == nil) then
		return
	end
	
	-- If we're at the maximum player limit, don't allow the session to open again.
	if (Network_Get_Client_Table_Count(false) >= CurrentlyJoinedSession.max_players) then
		PGLobbyLocalSessionOpen = false
	else
		PGLobbyLocalSessionOpen = value
	end
				
	if (ConnectionType == CONNECTION_TYPE_LAN) then
	
		CurrentlyJoinedSession.SessionOpen = PGLobbyLocalSessionOpen
		Network_Update_Session(CurrentlyJoinedSession)
		
	elseif (ConnectionType == CONNECTION_TYPE_INTERNET) then
		
		if PGLobbyLocalSessionOpen then
			GameAdvertiseData[PROPERTY_GAME_JOINABLE] = 1
		else
			GameAdvertiseData[PROPERTY_GAME_JOINABLE] = 0
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Post_Hosted_Session_Data()

	Net.Set_User_Info(GameAdvertiseData)
	
	if (HostingGame and 
		(ConnectionType == CONNECTION_TYPE_INTERNET) and
		(MatchingState == MATCHING_STATE_LIST_PLAY)) then
		Net.Set_Locator_Session_Info(GameAdvertiseData)
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Is_Session_Open(session)
	local is_session_open = ((session.SessionOpen ~= nil) and session.SessionOpen)

	if (ConnectionType == CONNECTION_TYPE_LAN) then
		is_session_open = is_session_open or (session.player_count < session.max_players)
	end
	
	if is_session_open and session.map_crc and TestValid(Global_Conquest_Lobby) ~= true then
		if (_PGLobby_Get_Map_Index_From_CRC(session.map_crc) == nil) and
			(Net.Allow_User_Created_Content(session.xuid) == false) then
			is_session_open = false
		end
	end

	return is_session_open
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
--  M A P   M O D E L   G E N E R A T I O N
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Generate_Map_Selection_Model(session)
 
	-- JOE NEW
	local errors = {}
	MPMapLookup = {}
	MPCRCLookup = {}
	local map_model = MapManager.Get_Multiplayer_Maps()
	map_model.foo = nil
	
	for index, dao in pairs(map_model) do
	
		-- If this is a hacked entry, don't do any of the math.
		if (dao.incomplete == nil) then
		
			dao.incomplete = false
			
			local highbound = string.find(dao.file_name, ".", 1, true)
			if (highbound ~= nil) then
				dao.file_name_no_extension = string.sub(dao.file_name, 1, highbound - 1)
			else
				dao.file_name_no_extension = dao.filename
			end
			
			dao.map_index = tonumber(index)
			
			-- We could test either of start_positions or capturable_structure_positions.  If either exists, this is an
			-- updated map.
			if (dao.start_positions ~= nil) then
			
				local width = dao.map_width
				local height = dao.map_height
				local start_mark_count = -1
				local cap_strc_count = -1
			
				dao.normalized_start_positions, start_mark_count = _PGLobby_Normalize_2D_Vectors(dao.start_positions, width, height)
				dao.normalized_capturable_structure_positions, cap_strc_count = _PGLobby_Normalize_2D_Vectors(dao.capturable_structure_positions, width, height)
				
				if (start_mark_count ~= dao.num_players) then
					local msg = "LUA_LOBBY: ERROR: Map File: " .. tostring(dao.file_name)
					msg = msg .. " -> Player count '" .. tostring(dao.num_players) .. " does not match the number of start positions found.";
					DebugMessage(msg)
					table.insert(errors, msg)
					dao.incomplete = true
				end

				if dao.is_custom_map then

					dao.display_name = Create_Wide_String(dao.file_name_no_extension .. " (custom)")

				elseif ((not dao.display_name) or (dao.display_name.empty()) or (dao.display_name.compare(MISSING) == 0)) then

					local msg = "LUA_LOBBY: ERROR: Map File: " .. tostring(dao.file_name) .. " -> Map name is invalid.";
					DebugMessage(msg)
					table.insert(errors, msg)
					dao.display_name = Create_Wide_String(dao.file_name_no_extension .. " (display name problem)")
					dao.incomplete = true
			
				end
				
			else
			
				dao.display_name = Create_Wide_String(dao.file_name_no_extension .. " (start marker problem)")
				dao.incomplete = true
			
			end
			
		end
		
		MPMapLookup[dao.file_name_no_extension] = dao

	end
    
	table.sort(map_model, _PGLobby_Map_Sort_Comparator)
	local sorted_map_model = map_model

	for index, dao in pairs(sorted_map_model) do
		dao.map_index = tonumber(index)
		MPCRCLookup[dao.map_crc] = index
	end

	return sorted_map_model, errors
	
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Get_Map_Index_From_CRC(crc)
	if MPCRCLookup then
		return MPCRCLookup[crc]
	end
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Map_Sort_Comparator(arg1, arg2)

	if (arg1.num_players < arg2.num_players) then
		return true
	end
	
	if (arg1.num_players > arg2.num_players) then
		return false
	end
	
	-- Num players is equal.
	if (arg1.display_name.compare(arg2.display_name) < 0) then
		return true
	end
	
	return false
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Normalize_2D_Vectors(positions, width, height)

	local result = {}
	local position_count = 0		-- 0-based!!!!!

	if positions == nil then return result, position_count end

	for index, pair in pairs(positions) do
			
		position_count = position_count + 1
		local normal_pair = {}
		normal_pair.x = pair.x / width
		normal_pair.y = pair.y / width
		result[index] = normal_pair
				
	end 
	
	return result, position_count
				
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _TEMP_Make_Hack_Map_Model(name_no_extension)
	local dao = {}
	dao.file_name_no_extension = name_no_extension
	dao.file_name = name_no_extension .. ".ted"
	dao.full_path = MAP_DIRECTORY .. dao.file_name
	dao.display_name = Create_Wide_String(name_no_extension .. " (incomplete)")
	dao.num_players = -1
	dao.incomplete = true
	return dao
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Get_Map_By_Index(index)
	return MPMapModel[index]		-- MPMapModel is 1-based
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Lookup_Map_DAO(key)
	return MPMapLookup[key]
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Get_Map_Player_Count(map_crc)

	local result = DEFAULT_PLAYER_CAP
	local idx = _PGLobby_Get_Map_Index_From_CRC(map_crc)
	if idx then
		local map_dao = PGLobby_Get_Map_By_Index(idx)
		if (map_dao ~= nil) then
			local num_players = map_dao.num_players
			if ((num_players ~= nil) and (num_players > 1)) then
				--result = num_players
  				if ( result > num_players ) then
 					result = num_players
	 			end
			end
		end
	end
	return result
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Convert_Faction_IDs_To_Strings()
	for _, client in pairs(ClientTable) do
		local faction_number = client.faction
		client.faction_id = tonumber(faction_number)
		client.faction = Get_Faction_String_Form(client.faction_id)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Convert_Faction_Strings_To_IDs()
	for _, client in pairs(ClientTable) do
		client.faction = Get_Faction_Numeric_Form(client.faction)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Set_Dialog_Is_Hidden(is_hidden)
	PGLobbyDialogIsHidden = is_hidden
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- M O D A L   M E S S A G E S
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Init_Modal_Message(scene)

	PGLobbyModalMessageScene = scene
	if (not TestValid(PGLobbyModalMessageScene.Yes_No_Ok_Dialog)) then
		local handle = Create_Embedded_Scene("Yes_No_Ok_Dialog", PGLobbyModalMessageScene, "Yes_No_Ok_Dialog")
	end
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Hidden(true)
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.End_Modal()
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Screen_Position(0.5, 0.5)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Display_Modal_Message(message, message_only, show_checkbox, userdata)

	-- Don't spawn modal messages if the parent dialog is hidden
	if (PGLobbyDialogIsHidden == true) then return end
	
	local model = {}
	model.Message = message
	if (message_only) then
		PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Message_Mode()
	else
		PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Ok_Mode()
	end
	if (show_checkbox) then
		PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
	else
		PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Checkbox_Visible(false)
	end
	
	model.Button_Left_Text = "TEXT_NO"
	model.Button_Right_Text = "TEXT_YES"
	model.Button_Middle_Text = "TEXT_BUTTON_OK"
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Model(model)
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_User_Data(userdata)
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Bring_To_Front()
	
	local was_hidden = PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Get_Hidden()
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Hidden(false)
	
	-- If the dialog is already showing, don't bother starting modal as it will already be modal.
	if (was_hidden)  then
		PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Start_Modal()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Display_Custom_Modal_Message(message, text_left, text_middle, text_right, keep_modal_on_event)

	-- Don't spawn modal messages if the parent dialog is hidden
	if (PGLobbyDialogIsHidden == true) then return end
	
	local model = {}
	model.Override = true
	model.Message = message
	model.Button_Left_Text = text_left
	model.Button_Right_Text = text_right
	model.Button_Middle_Text = text_middle
	model.Keep_Modal_On_Event = keep_modal_on_event

	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Checkbox_Visible(false)
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Model(model)
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Bring_To_Front()
		
	local was_hidden = PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Get_Hidden()
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Hidden(false)
	
	-- If the dialog is already showing, don't bother starting modal as it will already be modal.
	if (was_hidden)  then
		PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Start_Modal()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Hide_Modal_Message()
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.End_Modal()
	PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Set_Hidden(true)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Is_Modal_Message_Showing()
	return TestValid(PGLobbyModalMessageScene) and
	TestValid(PGLobbyModalMessageScene.Yes_No_Ok_Dialog) and
	(PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Get_Hidden() == false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- R E Q U E S T   Q U E U I N G   S Y S T E M
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Handles the sequential calling of requests in such as way as to not flood
-- the backend with requests upon requests.
-------------------------------------------------------------------------------
function _PGLobby_Throttled_Request_Queue_Process()

	_PGLobbyThrottledRequestSystemRunning = true
	
	-- If there are no more requests queued, we're done.
	if (#_PGLobbyThrottledRequestQueue <= 0) then
		DebugMessage("LUA_LOBBY: THROTTLED QUEUE: Request queue is empty.  Stopping throttled queue system.")
		_PGLobbyThrottledRequestSystemRunning = false
		return
	end
	
	-- We're clear...request something!
	local request = table.remove(_PGLobbyThrottledRequestQueue)
	request.func(request.mutex)
	
	-- If there's more to do, schedule another.
	if (#_PGLobbyThrottledRequestQueue > 0) then
		DebugMessage("LUA_LOBBY: THROTTLED QUEUE: Request queue is still not empty, scheduling another process.")
		PGCrontab_Schedule(_PGLobby_Throttled_Request_Queue_Process, 0, THROTTLED_REQUEST_QUEUE_PERIOD)
	else
		DebugMessage("LUA_LOBBY: THROTTLED QUEUE: Request queue is empty.  Stopping throttled queue system.")
		_PGLobbyThrottledRequestSystemRunning = false
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGLobby_Queue_Throttled_Request(request_function, mutex)

	-- Only queue unique requests!
	for _, request in ipairs(_PGLobbyThrottledRequestQueue) do
		if ((request.mutex == mutex) and (request.func == request_function)) then
			-- This EXACT request is already in the queue.  Don't schedule another.
			DebugMessage("LUA_LOBBY: Ignoring call to schedule a throttled request that is already in the queue.")
			return
		end
	end

	DebugMessage("LUA_LOBBY: THROTTLED QUEUE: Scheduling throttled request.")
	local request = {}
	request.mutex = mutex
	request.func = request_function
	table.insert(_PGLobbyThrottledRequestQueue, request)
	
	if (_PGLobbyThrottledRequestSystemRunning == false) then
		_PGLobbyThrottledRequestSystemRunning = true
		PGCrontab_Schedule(_PGLobby_Throttled_Request_Queue_Process, 0, THROTTLED_REQUEST_QUEUE_PERIOD)
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- Q U E U E D   R E Q U E S T S
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- UNQUEUED REQUEST:  Callback is Network_On_Find_Session()
-------------------------------------------------------------------------------
function PGLobby_Request_Find_Sessions(dao)

	DebugMessage("LUA_LOBBY: UNQUEUED REQUEST: Find sessions.")
	Network_Find_Sessions(dao.internet_game_type, dao.filters, dao.player_match)
	
end

-------------------------------------------------------------------------------
-- UNQUEUED REQUEST:  Callback is PGLobby_On_Stats_Registration()
-------------------------------------------------------------------------------
function PGLobby_Request_Stats_Registration(nonce)

	DebugMessage("LUA_LOBBY: UNQUEUED REQUEST: Stats registration.")
	Net.MM_Register_Stats_Token(nonce)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Request_All_Required_Backend_Data()

	if (ENABLE_ACHIEVEMENT_VERIFICATION) then 
		Net.Initialize_Multiplayer_Achievement_System() 
	end
	
	if (NetworkState == NETWORK_STATE_INTERNET) then
		if (ENABLE_ACHIEVEMENT_VERIFICATION) then 
			PGLobby_Request_All_Profile_Achievements()
		end
		if (ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then 
			PGLobby_Request_All_Achievement_Stats()
		end
	end
	
end
			
-------------------------------------------------------------------------------
-- Will queue up requests for all players in the client table whose info we
-- are missing.
-------------------------------------------------------------------------------
function PGLobby_Request_All_Profile_Achievements()

	if ((not ENABLE_ACHIEVEMENT_VERIFICATION) or (ConnectionType == CONNECTION_TYPE_LAN)) then
		return
	end
	
	DebugMessage("LUA_LOBBY: QUEUED REQUEST: Requesting all profile achievements.")
	
	ProfileAchievements = {}
	for _, client in pairs(ClientTable) do
	
		-- Only request data we don't have...don't request data we DO have.
		if (ProfileAchievements[client.common_addr] == nil) then
			PGLobby_Request_Profile_Achievements(client.common_addr)
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- Calls on the backend to give us a player's achievement data.
-- Implement the function On_Enumerate_Achievements() to recieve the callback.
-- If common_addr is nil, the achievement data for the local player will be
-- returned.
-- QUEUED REQUEST:  Callback is On_Enumerate_Achievements()
-------------------------------------------------------------------------------
function PGLobby_Request_Profile_Achievements(common_addr)

	if ((not ENABLE_ACHIEVEMENT_VERIFICATION) or (ConnectionType == CONNECTION_TYPE_LAN)) then
		return
	end
	
	-- Don't do AI players.
	local client = Network_Get_Client(common_addr)
	if ((client ~= nil) and (client.is_ai)) then
		return
	end

	-- Add this request to the throttle queue.
	_PGLobby_Queue_Throttled_Request(_PGLobby_Request_Profile_Achievements, common_addr)
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGLobby_Request_Profile_Achievements(common_addr)

	local label = common_addr
	if (JoinedGame) then
		local client = Network_Get_Client(common_addr)
		if ((client ~= nil) and (client.name ~= nil)) then
			label = client.name
		end
	end
	DebugMessage("LUA_LOBBY: THROTTLED REQUEST: Requesting profile achievements for player: " .. tostring(label))
	
	if (common_addr == nil) then
		Net.Request_Profile_Achievements()
	else
		Net.Request_Profile_Achievements(common_addr)
	end
	
end

-------------------------------------------------------------------------------
-- Will queue up requests for all players in the client table whose info we
-- are missing.
-------------------------------------------------------------------------------
function PGLobby_Request_All_Achievement_Stats()

	if (not ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then
		return
	end
	
	DebugMessage("LUA_LOBBY: QUEUED REQUEST: Requesting all achievement stats.")

	if GameScriptData.achievement_stats == nil then
		GameScriptData.achievement_stats = {}
	end

	for _, client in pairs(ClientTable) do
	
		-- Only request data we don't have...don't request data we DO have.
		if ((not client.is_ai) and (GameScriptData.achievement_stats[client.common_addr] == nil)) then
			PGLobby_Request_Medals_Progress_Stats(client.common_addr)
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- Calls on the backend to give us a player's multiplayer achievement stats.
-- Implement the function On_Query_Medals_Progress_Stats() to recieve the callback.
-- If common_addr is nil, we request stats for the local player.
-- QUEUED REQUEST:  Callback is On_Query_Medals_Progress_Stats()
-------------------------------------------------------------------------------
function PGLobby_Request_Medals_Progress_Stats(common_addr)

	if (not ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then
		return
	end
	
	-- Don't do AI players.
	local client = Network_Get_Client(common_addr)
	if ((client ~= nil) and (client.is_ai)) then
		return
	end

	-- Add this request to the throttle queue.
	_PGLobby_Queue_Throttled_Request(_PGLobby_Request_Medals_Progress_Stats, common_addr)
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Request_Medals_Progress_Stats(common_addr)
	
	-- Achievement progress fields.
	local fields = {
		PROPERTY_MEDAL_CUSTOMIZATION_MADE_EASY,
		PROPERTY_MEDAL_CANT_STOP_NOVUS,
		PROPERTY_MEDAL_UNDER_NOVUS_CONTROL,
		PROPERTY_MEDAL_PURE_OHMAGE,
		PROPERTY_MEDAL_BUILDING_THE_NETWORK,
		PROPERTY_MEDAL_THE_POWER_MUST_FLOW,
		PROPERTY_MEDAL_MY_WISH_IS_YOUR_COMMAND,
		PROPERTY_MEDAL_HIERARCHY_DOMINATION,
		PROPERTY_MEDAL_MASARI_GLOBAL_INFLUENCE,
		PROPERTY_MEDAL_GIFTS_ARE_NICE,
		PROPERTY_MEDAL_UNLIMITED_POWER,
		PROPERTY_MEDAL_TIME_MEANS_NOTHING,
		PROPERTY_MEDAL_RESEARCH_IS_KEY,
		PROPERTY_MEDAL_WHIRLING_DERVISH,
		PROPERTY_MEDAL_DARK_MATTER_FTW,
		PROPERTY_MEDAL_BLINDED_BY_THE_LIGHT,
		PROPERTY_MEDAL_THE_SACRED_COW,
		PROPERTY_MEDAL_PEACE_THROUGH_POWER,
		PROPERTY_MEDAL_MUTATION_MADNESS,
		PROPERTY_MEDAL_CLOAKING_IS_GOOD,
		PROPERTY_MEDAL_TECHNOLOGICAL_TERROR
	}
	
	local label = common_addr
	if (JoinedGame) then
		local client = Network_Get_Client(common_addr)
		if ((client ~= nil) and (client.name ~= nil)) then
			label = client.name
		end
	end
	DebugMessage("LUA_LOBBY: THROTTLED REQUEST: Requesting achievement stats for player: " .. tostring(label))
	
	-- Make the request!
	if (common_addr == nil) then
		Net.Request_Medals_Progress_Stats()
	else
		Net.Request_Medals_Progress_Stats( { common_addr } )
	end
	
end
		
-------------------------------------------------------------------------------
-- Calls on the backend to request stats for multiple common_addrs aggregated
-- into a single call.
-- QUEUED REQUEST:  Callback is On_Query_Medals_Progress_Stats()
-------------------------------------------------------------------------------
function PGLobby_Request_All_Medals_Progress_Stats()

	if (not ENABLE_ACHIEVEMENT_PROGRESS_NEGOTIATION) then
		return
	end
	
	-- Gather all the common_addrs
	local common_addr_list = {}
	for common_addr, client in pairs(ClientTable) do
	
		-- Don't do AI players.
		if (not client.is_ai) then
			table.insert(common_addr_list, common_addr)
		end
	
	end
	
	-- Add this request to the throttle queue.
	_PGLobby_Queue_Throttled_Request(_PGLobby_Request_All_Medals_Progress_Stats, common_addr_list)
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Request_All_Medals_Progress_Stats(common_addr_list)
	
	-- Achievement progress fields.
	local fields = {
		PROPERTY_MEDAL_CUSTOMIZATION_MADE_EASY,
		PROPERTY_MEDAL_CANT_STOP_NOVUS,
		PROPERTY_MEDAL_UNDER_NOVUS_CONTROL,
		PROPERTY_MEDAL_PURE_OHMAGE,
		PROPERTY_MEDAL_BUILDING_THE_NETWORK,
		PROPERTY_MEDAL_THE_POWER_MUST_FLOW,
		PROPERTY_MEDAL_MY_WISH_IS_YOUR_COMMAND,
		PROPERTY_MEDAL_HIERARCHY_DOMINATION,
		PROPERTY_MEDAL_MASARI_GLOBAL_INFLUENCE,
		PROPERTY_MEDAL_GIFTS_ARE_NICE,
		PROPERTY_MEDAL_UNLIMITED_POWER,
		PROPERTY_MEDAL_TIME_MEANS_NOTHING,
		PROPERTY_MEDAL_RESEARCH_IS_KEY,
		PROPERTY_MEDAL_WHIRLING_DERVISH,
		PROPERTY_MEDAL_DARK_MATTER_FTW,
		PROPERTY_MEDAL_BLINDED_BY_THE_LIGHT,
		PROPERTY_MEDAL_THE_SACRED_COW,
		PROPERTY_MEDAL_PEACE_THROUGH_POWER,
		PROPERTY_MEDAL_MUTATION_MADNESS,
		PROPERTY_MEDAL_CLOAKING_IS_GOOD,
		PROPERTY_MEDAL_TECHNOLOGICAL_TERROR
	}
	
	for _, common_addr in ipairs(common_addr_list) do
	
		local label = common_addr
		if (JoinedGame) then
			local client = Network_Get_Client(common_addr)
			if ((client ~= nil) and (client.name ~= nil)) then
				label = client.name
			end
		end
		DebugMessage("LUA_LOBBY: THROTTLED REQUEST: Requesting aggregated achievement stats for player: " .. tostring(label))
	
	end
	
	-- Make the request!
	Net.Request_Medals_Progress_Stats(common_addr_list)
	
end

-------------------------------------------------------------------------------
-- Calls on the backend to give us a player's multiplayer achievement stats.
-- Implement the function On_Query_GC_Stats() to recieve the callback.
-- If common_addr is nil, we request stats for the local player.
-- QUEUED REQUEST:  Callback is On_Query_GC_Stats()
-------------------------------------------------------------------------------
function PGLobby_Request_Global_Conquest_Properties(common_addr)

	-- Add this request to the throttle queue.
	_PGLobby_Queue_Throttled_Request(_PGLobby_Request_Global_Conquest_Properties, common_addr)

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Request_Global_Conquest_Properties(common_addr)

	if (common_addr == nil) then
		common_addr = Net.Get_Local_Addr()
	end
	
	local label = common_addr
	if (JoinedGame) then
		local client = Network_Get_Client(common_addr)
		if ((client ~= nil) and (client.name ~= nil)) then
			label = client.name
		end
	end
	
	DebugMessage("LUA_LOBBY: Requesting global conquest properties for player: " .. tostring(label))
	
	Net.Get_GC_Props(common_addr)
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- M O V I E   Q U A D S
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Activate_Movies()
	PGLobbyMoviesActive = true
	if (TestValid(this.Movie_1)) then
		this.Movie_1.Play()
	end
	if (TestValid(this.Movie_2)) then
		this.Movie_2.Play()
	end
	-- Do not play any of the globe movies here...let the specific events under which they
	-- become visible be responsible for starting them.
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Passivate_Movies()
	PGLobbyMoviesActive = false
	if (TestValid(this.Movie_1)) then
		this.Movie_1.Stop()
	end
	if (TestValid(this.Movie_2)) then
		this.Movie_2.Stop()
	end
	if (TestValid(this.Panel_Custom_Lobby) and TestValid(this.Panel_Custom_Lobby.Globe_Movie)) then
		this.Panel_Custom_Lobby.Globe_Movie.Stop()
	end
	if (TestValid(this.Panel_Game_Filters) and TestValid(this.Panel_Game_Filters.Globe_Movie)) then
		this.Panel_Game_Filters.Globe_Movie.Stop()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- H E A R T B E A T
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Start_Heartbeat()
	if (PGLobbyHeartbeating) then
		return
	end
	PGLobbyHeartbeating = true
	PGCrontab_Schedule(_PGLobby_Update_Heartbeat, 0, HEARTBEAT_INTERVAL)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGLobby_Update_Heartbeat()
	if (PGLobbyHeartbeating) then
		local dao = {}
		dao.common_addr = LocalClient.common_addr
		dao.client_count = Network_Get_Client_Table_Count()
		--[[--JOE DELETE::: The block below is for simulating a bad connection from all guests.
		if (HostingGame) then
			dao.client_count = Network_Get_Client_Table_Count()
		else
			dao.client_count = 999
		end--]]
		Broadcast_Heartbeat(dao)
		PGCrontab_Schedule(_PGLobby_Update_Heartbeat, 0, HEARTBEAT_INTERVAL)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Stop_Heartbeat()
	PGLobbyHeartbeating = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- K E E P A L I V E
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Keepalive_Open_Bracket()

	_PGLobbyKeepaliveBrackets = _PGLobbyKeepaliveBrackets + 1
	if (_PGLobbyKeepaliveBrackets >= MAX_KEEPALIVE_BRACKET_DELTA) then
		DebugMessage("LUA_LOBBY:  WARNING:  Keepalive has determined that the network has become unresponsive.")
		_PGLobbyKeepaliveBrackets = 0
		--Net.Force_XLive_Disconnect()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Keepalive_Close_Bracket()

	--[[_PGLobbyKeepaliveBrackets = _PGLobbyKeepaliveBrackets - 1
	if (_PGLobbyKeepaliveBrackets < 0) then
		_PGLobbyKeepaliveBrackets = 0
	end--]]
	
	-- For now just clear it.  If *anything* comes back from the network we should be alive and well.
	_PGLobbyKeepaliveBrackets = 0
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- T O O L T I P
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Mouse_Move()
	_PGLobbyTooltipHandle.Update_Position()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Set_Tooltip_Model(model)

	_PGLobbyTooltipHandle.Set_Model(model)
	if ((model.text_title ~= nil) and (model.icon_texture ~= nil)) then
		_PGLobbyTooltipHandle.Set_View_State(VIEW_STATE_TITLE_ICON_TEXT)
	elseif (model.text_title ~= nil) then
		_PGLobbyTooltipHandle.Set_View_State(VIEW_STATE_TITLE_TEXT)
	elseif (model.icon_texture ~= nil) then
		_PGLobbyTooltipHandle.Set_View_State(VIEW_STATE_ICON_TEXT)
	else
		_PGLobbyTooltipHandle.Set_View_State(VIEW_STATE_TEXT_ONLY)
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Set_Tooltip_Visible(value)

	_PGLobbyTooltipHandle.Set_Hidden(not value)
	_PGLobbyTooltipHandle.Bring_To_Front()
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- P I N G
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Mouse_Move()
	_PGLobbyTooltipHandle.Update_Position()
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- N A T
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Display_NAT_Information(text_object)

	if (NetworkState == NETWORK_STATE_INTERNET) then
		text_object.Set_Hidden(false)
	else
		text_object.Set_Hidden(true)
		return
	end
			
	-- Has the user chosen to no longer display NAT warnings?
	local display = Get_Profile_Value(PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS, true)
	local nat_type = Net.Get_NAT_Type()
	local nat_type_message = Get_Game_Text("TEXT_MULTIPLAYER_NAT_TYPE").append(": ")
	local spawned_dialog = false
	
	-- If the client's NAT is OPEN, there's no need to worry.
	if (nat_type == XONLINE_NAT_OPEN) then
		nat_type_message = nat_type_message.append(Get_Game_Text("TEXT_MULTIPLAYER_NAT_TYPE_OPEN"))
	end

	-- If the client's NAT is MODERATE, we may have issues.
	if (nat_type == XONLINE_NAT_MODERATE) then
		nat_type_message = nat_type_message.append(Get_Game_Text("TEXT_MULTIPLAYER_NAT_TYPE_MODERATE"))
		local message = Get_Game_Text("TEXT_MULTIPLAYER_LOCAL_MODERATE_NAT_WARNING")
		if (display) then
			PGLobby_Display_Modal_Message(message, false, true, PGLOBBY_NAT_WARNING_TOKEN)
			spawned_dialog = true
		end
	end
	
	-- If the client's NAT is STRICT, we may have issues.
	if (nat_type == XONLINE_NAT_STRICT) then
		nat_type_message = nat_type_message.append(Get_Game_Text("TEXT_MULTIPLAYER_NAT_TYPE_STRICT"))
		local message = Get_Game_Text("TEXT_MULTIPLAYER_LOCAL_STRICT_NAT_WARNING")
		if (display) then
			PGLobby_Display_Modal_Message(message, false, true, PGLOBBY_NAT_WARNING_TOKEN)
			spawned_dialog = true
		end
	end
	
	if (TestValid(text_object)) then
		text_object.Set_Text(nat_type_message)
	end
	
	return spawned_dialog
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Validate_NAT_Type(client)

	-- If the client IS the host, they will have recieved a different warning on installation.
	if (client.common_addr == LocalClient.common_addr) then
		return true
	end
	
	-- If the client's NAT is OPEN, there's no need to worry.
	if (client.nat_type == XONLINE_NAT_OPEN) then
		return true
	end
	
	local name = client.name
	if (name == nil) then
		name =  Get_Game_Text("TEXT_UNKNOWN") 
	end

	-- If the client's NAT is MODERATE, we may have issues.
	if (client.nat_type == XONLINE_NAT_MODERATE) then
	
		local message = Get_Game_Text("TEXT_MULTIPLAYER_HOST_WARNING_GUEST_MODERATE_NAT")
		message = Replace_Token(message, name, 1)
		return false, message
	
	end
	
	-- If the client's NAT is STRICT, we may have issues.
	if (client.nat_type == XONLINE_NAT_STRICT) then
	
		local message = Get_Game_Text("TEXT_MULTIPLAYER_HOST_WARNING_GUEST_STRICT_NAT")
		message = Replace_Token(message, name, 1)
		return false, message

	end
	
	return true

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Update_NAT_Warning_State()

	local userdata = PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Get_User_Data()
	if (userdata == PGLOBBY_NAT_WARNING_TOKEN) then
		local button_state = PGLobbyModalMessageScene.Yes_No_Ok_Dialog.Get_Checkbox_State()
		if (button_state) then
			-- The user wants to hide nat warnings
			Set_Profile_Value(PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS, false)
		end
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGLobby_Get_Preferred_Color()

	local default_color = nil
	if TestValid(Net) then
		default_color = Net.Get_Gamer_Preferred_Color()
	end
	if not default_color then
		default_color = 7
	end
	local color = Get_Profile_Value(PP_COLOR_INDEX, default_color)
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[color]
	if (color == nil or index == nil) then
		color = 7
	else
		color = tonumber(color)
	end
	
	return color
		
end

-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- S I M P L E   V A N I T Y   S T A T S
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGLobby_Save_Vanity_Game_Start_Data(ranked)

	-- *** DATE/TIME CAPTURE ***
	local datetime = Get_Localized_Formatted_Number.Get_Current_Date_Time()
	if (ranked) then
		Set_Profile_Value(PP_VANITY_LAST_RANKED_MATCH_DATETIME, datetime)
	else
		Set_Profile_Value(PP_VANITY_LAST_UNRANKED_MATCH_DATETIME, datetime)
	end
	
	-- *** OPPONENT NAME ***

	-- Some early outs
	if ((ClientTable == nil) or (LocalClient == nil)) then
		return
	end
	
	-- Figure out the other player's name.
	local name = nil
	
	for _, client in pairs(ClientTable) do
		if (client.common_addr ~= LocalClient.common_addr) then
			name = client.name
			break
		end
	end
	
	if (name == nil) then
		return
	end

	-- JLH 12/12/2007
	-- It is a TCR violation to store gamertags!
	--[[if (ranked) then
		Set_Profile_Value(PP_VANITY_LAST_RANKED_OPPONENT, name)
	else
		Set_Profile_Value(PP_VANITY_LAST_UNRANKED_OPPONENT, name)
	end--]]
	
end



function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_Game_Kill_Countdown = nil
	Broadcast_Game_Settings = nil
	Broadcast_Game_Settings_Accept = nil
	Broadcast_Game_Start_Countdown = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	Commit_Profile_Values = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
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
	Network_Get_Local_Username = nil
	Network_Get_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	Network_Kick_Player = nil
	Network_Refuse_Player = nil
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	OutputDebug = nil
	PGLobby_Activate_Movies = nil
	PGLobby_Begin_Stats_Registration = nil
	PGLobby_Convert_Faction_IDs_To_Strings = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Create_Session = nil
	PGLobby_Display_Custom_Modal_Message = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Generate_Map_Selection_Model = nil
	PGLobby_Get_Preferred_Color = nil
	PGLobby_Hide_Modal_Message = nil
	PGLobby_Init_Modal_Message = nil
	PGLobby_Is_Game_Joinable = nil
	PGLobby_Keepalive_Close_Bracket = nil
	PGLobby_Keepalive_Open_Bracket = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Mouse_Move = nil
	PGLobby_Passivate_Movies = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Refresh_Available_Games = nil
	PGLobby_Request_All_Medals_Progress_Stats = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Request_Global_Conquest_Properties = nil
	PGLobby_Request_Stats_Registration = nil
	PGLobby_Reset = nil
	PGLobby_Restart_Networking = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Dialog_Is_Hidden = nil
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
	PGLobby_Vars_Init = nil
	PGNetwork_Clear_Start_Positions = nil
	PGNetwork_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Client_Table = nil
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
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	Kill_Unused_Global_Functions = nil
end

