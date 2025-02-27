LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Structure_Build_Help.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Structure_Build_Help.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true
local ObjectNeedingHelp = nil

function Compute_Desire()
	
	if Player.Get_Player_Is_Crippled() then
		return -2.0
	end

	-- alien structures require no help once done with beacon
	if Is_Player_Of_Faction(Player, "ALIEN") or Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		--Goal.Suppress_Goal()
		return -2.0
	end	

	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local object_target = Target.Get_Game_Object()
	if not TestValid(object_target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if object_target.Get_Owner() ~= Player then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not object_target.Is_Category("TacticalBuildableStructure") then
		Goal.Suppress_Goal()
		return 0.0
	end

	local object_type = object_target.Get_Type()
	if not TestValid( object_type ) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if object_type.Get_Type_Value("Tactical_Under_Construction_Object_Type") ~= nil then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if object_target.Get_Attribute_Value("Number_Of_Assigned_Builders") > 0.0 then
		return 0.0
	end
	
	if object_target.Has_Behavior(70) then
		ObjectNeedingHelp = object_target
		return 1.0
	end

	if not object_target.Has_Behavior(39) then
		return 0.0
	end

	ObjectNeedingHelp = object_target
	return 1.0
end

function Score_Unit(unit)
	
	if not TestValid( unit ) then
		return 0.0
	end
	
	if not TestValid(Target) then
		return 0.0
	end
	
	local unit_type = unit.Get_Type()
	
	if not TestValid(unit_type) then
		return 0.0
	end 
	
	if not unit_type.Get_Type_Value("Is_Tactical_Base_Builder") then
		return 0.0
	end
	
	local taskforce = Goal.Get_Task_Force()
	if not taskforce then
		return 1.0
	end
	
	local total_units = taskforce.Get_Total_Unit_Count()
	if total_units > 0 then
		return 0.0
	end

	local distance = Target.Get_Distance(unit)
	
	if distance == nil or distance < 1.0 then
		distance = 1.0
	end
	
	-- keep it as a low priority
	local score = 0.01 + 0.01 / distance
	
	return score
		
end

function Service()

	if not Goal.Get_Task_Force() then
		return
	end
	
	if #Goal.Get_Task_Force().Get_Potential_Unit_Table() > 0 and #Goal.Get_Task_Force().Get_Unit_Table() < 1 then
		Goal.Claim_Units("Help_Structure",1,true)
	end

end

function Help_Structure(help_tf)

	local unit_list= help_tf.Get_Unit_Table()
	
	if not TestValid(Target) then
		ScriptExit()
	end
	
	local object_target = ObjectNeedingHelp
	
	if not TestValid(object_target) then
		ScriptExit()
	end

	local faction = Player.Get_Faction_Name()
	
	while unit_list and TestValid(object_target) and (object_target.Has_Behavior(70) or object_target.Has_Behavior(39)) do

		for _,unit in pairs(unit_list) do
			if TestValid( unit ) then
				if faction == "MASARI" then 
					unit.Activate_Ability("Masari_Tactical_Build_Unit_Ability",true,object_target)
				elseif faction == "NOVUS" then
					unit.Activate_Ability("Novus_Tactical_Build_Structure_Ability",true,object_target)
				else
					unit.Activate_Ability("Alien_Tactical_Build_Structure_Ability",true,object_target)
				end
			else
				ScriptExit()
			end
		end

		Sleep(5.0)
		
	end		

	ScriptExit()

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
