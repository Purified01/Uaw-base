if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Mission_Difficulty_Dialog.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Mission_Difficulty_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Joe_Howes $
--
--            $Change: 92970 $
--
--          $DateTime: 2008/02/08 16:20:47 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")
require("Campaign_Missions_Data")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

------------------------------------------------------------------------
-- On_Init
------------------------------------------------------------------------
function On_Init()

	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Player_Set_Difficulty)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Difficulty, Play_Option_Select_SFX)
	
	-- Initialize the Difficulty combo
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_EASY_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_NORMAL_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_HARD_NAME"))
	
	-- Tab order
	this.Combo_Difficulty.Set_Tab_Order(0)
		
	Display_Dialog()
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	Play_SFX_Event("GUI_Main_Menu_Options_Select")
end

------------------------------------------------------------------------
-- Display_Dialog
------------------------------------------------------------------------
function Display_Dialog()
	Clear_Key_Focus()
	-- Make sure the combo box has focus!.
	--this.Focus_First()
	
	--Default to the difficulty set in the player profile.
	this.Combo_Difficulty.Set_Selected_Index(Get_Difficulty())

	this.Combo_Difficulty.Set_Key_Focus()
end

------------------------------------------------------------------------
-- Hide_Dialog
------------------------------------------------------------------------
function Hide_Dialog(_, source)
	this.End_Modal()
end

------------------------------------------------------------------------
-- Player_Set_Difficulty
------------------------------------------------------------------------
function Player_Set_Difficulty()
	-- The player has chosen a difficulty level so return and pass the 
	-- selected value to the parent scene.
	this.End_Modal(this.Combo_Difficulty.Get_Selected_Index())
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
	Commit_Profile_Values = nil
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
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Init_Campaign_Missions_Data = nil
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
