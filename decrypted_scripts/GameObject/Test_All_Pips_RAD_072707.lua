if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[117] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/Test_All_Pips_RAD_072707.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/Test_All_Pips_RAD_072707.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)

	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_hi_science = "AI_Science_Officer_Pip_Head.alo"
	pip_hi_comm = "AI_Comm_Officer_Pip_Head.alo"
	pip_hi_grunt = "AI_Grunt_Pip_Head.alo"

	pip_col_moore = "MH_Moore_pip_head.alo"
	pip_ma_comm_officer = "Mi_comm_officer_pip_head.alo"
	pip_marine = "Mi_marine_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_chopper = "Mi_airforce_pip_head.alo"

	pip_viktor = "NH_Viktor_pip_Head.alo"
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	pip_altea = "ZH_Altea_Pip_head.alo"
	pip_charos = "ZH_Charos_pip_Head.alo"
	pip_zessus = "ZH_Zessus_Pip_head.alo"
	pip_disciple = "ZI_Disciple_pip_head.alo"
	pip_architect = "ZI_Architect_Pip_head.alo"
		
end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		Create_Thread("Thread_Show_PIPs")
	end
end

function Thread_Show_PIPs()
   Sleep(1)
   
   while true do 
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Mirabel"} )
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"The Founder"} )
		BlockOnCommand(Queue_Talking_Head(pip_founder, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Vertigo"} )
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Comm Officer"} )
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Science Officer"} )
		BlockOnCommand(Queue_Talking_Head(pip_novscience, "HIE01_SCENE02_06"))

	
   end
   
   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Orlok"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE02_06"))
   
   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Kamal"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Hierarchy Science Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_hi_science, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Hierarchy Comm Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_hi_comm, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Hierarchy Grunt"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_hi_grunt, "HIE01_SCENE02_06"))


   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Moore"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_col_moore, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Military Comm Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_ma_comm_officer, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Marine"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_marine, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Woolard"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_woolard, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Military Chopper Pilot"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_chopper, "HIE01_SCENE02_06"))


   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Viktor"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_viktor, "HIE01_SCENE02_06"))

   

   

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Science Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_novscience, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Comm Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_novcomm, "HIE01_SCENE02_06"))


   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Altea"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_altea, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Charos"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_charos, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Zessus"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_zessus, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Masari Disciple"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_disciple, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Masari Architect"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_architect, "HIE01_SCENE02_06"))

end











function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Advance_State = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Define_Retry_State = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Drop_In_Spawn_Unit = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	Formation_Attack = nil
	Formation_Attack_Move = nil
	Formation_Guard = nil
	Formation_Move = nil
	Full_Speed_Move = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Achievement_Buff_Display_Model = nil
	Get_Chat_Color_Index = nil
	Get_Current_State = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Get_Next_State = nil
	Get_Player_By_Faction = nil
	Hunt = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Remove_Xbox_Controller_Hint = nil
	On_Retry_Response = nil
	OutputDebug = nil
	PGAchievementAward_Init = nil
	PGColors_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Persist_Online_Achievements = nil
	Player_Earned_Offline_Achievements = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_From_Table = nil
	Reset_Objectives = nil
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Local_User_Applied_Medals = nil
	Set_Objective_Text = nil
	Set_Online_Player_Info_Models = nil
	Show_Earned_Offline_Achievements = nil
	Show_Earned_Online_Achievements = nil
	Show_Object_Attached_UI = nil
	Show_Retry_Dialog = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	SpawnList = nil
	Spawn_Dialog_Box = nil
	Strategic_SpawnList = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Loading_Screen_Background = nil
	UI_Set_Loading_Screen_Faction_ID = nil
	UI_Set_Loading_Screen_Mission_Text = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_Offline_Achievement = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
