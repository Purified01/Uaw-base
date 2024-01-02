-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienGrunt.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienGrunt.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Justin_Ficarrotta $
--
--            $Change: 40864 $
--
--          $DateTime: 2006/04/10 18:48:55 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- States: [Inactive], Active
local state = "Inactive"

local function Behavior_Init()
	if Object then 
		Object.Event_Object_In_Range(my_behavior.Object_In_Range, CIVILIAN_TRIGGER_RANGE, "CIVILIAN_URBAN_A") 
	end
end

local function Behavior_Service()

end

local function Behavior_Object_In_Range(prox_object, object)
	if (state == "Active") then
		MessageBox("Attacking Civilian")
		target_civilian = Find_First_Object("CIVILIAN_URBAN_A")
		Object.Attack_Move(target_civilian)
	end
end

local function Activate() 
	state = "Active"
end 

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Object_In_Range = Behavior_Object_In_Range
my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
