-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Alien_Monolith_Scout.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Alien_Monolith_Scout.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 79681 $
--
--          $DateTime: 2007/08/03 10:34:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGLogging")

ScriptShouldCRC = true


---------------------- Script Globals ----------------------

local USERDATA_STR = ""			-- filled in during On_Activate()

function Definitions()
	USERDATA_STR = ""
	
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIScoutLog.txt"
end

local ReturnToBaseObject = nil

---------------------- Goal Events and Queries ----------------------

function Compute_Desire()
	-- If we were not given any UserData then we won't run. We should only be
	-- run as a sub-goal of Alien_Scout_Controller.
	if not Goal.Get_User_Data() then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	-- We must have been given a target when were were created!
	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	-- We must be running for the Alien AI player.
	if not Is_Player_Of_Faction(Player, "ALIEN") and not Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	return 1.0
end


function Score_Unit(unit)

	if unit.Has_Behavior(BEHAVIOR_GARRISONABLE) or unit.Get_Garrison() ~= nil then
		return 0.0
	end

	-- Get the unit's object type.
	local unit_type = unit.Get_Type()
	if not unit_type then
		return 0.0
	end

	-- this is who we return to
	if unit_type.Get_Type_Value("Is_Command_Center") then
		ReturnToBaseObject = unit
	end

	-- We only want Alien Monoliths.
	if unit_type.Get_Name() ~= "ALIEN_CYLINDER" then
		return 0.0
	end
	
	-- If we don't have any units yet, claim the first one we can get.
	local taskforce = Goal.Get_Task_Force()
	if not taskforce then
		return 1.0
	end

	-- If we already have a claimed unit or a potential unit, we don't want any others.
	local total_units = #taskforce.Get_Potential_Unit_Table() + #taskforce.Get_Unit_Table()
	if total_units >= 1.0 then
		return 0.0
	end

	return 1.0

end


function On_Activate()
	USERDATA_STR = tostring(Goal.Get_User_Data())
	log("Alien_Monolith_Scout(%s) activated!", USERDATA_STR)
end


function Service()
	-- Need to have a task force before we start deciding to claim units.
	-- A task force is created when the first unit is offered to us as a
	-- potential unit.
	local task_force = Goal.Get_Task_Force()
	if not task_force then
		return
	end

	-- Get the current set of potential units.
	local potential_units = task_force.Get_Potential_Unit_Table()
	if #potential_units >= 1.0 then
		
		for _,v in pairs(potential_units) do
			log("Alien_Monolith_Scout(%s) claiming unit: %s", USERDATA_STR, tostring(v))
		end
		
		-- Claim them and issue the scouting orders.
		Goal.Claim_Units("Scout_Thread")
		
	end
end


function Scout_Thread(scout_tf)
	local scout_target = Target
	--log("Alien_Monolith_Scout(%s): Attack_Move(%s) order initiated!", USERDATA_STR, Describe_Target(scout_target))
	BlockOnCommand(scout_tf.Attack_Move(scout_target))
	
	local wait_time = GameRandom(15.0, 30.0) + GetCurrentTime()

	while GetCurrentTime() < wait_time do
		if Stop_Scouting() then
			scout_tf.Move_To( ReturnToBaseObject )
			break
		end
		Sleep(2.0)
	end

	Sleep(1.0)
	
	--log("Alien_Monolith_Scout(%s): Scouting of %s complete.", USERDATA_STR, Describe_Target(scout_target))
	ScriptExit()
end

function Stop_Scouting()

	local task_force = Goal.Get_Task_Force()
	if not task_force then
		return true
	end
	
	if stop_scouting then
		return true
	end
	
	local unit_list = task_force.Get_Unit_Table()
	
	if not unit_list or #unit_list < 1 then
		return true
	end
	
	for _,unit in pairs(unit_list) do
		if not TestValid( unit ) or unit.Get_Health() < 0.70 then
			return true
		end
	end

	return false
		
end
