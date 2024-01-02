-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGStateMachine.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGStateMachine.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 78036 $
--
--          $DateTime: 2007/07/23 17:04:56 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgcommands")

ScriptShouldCRC = true;

--
-- Define_State -- Define a new state in the state machine table.
--
-- @param state This is the tag used to identify the state.  Usually 
--			a text value or a number
-- @param function_value This is the function value that will process
--			all the messages associated with the given state.
-- @since 4/22/2005 7:26:01 PM -- BMH
-- 
function Define_State(state, function_value)
	local curproc = StateMachine[state]
	if curproc == nil then
		StateMachineIndexes[DefineStateIndex] = state
		StateMachineIndexLookup[state] = DefineStateIndex
		DefineStateIndex = DefineStateIndex + 1
	end
	
	StateMachine[state] = function_value
	
	if NextState == nil then
		NextState = state
	end
end


--
-- Advance_State -- Advance to the next state based on the 
-- 	order of state definition
--
-- @since 4/22/2005 7:26:01 PM -- BMH
-- 
function Advance_State()
	NextState = StateMachineIndexes[CurrentStateIndex + 1]
end


--
-- Set_Next_State -- Set the next state to transition to.
--
-- @param state tag specifying the state to transition to.
-- @since 4/22/2005 7:26:01 PM -- BMH
-- 
function Set_Next_State(state)
	if state == nil or StateMachine[state] ~= nil then
		NextState = state
	else
		MessageBox("%s -- Set_Next_State can't find state named %s", tostring(Script), state)
	end
end


--
-- Get_Current_State -- Returns what the current state is.
--
-- @return object detailing what the current state is.
-- @since 4/22/2005 7:12:14 PM -- BMH
-- 
function Get_Current_State()
	return CurrentState
end


--
-- Get_Next_State -- Returns what the next state will be.
--
-- @return object detailing what the next state will be.
-- @since 4/22/2005 7:12:14 PM -- BMH
-- 
function Get_Next_State()
	return NextState
end


--
-- Process_States -- This function is called to advance the State Machine through it's states
--
-- @since 4/22/2005 7:12:14 PM -- BMH
-- 
function Process_States()

	while NextState ~= nil do
		_curproc = StateMachine[NextState]
		if type(_curproc) == "function" then
			CurrentState = NextState
			CurrentStateIndex = StateMachineIndexLookup[CurrentState]
			_curproc(OnEnter)
			while CurrentState == NextState do
				_curproc(OnUpdate)
				if CurrentState == NextState then
					PumpEvents()
				end
			end
			_curproc(OnExit)
			DebugMessage("%s -- Advancing state from %s to %s.", tostring(Script), tostring(CurrentState), tostring(NextState))
		else
			ScriptError("%s -- Invalid State: %s, Function: %s", tostring(Script), tostring(NextState), tostring(_curproc))
			NextState = nil
		end
	end
end


--
-- Since we need a hero scientist to access the research panel, we must make sure we instantiate one at the beginning of 
-- the global game and whenever a new tactical game starts.
--
function Create_Science_Officers()
	if Script ~= Get_Game_Mode_Script() then return end
	
	--No research in strategic
	if Get_Game_Mode() == "Strategic" then return end
	
	local factions = Find_Player.Get_Playable_Faction_Names()
	for _, faction_name in pairs(factions) do
		Create_Officer(faction_name)
	end
end


--
-- If appropriate, create the science officer for each of the players of the specified faction.
--
function Create_Officer(faction_name)
	
	if faction_name == nil then return end
	local type_name = faction_name.."_Hero_Chief_Scientist_PIP_Only"
	-- we want to make sure that all the players of this faction have a science officer (so that they can access their
	-- research tree)
	if Find_Object_Type(type_name) == nil then return end
	local players = Find_Player.All(faction_name)
	local science_guys = Find_All_Objects_Of_Type(type_name)
	
	-- if a player already has a science officer, remove it from the list.
	for _, officer in pairs(science_guys) do
		local owner = officer.Get_Owner()
		players = Remove_From_Table(players, owner)
	end
	
	if #players > 0 then 
		local position = Create_Position() -- creates (0,0,0)
		local science_type = Find_Object_Type(type_name)
		for _, player in pairs(players) do
			Create_Generic_Object(science_type, position, player)	
		end
	end
end


--
-- Removes, if possible, the specified object from the given table
--
function Remove_From_Table(a_table, object_to_remove)
	for idx, elt in pairs(a_table) do
		if elt == object_to_remove then 
			table.remove(a_table, idx)
			break
		end		
	end	
	return a_table
end


--
-- Base_Definitions -- This function is called once when the script is first created.
--
-- @since 4/22/2005 6:04:55 PM -- BMH
-- 
function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	Common_Base_Definitions()

	StateMachine = {}
	StateMachineIndexes = {}
	StateMachineIndexLookup = {}
	OnEnter = 1
	OnUpdate = 2
	OnExit = 3
	CurrentStateIndex = 1
	DefineStateIndex = 1
	NextState = nil
	CurrentState = nil
	_curproc = nil
	StoryModeEvents = nil

	-- This controls how often the script is serviced.
	-- So try to process 5 times a second
	ServiceRate = 0.2

	if Definitions then
		Definitions()
	end

	if PG_Story_Mode_Init then
		PG_Story_Mode_Init()
	end
	
	Create_Thread("Create_Science_Officers")
end


--
-- main -- This is the main thread function for this script.
-- Upon return from this function the script will finish and be
-- destroyed by the system.
--
-- @since 4/22/2005 6:04:55 PM -- BMH
-- 
function main()

	-- Enter your list of commands to execute here...
	Process_States()

	DebugMessage("%s -- Exiting.", tostring(Script))
	-- ScriptExit will end the script no matter what state it's in.
	ScriptExit()
end

