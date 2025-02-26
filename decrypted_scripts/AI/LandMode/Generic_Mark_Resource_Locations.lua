if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[162] = true
LuaGlobalCommandLinks[134] = true
LuaGlobalCommandLinks[133] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Generic_Mark_Resource_Locations.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Generic_Mark_Resource_Locations.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGLogging")
ScriptShouldCRC = true

---------------------- Script Globals ----------------------

function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIResourceLog.txt"
end



---------------------- Goal Events and Queries ----------------------


function Compute_Desire()

	if true then
		return -2.0
	end

	-- This script is redundant for the alien faction because it has its own
	-- resource gathering scripts.
	if Is_Player_Of_Faction(Player, "ALIEN") or Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		--Goal.Suppress_Goal()
		return -2.0
	end

	if Player.Get_Player_Is_Crippled() then
		return -2.0
	end

	if Target then
		Goal.Suppress_Goal()
		return -1.0
	end
	
	-- KDB not needed 
	return -2.0

end

function Score_Unit(unit)
	return 0.0
end

function On_Activate()
	Create_Thread("Mark_Resources")
end

function Mark_Resources()

	base_structures = Find_Objects_With_Behavior(99, Player)
	if not base_structures then
		ScriptExit()
		return
	end
	
	Sleep(1)
	base_clusters = Find_Clusters(base_structures)
	if not base_clusters then
		ScriptExit()
		return
	end
	
	Sleep(1)
	for _, base in pairs(base_clusters) do
		-- KDB large radius not really needed as novus will build towers towards resources and the others dn't care
		resource_objects = Find_Resource_Objects(base, 200.0)
		if resource_objects then
			Sleep(1)
			resource_clusters = Find_Clusters(resource_objects)
			Sleep(1)
			if resource_clusters then
				for _, resource_pile in pairs(resource_clusters) do
					custom_target = Goal.Create_Custom_Target(resource_pile)
					Sleep(1)
					log("Generic_Mark_Resource_Locations activating subgoal on target %s", Describe_Target(custom_target))
					Goal.Activate_Sub_Goal("Generic_Build_Resource_Collector", custom_target, nil)
				end
			end
		end
	end
		
	BlockOnCommand(Goal.Wait_For_All_Sub_Goals())
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
