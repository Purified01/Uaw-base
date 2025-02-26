if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Novus_Manage_Patches.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Novus_Manage_Patches.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 97234 $
--
--          $DateTime: 2008/04/21 13:36:32 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGUICommands")

ScriptShouldCRC = true

local player_script = nil

function Definitions()
	SUBGOAL_UNIQUE_ID = 1

	-- Override from PGLogging.lua
	LOGFILE_NAME = "AINovusPatches.txt"
end

local	heal_type = nil
local	collect_type = nil
local	overclock_type = nil
local	reboot_type = nil
local	viral_reboot_type = nil
local wait_time = 0.0
local reboot_timer = 0.0
local viral_reboot_timer = 0.0
RebootCheckTime = 0.0

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "NOVUS") then
		--Goal.Suppress_Goal()
		return -2.0
	end

	if Player.Get_Player_Is_Crippled() then
		return -2.0
	end

	if Target then
		--Goal.Suppress_Goal()
		return -1.0
	end
	
	return 1.0
	
end

function Score_Unit(unit)

	return 0.0

end

function On_Activate()

	heal_type = Find_Object_Type("Novus_Patch_Backup_Systems")
	collect_type = Find_Object_Type("Novus_Patch_Optimized_Collection")
	overclock_type = Find_Object_Type("Novus_Patch_Overclocking")
	reboot_type = Find_Object_Type("Novus_Patch_Reboot")
	viral_reboot_type = Find_Object_Type("Novus_Patch_Viral_Cascade")

	if player_script == nil then
		player_script = Player.Get_Script()
	end
	
	PatchTimer = 0.0
	
	LastPatchObject = {}
	
end

function Service()

	if GetCurrentTime() < wait_time then
		return
	end
	
	if player_script == nil then
		return
	end

	Use_Patch()
	
end

function Use_Patch()

	if GetCurrentTime() < PatchTimer then
		return
	end

	if Create_Patch( heal_type ) then
		return
	end

	if Create_Patch( collect_type ) then
		return
	end

	if GetCurrentTime() > reboot_timer and Need_Reboot() and Create_Patch( reboot_type ) then
		-- only reboot every 120 seconds at maximum
		reboot_timer = GetCurrentTime() + 120.0
		return
	end
	
	if GetCurrentTime() > viral_reboot_timer and Create_Patch( viral_reboot_type ) then
		-- only viral reboot every 90 seconds
		viral_reboot_timer = GetCurrentTime() + 120.0
		return
	end
	
--	if Create_Patch( overclock_type ) then
--		return
--	end
	
end

-------------------------------------------------------
-- Need_Reboot: Check to see if the patch can be created
-------------------------------------------------------
function Need_Reboot()

	if GetCurrentTime() > RebootCheckTime then
		RebootCheckTime = GetCurrentTime() + 15.0
		local obj_list = Find_All_Objects_Of_Type( Player, "Stationary" )
		local count = 1
		KeyObjectsList = {}
		if obj_list then
			for _,unit in pairs(obj_list) do
				if TestValid(unit) and unit.Get_Type().Is_Victory_Relevant() then
					KeyObjectsList[count] = unit
					count = count + 1
				end
			end
		end
		return false
	end
	
	if KeyObjectsList then
		for _,unit in pairs(KeyObjectsList) do
			if TestValid(unit) and unit.Get_Attribute_Value("Virus_Level") > 0.0 then
				return true
			end
		end
	end
	
	return false
	
end

-------------------------------------------------------
-- Create_Patch: Check to see if the patch can be created
-------------------------------------------------------
function Create_Patch( patch_type )

	if TestValid( patch_type ) and not TestValid(LastPatchObject[patch_type]) then
		if Player.Is_Object_Type_Enabled(patch_type) then
		
			if player_script.Call_Function("Can_Build_Patch_Of_Type",patch_type) then
				--Call the player script function directly.  Raising the GUI event would
				--cause a game object to be created from the render thread(!)
				local patch_object = player_script.Call_Function("Build_Patch", patch_type)			
				log("Novus_Patches: Created patch %s.", patch_type.Get_Name() )
				PatchTimer = GetCurrentTime() + 12.0
				LastPatchObject[patch_type] = patch_object
				return true
			end
		end
	end
	
	return false
	
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
	Describe_Target = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Distance_Based_Unit_Score = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
