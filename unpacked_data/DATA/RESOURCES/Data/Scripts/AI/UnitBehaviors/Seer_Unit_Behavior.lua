-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Seer_Unit_Behavior.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Seer_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 84404 $
--
--          $DateTime: 2007/09/20 13:10:30 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	SeerThreadID = nil
	
end

local function Behavior_Service()
	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not SeerThreadID then
			SeerThreadID = Create_Thread("Seer_Thread")
		end
	elseif DefensiveThreadID then
		Create_Thread.Kill(SeerThreadID)
		SeerThreadID = nil
	end
end

--Thread this so that the slow service rate doesn't interfere with other LUA behaviors
function Seer_Thread()

	local ally_in_need
	
	while true do

		if not AIDefensiveIsRetreating and not AntiCrushUnitBehaviorActionTaken then
			 ally_in_need = Scan_For_Ally_In_Need(ally_in_need)
			if TestValid(ally_in_need) then
				Object.Move_To(ally_in_need)
			end
		end

		Sleep(2.5 + GameRandom.Get_Float(0.0,1.0))
		
	end

end

function Scan_For_Ally_In_Need( last_obj )
	
	local player = Object.Get_Owner()
	
	if not TestValid(player) then
		return nil
	end
	
	local best_target = nil
	local best_value = 999999.0
	
	local obj_list = Find_All_Objects_Of_Type( Object, 400.0, "Small + ~Resource + ~Resource_INST | CanAttack + ~Resource + ~Resource_INST | Stationary + ~Bridge + ~Resource + ~Resource_INST | Hardpoint" )
	
	if obj_list then
		for _, unit in pairs (obj_list) do
			if TestValid(unit) and not unit.Is_Death_Clone() then
				if ( unit.Get_Attribute_Value("Virus_Level") > 0.0 and player.Is_Ally(unit.Get_Owner()) ) or
						unit.Get_Attribute_Integer_Value("Object_Original_Owner_ID") == player.Get_ID()
				then
					local value = 500.0 - GameRandom(1,100) - Object.Get_Distance(unit)
					if last_obj == unit then
						value = 0.0
					end
					if value < best_value then
						best_value = value
						best_target = unit
					end
				end
			end
		end
	end
	
	return best_target
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)