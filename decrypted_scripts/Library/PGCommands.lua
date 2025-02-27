if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[33] = true
LuaGlobalCommandLinks[74] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[133] = true
LuaGlobalCommandLinks[72] = true
LuaGlobalCommandLinks[32] = true
LuaGlobalCommandLinks[119] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[98] = true
LuaGlobalCommandLinks[115] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGCommands.lua#31 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGCommands.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Joe_Howes $
--
--            $Change: 95705 $
--
--          $DateTime: 2008/03/25 11:03:45 $
--
--          $Revision: #31 $
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

-- This isn't being used any more...snip...  1/23/2008 4:11:09 PM -- BMH
-- Setup a callback for a given object falling under attack.
-- function Register_Attacked_Event(obj, func)
-- 	if not TestValid(obj) then
-- 		MessageBox("%s -- Error, object doesn't exist or has died.", tostring(Script))
-- 		return
-- 	end
--
-- 	if AttackedTable[obj] ~= nil then
-- 		MessageBox("%s -- Error, object already registered for attacked event", tostring(Script))
-- 		return
-- 	end
--
-- 	-- Storing the callback and if the object currently has a "deadly enemy"
-- 	AttackedTable[obj] = {func, false}
-- end
--
--
-- -- Executes the callback with (true, object) if first going under attack.
-- -- Executes the callback with (false) if no longer under attack.
-- function Process_Attacked_Events()
-- 	for obj, table in pairs(AttackedTable) do
-- 		if not TestValid(obj) then
-- 			AttackedTable[obj] = nil
-- 		else
-- 			most_deadly_enemy = FindDeadlyEnemy(obj)
-- 			if most_deadly_enemy then
--
-- 				-- If we have a deadly enemy and this just became true, run the callback.
-- 				if not table[2] then
-- 					table[2] = true
-- 					table[1](true, most_deadly_enemy)
-- 					Process_Attacked_Events()
-- 					return
-- 				end
--
-- 			-- Update that we don't have a deadly enemy any longer.
-- 			--else
-- 			elseif table[2] then
-- 				--MessageBox("obj:%s now has no deadly enemy", tostring(obj))
-- 				table[2] = false
-- 				table[1](false)
-- 			end
-- 		end
-- 	end
-- end
--
-- function Cancel_Attacked_Event(obj)
-- 	if obj ~= nil then
-- 		AttackedTable[obj] = nil
-- 	else
-- 		MessageBox("received nil object")
-- 	end
-- end
--
--

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
	-- Process_Attacked_Events()
	
	-- Don't test if this is a function, so that we can catch accidental redefinitions when it's used as a function.
	if Process_Reinforcements then
		Process_Reinforcements()
	end
	
	-- This is for behavior that we need evaluated every service without regard to story event state.
	if Story_Mode_Service then
		Story_Mode_Service()
	end
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
			obj.Enable_Behavior(41, true)
		end
	end
end

-- Return the most parent object of this object.
-- 5/12/2006 2:26:41 PM -- BMH
function Get_Root_Object(object)
	if not TestValid(object) then return object end
	if object.Has_Behavior(68) then
		return object.Get_Highest_Level_Hard_Point_Parent()
	end
	local parent = object.Get_Parent_Object()
	if parent and parent.Has_Behavior(22) then
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
		gui_scene.Raise_Event("Display_Build_Menu", nil, {structure})
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

function Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash, show_post_game_ui, display_credits)

	local scoring_script = Get_Game_Scoring_Script()
	if scoring_script and scoring_script.Get_Variable("GameOver") ~= true then
		scoring_script.Call_Function("Record_End_Game_Stats", winner)

		if Is_Multiplayer_Skirmish() or Is_Single_Player_Skirmish() then
			if Net == nil then
				Register_Net_Commands()
			end
			Net.Write_Events_File()
		end
		
		if show_splash == nil then
			show_splash = false
		end
		
		if show_post_game_ui == nil then
			show_post_game_ui = false
		end
		
		-- Maria 07.28.2007
		-- If show_post_game_ui then we will disable service for all behaviors (of all objects in the world) and we will
		-- also disable service for the Players.
		-- MBL 10.09.2007 Pause_For_Game_End(show_post_game_ui)
		Pause_Game(show_post_game_ui)

		if show_post_game_ui then
			local scene_name = ""
			if Is_Single_Player_Skirmish() or Is_Multiplayer_Skirmish() then
				scene_name = "Advanced_Battle_End_Dialog"
			elseif (Get_Game_Mode() == "Strategic") then
				scene_name = "Post_Campaign_Scene"
			elseif winner == Find_Player("local") then
				local local_player = Find_Player("local")
				if Is_Player_Of_Faction(local_player, "ALIEN") then
					scene_name = "Alien_Post_Battle_Scene"
				elseif Is_Player_Of_Faction(local_player, "MASARI") then
					scene_name = "Masari_Post_Battle_Scene"
				else
					scene_name = "Novus_Post_Battle_Scene"
				end
			else
				-- Don't show the manage forces screen if the player lost a tactical battle (global scenario only)
				_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash, display_credits)
				return
			end

				Get_Game_Mode_GUI_Scene().Raise_Event("Set_Announcement_Text", nil, nil)
				local for_multiplayer = false
				if Is_Multiplayer_Skirmish() then
					for_multiplayer = true
					Freeze_Multiplayer()
				end
				Get_Game_Mode_GUI_Scene().Raise_Event("Show_Game_End_Screen", nil, { scene_name, winner, to_main_menu, destroy_loser, build_temp_cc, GetCurrentTime.Frame(), for_multiplayer})
		end
	end

	if not show_post_game_ui then
		_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc, show_splash, display_credits)
	end
end


-- Search the build queues of the given player and count the number of instances of object_type that
-- are currently under production. Return that total number.
function PG_Count_Num_Instances_In_Build_Queues(object_type, player_wrapper)

	if not TestValid(object_type) or not TestValid(player_wrapper) then
		return 0
	end
	
	-- Find all objects belonging to the given player that have the "tactical enabler" behavior.
	-- (ie. objects that support build queues)
	local objects_with_build_queues = Find_Objects_With_Behavior(89, player_wrapper)
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
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
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
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
