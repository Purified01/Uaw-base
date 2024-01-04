-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Alien_Upgrade_Turrets.lua#8 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Alien_Upgrade_Turrets.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 84877 $
--
--          $DateTime: 2007/09/26 14:44:48 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
ScriptShouldCRC = true

local defs_done = false

function Definitions()

	if Find_Object_Type == nil then
		return
	end
	
	FinalUpGradeTo = nil
	UpGradeTo = nil
	UpgradeInfo = {}

	local temp_type = Find_Object_Type("Alien_Gravitic_Manipulator")
	if TestValid(temp_type) then
		UpgradeInfo[temp_type] = {}
		UpgradeInfo[temp_type][1] = Find_Object_Type("Alien_Gravitic_Manipulator_HP_Gravitic_Controller")
	end
	
	temp_type = Find_Object_Type("Alien_Radiation_Spitter")
	if TestValid(temp_type) then
		UpgradeInfo[temp_type] = {}
		UpgradeInfo[temp_type][1] = Find_Object_Type("Alien_Radiation_Spitter_HP_Desolator_Turret")
	end
	
	temp_type = Find_Object_Type("Masari_Guardian")
	if TestValid(temp_type) then
		UpgradeInfo[temp_type] = {}
		UpgradeInfo[temp_type][1] = Find_Object_Type("Masari_Guardian_Two_Faced_HP")
	end
	
	temp_type = Find_Object_Type("Masari_Sky_Guardian")
	if TestValid(temp_type) then
		UpgradeInfo[temp_type] = {}
		UpgradeInfo[temp_type][1] = Find_Object_Type("Masari_Sky_Guardian_Wind_Screen")
	end
	
	temp_type = Find_Object_Type("Masari_Elemental_Collector")
	if TestValid(temp_type) then
		UpgradeInfo[temp_type] = {}
		UpgradeInfo[temp_type][1] = Find_Object_Type("Masari_Matter_Engine_Matter_Sifter")
	end

	temp_type = Find_Object_Type("Masari_Natural_Interpreter")
	if TestValid(temp_type) then
		UpgradeInfo[temp_type] = {}
		UpgradeInfo[temp_type][1] = Find_Object_Type("Masari_Natural_Interpreter_of_Hostility")
		UpgradeInfo[temp_type][2] = Find_Object_Type("Masari_Natural_Interpreter_Of_Deception")
	end
	
	defs_done = true
	
end

function Compute_Desire()
	
	if not defs_done then
		Definitions()
	end
	
	if TestValid(FinalUpGradeTo) then
		-- we are upgrading
		return 99.0
	end
	
	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not Is_Player_Of_Faction(Player, "ALIEN") and not Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") and not Is_Player_Of_Faction(Player, "MASARI") then
		Goal.Suppress_Goal()
		return 0.0
	end	
	
	if not Target.Is_Ally(Player) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local object_target = Target.Get_Game_Object()
	if not TestValid(object_target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local type = object_target.Get_Type()
	if not TestValid(type) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local base_type = type.Get_Base_Type()
	if not TestValid(base_type) then
		Goal.Suppress_Goal()
		return 0.0
	end

	if UpgradeInfo[base_type] == nil or #UpgradeInfo[base_type] < 1 then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local found = false
	UpGradeTo = nil
	for _, t_type in pairs (UpgradeInfo[base_type]) do
		if TestValid(t_type) then
			if not Player.Is_Object_Type_Locked(t_type) then
				local hp_list = object_target.Get_Tactical_Hardpoint_Upgrades( false, true, false, nil, true )
				if hp_list ~= nil and hp_list[1] == t_type then
					UpGradeTo = t_type
				end
			end
			found = true
		end
	end

	if not found then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not TestValid( UpGradeTo ) then
		return 0.0
	end

	return 1.0
end

function Score_Unit(unit)
	
	if not TestValid(Target) or not TestValid(unit) then
		return 0.0
	end
	
	if unit == Target.Get_Game_Object() then
		return 1.0
	end
	
	return 0.0
	
end

function Service()

	if not Goal.Get_Task_Force() then
		return
	end
	
	if #Goal.Get_Task_Force().Get_Potential_Unit_Table() > 0 then
		FinalUpGradeTo = UpGradeTo
		Goal.Claim_Units("Upgrade_Turret_Thread")
	end

end

function Upgrade_Turret_Thread(turret_tf)

	local turret_object = turret_tf.Get_Unit_Table()[1]
	
	if TestValid( turret_object ) then
	
		if not TestValid(FinalUpGradeTo) then
			FinalUpGradeTo = nil
			return
		end
		
		BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, FinalUpGradeTo ))
		
	end
	
	FinalUpGradeTo = nil

end
