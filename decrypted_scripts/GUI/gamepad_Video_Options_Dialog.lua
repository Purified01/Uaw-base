if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[79] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Video_Options_Dialog.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Video_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
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
	
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Cancel_Clicked)


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

	RESOLUTION = Create_Wide_String("RESOLUTION")

	-- Specify the column for the list box
	this.List_Box_Resolutions.Set_Header_Style("NONE")
	this.List_Box_Resolutions.Add_Column(RESOLUTION, JUSTIFY_LEFT)
	this.List_Box_Resolutions.Refresh()

	Dialog_Box_Common_Init()
	Revert_Callback_Params = {}
	Revert_Callback_Params.script = Script
	Revert_Callback_Params.callback = "Confirm_Callback"

	PGColors_Init()

	-- Setup the slider bars
	GAMMA_STEPS = 100
	this.Slider_Bar_Gamma.Set_Steps(GAMMA_STEPS-1)
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

	SettingsModified = false
	Settings.Detail_Slider_Changed = false

	this.Text_Video_Card.Set_Text(Settings.Device_Description)

	this.Slider_Bar_Anti_Aliasing.Set_Steps(Settings.Num_AA_Levels-1)
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
			this.Text_Gamma_Low.Set_Hidden(true)
			this.Text_Gamma_Max.Set_Hidden(true)
			this.Slider_Bar_Gamma.Set_Hidden(true)
		else
			-- In case this was hidden in a previous Display_Dialog call
			this.Text_Gamma.Set_Hidden(false)
			this.Text_Gamma_Low.Set_Hidden(false)
			this.Text_Gamma_Max.Set_Hidden(false)
			this.Slider_Bar_Gamma.Set_Hidden(false)
		end
	end

	Highlight_Current_Resolution()
	OkayButtonClicked = false

	-- Apply starts out hidden until a setting is changed
	this.Button_Apply.Set_Hidden(true)
end

function Highlight_Current_Resolution()
	for _, res in pairs(Resolutions) do
		if res.Resolution.Width == Settings.Screen_Width and
			res.Resolution.Refresh == Settings.Screen_Refresh and
			res.Resolution.Height == Settings.Screen_Height then

			HighlightedEntry = res
			this.List_Box_Resolutions.Set_Selected_Row_Index(res.Row_ID)
			this.List_Box_Resolutions.Set_Row_Background(res.Row_ID, 25)

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
	Commit_Profile_Values()
	GUI_Dialog_Raise_Parent()
end

function Auto_Detect_Clicked(event_name, source)
	local gamma_index = _gamma_to_slider(1)
	this.Slider_Bar_Gamma.Set_Current_Step_Index(gamma_index)

	local recommended_settings = VideoSettingsManager.Get_Recommended_Settings()
	this.Slider_Bar_Anti_Aliasing.Set_Current_Step_Index(recommended_settings.AA_Level)
	this.Slider_Bar_Detail_Level.Set_Current_Step_Index(recommended_settings.Simple_Detail_Level)

	Settings.Vsync_Enabled = false
	this.Checkbox_Vsync.Set_Checked(false)

	if not BETA_BUILD and not GOLD_BUILD then
		Settings.Windowed_Enabled = false
		this.Checkbox_Windowed.Set_Checked(false)
	end

	Settings.Screen_Width = recommended_settings.Screen_Width 
	Settings.Screen_Height = recommended_settings.Screen_Height 
	Settings.Screen_Refresh = recommended_settings.Screen_Refresh 

	Highlight_Current_Resolution(recommended_settings)
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
			Settings.Widescreen_Enabled = true;
		else
			Settings.Widescreen_Enabled = false;
		end
	end	
end

function Gamma_Selection_Changed(event_name, source)
	Settings_Changed()
	local gamma = _slider_to_gamma(this.Slider_Bar_Gamma.Get_Current_Step_Index())
	VideoSettingsManager.Set_Gamma(gamma)
end

function Detail_Level_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.Simple_Detail_Level ~= this.Slider_Bar_Detail_Level.Get_Current_Step_Index() then
		Settings_Changed()
		Settings.Detail_Slider_Changed = true
		Settings.Simple_Detail_Level = this.Slider_Bar_Detail_Level.Get_Current_Step_Index()
	end
end

function Anti_Aliasing_Selection_Changed(event_name, source)
	-- I have recieved some false positives so I have to do this check
	if Settings.AA_Level ~= this.Slider_Bar_Anti_Aliasing.Get_Current_Step_Index() then
		Settings_Changed()
		Settings.AA_Level = this.Slider_Bar_Anti_Aliasing.Get_Current_Step_Index()
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
		Apply_Settings(OriginalSettings)
		Display_Dialog()
	elseif OkayButtonClicked then
		Hide_Dialog()
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
