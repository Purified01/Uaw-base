if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[15] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/AttackAliens.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/AttackAliens.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
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

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Advance_State = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Current_State = nil
	Get_Last_Tactical_Parent = nil
	Get_Next_State = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_From_Table = nil
	Remove_Invalid_Objects = nil
	Set_Next_State = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
