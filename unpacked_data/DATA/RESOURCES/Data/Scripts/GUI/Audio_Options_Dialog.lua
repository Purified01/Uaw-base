-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Audio_Options_Dialog.lua#14 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Audio_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 89108 $
--
--          $DateTime: 2007/12/05 14:48:23 $
--
--          $Revision: #14 $
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
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)

	this.Register_Event_Handler("Button_Clicked", this.Button_Accept, Accept_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Cancel_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Default, Default_Clicked)

	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Audio_Technology, Audio_Tech_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Audio_Technology, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Subtitles, Toggle_Subtitles)
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Jukebox_Mode, Toggle_JukeboxMode)

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
	
	this.Register_Event_Handler("Closing_All_Displays", nil, Esc_Pressed)

	-- Setup the tab ordering
	this.Button_Cancel.Set_Tab_Order(Declare_Enum(0))
	this.Button_Default.Set_Tab_Order(Declare_Enum())
	this.Button_Accept.Set_Tab_Order(Declare_Enum())

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	Success_Dialog_Params = { }
	Success_Dialog_Params.caption = Get_Game_Text("TEXT_3D_AUDIO_TECH_INIT_SUCCESS_1")
	Success_Dialog_Params.script = Script
	Success_Dialog_Params.spawned_from_script = true
	Success_Dialog_Params.callback = "On_Audio_Config_Success"
	Success_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")

	Failure_Dialog_Params = { }
	Failure_Dialog_Params.caption = Get_Game_Text("TEXT_3D_AUDIO_TECH_INIT_FAILURE_1")
	Failure_Dialog_Params.script = Script
	Failure_Dialog_Params.spawned_from_script = true
	Failure_Dialog_Params.callback = "On_Audio_Config_Failure"
	Failure_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")
	Failure_Dialog_Params.user_string_1 = Get_Game_Text("TEXT_3D_AUDIO_TECH_INIT_FAILURE_2")

	Dialog_Box_Common_Init()
	Revert_Callback_Params = {}
	Revert_Callback_Params.caption = Get_Game_Text("TEXT_AUDIO_SETTINGS_CHANGED_CONFIRMATION")
	Revert_Callback_Params.script = Script
	Revert_Callback_Params.callback = "Confirm_Callback"

	-- Get the AudioSettingsManager object
	Register_Audio_Commands()

	-- Init the list of mutli channel configs
	Init_Audio_Configs()

	-- Setup the slider bars
	this.Slider_Bar_Master_Volume.Set_Steps(100)
	this.Slider_Bar_Effects_Volume.Set_Steps(100)
	this.Slider_Bar_Dialog_Volume.Set_Steps(100)
	this.Slider_Bar_Music_Volume.Set_Steps(100)

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

	if not Dialog_Has_Reset then
		Dialog_Has_Reset = true
		Settings_Modified = false
		this.Button_Accept.Set_Hidden(true)

		-- Grab the original settings in case the user wants to cancel
		Original_Settings = AudioSettingsManager.Get_Current_Settings()
	end

	-- Grab a copy to modify
	Settings = AudioSettingsManager.Get_Current_Settings()
	Current_Config = Original_Settings.Audio_Config

	Subtitles_Enabled = Original_Settings.Subtitles_Enabled
	this.Checkbox_Subtitles.Set_Checked(Subtitles_Enabled)
	
	Jukebox_Enabled = Original_Settings.Jukebox_Enabled
	this.Checkbox_Jukebox_Mode.Set_Checked(Jukebox_Enabled)
	
	this.Slider_Bar_Master_Volume.Set_Current_Step_Index(Original_Settings.Master_Volume)
	this.Slider_Bar_Effects_Volume.Set_Current_Step_Index(Original_Settings.Effects_Volume)
	this.Slider_Bar_Dialog_Volume.Set_Current_Step_Index(Original_Settings.Dialog_Volume)
	this.Slider_Bar_Music_Volume.Set_Current_Step_Index(Original_Settings.Music_Volume)

	Settings_Modified = false
	Initial_Audio_Config_Select = true
	this.Combo_Audio_Technology.Set_Selected_Index(Get_Audio_Config_Index(Original_Settings.Audio_Config))
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
end

function Default_Clicked(event_name, source)
	this.Slider_Bar_Master_Volume.Set_Current_Step_Index(VOLUME_MASTER_SLIDER_DEFAULT)
	this.Slider_Bar_Effects_Volume.Set_Current_Step_Index(VOLUME_SFX_SLIDER_DEFAULT)
	this.Slider_Bar_Dialog_Volume.Set_Current_Step_Index(VOLUME_SPEECH_SLIDER_DEFAULT)
	this.Slider_Bar_Music_Volume.Set_Current_Step_Index(VOLUME_MUSIC_SLIDER_DEFAULT)
	
	Subtitles_Enabled = SUBTITLES_DEFAULT
	this.Checkbox_Subtitles.Set_Checked(SUBTITLES_DEFAULT)

	Jukebox_Enabled = JUKEBOX_DEFAULT
	this.Checkbox_Jukebox_Mode.Set_Checked(JUKEBOX_DEFAULT)

	Resetting_To_Default = true
	this.Combo_Audio_Technology.Set_Selected_Index(Get_Audio_Config_Index(DEFAULT_AUDIO_CONFIG))
end

function Revert_Settings()
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MASTER, Original_Settings.Master_Volume)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SFX, Original_Settings.Effects_Volume)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SPEECH, Original_Settings.Dialog_Volume)
	AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MUSIC, Original_Settings.Music_Volume)

	AudioSettingsManager.Set_Audio_Config(Original_Settings.Audio_Config)

	AudioSettingsManager.Apply(Original_Settings.Subtitles_Enabled, Original_Settings.Jukebox_Enabled)
end

function Cancel_Clicked(event_name, source)
	Revert_Settings()
	Hide_Dialog()

	Dialog_Has_Reset = false
end

function Settings_Changed()
	Settings_Modified = true
	this.Button_Accept.Set_Hidden(false)
end

function Accept_Clicked(event_name, source)
	Spawn_Dialog_Box(Revert_Callback_Params, "Revert_Video_DialogBox")
end

function Toggle_Subtitles(event_name, source)
	Settings_Changed()
	Subtitles_Enabled = not Subtitles_Enabled
	this.Checkbox_Subtitles.Set_Checked(Subtitles_Enabled)
end

function Toggle_JukeboxMode(_, _)
	Settings_Changed()
	Jukebox_Enabled = not Jukebox_Enabled
	this.Checkbox_Jukebox_Mode.Set_Checked(Jukebox_Enabled)
end

function Master_Volume_Selection_Changed(event_name, source)
	local selected_index = this.Slider_Bar_Master_Volume.Get_Current_Step_Index()

	if (not Initial_Audio_Config_Select) and (selected_index ~= Settings.Master_Volume) then
		Settings_Changed()
		Settings.Master_Volume = selected_index
		AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MASTER, Settings.Master_Volume)
	end
end

function Effects_Volume_Selection_Changed(event_name, source)
	local selected_index = this.Slider_Bar_Effects_Volume.Get_Current_Step_Index()

	if (not Initial_Audio_Config_Select) and (selected_index ~= Settings.Effects_Volume) then
		Settings_Changed()
		Settings.Effects_Volume = selected_index
		AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SFX, Settings.Effects_Volume)
	end
end

function Dialog_Volume_Selection_Changed(event_name, source)
	local selected_index = this.Slider_Bar_Dialog_Volume.Get_Current_Step_Index()

	if (not Initial_Audio_Config_Select) and (selected_index ~= Settings.Dialog_Volume) then
		Settings_Changed()
		Settings.Dialog_Volume = selected_index
		AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_SPEECH, Settings.Dialog_Volume)
	end
end

function Music_Volume_Selection_Changed(event_name, source)
	local selected_index = this.Slider_Bar_Music_Volume.Get_Current_Step_Index()

	if (not Initial_Audio_Config_Select) and (selected_index ~= Settings.Music_Volume) then
		Settings_Changed()
		Settings.Music_Volume = selected_index
		AudioSettingsManager.Set_Slider_Volume(VOLUME_SLIDER_MUSIC, Settings.Music_Volume)
	end
end

function Audio_Tech_Selection_Changed(event_name, source)
	-- Tables use one-based indexing while the selection boxes use zero-based
	local selected_index = this.Combo_Audio_Technology.Get_Selected_Index() + 1
	local selected_config = Audio_Configs[selected_index].Config_ID
	local succeeded = AudioSettingsManager.Set_Audio_Config(selected_config)

	if not Initial_Audio_Config_Select and not Resetting_To_Default then
		Settings_Changed()
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

function Confirm_Callback(button)
	if button == DIALOG_RESULT_RIGHT then
		Cancel_Clicked()
	else
		Dialog_Has_Reset = false
		AudioSettingsManager.Apply(Subtitles_Enabled, Jukebox_Enabled)
		Hide_Dialog()
	end
end

-------------------------------------------------------------------------------
-- Esc_Pressed
-------------------------------------------------------------------------------
function Esc_Pressed()
	if this.Get_Hidden() then return end
	--Only respond to Esc if we're not part of the in-game dialog stack - in that
	--case Esc is handled elsewhere
	local user_data = this.Get_User_Data()
	if not user_data or not TestValid(user_data.Parent_Dialog) then
		Cancel_Clicked()
	else
		Revert_Settings()
	end 
end
