LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/WalkerPuzzleCommon.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/WalkerPuzzleCommon.lua $
--
--    Original Author: Brian Hayes
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

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Defines a set of function common to all Walker Puzzles.
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Common puzzle init.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Common_Puzzle_Init()
	PuzzleActive = true
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Common puzzle cleanup
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Common_Puzzle_Clean_Up()
	PuzzleActive = nil
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Allow scripts to listen for Walker destruction
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Register_For_Walker_Death(script, function_name)
	--check if arguments are valid
	if function_name==nil or script==nil then
		return
	end

	if WalkerDeathCallbacks == nil then
		WalkerDeathCallbacks = {}
	end

	table.insert(WalkerDeathCallbacks, {script, function_name})
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Allow scripts to listen for hp_type destruction
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Register_For_HP_Destroyed_Callback(hp_type, script, function_name)
	
	--check if arguments are valid
	if hp_type==nil or function_name==nil or script==nil then
		return
	end	
	
	
	--declare the new row for this hp_type
	if HP_Callback_Registration_Table[hp_type] == nil then
		HP_Callback_Registration_Table[hp_type] = {}
	end
	
		
	--local temp_table = {}
	--temp_table.script = script
	--temp_table.function_name = function_name
	table.insert(HP_Callback_Registration_Table[hp_type], {script, function_name})
	
	
	--register for sgnal if this hp already exists on the walker
	hp_list = Object.Find_All_Hard_Points_Of_Type(hp_type)
	if hp_list then
		for _, obj in pairs(hp_list) do
			obj.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
		end
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Kills walkers...use object.Get_Script().Call_Function("Kill_Walker", Script, nil)
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Kill_Walker()
	if PuzzleActive and Object_Is_Dead ~= true then
		Object_Is_Dead = true
		Create_Thread("Thread_Walker_Death")
		return true
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Allow scripts to listen for production completion event
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Register_For_Production_Complete_Callback(obj_type, script, function_name)
	
	--check if arguments are valid
	if obj_type==nil or function_name==nil or script==nil then
		return
	end	
	
	
	--declare the new row for this hp_type
	if Production_Callback_Registration_Table[obj_type] == nil then
		Production_Callback_Registration_Table[obj_type] = {}
	end
	
		
	table.insert(Production_Callback_Registration_Table[obj_type], {script, function_name})
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Production completion event
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Behavior_On_Production_Complete(event, object)
	
	if TestValid(object) then

		for obj_type, call_table in pairs(Production_Callback_Registration_Table) do
			if object.Get_Type() == obj_type then 
				for _, call_item in pairs(call_table) do
					call_item[1].Call_Function(call_item[2], object)
				end
			end
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Index_To_Key_Table -- Convert an lua array into a keyed table of booleans.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Index_To_Key_Table(itable)
	local ret_table = {}
	if itable == nil then return ret_table end
	for _, tval in pairs(itable) do
		ret_table[tval] = true
	end
	return ret_table
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Table_Merge -- Merge source table into dest table.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Table_Merge(dest, source)
	for k,v in pairs(source) do
		dest[k] = v
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Walker_Set_Invulnerable -- Set this walker as invulnerable, but remember which hardpoints are vulnerable so when we turn off
--	                           invulnerability we only enable the correct hardpoints.
-- 11/16/2006 4:06:34 PM -- BMH
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Walker_Set_Invulnerable(on_off)

	if Walker_Invulnerable == nil or Walker_Invulnerable ~= on_off then
		if on_off then
			Walker_Invulnerable_Points = {}
			local hp_table = Object.Get_All_Hard_Points()
			for i,hard_point in pairs(hp_table) do
				if hard_point.Has_Behavior(62) == false then
					table.insert(Walker_Invulnerable_Points, hard_point)
					--hard_point.Make_Invulnerable(true)
					hard_point.Set_Cannot_Be_Killed(true)
				end
			end
		else
			if Walker_Invulnerable_Points == nil then return end
			for i,hard_point in pairs(Walker_Invulnerable_Points) do
				--hard_point.Make_Invulnerable(false)
				hard_point.Set_Cannot_Be_Killed(false)
			end
			Walker_Invulnerable_Points = {}
		end

		Walker_Invulnerable = on_off
	end
end




function Destroy_Walker_Object( object, final_blow_player, final_blow_object_type)
	if object then
		object.Make_Invulnerable(false)
		object.Set_Cannot_Be_Killed(false)
		
		if not final_blow_player then
			final_blow_player = false
		end
		
		if not final_blow_object_type then
			final_blow_object_type = false
		end
		
		object.Take_Damage(9999999999, "Damage_Default", final_blow_player, final_blow_object_type)  -- kill it
	end
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Behavior_On_Production_Complete = nil
	Common_Puzzle_Clean_Up = nil
	Common_Puzzle_Init = nil
	Destroy_Walker_Object = nil
	Index_To_Key_Table = nil
	Register_For_Production_Complete_Callback = nil
	Table_Merge = nil
	Kill_Unused_Global_Functions = nil
end
