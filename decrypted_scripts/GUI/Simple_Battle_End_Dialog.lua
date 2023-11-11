-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Simple_Battle_End_Dialog.lua#20 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Simple_Battle_End_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Nader_Akoury $
--
--            $Change: 82391 $
--
--          $DateTime: 2007/08/30 15:29:54 $
--
--          $Revision: #20 $
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
	this.Register_Event_Handler("Button_Clicked", this.Button_Players, Players_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Advanced_Stats, Advanced_Stats_Clicked)

	-- Setup the tab ordering
	this.Button_Play_Again.Set_Tab_Order(Declare_Enum(0))
	this.Button_Lobby.Set_Tab_Order(Declare_Enum())
	this.Button_Players.Set_Tab_Order(Declare_Enum())
	this.Button_Advanced_Stats.Set_Tab_Order(Declare_Enum())
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

	-- Initialize the results list boxes
	VOICE_CHAT = Create_Wide_String("VOICE_CHAT")
	PLAYER_NAME = Create_Wide_String("PLAYER_NAME")
	PLAYER_FACTION = Create_Wide_String("PLAYER_FACTION")
	CHAT_ON_ICON = Create_Wide_String("i_dialogue_radio_on.tga")
	CHAT_OFF_ICON = Create_Wide_String("i_dialogue_radio_off.tga")

	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Winner_Container.List_Box_Results_Winning_Team, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team1, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team2, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team3, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team4, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team5, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team6, Play_Option_Select_SFX)	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Losers_Container.List_Box_Results_Losing_Team7, Play_Option_Select_SFX)	
	
	Team_Results_List_Boxes = Find_GUI_Components(this.Losers_Container, "List_Box_Results_Losing_Team")
	table.insert(Team_Results_List_Boxes, 1,  this.Winner_Container.List_Box_Results_Winning_Team )
	Winners_List = this.Winner_Container.List_Box_Results_Winning_Team

	for _, box in pairs(Team_Results_List_Boxes) do
		box.Add_Column(VOICE_CHAT, JUSTIFY_LEFT)
		box.Add_Column(PLAYER_NAME, JUSTIFY_LEFT)
		box.Add_Column(PLAYER_FACTION, JUSTIFY_LEFT)
		box.Set_Header_Style("NONE")
		box.Refresh()
		box.Set_Hidden(true)
		box.Enable_Selection_Highlight(false)
	end

	Save_Replay_Dialog = nil

	PGColors_Init()
	PGNetwork_Init()

	Dialog_For_Multiplayer = Is_Multiplayer_Skirmish()

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
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
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


-- Less than comparator to sort based on winner
function Results_Table_Winner_Compare(player1_table, player2_table)
	if player1_table.team ~= Winning_Team then
		return false
	elseif player2_table.team ~= Winning_Team then
		return true
	else
		return player1_table.team < player2_table.team
	end
end

-- We should be getting this from XML, but it ends up in FactionClass, which isn't wrapped (yet)
function Get_Faction_Icon_Name(faction)
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

function Finalize_Init()
	Dialog_Active = true

	local scoring_script = Get_Game_Scoring_Script()
	if scoring_script == nil then return end

	-- Grab the client table
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable == nil or ctable.ClientTable == nil then return end

	Winning_Team = nil
	local user_data = this.Get_User_Data()
	local winner = user_data.Winner
	for idx, client in pairs(ctable.ClientTable) do
		if client.PlayerID == winner.Get_ID() then
			Winning_Team = client.team
			break
		end
	end

	-- The game always starts at frame 0, so we just need to get the current frame in order to calculate time
	local session_length = Get_Localized_Formatted_Number.Get_Time(user_data.GameEndTime)
	local session_length_string = Get_Game_Text("TEXT_SESSION_LENGTH")
	session_length_string.append(Create_Wide_String(" ")).append(session_length)
	this.Text_Session_Length.Set_Text(session_length_string)

	-- Organize results by winning team
	ResultsTable = scoring_script.Get_Variable("ResultsTable")
	table.sort(ResultsTable, Results_Table_Winner_Compare)

	if Dialog_For_Multiplayer then
		if Net == nil then
			Register_Net_Commands()
		end
		this.Button_Play_Again.Set_Hidden(true)
		this.Button_Players.Set_Hidden(false)
	else
		this.Button_Play_Again.Set_Hidden(false)
		this.Button_Players.Set_Hidden(true)
	end

	local num_teams = 0
	local last_team = nil
	local results_list = Team_Results_List_Boxes[1]

	RowsByID = {}

	for _, results in pairs(ResultsTable) do
		local player = results.player

		if results.team ~= last_team then
			last_team = results.team
			num_teams = num_teams + 1
			results_list = Team_Results_List_Boxes[num_teams]
			results_list.Set_Hidden(false)

			local team_wstring = Get_Game_Text("TEXT_HEADER_TEAM")
			team_wstring.append(Create_Wide_String(" ")).append(Get_Localized_Formatted_Number(results.team))

			local new_row = results_list.Add_Row()
			results_list.Set_Text_Data(PLAYER_NAME, new_row, team_wstring)
			if results.team == Winning_Team then
				results_list.Set_Text_Data(PLAYER_FACTION, new_row, Get_Game_Text("TEXT_VICTORY"))
			else
				results_list.Set_Text_Data(PLAYER_FACTION, new_row, Get_Game_Text("TEXT_DEFEAT"))
			end
		end

		local new_row = results_list.Add_Row()
		table.insert(RowsByID, { list_box = results_list, id = new_row })
		results_list.Set_User_Data(new_row, results.common_addr)

		results_list.Set_Text_Data(PLAYER_NAME, new_row, player.Get_Name())
		results_list.Set_Texture(PLAYER_FACTION, new_row, Get_Faction_Icon_Name(results.faction))
		results_list.Set_Row_Background(new_row, player.Get_Color())
		results_list.Set_Row_Font(new_row, "Default_Font")

		if Dialog_For_Multiplayer then
			if Net.Voice_Is_Peer_Talking(results.common_addr) then
				results_list.Set_Texture(VOICE_CHAT, new_row, CHAT_ON_ICON)
			else
				results_list.Set_Texture(VOICE_CHAT, new_row, CHAT_OFF_ICON)
			end
		end
	end

	-- Arrange the team results list boxes appropriately
	local container_x, container_y, container_width, container_height = this.Winner_Container.Get_World_Bounds()
	local list_box_height = 1.01 * Winners_List.Get_Minimum_World_Height_For_Content() -- Scale up the minimum height a bit
	local resized_x = container_x
	local resized_y = container_y + ((container_height - list_box_height)/2)
	local resized_width = container_width
	local resized_height = list_box_height

	Winners_List.Set_World_Bounds(resized_x, resized_y, resized_width, resized_height)

	container_x, container_y, container_width, container_height = this.Losers_Container.Get_World_Bounds()
	local vertical_spacing = container_height/(num_teams-1)
	local current_top = container_y
	for i = 2, num_teams do
		box = Team_Results_List_Boxes[i]

		list_box_height = 1.01 * box.Get_Minimum_World_Height_For_Content() -- Scale up the minimum height a bit
		resized_x = container_x
		resized_y = current_top + ((vertical_spacing - list_box_height)/2)
		resized_width = container_width
		resized_height = list_box_height

		current_top = current_top + vertical_spacing
		box.Set_World_Bounds(resized_x, resized_y, resized_width, resized_height)
	end
	
	return true
	
end


function Hide_Dialog()
	if Save_Replay_Dialog and Save_Replay_Dialog.Get_Hidden() == false then
		Save_Replay_Dialog.Hide_Dialog()
		Save_Replay_Dialog = nil
		return
	end
	
	if CloseHuds then
		for _, box in pairs(Team_Results_List_Boxes) do
			box.Clear()
			box.Set_Hidden(true)
		end

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

function Advanced_Stats_Clicked()
	this.Set_Hidden(true)
	CloseHuds = false

	local scene_name = "Advanced_Battle_End_Dialog"
	local advanced_ui = Get_Game_Mode_GUI_Scene()[scene_name]
	if not TestValid(advanced_ui) then
		advanced_ui = Get_Game_Mode_GUI_Scene().Create_Embedded_Scene(scene_name, scene_name)
	end

	advanced_ui.Set_Bounds(0.0, 0.0, 1.0, 1.0)
	advanced_ui.Set_Hidden(false)
	advanced_ui.Bring_To_Front()
	advanced_ui.Set_User_Data(this.Get_User_Data())
	advanced_ui.Finalize_Init(Dialog_For_Multiplayer)
	advanced_ui.Start_Modal(Unhide)
end

function Unhide()
	this.Set_Hidden(false)
	CloseHuds = true
end

function On_Update()
	if Dialog_Active and RowsByID ~= nil and Dialog_For_Multiplayer then
		for _, row_data in pairs(RowsByID) do
			local row_id = row_data.id
			local results_list = row_data.list_box
			local common_addr = results_list.Get_User_Data(row_id)

			if Net.Voice_Is_Peer_Talking(common_addr) then
				results_list.Set_Texture(VOICE_CHAT, row_id, CHAT_ON_ICON)
			else
				results_list.Set_Texture(VOICE_CHAT, row_id, CHAT_OFF_ICON)
			end
		end
	end
end

Interface = {}
Interface.Finalize_Init = Finalize_Init
