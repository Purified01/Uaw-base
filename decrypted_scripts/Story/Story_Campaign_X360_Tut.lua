if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[202] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[181] = true
LuaGlobalCommandLinks[92] = true
LuaGlobalCommandLinks[83] = true
LuaGlobalCommandLinks[56] = true
LuaGlobalCommandLinks[137] = true
LuaGlobalCommandLinks[29] = true
LuaGlobalCommandLinks[64] = true
LuaGlobalCommandLinks[48] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[86] = true
LuaGlobalCommandLinks[63] = true
LuaGlobalCommandLinks[28] = true
LuaGlobalCommandLinks[159] = true
LuaGlobalCommandLinks[50] = true
LuaGlobalCommandLinks[69] = true
LuaGlobalCommandLinks[38] = true
LuaGlobalCommandLinks[51] = true
LuaGlobalCommandLinks[44] = true
LuaGlobalCommandLinks[204] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[61] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[177] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[173] = true
LuaGlobalCommandLinks[138] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[53] = true
LuaGlobalCommandLinks[43] = true
LuaGlobalCommandLinks[90] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[21] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[20] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[146] = true
LuaGlobalCommandLinks[93] = true
LuaGlobalCommandLinks[55] = true
LuaGlobalCommandLinks[58] = true
LuaGlobalCommandLinks[206] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_X360_Tut.lua#81 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_X360_Tut.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Nader_Akoury $
--
--            $Change: 96859 $
--
--          $DateTime: 2008/04/11 15:24:41 $
--
--          $Revision: #81 $
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

	--UI_Set_Display_Credits_Pop(true)
	--Set_Hint_System_Visible(true)
	--UI_Show_Radar_Map(true)
	--UI_Show_Controller_Context_Display(true)
	--UI_Show_BattleCam_Button(true)

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	--ServiceRate = 1
	Define_State("State_Init", State_Init)
	Define_State("State_CameraControls", State_CameraControls)
	Define_State("State_SelectionAndMovement", State_SelectionAndMovement)
	Define_State("State_Combat", State_Combat)
	Define_State("State_Construction", State_Construction)
	Define_State("State_Heroes", State_Heroes)
	Define_State("State_Research", State_Research)
	Define_State("State_Groups", State_Groups)
	
	bool_play_opening_cine = true
	bool_use_control_locks = true
	bool_show_expanded_hints = true
	bool_teach_groups = true
	bool_new_dialog_is_in = true
	bool_Brets_stuff_fixed = true
	
	bool_restarting_init = false
	bool_restarting_camera = false
	bool_restarting_selectionAndMovement = false
	bool_restarting_combat = false
	bool_restarting_construction = false
	bool_restarting_groups = false
	bool_restarting_heroes = false
	bool_restarting_research = false
	bool_camera_zoomed_in = false
	bool_camera_zoomed_out = false
	bool_camera_rotated = false
	bool_camera_reset = false
	bool_research_panel_open = false
	bool_research_completed = false
	bool_rally_point_placed = false
	bool_custom_group_made = false
	bool_camera_scrolled = false
	bool_2911_moved_via_radar = false
	bool_show_radar_map = false
	
   neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	novus_two=Find_Player("NovusTwo")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
   hostile = Find_Player("Hostile")
	player_faction = novus
   
	--testing
	time_objective_sleep = 5
	timer_objective_complete = 2
	timer_low_ambient_flow_guys = 5
	timer_high_ambient_flow_guys = 5
	
	fow_novus_reveal = nil
	
	object_type_novus_robotic_assembly = Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY")
	object_type_novus_robotic_assembly_under_construction = Find_Object_Type("Novus_Robotic_Assembly_Construction")
	object_type_novus_robotic_infantry = Find_Object_Type("Novus_Robotic_Infantry")
	object_type_novus_robotic_assembly_upgrade = Find_Object_Type("Novus_Robotic_Assembly_Instance_Generator")
	object_type_novus_blade_trooper = Find_Object_Type("Novus_Reflex_Trooper")
	object_type_novus_transport = Find_Object_Type("NOVUS_AIR_INVASION_TRANSPORT")	

	counter_player_produced_robotic_infantry = 0
	counter_player_produced_blade_troopers = 0
	counter_snipe_target = 0
	counter_barrage_target = 0
	
	list_mirabel_barage_target = {}
	
	--jdg 10/24/07 novus science officer being replaced by novus comm officer...just changing this reference here
	pip_novscience = "NI_Comm_Officer_pip_Head.alo"
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_2911 = "NI_Reflex_pip_Head.alo" 
	pip_founder = "NH_Founder_pip_Head.alo"
	
	dialog_mission_intro = 0
	dialog_camera_zoom_in = 1
	dialog_camera_zoom_out = 2
	dialog_camera_rotate = 3
	dialog_camera_reset = 4
	dialog_select_2911 = 5
	dialog_move_2911 = 6
	dialog_move_2911_moving = 7
	dialog_move_2911_via_radarmap = 8
	dialog_move_2911_via_radarmap_done = 9
	dialog_combat_use_duplicate = 10
	dialog_combat_duplicate_activated = 11
	dialog_combat_done = 12
	dialog_construction_center_view = 13
	dialog_construction_move_constructor = 14
	dialog_construction_build_robotic_assembly = 15
	dialog_construction_build_three_robots = 16
	dialog_construction_upgrade_robotic_assembly = 17
	dialog_intro_groups = 18
	dialog_groups_switch_between = 19
	dialog_groups_combine = 20
	dialog_groups_done = 21
	dialog_heroes_intro = 22
	dialog_heroes_mirabel_snipe = 23
	dialog_heroes_mirabel_missile_barrage = 24
	dialog_heroes_done = 25
	dialog_start_researching = 26
	dialog_research_radiation_shielding = 27
	dialog_research_done = 28
	dialog_construction_place_rally_point = 29
	dialog_reset_camera_now = 30
	dialog_scroll_via_radarmap = 31
	
	player_produced_robotic_assembly = nil
	
	player_produced_robot01 = nil
	player_produced_robot02 = nil
	player_produced_robot03 = nil
	bool_player_produced_robot01_selected = false
	bool_player_produced_robot02_selected = false
	bool_player_produced_robot03_selected = false
	
	player_produced_bladetrooper01 = nil
	player_produced_bladetrooper02 = nil
	player_produced_bladetrooper03 = nil
	bool_player_produced_bladetrooper01_selected = false
	bool_player_produced_bladetrooper02_selected = false
	bool_player_produced_bladetrooper03_selected = false
	bool_player_made_group_at_mark = false
	bool_bots_at_mark = false
	bool_alarm_set = false
	bool_constructor_at_mark = false
	
	cinematic_flyovers = {}
	cinematic_flyover_in_use = {}
	flyover_max = 0
	
	end_locations_antimatter = { --facing = 180
	
		Create_Position(1581.41,	1778.21,	149.9), --player controlled unit goto spots
		Create_Position(1581.86,	1741.54,	149.9),--
		Create_Position(1581.5,	1704.34,	149.9),--
		Create_Position(1640.34,	1666.55,	149.9),--

	}
	
	end_locations_antimatter_preplaced = { --facing = 180
	
		Create_Position(1637.05,	1781.36,	149.9),--moving into place ahead of time
		Create_Position(1638.96,	1743.81,	149.9),
		Create_Position(1639.77,	1705.4,	149.9),
		Create_Position(1692.8,	1783.1,	149.9),
		Create_Position(1692.49,	1744.52,	149.9),
		Create_Position(1692.8,	1706.11,	149.9),
		Create_Position(1693.21,	1667.03,	149.9),
		Create_Position(1693.76,	1626.92,	149.9),
	}
	
	end_locations_amplifiers = { --facing = 90
	
		Create_Position(1405.98, 1605.7, 149.9),
		Create_Position(1454.29, 1606.55, 149.9),
		Create_Position(1503.22, 1606.38, 149.9),
		Create_Position(1403.86, 1560.7, 149.9),
		Create_Position(1455.33, 1561.55, 149.9),
		Create_Position(1501.99, 1561.38, 149.9),
		
	}
	
	end_locations_bladebots = { --facing = 90
	
		Create_Position(1400.92,	1524.92,	149.9),-->player unit start here
		Create_Position(1420.1,	1525.08,	149.9),
		Create_Position(1449.07,	1525.18,	149.9),
		Create_Position(1468.26,	1525.33,	149.9),
		Create_Position(1496.3,	1525.95,	149.9),
		Create_Position(1515.49,	1526.11,	149.9),
		
		Create_Position(1400.19,	1506.51,	149.9),
		Create_Position(1419.38,	1506.67,	149.9),
		Create_Position(1448.35,	1506.77,	149.9),
		Create_Position(1467.54,	1506.93,	149.9),
		Create_Position(1495.58,	1507.54,	149.9),
		Create_Position(1514.76,	1507.7,	149.9),
	}
	
	end_locations_bladebots_preplaced = { --facing = 90
	
		Create_Position(1400.39,	1487.39,	149.9),-->preplaced guys start here
		Create_Position(1419.57,	1487.55,	149.9),
		Create_Position(1448.55,	1487.65,	149.9),
		Create_Position(1467.73,	1487.81,	149.9),
		Create_Position(1495.77,	1488.42,	149.9),
		Create_Position(1514.96,	1488.58,	149.9),
		
		Create_Position(1400.22,	1466.96,	149.9),
		Create_Position(1419.4,	1467.11,	149.9),
		Create_Position(1448.37,	1467.21,	149.9),
		Create_Position(1467.56,	1467.37,	149.9),
		Create_Position(1495.6,	1467.98,	149.9),
		Create_Position(1514.79,	1468.14,	149.9),
	}
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
	x360tut_objective01e = 1000000000 --cannot start as nil, gets redifined later
end


---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\X360 Tutorial Start!!"))
		_CustomScriptMessage("JoeLog.txt", string.format("running new scripts...check."))
		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene which all hints will be attached to / removed from.
		Register_Hint_Callback_Script(Script)
		-- ***** HINT SYSTEM *****
		
		Script.Set_Async_Data("PreventForfeit", true)
		
		Fade_Screen_Out(0)
		Lock_Controls(1)
		Change_Local_Faction("Novus")
		Lock_Out_Stuff(true)
		Define_Hints()
		
		novus.Give_Money(10000)
		novus.Make_Ally(neutral)
		neutral.Make_Ally(novus)
		
		novus.Make_Ally(aliens)--temp alliance so i can prevent 29-11 from attacking too soon.
		novus_two.Make_Ally(aliens)
		aliens.Make_Ally(novus_two)
		
		--TESTING
		UI_Hide_Research_Button(true)
		UI_Hide_Sell_Button()
		UI_Hide_Command_Bar(true)
		UI_Set_Display_Credits_Pop(false)
		Set_Hint_System_Visible(false)
		
		UI_Show_Radar_Map(false)
		--UI_Show_Controller_Context_Display(false)
		UI_Show_BattleCam_Button(false)

		Set_Level_Name("TEXT_GAMEPAD_TUTORIAL00_NAME")

	end
end


function Thread_Mission_Start()

	Create_Thread("Thread_StartUp_BladeTrooper_Lineups")
	Create_Thread("Thread_StartUp_Civilian_Spawners")
	Create_Thread("Thread_OpeningCine_Flyovers")
	
	if bool_play_opening_cine == true then
		camera01 = Find_Hint("MARKER_CAMERA","camera01")
		target01 = Find_Hint("MARKER_CAMERA","target01")
		camera02 = Find_Hint("MARKER_CAMERA","camera02")
		
		camera03 = Find_Hint("MARKER_CAMERA","camera03")
		target03 = Find_Hint("MARKER_CAMERA","target03")
		
		camera04 = Find_Hint("MARKER_CAMERA","camera04")
		target04 = Find_Hint("MARKER_CAMERA","target04")
		
		nearrange, farrange = Set_Object_Fade_Range(1200, 1600)
		oldnear, oldfar = Set_Fog_Range(550, 2000)
		
		Fade_Screen_Out(0)
		Point_Camera_At(camera_start)
		Sleep(1)
		Start_Cinematic_Camera()
		Letter_Box_In(0.1)
		
		Transition_Cinematic_Camera_Key(camera01, 0, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Target_Key(target01, 0, 0, 0, 0, 0, 0, 0, 0)
		
		Fade_Screen_In(2) 
		
		Create_Thread("Thread_OpeningCine_Flyby")
		
		Sleep(1)
		
		-- Transition_Cinematic_Camera_Key(target_pos, time, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Transition_Cinematic_Camera_Key(camera02, 10, 0, 0, 0, 0, 0, 0, 0)
		
		Sleep(2)
		BlockOnCommand(Queue_Talking_Head(pip_novscience, "TUT360_SCENE01_01")) --Novus Science (NSC): Wormhole tunneling has commenced. Quantum waveform at 20% threshold. 

		Transition_Cinematic_Target_Key(founder, 3, 0, 0, 20, 0, 0, 0, 0)
		Sleep(3)
		Create_Thread("Thread_OpeningCine_FieldInverters")
		
		blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE01_02") --Founder (FOU): Attention Novus forces! Intelligence has confirmed a Hierarchy invasion of the third planet of the Terran system, Earth. This is not a simulation.
		
		BlockOnCommand(founder.Play_Animation("Anim_Cinematic", false, 1))
		founder.Play_Animation("Anim_Cinematic", true, 4)

		BlockOnCommand(blocking_dialog)
		founder.Play_Animation("Anim_Idle", false, 4)--breaks him out of his loop
		
		Transition_Cinematic_Camera_Key(camera03, 0, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Target_Key(target03, 0, 0, 0, 0, 0, 0, 0, 0)
		
		Sleep(1)
		
		Queue_Talking_Head(pip_founder, "TUT360_SCENE01_03") --Founder (FOU): Incursion units - prepare for wormhole entry through the portal. All core routines must be verified before initiating counter-offensive. 
		Sleep(2)
		
		Transition_Cinematic_Camera_Key(camera04, 5, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Target_Key(target04, 4, 0, 0, 0, 0, 0, 0, 0)
		
		bool_alarm_set = true
		Sleep(3)
		
		if bool_Brets_stuff_fixed == true then
			robots_come_together_flag = Find_Hint("MARKER_GENERIC_RED","robots-come-together")
			robots_come_together_goto01 = Find_Hint("MARKER_GENERIC_RED","robots-come-together-goto01")
			robots_come_together_goto02 = Find_Hint("MARKER_GENERIC_RED","robots-come-together-goto02")
			robots_come_together_goto03 = Find_Hint("MARKER_GENERIC_RED","robots-come-together-goto03")
			if not TestValid(robots_come_together_flag) then
				_CustomScriptMessage("JoeLog.txt", string.format("not TestValid(robots_come_together_flag)"))
			else
				Union_Squads( robots_come_together_flag, 2000, "Novus_Team_Robotic_Infantry", "Novus_Robotic_Infantry_Solo")
			end
			
			list_new_teams = Find_All_Objects_Of_Type("Novus_Team_Robotic_Infantry", player_faction)
			for i, new_team in pairs(list_new_teams) do
				if TestValid(new_team) then
					new_team.Change_Owner(neutral)
					new_team.Set_Container_Arrangement_Type( "Novus" ) 
					if i == 1 then
						new_team.Move_To(robots_come_together_goto01)
					elseif i == 2 then
						new_team.Move_To(robots_come_together_goto02)
					else
						new_team.Move_To(robots_come_together_goto03)
					end
				end
			end
			
			list_new_teams_units = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Team_Member")
			for i, new_teams_unit in pairs(list_new_teams_units) do
				if TestValid(new_teams_unit) then
					new_teams_unit.Enable_Behavior(79, false)
				end
			end
		else
			list_starting_robots = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Solo")
			for i, starting_robot in pairs(list_starting_robots) do
				if TestValid(starting_robot) then
					starting_robot.Change_Owner(neutral)
					starting_robot.Enable_Behavior(79, false)
				end
			end
		end
		
		Sleep(3)
	
		Transition_To_Tactical_Camera(5)
		Sleep(5)
		Letter_Box_Out(1)
		
		Set_Fog_Range(oldnear, oldfar)
		Set_Object_Fade_Range(nearrange, farrange)
		
		Sleep(1)
		
		End_Cinematic_Camera()
		
		bool_conversation_over = false
		Create_Thread("Thread_Dialog_Controller", dialog_mission_intro) 
		while bool_conversation_over == false do
			Sleep(1)
		end
		
	else
	
		Fade_Screen_Out(0)
		list_flyby_units = Find_All_Objects_With_Hint("flyby")
		for i, flyby_unit in pairs(list_flyby_units) do
			if TestValid(flyby_unit) then
				flyby_unit.Despawn()
			end
		end
		
		list_starting_robots = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Solo")
		for i, starting_robot in pairs(list_starting_robots) do
			if TestValid(starting_robot) then
				starting_robot.Change_Owner(neutral)
				starting_robot.Enable_Behavior(79, false)
			end
		end
		
		if TestValid(fieldinverter01) and TestValid(fieldinverter01_final)  then
			fieldinverter01.Teleport_And_Face(fieldinverter01_final)	
			fieldinverter01.Change_Owner(neutral)
			fieldinverter01.Enable_Behavior(79, false)
		end
		
		if TestValid(fieldinverter02) and TestValid(fieldinverter02_final)  then
			fieldinverter02.Teleport_And_Face(fieldinverter02_final)	
			fieldinverter02.Change_Owner(neutral)
			fieldinverter02.Enable_Behavior(79, false)
		end
		
		if TestValid(fieldinverter03) and TestValid(fieldinverter03_final)  then
			fieldinverter03.Teleport_And_Face(fieldinverter03_final)	
			fieldinverter03.Change_Owner(neutral)
			fieldinverter03.Enable_Behavior(79, false)
		end
		
		Point_Camera_At(camera_start)
		Sleep(1)
		Start_Cinematic_Camera()
		Letter_Box_In(0.1)

		Transition_Cinematic_Target_Key(camera_start, 0, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Camera_Key(camera_start, 0, 200, 55, 65, 1, 0, 0, 0)

		Fade_Screen_In(2) 
		
		Transition_To_Tactical_Camera(5)
		Sleep(5)
		Letter_Box_Out(1)
		
		Sleep(1)
		
		End_Cinematic_Camera()
	end
	
	Set_Next_State("State_CameraControls")
	
	--TESTING STATES
	--Set_Next_State("State_SelectionAndMovement")
	--Set_Next_State("State_Construction")
	--Set_Next_State("State_Heroes")
	--Set_Next_State("State_Research")
	--Set_Next_State("State_Groups")
	
	Lock_Controls(0)
	
	Sleep(10)
	--locking out all research here...needs this artificial delay due to some sort
	--of conflicting init behavior.
	player_script = novus.Get_Script()
	player_script.Call_Function("Block_Research_Branch","A",true,true)
	player_script.Call_Function("Block_Research_Branch","B",true,true)
	player_script.Call_Function("Block_Research_Branch","C",true,true)
	
end

function Thread_OpeningCine_Flyovers()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_OpeningCine_Flyovers HIT!!"))
	
	list_corruptor_flyovers =  Find_All_Objects_With_Hint("starting-flyover", "MOV_FLYOVER_CORRUPTOR")
	list_fast_corruptor_flyovers = Find_All_Objects_With_Hint("starting-flyover", "MOV_FLYOVER_CORRUPTOR_FAST")
	list_dervish_flyovers = Find_All_Objects_With_Hint("starting-flyover", "MOV_FLYOVER_DERVISH")
	
	for i, dervish in pairs(list_dervish_flyovers) do
		if TestValid(dervish) then
			Create_Thread("Thread_StartingCine_Flyover", dervish)
			--_CustomScriptMessage("JoeLog.txt", string.format("Create_Thread(Thread_StartingFoo_Flyover, dervish)"))
		end
	end
	
	Sleep(3)
	
	for i, corruptor in pairs(list_corruptor_flyovers) do
		if TestValid(corruptor) then
			Create_Thread("Thread_StartingCine_Flyover", corruptor)
			--_CustomScriptMessage("JoeLog.txt", string.format("Create_Thread(Thread_StartingFoo_Flyover, corruptor)"))
		end
	end
	
	Sleep(3)
	
	for i, fast_corruptor in pairs(list_fast_corruptor_flyovers) do
		if TestValid(fast_corruptor) then
			Create_Thread("Thread_StartingCine_Flyover", fast_corruptor)
			--_CustomScriptMessage("JoeLog.txt", string.format("Create_Thread(Thread_StartingFoo_Flyover, fast_corruptor)"))
		end
	end
	
	Sleep(10)
	
	Create_Thread("Thread_Cinematic_Flyovers")
end

function Thread_StartingCine_Flyover(flyover)
	if TestValid(flyover) then
		flyover.Hide(false)

		BlockOnCommand(flyover.Play_Animation("Anim_Cinematic", false, 0))

		flyover.Despawn()
	end
end

function Thread_OpeningCine_Flyby()
	list_flyby_units = Find_All_Objects_With_Hint("flyby")
	flyby_goto = Find_Hint("MARKER_GENERIC_RED","flyby-goto")
	
	for i, flyby_unit in pairs(list_flyby_units) do
		if TestValid(flyby_unit) then
			flyby_unit.Move_To(flyby_goto.Get_Position())
		end
	end
	
	Sleep(20)
	
	for i, flyby_unit in pairs(list_flyby_units) do
		if TestValid(flyby_unit) then
			flyby_unit.Despawn()
		end
	end
end

function Thread_OpeningCine_FieldInverters()
	if TestValid(fieldinverter01) and TestValid(fieldinverter_goto01) then
		fieldinverter01.Move_To(fieldinverter_goto01.Get_Position())
	end
	
	if TestValid(fieldinverter02) and TestValid(fieldinverter_goto01) then
		fieldinverter02.Move_To(fieldinverter_goto01.Get_Position())
	end
	
	if TestValid(fieldinverter03) and TestValid(fieldinverter_goto02) then
		fieldinverter03.Move_To(fieldinverter_goto02.Get_Position())
	end
	
	while bool_alarm_set == false do
		Sleep(1)
	end
	
	if TestValid(fieldinverter01) then
		fieldinverter01.Stop()
	end
	
	if TestValid(fieldinverter02) then
		fieldinverter02.Stop()
	end
	
	if TestValid(fieldinverter03) then
		fieldinverter03.Stop()
	end
	
	Sleep(4)
	
	if TestValid(fieldinverter01) and TestValid(fieldinverter_goto02) then
		fieldinverter01.Move_To(fieldinverter_goto02.Get_Position())
	end
	
	if TestValid(fieldinverter02) and TestValid(fieldinverter_goto02) then
		fieldinverter02.Move_To(fieldinverter_goto02.Get_Position())
	end
	
	if TestValid(fieldinverter03) and TestValid(fieldinverter_goto02) then
		fieldinverter03.Move_To(fieldinverter_goto02.Get_Position())
	end
	
	Sleep(10)
	
	if TestValid(fieldinverter01) and TestValid(fieldinverter01_final)  then
		fieldinverter01.Teleport_And_Face(fieldinverter01_final)	
		fieldinverter01.Change_Owner(neutral)
		fieldinverter01.Enable_Behavior(79, false)
	end
	
	if TestValid(fieldinverter02) and TestValid(fieldinverter02_final)  then
		fieldinverter02.Teleport_And_Face(fieldinverter02_final)	
		fieldinverter02.Change_Owner(neutral)
		fieldinverter02.Enable_Behavior(79, false)
	end
	
	if TestValid(fieldinverter03) and TestValid(fieldinverter03_final)  then
		fieldinverter03.Teleport_And_Face(fieldinverter03_final)	
		fieldinverter03.Change_Owner(neutral)
		fieldinverter03.Enable_Behavior(79, false)
	end
	
end


--***********************************************************************************************
function Thread_Recycle_Objectives(objective)
	local objective_version = 1 --we cycle different worded objective text so this just helps determine which one was last displayed
	local original_string = nil
	local v2_string = nil
	local v3_string = nil
	
	--see which objective you are and define the variants
	if objective == x360tut_objective01a then --x360tut_objective01a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01a")--Move the left stick in any direction to scroll the camera.
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective01a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01a"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01a_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01a_v3"
	elseif objective == x360tut_objective01b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective01b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01b"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01b_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01b_v3"
	elseif objective == x360tut_objective01c then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective01c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01c"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01c_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01c_v3"
	elseif objective == x360tut_objective01d then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective01d"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01d"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01d_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01d_v3"
	elseif objective == x360tut_objective01e then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective01e"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01e"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01e_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01e_v3"
	elseif objective == x360tut_objective01f then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective01f"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01f"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01f_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01f_v3"
	
	elseif objective == x360tut_objective03a then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective03a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03a"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03a_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03a_v3"
	elseif objective == x360tut_objective03b then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective03b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03b"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03b_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03b_v3"
	elseif objective == x360tut_objective03c then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective03c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03c"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03c_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03c_v3"
	
	elseif objective == x360tut_objective04a then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective04a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04a"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04a_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04a_v3"
	elseif objective == x360tut_objective04c then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective04c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04c"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04c_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04c_v3"
	elseif objective == x360tut_objective04d then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective04d"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04d"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04d_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04d_v3"
		
	elseif objective == x360tut_objective05a then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05a"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05a_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05a_v3"
	elseif objective == x360tut_objective05b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05b"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05b_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05b_v3"
	elseif objective == x360tut_objective05c then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05c"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05c_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05c_v3"
	elseif objective == x360tut_objective05d then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05d"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05d"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05d_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05d_v3"
	elseif objective == x360tut_objective05e then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05e"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05e"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05e_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05e_v3"
	elseif objective == x360tut_objective05f then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05f"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05f"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05f_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05f_v3"
	elseif objective == x360tut_objective05g then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05g"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05g"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05g_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05g_v3"
	elseif objective == x360tut_objective05h then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective05h"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05h"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05h_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05h_v3"
		
	elseif objective == x360tut_objective07a then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective07a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07a"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07a_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07a_v3"
	elseif objective == x360tut_objective07b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective07b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07b"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07b_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07b_v3"
	elseif objective == x360tut_objective07c then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective07c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07c"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07c_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07c_v3"
		
	elseif objective == x360tut_objective08a then 
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective08a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08a"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08a_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08a_v3"
	elseif objective == x360tut_objective08b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_objective08b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08b"
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08b_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08b_v3"
		
	--start of group objectives
	elseif objective == x360tut_group_objective01a then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective01a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06b"--Select all the Antimatter Tanks using the group tool.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06b_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06b_v3"
	elseif objective == x360tut_group_objective01b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective01b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c"--Move all the Antimatter Tanks to the location flashing on the radar map.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c_v3"
	elseif objective == x360tut_group_objective01c then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective01c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c2"--Move all the Antimatter Tanks to the portal staging area.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c2_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c2_v3"
		
	elseif objective == x360tut_group_objective02a then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective02a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06d"--Select all the Blade Troopers using the group tool.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06d_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06d_v3"
	elseif objective == x360tut_group_objective02b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective02b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06e"--Move all the Blade Troopers to the portal staging area.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06e_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06e_v3"
		
	elseif objective == x360tut_group_objective03a then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective03a"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06f"--Select all the Amplifiers using the group tool.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06f_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06f_v3"
	elseif objective == x360tut_group_objective03b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective03b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g"--Move all the Amplifiers to the location flashing on the radar map.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g_v3"
	elseif objective == x360tut_group_objective03c then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective03c"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g2"--Move the Amplifiers to the portal staging area.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g2_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g2_v3"
		
	elseif objective == x360tut_group_objective04 then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective04"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06h"--Combine Mirabel and Victor into their own control group.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06h_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06h_v3"	
	elseif objective == x360tut_group_objective04b then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Recycle_Objectives: x360tut_group_objective04b"))
		original_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06i"--Move Mirabel and Victor to the portal staging area.
		v2_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06i_v2"
		v3_string = "TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06i_v3"		
	end
	
	while objective ~= nil do
		Sleep(20)
		if objective == nil then--if objective has been cleared end this thred
			return
		end
		objective_version = objective_version + 1
		if objective_version == 4 then
			objective_version = 2 -- no longer cycling original thread in...its perma-displayed as an objective.
		end
		
		if objective_version == 1 then
			Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {original_string} )
		elseif objective_version == 2 then
			Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {v2_string} )
		elseif objective_version == 3 then
			Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {v3_string} )
		end
		
	end
end
---------------------------------------------------------------------------------------------------
------JDG: Objectives:
--camera controls
---------------------------------------------------------------------------------------------------
function State_CameraControls(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_CameraControls Start!!"))
		
		Create_Thread("Thread_Obj01_CameraControls_Setup")
	end
end

function Thread_Obj01_CameraControls_Setup()
	if bool_restarting_camera == true then
		--make sure everything is reset and  re-setup for this objective here
		if x360tut_objective01 ~= nil then
			Delete_Objective(x360tut_objective01)
		end
		
		if x360tut_objective01a ~= nil then
			Delete_Objective(x360tut_objective01a)
		end
		
		if x360tut_objective01b ~= nil then
			Delete_Objective(x360tut_objective01b)
		end
		
		if x360tut_objective01c ~= nil then
			Delete_Objective(x360tut_objective01c)
		end
		
		if x360tut_objective01d ~= nil then
			Delete_Objective(x360tut_objective01d)
		end
		
		if x360tut_objective01e ~= nil then
			Delete_Objective(x360tut_objective01e)
		end
		
		if x360tut_objective01f ~= nil then
			Delete_Objective(x360tut_objective01f)
		end
		
		if thread_id_camera_controls then
			Thread.Kill(thread_id_camera_controls)
		end

		if thread_id_camera_scroll_around then
			Thread.Kill(thread_id_camera_scroll_around)
		end
		
		if thread_id_camera_zoom_in then
			Thread.Kill(thread_id_camera_zoom_in)
		end
		
		if thread_id_camera_zoom_out then
			Thread.Kill(thread_id_camera_zoom_out)
		end
		
		if thread_id_camera_rotate then
			Thread.Kill(thread_id_camera_rotate)
		end
		
		if thread_id_camera_reset then
			Thread.Kill(thread_id_camera_reset)
		end
		
		if thread_id_camera_jump_to_location then
			Thread.Kill(thread_id_camera_jump_to_location)
		end
		
		if thread_id_camera_clear_all_objectives then
			Thread.Kill(thread_id_camera_clear_all_objectives)
		end
		
		Remove_Radar_Blip("blip_radarcontrol_jumpto")
	
		Point_Camera_At(camera_start)
		Fade_Screen_In(1)
		Lock_Controls(0)
	end
	
	x360tut_objective01 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01")--Learn how to use the camera.
	thread_id_camera_scroll_around = Create_Thread("Thread_Obj01_CameraControls_ScrollAround")
end

function Thread_Obj01_CameraControls_ScrollAround()
	Lock_Controls(0)

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01a_ADD"} )--Scroll the camera by doing X.
	thread_id_camera_zoom_in = Create_Thread("Thread_Obj01_CameraControls_ZoomIn") --monitors for scrolling
	Sleep(time_objective_sleep)
	
	x360tut_objective01a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01a")--Scroll the camera by doing X.
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective01a)
	
	while bool_camera_scrolled == false do
		Sleep(1)
	end
	
	Lock_Controls(0)
	
	if x360tut_objective01a~= nil then
		Objective_Complete(x360tut_objective01a)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_camera_zoom_in) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	Lock_Controls(0)
	
	bool_camera_zoomed_in = false
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01b_ADD"} )--Zoom in the camera by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective01b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01b")--Zoom in the camera by doing X.
	
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end

	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective01b)

	thread_id_camera_zoom_out = Create_Thread("Thread_Obj01_CameraControls_ZoomOut")
	
	
end

function Thread_Obj01_CameraControls_ZoomIn()

	initial_cam_settings = Get_Camera_Settings()
	
	starting_x = initial_cam_settings[5]
	starting_y = initial_cam_settings[6]
	_CustomScriptMessage("JoeLog.txt", string.format("starting_x = %d", starting_x))
	_CustomScriptMessage("JoeLog.txt", string.format("starting_y = %d", starting_y))

	while true do
		Sleep(1)
		
		current_cam_settings = Get_Camera_Settings()
		current_x = current_cam_settings[5]
		current_y = current_cam_settings[6]
		
		_CustomScriptMessage("JoeLog.txt", string.format("delta_x = %d", Abs(starting_x - current_x)))
		_CustomScriptMessage("JoeLog.txt", string.format("delta_y = %d", Abs(starting_y - current_y)))
		
		scroll_value = 30
		if Max(Abs(starting_x - current_x), Abs(starting_y - current_y)) > scroll_value then
			break
		end
		
	end
	
	bool_camera_scrolled = true
	
end

function Thread_Obj01_CameraControls_ZoomOut()
	
	while not bool_camera_zoomed_in do
		Sleep(1)
		--_CustomScriptMessage("JoeLog.txt", string.format("while not bool_camera_zoomed_in do"))
	end
	_CustomScriptMessage("JoeLog.txt", string.format("zoom detected?"))
	
	if x360tut_objective01b~= nil then
		Objective_Complete(x360tut_objective01b)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end

	thread_id_camera_rotate = Create_Thread("Thread_Obj01_CameraControls_Rotate")
end

function Thread_Obj01_CameraControls_Rotate()
	
	--while not bool_camera_zoomed_out do
	--	Sleep(1)
		--_CustomScriptMessage("JoeLog.txt", string.format("while not bool_camera_zoomed_out do"))
	--end
	
	if x360tut_objective01c~= nil then
		Objective_Complete(x360tut_objective01c)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_camera_rotate) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	bool_camera_rotated = false
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01d_ADD"} )--Rotate the camera by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective01d = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01d")--Rotate the camera by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective01d)

	thread_id_camera_reset = Create_Thread("Thread_Obj01_CameraControls_Reset")
end

function Thread_Obj01_CameraControls_Reset()
	
	while not bool_camera_rotated do
		Sleep(1)
		--_CustomScriptMessage("JoeLog.txt", string.format("while not bool_camera_rotated do"))
	end
	_CustomScriptMessage("JoeLog.txt", string.format("camera rotation detected?"))
	
	if x360tut_objective01d~= nil then
		Objective_Complete(x360tut_objective01d)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	--Sleep(5)
	
	Lock_Controls(0)
	
	--in prep for new dialog regarding resetting the camera
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_reset_camera_now) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	bool_camera_reset = false
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01e_ADD"} )--Reset the camera by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective01e = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01e")--Reset the camera by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective01e)

	thread_id_camera_jump_to_location = Create_Thread("Thread_Obj01_CameraControls_JumpToLocation")
end

function Thread_Obj01_CameraControls_JumpToLocation()
	
	while not bool_camera_reset do
		Sleep(1)
	end

	if x360tut_objective01e~= nil then
		Objective_Complete(x360tut_objective01e)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	if x360tut_objective01e~= nil then
		x360tut_objective01e = nil
	end
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_camera_reset) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	
	

	thread_id_camera_clear_all_objectives = Create_Thread("Thread_Obj01_CameraControls_ClearAllObjectives")
end

function Thread_Obj01_CameraControls_ClearAllObjectives()

	
	
	if x360tut_objective01~= nil then
		Delete_Objective(x360tut_objective01)
	end
	
	Set_Next_State("State_SelectionAndMovement")
end
---------------------------------------------------------------------------------------------------
--selection and movement
---------------------------------------------------------------------------------------------------
function State_SelectionAndMovement(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_SelectionAndMovement Start!!"))
		
		Create_Thread("Thread_Obj03_SelectionAndMovement_Setup")
	end
end

function Thread_Obj03_SelectionAndMovement_Setup()
	if bool_restarting_selectionAndMovement == true then
		if x360tut_objective03 ~= nil then
			Delete_Objective(x360tut_objective03)
		end
		
		if x360tut_objective03a ~= nil then
			Delete_Objective(x360tut_objective03a)
		end
		
		if x360tut_objective03b ~= nil then
			Delete_Objective(x360tut_objective03b)
		end
		
		if x360tut_objective03c ~= nil then
			Delete_Objective(x360tut_objective03c)
		end
	
	--Kill any potentially running threads
		if thread_id_SandM_select2911 then
			Thread.Kill(thread_id_SandM_select2911)
		end
		
		if thread_id_SandM_move2911 then
			Thread.Kill(thread_id_SandM_move2911)
		end
		
		if thread_id_SandM_move2911_via_radar then
			Thread.Kill(thread_id_SandM_move2911_via_radar)
		end
		
		if thread_id_SandM_move2911_clear_all_objectives then
			Thread.Kill(thread_id_SandM_move2911_clear_all_objectives)
		end
		
		--Kill any potentially running PROX-events
		moveto_2911_01.Cancel_Event_Object_In_Range(Prox_2911_Move01)
		--moveto_2911_02.Cancel_Event_Object_In_Range(Prox_2911_Move02)
		
		if TestValid(trooper_29_11) then
			trooper_29_11.Teleport_And_Face(trooper_29_11_startspot)
			trooper_29_11.Set_Selectable(false)
			trooper_29_11.Set_Cannot_Be_Killed(true)
			trooper_29_11.Highlight(false)
		end
		
		--need to kill any highlight arrows that might be lingering, too
		moveto_2911_01.Highlight(false)
		
		if TestValid(ground_highlight_2911_01) then
			ground_highlight_2911_01.Despawn()
		end
		
		if TestValid(ground_higlight_moveto_2911_01) then
			ground_higlight_moveto_2911_01.Despawn() 
		end
		
		Remove_Radar_Blip("blip_trooper_29_11")
		Remove_Radar_Blip("blip_moveto_2911_01")
		Remove_Radar_Blip("blip_moveto_2911_02")
		
	
		Fade_Screen_In(1)
		Lock_Controls(0)
	end
	
	bool_show_radar_map = true
	UI_Show_Radar_Map(true)
	
	thread_id_SandM_select2911 = Create_Thread("Thread_Obj03_SelectionAndMovement_Select29_11")
end

function Thread_Obj03_SelectionAndMovement_Select29_11()

	--if TestValid(trooper_29_11) then
	--	Point_Camera_At(trooper_29_11)
	--end

	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_select_2911) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
		--locking out X-button per tim
		Controller_Set_Tactical_Component_Lock("X_BUTTON",true)
	end
	
	if TestValid(trooper_29_11) then
		trooper_29_11.Set_Selectable(true)
	end
	
	x360tut_objective03 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03")--Learn how to use the radar map.

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03a_ADD"} )--Select BladeBot 29-11 by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective03a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03a")--Select BladeBot 29-11 by doing X.
	
	
	if thread_id_objective_reminders~= nil then
		if Thread.Is_Thread_Active(thread_id_objective_reminders) then
			Thread.Kill(thread_id_objective_reminders)
		end
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective03a)

	thread_id_SandM_move2911 = Create_Thread("Thread_Obj03_SelectionAndMovement_Move29_11")
end

function Thread_29_11_Flyby(dude)
	local despawn_flag = Find_Hint("MARKER_GENERIC_PURPLE","01b")
	if TestValid(dude) then
		BlockOnCommand(dude.Move_To(despawn_flag.Get_Position()))
	end
	
	if TestValid(dude) then
		dude.Despawn()
	end
	
end

function Thread_Obj03_SelectionAndMovement_Move29_11()

	while trooper_29_11.Is_Selected() == false do
		Sleep(1)
		--_CustomScriptMessage("JoeLog.txt", string.format("Sleep(1) waiting for player to select 29-11"))
	end
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
		--locking out X-button per tim
		Controller_Set_Tactical_Component_Lock("X_BUTTON",false)
	end
	
	local flyby_guys = Find_All_Objects_With_Hint("driveby-2911")
	for i, flyby_guy in pairs(flyby_guys) do
		if TestValid(flyby_guy) then
			Create_Thread("Thread_29_11_Flyby", flyby_guy)
		end
	end
	
	if TestValid(trooper_29_11) then
		trooper_29_11.Highlight(false)
		Remove_Radar_Blip("blip_trooper_29_11")
	end
	
	if TestValid(ground_highlight_2911_01) then
		ground_highlight_2911_01.Despawn()
	end
	
	if x360tut_objective03a~= nil then
		Objective_Complete(x360tut_objective03a)
		x360tut_objective03a = nil
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_move_2911) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	if not TestValid(moveto_2911_01) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(2911_moveto_01) "))
	else
		Register_Prox(moveto_2911_01, Prox_2911_Move01, 30, player_faction)
		moveto_2911_01.Highlight(true, -50)
		ground_higlight_moveto_2911_01 = Create_Generic_Object(Find_Object_Type("Highlight_Area"), moveto_2911_01, neutral)
		Add_Radar_Blip(moveto_2911_01, "DEFAULT", "blip_moveto_2911_01")
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03b_ADD"} )--Move 29-11 to the indicated location by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective03b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03b")--Move 29-11 to the indicated location by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective03b)

end

function Prox_2911_Move01(prox_obj, trigger_obj)
	if trigger_obj == trooper_29_11 then
		prox_obj.Cancel_Event_Object_In_Range(Prox_2911_Move01)

		thread_id_SandM_move2911_via_radar = Create_Thread("Thread_Obj03_SelectionAndMovement_Move29_11_ViaRadarMap")
		
		
	end
end

function Thread_Obj03_SelectionAndMovement_MakeSure_2911_Is_Selected()
	while true do
		Sleep(0.1)
		if trooper_29_11.Is_Selected() == false then
			novus.Select_Object(trooper_29_11)
			_CustomScriptMessage("JoeLog.txt", string.format("novus.Select_Object(trooper_29_11) "))
		end
		
		if bool_2911_moved_via_radar == true then--event is over...stop forcing the selection
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj03_SelectionAndMovement_MakeSure_2911_Is_Selected bool_2911_moved_via_radar == true "))
			return
		end
	end
end

function Thread_Obj03_SelectionAndMovement_Move29_11_ViaRadarMap()
	
	--if TestValid(trooper_29_11) then
	--	Point_Camera_At(trooper_29_11)
	--end
	--Sleep(1)
	
	
	if TestValid(trooper_29_11) then
		BlockOnCommand(trooper_29_11.Move_To(moveto_2911_01.Get_Position()))
		trooper_29_11.Stop()
		Sleep(1)
		trooper_29_11.Suspend_Locomotor(true)
	end
	
	while x360tut_objective03b == nil do -- safety sleep cause player can do this objective before the various timers time-out
		Sleep(1)
	end
	
	if x360tut_objective03b ~= nil then
		Objective_Complete(x360tut_objective03b)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	moveto_2911_01.Highlight(false)
	if ground_higlight_moveto_2911_01 ~= nil then
		ground_higlight_moveto_2911_01.Despawn()
	end
	Remove_Radar_Blip("blip_moveto_2911_01")
	
	
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_move_2911_via_radarmap) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	--Create_Thread("Thread_Obj03_SelectionAndMovement_MakeSure_2911_Is_Selected")
	
	--testing the radar map thingy
	if TestValid(trooper_29_11) then
		trooper_29_11.Register_Signal_Handler(Callback_On_Radar_Move,"RADAR_MOVE_ISSUED")
	end
	
	if TestValid(trooper_29_11) then
		Point_Camera_At(trooper_29_11)
	end
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
		
		Controller_Set_Tactical_Component_Lock("ALL",true)
		Controller_Set_Tactical_Scroll_Lock(true)

		-- Maria 12.04.2007: we are back to the old scheme so now the right trigger brings up the minimap.
		Controller_Set_Tactical_Component_Lock("RIGHT_TRIGGER",false) -- so player can open the mini-map (old controller scheme)
		--Controller_Set_Tactical_Component_Lock("RIGHT_SHOULDER_BUTTON",false) -- so player can open the mini-map
		Controller_Set_Tactical_Component_Lock("RIGHT_STICK",false) -- so player can direct his cursor on the mini-map
		Controller_Set_Tactical_Component_Lock("A_BUTTON",false) -- need A button for movement order
	end
	
	if trooper_29_11.Is_Selected() == false then
		novus.Select_Object(trooper_29_11)
		_CustomScriptMessage("JoeLog.txt", string.format("novus.Select_Object(trooper_29_11) "))

	end
	
	if not TestValid(moveto_2911_02) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(2911_moveto_02) "))
	else
		--Register_Prox(moveto_2911_02, Prox_2911_Move02, 50, player_faction)
		moveto_2911_02.Highlight(true, -50)
		ground_higlight_moveto_2911_02 = Create_Generic_Object(Find_Object_Type("Highlight_Area"), moveto_2911_02, neutral)
		Add_Radar_Blip(moveto_2911_02, "DEFAULT", "blip_moveto_2911_02")
	end

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03c_ADD"} )--Move 29-11 to the indicated location via the radar map by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective03c = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_03c")--Move 29-11 to the indicated location via the radar map by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective03c)

end

function Callback_On_Radar_Move(object, radar_move_postion)
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_On_Radar_Move HIT!!"))
	if object ~= trooper_29_11 then
		return
	end
	
	local tracking_distance = 75
	if moveto_2911_02.Get_Distance( radar_move_postion ) <= tracking_distance then
		_CustomScriptMessage("JoeLog.txt", string.format("moveto_2911_02.Get_Distance( radar_move_postion ) <= tracking_distance"))
		--Lock_Controls(1)
		
		--jdg 2/27/08 attempt to fix a weird magnetism issue
		if TestValid(trooper_29_11) then
			trooper_29_11.Set_Selectable(false)
		end
	
	
		trooper_29_11.Suspend_Locomotor(false)
		trooper_29_11.Move_To(moveto_2911_02.Get_Position())
		
		object.Unregister_Signal_Handler(Callback_On_Radar_Move)--player has followed orders...stop tracking this, please
		
		UI_Radar_Map_Zoom_Out()--fixes a bug where the radar map would get locked up invisibly when I lock out controls
		
		--Create_Thread("Thread_Camera_Follows_2911")
		
		Thread.Kill(thread_id_objective_reminders)--turning off the objective reminders once player goes into cine mode here
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
		
		bool_2911_moved_via_radar = true
		
		moveto_2911_02.Highlight(false)
		if TestValid(ground_higlight_moveto_2911_02) then
			ground_higlight_moveto_2911_02.Despawn()
		end
		Remove_Radar_Blip("blip_moveto_2911_02")
		

		Create_Thread("Thread_Obj03_SelectionAndMovement_Scroll_ViaRadarMap")
		
		Create_Thread("Thread_StartUp_OhmBot_Lineups")
	end
end



function Thread_Obj03_SelectionAndMovement_Scroll_ViaRadarMap()
	--UI_Show_Radar_Map(true)
	

	
	while bool_2911_moved_via_radar == false do
		Sleep(1)
	end
	
	while x360tut_objective03c == nil do
		Sleep(1)
	end
	

	Objective_Complete(x360tut_objective03c)
	x360tut_objective03c = nil
	_CustomScriptMessage("NaderLog.txt", string.format("Setting x360tut_objective03c to nil."))
	Thread.Kill(thread_id_objective_reminders)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
		--Point_Camera_At(trooper_29_11)

		Controller_Set_Tactical_Component_Lock("ALL",true)
		Controller_Set_Tactical_Scroll_Lock(true)

		-- Maria 12.04.2007: we are back to the old scheme so now the right trigger brings up the minimap.
		Controller_Set_Tactical_Component_Lock("RIGHT_TRIGGER",false) -- so player can open the mini-map (old controller scheme)
		Controller_Set_Tactical_Component_Lock("LEFT_STICK",false) -- so player can scroll with radar map
		--Controller_Set_Tactical_Component_Lock("A_BUTTON",false) -- need A button for movement order
	end
	
	--insert dialog here
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_scroll_via_radarmap) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01f_ADD"} )--Jump to the indicated location by X.
	
	if not TestValid(moveto_2911_02) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: not TestValid(marker_radarcontrol_jumpto)"))
	else
		Add_Radar_Blip(moveto_2911_02, "DEFAULT", "blip_radarcontrol_jumpto")
		moveto_2911_02.Highlight(true)
		ground_highlight_marker_radarcontrol_jumpto = Create_Generic_Object(Find_Object_Type("Highlight_Area"), moveto_2911_02, neutral)
	end
	
	Sleep(1)
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(140)
	end
	Sleep(time_objective_sleep)
	
	x360tut_objective01f = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_01f")--Jump to the indicated location by X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective01f)
	
	
	
	
	while not Is_On_Screen(moveto_2911_02) do
		Sleep(1)
	end
	
	--jdg 2/27/08 attempt to fix a weird magnetism issue
	if TestValid(trooper_29_11) then
		trooper_29_11.Set_Selectable(true)
	end
	
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Controller_Set_Tactical_Scroll_Lock(false) -- reset
	end
	
	--Remove_Radar_Blip("blip_radarcontrol_jumpto")
	--moveto_2911_02.Highlight(false)
	--if ground_highlight_marker_radarcontrol_jumpto ~= nil then
	--	ground_highlight_marker_radarcontrol_jumpto.Despawn()
	--end

	if x360tut_objective01f~= nil then
		Objective_Complete(x360tut_objective01f)
		x360tut_objective01f = nil
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	thread_id_SandM_move2911_clear_all_objectives = Create_Thread("Thread_Obj03_SelectionAndMovement_ClearAllObjectives")
	
end

function Thread_Obj03_SelectionAndMovement_ClearAllObjectives()
	if x360tut_objective03c ~= nil then
		Objective_Complete(x360tut_objective03c)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	moveto_2911_02.Highlight(false)
	if ground_highlight_marker_radarcontrol_jumpto ~= nil then
		ground_highlight_marker_radarcontrol_jumpto.Despawn()
	end
	Remove_Radar_Blip("blip_radarcontrol_jumpto")
	
	if x360tut_objective03~= nil then
		Delete_Objective(x360tut_objective03)
	end
	
	Set_Next_State("State_Combat")
end

---------------------------------------------------------------------------------------------------
--Combat stuff
---------------------------------------------------------------------------------------------------
function State_Combat(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_Combat Start!!"))
		Create_Thread("Thread_Obj04_Combat_Setup")
	end
end

function Thread_Obj04_Combat_Setup()
	if bool_restarting_combat == true then
		--delete any pre-existing objectives
		if x360tut_objective04 ~= nil then
			Delete_Objective(x360tut_objective04)
		end
		
		if x360tut_objective04a ~= nil then
			Delete_Objective(x360tut_objective04a)
		end
		
		--get rid of any duplicate-blade troopers
		list_duplicates = Find_All_Objects_Of_Type("Novus_Reflex_Trooper_Clone")
		for i, duplicate in pairs(list_duplicates) do
			if TestValid(duplicate) then
				duplicate.Despawn()
			end
		end
		
		--get rid of any robot death clones that might be lingering and potentially causing issues
		list_robot_death_clones = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Death_Clone_Resource")
		for i, death_clone in pairs(list_robot_death_clones) do
			if TestValid(death_clone) then
				death_clone.Despawn()
			end
		end
		
		--first, delete any existing robotic infantry....
		list_current_robots = Find_All_Objects_Of_Type("X360_Tutorial_OhmBot")
		for i, robotic_infantry in pairs(list_current_robots) do
			if TestValid(robotic_infantry) then
				robotic_infantry.Despawn()
			end
		end
		
		--now respawn where needed....using YELLOW flags for this
		list_new_robot_flags = Find_All_Objects_Of_Type("MARKER_GENERIC_YELLOW")
		for i, robot_flag in pairs(list_new_robot_flags) do
			local new_robot = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry"), robot_flag, novus) 
			new_robot.Teleport_And_Face(robot_flag)
			new_robot.Set_Hint(robot_flag.Get_Hint())
			new_robot.Set_Selectable(false)
			new_robot.Prevent_All_Fire(true)
			new_robot.Prevent_Opportunity_Fire(true)
			new_robot.Enable_Behavior(79, false)
		end
		
		--put 29-11 on his mark
		combat_start_2911 = Find_Hint("MARKER_GENERIC_GREEN","combat-start-2911")
		if TestValid(combat_start_2911) then
			if TestValid(trooper_29_11) then
				trooper_29_11.Despawn() -- killing old one so that we can re-set his "duplicate" timer easily.
				trooper_29_11 = Spawn_Unit(Find_Object_Type("X360_Tutorial_29-11"), combat_start_2911, novus) 
				trooper_29_11.Teleport_And_Face(combat_start_2911)
				
				player_faction.Lock_Unit_Ability("X360_Tutorial_29-11", "Unit_Ability_Spawn_Clones",true,STORY)
			end
		end
		
		Point_Camera_At(trooper_29_11)
		
		robotic_malfunctioner_leader = Find_Hint("X360_Tutorial_OhmBot","robotic-leader")
		if not TestValid(robotic_malfunctioner_leader) then
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  Thread_Obj04_Combat_Setup tutorial: not TestValid(robotic_malfunctioner_leader)"))
		end
		
		Fade_Screen_In(1)
		Lock_Controls(0)
	end

	Create_Thread("Thread_Obj04_Combat")
end

function Thread_Obj04_Combat()
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_move_2911_via_radarmap_done) --this is also the start of combat training
end

function Thread_Obj04_Combat_AttackArea()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj04_Combat_AttackArea HIT!"))

	--robot-leader goes bad here
	list_all_robotic_infantries = Find_All_Objects_Of_Type("X360_Tutorial_OhmBot")
	for i, robotic_infantry in pairs(list_all_robotic_infantries) do
		if TestValid(robotic_infantry) then
			robotic_infantry.Prevent_Opportunity_Fire(false)
			robotic_infantry.Make_Invulnerable(true)
		end
	end
	
	if not TestValid(robotic_malfunctioner_leader) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: not TestValid(robotic_malfunctioner_leader)"))
		--ScriptExit()
	else
		_CustomScriptMessage("JoeLog.txt", string.format("spawning robotic_malfunctioner_leader"))
		local new_robot = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry"), robotic_malfunctioner_leader, aliens) 
		new_robot.Teleport_And_Face(robotic_malfunctioner_leader)
		robotic_malfunctioner_leader.Despawn()
		robotic_malfunctioner_leader = new_robot
		robotic_malfunctioner_leader.Set_Hint("robotic-malfunction")
		robotic_malfunctioner_leader.Attach_Particle_Effect("Novus_Virus_stage_one_particle")
		robotic_malfunctioner_leader.Prevent_All_Fire(false)
		robotic_malfunctioner_leader.Change_Owner(aliens)
		robotic_malfunctioner_leader.Highlight_Small(true)
		Add_Radar_Blip(robotic_malfunctioner_leader, "DEFAULT", "blip_robotic_malfunctioner_leader")
		robotic_malfunctioner_leader.Register_Signal_Handler(Callback_Robotic_Malfunctioner_Leader_Attacked, "OBJECT_DAMAGED")
		robotic_malfunctioner_leader.Guard_Target(robotic_malfunctioner_leader.Get_Position())
		robotic_malfunctioner_leader.Make_Invulnerable(false)
		robotic_malfunctioner_leader.Set_Cannot_Be_Killed(true)
		
		robotic_malfunctioner_leader.Suspend_Locomotor(true)
	end 
	
	_CustomScriptMessage("JoeLog.txt", string.format("Create_Thread(Move_Camera_To,robotic_malfunctioner_leader)"))
	Create_Thread("Move_Camera_To",robotic_malfunctioner_leader)
	
	aliens.Make_Enemy(novus_two)
	
	while bool_conversation_over == false do
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj04_Combat_AttackArea: while bool_conversation_over == false do"))
		Sleep(1)
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj04_Combat_AttackArea: novus.Make_Enemy(aliens)"))
	novus.Make_Enemy(aliens)	
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
		Controller_Set_Tactical_Component_Lock("NONE",true)
		Controller_Set_Tactical_Scroll_Lock(false)
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj04_Combat_AttackArea: Lock_Controls(0)"))
	
	x360tut_objective04 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04")--Learn how to combat enemies.

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04a_ADD"} )--Attack the leader of the malfunctioning robots with 29-11 by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective04a = nil
	x360tut_objective04a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04a")--Attack the leader of the malfunctioning robots with 29-11 by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective04a)
end


function Callback_Robotic_Malfunctioner_Leader_Attacked()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Robotic_Malfunctioner_Leader_Attacked HIT!"))
	if TestValid(robotic_malfunctioner_leader) then
		robotic_malfunctioner_leader.Unregister_Signal_Handler(Callback_Robotic_Malfunctioner_Leader_Attacked)
	end
	
	Create_Thread("Thread_Robotic_Malfunctioner_Leader_Attacked")
end

function Thread_Robotic_Malfunctioner_Leader_Attacked()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Robotic_Malfunctioner_Leader_Attacked HIT!"))
	while x360tut_objective04a == nil do
		Sleep(1)
	end -- this sleep loop is a safety to make sure the objective is displayed before it gets cleared
	
	if x360tut_objective04a ~= nil then 
		Objective_Complete(x360tut_objective04a)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	Sleep(2)
	list_robotic_malfunctioners = Find_All_Objects_With_Hint("robotic-malfunction", "X360_Tutorial_OhmBot")
	for i, robotic_infantry in pairs(list_robotic_malfunctioners) do
		local new_robot = Spawn_Unit(Find_Object_Type("X360_Tutorial_OhmBot"), robotic_infantry, aliens) 
		new_robot.Teleport_And_Face(robotic_infantry)
		robotic_infantry.Despawn()
		new_robot.Attach_Particle_Effect("Novus_Virus_stage_one_particle")
		new_robot.Set_Hint("robotic-malfunction")
		new_robot.Highlight_Small(true)
		new_robot.Make_Invulnerable(false)
		new_robot.Set_Cannot_Be_Killed(true)
		new_robot.Suspend_Locomotor(true)
	end

	Create_Thread("Thread_Obj04_Combat_UseDuplicate")
end

function Thread_Obj04_Combat_UseDuplicate()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj04_Combat_UseDuplicate HIT!"))
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_combat_use_duplicate) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	Lock_Controls(0)
	
	--trying to keep blackout bomb ability displayed but grayed-out.
	player_faction.Reset_Story_Locks()
	--player_faction.Lock_Unit_Ability("Novus_Reflex_Trooper", "Unit_Ability_Blackout_Bomb_Attack",true,STORY)
		
	player_faction.Lock_Unit_Ability("X360_Tutorial_29-11", "Unit_Ability_Blackout_Bomb_Attack",true,STORY)	
	player_faction.Lock_Unit_Ability("X360_Tutorial_29-11", "Unit_Ability_Spawn_Clones",false,STORY)

	UI_Force_Display_Ability("X360_Tutorial_29-11", "Unit_Ability_Blackout_Bomb_Attack", true)
	
	--flashing 29-11's duplicate ability here
	UI_Start_Flash_Ability_Button("TEXT_ABILITY_NOVUS_DUPLICATE")
	
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04c_ADD"} )--Use 29-11's DUPLICATE ability to quickly deal with the remaining malfunctioning robots.
	Sleep(1)
	
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(141)
	end
	Sleep(time_objective_sleep)
	
	x360tut_objective04c = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04c")--Use 29-11's DUPLICATE ability to quickly deal with the remaining malfunctioning robots.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective04c)
	
	local bool_clones_exist = false
	while  bool_clones_exist == false do
		Sleep(1)
		blade_bot_clone = Find_First_Object("Novus_Reflex_Trooper_Clone")
		if TestValid(blade_bot_clone) then
			bool_clones_exist = true
			break
		end
	end
	
	if TestValid(robotic_malfunctioner_leader) then
		robotic_malfunctioner_leader.Set_Cannot_Be_Killed(false)
	end
	
	local list_current_malfunctioners = Find_All_Objects_With_Hint("robotic-malfunction", "X360_Tutorial_OhmBot")
	for i, robotic_infantry in pairs(list_current_malfunctioners) do
		if TestValid(robotic_infantry) then
			robotic_infantry.Set_Cannot_Be_Killed(false)
		end
	end
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_combat_duplicate_activated) --no need to block this one
	
	if x360tut_objective04c ~= nil then
		Objective_Complete(x360tut_objective04c)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04d_ADD"} )--Destroy the remaining infected Ohm Robots.
	Sleep(time_objective_sleep)
	x360tut_objective04d = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_04d")--Destroy the remaining infected Ohm Robots.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective04d)
	
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(86)
	end

	Create_Thread("Thread_Monitor_Obj04_MalfunctioningRobots")
	
	--jdg 1/9/08 too many hints here...cutting
	--Sleep(5)
	--if bool_show_expanded_hints == true then
	--	Add_Independent_Hint(139)
	--end
end

function Thread_Monitor_Obj04_MalfunctioningRobots()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Monitor_Obj04_MalfunctioningRobots HIT!"))
	loop_counter = 0
	while true do
		Sleep(1)
		
		list_all_malfunctioning_robots = Find_All_Objects_With_Hint("robotic-malfunction", "X360_Tutorial_OhmBot")
		local bool_robots_exist = false
		for i, robotic_infantry in pairs(list_all_malfunctioning_robots) do
			if TestValid(robotic_infantry) then
				loop_counter = loop_counter + 1
				bool_robots_exist = true
				_CustomScriptMessage("JoeLog.txt", string.format("bool_robots_exist = true, loop_counter = %d", loop_counter))
				break
			end
		end
		
		while TestValid(robotic_malfunctioner_leader) do
			Sleep(1)
		end
		
		if bool_robots_exist == false then
			
			if x360tut_objective04d ~= nil then
				Objective_Complete(x360tut_objective04d)
				Thread.Kill(thread_id_objective_reminders)
				Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
			end
			
			if x360tut_objective04 ~= nil then
				Delete_Objective(x360tut_objective04)
			end
			
			Set_Next_State("State_Construction")
			return
		end
	end
end

---------------------------------------------------------------------------------------------------
--Construction stuff
---------------------------------------------------------------------------------------------------
function State_Construction(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_Construction Start!!"))
		
		Create_Thread("Thread_Obj05_Construction_Setup")
	end
end

function Thread_Obj05_Construction_Setup()

	if bool_restarting_construction == true then
		--move the constructor back to his mark
		if TestValid(players_constructor) then
			players_constructor.Despawn()
			players_constructor = Spawn_Unit(Find_Object_Type("Novus_Constructor"), players_constructor_spawn_loc, novus) 
			players_constructor.Teleport_And_Face(players_constructor_spawn_loc) 
		else
			players_constructor = Spawn_Unit(Find_Object_Type("Novus_Constructor"), players_constructor_spawn_loc, novus) 
			players_constructor.Teleport_And_Face(players_constructor_spawn_loc) 
		end
		
		players_constructor.Suspend_Locomotor(true)
		
		--remove any lingering objectives
		if x360tut_objective05 ~= nil then
			Delete_Objective(x360tut_objective05)
		end
		
		if x360tut_objective05a ~= nil then
			Delete_Objective(x360tut_objective05a)
		end
		
		if x360tut_objective05b ~= nil then
			Delete_Objective(x360tut_objective05b)
		end
		
		if x360tut_objective05c ~= nil then
			Delete_Objective(x360tut_objective05c)
		end
		
		if x360tut_objective05d ~= nil then
			Delete_Objective(x360tut_objective05d)
		end
		
		if x360tut_objective05e ~= nil then
			Delete_Objective(x360tut_objective05e)
		end
		
		if x360tut_objective05f ~= nil then
			Delete_Objective(x360tut_objective05f)
		end
		
		if x360tut_objective05g ~= nil then
			Delete_Objective(x360tut_objective05g)
		end
		
		--delete any robotic assemblies that might have been produced.
		list_robotic_assembly_buildings = Find_All_Objects_Of_Type("Novus_Robotic_Assembly")
		for i, robotic_assembly_building in pairs(list_robotic_assembly_buildings) do
			if TestValid(robotic_assembly_building) then
				robotic_assembly_building.Despawn()
			end
		end
		
		--delete any "under construction" versions of robotic assemblies that might have been produced.
		list_robotic_assembly_buildings_under_construction = Find_All_Objects_Of_Type("Novus_Robotic_Assembly_Construction")
		for i, buildings_under_construction in pairs(list_robotic_assembly_buildings_under_construction) do
			if TestValid(buildings_under_construction) then
				buildings_under_construction.Despawn()
			end
		end
		
		--just in case
		list_robotic_assembly_building_beacons = Find_All_Objects_Of_Type("Novus_Robotic_Assembly_Beacon")
		for i, beacon in pairs(list_robotic_assembly_building_beacons) do
			if TestValid(beacon) then
				beacon.Despawn()
			end
		end
		
		--delete any robotic assemblies that might have been produced.
		list_player_produced_units = Find_All_Objects_With_Hint("player-produced-unit")
		for i, player_produced_unit in pairs(list_player_produced_units) do
			if TestValid(player_produced_unit) then
				player_produced_unit.Despawn()
			end
		end
		
		--kill any monitor-threads that might be running
		if thread_id_select_constructor then
			Thread.Kill(thread_id_select_constructor)
		end
		
		--remove any radar blips or other highlights and prox events
		if TestValid(ground_higlight_moveto_constructor_01) then
			moveto_constructor_01.Highlight(false)
			Remove_Radar_Blip("blip_moveto_constructor_01")
			ground_higlight_moveto_constructor_01.Despawn()
			moveto_constructor_01.Cancel_Event_Object_In_Range(Prox_Constructor_Move01)
			
		end
		
		counter_player_produced_blade_troopers = 0
		counter_player_produced_robotic_infantry = 0

		Point_Camera_At(trooper_29_11)
		Fade_Screen_In(1)
		Lock_Controls(0)
	end
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
	end
	
	Create_Thread("Thread_Obj05_Construction_SelectConstructor")
end

function Thread_Obj05_Construction_SelectConstructor()
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_combat_done) --also introduces contructors
	while bool_conversation_over == false do
		Sleep(1)
	end
	--lock out build options here...dan the jerk is breaking the mission here....
	player_faction.Reset_Story_Locks()
	player_faction.Lock_Object_Type(Find_Object_Type("NM04_Novus_Portal"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Redirection_Turret"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_EMP"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_Gravity_Bomb"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Remote_Terminal"),true, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Signal_Tower"),true, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Power_Router"),true, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Input_Station"),true, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly"),true, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Aircraft_Assembly"),true, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly"),true, STORY)
	

	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_select_constructor = Create_Thread("Thread_Monitor_Obj05_Construction_SelectConstructor")
	
end
function Thread_Monitor_Obj05_Construction_SelectConstructor()
	while players_constructor.Is_Selected() == false do
		Sleep(1)
		--_CustomScriptMessage("JoeLog.txt", string.format("Sleep(1) waiting for player to select players_constructor"))
	end
	
	Remove_Radar_Blip("blip_players_constructor_location")
	if TestValid(players_constructor_location) then
		players_constructor_location.Highlight(false)
	end
	
	if TestValid(ground_highlight_marker_players_constructor_location) then
		ground_highlight_marker_players_constructor_location.Despawn()
	end
	
	if x360tut_objective05a ~= nil then
		Objective_Complete(x360tut_objective05a)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	-- stop the ui button from flashing
	UI_Stop_Flash_Builder_Button()
	
	--Create_Thread("Thread_Obj05_Construction_CenterOnConstructor")
	Create_Thread("Thread_Obj05_Construction_BuildRoboticAssembly")
end



function Thread_Obj05_Construction_BuildRoboticAssembly()	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_construction_build_robotic_assembly) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	--starting from zero due to various bugs/issues
	player_faction.Reset_Story_Locks()
	
	--lock out the portal, agian
	player_faction.Lock_Object_Type(Find_Object_Type("NM04_Novus_Portal"),true,STORY)
	
	--also locking out the top row stuff
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Redirection_Turret"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_EMP"),true,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_Gravity_Bomb"),true,STORY)
	
	--locking these guys from "Research" rather than story allows me to
	--display them "grayed out" rather than just have them MIA
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Remote_Terminal"),true, RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Signal_Tower"),true, RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Power_Router"),true, RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Input_Station"),true, RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly"),true, RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Aircraft_Assembly"),true, RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly"),false, STORY)

	UI_Update_Selection_Abilities()	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05d_ADD"} )--Use your Constructor to build a Robotic Assembly building by doing X.
	
	moveto_constructor_01 = Find_Hint("MARKER_GENERIC_BLACK","moveto-constructor-01")
	moveto_constructor_01.Highlight(true, -50)
	ground_higlight_moveto_constructor_01 = Create_Generic_Object(Find_Object_Type("Highlight_Area"), moveto_constructor_01, neutral)
	Add_Radar_Blip(moveto_constructor_01, "DEFAULT", "blip_moveto_constructor_01")
	
	--flashing the robotic assembly build option here
	UI_Start_Flash_Construct_Building("NOVUS_ROBOTIC_ASSEMBLY")
	
	Sleep(1)
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(143)
	end
	Sleep(time_objective_sleep)
	x360tut_objective05d = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05d")--Use your Constructor to build a Robotic Assembly building by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective05d)
	
	--listen for the under_construction version here
	robotic_assembly_under_construction = Find_First_Object("Novus_Robotic_Assembly_Construction")
	while not TestValid(robotic_assembly_under_construction) do
		Sleep(1)
		robotic_assembly_under_construction = Find_First_Object("Novus_Robotic_Assembly_Construction")
	end
	
	moveto_constructor_01.Highlight(false)
	if ground_higlight_moveto_constructor_01 ~= nil then
		ground_higlight_moveto_constructor_01.Despawn()
	end
	
	Remove_Radar_Blip("blip_moveto_constructor_01")
	
	--player has started construction..kill the objective reminder text 
	_CustomScriptMessage("JoeLog.txt", string.format("object_type_novus_robotic_assembly_under_construction detected"))
	Thread.Kill(thread_id_objective_reminders)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	
	
	
	--listen for the final built version here
	robotic_assembly = Find_First_Object("Novus_Robotic_Assembly")
	while not TestValid(robotic_assembly) do
		Sleep(1)
		robotic_assembly = Find_First_Object("Novus_Robotic_Assembly")
	end
	
	--reseting unit locks due to code rot .... 2/16/08
	--starting from zero
	player_faction.Reset_Story_Locks()
	--show hackers, but make sure they are grayed out.
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),true,RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Infantry"),true,RESEARCH)


end

function Thread_Obj05_Construction_PlaceRallyPoint()
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_construction_place_rally_point) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	rally_point_flag = Find_Hint("MARKER_GENERIC_BLACK","rally-point-flag")
	if TestValid(rally_point_flag) then
		rally_point_flag.Highlight(true, -50)
		ground_higlight_rally_point_flag = Create_Generic_Object(Find_Object_Type("Highlight_Area"), rally_point_flag, neutral)
		Add_Radar_Blip(rally_point_flag, "DEFAULT", "blip_rally_point_flag")
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! not TestValid(rally_point_flag)"))
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05h_ADD"} )--With the Robotic Assembly selected, place a Rally point at the indicated location by moving the cursor there and pressing the "A" button.
	Sleep(time_objective_sleep)
	x360tut_objective05h = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05h")--With the Robotic Assembly selected, place a Rally point at the indicated location by moving the cursor there and pressing the "A" button.

	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective05h)
	
	Create_Thread("Thread_Obj05_Construction_BuildRobots")
end

function Thread_Obj05_Construction_BuildRobots()
	while bool_rally_point_placed == false do
		Sleep(1)
		--bool_rally_point_placed = true -- TEMP: Need code support to detect rally point placement.
	end
	
	if x360tut_objective05h ~= nil then
		Objective_Complete(x360tut_objective05h)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	rally_point_flag.Highlight(false)
	if TestValid(ground_higlight_rally_point_flag) then
		ground_higlight_rally_point_flag.Despawn()
	end
	
	Remove_Radar_Blip("blip_rally_point_flag")
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_construction_build_three_robots) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	--starting from zero
	player_faction.Reset_Story_Locks()
	--show hackers, but make sure they are grayed out.
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),true,RESEARCH)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Infantry"),false,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly_Instance_Generator"),true,STORY)

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05e_ADD"} )--Build three Robotic Infantry from your new Robotic Assembly building by doing X.
	
	--flashing the robotic infantry build option here
	UI_Start_Flash_Queue_Buttons ("NOVUS_ROBOTIC_ASSEMBLY", "NOVUS_ROBOTIC_INFANTRY")
	
	Sleep(1)
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(144)
	end
	Sleep(time_objective_sleep)
	
	x360tut_objective05e = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05e")--Build three Robotic Infantry from your new Robotic Assembly building by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end

	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective05e)

end

function Thread_Obj05_Construction_UpgradeRoboticAssembly()
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_construction_upgrade_robotic_assembly) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05f_ADD"} )--Upgrade your Robotic Assembly building by doing X.
	
	--flashing the blade trooper build option here
	UI_Start_Flash_Queue_Buttons ("NOVUS_ROBOTIC_ASSEMBLY", "Novus_Robotic_Assembly_Instance_Generator")
	
	Sleep(time_objective_sleep)
	x360tut_objective05f = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05f")--Upgrade your Robotic Assembly building by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective05f)
	
end

function Thread_Obj05_Construction_BuildBladeBots()

	while x360tut_objective05f == nil do
		Sleep(1)
	end

	if x360tut_objective05f ~= nil then
		Objective_Complete(x360tut_objective05f)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05g_ADD"} )--Build three Blade Troopers from your Robotic Assembly building by doing X.
	
	--flashing the blade trooper build option here
	UI_Start_Flash_Queue_Buttons ("NOVUS_ROBOTIC_ASSEMBLY", "NOVUS_REFLEX_TROOPER")
	
	Sleep(time_objective_sleep)
	x360tut_objective05g = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05g")--Build three Blade Troopers from your Robotic Assembly building by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective05g)
end



function Story_On_Construction_Complete(obj, constructor)
	_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete HIT! "))

	local obj_type

	if TestValid(obj) then
		obj_type = obj.Get_Type()
		if obj_type == object_type_novus_robotic_assembly then
			_CustomScriptMessage("JoeLog.txt", string.format("OCC - obj_type == object_type_novus_robotic_assembly "))
			
			player_produced_robotic_assembly = obj
			
			--over-riding build speeds here to hurry things along
			obj.Add_Attribute_Modifier( "STRUCTURE_SPEED_BUILD", 3 )
			obj.Add_Attribute_Modifier( "MAX_STRUCTURE_BUILD_RATE", 500 )
			obj.Add_Attribute_Modifier( "Unit_Build_Rate_Multiplier", 3 )
			obj.Add_Attribute_Modifier( "Max_Unit_Build_Rate", 500 )
			
			--registering this guy so we can track his waypoint.
			obj.Register_Signal_Handler(Callback_RoboticAssembly_RallyPoint_Placed, "RALLY_POINT_SET")
			
			if x360tut_objective05d ~= nil then
				Objective_Complete(x360tut_objective05d)
				Thread.Kill(thread_id_objective_reminders)
				Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
			end
			
			--locking out misc stuff here
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Infantry"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly_Instance_Generator"),true,STORY)
			
			--taking away control of constructor
			if  TestValid(players_constructor) then
				players_constructor.Change_Owner(neutral)
				players_constructor.Enable_Behavior(79, false)
			end
			
			Create_Thread("Thread_Obj05_Construction_PlaceRallyPoint")

		elseif obj_type == object_type_novus_robotic_infantry then 
			if player_produced_robot01 == nil then
				player_produced_robot01 = obj
				
				_CustomScriptMessage("JoeLog.txt", string.format("OCC - player_produced_robot01 defined"))
			elseif player_produced_robot02 == nil then
				player_produced_robot02 = obj

				_CustomScriptMessage("JoeLog.txt", string.format("OCC - player_produced_robot02 defined"))
			elseif player_produced_robot03 == nil then
				player_produced_robot03 = obj
				_CustomScriptMessage("JoeLog.txt", string.format("OCC - player_produced_robot03 defined"))
			end
			
			counter_player_produced_robotic_infantry = counter_player_produced_robotic_infantry + 1
			
			obj.Set_Hint("player-produced-unit")
			
			if counter_player_produced_robotic_infantry == 3 then
				if x360tut_objective05e ~= nil then
					Objective_Complete(x360tut_objective05e)
					Thread.Kill(thread_id_objective_reminders)
					Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
				end
				
				player_faction.Reset_Story_Locks()
				--show ohm bot and hackers, but make sure they are grayed out.
				player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),true,RESEARCH)
				player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Infantry"),true,STORY)
				
				Create_Thread("Thread_Obj05_Construction_UpgradeRoboticAssembly")
			end
			
		elseif obj_type == object_type_novus_robotic_assembly_upgrade then
			Create_Thread("Thread_Obj05_Construction_BuildBladeBots")
			
		elseif obj_type == object_type_novus_blade_trooper then
			if player_produced_bladetrooper01 == nil then
				player_produced_bladetrooper01 = obj
				_CustomScriptMessage("JoeLog.txt", string.format("OCC - player_produced_bladetrooper01 defined"))
			elseif player_produced_bladetrooper02 == nil then
				player_produced_bladetrooper02 = obj
				_CustomScriptMessage("JoeLog.txt", string.format("OCC - player_produced_bladetrooper02 defined"))
			elseif player_produced_bladetrooper03 == nil then
				player_produced_bladetrooper03 = obj
				
				_CustomScriptMessage("JoeLog.txt", string.format("OCC - player_produced_bladetrooper03 defined"))
			end
			
			counter_player_produced_blade_troopers = counter_player_produced_blade_troopers + 1
			
			obj.Set_Hint("player-produced-unit")
			
			if counter_player_produced_blade_troopers == 3 then
				if x360tut_objective05g ~= nil then
					Objective_Complete(x360tut_objective05g)
					Thread.Kill(thread_id_objective_reminders)
					Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
					
					player_faction.Reset_Story_Locks()
					--show ohm bot and hackers, but make sure they are grayed out.
					player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),true,RESEARCH)
					player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Infantry"),true,RESEARCH)
					player_faction.Lock_Object_Type(Find_Object_Type("Novus_Reflex_Trooper"),true, RESEARCH)
					
					Create_Thread("Thread_Obj05_Construction_ClearAllObjectives")
				end
			end
		end
	end
end


function Thread_Obj05_Construction_ClearAllObjectives()

	if x360tut_objective05 ~= nil then
		--Objective_Complete(x360tut_objective05)
		Delete_Objective(x360tut_objective05)
	end
	
	--setting player produced stuff to neutral here now that group-teaching is getting delayed.
	list_robots = Find_All_Objects_Of_Type("Novus_Robotic_Infantry")
	for i, robot in pairs(list_robots) do
		if TestValid(robot) then
			robot.Change_Owner(neutral)
			robot.Enable_Behavior(79, false)
			_CustomScriptMessage("JoeLog.txt", string.format("robot.Change_Owner(neutral)"))
		end
	end
	
	list_bladetroopers = Find_All_Objects_Of_Type("Novus_Reflex_Trooper")
	for i, bladetrooper in pairs(list_bladetroopers) do
		if TestValid(bladetrooper) then
			bladetrooper.Change_Owner(neutral)
			bladetrooper.Enable_Behavior(79, false)
			_CustomScriptMessage("JoeLog.txt", string.format("bladetrooper.Change_Owner(neutral)"))
		end
	end
	player_produced_bladetrooper01_goto = Find_Hint("MARKER_GENERIC_BLACK","moveto-bladebot01")
	player_produced_bladetrooper02_goto = Find_Hint("MARKER_GENERIC_BLACK","moveto-bladebot02")
	player_produced_bladetrooper03_goto = Find_Hint("MARKER_GENERIC_BLACK","moveto-bladebot03")
	
	if TestValid(player_produced_bladetrooper01) then
		player_produced_bladetrooper01.Move_To(player_produced_bladetrooper01_goto.Get_Position())
	end
	
	if TestValid(player_produced_bladetrooper02) then
		player_produced_bladetrooper02.Move_To(player_produced_bladetrooper02_goto.Get_Position())
	end
	
	if TestValid(player_produced_bladetrooper03) then
		player_produced_bladetrooper03.Move_To(player_produced_bladetrooper03_goto.Get_Position())
	end
	
	Set_Next_State("State_Heroes")
	
	Sleep(6)
	player_produced_bladetrooper_face = Find_Hint("MARKER_GENERIC_BLACK","face-bladebot")
	
	if TestValid(player_produced_bladetrooper01) then
		player_produced_bladetrooper01.Turn_To_Face(player_produced_bladetrooper_face)
	end
	
	if TestValid(player_produced_bladetrooper02) then
		player_produced_bladetrooper02.Turn_To_Face(player_produced_bladetrooper_face)
	end
	
	if TestValid(player_produced_bladetrooper03) then
		player_produced_bladetrooper03.Turn_To_Face(player_produced_bladetrooper_face)
	end

end

---------------------------------------------------------------------------------------------------
--Hero stuff
---------------------------------------------------------------------------------------------------
function State_Heroes(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_Heroes Start!!"))
		Create_Thread("Thread_Obj07_Heroes_Setup")
	end
end

function Thread_Obj07_Heroes_Setup()
	if bool_restarting_heroes == true then
		if TestValid(mirabel) then
			mirabel.Despawn()
		end
		
		--despawn any of her targets that might remain
		list_mirabels_targets = Find_All_Objects_With_Hint("mirabel-target")
		for i, mirabels_target in pairs(list_mirabels_targets) do
			if TestValid(mirabels_target) then
				mirabels_target.Despawn()
			end
		end
		
		--gotta get rid of any death clones too...<sigh>
		list_defiler_death_clones = Find_All_Objects_Of_Type("Alien_Defiler_Death_Clone")
		for i, defiler_death_clone in pairs(list_defiler_death_clones) do
			if TestValid(defiler_death_clone) then
				defiler_death_clone.Despawn()
			end
		end
		
		list_robot_death_clones = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Death_Clone_Resource")
		for i, robot_death_clone in pairs(list_robot_death_clones) do
			if TestValid(robot_death_clone) then
				robot_death_clone.Despawn()
			end
		end
		
		--reset counters
		counter_snipe_target = 0
		counter_barrage_target = 0
		
		if x360tut_objective07 ~= nil then
			Delete_Objective(x360tut_objective07)
		end
		
		if x360tut_objective07a ~= nil then
			Delete_Objective(x360tut_objective07a)
		end
		
		if x360tut_objective07b ~= nil then
			Delete_Objective(x360tut_objective07b)
		end
		
		if x360tut_objective07c ~= nil then
			Delete_Objective(x360tut_objective07c)
		end
		
		if thread_id_obj07_heroes_find_mirabel then
			Thread.Kill(thread_id_obj07_heroes_find_mirabel)
		end
		
		if thread_id_obj07_heroes_use_mirabels_snipe then
			Thread.Kill(thread_id_obj07_heroes_use_mirabels_snipe)
		end
		
		if thread_id_obj07_heroes_use_mirabels_snipe_finished then
			Thread.Kill(thread_id_obj07_heroes_use_mirabels_snipe_finished)
		end
		
		if thread_id_obj07_heroes_use_mirabels_barrage then
			Thread.Kill(thread_id_obj07_heroes_use_mirabels_barrage)
		end
		
		if thread_id_obj07_heroes_use_mirabels_barrage_finished then
			Thread.Kill(thread_id_obj07_heroes_use_mirabels_barrage_finished)
		end
		
		if thread_id_obj07_heroes_clear_objectives then
			Thread.Kill(thread_id_obj07_heroes_clear_objectives)
		end
		
		player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Vehicle_Snipe_Attack", true, STORY)
		player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Minirocket_Barrage", true, STORY)
		
		Point_Camera_At(trooper_29_11)
		Fade_Screen_In(1)
		Lock_Controls(0)	
	end
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
	end
	
	if TestValid(player_produced_robotic_assembly) then
		player_produced_robotic_assembly.Change_Owner(neutral)
		player_produced_robotic_assembly.Set_Selectable(false)
	end
	
	thread_id_obj07_heroes_find_mirabel = Create_Thread("Thread_Obj07_Heroes_Find_Mirabel")
end

function Thread_Mirabel_Arrives()
		--send in the transport here
	if TestValid(mirabel_transport_spawn_location) then
		local novus_transport = Spawn_Unit(object_type_novus_transport, mirabel_transport_spawn_location, novus, false)
		if TestValid(novus_transport) then
			--Add_Radar_Blip(nouvs_transport, "Default_Beacon_Placement", "blip_reinforcement")

			novus_transport.Set_Selectable(false)
			novus_transport.Make_Invulnerable(true)
			local blip_reinforcement = nil
			BlockOnCommand(novus_transport.Move_To(mirabel_spawn_location.Get_Position()))
			
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
			mirabel = Spawn_Unit(Find_Object_Type("Mirabel_360_Tutorial"), mirabel_spawn_location, player_faction) 
				
			Sleep(3)
			--Remove_Radar_Blip("blip_reinforcement")

			if TestValid(novus_transport) then
				BlockOnCommand(novus_transport.Move_To(mirabel_transport_spawn_location.Get_Position()))
				if TestValid(novus_transport) then
					novus_transport.Make_Invulnerable(false)
					novus_transport.Despawn()
				end
			end
		end
	end
end

function Thread_Obj07_Heroes_Find_Mirabel()
	
	
	Create_Thread("Thread_Mirabel_Arrives") 
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_heroes_intro) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	x360tut_objective07 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07")--Topic: Heroes
	
	
	
	
	

	
	while not TestValid(mirabel) do
		Sleep(1)
	end
	
	if TestValid(mirabel) then
		mirabel.Suspend_Locomotor(true)
		--mirabel.Prevent_All_Fire(true)
	end
	
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", true, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Minirocket_Barrage", true, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Vehicle_Snipe_Attack", true, STORY)

	--flashing the group button here
	if TestValid(mirabel) then
		UI_Flash_Control_Group_Containing_Unit(mirabel)
		_CustomScriptMessage("JoeLog.txt", string.format("UI_Flash_Control_Group_Containing_Unit(mirabel)"))
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Trying to flash mirabel group button, but she's not testing valid!!"))
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07a_ADD"} )--Select and center the camera on Mirabel by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective07a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07a")--Select and center the camera on Mirabel by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective07a)

	while not Is_On_Screen(mirabel) do
		Sleep(1)
	end
	
	if x360tut_objective07a ~= nil then
		Objective_Complete(x360tut_objective07a)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	thread_id_obj07_heroes_use_mirabels_snipe = Create_Thread("Thread_Obj07_Heroes_Use_Mirabels_Snipe")
	
end

function Thread_Obj07_Heroes_Use_Mirabels_Snipe()
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_heroes_mirabel_snipe) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	novus.Make_Enemy(aliens) -- making sure
	
	if TestValid(snipe_target01) then
		Create_Thread("Thread_Mirabel_SnipeTarget_Comes_OnLine", snipe_target01) 
		
		snipe_target01.Highlight(true)
		snipe_target01.Set_Hint("mirabel-target")
		snipe_target01.Register_Signal_Handler(Callback_Snipe_Target_Destroyed, "OBJECT_DELETE_PENDING")
		counter_snipe_target = counter_snipe_target + 1
	end

	if TestValid(snipe_target02) then
		Sleep(0.5)--aesthetic "variation"
		Create_Thread("Thread_Mirabel_SnipeTarget_Comes_OnLine", snipe_target02) 
		snipe_target02.Set_Hint("mirabel-target")
		
		snipe_target02.Register_Signal_Handler(Callback_Snipe_Target_Destroyed, "OBJECT_DELETE_PENDING")
		counter_snipe_target = counter_snipe_target + 1
	end

	--starting from zero
	player_faction.Reset_Story_Locks()
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", true, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Minirocket_Barrage", true, STORY)
	player_faction.Lock_Unit_Ability("Mirabel_360_Tutorial", "Unit_Ability_Mech_Minirocket_Barrage", true, STORY)

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07b_ADD"} )--Use Mirabel's SNIPE ability to destroy Y by doing X.

	--flashing Mirabels snipe ability
	UI_Start_Flash_Ability_Button("TEXT_ABILITY_NOVUS_VEHICLE_SNIPE")
	--this is a "smoke and mirror" gui call that let's me gray-out things
	UI_Force_Display_Ability("Mirabel_360_Tutorial", "Unit_Ability_Mech_Minirocket_Barrage", true)
	
	if TestValid(snipe_target01) then
		Point_Camera_At(snipe_target01)
	end
	
	Sleep(time_objective_sleep)
	x360tut_objective07b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07b")--Use Mirabel's SNIPE ability to destroy Y by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective07b)

end

function Thread_Mirabel_SnipeTarget_Comes_OnLine(target)
	if not TestValid(target) then
		return
	end
	
	target.Play_Animation("Anim_Cinematic", false, 1)--target raising up anim
	Sleep(1)
	target.Play_Animation("Anim_Cinematic", true, 2)--target "idle" spin anim...loops
	
	target.Prevent_Opportunity_Fire(true) 
	target.Change_Owner(aliens)
	
end

function Callback_Snipe_Target_Destroyed()
	counter_snipe_target = counter_snipe_target - 1
	
	if counter_snipe_target == 0 then --all snipe targets are destroyed...clear objective
		thread_id_obj07_heroes_use_mirabels_snipe_finished = Create_Thread("Thread_Snipe_Target_Destroyed")
	end
end

function Thread_Snipe_Target_Destroyed()
	if x360tut_objective07b ~= nil then
		Objective_Complete(x360tut_objective07b)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Vehicle_Snipe_Attack", true, STORY)
	mirabel.Prevent_Opportunity_Fire(true) 
	thread_id_obj07_heroes_use_mirabels_barrage = Create_Thread("Thread_Obj07_Heroes_Use_Mirabels_Barrage")
end

function Thread_Obj07_Heroes_Use_Mirabels_Barrage()
	barrage_target_spawn = Find_Hint("MARKER_GENERIC_RED","mirabel-target-barrage-spawn")
	
	list_barrage_target_flags = Find_All_Objects_With_Hint("mirabel-target-barrage", "MARKER_GENERIC_RED")
	for i, barrage_target_flag in pairs(list_barrage_target_flags) do
		if TestValid(barrage_target_flag) then
			--local barrage_target = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry"), barrage_target_spawn, novus) 
			local barrage_target = Spawn_Unit(Find_Object_Type("X360_Tutorial_OhmBot"), barrage_target_spawn, novus) 
			if TestValid(barrage_target) then
				
				thread_info = {}
				thread_info[1] = barrage_target
				thread_info[2] = barrage_target_flag
				
				Create_Thread("Thread_Setup_BarrageTargets_Move_Orders", thread_info)

				list_mirabel_barage_target[i] = barrage_target --adding these guys to a list so I can easily "smoke and mirror" kill them all to prevent mission stalling out
				barrage_target.Set_Hint("mirabel-target")
				barrage_target.Register_Signal_Handler(Callback_Barrage_Target_Destroyed, "OBJECT_DELETE_PENDING")
				counter_barrage_target = counter_barrage_target + 1
			end
		end
	end
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_heroes_mirabel_missile_barrage) 
	while bool_conversation_over == false do
		Sleep(1)
	end
		
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Minirocket_Barrage", false, STORY)
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07c_ADD"} )--Use Mirabel's ROCKET BARRAGE ability to destroy B by doing X.
 
	--flashing Mirabel's missile barrage button here
	UI_Start_Flash_Ability_Button("TEXT_ABILITY_NOVUS_MISSILE_BARRAGE")
	--this is a "smoke and mirror" gui call that let's me gray-out things
	UI_Force_Display_Ability("Mirabel_360_Tutorial", "Unit_Ability_Mech_Vehicle_Snipe_Attack", true)
	
	Sleep(time_objective_sleep)
	x360tut_objective07c = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_07c")--Use Mirabel's ROCKET BARRAGE ability to destroy B by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective07c)
	
end

function Thread_Setup_BarrageTargets_Move_Orders(thread_info)
	local robot = thread_info[1]
	local goto_flag = thread_info[2]
	
	if TestValid(robot) and TestValid(goto_flag) then
		BlockOnCommand(Full_Speed_Move(robot, goto_flag.Get_Position()))
	end
	
	if TestValid(robot) then
		robot.Suspend_Locomotor(true)
		robot.Prevent_All_Fire(true)
		robot.Prevent_Opportunity_Fire(true)
		robot.Highlight_Small(true)
		robot.Attach_Particle_Effect("Novus_Virus_stage_one_particle")
		robot.Change_Owner(aliens)
	end
end

function Callback_Barrage_Target_Destroyed()
	for i, mirabel_barage_target in pairs(list_mirabel_barage_target) do
		if TestValid(mirabel_barage_target) then
			mirabel_barage_target.Unregister_Signal_Handler(Callback_Barrage_Target_Destroyed)
			mirabel_barage_target.Take_Damage(100000)
		end
	end
	
	thread_id_obj07_heroes_use_mirabels_barrage_finished = Create_Thread("Thread_Barrage_Target_Destroyed")
end

function Thread_Barrage_Target_Destroyed()
	Sleep(2) -- dramatic delay 
	if x360tut_objective07c ~= nil then
		Objective_Complete(x360tut_objective07c)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	thread_id_obj07_heroes_clear_objectives = Create_Thread("Thread_Obj07_Heroes_ClearAllObjectives")
end

function Thread_Obj07_Heroes_ClearAllObjectives()
	
	if x360tut_objective07 ~= nil then
		Delete_Objective(x360tut_objective07)
	end
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_heroes_done) --includes dialog regarding opening the research panel
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	Set_Next_State("State_Research")
end

---------------------------------------------------------------------------------------------------
--Research stuff
---------------------------------------------------------------------------------------------------
function State_Research(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_Research Start!!"))
		Create_Thread("Thread_Obj08_Research_Setup")
	end
end

function Thread_Obj08_Research_Setup()
	if bool_restarting_research == true then
	
		if x360tut_objective08 ~= nil then
			Delete_Objective(x360tut_objective08)
		end
		
		if x360tut_objective08a ~= nil then
			Delete_Objective(x360tut_objective08a)
		end
		
		if x360tut_objective08b ~= nil then
			Delete_Objective(x360tut_objective08b)
		end
		
		if thread_id_obj08_research_open_panel then
			Thread.Kill(thread_id_obj08_research_open_panel)
		end
		
		if thread_id_obj08_research_do_research then
			Thread.Kill(thread_id_obj08_research_do_research)
		end
		
		if thread_id_obj08_research_clear_objectives then
			Thread.Kill(thread_id_obj08_research_clear_objectives)
		end
		
		Point_Camera_At(trooper_29_11)
		Fade_Screen_In(1)
		Lock_Controls(0)	
	end
	
	if bool_use_control_locks == false then
		Lock_Controls(0)
	else
		Lock_Controls(0)
	end
	
	thread_id_obj08_research_open_panel = Create_Thread("Thread_Obj08_Research_OpenResearchPanel")
end

function Thread_Obj08_Research_OpenResearchPanel()
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_start_researching) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	x360tut_objective08 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08")--Topic: Research

	-- Maria 02.15.2008
	-- We have changed the behavior of the Hide_Research_Button and the science guy is not despawned anymore, in fact, we are
	-- just hiding the button so we have to unhide it here
	-- novus_research =  Spawn_Unit(Find_Object_Type("Novus_Hero_Chief_Scientist_PIP_Only"), camera_start, novus) 
	UI_Hide_Research_Button(false)

	_CustomScriptMessage("JoeLog.txt", string.format("novus_research =  Spawn_Unit..."))
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08a_ADD"} )--Open the research panel by doing X.
	
	Sleep(1)
	
	--flashing the research button here
	UI_Start_Flash_Research_Button()
	
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(146)
	end
	Sleep(time_objective_sleep)
	
	x360tut_objective08a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08a")--Open the research panel by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective08a)
	
	thread_id_obj08_research_do_research = Create_Thread("Thread_Obj08_Research_ResearchSomething")
end


function Thread_Obj08_Research_ResearchSomething()
	while bool_research_panel_open == false do
		Sleep(1)
	end
	
	--speeding up research speed
	Find_Player("local").Get_Script().Call_Function("Set_Research_Time_Modifier", .25)

	if x360tut_objective08a ~= nil then
		Objective_Complete(x360tut_objective08a)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	bool_conversation_over = false
	Create_Thread("Thread_Dialog_Controller", dialog_research_radiation_shielding) 
	while bool_conversation_over == false do
		Sleep(1)
	end
	
	thread_id_obj08_research_clear_objectives = Create_Thread("Thread_Obj08_Research_ClearAllObjectives")
	
	player_script = novus.Get_Script()
	player_script.Call_Function("Block_Research_Branch","C",false,true)

	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08b_ADD"} )--Research Y by doing X.
	Sleep(time_objective_sleep)
	x360tut_objective08b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_08b")--Research Y by doing X.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_objective08b)

end

function Thread_Obj08_Research_ClearAllObjectives()
	while bool_research_completed == false do
		Sleep(1)
	end
	
	if x360tut_objective08b ~= nil then
		Objective_Complete(x360tut_objective08b)
		Thread.Kill(thread_id_objective_reminders)
		Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )--clears any lingering text
	end
	
	if x360tut_objective08 ~= nil then
		Delete_Objective(x360tut_objective08)
	end
	
	if bool_teach_groups == true then
		Set_Next_State("State_Groups")
	else
		Create_Thread("Thread_Mission_Complete")
	end
end

---------------------------------------------------------------------------------------------------
--Group stuff
---------------------------------------------------------------------------------------------------
function State_Groups(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("State_Groups Start!!"))

		Create_Thread("Thread_Obj06_Groups_Setup")
	end
end

function Thread_Obj06_Groups_Setup()
	Lock_Controls(1)
	Fade_Screen_Out(1)
	Sleep(1)
	--Point_Camera_At(founder)
	--Sleep(1)
		
	--the following stuff just cleans up any legacy objects on the map
	list_current_ohm_360robots = Find_All_Objects_Of_Type("X360_Tutorial_OhmBot")
	for i, current_ohm_360robot in pairs(list_current_ohm_360robots) do
		if TestValid(current_ohm_360robot) then
			current_ohm_360robot.Despawn()
		end
	end
	
	--clean up any dead robots after the Mirabel weapon training stuff
	list_robot_death_clones = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Death_Clone_Resource")
	for i, death_clone in pairs(list_robot_death_clones) do
		if TestValid(death_clone) then
			death_clone.Despawn()
		end
	end
	
	--just in case there're some lingering solo guys
	list_current_solo_ohm_robots = Find_All_Objects_Of_Type("Novus_Robotic_Infantry_Solo")
	for i, current_solo_ohm_robot in pairs(list_current_solo_ohm_robots) do
		if TestValid(current_solo_ohm_robot) then
			current_solo_ohm_robot.Despawn()
		end
	end
	
	list_current_ohm_squads = Find_All_Objects_Of_Type("Novus_Team_Robotic_Infantry")
	for i, current_ohm_squad in pairs(list_current_ohm_squads) do
		if TestValid(current_ohm_squad) then
			current_ohm_squad.Despawn()
		end
	end
	
	list_current_field_inverters = Find_All_Objects_Of_Type("Novus_Field_Inverter")
	for i, current_field_inverter in pairs(list_current_field_inverters) do
		if TestValid(current_field_inverter) then
			current_field_inverter.Despawn()
		end
	end
	
	--moving some of the amplifiers into place ahead of time...pathfind made moving large groups not really an option
	list_preplaced_antimatter_tanks = Find_All_Objects_With_Hint("preplaced", "Novus_Antimatter_Tank")
	for i, antimatter_tank in pairs(list_preplaced_antimatter_tanks) do
		if TestValid(antimatter_tank) then
			antimatter_tank.Set_Selectable(false)
			antimatter_tank.Teleport(end_locations_antimatter_preplaced[i]) 
			antimatter_tank.Set_Facing(180)
			antimatter_tank.Suspend_Locomotor(true)
		end
	end
	
	--turn all bladetroopers back over to the player
	list_blade_troopers = Find_All_Objects_Of_Type("X360_Tutorial_BladeTrooper")
	for i, blade_trooper in pairs(list_blade_troopers) do
		if TestValid(blade_trooper) then
			real_bladetrooper = Spawn_Unit(Find_Object_Type("Novus_Reflex_Trooper"), blade_trooper, novus)
			real_bladetrooper.Teleport_And_Face(blade_trooper)
			
			real_bladetrooper.Set_Hint(blade_trooper.Get_Hint())
			
			blade_trooper.Despawn()--this function replaces previous versions 360 specific bots (used as decoration) with real ones to be used in the following objectives
			real_bladetrooper.Suspend_Locomotor(true)
			real_bladetrooper.Change_Owner(neutral)
			
			real_bladetrooper.Set_Selectable(false)
		end
	end
	
	--gotta switch good old 29-11 over too...
	if not TestValid(trooper_29_11) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  Thread_Start_GroupObjectives: not TestValid(trooper_29_11)"))
	else
		real_bladetrooper = Spawn_Unit(Find_Object_Type("Novus_Reflex_Trooper"), trooper_29_11, novus)
		real_bladetrooper.Teleport_And_Face(trooper_29_11)
		
		trooper_29_11.Despawn()
		
		real_bladetrooper.Suspend_Locomotor(true)
		
		real_bladetrooper.Set_Hint("bladetrooper-start02")
		real_bladetrooper.Change_Owner(neutral)
		real_bladetrooper.Set_Selectable(false)
		
	end
	
	--also moving some of the blade troopers into place ahead of time...pathfind made moving large groups not really an option
	list_preplaced_blade_troopers = Find_All_Objects_With_Hint("bladetrooper-start02", "Novus_Reflex_Trooper")
	for i, blade_trooper in pairs(list_preplaced_blade_troopers) do
		if TestValid(blade_trooper) then
			blade_trooper.Set_Selectable(false)
			blade_trooper.Teleport(end_locations_bladebots_preplaced[i]) 
			blade_trooper.Set_Facing(90)
			blade_trooper.Suspend_Locomotor(true)
			blade_trooper.Change_Owner(neutral)
			blade_trooper.Enable_Behavior(79, false)
		else
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_Obj06_Groups_Setup: NOT TestValid(blade_trooper) !!"))
		end
	end
	
	--spawning in good old Vertigo, if needed
	if not TestValid(vertigo) then
		vertigo_spawn_spot = Find_Hint("MARKER_GENERIC_BLACK","vertigo-goto")
		if TestValid(vertigo_spawn_spot) then
			vertigo = Spawn_Unit(Find_Object_Type("Novus_Hero_Vertigo"), vertigo_spawn_spot, neutral) 
			if TestValid(vertigo) then
				vertigo.Set_Selectable(false)
				vertigo.Move_To(vertigo.Get_Position())
				Sleep(1)
				--vertigo.Suspend_Locomotor(true)
			end
		end
	end
	
	--gotta spawn in a new Mirabel (in case player skipped states)
	if not TestValid(mirabel) then
		mirabel = Spawn_Unit(Find_Object_Type("Mirabel_360_Tutorial"), mirabel_goto_location, neutral) 
		mirabel.Teleport_And_Face(mirabel_goto_location)
	else
		mirabel.Teleport_And_Face(mirabel_goto_location)
	end
	
	if bool_show_expanded_hints == true then
		--Add_Independent_Hint(147)
	end
	
	--need to lock out the various hero abilities...upload/download + retreat
	player_faction.Reset_Story_Locks()
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", true, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", true, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Vertigo", "Upload_Unit_Ability",true,STORY)	
	player_faction.Lock_Unit_Ability("Novus_Hero_Vertigo", "Download_Unit_Ability",true,STORY)
	player_faction.Lock_Unit_Ability("Novus_Antimatter_Tank", "Unit_Ability_Antimatter_Spray_Projectiles_Attack",true,STORY)
	player_faction.Lock_Unit_Ability("Novus_Reflex_Trooper", "Unit_Ability_Spawn_Clones",true,STORY)
	player_faction.Lock_Unit_Ability("Novus_Reflex_Trooper", "Unit_Ability_Blackout_Bomb_Attack",true,STORY)	
	player_faction.Lock_Unit_Ability("Novus_Amplifier", "Novus_Amplifier_Harmonic_Pulse",true,STORY)	
	
	player_faction.Lock_Generator("AmplifierCascadeResonanceBeamEffectGenerator", true )
	
	
	
	Create_Thread("Thread_Start_GroupObjectives")
end



function Thread_Start_GroupObjectives()


	--********************************Novus_Antimatter_Tank******************************
--if false then
	--goto a quick ingame cine to show all the antimatter tanks....
	camera01_antimatter = Find_Hint("MARKER_CAMERA","camera01-antimatter")
	target01_antimatter  = Find_Hint("MARKER_CAMERA","target01-antimatter")
	target02_antimatter = Find_Hint("MARKER_CAMERA","target02-antimatter")

	--the following camera move just points out the antimatter tanks to the player
	--Fade_Screen_Out(0)
	Point_Camera_At(snipe_target02_flag) 
	Sleep(1)
	Start_Cinematic_Camera()
	Letter_Box_In(0.1)
	
	Transition_Cinematic_Camera_Key(camera01_antimatter, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Target_Key(target01_antimatter, 0, 0, 0, 0, 0, 0, 0, 0)
	
	Fade_Screen_In(2) 
	Sleep(1)
	
	Transition_Cinematic_Target_Key(target02_antimatter, 5, 0, 0, 0, 0, 0, 0, 0)
	
	Sleep(1)
	
	Queue_Talking_Head(pip_founder, "TUT360_SCENE10_05") --Founder (FOU):  Good, all our control systems are verified. We should begin moving incursion units to their final positions.
	
	--turn all antimatter tanks back over to the player
	list_antimatter_tanks = Find_All_Objects_With_Hint("playerunit", "Novus_Antimatter_Tank")
	
	for i, antimatter_tank in pairs(list_antimatter_tanks) do
		if TestValid(antimatter_tank) then
			antimatter_tank.Change_Owner(novus)
			antimatter_tank.Suspend_Locomotor(true)
			antimatter_tank.Highlight_Small(true)
			
			Create_Generic_Object(Find_Object_Type("Highlight_Area"), antimatter_tank, neutral)
		end
	end
	
	Sleep(4)
	
	Transition_To_Tactical_Camera(5)
	Sleep(5)
	Letter_Box_Out(1)
	Sleep(1)
	End_Cinematic_Camera()
	
	Lock_Controls(0)
	
	--no using the X button to select units.
	Controller_Set_Tactical_Component_Lock("X_BUTTON",true)
	Controller_Set_Tactical_Component_Lock("A_BUTTON_DOUBLE_PRESS",true) --need to be able to lock out double tap A-BUTTON select all of type.
	
	bool_show_radar_map = true
	UI_Show_Radar_Map(true)
	x360tut_group_objective00 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06")--Topic: Group tool

	BlockOnCommand(Queue_Talking_Head(pip_founder, "TUT360_SCENE10_06")) --Founder (FOU):  Prepare the last of the Anti-Matter Tanks for mobilization.

	-- Maria 01.10.2008: we have to make sure we pull the unit from the pull of units belonging to the local player (novus in this case)
	-- otherwise we won't be able to find the control group containing it and the UI_Flash_Control_Group_Containing_Unit will fail.
	if list_antimatter_tanks and #list_antimatter_tanks > 1 then
		group_unit = list_antimatter_tanks[1]
	end
		
	if TestValid(group_unit) then
		UI_Flash_Control_Group_Containing_Unit(group_unit)
		_CustomScriptMessage("JoeLog.txt", string.format("UI_Flash_Control_Group_Containing_Unit(Novus_Antimatter_Tank)"))
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! UI_Flash_Control_Group_Containing_Unit(Novus_Antimatter_Tank)"))
	end
	
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06b_ADD"} )--New objective: Select all the Antimatter Tanks using the group tool.
	Sleep(time_objective_sleep)
	x360tut_group_objective01a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06b")--Select all the Antimatter Tanks using the group tool.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective01a)
	
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(148)
	end
	
	bool_units_selected = false
	while bool_units_selected == false do
		Sleep(1)
		bool_units_selected = true
		for i, antimatter_tank in pairs(list_antimatter_tanks) do
			if TestValid(antimatter_tank) then
				if not antimatter_tank.Is_Selected() then 
					bool_units_selected = false
					break
				end
			end
		end
	end
	
	
	_CustomScriptMessage("JoeLog.txt", string.format("BOOM! All antimatter tanks selected."))
	--remove the ground highlights
	list_highlights = Find_All_Objects_Of_Type("Highlight_Area")
	for i, highlight in pairs(list_highlights) do
		if TestValid(highlight) then
			highlight.Despawn()
		end
	end
	
	--complete the objective...
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective01a)
	--turn their locotomors back on so player can actully move them
	current_units = Find_All_Objects_Of_Type("Novus_Antimatter_Tank")
	for i, unit in pairs(current_units) do
		if TestValid(unit) then
			unit.Suspend_Locomotor(false)
		end
	end
	
	
	
	--add the objective to now move them to their mark
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c_ADD"} )--New objective: Move all the Antimatter Tanks to the location flashing on the radar map.
	--12/10/07 bug fix for showing radar pings before objective comes up
	--610
	anitmatter_goto_flag.Highlight(true)
	Add_Radar_Blip(anitmatter_goto_flag, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), anitmatter_goto_flag, neutral)
	
	
	Sleep(time_objective_sleep)
	x360tut_group_objective01b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c")--Move all the Antimatter Tanks to the location flashing on the radar map.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective01b)
	
	Register_Prox(anitmatter_goto_flag, Prox_GroupObjective01b, 50, novus)
	
	
	--wait until they've reached their mark
	bool_GroupObjective01b_completed = false
	while bool_GroupObjective01b_completed == false do
		Sleep(1)
	end
	
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective01b)
	anitmatter_goto_flag.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	
	BlockOnCommand(Queue_Talking_Head(pip_founder, "TUT360_SCENE10_07")) --Founder (FOU):  Systems check. Now direct the tanks to the staging area.
	
	--add the objective to now move them to their mark
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c2_ADD"} )--New objective: Move all the Antimatter Tanks to the location flashing on the radar map.
	
	--12/10/07 bug fix for showing radar pings before objective comes up
	--610
	portal_goto.Highlight(true)
	Add_Radar_Blip(portal_goto, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), portal_goto, neutral)
	
	Sleep(time_objective_sleep)
	x360tut_group_objective01c = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06c2")--Move all the Antimatter Tanks to the portal staging area.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective01c)
	Register_Prox(portal_goto, Prox_GroupObjective01c, 50, novus)
	
	
	--wait until they've reached their mark
	bool_GroupObjective01c_completed = false
	while bool_GroupObjective01c_completed == false do
		Sleep(1)
	end
	
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective01c)
	portal_goto.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	
	--this "thread" just teleports the units to the marks they are at during the cinematic...too many
	--pathfind issues to rely on them moving here naturally.
	Create_Thread("Thread_PortalUnits_Take_Your_Mark", index_anitmattertanks)
	
	--**********************Novus_Reflex_Trooper*****************************
	
	Sleep(5)
	--Fade_Screen_Out(1)
	--Sleep(1)
	--Point_Camera_At(marker_radarcontrol_jumpto) 
	--Start_Cinematic_Camera()
	--Letter_Box_In(0.1)
	--Fade_Screen_In(2) 
	--Sleep(1)
	--Letter_Box_Out(1)
	--Sleep(1)
	--End_Cinematic_Camera()
	
	--Point_Camera_At(marker_radarcontrol_jumpto)
	Point_Camera_At(fieldinverter_goto02)
	
	--BlockOnCommand(Queue_Talking_Head(pip_founder, "TUT360_SCENE10_07")) --Founder (FOU):  Systems check. Now direct the tanks to the staging area.
	BlockOnCommand(Queue_Talking_Head(pip_founder, "TUT360_SCENE10_09"))--Founder (FOU):  Good. Now assemble the remaining Blade Troopers and direct them to the portal staging area.
	
	-- Maria 01.10.2008 Moving this here to make sure the blade troopers belong to the Novus player
	-- before issuing the UI_Flash_Control_Group_Containing_Unit command, otherwise, they won't be part of 
	-- the novus player's control groups and the flash command will fail.
	
	--redefning my blade trooper list for the "Real" blade troopers
	list_blade_troopers = Find_All_Objects_With_Hint("bladetrooper-start", "Novus_Reflex_Trooper")
	for i, blade_trooper in pairs(list_blade_troopers) do
		if TestValid(blade_trooper) then
			blade_trooper.Change_Owner(novus)
			blade_trooper.Set_Selectable(true)
		end
	end
	
	if list_blade_troopers and #list_blade_troopers > 1 then
		group_unit = list_blade_troopers[1]
	end
	
	if TestValid(group_unit) then
		UI_Flash_Control_Group_Containing_Unit(group_unit)
		_CustomScriptMessage("JoeLog.txt", string.format("UI_Flash_Control_Group_Containing_Unit(Novus_Reflex_Trooper)"))
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! UI_Flash_Control_Group_Containing_Unit(Novus_Reflex_Trooper)"))
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06d_ADD"} )--Select all the Blade Troopers using the group tool.
	Sleep(time_objective_sleep)
	x360tut_group_objective02a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06d")--Select all the Blade Troopers using the group tool.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective02a)
	

	
	bool_units_selected = false
	while bool_units_selected == false do
		Sleep(1)
		bool_units_selected = true
		for i, blade_trooper in pairs(list_blade_troopers) do
			if TestValid(blade_trooper) then
				if not blade_trooper.Is_Selected() then 
					bool_units_selected = false
					break
				end
			end
		end
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("BOOM! All blade_troopers selected."))
	
	list_highlights = Find_All_Objects_Of_Type("Highlight_Area")
	for i, highlight in pairs(list_highlights) do
		if TestValid(highlight) then
			highlight.Despawn()
		end
	end
	
	--complete the objective...and kill any reminders
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective02a) 
	--current_units = Find_All_Objects_Of_Type("Novus_Reflex_Trooper")
	
	current_units = Find_All_Objects_With_Hint("bladetrooper-start", "Novus_Reflex_Trooper")

	--xxx fix me here for extra blade troopers
	
	for i, unit in pairs(current_units) do
		if TestValid(unit) then
			unit.Suspend_Locomotor(false)
		end
	end
	
	--add the objective to now move them to their mark
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06e_ADD"} )--Move all the Blade Troopers to the location flashing on the radar map.
	Sleep(time_objective_sleep)
	
	--12/10/07 bug fix for showing radar pings before objective comes up
	--610
	portal_goto.Highlight(true)
	Add_Radar_Blip(portal_goto, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), portal_goto, neutral)
	
	x360tut_group_objective02b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06e")
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective02b)

	Register_Prox(portal_goto, Prox_GroupObjective02b, 50, novus)
	
	bool_GroupObjective02b_completed = false
	while bool_GroupObjective02b_completed == false do
		Sleep(1)
	end
	
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective02b)
	portal_goto.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	
	Create_Thread("Thread_PortalUnits_Take_Your_Mark", index_blade_troopers)
	
	--*****************************Novus_Amplifier**********************************
	--the following cine mode just shows the  player that the amplifiers are spread out across the map
	amplifier01 = Find_Hint("NOVUS_AMPLIFIER","amplifier01")
	amplifier02 = Find_Hint("NOVUS_AMPLIFIER","amplifier02")
	amplifier03 = Find_Hint("NOVUS_AMPLIFIER","amplifier03")
	amplifier04 = Find_Hint("NOVUS_AMPLIFIER","amplifier04")
	amplifier05 = Find_Hint("NOVUS_AMPLIFIER","amplifier05")
	amplifier06 = Find_Hint("NOVUS_AMPLIFIER","amplifier06")
	
	--Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Letter_Box_In(0.1)
	--Fade_Screen_In(2)
	
	Queue_Talking_Head(pip_founder, "TUT360_SCENE10_02") --Founder (FOU):  Now we should verify our logic upgrade. When selecting a unit type, all corresponding units across the map will also be selected, regardless of their location. Please confirm by selecting all Amplifiers at this time.

	
	--this routine just does a quick tour of the map to show the player that 
	--all these units are spread out.
	Point_Camera_At(amplifier01) 
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	amplifier01.Highlight_Small(true)
	Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier01, neutral)
	Sleep(1)
	
	Point_Camera_At(amplifier02) 
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	amplifier02.Highlight_Small(true)
	Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier02, neutral)
	Sleep(1)
	
	Point_Camera_At(amplifier03) 
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	amplifier03.Highlight_Small(true)
	Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier03, neutral)
	Sleep(1)
	
	Point_Camera_At(amplifier04) 
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	amplifier04.Highlight_Small(true)
	Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier04, neutral)
	Sleep(1)
	
	Point_Camera_At(amplifier05) 
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	amplifier05.Highlight_Small(true)
	Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier05, neutral)
	--Sleep(1)
	
	--Point_Camera_At(amplifier06) 
	--Transition_To_Tactical_Camera(1)
	--Sleep(1)
	amplifier06.Highlight_Small(true)
	Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier06, neutral)

	Transition_To_Tactical_Camera(2)
	Sleep(2)
	Letter_Box_Out(1)
	Sleep(1)
	End_Cinematic_Camera()
	Lock_Controls(0)
	
	list_amplifiers = Find_All_Objects_Of_Type("Novus_Amplifier")
	for i, amplifier in pairs(list_amplifiers) do
		if TestValid(amplifier) then
			amplifier.Change_Owner(novus)
			amplifier.Suspend_Locomotor(true)			
			Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier, neutral)
		end
	end
	
	group_unit = Find_First_Object("Novus_Amplifier")
	UI_Flash_Control_Group_Containing_Unit(group_unit)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06f_ADD"} )--Select all the Amplifiers using the group tool.
	Sleep(time_objective_sleep)
	x360tut_group_objective03a = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06f")--Select all the Amplifiers using the group tool.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective03a)

	bool_units_selected = false
	while bool_units_selected == false do
		Sleep(1)
		bool_units_selected = true
		for i, amplifier in pairs(list_amplifiers) do
			if TestValid(amplifier) then
				if not amplifier.Is_Selected() then 
					bool_units_selected = false
					break
				end
			end
		end
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("BOOM! All amplifiers selected."))
	
	
	
	list_highlights = Find_All_Objects_Of_Type("Highlight_Area")
	for i, highlight in pairs(list_highlights) do
		if TestValid(highlight) then
			highlight.Despawn()
		end
	end
	
	--complete the objective...
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective03a) 
	current_units = Find_All_Objects_Of_Type("Novus_Amplifier")
	for i, unit in pairs(current_units) do
		if TestValid(unit) then
			unit.Suspend_Locomotor(false)
		end
	end
	
	Queue_Talking_Head(pip_founder, "TUT360_SCENE10_01") --Founder (FOU):  Good, now direct the Amplifiers to the location indicated.
	
	--add the objective to now move them to their mark
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g_ADD"} )--New objective: Move all the Antimatter Tanks to the location flashing on the radar map.
	
	--12/10/07 bug fix for showing radar pings before objective comes up
	--610
	amplifier_goto_flag.Highlight(true)
	Add_Radar_Blip(amplifier_goto_flag, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), amplifier_goto_flag, neutral)
	
	
	Sleep(time_objective_sleep)
	x360tut_group_objective03b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g")--Move all the Amplifiers to the location flashing on the radar map.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective03b) 
	
	
	Register_Prox(amplifier_goto_flag, Prox_GroupObjective03b, 50, novus)
	
	
	--wait until they've reached their mark
	bool_GroupObjective03b_completed = false
	while bool_GroupObjective03b_completed == false do
		Sleep(1)
	end
	
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective03b)
	amplifier_goto_flag.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	
	Queue_Talking_Head(pip_founder, "TUT360_SCENE10_08") --Founder (FOU):  Excellent, dispatch the Amplifiers the portal staging area.
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g2_ADD"} )--New objective: Move the Amplifiers to the portal staging area.
	
	--12/10/07 bug fix for showing radar pings before objective comes up
	--610
	portal_goto.Highlight(true)
	Add_Radar_Blip(portal_goto, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), portal_goto, neutral)
	
	Sleep(time_objective_sleep)
	x360tut_group_objective03c = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06g2")--Move the Amplifiers to the portal staging area.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective03c) 

	Register_Prox(portal_goto, Prox_GroupObjective03c, 50, novus)
	
	
	bool_GroupObjective03c_completed = false
	while bool_GroupObjective03c_completed == false do
		Sleep(1)
	end
	
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective03c)
	portal_goto.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	
	Create_Thread("Thread_PortalUnits_Take_Your_Mark", index_amplifiers)
	
	Sleep(time_objective_sleep)
--end


	
	if TestValid(mirabel) then
		Point_Camera_At(mirabel)
		mirabel.Change_Owner(player_faction)
		mirabel.Suspend_Locomotor(true)
		mirabel.Set_Selectable(true)
		mirabel.Highlight(true, -50)
		Add_Radar_Blip(mirabel, "DEFAULT", "blip_mirabel")
		mirabel_ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), mirabel, neutral)

	end
	
	if TestValid(vertigo) then
		vertigo.Change_Owner(player_faction)
		vertigo.Suspend_Locomotor(true)
		vertigo.Set_Selectable(true)
		vertigo.Highlight(true, -50)
		Add_Radar_Blip(vertigo, "DEFAULT", "blip_vertigo")
		vertigo_ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), vertigo, neutral)
	end
	
	BlockOnCommand(Queue_Talking_Head(pip_founder, "TUT360_SCENE10_03")) --Founder (FOU):  We need to test our custom-grouping routines. Try combining Mirabel and Vertigo into their own group.
	
	--new mirable and victor objective here
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06h_ADD"} )--New objective: Move all the Antimatter Tanks to the location flashing on the radar map.
	if bool_show_expanded_hints == true then
		Add_Independent_Hint(145)
	end
	Sleep(time_objective_sleep)
	x360tut_group_objective04 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06h")--Combine Mirabel and Victor into their own control group.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective04) 
	
	
	
	mirabel.Register_Signal_Handler(Callback_Object_Control_Group_Changed, "OBJECT_CONTROL_GROUP_CHANGED")
	vertigo.Register_Signal_Handler(Callback_Object_Control_Group_Changed, "OBJECT_CONTROL_GROUP_CHANGED")
	
	mirabel_control_group = -1
	vertigo_control_group = -1
	
	while mirabel_control_group == -1 or vertigo_control_group == -1 or mirabel_control_group ~= vertigo_control_group do
		Sleep(1)
	end

	Objective_Complete(x360tut_group_objective04)
	Thread.Kill(thread_id_objective_reminders)
	mirabel.Highlight(false)
	vertigo.Highlight(false)
	Remove_Radar_Blip("blip_mirabel")
	Remove_Radar_Blip("blip_vertigo")
	if TestValid(mirabel_ground_highlight) then
		mirabel_ground_highlight.Despawn()
	end
	if TestValid(vertigo_ground_highlight) then
		vertigo_ground_highlight.Despawn()
	end
	
	mirabel.Suspend_Locomotor(false)
	vertigo.Suspend_Locomotor(false)
	
	Sleep(time_objective_sleep)
	
	BlockOnCommand(Queue_Talking_Head(pip_founder, "TUT360_SCENE10_04")) --Founder (FOU):  Excellent, formation confirmed. Now assemble at the portal staging area, we'll be deploying momentarily.
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06i_ADD"} )--New objective: Move Mirabel and Victor to the portal staging area.
	
	--12/10/07 bug fix for showing radar pings before objective comes up
	--610
	portal_goto.Highlight(true)
	Add_Radar_Blip(portal_goto, "DEFAULT", "blip_objective")
	ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), portal_goto, neutral)
	
	Sleep(time_objective_sleep)
	x360tut_group_objective04b = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_06i")--New objective: Move Mirabel and Victor to the portal staging area.
	
	if Thread.Is_Thread_Active(thread_id_objective_reminders) then
		Thread.Kill(thread_id_objective_reminders)
	end
	
	thread_id_objective_reminders = Create_Thread("Thread_Recycle_Objectives", x360tut_group_objective04b) 
	
	Register_Prox(portal_goto, Prox_GroupObjective04b, 50, novus)
	
	bool_GroupObjective04b_completed = false
	while bool_GroupObjective04b_completed == false do
		Sleep(1)
		_CustomScriptMessage("JoeLog.txt", string.format("while bool_GroupObjective04b_completed == false do"))
	end
	
	Thread.Kill(thread_id_objective_reminders)
	Objective_Complete(x360tut_group_objective04b)
	portal_goto.Highlight(false)
	Remove_Radar_Blip("blip_objective")
	if TestValid(ground_highlight) then
		ground_highlight.Despawn()
	end
	
	--Sleep(time_objective_sleep)
	--temp stall of victory conditions
	--while true do
	--	Sleep(5)
	--end
	--***************************player wins*******************************	`
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	--Sleep(5)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	
	Create_Thread("Thread_Mission_Complete")
	
end

--player_produced_bladetrooper03.Register_Signal_Handler(Callback_Object_Control_Group_Changed, "OBJECT_CONTROL_GROUP_CHANGED")
--mod for new custom group 
function Callback_Object_Control_Group_Changed(object)
	if object == mirabel then 
		mirabel_control_group = object.Get_Control_Group_Assignment()
		_CustomScriptMessage("JoeLog.txt", string.format("Callback_Object_Control_Group_Changed: mirabel_control_group changed"))
	elseif object == vertigo then 
		vertigo_control_group = object.Get_Control_Group_Assignment()
		_CustomScriptMessage("JoeLog.txt", string.format("Callback_Object_Control_Group_Changed:vertigo_control_group changed"))
	end
end

function Thread_PortalUnits_Take_Your_Mark(unit_index)
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_PortalUnits_Take_Your_Mark HIT!"))
	local list_units = nil
	local list_goto_spots = nil
	local facing = nil
	
	if unit_index == index_anitmattertanks then -- antimatter tanks are by the portal...make them now line up at their marks
		list_goto_spots = end_locations_antimatter
		list_units = Find_All_Objects_With_Hint("playerunit", "Novus_Antimatter_Tank")
		facing = 180
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_PortalUnits_Take_Your_Mark antimatter stuff defined!"))
	elseif unit_index == index_blade_troopers then -- blade troopers are by the portal...make them now line up at their marks
		list_goto_spots = end_locations_bladebots
		list_units = Find_All_Objects_With_Hint("bladetrooper-start", "Novus_Reflex_Trooper")
		facing = 90
	elseif unit_index == index_amplifiers then
		list_goto_spots = end_locations_amplifiers
		list_units =Find_All_Objects_Of_Type("Novus_Amplifier")
		facing = 90
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! Thread_PortalUnits_Take_Your_Mark hit with BAD INDEX!!"))
	end
	
	Fade_Screen_Out(1)
	Lock_Controls(1)
	Sleep(1)
	
	for i, unit in pairs(list_units) do
		if TestValid(unit) then
				unit.Stop()
		else
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_PortalUnits_Take_Your_Mark NOT TestValid(unit)!"))
		end
	end
	
	Sleep(2) -- sleep to give stop() a chance to work before i suspend the locomotors.
	
	for i, unit in pairs(list_units) do
		if TestValid(unit) then
				unit.Set_Selectable(false)
				unit.Change_Owner(neutral)
				unit.Teleport(list_goto_spots[i])
				unit.Set_Facing(facing)
				unit.Highlight_Small(false)
				unit.Enable_Behavior(79, false)
				unit.Suspend_Locomotor(true)
		else
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_PortalUnits_Take_Your_Mark NOT TestValid(unit)!"))
		end
	end
	
	Fade_Screen_In(1)
	Lock_Controls(0)
	Sleep(1)
	
end

--******************************************************
--PROX events used in the group teaching section
--******************************************************
function Prox_GroupObjective01b(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Antimatter_Tank") then
		--hopefully player has followed directions...completing objecitve
		bool_GroupObjective01b_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_GroupObjective01b)
	end
end

function Prox_GroupObjective01c(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Antimatter_Tank") then
		--hopefully player has followed directions...completing objecitve
		bool_GroupObjective01c_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_GroupObjective01c)
	end
end

function Prox_GroupObjective02b(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Reflex_Trooper") then
		--hopefully player has followed directions...completing objecitve
		bool_GroupObjective02b_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_GroupObjective02b)
	end
end


function Prox_GroupObjective03b(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Amplifier") then
		--hopefully player has followed directions...completing objecitve
		bool_GroupObjective03b_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_GroupObjective03b)
	end
end

function Prox_GroupObjective03c(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Novus_Amplifier") then
		--hopefully player has followed directions...completing objecitve
		bool_GroupObjective03c_completed = true
		prox_obj.Cancel_Event_Object_In_Range(Prox_GroupObjective03c)
	end
end

function Prox_GroupObjective04b(prox_obj, trigger_obj)
	_CustomScriptMessage("JoeLog.txt", string.format("Prox_GroupObjective04b HIT"))

	local obj_type = trigger_obj.Get_Type()
	if obj_type == Find_Object_Type("Mirabel_360_Tutorial") or 
		obj_type == Find_Object_Type("Novus_Hero_Vertigo")  then
		--hopefully player has followed directions...completing objecitve
		bool_GroupObjective04b_completed = true
		_CustomScriptMessage("JoeLog.txt", string.format("Prox_GroupObjective04b bool_GroupObjective04b_completed = true"))
		prox_obj.Cancel_Event_Object_In_Range(Prox_GroupObjective04b)
	end
end



function Thread_Mission_Complete()
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
-- this music is faction specific, 
-- use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	Play_Music("Novus_Win_Tactical_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(5)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	
	--Don't want the victory music playing over the cutscene
	Fade_Out_Music() 
	BlockOnCommand(Play_Bink_Movie("360Tutorial_Finale", true))
	
	Lock_Controls(0)
	Force_Victory(novus)

end

function Force_Victory(player)

	Lock_Out_Stuff(false)

	if player == novus then
		-- Inform the campaign script of our victory.
		--global_script.Call_Function("Hierarchy_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		Quit_Game_Now(player, false, true, false)
	else
		Show_Retry_Dialog()
	end
end

function Lock_Out_Stuff(bool)
	Create_Thread("Thread_Lock_Out_Stuff", bool)
end

function Thread_Lock_Out_Stuff(bool)
	Sleep(3) -- need this delay now for some sort of behind-the-scenes initializing issue.
	player_faction.Lock_Unit_Ability("Novus_Reflex_Trooper", "Unit_Ability_Spawn_Clones",bool,STORY)
	player_faction.Lock_Unit_Ability("Novus_Reflex_Trooper", "Unit_Ability_Blackout_Bomb_Attack",bool,STORY)
	
	player_faction.Lock_Object_Type(Find_Object_Type("NM04_Novus_Portal"),bool,STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Remote_Terminal"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_EMP"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_Gravity_Bomb"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Signal_Tower"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Redirection_Turret"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Power_Router"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Input_Station"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Aircraft_Assembly"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab"),bool, STORY)
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),bool,STORY)

	player_faction.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false )
	uea.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false )
	
	--dont want variants to mimic anything
	neutral.Lock_Generator("NovusMirageFieldGenerator", true )
	
	neutral.Lock_Generator("NovusReflexTrooperCloakEffectGenerator", true )
	novus.Lock_Generator("NovusReflexTrooperCloakEffectGenerator", true )
	hostile.Lock_Generator("NovusReflexTrooperCloakEffectGenerator", true )
	
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", bool, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Minirocket_Barrage", bool, STORY)
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Unit_Ability_Mech_Vehicle_Snipe_Attack", bool, STORY)

end

function Define_Hints()
	PGColors_Init_Constants()
	novus.Enable_Colorization(true, 6)
	aliens.Enable_Colorization(true, 2)
	neutral.Enable_Colorization(true, 6)
	
	fow_novus_reveal = FogOfWar.Reveal_All(novus)
	
	camera_start = Find_Hint("MARKER_GENERIC_GREEN","camera-start")
	
	founder = Find_First_Object("NOVUS_HERO_FOUNDER")
	if not TestValid(founder) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: not TestValid(founder)"))
	else
		founder.Teleport_And_Face(camera_start)
		founder.Set_Cannot_Be_Killed(true)
		founder.Change_Owner(neutral)
	end
	
	trooper_29_11_startspot = Find_Hint("MARKER_GENERIC_BLACK","start-2911")
	
	trooper_29_11 = Find_First_Object("X360_Tutorial_29-11")
	if not TestValid(trooper_29_11) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: not TestValid(trooper_29_11)"))
	else
		trooper_29_11.Teleport_And_Face(trooper_29_11_startspot)
		trooper_29_11.Set_Selectable(false)
		trooper_29_11.Set_Cannot_Be_Killed(true)
		trooper_29_11.Change_Owner(novus)
	end
	
	players_constructor_location = Find_Hint("MARKER_GENERIC_GREEN","construction-start-constructor")
	if not TestValid(players_constructor_location) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: not TestValid(players_constructor_location)"))
	end
	
	players_constructor_spawn_loc = Find_Hint("MARKER_GENERIC_GREEN","constructor-spawn-loc")
	if not TestValid(players_constructor_spawn_loc) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: not TestValid(players_constructor_spawn_loc)"))
	end
	
	state_switch = Find_Hint("CIVILIAN_AMBULANCE","state-switch")
	if not TestValid(state_switch) then
		_CustomScriptMessage("JoeLog.txt", string.format("WARNING!!!  not TestValid(state_switch) "))

	else
		state_switch.Register_Signal_Handler(Callback_State_Switch_Destroyed, "OBJECT_DELETE_PENDING")
		state_switch_pos = state_switch.Get_Position()
	end
	
	list_preplaced_novus_structures = Find_All_Objects_With_Hint("preplaced")
	for i, preplaced_novus_structure in pairs(list_preplaced_novus_structures) do
		if TestValid(preplaced_novus_structure) then
			preplaced_novus_structure.Change_Owner(neutral)
			preplaced_novus_structure.Enable_Behavior(79, false)
		end
	end
	
	list_neutral_fieldinverters = Find_All_Objects_Of_Type("Novus_Field_Inverter", neutral)
	for i, neutral_fieldinverter in pairs(list_neutral_fieldinverters) do
		if TestValid(neutral_fieldinverter) then
			neutral_fieldinverter.Enable_Behavior(79, false)
		end
	end
	
	moveto_2911_01 = Find_Hint("MARKER_GENERIC_BLACK","moveto-2911-01")
	if not TestValid(moveto_2911_01) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(2911_moveto_01) "))
	end
	
	moveto_2911_02 = Find_Hint("MARKER_GENERIC_BLACK","moveto-2911-02")
	if not TestValid(moveto_2911_02) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(2911_moveto_02) "))
	end
	
	fieldinverter01 = Find_Hint("NOVUS_FIELD_INVERTER","fieldinverter01")
	fieldinverter02 = Find_Hint("NOVUS_FIELD_INVERTER","fieldinverter02")
	fieldinverter03 = Find_Hint("NOVUS_FIELD_INVERTER","fieldinverter03")
	fieldinverter_goto01 = Find_Hint("MARKER_GENERIC_BLACK","fieldinverter-goto01")
	fieldinverter_goto02 = Find_Hint("MARKER_GENERIC_BLACK","fieldinverter-goto02")
	
	fieldinverter01_final = Find_Hint("MARKER_GENERIC_BLACK","fieldinverter01-final")
	fieldinverter02_final = Find_Hint("MARKER_GENERIC_BLACK","fieldinverter02-final")
	fieldinverter03_final = Find_Hint("MARKER_GENERIC_BLACK","fieldinverter03-final")
	
	mirabel_spawn_location = Find_Hint("MARKER_GENERIC_BLACK","mirabel-spawn")
	mirabel_transport_spawn_location = Find_Hint("MARKER_GENERIC_BLACK","mirabel-transport-spawn")
	
	civ_spawn01 = Find_Hint("MARKER_GENERIC_BLACK","spawn01")
	civ_spawn02 = Find_Hint("MARKER_GENERIC_BLACK","spawn02")
	civ_despawn01 = Find_Hint("MARKER_GENERIC_BLACK","despawn01")
	civ_despawn02 = Find_Hint("MARKER_GENERIC_BLACK","despawn02")
	
	civ_spawn03 = Find_Hint("MARKER_GENERIC_BLACK","spawn03")
	civ_despawn03 = Find_Hint("MARKER_GENERIC_BLACK","despawn03")
	civ_spawn04 = Find_Hint("MARKER_GENERIC_BLACK","spawn04")
	civ_despawn04 = Find_Hint("MARKER_GENERIC_BLACK","despawn04")
	civ_spawn05 = Find_Hint("MARKER_GENERIC_BLACK","spawn05")
	civ_despawn05 = Find_Hint("MARKER_GENERIC_BLACK","despawn05")
	civ_spawn06 = Find_Hint("MARKER_GENERIC_BLACK","spawn06")
	civ_despawn06 = Find_Hint("MARKER_GENERIC_BLACK","despawn06")
	
	civ_spawn07 = Find_Hint("MARKER_GENERIC_BLACK","spawn07")
	civ_despawn07 = Find_Hint("MARKER_GENERIC_BLACK","despawn07")
	civ_spawn08 = Find_Hint("MARKER_GENERIC_BLACK","spawn08")
	civ_despawn08 = Find_Hint("MARKER_GENERIC_BLACK","despawn08")
	civ_spawn09 = Find_Hint("MARKER_GENERIC_BLACK","spawn09")
	civ_despawn09 = Find_Hint("MARKER_GENERIC_BLACK","despawn09")
	civ_spawn10 = Find_Hint("MARKER_GENERIC_BLACK","spawn10")
	civ_despawn10 = Find_Hint("MARKER_GENERIC_BLACK","despawn10")
	
	civ_spawn11 = Find_Hint("MARKER_GENERIC_BLACK","spawn11")
	civ_despawn11 = Find_Hint("MARKER_GENERIC_BLACK","despawn11")
	civ_spawn12 = Find_Hint("MARKER_GENERIC_BLACK","spawn12")
	civ_despawn12 = Find_Hint("MARKER_GENERIC_BLACK","despawn12")
	civ_spawn13 = Find_Hint("MARKER_GENERIC_BLACK","spawn13")
	civ_despawn13 = Find_Hint("MARKER_GENERIC_BLACK","despawn13")
	civ_spawn14 = Find_Hint("MARKER_GENERIC_BLACK","spawn14")
	civ_despawn14 = Find_Hint("MARKER_GENERIC_BLACK","despawn14")
	civ_spawn15 = Find_Hint("MARKER_GENERIC_BLACK","spawn15")
	civ_despawn15 = Find_Hint("MARKER_GENERIC_BLACK","despawn15")
	civ_spawn16 = Find_Hint("MARKER_GENERIC_BLACK","spawn16")
	civ_despawn16 = Find_Hint("MARKER_GENERIC_BLACK","despawn16")
	civ_spawn17 = Find_Hint("MARKER_GENERIC_BLACK","spawn17")
	civ_despawn17 = Find_Hint("MARKER_GENERIC_BLACK","despawn17")
	civ_spawn18 = Find_Hint("MARKER_GENERIC_BLACK","spawn18")
	civ_despawn18 = Find_Hint("MARKER_GENERIC_BLACK","despawn18")
	
	novus_portal = Find_First_Object("X360_TUTORIAL_PORTAL")
	if not TestValid(novus_portal) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(novus_portal) "))
	else
		novus_portal.Play_Animation("Anim_Idle", true, 0)
	end
	
	--defining the flags used in Mirabels snipe objective
	snipe_target01_flag = Find_Hint("MARKER_GENERIC_RED", "mirabel-target-snipe01")
	snipe_target02_flag = Find_Hint("MARKER_GENERIC_RED", "mirabel-target-snipe02")
	
	--spawn in the new targets Adam Pitts made
	snipe_target01 = Spawn_Unit(Find_Object_Type("CIN_Novus_Homeworld_SnipeTarget"), snipe_target01_flag, novus) 
	snipe_target02 = Spawn_Unit(Find_Object_Type("CIN_Novus_Homeworld_SnipeTarget"), snipe_target02_flag, novus) 
	
	--put the targets into idle loops
	snipe_target01.Play_Animation("Anim_Cinematic", true, 0)
	snipe_target02.Play_Animation("Anim_Cinematic", true, 0)
	
	--this is where mirabel waits after her combat training.
	mirabel_goto_location = Find_Hint("MARKER_GENERIC_BLACK","mirabel-final-goto")

	marker_radarcontrol_jumpto = Find_Hint("MARKER_GENERIC_BLACK","radarcontrol-jumpto")
		
	portal_goto = Find_Hint("MARKER_GENERIC_GREEN","portal-goto")
	
	--flyovers
	--hide all the preplaced flyover anim objects
	cinematic_flyovers = Find_All_Objects_With_Hint("flyover")
	flyover_max = table.getn(cinematic_flyovers)
	
	for i, flyover in pairs(cinematic_flyovers) do
		if TestValid(flyover) then
			flyover.Hide(true)
		end
	end
	
	anitmatter_goto_flag = Find_Hint("MARKER_GENERIC_BLACK","antimatter-goto")
	amplifier_goto_flag = Find_Hint("MARKER_GENERIC_BLACK","amplifier-goto")
	
	--used when teleporting units to their portal-ready locations
	index_anitmattertanks = 1
	index_blade_troopers = 2
	index_amplifiers = 3
	
	_CustomScriptMessage("JoeLog.txt", string.format("GG...running updated scripts."))
	--seeing if the robotic leader's flag is testing valid
	robotic_leader_flag = Find_Hint("MARKER_GENERIC_YELLOW","robotic-leader")
	if not TestValid(robotic_leader_flag) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(robotic_leader_flag) SCRIPT EXIT"))
		ScriptExit()
	end
	
	
	Create_Thread("Thread_Mission_Start")	

end





--******************************************************************************************
--This is my super-terrific dialog contoller ... most dialog gets driven from this funtion
--******************************************************************************************
function Thread_Dialog_Controller(conversation)
	if conversation == dialog_mission_intro then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE02_01") --Founder (FOU): Begin visual systems cross-check. Verify battlefield display.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_camera_zoom_in then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE02_02") --Founder (FOU): Excellent. Now increase magnification to maximum level.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_camera_zoom_out then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE02_03") --Founder (FOU): Now decrease magnification.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_camera_rotate then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE02_04") --Founder (FOU): Verify battlefield rotation algorithms.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
		
	elseif conversation == dialog_reset_camera_now then
		while bool_conversation_over == true do
			Sleep(1)
		end
		Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
		local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE02_05") --Founder (FOU): Algorithms confirmed. Reset visual systems to default view.
		BlockOnCommand(blocking_dialog)
		
		bool_conversation_over = true
	elseif conversation == dialog_camera_reset then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			--Queue_Talking_Head(pip_founder, "TUT360_SCENE02_05") --Founder (FOU): Algorithms confirmed. Visual feedback systems are fully operational.
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE03_01") --Novus Science (NSC): Attention: quantum waveform now at 30%.
			
			
			--jdg 12/10/07 redo
			--Queue_Talking_Head(pip_founder, "TUT360_SCENE03_02") --Founder (FOU): Our time is growing short. Begin radar systems cross-check. 
			
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_select_2911 then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
	
			--Queue_Talking_Head(pip_founder, "TUT360_SCENE03_04") --Founder (FOU): Radar systems confirmed. 
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE04_01") --Founder (FOU): Prepare to verify unit control.
			BlockOnCommand(blocking_dialog)
			
			Point_Camera_At(trooper_29_11)
			
			--Sleep(3)
			local blocking_dialog2 = Queue_Talking_Head(pip_founder, "TUT360_SCENE04_03") --Founder (FOU): Perform unit selection test.
			BlockOnCommand(blocking_dialog2)
			
			local intro_2911_location = Find_Hint("MARKER_GENERIC_BLACK","29-11-intro-goto")
			BlockOnCommand(trooper_29_11.Move_To(intro_2911_location.Get_Position()))
			if TestValid(trooper_29_11) then
				trooper_29_11.Highlight(true)
				Add_Radar_Blip(trooper_29_11, "DEFAULT", "blip_trooper_29_11")
				
				ground_highlight_2911_01 = Create_Generic_Object(Find_Object_Type("Highlight_Area"), trooper_29_11, neutral)
			end
			
			Queue_Talking_Head(pip_2911, "TUT360_SCENE04_02") --Blade Trooper 29-11 (BTR): Blade Trooper 29-11 awaiting input.

		end
		
		bool_conversation_over = true
	elseif conversation == dialog_move_2911 then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_2911, "TUT360_SCENE04_04") --Blade Trooper 29-11 (BTR): Blade Trooper ready.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE04_05") --Founder (FOU): Test confirmed. Now issue movement order to the designated location.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_move_2911_moving then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			local blocking_dialog = Queue_Talking_Head(pip_2911, "TUT360_SCENE04_06") --Blade Trooper 29-11 (BTR): Coordinates accepted. 
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_move_2911_via_radarmap then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_2911, "TUT360_SCENE04_07") --Blade Trooper 29-11 (BTR): Unit ready. 
			Queue_Talking_Head(pip_founder, "TUT360_SCENE04_08") --Founder (FOU): Excellent.  Now we should assess movement ability via the radar map. 
			Queue_Talking_Head(pip_2911, "TUT360_SCENE04_09") --Blade Trooper 29-11 (BTR): But my purpose is pain. Please provide more aggressive input.
			Queue_Talking_Head(pip_founder, "TUT360_SCENE04_10") --Founder (FOU): 29-11, you will comply with your orders! 
			local blocking_dialog = Queue_Talking_Head(pip_2911, "TUT360_SCENE04_11") --Blade Trooper 29-11 (BTR): If I must.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_scroll_via_radarmap then
		_CustomScriptMessage("JoeLog.txt", string.format("dialog_scroll_via_radarmap START"))
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_2911, "TUT360_SCENE04_06") --Blade Trooper 29-11 (BTR): Coordinates accepted. 
			
			Sleep(2)
			
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE03_03") --Founder (FOU): Locate target area on radar map and re-align viewpoint. 
			BlockOnCommand(blocking_dialog)
		end
		bool_conversation_over = true
	
	
	elseif conversation == dialog_move_2911_via_radarmap_done then
		_CustomScriptMessage("JoeLog.txt", string.format("dialog_move_2911_via_radarmap_done START"))
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_2911, "TUT360_SCENE04_12") --Blade Trooper 29-11 (BTR): 29-11 has complied.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE04_13") --Founder (FOU): Excellent, our control systems are fully functional. 
			BlockOnCommand(blocking_dialog)
			_CustomScriptMessage("JoeLog.txt", string.format("dialog_move_2911_via_radarmap_done: BlockOnCommand(blocking_dialog)"))
			
			while bool_bots_at_mark == false do
				_CustomScriptMessage("JoeLog.txt", string.format("while bool_bots_at_mark == false do Sleep(1)"))
				Sleep(1)
			end
			Create_Thread("Thread_Obj04_Combat_AttackArea") -- starts the robots attacking		
			_CustomScriptMessage("JoeLog.txt", string.format("dialog_move_2911_via_radarmap_done: Create_Thread(Thread_Obj04_Combat_AttackArea)"))
			
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE05_01") --Novus Science (NSC): Alert! Logic fault detected in infantry staging area!
			Queue_Talking_Head(pip_founder, "TUT360_SCENE05_02") --Founder (FOU): What is the cause of this error?
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE05_03") --Novus Science (NSC): A virus has infected the unit. The Ohm Robot must be disabled before it can spread.
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE05_04") --Novus Science (NSC): 29-11, your aggression protocols are authorized! Target that unit! 
			local blocking_dialog1 = Queue_Talking_Head(pip_2911, "TUT360_SCENE05_05") --Blade Trooper 29-11 (BTR): My threat sensors are tingling.
			BlockOnCommand(blocking_dialog1)
			_CustomScriptMessage("JoeLog.txt", string.format("dialog_move_2911_via_radarmap_done: BlockOnCommand(blocking_dialog1)"))
		end
		
		bool_conversation_over = true
		_CustomScriptMessage("JoeLog.txt", string.format("dialog_move_2911_via_radarmap_done: bool_conversation_over = true"))
	elseif conversation == dialog_combat_use_duplicate then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE05_06") --Novus Science (NSC): The virus is spreading! It must be contained.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE05_07") --Founder (FOU): Quickly, 29-11! Employ your Duplicate ability and terminate the others!
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_combat_duplicate_activated then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			local blocking_dialog = Queue_Talking_Head(pip_2911, "TUT360_SCENE05_08") --Blade Trooper 29-11 (BTR): More of me, means less of you.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_combat_done then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_2911, "TUT360_SCENE05_09") --Blade Trooper 29-11 (BTR): Ready to slice and dice.
			Queue_Talking_Head(pip_founder, "TUT360_SCENE05_10") --Founder (FOU): An acceptable outcome, 29-11, the virus has been contained. You may return to formation.
			local blocking_dialog1 = Queue_Talking_Head(pip_2911, "TUT360_SCENE05_11") --Blade Trooper 29-11 (BTR): My blades remain sharp.
			BlockOnCommand(blocking_dialog1)
			--destroy the duplicates
			list_duplicates = Find_All_Objects_Of_Type("Novus_Reflex_Trooper_Clone")
			for i, duplicate in pairs(list_duplicates) do
				if TestValid(duplicate) then
					duplicate.Take_Damage(9999999999, "Damage_Default") 
					_CustomScriptMessage("JoeLog.txt", string.format("duplicate.Take_Damage(9999999999, Damage_Default) "))
				end
			end

			--make 29-11 go back to his mark
			if TestValid(trooper_29_11) then
				trooper_29_11.Set_Selectable(false)
				trooper_29_11.Prevent_All_Fire(true)
				trooper_29_11.Prevent_Opportunity_Fire(true)
				trooper_29_11.Move_To(trooper_29_11_startspot.Get_Position())
				trooper_29_11.Enable_Behavior(79, false)
				_CustomScriptMessage("JoeLog.txt", string.format("Full_Speed_Move(trooper_29_11, trooper_29_11_startspot.Get_Position())"))
			end
			
			Sleep(3)
			
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE06_01") --Novus Science (NSC): Attention: quantum waveform now at 50%.
			local blocking_dialog2 = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_02") --Founder (FOU): We must accelerate our systems check. Replacing the damaged Ohm Robots will be a good test of our production capabilities. We'll need a Constructor unit to continue. 
			BlockOnCommand(blocking_dialog2)
			
			--lock out build options again
			--lock out build options here...dan the jerk is breaking the mission here....
			player_faction.Reset_Story_Locks()
			player_faction.Lock_Object_Type(Find_Object_Type("NM04_Novus_Portal"),true,STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab"),true,STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Redirection_Turret"),true,STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_EMP"),true,STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_Gravity_Bomb"),true,STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Remote_Terminal"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Signal_Tower"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Power_Router"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Input_Station"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Aircraft_Assembly"),true, STORY)
			player_faction.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly"),true, STORY)
			
			x360tut_objective05 = Add_Objective("TEXT_SP_MISSION_X360TUTORIAL_OBJECTIVE_05")--New objective: Learn how to build structures and units.
			
			players_constructor = Spawn_Unit(Find_Object_Type("Novus_Constructor"), players_constructor_spawn_loc, novus) 
			if not TestValid(players_constructor) then
				_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  x360 tutorial: Thread_Obj05_Construction_MakeConstructorFlow: not TestValid(players_constructor)"))
			end

			BlockOnCommand(Full_Speed_Move(players_constructor, players_constructor_location.Get_Position()))
			Sleep(1)
			players_constructor.Stop()

			if TestValid(players_constructor_location) then
				Add_Radar_Blip(players_constructor_location, "DEFAULT", "blip_players_constructor_location")
				players_constructor_location.Highlight(true)
				ground_highlight_marker_players_constructor_location = Create_Generic_Object(Find_Object_Type("Highlight_Area"), players_constructor_location, neutral)
			end
			
			Point_Camera_At(players_constructor)
			
			
			Play_SFX_Event("360Tut_Intro_Novus_Constructor")
			
			Sleep(3)
			
			local blocking_dialog3 = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_04") --Founder (FOU):  Good. Try selecting an idle Constructor now.
			BlockOnCommand(blocking_dialog3)
			
			if TestValid(trooper_29_11) then -- dont want him appearing in the group selection tool...changing to neutral
				trooper_29_11.Change_Owner(neutral)
				trooper_29_11.Turn_To_Face(founder)
			end
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_construction_center_view then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_05") --Founder (FOU):  Now center the view on that unit.
			BlockOnCommand(blocking_dialog)
		end

		bool_conversation_over = true
	elseif conversation == dialog_construction_move_constructor then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_06") --Founder (FOU):  Excellent, the application is working. Now send the Constructor to the designated area.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_construction_build_robotic_assembly then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_07") --Founder (FOU):  We'll start by building a Robotic Assembly. Select it on the construction tab and find a suitable area on the ground for placement. 
			BlockOnCommand(blocking_dialog)
		end

		bool_conversation_over = true
	elseif conversation == dialog_construction_place_rally_point then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE06_09") --Novus Science (NSC): Attention: quantum waveform now at 70%.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_10") --Founder (FOU):  Our assault upon the Hierarchy is drawing near. Ensure our new units take formation at their ready position....(this is the old line) Our counter-attack against the Hierarchy is drawing near. Quickly, build three Ohm Robots with the Assembly.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_construction_build_three_robots then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_17") --Founder (FOU):  Excellent. Now manufacture Ohm Robots from the Assembly.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_construction_upgrade_robotic_assembly then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_11") --Founder (FOU):  On the possibility they could malfunction again, upgrade the Assembly to build Blade Troopers to stand guard.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_intro_groups then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_12") --Founder (FOU):  Now let's verify our grouping algorithms. Select the group of Ohm Robots.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_groups_switch_between then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_13") --Founder (FOU):  Good. Now select the group of Blade Troopers.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_groups_combine then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE06_14") --Novus Science (NSC): Attention: quantum waveform now at 80%. Please assemble reinforcements for portal entry.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_15") --Founder (FOU):  This is an excellent opportunity to test our custom grouping system. We should combine the Ohm Robots and Blade Troopers into one squad.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_groups_done then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE06_16") --Founder (FOU):  Results verified. Reposition the squad to the portal staging area.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_heroes_intro then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE07_01") --Novus Science (NSC): The waveform is approaching a stabilized lock. All final preparations must be completed prior to quantum entanglement.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE07_02") --Founder (FOU):  Issue orders to all field commanders to prepare for wormhole jump! We need Mirabel.
			BlockOnCommand(blocking_dialog) 
			
			
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_heroes_mirabel_snipe then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_mirabel, "TUT360_SCENE07_04") --Mirabel (MIR): Reporting for duty, sir.
			Queue_Talking_Head(pip_founder, "TUT360_SCENE07_05") --Founder (FOU):  Mirabel, our jump to Earth is drawing near. Are your battle plans in order? 
			Queue_Talking_Head(pip_mirabel, "TUT360_SCENE07_06") --Mirabel (MIR): Yes, sir. We'll hit the Hierarchy hard this time. 
			Queue_Talking_Head(pip_founder, "TUT360_SCENE07_07") --Founder (FOU):  We'll need all your combat systems functioning at optimal levels.
			Queue_Talking_Head(pip_mirabel, "TUT360_SCENE07_08") --Mirabel (MIR): My targeting routines could use some alignment.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE07_09") --Founder (FOU):  Then let's put them through their paces. We'll start with your Snipe ability.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_heroes_mirabel_missile_barrage then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE07_10") --Founder (FOU):  Now let's test your Missile Barrage.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_heroes_done then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			Queue_Talking_Head(pip_mirabel, "TUT360_SCENE07_11") --Mirabel (MIR): Systems check. We're good to go!
			Queue_Talking_Head(pip_founder, "TUT360_SCENE07_12") --Founder (FOU):  Then assemble at the portal staging area. We'll be deploying momentarily. 
			local blocking_dialog = Queue_Talking_Head(pip_mirabel, "TUT360_SCENE07_13") --Mirabel (MIR): Yes, sir.
			BlockOnCommand(blocking_dialog)
		end
		
		--mirable moves to her staging flag now...changing factions to take away selection
		if TestValid(mirabel) then
			mirabel.Change_Owner(neutral)
			mirabel.Suspend_Locomotor(false)
			mirabel.Set_Selectable(false)
			
			if TestValid(mirabel_goto_location) then
				mirabel.Move_To(mirabel_goto_location)
			else
				_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! not TestValid(mirabel_goto_location) "))
			end
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_start_researching then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE08_01") --Novus Science (NSC): Sir, before we launch we are integrating all research systems into core memory.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE08_02") --Founder (FOU):  Acknowledged. We should verify our research capacity. 
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	
	elseif conversation == dialog_research_radiation_shielding then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Sleep(timer_objective_complete) -- giving time for "Objective Complete" dialog
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE08_03") --Founder (FOU):  Given the Hierarchy's offensive tactics, we should research Radiation Shielding for good measure. 
			BlockOnCommand(blocking_dialog)		
		end
		
		bool_conversation_over = true
	elseif conversation == dialog_research_done then
		while bool_conversation_over == true do
			Sleep(1)
		end
		
		if bool_new_dialog_is_in == true then
			Queue_Talking_Head(pip_founder, "TUT360_SCENE08_04") --Founder (FOU):  Excellent. Our research routines are operating within normal parameters.
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE08_05") --Novus Science (NSC): Attention: quantum waveform at 100% threshold. Begin jump procedure.
			Queue_Talking_Head(pip_founder, "TUT360_SCENE08_06") --Founder (FOU):  The time has come! Initiate counter-offensive!
			Queue_Talking_Head(pip_novscience, "TUT360_SCENE09_01") --Novus Science (NSC): Earth vector confirmed. Wormhole lock has been established.
			Queue_Talking_Head(pip_founder, "TUT360_SCENE09_02") --Founder (FOU):  Our program has been set. Our purpose is unyielding. The Hierarchy has attacked another innocent world and for this they must be exterminated. We are the last line of defense in a universe at war. 
			Queue_Talking_Head(pip_founder, "TUT360_SCENE09_03") --Founder (FOU):  Conflict protocols are authorized! Initiate jump!
			Queue_Speech_Event("TUT360_SCENE09_04") --Amplifier (AMP): Node 77 deploying! 
			Queue_Speech_Event("TUT360_SCENE09_05") --Anti-Matter Tank (ANT): Node 11 deploying!
			Queue_Speech_Event("TUT360_SCENE09_06") --Dervish (DER): Node 41 deploying!
			Queue_Talking_Head(pip_2911, "TUT360_SCENE09_07") --Blade Trooper 29-11 (BTR): Node 29 deploying!
			Queue_Talking_Head(pip_mirabel, "TUT360_SCENE09_08") --Mirabel (MIR): See you on the other side.
			local blocking_dialog = Queue_Talking_Head(pip_founder, "TUT360_SCENE09_09") --Founder (FOU):  May the odds favor our victory.
			BlockOnCommand(blocking_dialog)
		end
		
		bool_conversation_over = true
	end
end

--Keith callbacks and whatnot
function Tactical_Controller_Zoom(zoom_out)
	if zoom_out then
		bool_camera_zoomed_out=true
		bool_camera_zoomed_in=true
		--_CustomScriptMessage("JoeLog.txt", string.format("EVENT CALLBACK: bool_camera_zoomed_out = true!!"))
	else
		bool_camera_zoomed_out=true
		bool_camera_zoomed_in=true
		--_CustomScriptMessage("JoeLog.txt", string.format("EVENT CALLBACK: bool_camera_zoomed_in = true!!"))
	end
end

function Tactical_Controller_Rotate()
	bool_camera_rotated=true
end

function Tactical_Controller_Camera_Reset()
	bool_camera_reset = true
	if bool_use_control_locks and x360tut_objective01e~= nil then
		_CustomScriptMessage("JoeLog.txt", string.format("Tactical_Controller_Camera_Reset: x360tut_objective01e~= nil"))
	end
end

function Game_Mode_Research_Panel_Open()
	bool_research_panel_open = true
	--_CustomScriptMessage("JoeLog.txt", string.format("EVENT CALLBACK: bool_research_panel_open = true!!"))
end

function Game_Mode_Research_Is_Complete(player,suite_path,suite_index)
	bool_research_completed = true
	--_CustomScriptMessage("JoeLog.txt", string.format("EVENT CALLBACK: bool_research_completed = true!!"))
end

function Tactical_Group_Selected()
--currently not in use...using Thread_Monitor_Selection instead...
--The problem is that this hits before units are acutally selected..
end

function Callback_RoboticAssembly_RallyPoint_Placed(object, rally_point_location)
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_RoboticAssembly_RallyPoint_Placed HIT!!"))
	
	local tracking_distance = 50
	if rally_point_location.Get_Distance( rally_point_flag ) <= tracking_distance then
		_CustomScriptMessage("JoeLog.txt", string.format("rally_point_location.Get_Distance( rally_point_flag ) <= tracking_distance"))
		bool_rally_point_placed = true
		object.Unregister_Signal_Handler(Callback_RoboticAssembly_RallyPoint_Placed)--player has followed orders...stop tracking this, please
	end
end


function Thread_Monitor_Selection(unit)
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Monitor_Selection HIT!!!"))
	local local_unit = unit

	while TestValid(local_unit) do 
		Sleep(1)
		if local_unit.Is_Selected() then
			if local_unit == player_produced_robot01 then bool_player_produced_robot01_selected = true _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_robot01_selected = true!"))
			elseif local_unit == player_produced_robot02 then bool_player_produced_robot02_selected = true _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_robot02_selected = true!"))
			elseif local_unit == player_produced_robot03 then bool_player_produced_robot03_selected = true _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_robot03_selected = true!"))
			elseif local_unit == player_produced_bladetrooper01 then bool_player_produced_bladetrooper01_selected = true _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_bladetrooper01_selected = true!"))
			elseif local_unit == player_produced_bladetrooper02 then bool_player_produced_bladetrooper02_selected = true _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_bladetrooper02_selected = true!"))
			elseif local_unit == player_produced_bladetrooper03 then bool_player_produced_bladetrooper03_selected = true _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_bladetrooper03_selected = true!"))
			end
		else
			if local_unit == player_produced_robot01 then bool_player_produced_robot01_selected = false _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_robot01_selected = false!"))
			elseif local_unit == player_produced_robot02 then bool_player_produced_robot02_selected = false _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_robot02_selected = false!"))
			elseif local_unit == player_produced_robot03 then bool_player_produced_robot03_selected = false _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_robot03_selected = false!"))
			elseif local_unit == player_produced_bladetrooper01 then bool_player_produced_bladetrooper01_selected = false _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_bladetrooper01_selected = false!"))
			elseif local_unit == player_produced_bladetrooper02 then bool_player_produced_bladetrooper02_selected = false _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_bladetrooper02_selected = false!"))
			elseif local_unit == player_produced_bladetrooper03 then bool_player_produced_bladetrooper03_selected = false _CustomScriptMessage("JoeLog.txt", string.format("bool_player_produced_bladetrooper03_selected = false!"))
			end
		end
	end
end

--**************************************************************
--*************************Ambient Stuff************************
--**************************************************************
function Thread_StartUp_OhmBot_Lineups()
	--first, see how many guys you need...this is dictated by the number of end-position flags	list_robot_flags = Find_All_Objects_With_Hint("bladetrooper-start", "MARKER_GENERIC_RED")
	local spawn_flag = {}
	spawn_flag[1] = Find_Hint("MARKER_GENERIC_PURPLE","spawn-robots-0")
	spawn_flag[2] = Find_Hint("MARKER_GENERIC_PURPLE","spawn-robots-1")
	spawn_flag[3] = Find_Hint("MARKER_GENERIC_PURPLE","spawn-robots-2")
	spawn_flag[4] = Find_Hint("MARKER_GENERIC_PURPLE","spawn-robots-3")
	spawn_flag[5] = Find_Hint("MARKER_GENERIC_PURPLE","spawn-robots-4")
	local ohm_counter = 1
		
	list_new_robot_flags = Find_All_Objects_Of_Type("MARKER_GENERIC_YELLOW")
	for i, robot_flag in pairs(list_new_robot_flags) do
		if ohm_counter > 5 then
			ohm_counter = 1
			Sleep(.5)
		end
		
		local new_robot = Spawn_Unit(Find_Object_Type("X360_Tutorial_OhmBot"), spawn_flag[ohm_counter], novus_two) 
		--new_robot.Teleport_And_Face(spawn_flag)
		new_robot.Enable_Behavior(79, false)
		local ohm_hint = robot_flag.Get_Hint()
		if ohm_hint ~= nil then
			new_robot.Set_Hint(ohm_hint)
		end
		
		thread_info = {}
		thread_info[1] = new_robot
		thread_info[2] = robot_flag
		Sleep(0.1)
		Create_Thread("Thread_Setup_OhmBot_Move_Orders", thread_info)
		
		ohm_counter = ohm_counter + 1
					
	end
	--robotic_malfunctioner_leader = Find_Hint("X360_Tutorial_OhmBot","robotic-leader")
	
	--while not TestValid(robotic_malfunctioner_leader) do
	--	Sleep(1)
	--	_CustomScriptMessage("JoeLog.txt", string.format("WARNING! Thread_StartUp_OhmBot_Lineups: while not TestValid(robotic_malfunctioner_leader) do"))
	--	robotic_malfunctioner_leader = Find_Hint("X360_Tutorial_OhmBot","robotic-leader")
	--end
	
end

function Thread_Setup_OhmBot_Move_Orders(thread_info)
	--_CustomScriptMessage("JoeLog.txt", string.format("Thread_Setup_OhmBot_Move_Orders HIT!!"))
	local robot = thread_info[1]
	local goto_flag = thread_info[2]
	
	if not TestValid(robot) or not TestValid(goto_flag) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Setup_OhmBot_Move_Orders not TestValid(robot) or not TestValid(goto_flag) !!"))
	end
	
	if TestValid(robot) and TestValid(goto_flag) then
		--_CustomScriptMessage("JoeLog.txt", string.format("BlockOnCommand(Full_Speed_Move(robot, goto_flag.Get_Position()))"))
		BlockOnCommand(Full_Speed_Move(robot, goto_flag.Get_Position()))
	end
	
	if robot.Get_Hint() == "robotic-leader" then
		bool_bots_at_mark = true
		robotic_malfunctioner_leader = robot
	end
	
	local face_flag = Find_Hint("MARKER_GENERIC_PURPLE","face-robots")
	
	if TestValid(face_flag) then
		robot.Turn_To_Face(face_flag)
		robot.Set_Selectable(false)
		robot.Prevent_All_Fire(true)
		robot.Prevent_Opportunity_Fire(true)
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Setup_BladeTrooper_Move_Orders not TestValid(face_flag)!!"))
	end
	
end

function Thread_StartUp_BladeTrooper_Lineups()
	--first, see how many guys you need...this is dictated by the number of end-position flags
	list_bladetrooper_flags = Find_All_Objects_With_Hint("bladetrooper-start", "MARKER_GENERIC_RED")
	list_bladetrooper_flags02 = Find_All_Objects_With_Hint("bladetrooper-start02", "MARKER_GENERIC_RED")
	
	spawn_flag = Find_Hint("MARKER_GENERIC_PURPLE","spawn-bladetroopers")
		
	for i, bladetrooper_flag in pairs(list_bladetrooper_flags) do
		if TestValid(bladetrooper_flag) then
			bladetrooper = Spawn_Unit(Find_Object_Type("X360_Tutorial_BladeTrooper"), spawn_flag, novus) 	
			
			bladetrooper.Enable_Behavior(79, false)
			
			bladetrooper.Set_Hint(bladetrooper_flag.Get_Hint()) -- these guys get hints set so they can be manipulated later

			thread_info = {}
			thread_info[1] = bladetrooper
			thread_info[2] = bladetrooper_flag

			Create_Thread("Thread_Setup_BladeTrooper_Move_Orders", thread_info)
		end
	end
	
	for i, bladetrooper_flag in pairs(list_bladetrooper_flags02) do
		if TestValid(bladetrooper_flag) then
			bladetrooper = Spawn_Unit(Find_Object_Type("X360_Tutorial_BladeTrooper"), spawn_flag, novus) 	
			
			bladetrooper.Enable_Behavior(79, false)
			
			bladetrooper.Set_Hint(bladetrooper_flag.Get_Hint()) -- these guys get hints set so they can be manipulated later

			thread_info = {}
			thread_info[1] = bladetrooper
			thread_info[2] = bladetrooper_flag

			Create_Thread("Thread_Setup_BladeTrooper_Move_Orders", thread_info)
		end
	end
end

function Thread_Setup_BladeTrooper_Move_Orders(thread_info)
	--_CustomScriptMessage("JoeLog.txt", string.format("Thread_Setup_BladeTrooper_Move_Orders HIT!!"))
	local bladetrooper = thread_info[1]
	local goto_flag = thread_info[2]
	
	if not TestValid(bladetrooper) or not TestValid(goto_flag) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Setup_BladeTrooper_Move_Orders not TestValid(bladetrooper) or not TestValid(goto_flag) !!"))
	end
	
	if TestValid(bladetrooper) and TestValid(goto_flag) then
		--_CustomScriptMessage("JoeLog.txt", string.format("BlockOnCommand(Full_Speed_Move(bladetrooper, goto_flag.Get_Position()))"))
		BlockOnCommand(Full_Speed_Move(bladetrooper, goto_flag.Get_Position()))
	end
	
	if TestValid(founder) then
		bladetrooper.Set_Selectable(false)
		bladetrooper.Prevent_All_Fire(true)
		bladetrooper.Prevent_Opportunity_Fire(true)
		bladetrooper.Change_Owner(neutral)
		bladetrooper.Turn_To_Face(founder)
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Setup_BladeTrooper_Move_Orders not TestValid(trooper_29_11)!!"))
	end
end

--Jeff's camera move script
function Move_Camera_To(location)
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Point_Camera_At(location)
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	End_Cinematic_Camera()
	--Lock_Controls(0)
	Point_Camera_At(location)
	--Sleep(1)
	bool_camera_moving = false
end

function Thread_StartUp_Civilian_Spawners()
	local spawnflag =  nil
	local despawnflag = nil
	while true do
		--Sleep(GameRandom(1, 2))
		Sleep(15)
		spawn_flag_roll = GameRandom(1, 18)
	
		if spawn_flag_roll == 1 then
			spawnflag = civ_spawn01
			despawnflag = civ_despawn01
		elseif spawn_flag_roll == 2 then
			spawnflag = civ_spawn02
			despawnflag = civ_despawn02
		elseif spawn_flag_roll == 3 then
			spawnflag = civ_spawn03
			despawnflag = civ_despawn03
		elseif spawn_flag_roll == 4 then
			spawnflag = civ_spawn04
			despawnflag = civ_despawn04
		elseif spawn_flag_roll == 5 then
			spawnflag = civ_spawn05
			despawnflag = civ_despawn05
		elseif spawn_flag_roll == 6 then
			spawnflag = civ_spawn06
			despawnflag = civ_despawn06
			
		elseif spawn_flag_roll == 7 then
			spawnflag = civ_spawn07
			despawnflag = civ_despawn07
		elseif spawn_flag_roll == 8 then
			spawnflag = civ_spawn08
			despawnflag = civ_despawn08
		elseif spawn_flag_roll == 9 then
			spawnflag = civ_spawn09
			despawnflag = civ_despawn09
		elseif spawn_flag_roll == 10 then
			spawnflag = civ_spawn10
			despawnflag = civ_despawn10
			
		elseif spawn_flag_roll == 11 then
			spawnflag = civ_spawn11
			despawnflag = civ_despawn11
		elseif spawn_flag_roll == 12 then
			spawnflag = civ_spawn12
			despawnflag = civ_despawn12
		elseif spawn_flag_roll == 13 then
			spawnflag = civ_spawn13
			despawnflag = civ_despawn13
		elseif spawn_flag_roll == 14 then
			spawnflag = civ_spawn14
			despawnflag = civ_despawn14
		elseif spawn_flag_roll == 15 then
			spawnflag = civ_spawn15
			despawnflag = civ_despawn15
		elseif spawn_flag_roll == 16 then
			spawnflag = civ_spawn16
			despawnflag = civ_despawn16
		elseif spawn_flag_roll == 17 then
			spawnflag = civ_spawn17
			despawnflag = civ_despawn17
		elseif spawn_flag_roll == 18 then
			spawnflag = civ_spawn18
			despawnflag = civ_despawn18
		end
		
		local thread_info = {}
		thread_info[1]  = spawnflag
		thread_info[2]  = despawnflag
		Create_Thread("Thread_StartUp_Civilian_Spanwer_Move_Orders", thread_info)
		
	end
end

function Thread_StartUp_Civilian_Spanwer_Move_Orders(thread_info)
	local spawn_location = thread_info[1]  
	local goto_location = thread_info[2] 
	local spawn_type = nil
	local new_civ = nil
	
	if not TestValid(spawn_location) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_StartUp_Civilian_Spanwer_Move_Orders received invalid spawn_location!!"))
		return
	end
	
	if not TestValid(goto_location) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_StartUp_Civilian_Spanwer_Move_Orders received invalid goto_location!!"))
		return
	end
	
	spawn_type_roll = GameRandom(1, 2)
	if spawn_type_roll == 1 then
		spawn_type = Find_Object_Type("Novus_Robotic_Infantry")
	else
		spawn_type = Find_Object_Type("Novus_Constructor")
	end
	
	new_civ = Spawn_Unit(spawn_type, spawn_location, neutral) 
	
	if TestValid(new_civ) then
		new_civ.Enable_Behavior(79, false)
		BlockOnCommand(new_civ.Move_To(goto_location.Get_Position()))
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_StartUp_Civilian_Spanwer_Move_Orders not TestValid(new_civ) !!"))
	end
	
	if TestValid(new_civ) then
		new_civ.Despawn()
	end
	
end

-- ##########################################################################################
-- ##################FLYOVER(S) CONTROLLER AND SCRIPTS###########################################
-- ##########################################################################################
function Thread_Cinematic_Flyovers()
	Sleep(15)
	while (true) do
		--now pick a random flyover to play
		local flyover_roll = GameRandom.Free_Random(1, flyover_max)
		
		--this determines if the chosen flyover is already playing its anim, if it is it rolls again
		while cinematic_flyover_in_use[cinematic_flyovers[flyover_roll]] do
			flyover_roll = GameRandom.Free_Random(1, flyover_max)
			Sleep(3)
		end
		
		Create_Thread("Thread_Flyover_Animation", cinematic_flyovers[flyover_roll])
		
		Sleep(GameRandom(1, 15))
	end
end

function Thread_Flyover_Animation(flyover)
	--_CustomScriptMessage("JoeLog.txt", string.format("Thread_Flyover_Animation HIT! Flyover should now be playing."))
	cinematic_flyover_in_use[flyover] = true
	flyover.Hide(false)
	BlockOnCommand(flyover.Play_Animation("Anim_Cinematic", false, 0))
	flyover.Hide(true)
	cinematic_flyover_in_use[flyover] = false
end


function Post_Load_Callback()
	if fow_novus_reveal ~= nil then
		fow_novus_reveal = FogOfWar.Reveal_All(novus)
	end

	if x360tut_objective08 == nil then
		UI_Hide_Research_Button(true)
	end

	if bool_use_control_locks then
		if x360tut_objective03a ~= nil then
			Controller_Set_Tactical_Component_Lock("X_BUTTON",true)
		end
		
		if x360tut_objective03c ~= nil then
			if trooper_29_11.Is_Selected() == false then
				novus.Select_Object(trooper_29_11)
			end

			Controller_Set_Tactical_Component_Lock("ALL",true)
			Controller_Set_Tactical_Scroll_Lock(true)

			-- Maria 12.04.2007: we are back to the old scheme so now the right trigger brings up the minimap.
			Controller_Set_Tactical_Component_Lock("RIGHT_TRIGGER",false) -- so player can open the mini-map (old controller scheme)
			--Controller_Set_Tactical_Component_Lock("RIGHT_SHOULDER_BUTTON",false) -- so player can open the mini-map
			Controller_Set_Tactical_Component_Lock("RIGHT_STICK",false) -- so player can direct his cursor on the mini-map
			Controller_Set_Tactical_Component_Lock("A_BUTTON",false) -- need A button for movement order
		else
			_CustomScriptMessage("NaderLog.txt", string.format("x360tut_objective03c is nil!!"))
		end

		if x360tut_objective01f ~= nil then
			Lock_Controls(0)
			--Point_Camera_At(trooper_29_11)

			Controller_Set_Tactical_Component_Lock("ALL",true)
			Controller_Set_Tactical_Scroll_Lock(true)

			-- Maria 12.04.2007: we are back to the old scheme so now the right trigger brings up the minimap.
			Controller_Set_Tactical_Component_Lock("RIGHT_TRIGGER",false) -- so player can open the mini-map (old controller scheme)
			Controller_Set_Tactical_Component_Lock("LEFT_STICK",false) -- so player can scroll with radar map
			--Controller_Set_Tactical_Component_Lock("A_BUTTON",false) -- need A button for movement order
		end

		if x360tut_group_objective00 ~= nil then
			Controller_Set_Tactical_Component_Lock("X_BUTTON",true)
			Controller_Set_Tactical_Component_Lock("A_BUTTON_DOUBLE_PRESS",true) --need to be able to lock out double tap A-BUTTON select all of type.
		end
	else
		Lock_Controls(0)
	end

	UI_Hide_Sell_Button()
	UI_Hide_Command_Bar(true)
	UI_Set_Display_Credits_Pop(false)
	Set_Hint_System_Visible(false)

	UI_Show_Radar_Map(bool_show_radar_map)

	UI_Show_BattleCam_Button(false)
end









































function Kill_Unused_Global_Functions()
	-- Automated kill list.
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
	Tactical_Group_Selected = nil
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
	Update_Offline_Achievement = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end

