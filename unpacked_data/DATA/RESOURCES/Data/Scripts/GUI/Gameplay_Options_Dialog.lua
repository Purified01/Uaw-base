-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gameplay_Options_Dialog.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gameplay_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: James_Yarrow $
--
--            $Change: 85634 $
--
--          $DateTime: 2007/10/06 12:50:31 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")
require("PGHintSystem")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()

	PGHintSystem_Init()
	
	-- register required event handlers
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)

	this.Register_Event_Handler("Button_Clicked", this.Button_Accept, Accept_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Cancel_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Default, Default_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Reset_Hints, On_Reset_Hints_Clicked)
	

	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Edge_Scroll, Toggle_Edge_Scroll)
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Absolute_Scroll, Toggle_Absolute_Scroll)
	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Disable_Hints, Toggle_Hints)
--	this.Register_Event_Handler("Custom_Checkbox_Clicked", this.Checkbox_Alternate_Control, Toggle_Alternate_Control)

	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Tactical_Game_Speed, Tactical_Game_Speed_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Tactical_Game_Speed, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Strategic_Game_Speed, Strategic_Game_Speed_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Strategic_Game_Speed, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Scroll_Speed, Scroll_Speed_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Scroll_Speed, Play_Option_Select_SFX)

	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Difficulty, Difficulty_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Difficulty, Play_Option_Select_SFX)

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

	-- Get the GameplaySettingsManager object
	Register_Gameplay_Commands()

	-- Setup the slider bars
	this.Slider_Bar_Tactical_Game_Speed.Set_Steps(MAX_SPEED_SETTING)
	this.Slider_Bar_Strategic_Game_Speed.Set_Steps(MAX_SPEED_SETTING)
	this.Slider_Bar_Scroll_Speed.Set_Steps(SCROLL_SLIDERBAR_STEPS)

	-- Initialize the Difficulty combo
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_EASY_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_NORMAL_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_HARD_NAME"))

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
	-- Grab the original settings in case the user wants to cancel
	Settings = GameplaySettingsManager.Get_Current_Settings()

	this.Checkbox_Edge_Scroll.Set_Checked(not Settings.Edge_Scroll_Enabled)
	this.Checkbox_Absolute_Scroll.Set_Checked(Settings.Absolute_Scroll_Enabled)
	this.Checkbox_Disable_Hints.Set_Checked(not Get_Profile_Value(PP_HINT_SYSTEM_ENABLED, true))

	this.Slider_Bar_Tactical_Game_Speed.Set_Current_Step_Index(Settings.Tactical_Game_Speed)
	this.Slider_Bar_Strategic_Game_Speed.Set_Current_Step_Index(Settings.Strategic_Game_Speed)
	this.Slider_Bar_Scroll_Speed.Set_Current_Step_Index(Settings.Scroll_Speed)

	Set_Speed_Slider_Enabled_State()
	
	--Default to normal difficulty
	this.Combo_Difficulty.Set_Selected_Index(Get_Current_Difficulty())
	
	local allow_difficulty = Is_Campaign_Game()
	this.Combo_Difficulty.Set_Hidden(not allow_difficulty)
	this.Text_Difficulty.Set_Hidden(not allow_difficulty)	
	
	Set_Speed_Slider_Enabled_State()
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
end

function Default_Clicked(event_name, source)
	if this.Slider_Bar_Tactical_Game_Speed.Is_Enabled() then
		this.Slider_Bar_Tactical_Game_Speed.Set_Current_Step_Index(DEFAULT_SPEED_SETTING)
	end
	
	if this.Slider_Bar_Strategic_Game_Speed.Is_Enabled() then
		this.Slider_Bar_Strategic_Game_Speed.Set_Current_Step_Index(DEFAULT_SPEED_SETTING)
	end
	
	this.Slider_Bar_Scroll_Speed.Set_Current_Step_Index(DEFAULT_SCROLL_SETTING)

	Settings.Edge_Scroll_Enabled = true
	this.Checkbox_Edge_Scroll.Set_Checked(not Settings.Edge_Scroll_Enabled)

	Settings.Absolute_Scroll_Enabled = true
	this.Checkbox_Absolute_Scroll.Set_Checked(Settings.Absolute_Scroll_Enabled)
	
	this.Checkbox_Disable_Hints.Set_Checked(false)	
	
	this.Combo_Difficulty.Set_Selected_Index(1)	
end

function Cancel_Clicked(event_name, source)
	Hide_Dialog()
end

function Accept_Clicked(event_name, source)
	--Make sure not to apply settings for disabled speed sliders.
	if not this.Slider_Bar_Tactical_Game_Speed.Is_Enabled() then
		Settings.Tactical_Game_Speed = nil
	end
	
	if not this.Slider_Bar_Strategic_Game_Speed.Is_Enabled() then
		Settings.Strategic_Game_Speed = nil
	end

	GameplaySettingsManager.Apply(Settings)
	Set_Hint_System_Enabled(not this.Checkbox_Disable_Hints.Is_Checked())
	
	if Is_Campaign_Game() then
		Set_Campaign_Difficulty(Difficulty)		
	end
	
	Hide_Dialog()
end

function Toggle_Edge_Scroll(event_name, source)
	Settings.Edge_Scroll_Enabled = not Settings.Edge_Scroll_Enabled
	this.Checkbox_Edge_Scroll.Set_Checked(not Settings.Edge_Scroll_Enabled)
end

function Toggle_Absolute_Scroll(event_name, source)
	Settings.Absolute_Scroll_Enabled = not Settings.Absolute_Scroll_Enabled
	this.Checkbox_Absolute_Scroll.Set_Checked(Settings.Absolute_Scroll_Enabled)
end

function Tactical_Game_Speed_Selection_Changed(event_name, source)
	Settings.Tactical_Game_Speed = this.Slider_Bar_Tactical_Game_Speed.Get_Current_Step_Index()
end

function Strategic_Game_Speed_Selection_Changed(event_name, source)
	Settings.Strategic_Game_Speed = this.Slider_Bar_Strategic_Game_Speed.Get_Current_Step_Index()
end

function Scroll_Speed_Selection_Changed(event_name, source)
	Settings.Scroll_Speed = this.Slider_Bar_Scroll_Speed.Get_Current_Step_Index()
end

function Set_Speed_Slider_Enabled_State()
	local is_story_campaign = Is_Campaign_Game() and not Get_Game_Mode_Script().Get_Async_Data("IsScenarioCampaign")
	local should_enable = GameplaySettingsManager.Can_Change_Game_Speed() and not is_story_campaign
	this.Slider_Bar_Tactical_Game_Speed.Enable(should_enable)
	this.Slider_Bar_Strategic_Game_Speed.Enable(should_enable)
end

function On_Update()
	Set_Speed_Slider_Enabled_State()
end

function On_Reset_Hints_Clicked()
	Clear_Hint_Tracking_Map()
end

function Toggle_Hints()
	this.Checkbox_Disable_Hints.Set_Checked(not this.Checkbox_Disable_Hints.Is_Checked())
end

-------------------------------------------------------------------------------
-- Difficulty combo
-------------------------------------------------------------------------------
function Difficulty_Combo_Selection_Changed(event, source)

	if not Is_Campaign_Game() then
		--Can only change difficulty in SP campaign
		return
	end

	local index = this.Combo_Difficulty.Get_Selected_Index()
	Difficulty = "Difficulty_Normal"
	if index == 0 then
		Difficulty = "Difficulty_Easy"
	elseif index == 2 then 
		Difficulty = "Difficulty_Hard"
	end
end

function Get_Current_Difficulty()
	if not Is_Campaign_Game() then
		--Can only change difficulty in SP campaign
		return 1
	end
	
	Difficulty = Get_Campaign_Difficulty()
	
	if Difficulty == "Difficulty_Easy" then
		return 0
	elseif Difficulty == "Difficulty_Normal" then
		return 1
	elseif Difficulty == "Difficulty_Hard" then
		return 2
	end
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
