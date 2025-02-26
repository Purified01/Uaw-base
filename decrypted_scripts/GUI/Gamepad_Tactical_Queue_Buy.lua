if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Queue_Buy.lua#23 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Queue_Buy.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 95142 $
--
--          $DateTime: 2008/03/12 18:09:00 $
--
--          $Revision: #23 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGColors")
require("SpecialAbilities")

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	BuyButtons = {}
	FlashUnitType = {}
	Enabler = nil
	LastButtonIndex = -1
	Building = nil
	SpecialAbilityButtons = {}
	
	BUY_BUTTON_BUY = 1
	BUY_BUTTON_UPGRADE = 2

	PGColors_Init_Constants()
	Initialize_Special_Abilities(true)
	
	Set_GUI_Variable("NextUpdateUpgradeButtonTime", 0.0)
	Set_GUI_Variable("IsUpgrading", false)

	BuyButtons = Find_GUI_Components(Scene.Carousel_buy, "Unit")
	for i, button in pairs(BuyButtons) do
		-- RECALL: with the controller, Selectable_Icon_Clicked is equivlent to Controller_A_Button_Up
		-- Selectable_Icon_Right_Clicked is equivlent to Controller_X_Button_Up
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Buy_Button_Click)
		Scene.Register_Event_Handler("Selectable_Icon_Double_Clicked", button, On_Buy_Button_Click)
		Scene.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Controller_X_Button_Up)
		Scene.Register_Event_Handler("Selectable_Icon_Right_Double_Clicked", button, On_Controller_X_Button_Up)
		Scene.Register_Event_Handler("Selectable_Icon_Left_Stick_Clicked", button, On_Controller_Left_Stick_Click)
		button.Set_Hidden(true)
		
		-- we need this button to have a non-negative tab order so that we can navigate the buy menu with the game controller and/or
		-- the keyboard!.
		-- No tab order for carousels - EMP
		-- button.Set_Tab_Order(i)
		-- the timers for these buttons are cooldown timers, hence, the clock is red!
		button.Set_Clock_Tint({1.0, 0.0, 0.0, 140.0/255.0})
	end
	
	SpecialAbilityButtons = Find_GUI_Components(Scene.Carousel_buy, "SpecialAbility")
	if SpecialAbilityButtons then
		for _, button in pairs(SpecialAbilityButtons) do
			Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Special_Ability_Click)
			button.Set_Hidden(true)
		end
	end 
		
	--Carousels must be focusable, but buttons inside should not be
	Scene.Carousel_buy.Set_Tab_Order(1)
	
	--moving up and down the queue manager
	this.Register_Event_Handler("Controller_Left_Stick_Move", this.Carousel_buy, On_Left_Stick_Move)
	
	Init_Guard_Button_Data()
end

---------------------------------------------------------------------------------------
-- Init_Guard_Button_Data
-- ------------------------------------------------------------------------------------
function Init_Guard_Button_Data()
	
	if TestValid(this.Carousel_buy.GuardButton) then 
		FactionToGuardTexturesMap = {}
		FactionToGuardTexturesMap["ALIEN"] = "i_icon_a_sa_gaurd.tga"
		FactionToGuardTexturesMap["NOVUS"] = "i_icon_n_sa_gaurd.tga"
		FactionToGuardTexturesMap["MASARI"] = "i_icon_m_sa_gaurd.tga"
		-- There's no specific texture for the military for now so I'm using the one for the masari.
		FactionToGuardTexturesMap["MILITARY"] = "i_icon_m_sa_gaurd.tga"
		
		this.Carousel_buy.GuardButton.Set_Hidden(true)
		this.Carousel_buy.GuardButton.Set_Tooltip_Data({'ui', {"TEXT_GAMEPAD_ABILITY_GUARD", false, "TEXT_GAMEPAD_TOOLTIP_DESCRIPTION_ABILITY_GUARD"}})
		this.Register_Event_Handler("Selectable_Icon_Clicked", this.Carousel_buy.GuardButton, On_Guard_Button_Clicked)
	end
end

---------------------------------------------------------------------------------------
-- On_Guard_Button_Clicked
-- ------------------------------------------------------------------------------------
function On_Guard_Button_Clicked()
	-- Tell code that we are targeting while in guard mode.
	Activate_Guard_Mode()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Guard_Button
-- ------------------------------------------------------------------------------------------------------------------
function Update_Guard_Button()
	if not TestValid(this.Carousel_buy.GuardButton) then 
		return
	end
	
	-- Show the guard button only if this object has locomotor.
	if Get_Selection_Allows_Guard(Enabler) then 
		this.Carousel_buy.GuardButton.Set_Hidden(false)
		-- Set the texture.
		local player = Enabler.Get_Owner()
		if player then
			this.Carousel_buy.GuardButton.Set_Texture(FactionToGuardTexturesMap[player.Get_Faction_Name()])
		else -- default to the alien texture
			this.Carousel_buy.GuardButton.Set_Texture("i_icon_a_sa_gaurd.tga")
		end		
	else
		this.Carousel_buy.GuardButton.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_X_Button_Up -- If this is an upgrade button, cancel the upgrade, else
-- pass the event up to the Tactical Queue Manager so that it can pass it down to the 
-- Tactical Queue and thus cancel production if applicable.
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_X_Button_Up(event, source)
	if Get_GUI_Variable("IsUpgrading") then
		Cancel_Upgrade()
	else
		Scene.Get_Containing_Scene().Raise_Event_Immediate("Buy_Button_Controller_X_Button_Up", Scene.Get_Containing_Component(), nil)	
	end
end


---------------------------------------------------------------------------------------
-- On_Buy_Button_Click
-- ------------------------------------------------------------------------------------
function On_Buy_Button_Click(event, source)
	local user_data = source.Get_User_Data()
	-- user_data[1] = type
	-- user_data[2] = can_produce
	-- user_data[3] = structure upgrade
	
	-- this button may be 'visually' enabled but not functionally enabled!.
	if user_data[2] == false then 
		return
	end

	if user_data[3] == BUY_BUTTON_UPGRADE	then
		On_Upgrade_Button_Click(event,source)
	else
		Scene.Get_Containing_Scene().Raise_Event_Immediate("Buy_Button_Clicked", Scene.Get_Containing_Component(), { user_data[1] })
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Populate_Buy_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Populate_Buy_Menu(unit_table, structure_powered, enabler, curr_time, special_abilities)
	if not unit_table then
		-- Hide unused buttons
		local temp_button_index = 1
		while temp_button_index <= table.getn(BuyButtons) do
			BuyButtons[temp_button_index].Set_Hidden(true)
			BuyButtons[temp_button_index].Set_Clock_Filled(0.0)
			BuyButtons[temp_button_index].Set_Button_Enabled(true)
			temp_button_index = temp_button_index + 1
		end	

		Enabler = enabler
		LastButtonIndex = 1
	else
		local player = Find_Player("local")
		local player_credits = player.Get_Credits()

		Enabler = enabler
		
		-- we have to sort the table of units by the units' index.
		local index_to_type_info_map = {}
		local indeces = {}
		-- NOTE: unit_table is a table of tables.  Each of the inner tables contains:
		-- inner_table[1] = type
		-- inner_table[2] = assigned queue index (order)
		-- inner_table[3] = bool can produce? (tech and popcap dependencies)
		-- inner_table[4] = bool player has enough credits?
		-- inner_table[5] = build_cost for this type on this enabler
		-- inner_table[6] = build time
		-- inner_table[7] = build rate
		-- inner_table[8] = build_cooldown (eg for hero build in skirmish games)
		
		-- THE FOLLOWING INFO IS NEEDED FOR TOOLTIP UPDATE!!!!
		-- inner_table[9] = lifetime build cap
		-- inner_table[10] = historically built count
		-- inner_table[11] = current build cap
		-- inner_table[12] = current build count

		local object_type
		local can_produce
		local enough_credits
		local build_cost
		local types_count = 0
		local build_time, build_rate, build_cooldown
		local life_build_cap = -1
		local life_build_count = 0
		local curr_build_cap = -1
		local curr_build_count = 0
		
		for _, inner_table in pairs(unit_table) do
			object_type = inner_table[1]
			local queue_index = inner_table[2]
			
			if index_to_type_info_map[queue_index] == nil then 
				index_to_type_info_map[queue_index]  = {}
				table.insert(indeces, queue_index)
			end
			
			can_produce = inner_table[3]
			enough_credits = inner_table[4]
			build_cost = inner_table[5]
			build_time = inner_table[6]
			build_rate = inner_table[7]
			build_cooldown = inner_table[8]
			life_build_cap = inner_table[9]
			life_build_count = inner_table[10]
			curr_build_cap = inner_table[11]
			curr_build_count = inner_table[12]
			
			-- Oksana: display time adjusted for rate
			build_time = build_time / build_rate
			
			table.insert(index_to_type_info_map[queue_index], {object_type, can_produce, enough_credits, build_cost, build_time, build_rate, build_cooldown, life_build_cap, life_build_count, curr_build_cap, curr_build_count})
			types_count = types_count + 1
		end
		
		-- Sort the indeces in increasing order.
		table.sort(indeces)
		
		local button_index = 1
		local max_buttons = #BuyButtons
		for i, q_idx in ipairs(indeces) do
			if button_index > max_buttons then
				break
			end	
			local index_data = index_to_type_info_map[q_idx]
			for list_idx, type_data in pairs(index_data) do
				if button_index >max_buttons then
					break
				end		
			
				object_type = type_data[1]
				can_produce = type_data[2] -- takes precedence over enough_credits
				enough_credits = type_data[3]
				build_cost = type_data[4]
				build_time = type_data[5]
				build_rate = type_data[6]
				build_cooldown = type_data[7]
				life_build_cap = type_data[8]
				life_build_count = type_data[9]
				curr_build_cap = type_data[10]
				curr_build_count = type_data[11]
				
				if object_type then 
					icon_name = object_type.Get_Icon_Name()
					
					if icon_name ~= "" then
						local button = BuyButtons[button_index]
						
						if FlashUnitType[object_type] == true then
							button.Start_Flash()
						else
							button.Stop_Flash()
						end
						
						button.Set_Texture(icon_name)
						button.Set_Hidden(false)
						button.Set_Button_Enabled(true)
						button.Set_Text("")
						button.Clear_Cost()
						
						-- Maria 02.06.2008
						-- If the previous menu shown had only an upgrade that is under construction, the first carousel button will still
						-- have the X overlay exposed!.  So, we should always make sure that the buttons in the unit menu have the 
						-- A button overlay exposed!.
						button.Use_X_Overlay(false)
						
						-- enable the button only if the player has enough credits to purchase this unit and enpugh pop cap
						if can_produce == false then 
							if build_cooldown > 0 then 
								button.Set_Clock_Filled(build_cooldown)							
							else
								button.Set_Clock_Filled(0.0)
								-- disable the button
								button.Set_Button_Enabled(false)
								button.Set_Insufficient_Funds_Display(false)
							end
						elseif not enough_credits then 
							-- the button should display a redish border and the cost should be displayed in red.
							button.Set_Insufficient_Funds_Display(true)
						else
							button.Set_Insufficient_Funds_Display(false)
						end	

						if can_produce then 
							-- Maria 02.28.2007
							-- the cost of the unit may depend on the enabler it comes from.  In fact, some hard points may
							-- cause the build costs to go down so we will pass the cost information from code along with the 
							-- rest of the production informartion.
							--button.Set_Cost(object_type.Get_Tactical_Build_Cost())
							button.Set_Cost(build_cost)						
							button.Set_Clock_Filled(0.0)
						end
						
						button.Set_User_Data({object_type, can_produce, BUY_BUTTON_BUY})
						
						-- If the local player is Novus we must also check whether the structure is powered and thus can produce this object
						if Is_Player_Of_Faction(player, "NOVUS") == true then 
							if structure_powered == true then 
								button.Set_Low_Power_Display(false)
							else
								button.Set_Low_Power_Display(true)
							end					
						end
					
						-- Tooltip data: tooltip mode, type, builder, cost, build time, warm up time, cooldown time.
						button.Set_Tooltip_Data({'type', {object_type, build_cost, build_time, build_rate, -1.0, -1.0, life_build_cap, life_build_count, curr_build_cap, curr_build_count}})

						button_index = button_index + 1
					end
				end
			end
		end

		LastButtonIndex = button_index
	end
	
	-- Now update the upgrades menu.
	local upgrading = false
	if TestValid(Enabler) then 
		upgrading = Update_Upgrade_Menu(structure_powered, curr_time)
	end	

	-- Hide unused buttons
	button_index = LastButtonIndex
	while button_index <= table.getn(BuyButtons) do
		BuyButtons[button_index].Set_Hidden(true)
		button_index = button_index + 1
	end	
	
	Update_Special_Ability_Buttons(special_abilities)
	
	Update_Guard_Button()

	Set_GUI_Variable("IsUpgrading", upgrading)
	return upgrading
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Flashing_Unit_Button
-- ------------------------------------------------------------------------------------------------------------------
function Set_Flashing_Unit_Button(unit_type)
	FlashUnitType[unit_type] = true
end

-- ------------------------------------------------------------------------------------------------------------------
-- Stop_Flashing_Unit_Button
-- ------------------------------------------------------------------------------------------------------------------
function Stop_Flashing_Unit_Button(unit_type)
	FlashUnitType[unit_type] = nil	
end


-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------


-- JAC - 07/10/07 - Copied from Tactical_Upgrades_Menu.lua so that structure upgrades can use the build buttons in
-- controller based GUIs
 
-- ------------------------------------------------------------------------------------------------------------------
-- KDB Show upgrade options for buildings
-- ------------------------------------------------------------------------------------------------------------------
function Update_Upgrade_Menu( is_powered, cur_time )

	if not TestValid(Enabler) then
		-- reset the menu
		return
	end

	local buttons_list = BuyButtons
	
	local upgrading = false
	upgradable_buildings = {}

	-- show autobuild items (1st parameter false)
	upgradable_buildings = Enabler.Get_Updated_Buildable_Hardpoints_List()
	
	if upgradable_buildings == nil then 
		return
	end
	
	-- are we building any of these objects?
	local button_index = 1
	local build_index = 0
	local build_time = 0

	build_time = Enabler.Get_Tactical_Build_Time_Left_Seconds( true )
	construction_type = Enabler.Get_Building_Object_Type( true )
	local final_type = nil
	if construction_type ~= nil then
		final_type = construction_type.Get_Tactical_Buildable_Constructed_Type()
	end
	
	if final_type then
		for index, object_type in pairs(upgradable_buildings) do
			icon_name = object_type.Get_Icon_Name()
			if icon_name ~= "" then

				if object_type == final_type then
					build_index = button_index
					break
				end
				
				button_index = button_index + 1
				if button_index > table.getn(buttons_list) then
					break
				end
			end
		end
	end
	
	button_index = LastButtonIndex
	local player = Find_Player("local")		
	if player ~= Enabler.Get_Owner() then
		player = Enabler.Get_Owner()
	end
	
	local num_existing_upgrades = 0
	local player_credits = player.Get_Credits()
	
	for index, object_type in pairs(upgradable_buildings) do
		-- we don't want to display types locked from STORY!
		if player.Is_Object_Type_Locked(object_type, STORY) == false then
	
			icon_name = object_type.Get_Icon_Name()
			if icon_name ~= "" then
				local button = buttons_list[button_index]
				button.Set_Texture(icon_name)
				button.Set_Hidden(false)
				button.Set_User_Data({object_type, true, BUY_BUTTON_UPGRADE})
				button.Clear_Cost()
				
				local cost = -1.0
				
				if player.Is_Object_Type_Locked(object_type) == false then 
					
					-- if the player doesn't have enough money, the cost should be displayed in red.
					cost = object_type.Get_Tactical_Build_Cost()
					if player_credits < cost then 
						button.Set_Insufficient_Funds_Display(true)
					else
						button.Set_Insufficient_Funds_Display(false)
					end
					
					button.Set_Cost(cost)
					
					if construction_type and construction_type.Has_Behavior(39)  then
						if index == build_index then
							-- show timer
							local percent_done = Enabler.Get_Tactical_Build_Percent_Done( true )
							button.Set_Clock_Tint({0.0, 1.0, 0.0, 140.0/255.0})
							button.Set_Clock_Filled(percent_done)
							button.Set_Button_Enabled(true)
							upgrading = true
							button.Use_X_Overlay(true)
						else
							-- disable this button
							button.Set_Button_Enabled(false)
							button.Set_Clock_Filled(0)
						end
					else
						if not Ok_To_Upgrade(  Enabler, object_type ) then
							button.Set_Button_Enabled(false)
						else			
							button.Use_X_Overlay(false)
							button.Set_Button_Enabled(true)
							button.Set_Clock_Filled(0)
						end
					end
					
					if not is_powered then
						button.Set_Low_Power_Display(true)
						if upgrading then
							upgrading = false
						end
					else
						button.Set_Low_Power_Display(false)
					end
				else 
					-- just disable this button!
					button.Set_Button_Enabled(false)
				end
				
				if FlashUnitType[object_type] == true then
					button.Start_Flash()
				else
					button.Stop_Flash()
				end
				
				button.Set_Tooltip_Data({'type', {object_type, cost, object_type.Get_Tactical_Build_Time()}})

				button_index = button_index + 1
				if button_index > table.getn(buttons_list) then
					break
				end
			end				
		end					
	end

	LastButtonIndex = button_index		
	return upgrading
end

-- ------------------------------------------------------------------------------------------------------------------
-- Ok_To_Upgrade check to see if this hard point would be the next autobuild or it's not an autobuild at all
-- ------------------------------------------------------------------------------------------------------------------
function Ok_To_Upgrade( building, build_type)
	local ok = false
	if building ~= nil and build_type ~= nil then
		builing_list = building.Get_Tactical_Hardpoint_Upgrades( false, false, false, nil, true )
		if builing_list ~= nil then
			for index, object_type in pairs(builing_list) do
				if build_type == object_type then
					ok = true
					break
				end
			end
		end
	end
	return ok
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Upgrade_Button_Click KDB
-- ------------------------------------------------------------------------------------------------------------------
function On_Upgrade_Button_Click(event, source)
	
	if TestValid(Enabler) then
		-- Process the click as if the corresponding button had been clicked!
		local user_data = source.Get_User_Data()
		local type_to_build = user_data[1]
		
		-- If we click on a type that is already under construction do nothing.
		local actual_builder = Enabler.Get_Hardpoint_Builder(true)
		
		if actual_builder ~= nil then
			local construction_type = actual_builder.Get_Building_Object_Type()
			if construction_type ~= nil then
				return	-- building already in progress
			end
		end

		-- check for auto build		
		local builder = Enabler
		local hp_info = Enabler.Get_Next_Hard_Point_Tier_Upgrade( type_to_build )
		
		if hp_info ~= nil and hp_info[1] ~= nil and hp_info[2] ~= nil then
			-- there is both a socket available and a tier hard point left
			type_to_build = hp_info[1]
			builder = hp_info[2]
		end
	
		local success = Structure_Build_Hard_Point(builder, type_to_build)
		
		if success == true then 
			Play_SFX_Event("GUI_Generic_Button_Select")
			Raise_Event_Immediate_All_Scenes("Tactical_Enabler_Production_Started", {Enabler})
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Cancel_Upgrade 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Cancel_Upgrade()

	if TestValid(Enabler) then
		local actual_builder = Enabler.Get_Hardpoint_Builder(true)
		
		local success = false
		if actual_builder ~= nil then
			return Structure_Cancel_Build_Hard_Point(actual_builder)
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Structure_Build_Hard_Point 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Structure_Build_Hard_Point(socket_object, type_to_build)
	if socket_object == nil then
		MessageBox("Build_Hard_Point: The socket object is nil.")
		return false
	end
	
	if type_to_build ~= nil then
		if socket_object.Can_Build( type_to_build, true, true ) then
			Send_GUI_Network_Event("Network_Build_Hard_Point", { socket_object, type_to_build, Find_Player("local") })
			return true
		else
			return false
		end
	else
		MessageBox("Build_Hard_Point: The type to build is nil.")
		return false
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Structure_Cancel_Build_Hard_Point 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Structure_Cancel_Build_Hard_Point(socket_object)

	if socket_object == nil then
		MessageBox("Cancel_Build_Hard_Point: The socket object is nil.")
		return false
	end
	
	if socket_object.Can_Cancel_Build() then 
		Send_GUI_Network_Event("Network_Cancel_Build_Hard_Point", { socket_object, Find_Player("local") })
		return true
	else 
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end

	return false
end


function On_Left_Stick_Move(_, source, pos_x, pos_y, degrees)
	this.Get_Containing_Scene().Raise_Event_Immediate("Queue_Buy_Controller_Left_Stick_Move", this.Get_Containing_Component(), {pos_x, pos_y, degrees})
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Focus 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Focus()
	Scene.Carousel_buy.Set_Key_Focus()
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Controller_Left_Stick_Click 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Controller_Left_Stick_Click()
	if TestValid(Enabler) then
		Point_Camera_At(Enabler)
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Special_Ability_Click 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Special_Ability_Click(event, source)
	Get_Game_Mode_GUI_Scene().Raise_Event("Activate_Special_Ability", source, nil)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Special_Ability_Buttons 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Update_Special_Ability_Buttons(special_abilities)
	if special_abilities then
		local num_special_ability_buttons = #SpecialAbilityButtons
		for idx, ability in pairs(special_abilities) do
			if idx <= num_special_ability_buttons then
				local button = SpecialAbilityButtons[idx]
				local user_data = {}
				user_data.type_name = Enabler.Get_Type().Get_Name()
				user_data.ability = ability[1]
				user_data.active = ability[2]
				
				button.Set_User_Data(user_data)
				
				button.Set_Texture(ability[1].icon)
				button.Set_Hidden(false)
				button.Set_Clock_Tint({1.0, 0.0, 0.0, 0.43137254})
				
				if user_data.active then 
					button.Enable(true)
					button.Set_Grayscale(false)
					button.Hide_A_Button_Overlay(false)
				else
					button.Enable(false)
					button.Set_Grayscale(true)
					button.Hide_A_Button_Overlay(true)
				end				
				
				Update_SA_Button_Text_Button(button, {Enabler})
				
			end
		end
	else
		for _, button in pairs(SpecialAbilityButtons) do
			button.Set_Hidden(true)
		end
	end
end

function Focus_On_First_Active()
	-- Focus Order:
	-- 1) Active buy buttons
	-- 2) Active special ability buttons
	-- 3) Inactive buy buttons that still have their overlay unhidden (not enough money)
	-- 4) Inactive special abilities (cooling down)
	-- 5) No change

	-- Buy buttons first
	for _, button in pairs(BuyButtons) do
		if button.Is_Enabled() and not button.Get_Hidden() then
			Scene.Carousel_buy.Set_Active_Component(button)
			return
		end
	end
	
	-- Special abilities next
	for _, button in pairs(SpecialAbilityButtons) do
		if button.Is_Enabled() and not button.Get_Hidden() then
			Scene.Carousel_buy.Set_Active_Component(button)
			return
		end
	end
	
	for _, button in pairs(BuyButtons) do
		if not button.Is_Enabled() and not button.Get_Hidden() and not button.Is_Overlay_Hidden() then
			Scene.Carousel_buy.Set_Active_Component(button)
			return
		end
	end

	for _, button in pairs(SpecialAbilityButtons) do
		if not button.Is_Enabled() and not button.Get_Hidden() and not button.Is_Overlay_Hidden() then
			Scene.Carousel_buy.Set_Active_Component(button)
			return
		end
	end
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------




-- ------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Populate_Buy_Menu = Populate_Buy_Menu
Interface.Set_Flashing_Unit_Button = Set_Flashing_Unit_Button
Interface.Stop_Flashing_Unit_Button = Stop_Flashing_Unit_Button
Interface.Focus = Focus
Interface.Cancel_Upgrade = Cancel_Upgrade
Interface.Focus_On_First_Active = Focus_On_First_Active
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGColors_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

