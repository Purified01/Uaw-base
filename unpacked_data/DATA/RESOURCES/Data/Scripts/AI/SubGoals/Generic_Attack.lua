-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Attack.lua#21 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Attack.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 84304 $
--
--          $DateTime: 2007/09/19 13:35:50 $
--
--          $Revision: #21 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGLogging")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------
USERDATA_STR = ""				-- filled in during On_Activate()
MIN_UNITS_PER_GOAL = 12		-- need at least this many to issue attack
MAX_UNITS_PER_GOAL = 24		-- won't claim more than this many for a single mission
last_seen_non_empty_group_time = 0.0
CommandCenter = nil
LastStand = false
BuilderUnit = nil

function Definitions()
	USERDATA_STR = ""

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIAttackLog.txt"
	
	last_seen_non_empty_group_time = 0.0
	CommandCenter = nil
	LastStand = false
	BuilderUnit = nil	
end



---------------------- Goal Events and Queries ----------------------

function Compute_Desire()

	if not TestValid(Target) then
		Goal.Suppress_Goal()
		--log( "Generic_Attack(%s) - Compute_Desire() returning 0.0 because of no target.", USERDATA_STR )
		return 0.0
	end
	
	if not Target.Is_Enemy(Player) then
		--log("Generic_Attack(%s) - Compute_Desire() returning 0.0 for %s because it is not an enemy.", USERDATA_STR, Describe_Target(Target))
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
				--log("Generic_Attack(%s) - Compute_Desire() returning 0.0 because its object group target %s has no more visible members.", USERDATA_STR, Describe_Target(Target))
				return 0.0
			end
		end
	end

	-- TODO: If our target is a game object and it's been fogged for more than 30 seconds, give up.
	
	--log("Generic_Attack(%s) - Compute_Desire() returning 1.0 for %s", USERDATA_STR, Describe_Target(Target))
	return 1.0
end


function Score_Unit(unit)

	if not LastStand and add_no_more_units then		-- trying to limit this behavior so we see more clearly what's going on
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

	-- this is our command center
	if unit_type.Get_Type_Value("Is_Command_Center") then
		CommandCenter = unit
	end

	if unit_type.Get_Type_Value("Is_Tactical_Base_Builder") then
		BuilderUnit = unit
	end

	-- Never use immobile units.
	if not unit.Can_Move() then
		return 0.0
	end

	local score
	if LastStand then
		score = 1000.0
	else
		score = unit_type.Get_Type_Value("Attack_Score_Rating")
	end

	if not Is_Multiplayer_Skirmish() and GetCurrentTime() < 150.0 and unit.Is_Category("Hero") then
		-- keep heroes out of battle for a 2.5 minutes
		return 0.0
	end

	if score == nil or score <= 0.0 then
		return 0.0
	end

	if not CanUseWalkers and not LastStand and unit.Is_Category("Huge") then
		return 0.0
	end

	local taskforce = Goal.Get_Task_Force()
	if not taskforce then
		return 1.0
	end
	
	local total_units = taskforce.Get_Total_Unit_Count()
		
	if TestValid(Target) and total_units <= Target.Get_Group_Target_Size() then
		return score
	else
		return Get_Distance_Based_Unit_Score(taskforce, unit) * score
	end
	
end

function Can_Use_Walkers()
	
	if GameRandom(1,100) <= 10 then
		-- random chance one in ten
		return true
	end

	if Player.Get_Credits() >= 10000.0 then
		-- lots of cash allow walkers to be used
		return true
	end

	if GetCurrentTime() >= 720.0 then
		-- 12 minutes into the game allow them
		return true
	end

	return false	
end

function On_Activate()
	USERDATA_STR = tostring(Goal.Get_User_Data())
	log("Generic_Attack(%s) activated!", USERDATA_STR)
	
	CanUseWalkers = Can_Use_Walkers()
	
	LastStand = false
	WalkerIsPresent = false
	
	if (Target.Get_Target_Type() == "Object_Group") and (Target.Get_Group_Target_Size() > 0) then
		last_seen_non_empty_group_time = GetCurrentTime()
	end
	
	
end


function Service()
	-- Need to have a task force before we start deciding to claim units.
	-- A task force is created when the first unit is offered to us as a
	-- potential unit.
	
	Check_For_Last_Stand()
	
	local task_force = Goal.Get_Task_Force()
	if not task_force then
		return
	end

	-- Get the current set of potential units.
	local potential_units = task_force.Get_Potential_Unit_Table()
	local unit_list = task_force.Get_Unit_Table()
	-- only attack once, build up and attack again don'y stream the units in
	-- unless in last stand mode
	local number_to_claim = MAX_UNITS_PER_GOAL
	if LastStand then
		number_to_claim = 999
	end
	if ( LastStand and #potential_units >0 ) or (#potential_units >= MIN_UNITS_PER_GOAL and ( unit_list == nil or #unit_list == 0 )) then
		
		-- Claim them and issue the attack orders.
		local create_tf = Goal.Claim_Units("Attack_Thread", number_to_claim, true )
		if not create_tf then
			log("Generic_Attack(%s): Failure to claim, exiting script.", USERDATA_STR)
			ScriptExit()
		end
		
		local unit_list = task_force.Get_Unit_Table()
		WalkerIsPresent = false
		if unit_list then
			for _,v in pairs(unit_list) do
				--log("Generic_Attack(%s) claimed unit: %s", USERDATA_STR, tostring(v))
				if TestValid(v) and v.Is_Category("Huge") then
					WalkerIsPresent = true
				end
			end
		end		
		
	end
end


function Attack_Thread(attack_tf)
	-- Issue Guard_Target commands on object groups and Attack_Target commands on game objects.
	local target_type = Target.Get_Target_Type()
	
	local position = attack_tf.Get_Centroid()
	local time_out = GetCurrentTime() + 90.0
	local angle = 30.0 - GameRandom.Get_Float(0.0,60.0)
	
	if Target.Get_Distance(position) > 800.0 then
		-- attempt to form up
		while Target.Get_Distance(attack_tf.Get_Centroid()) > 800.0 and GetCurrentTime() < time_out do
			local pos = Project_Position(Target.Get_Target_Position(),position,600.0,angle)
			if pos == nil then
				break
			end
			
			attack_tf.Move_To(pos)
			Sleep(20.0)
			
		end
	end
	
	if target_type == "Object_Group" then
		log("Generic_Attack(%s): Guard_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
		while true do
			local end_tm = GetCurrentTime() + 20.0
			BlockOnCommand(attack_tf.Guard_Target(Target),20.0)
			if GetCurrentTime() < end_tm then
				break
			end
		end
	elseif target_type == "Game_Object" then
		log("Generic_Attack(%s): Attack_Target(%s) order initiated!", USERDATA_STR, Describe_Target(Target))
		while true do
			local end_tm = GetCurrentTime() + 20.0
			BlockOnCommand(attack_tf.Attack_Target(Target),20.0)
			if GetCurrentTime() < end_tm then
				break
			end
		end
	end
	log("Generic_Attack(%s): Attack complete.", USERDATA_STR)
	ScriptExit()
end

local passes = 0

function Check_For_Last_Stand()
	if passes == 0 or LastStand or TestValid(CommandCenter) or TestValid(BuilderUnit) then
		passes = passes + 1.0
		return
	end
	
	local obj_list = Find_All_Objects_Of_Type( Player )
	if obj_list then
		for _, unit in pairs (obj_list) do
			if TestValid(unit) then
				local obj_type = unit.Get_Type()
				if TestValid(obj_type) then
					if obj_type.Get_Type_Value("Is_Command_Center") then
						CommandCenter = unit
					end

					if obj_type.Get_Type_Value("Is_Tactical_Base_Builder") then
						BuilderUnit = unit
					end
					
				end
			end
		end
	end

	if TestValid(CommandCenter) or TestValid(BuilderUnit) then
		return
	end
	
	LastStand = true
	log("Generic_Attack(%s): No command center and builders left, going to LastStand!", USERDATA_STR)
	
end
