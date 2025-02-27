if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LUA_PREP = true



function Register_UI_Control_Handlers()

	-- RESEARCH BUTTON CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Start_Flash_Research_Button", nil, UI_Start_Flash_Research_Button)
	this.Register_Event_Handler("UI_Stop_Flash_Research_Button", nil,UI_Stop_Flash_Research_Button)	
	FlashResearchButton = false
	
	this.Register_Event_Handler("UI_Start_Flash_Research_Option", nil, UI_Start_Flash_Research_Option)
	ValidResearchPaths = {}
	ValidResearchPaths["A"] = true
	ValidResearchPaths["B"] = true
	ValidResearchPaths["C"] = true
	
	
	-- ABILITY BUTTONS CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Start_Flash_Ability_Button", nil, UI_Start_Flash_Ability_Button)
	this.Register_Event_Handler("UI_Stop_Flash_Ability_Button", nil,UI_Stop_Flash_Ability_Button)
	
	-- Sometimes designers may want locked abilities to show.  In that case, we will show the button disabled!.
	this.Register_Event_Handler("UI_Force_Display_Ability", nil, UI_Gamepad_Force_Display_Ability)
	ForceAbilityDisplay = {}
	
	-- BUILDER'S MENU BUILDING BUTTON CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Builder button
	this.Register_Event_Handler("UI_Start_Flash_Builder_Button", nil, UI_Start_Flash_Builder_Button)
	this.Register_Event_Handler("UI_Stop_Flash_Builder_Button", nil, UI_Stop_Flash_Builder_Button)
	FlashBuilderButton = false
	
	-- Menu buttons
	this.Register_Event_Handler("UI_Start_Flash_Construct_Building", nil, UI_Start_Flash_Construct_Building)
	this.Register_Event_Handler("UI_Stop_Flash_Construct_Building", nil, UI_Stop_Flash_Construct_Building)
	BuildingTypesToFlash = {}
	
	-- BUILD MENUS CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Start_Flash_Queue_Buttons", nil, UI_Start_Flash_Queue_Buttons)
	
	-- this one is called from the queue managers themselves so that we can update all scenes containing this data!!!!!.
	this.Register_Event_Handler("Internal_Stop_Queue_Buttons_Flash", nil, Stop_Flash_Queue_Buttons_Flash)
	
	-- SELL BUTTON CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Show_Sell_Button", nil, On_UI_Show_Sell_Button)
	this.Register_Event_Handler("UI_Hide_Sell_Button", nil, On_UI_Hide_Sell_Button)
	ForceHideSellButton = false
	
	-- SUPERWEAPON BUTTONS CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Start_Flash_Superweapon", nil, UI_Start_Flash_Superweapon)
	this.Register_Event_Handler("UI_Stop_Flash_Superweapon", nil, UI_Stop_Flash_Superweapon)	
	
	-- CREDITS/POP CAP AND ALL RELEVANT INFO CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Set_Display_Credits_Pop", nil,UI_Set_Display_Credits_Pop)
	
	-- TOOLTIP CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Display_Tooltip_Resources", nil, Set_UI_Display_Tooltip_Resources)
	
	-- RADAR MAP CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Radar_Map_Zoom_Out", nil, On_UI_Radar_Map_Zoom_Out)
	this.Register_Event_Handler("UI_Show_Radar_Map", nil, On_UI_Show_Radar_Map)
	ShowRadarMap = true
	
	-- CONTEXT DISPLAYS CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Show_Controller_Context_Display", nil, On_UI_Show_Controller_Context_Display)
	ShowContextDisplay = true
	
	-- BATTLECAM BUTTON CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Show_BattleCam_Button", nil, On_UI_Show_BattleCam_Button)
	ShowBattleCamButton = true
	
	-- CONTROL GROUP UI CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Flash_Control_Group_Containing_Unit", nil, On_UI_Flash_Control_Group_Containing_Unit)
	
	-- RESEARCH BUTTON CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Hide_Research_Button", nil, On_UI_Hide_Research_Button)
	
	-- COMMAND BAR CONTROL
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Hide_Command_Bar", nil, On_UI_Hide_Command_Bar)
	
	-- ******************* 	NOVUS SPECIFIC 
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("UI_Start_Patch_Menu_Button_Flash", nil, On_UI_Start_Patch_Menu_Button_Flash)
	this.Register_Event_Handler("UI_Stop_Patch_Menu_Button_Flash", nil, On_UI_Stop_Patch_Menu_Button_Flash)
	
	-- ******************* 	MASARI SPECIFIC 
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	-- ******************* 	ALIEN SPECIFIC 
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Hide_Command_Bar
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Hide_Command_Bar(_, _, hide_unhide)
	
	if hide_unhide and not TestValid(SelectedBuildings[1]) then
		Controller_Display_Command_Bar(false)
	end
	
	ForceHideCommandBar = hide_unhide
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Hide_Research_Button
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Hide_Research_Button(_, _, hide_unhide)
	ForceHideResearchButton = hide_unhide
	
	if hide_unhide then 
		Controller_Display_Research_And_Faction_UI(ControllerDisplayingResearchAndFactionUI, true) -- true == force update.	
	end
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Start_Patch_Menu_Button_Flash
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Start_Patch_Menu_Button_Flash(event, source)
	FlashPatchButton = true	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Stop_Patch_Menu_Button_Flash
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Stop_Patch_Menu_Button_Flash(event, source)
	FlashPatchButton = false	
end

-- ------------------------------------------------------------------------------------------------------------------
--  On_UI_Radar_Map_Zoom_Out
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Radar_Map_Zoom_Out(_, _)
	Radar_Map_Zoom_Out()
end

-- -----------------------------------------------------------------------------------------------------------------
-- On_UI_Flash_Control_Group_Containing_Unit
-- This is used by designers to flash a specific control group icon!
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Flash_Control_Group_Containing_Unit(_, _, unit)
	local cg_idx = Controller_Find_Control_Group_Containing_Unit(unit)
	if cg_idx ~= -1 then
		if TestValid(this.CommandBar.Gamepad_Radial_Control_Groups) then
			this.CommandBar.Gamepad_Radial_Control_Groups.Flash_Control_Group_Icon(cg_idx)
		else
			-- Mark this control group icon to be flashed!.
			this.Carousel_ControlGroups.Flash_Control_Group_Icon(cg_idx+1)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Show_BattleCam_Button
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Show_BattleCam_Button(_, _, show)
	ShowBattleCamButton = show
	if not show then
		-- do we need to display it right away?
		if not ControllerDisplayingCommandBar then
			this.GamepadContextDisplay.Set_Hidden(false)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Show_Controller_Context_Display
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Show_Controller_Context_Display(_, _, show)
	ShowContextDisplay = show
	-- Update the context data
	Controller_Update_Context()
	
	if show then 
		-- if the display is not being hidden but any other UI display mode, unhide it, else, let the current display mode 
		-- update the hidden state of the context display.
		if not ((ControllerDisplayingCommandBar or ControllerDisplayingResearchAndFactionUI or ControllerDisplayingSelectionUI)  -- tactical mode
			or 
			(DisplayingSelectionUI or DisplayingMegaweaponsUI or DisplayingHeroSelectionMenu)) then -- strategic mode.
			this.GamepadContextDisplay.Set_Hidden(false)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Show_Radar_Map
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Show_Radar_Map(_, _, show)
	ShowRadarMap = show
	if not show then
		Hide_Radar_Map()
	else
		Show_Radar_Map()
	end
	
	-- Flag code as to whether the Radar Map UI is visible or not!.
	Controller_Show_Radar_Map(show)
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Set_UI_Display_Tooltip_Resources
-- ------------------------------------------------------------------------------------------------------------------------------------
function Set_UI_Display_Tooltip_Resources(_, _, on_off)
	Tooltip.Set_Display_Tooltip_Resources(on_off)
end

	
-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Construct_Building - 
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Construct_Building(event, source, building_name)
	BuildingTypesToFlash[Find_Object_Type(building_name).Get_Name()] = true
	Update_Button_Flash_State()
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Construct_Building - 
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Construct_Building(event, source, building_name)
	BuildingTypesToFlash[Find_Object_Type(building_name).Get_Name()] = nil
	Update_Button_Flash_State()
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Queue_Buttons - 
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Queue_Buttons(event, source, builder_type, object_type)
	-- NOTE: object_type MAY be null for designers may only want to flash the building button 
	-- and none of the buy buttons.
	
	if not builder_type then 
		return
	end
	
	local queue_type = builder_type.Get_Building_Queue_Type()
	if queue_type == nil then 
		return		
	end
	
	-- just in case close all other displays!
	Close_All_Displays()
	
	QueueTypesToFlash[queue_type] = true
	
	if object_type then
		if QueueTypeStrgToEnumValue[queue_type] ~= QueueTypeStrgToEnumValue["NonProduction"] then
			QueueManager.Set_Flashing_Unit_Button(object_type)
		end
	end
	
	QueueManager.Set_Flashing_Building_Button(builder_type)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Stop_Flash_Queue_Buttons_Flash
-- ------------------------------------------------------------------------------------------------------------------
function Stop_Flash_Queue_Buttons_Flash(event, source, building_type, object_type)
	
	-- NOTE: object_type MAY be null for designers may only want to flash the building button 
	-- and none of the buy buttons.
	
	if not building_type then 
		return
	end
	
	local queue_type = building_type.Get_Building_Queue_Type()
	if queue_type == nil then
		return
	end
	
	QueueTypesToFlash[queue_type] = nil
	QueueManager.Stop_Flashing_Building_Button(building_type)
	
	if object_type then
		if QueueTypeStrgToEnumValue[queue_type] ~= QueueTypeStrgToEnumValue["NonProduction"] then
			QueueManager.Stop_Flashing_Unit_Button(object_type)
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Show_Sell_Button.
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Show_Sell_Button()
	ForceHideSellButton = false
	
	-- If applicable, unhide the sell button now!.
	if TestValid(SellButton) and ControllerDisplayingCommandBar then
		SellButton.Set_Hidden(false)
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Hide_Sell_Button.
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Hide_Sell_Button()
	ForceHideSellButton = true
	
	-- Hide the button!.
	if TestValid(SellButton) then 
		SellButton.Set_Hidden(true)
	end
end


-------------------------------------------------------------------------------
-- UI_Start_Flash_Superweapon
-------------------------------------------------------------------------------
function UI_Start_Flash_Superweapon(_, _, weapon_type_name)
	if SuperweaponButtons then
		for _, button in pairs(SuperweaponButtons) do
			if button.Get_User_Data() == weapon_type_name then
				Start_Flash(button)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- UI_Stop_Flash_Superweapon
-------------------------------------------------------------------------------
function UI_Stop_Flash_Superweapon(_, _, weapon_type_name)
	if SuperweaponButtons then
		for _, button in pairs(SuperweaponButtons) do
			if button.Get_User_Data() == weapon_type_name then
				Stop_Flash(button)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- UI_Start_Flash_Ability_Button
-------------------------------------------------------------------------------
function UI_Start_Flash_Ability_Button(_, _, ab_text_id)
	AbButtonsToFlash[ab_text_id] = true
end


-------------------------------------------------------------------------------
-- UI_Stop_Flash_Ability_Button
-------------------------------------------------------------------------------
function UI_Stop_Flash_Ability_Button(_, _, ab_text_id)

	if AbButtonsToFlash[ab_text_id] then
		AbButtonsToFlash[ab_text_id] = nil
	end
end

-------------------------------------------------------------------------------
-- UI_Force_Display_Ability
-------------------------------------------------------------------------------
function UI_Gamepad_Force_Display_Ability(_, _, unit_type, unit_ab_name, on_off)

	if on_off then
		Internal_UI_Force_Display_Ability(unit_type, unit_ab_name)
	else
		Internal_UI_Reset_Force_Display_Ability(unit_type, unit_ab_name)
	end	
end

-------------------------------------------------------------------------------
-- Internal_UI_Force_Display_Ability
-------------------------------------------------------------------------------
function Internal_UI_Force_Display_Ability(unit_type, unit_ab_name)
	
	local object_type_name = unit_type.Get_Name()
	
	if not ForceAbilityDisplay[object_type_name] then
		ForceAbilityDisplay[object_type_name] = {}
	end
	
	ForceAbilityDisplay[object_type_name][unit_ab_name] = true
	
	-- Refresh the display.
	Selection_Changed()
end

-------------------------------------------------------------------------------
-- Internal_UI_Reset_Force_Display_Ability
-------------------------------------------------------------------------------
function Internal_UI_Reset_Force_Display_Ability(unit_type, unit_ab_name)
	
	if not ForceAbilityDisplay then
		return
	end

	local object_type_name = unit_type.Get_Name()
	
	if not ForceAbilityDisplay[object_type_name] then
		return
	end
	
	ForceAbilityDisplay[object_type_name][unit_ab_name] = nil
	
	-- Refresh the display.
	Selection_Changed()
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Set_Display_Credits_Pop
-- ------------------------------------------------------------------------------------------------------------------
function UI_Set_Display_Credits_Pop(_, _, on_off)
	DisplayCreditsPop = on_off
	Scene.PopIcon.Set_Hidden(not DisplayCreditsPop)
	Scene.PopText.Set_Hidden(not DisplayCreditsPop)
	Scene.MaterialsText.Set_Hidden(not DisplayCreditsPop)
	Scene.RMIcon.Set_Hidden(not DisplayCreditsPop)
	if TestValid(this.WalkerPopText) then
		this.WalkerPopText.Set_Hidden(not DisplayCreditsPop)
	end
	
	if on_off then
		--Force an immediate update of the display
		LastRawMaterials = nil
		LastUsedPopCap = nil
		Update_Credits_Display()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Builder_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Builder_Button(_, _)
	FlashBuilderButton = true
	Update_Button_Flash_State()
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Builder_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Builder_Button(_, _)
	FlashBuilderButton = false
	Update_Button_Flash_State()
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Research_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Research_Button(_, _)
	if Can_Access_Research() then
		FlashResearchButton = true
	else
		FlashResearchButton = false
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Research_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Research_Button(_, _)
	FlashResearchButton = false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Research_Option
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Research_Option(_, _, branch, suite)

	if not ValidResearchPaths[branch] then
		MessageBox("UI_Start_Flash_Research_Option::The only valid research paths are 'A', 'B' or 'C'")
		return
	end
	
	if suite < 1 or suite > 4 then
		MessageBox("UI_Start_Flash_Research_Option::The only valid research suite values are 1, 2, 3 or 4")
		return
	end
	
	if TestValid(this.Research_Tree) then 
		this.Research_Tree.Set_Flash_Research_Option(branch, suite)
	end	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Register_UI_Control_Handlers = nil
	Kill_Unused_Global_Functions = nil
end
