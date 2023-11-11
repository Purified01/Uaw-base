-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Generic_Evasion_Unit_Behavior.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Generic_Evasion_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: James_Yarrow $
--
--            $Change: 84587 $
--
--          $DateTime: 2007/09/21 18:59:40 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")

ScriptShouldCRC = true


--A behavior that allows AI units with evasion abilities to turn them on when in danger

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	LastHealth = Object.Get_Health()

end

local function Behavior_Service()

	local health = Object.Get_Health()

	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() then

		if health < LastHealth and health <= GenericEvasion.UNIT_EVADE_AT_HEALTH and not Object.Is_Ability_Active(GenericEvasion.UNIT_ABILITY) then
			-- Evade !
			Object.Activate_Ability(GenericEvasion.UNIT_ABILITY,true)
		end
	end
	
	--Don't sleep - it will suppress any other LUA behavior attached to this unit
	--Sleep(0.5)

	LastHealth = health

end


my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)