-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Alien_Scout_Controller.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Alien_Scout_Controller.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 76451 $
--
--          $DateTime: 2007/07/12 14:55:55 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("Generic_Scout_Controller")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------



---------------------- Goal Events and Queries ----------------------



---------------------- Goal-specific Functions ----------------------

--
-- Choose_Scouting_Subgoal - Choose a goal to go explore the given target area.
-- Returns the name of the chosen scouting script.
--
function Choose_Scouting_Subgoal(scout_target)
	return "Alien_Monolith_Scout"
end


