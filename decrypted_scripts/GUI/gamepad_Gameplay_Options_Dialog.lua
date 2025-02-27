if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[14] = true
LuaGlobalCommandLinks[80] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Gameplay_Options_Dialog.lua#22 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Gameplay_Options_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Maria_Teruel $
--
--            $Change: 92645 $
--
--          $DateTime: 2008/02/06 16:43:59 $
--
--          $Revision: #22 $
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

	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Tactical_Game_Speed, Tactical_Game_Speed_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Tactical_Game_Speed, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Slider_Bar_Value_Changed", this.Slider_Bar_Strategic_Game_Speed, Strategic_Game_Speed_Selection_Changed)
	-- Maria 06.12.2007 - needed for SFX response
	this.Register_Event_Handler("Slider_Bar_Released", this.Slider_Bar_Strategic_Game_Speed, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Difficulty, Difficulty_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Difficulty, Play_Option_Select_SFX)

	this.Register_Event_Handler("Controller_A_Button_Up", nil, Accept_Clicked)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Cancel_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Cancel_Clicked)
	this.Register_Event_Handler("Closing_All_Displays", nil, Esc_Pressed)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, Default_Clicked)
	this.Register_Event_Handler("Controller_Y_Button_Up", nil, On_Reset_Hints_Clicked)
	
	-- Get the GameplaySettingsManager object
	Register_Gameplay_Commands()

	-- Setup the slider bars
	this.Slider_Bar_Tactical_Game_Speed.Set_Steps(MAX_SPEED_SETTING)
	this.Slider_Bar_Strategic_Game_Speed.Set_Steps(MAX_SPEED_SETTING)

	-- Initialize the Difficulty combo
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_EASY_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_NORMAL_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_HARD_NAME"))
	
	this.Combo_Box_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_DISABLED"))
	this.Combo_Box_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_SHORT"))
	this.Combo_Box_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_MEDIUM"))
	this.Combo_Box_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_LONG"))
	
	this.Combo_Box_Expanded_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_DISABLED"))
	this.Combo_Box_Expanded_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_SHORT"))
	this.Combo_Box_Expanded_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_MEDIUM"))
	this.Combo_Box_Expanded_Tooltip_Delay.Add_Item(Get_Game_Text("TEXT_GAMEPAD_DELAY_LONG"))
	
	local w_enable_string = Get_Game_Text("TEXT_ENABLED")
	local w_disable_string = Get_Game_Text("TEXT_DISABLED")

	this.Combo_Box_Hints_Enable_Diable.Add_Item(w_enable_string)
	this.Combo_Box_Hints_Enable_Diable.Add_Item(w_disable_string)
	
	this.Slider_Bar_Tactical_Game_Speed.Set_Tab_Order(Declare_Enum())
	this.Slider_Bar_Strategic_Game_Speed.Set_Tab_Order(Declare_Enum())
	this.Combo_Difficulty.Set_Tab_Order(Declare_Enum())
	this.Combo_Box_Tooltip_Delay.Set_Tab_Order(Declare_Enum())
	this.Combo_Box_Expanded_Tooltip_Delay.Set_Tab_Order(Declare_Enum())
	this.Combo_Box_Hints_Enable_Diable.Set_Tab_Order(Declare_Enum())

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


------------------------------------------------------------------------
-- Display_Dialog
------------------------------------------------------------------------
function Display_Dialog()

	PGPlayerProfile_Init()

	-- Grab the original settings in case the user wants to cancel
	Settings = GameplaySettingsManager.Get_Current_Settings()
	
	Original_Tooltip_Delay = Get_Profile_Value(PP_TOOLTIP_HINT_DELAY, .5)
	Original_Expanded_Tooltip_Delay = Get_Profile_Value(PP_TOOLTIP_EXPANDED_HINT_DELAY, 1.5)
	
	local ttd = (Math.floor(Original_Tooltip_Delay))+1
	this.Combo_Box_Tooltip_Delay.Set_Selected_Index(ttd)
	local ettd = (Math.floor(Original_Expanded_Tooltip_Delay))+1
	this.Combo_Box_Expanded_Tooltip_Delay.Set_Selected_Index(ettd)

	hints_enabled = Get_Profile_Value(PP_HINT_SYSTEM_ENABLED, true)
	if ( hints_enabled ) then
		this.Combo_Box_Hints_Enable_Diable.Set_Selected_Index(0)
	else
		this.Combo_Box_Hints_Enable_Diable.Set_Selected_Index(1)
	end

	this.Slider_Bar_Tactical_Game_Speed.Set_Current_Step_Index(Settings.Tactical_Game_Speed)
	this.Slider_Bar_Strategic_Game_Speed.Set_Current_Step_Index(Settings.Strategic_Game_Speed)

	Set_Speed_Slider_Enabled_State()
	
	--Default to normal difficulty
	this.Combo_Difficulty.Set_Selected_Index(Settings.Difficulty)
	
	--Allow difficulty modification at the main menu and during campaign games
	local allow_difficulty = Is_Campaign_Game() or Get_Game_Mode_Script() == nil
	this.Combo_Difficulty.Set_Hidden(not allow_difficulty)
	this.Text_Difficulty.Set_Hidden(not allow_difficulty)	
	
	if allow_difficulty then
		this.Reset_Hints_Txt.Set_Hidden(false)
		this.Button_Y.Set_Hidden(false)
		this.Combo_Box_Hints_Enable_Diable.Set_Hidden(false)	
		this.Text_Hints_Enable_Diable.Set_Hidden(false)
	else
		this.Reset_Hints_Txt.Set_Hidden(true)
		this.Button_Y.Set_Hidden(true)
		this.Combo_Box_Hints_Enable_Diable.Set_Hidden(true)	
		this.Text_Hints_Enable_Diable.Set_Hidden(true)
	end
	
	Set_Speed_Slider_Enabled_State()
	this.Focus_First()
	
	DisplayTime = GetCurrentRealTime()

end


------------------------------------------------------------------------
-- Hide_Dialog
------------------------------------------------------------------------
function Hide_Dialog()
	Commit_Profile_Values()

	GUI_Dialog_Raise_Parent()
	
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Gameplay_Options_Dialog"})
	if ( TestValid( Get_Game_Mode_GUI_Scene() ) ) then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Tooltip_Delay_Reload_Needed", nil, false)
	end
end

------------------------------------------------------------------------
-- Default_Clicked
------------------------------------------------------------------------
function Default_Clicked(event_name, source)
	if this.Slider_Bar_Tactical_Game_Speed.Is_Enabled() then
		this.Slider_Bar_Tactical_Game_Speed.Set_Current_Step_Index(DEFAULT_SPEED_SETTING)
	end
	
	if this.Slider_Bar_Strategic_Game_Speed.Is_Enabled() then
		this.Slider_Bar_Strategic_Game_Speed.Set_Current_Step_Index(DEFAULT_SPEED_SETTING)
	end
	
	Settings.Edge_Scroll_Enabled = true
	Settings.Absolute_Scroll_Enabled = true
	Settings.Difficulty = Difficulty_Normal
	this.Combo_Difficulty.Set_Selected_Index(Settings.Difficulty)	
	
	this.Combo_Box_Tooltip_Delay.Set_Selected_Index(1)
	this.Combo_Box_Expanded_Tooltip_Delay.Set_Selected_Index(2)
	
	this.Combo_Box_Hints_Enable_Diable.Set_Selected_Index(0)
end


------------------------------------------------------------------------
-- Cancel_Clicked
------------------------------------------------------------------------
function Cancel_Clicked(event_name, source)
	if ( DisplayTime + 1 > GetCurrentRealTime() ) then
		return
	end

	Hide_Dialog()
end


------------------------------------------------------------------------
-- Accept_Clicked
------------------------------------------------------------------------
function Accept_Clicked(event_name, source)
	if ( DisplayTime + 1 > GetCurrentRealTime() ) then
		return
	end

	--Make sure not to apply settings for disabled speed sliders.
	if not this.Slider_Bar_Tactical_Game_Speed.Is_Enabled() then
		Settings.Tactical_Game_Speed = nil
	end
	
	if not this.Slider_Bar_Strategic_Game_Speed.Is_Enabled() then
		Settings.Strategic_Game_Speed = nil
	end

	if this.Combo_Difficulty.Get_Hidden() then
		Settings.Difficulty = nil
	end

	GameplaySettingsManager.Apply(Settings)

	new_Tooltip_Delay = this.Combo_Box_Tooltip_Delay.Get_Selected_Index()
	new_Expanded_Tooltip_Delay = this.Combo_Box_Expanded_Tooltip_Delay.Get_Selected_Index()
	
	Set_Profile_Value(PP_TOOLTIP_HINT_DELAY, (new_Tooltip_Delay-0.5))
	Set_Profile_Value(PP_TOOLTIP_EXPANDED_HINT_DELAY, (new_Expanded_Tooltip_Delay-0.5))
	
	if ( 0 == this.Combo_Box_Hints_Enable_Diable.Get_Selected_Index() ) then
		Set_Hint_System_Enabled(true)
	else
		Set_Hint_System_Enabled(false)
	end

	Commit_Profile_Values()
	Hide_Dialog()
end


------------------------------------------------------------------------
-- Toggle_Edge_Scroll
------------------------------------------------------------------------
function Toggle_Edge_Scroll(event_name, source)
	Settings.Edge_Scroll_Enabled = not Settings.Edge_Scroll_Enabled
	this.Checkbox_Edge_Scroll.Set_Checked(not Settings.Edge_Scroll_Enabled)
end


------------------------------------------------------------------------
-- Toggle_Absolute_Scroll
------------------------------------------------------------------------
function Toggle_Absolute_Scroll(event_name, source)
	Settings.Absolute_Scroll_Enabled = not Settings.Absolute_Scroll_Enabled
	this.Checkbox_Absolute_Scroll.Set_Checked(Settings.Absolute_Scroll_Enabled)
end


------------------------------------------------------------------------
-- Tactical_Game_Speed_Selection_Changed
------------------------------------------------------------------------
function Tactical_Game_Speed_Selection_Changed(event_name, source)
	Settings.Tactical_Game_Speed = this.Slider_Bar_Tactical_Game_Speed.Get_Current_Step_Index()
end


------------------------------------------------------------------------
-- Strategic_Game_Speed_Selection_Changed
------------------------------------------------------------------------
function Strategic_Game_Speed_Selection_Changed(event_name, source)
	Settings.Strategic_Game_Speed = this.Slider_Bar_Strategic_Game_Speed.Get_Current_Step_Index()
end

------------------------------------------------------------------------
-- Set_Speed_Slider_Enabled_State
------------------------------------------------------------------------
function Set_Speed_Slider_Enabled_State()
	if GameplaySettingsManager.Can_Change_Game_Speed() then
		this.Slider_Bar_Tactical_Game_Speed.Enable(true)
		this.Slider_Bar_Strategic_Game_Speed.Enable(true)
	else
		this.Slider_Bar_Tactical_Game_Speed.Enable(false)
		this.Slider_Bar_Strategic_Game_Speed.Enable(false)
	end
end


------------------------------------------------------------------------
-- On_Update
------------------------------------------------------------------------
function On_Update()
	Set_Speed_Slider_Enabled_State()
end

------------------------------------------------------------------------
-- On_Reset_Hints_Clicked
------------------------------------------------------------------------
function On_Reset_Hints_Clicked()
	this.Reset_Hints_Txt.Set_Hidden(true)
	this.Button_Y.Set_Hidden(true)
	Clear_Hint_Tracking_Map()
end

-------------------------------------------------------------------------------
-- Difficulty combo
-------------------------------------------------------------------------------
function Difficulty_Combo_Selection_Changed(event, source)

	if not Is_Campaign_Game() and Get_Game_Mode_Script() ~= nil then
		--Can only change difficulty in SP campaign
		return
	end

	Settings.Difficulty = this.Combo_Difficulty.Get_Selected_Index()
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

------------------------------------------------------------------------
-- Kill_Unused_Global_Functions
------------------------------------------------------------------------
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
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
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
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
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
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
	Notify_Attached_Hint_Created = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGNetwork_Clear_Start_Positions = nil
	PGNetwork_Init = nil
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_Achievement_Map_Type = nil
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
	Toggle_Absolute_Scroll = nil
	Toggle_Edge_Scroll = nil
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
