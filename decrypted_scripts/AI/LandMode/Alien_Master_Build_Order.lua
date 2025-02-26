if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[115] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Alien_Master_Build_Order.lua#17 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Alien_Master_Build_Order.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #17 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGCommands")
require("PGAIBuildOrder")
ScriptShouldCRC = true

---------------------- Script Globals ----------------------

-- All "moves" follow the same format:
-- Table containing two named entries:
-- "Options": Table containing a number of named parameters that guide the code when executing this move.
-- "BuildOrder": Table containing sub-tables that each define an ObjectType to create, how many of that
-- type should be maintained at the same time, and whether the thread should exit when it reaches the
-- target number.
local STANDARD_LOW_CASH_START = {}
local STANDARD_INVASION_MOVE = {}
local STANDARD_OPENING_MOVES = {}
local STANDARD_MIDGAME_MOVES = {}
local STANDARD_MIDGAME_MOVES_01 = {}
local STANDARD_MIDGAME_MOVES_02 = {}
local STANDARD_ENDGAME_MOVES = {}
local STANDARD_FINISHGAME_MOVES = {}
local STANDARD_FAST_OPENING_MOVES = {}

function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIBuildOrder.txt"

	STANDARD_LOW_CASH_START = {
		Options = { DurationMin=60.0, DurationMax=60.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=1, ExitThread=false },
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=2, ExitThread=false },
		}
	}

	STANDARD_INVASION_MOVE = {
		Options = { DurationMin=60.0, DurationMax=60.0, KillThreadsWhenDone=true },
		BuildOrder =
		{
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
		}
	}

	STANDARD_OPENING_MOVES = {
		Options = { DurationMin=80.0, DurationMax=80.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=3, ExitThread=false },
		}
	}

	STANDARD_FAST_OPENING_MOVES = {
		Options = { DurationMin=90.0, DurationMax=90.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=4, ExitThread=false },
			{ Type="Alien_Hero_Kamal_Rex",					Count=1, ExitThread=false },
			{ Type="Alien_Hero_Orlok",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Nufai",							Count=1, ExitThread=false },
			{ Type="Alien_Scan_Drone",							Count=1, ExitThread=false },
			{ Type="Alien_Grunt",								Count=2, ExitThread=false },
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
		}
	}
	
	STANDARD_MIDGAME_MOVES = {
		Options = { DurationMin=50, DurationMax=50, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=5, ExitThread=false },
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
			{ Type="Alien_Scan_Drone",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Kamal_Rex",					Count=1, ExitThread=false },
			{ Type="Alien_Hero_Orlok",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Nufai",							Count=1, ExitThread=false },
			{ Type="Alien_Grunt",								Count=4, ExitThread=false },
		}
	}

	STANDARD_MIDGAME_MOVES_01 = {
		Options = { DurationMin=40, DurationMax=40, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=5, ExitThread=false },
			{ Type="Alien_Walker_Assembly",					Count=1, ExitThread=false },
			{ Type="Alien_Scan_Drone",							Count=1, ExitThread=false },
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
			{ Type="Alien_Grunt",								Count=8, ExitThread=false },
			{ Type="Alien_Hero_Kamal_Rex",					Count=1, ExitThread=false },
			{ Type="Alien_Hero_Orlok",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Nufai",							Count=1, ExitThread=false },
		}
	}

	STANDARD_MIDGAME_MOVES_02 =
	{
		Options = { DurationMin=60, DurationMax=70, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },	--2
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=5, ExitThread=false },
			{ Type="Alien_Walker_Assembly",					Count=1, ExitThread=false },
			{ Type="Alien_Scan_Drone",							Count=1, ExitThread=false },
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
			{ Type="Alien_Walker_Science",					Count=1, ExitThread=false },
			{ Type="Alien_Foo_Core",							Count=3, ExitThread=false },
			{ Type="Alien_Grunt",								Count=10, ExitThread=false },
			{ Type="Alien_Lost_One",							Count=4, ExitThread=false },
			{ Type="Alien_Cylinder",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Kamal_Rex",					Count=1, ExitThread=false },
			{ Type="Alien_Hero_Orlok",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Nufai",							Count=1, ExitThread=false },
			{ Type="Alien_Brute",								Count=3, ExitThread=false },
		}
	}
	
	STANDARD_ENDGAME_MOVES = {
		Options = { DurationMin=120.0, DurationMax=120.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=5, ExitThread=false },
			{ Type="Alien_Grunt",								Count=10, ExitThread=false },
			{ Type="Alien_Recon_Tank",							Count=6, ExitThread=false },
			{ Type="Alien_Brute",								Count=4, ExitThread=false },
			{ Type="Alien_Lost_One",							Count=4, ExitThread=false },
			{ Type="Alien_Cylinder",							Count=1, ExitThread=false },
			{ Type="Alien_Foo_Core",							Count=5, ExitThread=false },
			{ Type="Alien_Walker_Assembly",					Count=1, ExitThread=false },
			{ Type="Alien_Walker_Science",					Count=1, ExitThread=false },
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
			{ Type="Alien_Superweapon_Mass_Drop",			Count=1, ExitThread=false },
			{ Type="Alien_Hero_Kamal_Rex",					Count=1, ExitThread=false },
			{ Type="Alien_Hero_Orlok",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Nufai",							Count=1, ExitThread=false },
			{ Type="Alien_Scan_Drone",							Count=1, ExitThread=false },
		}
	}

	STANDARD_FINISHGAME_MOVES =
	{
		Options = { DurationMin=120.0, DurationMax=120.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=false },	--2
			{ Type="Alien_Superweapon_Reaper_Turret",		Count=5, ExitThread=false },	-- 8 (10)
			{ Type="Alien_Grunt",								Count=10, ExitThread=false },	-- 2-4 (14)
			{ Type="Alien_Recon_Tank",							Count=6, ExitThread=false },	-- 3 15 (29)
			{ Type="Alien_Lost_One",							Count=4, ExitThread=false },	-- 8 8 (37)
			{ Type="Alien_Brute",								Count=4, ExitThread=false },	-- 5 15 (52)
			{ Type="Alien_Cylinder",							Count=1, ExitThread=false },	-- 2 (58)
			{ Type="Alien_Foo_Core",							Count=5, ExitThread=false },	-- 2 8 (64)
			{ Type="Alien_Walker_Assembly",					Count=1, ExitThread=false },	
			{ Type="Alien_Walker_Science",					Count=1, ExitThread=false },
			{ Type="Alien_Walker_Habitat",					Count=1, ExitThread=false },
			{ Type="Alien_Superweapon_Mass_Drop",			Count=1, ExitThread=false },
			{ Type="Alien_Hero_Kamal_Rex",					Count=1, ExitThread=false },
			{ Type="Alien_Hero_Orlok",							Count=1, ExitThread=false },
			{ Type="Alien_Hero_Nufai",							Count=1, ExitThread=false },
			{ Type="Alien_Scan_Drone",							Count=2, ExitThread=false },
		}
	}
	
end


---------------------- Goal Events and Queries ----------------------


function Compute_Desire()

	if Player.Get_Player_Is_Crippled() then
		return -2.0
	end

	if Target then
		--Goal.Suppress_Goal()
		return -1.0
	end

	if not Is_Player_Of_Faction(Player, "ALIEN") and not Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		--Goal.Suppress_Goal()
		return -2.0
	end
	
	return 1.0

end


function Score_Unit(unit)
	return 0
end


function On_Activate()
	ResearchSleepTime = nil
	Create_Thread("Spawn_Sub_Goals")
	Create_Thread("Alien_Research")
end


function Spawn_Sub_Goals()

	Check_For_Invasion()
	Check_For_Low_Cash()
	Check_For_Hi_Cash()

	-- test 
	
	local tm = GetCurrentTime()
	Execute_Build_Order(STANDARD_OPENING_MOVES)
	local tm1 = GetCurrentTime()
	Execute_Build_Order(STANDARD_MIDGAME_MOVES)
	local tm2 = GetCurrentTime()
	Execute_Build_Order(STANDARD_MIDGAME_MOVES_01)
	local tm3 = GetCurrentTime()
	Execute_Build_Order(STANDARD_MIDGAME_MOVES_02)
	Execute_Build_Order(STANDARD_ENDGAME_MOVES)

	while true do
		Execute_Build_Order(STANDARD_FINISHGAME_MOVES)
		Sleep(1)
	end
end

-- ----------------------------------------------------------------
-- Do_Research: figure out and start research
-- ----------------------------------------------------------------
function Do_Research(player_script)

	local research_node_data
	local suites = {"A","C","B"}
	
	-- start researching
	for index = 1,2 do
		for suite_idx = 1,3 do
			research_node_data = player_script.Call_Function("Retrieve_Node_Data", suites[suite_idx], index)
			if research_node_data and not research_node_data.Completed and research_node_data.Enabled then
				return Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {suites[suite_idx], index})
			end
		end
	end
	
	return nil
	
end
-- ----------------------------------------------------------------
-- Alien_Research: Manage all alien research
-- ----------------------------------------------------------------
function Alien_Research()

	local research_block = nil
	local def_con = false

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then
		return
	end
	
	-- Is DEFCON enabled from the lobby?
	local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
	if script_data and script_data.is_defcon_game then
		def_con = true
	end

	local player_script = Player.Get_Script()
	
	if player_script == nil then
		ScriptExit()
	end
	
	-- during an invasion wait for a while
	while ResearchSleepTime == nil do
		Sleep(1.0)
	end
	
	Sleep(ResearchSleepTime)
	
	while true do
	
		-- check to see if we need to do research
		if not def_con and Player.Get_Credits() > 3500.0 and ( research_block ==nil or research_block.IsFinished() ) then
		
			if research_block and research_block.IsFinished() then
				research_block = nil
			end
			
			research_block = Do_Research(player_script)
			
		end
	
		Sleep(5.0)
	
	end
	
end

function Check_For_Invasion()

	local obj_list = Find_All_Objects_Of_Type( Player )
	Sleep(0.1)

	for _,unit in pairs(obj_list) do
		
		if TestValid( unit ) and unit.Get_Owner() == Player then
			local type = unit.Get_Type()
			if TestValid(type) and type.Get_Type_Value("Is_Command_Center") then
				ResearchSleepTime = 1.0
				return
			end
		end
		
	end
	
	ResearchSleepTime = 150.0
	
	Execute_Build_Order(STANDARD_INVASION_MOVE)

end

function Check_For_Low_Cash()

	if Player.Get_Credits() < 10000.0 then
		Execute_Build_Order(STANDARD_LOW_CASH_START)
	end
	
end

function Check_For_Hi_Cash()

	if Player.Get_Credits() > 18000.0 then
			Execute_Build_Order(STANDARD_FAST_OPENING_MOVES)
			Execute_Build_Order(STANDARD_FINISHGAME_MOVES)

		while true do
			Execute_Build_Order(STANDARD_FINISHGAME_MOVES)
			Sleep(1)
		end
	end
	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
