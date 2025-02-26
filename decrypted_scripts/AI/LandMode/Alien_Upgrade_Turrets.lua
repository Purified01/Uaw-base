if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Alien_Upgrade_Turrets.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Alien_Upgrade_Turrets.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
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
	
	if Player.Get_Player_Is_Crippled() then
		return -2.0
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
		--Goal.Suppress_Goal()
		return -2.0
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
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Burn_All_Objects = nil
	Calculate_Task_Force_Speed = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	Describe_Target = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	Get_Distance_Based_Unit_Score = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
