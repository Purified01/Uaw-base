if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[199] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[125] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_New_Tutorial_Strategic.lua#13 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_New_Tutorial_Strategic.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("RetryMission")
require("PGColors")
require("PGPlayerProfile")
require("PGFactions")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
ScriptPoolCount = 0

---------------------------------------------------------------------------------------------------

function Definitions()
	Define_State("State_Init", State_Init)
	Define_State("State_Start_Tut03", State_Start_Tut03) 
	Define_State("State_Tutorial_Campaign_Over", State_Tutorial_Campaign_Over) 
	
	-- Oksana: mark as tutorial so scoring manager knows what to expect
	IsTutorialCampaign = true;
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGFactions_Init()
	PGColors_Init_Constants()
	PGPlayerProfile_Init_Constants()
	--aliens.Enable_Colorization(true, 2)
	--novus.Enable_Colorization(true, 6)
	--uea.Enable_Colorization(true, 5)
	--masari.Enable_Colorization(true, 21)
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Register_Game_Scoring_Commands()
		Fade_Screen_Out(0)
		
		Set_Next_State("State_Start_Tut03")
	end
end

function State_Start_Tut03(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		
		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
		UI_Set_Loading_Screen_Background("Splash_Alien.tga")
		UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT03_LOAD_SCREEN_TEXT")
		
		-- jdg ... 10/01/07 ... asset bank stuff per Jason 
		--player is Hierarchy vs. Military
		aliens.Set_Is_AI_Required(false) 
		novus.Set_Is_AI_Required(false)
		masari.Set_Is_AI_Required(false)
		uea.Set_Is_AI_Required(true)
		
		Force_Land_Invasion(Find_First_Object("Region27"), novus, aliens, false)
	end
end

function State_Tutorial_Campaign_Over(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		Quit_Game_Now(aliens, true, false, false)
	end
end

--***************************************EVENT HANDLERS****************************************************************************************************
--this is used to overwrite the "Sandbox" map lineup and force which maps+scripts to use
function On_Land_Invasion()
	if CurrentState == "State_Start_Tut03" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/TUT_03_Tutorial_City.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Tutorial_Tut03"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "StoryCampaign"
		InvasionInfo.NightMission = false
	end
end



--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Novus "TACTICAL" mission scripts 
function Alien_Tactical_Mission_Over(victorious)
	if CurrentState == "State_Start_Tut03" then 
		if victorious then 
			-- Oksana: Notify achievements
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Tutorial")

			Set_Next_State("State_Tutorial_Campaign_Over")
			
		end
	end
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()
	Movie_Commands_Post_Load_Callback()
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Advance_State = nil
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
	Define_Retry_State = nil
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
	Get_Current_State = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
	Get_Next_State = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Remove_Xbox_Controller_Hint = nil
	On_Retry_Response = nil
	OutputDebug = nil
	PGColors_Init = nil
	PGHintSystem_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_From_Table = nil
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Objective_Text = nil
	Show_Object_Attached_UI = nil
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
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
