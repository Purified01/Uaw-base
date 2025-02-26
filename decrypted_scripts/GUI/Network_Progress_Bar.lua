if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[205] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Network_Progress_Bar.lua#16 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Network_Progress_Bar.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #16 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGNetwork")
require("PGColors")

ScriptPoolCount = 0

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function On_Init()

	DebugMessage("Progress Bar Initialized!!!")

	ComponentShowing = true
	Progressing = false

	CurrentProgress = 0.0
	Register_Net_Commands()
	Timer = Net.Get_Time()

	Network_Progress_Bar.Set_Bounds(0, 0, 1, 1)
	Network_Progress_Bar.Progress_Bar.Set_Filled(CurrentProgress)

	-- Event handlers
	Network_Progress_Bar.Register_Event_Handler("Update_Network_Progress", nil, Update_Network_Progress)
	Network_Progress_Bar.Register_Event_Handler("Update_Network_Progress_Message", nil, Update_Network_Progress_Message)

	-- TO RAISE THE EVENTS....
	--Raise_Event_Immediate_All_Scenes("Update_Network_Progress", {})
	--Raise_Event_Immediate_All_Scenes("Update_Network_Progress_Message", {})
	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- E X T E R N A L   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Network_Progress()
	if (ComponentShowing == false) then
		return
	end
	CurrentProgress = CurrentProgress + 0.1
	if (CurrentProgress > 1.0) then
		CurrentProgress = 0.0
	end
	Network_Progress_Bar.Progress_Bar.Set_Filled(CurrentProgress)
end

function Update_Network_Progress_Message(arg1, arg2)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()

	if (ComponentShowing == false) then
		return
	end

	if (Progressing == false) then
		return
	end

	local tmp = Net.Get_Time()
	if ((tmp - Timer) > 1.0) then
		Timer = tmp
		Update_Network_Progress()
	end

end

function On_Component_Shown()
	CurrentProgress = 0.0
	Timer = Net.Get_Time()
	ComponentShowing = true
	Network_Progress_Bar.Focus_First()
end

function On_Component_Hidden()
	Stop()
	ComponentShowing = false
end

function On_Cancel_Clicked()
	this.Get_Containing_Scene().Raise_Event_Immediate("Network_Progress_Bar_Cancelled", nil, {})
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Start(asset_bank_names)
	CurrentProgress = 0.0
	Progressing = true
	
	--Default is to show the cancel button, so make sure it's
	--back on in the case of a previous call to hide.
	this.Button_Cancel.Set_Hidden(false)	
	
	-- if we have a block status that we need to wait on, save it off and check it in the update
	if asset_bank_names then
		BlockStatus = Load_Asset_Banks(asset_bank_names)
	end
end

function Stop()
	Progressing = false
	CurrentProgress = 0.0
	this.End_Modal()
end

function Set_Message(message)
	Network_Progress_Bar.Text_Message.Set_Text(message)
end

function Hide_Cancel_Button()
	this.Button_Cancel.Set_Hidden(true)
end

function Is_Done()
	if BlockStatus then
		return BlockStatus.IsFinished()
	end
	return true
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- L A N   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N T E R N E T   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
function Is_Busy()
	return Progressing
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Claim_Focus()
	this.Focus_First()
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
Interface = {}
Interface.Start = Start
Interface.Stop = Stop
Interface.Set_Message = Set_Message
Interface.Is_Busy = Is_Busy
Interface.Hide_Cancel_Button = Hide_Cancel_Button
Interface.Claim_Focus = Claim_Focus
Interface.Is_Done = Is_Done
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
