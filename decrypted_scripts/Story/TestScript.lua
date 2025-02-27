if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[125] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/TestScript.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/TestScript.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

-- THIS IS IMPORTANT! Needed so other script instances can use the objectives API.
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)
end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
	
		UEA_Hero = Find_First_Object("Test_Hero_1")
		region = Find_First_Object("Region1")

		-- MARIA 04.07.2006
		-- Need this to create the icon for the science guy in Strategic!
		scientist_type = Find_Object_Type("Military_Hero_Chief_Scientist_PIP_Only")
		player = Find_Player("local")
		scientist_obj = Create_Generic_Object(scientist_type, region, player)


		Force_Land_Invasion(region, UEA_Hero.Get_Parent_Object(), UEA_Hero.Get_Owner(), true)

--    while (true) do
-- --    MessageBox("]]]] LUA: Test Script executing!")
--       Sleep(5)
--    end

		--[[
		-- This is an example of using the Objective API.
		
		Sleep(1)
		o1 = Add_Objective("Take a fleet to California")
		
		Sleep(1)
		o2 = Add_Objective("Find the crashed UFO")

		Sleep(1)
		o3 = Add_Objective("Kill all the grays")

		Sleep(1)
		Set_Objective_Checked(o1, true)

		Sleep(1)
		Set_Objective_Checked(o2, true)

		Sleep(1)
		Set_Objective_Checked(o3, true)
		
		Sleep(1)
		Delete_Objective(o3)
		Sleep(1)
		Delete_Objective(o1)
		Sleep(1)
		Delete_Objective(o2)
		--]]

	elseif message == OnUpdate then
	end
end


function On_Land_Invasion()
	--MessageBox("%s -- In On_Land_Invasion()", tostring(Script));

	--MessageBox("%s -- Location: %s, Invader: %s, OverrideMap: %s", tostring(Script), tostring(InvasionInfo.Location), 
	-- tostring(InvasionInfo.Invader), tostring(InvasionInfo.OverrideMapName))

	if FirstInvasionDone == nil then
		--DebugBreak()
		--MessageBox("%s -- setting verticalsliceMission1 script", tostring(Script));	

		-- Use the native map for the region and associate the mission script.
		InvasionInfo.TacticalScript = "DefaultLandScript"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
		
	else
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/Invasion_Demo_4.ted"
		InvasionInfo.TacticalScript = "DefaultLandScript"
		
		-- These are currently not implemented on the code side, but will be at
		-- some point in the future.  3/30/2006 4:40:36 PM -- BMH
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
	end

	FirstInvasionDone = true
end
---------------------------------------------------------------------------------------------------
-- EOF
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
	Objective_Complete = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Remove_From_Table = nil
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Set_Next_State = nil
	Set_Objective_Text = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	Suspend_Objectives = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
