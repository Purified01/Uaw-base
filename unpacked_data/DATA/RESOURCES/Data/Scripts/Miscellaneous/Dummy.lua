-- $Id$
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
--              $File$
--
--    Original Author: Brian Hayes
--
--            $Author$
--
--            $Change$
--
--          $DateTime$
--
--          $Revision$
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStoryMode")
require("PGAchievementAward")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
require("PGPlayerProfile")
require("PGMoveUnits")
require("PGSpawnUnits")

ServiceRate = 1

function member_test()
	MessageBox(string.format("%s", tostring(Thread.Is_Thread_Active(Thread.Get_Current_ID()))))
	-- MessageBox(string.format("%s: %s", tostring(Thread.Get_Name(Thread.Get_Current_ID())), tostring(Thread.Is_Thread_Active(Thread.Get_Current_ID()))))
	-- Thread.Is_Thread_Active(Thread.Get_Current_ID(), "blah", Thread.Get_Name(Thread.Get_Current_ID()))
end

function _create_test()
	while true do
		Sleep(2)
		marker = Find_First_Object("_TREE_MAPLE_02")
		new_unit = Spawn_Unit(Find_Object_Type("Alien_Walker_Habitat"), marker, Find_Player("Alien"))
		Sleep(5)
		new_unit.Despawn()
	end
end

function create_test()
	Create_Thread("_create_test")
	
end

function gal()
	-- Spawn_Unit(Find_Object_Type("Smuggler_Team_E"), Find_First_Object("Sullust"), Find_Player("Empire"))
	Find_First_Object("Generic_Smuggler_E").Get_Parent_Object().Activate_Ability()
end

function mtest()
	--marker = Find_First_Object("MARKER_GENERIC")
	--new_unit = Spawn_Unit(Find_Object_Type("Alien_Walker_Science"), marker, Find_Player("Alien"))
	Create_Thread("mthread")
end

function mthread()
	Drop_In_Spawn_Unit("Alien_Walker_Habitat", "Alien_Walker_Habitat_Glyph", Find_First_Object("_TREE_MAPLE_02"), Find_Player("Alien"))
	
end


function mattack()
	Formation_Attack(ar, av)
end

function dummy_thread()
	while true do
		Sleep(0.1)
	end
end

function sleep_thread()
	second_count = 0
	while true do
		if second_count == 10 then break end
		Sleep(1)
		second_count = second_count + 1
	end
	MessageBox("Sleep Done!")
end

function sleep_test()
	Create_Thread("sleep_thread")
	--Create_Thread("test_bad_func")
	--Create_Thread("test_bad_func")
	--Create_Thread("test_bad_func")
end

function thread_test()
	for i=1, 50 do
		Create_Thread("dummy_thread")
	end
end

function profile_test()
	Create_Thread("profile_test2")
end

function profile_test2()
	while true do
		test_bad_func()
		test_good_func()
		Sleep(0.1)
	end
end

function profile_test3()
	test_bad_func()
	test_good_func()
end

function test_good_func()
end

function test_bad_func()
	tval = 10
	for idx = 1, 1000 do
		tval = tval * 2.45
		tval = tval / 2.45
		tval = tval * 2.45
		tval = tval / 2.45
		tval = tval * 2.45
		tval = tval / 2.45
		tval = tval * 2.45
		tval = tval / 2.45
		tval = tval * 2.45
		tval = tval / 2.45
		tval = tval * 2.45
		tval = tval / 2.45
	end
end

function test_civ()
	civ = Find_First_Object("American_Civilian_Urban_01_Script")
	-- Spawn_Unit(Find_Object_Type("American_Civilian_Urban_01_Wartime_Spawned"), Find_First_Object("American_Civilian_Urban_01_Script"), Find_Player("Civilian"))
	-- American_Civilian_Urban_01_Wartime_Spawned
	Make_Civilians_Panic(civ, 500)
end

function test_con(arg)
	walker = Find_First_Object("Alien_Walker_Habitat")
	walker.Set_Object_Context_ID(arg)
end

function Walker_Inv(onoff)
	walker = Find_First_Object("Alien_Walker_Habitat")
	walker.Get_Script().Call_Function("Walker_Set_Invulnerable", onoff)
end


function Walker_Death(source)
	MessageBox("Walker: %s is dead!", tostring(source))
end

function test_reg()
	walker = Find_First_Object("Alien_Walker_Habitat")
	walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Walker_Death")
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

