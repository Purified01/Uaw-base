if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[113] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGBehaviors.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGBehaviors.lua $
--
--    Original Author: Brian Hayes
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

ScriptShouldCRC = true;
BehaviorNameTable = {}

function Base_Definitions()
	-- DebugMessage("%s -- In Base_Definitions", tostring(Script))

	for _,behavior in pairs(BehaviorNameTable) do
		if behavior.Active then 
			local bfunc = behavior["Clean_Up"]
			if bfunc then
				bfunc()
			end
		end
	end

	Common_Base_Definitions()
	
	-- This controls how often the script is serviced.
	-- So try to process 5 times a second
	ServiceRate = 1.0

	if Definitions then
		Definitions()
	end
end

function Get_Behavior_Sync_String()
	local outstr
	for _,behavior in pairs(BehaviorNameTable) do
		local astr = "(-)"
		if behavior.Active then astr = "(+)" end
		if outstr == nil then
			outstr = behavior.Name .. astr
		else
			outstr = outstr .. "," .. behavior.Name .. astr
		end
	end
	return outstr
end

function Init_Behaviors()

	BehaviorServiceTable = {}
	
	for _,behavior in pairs(BehaviorNameTable) do
		behavior.Active = false
	end
	
	local ActiveBehaviorNames = {}
	for _,bname in ipairs(BehaviorList) do
		behavior = BehaviorNameTable[bname]
		behavior.Active = true
		table.insert(BehaviorServiceTable, behavior)
		ActiveBehaviorNames[bname] = true
	end
	
	LastService = Simple_Mod(GameRandom.Get_Float() + ServiceRate, ServiceRate)
	Call_Behavior_Function("Init")

	Script.Set_Async_Data("ActiveBehaviorNames", ActiveBehaviorNames)
end

function Register_Behavior(behavior)
	BehaviorNameTable[behavior.Name] = behavior
end

function Call_Behavior_Function(name)
	for _,behavior in pairs(BehaviorServiceTable) do
		local bfunc = behavior[name]
		if bfunc then
			bfunc()
		end
	end
end

function Delete_Pending()
	Call_Behavior_Function("Delete_Pending")
end

function Health_At_Zero()
	Call_Behavior_Function("Health_At_Zero")
end

function Has_Behavior(name)
	local behavior = BehaviorNameTable[name]
	return behavior and behavior.Active
end

function Debug_Switch_Sides()
	Call_Behavior_Function("Switch_Sides")
end

function Post_Load_Game()
	Call_Behavior_Function("Post_Load_Game")
end

function Does_Object_Need_Behavior_Service()
	for _,behavior in pairs(BehaviorServiceTable) do
		local bfunc = behavior["Service"]
		if bfunc then
			return true
		end
	end
	return false
end

function main()

	if Does_Object_Need_Behavior_Service() then
		while true do
			Call_Behavior_Function("Service")
			PumpEvents()
		end
	end
end

function First_Service()
	Call_Behavior_Function("First_Service")
end

function Refresh_After_Mode_Switch()
	Call_Behavior_Function("Refresh_After_Mode_Switch")
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Register_Behavior = nil
	Remove_Invalid_Objects = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
