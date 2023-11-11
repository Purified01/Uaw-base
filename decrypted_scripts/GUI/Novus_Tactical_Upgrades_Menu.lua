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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Novus_Tactical_Upgrades_Menu.lua
--
--    Original Author: Maria Teruel
--
--          DateTime: 2007/02/24
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("Tactical_Upgrades_Menu")

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Faction_Display()
	Set_GUI_Variable("ControlGroupDisplayYOffset", 0.2)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Power_Icon
-- ------------------------------------------------------------------------------------------------------------------
function Update_Power_Icon()
	if TestValid(Object) and
			not Object.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) and 
			Object.Has_Behavior( BEHAVIOR_POWERED ) and 
			Object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 and 
			Object.Get_Owner() == Find_Player("local") then
		if not Is_Flashing(this.NoPower) then
			this.NoPower.Set_Hidden(false)
			Start_Flash(this.NoPower)
		end
	else
		Stop_Flash(this.NoPower)
		this.NoPower.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Inactive
-- ------------------------------------------------------------------------------------------------------------------
function Update_Inactive()
	if LetterBoxModeOn then
		-- if we are running a cinematic, let's not do anything (just make sure we are hidden!)
		if not this.NoPower.Get_Hidden() then
			Reset_No_Power_State()
		end
		return
	else
		Update_Power_Icon()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Reset_No_Power_State()
	Stop_Flash(this.NoPower)
	this.NoPower.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Display()
	Reset_No_Power_State()
	Update_Power_Icon()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Enter_Active
-- ------------------------------------------------------------------------------------------------------------------
function On_Enter_Active()
	Update_Control_Group_Display(false) -- do not set the ctrl group texture here (we just need to update its hidden/unhidden state)
	Update_Active()	
end
