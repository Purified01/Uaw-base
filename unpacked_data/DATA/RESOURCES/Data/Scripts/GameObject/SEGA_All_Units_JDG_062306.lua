-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SEGA_All_Units_JDG_062306.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SEGA_All_Units_JDG_062306.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Joe_Gernert $
--
--            $Change: 71438 $
--
--          $DateTime: 2007/05/25 16:43:15 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)

end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		
		--MessageBox("JDG VerticalSlice -- starting unit definitions")
		uea = Find_Player("Military")
		neutral = Find_Player("Neutral")
		aliens = Find_Player("Alien")
		civilian = Find_Player("Civilian")
		novus = Find_Player("Novus")
		masari = Find_Player("Masari")
		
		if novus then FogOfWar.Reveal_All(novus) end
		if aliens then FogOfWar.Reveal_All(aliens) end
		
	end
end










