-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGVictoryConditionDefs.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGVictoryConditionDefs.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Nader_Akoury $
--
--            $Change: 80512 $
--
--          $DateTime: 2007/08/09 19:36:34 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

function Init_Victory_Condition_Constants()
	VICTORY_CONQUER = 0
	VICTORY_ANNIHILATION = 1
	VICTORY_RESOURCE_RACE = 2 --This victory condition is not in the tables below so that it doesn't appear in dialogs.
	VICTORY_SUB_MODE = 3 --This victory condition is not in the tables below so that it doesn't appear in dialogs.
	
	local w_conquer = Get_Game_Text("TEXT_VICTORY_CONQUER")
	local w_annihilation = Get_Game_Text("TEXT_VICTORY_ANNIHILATION")
--	local w_resource = Get_Game_Text("TEXT_VICTORY_RESOURCE_RACE")
	
	VictoryConditionNames = {}
	VictoryConditionNames[VICTORY_CONQUER] = w_conquer
	VictoryConditionNames[VICTORY_ANNIHILATION] = w_annihilation
--	VictoryConditionNames[VICTORY_RESOURCE_RACE] = w_resource

	VictoryConditionConstants = {}
	VictoryConditionConstants[w_conquer] = VICTORY_CONQUER
	VictoryConditionConstants[w_annihilation] = VICTORY_ANNIHILATION
--	VictoryConditionConstants[w_resource] = VICTORY_RESOURCE_RACE
end	
