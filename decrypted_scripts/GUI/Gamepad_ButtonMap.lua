if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[80] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_ButtonMap.lua#12 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_ButtonMap.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")


function On_Init()

	this.Register_Event_Handler("Controller_A_Button_Up", nil, Accept_Clicked)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Cancel_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Cancel_Clicked)
	this.Register_Event_Handler("Closing_All_Displays", nil, Esc_Pressed)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, Default_Clicked)
		
	Register_Gameplay_Commands()

	this.ScrollSpeedSlider.Set_Steps(SCROLL_SLIDERBAR_STEPS)
	
	this.MagnetismCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_MAGNETISM_STRONG"))
	this.MagnetismCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_MAGNETISM_MEDIUM"))
	this.MagnetismCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_MAGNETISM_SLIGHT"))
	--I know the text ID says VIBRATION_OFF, but we're using the same entry for magnetism
	this.MagnetismCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_VIBRATION_OFF"))

	this.VibrationCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_VIBRATION_ALL"))
	this.VibrationCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_VIBRATION_AMBIENT"))
	this.VibrationCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_VIBRATION_ALERTS"))
	this.VibrationCombo.Add_Item(Get_Game_Text("TEXT_GAMEPAD_VIBRATION_OFF"))
	
	this.ScrollSpeedSlider.Set_Tab_Order(Declare_Enum(0))
	this.MagnetismCombo.Set_Tab_Order(Declare_Enum())
	this.VibrationCombo.Set_Tab_Order(Declare_Enum())	
	
	On_Show_Dialog()
end

function Hide_Dialog()

	Commit_Profile_Values()

	GUI_Dialog_Raise_Parent()
	
end

function On_Show_Dialog()

	PGPlayerProfile_Init()

	-- Grab the original settings in case the user wants to cancel
	Settings = GameplaySettingsManager.Get_Current_Settings()
	this.ScrollSpeedSlider.Set_Current_Step_Index(Settings.Scroll_Speed)
	if Settings.ControllerMagnetismLevel == MAGNETISM_STRONG then	
		this.MagnetismCombo.Set_Selected_Index(0)
	elseif Settings.ControllerMagnetismLevel == MAGNETISM_SLIGHT then
		this.MagnetismCombo.Set_Selected_Index(2)
	elseif Settings.ControllerMagnetismLevel == MAGNETISM_NONE then
		this.MagnetismCombo.Set_Selected_Index(3)		
	else
		this.MagnetismCombo.Set_Selected_Index(1)
	end
	
	if Settings.ControllerAmbientVibration and Settings.ControllerNotificationVibration then
		this.VibrationCombo.Set_Selected_Index(0)
	elseif Settings.ControllerAmbientVibration then
		this.VibrationCombo.Set_Selected_Index(1)
	elseif Settings.ControllerNotificationVibration then
		this.VibrationCombo.Set_Selected_Index(2)
	else
		this.VibrationCombo.Set_Selected_Index(3)
	end
	
	DisplayTime = GetCurrentRealTime()
		
	this.Focus_First()
end

function On_Hide_Dialog()
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Gamepad_ButtonMap"})
end

-------------------------------------------------------------------------------
-- Accept_Clicked
-------------------------------------------------------------------------------
function Accept_Clicked()
	if ( DisplayTime + 1 > GetCurrentRealTime() ) then
		return
	end

	Settings.Scroll_Speed = this.ScrollSpeedSlider.Get_Current_Step_Index()
	
	local magnetism_index = this.MagnetismCombo.Get_Selected_Index()
	if magnetism_index == 0 then
		Settings.ControllerMagnetismLevel = MAGNETISM_STRONG
	elseif magnetism_index == 2 then
		Settings.ControllerMagnetismLevel = MAGNETISM_SLIGHT
	elseif magnetism_index == 3 then
		Settings.ControllerMagnetismLevel = MAGNETISM_NONE	
	else
		Settings.ControllerMagnetismLevel = MAGNETISM_MEDIUM	
	end
	
	local vibration_index = this.VibrationCombo.Get_Selected_Index()
	if vibration_index == 0 then
		Settings.ControllerAmbientVibration = true
		Settings.ControllerNotificationVibration = true
	elseif vibration_index == 1 then
		Settings.ControllerAmbientVibration = true		
		Settings.ControllerNotificationVibration = false
	elseif vibration_index == 2 then
		Settings.ControllerAmbientVibration = false
		Settings.ControllerNotificationVibration = true
	else
		Settings.ControllerAmbientVibration = false
		Settings.ControllerNotificationVibration = false
	end	
	
	GameplaySettingsManager.Apply(Settings)
	
	Hide_Dialog()
end

function Default_Clicked(event_name, source)
	this.ScrollSpeedSlider.Set_Current_Step_Index(2)
	this.VibrationCombo.Set_Selected_Index(0)
	this.MagnetismCombo.Set_Selected_Index(1)
end

-------------------------------------------------------------------------------
-- Cancel_Clicked
-------------------------------------------------------------------------------
function Cancel_Clicked()
	if ( DisplayTime + 1 > GetCurrentRealTime() ) then
		return
	end

	Hide_Dialog()
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
	Clamp = nil
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
