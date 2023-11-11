-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Icons.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Icons.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Chris_Brooks $
--
--            $Change: 40315 $
--
--          $DateTime: 2006/03/31 16:47:53 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- Get the icon for a fleet
function Get_Fleet_Icon_Name(object)
	local hero = object.Get_Fleet_Hero()
	if hero then
      icon = hero.Get_Type().Get_Icon_Name()
	else
		-- TODO: show different icon based on faction
		icon = "i_button_uea_standind_army.tga"
	end
   return icon
end

-- We should be getting this from XML, but it ends up in FactionClass, which isn't wrapped (yet)
function Get_Faction_Icon_Name(object)
	local owner = object.Get_Owner()
	local faction = owner.Get_Faction_Name()
	if faction == "UEA" then 
		return "i_button_uea_fleettag.tga"
	elseif faction == "ALIEN" then
		return "i_button_alien_fleettag.tga"
	elseif faction == "NOVUS" then
		return "i_button_novus_fleettag.tga"
	else
		return "i_button_temporary.tga"
	end
end
