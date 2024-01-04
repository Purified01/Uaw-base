-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tactical_Queue_Buy.lua#18 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tactical_Queue_Buy.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 77952 $
--
--          $DateTime: 2007/07/23 11:47:23 $
--
--          $Revision: #18 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

SelectedBuilding = nil
LastButtonIndex = -1

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	IsFlashingBuyButtons = false
	BuyButtons = {}
	TempDisabledList = {}
	FlashUnitType = {}
	SelectedBuilding = nil
	LastButtonIndex = -1

	BUY_BUTTON_BUY = 1
	BUY_BUTTON_UPGRADE = 2
	BUY_BUTTON_SELL = 3

	if Are_Any_Controllers_Connected() then
		Set_GUI_Variable("NextUpdateUpgradeButtonTime", 0.0)
	end

	BuyButtons = Find_GUI_Components(Scene, "Unit")
	for i, button in pairs(BuyButtons) do
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Buy_Button_Click)
		--Register on double click too since these will come through (with no click) when the user clicks fast.
		Scene.Register_Event_Handler("Selectable_Icon_Double_Clicked", button, On_Buy_Button_Click)
		-- JAC - Only used to cancel structure upgrades
		Scene.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Upgrade_Button_Right_Click)
		button.Show_Queue_Line(false)
		button.Show_Queue_Buy_Line(false)
		
		-- we need this button to have a non-negative tab order so that we can navigate the buy menu with the game controller and/or
		-- the keyboard!.
		button.Set_Tab_Order(i)
		-- the timers for these buttons are cooldown timers, hence, the clock is red!
		button.Set_Clock_Tint({1.0, 0.0, 0.0, 140.0/255.0})
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
	elseif user_data[3] == BUY_BUTTON_SELL then
		On_Sell_Button_Click()
	else
		Scene.Get_Containing_Scene().Raise_Event_Immediate("Buy_Button_Clicked", Scene.Get_Containing_Component(), { user_data[1] })
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Populate_Buy_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Populate_Buy_Menu(unit_table, structure_powered, enabler)

	if unit_table == nil then
		-- Hide unused buttons
		local temp_button_index = 1
		while temp_button_index <= table.getn(BuyButtons) do
			BuyButtons[temp_button_index].Set_Hidden(true)
			temp_button_index = temp_button_index + 1
		end	

		LastButtonIndex = 1
		return
	end

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
					
					if IsFlashingBuyButtons or FlashUnitType[object_type] == true then
						button.Start_Flash()
					else
						button.Stop_Flash()
					end
					
					button.Set_Texture(icon_name)
					button.Set_Hidden(false)
					button.Set_Enabled(true)
					button.Set_Text("")
					button.Clear_Cost()
					
					-- enable the button only if the player has enough credits to purchase this unit and enpugh pop cap
					if can_produce == false then 
						if build_cooldown > 0 then 
							button.Set_Clock_Filled(build_cooldown)							
						else
							button.Set_Clock_Filled(0.0)
							-- disable the button
							button.Set_Enabled(false)
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
	
	-- Hide unused buttons
	while button_index <= table.getn(BuyButtons) do
		BuyButtons[button_index].Set_Hidden(true)
		button_index = button_index + 1
	end	
end



-- ------------------------------------------------------------------------------------------------------------------
-- Set_Flashing_Buy_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Set_Flashing_Buy_Buttons(value)
	IsFlashingBuyButtons = value
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
-- Temp_Enable_Build_Item
-- ------------------------------------------------------------------------------------------------------------------
function Temp_Enable_Build_Item(object_type)
	--TempDisabledList[object_type] = nil
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
function Update_Upgrade_Menu( building, cur_time )

	if not TestValid(building) then
		-- reset the menu
		Set_GUI_Variable("NextUpdateUpgradeButtonTime", 0.0)
		SelectedBuilding = nil
		return
	end

	-- we have already added all the possible upgrades for this building so let's not do anything else since the menu is going to be hidden!.
	if Get_GUI_Variable("FullyUpgraded") == true then return end

	SelectedBuilding = building
	
	local buttons_list = BuyButtons
	local next_upgrade_button_time = Get_GUI_Variable("NextUpdateUpgradeButtonTime")

	-- Just in case On_Init was called before the controller was connected.  In that case NextUpdateUpgradeButton will never be initialized
	if next_upgrade_button_time == nil then
		Set_GUI_Variable("NextUpdateUpgradeButtonTime", 0.0)
		next_upgrade_button_time = 0.0
	end

	if cur_time == nil then
		cur_time = next_upgrade_button_time
	end
	
	if cur_time >= next_upgrade_button_time then
		
		local upgrading = false
		upgradable_buildings = {}

		-- show autobuild items (1st parameter false)
		--upgradable_buildings = Object.Get_Tactical_Hardpoint_Upgrades( false, false, true )
		upgradable_buildings = SelectedBuilding.Get_Updated_Buildable_Hardpoints_List()
		
		if upgradable_buildings == nil then 
			-- nothing so 2x time a second
			Set_GUI_Variable("NextUpdateUpgradeButtonTime", cur_time + 0.5)
			return
		end
		
		-- are we building any of these objects?
		local button_index = LastButtonIndex
		local build_index = 0
		local build_time = 0

		build_time = SelectedBuilding.Get_Tactical_Build_Time_Left_Seconds( true )
		construction_type = SelectedBuilding.Get_Building_Object_Type( true )
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
		
		local player = Find_Player("local")
		
		if player ~= SelectedBuilding.Get_Owner() then
			--MessageBox("The owner of the structure is not the local player!!!!!.")
			player = SelectedBuilding.Get_Owner()
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
						
						if construction_type and construction_type.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION)  then
							if button_index == build_index then
								-- show timer
								local percent_done = Object.Get_Tactical_Build_Percent_Done( true )
								button.Set_Clock_Filled(percent_done)
								button.Set_Enabled(true)
								upgrading = true
							else
								-- disable this button
								button.Set_Enabled(false)
								button.Set_Clock_Filled(0)
							end
						else
							if not Ok_To_Upgrade( Object, object_type ) then
								button.Set_Enabled(false)
							else			
								button.Set_Enabled(true)
								button.Set_Clock_Filled(0)
							end
						end
						
						if SelectedBuilding.Has_Behavior( BEHAVIOR_POWERED ) and SelectedBuilding.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
							button.Set_Low_Power_Display(true)
							if upgrading then
								upgrading = false
							end
						else
							button.Set_Low_Power_Display(false)
						end
					else 
						-- just disable this button!
						button.Set_Enabled(false)
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

		-- Temporarily setting both update every frame.  The buy menu updates that often and would hide the upgrades otherwise.
		if upgrading then
			-- 10x times a second
			Set_GUI_Variable("NextUpdateUpgradeButtonTime", cur_time + 0.0)
		else
			-- 2 x times a second
			Set_GUI_Variable("NextUpdateUpgradeButtonTime", cur_time + 0.0)
		end		
	end

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
	
	if TestValid(SelectedBuilding) then
		-- Process the click as if the corresponding button had been clicked!
		local user_data = source.Get_User_Data()
		local type_to_build = user_data[1]
		
		-- If we click on a type that is already under construction do nothing.
		local actual_builder = SelectedBuilding.Get_Hardpoint_Builder(true)
		
		if actual_builder ~= nil then
			local construction_type = actual_builder.Get_Building_Object_Type()
			if construction_type ~= nil then
				return	-- building already in progress
			end
		end

		-- check for auto build		
		local builder = SelectedBuilding
		local hp_info = SelectedBuilding.Get_Next_Hard_Point_Tier_Upgrade( type_to_build )
		
		if hp_info ~= nil and hp_info[1] ~= nil and hp_info[2] ~= nil then
			-- there is both a socket available and a tier hard point left
			type_to_build = hp_info[1]
			builder = hp_info[2]
		end
	
		local success = Structure_Build_Hard_Point(builder, type_to_build)
		
		if success == true then 
			Play_SFX_Event("GUI_Generic_Button_Select")
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Maria 01.08.2007
-- On_Upgrade_Button_Right_Click -- cancel upgrade under construction
-- ------------------------------------------------------------------------------------------------------------------
function On_Upgrade_Button_Right_Click(event, source)
	
	-- JAC - Only process right button click if the button happens to be an upgrade
	local user_data = source.Get_User_Data()
	local is_upgrade = user_data[3]

	if is_upgrade == true then
		if Cancel_Upgrade(source.Get_User_Data())  == true then 
			Play_SFX_Event("GUI_Generic_Button_Select")
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end	
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Cancel_Upgrade 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Cancel_Upgrade(type_to_cancel)

	if TestValid(SelectedBuilding) then
		local actual_builder = SelectedBuilding.Get_Hardpoint_Builder(true)
		
		local success = false
		if actual_builder ~= nil then
			return Structure_Cancel_Build_Hard_Point(actual_builder, type_to_cancel)
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
function Structure_Cancel_Build_Hard_Point(socket_object, type_to_cancel)

	if socket_object == nil then
		MessageBox("Cancel_Build_Hard_Point: The socket object is nil.")
		return false
	end
	
	if type_to_cancel ~= nil then
		if socket_object.Can_Cancel_Build() then 
			Send_GUI_Network_Event("Network_Cancel_Build_Hard_Point", { socket_object, Find_Player("local") })
			return true
		else 
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	else
		MessageBox("Cancel_Build_Hard_Point: The type to cancel is nil.")
	end	
	
	return false
end



function Update_Sell_Menu(building)

	-- This should only happen if the building doesn't have any available upgrades since the upgrade
	-- menu will set SelectedBuilding with the current building
	if SelectedBuilding ~= building then
		SelectedBuilding = building
	end

	button_index = LastButtonIndex
	local button = BuyButtons[button_index]

	object_type = SelectedBuilding.Get_Original_Object_Type()
	if object_type ~= nil then
		cost = object_type.Get_Tactical_Sell_Credits(SelectedBuilding)
		if cost > 0 then
			button.Set_Cost(cost)
			button.Set_User_Data({object_type, true, BUY_BUTTON_SELL})
			button.Set_Hidden(false)
			button.Set_Texture("i_icon_sell.tga")
			button.Set_Enabled(true)
			button.Set_Insufficient_Funds_Display(false)
		end
	end
end



function On_Sell_Button_Click()
	
	if TestValid(SelectedBuilding) then
		-- Process the click as if the corresponding button had been clicked!
		Send_GUI_Network_Event("Network_Sell_Structure", { SelectedBuilding, Find_Player("local") })
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
Interface.Set_Flashing_Buy_Buttons = Set_Flashing_Buy_Buttons
Interface.Set_Flashing_Unit_Button = Set_Flashing_Unit_Button
Interface.Stop_Flashing_Unit_Button = Stop_Flashing_Unit_Button
Interface.Temp_Enable_Build_Item = Temp_Enable_Build_Item
Interface.Update_Upgrade_Menu = Update_Upgrade_Menu
Interface.Update_Sell_Menu = Update_Sell_Menu