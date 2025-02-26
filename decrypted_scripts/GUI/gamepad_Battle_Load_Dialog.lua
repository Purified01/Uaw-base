if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[205] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[34] = true
LuaGlobalCommandLinks[116] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Battle_Load_Dialog.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Battle_Load_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Joe_Howes $
--
--            $Change: 94892 $
--
--          $DateTime: 2008/03/07 16:13:32 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGFactions")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	PGNetwork_Init()
	Net.Register_Event_Handler(On_Message_Recieved)

	Percent_Complete = 0
	Quit_Button_Enabled = false
	Battle_Load_Force_Quit = false
	LocalClientFinishedLoadingTime = -1
	Previous_Percentage = Percent_Complete

	PlatformTextures = { }
	PlatformTextures[PLATFORM_PC] = "MP_Windows_Icon.tga"
	PlatformTextures[PLATFORM_360] = "MP_XBox_Icon.tga"
	
	Platform_Icons = Find_GUI_Components(this.AALogic, "Icon_Platform")
	Names = Find_GUI_Components(this.AALogic, "Text_Name")
	Progress_Bars = Find_GUI_Components(this.AALogic, "Progress_Bar")

	PGFactions_Init()
	Init_Faction_Models()

	Default_Background = this.AALogic.Background.Get_Texture_Name()

	this.Register_Event_Handler("Button_Clicked", this.StartMissionButton, On_Start_Mission_Button_Clicked)
	this.Register_Event_Handler("On_Update_Text", nil, On_Update_Text)
	this.AALogic.StartMissionButton.Set_Tab_Order(0)

	Hide_General_Components()
	Hide_Multiplayer_Components()

	-- Wait 60 seconds before allowing them to quit.
	TimeToShowQuitButton = 60
	
	Register_Game_Scoring_Commands()
end

function Init_Faction_Models()

	FactionModels = { }
	FactionModels[PG_FACTION_NOVUS] = { "L_Nh_founder.alo", "L_Nh_viktor.alo", "L_Nv_vertigo.alo" }
	FactionModels[PG_FACTION_ALIEN] = { "L_Ah_kamal_rex.alo", "L_Ah_nufai.alo", "L_Ah_orlok.alo" }
	FactionModels[PG_FACTION_MASARI] = { "L_Zh_altea.alo", "L_Zh_charos.alo", "L_Zh_zessus.alo" }
	FactionModels[PG_FACTION_MILITARY] = { "L_Mh_moore.alo" }

	FactionBackgrounds = { }
	FactionBackgrounds[PG_FACTION_NOVUS] = "splash_novus.tga"
	FactionBackgrounds[PG_FACTION_ALIEN] = "splash_alien.tga"
	FactionBackgrounds[PG_FACTION_MASARI] = "splash_masari.tga"
	FactionBackgrounds[PG_FACTION_MILITARY] = "splash_military.tga"

	FactionGUIModels = { }
	FactionGUIModels[PG_FACTION_NOVUS] = this.AALogic.Novus_Model
	FactionGUIModels[PG_FACTION_ALIEN] = this.AALogic.Alien_Model
	FactionGUIModels[PG_FACTION_MASARI] = this.AALogic.Masari_Model
	FactionGUIModels[PG_FACTION_MILITARY] = this.AALogic.Military_Model

	FactionAssetBanks = {}
	FactionAssetBanks[PG_FACTION_NOVUS] = "Bank_Battle_Load_Novus"
	FactionAssetBanks[PG_FACTION_ALIEN] = "Bank_Battle_Load_Alien"
	FactionAssetBanks[PG_FACTION_MASARI] = "Bank_Battle_Load_Masari"
	FactionAssetBanks[PG_FACTION_MILITARY] = "Bank_Battle_Load_Military"

end

function Hide_Multiplayer_Components()

	-- All platform icons are hidden by default
	for _, icon in pairs(Platform_Icons) do
		icon.Set_Hidden(true)
	end

	-- All names are hidden by default
	for _, name in pairs(Names) do
		name.Set_Text("")
		name.Set_Hidden(true)
	end

	-- All progress bars are hidden by default
	this.AALogic.Progress_Bar_Solo.Set_Hidden(true)
	this.AALogic.ProgressDisplay.Set_Hidden(true)
	for _, bar in pairs(Progress_Bars) do
		bar.Set_Filled(0)
		bar.Set_Hidden(true)
	end

end

function Hide_General_Components()

	-- All models are hidden by default
	for _, fgm in pairs(FactionGUIModels) do
		fgm.Set_Hidden(true)
	end

	-- The texture is hidden by default
	this.AALogic.Background.Set_Hidden(true)

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

function Display_Dialog(for_faction_display_name)
	ModelOverridden = false
	All_Clients_Loaded = false
	Broadcast_Complete_Sent = false
	ClientsLoaded = {}

	Quit_Button_Enabled = false
	Battle_Load_Force_Quit = false
	LocalClientFinishedLoadingTime = -1

	Percent_Complete = 0
	Previous_Percentage = Percent_Complete

	Loading_Components_Initialized = false

	Last_Faction_ID = Faction_ID
	Faction_ID = nil

	if for_faction_display_name then
		Faction_ID = Get_Faction_Numeric_Form_From_Localized(for_faction_display_name)
	end

	Init_Components()
	Init_Clients()
	--Refresh_Faction_Asset_Bank()
	-- JAC - These two calls are now made once the asset bank is finished loading
	Refresh_Faction_Model()
	Refresh_Faction_Background()
end


function Refresh_Faction_Asset_Bank()

	if ModelOverridden then
		return
	end

	if Faction_ID ~= nil and Faction_ID == Last_Faction_ID then
		return
	end

	if Faction_ID == nil then
		if Local_Client then
			Faction_ID = Local_Client.faction_id
		end

		if Faction_ID == nil then
			Faction_ID = PG_FACTION_NOVUS
		end
	end

	local asset_bank_name = {}
	asset_bank_name[0] = FactionAssetBanks[Faction_ID]
	BlockStatus = Load_Asset_Banks(asset_bank_name)

	ModelSet = false
end


function Refresh_Faction_Model()

	if ModelOverridden then
		return
	end

	if Faction_ID ~= nil and Faction_ID == Last_Faction_ID then
		return
	end

	if Faction_ID == nil then
		if Local_Client then
			Faction_ID = Local_Client.faction_id
		end

		if Faction_ID == nil then
			Faction_ID = PG_FACTION_NOVUS
		end
	end

	-- Hide whatever was displayed previously
	for _, component in pairs(FactionGUIModels) do
		component.Set_Model("")
		component.Set_Hidden(true)
	end

	local model_list = FactionModels[Faction_ID]
	local component = FactionGUIModels[Faction_ID]

	-- This can happen if Local_Client.faction_id returns an invalid faction
	if model_list == nil or component == nil then
		Faction_ID = PG_FACTION_NOVUS

		model_list = FactionModels[Faction_ID]
		component = FactionGUIModels[Faction_ID]
	end

	local index = GameRandom.Free_Random(1, #model_list)

	component.Set_Hidden(false)
	component.Set_Model(model_list[index])
	component.Play_Randomized_Animation("idle")

end

function Refresh_Faction_Background()

	-- Only do set the background if it was not overridden by a mission
	-- specific background
	if Default_Background == this.AALogic.Background.Get_Texture_Name() then
		if Faction_ID == nil then
			if Local_Client then
				Faction_ID = Local_Client.faction_id
			end
		end
			
		local background = Default_Background
		if Faction_ID then
			background = FactionBackgrounds[Faction_ID]
		end			

		this.AALogic.Background.Set_Texture(background)
	end

	-- The texture is hidden at the start
	this.AALogic.Background.Set_Hidden(false)

end

function Init_Components()
	
	this.AALogic.StartMissionButton.Stop_Animation()
	this.AALogic.StartMissionButton.Set_Hidden(true)
	this.AALogic.Quad_1.Set_Hidden(true)
	this.AALogic.ProgressDisplay.Stop_Animation()
	Animation_Started = false
	
	Ready_To_Start = false
				
	local data_table = GameScoringManager.Get_Game_Script_Data_Table()
	if not Loading_Components_Initialized then
		if data_table == nil then
			this.AALogic.Text_Mission_Description.Set_Text("")
			this.AALogic.Background.Set_Texture(Default_Background)
		else
			if data_table.Loading_Screen_Background then
				this.AALogic.Background.Set_Texture(data_table.Loading_Screen_Background)
			else
				this.AALogic.Background.Set_Texture(Default_Background)
			end

			if data_table.Loading_Screen_Mission_Text then
				this.AALogic.Text_Mission_Description.Set_Text(Get_Game_Text(data_table.Loading_Screen_Mission_Text))
			else
				this.AALogic.Text_Mission_Description.Set_Text("")
			end

			if data_table.Loading_Screen_Faction_ID then
				Faction_ID = data_table.Loading_Screen_Faction_ID
				--Refresh_Faction_Asset_Bank()
				-- JAC - These two calls are now made once the asset bank is finished loading
				Refresh_Faction_Model()
				Refresh_Faction_Background()
				ModelOverridden = true
			end

			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		Loading_Components_Initialized = true
	end
end

function Init_Clients()
	Is_Solo_Game = true

	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable == nil or ctable.ClientTable == nil or
		(Net and Net.Is_Loading_Replay()) then
		--this.AALogic.Progress_Bar_Solo.Set_Hidden(false)
		--this.AALogic.Progress_Bar_Solo.Set_Filled(0)
		this.AALogic.ProgressDisplay.Set_Hidden(false)
		return
	end

	Client_Table = ctable.ClientTable

	Human_Clients = {}
	Client_Progress_Bars = {}

	local current_index = 1
	Number_Of_Clients = 0
	Number_Of_Clients_Finished_Loading = 0
	ClientsLoaded = {}
	local local_addr = Net.Get_Local_Addr()
	for idx, client in pairs(ctable.ClientTable) do
		-- Find the local client
		if not client.is_ai then
			if local_addr == client.common_addr then
				Local_Client = client
			else
				Is_Solo_Game = false
			end
			Human_Clients[client] = current_index
			Platform_Icons[current_index].Set_Hidden(false)
			Platform_Icons[current_index].Set_Texture(PlatformTextures[client.platform])
			Names[current_index].Set_Hidden(false)
			Names[current_index].Set_Text(client.name)
			Progress_Bars[current_index].Set_Hidden(false)
			Client_Progress_Bars[client.common_addr] = Progress_Bars[current_index]
			current_index = current_index + 1
			Number_Of_Clients = Number_Of_Clients + 1
			ClientsLoaded[client] = false
		end
	end
	
	-- Everyone but the local player was AI, so use the solo progress bars
	if Is_Solo_Game then
		Hide_Multiplayer_Components()
		Init_Components()
		--this.AALogic.Progress_Bar_Solo.Set_Hidden(false)
		--this.AALogic.Progress_Bar_Solo.Set_Filled(0)
		this.AALogic.ProgressDisplay.Set_Hidden(false)
	end
end

function On_Message_Recieved(event)
	-- Do not handle events if the dialog is not visible
	if this.Get_Hidden() == true then end

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

		if event.message_type == MESSAGE_TYPE_REMOTE_LOAD_PROGRESS_UPDATED then
			if event.message == 1 then
				--JSY: Looks like we can get duplicates of this event (I had a 2 player game with 3 clients loaded).
				if not ClientsLoaded[sender] then
					Number_Of_Clients_Finished_Loading = Number_Of_Clients_Finished_Loading + 1
					ClientsLoaded[sender] = true
				end
			end
			Client_Progress_Bars[event.common_addr].Set_Filled(event.message)
		end
	elseif event.task == "TASK_CONNECTION_STATUS" then
		if event.status == "session_disconnect" then
			-- TODO: Put a message that says "Dropped" instead of their progress bar
			Remove_Client(sender)
		end
	elseif event.task == "TASK_LIVE_CONNECTION_CHANGED" then
		if ((event.connection_change_id == XONLINE_S_LOGON_DISCONNECTED) or
			(event.connection_change_id == XONLINE_E_LOGON_NO_NETWORK_CONNECTION) or
			(event.connection_change_id == XONLINE_E_LOGON_CANNOT_ACCESS_SERVICE) or 
			(event.connection_change_id == XONLINE_E_LOGON_UPDATE_REQUIRED) or
			(event.connection_change_id == XONLINE_E_LOGON_SERVERS_TOO_BUSY) or
			(event.connection_change_id == XONLINE_E_LOGON_CONNECTION_LOST) or
			(event.connection_change_id == XONLINE_E_LOGON_KICKED_BY_DUPLICATE_LOGON) or
			(event.connection_change_id == XONLINE_E_LOGON_INVALID_USER)) then
			-- If we disconnected, show the quit button as soon as we're done loading.
			TimeToShowQuitButton = 0
		end
	end
end

function Activate_Quit_Button()
	Quit_Button_Enabled = true
	this.AALogic.StartMissionButton.Set_Text(Get_Game_Text("TEXT_BUTTON_DISCONNECT_QUIT"))
	this.AALogic.StartMissionButton.Play_Animation("FadeUp", true)
	this.AALogic.Quad_1.Set_Hidden(false)
	this.AALogic.ProgressDisplay.Play_Animation("FadeOut", false)
end


function Check_If_All_Clients_Finished_Loading()
	if Is_Solo_Game then
		if Percent_Complete == 1 then
			All_Clients_Loaded = true
			if Is_Benchmarking_Enabled and Is_Benchmarking_Enabled() then
				Ready_To_Start = true
			else
				--this.AALogic.ProgressDisplay.Set_Hidden(true)
				--this.AALogic.StartMissionButton.Set_Hidden(false)
				if(not Animation_Started) then
					this.AALogic.StartMissionButton.Play_Animation("FadeUp", true)
					this.AALogic.ProgressDisplay.Play_Animation("FadeOut", false)
					Animation_Started = true
				end
			end
		end
	else
		-- Remove any clients that we have lost connection to
		if Client_Table ~= nil then
			for idx, client in pairs(Client_Table) do
				if Net.Get_Player_ID_By_Network_Address(client.common_addr) == -1 then
					Remove_Client(client)
				end
			end
		end

		All_Clients_Loaded = ( Number_Of_Clients == Number_Of_Clients_Finished_Loading )
		Ready_To_Start = All_Clients_Loaded
	end

	if LocalClientFinishedLoadingTime < 0 and Percent_Complete == 1 then
		LocalClientFinishedLoadingTime = Net.Get_Time()
	end
end


function On_Update()
	-- When the asset bank is finished loading, make sure we update the model and background
	--if BlockStatus.IsFinished() and ModelSet == false then
	--	Refresh_Faction_Model()
	--	Refresh_Faction_Background()
	--	ModelSet = true
	--end

	if Percent_Complete > Previous_Percentage then
		-- Update the progress fill level
		Previous_Percentage = Percent_Complete
		if Is_Solo_Game then
			-- Removing progress bar and replacnig with some simple animation -Oksana
			--this.AALogic.Progress_Bar_Solo.Set_Filled(Percent_Complete)
		else
			Net.MM_Broadcast(MESSAGE_TYPE_REMOTE_LOAD_PROGRESS_UPDATED, Percent_Complete)
		end
	end

	-- Wait for everyone else to finish, then the BatteLoadDialogClass will end the dialog
	Check_If_All_Clients_Finished_Loading()
	if Animation_Started then
		this.AALogic.StartMissionButton.Set_Key_Focus()
		this.AALogic.Quad_1.Set_Hidden(false)
	end
	
	if Is_Solo_Game ~= true and Quit_Button_Enabled ~= true and
		Percent_Complete == 1 and LocalClientFinishedLoadingTime > -1 and
		Net.Get_Time() - LocalClientFinishedLoadingTime > TimeToShowQuitButton then
		Activate_Quit_Button()
	end
end

function Remove_Client(client_to_remove)
	local index = Human_Clients[client_to_remove]
	if index ~= nil then
		Platform_Icons[index].Set_Hidden(true)
		Names[index].Set_Hidden(true)
		Progress_Bars[index].Set_Hidden(true)
		Client_Progress_Bars[client_to_remove.common_addr] = nil
		Number_Of_Clients = Number_Of_Clients - 1
		Human_Clients[client_to_remove] = nil
	end
	
	if Number_Of_Clients == 1 then
		Battle_Load_Force_Quit = true
	end
end

function On_Start_Mission_Button_Clicked()
	Battle_Load_Force_Quit = Quit_Button_Enabled
	Ready_To_Start = true
end

function Close_Dialog()
	--Make sure the models used by this screen are completely unloaded
	for _, component in pairs(FactionGUIModels) do
		component.Force_Dump_Assets()
	end
	this.AALogic.ProgressDisplay.Force_Dump_Assets()
	
	GUIDialogComponent.Set_Active(false)

	-- Reset the data so the next load does not have this screen
	local data_table = GameScoringManager.Get_Game_Script_Data_Table()
	if data_table ~= nil then
		data_table.Loading_Screen_Background = nil
		data_table.Loading_Screen_Mission_Text = nil
		data_table.Loading_Screen_Faction_ID = nil
		GameScoringManager.Set_Game_Script_Data_Table(data_table)
	end
end

function On_Update_Text(event_name, source, load_text)
	if load_text then
		this.AALogic.Text_Mission_Description.Set_Text(Get_Game_Text(load_text))
	else
		this.AALogic.Text_Mission_Description.Set_Text("")
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
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Refresh_Faction_Asset_Bank = nil
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
