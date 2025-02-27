if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[23] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/AIIdleThreads.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/AIIdleThreads.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGAICommands")
require("PGLogging")


---------------------- Script Globals ----------------------

LOGFILE_NAME = "IdleThreads.txt"

--function Definitions()
	-- Override from PGLogging.lua
--	LOGFILE_NAME = "IdleThreads.txt"
--end



------------- Globals Defined in the Unit's XML -------------

-- DEFENSIVE_THREAD_GUARD_SPECIFIC_TYPES: Defined in XML as a table of strings, each
-- string is the GameObjectType name of a unit type that we should consider guarding.

-- DEFENSIVE_THREAD_GUARD_TYPE_CATEGORIES: Defined in XML as a GameObjecType Category
-- Mask string that can be passed to Find_All_Objects_Of_Type. We will consider guarding
-- any owned units that match the mask.



---------------------- XML-Referenced Idle Threads ----------------------


-- Defensive_AI_Thread - This idle thread attacks any nearby threat, and if none are
-- visible, it will choose a target and guard it. The filters for the type of units
-- to guard are defined in XML (see above).
function Defensive_AI_Thread()

	--log("Started Defensive_AI_Thread for %s owned by player %s", tostring(Object), tostring(Object.Get_Owner()))
	
	-- KDB removed the attack part as that is handled by DefensiveAIUnitBehavior
	-- also added the checks for retreating and defensive AI
	
	while Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() do
	
		Sleep(3.0)
		
		if not AntiCrushUnitBehaviorActionTaken and not AIDefensiveIsRetreating and not AIDefensiveIsActing then
			-- Otherwise pick a suitable guard target and guard it.
			local guard_targets = Find_Suitable_Guard_Targets()
			if guard_targets and #guard_targets > 0 then
				local chosen_guard_target = Choose_Guard_Target(guard_targets)
				log("Defensive_AI_Thread: Issuing %s -> Guard_Target(%s) command", tostring(Object), tostring(chosen_guard_target))
				log("---")
				BlockOnCommand(Object.Guard_Target(chosen_guard_target))
			end
		end
		
	end

	Sleep(1.5)
		
end


-- Returns a table of targets that would be good choices for the object
-- that owns this script to guard.
function Find_Suitable_Guard_Targets()
	local specific_type_units = {}
	local category_mask_units = {}
	
	-- If a category mask was given, then search for all units owned by the current
	-- player that match the given mask.
	if DEFENSIVE_THREAD_GUARD_TYPE_CATEGORIES and DEFENSIVE_THREAD_GUARD_TYPE_CATEGORIES ~= "" then
		--log("Find_Suitable_Guard_Targets: Searching for objects matching mask \"%s\" on behalf of %s", DEFENSIVE_THREAD_GUARD_TYPE_CATEGORIES, tostring(Object))
		category_mask_units = PG_Find_All_Objects_Of_Type(DEFENSIVE_THREAD_GUARD_TYPE_CATEGORIES, Object.Get_Owner())
		if not category_mask_units then
			category_mask_units = {}
		end
		--log("Find_Suitable_Guard_Targets: Found %d matches.", #category_mask_units)
		--table.foreach(category_mask_units, show_table)
		Sleep(0)
	end
	
	-- If specific object types were given, then search for all units of those
	-- types owned by the current player.
	if DEFENSIVE_THREAD_GUARD_SPECIFIC_TYPES then
		local type_name = ""
		for _,type_name in pairs(DEFENSIVE_THREAD_GUARD_SPECIFIC_TYPES) do
			if type_name and type_name ~= "" then
				--log("Find_Suitable_Guard_Targets: Searching for objects of type %s on behalf of %s", type_name, tostring(Object))
				if DEBUGGING then
					if not Find_Object_Type(type_name) then
						log("Find_Suitable_Guard_Targets: %s is not the name of a valid object type!", type_name)
					end
				end
				local found_units = PG_Find_All_Objects_Of_Type(type_name, Object.Get_Owner())
				if found_units then
					specific_type_units = Merge_Table_Values(specific_type_units, found_units)
					--log("Find_Suitable_Guard_Targets: Found %d matches.", #found_units)
					--table.foreach(found_units, show_table)
				end
				Sleep(0)
			end
		end
	end
	
	-- Build a table that contains all matching units that are suitable guard targets.
	local guard_targets = Merge_Table_Values(specific_type_units, category_mask_units, Is_Suitable_Guard_Target)
	--log("Find_Suitable_Guard_Targets: The following objects were found to be suitable guard targets for %s:", tostring(Object))
	--table.foreach(guard_targets, show_table)
	return guard_targets
end


-- Is_Suitable_Guard_Target - Check if the given target object is a valid thing for us to guard.
-- Returns true or false.
function Is_Suitable_Guard_Target(target)
	if not TestValid(target) then return false end
	if Object.Get_Owner().Is_Enemy(target.Get_Owner()) then return false end
	if target == Object then return false end
	
	-- Beacons and objects under construction are not suitable guard targets.
	if target.Has_Behavior(39) then return false end
	if target.Has_Behavior(70) then return false end
	
	-- Todo: Limit the number of units guarding this target?
	
	return true
end


-- Choose_Guard_Target - Given a list of targets, choose one that we will actually
-- try to guard.
function Choose_Guard_Target(guard_targets)
	
	-- Make sure we were given a table with at least one entry.
	if not guard_targets or #guard_targets <= 0 then
		return nil
	end
	
	-- Choose a target based on distance (and the number of things already guarding it?).
	local randomizer = DiscreteDistribution.Create()
	if not randomizer then return nil end
	for _,target in pairs(guard_targets) do
		local distance_to_target = Object.Get_Distance(target)
		if distance_to_target > 0.0 then
			randomizer.Insert(target, 1.0 / distance_to_target)
			log("Choose_Guard_Target: Assigned %s a weight of %f", tostring(target), 1.0 / distance_to_target)
		else
			randomizer.Insert(target, 1.0)
			log("Choose_Guard_Target: Assigned %s a weight of 1.0", tostring(target))
		end
	end
	local chosen_target = randomizer.Sample()
	return chosen_target
end



---------------------- Helper Functions ----------------------

-- Combine the values of tables a and b into one table and return it.
-- If function f is given, only values that return true will be in the merged table.
function Merge_Table_Values(a, b, f)
	local t = {}
	for _,v in pairs(a) do if ((f and f(v)) or (not f)) then table.insert(t, v) end end
	for _,v in pairs(b) do if ((f and f(v)) or (not f)) then table.insert(t, v) end end
	return t
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
