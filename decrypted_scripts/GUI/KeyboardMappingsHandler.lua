if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[178] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/KeyboardMappingsHandler.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/02/21
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("PGCommands")
require("KeyboardGameCommands")

function Init_Keyboard_Mappings_Handler()
	
	this.Register_Event_Handler("Process_Keyboard_Command", nil, On_Process_Keyboard_Command)	
	this.Register_Event_Handler("Process_Hotkey_Ability_Activation", nil, On_Process_Hot_Key_Ability_Activation)
	
	-- When opening a queue via hotkey, we want the player to be able to cycle through all the buildings in the queue
	-- by pressing the key repeatedly
	QueueTypeToLastQueueIndex = {}
	
	Register_Game_Commands_Enum()
end



-- -----------------------------------------------------------------------------------------------------------------
-- On_Process_Keyboard_Command
-- -----------------------------------------------------------------------------------------------------------------
function On_Process_Keyboard_Command(event, source, game_command, is_double_key_press)
	
	if not game_command then 
		return 
	end

	local success = true
	if game_command ==COMMAND_ACTIVATE_SPECIAL_ABILITY_BUTTON_1 then 
		Selected_Subgroup_Activate_Ability_By_Index(1)
		
	elseif game_command == COMMAND_ACTIVATE_SPECIAL_ABILITY_BUTTON_2 then 
		Selected_Subgroup_Activate_Ability_By_Index(2)
		
	elseif game_command == COMMAND_ACTIVATE_SPECIAL_ABILITY_BUTTON_3 then 
		Selected_Subgroup_Activate_Ability_By_Index(3)	
		
	elseif game_command == COMMAND_ACTIVATE_SPECIAL_ABILITY_BUTTON_4 then 
		Selected_Subgroup_Activate_Ability_By_Index(4)	
		
	elseif game_command == COMMAND_ACTIVATE_SUPERWEAPON_1 then 
		Activate_Superweapon(1)
		
	elseif game_command == COMMAND_ACTIVATE_SUPERWEAPON_2 then 
		Activate_Superweapon(2)
		
	elseif game_command == COMMAND_ACTIVATE_SUPERWEAPON_3 then 
		Activate_Superweapon(3)
		
	elseif game_command == COMMAND_ACTIVATE_COMMAND_BUILD_QUEUE then 
		success = Activate_Build_Queue_By_Type('Command', is_double_key_press)
		
	elseif game_command == COMMAND_ACTIVATE_INFANTRY_BUILD_QUEUE then 
		success = Activate_Build_Queue_By_Type('Infantry', is_double_key_press)
		
	elseif game_command == COMMAND_ACTIVATE_VEHICLE_BUILD_QUEUE then 
		success = Activate_Build_Queue_By_Type('Vehicle', is_double_key_press)
		
	elseif game_command == COMMAND_ACTIVATE_AIR_BUILD_QUEUE then 
		success = Activate_Build_Queue_By_Type('Air', is_double_key_press)
		
	elseif game_command == COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE then 
		Toggle_Faction_Specific_Menu()
	
	elseif game_command == COMMAND_TOGGLE_RESEARCH_TREE_DISPLAY then 
		if Toggle_Research_Tree_Display then
			Toggle_Research_Tree_Display()
		end
		
	elseif game_command == COMMAND_HERO_1 then
		-- single press selects hero, double press selects hero and points camera at selected hero.
		Hotkey_Pressed_Hero(1, is_double_key_press)	
		
	elseif game_command == COMMAND_HERO_2 then
		-- single press selects hero, double press selects hero and points camera at selected hero.
		Hotkey_Pressed_Hero(2, is_double_key_press)
		
	elseif game_command == COMMAND_HERO_3 then	
		-- single press selects hero, double press selects hero and points camera at selected hero.
		Hotkey_Pressed_Hero(3, is_double_key_press)
		
	elseif game_command == COMMAND_FIND_BUILDER then 
		-- single press selects builder, double press selects builder and points camera at selected builder.
		Find_Builder(is_double_key_press)
		
	elseif game_command == COMMAND_TOGGLE_SELL_MODE then 
		-- Raise the Event of the sell mode button being clicked!
		if TestValid(SellButton) and not SellButton.Get_Hidden() then
			this.Raise_Event_Immediate("Selectable_Icon_Clicked", SellButton, {})
		end	
	end
end

-- -----------------------------------------------------------------------------------------------------------------
-- Activate_Build_Queue_By_Type
-- -----------------------------------------------------------------------------------------------------------------
function Activate_Build_Queue_By_Type(queue_type, is_double_key_press)
	
	if not QueueButtonsByType or not TestValid(QueueManager) then return end
	
	if LastVisitedQueue ~= queue_type then
		-- reset all memories of previous queues.
		QueueTypeToLastQueueIndex = {}
		QueueTypeToLastQueueIndex[queue_type] = 0
		LastVisitedQueue = queue_type
		is_double_key_press = false
	end
	
	if not is_double_key_press then -- advance the index
		QueueTypeToLastQueueIndex[queue_type] = QueueTypeToLastQueueIndex[queue_type] + 1
	end
	
	if QueueTypeToLastQueueIndex[queue_type] == 0 then
		-- if by any chance the index is zero, set it back to one!.
		QueueTypeToLastQueueIndex[queue_type] = 1
	end
	
	-- do we need to open the queue?
	local current_queue_type = QueueManager.Get_Type()
	if queue_type ~= QueueManager.Get_Type() then
		-- open the queue if it is not open
		local queue_button = QueueButtonsByType[queue_type]
		if TestValid(queue_button) then
			this.Raise_Event_Immediate("Selectable_Icon_Clicked", queue_button, {})
		end
	end
	
	-- Now that we know the build menu is open for this queue, we want to mimic the effect of single/double click on a specific building button.
	-- Note, the returned value is a valid value for the bldg index (which is computed based on the number of bldgs in the queue)
	QueueTypeToLastQueueIndex[queue_type] = QueueManager.Open_Queue_At_Index(queue_type, QueueTypeToLastQueueIndex[queue_type], is_double_key_press)
end


-- -----------------------------------------------------------------------------------------------------------------
-- Toggle_Faction_Specific_Menu
-- -----------------------------------------------------------------------------------------------------------------
function Toggle_Faction_Specific_Menu()
	if TestValid(FactionSpecificMenuButton) then 
		-- make sure the button is in a valid state.
		if not FactionSpecificMenuButton.Get_Hidden() and FactionSpecificMenuButton.Is_Button_Enabled() then 
			this.Raise_Event_Immediate("Selectable_Icon_Clicked", FactionSpecificMenuButton, {})
		end	
	elseif Toggle_Faction_Specific_Menu then 
		Toggle_Faction_Specific_Menu()
	end
end

-- -----------------------------------------------------------------------------------------------------------------
-- On_Process_Hot_Key_Ability_Activation
-- -----------------------------------------------------------------------------------------------------------------
function On_Process_Hot_Key_Ability_Activation(event, source, ab_index, is_generic_ability)
	if not ab_index then return end
	if ab_index < 1 and ab_index > 40 then return end
	Hot_Key_Activate_Land_Ability(ab_index, is_generic_ability)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hotkey_Pressed_Hero
-- ------------------------------------------------------------------------------------------------------------------
function Hotkey_Pressed_Hero(index, is_double_key_press)
	-- index can be 1, 2 or 3.  However, since we have the science guy occupying the first button, we must
	-- always add 1 to get a valid hero index value!.
	if not index then return end
	
	index = index + 1
	if index < 2 or index > #HeroIconTable then 
		return 
	end
	
	local hero_button = HeroIconTable[index]
	if not TestValid(hero_button) or hero_button.Get_Hidden() then
		return 
	end
	
	local hero = hero_button.Get_Hero()
	if not TestValid(hero) or not hero.Is_In_Active_Context() then
		return
	end
	
	if is_double_key_press then
		-- this is equivalent to a double click of the hero button!.
		this.Raise_Event_Immediate("Selectable_Icon_Double_Clicked", hero_button, {})		
	else
		-- counts as a single click on the hero button.
		this.Raise_Event_Immediate("Selectable_Icon_Clicked", hero_button, {})
	end	
end

-- -----------------------------------------------------------------------------------------------------------------
-- Activate_Superweapon
-- -----------------------------------------------------------------------------------------------------------------
function Activate_Superweapon(index)
	-- This is a faction-specific command so we must get the local player's faction name to 
	-- retrieve the command's data.
	
	local player = Find_Player("local")
	if player then 
		local faction_commands = KeyboardGameCommands[player.Get_Faction_Name()]
		if faction_commands then
			local sw_data = faction_commands["COMMAND_ACTIVATE_SUPERWEAPON_"..index]
			if sw_data then
				Activate_Superweapon_By_Name(sw_data.sw_type_name)
			end
		end
	end
end

-- -----------------------------------------------------------------------------------------------------------------
-- Hot_Key_Activate_Land_Ability
-- -----------------------------------------------------------------------------------------------------------------
function Hot_Key_Activate_Land_Ability(ab_command_idx, is_generic_ability)
	-- Since abilities are hooked up by faction, let's get the local player first.
	
	if not KeyboardGameCommands then return end
	
	local player = Find_Player("local")
	if not player then return end
	
	-- Now let us retrieve the ability data associated to this command from the table: KeyboardGameCommands
	-- The faction name will take us to the right sub-table and from there, we use the key "COMMAND_LAND_ABILITY_#ab_command_idx"
	-- to access the commad's data.
	local lookup_table = nil
	local lookup_key = nil
	local faction_name  = player.Get_Faction_Name()
	if is_generic_ability then
		lookup_table = KeyboardGameCommands["Unit_Control"]
		lookup_key = "COMMAND_GENERIC_LAND_ABILITY_"..ab_command_idx
		
		local this_command_data = lookup_table[lookup_key]
		if this_command_data and this_command_data.faction_to_unit_ability_name then
			lookup_key = faction_name
			lookup_table = this_command_data.faction_to_unit_ability_name
		end
	else
		lookup_table = KeyboardGameCommands[faction_name]
		lookup_key = "COMMAND_LAND_ABILITY_"..ab_command_idx
	end
	
	
	if lookup_table and lookup_key then 
		local command_data = lookup_table[lookup_key]
		if not command_data then return end
		
		-- we have the table, we can get the ability name associated to this command!.
		local unit_ability_name = command_data.unit_ability_name
		
		-- Now issue the order to activate (if possible) this ability!.
		Hot_Key_Activate_Unit_Ability(unit_ability_name)
	end
end

-- -----------------------------------------------------------------------------------------------------------------
-- Activate_Superweapon_By_Index
-- -----------------------------------------------------------------------------------------------------------------
function Activate_Superweapon_By_Index(index)
	if #SuperweaponButtons <= 0 then 
		return
	end
	
	if index < 1 or index > #SuperweaponButtons then 
		return
	end
	
	-- Issue the order to activate the specified superweapon.
	-- NOTE: that this command may fail if the SW is not ready nor available for launching (all that is handled in SuperweaponsControl.lua)
	this.Raise_Event_Immediate("Selectable_Icon_Clicked", SuperweaponButtons[index], {})
end


-- -----------------------------------------------------------------------------------------------------------------
-- Activate_Superweapon_By_Name
-- -----------------------------------------------------------------------------------------------------------------
function Activate_Superweapon_By_Name(sw_type_name)
	if #SuperweaponButtons <= 0 then 
		return
	end
	
	-- Do we have the current superweapon?
	-- the buttons contain the info so let's check.
	local valid_index = -1
	for idx = 1, #SuperweaponButtons do
		local button = SuperweaponButtons[idx]
		if TestValid(button) and not button.Get_Hidden() then 
			local weapon_type_name = button.Get_User_Data()
			if weapon_type_name == sw_type_name then
				valid_index = idx
				break
			end			
		end	
	end
	
	if valid_index > 0 then
		-- Issue the order to activate the specified superweapon.
		-- NOTE: that this command may fail if the SW is not ready nor available for launching (all that is handled in SuperweaponsControl.lua)
		this.Raise_Event_Immediate("Selectable_Icon_Clicked", SuperweaponButtons[valid_index], {})
	end
end



-- -----------------------------------------------------------------------------------------------------------------
-- Find_Builder
-- -----------------------------------------------------------------------------------------------------------------
function Find_Builder(is_double_key_press)
	if not is_double_key_press then
		Select_Next_Builder()
	else
		Point_Camera_At_Next_Builder()
	end
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Superweapon_By_Index = nil
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
	Init_Keyboard_Mappings_Handler = nil
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
