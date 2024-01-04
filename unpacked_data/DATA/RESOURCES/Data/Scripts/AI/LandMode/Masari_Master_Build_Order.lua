-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Masari_Master_Build_Order.lua#16 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Masari_Master_Build_Order.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 87963 $
--
--          $DateTime: 2007/11/15 17:33:46 $
--
--          $Revision: #16 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGCommands")
require("PGAIBuildOrder")
require("PGBase")
require("PGUICommands")

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
local STANDARD_OPENING_MOVES_00 = {}
local STANDARD_OPENING_MOVES = {}
local STANDARD_OPENING_MOVES_01 = {}
local STANDARD_MIDGAME_MOVES = {}
local STANDARD_ENDGAME_MOVES = {}
local STANDARD_FINISHGAME_MOVES = {}
local STANDARD_MIDGAME_MOVES_DARK = {}
local STANDARD_ENDGAME_MOVES_DARK = {}
local STANDARD_FINISHGAME_MOVES_DARK = {}
local STANDARD_OPENING_FAST_START = {}

function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIBuildOrder.txt"

	STANDARD_LOW_CASH_START = {
		Options = { DurationMin=30.0, DurationMax=30.0, KillThreadsWhenDone=true },
		BuildOrder =
		{
			{ Type="Masari_Foundation",						Count=1, ExitThread=false },
			{ Type="Masari_Architect",							Count=3, ExitThread=false },	--14
		}
	}

	STANDARD_INVASION_MOVE = {
		Options = { DurationMin=140.0, DurationMax=140.0, KillThreadsWhenDone=true },
		BuildOrder =
		{
			{ Type="Masari_Foundation",						Count=1, ExitThread=false },
		}
	}

	STANDARD_OPENING_MOVES_00 = {
		Options = { DurationMin=70.0, DurationMax=80.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	--14
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=4, ExitThread=false },	--12 26
		}
	}

	STANDARD_OPENING_MOVES = {
		Options = { DurationMin=70.0, DurationMax=80.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	--14
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=6, ExitThread=false },	--12 26
		}
	}

	STANDARD_OPENING_MOVES_01 = {
		Options = { DurationMin=45.0, DurationMax=45.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	--16 
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=10, ExitThread=false },	--16 32
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
		}
	}

	STANDARD_OPENING_FAST_START = {
		Options = { DurationMin=180.0, DurationMax=180.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	--16 
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=10, ExitThread=false },	--16 32
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
		}
	}
	
	STANDARD_MIDGAME_MOVES = {
		Options = { DurationMin=90.0*1.0, DurationMax=100.0*1.0, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },--16
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=13, ExitThread=false },--16 32
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Ground_Inspiration",					Count=1, ExitThread=false },
			{ Type="Masari_Air_Inspiration",						Count=1, ExitThread=false },
			{ Type="Masari_Seer",									Count=1, ExitThread=false },
			{ Type="Masari_Seeker",									Count=4, ExitThread=false }, --16 48
			{ Type="Masari_Hero_Charos",							Count=1, ExitThread=false },
			{ Type="Masari_Hero_Zessus",							Count=1, ExitThread=false },
			{ Type="Masari_Sentry",									Count=2, ExitThread=false },--8 56
			{ Type="Masari_Enforcer",								Count=3, ExitThread=false },
			{ Type="Masari_Peacebringer",							Count=1, ExitThread=false },	--8 (8) try to get the knowledge vault upgraded
		}
	}
	
	STANDARD_ENDGAME_MOVES = {
		Options = { DurationMin=90.0*1.0, DurationMax=100.0*1.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	--12
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=13, ExitThread=false },	--16 28
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Ground_Inspiration",					Count=1, ExitThread=false },
			{ Type="Masari_Air_Inspiration",						Count=1, ExitThread=false },
			{ Type="Masari_Seer",									Count=1, ExitThread=false },
			{ Type="Masari_Seeker",									Count=4, ExitThread=false },	--24 52 
			{ Type="Masari_Sentry",									Count=2, ExitThread=false },	--16 82
			{ Type="Masari_Enforcer",								Count=3, ExitThread=false },	--8  90
			{ Type="Masari_Hero_Charos",							Count=1, ExitThread=false },
			{ Type="Masari_Peacebringer",							Count=2, ExitThread=false },	--8 (8) - 
			{ Type="Masari_Hero_Zessus",							Count=1, ExitThread=false },
		}
	}

	STANDARD_FINISHGAME_MOVES =
	{
		Options = { DurationMin=60.0*1.0, DurationMax=60.0*1.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false }, -- 3 (18) -- 18
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=13, ExitThread=false },	-- 2 (26) 
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Ground_Inspiration",					Count=1, ExitThread=false },
			{ Type="Masari_Air_Inspiration",						Count=1, ExitThread=false },
			{ Type="Masari_Seeker",									Count=4, ExitThread=false },	-- 4 (24) -
			{ Type="Masari_Seer",									Count=1, ExitThread=false },
			{ Type="Masari_Elemental_Controller",				Count=1, ExitThread=false },
			{ Type="Masari_Sentry",									Count=2, ExitThread=false },	-- 4 (8) -
			{ Type="Masari_Enforcer",								Count=3, ExitThread=false },	-- 5 (15) - 
			{ Type="Masari_Skylord",								Count=1, ExitThread=false },	--8 (8) -
			{ Type="Masari_Peacebringer",							Count=3, ExitThread=false },	--8 (8) - 
			{ Type="Masari_Hero_Charos",							Count=1, ExitThread=false },
			{ Type="Masari_Hero_Zessus",							Count=1, ExitThread=false },
		}
	}

	STANDARD_MIDGAME_MOVES_DARK = {
		Options = { DurationMin=90.0*1.0, DurationMax=100.0*1.0, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=12, ExitThread=false },
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Ground_Inspiration",					Count=1, ExitThread=false },
			{ Type="Masari_Air_Inspiration",						Count=1, ExitThread=false },
			{ Type="Masari_Seeker",									Count=2, ExitThread=false },
			{ Type="Masari_Sentry",									Count=2, ExitThread=false },
			{ Type="Masari_Enforcer",								Count=3, ExitThread=false },
		}
	}
	
	STANDARD_ENDGAME_MOVES_DARK = {
		Options = { DurationMin=90.0*1.0, DurationMax=100.0*1.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	--12
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=12, ExitThread=false },	--16 28
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Ground_Inspiration",					Count=1, ExitThread=false },
			{ Type="Masari_Air_Inspiration",						Count=1, ExitThread=false },
			{ Type="Masari_Seeker",									Count=2, ExitThread=false },	--24 52 
			{ Type="Masari_Sentry",									Count=2, ExitThread=false },	--16 82
			{ Type="Masari_Enforcer",								Count=3, ExitThread=false },	--8  90
			{ Type="Masari_Peacebringer",							Count=1, ExitThread=false },
		}
	}

	STANDARD_FINISHGAME_MOVES_DARK =
	{
		Options = { DurationMin=60.0*1.0, DurationMax=60.0*1.0, KillThreadsWhenDone=true },	-- atrophy and die after endgame has expired
		BuildOrder = {
			{ Type="Masari_Architect",								Count=6, ExitThread=false },	-- 18
			{ Type="Masari_Foundation",							Count=1, ExitThread=false },
			{ Type="Masari_Infantry_Inspiration",				Count=1, ExitThread=false },
			{ Type="Masari_Natural_Interpreter",				Count=1, ExitThread=false },
			{ Type="Masari_Disciple",								Count=12, ExitThread=false },
			{ Type="Masari_Inventors_Lab",						Count=1, ExitThread=false },
			{ Type="Masari_Ground_Inspiration",					Count=1, ExitThread=false },
			{ Type="Masari_Air_Inspiration",						Count=1, ExitThread=false },
			{ Type="Masari_Seeker",									Count=2, ExitThread=false },-- 8
			{ Type="Masari_Elemental_Controller",				Count=1, ExitThread=false },	
			{ Type="Masari_Sentry",									Count=2, ExitThread=false },	-- 8
			{ Type="Masari_Enforcer",								Count=3, ExitThread=false },	-- 15
			{ Type="Masari_Skylord",								Count=1, ExitThread=false },	-- 8
			{ Type="Masari_Peacebringer",							Count=1, ExitThread=false },	-- 8
		}
	}
	
end


---------------------- Goal Events and Queries ----------------------


function Compute_Desire()

	if Target then
		Goal.Suppress_Goal()
		return 0.0
	end

	if not Is_Player_Of_Faction(Player, "Masari")  then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	return 1.0

end


function Score_Unit(unit)
	return 0
end


function On_Activate()
	Create_Thread("Spawn_Sub_Goals")
	Create_Thread("Masari_Research_And_Mode")
end

-- ----------------------------------------------------------------
-- Clear_Research_For: clear out nodes so we can research this suite and index
-- ----------------------------------------------------------------

function Clear_Research_For(player_script, suite, index)

	local research_node_data = player_script.Call_Function("Retrieve_Node_Data", suite, index)
	
	if research_node_data and research_node_data.Enabled then
		return true
	end
	
	-- start disabling other suites
	local suites = {"A", "B", "C"}
	
	for s_idx = 1, 3 do
		if suites[s_idx] ~= suite then
			for level = 4, 1, -1 do
				research_node_data = player_script.Call_Function("Retrieve_Node_Data", suites[s_idx], level)
				if research_node_data.Completed then
					Send_GUI_Network_Event("Network_Cancel_Research", {Player, suites[s_idx], level })
					return false
				end
			end
		end
	end
	
	return false
	
end

-- ----------------------------------------------------------------
-- Do_Research: figure out and start research
-- ----------------------------------------------------------------
function Do_Research(player_script, light_mode)

	local suite = "A"
	if not light_mode then
		suite = "B"
	end
	
	local research_node_data = player_script.Call_Function("Retrieve_Node_Data", suite, 1)
	
	if not research_node_data then
		return nil
	end
	
	if not research_node_data.Completed then
		if Clear_Research_For(player_script, suite, 1) then
			return Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {suite, 1})
		end
	end
	
	-- basic research done, check for balance
	for index = 1,2 do

		research_node_data = player_script.Call_Function("Retrieve_Node_Data", "C", index)
		
		if research_node_data and not research_node_data.Completed and research_node_data.Enabled then
			return Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"C", index})
		end
		
	end
	
	-- start researching our main line
	for index = 2,4 do
		research_node_data = player_script.Call_Function("Retrieve_Node_Data", suite, index)
		if research_node_data and not research_node_data.Completed and Clear_Research_For(player_script, suite, index) then
			return Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {suite, index})
		end
	end
	
	return nil
	
end
-- ----------------------------------------------------------------
-- Masari_Research_And_Mode: Manages all Masari research and mode switches
-- ----------------------------------------------------------------
function Masari_Research_And_Mode()

	local light_mode = true
	local light_mode_string = "Fire"
	local dark_mode_string = "Ice"
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
	
	local start_time_in_mode = GetCurrentTime()

	if GameRandom(1,100) < 50 then
		light_mode = false
	end
	
	while true do
	
		-- check to see if we should switch modes
		local sw_time = player_script.Call_Function("SW_Get_Cooldown_Time",nil)
		
		if not sw_time or sw_time < 0.0 or sw_time > 150.0 then
			-- we can change modes as the sw is not ready 
			if GetCurrentTime() - start_time_in_mode > 50.0 and Player.Get_Credits() > 350.0 and GameRandom(1,100) < 8 then
				if light_mode then
					light_mode = false
				else
					light_mode = true
				end
			end
		end

		local cur_mode = Player.Get_Elemental_Mode()
		
		if not light_mode and cur_mode == light_mode_string then
			Player.Set_Elemental_Mode(dark_mode_string)
			start_time_in_mode = GetCurrentTime()
		elseif light_mode and cur_mode == dark_mode_string then
			Player.Set_Elemental_Mode(light_mode_string)
			start_time_in_mode = GetCurrentTime()
		end
		
		-- check to see if we need to do research
		if not def_con and Player.Get_Credits() > 350.0 and ( research_block ==nil or research_block.IsFinished() ) then
		
			if research_block and research_block.IsFinished() then
				research_block = nil
			end
			
			research_block = Do_Research(player_script, light_mode)
			
		end
	
		Sleep(5.0)
	
	end
	
end


function Spawn_Sub_Goals()

	Player.Set_Preferred_Base_Layout("Masari_Base_Default")
	
	local light_mode = true
	
	Check_For_Invasion()
	Check_For_Low_Cash()
	Check_For_Hi_Cash(light_mode)
	
	Execute_Build_Order(STANDARD_OPENING_MOVES_00)
	
	Execute_Build_Order(STANDARD_OPENING_MOVES)
	
	Execute_Build_Order(STANDARD_OPENING_MOVES_01)
	
	if light_mode then
		Execute_Build_Order(STANDARD_MIDGAME_MOVES)
	else
		Execute_Build_Order(STANDARD_MIDGAME_MOVES_DARK)
	end
	
	if light_mode then
		Execute_Build_Order(STANDARD_ENDGAME_MOVES)
	else
		Execute_Build_Order(STANDARD_ENDGAME_MOVES_DARK)
	end	

	while true do
		if light_mode then
			Execute_Build_Order(STANDARD_FINISHGAME_MOVES)
		else
			Execute_Build_Order(STANDARD_FINISHGAME_MOVES_DARK)
		end
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
				return
			end
		end
		
	end
	
	Execute_Build_Order(STANDARD_INVASION_MOVE)

end

function Check_For_Low_Cash()

	if Player.Get_Credits() < 800.0 then
		Execute_Build_Order(STANDARD_LOW_CASH_START)
	end
	
end

function Check_For_Hi_Cash(light_mode)

	if Player.Get_Credits() > 1800.0 then
		if light_mode then
			Execute_Build_Order(STANDARD_OPENING_FAST_START)
			Execute_Build_Order(STANDARD_FINISHGAME_MOVES)
		else
			Execute_Build_Order(STANDARD_OPENING_FAST_START)
			Execute_Build_Order(STANDARD_FINISHGAME_MOVES_DARK)
		end

		while true do
			if light_mode then
				Execute_Build_Order(STANDARD_FINISHGAME_MOVES)
			else
				Execute_Build_Order(STANDARD_FINISHGAME_MOVES_DARK)
			end
			Sleep(1)
		end
	end
	
end