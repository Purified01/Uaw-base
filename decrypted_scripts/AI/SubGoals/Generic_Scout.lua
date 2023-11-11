-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Scout.lua#17 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Scout.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 83822 $
--
--          $DateTime: 2007/09/14 12:04:18 $
--
--          $Revision: #17 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

-- Global: string version of this goal's UserData
USERDATA_STR = ""			-- filled in during On_Activate()
DEBUGGING = true				-- set to false to disable logging and other aids
MIN_UNITS_PER_GOAL = 1		-- need at least this many to issue scouting orders
MAX_UNITS_PER_GOAL = 1		-- won't claim more than this many for a single mission
ReturnToBaseObject = nil
goal_creation_timeout = 0.0
stop_scouting = false
wait_after_scout = false
scout_go = false

function Definitions()
	USERDATA_STR = ""
	
	ReturnToBaseObject = nil
	goal_creation_timeout = 0.0
	stop_scouting = false
	wait_after_scout = false
	scout_go = false	
end


-- log - Custom logging function for this script.
function log (...)
	if not DEBUGGING then return end
	_CustomScriptMessage("AIScoutLog.txt", string.format(...))
end



function Compute_Desire()
	-- If we were not given any UserData then we won't run. We should only be
	-- run as a sub-goal of Generic_Scout_Controller.
	if not Goal.Get_User_Data() then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	-- We must have been given a target when were were created!
	if not TestValid(Target) then
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

	local score = unit_type.Get_Type_Value("Scout_Score_Rating")
	if score == nil or score <= 0.0 then
		return 0.0
	end
	
	-- Never use immobile units.
	if not unit.Can_Move() then
		return 0.0
	end

	if not Is_Multiplayer_Skirmish() and GetCurrentTime() < 150.0 and unit.Is_Category("Hero") then
		-- keep heroes out of battle for a 2.5 minutes
		return 0.0
	end

	local taskforce = Goal.Get_Task_Force()
	if taskforce and Already_Recruited( taskforce, unit ) then
		return 99.0
	end

	-- if in action and we aren't part of it we have no score
	if scout_go then
		return 0.0
	end

	if unit.Get_Health() < 1.0 then
		return 0.0
	end
	
	score = score + GameRandom.Get_Float(0.0, 0.05)
	
	return score
	
end

function Already_Recruited( task_force, our_unit )
	
	if not task_force then
		return false
	end
	
	local unit_list = task_force.Get_Unit_Table()
	if unit_list ~= nil then
		
		for _,unit in pairs(unit_list) do
			if TestValid( unit ) and unit == our_unit then
				return true
			end
		end
	end

	return false
	
end

function In_Potential_Units( task_force, our_unit )
	
	local potential_units = task_force.Get_Potential_Unit_Table()
	if potential_units ~= nil then
		
		for _,unit in pairs(potential_units) do
			if TestValid( unit ) and unit == our_unit then
				return true
			end
		end
	end

	return false
	
end

function On_Activate()
	USERDATA_STR = tostring(Goal.Get_User_Data())
	log("Generic_Scout(%s) activated!", USERDATA_STR)
	goal_creation_timeout = GetCurrentTime() + 60.0
	stop_scouting = false
	scout_go = false
	wait_after_scout = false
end


function Service()
	-- Need to have a task force before we start deciding to claim units.
	-- A task force is created when the first unit is offered to us as a
	-- potential unit.
	local task_force = Goal.Get_Task_Force()
	if not task_force then
	
		if GetCurrentTime() > goal_creation_timeout then
			log("Generic_Scout(%s): Timeout, not able to get units and or target. Terminating goal.", USERDATA_STR)
			ScriptExit()
		end
	
		return
	end

	-- Get the current set of potential units.
	local potential_units = task_force.Get_Potential_Unit_Table()
	if potential_units ~= nil and #potential_units >= MIN_UNITS_PER_GOAL and not scout_go then
		
		scout_go = true
		
		-- Claim them and issue the attack orders.
		local create_tf = Goal.Claim_Units("Scout_Thread", MAX_UNITS_PER_GOAL, true )
		if not create_tf then
			log("Generic_Scout(%s): Failure to claim, exiting script.", USERDATA_STR)
			ScriptExit()
		end
		
		local unit_list = task_force.Get_Unit_Table()
		if unit_list then
			for _,v in pairs(unit_list) do
				log("Generic_Scout(%s) claimed unit: %s", USERDATA_STR, tostring(v))
			end
		end		
		
	end
	
end


function Scout_Thread(scout_tf)
	-- Register for notification when one of our units ends or cancels its movement.
	-- This doesn't guarantee that one of them made it to the goal however, but it
	-- will avoid the situation of having one unit reach the goal and stand idle
	-- while it waits for the others to arrive.
	scout_tf.Register_Signal_Handler(Scout_Movement_Finished, "OBJECT_MOVEMENT_FINISHED")
	--scout_tf.Register_Signal_Handler(Scout_Movement_Finished, "OBJECT_MOVEMENT_CANCELED")

	-- Now that we know what units we are actually going to use, see if the target
	-- scouting location needs to be adjusted at all in order for our units to be
	-- able to reach the target area. (MovementClass and such will play a role here.)
	
	if not TestValid(Target) then
		log("Generic_Scout(%s): Scouting aborting, no target.", USERDATA_STR)
		ScriptExit()
		return
	end		
	
--	local scout_target = Target
--	local scout_position = Find_Nearest_Open_Position(Target, scout_tf)
--	if scout_position then
--		scout_target = Goal.Create_Custom_Target(scout_position)
--		log("Generic_Scout(%s): Scouting target position adjusted because of task force composition.", USERDATA_STR)
--	end

	-- note that describe can error out ... so checge it if this is needed.
	--log("Generic_Scout(%s): Attack_Move(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
	local target_pos = Target.Get_Target_Position()
	local cur_pos = scout_tf.Get_Centroid()
	local distance = target_pos.Get_Distance(cur_pos)
	local final_pos = Project_Position(cur_pos,target_pos,distance+125.0)

	wait_after_scout = false
	
	BlockOnCommand(scout_tf.Attack_Move(final_pos),180.0,Stop_Scouting)
	--BlockOnCommand(scout_tf.Explore_Area(scout_target))

	if wait_after_scout then
		stop_scouting = false
		local wait_time = GetCurrentTime() + 15.0
		while not Stop_Scouting() and GetCurrentTime() < wait_time do
			Sleep(2.5)
		end
	end

	if TestValid( ReturnToBaseObject ) then
		log( "Generic_Scout(%s): Scouting is returning to %s .", USERDATA_STR, ReturnToBaseObject.Get_Type().Get_Name() )
		local wait_time = GetCurrentTime() + 20.0
		while not Back_To_Base() and GetCurrentTime() < wait_time do
			scout_tf.Move_To(ReturnToBaseObject)
			Sleep(5.0)
		end
	end

	--log("Generic_Scout(%s): Scouting of %s complete.", USERDATA_STR, Describe_Target(scout_target))
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
	if TestValid( ReturnToBaseObject ) and ReturnToBaseObject.Get_Distance(position) <= 150.0 then
		return true
	end
	
	return false	
	
end

function Scout_Movement_Finished(scout_tf, finished_object)
	stop_scouting = true
	wait_after_scout = true
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
		if not TestValid( unit ) or unit.Get_Health() < 0.80 then
			return true
		end
	end

	return false
		
end
