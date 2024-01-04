-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/PatchBehavior.lua#4 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/PatchBehavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 85263 $
--
--          $DateTime: 2007/10/02 11:43:31 $
--
--          $Revision: #4 $
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


-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Health_At_Zero
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Health_At_Zero()
	if not TestValid(Object) then return end
	if OwnerScript then 
		OwnerScript.Call_Function("Unregister_Patch_Enabler", Object)
	end
	Object.Unregister_Signal_Handler(On_Owner_Changed)
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
	
	-- remove the patch enabler from the old owner's list (if applicable)
	if OwnerScript then 
		OwnerScript.Call_Function("Unregister_Patch_Enabler", Object)
	end
	
	Owner = Object.Get_Owner()
	OwnerScript = Owner.Get_Script()
	
	-- Register this patch enabler with the new owner!.
	Register_Patch_Enabler()
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	Register_Patch_Enabler()
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Register_Patch_Enabler
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Register_Patch_Enabler()
	if TestValid(Object) and TestValid(Owner) then 
		
		OwnerScript = Owner.Get_Script()
		
		if OwnerScript then 
			OwnerScript.Call_Function("Register_Patch_Enabler", Object )
		end
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- This section must be at the bottom of the file.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero
my_behavior.Delete_Pending = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
