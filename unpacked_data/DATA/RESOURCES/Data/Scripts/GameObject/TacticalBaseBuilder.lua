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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/TacticalBaseBuilder.lua
--
--    Original Author: Maria Teruel
--
--          DateTime: 2007/05/16
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}


-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Init
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	if TestValid(Object) then 
		Owner = Object.Get_Owner()
		OwnerScript = Owner.Get_Script()
		Object.Register_Signal_Handler(On_Owner_Changed, "OBJECT_OWNER_CHANGED")	
	end
	Script.Set_Async_Data("BUILDER_DATA", BUILDER_DATA)
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
	
	-- remove the builder from the old owner's list (if it exists: note that if the builder is mind controlled
	-- he won't get added to the new owner's list, therefore, when he is not controlled anymore and we
	-- want to update the player's lists, it is possible that he won't belong to one of the owner's lists)
	if OwnerScript then 
		OwnerScript.Call_Function("Remove_Builder", Object)
	end
	
	-- update the superweapon's owner information.  On service we will take care of updating the player's list.
	Owner = Object.Get_Owner()
	OwnerScript = Owner.Get_Script()
	-- Now add this guy to the new owner's list (if applicable)
	if OwnerScript then 
		OwnerScript.Call_Function("Add_Builder", Object)
	end
	
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Health_At_Zero
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Health_At_Zero()
	if not TestValid(Object) then return end
	if OwnerScript then 
		OwnerScript.Call_Function("Remove_Builder", Object)
	end
	Object.Unregister_Signal_Handler(On_Owner_Changed)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	-- Tell the builder management system that we're around
	if TestValid(Object) and OwnerScript then 
		OwnerScript.Call_Function("Add_Builder", Object )
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- This line must be at the bottom of the file.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero
my_behavior.Delete_Pending = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
