if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[148] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[14] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Generic_Manage_Reinforcements.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Generic_Manage_Reinforcements.lua $
--
--    Original Author: James Yarrow
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

function Compute_Desire()

	if not Is_Campaign_Game() then
		--Goal.Suppress_Goal()
		return -2.0
	end

	if Target then
		--Goal.Suppress_Goal()
		return -1.0
	end
	
	local global_script = Get_Game_Mode_Script("Strategic")
	if TestValid(global_script) and global_script.Get_Async_Data("IsScenarioCampaign") then
		return 1.0
	else
		--Don't permit hero reinforcements in story campaigns
		Goal.Suppress_Goal()
		return 0.0
	end	
end

function Score_Unit(unit)
	local taskforce = Goal.Get_Task_Force()
	if taskforce and #taskforce.Get_Unit_Table() > 0 then
		return 0.0
	end

	if not unit.Has_Behavior(160) then
		return 0.0
	end
	
	local strategic_hero = unit.Get_Ghosted_Object()
	if not TestValid(strategic_hero) then
		return 0.0
	end

	local fleet = strategic_hero.Get_Parent_Object()
	if not TestValid(fleet) then
		return 0.0
	end
	
	local region = strategic_hero.Get_Region_In()
	if not TestValid(region) then
		return 0.0
	end
		
	local reinforce_score = fleet.Get_Strike_Force_Reinforcement_Time()
	if HasHero or reinforce_score > 15.0 * 60.0 then
		if GetCurrentTime() < reinforce_score then
			return 0.0
		end
	end
		
	--Prefer heroes with larger pop cap (they tend to be stronger)
	reinforce_score = reinforce_score - strategic_hero.Get_Type().Get_Type_Value("Associated_Pop_Cap")
	if reinforce_score < 0 then
		reinforce_score = 0
	end
	return 10.0 / (reinforce_score + 1.0) 
end

function Service()
	local taskforce = Goal.Get_Task_Force()
	if not taskforce then
		return
	end
	
	local potential_units = taskforce.Get_Potential_Unit_Table()
	if #potential_units > 0 then
		Goal.Claim_Units("Reinforce_Thread", 1, false)
	end
end

function On_Activate()
	--Determine whether we already have a hero.  If not, we'll be much more aggressive about pulling one in
	HasHero = false
	local region = Get_Conflict_Location()
	local fleet_count = region.Get_Number_Of_Fleets_Contained()
	for i = 1, fleet_count do
		local fleet = region.Get_Fleet_At(i - 1)
		if TestValid(fleet) and fleet.Get_Owner() == Player then
			if fleet.Is_Striker_Fleet() then
				HasHero = true
				return
			end
		end
	end	
end

function Reinforce_Thread(tf)
	local all_units = tf.Get_Unit_Table()
	for _, unit in pairs(all_units) do
		local strategic_hero = unit.Get_Ghosted_Object()
		local fleet = strategic_hero.Get_Parent_Object()
		fleet.Request_Strike_Force_Reinforcement()
	end
	
	tf.Register_Signal_Handler(On_Member_Delete_Pending, "Object_Delete_Pending")
	
	--Spin our wheels forever.  When the reinforcement arrives the stand-in will be destroyed and the goal will exit.
	while true do
		Sleep(500)
	end
end

function On_Member_Delete_Pending(tf)
	if not tf or tf.Get_Total_Unit_Count() == 0 then
		ScriptExit()
	end
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
