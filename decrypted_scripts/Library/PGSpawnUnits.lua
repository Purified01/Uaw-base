if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[20] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGSpawnUnits.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGSpawnUnits.lua $
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


-- Spawn units simultaneously.
function SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)

		local unit_list = {}
		
		if not add_to_pop_cap then
			add_to_pop_cap = false
		end
		
		for k, unit_type in pairs(type_list) do
			local unit = Spawn_Unit(unit_type, entry_marker, player)
			table.insert(unit_list, unit)
			if allow_ai_usage then
				--MessageBox("allow_ai_usage: %s", tostring(unit))
				unit.Prevent_AI_Usage(false)
			else
				unit.Prevent_AI_Usage(true) -- This doesn't happen automatically, unlike for Reinforce_Unit
			end
			if delete_after_scenario then
				unit.Mark_Parent_Mode_Object_For_Death()
			end
		end
		
		return unit_list
end

function Strategic_SpawnList(type_list, player, into_fleet)
	local unit_list = {}
	for _, unit_type in pairs(type_list) do
		local unit = Spawn_Unit(unit_type, player, into_fleet)
		if TestValid(unit) then
			table.insert(unit_list, unit)
		end
	end
	return unit_list
end

-- Called once the drop in animation has completed.
function Drop_In_Spawn_Unit_Callback(block)
	local entry = DropInSpawnUnitTable[block]
	if entry == nil then return end
	DropInSpawnUnitTable[block] = nil
	if entry.glyph == nil then return end
	position = entry.glyph.Get_Position()
	owner = entry.glyph.Get_Owner()
	Spawn_Unit(entry.spawn_type, position, owner)
	entry.glyph.Despawn()
end

-- Spawn a unit using the drop in animation for the unit.
function Drop_In_Spawn_Unit(type, glyph_type, position, player, drop_anim)
	glyph = Spawn_Unit(glyph_type, position, player)
	if drop_anim == nil then drop_anim = "Anim_FlyLandDrop" end
	block = glyph.Play_Animation(drop_anim, false)
	if block == nil then return end
	if DropInSpawnUnitTable == nil then DropInSpawnUnitTable = {} end
	DropInSpawnUnitTable[block] = {}
	DropInSpawnUnitTable[block].spawn_type = type
	DropInSpawnUnitTable[block].glyph = glyph
	block.Register_Callback(Drop_In_Spawn_Unit_Callback)
	BlockOnCommand(block)
end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Drop_In_Spawn_Unit = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	SpawnList = nil
	Strategic_SpawnList = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
