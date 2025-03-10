if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGNetwork.lua#41 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGNetwork.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 97873 $
--
--          $DateTime: 2008/05/01 13:53:02 $
--
--          $Revision: #41 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGVictoryConditionDefs")
require("PGFactions")
require("PGColors")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGNetwork_Init()
	PGNetwork_Init_Constants()
	PGNetwork_Init_Variables()
end

-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- C O N S T A N T S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
function PGNetwork_Init_Constants()

	-- Should we send as few messages as possible?
	MINIMAL_BROADCAST 											= true
	
	INTERNET_GAME_TYPE_STANDARD_GAME 						= Declare_Enum(0)
	INTERNET_GAME_TYPE_RANKED_GAME							= Declare_Enum()
	INTERNET_GAME_TYPE_GLOBAL_CONQUEST_GAME				= Declare_Enum()
	
	MESSAGE_TYPE_START_GAME										= Declare_Enum(1)	-- 1
	MESSAGE_TYPE_CHAT												= Declare_Enum()	-- 2
	MESSAGE_TYPE_PLAYER_NAME									= Declare_Enum()	-- 3
	MESSAGE_TYPE_PLAYER_FACTION								= Declare_Enum()	-- 4
	MESSAGE_TYPE_PLAYER_COLOR									= Declare_Enum()	-- 5
	MESSAGE_TYPE_PLAYER_TEAM									= Declare_Enum()	-- 6
	MESSAGE_TYPE_PLAYER_APPLIED_MEDALS						= Declare_Enum()	-- 7
	MESSAGE_TYPE_PLAYER_TOTAL_ONLINE_ACHIEVEMENTS		= Declare_Enum()	-- 8
	MESSAGE_TYPE_PLAYER_TOTAL_OFFLINE_ACHIEVEMENTS		= Declare_Enum()	-- 9
	MESSAGE_TYPE_PLAYER_APPLIED_ONLINE_ACHIEVEMENTS		= Declare_Enum()	-- 10
	MESSAGE_TYPE_PLAYER_APPLIED_OFFLINE_ACHIEVEMENTS	= Declare_Enum()	-- 11
	MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS					= Declare_Enum()	-- 12
	MESSAGE_TYPE_PLAYER_SEAT_ASSIGNMENT						= Declare_Enum()	-- 13
	MESSAGE_TYPE_PLAYER_REQUEST_START_POSITION			= Declare_Enum()	-- 14
	MESSAGE_TYPE_PLAYER_ASSIGN_START_POSITION				= Declare_Enum()	-- 15
	MESSAGE_TYPE_PLAYER_CLEAR_START_POSITION				= Declare_Enum()	-- 16
	MESSAGE_TYPE_REFUSE_PLAYER									= Declare_Enum()	-- 17
	MESSAGE_TYPE_KICK_PLAYER									= Declare_Enum()	-- 18
	MESSAGE_TYPE_KICK_AI_PLAYER								= Declare_Enum()	-- 19
	MESSAGE_TYPE_GAME_SETTINGS									= Declare_Enum() 	-- 20
	MESSAGE_TYPE_GAME_SETTINGS_ACCEPT						= Declare_Enum()	-- 21
	MESSAGE_TYPE_GAME_SETTINGS_DECLINE						= Declare_Enum()	-- 22
	MESSAGE_TYPE_GAME_START_COUNTDOWN						= Declare_Enum()	-- 23
	MESSAGE_TYPE_GAME_KILL_COUNTDOWN							= Declare_Enum()	-- 24
	MESSAGE_TYPE_HOST_DISCONNECTED							= Declare_Enum()	-- 25
	MESSAGE_TYPE_MULTIPLAYER_WINNER							= Declare_Enum()	-- 26
	MESSAGE_TYPE_IN_GAME_CHAT									= Declare_Enum()	-- 27
	MESSAGE_TYPE_REMOTE_LOAD_PROGRESS_UPDATED				= Declare_Enum()	-- 28
	MESSAGE_TYPE_STATS_REGISTRATION_BEGIN					= Declare_Enum()	-- 29
	MESSAGE_TYPE_STATS_CLIENT_REGISTERED					= Declare_Enum()	-- 30
	MESSAGE_TYPE_REBROADCAST_USER_SETTINGS					= Declare_Enum()	-- 31
	MESSAGE_TYPE_REBROADCAST_GAME_SETTINGS					= Declare_Enum()	-- 32
	MESSAGE_TYPE_HOST_RECOMMENDED_SETTINGS					= Declare_Enum()	-- 33
	MESSAGE_TYPE_RESERVED_PLAYER								= Declare_Enum()	-- 34
	MESSAGE_TYPE_KICK_RESERVED_PLAYER						= Declare_Enum()	-- 35
	MESSAGE_TYPE_HEARTBEAT										= Declare_Enum()	-- 36
	MESSAGE_TYPE_RANKED_SEED									= Declare_Enum()	-- 37
	MESSAGE_TYPE_PLAYER_NAT_TYPE								= Declare_Enum()	-- 38
	MESSAGE_TYPE_PLAYER_SETTINGS								= Declare_Enum()	-- 39
	MESSAGE_TYPE_ALL_GAME_SETTINGS							= Declare_Enum()	-- 40
	MESSAGE_TYPE_PLAYER_RESET_GLOBE							= Declare_Enum()	-- 41
	MESSAGE_TYPE_GAME_SEED										= Declare_Enum()	-- 42
	MESSAGE_TYPE_HOST_CLEAR_START_POSITIONS				= Declare_Enum()	-- 43
	MESSAGE_TYPE_CLIENT_HAS_MAP								= Declare_Enum()	-- 44
	MESSAGE_TYPE_UPDATE_SESSION								= Declare_Enum()	-- 45
	MESSAGE_TYPE_DOWNLOAD_PROGRESS							= Declare_Enum()	-- 46
	MESSAGE_TYPE_PLAYER_PLATFORM								= Declare_Enum()	-- 47

	AI_EASY_INDEX = 0
	AI_MEDIUM_INDEX = 1
	AI_HARD_INDEX = 2
	AI_DIFFICULTIES = {}
	AI_DIFFICULTIES[AI_EASY_INDEX] = Difficulty_Easy
	AI_DIFFICULTIES[AI_MEDIUM_INDEX] = Difficulty_Normal
	AI_DIFFICULTIES[AI_HARD_INDEX] = Difficulty_Hard
	
	CONNECTION_TYPE_UNKNOWN = "CONNECTION_TYPE_UNKNOWN"
	CONNECTION_TYPE_INTERNET = "CONNECTION_TYPE_INTERNET"
	CONNECTION_TYPE_LAN = "CONNECTION_TYPE_LAN"
	
	if ( Is_Gamepad_Active() ) then
		MAX_TEAMS = 4
		
		MAP_MAX_PLAYER_COUNT = 4
		VIEW_PLAYER_INFO_CLUSTER_COUNT = 4		-- Create 4 player info cluster buckets.
	else
		MAX_TEAMS = 8

		MAP_MAX_PLAYER_COUNT = 8
		VIEW_PLAYER_INFO_CLUSTER_COUNT = 8		-- Create 8 player info cluster buckets.
	end

	Init_Victory_Condition_Constants()
	PGColors_Init()
	PGFactions_Init()

	Register_Net_Commands() -- need to make sure Net is defined
	Net.Register_XLive_Constants()
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- V A R I A B L E S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PGNetwork_Init_Variables()
	ClientTable = {}
	KickedPlayers = {}
	if (GameOptions == nil) then
		GameOptions = {}
	end
	GameScriptData = {}
	StartGameCalled = false
	if (ConnectionType == nil) then
		ConnectionType = CONNECTION_TYPE_UNKNOWN
	end
	HostingGame = false
	AIPlayers = {}
	AIPlayerSequence = 0
	ReservedPlayers = {}
	ReservedPlayerSequence = 0
	InternetHandlerRegistered = false
	LANHandlerRegistered = false
	Network_Reset_Seat_Assignments()
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes networking for internet play (as opposed to LAN play).
-------------------------------------------------------------------------------
function PGNetwork_Internet_Init()
	ConnectionType = CONNECTION_TYPE_INTERNET
	ClientTable = {}
	KickedPlayers = {}
	DebugMessage("LUA_NET:: Registering internet event handler...")
	Register_For_Network_Events()

	if (LocalClient == nil) then
		LocalClient = {}
	end
	LocalClient.common_addr = Net.Get_Local_Addr()
	GameOptions = {}
	GameOptions.seed = 12345
	GameOptions.is_campaign = false
	GameOptions.is_lan = false
	GameOptions.is_internet = true
	GameOptions.is_skirmish = true		-- ALL multiplayer games are skirmish.
	
	GameScriptData.victory_condition = VICTORY_CONQUER	
end

-------------------------------------------------------------------------------
-- Initializes networking for LAN play (as opposed to internet play).
-------------------------------------------------------------------------------
function PGNetwork_LAN_Init()
	ConnectionType = CONNECTION_TYPE_LAN
	ClientTable = {}
	KickedPlayers = {}
	DebugMessage("LUA_NET:: Registering LAN event handler...")
	Register_For_Network_Events()

	if (LocalClient == nil) then
		LocalClient = {}
	end
	LocalClient.common_addr = Net.Get_Local_Addr()
	GameOptions = {}
	GameOptions.seed = 12345
	GameOptions.is_campaign = false
	GameOptions.is_lan = true
	GameOptions.is_internet = false
	GameOptions.is_skirmish = true		-- ALL multiplayer games are skirmish.
	
	GameScriptData.victory_condition = VICTORY_CONQUER
end

-------------------------------------------------------------------------------
-- Generic event handler registration.
-------------------------------------------------------------------------------
function Register_For_Network_Events(connection_type)

	-- If the caller doesn't want to override the connection type, fall back
	-- to the global.
	if (connection_type == nil) then
		connection_type = ConnectionType
	end

	if (connection_type == CONNECTION_TYPE_INTERNET) then
	
		-- If the LAN handler is registered, unregister it.
		if (LANHandlerRegistered) then
			Net.Unregister_Event_Handler(On_LAN_Event)
			LANHandlerRegistered = false
		end
		
		if (not InternetHandlerRegistered) then
			Net.Register_Event_Handler(On_Internet_Event)
			InternetHandlerRegistered = true
		end
		
	elseif (connection_type == CONNECTION_TYPE_LAN) then
	
		-- If the Internet handler is registered, unregister it.
		if (InternetHandlerRegistered) then
			Net.Unregister_Event_Handler(On_Internet_Event)
			InternetHandlerRegistered = false
		end
	
		if (not LANHandlerRegistered) then
			Net.Register_Event_Handler(On_LAN_Event)
			LANHandlerRegistered = true
		end
		
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Register_For_Network_Events()")
	end

end

-------------------------------------------------------------------------------
-- Cleans up and unregisters LAN stuff (usually called when backing out of a 
-- menu.
-------------------------------------------------------------------------------
function Unregister_For_Network_Events()
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Net.Unregister_Event_Handler(On_Internet_Event)
		InternetHandlerRegistered = false
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		Net.Unregister_Event_Handler(On_LAN_Event)
		LANHandlerRegistered = false
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Unregister_For_Network_Events()")
	end
end

-------------------------------------------------------------------------------
-- Builds a map from common addresses to client details.
-------------------------------------------------------------------------------
function Set_Client_Table(clients)
	DebugMessage("LUA_NET: New client table...")
	ClientTable = {}
	for _, client in ipairs(clients) do
		DebugMessage("LUA_NET:      NEW CLIENT: " .. tostring(client.common_addr))
		Network_Add_Client(client.common_addr)
	end
end

-------------------------------------------------------------------------------
-- Just like it says.
-------------------------------------------------------------------------------
function Check_Unique_Teams()

	local check = {}

	for _, client in pairs(ClientTable) do

		local index = client.team
		if (check[index] == true) then
			return false
		end
		check[index] = true

	end

	return true

end

-------------------------------------------------------------------------------
-- Just like it says.
-------------------------------------------------------------------------------
function Check_Color_Is_Taken(target)

	for _, client in pairs(ClientTable) do
		if (client.common_addr ~= target.common_addr) then
			if (client.color == target.color) then
				return true
			end
		end
	end
	return false
	
end
		
-------------------------------------------------------------------------------
-- Just like it says.
-------------------------------------------------------------------------------
function Check_Unique_Colors()

	local color_check_array = {}

	for _, client in pairs(ClientTable) do
	
		if (client.color == nil) then
			return false
		end

		if (color_check_array[client.color] ~= nil) then
			return false
		end
		color_check_array[client.color] = true

	end

	return true

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Are_Chat_Names_Unique()

	-- n^2 iteration over the ClientTable
	for outer_index, outer_client in pairs(ClientTable) do
	
		if (outer_client.name == nil) then
			return false
		end

		-- Outer info
		local outer_name = tostring(outer_client.name)
		local outer_addr = outer_client.common_addr

		for _, inner_client in pairs(ClientTable) do 
		
			if (inner_client.name == nil) then
				return false
			end

			-- Ignore the client if it *IS* the outer client
			if (outer_addr ~= inner_client.common_addr) then
				local inner_name = tostring(inner_client.name)
				if (outer_name == inner_name) then
					return false
				end
			end

		end

	end

	return true

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Validate_Player_Uniqueness(player)

	for _, client in pairs(ClientTable) do

		-- Don't do a self comparison.
		if (client.common_addr ~= player.common_addr) then
			if (client.name == player.name) then
				return false
			elseif (client.color == player.color) then
				return false
			elseif (client.team == player.team) then
				return false
			end
		end

	end

	return true

end

-------------------------------------------------------------------------------
-- For debugging...just reports all players in a game and their details.
-------------------------------------------------------------------------------
function Report_All_Players()

	DebugMessage("*** PLAYER REPORT ***")

	for _, client in pairs(ClientTable) do

		DebugMessage("Player: " .. tostring(client.name))
		DebugMessage("\tFaction: " .. tostring(client.faction))
		DebugMessage("\tColor: " .. tostring(client.color))

	end

	return true

end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- On_Internet_Event(): Convenience function for generically processing 
-- incoming internet events. Callers need to populate the Internet_Event_Table and 
-- register this function with the Net object and it will magically invoke 
-- their functions for them.
-------------------------------------------------------------------------------
function On_Internet_Event(event)

	if event.type == NETWORK_EVENT_TASK_COMPLETE then
		if (Internet_Event_Table[event.task] ~= nil) then
			Internet_Event_Table[event.task](event)
		end
	elseif event.type == NETWORK_EVENT_ERROR then
		MessageBox("Network Error %s", tostring(event.message))
	end

end

-------------------------------------------------------------------------------
-- On_LAN_Event(): Convenience function for generically processing incoming 
-- LAN events.  Callers need to populate the LAN_Event_Table and register this
-- function with the Net object and it will magically invoke thier functions 
-- for them.
-------------------------------------------------------------------------------
function On_LAN_Event(event)

	if (event == nil) then
		DebugMessage("LUA_NET: ERROR: Got a nil network event!")
	elseif (event.type == NETWORK_EVENT_TASK_COMPLETE) then
		if (LAN_Event_Table[event.task] ~= nil) then
			LAN_Event_Table[event.task](event)
		end
	elseif (event.type == NETWORK_EVENT_ERROR) then
		MessageBox("Network Error %s", tostring(event.message))
	end

end

-------------------------------------------------------------------------------
-- Start game response for Internet connections.
-------------------------------------------------------------------------------
function Internet_On_Start_Game()
	if (StartGameCalled == false) then
		DebugMessage("LUA_NET:  Internet_On_Start_Game():  Calling Net.MM_Start_Game()...")
		StartGameCalled = true	
		Report_All_Players()
		local itable = {}
		local client_count = 0
		for _, client in pairs(ClientTable) do
			table.insert(itable, client)
			if client.is_ai == nil or client.is_ai == false then client_count = client_count + 1 end
		end
		if client_count <= 1 then GameOptions.is_internet = false end
		Net.MM_Start_Game(GameOptions, itable)
	else
		DebugMessage("LUA_NET:  Internet_On_Start_Game():  Start game already called.  Exiting...")
	end
end

-------------------------------------------------------------------------------
-- Start game response for LAN connections.
-------------------------------------------------------------------------------
function LAN_On_Start_Game()
	if (StartGameCalled == false) then
		DebugMessage("LUA_NET:  LAN_On_Start_Game():  Calling Net.LAN_Start_Game()...")
		StartGameCalled = true	
		Report_All_Players()
		local itable = {}
		local client_count = 0
		for _, client in pairs(ClientTable) do
			table.insert(itable, client)
			if client.is_ai == nil or client.is_ai == false then client_count = client_count + 1 end
		end
		if client_count <= 1 then GameOptions.is_lan = false end
		Net.LAN_Start_Game(GameOptions, itable) --ClientTable)
	else
		DebugMessage("LUA_NET:  LAN_On_Start_Game():  Start game already called.  Exiting...")
	end
end

-------------------------------------------------------------------------------
-- Generic start game response.
-------------------------------------------------------------------------------
function Network_On_Start_Game()
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Internet_On_Start_Game()
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		LAN_On_Start_Game()
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_On_Start_Game()")
	end
end

-------------------------------------------------------------------------------
-- Returns the client data structure given it's common_addr.
-------------------------------------------------------------------------------
function Network_Get_Client(common_addr)
	if (ClientTable == nil) then
		return nil
	end
	return ClientTable[common_addr]
end

-------------------------------------------------------------------------------
-- Returns the client data given a player ID.
-------------------------------------------------------------------------------
function Network_Get_Client_By_ID(player_id)
	for _, client in pairs(ClientTable) do
		if (client.PlayerID == player_id) then
			return client
		end
	end
	return nil
end

-------------------------------------------------------------------------------
-- Handle cases where our common addr changes.
-------------------------------------------------------------------------------
function Network_Update_Local_Common_Addr(new_addr)
	if LocalClient.common_addr ~= new_addr then
		if ClientTable[LocalClient.common_addr] then
			ClientTable[LocalClient.common_addr] = nil
			ClientTable[new_addr] = LocalClient
		end
		LocalClient.common_addr = new_addr
	end
	Network_Resort_Client_Table()
end


-------------------------------------------------------------------------------
-- Table values with keys that hash to the same value iterate in the order in which
-- they were added to the table.  So the entries have to be added in the same order.
-- Pull all the entries out of the client table and do a real sort on them, then add
-- them back to the table so they're in the correct order.  8/7/2007 1:39:46 PM -- BMH
-------------------------------------------------------------------------------
function Network_Client_Table_Sort_Compare(index1, index2)
	return index1 < index2
end

function Network_Resort_Client_Table()
	local temp_table = {}
	for k,v in pairs(ClientTable) do
		table.insert(temp_table, k)
	end
	table.sort(temp_table, Network_Client_Table_Sort_Compare)
	local swap_table = ClientTable
	ClientTable = {}
	for _, addr in ipairs(temp_table) do
		ClientTable[addr] = swap_table[addr]
	end
end

-------------------------------------------------------------------------------
-- Adds the client specified by its common_addr to the client table.
-- Also enables voice chat for the peer.
-------------------------------------------------------------------------------
function Network_Add_Client(common_addr)

	ClientTable[common_addr] = { ["common_addr"] = common_addr }
	if (common_addr == LocalClient.common_addr) then
		ClientTable[common_addr] = LocalClient
	end
	
	if ((Net.Get_Signin_State() == "online") and
		(common_addr ~= LocalClient.common_addr)) then
		Net.Voice_Add_Peer(common_addr)
	end
	Network_Resort_Client_Table()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Get_AI_Player_Count()
	local count = 0
	for _, client in pairs(ClientTable) do
		if client.is_ai == true then
			count = count + 1
		end
	end
	return count
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Get_Client_Table_Count(include_ai)
	if (include_ai == nil) then
		include_ai = true
	end
	local count = 0
	for _, client in pairs(ClientTable) do
		if include_ai or (client.is_ai == nil or client.is_ai == false) then
			count = count + 1
		end
	end
	return count
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Calculate_Initial_Max_Player_Count()
	if (MapPlayerLimit == nil) then
		MapPlayerLimit = MAP_MAX_PLAYER_COUNT
	end

	if (GameOptions == nil) or (GameOptions.map_crc == nil) then
		MapPlayerLimit = MAP_MAX_PLAYER_COUNT
	else
		MapPlayerLimit = PGLobby_Get_Map_Player_Count(GameOptions.map_crc)
		--MapPlayerLimit = PGLobby_Get_Map_Player_Count(GameOptions.map_index)
		if ( MapPlayerLimit > MAP_MAX_PLAYER_COUNT ) then
			MapPlayerLimit = MAP_MAX_PLAYER_COUNT 
		end
	end

	MaxPlayerCount = MapPlayerLimit - Network_Get_AI_Player_Count()
end

-------------------------------------------------------------------------------
-- Removes the client specified by its common_addr from the client table.
-- Also disables voice chat for the peer.
-------------------------------------------------------------------------------
function Network_Remove_Client(common_addr)

	local seat = -1
	for index, client in pairs(ClientSeatAssignments) do
		if (client.common_addr == common_addr) then
			seat = index
			break
		end
	end

	if (seat ~= -1) then
		ClientSeatAssignments[seat] = {["is_closed"] = false}
		if _PGMOEnabled == true then
			local start_marker_id = PGMO_Get_Start_Marker_ID_From_Seat(seat)
			-- If the player has chosen a start position, free it.
			if (start_marker_id ~= nil) then
				PGMO_Clear_Start_Position(start_marker_id) 
			end
		end
	end
	
	local disconnector = ClientTable[common_addr]
	ClientTable[common_addr] = nil
	if TestValid(common_addr) and
		 common_addr ~= LocalClient.common_addr then
		Net.Voice_Remove_Peer(common_addr)
	end
	
	Network_Resort_Client_Table()
	return disconnector
	
end

-------------------------------------------------------------------------------
-- Enforce team-only chat.
-- NOTE:  All we're currently expecting of the client_table is that it is a 
-- map of maps with a common_addr field and a team field.
-------------------------------------------------------------------------------
function Network_Prune_Voice_Peers(client_table, local_team)

	if (client_table == nil) then
		client_table = ClientTable
	end
	
	if (local_team == nil) then
		local_team = LocalClient.team
	end

	for _, client in pairs(client_table) do
		if ((client.is_ai == nil) or (client.is_ai == false)) then
			if (client.team ~= local_team) then
				Net.Voice_Remove_Peer(client.common_addr)
			end
		end
	end
	
end

-------------------------------------------------------------------------------
-- Unenforce team-only chat.
-- NOTE:  All we're currently expecting of the client_table is that it is a 
-- map of maps with a common_addr field and a team field.
-------------------------------------------------------------------------------
function Network_Unprune_Voice_Peers(client_table, local_team)

	if (client_table == nil) then
		client_table = ClientTable
	end

	if (local_team == nil) then
		local_team = LocalClient.team
	end

	for _, client in pairs(client_table) do
		if ((client.is_ai == nil) or (client.is_ai == false)) then
			if (client.team ~= local_team) then
				Net.Voice_Add_Peer(client.common_addr)
			end
		end
	end
	
end
	
-------------------------------------------------------------------------------
-- Only the host may call this function.
-------------------------------------------------------------------------------
function Network_Send_Recommended_Settings(client)

	if (not HostingGame) then
		return
	end

	local dao = {}
	dao.common_addr = client.common_addr
	dao.team = _PGNet_Get_Unused_Team(client)
	dao.colors = _PGNet_Get_Unused_Colors(client)
	Network_Broadcast(MESSAGE_TYPE_HOST_RECOMMENDED_SETTINGS, dao)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Reset_Seat_Assignments()
	ClientSeatAssignments = {}
	for i = 1, VIEW_PLAYER_INFO_CLUSTER_COUNT do
		ClientSeatAssignments[i] = {["is_closed"] = false}
	end
end

-------------------------------------------------------------------------------
-- Only the host calls this function. 
-------------------------------------------------------------------------------
function Network_Assign_Host_Seat(client)

	if (not HostingGame) then
		return
	end
	
	local seat = HOST_SEAT_POSITION
	ClientSeatAssignments[seat] = client

end

-------------------------------------------------------------------------------
-- Only the host calls this function.
-------------------------------------------------------------------------------
function Network_Assign_Guest_Seat(client, seat_override)

	if (not HostingGame) then
		return
	end

	local seat = -1
	if seat_override ~= nil then
		if seat_override == HOST_SEAT_POSITION then
			DebugMessage("LUA_LOBBY: ERROR: Tried to assign a guest to the host seat for client : " .. tostring(client.common_addr))
			return
		end

		local client = ClientSeatAssignments[seat_override]
		if (client == nil) or (client.is_closed == false) then
			seat = seat_override
		end
	else
		local start_pos = HOST_SEAT_POSITION + 1

		for i = start_pos, CLIENT_SEATS_MAX do
			local client = ClientSeatAssignments[i]
			if (client == nil) or (client.is_closed == false) then
				seat = i
				break
			end
		end

		if (seat == -1) then
			DebugMessage("LUA_LOBBY: ERROR: Unable to find a seat assignment for client: " .. tostring(client.common_addr))
			return
		end
	end

	ClientSeatAssignments[seat] = client

end

-------------------------------------------------------------------------------
-- Only the host calls this function.
-------------------------------------------------------------------------------
function Network_Reseat_Guests()

	if (not HostingGame) then
		return
	end

	Network_Clear_Guest_Seats()

	for _, client in pairs(ClientTable) do
			
		-- Don't reseat the host.
		if (client.common_addr ~= LocalClient.common_addr) then
			Network_Assign_Guest_Seat(client)
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- Only the host calls this function.
-------------------------------------------------------------------------------
function Network_Clear_Guest_Seats()

	if (not HostingGame) then
		return
	end

	for seat, client in pairs(ClientSeatAssignments) do
			
		-- Don't clear the host seat.
		if (client.common_addr ~= LocalClient.common_addr) then
			ClientSeatAssignments[seat] = { ["is_closed"] = false }
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- Only guests call this function.
-------------------------------------------------------------------------------
function Network_Do_Seat_Assignment(triple)

	if (HostingGame) then
		return
	end
	
	local client = nil
	
	if triple.is_closed == true then
		client = { ["is_closed"] = true }
	elseif triple.is_closed == false then
		client = { ["is_closed"] = false }
	else
		client = Network_Get_Client(triple.client_addr)
	end

	if client == nil then
		client = { ["is_closed"] = true }
	end

	ClientSeatAssignments[triple.seat] = client

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Get_Seat(client)

	local result = nil
	
	if (client == nil) then
		return nil
	end
	
	for seat, seat_client in pairs(ClientSeatAssignments) do
		if (client.common_addr == seat_client.common_addr) then
			result = seat
			break
		end
	end
	
	return result

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Get_Client_From_Seat(seat)
	return ClientSeatAssignments[seat]
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Request_Start_Position(client, marker_id)

	-- If we're the host, just perform the action.
	if (HostingGame) then
		Network_Assign_Start_Position(client, marker_id)
		return
	end
	
	Network_Broadcast(MESSAGE_TYPE_PLAYER_REQUEST_START_POSITION, marker_id)
	
end

-------------------------------------------------------------------------------
-- Clear all local clients of their start positions.  If we're the host, we
-- send out a message instructing guests to do the same.
-------------------------------------------------------------------------------
function PGNetwork_Clear_Start_Positions()
	for _, client in pairs(ClientTable) do
		client.start_marker_id = nil
	end
	if (HostingGame) then
		Network_Broadcast(MESSAGE_TYPE_HOST_CLEAR_START_POSITIONS, LocalClient.common_addr)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Request_Clear_Start_Position(start_marker_id, common_addr)

	if (not HostingGame) then
		-- If we're a guest, we can only ever request our own start marker be cleared.
		common_addr = LocalClient.common_addr
	else
		-- If we're the host, we default to ourselves, otherwise we use the incoming argument.
		if (common_addr == nil) then
			common_addr = LocalClient.common_addr
		end
	end

	local duple = {}
	duple.client_addr = common_addr
	duple.start_marker_id = start_marker_id
	Network_Broadcast(MESSAGE_TYPE_PLAYER_CLEAR_START_POSITION, duple)

end
			
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Assign_Start_Position(client, start_marker_id, dao, send_to)

	if (not HostingGame) then
		return
	end
	
	local duple = {}
	duple.client_addr = client.common_addr
	duple.start_marker_id = start_marker_id
	client = Network_Get_Client(client.common_addr)
	client.start_marker_id = start_marker_id
	
	if (dao ~= nil) then
		dao.start_positions[client.common_addr] = duple
	else
		Network_Broadcast(MESSAGE_TYPE_PLAYER_ASSIGN_START_POSITION, duple, send_to)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Broadcast_Reset_Start_Positions()
	if (HostingGame) then
		Network_Broadcast(MESSAGE_TYPE_GAME_RESET_START_POSITIONS, 1)
	end
end

-------------------------------------------------------------------------------
-- Clears the client table.
-------------------------------------------------------------------------------
function Network_Clear_All_Clients()
	ClientTable = {}
	KickedPlayers = {}
	Network_Reset_Seat_Assignments()
end

-------------------------------------------------------------------------------
-- Generic user settings broadcaster.
-------------------------------------------------------------------------------
function Broadcast_Game_Settings(send_to)

	if (not HostingGame) then
		return
	end

	if (MINIMAL_BROADCAST) then
	
		local dao = {}
		dao.game_script_data = GameScriptData
		dao.seed = GameOptions.seed
		Broadcast_AI_Players(dao)
		Broadcast_Seat_Assignments(dao)
		Broadcast_Start_Positions(dao)
		Network_Broadcast(MESSAGE_TYPE_ALL_GAME_SETTINGS, dao, send_to)
		
	else
	
		DebugMessage("LUA_NET:  **** Broadcasting Game Settings ****")
		Network_Broadcast(MESSAGE_TYPE_GAME_SETTINGS, GameScriptData)
		Network_Broadcast(MESSAGE_TYPE_GAME_SEED, GameOptions.seed)
		Broadcast_AI_Players(nil, send_to)
		Broadcast_Seat_Assignments(nil, send_to)
		Broadcast_Start_Positions(nil, send_to)
		
	end
    
end

-------------------------------------------------------------------------------
-- Generic user settings broadcaster.
-------------------------------------------------------------------------------
function Send_User_Settings(user_table, send_to)

	-- By default, we broadcast our local client settings.
	if (user_table == nil) then
		user_table = LocalClient
	end

	-- Only the host may broadcast user settings for others (and then only AI)
	if (HostingGame) then
		if (not user_table.is_ai) then
			user_table = LocalClient
		end
	else
		user_table = LocalClient
	end
	
	if (MINIMAL_BROADCAST) then
		Send_User_Settings_Aggregated(user_table, send_to)
	else
		Send_User_Settings_Segregated(user_table, send_to)
	end
	
end
	

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Send_User_Settings_Aggregated(user_table, send_to)

	DebugMessage("LUA_NET:  **** Broadcasting User Settings AGGREGATED ****")
	
	local dao = {}
	dao.name = user_table.name
	dao.platform = user_table.platform
	dao.faction = user_table.faction
	dao.color = user_table.color
	dao.team = user_table.team
	dao.applied_medals = user_table.applied_medals
	dao.nat_type = tostring(LocalClient.nat_type)
	if (dao.nat_type == nil) then
		DebugMessage("LUA_NET:  ERROR: Unable to find our own NAT type.")
	end
	-- Should only be set in Global Conquest.
	dao.reset_globe = user_table.reset_globe
	
	Network_Broadcast(MESSAGE_TYPE_PLAYER_SETTINGS, dao, send_to)

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Send_User_Settings_Segregated(user_table, send_to)

	DebugMessage("LUA_NET:  **** Broadcasting User Settings SEGREGATED ****")
	
	-- Mandatory!!  If any of these settings are nil we have a problem
	Network_Broadcast(MESSAGE_TYPE_PLAYER_PLATFORM, user_table.platform, send_to)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_NAME, user_table.name, send_to)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_FACTION, tostring(user_table.faction), send_to)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_COLOR, tostring(user_table.color), send_to)
	Network_Broadcast(MESSAGE_TYPE_PLAYER_TEAM, tostring(user_table.team), send_to)
	
	-- Global Conquest only
	if (user_table.reset_globe ~= nil) then
		Network_Broadcast(MESSAGE_TYPE_PLAYER_RESET_GLOBE, user_table.reset_globe, send_to)
	end

	-- Medals
	Network_Broadcast(MESSAGE_TYPE_PLAYER_APPLIED_MEDALS, user_table.applied_medals, send_to)
	
	-- NAT
	if (NetworkState == NETWORK_STATE_INTERNET) then
		Network_Broadcast(MESSAGE_TYPE_PLAYER_NAT_TYPE, tostring(LocalClient.nat_type), send_to)
	end
	
end

-------------------------------------------------------------------------------
-- Broadcasts the individual elements of an array one at a time.
-- NOTE:  The client won't automatically assemble these chunks!!  The chunks
-- are broadcast in a duple with the index and the value, so on the other end
-- the client will have to populate it's table with the given index and value.
-------------------------------------------------------------------------------
function Broadcast_IArray_In_Chunks(message_type, i_array)

	-- It is possible that the value to be broadcast is null, which is OK.
	-- It's OK because in the initialization of the scene, we are populating
	-- combo boxes and lists and auto-selecting items which fire settings
	-- broadcasts before other elements are completely initialized.
	-- We just dont't send nil messages.
	if (i_array == nil) then
		DebugMessage("LUA_NET:  WARNING:  Asked to broadcast a nil value for type: " .. tostring(message_type))
		return
	end

	for index, achievement in ipairs(i_array) do
		local duple = 
		{
			index = index,
			achievement = achievement
		}
		Network_Broadcast(message_type, duple)
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Broadcast_AI_Players(dao, send_to)

	if (dao ~= nil) then
		dao.ai_players = {}
	end
	
	for _, player in pairs(AIPlayers) do
	
		if (dao ~= nil) then
			dao.ai_players[player.common_addr] = player
		else
			Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, player, send_to)
		end
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Broadcast_Seat_Assignments(dao, send_to)

	if (not HostingGame) then
		return
	end

	if (dao ~= nil) then
		dao.seat_assignments = {}
	end
	
	for seat, client in pairs(ClientSeatAssignments) do
	
		if client then
			local triple = {}
			triple.seat = seat
			triple.is_closed = client.is_closed
			triple.client_addr = client.common_addr
			if (dao ~= nil) then
				table.insert(dao.seat_assignments, triple)
			else
				Network_Broadcast(MESSAGE_TYPE_PLAYER_SEAT_ASSIGNMENT, triple, send_to)
			end
		end
	
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Broadcast_Start_Positions(dao, send_to)

	if (not HostingGame) then
		return
	end
	
	if (dao ~= nil) then
		dao.start_positions = {}
	end
	
	for common_addr, client in pairs(ClientTable) do
		if (client.start_marker_id ~= nil) then
			Network_Assign_Start_Position(client, client.start_marker_id, dao, send_to)
		end
	end
	
end

-------------------------------------------------------------------------------
-- Generic acceptance broadcaster.
-- In the Custom Lobby / LAN Lobby, the acceptance / declining of game 
-- settings is changed so often that the network traffic generated by 
-- broadcasting those is a problem.  The optimization here is that we only
-- broadcast acceptance / declination if it is different from the previous
-- broadcast.  Callers can override this in certain situations by passing
-- the ignore_optimization flag.
-------------------------------------------------------------------------------
function Broadcast_Game_Settings_Accept(value, ignore_optimization)

	if (value == nil) then
		value = true
	end	
	
	if (ignore_optimization == nil) then
		ignore_optimization = false
	end

	if ((value == _PGNetworkLastAcceptValue) and (not ignore_optimization)) then
		return
	end

	_PGNetworkLastAcceptValue = value
	
	if (value) then
		Network_Broadcast(MESSAGE_TYPE_GAME_SETTINGS_ACCEPT, LocalClient.common_addr)
	else
		Network_Broadcast(MESSAGE_TYPE_GAME_SETTINGS_DECLINE, LocalClient.common_addr)
	end
	
end

-------------------------------------------------------------------------------
-- Broadcasts a settings accept for each AI player.
-------------------------------------------------------------------------------
function Broadcast_AI_Game_Settings_Accept()
	for _, player in pairs(AIPlayers) do
		Network_Broadcast(MESSAGE_TYPE_GAME_SETTINGS_ACCEPT, player.common_addr)
	end
end

-------------------------------------------------------------------------------
-- Generic start countdown broadcaster
-------------------------------------------------------------------------------
function Broadcast_Game_Start_Countdown(tick_value, host_override_settings)

	local dao = {}
	dao.tick_value = tick_value
	dao.host_override_settings = host_override_settings
	Network_Broadcast(MESSAGE_TYPE_GAME_START_COUNTDOWN, dao)
	
end

-------------------------------------------------------------------------------
-- Begin Stats registration process.
-------------------------------------------------------------------------------
function Broadcast_Stats_Registration_Begin(nonce)
	if (HostingGame and GameOptions.ranked) then
		DebugMessage("LUA_ARBITRATION: HOST: Brodcasting nonce message: " .. tostring(nonce))
		Network_Broadcast(MESSAGE_TYPE_STATS_REGISTRATION_BEGIN, nonce)
	end
end

-------------------------------------------------------------------------------
-- Generic kill countdown broadcaster
-------------------------------------------------------------------------------
function Broadcast_Game_Kill_Countdown()
	Network_Broadcast(MESSAGE_TYPE_GAME_KILL_COUNTDOWN, LocalClient.name)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Broadcast_Host_Disconnected()
	if (HostingGame) then
		Network_Broadcast(MESSAGE_TYPE_HOST_DISCONNECTED, LocalClient.name)
	end
end

-------------------------------------------------------------------------------
-- JOE DELETE:  This needs to go away
-------------------------------------------------------------------------------
function Broadcast_Multiplayer_Winner(winner_addr)
	if (HostingGame) then
		Network_Broadcast(MESSAGE_TYPE_MULTIPLAYER_WINNER, winner_addr)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Broadcast_Heartbeat(dao)
	Network_Broadcast(MESSAGE_TYPE_HEARTBEAT, dao)
end

-------------------------------------------------------------------------------
-- Generic network message broadcaster.
-------------------------------------------------------------------------------
function Network_Broadcast(message_type, message, send_to)

	-- It is possible that the value to be broadcast is null, which is OK.
	-- It's OK because in the initialization of the scene, we are populating
	-- combo boxes and lists and auto-selecting items which fire settings
	-- broadcasts before other elements are completely initialized.
	-- We just dont't send nil messages.
	if (message == nil) then
		return
	end
	
	-- DebugMessage("LUA_NET -- Broadcast: type: %s, msg: %s", tostring(message_type), tostring(message))

	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
	
		if (send_to == nil) then
			Net.MM_Broadcast(message_type, message)
		else
			Net.MM_Send_To(send_to, message_type, message)
		end
		
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
	
		if (send_to == nil) then
			Net.LAN_Broadcast(message_type, message)
		else
			Net.LAN_Send_To(send_to, message_type, message)
		end
		
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Broadcast()")
	end

end

-------------------------------------------------------------------------------
-- Generic network session creator.
-------------------------------------------------------------------------------
function Network_Create_Session(session_data)
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		return Net.MM_Create(session_data)
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		return Net.LAN_Create_Session(session_data)
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Create_Session()")
	end
	return nil
end

-------------------------------------------------------------------------------
-- Generic start game broadcast.
-------------------------------------------------------------------------------
function Network_Broadcast_Start_Game_Signal(game_name)
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Net.MM_Broadcast(MESSAGE_TYPE_START_GAME, "starting...")
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		Net.LAN_Broadcast(MESSAGE_TYPE_START_GAME, "starting...")
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Broadcast_Start_Game_Signal()")
	end
end

-------------------------------------------------------------------------------
-- Generic game join.
-------------------------------------------------------------------------------
function Network_Join_Game(session)
	local result = false
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		if (session[X_CONTEXT_GAME_TYPE] == nil) then
			Net.Set_User_Info( { [X_CONTEXT_GAME_TYPE] = X_CONTEXT_GAME_TYPE_STANDARD } )
		else
			Net.Set_User_Info( { [X_CONTEXT_GAME_TYPE] = session[X_CONTEXT_GAME_TYPE] } )
		end
		result = Net.MM_Join(session.common_addr, session.security_id, session.security_key, session.host_port)
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		result = Net.LAN_Join(session.common_addr, session.security_id, session.security_key, session.host_port)
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Join_Game()")
	end
	return result
end

-------------------------------------------------------------------------------
-- Generic session finder.
-------------------------------------------------------------------------------
function Network_Find_Sessions(search_type, filters, player_match)
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		return Net.MM_Find_All(search_type, filters, player_match)
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		return Net.LAN_Find_Sessions()
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Find_Sessions()")
	end
	return false
end

-------------------------------------------------------------------------------
-- Generic game leave.
-------------------------------------------------------------------------------
function Network_Leave_Game()
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Net.MM_Leave()
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		Net.LAN_Leave()
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Leave_Game()")
	end
	ReservedPlayers = {}
	KickedPlayers = {}
	ClientTable = {}
	AIPlayers = {}
end

-------------------------------------------------------------------------------
-- Generic session stop.
-------------------------------------------------------------------------------
function Network_Stop_Session()
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Net.MM_Leave()
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		Net.LAN_Stop_Session()
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Stop_Session()")
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Update_Session(...)

	local refuse_joiners = false

	-- If the session has been set to closed, make sure we're immediately refusing joiners.
	if (PGLobbyLocalSessionOpen ~= nil) then
	
		if (PGLobbyLocalSessionOpen) then
			DebugMessage("LUA_LOBBY: JOIN REFUSAL: Session is set to open.")
			refuse_joiners = false
		else
			DebugMessage("LUA_LOBBY: JOIN REFUSAL: Session is set to closed.")
			refuse_joiners = true
		end
		
	end
	
	-- If the session state is open or unknown, we still want to automatically check the player count
	-- to determine if we should refuse joiners.
	if (not refuse_joiners) then
	
		-- We check player_count if all the data is valid.  Otherwise we're likely setting up a game.
		if ((CurrentlyJoinedSession ~= nil) and
			(CurrentlyJoinedSession.player_count ~= nil) and
			(CurrentlyJoinedSession.max_players ~= nil) and
			(CurrentlyJoinedSession.player_count >= CurrentlyJoinedSession.max_players)) then
			
			-- We're full!
			DebugMessage("LUA_LOBBY: JOIN REFUSAL: Session is full.  Auto-refusing...")
			refuse_joiners = true
		
		end
		
	end

	DebugMessage("LUA_LOBBY: JOIN REFUSAL: Now refusing joiners? ---> " .. tostring(refuse_joiners))
	Net.Force_Refuse_Joiners(refuse_joiners)
		
	if (ConnectionType == CONNECTION_TYPE_INTERNET) then
		Net.MM_Update(...)
	elseif (ConnectionType == CONNECTION_TYPE_LAN) then
		Net.LAN_Update_Session(...)
	else
		DebugMessage("LUA_NET: ERROR: Unknown connection type in Network_Update_Session()")
	end

	if HostingGame then
		Network_Broadcast(MESSAGE_TYPE_UPDATE_SESSION, CurrentlyJoinedSession)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Kick_Player(common_addr)
	Network_Broadcast(MESSAGE_TYPE_KICK_PLAYER, common_addr)
	KickedPlayers[common_addr] = Network_Remove_Client(common_addr)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Refuse_Player(common_addr)
	if (HostingGame) then
		Network_Broadcast(MESSAGE_TYPE_REFUSE_PLAYER, common_addr)
		Network_Remove_Client(common_addr)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Generate_AI_Player()

	local ai = {}
	ai.common_addr = Get_Next_AI_Common_Addr()
	ai.is_ai = true
	ai.faction = PG_FACTION_NOVUS
	ai.color = 9
	ai.team = 1
	ai.ai_difficulty = Get_Difficulty()
	if not ai.ai_difficulty then
		ai.ai_difficulty = AI_DIFFICULTIES[AI_MEDIUM_INDEX]
	end
	-- AI are always considered accepting
	ai.AcceptsGameSettings = true
	ai.name = Network_Get_AI_Name(ai.ai_difficulty)

	return ai

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_Get_AI_Name(difficulty)
	local difficulty_label = Get_Game_Text("TEXT_EASY_AI_PLAYER")
	if difficulty == Difficulty_Normal then
		difficulty_label = Get_Game_Text("TEXT_MEDIUM_AI_PLAYER")
	elseif difficulty == Difficulty_Hard then
		difficulty_label = Get_Game_Text("TEXT_HARD_AI_PLAYER")
	end
	return difficulty_label
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Next_AI_Common_Addr()
	AIPlayerSequence = AIPlayerSequence + 1
	return "AI_" .. AIPlayerSequence
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Add_AI_Player(force_unique)

	if (not HostingGame) then
		return
	end

	local ai_player = Generate_AI_Player()
	
	AIPlayers[ai_player.common_addr] = ai_player
	ClientTable[ai_player.common_addr] = ai_player
	
	if force_unique then
		ai_player.team = _PGNet_Get_Unused_Team(ai_player)
		ai_player.color = _PGNet_Get_Unused_Color(ai_player)
	end
	
	Network_Broadcast(MESSAGE_TYPE_PLAYER_AI_PLAYER_DETAILS, ai_player)

	return ai_player
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Edit_AI_Player(ai_player)
	-- It should have a common_addr already.
	if (ai_player.common_addr == nil) then
		DebugMessage("ERROR:  Invalid common_addr for edited AI player.  Unable to update!")
	end
	AIPlayers[ai_player.common_addr] = ai_player
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Kick_All_AI_Players()

	local temp = {}
	for _, ai in pairs(AIPlayers) do
		table.insert(temp, ai)
	end
	
	for _, ai in ipairs(temp) do
		Network_Kick_AI_Player(ai)
	end

end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Kick_AI_Player(player)
	if (player.is_ai) then
		Network_Broadcast(MESSAGE_TYPE_KICK_AI_PLAYER, player.common_addr)
		Network_Remove_Client(player.common_addr)
		AIPlayers[player.common_addr] = nil
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Generate_Reserved_Player(id)

	local reserved = {}
	reserved.common_addr = Get_Next_Reserved_Common_Addr()
	reserved.name = Create_Wide_String("Reserved " .. id)
	reserved.color = 9

	return reserved

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Is_Reserved_Player(common_addr)
	return ReservedPlayers[common_addr] ~= nil
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Next_Reserved_Common_Addr()
	ReservedPlayerSequence = ReservedPlayerSequence + 1
	return "RESERVED_" .. ReservedPlayerSequence
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Add_Reserved_Player(reserved_player)

	if (not HostingGame) then
		return
	end
	
	ReservedPlayers[reserved_player.common_addr] = reserved_player
	Network_Assign_Guest_Seat(reserved_player)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Add_Reserved_Players(count)

	if ((not HostingGame) or (count <= 0)) then
		return
	end
	
	for i = 1, count do
	
		local reserved_player = Generate_Reserved_Player(i)
		Network_Add_Reserved_Player(reserved_player)
		Network_Broadcast(MESSAGE_TYPE_RESERVED_PLAYER, reserved_player)
		
	end
   
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Kick_All_Reserved_Players()

	local temp = {}
	for _, reserved in pairs(ReservedPlayers) do
		table.insert(temp, reserved)
	end
	
	for _, reserved in ipairs(temp) do
		Network_Kick_Reserved_Player(reserved)
	end

end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Network_Kick_Reserved_Player(player)
	if (Is_Reserved_Player(player.common_addr)) then
		Network_Broadcast(MESSAGE_TYPE_KICK_RESERVED_PLAYER, player.common_addr)
		Network_Remove_Client(player.common_addr)
		ReservedPlayers[player.common_addr] = nil
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_All_Client_Accepts(value)

	if (value == nil) then
		value = true
	end
	
	local message = MESSAGE_TYPE_GAME_SETTINGS_ACCEPT
	if (value == false) then
		message = MESSAGE_TYPE_GAME_SETTINGS_DECLINE
	end
	
	for _, client in pairs(ClientTable) do
	
		if (not client.is_ai and client.AcceptsGameSettings ~= value) then
			client.AcceptsGameSettings = value
			Network_Broadcast(message, client.common_addr)
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_All_AI_Accepts(value)
	for _, client in pairs(ClientTable) do
		if (client.is_ai) then
			client.AcceptsGameSettings = value
		end
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Check_Accept_Status()
	for _, client in pairs(ClientTable) do
		if ((client.AcceptsGameSettings == nil) or (client.AcceptsGameSettings == false)) then
			return false
		end
	end
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Check_Guest_Accept_Status(host_common_addr)

	-- The host is always considered accepting, so we skip the host.
	for _, client in pairs(ClientTable) do
		if (client.common_addr ~= host_common_addr) then
			if ((client.AcceptsGameSettings == nil) or (client.AcceptsGameSettings == false)) then
				return false
			end
		end
	end
	return true
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Check_Stats_Registration_Status()
	for _, client in pairs(ClientTable) do
		if (client.StatsRegistered ~= true) then
			return false
		end
	end
	return true
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Client_Table_Count()
	local count = 0
	for _, client in pairs(ClientTable)do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_Clients_With_Player_IDs()

	for _, client in pairs(ClientTable) do
		client.PlayerID = Net.Get_Player_ID_By_Network_Address(client.common_addr)
		if (client.common_addr == LocalClient.common_addr) then
			LocalClient.PlayerID = client.PlayerID
		end

		if GameOptions.alliances_enabled then
			client.team = client.PlayerID + 1
		end
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Network_Get_Local_Username()

	local username = Get_Game_Text("TEXT_DEFAULT_PLAYER_NAME")
	local signin_state = Net.Get_Signin_State()
	if (signin_state == "online") or
		(signin_state == "local") or
		(signin_state == "non-live") then
		-- Set the chat name from the current XLive profile.
		username = Net.Get_User_Name()
		if ( not Is_Gamepad_Active() ) then
			Set_Profile_Value(PP_LAST_CHAT_NAME, tostring(username))
		end
	end
	if (username == nil or tostring(username) == "") then
		DebugMessage("LUA_LOBBY:  Unable to determine local username.  Using default player name.")
		username = Get_Game_Text("TEXT_DEFAULT_PLAYER_NAME")
	end
	return username

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGNet_Get_Unused_Team(target_client)

	local tally = {}
	
	-- Which teams are taken?
	for _, client in pairs(ClientTable) do
	
		-- Don't count the team this client is currently on.
		if (client.common_addr ~= target_client.common_addr) then
		
			-- For AI players the host will call this before their local settings have hit the ClientTable.
			if (client.common_addr == LocalClient.common_addr) then
				client = LocalClient
			end
			local team = tonumber(client.team)
			tally[team] = true 
			
		end
		
	end
	
	for i = 1, MAX_TEAMS do
		if (tally[i] == nil) then
			return i
		end
	end
	
	return 1 	-- Default to team 1

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGNet_Get_Client_Color_Tally(target_client)

	local tally = {}
	
	-- Which colors are taken?
	for _, client in pairs(ClientTable) do
	
		-- Don't count the color this client currently has.
		if (client.common_addr ~= target_client.common_addr) then
		
			-- For AI players the host will call this before their local settings have hit the ClientTable.
			if (client.common_addr == LocalClient.common_addr) then
				client = LocalClient
			end
			local color = tonumber(client.color)
			tally[color] = true 
			
		end
		
	end
	
	return tally
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGNet_Get_Unused_Color(target_client)

	local tally = _PGNet_Get_Client_Color_Tally(target_client)
	
	for _, color in pairs(({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })) do
		if (tally[color] == nil) then
			return color
		end
	end
	
	return ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[0] 	-- Default to the first chat color

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PGNet_Get_Unused_Colors(target_client)

	local tally = _PGNet_Get_Client_Color_Tally(target_client)
	local unused_colors = {}
	
	for _, color in pairs(({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })) do
		if (tally[color] == nil) then
			table.insert(unused_colors, color)
		end
	end
	
	return unused_colors
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGNet_Is_Color_Used(color)

	-- Which colors are taken?
	for _, client in pairs(ClientTable) do
		if ((client.color == color) and (client.common_addr ~= LocalClient.common_addr)) then
			return true
		end
	end
	
	return false
	
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
	Broadcast_Heartbeat = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Broadcast_Stats_Registration_Begin = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
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
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Is_Player_Of_Faction = nil
	Max = nil
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
	Network_Get_Client_Table_Count = nil
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
	Network_Update_Local_Common_Addr = nil
	OutputDebug = nil
	PGNetwork_Clear_Start_Positions = nil
	PGNetwork_Init = nil
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
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
	Kill_Unused_Global_Functions = nil
end

