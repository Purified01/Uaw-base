if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[107] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Generic_Filtered_Ranged_AE.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Generic_Filtered_Ranged_AE.lua $
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


--A behavior that allows AI to take advantage of opportunities to trigger ranged area effect abilities.

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	recent_units = {}
	HasRegisteredRangeCheck = false
end

local function Behavior_Service()

	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() then
		if not HasRegisteredRangeCheck then
			Object.Event_Object_In_Range(Unit_Filter, RANGED_AE.COLLECT_RANGE)
			HasRegisteredRangeCheck = true
		end
		
		if Object.Is_Ability_Ready(RANGED_AE.ABILITY_NAME) and not Object.Is_Ability_Active(RANGED_AE.ABILITY_NAME) then
			ae_target, score = Find_Best_Local_Threat_Center(recent_units, RANGED_AE.AE_RANGE)
		
			if score and score >= RANGED_AE.MIN_SCORE then
				Object.Activate_Ability(RANGED_AE.ABILITY_NAME, true, ae_target)
				if RANGED_AE.SLEEP_TIME then
					Sleep(RANGED_AE.SLEEP_TIME)
				end
			end
		end
	
	end
	
	recent_units = {}	
	Sleep( 2.0 )
end

function Unit_Filter(self_obj, trigger_obj)

	if not trigger_obj.Get_Owner().Is_Enemy(Object.Get_Owner()) then
		return
	end
	
	if not trigger_obj.Is_Category(RANGED_AE.CATEGORY_FILTER) then
		return
	end
	
	if not recent_units[trigger_obj] then
		recent_units[trigger_obj] = trigger_obj
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
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
