LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Sub_Goal_Build_Unit.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Sub_Goal_Build_Unit.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

local minimum_cash = 2000.0

function Compute_Desire()
	--This is a sub goal.  Once it's been activated by another goal it remains desirable, but
	--it never becomes active on its own.
	if Goal.Is_Active() then
		return 1.0
	else
		return 0.0
	end
end

function Score_Unit(unit)
	--Once we're ready to build we'll recruit a single tactical enabler that's capable of
	--producing the required object type.
	if not required_cash then
		return 0.0
	end

	if Goal.Get_Resources() < required_cash then
		return 0.0
	end

	local tf = Goal.Get_Task_Force()
	if tf and tf.Get_Total_Unit_Count() > 0 then
		return 0.0
	end

	if unit.Tactical_Enabler_Can_Produce(type_to_build, Player, build_count) then
		return 1.0
	end
	
	return 0.0
end

function On_Activate()

	type_to_build = nil
	build_count = nil
	required_cash = nil
	Create_Thread("Prepare_To_Build")
	
	if Is_Player_Of_Faction(Player, "MASARI") then
		minimum_cash = 100.0
	end
	
end

function Prepare_To_Build()

	local user_data = Goal.Get_User_Data()
	if type(user_data) == "table" then
		type_to_build = user_data[1]
		build_count = user_data[2] 
		if not build_count then
			build_count = 1
		end
	else
		type_to_build = user_data
		build_count = 1
	end

	--We currently save up for all units and then submit them to a single structure for building.  Ideally we would
	--refine this to break the build up into batches of the maximum size that can be built simultaneously (currently 5)
	
	--Take steps to unlock this type
	Fix_Tactical_Dependencies(Player, Goal, type_to_build)

	--Secure cash for the build.
	required_cash = type_to_build.Get_Tactical_Build_Cost() * build_count
	
	-- don't even try to build if we have less than 1000 as it can block structure building
	while Player.Get_Credits() < minimum_cash and not type_to_build.Get_Type_Value("Is_Tactical_Base_Builder") and
	not type_to_build.Get_Type_Value("Is_Resource_Collector") and not type_to_build.Is_Category("Huge") do
		Sleep(2.0)
	end
	
	-- don't request the cash until we have it as other wise we can jam up the queue with lots of open orders with small
	-- amounts of cash claimed
	-- don't block walkers
	while Player.Get_Credits() < required_cash and not type_to_build.Is_Category("Huge") do
		Sleep(1.0)
	end
	
	while required_cash > 0.0 do
		required_cash = required_cash - Goal.Request_Resources(required_cash, false)
		Sleep(1)
	end
	
	--Keep this thread alive so that it doesn't exit and cause the goal to be prematurely killed.
	--Also periodically re-check the dependencies so that we don't get blocked if something vanishes
	--after our initial check.
	while true do
		Sleep(10)
		Fix_Tactical_Dependencies(Player, Goal, type_to_build)
	end
end

function Build_Thread(tf)

	--Currently we schedule the build and immediately quit so that the producing structure is freed up
	--to be recruited for another build.  Another possibility would be to support the notion of structures
	--being recruitable by multiple goals.
	tf.Build_Unit(type_to_build, build_count)
	ScriptExit()
end

function Service()
	if Goal.Get_Task_Force() and #Goal.Get_Task_Force().Get_Potential_Unit_Table() > 0 then
		Goal.Claim_Units("Build_Thread")
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
