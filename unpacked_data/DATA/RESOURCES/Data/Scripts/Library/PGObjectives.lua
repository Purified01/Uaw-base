-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGObjectives.lua#17 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGObjectives.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Mike_Lytle $
--
--            $Change: 80173 $
--
--          $DateTime: 2007/08/08 10:12:25 $
--
--          $Revision: #17 $
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
		local objs = game_mode_script.Call_Function("Get_Objectives")
		if not objs then
			return {}
		end
		return objs
	end

	return PGObjectives_Objectives
end

-- Create a new objective - returns a handle to the objective
function Add_Objective(...)
	-- If not in gamemode script, call into it instead
	local _text = string.format(...)
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		MessageBox("To do Add_Objective(), we need a story script. Also, the story script must do require(\"PGObjectives\").")
		return -1
	end
	if game_mode_script ~= Script then
		local ret = game_mode_script.Call_Function("Add_Objective", _text)
		if ret == nil then
			MessageBox("To do Add_Objective(), we need a story script. Also, the story script must do require(\"PGObjectives\").")
			return false
		end
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
		return game_mode_script.Call_Function("Set_Objective_Text", objective, _text)
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
		return game_mode_script.Call_Function("Set_Objective_Checked", objective, is_checked)
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
		return game_mode_script.Call_Function("Delete_Objective", objective, immediate)
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
		return game_mode_script.Call_Function("Reset_Objectives")
	end

	PGObjectives_Objectives = {}
	-- NOTE: intentionally don't reset index, so any old, now-invalid objective indexes don't point
	-- to something random

	Notify_Objective_Listeners()
end

-- Add a listener to get notified whenever objectives change.
-- Pass in your "Script" and the name of your callback function. 
function Add_Objectives_Listener(script, function_name)
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

-- Remove a listener.
function Remove_Objectives_Listener(script, function_name)
	-- If not in gamemode script, call into it instead
	local game_mode_script = Get_Game_Mode_Script()
	if not game_mode_script then
		return false
	end
	if game_mode_script ~= Script then
		return game_mode_script.Call_Function("Remove_Objectives_Listener", script, function_name)
	end

	for i, listener in pairs(PGObjectives_Listeners) do 
		if listener.script == script and listener.function_name == function_name then
			table.remove(PGObjectives_Listeners, i)
			return true
		end
	end
	return false
end

function Notify_Objective_Listeners(adding, obj_to_remove, update_display)
	local game_mode_script = Get_Game_Mode_Script()
	if game_mode_script ~= Script then
		return
	end

	-- TODO: remove listeners with dead scripts
	for i, listener in pairs(PGObjectives_Listeners) do 
		if TestValid(listener.script) then
			listener.script.Call_Function(listener.function_name, adding, remove_obj_at_index)
		end
	end
end

-- Check off an objective, then delete it after a delay
function Objective_Complete(objective, persist_it)
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
