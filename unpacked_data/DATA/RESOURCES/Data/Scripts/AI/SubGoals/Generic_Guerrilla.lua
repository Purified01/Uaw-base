-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Guerrilla.lua#14 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Guerrilla.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 83822 $
--
--          $DateTime: 2007/09/14 12:04:18 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGLogging")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------
USERDATA_STR = ""				-- filled in during On_Activate()
MIN_UNITS_PER_GOAL = 1			-- need at least this many to issue guerrillaing orders
MAX_UNITS_PER_GOAL = 2		-- won't claim more than this many for a single mission
ReturnToBaseObject = nil
guerrilla_go = false
last_seen_non_empty_group_time = 0.0

function Definitions()
	USERDATA_STR = ""

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIGuerrillaLog.txt"
	
	ReturnToBaseObject = nil
	guerrilla_go = false
	last_seen_non_empty_group_time = 0.0	
end

---------------------- Goal Events and Queries ----------------------

function Compute_Desire()

	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not Target.Is_Enemy(Player) then
--		log("Generic_Guerrilla(%s) - Compute_Desire() returning 0.0 for %s because it is not an enemy.", USERDATA_STR, Describe_Target(Target))
		return 0.0
	end

--	log("Generic_Guerrilla(%s) - Compute_Desire() returning 1.0 for %s", USERDATA_STR, Describe_Target(Target))
	return 1.0
end


function Score_Unit(unit)

	if add_no_more_units then		-- trying to limit this behavior so we see more clearly what's going on
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

	-- Never use immobile units.
	if not unit.Can_Move() then
		return 0.0
	end

	local score = unit_type.Get_Type_Value("Guerilla_Score_Rating")
	if score == nil or score <= 0.0 then
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
	if guerrilla_go then
		return 0.0
	end
	
	if unit.Get_Health() < 1.0 then
		return 0.0
	end

	return score	
	
end

function In_Potential_Units( task_force, our_unit )
	
	if not task_force then
		return false
	end
	
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

function On_Activate()
	USERDATA_STR = tostring(Goal.Get_User_Data())
	log("Generic_Guerrilla(%s) activated!", USERDATA_STR)

	if (Target.Get_Target_Type() == "Object_Group") and (Target.Get_Group_Target_Size() > 0) then
		last_seen_non_empty_group_time = GetCurrentTime()
	end
	
	ReturnToBaseObject = nil
	guerrilla_go = false		
	last_seen_non_empty_group_time = 0.0

	MIN_UNITS_PER_GOAL = 3
	MAX_UNITS_PER_GOAL = 3
		
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
	local total_score = 0
	local power_guerilla = false
	
	MIN_UNITS_PER_GOAL = 3
	MAX_UNITS_PER_GOAL = 3
	
	if potential_units and not guerrilla_go then
		for _,unit in pairs(potential_units) do
			if TestValid( unit ) then
				local unit_type = unit.Get_Type()
				if TestValid(unit_type) then
					local score = unit_type.Get_Type_Value("Guerilla_Score_Rating")
					if score ~= nil and score > 0.0 then
						if score >=2 then
							total_score = score
							MIN_UNITS_PER_GOAL = 1
							MAX_UNITS_PER_GOAL = 1
							power_guerilla = true
							break
						else
							total_score = total_score + score
						end
					end
				end
			end
		end
	end	
	
	if not guerrilla_go and total_score > 2.0 and not power_guerilla then
		MIN_UNITS_PER_GOAL = 2
		MAX_UNITS_PER_GOAL = 2
	end
	
	if potential_units ~= nil and #potential_units >= MIN_UNITS_PER_GOAL and not guerrilla_go then
		
		guerrilla_go = true
		
		-- Claim them and issue the attack orders.
		local create_tf = Goal.Claim_Units("Guerrilla_Thread", MAX_UNITS_PER_GOAL, true )
		if not create_tf then
			log("Generic_Guerrilla(%s): Failure to claim, exiting script.", USERDATA_STR)
			ScriptExit()
		end
		
		local unit_list = task_force.Get_Unit_Table()
		if unit_list then
			for _,v in pairs(unit_list) do
				log("Generic_Guerrilla(%s) claimed unit: %s", USERDATA_STR, tostring(v))
			end
		end		
		
	end
end


function Guerrilla_Thread(attack_tf)
	-- Issue Guard_Target commands on object groups and Guerrilla_Target commands on game objects.

	local target_type = Target.Get_Target_Type()
	
	if TestValid(ReturnToBaseObject) then
		local pos = Target.Get_Target_Position()
		local distance = ReturnToBaseObject.Get_Distance(pos)
		if distance > 600.0 then
			-- angle to the side
			local mid_point = Project_Position(pos,ReturnToBaseObject,500.0,90.0 - GameRandom(0.0,180.0))
			if TestValid(mid_point) then
				BlockOnCommand(attack_tf.Move_To(mid_point),120.0,Stop_Attack)
			end
		end
	end
	
	if not Stop_Attack() then
		if target_type == "Object_Group" then
			log("Generic_Guerrilla(%s): Guard_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
			attack_tf.Guard_Target(Target)
			BlockOnCommand(attack_tf.Guard_Target(Target),180.0,Stop_Attack)
		elseif target_type == "Game_Object" then
			log("Generic_Guerrilla(%s): Guerrilla_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
			BlockOnCommand(attack_tf.Attack_Target(Target),180.0,Stop_Attack)
		end
	end

	if TestValid(ReturnToBaseObject) then
		log("Generic_Guerrilla(%s): Guerrilla_Target retreat to %s ordered!", USERDATA_STR, ReturnToBaseObject.Get_Type().Get_Name())
		local wait_time = GetCurrentTime() + 20.0
		while not Back_To_Base() and GetCurrentTime() < wait_time do
			attack_tf.Move_To(ReturnToBaseObject)
			Sleep(5.0)
		end
	end
		
	log("Generic_Guerrilla(%s): Guerrilla_Target(%s) Is finished.", USERDATA_STR, Describe_Target(Target))
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
	
	if not TestValid( ReturnToBaseObject ) then
		return true
	end

	local position = task_force.Get_Centroid()
	if ReturnToBaseObject.Get_Distance(position) <= 200.0 then
		return true
	end
	
	return false	
	
end

function Stop_Attack()

	local task_force = Goal.Get_Task_Force()
	
	if not task_force then
		return true
	end
	
	local unit_list = task_force.Get_Unit_Table()
	
	if not unit_list or #unit_list < 1 then
		return true
	end
	
	for _,unit in pairs(unit_list) do
		if not TestValid( unit ) or unit.Get_Health() < 0.85 then
			return true
		end
	end

	return false
	
end