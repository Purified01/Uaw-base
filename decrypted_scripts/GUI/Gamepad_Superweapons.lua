if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[14] = true
LuaGlobalCommandLinks[194] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[160] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Superweapons.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Superweapons.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("KeyboardGameCommands")
SuperweaponButtons = nil


-- ------------------------------------------------------------------------------------------------------------------
-- Superweapons_Init
-- ------------------------------------------------------------------------------------------------------------------
function Superweapons_Init()
	
	MAX_NUM_PLAYERS = 7
	MAX_NUM_SW_PER_PLAYER = 2
	WeaponTypeNameToButton = {}
	
	if TestValid(this.CommandBar.SWButtons) then 
		SuperweaponButtons = Find_GUI_Components(this.CommandBar.SWButtons, "SuperweaponButton")
	elseif TestValid(this.FactionButtons) then 
		if TestValid(this.FactionButtons.Carousel) then 
			SuperweaponButtons = Find_GUI_Components(this.FactionButtons.Carousel, "SuperweaponButton")
		end
	else
		SuperweaponButtons = Find_GUI_Components(this.CommandBar, "SuperweaponButton")
	end
	
	Register_Game_Scoring_Commands()

	RedTint = {1.0, 0.0, 0.0, 120.0/255.0}
	
	for index, button in pairs(SuperweaponButtons) do
		button.Set_Hidden(true)
		button.Set_Clock_Tint(RedTint)
		-- Event handling
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Superweapon_Button_Clicked)
	end
	
	if TestValid(this.EnemySWTimers) then 
		Timers = {}
		Timers = Find_GUI_Components(this.EnemySWTimers, "Timer")
		for _, timer in pairs(Timers) do
			timer.Set_Hidden(true)
		end
		TimersCount = 0
	end
	

	
	-- Register to hear when superweapon is launched.
	this.Register_Event_Handler("Superweapon_Launched", nil, On_Superweapon_Launched)

	-- Called when the user selects the position to launch the superweapon.
	this.Register_Event_Handler("Network_Launch_Superweapon", nil, On_Network_Launch_Superweapon)

	Init_Players_List()
	Initialized = true
	
	-- Maria 12.05.2007
	-- Let's keep a table of all the SW enablers present.  This will come in handy when trying to determine whether a selected structure is 
	-- a SW enabler or not (so that we can display an 'ability' button for the SW building)
	SWEnablers = {}
	Superweapon_Update()		
end

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Players_List
-- ------------------------------------------------------------------------------------------------------------------
function Init_Players_List()

	Players = {}
	
	local local_player = Find_Player("local")
	if not local_player then return end
	local local_player_id = local_player.Get_ID()
	
	if Is_Campaign_Game() then 
		
		-- Get the attacker/defender's SW data!.
		local enemy = Get_Current_Conflict_Enemy_Player(local_player)
		if not enemy then return end
		
		table.insert(Players, {enemy, enemy.Get_Use_Colorization()})
		
	elseif Get_Is_Debug_Load_Map() then 
	
		local factions = Find_Player.Get_Playable_Faction_Names()
		for _, faction_name in pairs(factions) do
			local players = Find_Player.All(faction_name)
			if #players > 0 then 
				for _, player in pairs(players) do
					if player ~= local_player then 
						table.insert(Players, {player, player.Get_Use_Colorization()})
					end
				end
			end
		end
	else
		-- Get the table of all valid players for this game!.
		local ctable = GameScoringManager.Get_Player_Info_Table()
		if ctable == nil or ctable.ClientTable == nil then return end

		-- Split the client table into seperate teams.
		for idx, client in pairs(ctable.ClientTable) do
			if local_player_id ~= client.PlayerID then
				local player = Find_Player(client.PlayerID)
				table.insert(Players, {player, true})
			end			
		end	
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_SW_Launch_Ability_Data
-- ------------------------------------------------------------------------------------------------------------------
function Get_SW_Launch_Ability_Data(objects)
	if not objects then 
		return
	end
	
	local player = Find_Player("local")
	local player_script = player.Get_Script()
	
	local sw_enabler_state_data = {}
	if player_script then 
		sw_enabler_state_data = player_script.Get_Async_Data("SWEnablerToSWStateMap")
	end
	
	if sw_enabler_state_data == nil then 
		return
	end
	
	-- NOTE: 	the data in sw_enabler_state_data is as follows
	--		table[1] = weapon type name
	--		table[2] = is weapon enabled
	--		table[3] = num ready to fire
	--		table[4] = progress (to update the cooldown clock)
	
	local enabled = false
	local num_ready = 0
	-- we'll get the smallest progress if all of them are disabled for that is the next one to be 
	-- available,
	local progress = 1e+018
	for _, enabler in pairs(objects) do
		local data = sw_enabler_state_data[enabler]
		if data then 
			
			-- the button is enabled if at least one of the SW is.
			enabled = enabled or data[2] -- is enabled? (this doesn't mean that it can fire if it is enabled)
			num_ready = num_ready + data[3]
			
			-- NOTE: If the SW is disabled just because it is cooling down (and not because of lack of power for example)
			-- the SW button should show enabled but with the cooldown clock on it.  Clicking on the button will have no effect
			-- since the SW is not ready to fire.
			
			-- is coolingdown/recharging
			if data[4] < progress then
				progress = data[4]				
			end
		end	
	end
	
	-- if the progress has not been updated, reset it to 0.
	if progress == 1e+018 then
		progress = 0.0
	end

	return enabled, num_ready, progress
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_SW_Ability_Data
-- ------------------------------------------------------------------------------------------------------------------
function Get_SW_Ability_Data(objects)
	-- For the local player we update the superweapon buttons!.
	local player = Find_Player("local")
	local player_script = player.Get_Script()
	
	local sw_enabler_state_data = {}
	if player_script then 
		sw_enabler_state_data = player_script.Get_Async_Data("SWEnablerToSWStateMap")
	end
	
	if sw_enabler_state_data == nil then 
		return
	end
	
	-- Now set up the ability dta for the specified objects.
	local enabler = objects[1]
	local sw_data = sw_enabler_state_data[enabler]
	if not sw_data then
		return
	end
	-- NOTE: 	the data in sw_enabler_state_data is as follows
	--		table[1] = weapon type name
	--		table[2] = is weapon enabled
	--		table[3] = num ready to fire
	--		table[4] = progress (to update the cooldown clock)
	
	local abilities = {}
	local ability_data = {}
	ability_data.unit_ability_name = "Unit_Ability_Launch_SW"
	CurrentAbilityCount[ability_data.unit_ability_name] = -1
	ability_data.AbilityOwner = enabler
	
	if not ability_data.sw_type_name then
		ability_data.sw_type_name = sw_data[1]
	end
	
	ability_data.icon = Find_Object_Type(ability_data.sw_type_name).Get_Icon_Name()
	
	local enabled = false	
	-- Now we should determine whether this ability is enabled or not 
	for _, sw_state_data in pairs(sw_enabler_state_data) do
		if sw_state_data[2] then
			enabled = true
			break
		end
	end
	
	table.insert(abilities, {ability_data, enabled})
	
	return abilities
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Local_SW_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Local_SW_Data()

	-- For the local player we update the superweapon buttons!.
	local player = Find_Player("local")
	local player_script = player.Get_Script()
	
	local weapons_state_data = {}
	if player_script then 
		weapons_state_data = player_script.Get_Async_Data("WeaponTypeToWeaponStateTable")
	end
	
	if weapons_state_data == nil then 
		Reset_Weapon_Buttons()
		return
	end
	
	SWEnablers = {}
	local button_index = 1
	for weapon_type_name, weapon_state_table in pairs(weapons_state_data) do
		-- NOTE: 	the data in weapon_state_table is as follows
		--		table[1] = is enabler present
		--		table[2] = can fire (ie is weapon enabled)
		--		table[3] = progress data
		-- 		table[4] = count
		--		table[5] = number ready to fire
		--		table[6] = enabler associated to this weapon (we need it for tooltip purposes!)
		
		local is_enabler_present = weapon_state_table[1]
		local is_enabled = weapon_state_table[2]
		local progress = weapon_state_table[3]
		local count = weapon_state_table[4]
		local num_ready = weapon_state_table[5]
		local owning_enabler = weapon_state_table[6]
		local cooldown = weapon_state_table[7]
		
		if is_enabler_present then
			local button = SuperweaponButtons[button_index]
			if TestValid(button) then 
				button.Set_Hidden(false)
			
				-- set the texture assigned to this weapon type
				button.Set_Texture(Find_Object_Type(weapon_type_name).Get_Icon_Name())
				-- Set the count for this weapon type
				if num_ready >= count then
					button.Set_Text(Get_Localized_Formatted_Number(count))
				else
					local wstr_fraction = Get_Game_Text("TEXT_FRACTION")
					Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(num_ready), 0)
					Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(count), 1)
					button.Set_Text(wstr_fraction)
				end
				
				-- Is this weapon enabled?
				button.Set_Button_Enabled(is_enabled)
				
				-- two way referencing for ease of access
				button.Set_User_Data(weapon_type_name)
				if TestValid(owning_enabler) then 
					--[[
					local tooltip_text = Create_Wide_String("")
					if progress > 0.0 then
						tooltip_text.append(Create_Wide_String("\n"))
						local time_string = Get_Localized_Formatted_Number.Get_Time(progress * cooldown)
						tooltip_text.append(Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), time_string, 0))
					end
					]]--
					button.Set_Tooltip_Data({'object', {owning_enabler, false, false}})
					SWEnablers[owning_enabler] = true
				end
				
				WeaponTypeNameToButton[weapon_type_name] = button
				button.Set_Clock_Filled(progress)
				
				button_index = button_index + 1	
			end
		end
	end
	
	for idx = button_index, table.getn(SuperweaponButtons) do
		local button = SuperweaponButtons[idx]
		button.Set_Hidden(true)
		button.Set_Clock_Filled(0.0)
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Superweapon_Updates
-- ------------------------------------------------------------------------------------------------------------------
function Superweapon_Update()

	if not Initialized then return end
	
	-- First update the UI for the local player
	Update_Local_SW_Data()
	
	-- Now update the timers for the other players (if necessary)
	Update_Non_Local_SW_Data()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Timers
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Timers()
	for _, timer in pairs(Timers) do
		timer.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Non_Local_SW_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Non_Local_SW_Data()
	
	if not TestValid(this.EnemySWTimers) then return end
	
	Reset_Timers()
	TimersCount = 0
	
	for _, player_data in pairs(Players) do 
		Update_SW_Timers_For_Player(player_data)
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_SW_Timers_For_Player
-- ------------------------------------------------------------------------------------------------------------------
function Update_SW_Timers_For_Player(player_data)
	
	if not player_data then return end
	
	local player = player_data[1]
	local player_script = player.Get_Script()
	if not player_script then return end
	
	local weapons_state_data = {}
	weapons_state_data = player_script.Get_Async_Data("WeaponTypeToWeaponStateTable")
	if weapons_state_data == nil then 
		return
	end	
	
	-- Maria 07.03.2007
	if not Is_Table_Empty(weapons_state_data) then 
		
		if TimersCount >= MAX_NUM_PLAYERS then
			return
		end
		
		TimersCount = TimersCount + 1
		local timer = Timers[TimersCount]
		timer.Set_Hidden(false)
		timer.Set_SW_Data(player, player_data[2], weapons_state_data)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Table_Empty
-- ------------------------------------------------------------------------------------------------------------------
function Is_Table_Empty(a_table)
	for _, _ in pairs(a_table) do
		return false		
	end
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Weapon_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Weapon_Buttons()
	for _, button in pairs(SuperweaponButtons) do
		button.Set_Hidden(true)
		button.Set_Clock_Filled(0.0)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Network_Launch_Superweapon - Issues the launch in sync across all systems.
-- ------------------------------------------------------------------------------------------------------------------
function On_Network_Launch_Superweapon(event, source, weapon_type, position, player, firing_enabler)

	if weapon_type == nil then return end
	

	-- TODO:  Since network events can be spoofed we should add checks here to make sure
	--        this user is really able to fire this superweapon.  That way if it's a spoofed
	--        packet the other clients will fail to launch the weapon and the game will go OOS.
	--        11/1/2006 10:43:06 AM -- BMH
	local player_script = player.Get_Script()
		
	if player_script then 
		player_script.Call_Function("Launch_Superweapon", weapon_type, position, firing_enabler)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Superweapon_Launched
-- ------------------------------------------------------------------------------------------------------------------
function On_Superweapon_Launched(event, source, weapon_type, position, firing_enabler)
	Send_GUI_Network_Event("Network_Launch_Superweapon", { weapon_type, position, Find_Player("local"), firing_enabler })
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Superweapon_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Superweapon_Button_Clicked(event, button)
	
	if CommandBarEnabled == false then return end

	-- MLL: Clear the flag that the builder ability has been activated.
	BuilderAbilityActivated = false
	local weapon_type_name = button.Get_User_Data()
	
	if weapon_type_name ~= nil then 
		if GUI_Can_Fire_Superweapon(weapon_type_name) then
			local weapon_type = Find_Object_Type(weapon_type_name)
			GUI_Begin_Spawn_Superweapon_Targeting(weapon_type)
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- GUI_Can_Fire_Superweapon -- Multiplayer safe player script query.  5/31/2007 10:23:33 AM -- BMH
-- ------------------------------------------------------------------------------------------------------------------
function GUI_Can_Fire_Superweapon(weapon_type_name, enabler)
	local player = Find_Player("local")
	if player == nil then return false end
	local player_script = player.Get_Script()
	if player_script == nil then return false end

	if not TestValid(enabler) then 
		weapon_state = player_script.Get_Async_Data("WeaponTypeToWeaponStateTable")
		--{present, enabled, progress_data, count, num_can_fire, enabler, cooldown}
		if weapon_state == nil then return false end
		return weapon_state[weapon_type_name] and (weapon_state[weapon_type_name][5] > 0)
	else
		-- We are interested in the specified enabler only!.
		-- For the local player we update the superweapon buttons!.
		sw_enabler_state = player_script.Get_Async_Data("SWEnablerToSWStateMap")
		-- NOTE: 	the data in sw_enabler_state_data is as follows
		--		table[1] = weapon type name
		--		table[2] = is weapon enabled
		--		table[3] = num ready to fire
		--		table[4] = progress (to update the cooldown clock)
		if sw_enabler_state == nil then 
			return false
		end
		
		return (sw_enabler_state[enabler] and sw_enabler_state[enabler][3] > 0)
	end
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Get_SW_Ability_Data = nil
	Get_SW_Launch_Ability_Data = nil
	Superweapons_Init = nil
	Kill_Unused_Global_Functions = nil
end
