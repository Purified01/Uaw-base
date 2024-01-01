-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Manage_Patches.lua#13 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Manage_Patches.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 86527 $
--
--          $DateTime: 2007/10/24 11:53:47 $
--
--          $Revision: #13 $
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
		Goal.Suppress_Goal()
		return 0.0
	end

	if Target then
		Goal.Suppress_Goal()
		return 0.0
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

	if TestValid( patch_type ) then
		if Player.Is_Object_Type_Enabled(patch_type) then
		
			if player_script.Call_Function("Can_Build_Patch_Of_Type",patch_type) then
				Get_Game_Mode_GUI_Scene().Raise_Event("Build_Patch_Now", nil, {Player, patch_type})
				log("Novus_Patches: Created patch %s.", patch_type.Get_Name() )
				wait_time = GetCurrentTime() + 1.0
				return true
			end
		end
	end
	
	return false
	
end

