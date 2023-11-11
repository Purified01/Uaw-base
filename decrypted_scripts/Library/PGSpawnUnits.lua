-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGSpawnUnits.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGSpawnUnits.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 69723 $
--
--          $DateTime: 2007/05/04 14:15:24 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")


function Process_Reinforcements()
	for index, btable in ipairs(block_table) do
		for k, block in pairs(btable) do
			if not block.block then
				--Haven't yet issued the reinforcement command, or else a previous attempt failed
				block.block = Reinforce_Unit(block.ref_type, block.entry_marker, block.player, true, block.obey_zones)
			elseif block.block.IsFinished() then
				new_units = block.block.Result()
				if type(new_units) == "table" then
					for j, unit in pairs(new_units) do
						DebugMessage("%s -- Process_Reinforcements Block: %s, unit: %s, allow:%s, delete:%s", tostring(Script), tostring(block.block), tostring(unit), tostring(block.allow_ai_usage), tostring(block.delete_after_scenario))
						if block.allow_ai_usage then
							--MessageBox("allow_ai_usage: %s", tostring(unit))
							unit.Prevent_AI_Usage(false)
						end
						if block.delete_after_scenario then
							--MessageBox("deleting after scenario: %s", tostring(unit))
							unit.Mark_Parent_Mode_Object_For_Death()
						end
						table.insert(block.block_track.unit_list, unit)
					end
					block.block_track.type_count = block.block_track.type_count - 1
					if block.block_track.type_count <= 0 then
						if type(block.callback) == "function" then
							block.callback(block.block_track.unit_list)
						end
						table.remove(block_table, index)
						Process_Reinforcements()
						return
					end
				end
				block_table[index][k] = nil
				Process_Reinforcements()
				return
			end
		end
	end
		
	new_units = nil
end

function Add_Reinforcement(object_type, player)

	if type(object_type) == "string" then
		object_type = Find_Object_Type(object_type)
	end
	
	Reinforce_Unit(object_type, false, player, true, false)
end


-- Reinforce units via transport, simultaneously.
function ReinforceList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, ignore_reinforcement_rules, callback)

	if type(ignore_reinforcement_rules) == "function" then
		MessageBox("Received a function for 6th parameter; expected bool.  Note the signature change, sorry.")
		return
	end
	
	if player == nil then
		MessageBox("expected a player for 3rd parameter; aborting")
		return
	end

	table.insert(block_table, {})
	index = table.getn(block_table)

	block_track = {
		type_count = table.getn(type_list),
		unit_list = {} 
	}
	
	for k, unit_type in pairs(type_list) do
		ref_type = Find_Object_Type(unit_type)
		btab = {
			block = nil,
			block_track = block_track,
			ref_type = ref_type,
			entry_marker = entry_marker,
			player = player,
			obey_zones = not ignore_reinforcement_rules,
			allow_ai_usage = allow_ai_usage, 
			callback = callback,
			delete_after_scenario = delete_after_scenario 
		}
		table.insert(block_table[index], btab)
		btab = nil
		ref_type = nil
	end
end

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


