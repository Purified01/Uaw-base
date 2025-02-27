if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[98] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/GlobalResourceStructureBehavior.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/GlobalResourceStructureBehavior.lua $
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

--Adapted from NeutralRefinery.lua

require("PGBehaviors")
require("PGUICommands")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

	if Get_Game_Mode() == "Strategic" then

		CYCLE_DURATION = 30.0
		IsGlobal = true
		
		ResourcesPerCycle = GlobalResourcesPerCycle
		if ResourcesPerCycle == nil then
			ResourcesPerCycle = 0.0
		end		
		
		if GlobalResourceCap  then
			Object.Get_Owner().Add_To_Credit_Cap(GlobalResourceCap)
		end
	else 
		CYCLE_DURATION = 30.0
		IsGlobal = false

		ResourcesPerCycle = TacticalResourcesPerCycle
		if ResourcesPerCycle == nil then
			ResourcesPerCycle = 0.0
		end		
		
		if TacticalResourceCap  then
			Object.Get_Owner().Add_To_Credit_Cap(TacticalResourceCap)
		end		
	end
	
	LastCycleTime = GetCurrentTime()
	NextCycleTime = LastCycleTime + CYCLE_DURATION

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	
	local tm = GetCurrentTime()
	
	if tm >= NextCycleTime then	
		
		if TestValid(Object) then 
			local owner = Object.Get_Owner()
			if owner ~= nil then
				local old_credits = owner.Get_Credits()
				owner.Add_Credits(ResourcesPerCycle)
				local new_credits = owner.Get_Credits()
				local credits_added = new_credits - old_credits
				if owner == Find_Player("local") and credits_added > 0.0 then
					 local particle = Create_Generic_Object(Find_Object_Type("Resource_Floaty"), Object.Get_Position(), owner)
					 particle.Set_GUI_User_Data(credits_added)
				end				
			end
		end

		LastCycleTime = NextCycleTime
		NextCycleTime = LastCycleTime + CYCLE_DURATION
	
	end
end

local function Behavior_First_Service()
end

local function Behavior_Delete_Pending()
	if IsGlobal then
		if GlobalResourceCap then
			local owner = Object.Get_Owner()
			if TestValid(owner) then
				Object.Get_Owner().Remove_From_Credit_Cap(GlobalResourceCap)
			end
		end
	else
		if TacticalResourceCap then
			local owner = Object.Get_Owner()
			if TestValid(owner) then
				Object.Get_Owner().Remove_From_Credit_Cap(TacticalResourceCap)
			end
		end
	end			
end

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
my_behavior.First_Service = Behavior_First_Service
my_behavior.Delete_Pending = Behavior_Delete_Pending

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
