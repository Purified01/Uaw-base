-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/VS2DemoCampaign.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/VS2DemoCampaign.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Steve_Copeland $
--
--            $Change: 47142 $
--
--          $DateTime: 2006/06/26 16:50:09 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("UIControl")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)
end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then

		-- Trigger an invasion (campaign is only one tactical battle)
		region = Find_First_Object("Region25")
		player_alien = Find_Player("Alien")
		
		dummy_hero = Find_First_Object("Alien_Hero")
		dummy_hero_fleet = dummy_hero.Get_Parent_Object()

		Force_Land_Invasion(region, dummy_hero_fleet, player_alien, true)
		
	end
end


---------------------------------------------------------------------------------------------------
---- Event Handlers

function On_Land_Invasion()

	-- Set up the invasion specifics.
	InvasionInfo.OverrideMapName = "./Data/Art/Maps/_____steve_playground.ted"
	InvasionInfo.TacticalScript = "VS2DemoBattle"
	InvasionInfo.UseStrategicPersistence = false
	InvasionInfo.UseStrategicProductionRules = true
end
