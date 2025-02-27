LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Global_Conquest_Lobby.lua#27 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Global_Conquest_Lobby.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 94288 $
--
--          $DateTime: 2008/02/28 15:20:35 $
--
--          $Revision: #27 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("Common_Global_Conquest_Lobby")


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Init()
	GCCommon_On_Init()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Register_Event_Handlers()

	GCCommon_Register_Event_Handlers()
	Global_Conquest_Lobby.Register_Event_Handler("Mouse_Move", nil, On_Mouse_Move)
	Global_Conquest_Lobby.Register_Event_Handler("Mouse_Right_Down", Global_Conquest_Lobby.Quad_Mouse_Event_Catcher, On_Mouse_Right_Down)	
	Global_Conquest_Lobby.Register_Event_Handler("Mouse_Right_Up", Global_Conquest_Lobby.Quad_Mouse_Event_Catcher, On_Mouse_Right_Up)
	
end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
-------------------------------------------------------------------------------
function Initialize_Components()
	GCCommon_Initialize_Components()
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Constants_Init()
	GCCommon_Constants_Init()
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Variables_Init()
	GCCommon_Variables_Init()
end

-------------------------------------------------------------------------------
-- This function should be called any time the lobby is to be re-initialized.
-------------------------------------------------------------------------------
function Variables_Reset()
	GCCommon_Variables_Reset()
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()
	return GCCommon_On_Update()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Main_Navigation_Visible(value)
	-- Do nothing ... gamepad really only worries about this.
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	GCCommon_On_Component_Shown()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Component_Hidden()
	GCCommon_On_Component_Hidden()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Back_Clicked()
	GCCommon_On_Back_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Closing_All_Displays()
	GCCommon_On_Closing_All_Displays()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Download_Dialog_Cancelled()
	GCCommon_On_Download_Dialog_Cancelled()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Novus_Clicked(event_name, source)
	GCCommon_On_Novus_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Alien_Clicked(event_name, source)
	GCCommon_On_Alien_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Masari_Clicked(event_name, source)
	GCCommon_On_Masari_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Launch_Game_Clicked()
	GCCommon_On_Launch_Game_Clicked()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI()

	GCCommon_Refresh_UI()

	-- Selected region tint.
	if (SelectedRegion ~= nil) then
		local shade_set = PG_GLOBAL_CONQUEST_SHADE_SETS[CurrentFaction]
		local tint = shade_set.SelectTint
		GCLobbyManager.Set_Region_Tint(SelectedRegion.Label, tint[1], tint[2], tint[3], tint[4])
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Scene_Mouse_Move(event, source, key)
	GCCommon_On_Scene_Mouse_Move(event, source, key)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Scene_Mouse_Up()
	GCCommon_On_Scene_Mouse_Up()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_My_Online_Profile_Clicked()

	GCCommon_On_My_Online_Profile_Clicked()
	Global_Conquest_Lobby.Achievement_Chest.Bring_To_Front()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Click() 
	GCCommon_Play_Click() 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Alien_Steam() 
	GCCommon_Play_Alien_Steam() 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Prepare_Fadeout()
	GCCommon_Prepare_Fadeout()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Mouse_Move(event, source)
	GCCommon_On_Mouse_Move(event, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Mouse_Right_Down(event, source)
	GCCommon_On_Mouse_Right_Down(event, source)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Mouse_Right_Up(event, source)
	GCCommon_On_Mouse_Right_Up(event, source)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Conquered_Globe_Reset_Flag(value)

	local flags = Get_Profile_Value(PP_LOBBY_RESET_CONQUERED_GLOBE, "")
	local user_id = Net.Get_Offline_XUID()
	
	-- If there is NO key stored, create a base one.
	if (flags == "") then
		flags = {}
	end
	
	-- If there is no key stored for the current user, plug one in.
	if (flags[user_id] == nil) then
		local curr_flags = {}
		curr_flags[PG_FACTION_NOVUS] = false
		curr_flags[PG_FACTION_ALIEN] = false
		curr_flags[PG_FACTION_MASARI] = false
		flags[user_id] = curr_flags
	end
	
	DebugMessage("LUA_GLOBAL_CONQUEST: Set globe reset flag for faction " .. tostring(CurrentFaction) .. ": " .. tostring(value))
	flags[user_id][CurrentFaction] = value
	Set_Profile_Value(PP_LOBBY_RESET_CONQUERED_GLOBE, flags)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Conquered_Globe_Reset_Flag()

	local flags = Get_Profile_Value(PP_LOBBY_RESET_CONQUERED_GLOBE, "")
	local user_id = Net.Get_Offline_XUID()
	
	if ((flags == "") or (flags[user_id] == nil)) then
		-- By default, we say no, the user has NOT chosen to reset the globe view.
		DebugMessage("LUA_GLOBAL_CONQUEST: No globe reset flags found in the registry.  Returning false.")
		return false
	end
	
	local value = flags[user_id][CurrentFaction]
	DebugMessage("LUA_GLOBAL_CONQUEST: Return globe reset flag for faction " .. tostring(CurrentFaction) .. ": " .. tostring(value))
	return value
		
end

-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Get_At_Cursor_Region_Tint(at_cursor_region, selected_region, shade_set)

	-- SEVERE COMPLICATION:
	-- Since we can only write to the backend in an arbitrated session, we will get into a
	-- state of "global conquer limbo" where the user has conquered the globe, all the regions have
	-- had their conquered status set to false, but the user may or may not want to be showing the
	-- globe as "conquered".  This aesthetic is supported by several flags which are explained when used.
	local regions_conquered_override = GCCommon_Get_Regions_Conquered_Override()
	
	local conquered_flag = at_cursor_region.ConqueredStatus
	if (regions_conquered_override ~= nil) then
		conquered_flag = regions_conquered_override
	end
	
	local tint = shade_set.UnconqueredTint
	
	-- On the PC, we manually click-to-select regions, so we need to check the selected region for tinting.
	if ((selected_region ~= nil) and (at_cursor_region.Index == selected_region.Index)) then
		tint = shade_set.SelectTint
	elseif (conquered_flag) then
		tint = shade_set.ConqueredTint
	end
	
	return tint
	
end
		

-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- N E T W O R K   E V E N T S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Central message processor.
-- All the NMP_* functions are called from here.
-------------------------------------------------------------------------------
function Network_On_Message(event)
	GCCommon_Network_On_Message(event)
end

-------------------------------------------------------------------------------
-- Called when someone issues a join/leave request for our game.
-------------------------------------------------------------------------------
function Network_On_Connection_Status(event)
	GCCommon_Network_On_Connection_Status(event)
end

-------------------------------------------------------------------------------
-- Network_On_Find_Session - Called on a successful Net.X_Find_All() operation.
-------------------------------------------------------------------------------
function Network_On_Find_Internet_Session(event)
	GCCommon_Network_On_Find_Internet_Session(event)
end

-------------------------------------------------------------------------------
-- When the GC stats are recieved
-------------------------------------------------------------------------------
function On_Query_GC_Stats(event)
	GCCommon_On_Query_GC_Stats(event)
end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function On_Enumerate_Achievements(event)
	GCCommon_On_Enumerate_Achievements(event)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Query_Medals_Progress_Stats(event)
	GCCommon_On_Query_Medals_Progress_Stats(event)
end	

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function Network_On_Live_Connection_Changed(event)
	GCCommon_Network_On_Live_Connection_Changed(event)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Do_Start_Game()
	GCCommon_Do_Start_Game()
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- M I S C 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Quickmatch_Clicked()
	GCCommon_Begin_Quickmatch(true)
end

-------------------------------------------------------------------------------
-- EVENT HANDLER:  Called when the user clicks the "Quickmatch" button on
-- the status dialog rather than the main screen.
-------------------------------------------------------------------------------
function On_Net_Status_Quickmatch()
	GCCommon_Leave_Game()
	GCCommon_Begin_Quickmatch(true)
end

-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
--Interface = {}


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_Game_Kill_Countdown = nil
	Broadcast_Game_Start_Countdown = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GCCommon_Hide_Win_Dialog = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Is_Player_Of_Faction = nil
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
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	On_Closing_All_Displays = nil
	OutputDebug = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Get_Preferred_Color = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Mouse_Move = nil
	PGLobby_Passivate_Movies = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Reset = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Player_Solid_Color = nil
	PGLobby_Set_Tooltip_Model = nil
	PGLobby_Update_NAT_Warning_State = nil
	PGLobby_Update_Player_Count = nil
	PGLobby_Validate_NAT_Type = nil
	PGMO_Assign_Random_Start_Position = nil
	PGMO_Assign_Start_Position = nil
	PGMO_Clear_Start_Position_By_Seat = nil
	PGMO_Clear_Start_Positions = nil
	PGMO_Disable_Neutral_Structure = nil
	PGMO_Enable_Neutral_Structure = nil
	PGMO_Get_Assignment_Count = nil
	PGMO_Get_Enabled = nil
	PGMO_Get_First_Empty_Start_Position = nil
	PGMO_Get_Reverse_First_Empty_Start_Position = nil
	PGMO_Get_Saved_Start_Pos_User_Data = nil
	PGMO_Get_Seat_Assignment = nil
	PGMO_Get_Start_Marker_ID = nil
	PGMO_Hide = nil
	PGMO_Is_Seat_Assigned = nil
	PGMO_Restore_Start_Position_Assignments = nil
	PGMO_Save_Start_Position_Assignments = nil
	PGMO_Set_Interactive = nil
	PGMO_Set_Seat_Color = nil
	PGMO_Show = nil
	PGNetwork_Clear_Start_Positions = nil
	PGOfflineAchievementDefs_Init = nil
	PG_GC_Create_Props_From_Lobby = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Prepare_Fadeout = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Local_User_Applied_Medals = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	Validate_Region_Definitions = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	defined = nil
	Kill_Unused_Global_Functions = nil
end
