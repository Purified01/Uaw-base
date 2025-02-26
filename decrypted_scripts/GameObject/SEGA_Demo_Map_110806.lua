if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[21] = true
LuaGlobalCommandLinks[171] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[177] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[29] = true
LuaGlobalCommandLinks[64] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[56] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[28] = true
LuaGlobalCommandLinks[58] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[20] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[38] = true
LuaGlobalCommandLinks[55] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/SEGA_Demo_Map_110806.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/SEGA_Demo_Map_110806.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #10 $
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

end


---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\X360_Skirmish Start!!"))
		--Set_Active_Context("360_Skirmish")
		--Fade_Screen_Out(0)
		--Lock_Controls(1)
		Change_Local_Faction("Novus")
		
		Create_Thread("Thread_Mission_Start")
		
	end
end

function Thread_Mission_Start()
	_CustomScriptMessage("JoeLog.txt", string.format("X360_Skirmish Thread_Mission_Start!!"))

	--define and setup the various guard-groups
	bridge01_guardgroup = Find_All_Objects_With_Hint("bridge01")
	bridge02_guardgroup = Find_All_Objects_With_Hint("bridge02")
	bridge03_guardgroup = Find_All_Objects_With_Hint("bridge03")
	masari_base_guardgroup = Find_All_Objects_With_Hint("baseguard")
	list_pointguards = Find_All_Objects_With_Hint("pointguard")
	masari_foundation = Find_First_Object("MASARI_FOUNDATION")
	
	
	Hunt(bridge01_guardgroup, "AntiDefault", false, true, bridge01_guardgroup[1], 100)
	Hunt(bridge02_guardgroup, "AntiDefault", false, true, bridge02_guardgroup[1], 100)
	Hunt(bridge03_guardgroup, "AntiDefault", false, true, bridge03_guardgroup[1], 100)
	
	Hunt(masari_base_guardgroup, "AntiDefault", false, true, masari_foundation, 500)
	
	for i, pointguard in pairs(list_pointguards) do
		if TestValid(pointguard) then
			pointguard.Guard_Target(pointguard.Get_Position())
		end
	end
	
	All_Locks_Off(masari, true)
	
	--[[novus.Give_Money(20000)
	masari.Give_Money(2000)
	
	--goto mission
	camera_start = Find_First_Object("NOVUS_CONSTRUCTOR")
	Fade_Screen_Out(0)
		
	Point_Camera_At(camera_start)
	--Sleep(1)
	--Start_Cinematic_Camera()
	Letter_Box_In(0.1)

	--Transition_Cinematic_Target_Key(camera_start, 0, 0, 0, 0, 0, 0, 0, 0)
	--Transition_Cinematic_Camera_Key(camera_start, 0, 200, 55, 65, 1, 0, 0, 0)

	Fade_Screen_In(2) 
	
	Transition_To_Tactical_Camera(5)
	Sleep(5)
	Letter_Box_Out(1)
	
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	
	--Create_Thread("Thread_Monitor_Mission_WinLoss_Status")]]
	
end


	




































































--**************************************************************
--*************************Ambient Stuff************************
--**************************************************************

function Thread_StartUp_OhmBot_Lineups()
	--first, see how many guys you need...this is dictated by the number of end-position flags	list_robot_flags = Find_All_Objects_With_Hint("bladetrooper-start", "MARKER_GENERIC_RED")
	local spawn_flag = Find_Hint("MARKER_GENERIC_PURPLE","spawn-robots")
	
	list_new_robot_flags = Find_All_Objects_Of_Type("MARKER_GENERIC_YELLOW")
	for i, robot_flag in pairs(list_new_robot_flags) do
		--local new_robot = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry"), spawn_flag, novus) 
		local new_robot = Spawn_Unit(Find_Object_Type("X360_Tutorial_OhmBot"), spawn_flag, novus) 
		new_robot.Enable_Behavior(79, false)
		new_robot.Set_Hint(robot_flag.Get_Hint())
		
		thread_info = {}
		thread_info[1] = new_robot
		thread_info[2] = robot_flag
		
		Create_Thread("Thread_Setup_OhmBot_Move_Orders", thread_info)
		
	end
	robotic_malfunctioner_leader = Find_Hint("X360_Tutorial_OhmBot","robotic-leader")
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
	spawn_flag = Find_Hint("MARKER_GENERIC_PURPLE","spawn-bladetroopers")
	
	--testing
	--Point_Camera_At(spawn_flag)
	
	for i, bladetrooper_flag in pairs(list_bladetrooper_flags) do
		if TestValid(bladetrooper_flag) then
			bladetrooper = Spawn_Unit(Find_Object_Type("X360_Tutorial_BladeTrooper"), spawn_flag, novus) 	
			
			bladetrooper.Enable_Behavior(79, false)

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
		_CustomScriptMessage("JoeLog.txt", string.format("BlockOnCommand(Full_Speed_Move(bladetrooper, goto_flag.Get_Position()))"))
		BlockOnCommand(Full_Speed_Move(bladetrooper, goto_flag.Get_Position()))
	end
	
	if TestValid(trooper_29_11) then
		bladetrooper.Turn_To_Face(trooper_29_11)
		bladetrooper.Set_Selectable(false)
		bladetrooper.Prevent_All_Fire(true)
		bladetrooper.Prevent_Opportunity_Fire(true)
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Setup_BladeTrooper_Move_Orders not TestValid(trooper_29_11)!!"))
	end
end







function Thread_StartUp_Signal_Flowers()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_StartUp_Signal_Flowers HIT!!"))
	
	Create_Thread("Thread_Ambient_Signal_Flowers_Routine_1a")
	Create_Thread("Thread_Ambient_Signal_Flowers_Routine_1b")
	Create_Thread("Thread_Ambient_Signal_Flowers_Routine_1c")
	Create_Thread("Thread_Ambient_Signal_Flowers_Routine_1d")
end

function Thread_Ambient_Signal_Flowers_Routine_1a() -- these guys all despawn at flag 1a

	local list_spawn_flags = {}
	list_spawn_flags[1] = Find_Hint("MARKER_GENERIC_PURPLE","01b")
	list_spawn_flags[2] = Find_Hint("MARKER_GENERIC_PURPLE","01c")
	list_spawn_flags[3] = Find_Hint("MARKER_GENERIC_PURPLE","01d")
	
	local counter_list_spawn_flags = table.getn(list_spawn_flags)
	
	local spawn_flag = nil
	
	while true do
		Sleep(GameRandom( 0.25, timer_ambient_flow_guys )) -- lets me tweak the "flux-rate" of these guys easily
		
		local spawn_number_roll = GameRandom( 1, 3 )

		if spawn_number_roll == 1 then
			spawn_flag = list_spawn_flags[1]
		elseif spawn_number_roll == 2 then
			spawn_flag = list_spawn_flags[2]
		else
			spawn_flag = list_spawn_flags[3]
		end
		
		if spawn_flag ~= nil then
			_CustomScriptMessage("JoeLog.txt", string.format("flow_dude = Spawn_Unit(Find_Object_Type(Novus_Robotic_Infantry_Ambient_Flow_1a), spawn_flag, faction, false, false)"))
			flow_dude = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry_Ambient_Flow_1a"), spawn_flag, novus, false, false) 
			flow_dude.Set_Selectable(false)
			flow_dude.Enable_Behavior(79, false)
			--these guys will despawn themselves.
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Ambient_Signal_Flowers_Routine_1b not TestValid(spawn_flag) !!"))
		end
	end
end

function Thread_Ambient_Signal_Flowers_Routine_1b() -- these guys all despawn at flag 1b

	local list_spawn_flags = {}
	list_spawn_flags[1] = Find_Hint("MARKER_GENERIC_PURPLE","01a")
	list_spawn_flags[2] = Find_Hint("MARKER_GENERIC_PURPLE","01c")
	list_spawn_flags[3] = Find_Hint("MARKER_GENERIC_PURPLE","01d")
	
	local counter_list_spawn_flags = table.getn(list_spawn_flags)
	
	local spawn_flag = nil

	while true do
		Sleep(GameRandom( 0.25, timer_ambient_flow_guys )) -- lets me tweak the "flux-rate" of these guys easily
		
		local spawn_number_roll = GameRandom( 1, 3 )

		if spawn_number_roll == 1 then
			spawn_flag = list_spawn_flags[1]
		elseif spawn_number_roll == 2 then
			spawn_flag = list_spawn_flags[2]
		else
			spawn_flag = list_spawn_flags[3]
		end
		
		if spawn_flag ~= nil then
			_CustomScriptMessage("JoeLog.txt", string.format("flow_dude = Spawn_Unit(Find_Object_Type(Novus_Robotic_Infantry_Ambient_Flow_1b), spawn_flag, faction, false, false)"))
			flow_dude = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry_Ambient_Flow_1b"), spawn_flag, novus, false, false) 
			flow_dude.Set_Selectable(false)
			flow_dude.Enable_Behavior(79, false)
			--these guys will despawn themselves.
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Ambient_Signal_Flowers_Routine_1b not TestValid(spawn_flag) !!"))
		end
	end
end

function Thread_Ambient_Signal_Flowers_Routine_1c() -- these guys all despawn at flag 1c

	local list_spawn_flags = {}
	list_spawn_flags[1] = Find_Hint("MARKER_GENERIC_PURPLE","01a")
	list_spawn_flags[2] = Find_Hint("MARKER_GENERIC_PURPLE","01b")
	list_spawn_flags[3] = Find_Hint("MARKER_GENERIC_PURPLE","01d")
	
	local counter_list_spawn_flags = table.getn(list_spawn_flags)
	
	local spawn_flag = nil
	
	while true do
		Sleep(GameRandom( 0.25, timer_ambient_flow_guys )) -- lets me tweak the "flux-rate" of these guys easily
		
		local spawn_number_roll = GameRandom( 1, 3 )

		if spawn_number_roll == 1 then
			spawn_flag = list_spawn_flags[1]
		elseif spawn_number_roll == 2 then
			spawn_flag = list_spawn_flags[2]
		else
			spawn_flag = list_spawn_flags[3]
		end
		
		if spawn_flag ~= nil then
			_CustomScriptMessage("JoeLog.txt", string.format("flow_dude = Spawn_Unit(Find_Object_Type(Novus_Robotic_Infantry_Ambient_Flow_1c), spawn_flag, faction, false, false)"))
			flow_dude = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry_Ambient_Flow_1c"), spawn_flag, novus, false, false) 
			flow_dude.Set_Selectable(false)
			flow_dude.Enable_Behavior(79, false)
			--these guys will despawn themselves.
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Ambient_Signal_Flowers_Routine_1c not TestValid(spawn_flag) !!"))
		end
	end
end

function Thread_Ambient_Signal_Flowers_Routine_1d() -- these guys all despawn at flag 1d

	local list_spawn_flags = {}
	list_spawn_flags[1] = Find_Hint("MARKER_GENERIC_PURPLE","01a")
	list_spawn_flags[2] = Find_Hint("MARKER_GENERIC_PURPLE","01b")
	list_spawn_flags[3] = Find_Hint("MARKER_GENERIC_PURPLE","01c")
	
	local counter_list_spawn_flags = table.getn(list_spawn_flags)
	
	local spawn_flag = nil
	
	while true do
		Sleep(GameRandom( 0.25, timer_ambient_flow_guys )) -- lets me tweak the "flux-rate" of these guys easily
		
		local spawn_number_roll = GameRandom( 1, 3 )

		if spawn_number_roll == 1 then
			spawn_flag = list_spawn_flags[1]
		elseif spawn_number_roll == 2 then
			spawn_flag = list_spawn_flags[2]
		else
			spawn_flag = list_spawn_flags[3]
		end
		
		if spawn_flag ~= nil then
			_CustomScriptMessage("JoeLog.txt", string.format("flow_dude = Spawn_Unit(Find_Object_Type(Novus_Robotic_Infantry_Ambient_Flow_1d), spawn_flag, faction, false, false)"))
			flow_dude = Spawn_Unit(Find_Object_Type("Novus_Robotic_Infantry_Ambient_Flow_1d"), spawn_flag, novus, false, false) 
			flow_dude.Set_Selectable(false)
			flow_dude.Enable_Behavior(79, false)
			--these guys will despawn themselves.
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Ambient_Signal_Flowers_Routine_1d not TestValid(spawn_flag) !!"))
		end
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
	--Point_Camera_At(location)
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
	Maintain_Base = nil
	Max = nil
	Min = nil
	Move_Camera_To = nil
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
	Thread_StartUp_BladeTrooper_Lineups = nil
	Thread_StartUp_OhmBot_Lineups = nil
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
