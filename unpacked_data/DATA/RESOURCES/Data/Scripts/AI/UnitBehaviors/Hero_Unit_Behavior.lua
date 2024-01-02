-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Hero_Unit_Behavior.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Hero_Unit_Behavior.lua $
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

	HeroThreadID = nil
	HeroRetreatDone = false
	
	if HeroUnitBehavior == nil then
		HeroUnitBehavior = {}
	end

end

local function Behavior_Service()
	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not HeroThreadID then
			HeroThreadID = Create_Thread("Hero_Thread")
		end
	elseif HeroThreadID then
		Create_Thread.Kill(HeroThreadID)
		HeroThreadID = nil
	end
end

--Thread this so that the slow service rate doesn't interfere with other LUA behaviors
function Hero_Thread()

	-- sleep for 3 minutes before checking the first time
	Sleep(180.0)

	while true do

		if not HeroRetreatDone and HeroUnitBehavior.RetreatAbility and Object.Is_Ability_Ready(HeroUnitBehavior.RetreatAbility) and Check_For_Retreat() then
			Object.Activate_Ability(HeroUnitBehavior.RetreatAbility,true,Object.Get_Position())
			HeroRetreatDone = true
		end
		
		Sleep(15.0)
	end
end

function Check_For_Retreat()

	local player = Object.Get_Owner()
	if not TestValid(player) then
		return false
	end
	
	local obj_list = Find_All_Objects_Of_Type( "Small | CanAttack + ~Resource + ~Resource_INST | Stationary + ~Bridge + ~Resource + ~Resource_INST" )
	if obj_list then
		for _, unit in pairs (obj_list) do
			if TestValid(unit) then
				if player.Is_Enemy(unit.Get_Owner()) then
					if not unit.Is_Cloaked() and not unit.Is_Death_Clone() then
						-- found a valid unit, no retreat
						return false
					end
				else
					local unit_type = unit.Get_Type()
					if TestValid(unit_type) and not unit.Is_Death_Clone() and ( unit.Is_Category("Stationary") or unit_type.Get_Type_Value("Is_Tactical_Base_Builder") ) then
						-- we own a structure or builder, don't run
						return false
					end
				end
			end
		end
	end
	
	-- nothing we can fight, retreat
	return true
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)