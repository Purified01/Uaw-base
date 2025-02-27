if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Disconnect_Dialog.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Disconnect_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	PGNetwork_Init()
	Net.Register_Event_Handler(On_Message_Recieved)

	-- Copied from DisconnectDialog.cpp
	PLAYER_KICK_TIMEOUT = 15
	PLAYER_BUTTON_ENABLE_DELAY = 3
	PLAYER_LIST_DISPLAY_REFRESH_DELAY = .5
	ENABLE_QUIT_AFTER_INTERRUPTIONS = 1

	Names = Find_GUI_Components(this, "Text_Player_Name")
	Disconnect_Bars = Find_GUI_Components(this, "Disconnect_Bar")
	Kick_Buttons = Find_GUI_Components(this, "Button_Kick")

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	MESSAGE = Create_Wide_String("MESSAGE")
	this.Chat_Display_List.Set_Header_Style("NONE")
	this.Chat_Display_List.Add_Column(MESSAGE, JUSTIFY_LEFT, true)
	this.Chat_Display_List.Set_Maximum_Rows(1000)
	this.Chat_Display_List.Enable_Selection_Highlight(false)
	this.Chat_Display_List.Refresh()

	This_Message_Handler = "Disconnect_Dialog"
	Num_Connection_Interruptions = 0
	Seperator = Create_Wide_String("> ")
	Parsed_Message = Create_Wide_String("")

	-- Setup tab order and register event handlers in one fell swoop!
	this.Button_Quit_Game.Set_Tab_Order(Declare_Enum(0))
	for index, kick_button in pairs(Kick_Buttons) do
		kick_button.Set_Tab_Order(Declare_Enum())
		this.Register_Event_Handler("Button_Clicked", kick_button, Vote_Kick_Player)
	end

	this.Register_Event_Handler("Key_Press", this.Chat_Input_Box, On_Key_Press)
	this.Register_Event_Handler("Button_Clicked", this.Button_Quit_Game, Quit_Game)

	Register_Game_Scoring_Commands()
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
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end


function Display_Dialog()
	Kick_Vote = {}

	Num_Connection_Interruptions = Num_Connection_Interruptions + 1
	if Num_Connection_Interruptions >= ENABLE_QUIT_AFTER_INTERRUPTIONS then
		this.Button_Quit_Game.Enable(true)
	else
		this.Button_Quit_Game.Enable(false)
	end

	Last_Refresh_Time = 0
	Dialog_Start_Time = Net.Get_Time()
	IsActive = true

	Init_Components()
	Init_Clients()

	Update_Connection_Display()

	-- TODO: Add a line to the chat list saying waiting for player, with the slowest player's name
end

function Init_Components()
	-- All names are hidden by default
	for _, name in pairs(Names) do
		name.Set_Text("")
		name.Set_Hidden(true)
	end

	-- All progress bars are hidden by default
	for _, bar in pairs(Disconnect_Bars) do
		bar.Set_Filled(0)
		bar.Set_Hidden(true)
	end

	-- All kick buttons are hidden by default
	Disable_Kick_Buttons()
end

function Init_Clients()
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable == nil or ctable.ClientTable == nil then return end

	Client_Table = ctable.ClientTable

	Human_Clients = {}
	Client_Kick_Button_Map = {}
	Client_Disconnect_Bars = {}

	local current_index = 1
	Number_Of_Clients = 0
	local local_addr = Net.Get_Local_Addr()
	for idx, client in pairs(ctable.ClientTable) do
		-- Find the local client
		local player_wrapper = Find_Player(client.PlayerID)
		if (player_wrapper ~= nil) and (not player_wrapper.Is_AI_Player()) then
			if local_addr == client.common_addr then
				Local_Client = client
			else
				table.insert(Human_Clients, client)
				Names[current_index].Set_Hidden(false)
				Names[current_index].Set_Text(client.name)

				Client_Kick_Button_Map[Kick_Buttons[current_index]] = idx

				Disconnect_Bars[current_index].Set_Hidden(false)
				Client_Disconnect_Bars[client.common_addr] = Disconnect_Bars[current_index]

				current_index = current_index + 1
				Number_Of_Clients = Number_Of_Clients + 1
			end
		end
	end
end

function On_Message_Recieved(event)
	if event.type == NETWORK_EVENT_TASK_COMPLETE and event.task == "TASK_MM_MESSAGE" then
		if Client_Table == nil then
			-- Somehow we have recieved a message before initializing the client table...
			return
		end

		local sender = Client_Table[event.common_addr]
		if sender == nil then
			DebugMessage("LUA_NET: Recieved a message from an unknown client at address: " .. tostring(event.common_addr))
			return
		end

		if event.message_type == MESSAGE_TYPE_KICK_PLAYER then
			if Kick_Vote[event.message] then
				local add_vote = true
				for _, voter in pairs(Kick_Vote[event.message].Voters) do
					if voter == sender then
						add_vote = false
						break
					end
				end

				if add_vote then
					table.insert(Kick_Vote[event.message].Voters, sender)
					Kick_Vote[event.message].Vote_Count = Kick_Vote[event.message].Vote_Count + 1
				end
			else
				Kick_Vote[event.message] = { }
				Kick_Vote[event.message].Voters = { }
				Kick_Vote[event.message].Vote_Count = 1
				table.insert(Kick_Vote[event.message].Voters, sender)
			end

			if Kick_Vote[event.message].Vote_Count >= Number_Of_Clients then
				-- Actually kick this person...
				local kick_client = Client_Table[event.message]
				DisconnectHandler.Force_Quit(kick_client.PlayerID)
				GUIDialogComponent.Set_Active(false)
			end
		end

		if event.message_type == MESSAGE_TYPE_IN_GAME_CHAT then
			if event.message.Message_Handler == This_Message_Handler then
				Parsed_Message.assign(sender.name)
				display_string = Parsed_Message.append(Seperator).append(event.message.Message)

				local scroll_to_bottom = false
				if this.Chat_Display_List.Get_Slider_Bar_Position() == 0 then
					scroll_to_bottom = true
				end

				local new_message_row = this.Chat_Display_List.Add_Row()
				this.Chat_Display_List.Set_Text_Data(MESSAGE, new_message_row, display_string)
				this.Chat_Display_List.Set_Row_Color(new_message_row, tonumber(sender.color))

				if scroll_to_bottom then
					this.Chat_Display_List.Scroll_To_Bottom()
				end
			end
		end
	end
end

function On_Update()

	if IsActive then
		local current_time = Net.Get_Time()

		if current_time - Last_Refresh_Time > PLAYER_LIST_DISPLAY_REFRESH_DELAY then
			Update_Connection_Display()
			Last_Refresh_Time = current_time
		end

		if current_time - Dialog_Start_Time > PLAYER_BUTTON_ENABLE_DELAY then
			Enable_Kick_Buttons()
		end

		Check_For_Timed_Out()
	end
end

function Vote_Kick_Player(event_name, source)
	local player_index = Client_Kick_Button_Map[source]

	-- Vote to kick the player
	Net.MM_Broadcast(MESSAGE_TYPE_KICK_PLAYER, player_index)
end

function Disable_Kick_Buttons()
	for idx, kick_button in pairs(Kick_Buttons) do
		kick_button.Enable(false)
		kick_button.Set_Hidden(true)
	end
end

function Enable_Kick_Buttons()
	for idx, kick_button in pairs(Kick_Buttons) do
		if idx > Number_Of_Clients then break end
		kick_button.Enable(true)
		kick_button.Set_Hidden(false)
	end
end

function Update_Connection_Display()
	local current_time = Net.Get_Time()
	for _, client in pairs(Human_Clients) do
		local last_heard_from = DisconnectHandler.Get_Time_Since_Last_Packet(client.PlayerID)

		if last_heard_from ~= nil then
			local delta = current_time - (last_heard_from/1000) -- current_time is in seconds, last_heard_from is in milliseconds
			delta = Max(0, delta) -- I am getting a negative zero which Set_Filled does NOT like
			delta = Min(PLAYER_KICK_TIMEOUT, delta)
			Client_Disconnect_Bars[client.common_addr].Set_Filled(delta/PLAYER_KICK_TIMEOUT)
		end
	end
end

function Check_For_Timed_Out()
	for _, client in pairs(Human_Clients) do
		if DisconnectHandler.Check_If_Timed_Out(client.PlayerID) then
			DisconnectHandler.Force_Quit(client.PlayerID)
			GUIDialogComponent.Set_Active(false)
			break
		end
	end
end

function Quit_Game(event_name, source)
	DisconnectHandler.Force_Quit(Local_Client.PlayerID)
	GUIDialogComponent.Set_Active(false)
end

function On_Key_Press(event_name, source, key)
	if (string.byte(key, 1) == 13) then
		Send_Clicked(event_name, source)
	end
end

function Send_Clicked(event_name, source)
	local message = this.Chat_Input_Box.Get_Text()

	if not message.empty() then
		local packet = { }
		packet.Message = message
		packet.Message_Handler = This_Message_Handler

		this.Chat_Input_Box.Set_Text("")
		Net.MM_Broadcast(MESSAGE_TYPE_IN_GAME_CHAT, packet)
	end
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
