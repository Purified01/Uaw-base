LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGGoalController.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGGoalController.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- PGGoalController provides some common functions to all "controller"-style goal scripts.
-- ie. Goals that only have one instance, and whose purpose is to choose targets and goals
-- to execute to fulfill a certain purpose. Example: Generic_Attack_Controller



require("PGLogging")


---------------------- Global Variables ----------------------

-- ACTIVE_SUBGOALS = {}		-- table of all active sub-goals indexed by unique id with value { blocking_object, script_name, ai_target, user_data }


---------------------- Library Functions ----------------------

-- Record_New_Active_Subgoal - When we activate a new sub-goal, we record its creation
-- parameters here so that we can later scan for things like the blocking objects of
-- our sub-goals and their targets.
function Record_New_Active_Subgoal(index_value, blocking_object, script_name, ai_target, user_data, arbitrary_data)
	-- We must have a valid blocking object representing this new sub-goal in
	-- order to add it to the table.
	if (not blocking_object) or blocking_object.IsFinished() then
		return
	end

	if not ACTIVE_SUBGOALS then
		ACTIVE_SUBGOALS = {}
	end
	
	-- Record it in the global table of active attack sub-goals.
	ACTIVE_SUBGOALS[index_value] = { Block=blocking_object, Script=script_name, Target=ai_target, UserData=user_data, ArbitraryData=arbitrary_data }
	
	-- Print out the current table contents.
	for k,v in pairs(ACTIVE_SUBGOALS) do
		log("ACTIVE_SUBGOALS[%s] = { Block=%s, Script=%s, Target=%s, UserData=%s, ArbitraryData=%s }", tostring(k),
			tostring(v["Block"]), v["Script"], Describe_Target(v["Target"]), tostring(v["UserData"]), tostring(v["ArbitraryData"]))
	end
end


-- Target_Is_Already_Used - Check if any of our active sub-goals are using the
-- given ai_target.
function Target_Is_Already_Used(ai_target)
	if ACTIVE_SUBGOALS then
		for _,v in pairs(ACTIVE_SUBGOALS) do
			if v["Target"] == ai_target then
				return true
			end
		end
	end
	return false
end


-- Wait_For_Any_Subgoal - Block until one of our subgoals is finished. Once one
-- of them finished, make sure we remove their data from the ACTIVE_SUBGOALS table.
function Wait_For_Any_Subgoal()
	-- Create an array of blocking objects for all our active sub-goals.
	local blocking_objects = {}
	
	if not ACTIVE_SUBGOALS then
		return
	end
	
	for k,v in pairs(ACTIVE_SUBGOALS) do
		table.insert(blocking_objects, v["Block"])
	end
	
	-- If we got some blocking objects to wait on, go ahead and wait.
	if #blocking_objects > 0 then
		WaitForAnyBlock(blocking_objects)

		-- Ok waiting done! At least one of our blocking objects must be finished,
		-- so clean up the relevant table entries.
		Clean_Active_Subgoal_Table()
	end
end


-- Clean_Active_Subgoal_Table - Remove any entries from the table of active subgoals
-- that are finished (ie. those subgoals no longer exist).
function Clean_Active_Subgoal_Table()
	-- At least one of our blocking objects may be finished.
	-- Find them and remove their whole entry from the table.
	
	if not ACTIVE_SUBGOALS then
		return
	end
	
	local keys_to_remove = {}
	for k,v in pairs(ACTIVE_SUBGOALS) do
		if (not v) or v["Block"].IsFinished() then
			-- We can't remove table entries while iterating, so save of the keys
			-- for the entries we want to remove.
			table.insert(keys_to_remove, k)
		end
	end
	for _,v in pairs(keys_to_remove) do
		ACTIVE_SUBGOALS[v] = nil
		log("Removed sub-goal index %s", tostring(v))
	end
end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Record_New_Active_Subgoal = nil
	Target_Is_Already_Used = nil
	Wait_For_Any_Subgoal = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
