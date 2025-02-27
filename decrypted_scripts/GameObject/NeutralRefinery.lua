if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[109] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/NeutralRefinery.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/NeutralRefinery.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")
require("PGUICommands")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

-- ResourcesPerSecond : This is set by xml script

	if ResourcesPerSecond == nil then
		ResourcesPerSecond = 0.0
	end		
	
	LastCheckTime = GetCurrentTime()
	NextCheckTime = LastCheckTime + 1.0

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	
	local tm = GetCurrentTime()
	
	if tm >= NextCheckTime then
			
		if TestValid( Object ) then 
		
			local owner = Object.Get_Owner()
			if owner ~= nil then
				-- All factions now get income
				local time_passed = tm - LastCheckTime
				local resources = ResourcesPerSecond * time_passed
				
 				local faction = owner.Get_Faction_Name()
 				if faction == "MASARI" then
 					resources = resources / 10.0
 				end
				
				owner.Add_Raw_Materials( resources,  Object)
				
				-- round up for prints
				resources = resources + 0.5
				
				Get_Game_Mode_GUI_Scene().Raise_Event("Resource_Harvested", nil, {Object, Object, resources})
			end
		end

		LastCheckTime = tm
		NextCheckTime = LastCheckTime + 1.0
	
	end
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service

Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_GUI_Variable = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
