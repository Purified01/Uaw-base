if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[79] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[78] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Audio_Options_Dialog.lua#19 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Audio_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #19 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	
	-- get video settings manager object
	Register_Video_Commands()

	-- register required event handlers
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)

	this.Register_Event_Handler("Button_Clicked", this.Button_Accept, Accept_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Cancel_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Default, Default_Clicked)

	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Audio_Technology, Audio_Tech_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Audio_Technology, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Master_Volume, Master_Volume_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Master_Volume, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Effects_Volume, Effects_Volume_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Effects_Volume, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Dialog_Volume, Dialog_Volume_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Dialog_Volume, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Music_Volume, Music_Volume_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Music_Volume, Play_Option_Select_SFX)

	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Dialog_Volume, Play_Dialog_Test_Sound)
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Effects_Volume, Play_Effects_Test_Sound)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Gamma, Gamma_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Gamma, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Accept_Clicked)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Cancel_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Cancel_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, Default_Clicked)
	
	-- Setup the tab ordering
--	this.Button_Cancel.Set_Tab_Order(Declare_Enum(0))
--	this.Button_Default.Set_Tab_Order(Declare_Enum())
--	this.Button_Accept.Set_Tab_Order(Declare_Enum())

	this.Slider_Bar_Master_Volume.Set_Tab_Order(Declare_Enum(0))
	this.Slider_Bar_Effects_Volume.Set_Tab_Order(Declare_Enum())
	this.Slider_Bar_Dialog_Volume.Set_Tab_Order(Declare_Enum())
	this.Slider_Bar_Music_Volume.Set_Tab_Order(Declare_Enum())

	this.Slider_Bar_Gamma.Set_Tab_Order(Declare_Enum())
	
--	this.Checkbox_Subtitles.Set_Tab_Order(Declare_Enum())
--	this.Checkbox_Jukebox_Mode.Set_Tab_Order(Declare_Enum())
	local w_enable_string = Get_Game_Text("TEXT_ENABLED")
	local w_disable_string = Get_Game_Text("TEXT_DISABLED")

	this.Subtitles_Enable_Disable_Combo_Box.Set_Tab_Order(Declare_Enum())
	this.Subtitles_Enable_Disable_Combo_Box.Add_Item(w_enable_string)
	this.Subtitles_Enable_Disable_Combo_Box.Add_Item(w_disable_string)

	this.Jukebox_Enable_Disable_Combo_Box.Set_Tab_Order(Declare_Enum())
	this.Jukebox_Enable_Disable_Combo_Box.Add_Item(w_enable_string)
	this.Jukebox_Enable_Disable_Combo_Box.Add_Item(w_disable_string)

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	Success_Dialog_Params = { }
	Success_Dialog_Params.caption = ""
	Success_Dialog_Params.script = Script
	Success_Dialog_Params.spawned_from_script = true
	Success_Dialog_Params.callback = "On_Audio_Config_Success"
	Success_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")
	Success_Dialog_Params.user_string_1 = Get_Game_Text("TEXT_3D_AUDIO_TECH_INIT_SUCCESS_1")

	Failure_Dialog_Params = { }
	Failure_Dialog_Params.caption = ""
	Failure_Dialog_Params.script = Script
	Failure_Dialog_Params.spawned_from_script = true
	Failure_Dialog_Params.callback = "On_Audio_Config_Failure"
	Failure_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")
	Failure_Dialog_Params.user_string_1 = Get_Game_Text("TEXT_3D_AUDIO_TECH_INIT_FAILURE_1")
	Failure_Dialog_Params.user_string_2 = Get_Game_Text("TEXT_3D_AUDIO_TECH_INIT_FAILURE_2")

	-- Get the AudioSettingsManager object
	Register_Audio_Commands()

	-- Init the list of mutli channel configs
	Init_Audio_Configs()

	-- Setup the slider bars
	this.Slider_Bar_Master_Volume.Set_Steps(100)
	this.Slider_Bar_Effects_Volume.Set_Steps(100)
	this.Slider_Bar_Dialog_Volume.Set_Steps(100)
	this.Slider_Bar_Music_Volume.Set_Steps(100)

	GAMMA_STEPS = 100
	this.Slider_Bar_Gamma.Set_Steps(GAMMA_STEPS-1)

	-- Display_Dialog does not get called the first time
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



function Display_Dialog()
	if Dialog_Was_Up then
		Dialog_Was_Up = false
		return
	end

	-- Grab the original settings in case the user wants to cancel
	Original_Settings = AudioSettingsManager.Get_Current_Settings()
	Current_Config = Original_Settings.Audio_Config
	
	Original_Video_Setting = VideoSettingsManager.Get_Current_Settings()

	if ( Original_Settings.Subtitles_Enabled ) then
		this.Subtitles_Enable_Disable_Combo_Box.Set_Selected_Index(0)
	else
		this.Subtitles_Enable_Disable_Combo_Box.Set_Selected_Index(1)
	end
	
	if ( Original_Settings.Jukebox_Enabled ) then
		this.Jukebox_Enable_Disable_Combo_Box.Set_Selected_Index(0)
	else
		this.Jukebox_Enable_Disable_Combo_Box.Set_Selected_Index(1)
	end
	
	this.Slider_Bar_Master_Volume.Set_Current_Step_Index(Original_Settings.Master_Volume)
	this.Slider_Bar_Effects_Volume.Set_Current_Step_Index(Original_Settings.Effects_Volume)
	this.Slider_Bar_Dialog_Volume.Set_Current_Step_Index(Original_Settings.Dialog_Volume)
	this.Slider_Bar_Music_Volume.Set_Current_Step_Index(Original_Settings.Music_Volume)

	Initial_Audio_Config_Select = true
	this.Combo_Audio_Technology.Set_Selected_Index(Get_Audio_Config_Index(Original_Settings.Audio_Config))
	
	this.Slider_Bar_Gamma.Set_Current_Step_Index(_gamma_to_slider(Original_Video_Setting.Gamma))
	
	DisplayTime = GetCurrentRealTime()
	
	this.Focus_First()
	
end

function Hide_Dialog()
	Commit_Profile_Values()

	GUI_Dialog_Raise_Parent()
	
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Audio_Options_Dialog"})
end

function Default_Clicked(event_name, source)
	this.Slider_Bar_Master_Volume.Set_Current_Step_Index(VOLUME_MASTER_SLIDER_DEFAULT)
	this.Slider_Bar_Effects_Volume.Set_Current_Step_Index(VOLUME_SFX_SLIDER_DEFAULT)
	this.Slider_Bar_Dialog_Volume.Set_Current_Step_Index(VOLUME_SPEECH_SLIDER_DEFAULT)
	this.Slider_Bar_Music_Volume.Set_Current_Step_Index(VOLUME_MUSIC_SLIDER_DEFAULT)

	Resetting_To_Default = true
	this.Combo_Audio_Technology.Set_Selected_Index(Get_Audio_Config_Index(DEFAULT_AUDIO_CONFIG))
	
	local gamma_index = _gamma_to_slider(1)
	this.Slider_Bar_Gamma.Set_Current_Step_Index(gamma_index)
	Gamma_Selection_Changed()
	
	Jukebox_Enabled = JUKEBOX_DEFAULT
	if ( Jukebox_Enabled ) then
		this.Jukebox_Enable_Disable_Combo_Box.Set_Selected_Index(0)
	else
		this.Jukebox_Enable_Disable_Combo_Box.Set_Selected_Index(1)
	end

	Subtitles_Enabled = SUBTITLES_DEFAULT
	if ( Subtitles_Enabled ) then
		this.Subtitles_Enable_Disable_Combo_Box.Set_Selected_Index(0)
	else
		this.Subtitles_Enable_Disable_Combo_Box.Set_Selected_Index(1)
	end
	
end

function Cancel_Clicked(event_name, source)
	if ( DisplayTime + 1 > GetCurrentRealTime() ) then
		return
	end
	
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MASTER, Original_Settings.Master_Volume)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SFX, Original_Settings.Effects_Volume)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SPEECH, Original_Settings.Dialog_Volume)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MUSIC, Original_Settings.Music_Volume)

	AudioSettingsManager.Set_Audio_Config(Original_Settings.Audio_Config)

	AudioSettingsManager.Apply(Original_Settings.Subtitles_Enabled, Original_Settings.Jukebox_Enabled)
	
	VideoSettingsManager.Set_Gamma(Original_Video_Setting.Gamma, true)

	Hide_Dialog()
end

function Accept_Clicked(event_name, source)
	if ( DisplayTime + 1 > GetCurrentRealTime() ) then
		return
	end
	
	if (this.Subtitles_Enable_Disable_Combo_Box.Get_Selected_Index() == 0) then
		Subtitles_Enabled = true
	else
		Subtitles_Enabled = false;
	end
	
	if (this.Jukebox_Enable_Disable_Combo_Box.Get_Selected_Index() == 0) then
		Jukebox_Enabled = true
	else
		Jukebox_Enabled = false;
	end
	
	local gamma = _slider_to_gamma(this.Slider_Bar_Gamma.Get_Current_Step_Index())
	if Original_Video_Setting.Gamma ~= gamma then
		VideoSettingsManager.Set_Gamma(gamma, true)
	end
	
	AudioSettingsManager.Apply(Subtitles_Enabled, Jukebox_Enabled)
	Hide_Dialog()
end

function Master_Volume_Selection_Changed(event_name, source)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MASTER, this.Slider_Bar_Master_Volume.Get_Current_Step_Index())
end

function Effects_Volume_Selection_Changed(event_name, source)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SFX, this.Slider_Bar_Effects_Volume.Get_Current_Step_Index())
end

function Dialog_Volume_Selection_Changed(event_name, source)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SPEECH, this.Slider_Bar_Dialog_Volume.Get_Current_Step_Index())
end

function Music_Volume_Selection_Changed(event_name, source)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MUSIC, this.Slider_Bar_Music_Volume.Get_Current_Step_Index())
end

function Audio_Tech_Selection_Changed(event_name, source)
	-- Tables use one-based indexing while the selection boxes use zero-based
	local selected_index = this.Combo_Audio_Technology.Get_Selected_Index() + 1
	local selected_config = Audio_Configs[selected_index].Config_ID
	local succeeded = AudioSettingsManager.Set_Audio_Config(selected_config)

	if not Initial_Audio_Config_Select and not Resetting_To_Default then
		if succeeded then
			Spawn_Dialog_Box(Success_Dialog_Params)
		else
			Failure_Config = selected_config
			Spawn_Dialog_Box(Failure_Dialog_Params)
		end		
	end
	
	Resetting_To_Default = false
	Initial_Audio_Config_Select = false
end

function Init_Audio_Configs()
	Audio_Configs = AudioSettingsManager.Get_Multi_Channel_Configs()
	for index, config_data in pairs(Audio_Configs) do
		this.Combo_Audio_Technology.Add_Item(config_data.Display_String)
	end

	this.Combo_Audio_Technology.Refresh()
end

function Get_Audio_Config_Index(config_id)
	local config_index = 0

	for index, config_data in pairs(Audio_Configs) do
		if config_data.Config_ID == config_id then
			config_index = index - 1 -- Tables use one-based indexing while the selection boxes use zero-based
			break
		end
	end

	return config_index
end

function On_Audio_Config_Success()
	Dialog_Was_Up = true

	local selected_index = this.Combo_Audio_Technology.Get_Selected_Index() + 1
	Current_Config = Audio_Configs[selected_index].Config_ID
end

function On_Audio_Config_Failure()
	Dialog_Was_Up = true

	local settings = AudioSettingsManager.Get_Current_Settings()

	Resetting_To_Default = true
	if settings.Audio_Config == Failure_Config then
		this.Combo_Audio_Technology.Set_Selected_Index(Get_Audio_Config_Index(DEFAULT_AUDIO_CONFIG))
	else
		this.Combo_Audio_Technology.Set_Selected_Index(Get_Audio_Config_Index(settings.Audio_Config))
	end
end

function Play_Effects_Test_Sound()
	AudioSettingsManager.Play_Test_Sound(VOLUME_SLIDER_SFX)
end

function Play_Dialog_Test_Sound()
	AudioSettingsManager.Play_Test_Sound(VOLUME_SLIDER_SPEECH)
end

function Gamma_Selection_Changed(event_name, source)
	if ( not Setting_Gamma ) then
		Setting_Gamma = true
		
		local gamma = _slider_to_gamma(this.Slider_Bar_Gamma.Get_Current_Step_Index())
		if Original_Video_Setting.Gamma ~= gamma then
			VideoSettingsManager.Set_Gamma(gamma, false)
		end
		
		Setting_Gamma = false
	end
end

function _slider_to_gamma(slider_index)
	return MIN_GAMMA + (slider_index / GAMMA_STEPS) * (MAX_GAMMA - MIN_GAMMA)
end

function _gamma_to_slider(gamma)
	local slider = (gamma - MIN_GAMMA) / (MAX_GAMMA - MIN_GAMMA)
	return Clamp(slider,0,1) * GAMMA_STEPS
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
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
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
	PGNetwork_Init = nil
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
	PGPlayerProfile_Init = nil
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
