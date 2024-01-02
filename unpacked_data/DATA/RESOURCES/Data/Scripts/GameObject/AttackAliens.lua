-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AttackAliens.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AttackAliens.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Rich_Donnelly $
--
--            $Change: 65027 $
--
--          $DateTime: 2007/03/10 12:23:16 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

--When player units move near this object its spawn behavior becomes enabled

function Definitions()

	Define_State("State_Init", State_Init);
	
end

function State_Init(message)
	if message == OnEnter then
		alien_player = Find_Player("Alien")
		
		while true do
			if TestValid(Object) then
				if not Object.Has_Attack_Target() then
					--all_enemies = Find_All_Objects_Of_Type("Attack_Grey_02")
					--all_enemies = Find_All_Objects_Of_Type(alien_player)
					--table_size = table.getn(all_enemies)
					--target = all_enemies[GameRandom(1, table_size)]
					target = Find_Nearest(Object, alien_player, true)
					if TestValid(target) then
						Object.Attack_Move(target)
					else
						alien_player = Find_Player("Alien_ZM06_KamalRex")
						target = Find_Nearest(Object, alien_player, true)
						if TestValid(target) then
							Object.Attack_Move(target)
						end
					end
				Sleep (5)
				end
			end
			Sleep(1)
		end
	end
end

