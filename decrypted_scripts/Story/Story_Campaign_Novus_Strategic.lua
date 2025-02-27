if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[83] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[177] = true
LuaGlobalCommandLinks[38] = true
LuaGlobalCommandLinks[199] = true
LuaGlobalCommandLinks[61] = true
LuaGlobalCommandLinks[180] = true
LuaGlobalCommandLinks[63] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[60] = true
LuaGlobalCommandLinks[62] = true
LuaGlobalCommandLinks[28] = true
LuaGlobalCommandLinks[56] = true
LuaGlobalCommandLinks[131] = true
LuaGlobalCommandLinks[81] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[175] = true
LuaGlobalCommandLinks[58] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[94] = true
LuaGlobalCommandLinks[179] = true
LuaGlobalCommandLinks[183] = true
LuaGlobalCommandLinks[125] = true
LuaGlobalCommandLinks[43] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Novus_Strategic.lua#44 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Novus_Strategic.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Joe_Howes $
--
--            $Change: 95773 $
--
--          $DateTime: 2008/03/26 11:57:26 $
--
--          $Revision: #44 $
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
	Define_State("State_Start_Tut01", State_Start_Tut01) -- first tutorial ... at capitol building
	Define_State("State_Start_Tut02", State_Start_Tut02) -- second tutorial ... at military base south of Capitol Building
	Define_State("State_Tutorial_Campaign_Over", State_Tutorial_Campaign_Over) -- goto Novus campaign -- right now just exits to main menu
	Define_State("State_Start_NM01", State_Start_NM01) --first Novus mission -- near the pyramids
	Define_State("State_Start_NM01_Dialogue", State_Start_NM01_Dialogue) --first Novus mission -- near the pyramids
	Define_State("State_Start_NM02", State_Start_NM02) -- second Novus mission -- in England
	Define_State("State_Start_NM02_Dialogue", State_Start_NM02_Dialogue) -- second Novus mission -- in England
	Define_State("State_Start_NM03", State_Start_NM03) -- third novus -- Siberia
	Define_State("State_Start_NM03_Dialogue", State_Start_NM03_Dialogue) -- third novus -- Siberia
	Define_State("State_Start_NM04", State_Start_NM04) -- forth Novus -- TBD
	Define_State("State_Start_NM04_Dialogue", State_Start_NM04_Dialogue) -- forth Novus -- TBD
	Define_State("State_Start_NM05", State_Start_NM05) -- fifth Novus -- South Africa
	Define_State("State_Start_NM05_Dialogue", State_Start_NM05_Dialogue) -- fifth Novus -- South Africa
	Define_State("State_Start_NM06", State_Start_NM06) -- sixth Novus -- ZRH interior
	Define_State("State_Start_NM06_Dialogue", State_Start_NM06_Dialogue) -- sixth Novus -- ZRH interior
	Define_State("State_Start_NM07", State_Start_NM07) -- Seventh Novus -- NM01 map ... near the pyramids
	
	Define_Retry_State()
	
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
	aliens.Enable_Colorization(true, 2)
	novus.Enable_Colorization(true, 6)
	uea.Enable_Colorization(true, 5)
	masari.Enable_Colorization(true, 21)
	
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
	NM01_successful = false
	NM02_successful = false
	NM03_successful = false
	NM04_successful = false
	NM05_successful = false
	NM06_successful = false
	NM07_successful = false
	
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
			Set_Next_State("State_Start_NM01_Dialogue")
			
		else
			Set_Next_State(tostring(data_table.Start_Mission))
			data_table.Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		--Set_Next_State("State_Start_NM01_Dialogue")
		
		--puts up text in the objective box to let player know how to skip to specific missions
		--skipping info getting commented out for sega delivery of first four missions ... jdg 1/5/07
		--objective_skipping_info = Add_Objective("To skip to a specific mission via console commands: \n1. Type 'attach Story_Campaign_Novus_Strategic'\n2. Type 'lua' then which mission to start NM01() - NM07()\n** eg. 'lua NM01()'")
		--objective_skipping_info = Add_Objective("Move your hero to the red-zone to begin.")
		
		hero = Find_First_Object("Novus_Hero_Mech")
		hero.Set_Selectable(false)
		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = Point_Camera_At.Set_Transition_Time(1, 1)
		globe_spinning_thread=nil
		
		current_global_story_dialogue_id=nil
		current_global_story_dialogue_id_sub_a=nil
		current_global_story_dialogue_id_sub_b=nil
		
		Pause_Sun(true)

		Set_Profile_Value(PP_LAST_PLAYED_CAMPAIGN, PG_CAMPAIGN_NOVUS)
		Commit_Profile_Values()
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

		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
		UI_Set_Loading_Screen_Background("splash_military.tga")
		UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT01_LOAD_SCREEN_TEXT")
		
		-- jdg ... 10/01/07 ... asset bank stuff per Jason 
		--player is Military vs Hierarchy -- redundant scripts...this now launches from Story_Campaign_Tutorial_Strategic.lua
		uea.Set_Is_AI_Required(false)
		aliens.Set_Is_AI_Required(true) 
		novus.Set_Is_AI_Required(false)
		masari.Set_Is_AI_Required(false)
		
		
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
		
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving to psuedo-Washington D.C. for Tutorial 02"))
			local region = Find_First_Object("Region23") -- (22  - Washington DC/using 23 - Gulf Coast for now)
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Military then Novus  vs Hierarchy -- redundant scripts...this now launches from Story_Campaign_Tutorial_Strategic.lua
			uea.Set_Is_AI_Required(false)
			novus.Set_Is_AI_Required(false)
			aliens.Set_Is_AI_Required(false) 
			masari.Set_Is_AI_Required(false)
			
			Force_Land_Invasion(region, aliens, uea, false)
		end
	end
end

function State_Start_NM01_Dialogue(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM01_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region22"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_NM01")
		
		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM01")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region15"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region15"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end				
				end
			end
		end
	end
end

function NM01_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region15"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region22"))
	Fade_Screen_In(1)
	
	
		local region=Find_First_Object("Region22")
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region22"), true)
		region.Start_Command_Center_Construction(Find_Object_Type("Novus_Material_Center"),novus,true)
		global_story_dialogue_setup = true
		
	founder_slot=2;
	novcomm_slot=1;
	mirabel_slot=3;
	Set_PIP_Model(founder_slot, pip_founder)
	Set_PIP_Model(mirabel_slot, pip_mirabel)
	Set_PIP_Model(novcomm_slot, pip_novcomm)
	
	Sleep(1)
	
	old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 12
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region15"))
		
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_01", founder_slot))
		--BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE02_02", mirabel_slot))
		--BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS01_SCENE02_03", novcomm_slot))
		--BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_04", founder_slot))
		--BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_05", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE02_06", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_07", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE02_08", mirabel_slot))
		--BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_09", founder_slot))
		--BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE02_10", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_11", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_12", founder_slot))
	else
		Sleep(2)
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region15"))
	Zoom_Camera(1)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE02_13", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE02_14", mirabel_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_NM01()
	local hero = Find_First_Object("Novus_Hero_Mech")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	region_start=Find_First_Object("Region22")
	region_end=Find_First_Object("Region35")
	move_time = 6
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region35")
	region_end=Find_First_Object("Region31")
	move_time = 6
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region31")
	region_end=Find_First_Object("Region18")
	move_time = 8
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region18")
	region_end=Find_First_Object("Region15")
	move_time = 6
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_NM01(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM01"))
		Point_Sun_At(Find_First_Object("Region15"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving to the Sahara for NM01"))
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS01_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy with some Military presence
			novus.Set_Is_AI_Required(false)
			masari.Set_Is_AI_Required(false)
			-- dme ... 12/18/07 ... Turning off the military and alien asset banks as it's being called directly in the map bank now. 
			aliens.Set_Is_AI_Required(false) 
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_01)
			Commit_Profile_Values()
			Force_Land_Invasion(Find_First_Object("Region15"), aliens, novus, false)
		end
		
	end
end

function Global_Store_Novus_Layout(given_table)
	novus_base_table = given_table
end

function Global_Load_Novus_Layout()
	return novus_base_table
end



function State_Start_NM02_Dialogue(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM02_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region15"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_NM02")
		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM02")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region24"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region24"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function NM02_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region24"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region15"))
	Fade_Screen_In(1)
	
		local region=Find_First_Object("Region15")
		local center=region.Get_Command_Center()
		if TestValid(center) then center.Despawn() end
		Sleep(1) -- must be here to give the command center time to despawn (jgs?)
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region15"), true)
		region.Start_Command_Center_Construction(Find_Object_Type("Novus_Material_Center"),novus,true)
		global_story_dialogue_setup = true
		
	founder_slot=2;
	novcomm_slot=1;
	mirabel_slot=3;
	Set_PIP_Model(founder_slot, pip_founder)
	Set_PIP_Model(mirabel_slot, pip_mirabel)
	Set_PIP_Model(novcomm_slot, pip_novcomm)
	
	Sleep(2)
	
	Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 10
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region24"))
		
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS02_SCENE00_01", novcomm_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS02_SCENE00_02", founder_slot))
	else
		Sleep(2)
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region24"))
	Zoom_Camera(1)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS02_SCENE00_03", novcomm_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS02_SCENE00_04", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS02_SCENE00_05", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS02_SCENE00_06", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS02_SCENE00_07", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS02_SCENE00_08", founder_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_NM02()
	local hero = Find_First_Object("Novus_Hero_Mech")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	Sleep(2)
	region_start=Find_First_Object("Region15")
	region_end=Find_First_Object("Region18")
	move_time = 4
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region18")
	region_end=Find_First_Object("Region31")
	move_time = 4
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region31")
	region_end=Find_First_Object("Region35")
	move_time = 4
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region35")
	region_end=Find_First_Object("Region23")
	move_time = 4
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region23")
	region_end=Find_First_Object("Region24")
	move_time = 4
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_NM02(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM02"))
		Point_Sun_At(Find_First_Object("Region24"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving for NM02"))
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
			local region = Find_First_Object("Region24") -- (24 - Midwest)

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS02_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy with some Military presence
			novus.Set_Is_AI_Required(false)
			aliens.Set_Is_AI_Required(false) 
			masari.Set_Is_AI_Required(false)
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_02)
			Commit_Profile_Values()
			Force_Land_Invasion(region, nil, novus, false)
		end
	
	end
end




function State_Start_NM03_Dialogue(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM03_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region24"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_NM03")

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM03")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region8"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region8"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function NM03_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region8"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region24"))
	Fade_Screen_In(1)
	
		local region=Find_First_Object("Region24")
		local center=region.Get_Command_Center()
		if TestValid(center) then center.Despawn() end
		Sleep(1) -- must be here to give the command center time to despawn (jgs?)
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region24"), true)
		region.Start_Command_Center_Construction(Find_Object_Type("Novus_Material_Center"),novus,true)
		global_story_dialogue_setup = true

	founder_slot=2;
	novcomm_slot=1;
	mirabel_slot=3;
	Set_PIP_Model(founder_slot, pip_founder)
	Set_PIP_Model(mirabel_slot, pip_viktor)
	Set_PIP_Model(novcomm_slot, pip_novcomm)
	
	Sleep(1)
	
	Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 5
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region8"))
		
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS03_SCENE00_01", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_viktor, "NVS03_SCENE00_02", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS03_SCENE00_03", founder_slot))
	else
		Sleep(2)
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region8"))
	Zoom_Camera(1)
	Set_PIP_Model(mirabel_slot, pip_mirabel)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS03_SCENE00_04", novcomm_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS03_SCENE00_05", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS03_SCENE00_06", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS03_SCENE00_07", founder_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_NM03()
	local hero = Find_First_Object("Novus_Hero_Mech")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	Sleep(2)
	region_start=Find_First_Object("Region24")
	region_end=Find_First_Object("Region11")
	move_time = 6
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region11")
	region_end=Find_First_Object("Region8")
	move_time = 6
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_NM03(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM03"))
		Point_Sun_At(Find_First_Object("Region8"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving for NM03"))
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS03_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy 
			novus.Set_Is_AI_Required(false)
			aliens.Set_Is_AI_Required(true) 
			masari.Set_Is_AI_Required(false)
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_03)
			Commit_Profile_Values()
			Force_Land_Invasion(Find_First_Object("Region8"), nil, novus, false)
		end

	end
end




function State_Start_NM04_Dialogue(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM04_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region8"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_NM04")

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM04")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region7"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region7"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function NM04_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region7"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region8"))
	Fade_Screen_In(1)
	
		local region=Find_First_Object("Region8")
		local center=region.Get_Command_Center()
		if TestValid(center) then center.Despawn() end
		Sleep(1) -- must be here to give the command center time to despawn (jgs?)
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region8"), true)
		region.Start_Command_Center_Construction(Find_Object_Type("Novus_Material_Center"),novus,true)
		global_story_dialogue_setup = true

	founder_slot=2;
	novcomm_slot=1;
	mirabel_slot=3;
	Set_PIP_Model(founder_slot, pip_founder)
	Set_PIP_Model(mirabel_slot, pip_mirabel)
	Set_PIP_Model(novcomm_slot, pip_novcomm)
	
	Sleep(1)
	
	Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 5
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region7"))
		
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS04_SCENE01_01", founder_slot))
	else
		Sleep(2)
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region7"))
	Zoom_Camera(1)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS04_SCENE01_02", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS04_SCENE01_03", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS04_SCENE01_04", mirabel_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_NM04()
	local hero = Find_First_Object("Novus_Hero_Mech")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	Sleep(2)
	region_start=Find_First_Object("Region8")
	region_end=Find_First_Object("Region7")
	move_time = 6
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_NM04(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM04"))
		Point_Sun_At(Find_First_Object("Region7"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving for NM04"))
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS04_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy with some Military presence
			novus.Set_Is_AI_Required(false)
			aliens.Set_Is_AI_Required(true) 
			masari.Set_Is_AI_Required(false)
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_04)
			Commit_Profile_Values()
			Force_Land_Invasion(Find_First_Object("Region7"), aliens, novus, false)
		end
	
	end
end

function State_Start_NM05_Dialogue(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM05_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region7"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_NM05")
		global_story_dialogue_setup = false

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM05")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region21"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region21"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function NM05_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region21"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region7"))
	Fade_Screen_In(1)
	
		local region=Find_First_Object("Region7")
		local center=region.Get_Command_Center()
		if TestValid(center) then center.Despawn() end
		Sleep(1) -- must be here to give the command center time to despawn (jgs?)
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region7"), true)
		region.Start_Command_Center_Construction(Find_Object_Type("Novus_Material_Center"),novus,true)
		global_story_dialogue_setup = true

	founder_slot=2;
	novcomm_slot=1;
	mirabel_slot=3;
	Set_PIP_Model(founder_slot, pip_founder)
	Set_PIP_Model(mirabel_slot, pip_mirabel)
	Set_PIP_Model(novcomm_slot, pip_novcomm)
	
	Sleep(1)
	
	Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE01_01", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE01_02", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE01_03", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE01_04", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE01_05", founder_slot))
	else
		Sleep(2)
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region21"))
	Zoom_Camera(1)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE01_06", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE01_07", mirabel_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE01_08", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE01_09", founder_slot))
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE01_10", mirabel_slot))
		Set_PIP_Model(mirabel_slot, pip_viktor)
		BlockOnCommand(Queue_Talking_Head(pip_viktor, "NVS05_SCENE01_11", mirabel_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_NM05()
	local hero = Find_First_Object("Novus_Hero_Mech")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	Sleep(2)
	transition_time = 7
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region16"))
	region_start=Find_First_Object("Region7")
	region_end=Find_First_Object("Region16")
	move_time = 6
	transition_time = 7
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region21"))
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region16")
	region_end=Find_First_Object("Region21")
	move_time = 6
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_NM05(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM05"))
		Point_Sun_At(Find_First_Object("Region21"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving for NM05"))
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS05_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy with some Military presence
			novus.Set_Is_AI_Required(false)
			aliens.Set_Is_AI_Required(true) 
			masari.Set_Is_AI_Required(false)
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_05)
			Commit_Profile_Values()
			Force_Land_Invasion(Find_First_Object("Region21"), aliens, novus, false)
		end
	end
end






function State_Start_NM06_Dialogue(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region22"), true)
		
		current_global_story_dialogue_id = Create_Thread("NM06_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region21"))

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if EscToStartState or global_story_dialogue_done then
			  if global_story_dialogue_setup then 
				Stop_All_Speech()
				EscToStartState = false
				
				if not (current_global_story_dialogue_id == nil) then
					Thread.Kill(current_global_story_dialogue_id)
				end
				if not (current_global_story_dialogue_id_sub_b == nil) then
					Thread.Kill(current_global_story_dialogue_id_sub_b)
				end
				
				Lock_Controls(0)
				End_Cinematic_Camera()
				
				local hero = Find_First_Object("Novus_Hero_Mech")
				local fleet = hero.Get_Parent_Object()
				fleet.Move_Fleet_To_Region(Find_First_Object("Region21"), true)
		
				global_story_dialogue_done=true
				Set_Next_State("State_Start_NM06") -- turn this back on!!!!!!!!
			  end
			end
		end
	end
end

function NM06_Global_Story_Dialogue()
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Point_Sun_At(Find_First_Object("Region21"))
	
	local region=Find_First_Object("Region21")
	region.Start_Command_Center_Construction(Find_Object_Type("Novus_Material_Center"),novus,true)
		
	Start_Cinematic_Camera()
	
	local center=region.Get_Command_Center()
	if TestValid(center) then center.Despawn() end
	Sleep(1) -- must be here to give the command center time to despawn (jgs?)
	global_story_dialogue_setup=true
		
	if true then
		globe.Play_Animation("Anim_Cinematic",true,0)
		Sleep(1)
		Fade_Screen_In(1)
		Letter_Box_In(1)
	
		camera_pos = globe.Get_Bone_Position("camera_cine_01")
		target1_pos = Find_First_Object("Region21")
		target2_pos = globe.Get_Bone_Position("target_cine_01")
     -- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Set_Cinematic_Camera_Key(camera_pos, 0, -260, 200, 0, 0, 0, 0)
		Set_Cinematic_Target_Key(target1_pos, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Camera_Key(camera_pos, 8, 0, -260, 150, 0, 0, 0, 0)
		Transition_Cinematic_Target_Key(target2_pos, 20, 0, 0, 0, 0, 0, 0, 0)
		Sleep(2)
		globe.Play_Animation("Anim_Cinematic",true,1)
		Sleep(5)
		globe.Play_Animation("Anim_Cinematic",true,2)
		Sleep(1)
	end
	
	Fade_Screen_Out(2)
	Sleep(2)

	global_story_dialogue_done=true
end
	
function State_Start_NM06(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM06"))
		Point_Sun_At(Find_First_Object("Region21"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving for NM06"))
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS06_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy
			novus.Set_Is_AI_Required(false)
			aliens.Set_Is_AI_Required(false) 
			masari.Set_Is_AI_Required(false)
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_06)
			Commit_Profile_Values()
			Force_Land_Invasion(Find_First_Object("Region30"), aliens, novus, false)
		end
	end
end




-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

function State_Start_NM07(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Point_Sun_At(Find_First_Object("Region15"))
		JumpToNextMission=false
		EscToStartState=false
		UI_Hide_Start_Mission_Button()
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_NM07"))

		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving to the pseudo-Sahara for NM07"))
			local region = Find_First_Object("Region15") -- (15 - Middle East)

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS07_LOAD_SCREEN_TEXT")
			
			-- jdg ... 10/01/07 ... asset bank stuff per Jason 
			--player is Novus  vs Hierarchy with some Military presence
			novus.Set_Is_AI_Required(false)
			masari.Set_Is_AI_Required(false)
			-- dme ... 12/18/07 ... Turning off the military and alien asset banks as it's being called directly in the map bank now. 
			aliens.Set_Is_AI_Required(false) 
			uea.Set_Is_AI_Required(false)
			
			Set_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_07)
			Commit_Profile_Values()
			Force_Land_Invasion(region, aliens, novus, false)
		end
	end
end

function State_Tutorial_Campaign_Over(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Tutorial_Campaign_Over"))
		--MessageBox("You Won! Thanks for playing\nNow returning you to the Main Menu...")
		Set_Profile_Value(PP_CAMPAIGN_TUTORIAL_COMPLETED, true)
		Commit_Profile_Values()
		
		--Quit_Game_Now(novus, true, true, false)
		Register_Campaign_Commands()
		CampaignManager.Start_Campaign("NOVUS_Story_Campaign")
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
		
	if CurrentState == "State_Start_Tut01" then 
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

	elseif CurrentState == "State_Start_NM01" then
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M15_Middle_East.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM01"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "NM01_StoryCampaign"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_NM02" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M24_Midwest.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM02"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
		InvasionInfo.StartingContext = "StoryCampaign"
		InvasionInfo.NightMission = true
	
	elseif CurrentState == "State_Start_NM03" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M08_Eastern_Siberia.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM03"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "StoryCampaign"
		InvasionInfo.RequiredContexts = { "Cinematic_Intro" }
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_NM04" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M07_Turkestan.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM04"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "NM04_StoryCampaign"
		InvasionInfo.RequiredContexts = { "hide_me" }
		InvasionInfo.NightMission = false
		Change_Local_Faction("Novus")
	
	elseif CurrentState == "State_Start_NM05" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M21_South_Africa.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM05"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "StoryCampaignNovus5"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_NM06" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/NOV_M06_ZRHShip.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM06"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.NightMission = false
		InvasionInfo.StartingContext = "StoryCampaignNovus6"
	
	elseif CurrentState == "State_Start_NM07" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M15_Middle_East.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_NM07"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "NM07_IntroCinematic"
		InvasionInfo.RequiredContexts = { "NM07_StoryCampaign", "NM07_EndCinematic" }
		InvasionInfo.NightMission = false	
	end
end



--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Novus "TACTICAL" mission scripts 
function Novus_Tactical_Mission_Over(victorious)
	--local completed_mission = 0
	if CurrentState == "State_Start_Tut01" then 
		if victorious then
			tutorial01_successful = true
			Set_Next_State("State_Start_Tut02")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT")
			--completed_mission = 1
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(1, "N")
		end
	elseif CurrentState == "State_Start_Tut02" then
		if victorious then
			tutorial02_successful = true
			Set_Next_State("State_Tutorial_Campaign_Over")
			Set_Profile_Value(PP_CAMPAIGN_TUTORIAL_COMPLETED, true)			

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT")
			--completed_mission = 2
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(2, "N")
		end
	elseif CurrentState == "State_Start_NM01" then 
		if victorious then
			NM01_successful = true
			
			Set_Profile_Value(PP_NOVUS_MISSION_01_AVAILABLE, true)
			
			-- Mark the next mission as available
 			Set_Profile_Value(PP_NOVUS_MISSION_02_AVAILABLE, true)
			
 			Set_Next_State("State_Start_NM02_Dialogue")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text()
			--completed_mission = 3
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(3, "N")
		end
	elseif CurrentState == "State_Start_NM02" then 
		if victorious then
			NM02_successful = true
			
			-- Mark the next mission as available
 			Set_Profile_Value(PP_NOVUS_MISSION_03_AVAILABLE, true)
			Set_Next_State("State_Start_NM03_Dialogue")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text()
			--completed_mission = 4
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(4, "N")
		end
	elseif CurrentState == "State_Start_NM03" then 
		if victorious then
			NM03_successful = true
			
			-- Mark the next mission as available
 			Set_Profile_Value(PP_NOVUS_MISSION_04_AVAILABLE, true)
			
			Set_Next_State("State_Start_NM04_Dialogue")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text()
			--completed_mission = 5
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(5, "N")
		end
	elseif CurrentState == "State_Start_NM04" then 
		if victorious then
			NM04_successful = true
			
			-- Mark the next mission as available
 			Set_Profile_Value(PP_NOVUS_MISSION_05_AVAILABLE, true)
			Set_Next_State("State_Start_NM05_Dialogue")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text()
			--completed_mission = 6
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(6, "N")
		end
	elseif CurrentState == "State_Start_NM05" then 
		if victorious then
			NM05_successful = true
			
			-- Mark the next mission as available
 			Set_Profile_Value(PP_NOVUS_MISSION_06_AVAILABLE, true)
			Set_Next_State("State_Start_NM06_Dialogue")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text()
			--completed_mission = 7
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(7, "N")
		end
	elseif CurrentState == "State_Start_NM06" then 
		if victorious then
			NM06_successful = true
			
			-- Mark the next mission as available
 			Set_Profile_Value(PP_NOVUS_MISSION_07_AVAILABLE, true)
			Set_Next_State("State_Start_NM07")

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS07_LOAD_SCREEN_TEXT")
			--completed_mission = 8
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(8, "N")
		end
	elseif CurrentState == "State_Start_NM07" then 
		if victorious then
			NM07_successful = true

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("Splash_Alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE01_LOAD_SCREEN_TEXT")
			
			-- Handle campaign completion immediately: it's more efficient
			-- than doing a quit out to global and a state pump
			Set_Profile_Value(PP_CAMPAIGN_NOVUS_COMPLETED, true)
			
			-- Oksana: Notify achievements
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(9, "N")
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Novus")
			
			Register_Campaign_Commands()
			CampaignManager.Start_Campaign("Hierarchy_Story_Campaign")			
			--completed_mission = 9
		end
	end
	
	-- Notify the achievement system, i applicable
 	--[[if completed_mission > 0 then
		GameScoringManager.Notify_Achievement_System_Of_Campaign_Mission_Completion(completed_mission, "N")
  	end--]]
	
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

function NM01()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM01"))
	Set_Next_State("State_Start_NM01")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM01\nMove your hero to any enemy territory to trigger the mission.")
end

function NM02()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM02"))
	Set_Next_State("State_Start_NM02")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM02\nMove your hero to any enemy territory to trigger the mission.")
end

function NM03()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM03"))
	Set_Next_State("State_Start_NM03")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM03\nMove your hero to any enemy territory to trigger the mission.")
end

function NM04()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM04"))
	Set_Next_State("State_Start_NM04")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM04\nMove your hero to any enemy territory to trigger the mission.")
end

function NM05()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM05"))
	Set_Next_State("State_Start_NM05")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM05\nMove your hero to any enemy territory to trigger the mission.")
end

function NM06()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM06"))
	Set_Next_State("State_Start_NM06")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM06\nMove your hero to any enemy territory to trigger the mission.")
end

function NM07()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to NM07"))
	Set_Next_State("State_Start_NM07")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: NM07\nMove your hero to any enemy territory to trigger the mission.")
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

