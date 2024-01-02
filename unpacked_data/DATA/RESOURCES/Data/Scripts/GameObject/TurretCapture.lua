-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/TurretCapture.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/TurretCapture.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Steve_Copeland $
--
--            $Change: 70126 $
--
--          $DateTime: 2007/05/10 11:00:40 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	if TestValid(Object) then 
		Owner = Object.Get_Owner()
		Object.Register_Signal_Handler(On_Owner_Changed, "OBJECT_OWNER_CHANGED")
		OwnerScript = Owner.Get_Script()
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Owner_Changed
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function On_Owner_Changed(obj, old_owner)
	if not TestValid(Object) then 
		MessageBox("Invalid Object")
	end

	new_owner = Object.Get_Owner()
	pos = Object.Get_Position()

	replacement_turret_type = Find_Object_Type("Neutral_Turret_Captured_Novus")
	if new_owner == Find_Player("Alien") then
		replacement_turret_type = Find_Object_Type("Neutral_Turret_Captured_Hierarchy")
	elseif new_owner == Find_Player("Masari") then
		replacement_turret_type = Find_Object_Type("Neutral_Turret_Captured_Masari")
	end

	Object.Despawn()
	Spawn_Unit(replacement_turret_type, pos, new_owner)  

end



-- Registering the behavior.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
