if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[81] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[175] = true
LuaGlobalCommandLinks[199] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[177] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[183] = true
LuaGlobalCommandLinks[125] = true
LuaGlobalCommandLinks[116] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Tutorial_Strategic.lua#29 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Tutorial_Strategic.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #29 $
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
require("PGCampaigns")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
ScriptPoolCount = 0

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Start_360Tutorial", State_Start_360Tutorial) -- new first tutorial ... on Novus homeworld
	Define_State("State_Start_Tut01", State_Start_Tut01) -- first tutorial ... at capitol building
	Define_State("State_Start_Tut02", State_Start_Tut02) -- second tutorial ... at military base south of Capitol Building
		
	Define_Retry_State()

	-- Oksana: mark as tutorial so scoring manager knows what to expect
	IsTutorialCampaign = true;

	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGFactions_Init()
	PGCampaigns_Init()
	PGColors_Init_Constants()
	PGPlayerProfile_Init_Constants()
	--aliens.Enable_Colorization(true, 2)
	--novus.Enable_Colorization(true, 6)
	--uea.Enable_Colorization(true, 5)
	--masari.Enable_Colorization(true, 21)
	
	--define pip heads for global dialogue	
	--tutorial/military
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "mi_marine_pip_head.alo"
	
	--novus
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_viktor = "NH_Viktor_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	--mission win/loss bools
	tutorial01_successful = false
	tutorial02_successful = false
	x360tutorial_successful = false
	
	--used in skip-mission cheats
	bool_user_chose_mission = false
	global_story_dialogue_done=false
	
	--this is used to hold data generated at the end of novus 1 to be used again in mission 7
	novus_base_table = {}
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\n*************NOVUS CAMPAIGN START********"))
		
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		
		-- Maria 11.07.2007
		-- Changing this name since we are going to have similar functionality (to the Debug Load Mission)
		-- for loading missions in the Gamepad Version.
		if data_table == nil or data_table.Start_Mission == nil then
			-- Only the xbox has the xbox tutorial, otherwise skip straight to Tut01
			if Is_Xbox() or Is_Gamepad_Active() then
				Set_Next_State("State_Start_360Tutorial")
			else
				Set_Next_State("State_Start_Tut01")
			end
		else
			Set_Next_State(tostring(data_table.Start_Mission))
			data_table.Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		--Set_Next_State("State_Start_NM01_Dialogue")
		
		--puts up text in the objective box to let player know how to skip to specific missions
		--skipping info getting commented out for sega delivery of first four missions ... jdg 1/5/07
		--objective_skipping_info = Add_Objective("To skip to a specific mission via console commands: \n1. Type 'attach Story_Campaign_Tutorial_Strategic'\n2. Type 'lua' then which mission to start Tut01() - NM07()\n** eg. 'lua NM01()'")
		--objective_skipping_info = Add_Objective("Move your hero to the red-zone to begin.")
		
		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = Point_Camera_At.Set_Transition_Time(1, 1)
		globe_spinning_thread=nil
		
		current_global_story_dialogue_id=nil
		current_global_story_dialogue_id_sub_a=nil
		current_global_story_dialogue_id_sub_b=nil
		
		Pause_Sun(true)
		Set_Profile_Value(PP_LAST_PLAYED_CAMPAIGN, PG_CAMPAIGN_PRELUDE)
		Commit_Profile_Values()
	end
end

function State_Start_360Tutorial(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		JumpToNextMission=false
		EscToStartState=false
		Change_Local_Faction("Novus")
		hero = Find_First_Object("Military_Hero_Randal_Moore")
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_360Tutorial"))
		--making the campaign goto the first mission 
		local region = Find_First_Object("Region22") -- (22  - Washington DC/using 23 - Gulf Coast for now)

		-- JAC - testing setting the Is_AI_Required flag so we can have proper asset bank loading
		novus.Set_Is_AI_Required(false)
		masari.Set_Is_AI_Required(false)
		aliens.Set_Is_AI_Required(false)

		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
		UI_Set_Loading_Screen_Background("splash_novus.tga")
		UI_Set_Loading_Screen_Mission_Text("GAMEPAD_TEXT_SP_MISSION_360TUT_LOAD_SCREEN_TEXT")
		Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_01)
		Commit_Profile_Values()
		Force_Land_Invasion(region, aliens, novus, false)
	end
end

function State_Start_Tut01(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		JumpToNextMission=false
		EscToStartState=false
		Change_Local_Faction("Military")
		hero = Find_First_Object("Military_Hero_Randal_Moore")
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_Tut01"))
		--making the campaign goto the first mission 
		local region = Find_First_Object("Region22") -- (22  - Washington DC/using 23 - Gulf Coast for now)

		-- JAC - testing setting the Is_AI_Required flag so we can have proper asset bank loading
		novus.Set_Is_AI_Required(false)
		masari.Set_Is_AI_Required(false)
		aliens.Set_Is_AI_Required(true)

		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
		UI_Set_Loading_Screen_Background("splash_military.tga")
		UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT01_LOAD_SCREEN_TEXT")
		Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_02)
		Commit_Profile_Values()
		Force_Land_Invasion(region, aliens, uea, false)
	end
end

function State_Start_Tut02(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		JumpToNextMission=false
		EscToStartState=false
		Change_Local_Faction("Military")
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_Tut02"))
		
		-- JAC - testing setting the Is_AI_Required flag so we can have proper asset bank loading
		novus.Set_Is_AI_Required(false)
		masari.Set_Is_AI_Required(false)
		aliens.Set_Is_AI_Required(false)		
		uea.Set_Is_AI_Required(false)
		
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving to psuedo-Washington D.C. for Tutorial 02"))
			local region = Find_First_Object("Region23") -- (22  - Washington DC/using 23 - Gulf Coast for now)
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT")
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_03)
			Commit_Profile_Values()
			Force_Land_Invasion(region, aliens, uea, false)
		end
	end
end

--***************************************THREADS****************************************************************************************************





--***************************************EVENT HANDLERS****************************************************************************************************
--this is used to overwrite the "Sandbox" map lineup and force which maps+scripts to use
function On_Land_Invasion()

	if objective_triggering_info ~= nil then
		--this just removes old (now redundant) text
		Delete_Objective(objective_triggering_info)
	end
	
	if objective_skipping_info ~= nil then
		--this just removes old (now redundant) text
		Delete_Objective(objective_skipping_info)
	end
	
	if CurrentState == "State_Start_360Tutorial" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/360_Tutorial.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_X360_Tut"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "360_Tutorial"
		InvasionInfo.RequiredContexts = { "hide_me"}

	elseif CurrentState == "State_Start_Tut01" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/TUT_01_Washington_DC.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_Tut01"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
		InvasionInfo.StartingContext = "Tut01_StoryCampaign"
		InvasionInfo.RequiredContexts = { "hide_me" }
		
	elseif CurrentState == "State_Start_Tut02" then 	
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/TUT_02_FortMcNair.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_Tut02"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "Tut02_StoryCampaign"
		InvasionInfo.RequiredContexts = { "Tut02_StoryCampaign_Novus", "Tut02_StoryCampaign_Midtro" }
	end
end



--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Novus "TACTICAL" mission scripts 
function Novus_Tactical_Mission_Over(victorious)
	if CurrentState == "State_Start_360Tutorial" then 
		if victorious then
			x360tutorial_successful = true
			Set_Next_State("State_Start_Tut01")
			
			-- Since this is the completion of the first mission, we have to mark this one
			-- as available too.  The proceeding ones will be marked as the previous one gets
			-- completed.
			Set_Profile_Value(PP_TUTORIAL_00_AVAILABLE, true)
			
			-- Mark the next mission as available
			Set_Profile_Value(PP_TUTORIAL_01_AVAILABLE, true)

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT01_LOAD_SCREEN_TEXT")
		end
	elseif CurrentState == "State_Start_Tut01" then 
		if victorious then
			tutorial01_successful = true
			Set_Next_State("State_Start_Tut02")
			
			-- Mark the next mission as available
			Set_Profile_Value(PP_TUTORIAL_02_AVAILABLE, true)

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT")
		end
	elseif CurrentState == "State_Start_Tut02" then
		if victorious then
			tutorial02_successful = true
								
			-- Oksana: Notify achievements
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Tutorial")
			
			Set_Profile_Value(PP_CAMPAIGN_TUTORIAL_COMPLETED, true)

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS01_LOAD_SCREEN_TEXT")
			
			-- Handle campaign completion immediately: it's more efficient
			-- than doing a quit out to global and a state pump
			Register_Campaign_Commands()
			CampaignManager.Start_Campaign("NOVUS_Story_Campaign")
		end
	end
	
	Commit_Profile_Values()
	
	if not victorious then
		Retry_Current_Mission()
	end
	
	--changing this bool forces campaign back on track if player had skipped to a specific mission
	bool_user_chose_mission = false
	
	
end

function Force_Victory(player)
	-- Quit_Game_Now(winning_player, quit_to_main_menu, destroy_loser_forces, build_temporary_command_center, VerticalSliceTriggerVictorySplashFlag)
	Quit_Game_Now(player, false, false, false)
end

--This is called from UI when the Start Mission button is clicked.
--function Request_Start_Mission()
--	if not JumpToNextMission then
--		JumpToNextMission = true
--	end
--end

function Story_Handle_Esc()
	if not EscToStartState then
		EscToStartState = true
	end
end

function Thread_Region_Flash(target)
	for i=1,3 do
		UI_Set_Region_Color(target, {1,1,0})
		Sleep(.5)
		UI_Clear_Region_Color(target)
		Sleep(.5)
	end
	current_global_story_dialogue_id_sub_a = nil
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()
	Movie_Commands_Post_Load_Callback()
end

--***************************************CHEATS****************************************************************************************************
--***************************************CHEATS****************************************************************************************************
--***************************************CHEATS****************************************************************************************************
-- below are the "cheat-functions" to launch specific missions (from global mode)
function Tut01()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to Tut01"))
	Set_Next_State("State_Start_Tut01")
	bool_user_chose_mission = true

	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: Tut01\nMove your hero to any enemy territory to trigger the mission.")

end

function Tut02()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to Tut02"))
	Set_Next_State("State_Start_Tut02")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: Tut02\nMove your hero to any enemy territory to trigger the mission.")
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
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Objective_Text = nil
	Show_Object_Attached_UI = nil
	Show_Retry_Dialog = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Thread_Region_Flash = nil
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
