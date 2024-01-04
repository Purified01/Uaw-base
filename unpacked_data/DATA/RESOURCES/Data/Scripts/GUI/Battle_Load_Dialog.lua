-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Battle_Load_Dialog.lua#28 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Battle_Load_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Mike_Lytle $
--
--            $Change: 86617 $
--
--          $DateTime: 2007/10/24 17:32:25 $
--
--          $Revision: #28 $
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
	DialogStartTime = Net.Get_Time()
	Previous_Percentage = Percent_Complete

	Names = Find_GUI_Components(this, "Text_Name")
	Progress_Bars = Find_GUI_Components(this, "Progress_Bar")

	PGFactions_Init()
	Init_Faction_Models()

	Default_Background = this.Background.Get_Texture_Name()

	this.Register_Event_Handler("Button_Clicked", this.StartMissionButton, On_Start_Mission_Button_Clicked)
	this.StartMissionButton.Set_Tab_Order(0)

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
	FactionGUIModels[PG_FACTION_NOVUS] = this.Novus_Model
	FactionGUIModels[PG_FACTION_ALIEN] = this.Alien_Model
	FactionGUIModels[PG_FACTION_MASARI] = this.Masari_Model
	FactionGUIModels[PG_FACTION_MILITARY] = this.Military_Model

end

function Hide_Multiplayer_Components()

	-- All names are hidden by default
	for _, name in pairs(Names) do
		name.Set_Text("")
		name.Set_Hidden(true)
	end

	-- All progress bars are hidden by default
	this.Progress_Bar_Solo.Set_Hidden(true)
	this.ProgressDisplay.Set_Hidden(true)
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
	this.Background.Set_Hidden(true)

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
	ModelOverridden = false
	All_Clients_Loaded = false
	Broadcast_Complete_Sent = false
	ClientsLoaded = {}

	Quit_Button_Enabled = false
	Battle_Load_Force_Quit = false
	DialogStartTime = Net.Get_Time()

	Percent_Complete = 0
	Previous_Percentage = Percent_Complete

	Loading_Components_Initialized = false

	Init_Components()
	Init_Clients()
	Refresh_Faction_Model()
	Refresh_Faction_Background()
end

function Refresh_Faction_Model(faction_id)

	if ModelOverridden then return end

	if faction_id == nil then
		local local_player = Find_Player("local")		
		if Local_Client then
			faction_id = Local_Client.faction_id
		elseif local_player then
			faction_id = Get_Faction_Numeric_Form_From_Localized(local_player.Get_Faction_Display_Name())
		end

		if faction_id == nil then
			faction_id = PG_FACTION_NOVUS
		end
	end

	local model_list = FactionModels[faction_id]
	local component = FactionGUIModels[faction_id]

	-- This can happen if Local_Client.faction_id returns an invalid faction
	if model_list == nil or component == nil then
		faction_id = PG_FACTION_NOVUS

		model_list = FactionModels[faction_id]
		component = FactionGUIModels[faction_id]
	end

	local index = GameRandom.Free_Random(1, #model_list)

	component.Set_Hidden(false)
	component.Set_Model(model_list[index])
	component.Play_Randomized_Animation("idle")

end

function Refresh_Faction_Background(faction_id)

	-- Only do set the background if it was not overridden by a mission
	-- specific background
	if Default_Background == this.Background.Get_Texture_Name() then
		if faction_id == nil then
			local local_player = Find_Player("local")		
			if Local_Client then
				faction_id = Local_Client.faction_id
			elseif local_player then
				faction_id = Get_Faction_Numeric_Form_From_Localized(local_player.Get_Faction_Display_Name())
			end
		end
			
		local background = Default_Background
		if faction_id then
			background = FactionBackgrounds[faction_id]
		end			

		this.Background.Set_Texture(background)
	end

	-- The texture is hidden at the start
	this.Background.Set_Hidden(false)

end

function Init_Components()
	
	this.StartMissionButton.Stop_Animation()
	this.StartMissionButton.Set_Hidden(true)
	this.ProgressDisplay.Stop_Animation()
	Animation_Started = false
	
	Ready_To_Start = false
				
	local data_table = GameScoringManager.Get_Game_Script_Data_Table()
	if not Loading_Components_Initialized then
		if data_table == nil then
			this.Text_Mission_Description.Set_Text("")
			this.Background.Set_Texture(Default_Background)
		else
			if data_table.Loading_Screen_Background then
				this.Background.Set_Texture(data_table.Loading_Screen_Background)
			else
				this.Background.Set_Texture(Default_Background)
			end

			if data_table.Loading_Screen_Mission_Text then
				this.Text_Mission_Description.Set_Text(Get_Game_Text(data_table.Loading_Screen_Mission_Text))
			else
				this.Text_Mission_Description.Set_Text("")
			end

			if data_table.Loading_Screen_Faction_ID then
				Refresh_Faction_Model(data_table.Loading_Screen_Faction_ID)
				Refresh_Faction_Background(data_table.Loading_Screen_Faction_ID)
				ModelOverridden = true
			end

			-- Reset the data so the next load does not have this screen
			--data_table.Loading_Screen_Background = nil
			--data_table.Loading_Screen_Mission_Text = nil
			--data_table.Loading_Screen_Faction_ID = nil
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
		--this.Progress_Bar_Solo.Set_Hidden(false)
		--this.Progress_Bar_Solo.Set_Filled(0)
		this.ProgressDisplay.Set_Hidden(false)
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
		--this.Progress_Bar_Solo.Set_Hidden(false)
		--this.Progress_Bar_Solo.Set_Filled(0)
		this.ProgressDisplay.Set_Hidden(false)
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
	end
end

function Activate_Quit_Button()
	Quit_Button_Enabled = true
	this.StartMissionButton.Set_Text(Get_Game_Text("TEXT_BUTTON_DISCONNECT_QUIT"))
	this.StartMissionButton.Play_Animation("FadeUp", true)
	this.ProgressDisplay.Play_Animation("FadeOut", false)
end


function Check_If_All_Clients_Finished_Loading()
	if Is_Solo_Game then
		if Percent_Complete == 1 then
			All_Clients_Loaded = true
			if Is_Benchmarking_Enabled and Is_Benchmarking_Enabled() then
				Ready_To_Start = true
			else
				--this.ProgressDisplay.Set_Hidden(true)
				--this.StartMissionButton.Set_Hidden(false)
				if(not Animation_Started) then
					this.StartMissionButton.Play_Animation("FadeUp", true)
					this.ProgressDisplay.Play_Animation("FadeOut", false)
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
end


function On_Update()
	if Percent_Complete > Previous_Percentage then
		-- Update the progress fill level
		Previous_Percentage = Percent_Complete
		if Is_Solo_Game then
			-- Removing progress bar and replacnig with some simple animation -Oksana
			--this.Progress_Bar_Solo.Set_Filled(Percent_Complete)
		else
			Net.MM_Broadcast(MESSAGE_TYPE_REMOTE_LOAD_PROGRESS_UPDATED, Percent_Complete)
		end
	end

	-- Wait for everyone else to finish, then the BatteLoadDialogClass will end the dialog
	Check_If_All_Clients_Finished_Loading()

	if Is_Solo_Game ~= true and Quit_Button_Enabled ~= true and Percent_Complete == 1 and
			Net.Get_Time() - DialogStartTime > TimeToShowQuitButton then
		Activate_Quit_Button()
	end

end

function Remove_Client(client_to_remove)
	local index = Human_Clients[client_to_remove]
	if index ~= nil then
		Names[index].Set_Hidden(true)
		Progress_Bars[index].Set_Hidden(true)
		Client_Progress_Bars[client_to_remove.common_addr] = nil
		Number_Of_Clients = Number_Of_Clients - 1
		Human_Clients[client_to_remove] = nil
	end
end

function On_Start_Mission_Button_Clicked()
	Battle_Load_Force_Quit = Quit_Button_Enabled
	Ready_To_Start = true
end
