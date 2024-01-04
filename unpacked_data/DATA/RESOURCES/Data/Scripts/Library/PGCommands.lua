-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGCommands.lua#55 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGCommands.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Maria_Teruel $
--
--            $Change: 83884 $
--
--          $DateTime: 2007/09/14 17:04:02 $
--
--          $Revision: #55 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")


-- Deprecated...
--
-- function ProduceForce(taskforce)
--    tfIndex = 0
--
--    DebugMessage("Beginning production on %s at %s.", tostring(taskforce),
--          tostring(taskforce.Production_Facility()))
--
--    -- loop through all the unit types and produce each one.
--    UnitType = taskforce.Get_Type_Of_Unit(tfIndex)
--    while UnitType do
--
--       -- Build the object at the production facility.
--       tfObj = WaitProduceObject(UnitType, taskforce.Production_Facility())
--       DebugMessage("Object %s produced.", tostring(tfObj))
--
--       -- Add the object to the task force.
--       taskforce.Add_Force(tfObj)
--
--        -- Remove our reference to the object, since a merge will destroy it.
--       tfObj.Release()
--
--       -- Merge the new fleets together.
--       BlockOnCommand(taskforce.Form_Units())
--
--       -- Look for another unit type.
--       tfIndex = tfIndex + 1
--       UnitType = taskforce.Get_Type_Of_Unit(tfIndex)
--    end
-- end
--
-- function ProduceObject(player, objecttype, where)
--    return _ProduceObject(player, objecttype, where)
-- end
--
-- function WaitProduceObject(objecttype, where)
--    return BlockOnCommand(ProduceObject(PlayerObject, objecttype, where))
-- end

function WaitForever()
	DebugMessage("%s -- Waiting forever...", tostring(Script))
	while true do
		PumpEvents()
	end
--	BlockOnCommand(BlockForever())
	DebugMessage("%s -- Something interrupted the wait!.", tostring(Script))
end

--	TimerTable[func] = {timeout = timeout, start_time = GetCurrentTime(), param = param }
--function Debug_Timer_Table()
--	OutputDebug("%s -- TimerTable Dump.\n", tostring(Script))
--	for func,tabtab in pairs(TimerTable) do
--		for idx,tab in pairs(tabtab) do
--			OutputDebug("%s, %f, %f, %s\n", tostring(func), tab.timeout, tab.start_time, tostring(tab.param))
--		end
--	end
--end

function Register_Timer(func, timeout, param)
	if TimerTable[func] == nil then
		TimerTable[func] = {}
	end
	
	table.insert(TimerTable[func], {timeout = timeout, start_time = GetCurrentTime(), param = param})
end

function Process_Timers()
	for func,tabtab in pairs(TimerTable) do
		found_entry = false
		for idx,tab in pairs(tabtab) do
			found_entry = true
			if tab.timeout + tab.start_time < GetCurrentTime() then
				tabtab[idx] = nil
				func(tab.param)
				Process_Timers()
				return
			end
		end
		if found_entry == false then
			TimerTable[func] = nil
			Process_Timers()
			return
		end
	end
end

-- Cancels all occurences of this timer function
function Cancel_Timer(func)
	if func ~= nil then
		TimerTable[func] = nil
	else
		MessageBox("%s -- cancelling nonexistant function, got:%s; aborting.", tostring(Script), type(func))
	end
end


-- Setup a callback for the death or deletion of a given object.
function Register_Death_Event(obj, func)
	if not TestValid(obj) then
		MessageBox("%s -- Error, object doesn't exist or has already died.", tostring(Script))
		return
	end

	if DeathTable[obj] ~= nil then
		MessageBox("%s -- Error, object already registered for death event", tostring(Script))
		return
	end
	
	DeathTable[obj] = func
end

function Process_Death_Events()
	for obj, func in pairs(DeathTable) do
		if not TestValid(obj) then
			DeathTable[obj] = nil
			func()
			Process_Death_Events()
			return
		end
	end
end

-- Setup a callback for a given object falling under attack.
function Register_Attacked_Event(obj, func)
	if not TestValid(obj) then
		MessageBox("%s -- Error, object doesn't exist or has died.", tostring(Script))
		return
	end

	if AttackedTable[obj] ~= nil then
		MessageBox("%s -- Error, object already registered for attacked event", tostring(Script))
		return
	end
	
	-- Storing the callback and if the object currently has a "deadly enemy"
	AttackedTable[obj] = {func, false}
end


-- Executes the callback with (true, object) if first going under attack.
-- Executes the callback with (false) if no longer under attack.
function Process_Attacked_Events()
	for obj, table in pairs(AttackedTable) do
		if not TestValid(obj) then
			AttackedTable[obj] = nil
		else
			most_deadly_enemy = FindDeadlyEnemy(obj)
			if most_deadly_enemy then
		
				-- If we have a deadly enemy and this just became true, run the callback.
				if not table[2] then
					table[2] = true
					table[1](true, most_deadly_enemy)
					Process_Attacked_Events()
					return
				end
			
			-- Update that we don't have a deadly enemy any longer.
			--else
			elseif table[2] then
				--MessageBox("obj:%s now has no deadly enemy", tostring(obj))
				table[2] = false
				table[1](false)
			end
		end
	end
end

function Cancel_Attacked_Event(obj)
	if obj ~= nil then
		AttackedTable[obj] = nil
	else
		MessageBox("received nil object")
	end
end



-- Set up proximity triggers on arbitrary objects and have them serviced.
function Register_Prox(obj, func, range, player_filter)

	-- prevent this from doing anything in galactic mode
	if Get_Game_Mode() == "Strategic" then
		DebugMessage("%s -- Warning, proximity register disallowed in galactic mode; aborting.", tostring(Script))
		return
	end

	if not TestValid(obj) then
		MessageBox("%s -- Register_Prox recieved invalid object; aborting prox register", tostring(Script))
		ScriptError("%s -- Register_Prox recieved invalid object", tostring(Script))
		return
	end
	
	-- Note the player_filter is optional.  The user of this function must check
	-- for player validity at the source.	
	if player_filter == nil then
		DebugMessage("%s -- Warning, passed a nil player, not filtering prox by player", tostring(Script))
	end

	obj.Event_Object_In_Range(func, range, player_filter)
	ProxTable[obj] = 1
end

function Process_Proximities()
	for obj, count in pairs(ProxTable) do
		if TestValid(obj) then
			obj.Service_Wrapper()
		else
			ProxTable[obj] = nil
		end
	end
end

function Pump_Service()
	Process_Timers()
	Process_Death_Events()
	Process_Proximities()
	Process_Attacked_Events()
	
	-- Don't test if this is a function, so that we can catch accidental redefinitions when it's used as a function.
	if Process_Reinforcements then
		Process_Reinforcements()
	end
	
	-- This is for behavior that we need evaluated every service without regard to story event state.
	if Story_Mode_Service then
		Story_Mode_Service()
	end
end


-- Try an ability if the AI difficulty will allow a chance
function Try_Ability(thing, ability_name, target)

	owner = PlayerObject
	if not Is_A_Taskforce(thing) then
		owner = thing.Get_Owner()
	end
	if owner == nil then
		MessageBox("%s -- no owner for thing:%s", tostring(Script), tostring(thing))
	end

	-- At a given difficulty, there is a chance that the ability use will be allowed.
	if not Chance(GetAbilityChanceSeed(), GetChanceAllowed(owner.Get_Difficulty())) then
		return false
	end

	return Use_Ability_If_Able(thing, ability_name, target)
end


-- Activates the ability for a unit or a taskforce's units if able.
-- Optionally uses ability on a target.
-- Returns true if the ability was attempted
function Use_Ability_If_Able(thing, ability_name, target)

	-- Taskforces aren't able to check for the ability availablity or readiness, but check this for units
	if Is_A_Taskforce(thing) or (thing.Has_Ability(ability_name) and thing.Is_Ability_Ready(ability_name) and (not thing.Is_Ability_Active(ability_name))) then
	
		if target == nil then
			thing.Activate_Ability(ability_name, true)
		elseif TestValid(target) then
			thing.Activate_Ability(ability_name, target)
		end
		return true
	end
	return false
end


function Is_A_Taskforce(thing)
	return thing and thing.Get_Unit_Table
end


-- This will consider diverting the passed object in order to use an area of effect ability centered on the unit.
function ConsiderDivertAndAOE(object, ability_name, area_of_effect, recent_enemy_units, min_threat_to_use_ability)

	-- At a given difficulty, there is a chance that the divert for ability use will be allowed.
	if not Chance(GetCurrentMinute(), GetChanceAllowed(object.Get_Owner().Get_Difficulty())) then
		return
	end

	-- See if the ability is ready and there are enough enemies around to consider using it.
	if object.Is_Ability_Ready(ability_name) then

		DebugMessage("%s -- %s is ready and trigger number met", tostring(Script), ability_name)

		-- If we haven't found a good use for the ability
		if aoe_pos == nil then

			-- Find a good place to use the ability and divert or throw the result away.
			aoe_pos, aoe_victim_threat = Find_Best_Local_Threat_Center(recent_enemy_units, area_of_effect)
			if aoe_pos == nil then
				DebugMessage("%s -- couldn't get a valid threat center", tostring(Script))
				DebugPrintTable(recent_enemy_units)
				return
			end				

			DebugMessage("%s -- Found ability pos with threat %d", tostring(Script), aoe_victim_threat)
			if (aoe_victim_threat > min_threat_to_use_ability) then
			
				-- Check distance to prevent the unit from spinning in circles on repeated diversions
				if object.Get_Distance(aoe_pos) > 15 then
					DebugMessage("%s -- Met minimum threat; diverting.", tostring(Script))
					Use_Ability_If_Able(object, "SPRINT")
					object.Divert(aoe_pos)
				else
					DebugMessage("%s -- Met minimum threat; Already very close to ideal target so no divert necessary.", tostring(Script))
				end
			else
				DebugMessage("%s -- Resetting pos and threat.", tostring(Script))
				aoe_pos = nil
				aoe_victim_threat = nil
			end

		-- We have found a good use for the ability 
		else

			-- Are we done chasing down the position to use the ability?
			if object.Is_On_Diversion() then
			
				DebugMessage("%s -- In process of diverting to chase threat %d (no new orders issued)", tostring(Script), aoe_victim_threat)
			
			else
				
				-- We're done diverting.  Perform a sanity check to make sure at least one enemy is now in range.
				--if OneOrMoreInRange(object, recent_enemy_units, area_of_effect) then
				-- We're done diverting so check to see if we're at least in range of the best location (even if not centered on it)
				aoe_pos, aoe_victim_threat = Find_Best_Local_Threat_Center(recent_enemy_units, area_of_effect)
				if aoe_pos and (object.Get_Distance(aoe_pos) < area_of_effect) then

					-- Use the ability
					DebugMessage("%s -- Attempting %s.", tostring(Script), ability_name)
					Use_Ability_If_Able(object, ability_name)
				else
					DebugMessage("%s -- Nothing at diversion locaion; aborting.", tostring(Script))
				end
				
				-- Reset everything; this try is done.  If the victims moved too much, we'll need to start over.
				recent_enemy_units = {}
				aoe_pos = nil
				aoe_victim_threat = nil
			end
		end
	end
end

function OneOrMoreInRange(origin_unit, target_unit_list, range)
	for key, unit in pairs(target_unit_list) do
		if origin_unit.Get_Distance(unit) < range then
			return true
		end
	end
	return false
end

function PruneFriendlyObjects(obj_table)
	non_friendly_obj_table = {}
	for i, obj in pairs(obj_table) do
		if not (obj.Get_Owner() == PlayerObject) then
			 table.insert(non_friendly_obj_table, obj)
		end
	end
	
	return non_friendly_obj_table
end

-- Always returns a unit if receiving an object that is a unit or a unit's hardpoint.
function Get_Last_Tactical_Parent(obj)
	parent = obj.Get_Highest_Level_Hard_Point_Parent()
	if parent == nil then
		parent = obj
	end
	return parent
	
--	while obj.Get_Parent_Object() ~= nil do
--		obj = obj.Get_Parent_Object()
--    end
--	return obj
end

function Burn_All_Objects(center_object, radius, object_type)
	local burn_objects = {}
	if object_type then
		burn_objects = Find_All_Objects_Of_Type(center_object, radius, object_type)
	else
		burn_objects = Find_All_Objects_Of_Type(center_object, radius)
	end

	for _, obj in pairs(burn_objects) do
		if obj.Get_Type().Get_Type_Value("Is_Combustible") then
			obj.Enable_Behavior(BEHAVIOR_BURNING, true)
		end
	end
end

-- Return the most parent object of this object.
-- 5/12/2006 2:26:41 PM -- BMH
function Get_Root_Object(object)
	if not TestValid(object) then return object end
	if object.Has_Behavior(BEHAVIOR_HARD_POINT) then
		return object.Get_Highest_Level_Hard_Point_Parent()
	end
	local parent = object.Get_Parent_Object()
	if parent and parent.Has_Behavior(BEHAVIOR_TEAM) then
		return parent
	end
	return object
end

function Carve_Glyph(carver, type_name, position)

	local beacon_type = Find_Object_Type(type_name).Get_Type_Value("Tactical_Buildable_Beacon_Type")
	local beacon = Create_Generic_Object(beacon_type, position, carver.Get_Owner())
	carver.Activate_Ability("Alien_Tactical_Build_Structure_Ability", beacon)

end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.13.2006
-- This function prompts the game mode scene to disply the build menu of the specified producing structure.  If no structure has been
-- specified, an arbitrary one will be chosen!
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function Display_Build_Menu(structure)

	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event_Immediate("Display_Build_Menu", nil, {structure})
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.15.2006
-- Process_Tactical_Mission_Over - This function sets the new state in the strategic script and falls back to strategic mode
-- If you want to immediately transition into tactical mode you need to use the Force_Land_Invasion when you service the state
-- (in the strategic script) set by this function.
--
-- INPUT: YOU MUST ALWAYS SPECIFCY WHICH PLAYER IS THE ONE COMPLETING THE MISSION.
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function Process_Tactical_Mission_Over(player)

	local global_script = Get_Game_Mode_Script("Strategic")
	if Is_Player_Of_Faction(player, "Novus") then
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
	elseif Is_Player_Of_Faction(player, "Alien") or Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then 
		global_script.Call_Function("Alien_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		-- do something else
	elseif Is_Player_Of_Faction(player, "Masari") then 
		global_script.Call_Function("Masari_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		-- do something else
	else
		MessageBox("PGCommands::Trigger_Next_Mission: Unhandled case")
	end
	
	-- Parameters:  winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag
	Quit_Game_Now(player, false, true, false)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- RICK 12.07.2006
--
-- PG_Find_All_Objects_Of_Type(type) - This function serves as a 'virtual wrapper' for Find_All_Objects_Of_Type.
-- any objects which span a range of types (Alien_Recon_Tank and Alien_Recon_Tank_Flying for example)
-- will be returned in a single combined list. If a non spanning object type is given, it executes the normal function.
-- This function can also be used to find structures under construction combined with the intact ones of similar type.
-- It will not find and combine beacons, as those structures are not technically active yet.
--
-- Always use the base/ground unit or the completed structure as the search object to ensure success.
--
-- NOTE: The code function that we wrap (Find_All_Objects_Of_Type) supports many filter parameters beyond just
-- the object type. In order to support those additional filters (such as Player!!!), we use the variable argument
-- syntax here to mimic the flexible function call syntax of Find_All_Objects_Of_Type itself. See the wiki entry!
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function PG_Find_All_Objects_Of_Type(input_type, ...)

	-- Initialize the variant lookup list.
	local discovered_variant_list = {}
	local total_variant_list = {}
	local variant_count,append_count

	if variant_lookups == nil then
		variant_lookups = {}
		
		-- Alien Structures
		variant_lookups["Alien_Arrival_Site"] = {"Alien_Arrival_Site", "Alien_Arrival_Site_Construction"}
		variant_lookups["Alien_Gravitic_Manipulator"] = {"Alien_Gravitic_Manipulator", "Alien_Gravitic_Manipulator_Construction"}
		variant_lookups["Alien_Radiation_Spitter"] = {"Alien_Radiation_Spitter", "Alien_Radiation_Spitter_Construction"}
		variant_lookups["Alien_Superweapon_Mass_Drop"] = {"Alien_Superweapon_Mass_Drop", "Alien_Superweapon_Mass_Drop_Construction"}
	
	
		-- Alien Walkers
		variant_lookups["Alien_Walker_Assembly"] = {"Alien_Walker_Assembly", "Customized_Alien_Walker_Assembly", "Alien_Walker_Assembly_Glyph", "Customized_Alien_Walker_Assembly_Glyph"}
		variant_lookups["Alien_Walker_Habitat"] = {"Alien_Walker_Habitat", "Customized_Alien_Walker_Habitat", "Alien_Walker_Habitat_Glyph", "Customized_Alien_Walker_Habitat_Glyph"}
		variant_lookups["Alien_Walker_Science"] = {"Alien_Walker_Science", "Customized_Alien_Walker_Science", "Alien_Walker_Science_Glyph", "Customized_Alien_Walker_Science_Glyph"}
		
		
		-- Alien Units
		variant_lookups["Alien_Hero_Orlok"] = {"Alien_Hero_Orlok", "Alien_Hero_Orlok_Base", "Alien_Hero_Orlok_Endure_Mode", "Alien_Hero_Orlok_Siege_Mode"}
		variant_lookups["Alien_Superweapon_Reaper_Turret"] = {"Alien_Superweapon_Reaper_Turret", "Alien_Reaper_Turret_Beacon", "Alien_Reaper_Turret_Construction"}
		variant_lookups["Alien_Scan_Drone"] = {"Alien_Scan_Drone", "Alien_Scan_Drone_Construction"}
	
	
		-- Masari Structures
		variant_lookups["Masari_Air_Inspiration"] = {"Masari_Air_Inspiration", "Masari_Air_Inspiration_Beacon", "Masari_Air_Inspiration_Construction", "Masari_Air_Inspiration_Fire", "Masari_Air_Inspiration_Ice"}
		variant_lookups["Masari_Atlatea"] = {"Masari_Atlatea", "Masari_Atlatea_Fire", "Masari_Atlatea_Ice"}
		variant_lookups["Masari_Element_Magnet"] = {"Masari_Element_Magnet_Fire", "Masari_Element_Magnet_Ice"}
		variant_lookups["Masari_Elemental_Collector"] = {"Masari_Elemental_Collector", "Masari_Elemental_Collector_Beacon", "Masari_Elemental_Collector_Construction", "Masari_Elemental_Collector_Fire", "Masari_Elemental_Collector_Ice"}
		variant_lookups["Masari_Elemental_Controller"] = {"Masari_Elemental_Controller", "Masari_Elemental_Controller_Beacon", "Masari_Elemental_Controller_Construction", "Masari_Elemental_Controller_Fire", "Masari_Elemental_Controller_Ice"}
		variant_lookups["Masari_Foundation"] = {"Masari_Foundation","Masari_Foundation_Beacon" ,"Masari_Foundation_Construction", "Masari_Foundation_Fire", "Masari_Foundation_Ice"}
		variant_lookups["Masari_Ground_Inspiration"] = {"Masari_Ground_Inspiration","Masari_Ground_Inspiration_Beacon" , "Masari_Ground_Inspiration_Construction", "Masari_Ground_Inspiration_Fire", "Masari_Ground_Inspiration_Ice"}
		variant_lookups["Masari_Guardian"] = {"Masari_Guardian","Masari_Guardian_Beacon" ,"Masari_Guardian_Construction", "Masari_Guardian_Fire", "Masari_Guardian_Ice"}
		variant_lookups["Masari_Infantry_Inspiration"] = {"Masari_Infantry_Inspiration", "Masari_Infantry_Inspiration_Beacon", "Masari_Infantry_Inspiration_Construction", "Masari_Infantry_Inspiration_Fire", "Masari_Infantry_Inspiration_Ice"}
		variant_lookups["Masari_Inventors_Lab"] = {"Masari_Inventors_Lab","Masari_Inventors_Lab_Beacon" , "Masari_Inventors_Lab_Construction", "Masari_Inventors_Lab_Fire", "Masari_Inventors_Lab_Ice"}
		variant_lookups["Masari_Key_Inspiration"] = {"Masari_Key_Inspiration", "Masari_Key_Inspiration_Fire", "Masari_Key_Inspiration_Ice"}
		variant_lookups["Masari_Megaweapon"] = {"Masari_Megaweapon", "Masari_Megaweapon_Fire", "Masari_Megaweapon_Ice"}
		variant_lookups["Masari_Natural_Interpreter"] = {"Masari_Natural_Interpreter","Masari_Natural_Interpreter_Beacon", "Masari_Natural_Interpreter_Construction", "Masari_Natural_Interpreter_Fire", "Masari_Natural_Interpreter_Ice"}
		variant_lookups["Masari_Sky_Guardian"] = {"Masari_Sky_Guardian", "Masari_Sky_Guardian_Beacon", "Masari_Sky_Guardian_Construction", "Masari_Sky_Guardian_Fire", "Masari_Sky_Guardian_Ice"}
		variant_lookups["Masari_Will_Processor"] = {"Masari_Will_Processor", "Masari_Will_Processor_Fire", "Masari_Will_Processor_Ice"}
	
	
		-- Masari Units
		variant_lookups["Masari_Hero_Charos"] = {"Masari_Hero_Charos", "Masari_Hero_Charos_Fire", "Masari_Hero_Charos_Ice"}
		variant_lookups["Masari_Hero_Zessus"] = {"Masari_Hero_Zessus", "Masari_Hero_Zessus_Base", "Masari_Hero_Zessus_Fire", "Masari_Hero_Zessus_Ice"}
		variant_lookups["Masari_Figment"] = {"Masari_Figment", "Masari_Figment_Fire", "Masari_Figment_Ice"}
		variant_lookups["Masari_Seeker"] = {"Masari_Seeker", "Masari_Seeker_Fire", "Masari_Seeker_Ice"}
		variant_lookups["Masari_Skylord"] = {"Masari_Skylord", "Masari_Skylord_Fire", "Masari_Skylord_Ice"}
		variant_lookups["Masari_Architect"] = {"Masari_Architect","Masari_Architect_Fire","Masari_Architect_Ice"}
	--	variant_lookups["Masari_Architect"] = {"Masari_Architect", "Masari_Sentry_With_Architect"}
		variant_lookups["Masari_Seer"] = {"Masari_Seer", "Masari_Seer_Fire", "Masari_Seer_Ice"}
	--	variant_lookups["Masari_Seer"] = {"Masari_Seer", "Masari_Seer_Fire", "Masari_Seer_Ice", "Masari_Sentry_With_Seer"}
		variant_lookups["Masari_Enforcer"] = {"Masari_Enforcer", "Masari_Enforcer_Fire", "Masari_Enforcer_Ice"}
		variant_lookups["Masari_Peacebringer"] = {"Masari_Peacebringer", "Masari_Peacebringer_Fire", "Masari_Peacebringer_Ice"}
			
		variant_lookups["Masari_Avenger"] = {"Masari_Avenger",
														 "Masari_Avenger_Enforcer",		"Masari_Avenger_Enforcer_Fire",			"Masari_Avenger_Enforcer_Ice",
														 "Masari_Avenger_Peacebringer",	"Masari_Avenger_Peacebringer_Fire",		"Masari_Avenger_Peacebringer_Ice",
														 "Masari_Avenger_Seeker",			"Masari_Avenger_Seeker_Fire",				"Masari_Avenger_Seeker_Ice",
														 "Masari_Avenger_Sentry",			"Masari_Avenger_Sentry_Fire",				"Masari_Avenger_Sentry_Ice",
														 "Masari_Avenger_Skylord",			"Masari_Avenger_Skylord_Fire",			"Masari_Avenger_Skylord_Ice",
														 "Masari_Avenger_Figment",			"Masari_Avenger_Figment_Fire",			"Masari_Avenger_Figment_Ice"
														}
	
		variant_lookups["Masari_Disciple"] = {"Masari_Disciple", "Masari_Disciple_Fire", "Masari_Disciple_Ice",}
	
	--	variant_lookups["Masari_Disciple"] = {"Masari_Disciple", "Masari_Disciple_Fire", "Masari_Disciple_Ice",
	--			"Masari_Sentry_With_Disciple", "Masari_Sentry_With_Disciple_Fire", "Masari_Sentry_With_Disciple_Ice"}
	
	
		variant_lookups["Masari_Sentry"] = {"Masari_Sentry", "Masari_Sentry_Fire","Masari_Sentry_Ice"}
		
		
		-- Novus Structures
		variant_lookups["Novus_Aircraft_Assembly"] = {"Novus_Aircraft_Assembly", "Novus_Aircraft_Assembly_Construction", "Novus_Aircraft_Assembly_With_Scramjet_Hangar"}
		variant_lookups["Novus_Superweapon_Gravity_Bomb"] = {"Novus_Superweapon_Gravity_Bomb", "Novus_Superweapon_Gravity_Bomb_Construction", "NM01_Gravity_Bomb"}
		variant_lookups["Novus_Input_Station"] = {"Novus_Input_Station","Novus_Input_Station_Beacon", "Novus_Input_Station_Construction"}
		variant_lookups["Novus_Power_Router"] = {"Novus_Power_Router", "Novus_Power_Router_Construction"}
		variant_lookups["Novus_Redirection_Turret"] = {"Novus_Redirection_Turret", "Novus_Redirection_Turret_Construction"}
		variant_lookups["Novus_Remote_Terminal"] = {"Novus_Remote_Terminal", "Novus_Remote_Terminal_Construction"}
		variant_lookups["Novus_Robotic_Assembly"] = {"Novus_Robotic_Assembly", "Novus_Robotic_Assembly_Construction", "Novus_Robotic_Assembly_With_Instance_Generator"}
		variant_lookups["Novus_Science_Lab"] = {"Novus_Science_Lab", "Novus_Science_Center_Construction", "Novus_Science_Lab_With_Singularity_Compressor"}
		variant_lookups["Novus_Signal_Tower"] = {"Novus_Signal_Tower", "Novus_Signal_Tower_Construction"}
		variant_lookups["Novus_Superweapon_EMP"] = {"Novus_Superweapon_EMP", "Novus_Superweapon_EMP_Construction"}
		variant_lookups["Novus_Vehicle_Assembly"] = {"Novus_Vehicle_Assembly", "Novus_Vehicle_Assembly_Construction", "Novus_Vehicle_Assembly_With_Inversion_Processor", "Novus_Vehicle_Assembly_With_Resonation_Processor"}
	
	
		-- Novus Units
		variant_lookups["Novus_Hero_Founder"] = {"Novus_Hero_Founder", "Novus_Hero_Founder_Performance"}
		variant_lookups["Novus_Field_Inverter"] = {"Novus_Field_Inverter", "Novus_Field_Inverter_Shield_Mode"}
	end

		
	local variant_types = variant_lookups[input_type]
	
	-- If there are no variant types for this entry, perform a regular find.
	if variant_types == nil then
		return Find_All_Objects_Of_Type(input_type, ...)
	else
		-- Perform a compound search for variants.
		for variant_count = 1,#variant_types do
			discovered_variant_list = Find_All_Objects_Of_Type(variant_types[variant_count], ...)
			if #discovered_variant_list > 0 then
				for append_count = 1,#discovered_variant_list do
					table.insert(total_variant_list,discovered_variant_list[append_count])
				end
			end
		end
		return total_variant_list
	end
	
end

function Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash, show_post_game_ui)

	local scoring_script = Get_Game_Scoring_Script()
	if scoring_script and scoring_script.Get_Variable("GameOver") ~= true then
		scoring_script.Call_Function("Record_End_Game_Stats", winner)

		if Is_Multiplayer_Skirmish() or Is_Single_Player_Skirmish() then
			if Net == nil then
				Register_Net_Commands()
			end
			Net.Write_Events_File()
		end
		
		if show_post_game_ui == nil then
			show_post_game_ui = false
		end
		
		-- Maria 07.28.2007
		-- If show_post_game_ui then we will disable service for all behaviors (of all objects in the world) and we will
		-- also disable service for the Players.
		Pause_For_Game_End(show_post_game_ui)

		if show_post_game_ui then
			local quit_params = {}
			quit_params.Winner = winner
			quit_params.DestroyLoser = destroy_loser
			quit_params.ToMainMenu = to_main_menu
			quit_params.BuildTempCC = build_temp_cc
			quit_params.GameEndTime = GetCurrentTime.Frame()

			local scene_name = ""
			local local_player = Find_Player("local")
			if Is_Single_Player_Skirmish() or Is_Multiplayer_Skirmish() then
				scene_name = "Advanced_Battle_End_Dialog"
			elseif (Get_Game_Mode() == "Strategic") then
				scene_name = "Post_Campaign_Scene"
			elseif winner == local_player then
				if Is_Player_Of_Faction(local_player, "ALIEN") then
					scene_name = "Alien_Post_Battle_Scene"
				elseif Is_Player_Of_Faction(local_player, "MASARI") then
					scene_name = "Masari_Post_Battle_Scene"
				else
					scene_name = "Novus_Post_Battle_Scene"
				end
			else
				-- Don't show the manage forces screen if the player lost a tactical battle (global scenario only)
				_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash)
				return
			end

			local post_game_ui = Get_Game_Mode_GUI_Scene()[scene_name]
			if not TestValid(post_game_ui) then
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, nil)
				post_game_ui = Get_Game_Mode_GUI_Scene().Create_Embedded_Scene(scene_name, scene_name)
			end

			post_game_ui.Set_Bounds(0.0, 0.0, 1.0, 1.0)
			post_game_ui.Set_Hidden(false)
			post_game_ui.Bring_To_Front()
			post_game_ui.Set_User_Data(quit_params)
			if post_game_ui.Finalize_Init() then
				post_game_ui.Start_Modal(Really_Quit)
			else
				_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash)
			end
		end
	end

	if not show_post_game_ui then
		_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash)
	end
end

function Really_Quit(post_game_ui)
	local quit_params = post_game_ui.Get_User_Data()
	_Quit_Game_Now(quit_params.Winner, quit_params.ToMainMenu, quit_params.DestroyLoser, quit_params.BuildTempCC)
end


-- Search the build queues of the given player and count the number of instances of object_type that
-- are currently under production. Return that total number.
function PG_Count_Num_Instances_In_Build_Queues(object_type, player_wrapper)

	if not TestValid(object_type) or not TestValid(player_wrapper) then
		return 0
	end
	
	-- Find all objects belonging to the given player that have the "tactical enabler" behavior.
	-- (ie. objects that support build queues)
	local objects_with_build_queues = Find_Objects_With_Behavior(BEHAVIOR_TACTICAL_ENABLER, player_wrapper)
	if not objects_with_build_queues then
		return 0
	end
	
	-- Iterate those objects, searching the build queues of each one for instances of the given object type.
	local num_instances_in_build_queues = 0
	for _,obj in pairs(objects_with_build_queues) do
		if TestValid(obj) then
			local build_queue = obj.Tactical_Enabler_Get_Queued_Objects()
			if build_queue ~= nil then	-- there may very well be nothing queued here
				for _,queue_entry in pairs(build_queue) do
					if queue_entry ~= nil then
						if queue_entry.Type == object_type then
							num_instances_in_build_queues = num_instances_in_build_queues + queue_entry.Quantity
						end
					end
				end
			end
		end
	end
	
	return num_instances_in_build_queues
end

function Kill_All_Units_Of_Player(player)
	local all_units = Find_All_Objects_Of_Type(player)
	for _,unit in pairs(all_units) do
		-- NOTE: Only masari units have this type of attributes!
		if Is_Player_Of_Faction(player, "Masari") then
			-- Make sure killing the units doesn't spawn avengers or any other type of unit!!.
			-- Thus, clear the Phoenix and Regenerate types for this object (if applicable)
			unit.Add_Attribute_Modifier("Phoenix_Type", "")
			unit.Add_Attribute_Modifier("Regenerate_Type", "")
		end
		
		--Need to use special kill logic here for walkers
		local unit_script = unit.Get_Script()
		if not TestValid(unit_script) or not unit_script.Call_Function("Kill_Walker") then
			unit.Take_Damage(9999999999, "Damage_Default")  -- kill it
		end
	end
end
