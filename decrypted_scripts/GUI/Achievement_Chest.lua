LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Achievement_Chest.lua#25 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Achievement_Chest.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #25 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGColors")
require("PGPlayerProfile")
require("PGAchievementsCommon")
require("Achievement_Common")
require("PGOnlineAchievementDefs")
require("PGFactions")
require("PGNetwork")
require("PGCrontab")
require("Lobby_Network_Logic")		-- For retriving XLive achievement data.
require("Common_Achievement_Chest")


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Init()

	MCCommon_On_Init()
	-- Tab order.
	Achievement_Display.Button_Back.Set_Tab_Order(Declare_Enum(0))
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()
	MCCommon_On_Update()
end

------------------------------------------------------------------------
-- On_Mouse_Over_Button - Play SFX response
------------------------------------------------------------------------
function On_Mouse_Over_Button(event, source)
	MCCommon_On_Mouse_Over_Button(event, source)
end

------------------------------------------------------------------------
-- On_Button_Pushed - Play SFX response
------------------------------------------------------------------------
function On_Button_Pushed(event, source)
	MCCommon_On_Button_Pushed(event, source)
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Close_Dialog(event, source, key)
	MCCommon_Close_Dialog(event, source, key)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	MCCommon_On_Component_Shown()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	MCCommon_Cleanup_Dialog()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_All_Clicked()
	MCCommon_On_All_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Novus_Clicked()
	MCCommon_On_Novus_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Alien_Clicked()
	MCCommon_On_Alien_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Masari_Clicked()
	MCCommon_On_Masari_Clicked()
end

-------------------------------------------------------------------------------
-- Back button
-------------------------------------------------------------------------------
function On_Back_Clicked(event_name, source)
	MCCommon_On_Back_Clicked(event_name, source)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_Gained(event, source, key)
	MCCommon_On_Focus_Gained(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_Lost(event, source, key)
	MCCommon_On_Focus_Lost(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Button_Ranked_Clicked()
	MCCommon_On_Button_Ranked_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Button_Unranked_Clicked()
	MCCommon_On_Button_Unranked_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Mouseover(event, source, key)
	MCCommon_On_Medal_Mouseover(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Mouseout(event, source, key)
	MCCommon_On_Medal_Mouseout(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Clicked(event, source, key)
	MCCommon_On_Medal_Clicked(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Buff_Primary_Mouse_Up(event, source, key)
	MCCommon_On_Buff_Primary_Mouse_Up(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Buff_Drop(event, source, key)
	MCCommon_On_Buff_Drop(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Applied_Quad_Drop(event, source, key)
	MCCommon_On_Applied_Quad_Drop(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Primary_Mouse_Down(event, source, key)
	MCCommon_On_Medal_Primary_Mouse_Down(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Buff_Mouse_Down(event, source, key)
	MCCommon_Medal_Buff_Mouse_Down(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Click() 
	MCCommon_Play_Click() 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Alien_Steam() 
	MCCommon_Play_Alien_Steam() 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Prepare_Fadeout()
	MCCommon_Prepare_Fadeout()
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()
	MCCommon_On_YesNoOk_Yes_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_YesNoOk_Ok_Clicked()
	MCCommon_On_YesNoOk_Ok_Clicked()
end

-------------------------------------------------------------------------------
-- Called when the backend has our achievement data ready for us.
-- Note that this call clobbers the OnlineAchievementsModel with status values
-- from the backend!
-------------------------------------------------------------------------------
function On_Enumerate_Achievements(event)
	MCCommon_On_Enumerate_Achievements(event)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Query_Medals_Progress_Stats(event)
	MCCommon_On_Query_Medals_Progress_Stats(event)
end	


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Showing()
	return MCCommon_Is_Showing()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Showing = Is_Showing

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
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	Create_Base_Boolean_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Is_Player_Of_Faction = nil
	MCCommon_Is_Achievement_Applied = nil
	MCCommon_On_Medal_Buff_Mouse_Down = nil
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
	Network_Get_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	Network_Kick_Player = nil
	Network_Refuse_Player = nil
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	OutputDebug = nil
	PGLobby_Activate_Movies = nil
	PGLobby_Begin_Stats_Registration = nil
	PGLobby_Convert_Faction_IDs_To_Strings = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Create_Session = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Generate_Map_Selection_Model = nil
	PGLobby_Get_Preferred_Color = nil
	PGLobby_Is_Game_Joinable = nil
	PGLobby_Keepalive_Close_Bracket = nil
	PGLobby_Keepalive_Open_Bracket = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Mouse_Move = nil
	PGLobby_Passivate_Movies = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Refresh_Available_Games = nil
	PGLobby_Request_All_Medals_Progress_Stats = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Request_Global_Conquest_Properties = nil
	PGLobby_Request_Stats_Registration = nil
	PGLobby_Reset = nil
	PGLobby_Restart_Networking = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Player_Solid_Color = nil
	PGLobby_Set_Tooltip_Model = nil
	PGLobby_Start_Heartbeat = nil
	PGLobby_Stop_Heartbeat = nil
	PGLobby_Update_NAT_Warning_State = nil
	PGLobby_Update_Player_Count = nil
	PGLobby_Validate_Client_Medals = nil
	PGLobby_Validate_Local_Session_Data = nil
	PGLobby_Validate_NAT_Type = nil
	PGNetwork_Clear_Start_Positions = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Prepare_Fadeout = nil
	Prune_Unachieved_Achievements = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Restore_Model_State = nil
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
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	Kill_Unused_Global_Functions = nil
end
