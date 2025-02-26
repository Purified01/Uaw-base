if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Leaderboard_Dialog.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Leaderboard_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Nader_Akoury $
--
--            $Change: 95204 $
--
--          $DateTime: 2008/03/13 17:48:05 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGNetwork")
require("PGColors")
require("PGPlayerProfile")
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
require("PGFactions")
require("Lobby_Network_Logic")


-------------------------------------------------------------------------------
-- Initializes the GUI elements on initial creation
-------------------------------------------------------------------------------
function GUI_Init()

	-- Constants
	Init_Filters()
	PGColors_Init()
	ENTRIES_PER_PAGE = 17
	FAST_FORWARD = 5
	Network_Error_String = Create_Wide_String("TEXT_BD_MATCHMAKING_TASK_FAILED")
	
	-- Variables (need to be initialized AFTER the constants)
	Init_Variables()
	Register_Net_Commands()
	
	-- Event handlers
	Net.Register_Event_Handler(On_Message_Recieved)

	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Closing_All_Displays", nil, Close_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Button_Back, Close_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Button_Gamer_Card, Gamer_Card_Clicked)
--	this.Register_Event_Handler("Button_Clicked", this.Button_Download_Replay, Download_Replay_Clicked)

	this.Register_Event_Handler("Button_Clicked", this.Button_First, Button_First_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Last, Button_Last_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Next_Few, Button_Next_Few_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Previous_Few, Button_Previous_Few_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Next, Button_Next_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Previous, Button_Previous_Clicked)

--	this.Register_Event_Handler("Button_Clicked", this.Button_Filter, Toggle_Next_Filter)

	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Filter_By_Friends, Toggle_Friends_Filter)

	this.Leader_List.Set_Maximum_Rows(ENTRIES_PER_PAGE + 1) -- Plus one for the player

	RANK = Get_Game_Text("TEXT_HEADER_PLAYER_RANK")
	NAME = Get_Game_Text("TEXT_HEADER_GAMERTAG")
	WINS = Get_Game_Text("TEXT_HEADER_WINS")
	LOSSES = Get_Game_Text("TEXT_HEADER_LOSSES")
	FACTION = Get_Game_Text("TEXT_HEADER_FACTION")

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- When data is not available use this text tag
	TEXT_NOT_AVAILABLE = Get_Game_Text("TEXT_NOT_AVAILABLE")

	-- Specify the column for the list box
	this.Leader_List.Set_Header_Style("NONE")
	this.Leader_List.Add_Column(RANK, JUSTIFY_CENTER) -- The column for the rank
	this.Leader_List.Add_Column(NAME, JUSTIFY_CENTER) -- The column for the player name
	this.Leader_List.Add_Column(FACTION, JUSTIFY_CENTER) -- The column for the faction
	this.Leader_List.Add_Column(WINS, JUSTIFY_CENTER) -- The column for the wins
	this.Leader_List.Add_Column(LOSSES, JUSTIFY_CENTER) -- The column for the losses

	this.Leader_List.Set_Column_Width(NAME, 0.25)
	this.Leader_List.Refresh()

	-- Setup the tab ordering
	this.Button_Back.Set_Tab_Order(Declare_Enum(0))
	this.Button_Gamer_Card.Set_Tab_Order(Declare_Enum())
--	this.Button_Download_Replay.Set_Tab_Order(Declare_Enum())
--	this.Button_Filter.Set_Tab_Order(Declare_Enum())

	this.Button_First.Set_Tab_Order(Declare_Enum())
	this.Button_Previous_Few.Set_Tab_Order(Declare_Enum())
	this.Button_Previous.Set_Tab_Order(Declare_Enum())
	this.Button_Next.Set_Tab_Order(Declare_Enum())
	this.Button_Next_Few.Set_Tab_Order(Declare_Enum())
	this.Button_Last.Set_Tab_Order(Declare_Enum())

	this.Leader_List.Set_Tab_Order(Declare_Enum())
	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Leader_List, Play_Option_Select_SFX)	

	this.Button_Filter.Set_Hidden(true)
	this.Button_Download_Replay.Set_Hidden(true)

	Display_Dialog()
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



function Init_Filters()
	-- Must be kept in sync with C++ enums
	STAT_FILTER_OVERALL = Declare_Enum(0)
	STAT_FILTER_NOVUS = Declare_Enum()
	STAT_FILTER_HIERARCHY = Declare_Enum()
	STAT_FILTER_MASARI = Declare_Enum()

	Filters = { }
	table.insert(Filters, STAT_FILTER_OVERALL)
	table.insert(Filters, STAT_FILTER_NOVUS)
	table.insert(Filters, STAT_FILTER_HIERARCHY)
	table.insert(Filters, STAT_FILTER_MASARI)
end

function Init_Page_Variables()
	Last_Page = 0
	Current_Page = nil -- so Previous_Page will be set to nil in the Set_Current_Page function
	Set_Current_Page(0)
end

function Init_Filter_Variables()
	Previous_Filter = nil
	Current_Filter = Filters[1]
	Next_Filter_Index = 2
	Friends_Filter_Enabled = false
	this.Checkbox_Filter_By_Friends.Set_Checked(Friends_Filter_Enabled)
end

function Init_Variables()
	Querying_Owner_Stats = false
	Init_Page_Variables()
	Init_Filter_Variables()
end

-- --------------------------------------------------------------------------------------------------------------------
-- V I E W   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
function Display_Dialog()
	this.Movie_1.Play()
	if Net.Get_Signin_State() ~= "online" then
		Net.Show_Signin_UI()
		Close_Dialog()
		return
	end

	Init_Variables()
	Query_Owner_Stats()

	this.Focus_First()
end

function Close_Dialog(event, source, key)
	this.Movie_1.Stop()
	this.Set_Hidden(true)
	this.Leader_List.Clear()
	this.Leader_List.Reset_Row_Selection()
	
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Leaderboard_Dialog"})
	
	this.End_Modal()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
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

function Query_Stats()
	if Current_Page == Previous_Page and Current_Filter == Previous_Filter then return end

	local stats_data = { }
	stats_data.filter = Current_Filter
	stats_data.num_entries = ENTRIES_PER_PAGE
	stats_data.starting_rank = (Current_Page * ENTRIES_PER_PAGE) + 1
	stats_data.friends_only = Friends_Filter_Enabled

	Net.MM_Query_Stats(stats_data)
	this.Button_Filter.Enable(false)
	this.Querying_Pop_Up.Set_Hidden(false)
end

function Query_Owner_Stats()
	local stats_data = { }
	stats_data.filter = Current_Filter

	Querying_Owner_Stats = true
	Net.MM_Query_Stats(stats_data, true)
	this.Querying_Pop_Up.Set_Hidden(false)

	this.Button_Filter.Enable(false)
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function Network_On_Live_Connection_Changed(event)

	DebugMessage("LUA_LEADERBOARDS: Live connection changed.")
	
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
		DebugMessage("LUA_LEADERBOARDS: Live connection has become unrecoverable.  Quitting to main menu.")
		Close_Dialog()
	end
					
end

function On_Message_Recieved(event)
	if event.type == NETWORK_EVENT_TASK_COMPLETE then
		if event.task == "TASK_MM_QUERY_STATS" then
			if Querying_Owner_Stats then
				Owner_Stats = event.stats[1]
				Querying_Owner_Stats = false
				this.Button_Filter.Enable(true)
	
				Query_Stats() -- now query the rest of the stats
			else
				if event.stats then
					Set_Last_Page(event.stats.total_rows)
				end
	
				Display_Stats(event.stats)
				this.Querying_Pop_Up.Set_Hidden(true)
				this.Button_Filter.Enable(true)
			end
		elseif event.task == "TASK_LIVE_CONNECTION_CHANGED" then
			Network_On_Live_Connection_Changed(event)
		end
	elseif event.type == NETWORK_EVENT_ERROR and
		event.message.compare(Network_Error_String) then
		this.Querying_Pop_Up.Set_Hidden(true)
		this.Button_Filter.Enable(true)
	end
end

function Rank_Compare(player1_table, player2_table)
	return player1_table.rank < player2_table.rank
end

function Display_Stats(stats)
	-- Maria 10.17.2007
	-- If the player keep clicking on the right arrow the list will try to get 
	-- populated even though there's no more data.  I am placing this safe
	-- guard here but ideally we would like to get the arrow disabled so that
	-- the user knows there's no more content.
	if not stats then 
		return
	end
	
	this.Leader_List.Clear()

	-- Sort the table based on ranks
	table.sort(stats, Rank_Compare)

	local new_row = this.Leader_List.Add_Row()
	this.Leader_List.Set_Row_Font(new_row, "Arial_White_14_Bold")
	this.Leader_List.Set_Row_Background(new_row, 18, "i_dialogue_button_large_middle_mouse_over.tga")
	if Owner_Stats == nil then
		local stats = {}
		stats.gamer_tag = Net.Get_User_Name()
		Add_User_Stats_To_Display_List(new_row, stats)
	else
		Add_User_Stats_To_Display_List(new_row, Owner_Stats)
	end

	-- If no stats are returned do not update the display
	-- This can happen when querying friend stats beyond
	-- a certain page
	if stats == nil then return end

	for index, stat_row in ipairs(stats) do
		Add_User_Stats_To_Display_List(this.Leader_List.Add_Row(), stat_row)
	end
end

function Add_User_Stats_To_Display_List(row, stat)
	if stat ~= nil then
		this.Leader_List.Set_Text_Data(NAME, row, stat.gamer_tag)

		if stat.rank then
			this.Leader_List.Set_Text_Data(RANK, row, Get_Localized_Formatted_Number(stat.rank))
		else
			this.Leader_List.Set_Text_Data(RANK, row, TEXT_NOT_AVAILABLE)
		end

		if stat.faction then
			this.Leader_List.Set_Texture(FACTION, row, Get_Faction_Icon_Name(stat.faction))
		else
			this.Leader_List.Set_Text_Data(FACTION, row, TEXT_NOT_AVAILABLE)
		end

		if stat.wins then
			this.Leader_List.Set_Text_Data(WINS, row, Get_Localized_Formatted_Number(stat.wins))
		else
			this.Leader_List.Set_Text_Data(WINS, row, TEXT_NOT_AVAILABLE)
		end

		if stat.losses then
			this.Leader_List.Set_Text_Data(LOSSES, row, Get_Localized_Formatted_Number(stat.losses))
		else
			this.Leader_List.Set_Text_Data(LOSSES, row, TEXT_NOT_AVAILABLE)
		end

		this.Leader_List.Set_User_Data(row, stat.xuid)
	end
end

function Set_Last_Page(total_rows)
		if total_rows == 0 then
			Last_Page = 0
		elseif Math.mod(total_rows, ENTRIES_PER_PAGE) == 0 then
			Last_Page = (total_rows/ENTRIES_PER_PAGE) - 1
		else
			Last_Page = Dirty_Floor(total_rows/ENTRIES_PER_PAGE)
		end
end

function Set_Current_Page(page_number)
	Previous_Page = Current_Page
	Current_Page = page_number

	-- Display Page + 1 because the page number uses zero based indexing
	this.Text_Page_Number.Set_Text(Get_Localized_Formatted_Number(Current_Page+1))
end

function Button_First_Clicked()
	Set_Current_Page(0)
	Query_Stats()
end

function Button_Last_Clicked()
	Set_Current_Page(Last_Page)
	Query_Stats()
end

function Button_Next_Few_Clicked()
	Set_Current_Page(Min(Current_Page + FAST_FORWARD, Last_Page))
	Query_Stats()
end

function Button_Previous_Few_Clicked()
	Set_Current_Page(Max(Current_Page - FAST_FORWARD, 0))
	Query_Stats()
end

function Button_Next_Clicked()
	Set_Current_Page(Min(Current_Page + 1, Last_Page))
	Query_Stats()
end

function Button_Previous_Clicked()
	Set_Current_Page(Max(Current_Page - 1, 0))
	Query_Stats()
end

function Toggle_Next_Filter()
	Init_Page_Variables()

	Previous_Filter = Current_Filter
	Current_Filter = Filters[Next_Filter_Index]
	Next_Filter_Index = Simple_Mod(Next_Filter_Index, table.getn(Filters)) + 1

	Query_Owner_Stats()
end

function Gamer_Card_Clicked()
	local highlighted_row = this.Leader_List.Get_Selected_Row_Index()
	if highlighted_row == -1 then
		Net.Show_Gamer_Card_UI()
	else
		local xuid = this.Leader_List.Get_User_Data(highlighted_row)
		Net.Show_Gamer_Card_UI(xuid)
	end
end

function Download_Replay_Clicked()
end

function Toggle_Friends_Filter()
	Init_Page_Variables()
	Friends_Filter_Enabled = not Friends_Filter_Enabled
	this.Checkbox_Filter_By_Friends.Set_Checked(Friends_Filter_Enabled)
	Query_Stats()
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
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Download_Replay_Clicked = nil
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
	Is_Player_Of_Faction = nil
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
	PGOfflineAchievementDefs_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Client_Table = nil
	Set_Local_User_Applied_Medals = nil
	Show_Object_Attached_UI = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Toggle_Next_Filter = nil
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	Kill_Unused_Global_Functions = nil
end
