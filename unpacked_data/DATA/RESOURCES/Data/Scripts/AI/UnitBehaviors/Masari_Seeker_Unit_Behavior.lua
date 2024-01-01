-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Masari_Seeker_Unit_Behavior.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Masari_Seeker_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 84404 $
--
--          $DateTime: 2007/09/20 13:10:30 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	--Disable autofire of this ability since it will be used on enemy and shouldn't be (at least by the AI)
	-- KDB only disable in thread as this may not have been researched yet
	--Object.Set_Single_Ability_Autofire("Inquisitor_Destabilize_Unit_Ability", false)

	-- need to add clearing of virus etc	(that's why service needed)
	-- Try not to edit ServiceRate - it affects all LUA behaviors for this unit
	--ServiceRate = 3.0
	
	SeekerThreadID = nil
	
end

local function Behavior_Service()
	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not SeekerThreadID then
			SeekerThreadID = Create_Thread("Seeker_Thread")
		end
	elseif SeekerThreadID then
		Create_Thread.Kill(SeekerThreadID)
		SeekerThreadID = nil
	end
end

function Seeker_Thread()

	while true do

		local player = Object.Get_Owner()
	
		if TestValid(player) then
			if not player.Is_Unit_Ability_Locked("Inquisitor_Destabilize_Unit_Ability") and Object.Is_Ability_Ready("Inquisitor_Destabilize_Unit_Ability") then
			
				Object.Set_Single_Ability_Autofire("Inquisitor_Destabilize_Unit_Ability", false)
				
				if Object.Is_Ability_Active("Inquisitor_Destabilize_Unit_Ability") then
					-- turn it off as we don't want our units 'frozen'
					Object.Activate_Ability("Inquisitor_Destabilize_Unit_Ability",false)
					Object.Clear_Attack_Target()
				else
				
					-- search for objects to fix
					local obj_list = Find_All_Objects_Of_Type( Object, 350.0, "Small + ~Resource + ~Resource_INST | CanAttack | Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST | Hardpoint" )
					local ability_target = nil
						
					if obj_list then
						for _, unit in pairs (obj_list) do
							if TestValid(unit) then
								if player.Is_Enemy(unit.Get_Owner()) then
									local original_player = unit.Get_Attribute_Integer_Value("Object_Original_Owner_ID")
									if ( unit.Is_Phased() or original_player == player.Get_ID() ) and not unit.Is_Death_Clone() and not unit.Is_Category("Resource | Resource_INST") then
										-- fix it
										ability_target = unit
										break
									end
								else
									if unit.Get_Attribute_Value("Virus_Level") > 0 and not unit.Is_Death_Clone() and not unit.Is_Category("Resource | Resource_INST") then
										-- fix it
										ability_target = unit
										break
									end
								end
							end
						end
						
						-- activate ability !
						if TestValid(ability_target) then
							Object.Activate_Ability("Inquisitor_Destabilize_Unit_Ability",true,ability_target)
						end
						
					end
				end
				
			end
		end
	
		Sleep(2.0)
	
	end
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)