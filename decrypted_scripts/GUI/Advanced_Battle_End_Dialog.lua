-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Advanced_Battle_End_Dialog.lua#31 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Advanced_Battle_End_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Nader_Akoury $
--
--            $Change: 88091 $
--
--          $DateTime: 2007/11/19 14:50:39 $
--
--          $Revision: #31 $
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
	this.Register_Event_Handler("Button_Clicked", this.Button_Save_Replay, Save_Replay_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Play_Again, Play_Again_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Lobby, Lobby_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Gamer_Card, Gamer_Card_Clicked)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Results_List_Box, Selected_Results_Changed)

	-- Setup the tab ordering
	this.Button_Play_Again.Set_Tab_Order(Declare_Enum(0))
	this.Button_Lobby.Set_Tab_Order(Declare_Enum())
	this.Button_Save_Replay.Set_Tab_Order(Declare_Enum())

	local game_script = Get_Game_Mode_Script()
	if game_script and game_script.Get_Async_Data("BETA_BUILD") then
		this.Button_Save_Replay.Enable(false)
	end

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- Initialize the results list box
	Results_List = this.Results_List_Box
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
--	Results_List.Enable_Selection_Highlight(false)

	Results_List.Set_Column_Width(VOICE_CHAT, 0.05)
	Results_List.Set_Column_Width(PLAYER_NAME, 0.25)
	Results_List.Set_Column_Width(PLAYER_FACTION, 0.12)
	Results_List.Set_Column_Width(UNITS_DESTROYED, 0.12)
	Results_List.Set_Column_Width(BUILDINGS_DESTROYED, 0.12)
	Results_List.Set_Column_Width(HEROES_DESTROYED, 0.12)
	Results_List.Set_Column_Width(RESOURCES_COLLECTED, 0.12)
--	Results_List.Set_Column_Width(PLAYER_RANK, 0.1)
	Results_List.Refresh()

	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", Results_List, Play_Option_Select_SFX)

	Save_Replay_Dialog = nil

	PGColors_Init()
	PGNetwork_Init()

	Dialog_For_Multiplayer = Is_Multiplayer_Skirmish()
	Connected_To_Live = Net.Get_Signin_State() == "online"

	-- Hidden initially until the user highlights a valid row
	this.Button_Gamer_Card.Set_Hidden(true)

	this.Button_Lobby.Enable(true)
	if Dialog_For_Multiplayer then
		this.Button_Lobby.Enable(false)
	end
		
	-- Disable save replay button if this is a loaded save game
	if Is_Loaded_Save_Game() then
		if this.Button_Save_Replay.Is_Enabled() == true then
			this.Button_Save_Replay.Enable(false)
		end
	end
	
	Register_Game_Scoring_Commands()
	Freeze_Multiplayer()
	CloseHuds = true
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
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
		if results.player == Find_Player("local") then
			is_winner = true
			winner_faction = results.faction
			break
		end
	end

	for _, team in pairs(Teams) do
		for _, results in pairs(team) do
			if loser_faction == nil then loser_faction = results.faction end
			if is_winner == false and results.player == Find_Player("local") then
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
	Dialog_Active = true
	if is_multiplayer ~= nil then
		Dialog_For_Multiplayer = is_multiplayer
	end

	if Dialog_For_Multiplayer then
		if Net == nil then
			Register_Net_Commands()
		end
		this.Button_Play_Again.Set_Hidden(true)
	else
		this.Button_Play_Again.Set_Hidden(false)
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
	for idx, results in pairs(ResultsTable) do
		if results.team == Winning_Team then
			table.insert(Winning_Team_List, results)
		else
			if Teams[results.team] == nil then
				Teams[results.team] = {}
			end
			table.insert(Teams[results.team], results)
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

	local last_team = nil
	for _, results in pairs(Winning_Team_List) do
		last_team = Add_Player_Results(results, last_team)
	end

	for _, team in pairs(Teams) do
		for _, results in pairs(team) do
			last_team = Add_Player_Results(results, last_team)
		end
	end

	-- Make sure the rows get setup properly, so make sure to refresh
	Results_List.Refresh()

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
	Save_Replay_Dialog = Spawn_Dialog("Save_Game_Dialog")
	Save_Replay_Dialog.Spawned_From_Battle_End()

	if SaveLoadManager == nil then
		Register_Save_Load_Commands()
	end

	Save_Replay_Dialog.Set_Mode(SAVE_LOAD_MODE_REPLAY)
	Save_Replay_Dialog.Display_Dialog()
end

function Play_Again_Clicked()
	Hide_Dialog()
	Setup_Map_Restart()
end

function Players_Clicked()
	if Net == nil then
		Register_Net_Commands()
	end
	Net.Show_Players_UI()
end

function Unhide()
	this.Set_Hidden(false)
	CloseHuds = true
end

--function Simple_Stats_Clicked()
--	Hide_Dialog()
--end

function Gamer_Card_Clicked()
	local row = Results_List.Get_Selected_Row_Index()
	if row == -1 then return end -- Invalid row specified

	local results = Results_List.Get_User_Data(row)
	if results == nil then return end -- Not all rows have results on them

	local xuid = Net.Get_XUID_By_Network_Address(results.common_addr)
	Net.Show_Gamer_Card_UI(xuid)
end

function Selected_Results_Changed(event, source)
	-- Hidden until the user highlights a valid row
	this.Button_Gamer_Card.Set_Hidden(true)

	local row = Results_List.Get_Selected_Row_Index()
	if row == -1 then return end -- Invalid row specified

	local results = Results_List.Get_User_Data(row)
	if results == nil then return end -- Not all rows have results on them

	local player = results.player
	if Connected_To_Live and not player.Is_AI_Player() then
		this.Button_Gamer_Card.Set_Hidden(false)
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

Interface = {}
Interface.Finalize_Init = Finalize_Init
