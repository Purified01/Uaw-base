-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Ingame_Chat_Dialog.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Ingame_Chat_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Nader_Akoury $
--
--            $Change: 85341 $
--
--          $DateTime: 2007/10/02 18:24:21 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	Dialog_Box_Common_Init()

	this.Register_Event_Handler("Key_Press", this.Chat_Edit_Box, On_Key_Press)
	this.Register_Event_Handler("Button_Clicked", this.Button_Send, Send_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Hide_Dialog)
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Check_Box, Toggle_Teammates_Only)
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Multiplayer_Match_Completed", nil, Hide_Dialog)
	this.Register_Event_Handler("Key_Focus_Lost", this.Chat_Edit_Box, On_Chat_Input_Focus_Lost)

	-- Tab order
	this.Chat_Edit_Box.Set_Tab_Order(Declare_Enum(0))
	this.Button_Cancel.Set_Tab_Order(Declare_Enum())
	this.Check_Box.Set_Tab_Order(Declare_Enum())
	this.Button_Send.Set_Tab_Order(Declare_Enum())

	this.Chat_Edit_Box.Set_Text_Limit(160) -- Magic number from the C++ source code

	Register_Game_Scoring_Commands()

	local Message_List = GUIDialogComponent.Find_Dialog("Ingame_Message_List")
	if Message_List then
		Message_List_Script = Message_List.Get_Script()
	end

	Setup_Teams()
	PGNetwork_Init()

	TeamMatesOnly = false
	this.Check_Box.Set_Checked(false)
end

function Toggle_Teammates_Only(event_name, source)
	TeamMatesOnly = not TeamMatesOnly
	this.Check_Box.Set_Checked(TeamMatesOnly)
end

function Set_Teammates_Only(force_teammates_only)
	ForceTeamMatesOnly = false
	if force_teammates_only == true then
		ForceTeamMatesOnly = true
		this.Check_Box.Set_Hidden(true)
	else
		this.Check_Box.Set_Hidden(false)
	end
end

function Setup_Teams()
	local ctable = GameScoringManager.Get_Player_Info_Table()
	Teams = {}

	if ctable == nil or ctable.ClientTable == nil then return end

	LocalClient = {}
	LocalClient.common_addr = Net.Get_Local_Addr()

	-- Split the client table into seperate teams.
	for idx, client in pairs(ctable.ClientTable) do
		-- Store off the local client
		if client.common_addr == LocalClient.common_addr then
			LocalClient = client
		end

		if Teams[client.team] == nil then
			Teams[client.team] = {}
		end
		table.insert(Teams[client.team], client)
	end
end

function Display_Dialog(teammates_only)
	CloseHuds = true
	this.Focus_First()
	Set_Teammates_Only(teammates_only)
	if Message_List_Script then
		Message_List_Script.Call_Function("Keep_Dialog_Open", true, true)
	end
end

function Hide_Dialog()
	CloseHuds = false
	GUIDialogComponent.Set_Active(false)
	if Message_List_Script then
		Message_List_Script.Call_Function("Keep_Dialog_Open", false, true)
	end
end

function On_Key_Press(event_name, source, key)
	if (string.byte(key, 1) == 13) then
		Send_Clicked(event_name, source)
	end
end

function Send_Clicked(event_name, source)
	local message = this.Chat_Edit_Box.Get_Text()

	if not message.empty() then
		local packet = { }
		packet.Message = message
		packet.Message_Handler = This_Message_Handler

		this.Chat_Edit_Box.Set_Text("")

		if (Find_Player("local").Is_Observer()) then
			Send_Msg_To_Observers(packet)
		elseif ForceTeamMatesOnly or TeamMatesOnly then
			Send_Msg_To_Team(packet, LocalClient.team)
		else
			Net.MM_Broadcast(MESSAGE_TYPE_IN_GAME_CHAT, packet)
		end
	end

	-- Per Chris's request, hide after every message is sent
	Hide_Dialog()
end

function Send_Msg_To_Team(msg, team_id)
	local team = Teams[team_id]
	for _, mate in pairs(team) do
		Net.MM_Send_To(mate.common_addr, MESSAGE_TYPE_IN_GAME_CHAT, msg)
	end
end

function Send_Msg_To_Observers(msg)
	for _, team in pairs(Teams) do
		for _, mate in pairs(team) do
			local pid = Net.Get_Player_ID_By_Network_Address(mate.common_addr)
			local player = Find_Player(pid)
			if player and player.Is_Observer() then
				Net.MM_Send_To(mate.common_addr, MESSAGE_TYPE_IN_GAME_CHAT, msg)
			end
		end
	end
end

function On_Chat_Input_Focus_Lost(event, source)
	-- If the chat edit box is visible, it should always have keyboard input focus
	if CloseHuds == true then
		this.Chat_Edit_Box.Set_Key_Focus()
	end
end
