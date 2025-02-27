if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[159] = true
LuaGlobalCommandLinks[20] = true
LuaGlobalCommandLinks[76] = true
LuaGlobalCommandLinks[115] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/Dummy.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/Dummy.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStoryMode")
require("PGAchievementAward")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
require("PGPlayerProfile")

function gal()
	-- Spawn_Unit(Find_Object_Type("Smuggler_Team_E"), Find_First_Object("Sullust"), Find_Player("Empire"))
	Find_First_Object("Generic_Smuggler_E").Get_Parent_Object().Activate_Ability()
end

function mov()
	Find_First_Object("Tartan_Patrol_Cruiser").Move_To(Find_First_Object("Skirmish_Empire_Star_Base_1"))
	MessageBox("Moved")
end

function tone()
	while true do
		DebugMessage("%s -- %s", tostring(Script), Thread.Get_Name(Thread.Get_Current_ID()))
		Sleep(1)
	end
end
function ttwo()
	while true do
		DebugMessage("%s -- %s", tostring(Script), Thread.Get_Name(Thread.Get_Current_ID()))
		Sleep(1.1)
	end
end
function tthree()
	while true do
		DebugMessage("%s -- %s", tostring(Script), Thread.Get_Name(Thread.Get_Current_ID()))
		Sleep(1.3)
	end
end

function Kill_Em()
	for k, id in pairs(threads) do
		Thread.Kill(id)
	end
end

function Kill_Em2()
	Thread.Kill_All()
end

function Kill_Em3()
	Thread.Create("Kill_Em2")
end

function Test_Threads()
	threads = {}
	table.insert(threads, Thread.Create("tone"))
	table.insert(threads, Thread.Create("ttwo"))
	table.insert(threads, Thread.Create("tthree"))
end

function Do_It()
	Create_Thread("test_call")
end

function test_call()
	MessageBox("test_call")
end

function stest()
	MessageBox("%s", tostring((Find_First_Object("X-Wing").Get_Parent_Object()).Move_To(Find_First_Object("IPV1_System_Patrol_Craft"))))
end

function ref()
	Reinforce_Unit(Find_Object_Type("Corellian_Corvette"), false, Find_Player("Rebel"), true, false)
end

function move()
	MessageBox("Begin")
	-- Find_Player("Empire").Enable_As_Actor()
	-- FogOfWar.Reveal_All(Find_Player("Empire"))
	-- unit_list = { "Rebel_Heavy_Tank_Brigade" }
	unit_list = { "Boba_Fett_Team" }
	-- unit_list = { "Darth_Team" }
	--unit_list = { "Han_Solo_Team" }
	ReinforceList(unit_list, Find_First_Object("Corellian_Corvette"), Find_Player("Rebel"), false, true, true, test_call)
	--Formation_Attack(tanks, trooper)
	MessageBox("Done")
	Sleep(500)
end

function find()
	trooper = Find_First_Object("Stormtrooper_Team")
	tanks = Find_All_Objects_Of_Type("T4B_Tank")
end

function one()
	Spawn_Unit(Find_Object_Type("Rebel_Heavy_Tank_Brigade"), Find_First_Object("Power_Generator_R"), Find_Player("Rebel"))
end

function two()
	Spawn_Unit(Find_Object_Type("Corellian_Corvette"), Find_First_Object("Skirmish_Rebel_Star_Base_1"), Find_Player("Rebel"))
end

function Create_Medal_Effect()

	local effect = "Achievement_Nanite_Mastery"
	local position = Create_Position() -- this will create the vector (0,0,0)
	local faction = "Novus"
	Create_Generic_Object(Find_Object_Type(effect), position, Find_Player(faction))
	
end

function Set_Offline_Ach()

	PGOfflineAchievementDefs_Init()

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("Couldn't get the script")
		return
	end

	local value

	value = scoring_script.Call_Function("Get_Offline_Achievement_State", BUILT_N_BUILDINGS_IN_GAME_ID)
	value.PercentageComplete = 100
	value.Complete = true
	scoring_script.Call_Function("Update_Offline_Achievement_State", value.Id, value)

	value = scoring_script.Call_Function("Get_Offline_Achievement_State", KILLED_N_DEFILER_UNITS_ID)
	value.PercentageComplete = 60
	value.DefilerUnitsKilled = 6
	scoring_script.Call_Function("Update_Offline_Achievement_State", value.Id, value)

	--[[value = scoring_script.Call_Function("Get_Offline_Achievement_State", SKIRMISH_VS_AI_MEDIUM_ID)
	value.PercentageComplete = 43
	value.Versus1AI = false
	value.Versus2AI = true
	value.Versus3AI = false
	scoring_script.Call_Function("Update_Offline_Achievement_State", value.Id, value)

	value = scoring_script.Call_Function("Get_Offline_Achievement_State", FACTION_MASARI_STORY_ID)
	value.PercentageComplete = 100
	value.MissionsComplete = 100
	value.MissionsRequired = 100
	scoring_script.Call_Function("Update_Offline_Achievement_State", value.Id, value)

	value = scoring_script.Call_Function("Get_Offline_Achievement_State", PROCEDURAL_CAMPAIGNS_HARD_ID)
	value.PercentageComplete = 25
	value.MissionsComplete = 8
	value.MissionsRequired = 20
	scoring_script.Call_Function("Update_Offline_Achievement_State", value.Id, value)--]]

end

function Award_All_Medals(value)

	if (value == nil) then
		value = true
	end
	
	Register_Player_Profile_Commands()
	PGPlayerProfile_Init()
	Set_Profile_Value(PP_ALL_MEDALS_AWARDED_BYPASS, value)

	--[[ JOE DELETE::  Old disk-driven method
	PGAchievementAward_Init()
	PGOnlineAchievementDefs_Init()

	-- Online
	local fake_map = _PG_Create_Base_Online_Achievement_Map()
	
	-- Set the online username
	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("ONLINE_ACHIEVEMENT_AWARD:  Couldn't get the game scoring script.")
		return
	end
	local player = Create_Wide_String(player)
	scoring_script.Call_Function("Set_Online_Username", player)
	
	-- Update all the achievements and store them.
	for id, achievement in ipairs(fake_map) do
		Update_Achievement(achievement, 1)
		scoring_script.Call_Function("Update_Online_Achievement_State", player, id, achievement)
	end--]]

end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Award_All_Medals = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Create_Medal_Effect = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Do_It = nil
	Find_All_Parent_Units = nil
	Get_Achievement_Buff_Display_Model = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Get_Player_By_Faction = nil
	Kill_Em = nil
	Kill_Em3 = nil
	Maintain_Base = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGAchievementAward_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Persist_Online_Achievements = nil
	Player_Earned_Offline_Achievements = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Set_Local_User_Applied_Medals = nil
	Set_Offline_Ach = nil
	Set_Online_Player_Info_Models = nil
	Show_Earned_Offline_Achievements = nil
	Show_Earned_Online_Achievements = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	Story_AI_Request_Build_Hard_Point = nil
	Story_AI_Request_Build_Units = nil
	Story_AI_Set_Aggressive_Mode = nil
	Story_AI_Set_Autonomous_Mode = nil
	Story_AI_Set_Defensive_Mode = nil
	Story_AI_Set_Scouting_Mode = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Test_Threads = nil
	Update_Offline_Achievement = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	gal = nil
	mov = nil
	move = nil
	one = nil
	ref = nil
	stest = nil
	two = nil
	Kill_Unused_Global_Functions = nil
end
