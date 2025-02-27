if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[52] = true
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Military_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 93510 $
--
--          $DateTime: 2008/02/16 10:09:35 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Gamepad_Tactical_Command_Bar_Common")

MODE_INVALID = -1
MODE_CONSTRUCTION = 1 -- can make buildings
MODE_SELECTION = 2    -- can control units
Mode = MODE_CONSTRUCTION

-- ---------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Player = Find_Player("Military")
	
	if Player == nil then 
		MessageBox("the player is nil")
	else
		Scene.FactionText.Set_Text(Player.Get_Faction_Display_Name())
	end
	CloseHuds = false

	Init_Tab_Orders()

	Init_Tactical_Command_Bar_Common(Scene, Player)
	
		--Set the correct sell button texture
	if TestValid(SellButton) then
		SellButton.Set_Texture("i_icon_military_sell.tga")
	end
	
	-- hide the builder button, military has no builder unit
	if TestValid(BuilderButton) then 
		BuilderButton.Set_Hidden(true)
	end
end


function Hide_Faction_Specific_Buttons()
end

function Hide_Research_Tree()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()
	-- Are there any huds open!?
	CloseHuds = Update_Common_Scene()
end



-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays(event, source)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Maria 08.09.2006
-- Hide_All_Faction_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Faction_Specific_UI(onoff)
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Scientist_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Scientist_Button_Clicked()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Faction_Has_Queue_Type -- Does this faction have the specific build queue type
-- ------------------------------------------------------------------------------------------------------------------
function Faction_Has_Queue_Type(queue_type)
	return true
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	Commit_Profile_Values = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Define_Retry_State = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Hero_Button = nil
	GUI_Cancel_Talking_Head = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Pool_Free = nil
	Gamepad_Point_Camera_At_Next_Builder = nil
	Get_Button_Index_For_Unit_Type = nil
	Get_Chat_Color_Index = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Selected_Unit_Type_For_Button_Index = nil
	Hot_Key_Activate_Unit_Ability = nil
	Init_Control_Group_Textures_Prefix_Map = nil
	Is_First_Button = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Build_Button_Focus_Gained = nil
	On_Handle_BattleCam_Button_Up = nil
	On_Mouse_Off_Hero_Button = nil
	On_Mouse_Over_Hero_Button = nil
	On_Remove_Xbox_Controller_Hint = nil
	On_Set_Achievement_Buff_Display_Model = nil
	OutputDebug = nil
	PGColors_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Post_Load_Game = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Show_Retry_Dialog = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Mouse_Buttons = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
