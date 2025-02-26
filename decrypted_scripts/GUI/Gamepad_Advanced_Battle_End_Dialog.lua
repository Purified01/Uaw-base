if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[74] = true
LuaGlobalCommandLinks[195] = true
LuaGlobalCommandLinks[33] = true
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[83] = true
LuaGlobalCommandLinks[115] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[36] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Advanced_Battle_End_Dialog.lua#17 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Advanced_Battle_End_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Joe_Howes $
--
--            $Change: 96029 $
--
--          $DateTime: 2008/03/31 15:47:46 $
--
--          $Revision: #17 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	-- register required event handlers
	this.Register_Event_Handler("Controller_Y_Button_Up", nil, Gamer_Card_Clicked)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Lobby_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Lobby_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, Player_Review_Clicked)
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Save_Replay_Clicked)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Results_List_Box, Selected_Results_Changed)

	-- Setup the tab ordering
	--this.Button_Lobby.Set_Tab_Order(Declare_Enum())
	--this.Button_Save_Replay.Set_Tab_Order(Declare_Enum())

	-- turn off replay button by default
	this.Button_Save_Replay.Enable(false)
	this.Button_Save_Replay.Set_Hidden(true)
	this.Button_A.Set_Hidden(true)

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- Initialize the results list box
	Results_List = this.Results_List_Box
	Results_List.Set_Tab_Order(Declare_Enum(0))
	
	VOICE_CHAT = Create_Wide_String("VOICE_CHAT")
	PLAYER_NAME = Create_Wide_String("PLAYER_NAME")
	PLAYER_FACTION = Create_Wide_String("PLAYER_FACTION")
	NO_CHAT_ICON = Create_Wide_String("i_no_medal.tga")
	CHAT_ON_ICON = Create_Wide_String("i_dialogue_radio_on.tga")
	CHAT_OFF_ICON = Create_Wide_String("i_dialogue_radio_off.tga")

	UNITS_DESTROYED = Get_Game_Text("TEXT_HEADER_UNITS_DESTROYED")
	BUILDINGS_DESTROYED = Get_Game_Text("TEXT_HEADER_BUILDINGS_DESTROYED")
	HEROES_DESTROYED = Get_Game_Text("TEXT_HEADER_HEROES_DESTROYED")
	RESOURCES_COLLECTED = Get_Game_Text("TEXT_HEADER_RESOURCES_COLLECTED")
--	PLAYER_RANK = Get_Game_Text("TEXT_HEADER_PLAYER_RANK")

	Results_List.Add_Column(VOICE_CHAT, JUSTIFY_LEFT)
	Results_List.Add_Column(PLAYER_NAME, JUSTIFY_LEFT)
	Results_List.Add_Column(PLAYER_FACTION, JUSTIFY_CENTER)
	Results_List.Add_Column(UNITS_DESTROYED, JUSTIFY_CENTER)
	Results_List.Add_Column(BUILDINGS_DESTROYED, JUSTIFY_CENTER)
	Results_List.Add_Column(HEROES_DESTROYED, JUSTIFY_CENTER)
	Results_List.Add_Column(RESOURCES_COLLECTED, JUSTIFY_CENTER)
--	Results_List.Add_Column(PLAYER_RANK, JUSTIFY_CENTER)

	-- Chat, name, and faction have no header while the rest do
	Results_List.Set_Header_Style("TEXT")
	Results_List.Set_Header_Style("NONE", VOICE_CHAT)
	Results_List.Set_Header_Style("NONE", PLAYER_NAME)
	Results_List.Set_Header_Style("NONE", PLAYER_FACTION)
	Results_List.Enable_Selection_Highlight(false) -- need to see the selection with gamepad

	Results_List.Set_Column_Width(VOICE_CHAT, 0.05)
	Results_List.Set_Column_Width(PLAYER_NAME, 0.25)
	Results_List.Set_Column_Width(PLAYER_FACTION, 0.12)
	Results_List.Set_Column_Width(UNITS_DESTROYED, 0.12)
	Results_List.Set_Column_Width(BUILDINGS_DESTROYED, 0.12)
	Results_List.Set_Column_Width(HEROES_DESTROYED, 0.12)
	Results_List.Set_Column_Width(RESOURCES_COLLECTED, 0.12)
--	Results_List.Set_Column_Width(PLAYER_RANK, 0.1)
	Results_List.Refresh()

	this.Register_Event_Handler("List_Selected_Index_Changed", Results_List, Play_Option_Select_SFX)	

	Save_Replay_Dialog = nil

	PGColors_Init()
	PGNetwork_Init()

	Connected_To_Live = Net.Get_Signin_State() == "online"
		
	-- Disable save replay button if this is a loaded save game
	if Is_Loaded_Save_Game() then
		if this.Button_Save_Replay.Is_Enabled() == true then
			this.Button_Save_Replay.Enable(false)
			this.Button_Save_Replay.Set_Hidden(true)
			this.Button_A.Set_Hidden(true)
		end
	end
	
	Register_Game_Scoring_Commands()
	Freeze_Multiplayer()
	CloseHuds = true
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	
	this.Focus_First()
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
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Option_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
	end
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
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end


-- Less than comparator to sort teams based on team number
function Team_Sort_By_Ordinal_Compare(team1_table, team2_table)
	-- Grab a player from each team
	local player1_table = team1_table[1]
	local player2_table = team2_table[1]

	return player1_table.team < player2_table.team
end

-- Less than comparator to sort players by rank within a team
function Team_Sort_By_Rank_Compare(player1_table, player2_table)
	return player1_table.rank < player2_table.rank
end

-- We should be getting this from XML, but it ends up in FactionClass, which isn't wrapped (yet)
function Get_Faction_Icon_Name(player)
	local faction = player.Get_Faction_Name()
	if faction == "MASARI" then 
		return Create_Wide_String("i_logo_masari_leaderboard.tga")
	elseif faction == "ALIEN" then
		return Create_Wide_String("i_logo_aliens_leaderboard.tga")
	elseif faction == "NOVUS" then
		return Create_Wide_String("i_logo_novus_leaderboard.tga")
	else
		return Create_Wide_String("i_logo_military_leaderboard.tga")
	end
end

function Play_End_Battle_Music()

	local is_winner = false
	local winner_faction
	local loser_faction

	for _, results in pairs(Winning_Team_List) do
		if winner_faction == nil then winner_faction = results.faction end
		if results.player ==  LocalPlayer then
			is_winner = true
			winner_faction = results.faction
			break
		end
	end

	for _, team in pairs(Teams) do
		for _, results in pairs(team) do
			if loser_faction == nil then loser_faction = results.faction end
			if is_winner == false and results.player == LocalPlayer then
				loser_faction = results.faction
				break
			end
		end
	end

	if is_winner then
		if winner_faction == "MASARI" then 
			Play_Music("Masari_Win_Tactical_Event")
		elseif winner_faction == "ALIEN" then
			Play_Music("Alien_Win_Tactical_Event")
		elseif winner_faction == "NOVUS" then
			Play_Music("Novus_Win_Tactical_Event")
		else
			Play_Music("Military_Win_Tactical_Event")
		end
	else
		if winner_faction == "MASARI" then 
			Play_Music("Lose_To_Masari_Event")
		elseif winner_faction == "ALIEN" then
			Play_Music("Lose_To_Alien_Event")
		elseif winner_faction == "NOVUS" then
			Play_Music("Lose_To_Novus_Event")
		else
			Play_Music("Lose_To_Military_Event")
		end
	end
end

function Finalize_Init(is_multiplayer)

	LocalPlayer = Find_Player("local")
	
	Dialog_Active = true
	if is_multiplayer ~= nil then
		Dialog_For_Multiplayer = is_multiplayer
	end

	if Dialog_For_Multiplayer then
		if Net == nil then
			Register_Net_Commands()
		end
		this.Button_X.Set_Hidden(false)
		this.Button_Gamer_Card.Set_Hidden(false)
		this.Button_Player_Review.Set_Hidden(false)
		this.Button_Y.Set_Hidden(false)
	else
		this.Button_X.Set_Hidden(true)
		this.Button_Gamer_Card.Set_Hidden(true)
		this.Button_Player_Review.Set_Hidden(true)
		this.Button_Y.Set_Hidden(true)
	end

	-- The game always starts at frame 0, so we just need to get the current frame in order to calculate time
	local user_data = this.Get_User_Data()
	local session_length = Get_Localized_Formatted_Number.Get_Time(user_data.GameEndTime)
	local session_length_string = Get_Game_Text("TEXT_SESSION_LENGTH")
	session_length_string.append(Create_Wide_String(" ")).append(session_length)
	this.Text_Session_Length.Set_Text(session_length_string)

	-- Get the results
	local scoring_script = Get_Game_Scoring_Script()
	if scoring_script == nil then return end
	ResultsTable = scoring_script.Get_Variable("ResultsTable")

	-- Figure out the winning team
	Winning_Team = nil
	local winner = user_data.Winner
	for idx, results in pairs(ResultsTable) do
		if results.player == winner then
			Winning_Team = results.team
		end
	end

	-- Break up the players into teams
	Teams = {}
	Winning_Team_List = {}
	local local_team = nil
	for idx, results in pairs(ResultsTable) do
		if results.team == Winning_Team then
			table.insert(Winning_Team_List, results)
		else
			if Teams[results.team] == nil then
				Teams[results.team] = {}
			end
			table.insert(Teams[results.team], results)
		end
		if results.player ==  LocalPlayer then
			local_team = results.team
		end
	end
	
	-- Can't call table.sort on a table with non-sequential array elements.
	-- Re-add all the elements to an array before calling sort.
	local tmp_teams = {}
	for k,v in pairs(Teams) do
		table.insert(tmp_teams, v)
	end
	Teams = tmp_teams

	-- Organize teams by team number
	table.sort(Teams, Team_Sort_By_Ordinal_Compare)

	-- Sort each team by rank
	for idx, team in pairs(Teams) do
		table.sort(team, Team_Sort_By_Rank_Compare)
	end

	RowsByID = {}
	ClientDetails = {}

	local last_team = nil
	for _, results in pairs(Winning_Team_List) do
		last_team = Add_Player_Results(results, last_team)
	end

	for _, team in pairs(Teams) do
		for _, results in pairs(team) do
			last_team = Add_Player_Results(results, last_team)
		end
	end

	Network_Unprune_Voice_Peers(ClientDetails, local_team)
	
	-- Make sure the rows get setup properly, so make sure to refresh
	Results_List.Refresh()
	if #RowsByID > 0 then
		Results_List.Set_Selected_Row_Index(RowsByID[1])
	end

	Play_End_Battle_Music()
	
	return true
end

function Add_Player_Results(results, last_team)
	local player = results.player
	local new_row = Results_List.Add_Row()

	if results.team ~= last_team then
		last_team = results.team
		local team_wstring = Get_Game_Text("TEXT_HEADER_TEAM")
		team_wstring.append(Create_Wide_String(" ")).append(Get_Localized_Formatted_Number(results.team))
		Results_List.Set_Text_Data(PLAYER_NAME, new_row, team_wstring)
		if results.team == Winning_Team then
			Results_List.Set_Text_Data(PLAYER_FACTION, new_row, Get_Game_Text("TEXT_VICTORY"))
		else
			Results_List.Set_Text_Data(PLAYER_FACTION, new_row, Get_Game_Text("TEXT_DEFEAT"))
		end
		new_row = Results_List.Add_Row()
	end

	table.insert(RowsByID, new_row)
	Results_List.Set_User_Data(new_row, results)
	ClientDetails[results.common_addr] = results

	Results_List.Set_Text_Data(PLAYER_NAME, new_row, player.Get_Name())
	Results_List.Set_Texture(PLAYER_FACTION, new_row, Get_Faction_Icon_Name(player))
	Results_List.Set_Text_Data(UNITS_DESTROYED, new_row, Get_Localized_Formatted_Number(results.units_destroyed))
	Results_List.Set_Text_Data(BUILDINGS_DESTROYED, new_row, Get_Localized_Formatted_Number(results.buildings_destroyed))
	Results_List.Set_Text_Data(HEROES_DESTROYED, new_row, Get_Localized_Formatted_Number(results.heroes_destroyed))
	Results_List.Set_Text_Data(RESOURCES_COLLECTED, new_row, Get_Localized_Formatted_Number(player.Get_Total_Credits_Collected()))
--	Results_List.Set_Text_Data(PLAYER_RANK, new_row, Get_Localized_Formatted_Number(results.rank))
	Results_List.Set_Row_Background(new_row, player.Get_Color(), "score_screen_color.tga")
	Results_List.Set_Row_Font(new_row, "Default_Font")

	if Dialog_For_Multiplayer then
		if player.Is_AI_Player() or Net.Get_Player_ID_By_Network_Address(results.common_addr) == -1 then
				Results_List.Set_Texture(VOICE_CHAT, new_row, NO_CHAT_ICON)
		else
			if Net.Voice_Is_Peer_Talking(results.common_addr) then
				Results_List.Set_Texture(VOICE_CHAT, new_row, CHAT_ON_ICON)
			else
				Results_List.Set_Texture(VOICE_CHAT, new_row, CHAT_OFF_ICON)
			end
		end
	end

	return last_team
end

function Hide_Dialog()
	-- Don't allow them to close this dialog if it is not the modal, because
	-- callback will be supressed.
	if this.Is_Modal_Scene() == false then return end

	-- Don't allow them to close this dialog if the Lobby button is disabled.
	if this.Button_Lobby.Is_Enabled() == false then return end

	if Save_Replay_Dialog and Save_Replay_Dialog.Get_Hidden() == false then
		Save_Replay_Dialog.Hide_Dialog()
		Save_Replay_Dialog = nil
		return
	end

	if CloseHuds then
		Results_List.Clear()
		this.Set_Hidden(true)
		this.End_Modal()
		Dialog_Active = false
	end
end

function Lobby_Clicked()
	Hide_Dialog()
end

function Save_Replay_Clicked()
	--replays in multiplayer only
	if Dialog_For_Multiplayer then 
		Save_Replay_Dialog = Spawn_Dialog("Save_Game_Dialog")
		Save_Replay_Dialog.Spawned_From_Battle_End()

		if SaveLoadManager == nil then
			Register_Save_Load_Commands()
		end

		Save_Replay_Dialog.Set_Mode(SAVE_LOAD_MODE_REPLAY)
		Save_Replay_Dialog.Display_Dialog()
	end
end

function Players_Clicked()
	if Net == nil then
		Register_Net_Commands()
	end
	Net.Show_Players_UI()
end

function Gamer_Card_Clicked()

	if (this.Button_Gamer_Card.Is_Enabled() == false) or
		(this.Button_Gamer_Card.Get_Hidden() == true) then
		return
	end
	
	local row = Results_List.Get_Selected_Row_Index()
	if row == -1 then return end -- Invalid row specified

	local results = Results_List.Get_User_Data(row)
	if results == nil then return end -- Not all rows have results on them
	
	-- Cannot view AI
	local player = results.player
	if player.Is_AI_Player() then return end

	local xuid = Net.Get_XUID_For_Player(player)
	Net.Show_Gamer_Card_UI(xuid)
	
end

function Player_Review_Clicked()

	if (this.Button_Player_Review.Is_Enabled() == false) then
		return
	end
	
	local row = Results_List.Get_Selected_Row_Index()
	if row == -1 then return end -- Invalid row specified

	local results = Results_List.Get_User_Data(row)
	if results == nil then return end -- Not all rows have results on them

	-- Cannot review yourself or AI
	local player = results.player
	if player == LocalPlayer or player.Is_AI_Player() then return end

	local xuid = Net.Get_XUID_For_Player(player)
	Net.Show_Player_Review_UI(xuid)
	
end

function Unhide()
	this.Set_Hidden(false)
	CloseHuds = true
	this.Focus_First()
end

--function Simple_Stats_Clicked()
--	Hide_Dialog()
--end

function Selected_Results_Changed(event, source)
	-- Hidden until the user highlights a valid row
	this.Button_Player_Review.Enable(false)
	this.Button_Gamer_Card.Enable(false)

	local row = Results_List.Get_Selected_Row_Index()
	if row == -1 then return end -- Invalid row specified

	local results = Results_List.Get_User_Data(row)
	if results == nil then return end -- Not all rows have results on them

	local player = results.player
	if Connected_To_Live and (not player.Is_AI_Player()) and (player ~= LocalPlayer) then
		this.Button_Player_Review.Enable(true)
	end
	if Connected_To_Live and (not player.Is_AI_Player()) then
		this.Button_Gamer_Card.Enable(true)
	end
end

function On_Update()
	if Dialog_Active and RowsByID ~= nil and Dialog_For_Multiplayer then

		-- If we're in multiplayer and we've switched back to single player then it's now
		-- ok to enable the Quit button.
		if this.Button_Lobby.Is_Enabled() ~= true and Is_Multiplayer_Skirmish() ~= true then
			this.Button_Lobby.Enable(true)
		end
		
		--Enable goto lobby and disable save replay button if we are comming out of a replay
		if Is_Replay() then
			if this.Button_Lobby.Is_Enabled() == false then
				this.Button_Lobby.Enable(true)
			end
			
			if this.Button_Save_Replay.Is_Enabled() == true then
				this.Button_Save_Replay.Enable(false)
				this.Button_Save_Replay.Set_Hidden(true)
				this.Button_A.Set_Hidden(true)
			end
		end

		for _, row_id in pairs(RowsByID) do
			local results = Results_List.Get_User_Data(row_id)
			local player = results.player

			if player.Is_AI_Player() or Net.Get_Player_ID_By_Network_Address(results.common_addr) == -1 then
				Results_List.Set_Texture(VOICE_CHAT, row_id, NO_CHAT_ICON)
			else
				if Net.Voice_Is_Peer_Talking(results.common_addr) then
					Results_List.Set_Texture(VOICE_CHAT, row_id, CHAT_ON_ICON)
				else
					Results_List.Set_Texture(VOICE_CHAT, row_id, CHAT_OFF_ICON)
				end
			end
		end
	end
end

function Set_Dialog_For_Multiplayer(value)

	Dialog_For_Multiplayer = value
	
	this.Button_Lobby.Enable(true)
	if Dialog_For_Multiplayer then
		this.Button_Lobby.Enable(false)
		Results_List.Enable_Selection_Highlight(true) -- need to see the selection with gamepad
		
		-- replays in multiplayer only
		this.Button_Save_Replay.Enable(true)
		this.Button_Save_Replay.Set_Hidden(false)
		this.Button_A.Set_Hidden(false)
	end
	
end

Interface = {}
Interface.Finalize_Init = Finalize_Init
Interface.Set_Dialog_For_Multiplayer = Set_Dialog_For_Multiplayer

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
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
	PGPlayerProfile_Init = nil
	Players_Clicked = nil
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
	Unhide = nil
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
