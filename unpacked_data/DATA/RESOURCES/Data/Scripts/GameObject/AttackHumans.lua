-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AttackHumans.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AttackHumans.lua $
--
--    Original Author: James Yarrow
--
--            $Author: oksana_kubushyna $
--
--            $Change: 40718 $
--
--          $DateTime: 2006/04/08 13:16:49 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

--When player units move near this object its spawn behavior becomes enabled

function Definitions()

	Define_State("State_Init", State_Init);
		
	loc_table = Find_All_Objects_Of_Type("Story_Trigger_Zone")
	
end


--jdg this is the new script...tells the spawned greys to guard their "closest" walker
--function State_Init(message)
--	if message == OnEnter then
--		while true do
--			if TestValid(Object) then
--				nearest_walker = Find_Nearest(Object, "ALIEN_WALKER_Barracks")
--					if TestValid(Object) and TestValid(nearest_walker) then
						--guard walker
--						Object.Guard_Target(nearest_walker)
--						Sleep(5)
--					end
				
				
--			end
--		end
		
--	end
--end

function State_Init(message)
	if message == OnEnter then
		UEA_player = Find_Player("UEA")
		
		while true do
			if TestValid(Object) then
				if not Object.Has_Attack_Target() then
					--all_enemies = Find_All_Objects_Of_Type("Attack_Grey_02")
					--all_enemies = Find_All_Objects_Of_Type(UEA_player)
					--table_size = table.getn(all_enemies)
					--target = all_enemies[GameRandom(1, table_size)]
					target = Find_Nearest(Object, UEA_player, true)
					if TestValid(target) then
						Object.Attack_Move(target)
					end
				end
				--Sleep(5)
				--if Object.Has_Attack_Target() then
				--	random_slot = GameRandom(1, 8)
				--	random_loc = loc_table[random_slot]
				--	Object.Move_To(random_loc.Get_Position())
				--	Sleep(1.5)
				--end
			end
			Sleep(1)
		end
	end
end
