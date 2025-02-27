if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[79] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Video_Options_Dialog.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Video_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	-- Get the VideoSettingsManager object
	Register_Video_Commands()

	if BETA_BUILD or GOLD_BUILD then
		this.Checkbox_Windowed.Enable(false)
		this.Checkbox_Windowed.Set_Hidden(true)
		this.Text_Windowed.Set_Hidden(true)
	else
		this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Windowed, Toggle_Windowed)
	end

	-- register required event handlers
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)

	this.Register_Event_Handler("Button_Clicked", this.Button_Auto_Detect, Auto_Detect_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Advanced, Advanced_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Cancel_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Apply, Apply_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Okay, Okay_Clicked)

	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Vsync, Toggle_Vsync)
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Hardware_Mouse, Toggle_Hardware_Mouse)

	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Gamma, Gamma_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Gamma, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Detail_Level, Detail_Level_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Detail_Level, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Anti_Aliasing, Anti_Aliasing_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Anti_Aliasing, Play_Option_Select_SFX)
	

	this.Register_Event_Handler("List_Selected_Index_Changed", this.List_Box_Resolutions, Resolution_Selection_Changed)
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.List_Box_Resolutions, Play_Option_Select_SFX)	
	
	-- SKY 08/30/2007 - DX10 checkbox
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_DX10, Toggle_DX10)

	this.Register_Event_Handler("Closing_All_Displays", nil, Esc_Pressed)

	-- Setup the tab ordering
	this.Button_Auto_Detect.Set_Tab_Order(Declare_Enum(0))
	this.Button_Advanced.Set_Tab_Order(Declare_Enum())
	this.Button_Cancel.Set_Tab_Order(Declare_Enum())
	this.Button_Apply.Set_Tab_Order(Declare_Enum())
	this.Button_Okay.Set_Tab_Order(Declare_Enum())

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()
	
	-- SKY 8/14/2007 - DirectX versions, copied from alGraphicsDriver.h
	DRIVER_TYPE_DX9 = Declare_Enum(0)
	DRIVER_TYPE_DX10 = Declare_Enum()
	DRIVER_TYPE_XBOX360 = Declare_Enum()

	RESOLUTION = Create_Wide_String("RESOLUTION")

	-- Specify the column for the list box
	this.List_Box_Resolutions.Set_Header_Style("NONE")
	this.List_Box_Resolutions.Add_Column(RESOLUTION, JUSTIFY_LEFT)
	this.List_Box_Resolutions.Refresh()

	Dialog_Box_Common_Init()
	Revert_Callback_Params = {}
	Revert_Callback_Params.caption = Get_Game_Text("TEXT_GRAPHICS_SETTINGS_CHANGED_CONFIRMATION")
	Revert_Callback_Params.script = Script
	Revert_Callback_Params.callback = "Confirm_Callback"
		
	AAChanged_Dialog_Params = { }
	AAChanged_Dialog_Params.caption = Get_Game_Text("TEXT_WARNING_ANTI_ALIASING_CHANGE")
	AAChanged_Dialog_Params.script = Script
	AAChanged_Dialog_Params.spawned_from_script = true
	AAChanged_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")
	AAChanged_Dialog_Params.callback = "Confirm_Callback"
	
	DXChanged_Dialog_Params = { }
	DXChanged_Dialog_Params.caption = Get_Game_Text("TEXT_WARNING_DIRECTX_CHANGE")
	DXChanged_Dialog_Params.script = Script
	DXChanged_Dialog_Params.spawned_from_script = true
	DXChanged_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")
	DXChanged_Dialog_Params.callback = "Confirm_Callback"

	PGColors_Init()

	-- Setup the slider bars
	GAMMA_STEPS = 100
	this.Slider_Bar_Gamma.Set_Steps(GAMMA_STEPS)
	this.Slider_Bar_Detail_Level.Set_Steps(MAX_DETAIL_LEVEL)

	-- I assume the available resolutions are not going to change
	Init_Available_Resolutions()

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
	Original_Gamma = Settings.Gamma -- this the only thing that needs to be reset on a cancel

	-- if OriginalSettings.Original_Driver_Type == DRIVER_TYPE_DX10 then
	--	this.Checkbox_Hardware_Mouse.Set_Hidden(true)
	--	this.Text_Hardware_Mouse.Set_Hidden(true)
	-- end

	SettingsModified = false
	Settings.Detail_Slider_Changed = false
	
	-- SKY 08/14/2007 - DX10 needs to notify the user to restart the game when AA or DX version is changed
	AAModified = false
	DX10Modified = false

	this.Text_Video_Card.Set_Text(Settings.Device_Description)

	this.Slider_Bar_Anti_Aliasing.Set_Steps(Settings.Num_AA_Levels-1 + Settings.Num_CSAA_Levels)
	this.Slider_Bar_Anti_Aliasing.Set_Current_Step_Index(Settings.AA_Level)
	
	-- If no AA (one level), then disable the slider
	if Settings.Num_AA_Levels == 1 then
		this.Slider_Bar_Anti_Aliasing.Enable(false)
	end

	this.Slider_Bar_Detail_Level.Set_Current_Step_Index(Settings.Simple_Detail_Level)

	this.Checkbox_Vsync.Set_Checked(Settings.Vsync_Enabled)
	this.Checkbox_Hardware_Mouse.Set_Checked(Settings.Hardware_Mouse_Enabled)

	if not BETA_BUILD and not GOLD_BUILD then
		this.Checkbox_Windowed.Set_Checked(Settings.Windowed_Enabled)

		if Settings.Windowed_Enabled then
			this.Text_Gamma.Set_Hidden(true)
			this.Text_Gamma_Level.Set_Hidden(true)
			this.Slider_Bar_Gamma.Set_Hidden(true)
		else
			-- In case this was hidden in a previous Display_Dialog call
			this.Text_Gamma.Set_Hidden(false)
			this.Text_Gamma_Level.Set_Hidden(false)
			this.Slider_Bar_Gamma.Set_Hidden(false)
		end
	end
	
	this.Slider_Bar_Gamma.Set_Current_Step_Index(_gamma_to_slider(Settings.Gamma))
	
	--- SKY 08/30/2007 - DX10 support
	if Settings.DX10_Supported then
		this.Checkbox_DX10.Set_Hidden(false)
		this.Text_DX10.Set_Hidden(false)
		this.Checkbox_DX10.Set_Checked(Settings.DX10_Enabled)
	else
		this.Checkbox_DX10.Set_Hidden(true)
		this.Text_DX10.Set_Hidden(true)
	end

	Select_Current_Resolution(true)
	OkayButtonClicked = false

	-- Apply starts out hidden until a setting is changed
	this.Button_Apply.Set_Hidden(true)
	
	-- Update all text
	Update_Text()
end

function Select_Current_Resolution(highlight)
	for _, res in pairs(Resolutions) do
		if res.Resolution.Width == Settings.Screen_Width and
			res.Resolution.Refresh == Settings.Screen_Refresh and
			res.Resolution.Height == Settings.Screen_Height then

			this.List_Box_Resolutions.Set_Selected_Row_Index(res.Row_ID)

			if highlight then
				HighlightedEntry = res
				this.List_Box_Resolutions.Set_Row_Background(res.Row_ID, 25)
			end

		end
	end
end

function Apply_Settings(settings)
	if HighlightedEntry then
		this.List_Box_Resolutions.Set_Row_Background(HighlightedEntry.Row_ID, 0)
	end
	VideoSettingsManager.Apply(settings)
end


function Init_Available_Resolutions()
	this.List_Box_Resolutions.Clear()

	Resolutions = VideoSettingsManager.Get_Available_Resolutions()
	for index, resolution_data in pairs(Resolutions) do
		local new_row = this.List_Box_Resolutions.Add_Row()
		this.List_Box_Resolutions.Set_Text_Data(RESOLUTION, new_row, resolution_data.Display_String)
		Resolutions[index] = { Resolution = resolution_data, Row_ID = new_row }
	end
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
end

function Auto_Detect_Clicked(event_name, source)
	local recommended_settings = VideoSettingsManager.Get_Recommended_Settings()
	this.Slider_Bar_Anti_Aliasing.Set_Current_Step_Index(recommended_settings.AA_Level)
	this.Slider_Bar_Detail_Level.Set_Current_Step_Index(recommended_settings.Simple_Detail_Level)

	for key, member in pairs(recommended_settings) do
		Settings[key] = member
	end
	
	if recommended_settings.DX10_Supported then
		this.Checkbox_DX10.Set_Checked(recommended_settings.DX10_Recommended)
		if Settings.DX10_Enabled ~= recommended_settings.DX10_Recommended then
			DX10Modified = true
			Settings.DX10_Enabled = recommended_settings.DX10_Recommended
		end
	end

	Settings.Gamma = _gamma_to_slider(1)
	this.Slider_Bar_Gamma.Set_Current_Step_Index(Settings.Gamma)

	Select_Current_Resolution()
	
	Settings.Vsync_Enabled = false
	this.Checkbox_Vsync.Set_Checked(false)

	Settings.Advanced_Details_Changed = true
	Settings_Changed()
end

function Advanced_Clicked(event_name, source)
	Spawn_Dialog("Advanced_Video_Options_Dialog", true)
end

function Cancel_Clicked(event_name, source)
	VideoSettingsManager.Set_Gamma(Original_Gamma)
	Hide_Dialog()
end

function Apply_Clicked(event_name, source)
	Apply_Settings(Settings)
	Spawn_Dialog_Box(Revert_Callback_Params, "Revert_Video_DialogBox")
end

function Okay_Clicked(event_name, source)
	if SettingsModified then
		OkayButtonClicked = true
		Apply_Clicked()
	else
		Hide_Dialog()
	end
end

function Settings_Changed()
	SettingsModified = true
	this.Button_Apply.Set_Hidden(false)
end

function Toggle_Vsync(event_name, source)
	Settings_Changed()
	Settings.Vsync_Enabled = not Settings.Vsync_Enabled
	this.Checkbox_Vsync.Set_Checked(Settings.Vsync_Enabled)
end

function Toggle_Hardware_Mouse(event_name, source)
	Settings_Changed()
	Settings.Hardware_Mouse_Enabled = not Settings.Hardware_Mouse_Enabled
	this.Checkbox_Hardware_Mouse.Set_Checked(Settings.Hardware_Mouse_Enabled)
end

function Toggle_Windowed(event_name, source)
	Settings_Changed()
	Settings.Windowed_Enabled = not Settings.Windowed_Enabled
	this.Checkbox_Windowed.Set_Checked(Settings.Windowed_Enabled)
	
	-- SKY 07/18/2007 - if we're in fullscreen mode now, then change the resolution to what's selected so that we don't have ackward values
	if Settings.Windowed_Enabled == false then
		if this.List_Box_Resolutions.Get_Selected_Row_Index() == -1 then
			this.List_Box_Resolutions.Set_Selected_Row_Index(0)
		end
		Resolution_Selection_Changed(event_name, source)
	end		
end

-- SKY 08/30/2007 - DX10 support
function Toggle_DX10(event_name, source)
	Settings_Changed()
	Settings.DX10_Enabled = not Settings.DX10_Enabled
	this.Checkbox_DX10.Set_Checked(Settings.DX10_Enabled)
	DX10Modified = true
end

function Resolution_Selection_Changed(event_name, source)

	-- Tables use one-based indexing while the selection boxes use zero-based
	local selected_index = this.List_Box_Resolutions.Get_Selected_Row_Index() + 1
	local res = Resolutions[selected_index]

	-- I have recieved some false positives so I have to do this check
	if Settings.Screen_Width ~= res.Resolution.Width or
		Settings.Screen_Height ~= res.Resolution.Height or
		Settings.Screen_Refresh ~= res.Resolution.Refresh then
		Settings_Changed()
		Settings.Screen_Width = res.Resolution.Width
		Settings.Screen_Height = res.Resolution.Height
		Settings.Screen_Refresh = res.Resolution.Refresh

		-- SKY 08/02/2007 - check for widescreen resolutions, use 1.5 as a threshold (greater than 4/3 and less than 16/10)
		local selected_ratio = Settings.Screen_Width / Settings.Screen_Height
		if(selected_ratio > 1.5) then
			Settings.Widescreen_Enabled = true
		else
			Settings.Widescreen_Enabled = false
		end
	end	
end

function Gamma_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	local gamma = _slider_to_gamma(this.Slider_Bar_Gamma.Get_Current_Step_Index())
	if Settings.Gamma ~= gamma then
		Settings_Changed()
		VideoSettingsManager.Set_Gamma(gamma)
		
		-- Update text
		Update_Text()
	end
end

function Detail_Level_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Simple_Detail_Level ~= this.Slider_Bar_Detail_Level.Get_Current_Step_Index() then
		Settings_Changed()
		Settings.Detail_Slider_Changed = true
		Settings.Simple_Detail_Level = this.Slider_Bar_Detail_Level.Get_Current_Step_Index()
		
		-- Update text
		Update_Text()
	end
end

function Anti_Aliasing_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.AA_Level ~= this.Slider_Bar_Anti_Aliasing.Get_Current_Step_Index() then
		Settings_Changed()
		AAModified = true
		Settings.AA_Level = this.Slider_Bar_Anti_Aliasing.Get_Current_Step_Index()
		
		-- Update_Text
		Update_Text()
	end
end

function _gamma_to_slider(gamma)
	local slider = (gamma - MIN_GAMMA) / (MAX_GAMMA - MIN_GAMMA)
	return Clamp(slider,0,1) * GAMMA_STEPS
end

function _slider_to_gamma(slider_index)
	return MIN_GAMMA + (slider_index / GAMMA_STEPS) * (MAX_GAMMA - MIN_GAMMA)
end

function Confirm_Callback(button)
	if button == 3 then
		-- Manually need to reset gamma (since it isn't part of the video settings structure) 
		VideoSettingsManager.Set_Gamma(Original_Gamma)
		
		-- If the user changed the simple detail level, need to force it back to original settings too
		-- Set the settings using 'Advanced_Details_Changed' so that if the settings were customized, we revert
		-- back to the customized settings.  If the settings were a default set, they should still revert properly too.
		if OriginalSettings.Simple_Detail_Level ~= Settings.Simple_Detail_Level then
			OriginalSettings.Advanced_Details_Changed = true
		end
		
		Apply_Settings(OriginalSettings)
		Display_Dialog()
	else
		-- SKY 08/30/2007 - display a dialog if the DirectX version or AA changed
		if DX10Modified == true then
			DX10Mofified = false
			Spawn_Dialog_Box(DXChanged_Dialog_Params)
		elseif AAModified == true and OriginalSettings.Original_Driver_Type == DRIVER_TYPE_DX10 then
			AAModified = false
			Spawn_Dialog_Box(AAChanged_Dialog_Params)
		elseif OkayButtonClicked then
			Hide_Dialog()
		end
	end
end

function Update_Text()
	-- Anti-aliasing slider
	local index = this.Slider_Bar_Anti_Aliasing.Get_Current_Step_Index() + 1
	this.Text_AA_Level.Set_Text(Settings.AA_Descriptions[index])

	-- Detail slider
	if Settings.Simple_Detail_Level == 0 then
		this.Text_Detail_Level_Level.Set_Text(Get_Game_Text("TEXT_VERYLOW"))
	elseif Settings.Simple_Detail_Level == 1 then
		this.Text_Detail_Level_Level.Set_Text(Get_Game_Text("TEXT_LOW"))
	elseif Settings.Simple_Detail_Level == 2 then
		this.Text_Detail_Level_Level.Set_Text(Get_Game_Text("TEXT_MEDIUM"))
	elseif Settings.Simple_Detail_Level == 3 then
		this.Text_Detail_Level_Level.Set_Text(Get_Game_Text("TEXT_HIGH"))
	elseif Settings.Simple_Detail_Level == 4 then
		this.Text_Detail_Level_Level.Set_Text(Get_Game_Text("TEXT_VERYHIGH"))
	end
	
	-- Gamma slider
	local gamma = _slider_to_gamma(this.Slider_Bar_Gamma.Get_Current_Step_Index())
	local percentage_text = ""
	if gamma < 1 then
		percentage_text = "-" .. string.format("%.1f", (1 - gamma) * 100) .. "%";
	else
		percentage_text = "+" .. string.format("%.1f", (gamma - 1) * 100) .. "%";
	end
	this.Text_Gamma_Level.Set_Text(percentage_text)
end

-------------------------------------------------------------------------------
-- Esc_Pressed
-------------------------------------------------------------------------------
function Esc_Pressed()
	--Only respond to Esc if we're not part of the in-game dialog stack - in that
	--case Esc is handled elsewhere
	local user_data = this.Get_User_Data()
	if not user_data or not TestValid(user_data.Parent_Dialog) then
		Cancel_Clicked()
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
	Commit_Profile_Values = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
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
