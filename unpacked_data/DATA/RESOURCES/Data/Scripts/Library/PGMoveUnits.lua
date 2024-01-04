-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGMoveUnits.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGMoveUnits.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 64598 $
--
--          $DateTime: 2007/03/06 15:03:58 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")



-- This will move an entire unit list with simultaneous orders.  
-- They will block as a whole and pass when the last unit's move is complete.
function Formation_Move(unit_list, target)
	if type(unit_list) == "table" then
		Remove_Invalid_Objects(unit_list)
		for k, unit in pairs(unit_list) do -- An individual unit is needed to reach the Move_To function.
			BlockOnCommand(unit.Move_To(unit_list, target))  -- Note that the unit list is passed.
			return
		end
		DebugMessage("%s -- Formation_Move, unit_list is empty", tostring(Script))
	elseif type(unit_list) == "userdata" then
		BlockOnCommand(unit_list.Move_To(target))
	else
		DebugMessage("%s -- Formation_Move, expected table or userdata got %s", tostring(Script), tostring(unit_list))
	end
end

function Formation_Attack(unit_list, target)
	if type(unit_list) == "table" then
		Remove_Invalid_Objects(unit_list)
		for k, unit in pairs(unit_list) do
			BlockOnCommand(unit.Attack_Target(unit_list, target))
			return
		end
		DebugMessage("%s -- Formation_Attack, unit_list is empty", tostring(Script))
	elseif type(unit_list) == "userdata" then
		BlockOnCommand(unit_list.Attack_Target(target))
	else
		DebugMessage("%s -- Formation_Attack, expected table or userdata got %s", tostring(Script), tostring(unit_list))
	end
end

function Formation_Attack_Move(unit_list, target)
	if type(unit_list) == "table" then
		Remove_Invalid_Objects(unit_list)
		for k, unit in pairs(unit_list) do
			BlockOnCommand(unit.Attack_Move(unit_list, target))
			return
		end
		DebugMessage("%s -- Formation_Attack, unit_list is empty", tostring(Script))
	elseif type(unit_list) == "userdata" then
		BlockOnCommand(unit_list.Attack_Move(target))
	else
		DebugMessage("%s -- Formation_Attack, expected table or userdata got %s", tostring(Script), tostring(unit_list))
	end
end


function Formation_Guard(unit_list, target)
	if type(unit_list) == "table" then
		Remove_Invalid_Objects(unit_list)
		for k, unit in pairs(unit_list) do
			BlockOnCommand(unit.Guard_Target(unit_list, target))
			return
		end
		DebugMessage("%s -- Formation_Guard, unit_list is empty", tostring(Script))
	elseif type(unit_list) == "userdata" then
		BlockOnCommand(unit_list.Guard_Target(target))
	else
		DebugMessage("%s -- Formation_Guard, expected table or userdata got %s", tostring(Script), tostring(unit_list))
	end
end

function Hunt(single_unit_or_table, priorities, allow_wander, respect_fog, constraint_center, constraint_radius)
	if type(single_unit_or_table) == "table" then
		Remove_Invalid_Objects(single_unit_or_table)
		if #single_unit_or_table == 0 then
			return
		end
	elseif not TestValid(single_unit_or_table) then
		return
	end

	local block = _Hunt(single_unit_or_table, priorities, allow_wander, respect_fog, constraint_center, constraint_radius)
	Create_Thread("Hunt_Blocking_Thread", block)
end

function Hunt_Blocking_Thread(block)
	BlockOnCommand(block)
end

function Full_Speed_Move(unit_list, target)
	if type(unit_list) == "table" then
		Remove_Invalid_Objects(unit_list)
		for k, unit in pairs(unit_list) do
			return unit.Parameterized_Move_Order(unit_list, target, "No_Formup")
		end
	elseif type(unit_list) == "userdata" then
		return unit_list.Parameterized_Move_Order(target, "No_Formup")
	end
end


