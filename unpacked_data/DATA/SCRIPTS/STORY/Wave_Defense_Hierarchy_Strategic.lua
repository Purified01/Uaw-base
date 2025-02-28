if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[131] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[83] = true
LuaGlobalCommandLinks[56] = true
LuaGlobalCommandLinks[60] = true
LuaGlobalCommandLinks[61] = true
LuaGlobalCommandLinks[199] = true
LuaGlobalCommandLinks[59] = true
LuaGlobalCommandLinks[180] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[38] = true
LuaGlobalCommandLinks[63] = true
LuaGlobalCommandLinks[62] = true
LuaGlobalCommandLinks[28] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[81] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[175] = true
LuaGlobalCommandLinks[58] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[94] = true
LuaGlobalCommandLinks[43] = true
LuaGlobalCommandLinks[183] = true
LuaGlobalCommandLinks[125] = true
LuaGlobalCommandLinks[179] = true

LUA_PREP = true

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

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Start_Defense", State_Start_Defense)
	Define_State("State_Start_Dialogue", State_Start_Dialogue) 
	Define_State("State_Campaign_Over", State_Campaign_Over)

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

	aliens.Enable_Colorization(true, COLOR_BLUE)
	masari.Enable_Colorization(true, COLOR_RED)
    ZM01_successful = false
    
	bool_user_chose_mission = false
	global_story_dialogue_done=false
end

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Debug_Start_Mission == nil then
			Set_Next_State("State_Start_Dialogue")
		else
			Set_Next_State(tostring(data_table.Debug_Start_Mission))
			data_table.Debug_Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		
		hero = Find_First_Object("Alien_Hero_Orlok")
		hero.Set_Selectable(false)
		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = Point_Camera_At.Set_Transition_Time(1, 1)
		globe_spinning_thread=nil
		
		current_global_story_dialogue_id=nil
		
		Pause_Sun(true)
	end
end

function State_Start_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("Global_Story_Dialogue")

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_Defense")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					
					Lock_Controls(0)
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end				
				end
			end
		end
	end
end

function Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region1")) --goto
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region23")) --start
	Fade_Screen_In(1)
	
    local hero = Find_First_Object("Alien_Hero_Orlok")
    local fleet = hero.Get_Parent_Object()
    fleet.Move_Fleet_To_Region(Find_First_Object("Region23"), true) --start
    global_story_dialogue_setup = true
		
	old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 1
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region1")) --goto
		
	Fade_Screen_Out(1)
	Sleep(1)
	global_story_dialogue_done=true
end
	
function State_Start_Defense(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Point_Sun_At(Find_First_Object("Region1")) --goto
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("splash_alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_WAVE_DEFENSE_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(Find_First_Object("Region1"), novus, aliens, false) --goto
		end
		
	end
end


function On_Land_Invasion()

    if CurrentState == "State_Start_Defense" then
        InvasionInfo.OverrideMapName = "./Data/Art/Maps/WaveDefenseM1.ted"
        InvasionInfo.TacticalScript = "Wave_Defense_Hierarchy"
        InvasionInfo.UseStrategicPersistence = false
        InvasionInfo.UseStrategicProductionRules = false
        InvasionInfo.StartingContext = "WaveDefenseH"
        InvasionInfo.NightMission = false
    end
end

function Hierarchy_Tactical_Mission_Over(victorious)
    if CurrentState == "State_Start_Defense" then 
		if victorious then
			ZM01_successful = true
			Set_Next_State("State_Campaign_Over")
		end
    end

	if not victorious then
		Retry_Current_Mission()
	end
end

function State_Campaign_Over(message)
	if message == OnEnter then
		-- Register_Campaign_Commands()
		Quit_Game_Now(aliens, true, true, false, false, true, false)
	end
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
	Fake_Fleet_Move = nil
	Find_All_Parent_Units = nil
	Flash_Region = nil
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

