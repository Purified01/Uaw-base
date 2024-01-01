-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGBase.lua#31 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGBase.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 83784 $
--
--          $DateTime: 2007/09/13 19:42:40 $
--
--          $Revision: #31 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

if type(jit) == "table" then
	require("jit.opt").start()
end
require("PGDebug")

YieldCount = 0;

function ScriptExit()
	_ScriptExit() -- set a flag in 'C' to terminate the whole script on next yield
	
	if GetThreadID() >= 0 then
		coroutine.yield(false) -- return false to exit this thread
	end
end

function Sleep(time)

	--DebugMessage("Sleeping...  SleepTime: %.3f, CurTime: %.3f\n", time, GetCurrentTime())
	ThreadValue.Set("StartTime", GetCurrentTime())
	
	-- AJA 12/19/2006 - Changed from a 'while ... do' to a 'repeat ... until'
	-- structure so that PumpEvents() is always called at least once, so that
	-- calls like Sleep(0) are supported.
	repeat
		PumpEvents()
	until GetCurrentTime() - ThreadValue("StartTime") >= time
	
	--DebugMessage("Done with Sleep.  Continuing, CurTime: %.3f\n", GetCurrentTime())
end

-- Service the block until optional max duration has expired or alternate break function returns true
-- Pass -1 max_duration to use optional alternate break function with no time limit
function BlockOnCommand(block, max_duration, alternate_break_func)

	PumpEvents()

	if not block then
		return nil
	end

	break_block = false
	
	ThreadValue.Set("BlockStart", GetCurrentTime())
	
	repeat
		if break_block == true then
			break_block = false
			return nil
		end

		PumpEvents()
	
		if ((max_duration ~= nil) and (max_duration ~= -1) 
			and (GetCurrentTime() - ThreadValue("BlockStart") > max_duration)) then
			--MessageBox("%s -- Had a time limit and it expired", tostring(Script))
			return nil
		end

		if ((alternate_break_func ~= nil) and alternate_break_func()) then
			--MessageBox("%s-- had a break func and it returned true", tostring(Script))
			return nil
		end

	until (block.IsFinished() == true) 

	PumpEvents()

	return block.Result()
end

function BreakBlock()
	break_block = true
end

function TestCommand(block)
	if not block then
		return nil
	end

	PumpEvents()

	return block.IsFinished()
end

-- Block until any one of the blocking objects in the given list is finished.
-- Returns the block that finished.
function WaitForAnyBlock(block_list)
	while true do
		for _,block in pairs(block_list) do
			if not block then
				return nil
			end
			if block.IsFinished() == true then
				return block
			end
		end
		PumpEvents()
	end
end

function PumpEvents()

	if Object then
		local service_wrapper = Object.Service_Wrapper
		if service_wrapper then
			service_wrapper()
		end
	end

	if Thread.Get_Current_ID() == -1 then
		ScriptError("%s -- Attempt to call PumpEvents from main thread!!!", tostring(Script))
	end

	if Pump_Service and type(Pump_Service) == "function" and Thread.Is_Pumping_Thread() then
		Pump_Service()
	end

	if ThreadValue("InPumpEvents") then
		ScriptError("%s -- Already in pump event!!", tostring(Script))
	end

	ThreadValue.Set("InPumpEvents", true)
	
	--DebugMessage("%s -- Entering yield.  Count: %d, Time: %.3f\n", tostring(Script), YieldCount, GetCurrentTime())
	YieldCount = YieldCount + 1
	coroutine.yield(true) -- yield here and return to 'C'
	--DebugMessage("%s -- Return from yield.  Count: %d, Time: %.3f\n", tostring(Script), YieldCount, GetCurrentTime())
	
	CurrentEvent = GetEvent()
	while CurrentEvent do
		ScriptMessage("%s -- Pumping Event: %s.", tostring(Script), tostring(CurrentEvent))
		EventParams = GetEvent.Params()
		if EventParams then
			CurrentEvent(unpack(EventParams))
		else 
			CurrentEvent()
		end
		
		if Script.Debug_Should_Issue_Event_Alert() and DebugEventAlert then
			DebugEventAlert(CurrentEvent, EventParams)
		end
		
		CurrentEvent = GetEvent()
	end
	ThreadValue.Set("InPumpEvents", false)
end

function TestValid(wrapper)
	if wrapper == nil then
		return false
	end

	if wrapper.Is_Valid == nil then
		return false
	end

	return wrapper.Is_Valid()
end

function Clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

function Min(a, b)
	if a <= b then
		return a
	else
		return b
	end
end

function Max(a, b)
	if a >= b then
		return a
	else
		return b
	end
end

-- Nasty hack of a floor function to be replaced if a math library floor funciton is exposed
function Dirty_Floor(val)
	return tonumber(string.format("%d", val)) -- works on implicit string to int conversion
end

-- Machine independent modulus function 
function Simple_Mod(a,b)
	-- return a-b*Dirty_Floor(a/b)
	-- changing it to use the wrapped PGMath fmod function
	return Math.mod(a,b)
end

-- Braindead rounding
function Simple_Round(num, places)
	return tonumber(string.format("%." .. (places or 0) .. "f", num))
end

-- Utility function to help declare enumerations.
function Declare_Enum(svar)
	if svar then 
		EnumVar = svar
	else
		EnumVar = EnumVar + 1
	end
	return EnumVar
end

-- Returns if something happened, given a % chance
function Chance(seed, percent)
	roll = Simple_Mod((seed + 1), 100)
	is_allowed = roll < percent
	DebugMessage("%s -- seed:%d percent:%d roll:%d is_allowed:%s", tostring(Script), seed, percent, roll, tostring(is_allowed))
	return is_allowed
end

-- If the item is in the table, returns its index. 
-- If it isn't there, returns nil.
function Table_Find(array, findme)
	for i=1,table.getn(array) do
		if array[i] == findme then
			return i
		end
	end
	return nil
end

function GetCurrentMinute()
	--return math.floor(GetCurrentTime()/60)
	return Dirty_Floor(GetCurrentTime()/60)
end

-- Every X seconds, the AI will have a new opportunity to see if it's allowed to use an ability
function GetAbilityChanceSeed()
	return Dirty_Floor(GetCurrentTime()/10) + 9
end

function GetChanceAllowed(difficulty)
	chance = 60
	if difficulty == "Easy" then
		chance = 20
	elseif difficulty == "Hard" then
		chance = 100
	end
	return chance
end


function PlayerSpecificName(player_object, var_name)
--	ret_value = tostring(player_object.Get_ID()) .. "_" .. var_name
--	DebugMessage("%s -- creating player specific string %s.", tostring(Script), ret_value)
--	return ret_value
        return (tostring("PLAYER" .. player_object.Get_ID()) .. "_" .. var_name)
end

function Pre_Save_Callback()
	non_persistent_tables = {
        PGObjectives_Listeners
	}

	for _, ptab in pairs(non_persistent_tables) do
		local mt = getmetatable(ptab)
        if mt == nil then
            mt = {}
            setmetatable(ptab, mt)
        end
		mt.__persist = false
	end
end

function Flush_G()

	entries_for_deletion = {}
	
	--Define the set of tables that we had better keep around
	very_important_tables = {
								_LOADED,
								_REQUIRED_FILES,
								package,
								coroutine,
								string,
								LuaWrapperMetaTable,
								LuaLightMetaTable,
								_G,
								security,
								jit,
								table,
								BehaviorNameTable,
								entries_for_deletion,
								Interface,								
								KeyboardGameCommands
							}
	
	--Silly thing is nil (we think) if we try to add it earlier
	table.insert(very_important_tables, very_important_tables)

	--Iterate all globals
	for i,g_entry in pairs(_G) do
	
		if type(g_entry) == "table" then
			--Tables are inherently unsafe: who knows what might be in there?
			--If they're not in the list of things we must keep then they go.
			
			for j,important_entry in pairs(very_important_tables) do
				if important_entry == g_entry then
					keep_table = true
				end
			end
			if not keep_table then
				table.insert(entries_for_deletion, i)
			end
			
			keep_table = nil
			
		elseif type(g_entry) == "userdata" then
			--Some User Data (e.g. our code functions) should be kept, but some is very, very dangerous.
			--Query the object to see whether it's safe to persist.
	
			if g_entry.Is_Pool_Safe and not g_entry.Is_Pool_Safe() then
				table.insert(entries_for_deletion, i)
			end
	
		end
		
	end
	
	for i,bad_entry in pairs(entries_for_deletion) do
		_G[bad_entry] = nil
	end
	
	entries_for_deletion = nil
	very_important_tables = nil

end



-- -----------------------------------------------------------------------------------------------------------------
-- Iterate through a table, and removing any nil or invalid objects.
-- -CHRISB 6/26/2006
-- ------------------------------------------------------------------------------------------------------------------
function Remove_Invalid_Objects(objects)
	local n = table.getn(objects)
	if n > 0 then
		for i=n,1,-1 do
			if not TestValid(objects[i]) then
				table.remove(objects, i)
			end
		end
	end
	
	return objects
end



-- -----------------------------------------------------------------------------------------------------------------
-- Ensure that all results from Find_All_Objects_Of_Type are playable units, not hard points or team sub-objects.
-- ------------------------------------------------------------------------------------------------------------------

function Find_All_Parent_Units(...)

	local unit_table = Find_All_Objects_Of_Type(unpack(arg))
	local sort_table = {}
	for _, unit in pairs(unit_table) do
		sort_table[Get_Root_Object(unit)] = true
	end
	unit_table = {}
	for unit, _ in pairs(sort_table) do
		table.insert(unit_table, unit)
	end
	return unit_table
end

-- Does the player match the passed in faction name?
-- 10/17/2006 3:06:01 PM -- BMH
function Is_Player_Of_Faction(player, faction_name)
	local faction = Find_Player(faction_name)
	return faction and player and player.Get_Faction_Name() == faction.Get_Faction_Name()
end

 
-------------------------------------------------------------------------------
-- Lua's built-in table.sort() function only sorts arrays of primitives
-- (strings and numbers).  This function allows the caller to sort an array
-- of maps, by specifying the array, which map attribute to sort by, and 
-- optionally a comparator function for that attribute.
--
-- For example:
--
--		t1 = {}
--		t1.Name = "hrtuip"
--		t1.Label = "T1_LABEL"
--		t2 = {}
--		t2.Name = "asgyu"
--		t2.Label = "T2_LABEL"
--		t3 = {}
--		t3.Name = "dfniuo"
--		t3.Label = "T3_LABEL"
--	
--		local the_list = {
-- 			t4,
--   		t1,
--   		t3,
--   		t5,
--   		t2,
--  	}
--
--   	sorted_list = Sort_Array_Of_Maps(the_list, "Name")
--
-- Printing out "sorted_list" will result in:
--
--		T2_LABEL: asgyu
--		T3_LABEL: dfniuo
--		T1_LABEL: hrtuip
--
-- NOTE: This function assumes a 0-based array instead of 1-based.
--
-- NOTE: Since this function is based upon Lua's table.sort() function,
-- it requires that the values found under the sort attribute cannot be tables
-- themselves.  In fact they must be strings or numbers (not wide strings).
-- If you want the function to automatically convert the attribute to a string,
-- set the force_sort_attrib_string parameter to true.
--
--
-- array - REQUIRED:  This function expects that array is an array of map
--		   tables which ALL contain the attribute specified by sort_attrib.
--
-- sort_attrib - REQUIRED:  The table attribute by which to sort.
--
-- force_sort_attrib_string - OPTIONAL:  Will cause the function to 
--							  automatically convert the sort attribute to
--							  a string suitable for Lua's table.sort() function.
--
-- comparator - OPTIONAL:  A Lua function which compares two instances of the
--				attribute specified by sort_attrib.
--
-- Returns an array of map tables whose membership is exactly that of array,
-- but whose elements are sorted by the sort_attrib.
-------------------------------------------------------------------------------
function Sort_Array_Of_Maps(array, sort_attrib, force_sort_attrib_string, comparator)

	local size = table.getn(array)

	-- Build a dictionary of the array, keyed on the sort attribute, 
	-- as well as an array of the attributes themselves, which will be sorted later.
	local dictionary = {}
	local attribs = {}

	for i = 1,size do
		local member = array[i]
		if (force_sort_attrib_string) then
			local tmp = tostring(member[sort_attrib]) 
			dictionary[tmp] = member
			attribs[i] = tmp
		else
			dictionary[member[sort_attrib]] = member
			attribs[i] = member[sort_attrib]
		end
		member = dictionary[member[sort_attrib]]
	end


	-- Sort the attribs
	if (comparator == nil) then
		table.sort(attribs)
	else
		table.sort(attribs, comparator)
	end


	-- Build the result
	local result = {}

	for i = 1,size do
		local lookup = attribs[i]
		local member = dictionary[lookup]
		result[i] = member
	end

	return result

end


-------------------------------------------------------------------------------
-- Split function from the Lua Wiki site:  
--	http://lua-users.org/wiki/StringRecipes
-- Author unknown.
-------------------------------------------------------------------------------
function String_Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

-------------------------------------------------------------------------------
-- Deep copy function from the Lua Wiki site:  
--	http://lua-users.org/wiki/CopyTable
-- Author DavidManura.
-------------------------------------------------------------------------------
--[[
	This is take from http://lua-users.org/wiki/CopyTable

	table.copy( t )

	This function returns a deep copy of a given table.
	The code properly handles the case where the original table
	nests another table multiple times, in which case only a
	single copy of the nested table is made.  This code does not
	deep copy userdata or lightuserdata since it does not have
	knowledge how to do that.

	Compatible with Lua 5.0 and 5.1.
]]--
function table.copy( t, _lookup_table )
	-- Note: _lookup_table is nil except when this function
	--   recursively calls itself. _lookup_table is used for
	--   ensuring that the copies of nested tables with the
	--   same identity also have the same identity to each other.
	_lookup_table = _lookup_table or {}
	local tcopy = {}
	if not _lookup_table[t] then
		_lookup_table[t] = tcopy
	end
	for i,v in pairs( t ) do
		if type( i ) == "table" then
			if _lookup_table[i] then
				i = _lookup_table[i]
			else
				i = table.copy( i, _lookup_table )
			end
		end
		if type( v ) ~= "table" then
			tcopy[i] = v
		else
			if _lookup_table[v] then
				tcopy[i] = _lookup_table[v]
			else
				tcopy[i] = table.copy( v, _lookup_table )
			end
		end
	end
	return tcopy
end

--[[
	table.compare( t1, t2 )

	This function does a deep compare of two tables.
	The code properly handles the case where the original table
	nests another table multiple times.
]]--
function table.compare(t1, t2)
	for key, value in pairs(t1) do
		if type(value) == "table" then
			if table.compare(value, t2[key]) then
				return true
			end
		elseif t2[key] ~= value then
			return true
		end
	end
end

-- -----------------------------------------------------------------------------------------------------------------
-- Persist_Wrapper_For_Signal_Registration
-- Called by code to ensure that any wrapper that has a signal handler registered
-- will not be garbage collected during script lifetime
-- ------------------------------------------------------------------------------------------------------------------
function Persist_Wrapper_For_Signal_Registration(wrapper)
	if not _SignalPersistentWrappers then
		_SignalPersistentWrappers = {}
	end
	_SignalPersistentWrappers[wrapper] = wrapper
end
