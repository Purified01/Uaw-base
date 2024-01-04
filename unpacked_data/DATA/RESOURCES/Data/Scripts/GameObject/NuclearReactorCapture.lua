-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/NuclearReactorCapture.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/NuclearReactorCapture.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Pat_Pannullo $
--
--            $Change: 73588 $
--
--          $DateTime: 2007/06/19 10:27:48 $
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

	replacement_reactor_type = Find_Object_Type("Neutral_Nuclear_Reactor")
	if new_owner == Find_Player("Alien") then
		replacement_reactor_type = Find_Object_Type("Neutral_Nuclear_Reactor_Hierarchy")
	elseif new_owner == Find_Player("Masari") then
		replacement_reactor_type = Find_Object_Type("Neutral_Nuclear_Reactor_Masari")
	elseif new_owner == Find_Player("Novus") then
		replacement_reactor_type = Find_Object_Type("Neutral_Nuclear_Reactor_Novus")
	end

	Object.Despawn()
	Spawn_Unit(replacement_reactor_type, pos, new_owner)  

end



-- Registering the behavior.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
