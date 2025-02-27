if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[21] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[15] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[53] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/VS2DemoBattle.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/VS2DemoBattle.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGSpawnUnits")
require("PGMoveUnits")
require("UIControl")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")


---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	-- Maria 07.11.2006 - Needed for support of the ESC key
	ClosedHuds = false
	
	Define_State("State_Init", State_Init)
	Define_State("State_Air_Attack_One", State_Air_Attack_One)
	Define_State("State_Air_Attack_Two", State_Air_Attack_Two)
	Define_State("State_Mixed_Ground_Attack", State_Mixed_Ground_Attack)

	num_grunts_for_air_attack = 8
	
	uav_type_list = {
		"Military_Dragonfly_UAV"
		,"Military_Dragonfly_UAV"
		,"Military_Dragonfly_UAV"
		,"Military_Dragonfly_UAV"
	}

	jet_type_list = {
		"Novus_Dervish_Jet"
		,"Novus_Dervish_Jet"
	}

end



-- ---------------------------------------
-- Maria 07.11.2006
-- Support for the ESC key 
-- ---------------------------------------
function Close_All_Huds(were_huds_open)
	ClosedHuds = were_huds_open[1]
end


---------------------------------------------------------------------------------------------------
------ STATES	    -------------------------------------------------------------------------------



function State_Init(message)
	if message == OnEnter then
	
		-- Initialize various aspects of the scenario.
		--DebugBreak()

		state_start_time = GetCurrentTime()
		
		player_alien = Find_Player("Alien")
		player_novus = Find_Player("Novus")
		player_military = Find_Player("Military")
		
		FogOfWar.Reveal_All(player_alien)
		FogOfWar.Reveal_All(player_novus)
		FogOfWar.Reveal_All(player_military)
		

		--Set_Active_Context("vs2demo")

		-- Find various markers for spawning and pathing air units
		air_one_marker = Find_Hint("Marker_Generic", "air-one")
		if air_one_marker == nil then
			MessageBox("didn't find air_one_marker")
		end
		air_two_marker = Find_Hint("Marker_Generic", "air-two")
		if air_two_marker == nil then
			MessageBox("didn't find air_two_marker")
		end
		air_three_marker = Find_Hint("Marker_Generic", "air-three")
		if air_three_marker == nil then
			MessageBox("didn't find air_three_marker")
		end
        
		-- Find various markers for spawning and pathing ground units
		mixed_ground_units_marker_one = Find_Hint("Marker_Generic", "mixed-ground-one")
		if mixed_ground_units_marker_one == nil then
			MessageBox("didn't find mixed_ground_units_marker")
		end
		mixed_ground_units_marker_two = Find_Hint("Marker_Generic", "mixed-ground-two")
		if mixed_ground_units_marker_two == nil then
			MessageBox("didn't find mixed_ground_units_marker_two")
		end
		mixed_ground_units_marker_three = Find_Hint("Marker_Generic", "mixed-ground-three")
		if mixed_ground_units_marker_three == nil then
			MessageBox("didn't find mixed_ground_units_marker_three")
		end
		
		mech = Find_First_Object("Novus_Hero_Mech", player_novus)
		if mech == nil then
			MessageBox("didn't find mech")
		end

		Cache_Models()

		-- Find starting set of alien units, then keep this updated by events that add units.
		-- Remove dead units before making use of the list.
		alien_units = Find_All_Parent_Units("Infantry | Vehicle | Air", player_alien)
		alien_walkers = Find_All_Parent_Units("Walker", player_alien)
		alien_grunts = {}
		
		-- Ignore the dummy hero, who is necessary to trigger the invasion.
		alien_hero = Find_First_Object("Alien_Hero", player_alien)
		if not TestValid(alien_hero) then
			MessageBox("didn't find alien_hero")
		else			
			alien_hero.Hide(true)  				-- Can't be seen
			alien_hero.Set_Selectable(false)	-- Can't be selected
			alien_hero.Set_In_Limbo(true)		-- Can't be attacked by enemies
		end
		
		-- Tell the defense units to guard their current position.
		novus_units = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus)
		for i, unit in pairs(novus_units) do
			unit.Guard_Target(unit.Get_Position())
		end
		
		-- The mech's default weapon should be used continuously and the special attack (missiles) should autofire when available.	
		mech.Set_All_Abilities_Autofire(true)

		-- DEBUG SKIP
		--Set_Next_State("State_Mixed_Ground_Attack")

	elseif message == OnUpdate then
	
		-- Move to the next state if the player has eno`ugh units 
		Remove_Invalid_Objects(alien_grunts)
		if (alien_grunts and table.getn(alien_grunts) >= num_grunts_for_air_attack) then
			Set_Next_State("State_Air_Attack_One")
		end

	elseif message == OnExit then


	end
end


function Cache_Models()
	Find_Object_Type("Alien_Team_Science_Greys").Load_Assets()
	Find_Object_Type("Alien_Recon_Tank").Load_Assets()
	Find_Object_Type("Alien_Grunt").Load_Assets()
	Find_Object_Type("Alien_Brute").Load_Assets()
	Find_Object_Type("Military_Dragonfly_UAV").Load_Assets()
	Find_Object_Type("Novus_Dervish_Jet").Load_Assets()
end

---------------------------------------------------------------------------------------------------



function State_Air_Attack_One(message)
	if message == OnEnter then
	
		-- Jets attack the first walker.
		novus_jets = SpawnList(jet_type_list, air_one_marker, player_novus)
		Concat_Indexed_Tables(novus_jets, SpawnList(jet_type_list, air_two_marker, player_novus))
		Concat_Indexed_Tables(novus_jets, SpawnList(jet_type_list, air_three_marker, player_novus))
		for i, unit in pairs(novus_jets) do
			unit.Attack_Target(alien_walkers[1])
		end

		-- UAVs attack everything the alien player has that's not a walker.
		military_uav = SpawnList(uav_type_list, air_one_marker, player_novus)
		Concat_Indexed_Tables(military_uav, SpawnList(uav_type_list, air_two_marker, player_novus))
		Concat_Indexed_Tables(military_uav, SpawnList(uav_type_list, air_three_marker, player_novus))
		Attack_All(military_uav, alien_units)
		
		-- Jets return independently, without blocking
		-- (there is a bug with their formation move where it doesn't finish blocking)
		Remove_Invalid_Objects(novus_jets)
		for i, unit in pairs(novus_jets) do
			unit.Move_To(air_one_marker)
		end

		-- UAVs run away.
		Formation_Move(military_uav, air_one_marker)

		-- One time (non blocking) guard order to the UAVs.
		Remove_Invalid_Objects(military_uav)
		for i, unit in pairs(military_uav) do
			unit.Guard_Target(air_one_marker)
		end

	elseif message == OnUpdate then
	
		-- Move to the next state if enough anti-air hardpoints are configured or if enough time has elapsed.
		local aa_count = Get_Hardpoint_Count(alien_walkers, Find_Object_Type("Alien_Walker_Habitat_Lightning_Turret"))
		if (aa_count >= 2) then
			Set_Next_State("State_Air_Attack_Two")
		end

	end
	
end





---------------------------------------------------------------------------------------------------



function State_Air_Attack_Two(message)
	if message == OnEnter then
	
		state_start_time = GetCurrentTime()

		-- Have jets attack a walker, non blocking
		-- Formation_Move for jets is bugged.
		Remove_Invalid_Objects(novus_jets)
		Remove_Invalid_Objects(alien_walkers)
		if alien_walkers[1] ~= nil then
			for i, unit in pairs(novus_jets) do
				unit.Attack_Target(alien_walkers[1])
			end
		end
		
		-- Attack everything the alien player has, sequentially.
		Attack_All(military_uav, alien_units)
		Attack_Move_All(military_uav, alien_walkers)

	elseif message == OnUpdate then
	
		-- Move to the next state if enough anti-vehicle hardpoints are configured or if enough time has elapsed.
		local av_count = Get_Hardpoint_Count(alien_walkers, Find_Object_Type("Alien_Walker_Habitat_Back_Plasma_Turret"))
		if (av_count >= 1) then
			Set_Next_State("State_Mixed_Ground_Attack")
			return
		end

		allow_reset_to_first_state = true
	end
end


---------------------------------------------------------------------------------------------------



function State_Mixed_Ground_Attack(message)
	if message == OnEnter then
	
		state_start_time = GetCurrentTime()
		
		-- Attack the player with mixed novus units.  Each attack blocks, so run in separate threads for staggered attack control.
		Create_Thread("Gound_Attack_One")
		Sleep(10)
		Create_Thread("Ground_Attack_Two")
		Sleep(15)
		Create_Thread("Ground_Attack_Three")
		
		-- Indefinately search for new walkers.
		Create_Thread("Hunt_Walkers")
	end
end

function Gound_Attack_One()
	local recruit_radius = 300
	-- TODO: attack with vehicles, have infantry guard the vehicles.
	novus_mixed_ground_one = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus, mixed_ground_units_marker_one, recruit_radius)
	Attack_Move_All(novus_mixed_ground_one, alien_walkers)
end

function Ground_Attack_Two()
	local recruit_radius = 300
	novus_mixed_ground_two = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus, mixed_ground_units_marker_two, recruit_radius)
	Attack_Move_All(novus_mixed_ground_two, alien_walkers)
end

function Ground_Attack_Three()
	local recruit_radius = 300
	novus_mixed_ground_three = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus, mixed_ground_units_marker_three, recruit_radius)
	Attack_Move_All(novus_mixed_ground_three, alien_walkers)
	
	-- Just put all of the units on guard again.
	Remove_Invalid_Objects(novus_units)
	for i, unit in pairs(novus_units) do
		unit.Guard_Target(unit.Get_Position())
	end	
end

function Hunt_Walkers()
	while true do
		Attack_Move_All(novus_units, alien_walkers)
		Sleep(1)
	end
end


---------------------------------------------------------------------------------------------------
------ UTILITIES -------------------------------------------------------------------------------


-- Move to library?
function Remove_Type_From_List(unit_list, type)
	for i, unit in pairs(unit_list) do
		if unit.Get_Type() == type then
			table.remove(unit_list, i)
			
			-- Can't continue to iterate a mutated list, so recurse.
			Remove_Type_From_List(unit_list, type)
			return
		end
	end
end


-- BLOCKING Attack move to all victims, one at a time, in an arbitrary order.
function Attack_Move_All(attacker_list, victim_list)

	if victim_list then
		for i=1, table.getn(victim_list) do
			Remove_Invalid_Objects(attacker_list)
			if TestValid(victim_list[i]) then
				Formation_Attack_Move(attacker_list, victim_list[i])
			end
		end
	
		Remove_Invalid_Objects(victim_list)
	end
end


-- BLOCKING Attack all victims, one at a time, in an arbitrary order.
function Attack_All(attacker_list, victim_list)

	if victim_list then
		for i=1, table.getn(victim_list) do
			Remove_Invalid_Objects(attacker_list)
			if TestValid(victim_list[i]) then
				Formation_Attack(attacker_list, victim_list[i])
			end
		end
	
		Remove_Invalid_Objects(victim_list)
	end
end

-- Move to library?
function Remove_Hardpoints_From_List(obj_list)
	for i, obj in pairs(obj_list) do
		if obj.Has_Behavior(68) then
			table.remove(obj_list, i)
			
			-- Can't continue to iterate a mutated list, so recurse.
			Remove_Type_From_List(obj_list)
			return
		end
	end
end

-- Insert table 2 elements to the end of table 1 (table.concat returns a string and isn't useful).
function Concat_Indexed_Tables(table1, table2)
	for i, entry in pairs(table2) do
		table.insert(table1, entry)
	end
end



function Get_Hardpoint_Count(unit_list, hp_type)

	Remove_Invalid_Objects(unit_list)
	
	local count = 0
	for i, unit in pairs(unit_list) do
		if unit.Has_Behavior(69) then
			hp_list = unit.Find_All_Hard_Points_Of_Type(hp_type)
			if hp_list ~= nil then
				count = count + table.getn(hp_list)
			end
		else
			ScriptError("Count_Hardpoints received a non-walker")
		end
	end
	
	return count
end

-- Each member of an attacker list will find the nearest enemy and attack it.
-- Non blocking script.  Issue repeatedly to clear a map of enemies.
function Attack_Nearest_Enemy_All(attacker_list)

	Remove_Invalid_Objects(attacker_list)
	
	if attacker_list then
		local owner_player = attacker_list[1].Get_Owner()
		for i, attacker in pairs(attacker_list) do

			if TestValid(attacker) and not attacker.Has_Active_Orders() then
				nearest_enemy = Find_Nearest(attacker, "Infantry | Vehicle | Walker", owner_player, false)
				if TestValid(nearest_enemy) then
					attacker.Attack_Target(nearest_enemy)
				end
			end
		end
	end
end



---------------------------------------------------------------------------------------------------
------ GLOBAL EVENTS -------------------------------------------------------------------------------

function On_Construction_Complete(obj)

	-- Add constructed units to the running lists
	if obj.Get_Owner() == player_alien then

		local obj_type =  obj.Get_Type()  
		if obj_type == Find_Object_Type("Alien_Walker_Habitat") then
			table.insert(alien_walkers, obj)
		else
			table.insert(alien_units, obj)
			if obj_type == Find_Object_Type("Alien_Grunt") then
				table.insert(alien_grunts, obj)
				
				-- During Air_Attack_Two's update, the player can reset to state one by building a grunt.
				if allow_reset_to_first_state then
					local aa_count = Get_Hardpoint_Count(alien_walkers, Find_Object_Type("Alien_Walker_Habitat_Lightning_Turret"))
					if aa_count == 0 then
						allow_reset_to_first_state = false
						Set_Next_State("State_Air_Attack_One")
					end
				end
			end
		end
	end
end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Advance_State = nil
	Attack_Nearest_Enemy_All = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	Close_All_Huds = nil
	Commit_Profile_Values = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Drop_In_Spawn_Unit = nil
	Enable_UI_Element_Event = nil
	Formation_Guard = nil
	Full_Speed_Move = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Current_State = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Next_State = nil
	Hunt = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGHintSystem_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_From_Table = nil
	Remove_Hardpoints_From_List = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Objective_Text = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	Strategic_SpawnList = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Loading_Screen_Background = nil
	UI_Set_Loading_Screen_Faction_ID = nil
	UI_Set_Loading_Screen_Mission_Text = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
