-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Defend.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Defend.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: James_Yarrow $
--
--            $Change: 80200 $
--
--          $DateTime: 2007/08/08 11:48:56 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGLogging")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------
USERDATA_STR = ""				-- filled in during On_Activate()
MIN_UNITS_PER_GOAL = 2			-- need at least this many to issue defense orders
MAX_UNITS_PER_GOAL = 12		-- won't claim more than this many for a single mission (NOTE: Can be overridden in On_Activate)
EXIT_COUNTDOWN_ALREADY_STARTED = false		-- gets set to true when we've decided to terminate this goal after a certain amount of time
ReturnToBaseObject = nil

function Definitions()
	USERDATA_STR = ""
	MIN_UNITS_PER_GOAL = 2
	MAX_UNITS_PER_GOAL = 12
	EXIT_COUNTDOWN_ALREADY_STARTED = false
	ReturnToBaseObject = nil

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIDefendLog.txt"
end



---------------------- Goal Events and Queries ----------------------

function Compute_Desire()
	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	-- If our target is an empty object group, give up after 30 seconds.
	local target_type = Target.Get_Target_Type()
	if target_type == "Object_Group" then
		if Target.Get_Group_Target_Size() > 0 then
			last_seen_non_empty_group_time = GetCurrentTime()
		else
			local time_since_last_seen_non_empty = GetCurrentTime() - last_seen_non_empty_group_time
			if time_since_last_seen_non_empty > 30.0 then
				log("Generic_Defend(%s) - Compute_Desire() returning 0.0 because its object group target %s has no more visible members.", USERDATA_STR, Describe_Target(Target))
				return 0.0
			end
		end
	end
	
	
	--log("Generic_Defend(%s) - Compute_Desire() returning 1.0 for %s", USERDATA_STR, Describe_Target(Target))
	-- KDB turning it off as it doesn't really work as well as the Defensive_AI_unit_behavior
	return 0.0
end


function Score_Unit(unit)

	-- We don't want any more units if we've already started a countdown to goal termination.
	if EXIT_COUNTDOWN_ALREADY_STARTED then
		return 0.0
	end
	
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

	local score = unit_type.Get_Type_Value("Attack_Score_Rating")
	if score == nil or score <= 0.0 then
		return 0.0
	end

	-- Need to be mobile to defend the base.
	if not unit.Can_Move() then
		return 0.0
	end
	
	-- We won't use structures for base defense, even mobile ones.
	if unit.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) then
		return 0.0
	end
	
	local taskforce = Goal.Get_Task_Force()
	if not taskforce then
		return 0.1
	end
	
	local total_units = #taskforce.Get_Potential_Unit_Table() + #taskforce.Get_Unit_Table()
	
	-- We don't want any more units for this Goal than MAX_UNITS_PER_GOAL.
	if total_units >= MAX_UNITS_PER_GOAL then
		return 0.0
	end

	-- Prefer to grab units that are closest to the target, but rate every unit
	-- with a very small score to say: "We'll take anything that's idle, but only
	-- if no other goals want it".
	return Get_Distance_Based_Unit_Score(taskforce, unit) * 0.1
end


function On_Activate()
	USERDATA_STR = tostring(Goal.Get_User_Data())
	log("Generic_Defend(%s) activated!", USERDATA_STR)
	
	-- Depending on our target, we may have different MAX_UNITS_PER_GOAL values.
	if Target then
		if Target.Is_Enemy(Player) then
			MAX_UNITS_PER_GOAL = 12					-- Send more units to attack enemy invaders...
		elseif Target.Is_Ally(Player) then
			MAX_UNITS_PER_GOAL = 5					-- ... than we would to defend base structures.
		end
	end
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
	if #potential_units >= MIN_UNITS_PER_GOAL or (#potential_units > 0 and #task_force.Get_Unit_Table() > 0) then
		
		for _,v in pairs(potential_units) do
			log("Generic_Defend(%s) claiming unit: %s", USERDATA_STR, tostring(v))
		end
		
		-- Claim them and issue the attack orders.
		Goal.Claim_Units("Defend_Thread")
		
	end
end


function Defend_Thread(tf)

	if not TestValid(Target) then
		ScriptExit()
	end

	local target_type = Target.Get_Target_Type()
	
	-- Guard_Target on enemy object groups.
	if target_type == "Object_Group" then
		log("Generic_Defend(%s): Guard_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
		BlockOnCommand(tf.Guard_Target(Target))
	elseif target_type == "Game_Object" then
	-- Attack_Target on enemy game objects.
		if Target.Is_Enemy(Player) then
			log("Generic_Defend(%s): Attack_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
			BlockOnCommand(tf.Attack_Target(Target))
	-- Guard_Target on friendly game objects.
		else
			-- Register for movement finished on any object in the defense task force. We will use that event to
			-- start a timer that, once elapsed, will end the Goal. This has the effect of only guarding this
			-- friendly structure for a certain amount of time before the units are released.
			tf.Register_Signal_Handler(Friendly_Structure_Defense_Movement_Finished, "OBJECT_MOVEMENT_FINISHED")

			-- Issue the guard command.
			log("Generic_Defend(%s): Guard_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
			BlockOnCommand(tf.Guard_Target(Target))
		end
	else
		log("Generic_Defend(%s): ERROR! Unhandled target type %s.", USERDATA_STR, Describe_Target(Target))
		ScriptExit()
	end
	
	if TestValid(ReturnToBaseObject) then
		log("Generic_Defend(%s): Retreat to %s ordered!", USERDATA_STR, ReturnToBaseObject.Get_Type().Get_Name())
		BlockOnCommand(tf.Attack_Move(ReturnToBaseObject), 120.0, Back_To_Base )
	end
	
	log("Generic_Defend(%s): Defense action complete.", USERDATA_STR)
	ScriptExit()
end

function Back_To_Base()

	local task_force = Goal.Get_Task_Force()
	
	if not task_force then
		return true
	end

	local unit_list = task_force.Get_Unit_Table()
	
	if not unit_list or #unit_list < 1 then
		return true
	end

	local position = task_force.Get_Centroid()
	if ReturnToBaseObject.Get_Distance(position) <= 200.0 then
		return true
	end
	
	return false	
	
end

function Friendly_Structure_Defense_Movement_Finished(tf, finished_object)
	-- Exit this script after 30 seconds.
	if not EXIT_COUNTDOWN_ALREADY_STARTED then
		EXIT_COUNTDOWN_ALREADY_STARTED = true
		local exit_time_in_secs = GameRandom(10, 30)
		log("Generic_Defend(%s): Object Movement Finished for task force member %s. Scheduling goal termination...", USERDATA_STR, tostring(finished_object))
		Create_Thread("Script_Exit_Countdown_Thread", exit_time_in_secs)
	end
end


function Script_Exit_Countdown_Thread(exit_after_x_seconds)
	log("Generic_Defend(%s): This script will exit after %g seconds.", USERDATA_STR, exit_after_x_seconds)
	Sleep(exit_after_x_seconds)
	log("Generic_Defend(%s): Exiting now!", USERDATA_STR)
	ScriptExit()
end

