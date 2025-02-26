LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Generic_Filtered_PBAOE.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Generic_Filtered_PBAOE.lua $
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

require("PGBase")

cap_targetScriptShouldCRC = true

--A behavior that allows AI to take advantage of opportunities to trigger point blank area effect abilities.
--May be extended in the future to divert units to optimize AE use.

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	recent_units = {}
	enemy_count = 0
	HasRegisteredRangeCheck = false
end

local function Behavior_Service()

	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() then
		if not HasRegisteredRangeCheck then
			Object.Event_Object_In_Range(Unit_Filter, FILTERED_PBAOE.COLLECT_RANGE)
			HasRegisteredRangeCheck = true
		end
		
		if enemy_count >= FILTERED_PBAOE.MIN_TARGETS then
			Object.Activate_Ability(FILTERED_PBAOE.ABILITY_NAME, true)
		end
	
	end
	
	recent_units = {}	
	enemy_count = 0
end

function Unit_Filter(self_obj, trigger_obj)

	if not trigger_obj.Get_Owner().Is_Enemy(Object.Get_Owner()) then
		return
	end
	
	if not trigger_obj.Is_Category(FILTERED_PBAOE.CATEGORY_FILTER) then
		return
	end

	if trigger_obj.Is_Category("Resource | Resource_INST | Bridge | Stationary + Insignificant") then
		return
	end
	
	if FILTERED_PBAOE.NOT_CATEGORY_FILTER and not trigger_obj.Is_Category(FILTERED_PBAOE.NOT_CATEGORY_FILTER) then
		return
	end
	
	if not recent_units[trigger_obj] then
		recent_units[trigger_obj] = trigger_obj
		enemy_count = enemy_count + 1
	end

end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
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
