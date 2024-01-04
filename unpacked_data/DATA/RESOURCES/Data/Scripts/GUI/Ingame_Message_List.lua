-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Ingame_Message_List.lua#18 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Ingame_Message_List.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Joe_Howes $
--
--            $Change: 85655 $
--
--          $DateTime: 2007/10/06 19:13:38 $
--
--          $Revision: #18 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	PGColors_Init()
	PGNetwork_Init()
	Net.Register_Event_Handler(On_Message_Recieved)

	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Closing_All_Displays", this, Hide_Dialog)
	this.Register_Event_Handler("Mouse_On", this.Message_List, Show_Scrollbar)
	this.Register_Event_Handler("Mouse_Off", this.Message_List, Show_Scrollbar)

	Stay_Open = false
	Forced_State = false
	Fade_End_Time = -1
	-- Maria 07.30.2007: Adding this hide here because in many cases the Fade_End_Time never gets set and therefore the dialog never
	-- gets hidden.  This is causing the 'ghost' dialog to hijack mouse input at its location.
	this.Message_List.Set_Hidden(true)

	MESSAGE_ITEM_LIFE_TIME = 15

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	SYSTEM_CHAT_COLOR = COLOR_WHITE
	
	WIDE_OPEN_BRACE = Create_Wide_String("[")
	WIDE_CLOSE_BRACE = Create_Wide_String("]")
	
	MESSAGE = Create_Wide_String("MESSAGE")
	this.Message_List.Set_Header_Style("NONE")
	this.Message_List.Add_Column(MESSAGE, JUSTIFY_LEFT, true)
	this.Message_List.Enable_Selection_Highlight(false)
	this.Message_List.Set_Line_Wrapping_Enabled(true)
	this.Message_List.Refresh()

	Tint = { 0, 0, 0, 0 } -- make it initially invisible
--	this.Message_List.Set_Maximum_Rows(10) -- limit the maximum number of visible messages to 10

	Seperator = Create_Wide_String("> ")
	Parsed_Message = Create_Wide_String("")
	Display_Dialog()
	Register_Game_Scoring_Commands()
end

function Display_Dialog(event, source)
	GUIDialogComponent.Set_Render_Priority(384)
end

function Hide_Dialog(event, source)
	GUIDialogComponent.Set_Active(false)
	Keep_Dialog_Open(false, true)
end

function Show_Scrollbar(event, source)
	if Fade_End_Time ~= -1 then
		if event == "Mouse_On" then
			Keep_Dialog_Open(true)
		elseif event == "Mouse_Off" then
			Keep_Dialog_Open(false)
		end
	end
end

function Create_Parsed_Message(name, message)
	Parsed_Message.assign(name)
	return Parsed_Message.append(Seperator).append(message)
end

function Add_Unparsed_Message(name, message, color)
	local display_string = Create_Parsed_Message(name, message)
	Add_Parsed_Message(display_string, color)
end

function Add_Parsed_Message(display_string, color)
	local scroll_to_bottom = false
	if this.Message_List.Get_Slider_Bar_Position() == 0 then
		scroll_to_bottom = true
	end

	local new_message_row = this.Message_List.Add_Row()
	local label = MP_COLORS_LABEL_LOOKUP[color] 
	local dao = MP_CHAT_COLOR_TRIPLES[label]
	this.Message_List.Set_Row_Color(new_message_row, dao[PG_R], dao[PG_G], dao[PG_B], dao[PG_A])
	this.Message_List.Set_Text_Data(MESSAGE, new_message_row, display_string)
	
	if scroll_to_bottom then
		this.Message_List.Scroll_To_Bottom()
	end

	Tint = { 1, 1, 1, 1 }
	Last_Time = Net.Get_Time()
	Fade_End_Time = Last_Time + MESSAGE_ITEM_LIFE_TIME -- Keep messages up for x seconds
	this.Message_List.Set_Hidden(false)
	this.Message_List.Set_Tint(1, 1, 1, 1) -- Make sure it is visible again
	Set_Interactive_State()
end

function Player_Left_Callback(player)
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable ~= nil and ctable.ClientTable ~= nil then
		ClientTable = ctable.ClientTable
	end

	local sender = Network_Get_Client_By_ID(player.Get_ID())
	if sender == nil then
		DebugMessage("LUA_NET: Couldn't find a client table entry for player: %s", tostring(player.Get_Name()))
		return
	end

	Add_Unparsed_Message(sender.name, Get_Game_Text("TEXT_PLAYER_LEFT_GAME"), sender.color)
end

function Game_Options_Changed_Callback(player)
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable ~= nil and ctable.ClientTable ~= nil then
		ClientTable = ctable.ClientTable
	end

	local sender = Network_Get_Client_By_ID(player.Get_ID())
	if sender == nil then
		DebugMessage("LUA_NET: Couldn't find a client table entry for player: %s", tostring(player.Get_Name()))
		return
	end

	Add_Unparsed_Message(sender.name, Get_Game_Text("TEXT_GAME_SPEED_CHANGED"), sender.color)	
end

function On_Message_Recieved(event)
	if event.type == NETWORK_EVENT_TASK_COMPLETE then
		if event.task == "TASK_MM_MESSAGE" and
			event.message_type == MESSAGE_TYPE_IN_GAME_CHAT and
			event.message.Message_Handler == This_Message_Handler then

			local ctable = GameScoringManager.Get_Player_Info_Table()
			if ctable ~= nil and ctable.ClientTable ~= nil then
				ClientTable = ctable.ClientTable
			end

			local sender = Network_Get_Client(event.common_addr)
			if sender == nil then
				DebugMessage("LUA_NET: Recieved a message from an unknown client at address: " .. tostring(event.common_addr))
				return
			end

			if Net.Is_Gamer_Muted(event.common_addr) == false then
				--[[ NADER: Obsolete - apparently chat does not need to go through the text filter
				if Net.Get_Signin_State() == "online" then
					Net.Chat_Verify_Text(Create_Parsed_Message(sender.name, event.message.Message), sender.color, sender.name)
				else
					Add_Unparsed_Message(sender.name, event.message.Message, sender.color)
				end
				]]

				Add_Unparsed_Message(sender.name, event.message.Message, sender.color)
			end

		elseif event.task == "TASK_VERIFY_CHAT_TEXT" then
		
			local message = event.message
			local color = event.color
		
			if (event.rejected) then
				message = Create_Wide_String(WIDE_OPEN_BRACE)
				message = message.append(Get_Game_Text("TEXT_CHAT_REJECTED"))
				message = message.append(WIDE_CLOSE_BRACE)
				message = Replace_Token(message, event.sender, 1)
				color = SYSTEM_CHAT_COLOR
			end
				
			Add_Parsed_Message(message, color)
			
		end
	end
end

function On_Update()
	local current_time = Net.Get_Time()

	if Stay_Open then
		-- Simple do not fade
	elseif Fade_End_Time ~= -1 and current_time <= Fade_End_Time then
		local delta = (Fade_End_Time - current_time) / MESSAGE_ITEM_LIFE_TIME -- make it take x seconds to disappear
		for i, tint in pairs(Tint) do
			if tint > 0 then
				Tint[i] = Update_Individual_Tint(tint, delta)
			end
		end
		Last_Time = current_time
		this.Message_List.Set_Tint(unpack(Tint))
		if Fade_End_Time == -1 then
			this.Message_List.Set_Hidden(true)
		end
	end
end

function Update_Individual_Tint(tint, delta)
	if delta < 0.35 then
		Fade_End_Time = -1 -- yes this will get set multiple times, but no biggie
		this.Message_List.Scroll_To_Bottom()
		return 0
	else
		return delta
	end
end

function Keep_Dialog_Open(open, forced)
	if not forced and (Forced_State or (Stay_Open == open)) then return end

	Stay_Open = open
	if open then
		Forced_State = forced
		Tint = { 1, 1, 1, 1 }
		this.Message_List.Set_Tint(1, 1, 1, 1) -- Make sure it is visible again
		this.Message_List.Set_Hidden(false)
	else
		Forced_State = false
		if forced then
			Fade_End_Time = -1
			this.Message_List.Set_Hidden(true)
			this.Message_List.Scroll_To_Bottom()
			Tint = { 0, 0, 0, 0 }
			this.Message_List.Set_Tint(0, 0, 0, 0) -- Force it to be invisible
		else
			Last_Time = Net.Get_Time()
			Fade_End_Time = Last_Time + MESSAGE_ITEM_LIFE_TIME -- Keep message list up for x seconds
			this.Message_List.Set_Hidden(false)
		end
	end

	Set_Interactive_State()
end

function Set_Interactive_State()
	if Stay_Open and Forced_State then
		this.Message_List.Set_Interactive(true)
	else
		this.Message_List.Set_Interactive(false)
	end
end
