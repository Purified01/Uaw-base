-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Achievement_Common.lua#13 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Achievement_Common.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 87644 $
--
--          $DateTime: 2007/11/09 10:05:36 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGColors")
require("PGPlayerProfile")
require("PGOnlineAchievementDefs")


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- If use_live_backend is true, no achievement status data will be 
-- loaded via the scoring script.  Instead it is the responsibility of the
-- caller to request status data form the backend, and then call
-- PGAchievement_Merge_Live_Backend_Data() to merge that with the standard script
-- achievement data model.
------------------------------------------------------------------------------
function Achievement_Common_Init(ShowUnachievedAchievements)

	MEDALS_BETA_FLAG = BETA_BUILD
	
	PGPlayerProfile_Init()
	AppliedAchievementsModel = {}
	AchievementIcon = Create_Wide_String("i_alien_hardpoint_key_small_2.tga")

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("WARNING:  Unable to populate UI.  Failed to the the scoring script.")
		return
	end

	-- Online models
	PGOnlineAchievementDefs_Init()
	-- Give ourselves a chance to divorce the two...
	OnlineAchievementsModel = OnlineAchievementMap

	-- Undo buffers in cse the user cancels out
	AppliedAchievementsModelUndo = {}
	--OfflineAchievementsModelUndo = {}
	OnlineAchievementsModelUndo = {}
	Capture_Model_State()

end


------------------------------------------------------------------------------
-- Build a model of only the achieved achievements from the given model.
------------------------------------------------------------------------------
function Prune_Unachieved_Achievements(model)

	local achievement_count = table.getn(model)
	local pruned = {}

	for i = 1, achievement_count do

		local achievement = model[i]
		if (achievement.Achieved) then
			table.insert(pruned, achievement)
		end

	end

	return pruned

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Copies contents of one table to another, assuming that the src table is
-- a proper array.
------------------------------------------------------------------------------
function Lazy_Copy(tabledst, tablesrc)
	local count = table.getn(tablesrc)
	for i = 1,count do
		tabledst[i] = tablesrc[i]
	end
end


------------------------------------------------------------------------------
-- Capture the state of all models so that if the user decides to cancel, we
-- can revert.
------------------------------------------------------------------------------
function Capture_Model_State()
	AppliedAchievementsModelUndo = {}
	-- JOE DELETE: OfflineAchievementsModelUndo = {}
	OnlineAchievementsModelUndo = {}
	Lazy_Copy(AppliedAchievementsModelUndo, AppliedAchievementsModel)
	-- JOE DELETE: Lazy_Copy(OfflineAchievementsModelUndo, OfflineAchievementsModel)
	Lazy_Copy(OnlineAchievementsModelUndo, OnlineAchievementsModel)
end


------------------------------------------------------------------------------
-- In the event that a user cancels an achievement application session, this
-- will restore to the original state.
------------------------------------------------------------------------------
function Restore_Model_State()
	AppliedAchievementsModel = AppliedAchievementsModelUndo
	-- JOE DELETE: OfflineAchievementsModel = OfflineAchievementsModelUndo
	OnlineAchievementsModel = OnlineAchievementsModelUndo
end

------------------------------------------------------------------------------
-- Merges the status flags from the live backend into the standard script
-- online achievements model.
--
-- NOTE:  The "Achieved" field from records in the local_model argument will
-- be overwritten with values from the backend.
------------------------------------------------------------------------------
function PGAchievement_Merge_Live_Backend_Data(live_raw, local_model)

	local status = true
	local count = 0
	local medals_unlocked = 5			-- Everyone starts with 5 medals unlocked.
	live_raw.foo = nil 
	
	-- Override?
	local override = false
	if (MEDALS_BETA_FLAG) then
		override = true
	end
	
	for index, live_dao in pairs(live_raw) do
	
		--DebugMessage("JOE DBG::::  ID: " .. tostring(live_dao.id))
		--DebugMessage("JOE DBG::::  Achieved??: " .. tostring(live_dao.achieved))
		--DebugMessage("JOE DBG::::  Label: " .. tostring(live_dao.label))
		--DebugMessage("JOE DBG::::  Desc: " .. tostring(live_dao.description))
		--DebugMessage("JOE DBG::::  Steps: " .. tostring(live_dao.steps))
		local id = live_dao.id
		if (id == nil) then
			id = live_dao.Id
		end
		local script_dao = local_model[id]
		if (script_dao == nil) then
			DebugMessage("LUA_ACHIEVEMENT: Skipping live non-medal achievement id: " .. tostring(live_dao.id))
		else
			count = count + 1
			if (override) then
				script_dao.Achieved = true
			else
				script_dao.Achieved = live_dao.achieved
			end
			if (script_dao.Achieved) then
				medals_unlocked = medals_unlocked + 1
			end
		end
		
	end
	
	if (count ~= TOTAL_FACTION_MEDALS_COUNT) then
		status = false
	end
	
	return status, medals_unlocked
	
end
