LUA_PREP = true

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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Global_Conquest_Lobby.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 95231 $
--
--          $DateTime: 2008/03/14 09:42:07 $
--
--          $Revision: #34 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("Common_Global_Conquest_Lobby")

ScriptPoolCount = 0


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
end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
-------------------------------------------------------------------------------
function Initialize_Components()

	GCCommon_Initialize_Components()
	Initalize_Controller_Components()
	
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

	if (not GCCommon_On_Update()) then
		return false
	end

	-- If our regions are setup, update the region tooltip.
	if (CurrentFactionStateLookup ~= nil) then
		GCCommon_Update_Region_At_Cursor()
	end
	
	-- If we're already in a game or are forced to ignore input, don't do anything.
	if ((not HostingGame) and (not JoinedGame) and
		(not GCLobbyManager.Is_Input_Processing_Suspended()) and GCSceneInputEnabled) then
		-- If SelectedRegion becomes nil, that means no regions are selected.
		SelectedRegion = AtCursorRegion
		GCCommon_Update_Region_Tooltip()
	end
	
	this.Focus_First()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Main_Navigation_Visible(value)

	this.Frame_1.Set_Hidden(not value)
	this.Quad_3.Set_Hidden(not value)
	this.Button_Quickmatch.Set_Hidden(not value)
	this.Quad_2.Set_Hidden(not value)
	this.Button_Tmp_My_Online_Profile.Set_Hidden(not value)
	this.Quad_4.Set_Hidden(not value)
	this.Button_Launch_Game.Set_Hidden(not value)
	this.Quad_1.Set_Hidden(not value)
	this.Button_Back.Set_Hidden(not value)
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()

	GCCommon_On_Component_Shown()
	Net.Get_Gamer_Picture(Global_Conquest_Lobby.Quad_Avatar)
	
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

	if ( TestValid(Global_Conquest_Lobby.Global_Conquest_Win_Dialog) and
			not Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Get_Hidden() ) then
		Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Leave_Button()
		return
	end

	GCCommon_On_My_Online_Profile_Clicked()
	
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

	if ( CurrentFaction == PG_FACTION_NOVUS ) then
		Set_Profile_Value( PP_LOBBY_RESET_CONQUERED_GLOBE_NOVUS, value )
	elseif ( CurrentFaction == PG_FACTION_ALIEN ) then
		Set_Profile_Value( PP_LOBBY_RESET_CONQUERED_GLOBE_ALIEN, value )
	elseif ( CurrentFaction == PG_FACTION_MASARI ) then
		Set_Profile_Value( PP_LOBBY_RESET_CONQUERED_GLOBE_MASARI, value )
	end
	Commit_Profile_Values()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Conquered_Globe_Reset_Flag()

	if ( CurrentFaction == PG_FACTION_NOVUS ) then
		return Get_Profile_Value( PP_LOBBY_RESET_CONQUERED_GLOBE_NOVUS, GLOBE_RESET_STATE_HAS_NOT_MADE_CHOICE )
	elseif ( CurrentFaction == PG_FACTION_ALIEN ) then
		return Get_Profile_Value( PP_LOBBY_RESET_CONQUERED_GLOBE_ALIEN, GLOBE_RESET_STATE_HAS_NOT_MADE_CHOICE )
	elseif ( CurrentFaction == PG_FACTION_MASARI ) then
		return Get_Profile_Value( PP_LOBBY_RESET_CONQUERED_GLOBE_MASARI, GLOBE_RESET_STATE_HAS_NOT_MADE_CHOICE )
	else
		return false
	end
		
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
	
	-- On the gamepad, we auto-select whatever region is under the reticle, so we only need to check conquered status.
	if (conquered_flag) then
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

	GCLobbyManager.Cleanup();
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

	if ( TestValid(Global_Conquest_Lobby.Global_Conquest_Win_Dialog) and
			not Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Get_Hidden() ) then
		Global_Conquest_Lobby.Global_Conquest_Win_Dialog.Reset_Button()
		return
	end
	GCCommon_Begin_Quickmatch(true)
	
end

-------------------------------------------------------------------------------
-- EVENT HANDLER:  Called when the user clicks the "Quickmatch" button on
-- the status dialog rather than the main screen.
-------------------------------------------------------------------------------
function On_Net_Status_Quickmatch()
	GCCommon_Leave_Game()
	GCCommon_Begin_Quickmatch(false)
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- JAB 
-------------------------------------------------------------------------------
function Initalize_Controller_Components()

	this.Register_Event_Handler("Controller_Right_Bumper_Up", nil, Increase_Faction_Selection)
	this.Register_Event_Handler("Controller_Left_Bumper_Up", nil, Decrease_Faction_Selection)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Controller_Y_Button_Up", nil, On_My_Online_Profile_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, On_Quickmatch_Clicked)
	this.Register_Event_Handler("Controller_Start_Button_Up", nil, On_Start_Button_Up)
	this.Register_Event_Handler("Controller_Left_Trigger_Press", nil, On_Scene_Mouse_Up)
	
	-- Pressing the A button is 
	this.Register_Event_Handler("Controller_A_Button_Up", nil, On_Launch_Game_Clicked)	
	
	this.Text_Title.Set_Tab_Order(Declare_Enum(0))
	
	this.Focus_First()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Increase_Faction_Selection()

	if (CurrentFaction == PG_FACTION_NOVUS) then
		On_Alien_Clicked()
	elseif (CurrentFaction == PG_FACTION_ALIEN) then
		On_Masari_Clicked()
	end

end
		
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Decrease_Faction_Selection()

	if (CurrentFaction == PG_FACTION_MASARI) then
		On_Alien_Clicked()
	elseif (CurrentFaction == PG_FACTION_ALIEN) then
		On_Novus_Clicked()
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Start_Button_Up()


end		

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
	On_Mouse_Move = nil
	On_Mouse_Right_Down = nil
	On_Mouse_Right_Up = nil
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
