-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Player_List_Dialog.lua#23 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Player_List_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Joe_Howes $
--
--            $Change: 86795 $
--
--          $DateTime: 2007/10/26 14:39:12 $
--
--          $Revision: #23 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGFactions")
require("PGUICommands")
require("PGOnlineAchievementDefs")
require("Player_List_Tooltip")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

------------------------------------------------------------------------
-- On_Init
------------------------------------------------------------------------
function On_Init()
	-- Need the network for the timer
	PGNetwork_Init()
	PGColors_Init()
	PGFactions_Init()

	Last_Update_Time = Net.Get_Time()

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	Register_Game_Scoring_Commands()
	local game_data = GameScoringManager.Get_Game_Script_Data_Table()
	if game_data and game_data.GameOptions and
		game_data.GameOptions.alliances_enabled then
		Alliances_Allowed = true
	else
		Alliances_Allowed = false
	end

	-- Force alliances to disabled for now
	--Alliances_Allowed = false

	PLAYER_NAME = Get_Game_Text("TEXT_INTERNET_SERVER_NAME_BUTTON")
	CREDITS = Get_Game_Text("TEXT_CREDITS")
	FACTION = Get_Game_Text("TEXT_INTERNET_COLOR") -- I know this is a weird name for faction, but that is how it is listed for text id...
	FPS = Get_Game_Text("TEXT_MULTIPLAYER_FPS") -- This needs to be added in again
	PING = Get_Game_Text("TEXT_INTERNET_PING_BUTTON")
	TEAM = Get_Game_Text("TEXT_HEADER_TEAM")
	
	if Alliances_Allowed then
		ALLIANCE = Get_Game_Text("TEXT_MULTIPLAYER_ALLIANCES")
		this.Player_List.Add_Column(ALLIANCE, JUSTIFY_CENTER)
	end

	this.Player_List.Add_Column(PLAYER_NAME, JUSTIFY_LEFT)
	this.Player_List.Add_Column(TEAM, JUSTIFY_CENTER)
	this.Player_List.Add_Column(CREDITS, JUSTIFY_CENTER)
	this.Player_List.Add_Column(FACTION, JUSTIFY_CENTER)
	this.Player_List.Add_Column(PING, JUSTIFY_CENTER)
	this.Player_List.Add_Column(FPS, JUSTIFY_CENTER)
	
	-- Nader 09.07.2007
	-- Setting the column widths explicity to ensure all columns are wide enough
	local width_remaining = 1.0
	if Alliances_Allowed then
		width_remaining = Set_Player_List_Column_Width(ALLIANCE, width_remaining, 0.15)
	end
	width_remaining = Set_Player_List_Column_Width(CREDITS, width_remaining, 0.10)
	width_remaining = Set_Player_List_Column_Width(FACTION, width_remaining, 0.15)
	width_remaining = Set_Player_List_Column_Width(FPS, width_remaining, 0.08)
	width_remaining = Set_Player_List_Column_Width(PING, width_remaining, 0.08)
	width_remaining = Set_Player_List_Column_Width(TEAM, width_remaining, 0.08)
	width_remaining = Set_Player_List_Column_Width(PLAYER_NAME, width_remaining, width_remaining)
	this.Player_List.Set_Header_Style("TEXT")
	this.Player_List.Refresh()
	
	Init_Medal_List()

	if Alliances_Allowed then
	
		-- Networked Alliance events
		this.Register_Event_Handler("Player_List_Alliance_Event", nil, On_Player_List_Alliance_Event)
		
		-- Alliance events
		ALLIANCE_EVENT_REQUEST_ALLIANCE				= "ALLIANCE_EVENT_REQUEST_ALLIANCE"
		ALLIANCE_EVENT_BREAK_ALLIANCE					= "ALLIANCE_EVENT_BREAK_ALLIANCE"
		ALLIANCE_EVENT_ACCEPT_ALLIANCE_REQUEST		= "ALLIANCE_EVENT_ACCEPT_ALLIANCE_REQUEST"
		ALLIANCE_EVENT_CANCEL_ALLIANCE_REQUEST		= "ALLIANCE_EVENT_CANCEL_ALLIANCE_REQUEST"
		
		-- Alliance Event Handlers
		Alliance_Event_Handlers = {}
		Alliance_Event_Handlers[ALLIANCE_EVENT_REQUEST_ALLIANCE]				= On_Network_Request_Alliance
		Alliance_Event_Handlers[ALLIANCE_EVENT_BREAK_ALLIANCE]				= On_Network_Break_Alliance
		Alliance_Event_Handlers[ALLIANCE_EVENT_ACCEPT_ALLIANCE_REQUEST]	= On_Network_Accept_Alliance_Request
		Alliance_Event_Handlers[ALLIANCE_EVENT_CANCEL_ALLIANCE_REQUEST]	= On_Network_Cancel_Alliance_Request
		
	end

	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)

	-- Register SFX handlers
	if this.Button_Gamercard then
		this.Register_Event_Handler("Mouse_On", this.Button_Gamercard, Play_Mouse_Over_Button_SFX)
		this.Register_Event_Handler("Button_Clicked", this.Button_Gamercard, Play_Button_Select_SFX)
		this.Register_Event_Handler("Button_Clicked", this.Button_Gamercard, On_Button_Gamercard_Clicked)
	end

	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Player_List, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Player_List, Play_Option_Select_SFX)
	this.Register_Event_Handler("Multiplayer_Match_Completed", nil, Hide_Dialog)

	Credits_Not_Visible_String = Create_Wide_String("--")

	Empty_Wstring = Create_Wide_String("")
	Missing_Wstring = Create_Wide_String("[MISSING]")
	local Message_List = GUIDialogComponent.Find_Dialog("Ingame_Message_List")
	if Message_List then
		Message_List_Script = Message_List.Get_Script()
	end

	Client_Table = { }
	Player_List_Rows = { }
	Aggregated_Alliance_Events = { }
	Is_Showing = true

	if Alliances_Allowed then
		Alliance_Request_List = { }
		Alliance_Checkboxes = { }
	end
	
end

function Set_Player_List_Column_Width(column, width_remaining, column_width)
	this.Player_List.Set_Column_Width(column, column_width)
	return width_remaining - column_width
end

-- -----------------------------------------------------------------------------
-- Init_Medal_List: this initializes the data needed to populate the
-- medals list.
-- -----------------------------------------------------------------------------
function Init_Medal_List()
	PGOnlineAchievementDefs_Init()
	MAX_NUM_MEDALS = 3
	MedalList = this.Medal_List

	if not TestValid(MedalList) then return end
	
	-- Columns definition
	MEDAL_ICON_1 = Create_Wide_String("TEXT_LAN_BUFF_1")
	MEDAL_ICON_2 = Create_Wide_String("TEXT_LAN_BUFF_2")
	MEDAL_ICON_3 = Create_Wide_String("TEXT_LAN_BUFF_3")
	
	MedalList.Add_Column(MEDAL_ICON_1, JUSTIFY_CENTER)
	MedalList.Add_Column(MEDAL_ICON_2, JUSTIFY_CENTER)
	MedalList.Add_Column(MEDAL_ICON_3, JUSTIFY_CENTER)	
	MedalList.Set_Column_Width(MEDAL_ICON_1, 0.33)
	MedalList.Set_Column_Width(MEDAL_ICON_2, 0.33)
	MedalList.Set_Column_Width(MEDAL_ICON_3, 0.33)
	MedalList.Set_Header_Style("TEXT") 
	MedalList.Refresh()
	
	-- Map to provides easy access to the columns
	MedalIndexToColumTag = {}
	MedalIndexToColumTag[1] = MEDAL_ICON_1
	MedalIndexToColumTag[2] = MEDAL_ICON_2
	MedalIndexToColumTag[3] = MEDAL_ICON_3
	
	EMPTY_MEDAL_BUCKET_TEXTURE = "i_alien_blueprint_close_slot.tga"
	
	-- Given that this scene goes on top of the game scene, we are going to manage our own tooltip.
	-- Besides, we want this tooltip to look more generic and not faction specific.  Also, it only 
	-- displays a line of text (buff description) so it is pretty straight forward.
	Init_Tooltip() -- Refer to Player_List_Tooltip.lua
	
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end

------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		if source == this.Button_Back then
			Play_SFX_Event("GUI_Main_Menu_Back_Select")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
	end
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Display_Dialog()
	Is_Showing = true
	this.Set_Screen_Position(0.5, 0.5)
	Client_Table = { }

	Initialize_Player_List()
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Hide_Dialog()
	Is_Showing = false
	GUIDialogComponent.Set_Active(false)
	-- Make sure we reset the tooltip data.

	if TestValid(Tooltip) then
		On_End_Buff_Tooltip()
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Alliance_Checkbox_Clicked(_, source, _)

	if not Alliances_Allowed then return end

	if (TestValid(source)) then
		
		-- Toggle the state
		local old_state = source.Is_Checked()
		local new_state = (not old_state)
		

		-- DATA: Respond to the new state.
		local local_player = Find_Player("local")
		local target_player_id = source.Get_User_Data()
		local target_player = Find_Player(target_player_id)
		
		if ((not old_state) and new_state) then			-- Was cleared before, user is checking the box.
		
			DebugMessage("LUA_ALLIANCES: Local user creating a new alliance.")
			
			-- *** New Alliance Request ***

			-- First we break any old alliances / pending requests.
			local has_ally, curr_ally = Has_Ally(local_player)
			if (has_ally) then
				DebugMessage("LUA_ALLIANCES: Breaking existing alliance: '" .. tostring(local_player.Get_Name()) .. "' -> '" .. tostring(curr_ally.Get_Name()) .. "'")
				Add_Alliance_Event(ALLIANCE_EVENT_BREAK_ALLIANCE, { local_player, curr_ally })
			end
			Clear_Pending_Alliance_Requests(local_player)
			
			-- Is there a pending request from someone else?
			if (Has_Pending_Request(target_player, local_player)) then
				-- Yes.  We accept the request.
				DebugMessage("LUA_ALLIANCES: Accepting alliance request from " .. tostring(target_player.Get_Name()))
				Add_Alliance_Event(ALLIANCE_EVENT_ACCEPT_ALLIANCE_REQUEST, { local_player, target_player })
			else
				-- No.  We are making a request.
				DebugMessage("LUA_ALLIANCES: Requesting alliance with " .. tostring(target_player.Get_Name()))
				Add_Alliance_Event(ALLIANCE_EVENT_REQUEST_ALLIANCE, { local_player, target_player })
			end
			
			
		elseif (old_state and (not new_state)) then		-- Was checked before, user is unchecking the box.
		
			DebugMessage("LUA_ALLIANCES: Local user is killing an existing alliance.")
			
			-- *** Kill Existing Alliance / Request ***
				
			if (local_player.Is_Ally(target_player)) then
			
				-- We are already allied with this player, so break the alliance.
				DebugMessage("LUA_ALLIANCES: Breaking alliance with " .. tostring(target_player.Get_Name()))
				Add_Alliance_Event(ALLIANCE_EVENT_BREAK_ALLIANCE, { local_player, target_player })
				
			--elseif (Has_Pending_Request(target_player, local_player)) then
			elseif (Has_Pending_Request(local_player, target_player)) then
			
				-- There is a pending request, so we cancel it.
				DebugMessage("LUA_ALLIANCES: Cancelling pending request from " .. tostring(target_player.Get_Name()))
				Add_Alliance_Event(ALLIANCE_EVENT_CANCEL_ALLIANCE_REQUEST, { local_player, target_player })
				
			end
			
		end
		
		Flush_Alliance_Events()

	end

end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Clear_Pending_Alliance_Requests(local_player)

	for other_player, requests in pairs(Alliance_Request_List) do
		if (requests[local_player] ~= nil) then
			DebugMessage("LUA_ALLIANCES: Auto-cancelling pending alliance request to " .. tostring(other_player.Get_Name()))
			Add_Alliance_Event(ALLIANCE_EVENT_CANCEL_ALLIANCE_REQUEST, { local_player, other_player })
		end
	end
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Add_Alliance_Event(label, args)
	DebugMessage("LUA_ALLIANCE: Adding alliance network event: " .. tostring(label))
	local dao = {}
	dao[1] = label
	dao[2] = args
	table.insert(Aggregated_Alliance_Events, dao)
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Flush_Alliance_Events()
	DebugMessage("LUA_ALLIANCE: Flushing all current alliance network events.")
	Send_GUI_Network_Event("Player_List_Alliance_Event", { Aggregated_Alliance_Events }) 
	Aggregated_Alliance_Events = {}
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Set_Player_Row_Data(row_id, player_data, player_table, initialize)

	local local_player = Find_Player("local")
	local target_player = Find_Player(player_table.PlayerID)
	local is_local_player = (local_player.Get_ID() == player_table.PlayerID)
	
	if Alliances_Allowed then
		-- Alliance checkboxes
		if (not is_local_player) and (not player_table.is_ai) then

			local scene = nil

			if (initialize) then

				this.Player_List.Set_Scene_Data(ALLIANCE, row_id, Create_Wide_String("Custom_Checkbox"))			
				scene = this.Player_List.Get_Scene_Data(ALLIANCE, row_id)
				if (scene) then
					scene.Set_User_Data(player_table.PlayerID)
					Alliance_Checkboxes[player_table.PlayerID] = scene
					scene.Set_Checked(false)
					this.Register_Event_Handler("Custom_Checkbox_Clicked", scene, On_Alliance_Checkbox_Clicked)
				end

			else
				scene = Alliance_Checkboxes[player_table.PlayerID] 
			end

			scene.Set_Checked(local_player.Is_Ally(target_player) or Has_Pending_Request(local_player, target_player))

		end
		
	end
	
			

	if player_data == nil then
		this.Player_List.Set_Text_Data(FPS, row_id, Credits_Not_Visible_String)
	else
		this.Player_List.Set_Text_Data(FPS, row_id, Get_Localized_Formatted_Number(player_data.FPS))
	end

	if player_data == nil or player_data.Credits == nil then
		this.Player_List.Set_Text_Data(CREDITS, row_id, Credits_Not_Visible_String)
	else
		this.Player_List.Set_Text_Data(CREDITS, row_id, Get_Localized_Formatted_Number(player_data.Credits))
	end

	if player_table.is_ai then
		this.Player_List.Set_Text_Data(PING, row_id, Credits_Not_Visible_String)
	else
		this.Player_List.Set_Text_Data(PING, row_id, Get_Localized_Formatted_Number(Net.Get_Ping_Time(player_table.common_addr)))
	end
	
	this.Player_List.Set_User_Data(row_id, player_table)
	this.Player_List.Set_Text_Data(PLAYER_NAME, row_id, player_table.name)
	this.Player_List.Set_Text_Data(TEAM, row_id, Get_Localized_Formatted_Number(player_table.team))
	this.Player_List.Set_Row_Color(row_id, tonumber(player_table.color))
	this.Player_List.Set_Text_Data(FACTION, row_id, Get_Localized_Faction_Name(Get_Faction_Numeric_Form(player_table.faction)))
	
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Initialize_Player_List()
	Player_List_Rows = { }
	this.Player_List.Clear()
	this.Player_List.Reset_Row_Selection()

	if TestValid(MedalList) then
		MedalList.Clear()
		MedalList.Reset_Row_Selection()
	end

	Client_Table = Get_Client_Table()

	local player_count = 0
	for _, player in pairs(Client_Table) do
		local player_data = Get_Player_Data(player.PlayerID)

		-- This can happen if the player is AI controlled or is inactive
		if player.is_ai or player_data ~= nil then
			player_count = player_count + 1
			local new_row = this.Player_List.Add_Row()
			table.insert(Player_List_Rows, new_row)
			Set_Player_Row_Data(new_row, player_data, player, true)
		
			if TestValid(MedalList) then
				-- Now update the player's medal display.
				Set_Player_Medal_Data(player)
			end
		end
	end

	-- If there are only two human players left in the game, they cannot
	-- form an alliance
	if player_count == 2 then
		Alliances_Allowed = false
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Set_Player_Medal_Data(player_data)
	
	-- tooltip data:
	-- should be custom with the desc of the buff: player_data.BuffDesc
	if (not TestValid(MedalList)) or (not player_data) then 
		return
	end
	
	local medal_ct = 1	
	local new_row = MedalList.Add_Row()
	if player_data.applied_medals then		
		for _, achievement_id in ipairs(player_data.applied_medals) do
			if medal_ct > MAX_NUM_MEDALS then
				break
			end
			
			local achievement_data = OnlineAchievementMap[achievement_id]
			local col_tag = MedalIndexToColumTag[medal_ct]
			MedalList.Set_Scene_Data(col_tag, new_row, Create_Wide_String("Medal_Icon_Scene"))			
			local scene = MedalList.Get_Scene_Data(col_tag, new_row)
			if TestValid(scene) then 	
				scene.Set_User_Data({achievement_data.Texture, achievement_data.BuffDesc})
				this.Register_Event_Handler("Display_Buff_Tooltip", scene, On_Display_Buff_Tooltip)
				this.Register_Event_Handler("End_Buff_Tooltip", scene, On_End_Buff_Tooltip)
			end
			medal_ct = medal_ct + 1
		end	
	end
	
	-- The buckets that have no medals get an "Empty bucket" kind of texture.
	for i = medal_ct, MAX_NUM_MEDALS do
		local col_tag = MedalIndexToColumTag[i]
		MedalList.Set_Scene_Data(col_tag, new_row, Create_Wide_String("Medal_Icon_Scene"))
		local scene = MedalList.Get_Scene_Data(col_tag, new_row)
		if TestValid(scene) then 	
			scene.Set_User_Data({EMPTY_MEDAL_BUCKET_TEXTURE})
			-- No need to register for signals since these guys have no tooltip data!.
		end
	end
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Refresh_Player_List()
	for _, row_id in pairs(Player_List_Rows) do
		local client = this.Player_List.Get_User_Data(row_id)
		local player_id = client.PlayerID
		local player_data = Get_Player_Data(player_id)

		-- This can happen if the player is AI controlled or is inactive
		if player_data ~= nil then
			Set_Player_Row_Data(row_id, player_data, client)
		end
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Update()

	if (not Is_Showing) then
		return
	end
	
	local current_time = Net.Get_Time()
	if current_time - Last_Update_Time >= 1 then
		Refresh_Player_List()
		Last_Update_Time = current_time
	end

	if TestValid(Tooltip) then
		-- If the tooltip is active we want to update its position.
		Update_Tooltip()
	end
	
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Can_Ally(player1, player2)
	if player1 == player2 then return false end
	if not Alliances_Allowed then return false end
	if player1 == nil or player2 == nil then return false end

	local num_players = 0
	for _, table1 in pairs(Client_Table) do
		num_players = num_players + 1
	end

	if num_players <= 2 then return false end

	return true
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Has_Ally(player)
	for _, table in pairs(Client_Table) do
		local other_player = Find_Player(table.PlayerID)
		if player ~= other_player and
			player.Is_Ally(other_player) then
			return true, other_player
		end
	end
	return false
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Get_Selected_Player()
	local row = this.Player_List.Get_Selected_Row_Index()
	if row >= 0 then
		local player_id = this.Player_List.Get_User_Data(row).PlayerID
		return Find_Player(player_id)
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Is_Valid_Game_Text(wstr)
	if type(wstr) ~= "userdata" then return false end
	if wstr.compare == nil then return false end
	if wstr.compare(Missing_Wstring) then return false end
	return true
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Get_Player_Addr(player_id)

	DebugMessage("LUA_ALLIANCES: Getting address for player: " .. tostring(player_id))
		
	if ((Client_Table == nil) or (#Client_Table == 0)) then
		DebugMessage("LUA_ALLIANCES: WARNING: Client_Table is invalid...retrieving...")
		Client_Table = Get_Client_Table()
	end

	for addr, table in pairs(Client_Table) do
		if player_id == table.PlayerID then
			return addr
		end
	end
			
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Get_Client_Table()
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ((ctable == nil) or (ctable.ClientTable == nil)) then 
		DebugMessage("LUA_ALLIANCES: ERROR: Unable to get client table from the game scoring manager!")
		return nil
	end
	return ctable.ClientTable
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Update_Client_Table()
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable == nil or ctable.ClientTable == nil then return end

	ctable.ClientTable = Client_Table
	GameScoringManager.Set_Player_Info_Table(ctable)

	local game_mode_script = Get_Game_Mode_Script()
	game_mode_script.Call_Function("Setup_Teams")

	local chat_dialog = GUIDialogComponent.Find_Dialog("Ingame_Chat_Dialog")
	if chat_dialog then
		chat_script = chat_dialog.Get_Script()
		if chat_script then
			chat_script.Call_Function("Setup_Teams")
		end
	end
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Set_Unique_Teams(player1, player2)
	local player1_id = player1.Get_ID()
	local player2_id = player2.Get_ID()

	local player1_addr = Get_Player_Addr(player1_id)
	local player2_addr = Get_Player_Addr(player2_id)

	-- player ids are 0 based and teams are 1 based
	Client_Table[player1_addr].team = player1_id + 1
	Client_Table[player2_addr].team = player2_id + 1

	Update_Client_Table(Client_Table)
end

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- A L L I A N C E   E V E N T   H A N D L E R S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Player_List_Alliance_Event(event, source, event_list)

	if ((event_list == nil) or (#event_list == 0)) then
		return
	end
	
	for _, dao in ipairs(event_list) do
		local label = dao[1]
		local args = dao[2]
		local handler = Alliance_Event_Handlers[label]
		if (handler == nil) then
			DebugMessage("LUA_ALLIANCES: ERROR: Unknown alliance event handler: " .. tostring(dao.label))
		else
			handler(args)
		end
	end
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Network_Break_Alliance(args)

	local player1 = args[1]
	local player2 = args[2]
	
	DebugMessage("LUA_ALLIANCES: ALLIANCE EVENT:  Break Alliance:  " .. tostring(player1) .. " -> " .. tostring(player2))

	player1.Make_Enemy(player2)
	player2.Make_Enemy(player1)
	Set_Unique_Teams(player1, player2)
	FogOfWar.ReInitialize(player1)
	FogOfWar.ReInitialize(player2)

	-- Remove any pending requests
	Remove_Pending_Request(player1, player2)
	Remove_Pending_Request(player2, player1)
	
	Raise_Game_Event("MP_Alliance_Broken", player1)
	Raise_Game_Event("MP_Alliance_Broken", player2)

	local local_player = Find_Player("local")
	if local_player == player1 or local_player == player2 then
		local wstr_msg = Get_Game_Text("TEXT_ALLIANCE_BROKEN")
		if Is_Valid_Game_Text(wstr_msg) then
			Replace_Token(wstr_msg, player1.Get_Name(), 1)
			Replace_Token(wstr_msg, player2.Get_Name(), 2)
			Display_Message(wstr_msg, COLOR_WHITE)
		else -- Temporary until this is localized
			Display_Message(Create_Wide_String(string.format("%s and %s have broken their alliance.", player1.Get_Name(), player2.Get_Name())), COLOR_WHITE)
		end
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Set_Common_Team(player1, player2)
	local player1_id = player1.Get_ID()
	local player2_id = player2.Get_ID()

	local player1_addr = Get_Player_Addr(player1_id)
	local player2_addr = Get_Player_Addr(player2_id)

	DebugMessage("LUA_ALLIANCES:  Setting common teams...")
	DebugMessage("LUA_ALLIANCES:     Between '" .. tostring(player1.Get_Name()) .. "' -> " .. tostring(player1_addr) .. "'")
	DebugMessage("LUA_ALLIANCES:     And '" .. tostring(player2.Get_Name()) .. "' -> " .. tostring(player2_addr) .. "'")
	
	-- player ids are 0 based and teams are 1 based
	Client_Table[player1_addr].team = player1_id + 1
	Client_Table[player2_addr].team = player1_id + 1

	Update_Client_Table(Client_Table)
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Network_Accept_Alliance_Request(args)

	local player1 = args[1]
	local player2 = args[2]
	
	DebugMessage("LUA_ALLIANCES: ALLIANCE EVENT:  Accept Alliance:  " .. tostring(player1) .. " -> " .. tostring(player2))

	player1.Make_Ally(player2)
	player2.Make_Ally(player1)
	Set_Common_Team(player1, player2)

	-- Remove any pending requests
	Remove_Pending_Request(player1, player2)
	Remove_Pending_Request(player2, player1)
	
	Raise_Game_Event("MP_Alliance_Formed", player1)
	
	local local_player = Find_Player("local")
	if local_player == player1 or local_player == player2 then
		local wstr_msg = Get_Game_Text("TEXT_ALLIANCE_FORGED")
		if Is_Valid_Game_Text(wstr_msg) then
			Replace_Token(wstr_msg, player1.Get_Name(), 1)
			Replace_Token(wstr_msg, player2.Get_Name(), 2)
			Display_Message(wstr_msg, COLOR_WHITE)
		else
			Display_Message(Create_Wide_String(string.format("%s and %s have have forged an alliance.", player1.Get_Name(), player2.Get_Name())), COLOR_WHITE)
		end
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Network_Request_Alliance(args)

	local player1 = args[1]
	local player2 = args[2]
	
	DebugMessage("LUA_ALLIANCES: ALLIANCE EVENT:  Request Alliance:  " .. tostring(player1) .. " -> " .. tostring(player2))
	
	Add_Pending_Request(player1, player2)
	
	local local_player = Find_Player("local")
	if local_player == player1 or local_player == player2 then
		local wstr_msg = Get_Game_Text("TEXT_ALLIANCE_REQUESTED")
		if Is_Valid_Game_Text(wstr_msg) then
			Replace_Token(wstr_msg, player1.Get_Name(), 1)
			Replace_Token(wstr_msg, player2.Get_Name(), 2)
			Display_Message(wstr_msg, player1.Get_Color())
		else
			Display_Message(Create_Wide_String(string.format("%s has requested an alliance with %s.", player1.Get_Name(), player2.Get_Name())), COLOR_WHITE)
		end
	end
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Network_Cancel_Alliance_Request(args)

	local player1 = args[1]
	local player2 = args[2]
	
	DebugMessage("LUA_ALLIANCES: ALLIANCE EVENT:  Cancel Alliance Request:  " .. tostring(player1) .. " -> " .. tostring(player2))
	
	-- Remove any pending requests
	Remove_Pending_Request(player1, player2)
	Remove_Pending_Request(player2, player1)
	
	local local_player = Find_Player("local")
	if local_player == player1 or local_player == player2 then
		local wstr_msg = Get_Game_Text("TEXT_ALLIANCE_CANCELLED")
		if Is_Valid_Game_Text(wstr) then
			Replace_Token(wstr_msg, player1.Get_Name(), 1)
			Replace_Token(wstr_msg, player2.Get_Name(), 2)
			Display_Message(wstr_msg, player1.Get_Color())
		else
			Display_Message(Create_Wide_String(string.format("%s has rescinded the alliance request with %s.", player1.Get_Name(), player2.Get_Name())), COLOR_WHITE)
		end
	end
	
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Add_Pending_Request(player1, player2)
	local target_list = Alliance_Request_List[player2]
	if target_list == nil then target_list = { } end
	target_list[player1] = true -- any value but nil will do
	Alliance_Request_List[player2] = target_list
	DebugMessage("LUA_ALLIANCES: Adding pending request between '" .. tostring(player1.Get_Name()) .. "' and '" .. tostring(player2.Get_Name()) .. "'")
end


------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Remove_Pending_Request(player1, player2)
	local target_list = Alliance_Request_List[player2]
	if target_list ~= nil then
		target_list[player1] = nil
	end
	Alliance_Request_List[player2] = target_list
	DebugMessage("LUA_ALLIANCES: Removing pending request between '" .. tostring(player1.Get_Name()) .. "' and '" .. tostring(player2.Get_Name()) .. "'")
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Has_Pending_Request(querying_player, player_to_query)
	local player_to_query_list = Alliance_Request_List[player_to_query]
	if player_to_query_list ~= nil and
		player_to_query_list[querying_player] ~= nil then
		return true
	else
		return false
	end
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function On_Button_Gamercard_Clicked(event, source)
	local row_id = this.Player_List.Get_Selected_Row_Index()
	if row_id >= 0 then
		local player = this.Player_List.Get_User_Data(row_id)
		if not player.is_ai then
			local player_id = this.Player_List.Get_User_Data(row_id).PlayerID

			if player_id then
				local common_addr = Get_Player_Addr(player_id)
				local xuid = Net.Get_XUID_By_Network_Address(common_addr)
				Net.Show_Gamer_Card_UI(xuid)
			end
		end
	end
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Display_Message(message, color)
	if Message_List_Script then
		Message_List_Script.Call_Function("Add_Parsed_Message", message, color)
	end
end
