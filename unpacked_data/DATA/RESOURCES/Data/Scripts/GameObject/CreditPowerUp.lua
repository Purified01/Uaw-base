-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/CreditPowerUp.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/CreditPowerUp.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 39910 $
--
--          $DateTime: 2006/03/23 18:29:56 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

local function Behavior_Init()
	if Object then Object.Event_Object_In_Range(my_behavior.Object_In_Range, 20) end
end

local function Behavior_Service()

end

local function object_in_range_handler(prox_object, object)

	local player = object.Get_Owner()
	if player.Is_Human() then
	
		player.Give_Money(CREDIT_POWER_UP_AMOUNT)
		-- Cancel the object in range event from signaling anymore.	
		Object.Cancel_Event_Object_In_Range(my_behavior.Object_In_Range)

		Object.Despawn()
	end
end

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
my_behavior.Object_In_Range = Behavior_Object_In_Range
Register_Behavior(my_behavior)
