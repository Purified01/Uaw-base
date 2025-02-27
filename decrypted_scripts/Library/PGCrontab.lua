if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGCrontab.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGCrontab.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 96589 $
--
--          $DateTime: 2008/04/08 16:51:17 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- Simple system for scheduling callback into the future.
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

require("PGBase")


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- S E T U P
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGCrontab_Init()

	-- Constants
	_PG_CRONTAB_FUNCTION_IDX = Declare_Enum(1)
	_PG_CRONTAB_MINUTES_IDX = Declare_Enum()
	_PG_CRONTAB_SECONDS_IDX = Declare_Enum()
	_PG_CRONTAB_REPEATING_IDX = Declare_Enum()
	_PG_CRONTAB_GROWTH_SAFETY_THRESHOLD = 3			-- If a function is scheduled 100 times in 3 seconds, halt.
	_PG_CRONTAB_GROWTH_SAFETY_SAMPLE_SIZE = 100
	
	-- Variables
	_PGCrontabSequence = 0
	_PGCrontabLastCurr = _PGCrontab_Get_Timestamp()
	_PGCronTable = {}
	_PGCrontabFunctionStore = {}
	_PGCrontabParanoiaCheck = {} 

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- P U B L I C   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function PGCrontab_Update()

	local curr = _PGCrontab_Get_Timestamp()
	
	if (curr ~= nil) then
	
		-- We only iterate the table once per second
		if (curr <= _PGCrontabLastCurr) then
			return
		end
		_PGCrontabLastCurr = curr
		
		-- Iterate through the crons and call the functions that have been scheduled.
		local prune_list = {}
		for key, cron in pairs(_PGCronTable) do
		
			local delta = _PGCrontab_Compute_Delta(curr, cron)
			
			-- Has the cron procced?
			if (delta >= cron.Seconds) then
			
				-- Proc
				cron.Function()
				
				-- Repeating?
				if (cron.RepeatCount == nil) then
				
					-- Not a repeating cron, clear it.
					table.insert(prune_list, key)
					
				else
				
					-- Repeating cron.  Schedule the next one.
					if (cron.RepeatCount > 0) then
						-- Decrement the counter.
						cron.RepeatCount = cron.RepeatCount - 1
					elseif (cron.RepeatCount == 0) then
						-- Next one will be the last
						cron.RepeatCount = nil
					end
					-- Schedule the next proc.
					cron.Timestamp = _PGCrontab_Get_Timestamp()
					
				end
				
			end

		end
		
		-- Prune all the keys in the prune list.
		for _, key in ipairs(prune_list) do
			_PGCronTable[key] = nil
		end
		
	end
	
end

-------------------------------------------------------------------------------
-- For repeat_count:
--	- nil:  Proc the function once, do not repeat.
--	- -1:  Proc the function infinitely.
--	- > 0:  Proc the function a specified number of times. 
-------------------------------------------------------------------------------
function PGCrontab_Schedule(function_handle, minutes, seconds, repeat_count)

	local key = _PGCrontab_Generate_Key(function_handle)
	if (key == nil) then
		-- If the key generator fails, it's likely the caller is mistakenly 
		-- scheduling the function call recursively and infinitely and we need to stop it.
		return
	end
	
	local total_sec = (minutes * 60) + seconds
	
	local cron = {}
	cron.Timestamp = _PGCrontab_Get_Timestamp()
	cron.Function = function_handle
	cron.Seconds = total_sec
	if ((repeat_count == nil) or (repeat_count == -1)) then
		cron.RepeatCount = repeat_count
	else
		cron.RepeatCount = repeat_count - 2  -- The way this counter is decremented means we subtract 2.
		if (cron.RepeatCount < 0) then
			cron.RepeatCount = nil
		end
	end
	
	_PGCronTable[key] = cron

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGCrontab_Kill_Scheduled_Functions(function_handle)

	local new_cron_table = {}
	
	for key, cron in pairs(_PGCronTable) do
		if (cron.Function ~= function_handle) then
			new_cron_table[key] = cron
		end
	end
	
	_PGCronTable = new_cron_table

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- P R I V A T E   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Every function that gets passed is assigned a sequence, so that subsequent
-- requests to schedule each function call are guananteed storage and
-- execution.
-------------------------------------------------------------------------------
function _PGCrontab_Generate_Key(function_handle)

	-- Determine this function's sequence value.
	if (sequence == nil) then
		sequence = 1
	else
		sequence = sequence + 1
	end
	
	-- Check for the exponential growth issue.
	if (not _PGCrontab_Validate_Growth(function_handle)) then
		return nil
	end
		
	--return string.format("%s_%d", tostring(function_handle), sequence)
	_PGCrontabSequence = _PGCrontabSequence + 1
	return _PGCrontabSequence

end
	
-------------------------------------------------------------------------------
-- If a caller is not careful, it is possible that they may recursively
-- have PGCrontab call their function over and over again which will create
-- a memory leak that will grow out of control exponentially.  This validation
-- check helps detect that occurrence and alerts anyone running a debug build.
-------------------------------------------------------------------------------
function _PGCrontab_Validate_Growth(function_handle)

	local dao = _PGCrontabParanoiaCheck[function_handle]
	if (dao == nil) then
		dao = {}
		dao.count = 1
		dao.timestamp = {}
		_PGCrontabParanoiaCheck[function_handle] = dao
	else
		dao.count = dao.count + 1
	end
	table.insert(dao.timestamp, _PGCrontab_Get_Timestamp())
	
	-- If there are more than our sample size calls scheduled, check the timestamp of
	-- the N-SampleSize'th one and make sure it's not growing too fast.
	if (dao.count > _PG_CRONTAB_GROWTH_SAFETY_SAMPLE_SIZE) then
	
		local curr_ts = dao.timestamp[dao.count]
		local previous_ts = dao.timestamp[dao.count - _PG_CRONTAB_GROWTH_SAFETY_SAMPLE_SIZE]
			
		-- Is the difference between the two timestamps smaller than the safety threshold?
		if ((curr_ts - previous_ts) <= _PG_CRONTAB_GROWTH_SAFETY_THRESHOLD) then
			ScriptError("PGCrontab recursive exponential growth issue.")
			MessageBox("PGCrontab ** RECURSIVE EXPONENTIAL GROWTH ISSUE **:  Check the AILog and get Joe Howes!!!!")
			return false
		end
		
		-- Keep the buffer from growing!!
		table.remove(dao.timestamp, 1)
		dao.count = _PG_CRONTAB_GROWTH_SAFETY_SAMPLE_SIZE
		
	end
	
	return true

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGCrontab_Get_Timestamp()

	local result = nil

	if (Net == nil) then
		result = tonumber(Dirty_Floor(GetCurrentTime()))
	else
		result = tonumber(Dirty_Floor(Net.Get_Time()))
	end
	
	return result
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGCrontab_Compute_Delta(curr_time, cron)
	return (curr_time - cron.Timestamp)
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGCrontab_Init = nil
	PGCrontab_Schedule = nil
	PGCrontab_Update = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
