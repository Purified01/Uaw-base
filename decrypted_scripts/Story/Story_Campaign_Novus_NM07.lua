if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[21] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[92] = true
LuaGlobalCommandLinks[83] = true
LuaGlobalCommandLinks[56] = true
LuaGlobalCommandLinks[29] = true
LuaGlobalCommandLinks[64] = true
LuaGlobalCommandLinks[48] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[86] = true
LuaGlobalCommandLinks[55] = true
LuaGlobalCommandLinks[206] = true
LuaGlobalCommandLinks[58] = true
LuaGlobalCommandLinks[15] = true
LuaGlobalCommandLinks[69] = true
LuaGlobalCommandLinks[38] = true
LuaGlobalCommandLinks[51] = true
LuaGlobalCommandLinks[44] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[150] = true
LuaGlobalCommandLinks[90] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[43] = true
LuaGlobalCommandLinks[93] = true
LuaGlobalCommandLinks[165] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[175] = true
LuaGlobalCommandLinks[61] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[132] = true
LuaGlobalCommandLinks[63] = true
LuaGlobalCommandLinks[28] = true
LUA_PREP = true

 -- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Novus_NM07.lua#34 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Novus_NM07.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #34 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGMoveUnits")
require("PGUICommands")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
require("PGSpawnUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")
require("RetryMission")
require("PGBaseDefinitions")

require("SuperweaponsControl")

require("PGStoryMode") 

















---------------------------------------------------------------------------------------------------

function Definitions()
	-- only service once a second
	ServiceRate = 1
	
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	alientwo = Find_Player("Alien_ZM06_KamalRex")
	masari = Find_Player("Masari")
	
	ass_walker_list = {}
	hab_walker_list = {}
	sci_walker_list = {}
	
	--jdg breaking jeff's mission
	assmbly_walker_a = nil
	assmbly_walker_b = nil
	bool_assmbly_walker_a_attacked = false
	bool_assmbly_walker_b_attacked = false
	habitat_walker_a = nil
	habitat_walker_b = nil
	bool_habitat_walker_a_attacked = false
	bool_habitat_walker_b_attacked = false
	bool_assembly_walker_at_mark = false
	bool_habitat_walker_at_mark = false
	
	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, 2)
--	novus.Enable_Colorization(true, 6)
--	uea.Enable_Colorization(true, 5)
		
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "mi_marine_pip_head.alo"

	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		-- ***** ACHIEVEMENT_AWARD *****
		PGAchievementAward_Init()
		-- ***** ACHIEVEMENT_AWARD *****

   	novus.Set_Research_Points_Override(6)

		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		-- ***** HINT SYSTEM *****
		
			-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", novus)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", novus)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", novus)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", novus)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", novus)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", novus)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", novus)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", novus)
		local radar_filter_id9 = RadarMap.Add_Filter("Radar_Map_Is_Grayscale", novus, false, "Bitwise_And")
	

		
		--hero_start_pos = Find_Hint("MARKER_INVADER_CREATION_POSITION","nm07")
		--hero = Create_Generic_Object(Find_Object_Type("Novus_Hero_Mech"), hero_start_pos, novus) 
		
		uea.Allow_AI_Unit_Behavior(false)
		aliens.Allow_AI_Unit_Behavior(false)
		masari.Allow_AI_Unit_Behavior(false)
		alientwo.Allow_AI_Unit_Behavior(false)
	
		--Stop_All_Speech()
		--Flush_PIP_Queue()
		--Allow_Speech_Events(true)
		
		UI_On_Mission_Start()  -- this resets the state of several UI systems, namely: Unsuspend_Objectives, Stop_All_Speech, Flush_PIP_Queue, Allow_Speech_Events(true), Unsuspend_Hint_System

		Fade_Screen_Out(0)
		
		--stuff for if player is using a controller...turn off various UI stuff
		Set_Level_Name("TEXT_GAMEPAD_NM07_NAME")
		--if Is_Gamepad_Active() then
		--	UI_Show_Controller_Context_Display(false)
		--end
		
		Create_Thread("Thread_Mission_Start")
	
	elseif message == OnUpdate then
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Mission_Start()
	-- display intro cinematic
	Fade_Out_Music()
    BlockOnCommand(Play_Bink_Movie("Novus_M7_S1",true))
    
	Set_Active_Context("NM07_StoryCampaign")
	
	ass_walker_list=Find_All_Objects_Of_Type("NM07_CUSTOM_ASSEMBLY_WALKER")
	for i, unit in pairs(ass_walker_list) do
		if TestValid(unit) then
			unit.Set_Object_Context_ID("NM07_EndCinematic")
			--unit.Set_Service_Only_When_Rendered(true)
		end
	end
	hab_walker_list=Find_All_Objects_Of_Type("NM07_CUSTOM_HABITAT_WALKER")
	for i, unit in pairs(hab_walker_list) do
		if TestValid(unit) then
			unit.Set_Object_Context_ID("NM07_EndCinematic")
			--unit.Set_Service_Only_When_Rendered(true)
		end
	end
	sci_walker_list=Find_All_Objects_Of_Type("NM07_CUSTOM_SCIENCE_WALKER")
	for i, unit in pairs(sci_walker_list) do
		if TestValid(unit) then
			unit.Set_Object_Context_ID("NM07_EndCinematic")
			--unit.Set_Service_Only_When_Rendered(true)
		end
	end
		
	Import_Base_From_Global()
	novus.Reset_Story_Locks()
	Lock_Objects(true)
	-- UI_Hide_Research_Button()
	--UI_Hide_Sell_Button()

	failure_text="TEXT_SP_MISSION_MISSION_FAILED"
	
	hero = Find_Hint("Novus_Hero_Mech","mirabel7")
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
	if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
	hero.Suspend_Locomotor(true)
	vertigo = Find_Hint("NOVUS_HERO_VERTIGO","vertigo")
	-- heroes nerfed late, so adding damage modifier, Vertigo old health(1000) / Vertigo new health(700) - 1 = -.3
	if TestValid(vertigo) then vertigo.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.3) end
	founder = Find_First_Object("Novus_Hero_Founder")
	-- heroes nerfed late, so adding damage modifier, Founder old health(1400) / Founder new health(600/900) - 1 = -.58
	if TestValid(founder) then founder.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.58) end
	moore = Find_First_Object("Military_Hero_General_Randal_Moore")
	moore.Set_Cannot_Be_Killed(true)
	Hunt(moore, "PrioritiesLikeOneWouldExpectThemToBe", false, true, moore, 200)
	
	portal = Find_Hint("NM04_NOVUS_PORTAL", "portal")
	--novusbase7=Find_Hint("MARKER_GENERIC", "novusbase7")
	
	--define defeat condifition: hero dies
	Register_Death_Event(hero, Death_Hero_Mech)
	Register_Death_Event(vertigo, Death_Hero_Vertigo)
	Register_Death_Event(founder, Death_Hero_Founder)
	
	--jdg 1/25/08 moore set to cannot be killed...eliminating the death callback.
	--Register_Death_Event(moore, Death_Hero_Moore)
	
	Register_Death_Event(portal, Death_Hero_Portal)
	
	novusbaseattack=Find_All_Objects_With_Hint("novusbase7")
	
	dialogue_radiation=false
	dialogue_assembly_a=false
	dialogue_troop_a=false
	dialogue_science_a=false
	dialogue_science_b=false
	
	bldg1=Find_Hint("_WAREHOUSE_06","building1")
	bldg1.Take_Damage(9999)
	bldg2=Find_Hint("_WAREHOUSE_04","building2")
	bldg2.Take_Damage(9999)
	
	novus_base=Find_Hint("MARKER_GENERIC","novusbase")
	
	at_spawns=Find_All_Objects_With_Hint("zrh-form-spawn")
	at_formup_a=Find_All_Objects_With_Hint("zrh-form-6")
	at_formup_b=Find_All_Objects_With_Hint("zrh-form-5")
	at_formup_c=Find_All_Objects_With_Hint("zrh-form-4")
	at_formup_d=Find_All_Objects_With_Hint("zrh-form-3")
	at_formup_e=Find_All_Objects_With_Hint("zrh-form-2")
	at_formup_f=Find_All_Objects_With_Hint("zrh-form-1")
	at_formup_time=75
	
	walkers_dead=false
	
	obj_a_walkers=2
	obj_b_walkers=2
	obj_c_walkers=3
	walkera_dead=0
	walkera_alldead=false
	walkerb_dead=0
	walkerb_alldead=false
	walkerc_dead=0
	walkerc_alldead=false
	
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	aliens.Allow_Autonomous_AI_Goal_Activation(true)
	
	civilian.Make_Ally(novus)
	civilian.Make_Ally(uea)
	uea.Make_Ally(civilian)
	uea.Make_Ally(novus)
	novus.Make_Ally(civilian)
	novus.Make_Ally(uea)
	
	novus.Give_Money(40000)
	
	
	
	
	
	--set low civ population on large maps (esp single player)
	--jdg 1/10/08 slash and burn balance for the 360...goodbye civies 
	--Spawn_Civilians_Automatically(true)
	--Set_Desired_Civilian_Population(100)
	--Make_Civilians_Panic(mapcenter, 10000)

	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Music_Doom_Of_The_Aliens") -- needs to be big darth vader troops on the move kind of music
	
	Point_Camera_At(hero)
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(2) 
	Transition_To_Tactical_Camera(7)
	Sleep(1)
	Create_Thread("Dialogue_Start_Mission")
	Sleep(6)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	hero.Suspend_Locomotor(false)

	inverters_team=Find_All_Objects_With_Hint("unfold")
	for units, unit in pairs(inverters_team) do
		if TestValid(unit) then
			unit.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
		end
	end
	
	-- show mission objective a and wait for it to be triggered
	Create_Thread("Setup_Military_Defenders")
	Create_Thread("Setup_Hierarchy_Guards")
		
		--jdg was 30
	invasion_time=60
	
	
	
	

	
if true then
	--jdg 1/10/08 slash and burn balancing for the 360---removing grunt encounter
	--Create_Thread("Alien_Troops_Cycler")
	
	nov07_objective = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE")
	
	while invasion_time>0 do
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(invasion_time), 1)
		Set_Objective_Text(nov07_objective, out_string)
		--MessageBox(tostring(invasion_time))
		Sleep(1)
		invasion_time=invasion_time-1
	end
	Delete_Objective(nov07_objective)
end
if true then
	walkers_left=2
	Create_Thread("Setup_Walker_A")
	Sleep(1)
	Create_Thread("Show_Objective_A")
	Create_Thread("Dialogue_Assembly_Walkers")
	
	while not(objective_a_completed) do
		if not mission_success and not mission_failure then
			if not walkera_alldead then
				if walkers_left<=0 then walkera_alldead=true end
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_A")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_a_walkers-walkers_left), 1)
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_a_walkers), 2)
				Set_Objective_Text(nov07_objective_a, out_string)
				Sleep(1)
			else
				Objective_Complete(nov07_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_A_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				Remove_Radar_Blip("blip_objective_a")
				objective_a_completed=true;
			end
		end
		Sleep(1)
	end

	--jdg let the player get a little breather
	Sleep(30)
	walkers_left=2
	Create_Thread("Setup_Walker_B")
	Sleep(1)
	Create_Thread("Show_Objective_B")
	Create_Thread("Dialogue_Troop_Walkers")
	
	while not(objective_b_completed) do
		if not mission_success and not mission_failure then
			if not walkerb_alldead then
				if walkers_left<=0 then walkerb_alldead=true end
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_b_walkers-walkers_left), 1)
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_b_walkers), 2)
				Set_Objective_Text(nov07_objective_b, out_string)
				Sleep(1)
			else
				Objective_Complete(nov07_objective_b)
				Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_B_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				Remove_Radar_Blip("blip_objective_b")
				objective_b_completed=true;
			end
		end
		Sleep(1)
	end

end

	Create_Thread("Hierarchy_Guards_Attack")
	
	--jdg let the player get a little breather
	Sleep(30)
	walkers_left=3
	Create_Thread("Setup_Walker_C")
	Sleep(1)
	Create_Thread("Show_Objective_C")
	Create_Thread("Dialogue_Science_Walkers")
	
	while not(objective_c_completed) do
		if not mission_success and not mission_failure then
			if not walkerc_alldead then
				if walkers_left<=0 then walkerc_alldead=true end
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_C")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_c_walkers-walkers_left), 1)
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_c_walkers), 2)
				Set_Objective_Text(nov07_objective_c, out_string)
				Sleep(1)
			else
				Objective_Complete(nov07_objective_c)
				Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_C_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				Remove_Radar_Blip("blip_objective_c")
				objective_c_completed=true;
			end
		end
		Sleep(1)
	end
		 
	hero.Set_Cannot_Be_Killed(true)
	vertigo.Set_Cannot_Be_Killed(true)
	founder.Set_Cannot_Be_Killed(true)
	moore.Set_Cannot_Be_Killed(true)
	portal.Set_Cannot_Be_Killed(true)
	Create_Thread("Thread_Mission_Complete");
	
end

function Hierarchy_Guards_Attack()
	guards=Find_All_Objects_With_Hint("guards")
	for i, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
			Sleep(1)
		end
	end
end

function Setup_Hierarchy_Guards()
	guards=Find_All_Objects_With_Hint("guards")
	for i, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	while invasion_time>0 do 
		Sleep(2)
	end
	for i, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(false)
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
end

function Alien_Troops_Cycler()
	Create_Thread("Alien_Troops_6")
	Create_Thread("Alien_Troops_5")
	Create_Thread("Alien_Troops_4")
	while not objective_b_completed do
		spawned_table=nil
		spawned_table={}
		for j=1, 3 do
			for i, unit in pairs(at_spawns) do
				if TestValid(unit) then
					spawned=Create_Generic_Object("ALIEN_GRUNT",unit,aliens)
					spawned.Prevent_AI_Usage(true)
					spawned.Prevent_All_Fire(true)
					table.insert(spawned_table, spawned)
					Sleep(.1)
				end
			end
		end
		Create_Thread("Alien_Troops_Movement",spawned_table)
		Sleep(at_formup_time+2)
	end
end

function Alien_Troops_Movement(forces)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_a[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_b[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_c[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Alien_Troops_6()
	forces6=Find_All_Objects_With_Hint("start6")
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_b[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_c[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces6, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Alien_Troops_5()
	forces5=Find_All_Objects_With_Hint("start5")
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_c[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces5, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Alien_Troops_4()
	forces4=Find_All_Objects_With_Hint("start4")
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces4, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Setup_Walker_A()
	markers=Find_All_Objects_With_Hint("objectivea")
	for i, mark in pairs(markers) do
		if TestValid(mark) then
			--walker=Create_Generic_Object("NM07_CUSTOM_ASSEMBLY_WALKER",mark,aliens)
			walker=ass_walker_list[i]
			walker.Set_Object_Context_ID("NM07_StoryCampaign")
			walker.Teleport(mark)
			walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_A") 
			Create_Thread("Thread_Assembly_Walker_Attack",{walker,novusbaseattack[i]})
			
			
			
			walker.Add_Reveal_For_Player(novus)
			walker.Override_Max_Speed(.10)
			Add_Radar_Blip(walker, "DEFAULT", "blip_objective_a")
			
			
			
			--jdg prox event here?
			local proxflag = novusbaseattack[i]
			Register_Prox(proxflag, Prox_AssemblyWalker_AtMark, 500, aliens)
			
			
		end
	end
	
	assembly_walker_a = ass_walker_list[1]
	assembly_walker_b = ass_walker_list[2]
	assembly_walker_a.Register_Signal_Handler(Callback_AssemblyWalker_A_Attacked, "OBJECT_DAMAGED")
	assembly_walker_b.Register_Signal_Handler(Callback_AssemblyWalker_B_Attacked, "OBJECT_DAMAGED")
	
	--jdg 1/10/08 delaying unit production until walker is actually attacked ... trying to increase performance.
	while not bool_assmbly_walker_a_attacked and not bool_assmbly_walker_b_attacked and not bool_assembly_walker_at_mark do
		Sleep(5)
	end
	
	Create_Thread("Thread_Assembly_Walker_Produced_Hunt")
	
end

function Prox_AssemblyWalker_AtMark(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == aliens then
		prox_obj.Cancel_Event_Object_In_Range(Prox_AssemblyWalker_AtMark)
		bool_assembly_walker_at_mark = true
	end
end


function Callback_AssemblyWalker_A_Attacked()
	assembly_walker_a.Unregister_Signal_Handler(Callback_AssemblyWalker_A_Attacked)
	bool_assmbly_walker_a_attacked = true
	markers=Find_All_Objects_With_Hint("objectivea")
	Create_Thread("Thread_Assembly_Walker_Produce",{assembly_walker_a,table.getn(markers)})
end

function Callback_AssemblyWalker_B_Attacked()
	assembly_walker_b.Unregister_Signal_Handler(Callback_AssemblyWalker_B_Attacked)
	bool_assmbly_walker_b_attacked = true
	markers=Find_All_Objects_With_Hint("objectivea")
	Create_Thread("Thread_Assembly_Walker_Produce",{assembly_walker_b,table.getn(markers)})
end

function Death_Walker_A()
	walkers_left=walkers_left-1
	if not dialogue_assembly_a then Create_Thread("Dialogue_Assembly_A") end
end

function Thread_Assembly_Walker_Attack(params)
	local walker_obj=params[1]
	local point=params[2]
	if TestValid(point) then walker_obj.Guard_Target(point) end
	while TestValid(walker_obj) do
		prox_obj=Find_Nearest(walker_obj, novus, true)
		if TestValid(prox_obj) then
			if walker_obj.Get_Distance(prox_obj)<=300 then
				hp_list = walker_obj.Find_All_Hard_Points_Of_Type("Alien_Walker_Assembly_HP_Scarn_Beam")
				if not hp_list==nil then
					for i, hp in pairs(hp_list) do
						hp.Activate_Ability("Assembly_Scarn_Beam", true, prox_obj)
					end
				end
			end
		end
		Sleep(3)
	end
end

function Thread_Assembly_Walker_Produced_Hunt()
	while not walkera_alldead do
		defilers=Find_All_Objects_Of_Type("ALIEN_DEFILER")
		--for i, unit in pairs(defilers) do
		--	Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
			--unit.Guard_Target(novusbase7)
		--end
		
		Hunt(defilers, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
		Sleep(30)
	end
end

function Thread_Assembly_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_DEFILER")
	
	local prod_num=1
	local built={}
	local inqueue={}
	local queued=0
	local build=0
	local pod_type = Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod")
	while TestValid(walker_obj) do
		
		local max_allowed_units = 3
		local list_current_units =  Find_All_Objects_Of_Type("ALIEN_DEFILER")
		local counter_current_units = table.getn(list_current_units)
		
		--jdg 1/10/08 limiting number of units for performance reasons
		while counter_current_units >= max_allowed_units do 
			Sleep(2)
			list_current_units =  Find_All_Objects_Of_Type("ALIEN_DEFILER")
			counter_current_units = table.getn(list_current_units)
		end
		
		queued=0
		built=Find_All_Objects_Of_Type(prod_unit)
		inqueue=walker_obj.Tactical_Enabler_Get_Queued_Objects()
		if inqueue then
			for i, unit in pairs(inqueue) do
				if TestValid(unit) then
					if unit.Get_Type()==prod_unit then
						queued=queued+1
					end
				end
			end
		end
		if table.getn(built)>0 then 
			build=table.getn(built)/2
		else
			build=0
		end
		if (queued+build)<prod_num then
			got_pod=false
			hardpoints=walker_obj.Get_All_Hard_Points()
			for i,hp in pairs(hardpoints) do
				if TestValid(hp) and hp.Get_Type()== pod_type then
					got_pod=true
				end
			end
			if got_pod then
				Tactical_Enabler_Begin_Production(walker_obj, prod_unit, 1, aliens)
			end
			Sleep(5)	
		else 
			Sleep(60)
		end
	end
end

function Setup_Walker_B()
	markers=Find_All_Objects_With_Hint("objectiveb")
	for i, mark in pairs(markers) do
		if TestValid(mark) then
			--walker=Create_Generic_Object("NM07_CUSTOM_HABITAT_WALKER",mark,aliens)
			walker=hab_walker_list[i]
			walker.Set_Object_Context_ID("NM07_StoryCampaign")
			walker.Teleport(mark)
			walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_B") 
			Create_Thread("Thread_Habitat_Walker_Attack",{walker,novusbaseattack[i]})
			walker.Add_Reveal_For_Player(novus)
			walker.Override_Max_Speed(.20)
			Add_Radar_Blip(walker, "DEFAULT", "blip_objective_b")
			
			
			--jdg prox event here?
			local proxflag = novusbaseattack[i]
			Register_Prox(proxflag, Prox_HabitatWalker_AtMark, 500, aliens)
		end
	end
	
	habitat_walker_a = hab_walker_list[1]
	habitat_walker_b = hab_walker_list[2]
	habitat_walker_a.Register_Signal_Handler(Callback_HabitatWalker_A_Attacked, "OBJECT_DAMAGED")
	habitat_walker_b.Register_Signal_Handler(Callback_HabitatWalker_B_Attacked, "OBJECT_DAMAGED")
	
	--jdg 1/10/08 delaying unit production until walker is actually attacked ... trying to increase performance.
	while not bool_habitat_walker_a_attacked and not bool_habitat_walker_b_attacked and not bool_habitat_walker_at_mark do
		Sleep(5)
	end
	
	Create_Thread("Thread_Habitat_Walker_Produced_Hunt")
end

function Prox_HabitatWalker_AtMark(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == aliens then
		prox_obj.Cancel_Event_Object_In_Range(Prox_HabitatWalker_AtMark)
		bool_habitat_walker_at_mark = true
	end
end


function Callback_HabitatWalker_A_Attacked()
	habitat_walker_a.Unregister_Signal_Handler(Callback_HabitatWalker_A_Attacked)
	bool_habitat_walker_a_attacked = true
	markers=Find_All_Objects_With_Hint("objectiveb")
	Create_Thread("Thread_Habitat_Walker_Produce",{habitat_walker_a,table.getn(markers)})
end

function Callback_HabitatWalker_B_Attacked()
	habitat_walker_b.Unregister_Signal_Handler(Callback_HabitatWalker_B_Attacked)
	bool_habitat_walker_b_attacked = true
	markers=Find_All_Objects_With_Hint("objectiveb")
	Create_Thread("Thread_Habitat_Walker_Produce",{habitat_walker_b,table.getn(markers)})
end



function Thread_Habitat_Walker_Produced_Hunt()
	while not walkera_alldead do
		brutes=Find_All_Objects_Of_Type("ALIEN_GRUNT")
		--for i, unit in pairs(brutes) do
			
			--unit.Guard_Target(novusbase7)
		--end
		
		Hunt(brutes, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
		Sleep(30)
	end
end


--jdg these walkeres do not have brute hardpoints...chanign to produce grunts
function Thread_Habitat_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_GRUNT")
	
	--jdg 1/10/08 slash and burn balancing...reducing from 9 to 1
	local prod_num=1
	local built={}
	local inqueue={}
	local queued=0
	local build=0
	while TestValid(walker_obj) do
		local max_allowed_units = 12
		local list_current_units =  Find_All_Objects_Of_Type("ALIEN_GRUNT")
		local counter_current_units = table.getn(list_current_units)
		
		--jdg 1/10/08 limiting number of units for performance reasons
		while counter_current_units >= max_allowed_units do 
			Sleep(2)
			list_current_units =  Find_All_Objects_Of_Type("ALIEN_GRUNT")
			counter_current_units = table.getn(list_current_units)
		end
		
		queued=0
		built=Find_All_Objects_Of_Type(prod_unit)
		inqueue=walker_obj.Tactical_Enabler_Get_Queued_Objects()
		if inqueue then
			for i, unit in pairs(inqueue) do
				if TestValid(unit) then
					if unit.Get_Type()==prod_unit then
						queued=queued+1
					end
				end
			end
		end
		if table.getn(built)>0 then 
			build=table.getn(built)/2
		else
			build=0
		end
		if (queued+build)<prod_num then
			Tactical_Enabler_Begin_Production(walker_obj, prod_unit, 1, aliens)
			Sleep(5)
		else
			Sleep(60)
		end
	end
end

function Death_Walker_B()
	walkers_left=walkers_left-1
	if walkers_left==1 then
		if not dialogue_troop_a then Create_Thread("Dialogue_Troop_A") end
	end
end

function Thread_Habitat_Walker_Attack(params)
	local walker_obj=params[1]
	local point=params[2]
	if TestValid(point) then walker_obj.Guard_Target(point) end
	while TestValid(walker_obj) do
		prox_obj=Find_Nearest(walker_obj, novus, true)
		if TestValid(prox_obj) then
			if walker_obj.Get_Distance(prox_obj)<=250 then
				hp_list = walker_obj.Find_All_Hard_Points_Of_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner")
				if not hp_list==nil then
					ability_used=false
					for i, hp in pairs(hp_list) do
						if not ability_used then
							if hp.Is_Ability_Ready("Radiation_Artillery_Cannon_Attack_Ability") then
								hp.Activate_Ability("Radiation_Artillery_Cannon_Attack_Ability", true, prox_obj)
								ability_used=true
								if not dialogue_radiation then Create_Thread("Dialogue_Troop_Walkers_Damage") end
							end
						end
					end
				end
			end
		end
		Sleep(3)
	end
end

function Setup_Walker_C()
	markers=Find_All_Objects_With_Hint("objectivec")
	for i, mark in pairs(markers) do
		if TestValid(mark) then
			--walker=Create_Generic_Object("NM07_CUSTOM_SCIENCE_WALKER",mark,aliens)
			walker=sci_walker_list[i]
			walker.Set_Object_Context_ID("NM07_StoryCampaign")
			walker.Teleport(mark)
			walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_C") 
			Create_Thread("Thread_Science_Walker_Attack",{walker,novusbaseattack[i]})
			walker.Add_Reveal_For_Player(novus)
			walker.Override_Max_Speed(.05)
			Add_Radar_Blip(walker, "DEFAULT", "blip_objective_c")
		end
	end
end

function Death_Walker_C()
	walkers_left=walkers_left-1
	if walkers_left==3 then
		if not dialogue_science_a then Create_Thread("Dialogue_Science_A") end
	end
	if walkers_left==1 then
		if not dialogue_science_b then Create_Thread("Dialogue_Science_B") end
	end
end

function Thread_Science_Walker_Attack(params)
	local walker_obj=params[1]
	local point=params[2]
	if TestValid(point) then walker_obj.Guard_Target(point) end
	local cooldown=0
	while TestValid(walker_obj) do
		prox_obj=Find_Nearest(walker_obj, novus, true)
		if TestValid(prox_obj) then
			if walker_obj.Get_Distance(prox_obj)<=300 then
				cooldown=cooldown-1
				if cooldown<1 then
					walker_obj.Activate_Ability("Alien_Radiation_Cascade_Unit_Ability", true, prox_obj.Get_Position(), true)
					Sleep(12)
					if TestValid(walker_obj) and TestValid(point) then
						walker_obj.Guard_Target(point)
					end
					cooldown=20
				end
			end
		end
		Sleep(3)
	end
end

function Setup_Military_Defenders()
	mil_units=Find_All_Objects_Of_Type("Military_AbramsM2_Tank")
	for i, mil_unit in pairs(mil_units) do
		if TestValid(mil_unit) then
			Hunt(mil_unit, false, true, mil_unit, 200)
		end
	end
	mil_units=Find_All_Objects_Of_Type("Military_Hummer")
	for i, mil_unit in pairs(mil_units) do
		if TestValid(mil_unit) then
			Hunt(mil_unit, false, true, mil_unit, 200)
		end
	end
	mil_units=Find_All_Objects_Of_Type("Military_Apache")
	for i, mil_unit in pairs(mil_units) do
		if TestValid(mil_unit) then
			Hunt(mil_unit, true, false, novus_base, 600)
		end
	end
end

function Show_Objective_A()
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	nov07_objective_a = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE_A")
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_A")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(0), 1)
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(2), 2)
		Set_Objective_Text(nov07_objective_a, out_string)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- adds mission objective for objective B
function Show_Objective_B()
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_B_ADD"} )
	Sleep(time_objective_sleep)
	nov07_objective_b = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE_B")
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_B")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(0), 1)
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(2), 2)
		Set_Objective_Text(nov07_objective_b, out_string)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- adds mission objective for objective C
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_C_ADD"} )
	Sleep(time_objective_sleep)
	nov07_objective_c = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE_C")
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_C")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(0), 1)
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(3), 2)
		Set_Objective_Text(nov07_objective_c, out_string)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

--on hero death, force defeat
function Death_Hero_Mech()
	if mission_failure == false then
		mission_failure = true
		Create_Thread("Thread_Death_Hero_Mech")
	end
end

function Thread_Death_Hero_Mech()
	UI_Pre_Mission_End() -- this does Suspend_Objectives, Stop_All_Speech, Flush_PIP_Queue, Suspend_Hint_System
	-- Whenever we go into BlockOnCommand we run the risk of having other threads add speech events, so we have to make
	-- sure to queue the pip head first and ONLY then dis-allow other speech events (this will queue the event we want but
	-- will prevent any future speech events from being queued).
	local block = Queue_Talking_Head(pip_novcomm, "ALL06_SCENE02_03")
	Allow_Speech_Events(false)
	BlockOnCommand(block)
			
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"

	Create_Thread("Thread_Mission_Failed")

end

--on hero death, force defeat
--function Death_Hero_Moore()
--	Create_Thread("Thread_Death_Hero_Moore")
--end

--function Thread_Death_Hero_Moore()
--	if TestValid(hero) then
--		UI_Pre_Mission_End() -- this does Suspend_Objectives, Stop_All_Speech, Flush_PIP_Queue, Suspend_Hint_System
		-- Whenever we go into BlockOnCommand we run the risk of having other threads add speech events, so we have to make
		-- sure to queue the pip head first and ONLY then dis-allow other speech events (this will queue the event we want but
		-- will prevent any future speech events from being queued).
--		local block = Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_18")
--		Allow_Speech_Events(false)
--		BlockOnCommand(block)
--	end
--	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE"
--	Create_Thread("Thread_Mission_Failed")
--end

--on hero death, force defeat
function Death_Hero_Vertigo()
	if not mission_failure == true then
		mission_failure = true
		Create_Thread("Thread_Death_Hero_Vertigo")
	end
end

function Thread_Death_Hero_Vertigo()

	UI_Pre_Mission_End() -- this does Suspend_Objectives, Stop_All_Speech, Flush_PIP_Queue, Suspend_Hint_System
	-- Whenever we go into BlockOnCommand we run the risk of having other threads add speech events, so we have to make
	-- sure to queue the pip head first and ONLY then dis-allow other speech events (this will queue the event we want but
	-- will prevent any future speech events from being queued).
	local block = Queue_Talking_Head(pip_novcomm, "ALL06_SCENE02_05")
	Allow_Speech_Events(false)
	BlockOnCommand(block)
		
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_VERTIGO"
	Create_Thread("Thread_Mission_Failed")

end

--on hero death, force defeat
function Death_Hero_Founder()
	if not mission_failure == true then
		mission_failure = true
		Create_Thread("Thread_Death_Hero_Founder")
	end
end

function Thread_Death_Hero_Founder()
	UI_Pre_Mission_End() -- this does Suspend_Objectives, Stop_All_Speech, Flush_PIP_Queue, Suspend_Hint_System
	-- Whenever we go into BlockOnCommand we run the risk of having other threads add speech events, so we have to make
	-- sure to queue the pip head first and ONLY then dis-allow other speech events (this will queue the event we want but
	-- will prevent any future speech events from being queued).
	local block = Queue_Talking_Head(pip_novcomm, "ALL06_SCENE02_04")
	Allow_Speech_Events(false)
	BlockOnCommand(block)
	
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_FOUNDER"
	Create_Thread("Thread_Mission_Failed")
end

--on hero death, force defeat
function Death_Hero_Portal()
	failure_text="TEXT_SP_MISSION_NVS07_OBJECTIVE_FAIL"
	if mission_failure == false then
		mission_failure = true
		Create_Thread("Thread_Mission_Failed")
	end
end


function Thread_Mission_Failed()
		--Reset_Objectives() -- Oksana: reset objectives so we don't accidentally grant objective AFTER we lost!
		--Stop_All_Speech()
		--Flush_PIP_Queue()
		--Allow_Speech_Events(false)
	UI_On_Mission_End()
			
	mission_failure = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Lose_To_Alien_Event") -- this music is faction specific, use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	-- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
	-- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Announcement_Text", nil, {failure_text} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(aliens)
end

function Thread_Mission_Complete()
	--Stop_All_Speech()
	--Flush_PIP_Queue()
	--Allow_Speech_Events(false)
		
	UI_On_Mission_End()
			
	mission_success = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Novus_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	
	Fade_Screen_Out(0)
	--play outro cinematic - final cinematic for novus campaign
	Set_Active_Context("NM07_EndCinematic")
	Fade_Out_Music()
    BlockOnCommand(Play_Bink_Movie("Novus_M7_S3",true))
	
	Force_Victory(novus)
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script
function Force_Victory(player)
		if player == novus then
		
			novus.Reset_Story_Locks()
			-- ***** ACHIEVEMENT_AWARD *****
			--if (Player_Earned_Offline_Achievements()) then
				--Supply Novus as the player here - the parameter is only used to determine which version of the *_Tactical_Mission_Over
				--function we call, and as with the no achievements case below the Novus campaign is the one we want to move forward.
			--	Create_Thread("Show_Earned_Achievements_Thread", {Get_Game_Mode_GUI_Scene(), novus})
			--else
				
			-- Inform the campaign script of our victory.
			global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
			
			--Rely on the global script to schedule the next campaign, thus triggering a quit.
		else
			Show_Retry_Dialog()
		end
end

-- ***** ACHIEVEMENT_AWARD *****
function Show_Earned_Achievements_Thread(map)
	local dialog = Show_Earned_Offline_Achievements(map[1])
	while (dialog.Is_Showing()) do
		Sleep(1)
	end
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Cleanup_Hint_System", nil, {})
	Process_Tactical_Mission_Over(map[2])
end


-- here is where objects are locked or unlocked for the tactical game
function Lock_Objects(boolean)
		--novus.Lock_Object_Type(Find_Object_Type("NOVUS_DERVISH_JET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),boolean,STORY)
		
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Scarn_Beam"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Mass_Driver"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Radiation_Wake"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner"),false,STORY)
		novus.Lock_Generator("VirusInfectAuraGenerator", false ,STORY)	
		
		novus.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false ,STORY)

		novus.Lock_Generator("Resonance_Beam_Effect_Generator", false ,STORY)
		novus.Lock_Generator("Resonance_Cascade_Beam_Effect_Generator", false ,STORY)
		novus.Lock_Generator("Novus_Amplifier_Resonance_Weapon", false ,STORY)
		novus.Lock_Generator("Novus_Amplifier_Resonance_Cascade_Weapon", false ,STORY)
		novus.Lock_Generator("AmplifierResonanceBeamEffectGenerator", false ,STORY)
		novus.Lock_Generator("AmplifierCascadeResonanceBeamEffectGenerator", false ,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Unit_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Control_Turret_Area_Special_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Special_Ability", false, STORY)
		
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
		
		--All_Locks_Off(aliens, true)
		
		aliens.Lock_Generator("AlienTankPlasmaAEExplosionEffect", true,STORY)
		aliens.Lock_Generator("DefilerOnDeathExplosionGenerator", true,STORY)
		--aliens.Lock_Generator("CylinderOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("ReaperOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("ScanDroneOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("AssemblyOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("HabitatOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("ScienceWalkerOnDeathExplosionGenerator", true,STORY)
		--aliens.Lock_Generator("FooCoreOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("OrlokOnDeathExplosionGenerator", true,STORY)
		
		aliens.Lock_Effect("AlienRadiatedShotsImpactEffect", true,STORY)
end

function Import_Base_From_Global()
	novus_base_layout = global_script.Call_Function("Global_Load_Novus_Layout")
	structures_type_table = novus_base_layout[1]
	structures_pos_table = novus_base_layout[2]
	structures_face_table = novus_base_layout[3]
	if not structures_type_table==nil then
		for i, structure in pairs(structures_type_table) do
			last_structure = Create_Generic_Object(structures_type_table[i], structures_pos_table[i], novus)
			last_structure.Set_Facing(structures_face_table[i])
		end
	else 
		structures_type_table = Find_All_Objects_Of_Type("MARKER_GENERIC_BLUE")
		for i, structure in pairs(structures_type_table) do
			type_structure=structures_type_table[i]
			if type_structure.Get_Hint()=="terminal" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_REMOTE_TERMINAL"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="tower" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_SIGNAL_TOWER"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="power" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_POWER_ROUTER"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="input" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_INPUT_STATION"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="robotic" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"), type_structure.Get_Position(), novus)
			end

		end
	end
end

function Dialogue_Start_Mission()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE04_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE04_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE04_06"))
	end
	vertigo.Activate_Ability("Upload_Unit_Ability",true,hero,true)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "NVS07_SCENE05_15"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_14"))
	end
end

function Dialogue_Assembly_Walkers()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_16"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_17"))
	end
end

function Dialogue_Assembly_A()
	dialogue_assembly_a=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_07"))
	end
end

function Dialogue_Troop_Walkers()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_18"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_19"))
	end
end

function Dialogue_Troop_A()
	dialogue_troop_a=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_02"))
	end
end

function Dialogue_Troop_Walkers_Damage()
	dialogue_radiation=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_20"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_21"))
	end
end

function Dialogue_Science_A()
	dialogue_science_a=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "NVS07_SCENE05_12"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_13"))
	end
end

function Dialogue_Science_B()
	dialogue_science_b=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_10"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_11"))
	end
end

function Dialogue_Science_Walkers()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_22"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "NVS07_SCENE05_23"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_24"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_25"))
	end
end

function Post_Load_Callback()
	-- UI_Hide_Research_Button()
	--UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Advance_State = nil
	Alien_Troops_Cycler = nil
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
	Force_SW_Cooldown_Complete = nil
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
	Init_Superweapons_Data = nil
	Maintain_Base = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Remove_Xbox_Controller_Hint = nil
	On_Retry_Response = nil
	OutputDebug = nil
	PGColors_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Persist_Online_Achievements = nil
	Player_Earned_Offline_Achievements = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_From_Table = nil
	Reset_Objectives = nil
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Local_User_Applied_Medals = nil
	Set_Online_Player_Info_Models = nil
	Show_Earned_Achievements_Thread = nil
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
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
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

