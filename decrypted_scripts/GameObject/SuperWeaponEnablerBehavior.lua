-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SuperWeaponEnablerBehavior.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SuperWeaponEnablerBehavior.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Keith_Brors $
--
--            $Change: 67530 $
--
--          $DateTime: 2007/04/11 11:11:55 $
--
--          $Revision: #6 $
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
		PlayerDataUpdated = false
		Owner = Object.Get_Owner()
		-- Maria 01.03.2007
		-- We need to know when a super weapon changes owner so that we can update the UI accordingly.  This is necessary
		-- because each superweapon adds itself to the owner's list on creation and removes itself on destruction.
		Object.Register_Signal_Handler(On_Owner_Changed, "OBJECT_OWNER_CHANGED")
		OwnerScript = Owner.Get_Script()
	end
	
	OurGameObjectType = nil
	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Owner_Changed
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function On_Owner_Changed()
	if not TestValid(Object) then 
		MessageBox("Invalid Object")
	end
	
	if Object.Get_Owner() == Owner then 
		MessageBox("didn't we change owners?????")
		return
	end
	
	-- remove the superweapon from the old owner's list (if applicable)
	if OwnerScript then 
		OwnerScript.Call_Function("Remove_SW_Enabler", Object)
	end
	
	-- update the superweapon's owner information.  On service we will take care of updating the player's list.
	Owner = Object.Get_Owner()
	OwnerScript = Owner.Get_Script()
	PlayerDataUpdated = false	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	-- Tell Superweapon system that we're around (only if we are the local player so that we can update the UI accordingly)
--	if TestValid(Object) and OwnerScript then 
--		PlayerDataUpdated = OwnerScript.Call_Function("On_Superweapon_Enabler_Created", Object, SuperWeaponType )
--	end
end


-- --------------------------------------------------------------------------------------------------------------------
-- Service
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	if OwnerScript ~= nil and TestValid(Object) then
		if SWOwnerList ~= nil then
			if OurGameObjectType ~= Object.Get_Type() then
			
				OurGameObjectType = Object.Get_Type()
				OwnerScript.Call_Function("Remove_SW_Enabler", Object)
				
				if SWOwnerList[OurGameObjectType] ~=nil then
					PlayerDataUpdated = OwnerScript.Call_Function("On_Superweapon_Enabler_Created", Object, SWOwnerList[OurGameObjectType] )
				end
			elseif PlayerDataUpdated == false then
					PlayerDataUpdated = OwnerScript.Call_Function("On_Superweapon_Enabler_Created", Object, SWOwnerList[OurGameObjectType] )
			end
		end
	end
	Sleep(0.5)
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
