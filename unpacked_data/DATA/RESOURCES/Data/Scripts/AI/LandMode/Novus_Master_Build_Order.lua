-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Master_Build_Order.lua#23 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Master_Build_Order.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 79622 $
--
--          $DateTime: 2007/08/02 17:02:29 $
--
--          $Revision: #23 $
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

	STANDARD_OPENING_MOVES_TEST = {
		Options = { DurationMin=10.0, DurationMax=10.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=2, ExitThread=true },
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Input_Station",						Count=4, ExitThread=false },
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
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },
			{ Type="Novus_Corruptor",							Count=2, ExitThread=false },	-- 4 16
			{ Type="Novus_Antimatter_Tank",					Count=13, ExitThread=false },	--(12) 46

		}
	}

	STANDARD_FASTSTART_MOVE = {
		Options = { DurationMin=100.0, DurationMax=100.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=3, ExitThread=false },
			{ Type="Novus_Constructor",						Count=2, ExitThread=false },	-- 6 
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=12, ExitThread=false },	-- 6 12
			{ Type="Novus_Input_Station",						Count=4, ExitThread=false },
			{ Type="Novus_Corruptor",							Count=1, ExitThread=false },	-- 4 16
		}
	}

	STANDARD_OPENING_MOVES_02 = {
		Options = { DurationMin=30.0, DurationMax=30.0, KillThreadsWhenDone=true },
		BuildOrder = {
			{ Type="Novus_Remote_Terminal",					Count=1, ExitThread=false },
			{ Type="Novus_Constructor",						Count=3, ExitThread=true },	--6
			{ Type="Novus_Power_Router",						Count=1, ExitThread=false },
			{ Type="Novus_Robotic_Infantry",					Count=8, ExitThread=false },	-- 8 14
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },
			{ Type="Novus_Corruptor",							Count=1, ExitThread=false },	-- 8 22
			{ Type="Novus_Hero_Mech",							Count=1, ExitThread=false },
			{ Type="Novus_Antimatter_Tank",					Count=13, ExitThread=false },	--(12) 46

		}
	}
	
	STANDARD_MIDGAME_MOVES = {
		Options = { DurationMin=90.0*1.0, DurationMax=100.0*1.2, KillThreadsWhenDone=true },	-- all of our unit counts are replaced by the endgame block
		BuildOrder = {
			{ Type="Novus_Corruptor",							Count=4, ExitThread=false },	--8
			{ Type="Novus_Constructor",						Count=3, ExitThread=false },	--6  14
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },	
			{ Type="Novus_Robotic_Infantry",					Count=15,ExitThread=false },	-- 16 30
			{ Type="Novus_Variant",								Count=1, ExitThread=false },	-- 4 34
			{ Type="Novus_Antimatter_Tank",					Count=13, ExitThread=false },	--(12) 46
			{ Type="Novus_Dervish_Jet",						Count=2, ExitThread=false },	--(24) 70
			{ Type="Novus_Power_Router",						Count=2, ExitThread=false },
			{ Type="Novus_Hero_Mech",							Count=1, ExitThread=false },
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
			{ Type="Novus_Dervish_Jet",						Count=4, ExitThread=false },	--(30) 70
			{ Type="Novus_Field_Inverter",					Count=13, ExitThread=false },	--(12) 82
			{ Type="Novus_Variant",								Count=1, ExitThread=false },	--(2) 84
			{ Type="Novus_Input_Station",						Count=5, ExitThread=false },
			{ Type="Novus_Reflex_Trooper",					Count=2, ExitThread=false },	--(9) 93
			{ Type="Novus_Hero_Vertigo",						Count=1, ExitThread=false },
			{ Type="Novus_Hero_Mech",							Count=1, ExitThread=false },
			{ Type="Novus_Superweapon_Gravity_Bomb",		Count=1, ExitThread=false },
			{ Type="Novus_Superweapon_EMP",					Count=1, ExitThread=false },
		}
	}
end



---------------------- Goal Events and Queries ----------------------


function Compute_Desire()
	if Target then
		Goal.Suppress_Goal()
		return 0.0
	end

	if not Is_Player_Of_Faction(Player, "NOVUS") then
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
	Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 1})
	Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 2})
	while true do
		Execute_Build_Order(STANDARD_OPENING_MOVES_02)
		if Player.Get_Credits() > 5000.0 then
			break
		end
	end
	Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"C", 1})	
	Execute_Build_Order(STANDARD_ENDGAME_MOVES)
	Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 3})
	Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"C", 2})	
	Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 4})

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
				return
			end
		end
		
	end
	
	Execute_Build_Order(STANDARD_INVASION_MOVE)

end

function Check_For_Low_Cash()

	if Player.Get_Credits() < 8000.0 then
		Execute_Build_Order(STANDARD_LOW_CASH_START)
	end
	
end

function Check_For_Hi_Cash()

	if Player.Get_Credits() > 18000.0 then
			Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 1})
			Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"C", 1})
			Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 2})
			Execute_Build_Order(STANDARD_FASTSTART_MOVE)
			Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 3})
			Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"B", 4})
			Execute_Build_Order(STANDARD_ENDGAME_MOVES)
			Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {"C", 2})

		while true do
			Execute_Build_Order(STANDARD_ENDGAME_MOVES)
			Sleep(1)
		end
	end
	
end