if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[21] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[177] = true
LuaGlobalCommandLinks[93] = true
LuaGlobalCommandLinks[92] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[117] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/Marker_SEGA_Skirmish02.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/Marker_SEGA_Skirmish02.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #9 $
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
require("PGStoryMode") --needed for ai base building
require("PGColors")
require("PGUICommands")
require("RetryMission")
require("PGBaseDefinitions")
require("PGAICommands")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	--ServiceRate = 1
	Define_State("State_Init", State_Init)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
   hostile = Find_Player("Hostile")
	player_faction = novus
	time_objective_sleep = 5

end


---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\Marker_SEGA_Skirmish02 Start!!"))

		Change_Local_Faction("Novus")
		
		Create_Thread("Thread_Mission_Start")
		
		goto01 = Find_Hint("MARKER_GENERIC_GREEN","goto01")
		goto02 = Find_Hint("MARKER_GENERIC_GREEN","goto02")
		goto03 = Find_Hint("MARKER_GENERIC_GREEN","goto03")
		
		camera_start = Find_First_Object("Novus_Hero_Mech")
		Point_Camera_At(camera_start)
		
		-- Maria 08.31.2007
		-- For this map only, we need to use a different scene to display the control groups UI so we need
		-- to make sure we instantiate the proper one here.
		UI_Instantiate_Radial_Control_Group_Scene()		
	end
end


function Thread_Mission_Start()
	_CustomScriptMessage("JoeLog.txt", string.format("Marker_SEGA_Skirmish02 Thread_Mission_Start!!"))
	
	Create_Thread("Thread_Start_Objectives")

	novus_remote_terminal = Find_First_Object("NOVUS_REMOTE_TERMINAL")
	while not TestValid(novus_remote_terminal) do
		Sleep(1)
	end
	
	novus_remote_terminal.Despawn()
end



function Thread_Start_Objectives()
	Sleep(5)
	
	--*********************Novus_Robotic_Infantry**********************************

	group_unit = Find_First_Object("Novus_Robotic_Infantry")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_01"} )--Select your Ohm Robots and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective01 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_01")--Select your Ohm Robots and move them to the location indicated on the radar map.

	Register_Prox(goto01, Prox_Objective01, 50, novus)
	goto01.Highlight(true)
	Add_Radar_Blip(goto01, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto01, neutral)

	
	bool_objective01_completed = false
	while bool_objective01_completed == false do
		Sleep(1)
	end
	
	
	--*********************Novus_Hacker**********************************
	
	
	goto01.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective01)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Hacker")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_02"} )--Select your Hackers and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective02 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_02")--Select your Hackers and move them to the location indicated on the radar map.
	
	Register_Prox(goto02, Prox_Objective02, 50, novus)
	goto02.Highlight(true)
	Add_Radar_Blip(goto02, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto02, neutral)
	
	bool_objective02_completed = false
	while bool_objective02_completed == false do
		Sleep(1)
	end
	
	--**********************Novus_Reflex_Trooper*****************************
	
	goto02.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective02)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Reflex_Trooper")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_03"} )--Select your Blade Troopers and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective03 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_03")--Select your Blade Troopers and move them to the location indicated on the radar map.
	
	Register_Prox(goto03, Prox_Objective03, 50, novus)
	goto03.Highlight(true)
	Add_Radar_Blip(goto03, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto03, neutral)
	
	bool_objective03_completed = false
	while bool_objective03_completed == false do
		Sleep(1)
	end
	
	--******************************Novus_Field_Inverter**********************************
	
	goto03.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective03)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Field_Inverter")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_04"} )--Select your Field Inverters and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective04 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_04")--Select your Field Inverters and move them to the location indicated on the radar map.
	
	Register_Prox(goto01, Prox_Objective04, 50, novus)
	goto01.Highlight(true)
	Add_Radar_Blip(goto01, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto01, neutral)
	
	bool_objective04_completed = false
	while bool_objective04_completed == false do
		Sleep(1)
	end
	
	--*****************************Novus_Amplifier**********************************
	
	goto01.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective04)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Amplifier")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_05"} )--Select your Amplifiers and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective05 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_05")--Select your Amplifiers and move them to the location indicated on the radar map.
	
	Register_Prox(goto02, Prox_Objective05, 50, novus)
	goto02.Highlight(true)
	Add_Radar_Blip(goto02, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto02, neutral)
	
	bool_objective05_completed = false
	while bool_objective05_completed == false do
		Sleep(1)
	end
	
	--********************************Novus_Antimatter_Tank******************************
	
	goto02.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective05)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Antimatter_Tank")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_06"} )--Select your Anti-matter tanks and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective06 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_06")--Select your Anti-matter tanks and move them to the location indicated on the radar map.
	
	Register_Prox(goto03, Prox_Objective06, 50, novus)
	goto03.Highlight(true)
	Add_Radar_Blip(goto03, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto03, neutral)
	
	bool_objective06_completed = false
	while bool_objective06_completed == false do
		Sleep(1)
	end
	
	--*******************************Novus_Variant*******************************
	
	goto03.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective06)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Variant")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_07"} )--Select your Variants and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective07 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_07")--Select your Variants and move them to the location indicated on the radar map.
	
	Register_Prox(goto01, Prox_Objective07, 50, novus)
	goto01.Highlight(true)
	Add_Radar_Blip(goto01, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto01, neutral)
	
	bool_objective07_completed = false
	while bool_objective07_completed == false do
		Sleep(1)
	end
	
	--****************************Novus_Corruptor************************************
	
	goto01.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective07)
	Sleep(time_objective_sleep)

	group_unit = Find_First_Object("Novus_Corruptor")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_08"} )--Select your Corruptors and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective08 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_08")--Select your Corruptors and move them to the location indicated on the radar map.
	
	Register_Prox(goto02, Prox_Objective08, 150, novus)
	goto02.Highlight(true)
	Add_Radar_Blip(goto02, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto02, neutral)
	
	bool_objective08_completed = false
	while bool_objective08_completed == false do
		Sleep(1)
	end
	
	--**************************Novus_Dervish_Jet**********************************
	
	goto02.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective08)
	Sleep(time_objective_sleep)

	group_unit = Find_First_Object("Novus_Dervish_Jet")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_09"} )--Select your Dervish Jets and move them to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective09 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_09")--Select your Dervish Jets and move them to the location indicated on the radar map.
	
	Register_Prox(goto03, Prox_Objective09, 150, novus)
	goto03.Highlight(true)
	Add_Radar_Blip(goto03, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto03, neutral)

	bool_objective09_completed = false
	while bool_objective09_completed == false do
		Sleep(1)
	end
	
	--***************************Mirabel*******************************
	
	goto03.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective09)
	Sleep(time_objective_sleep)
	
	group_unit = Find_First_Object("Novus_Hero_Mech")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_10"} )--Select Mirabel and move her to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective10 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_10")--Select Mirabel and move her to the location indicated on the radar map.
	
	Register_Prox(goto01, Prox_Objective10, 50, novus)
	goto01.Highlight(true)
	Add_Radar_Blip(goto01, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto01, neutral)

	bool_objective10_completed = false
	while bool_objective10_completed == false do
		Sleep(1)
	end
	
	--***************************Vertigo*******************************
	
	goto01.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective10)
	Sleep(time_objective_sleep)	
	
	group_unit = Find_First_Object("Novus_Hero_Vertigo")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_11"} )--Select Vertigo and move him to the location indicated on the radar map.
	Sleep(time_objective_sleep)
	x360_skirmish02_objective11 = Add_Objective("TEXT_SP_MISSION_360_SKIRMISH2_OBJECTIVE_11")--Select Vertigo and move him to the location indicated on the radar map.
	
	Register_Prox(goto02, Prox_Objective11, 150, novus)
	goto02.Highlight(true)
	Add_Radar_Blip(goto02, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), goto02, neutral)

	bool_objective11_completed = false
	while bool_objective11_completed == false do
		Sleep(1)
	end
	
	goto02.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	Objective_Complete(x360_skirmish02_objective11)
	Sleep(time_objective_sleep)	
	
	--***************************player wins*******************************	`
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(5)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	
	Force_Victory(novus)
	
	
end


function Force_Victory(player)
	if player == novus then
		Quit_Game_Now(player, true, true, false)
	else
		Show_Retry_Dialog()
	end
end


















--PROX events

function Prox_Objective01(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Robotic_Infantry") then
		--hopefully player has followed directions...completing objecitve
		bool_objective01_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective01)
	end
end

function Prox_Objective02(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Hacker") then
		--hopefully player has followed directions...completing objecitve
		bool_objective02_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective02)
	end
end

function Prox_Objective03(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Reflex_Trooper") then
		--hopefully player has followed directions...completing objecitve
		bool_objective03_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective03)
	end
end

function Prox_Objective04(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Field_Inverter") then
		--hopefully player has followed directions...completing objecitve
		bool_objective04_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective04)
	end
end

function Prox_Objective05(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Amplifier") then
		--hopefully player has followed directions...completing objecitve
		bool_objective05_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective05)
	end
end

function Prox_Objective06(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Antimatter_Tank") then
		--hopefully player has followed directions...completing objecitve
		bool_objective06_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective06)
	end
end

function Prox_Objective07(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Variant") then
		--hopefully player has followed directions...completing objecitve
		bool_objective07_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective07)
	end
end

function Prox_Objective08(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Corruptor") then
		--hopefully player has followed directions...completing objecitve
		bool_objective08_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective08)
	end
end

function Prox_Objective09(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Dervish_Jet") then
		--hopefully player has followed directions...completing objecitve
		bool_objective09_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective09)
	end
end

function Prox_Objective10(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Hero_Mech") then
		--hopefully player has followed directions...completing objecitve
		bool_objective10_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective10)
	end
end

function Prox_Objective11(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Hero_Vertigo") then
		--hopefully player has followed directions...completing objecitve
		bool_objective11_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective11)
	end
end

	
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Advance_State = nil
	Burn_All_Objects = nil
	Calculate_Task_Force_Speed = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Define_Retry_State = nil
	Describe_Target = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Drop_In_Spawn_Unit = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
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
	Get_Distance_Based_Unit_Score = nil
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
	Maintain_Base = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
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
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	SpawnList = nil
	Spawn_Dialog_Box = nil
	Story_AI_Request_Build_Hard_Point = nil
	Story_AI_Request_Build_Units = nil
	Story_AI_Set_Aggressive_Mode = nil
	Story_AI_Set_Autonomous_Mode = nil
	Story_AI_Set_Defensive_Mode = nil
	Story_AI_Set_Scouting_Mode = nil
	Strategic_SpawnList = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
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
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
