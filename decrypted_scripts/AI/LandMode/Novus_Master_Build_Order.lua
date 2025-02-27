if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[115] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Novus_Master_Build_Order.lua#16 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Novus_Master_Build_Order.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #16 $
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
local STANDARD_INVASION_MOVE_01 = {}
local STANDARD_OPENING_MOVES_TEST = {}
local STANDARD_OPENING_MOVES = {}
local STANDARD_OPENING_MOVES_01 = {}
local STANDARD_OPENING_MOVES_02 = {}
local STANDARD_MIDGAME_MOVES = {}
local STANDARD_ENDGAME_MOVES = {}
local STANDARD_FASTSTART_MOVE = {}

function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIBuildOrder.txt"

	STANDARD_LOW_CASH_START = {
		Options = { DurationMin=45.0, DurationMax=45.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=2, ExitThread=true },
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Input_Station",						Count=2, ExitThread=false },
		}
	}

	STANDARD_INVASION_MOVE = {
		Options = { DurationMin=80.0, DurationMax=80.0, KillThreadsWhenDone=true },
		BuildOrder =
		{
			{ Type="Novus_Remote_Terminal",						Count=1, ExitThread=false },
		}
	}

	STANDARD_INVASION_MOVE_01 = {
		Options = { DurationMin=80.0, DurationMax=80.0, KillThreadsWhenDone=true },
		BuildOrder =
		{
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Input_Station",						Count=2, ExitThread=false },
		}
	}

	STANDARD_OPENING_MOVES_TEST = {
		Options = { DurationMin=10.0, DurationMax=10.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=2, ExitThread=true },
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },
		}
	}

	STANDARD_OPENING_MOVES = {
		Options = { DurationMin=90.0, DurationMax=90.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=2, ExitThread=true },
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Input_Station",						Count=4, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=8, ExitThread=false },	-- 6 12
		}
	}

	STANDARD_OPENING_MOVES_01 = {
		Options = { DurationMin=50.0, DurationMax=50.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=3, ExitThread=false },	-- 6 
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=12, ExitThread=false },	-- 6 12
			{ Type="Novus_Input_Station",						Count=4, ExitThread=false },
			{ Type="Novus_Corruptor",							Count=2, ExitThread=false },	-- 4 16
		}
	}

	STANDARD_FASTSTART_MOVE = {
		Options = { DurationMin=100.0, DurationMax=100.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=3, ExitThread=false },	-- 6 
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=12, ExitThread=false },	-- 6 12
			{ Type="Novus_Input_Station",						Count=4, ExitThread=false },
			{ Type="Novus_Corruptor",							Count=2, ExitThread=false },	-- 4 16
		}
	}

	STANDARD_OPENING_MOVES_02 = {
		Options = { DurationMin=30.0, DurationMax=30.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=3, ExitThread=true },	--6
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=15, ExitThread=false },	-- 8 14
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },
			{ Type="Novus_Corruptor",							Count=4, ExitThread=false },	-- 8 22
			{ Type="Novus_Hero_Mech",							Count=1, ExitThread=false },
		}
	}
	
	STANDARD_MIDGAME_MOVES = {
		Options = { DurationMin=90.0*1.0, DurationMax=100.0*1.2, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Novus_Corruptor",							Count=4, ExitThread=false },	--8
			{ Type="Novus_Constructor",						Count=3, ExitThread=false },	--6  14
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },	
			{ Type="Novus_Robotic_Infantry",					Count=15,ExitThread=false },	-- 16 30
			{ Type="Novus_Variant",								Count=2, ExitThread=false },	-- 4 34
			{ Type="Novus_Antimatter_Tank",					Count=3, ExitThread=false },	--(12) 46
			{ Type="Novus_Dervish_Jet",						Count=4, ExitThread=false },	--(24) 70
			{ Type="Novus_Power_Router",						Count=2, ExitThread=false },
			{ Type="Novus_Hero_Mech",							Count=1, ExitThread=false },
			{ Type="Novus_Hacker",								Count=1, ExitThread=false },	
		}
	}
	
	STANDARD_ENDGAME_MOVES = {
		Options = { DurationMin=60.0*2.0, DurationMax=60.0*3.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Novus_Power_Router",						Count=2, ExitThread=false },
			{ Type="Novus_Constructor",						Count=3, ExitThread=false },	-- 6
			{ Type="Novus_Science_Lab",						Count=1, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=12, ExitThread=false},	-- 12 18
			{ Type="Novus_Antimatter_Tank",					Count=3, ExitThread=false },	--(8) 26
			{ Type="Novus_Corruptor",							Count=4, ExitThread=false },	--(10) 40
			{ Type="Novus_Dervish_Jet",						Count=6, ExitThread=false },	--(30) 70
			{ Type="Novus_Field_Inverter",					Count=4, ExitThread=false },	--(12) 82
			{ Type="Novus_Variant",								Count=2, ExitThread=false },	--(2) 84
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },
			{ Type="Novus_Reflex_Trooper",					Count=2, ExitThread=false },	--(9) 93
			{ Type="Novus_Hero_Vertigo",						Count=1, ExitThread=false },
			{ Type="Novus_Hero_Mech",							Count=1, ExitThread=false },
			{ Type="Novus_Superweapon_Gravity_Bomb",		Count=1, ExitThread=false },
			{ Type="Novus_Superweapon_EMP",					Count=1, ExitThread=false },
			{ Type="Novus_Hacker",								Count=1, ExitThread=false },	
		}
	}
end



---------------------- Goal Events and Queries ----------------------


function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "NOVUS") then
		--Goal.Suppress_Goal()
		return -2.0
	end

	if Target then
		--Goal.Suppress_Goal()
		return -1.0
	end

	if Player.Get_Player_Is_Crippled() then
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
	Create_Thread("novus_Research")
end


function Spawn_Sub_Goals()

--	while true do
--		Execute_Build_Order(STANDARD_OPENING_MOVES_TEST)
--		Sleep(1)
--	end

	Check_For_Invasion()
	Check_For_Low_Cash()
	Check_For_Hi_Cash()

	Execute_Build_Order(STANDARD_OPENING_MOVES)
	Execute_Build_Order(STANDARD_OPENING_MOVES_01)
	while true do
		Execute_Build_Order(STANDARD_OPENING_MOVES_02)
		if Player.Get_Credits() > 5000.0 then
			break
		end
	end
	Execute_Build_Order(STANDARD_ENDGAME_MOVES)

	while true do
		Execute_Build_Order(STANDARD_ENDGAME_MOVES)
		Sleep(1)
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
	Execute_Build_Order(STANDARD_INVASION_MOVE_01)

end

function Check_For_Low_Cash()

	if Player.Get_Credits() < 8000.0 then
		Execute_Build_Order(STANDARD_LOW_CASH_START)
	end
	
end

function Check_For_Hi_Cash()

	if Player.Get_Credits() > 18000.0 then
			Execute_Build_Order(STANDARD_FASTSTART_MOVE)
			Execute_Build_Order(STANDARD_ENDGAME_MOVES)

		while true do
			Execute_Build_Order(STANDARD_ENDGAME_MOVES)
			Sleep(1)
		end
	end
	
end

-- ----------------------------------------------------------------
-- Do_Research: figure out and start research
-- ----------------------------------------------------------------
function Do_Research(player_script)

	local research_node_data
	local suites = {"B","C"}
	
	-- start researching
	for index = 1,4 do
		for suite_idx = 1,2 do
			if suite_idx == 1 or index <= 2 then
				research_node_data = player_script.Call_Function("Retrieve_Node_Data", suites[suite_idx], index)
				if research_node_data and not research_node_data.Completed and research_node_data.Enabled then
					return Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {suites[suite_idx], index})
				end
			end
		end
	end
	
	return nil
	
end
-- ----------------------------------------------------------------
-- Novus_Research: Manage all novus research
-- ----------------------------------------------------------------
function novus_Research()

	local research_block = nil
	local def_con = false

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then
		return
	end
	
	-- during an invasion wait for a while
	while ResearchSleepTime == nil do
		Sleep(1.0)
	end
	
	Sleep(ResearchSleepTime)
	
	-- Is DEFCON enabled from the lobby?
	local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
	if script_data and script_data.is_defcon_game then
		def_con = true
	end

	local player_script = Player.Get_Script()
	
	if player_script == nil then
		ScriptExit()
	end
	
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
