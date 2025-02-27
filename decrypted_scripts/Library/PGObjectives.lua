if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[1] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[208] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGObjectives.lua#13 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGObjectives.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")

function Init_Objectives()

	PGObjectives_Objectives = {}
	PGObjectives_TopIndex = 0
	PGObjectives_Listeners = {}
	
end

-- Return a table with ALL objectives
function Get_Objectives()
	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return {}
	end
	if game_mode_script ~= Script then
		local objs = game_mode_script.Get_Async_Data("Objectives")
		
		if not objs and Is_Non_Render_Thread_Save_Game() then
			--Didn't get anything the new way?  If this is an old
			--save game, then double-check by doing the query the
			--old way.
			objs = game_mode_script.Call_Function("Get_Objectives")
		end
		
		if not objs then
			return {}
		end
		return objs
	end

	return PGObjectives_Objectives
end

-- Create a new objective - returns a handle to the objective
function Add_Objective(...)
	if ObjectivesSuspended then
		return false
	end
	
	-- If not in gamemode script, call into it instead
	local _text = string.format(...)
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		MessageBox("To do Add_Objective(), we need a story script. Also, the story script must do require(\"PGObjectives\").")
		return false
	end
	if game_mode_script ~= Script then
		--Can no longer modify objectives from UI script
		return false
	end

	local obj = {}
	obj.text = _text
	obj.checked = false
	PGObjectives_TopIndex = PGObjectives_TopIndex + 1
	obj.index = PGObjectives_TopIndex
	PGObjectives_Objectives[PGObjectives_TopIndex] = obj

	Notify_Objective_Listeners(true)	

	return PGObjectives_TopIndex
end

-- Update the text of an objective.
function Set_Objective_Text(objective, ...)
	local _text
	local arg1 = ...
	if arg1 and type(arg1) == "userdata" then
		_text = arg1
	else
		_text = string.format(...)
	end
	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return false
	end
	if game_mode_script ~= Script then
		--Can no longer modify objectives from UI script
		return false
	end

	local obj = PGObjectives_Objectives[objective]
	if obj then
		obj.text = _text
		Notify_Objective_Listeners()	
		return true
	end
	return false
end

-- Sets an objective checked or unchecked.
function Set_Objective_Checked(objective, is_checked)
	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return false
	end
	if game_mode_script ~= Script then
		--Can no longer modify objectives from UI script
		return false
	end

	local obj = PGObjectives_Objectives[objective]
	if obj then
		obj.checked = is_checked
		Notify_Objective_Listeners()	
		return true
	end
	return false
end

-- Remove an objective.
function Delete_Objective(objective, immediate)
	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return false
	end
	if game_mode_script ~= Script then
		--Can no longer modify objectives from UI script
		return false
	end

	if PGObjectives_Objectives[objective] then
		local old_obj = PGObjectives_Objectives[objective]
		PGObjectives_Objectives[objective] = nil
		Notify_Objective_Listeners(false, old_obj.index)	
		return true
	end
	return false
end

-- Remove ALL objectives.
function Reset_Objectives()
	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return
	end
	if game_mode_script ~= Script then
		--Can no longer modify objectives from UI script
		return false
	end

	PGObjectives_Objectives = {}
	-- NOTE: intentionally don't reset index, so any old, now-invalid objective indexes don't point
	-- to something random

	Notify_Objective_Listeners()
end

-- THIS FUNCTION IS DEPRECATED.  IT EXISTS ONLY FOR COMPATIBILITY WITH OLD SAVE GAMES.
function Add_Objectives_Listener(script, function_name)

	if not Is_Non_Render_Thread_Save_Game() then
		return
	end

	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return false
	end
	if game_mode_script ~= Script then
		return game_mode_script.Call_Function("Add_Objectives_Listener", script, function_name)
	end

	if PGObjectives_Listeners == nil then
		PGObjectives_Listeners = {}
   end

	-- Make sure this listener isn't already here.
	for i, listener in pairs(PGObjectives_Listeners) do 
		if listener.script == script and listener.function_name == function_name then
			return false
		end
	end

	-- Create the listener and add it.
	local listener = {}
	listener.script = script
	listener.script.Set_Persistable(false)
	listener.function_name = function_name
	table.insert(PGObjectives_Listeners, listener)
	return true
end

function Notify_Objective_Listeners(adding, obj_to_remove, update_display)
	local game_mode_script = Get_Game_Mode_Script()
	if game_mode_script ~= Script then
		return
	end

	Script.Set_Async_Data("Objectives", PGObjectives_Objectives)

	Get_Game_Mode_GUI_Scene().Raise_Event("Objectives_Changed", nil, { adding, remove_obj_at_index })
end

-- Check off an objective, then delete it after a delay
function Objective_Complete(objective, persist_it)
	if ObjectivesSuspended then
		return
	end
	
	Set_Objective_Checked(objective, true)
	
		-- Oksana: notify player of completed research
	Raise_Game_Event("Objective_Completed", Find_Player("local"))
	
	if not persist_it then
		Register_Timer(Timer_Delete_Objective, 10, objective)
	end
end

function Timer_Delete_Objective(objective)
	Delete_Objective(objective)
end

function Suspend_Objectives( on_off )
	if on_off then
		PGObjectives_Objectives = {}
		Script.Set_Async_Data("Objectives", PGObjectives_Objectives)
		Notify_Objective_Listeners()		
	end
	ObjectivesSuspended = on_off
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Objective_Complete = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Set_Objective_Text = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	Suspend_Objectives = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
