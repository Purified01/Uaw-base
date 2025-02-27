if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[159] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Master_Unit_Goal_Controller.lua#15 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Master_Unit_Goal_Controller.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGVectorMath")
require("PGLogging")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------

attack_controller_script = nil		-- Script context for the attack controller
scout_controller_script = nil			-- Script context for the scouting controller
defense_controller_script = nil		-- Script context for the defense controller
DESIGNER_CONTROL_OVERRIDE = false	-- Set to true when the designers have poked in manual AI priorities


function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "DefaultLog.txt"

	attack_controller_script = nil
	scout_controller_script = nil
	defense_controller_script = nil
	DESIGNER_CONTROL_OVERRIDE = false
	guerrilla_controller_script = nil
end



---------------------- Goal Events and Queries ----------------------

-- The Master Unit Goal Controller only has one instance.
-- It spawns sub-goals (which are controller goals themselves) to
-- decide the when and how of each type of unit use (attack, defend,
-- scout).
function Compute_Desire()

	if Target then
		--Goal.Suppress_Goal()
		return -1.0
	end

	return 1.0
end


-- This controller script never claims units directly.
function Score_Unit(unit)
	return 0.0
end


-- We do all of our work in the thread, which starts when we
-- activate (on the nil target).
function On_Activate()
	-- Launch the thread we use to do all the work.
	log("Master_Unit_Goal_Controller activated. Master_Controller_Thread created.")
	Create_Thread("Master_Controller_Thread")
	Create_Thread("Master_Crippled_Thread")
end

---------------------- the check for being crippled -----------------

function Master_Crippled_Thread()

	local command_center = nil

	while not Player.Get_Player_Is_Crippled() do
	
		if not TestValid(command_center) or command_center.Get_Owner() ~= Player then
			command_center = nil
			local ok = false
			local obj_list = Find_All_Objects_Of_Type( Player, "Small + ~Resource + ~Resource_INST | Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST" )
			if obj_list then
				for _, unit in pairs (obj_list) do
					if TestValid( unit ) then
						local unit_type = unit.Get_Type()
						if TestValid( unit_type ) then
							if unit_type.Get_Type_Value("Is_Command_Center") then
								command_center = unit
								ok = true
							end
							if unit_type.Get_Type_Value("Is_Tactical_Base_Builder") then
								ok = true
							end
						end
					end
				end
			end
			
			if not ok then
				Player.Set_Player_Is_Crippled(true)
				return
			end
			
		end
		
		Sleep(10.0)
	end
	
end

---------------------- Goal-specific Functions ----------------------

-- Until this game mode ends, we'll be periodically checking the game
-- state to figure out how many of which type of unit goals we should
-- be instantiating in order to give the player a good challenge.
function Master_Controller_Thread()

	-- Spawn sub-goals for offense/scouting/defense controllers. These sub-controllers
	-- will accept a number defining the maximum number of concurrent sub-goals they
	-- are allows to have active for their goal category (ie. no more than N concurrent
	-- attack goals). At this point they will all be created with a maximum of zero
	-- sub-goals allowed.
	--
	-- Instead of defining how many concurrent goals are allowed, maybe we should say
	-- how many units are allowed to be claimed?
	
	-- When creating a sub-goal we need to assign a target. Since these sub-goals are
	-- "controller" scripts (ie. just one instance and their purpose is to spawn other
	-- sub-goals), we don't actually care what their target is. Let's just create a
	-- bogus PositionTarget for them.
	local bogus_position = Create_Position(0,0,0)
	local bogus_target = Goal.Create_Custom_Target(bogus_position)
	
	-- UserData we'll pass to the child controller scripts.
	local child_user_data = { ParentScriptName="Master_Unit_Goal_Controller", MaxConcurrentSubgoals=0 }
	
	attack_controller_script = nil
	scout_controller_script = nil
	defense_controller_script = nil
	guerrilla_controller_script = nil

	-- Create the controller sub-goals.
	local attack_controller_script_name, attack_controller_block = Activate_Attack_Controller(bogus_target, child_user_data)
	local scout_controller_script_name, scout_controller_block = Activate_Scout_Controller(bogus_target, child_user_data)
	local defense_controller_script_name, defense_controller_block = Activate_Defense_Controller(bogus_target, child_user_data)
	local guerrilla_controller_script_name, guerrilla_controller_block = Activate_Guerrilla_Controller(bogus_target, child_user_data)
	
	if not attack_controller_block then
		log("Could not create the %s as a sub-goal of Master_Unit_Goal_Controller!", attack_controller_script_name)
	else
		attack_controller_script = Goal.Get_Script_For_Sub_Goal(attack_controller_script_name, bogus_target, child_user_data)
		if not attack_controller_script then
			log("Could not access the script wrapper for the %s sub-goal of Master_Unit_Goal_Controller!", attack_controller_script_name)
		end
	end
	if not scout_controller_block then
		log("Could not create the %s as a sub-goal of Master_Unit_Goal_Controller!", scout_controller_script_name)
	else
		scout_controller_script = Goal.Get_Script_For_Sub_Goal(scout_controller_script_name, bogus_target, child_user_data)
		if not scout_controller_script then
			log("Could not access the script wrapper for the %s sub-goal of Master_Unit_Goal_Controller!", scout_controller_script_name)
		end
	end
	--Logging here causes problems now defense controller has been removed
	--[[
	if not defense_controller_block then
		log("Could not create the %s as a sub-goal of Master_Unit_Goal_Controller!", defense_controller_script_name)
	else
		defense_controller_script = Goal.Get_Script_For_Sub_Goal(defense_controller_script_name, bogus_target, child_user_data)
		if not defense_controller_script then
			log("Could not access the script wrapper for the %s sub-goal of Master_Unit_Goal_Controller!", defense_controller_script_name)
		end
	end]]--
	if not guerrilla_controller_block then
		log("Could not create the %s as a sub-goal of Master_Unit_Goal_Controller!", guerrilla_controller_script_name)
	else
		guerrilla_controller_script = Goal.Get_Script_For_Sub_Goal(guerrilla_controller_script_name, bogus_target, child_user_data)
		if not guerrilla_controller_script then
			log("Could not access the script wrapper for the %s sub-goal of Master_Unit_Goal_Controller!", guerrilla_controller_script_name)
		end
	end
	

	if DESIGNER_CONTROL_OVERRIDE == false then
		Set_Goal_Balance(1,3,1)
	end
	
	-- Main Controller Loop. If the designers haven't poked in manual priorities for us, then we can autonomously
	-- decide to alter the balance of the attack/scout/defend goals. If they have poked priorities in, we can't
	-- modify the goal balance at all.
	while true do

		-- KDB removed the set balance stuff
		-- if is put back in we will have to make sure the goal controllers are still running
		-- as the they can exit
		--if DESIGNER_CONTROL_OVERRIDE == false then
		--end
	
		-- Update our view of the game state?
		
		-- Based on more current info, decide on the division of offense/scouting/defense goals.
		
		-- Notify each child controller script of its new maximum concurrent goal count.
	
		Sleep(10.0)
	end

	log("Master_Controller_Thread is exiting!!")
end


--
-- Activate_Attack_Controller - Activate the appropriate sub-goal controller script.
--
function Activate_Attack_Controller(target, userdata)
	-- TODO: Customize attack controller per-faction.
	local script_name = "Generic_Attack_Controller"
	return script_name, Goal.Activate_Sub_Goal(script_name, target, userdata)
end

--
-- Activate_Guerrilla_Controller - Activate the appropriate sub-goal controller script.
--
function Activate_Guerrilla_Controller(target, userdata)
	-- TODO: Customize Guerrilla controller per-faction.
	local script_name = "Generic_Guerrilla_Controller"
	return script_name, Goal.Activate_Sub_Goal(script_name, target, userdata)
end

--
-- Activate_Scout_Controller - Activate the appropriate sub-goal controller script.
--
function Activate_Scout_Controller(target, userdata)
	-- Customize scout controller per-faction.
	local script_name = "Generic_Scout_Controller"
--	if Is_Player_Of_Faction(Player, "ALIEN") or Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
--		script_name = "Alien_Scout_Controller"
--	end
	return script_name, Goal.Activate_Sub_Goal(script_name, target, userdata, true)
end


--
-- Activate_Defense_Controller - Activate the appropriate sub-goal controller script.
--
-- KDB removed tactical level handles defense
function Activate_Defense_Controller(target, userdata)
	-- TODO: Customize defense controller per-faction.
--	local script_name = "Generic_Defend_Controller"
--	return script_name, Goal.Activate_Sub_Goal(script_name, target, userdata)
end


--
-- Set_Goal_Balance - Set the sub-goal-controllers limits on max concurrent sub-goals.
--
function Set_Goal_Balance(attack, scout, defense)
	if attack_controller_script then
		attack_controller_script.Call_Function("Update_Max_Concurrent_Subgoals", attack)
	else
		log("Set_Goal_Balance: ERROR - attack_controller_script is nil!")
	end
	if scout_controller_script then
		scout_controller_script.Call_Function("Update_Max_Concurrent_Subgoals", scout)
	else
		log("Set_Goal_Balance: ERROR - scout_controller_script is nil!")
	end
	
-- KDB removed	
--	if defense_controller_script then
--		defense_controller_script.Call_Function("Update_Max_Concurrent_Subgoals", defense)
--	else
--		log("Set_Goal_Balance: ERROR - defense_controller_script is nil!")
--	end
	
	-- KDB guerrilla script is set at 2 no change for mode, could be changed in future
	if guerrilla_controller_script then
		guerrilla_controller_script.Call_Function("Update_Max_Concurrent_Subgoals", 2 )
	else
		log("Set_Goal_Balance: ERROR - guerrilla_controller_script is nil!")
	end

	log("Current goal balance: %g attack, %g scout, %g defense", attack, scout, defense)
	
end


--
-- Set_Aggressive_Mode - Interface function called from PGStoryMode.lua. This function
-- puts the Master Unit Goal Controller into aggressive mode with a designer override.
--
function Set_Aggressive_Mode()
	log("Set_Aggressive_Mode: Manual designer control over AI sub-goal concurrency established.")
	DESIGNER_CONTROL_OVERRIDE = true
	Set_Goal_Balance(2, 1, 1)
	return true
end


--
-- Set_Defensive_Mode - Interface function called from PGStoryMode.lua. This function
-- puts the Master Unit Goal Controller into defensive mode with a designer override.
--
function Set_Defensive_Mode()
	log("Set_Defensive_Mode: Manual designer control over AI sub-goal concurrency established.")
	DESIGNER_CONTROL_OVERRIDE = true
	Set_Goal_Balance(1, 1, 3)
	return true
end


--
-- Set_Scouting_Mode - Interface function called from PGStoryMode.lua. This function
-- puts the Master Unit Goal Controller into scouting mode with a designer override.
--
function Set_Scouting_Mode()
	log("Set_Scouting_Mode: Manual designer control over AI sub-goal concurrency established.")
	DESIGNER_CONTROL_OVERRIDE = true
	Set_Goal_Balance(1, 3, 1)
	return true
end


--
-- Set_Aggressive_Mode - Interface function called from PGStoryMode.lua. This function
-- puts the Master Unit Goal Controller back into autonomous mode and removes the
-- designer override.
--
function Set_Autonomous_Mode()
	log("Set_Autonomous_Mode: Manual designer control over AI sub-goal concurrency relinquished.")
	DESIGNER_CONTROL_OVERRIDE = false
	return true
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Burn_All_Objects = nil
	Calculate_Task_Force_Speed = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	Describe_Target = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	Get_Distance_Based_Unit_Score = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	PG_Vector_Add = nil
	PG_Vector_Multiply_Scalar = nil
	PG_Vector_Normalize = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
