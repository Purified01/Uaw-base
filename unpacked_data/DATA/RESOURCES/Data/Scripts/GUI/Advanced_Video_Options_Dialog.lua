-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Advanced_Video_Options_Dialog.lua#14 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Advanced_Video_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Thanh_Nguyen $
--
--            $Change: 85515 $
--
--          $DateTime: 2007/10/04 16:15:15 $
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

	this.Register_Event_Handler("Button_Clicked", this.Button_Okay, Okay_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Apply, Apply_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Cancel_Clicked)
--	this.Register_Event_Handler("Button_Clicked", this.Button_Auto_Detect, Auto_Detect_Clicked)

	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Bloom, Toggle_Bloom)
--	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Soft_Shadows, Toggle_Soft_Shadows)
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Heat_Distortion, Toggle_Heat_Distortion)

	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Particle_Detail, Particle_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Particle_Detail, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Geometry_Detail, Geometry_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Geometry_Detail, Play_Option_Select_SFX)

	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Water_Detail, Water_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Water_Detail, Play_Option_Select_SFX)

	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Shader_Detail, Shader_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Shader_Detail, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Texture_Detail, Texture_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Texture_Detail, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Shadow_Detail, Shadow_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Shadow_Detail, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Environment_Detail, Environment_Detail_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Environment_Detail, Play_Option_Select_SFX)

	-- Setup the tab ordering
	this.Button_Auto_Detect.Set_Tab_Order(Declare_Enum(0))
	this.Button_Cancel.Set_Tab_Order(Declare_Enum())
	this.Button_Apply.Set_Tab_Order(Declare_Enum())
	this.Button_Okay.Set_Tab_Order(Declare_Enum())

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- Get the VideoSettingsManager object
	Register_Video_Commands()

	-- Setup the slider bars
	-- SKY 07/16/2007 - particle, geometry, and environment sliders shouldn't be decremented because they go from 0 to 100
	this.Slider_Bar_Shadow_Detail.Set_Steps(SHADOW_LOD_COUNT-1)
	this.Slider_Bar_Texture_Detail.Set_Steps(TEXTURE_LOD_COUNT-1)
	this.Slider_Bar_Particle_Detail.Set_Steps(PARTICLE_LOD_COUNT)
	this.Slider_Bar_Geometry_Detail.Set_Steps(GEOMETRY_LOD_COUNT)
	this.Slider_Bar_Environment_Detail.Set_Steps(ENVIRONMENT_LOD_COUNT)

	-- Comment lifted from the AdvancedVideoOptionsDialog.cpp
	-- // (gth) Don't ever let Intel HW go above fixed function, we get 1fps and you can't even navigate the menus!
	if WATER_LOD_COUNT and not IS_INTEL_HARDWARE then
		this.Slider_Bar_Water_Detail.Set_Steps(WATER_LOD_COUNT-1)
	else
		this.Slider_Bar_Water_Detail.Enable(false)
		this.Slider_Bar_Water_Detail.Set_Hidden(true)
	end

	-- Comment lifted from the AdvancedVideoOptionsDialog.cpp
	-- // (gth) Don't ever let Intel HW go above fixed function, we get 1fps and you can't even navigate the menus!
	if SHADER_LOD_COUNT and not IS_INTEL_HARDWARE then
		this.Slider_Bar_Shader_Detail.Set_Steps(SHADER_LOD_COUNT-1)
	else
		this.Slider_Bar_Shader_Detail.Enable(false)
		this.Slider_Bar_Shader_Detail.Set_Hidden(true)
	end

	-- Apparently this toggle does nothing code side at the moment... just hide it for now
	this.Text_Soft_Shadows.Set_Hidden(true)
	this.Checkbox_Soft_Shadows.Set_Hidden(true)
	this.Button_Auto_Detect.Set_Hidden(true)

	Dialog_Box_Common_Init()
	Revert_Callback_Params = {}
	Revert_Callback_Params.caption = Get_Game_Text("TEXT_GRAPHICS_SETTINGS_CHANGED_CONFIRMATION")
	Revert_Callback_Params.script = Script
	Revert_Callback_Params.callback = "Confirm_Callback"

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
	-- Grab the original settings and make a copy to modify
	OriginalSettings = VideoSettingsManager.Get_Current_Settings()
	Settings = VideoSettingsManager.Get_Current_Settings()

	Settings.Advanced_Details_Changed = false

	if WATER_LOD_COUNT and not IS_INTEL_HARDWARE then
		this.Slider_Bar_Water_Detail.Set_Current_Step_Index(Settings.Water_Detail)
	end

	if SHADER_LOD_COUNT and not IS_INTEL_HARDWARE then
		this.Slider_Bar_Shader_Detail.Set_Current_Step_Index(Settings.Shader_Detail)
	end

	this.Slider_Bar_Geometry_Detail.Set_Current_Step_Index(Settings.Geometry_Detail)
	this.Slider_Bar_Environment_Detail.Set_Current_Step_Index(Settings.Environment_Detail)
	this.Slider_Bar_Shadow_Detail.Set_Current_Step_Index(Settings.Shadow_Detail)
	this.Slider_Bar_Particle_Detail.Set_Current_Step_Index(Settings.Particle_Detail)
	this.Slider_Bar_Texture_Detail.Set_Current_Step_Index(Settings.Texture_Detail)

--	this.Checkbox_Soft_Shadows.Set_Checked(Settings.Soft_Shadows_Enabled)
	this.Checkbox_Bloom.Set_Checked(Settings.Bloom_Enabled)
	this.Checkbox_Heat_Distortion.Set_Checked(Settings.Heat_Distortion_Enabled)

	OkayButtonClicked = false

	-- Apply starts out hidden until a setting is changed
	this.Button_Apply.Set_Hidden(true)
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
end

function On_Settings_Changed()
	this.Button_Apply.Set_Hidden(false)
	Settings.Advanced_Details_Changed = true
end

function Auto_Detect_Clicked(event_name, source)
	local recommended_settings = VideoSettingsManager.Get_Recommended_Settings()

	if WATER_LOD_COUNT and not IS_INTEL_HARDWARE then
		this.Slider_Bar_Water_Detail.Set_Current_Step_Index(recommended_settings.Water_Detail)
	end
	
	if SHADER_LOD_COUNT and not IS_INTEL_HARDWARE then
		this.Slider_Bar_Shader_Detail.Set_Current_Step_Index(recommended_settings.Shader_Detail)
	end

	this.Slider_Bar_Particle_Detail.Set_Current_Step_Index(recommended_settings.Particle_Detail)
	this.Slider_Bar_Geometry_Detail.Set_Current_Step_Index(recommended_settings.Geometry_Detail)
	this.Slider_Bar_Texture_Detail.Set_Current_Step_Index(recommended_settings.Texture_Detail)
	this.Slider_Bar_Shadow_Detail.Set_Current_Step_Index(recommended_settings.Shadow_Detail)
	this.Slider_Bar_Environment_Detail.Set_Current_Step_Index(recommended_settings.Environment_Detail)

	-- Manually implement check-box change handling here :(
	if recommended_settings.Bloom_Enabled ~= Settings.Bloom_Enabled then
		On_Settings_Changed()
		Settings.Bloom_Enabled = recommended_settings.Bloom_Enabled
		this.Checkbox_Bloom.Set_Checked(recommended_settings.Bloom_Enabled)
	end

--	if recommended_settings.Soft_Shadows_Enabled ~= Settings.Soft_Shadows_Enabled then
--		On_Settings_Changed()
--		Settings.Soft_Shadows_Enabled = recommended_settings.Soft_Shadows_Enabled
--		this.Checkbox_Soft_Shadows.Set_Checked(recommended_settings.Soft_Shadows_Enabled)
--	end

	if recommended_settings.Heat_Distortion_Enabled ~= Settings.Heat_Distortion_Enabled then
		On_Settings_Changed()
		Settings.Heat_Distortion_Enabled = recommended_settings.Heat_Distortion_Enabled
		this.Checkbox_Heat_Distortion.Set_Checked(recommended_settings.Heat_Distortion_Enabled)
	end
end

function Cancel_Clicked(event_name, source)
	Hide_Dialog()
end

function Apply_Clicked(event_name, source)
	VideoSettingsManager.Apply(Settings)
	Spawn_Dialog_Box(Revert_Callback_Params, "Revert_Video_DialogBox")
end

function Okay_Clicked(event_name, source)
	if Settings.Advanced_Details_Changed then
		OkayButtonClicked = true
		Apply_Clicked()
	else
		Hide_Dialog()
	end
end

--function Toggle_Soft_Shadows(event_name, source)
--	On_Settings_Changed()
--	Settings.Soft_Shadows_Enabled = not Settings.Soft_Shadows_Enabled
--	this.Checkbox_Soft_Shadows.Set_Checked(Settings.Soft_Shadows_Enabled)
--end

function Toggle_Bloom(event_name, source)
	On_Settings_Changed()
	Settings.Bloom_Enabled = not Settings.Bloom_Enabled
	this.Checkbox_Bloom.Set_Checked(Settings.Bloom_Enabled)
end

function Toggle_Heat_Distortion(event_name, source)
	On_Settings_Changed()
	Settings.Heat_Distortion_Enabled = not Settings.Heat_Distortion_Enabled
	this.Checkbox_Heat_Distortion.Set_Checked(Settings.Heat_Distortion_Enabled)
end

function Particle_Detail_Selection_Changed(event_name, source, bar_move)
	-- I have recieved some false positives so I have to do this check
	if Settings.Particle_Detail ~= this.Slider_Bar_Particle_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Particle_Detail = this.Slider_Bar_Particle_Detail.Get_Current_Step_Index()
	end
end

function Geometry_Detail_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Geometry_Detail ~= this.Slider_Bar_Geometry_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Geometry_Detail = this.Slider_Bar_Geometry_Detail.Get_Current_Step_Index()
	end
end

function Water_Detail_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Water_Detail ~= this.Slider_Bar_Water_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Water_Detail = this.Slider_Bar_Water_Detail.Get_Current_Step_Index()
	end
end

function Texture_Detail_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Texture_Detail ~= this.Slider_Bar_Texture_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Texture_Detail = this.Slider_Bar_Texture_Detail.Get_Current_Step_Index()
	end
end

function Shader_Detail_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Shader_Detail ~= this.Slider_Bar_Shader_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Shader_Detail = this.Slider_Bar_Shader_Detail.Get_Current_Step_Index()
	end
end

function Shadow_Detail_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Shadow_Detail ~= this.Slider_Bar_Shadow_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Shadow_Detail = this.Slider_Bar_Shadow_Detail.Get_Current_Step_Index()
	end
end

function Environment_Detail_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Environment_Detail ~= this.Slider_Bar_Environment_Detail.Get_Current_Step_Index() then
		On_Settings_Changed()
		Settings.Environment_Detail = this.Slider_Bar_Environment_Detail.Get_Current_Step_Index()
	end
end

function Confirm_Callback(button)
	if button == DIALOG_RESULT_RIGHT then
		-- Manually need to force detail slider changed state
		OriginalSettings.Advanced_Details_Changed = true

		VideoSettingsManager.Apply(OriginalSettings)
		Display_Dialog()
	else
		if OkayButtonClicked then
			Hide_Dialog()
		end
	end
end
