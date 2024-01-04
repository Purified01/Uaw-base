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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tactical_Upgrades_Menu.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/02/24
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	if not TestValid(Object) then return end

	this.Register_Event_Handler("Component_Hidden", this, On_Hide_Scene)
	Object.Register_Signal_Handler(On_Power_Change, "OBJECT_POWERED_STATE_CHANGED", this)
	
	if Get_GUI_Variable("IsMenuOpen") == nil then 
		Set_GUI_Variable("IsMenuOpen", false)
	end
	
	ButtonIdxToOrigBoundsMap = {}
	local buttons_list = Find_GUI_Components(this.Menu, "Upgrade")
	for index, button in pairs(buttons_list) do
		button.Set_Hidden(true)
		-- the clock should be green
		button.Set_Clock_Tint({0.0, 1.0, 0.0, 170.0/255.0})
		ButtonIdxToOrigBoundsMap[index] = {}
		ButtonIdxToOrigBoundsMap[index].x, ButtonIdxToOrigBoundsMap[index].y, ButtonIdxToOrigBoundsMap[index].w, ButtonIdxToOrigBoundsMap[index].h = button.Get_Bounds()
		
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Upgrade_Button_Click)
		this.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Upgrade_Button_Right_Click)
	end
	
	Compute_Button_Gap()
	
	Set_GUI_Variable("UpgradeButtons", buttons_list)
	
	-- we need to know whether we are in SellMode or not so that we can process reticle clicks properly!
	Set_GUI_Variable("SellModeActive", false)
	if Object.Get_Owner() == Find_Player("local") then
		-- Update sell mode state accrodingly.
		Set_GUI_Variable("SellModeActive", Is_Sell_Mode_Active())
	end
	
	this.Register_Event_Handler("Refresh_Sell_Mode", nil, On_Refresh_Sell_Mode)
	
	Set_GUI_Variable("NextUpdateUpgradeButtonTime", 0.0)
	
	-- this is valid for novus only since we need to re-position the scene whenever the no power icon is on/off
	Set_GUI_Variable("SceneRaised", false)
	Set_GUI_Variable("FullyUpgraded", false)
	Set_GUI_Variable("LastNumBttsShown", 0)
	
	Initialize_Health_Bar_Display()
	
	LetterBoxModeOn = false
	this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	
	if TestValid(this.CtrlGroup) then 
		this.Register_Event_Handler("Object_Control_Group_Assignment_Changed", nil, On_Control_Group_Assignment_Changed)
		Set_GUI_Variable("FirstServiceInit", true)
		Set_GUI_Variable("ControlGroupIndex", -1)
		Set_GUI_Variable("ControlGroupDisplayUp", true)
		Update_Control_Group_Display(true)
	end
	
	-- Novus has the no power icon, Masari has the DMA bar
	if Initialize_Faction_Display then
		Initialize_Faction_Display()
	else
		Set_GUI_Variable("ControlGroupDisplayYOffset", 0.28)
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(event, source, on_off)
	LetterBoxModeOn = on_off
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Compute_Button_Gap
-- -------------------------------------------------------------------------------------------------------------------------------------
function Compute_Button_Gap()
	-- only use buttons 1 and 2
	local buttonL_bds = ButtonIdxToOrigBoundsMap[1]
	local buttonR_bds = ButtonIdxToOrigBoundsMap[2]
	if not buttonL_bds or not buttonR_bds then return end
	
	if buttonR_bds.x > (buttonL_bds.x + buttonL_bds.w) then
		GAP =  buttonR_bds.x - (buttonL_bds.x + buttonL_bds.w)
	else
		GAP =  (buttonL_bds.x + buttonL_bds.w) - buttonR_bds.x
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_Health_Bar_Display
-- -------------------------------------------------------------------------------------------------------------------------------------
function Initialize_Health_Bar_Display()
	if not TestValid(this.HealthBar) then return end
	
	this.HealthBar.Set_Hidden(true)
	local healthX, healthY, healthWidth, healthHeight = this.HealthBar.Quad.Get_Bounds()
	local healthOrigWidth = healthWidth
	
	Set_GUI_Variable("HealthOrigWidth", healthOrigWidth)
	Set_GUI_Variable("HealthX", healthX)
	Set_GUI_Variable("HealthY", healthY)
	Set_GUI_Variable("HealthWidth", healthWidth)
	Set_GUI_Variable("HealthHeight", healthHeight)
	
	-- Colors for the health bar
	-- NOTE: we don't set them with Set_GUI_Variable since they are static
	COLOR_HEALTH_GOOD = { }
	COLOR_HEALTH_MEDIUM = { }
	COLOR_HEALTH_LOW = { }
	
	COLOR_HEALTH_GOOD.R = 0.125
	COLOR_HEALTH_GOOD.G = 1.0
	COLOR_HEALTH_GOOD.B = 0.125
	COLOR_HEALTH_GOOD.A = 1.0

	COLOR_HEALTH_MEDIUM.R = 1.0
	COLOR_HEALTH_MEDIUM.G = 1.0
	COLOR_HEALTH_MEDIUM.B = 0.125
	COLOR_HEALTH_MEDIUM.A = 1.0

	COLOR_HEALTH_LOW.R = 1.0
	COLOR_HEALTH_LOW.G = 0.125
	COLOR_HEALTH_LOW.B = 0.125
	COLOR_HEALTH_LOW.A = 1.0
	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Health_Display
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Health_Display()

	if not TestValid(Object) then return end
	
	local health_percent = Object.Get_Hull()
	if not health_percent then health_percent = 0.0 end
	
	if this.HealthBar.Get_Hidden() == true and not LetterBoxModeOn then
		this.HealthBar.Set_Hidden(false)
	end
	
	-- just hide the bar if we have zero health.
	if health_percent <= 0 then 
		this.HealthBar.Set_Hidden(true)
		Set_GUI_Variable("LastUpdatedHealthPercent", health_percent)
		return
	end
	
	if Get_GUI_Variable("LastUpdatedHealthPercent") == health_percent then return end
	Set_GUI_Variable("LastUpdatedHealthPercent", health_percent)
	
	local orig_w = Get_GUI_Variable("HealthOrigWidth")
	local x = Get_GUI_Variable("HealthX")
	local y = Get_GUI_Variable("HealthY")
	local w = Get_GUI_Variable("HealthWidth")
	local h = Get_GUI_Variable("HealthHeight")
	
	-- update the width of the bar according to the health percent.
	w = orig_w * health_percent
	this.HealthBar.Quad.Set_Bounds(x, y, w, h)

	--Tint the health bar based on current health
	if health_percent > 0.66 then
		this.HealthBar.Quad.Set_Tint(COLOR_HEALTH_GOOD.R, COLOR_HEALTH_GOOD.G, COLOR_HEALTH_GOOD.B, COLOR_HEALTH_GOOD.A)
	elseif health_percent > 0.33 then
		this.HealthBar.Quad.Set_Tint(COLOR_HEALTH_MEDIUM.R, COLOR_HEALTH_MEDIUM.G, COLOR_HEALTH_MEDIUM.B, COLOR_HEALTH_MEDIUM.A)
	else
		this.HealthBar.Quad.Set_Tint(COLOR_HEALTH_LOW.R, COLOR_HEALTH_LOW.G, COLOR_HEALTH_LOW.B, COLOR_HEALTH_LOW.A)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- First_Service_Init
-- -------------------------------------------------------------------------------------------------------------------------------------
function First_Service_Init()
	if Get_GUI_Variable("FirstServiceInit") then
		if Object.Get_Owner() == Find_Player("local") then
			-- NOTE: we need to do it here because some objects need to check for
			-- Ctrl. gp assignment on their parents.
			Check_For_Existing_Control_Group_Assignment()
		end
		Set_GUI_Variable("FirstServiceInit", false)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Check_For_Existing_Control_Group_Assignment
-- -------------------------------------------------------------------------------------------------------------------------------------
function Check_For_Existing_Control_Group_Assignment()
	local cg_assignment = Object.Get_Control_Group_Assignment()
	if cg_assignment ~= -1.0 then
		-- Update the object's UI to reflect the control group assignment.
		Process_Control_Group_Assignment_Change(Object, cg_assignment)	
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Assignment_Changed
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Assignment_Changed(event, source, object, group_id)
	Process_Control_Group_Assignment_Change(object, group_id)	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Process_Control_Group_Assignment_Change
-- -------------------------------------------------------------------------------------------------------------------------------------
function Process_Control_Group_Assignment_Change(object, group_id)
	if object ~= Object then 
		return
	end
	Set_GUI_Variable("ControlGroupIndex", group_id)
	Update_Control_Group_Display(true)
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Control_Group_Display
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Control_Group_Display(set_texture)
	if not TestValid(this.CtrlGroup) then return end
	local group_id = Get_GUI_Variable("ControlGroupIndex")
	-- if we are not the local player or the object is not assigned to any control group then hide the display!.
	if Object.Get_Owner() ~= Find_Player("local") or group_id <= -1 then 
		this.CtrlGroup.Set_Hidden(true)
	else
		this.CtrlGroup.Set_Hidden(false)
		if set_texture then 
			local texture_name = "I_icon_ctrl_"..group_id..".tga"
			this.CtrlGroup.Set_Texture(texture_name)
		end
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Debug_Switch_Sides
-- -------------------------------------------------------------------------------------------------------------------------------------
function Debug_Switch_Sides()
	Update_Control_Group_Display(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Enter_Inactive
-- ------------------------------------------------------------------------------------------------------------------
function On_Enter_Inactive()
	if Get_GUI_Variable("IsMenuOpen") then 
		Display_Menu(false)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Active - EQUIVALENT TO ON_UPDATE
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Active()
	
	if LetterBoxModeOn then
		if not this.Get_Hidden() then 
			this.Set_Hidden(true)
		end
	elseif this.Get_Hidden() then 
		this.Set_Hidden(false)
	end
	
	First_Service_Init()
	
	-- Specific updates, eg., Novus has the no power icon, Masari has the DMA bar
	if Update_Faction_Display then 
		Update_Faction_Display()
	end
	
	-- All factions have health display.
	Update_Health_Display()
	
	if not Are_Any_Controllers_Connected() then
		if TestValid(Object) then
			Object.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION)
			local is_menu_open = Get_GUI_Variable("IsMenuOpen")
				
			if Object.Get_Owner() == Find_Player("local") then 
				
				-- the structures under construction only display their health!.
				if Object.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) == true then
					if is_menu_open == true then 
						Display_Menu(false)
					end
					return
				end
				
				if Object.Is_Selected() == true then 
					if is_menu_open == false then
						Display_Menu(true)	
					end
				elseif is_menu_open == true then 
					Display_Menu(false)
				end
			end
			-- should we display/hide the menu?
			Update_Menu(GetCurrentTime())
		end
	elseif Get_GUI_Variable("IsMenuOpen") then
		Display_Menu(false)
	end
	
	Update_Control_Group_Position()
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Control_Group_Position
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Control_Group_Position()
	-- if we are fully upgraded or we are powered (Novus case) we
	-- want to lower the control group quad so that it displays at the same
	-- location as any other CG display on health bars.
	if Get_GUI_Variable("ControlGroupIndex") == -1.0 then
		return
	end
	
	local powered = true
	if TestValid(this.NoPower) and not this.NoPower.Get_Hidden() then
		powered = false
	end
	
	local display_cg_down = powered and Get_GUI_Variable("FullyUpgraded")
	
	if display_cg_down and Get_GUI_Variable("ControlGroupDisplayUp") then
		-- move down
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = this.CtrlGroup.Get_Bounds()
		this.CtrlGroup.Set_Bounds(bds.x, bds.y + Get_GUI_Variable("ControlGroupDisplayYOffset"), bds.w, bds.h)
		Set_GUI_Variable("ControlGroupDisplayUp", false)
	elseif not display_cg_down and not Get_GUI_Variable("ControlGroupDisplayUp") then
		-- move up
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = this.CtrlGroup.Get_Bounds()
		this.CtrlGroup.Set_Bounds(bds.x, bds.y - Get_GUI_Variable("ControlGroupDisplayYOffset"), bds.w, bds.h)
		Set_GUI_Variable("ControlGroupDisplayUp", true)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Refresh_Sell_Mode
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Refresh_Sell_Mode(event, source, on_off)
	if Object.Get_Owner() == Find_Player("local") then 
		Set_GUI_Variable("SellModeActive", on_off)
		if on_off == true and Get_GUI_Variable("IsMenuOpen") == true then 
			-- close any menu we may have up!
			Display_Menu(false)
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Display_Menu(display_hide)
	if display_hide == true and Get_GUI_Variable("FullyUpgraded") == false then 
		Set_GUI_Variable("IsMenuOpen", true)
		this.Menu.Set_Hidden(false)
	else
		Set_GUI_Variable("IsMenuOpen", false)
		this.Menu.Set_Hidden(true)
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
-- Reset_Buttons_Format
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Buttons_Format(num_bttns_showing)
	local buttons_list = Get_GUI_Variable("UpgradeButtons")
	
	if num_bttns_showing > #buttons_list then return end
	
	for i = 1, num_bttns_showing do
		local button = buttons_list[i]
		if ButtonIdxToOrigBoundsMap[i] then 
			local bds = ButtonIdxToOrigBoundsMap[i]
			button.Set_Bounds(bds.x, bds.y, bds.w, bds.h)
		end
	end
	
	Set_GUI_Variable("UpgradeButtons", buttons_list)	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Format_Buttons
-- -------------------------------------------------------------------------------------------------------------------------------------
function Format_Buttons(num_bttns_showing)
	-- reset the formatting of the buttons we need to use.
	Reset_Buttons_Format(num_bttns_showing)
	
	-- re-position the buttons now!.
	local buttons_list = Get_GUI_Variable("UpgradeButtons")
	if not buttons_list then return end
	
	local offset = ((#buttons_list) - num_bttns_showing)/2.0
	local gaps = Math.floor(offset)
	
	-- now, each button has to be moved by offset+gaps.
	for idx = 1, num_bttns_showing do
		local button = buttons_list[idx]
		local orig_bds = ButtonIdxToOrigBoundsMap[idx] 
		button.Set_Bounds(orig_bds.x + offset*orig_bds.w +  gaps*GAP, orig_bds.y, orig_bds.w, orig_bds.h)
	end
	
	Set_GUI_Variable("LastNumBttsShown", num_bttns_showing)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Menu_Position
-- ------------------------------------------------------------------------------------------------------------------
function Update_Menu_Position(num_bttns_showing)
	
	-- if we have the NoPower icon, raise/lower the menu depending on the show state of the icon.
	if TestValid(this.NoPower) then
		if this.NoPower.Get_Hidden() == true and Get_GUI_Variable("SceneRaised") == false then 
			if not OrigMenuPosition then
				OrigMenuPosition = {}
				OrigMenuPosition.x, OrigMenuPosition.y,  OrigMenuPosition.w, OrigMenuPosition.h = this.Menu.Get_Bounds()
			end
			
			local x, y, w, h = this.NoPower.Get_Bounds()
			this.Menu.Set_Bounds(OrigMenuPosition.x, y, OrigMenuPosition.w, OrigMenuPosition.h)
			Set_GUI_Variable("SceneRaised", true)
		elseif this.NoPower.Get_Hidden() == false and Get_GUI_Variable("SceneRaised") == true then
			this.Menu.Set_Bounds(OrigMenuPosition.x, OrigMenuPosition.y, OrigMenuPosition.w, OrigMenuPosition.h)		
			Set_GUI_Variable("SceneRaised", false)
		end	
	end
	
	-- center the menu on the scene
	if num_bttns_showing ~= #Get_GUI_Variable("UpgradeButtons") and Get_GUI_Variable("LastNumBttsShown") ~= num_bttns_showing then 
		Format_Buttons(num_bttns_showing)			
	end	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Reset_Buttons
-- -------------------------------------------------------------------------------------------------------------------------------------
function Reset_Buttons()
	
	local buttons_list = Get_GUI_Variable("UpgradeButtons")
	if not buttons_list then return end
	
	-- now, each button has to be moved by offset+gaps.
	for _, button in pairs(buttons_list) do
		button.Set_Hidden(true)
		button.Set_Text("")
		button.Clear_Cost()
		button.Set_Clock_Filled(0.0)
	end
	
	Set_GUI_Variable("UpgradeButtons", buttons_list)
end


-- ------------------------------------------------------------------------------------------------------------------
-- KDB Show upgrade options for buildings
-- ------------------------------------------------------------------------------------------------------------------
function Update_Menu( cur_time )

	if Get_GUI_Variable("IsMenuOpen") == false then return end
	
	if #Get_GUI_Variable("UpgradeButtons") <= 0 then
		return
	end
	
	if not TestValid(Object) then
		-- reset the menu
		Set_GUI_Variable("NextUpdateUpgradeButtonTime", 0.0)
		this.Menu.Set_Hidden(true)
		return
	end

	-- we have already added all the possible upgrades for this building so let's not do anything else since the menu is going to be hidden!.
	if Get_GUI_Variable("FullyUpgraded") == true then return end
	
	local buttons_list = Get_GUI_Variable("UpgradeButtons")
	local next_upgrade_button_time = Get_GUI_Variable("NextUpdateUpgradeButtonTime")
	if cur_time == nil then
		cur_time = next_upgrade_button_time
	end
	
	if cur_time >= next_upgrade_button_time then
		
		local upgrading = false
		upgradable_buildings = {}

		-- show autobuild items (1st parameter false)
		--upgradable_buildings = Object.Get_Tactical_Hardpoint_Upgrades( false, false, true )
		upgradable_buildings = Object.Get_Updated_Buildable_Hardpoints_List()
		
		if upgradable_buildings == nil then 
			-- nothing so 2x time a second
			--Set_GUI_Variable("NextUpdateUpgradeButtonTime", cur_time + 0.5)
			Set_GUI_Variable("FullyUpgraded", true)
			return
		end
		
		-- are we building any of these objects?
		local button_index = 1
		local build_index = 0
		local build_time = 0

		build_time = Object.Get_Tactical_Build_Time_Left_Seconds( true )
		construction_type = Object.Get_Building_Object_Type( true )
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
		
		button_index = 1
		local player = Find_Player("local")
		
		if player ~= Object.Get_Owner() then
			--MessageBox("The owner of the structure is not the local player!!!!!.")
			player = Object.Get_Owner()
		end
		
		local num_existing_upgrades = 0
		local player_credits = player.Get_Credits()
		if #upgradable_buildings > 0 then 
			-- let's clear the state of the buttons.
			Reset_Buttons()
		end
		
		for index, object_type in pairs(upgradable_buildings) do
			-- we don't want to display types locked from STORY!
			if player.Is_Object_Type_Locked(object_type, STORY) == false then
		
				icon_name = object_type.Get_Icon_Name()
				if icon_name ~= "" then
					local button = buttons_list[button_index]
					button.Set_Texture(icon_name)
					button.Set_Hidden(false)
					button.Set_User_Data(object_type)
					
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
						
						if Object.Has_Behavior( BEHAVIOR_POWERED ) and Object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
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

		if button_index == 1 then
			-- this building has all upgrades already, so let's hide this scene
			this.Menu.Set_Hidden(true)
			Set_GUI_Variable("FullyUpgraded", true)
		else
			-- in the case of Novus, we need to re-position the menu depending on whether the no power icon is on or off.
			Update_Menu_Position(button_index - 1)
		end
		
		if upgrading then
			-- 10x times a second
			Set_GUI_Variable("NextUpdateUpgradeButtonTime", cur_time + 0.1)
		else
			-- 2 x times a second
			Set_GUI_Variable("NextUpdateUpgradeButtonTime", cur_time + 0.5)
		end		
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Upgrade_Button_Click KDB
-- ------------------------------------------------------------------------------------------------------------------
function On_Upgrade_Button_Click(event, source)
	
	-- if the sell mode is active, then clicking anywhere in this structure will cause it to get sold! (if possible)
	if Get_GUI_Variable("SellModeActive") == true then 
		-- We want to sell this structure!
		if Object.Has_Behavior(BEHAVIOR_TACTICAL_SELL) == true then
			Send_GUI_Network_Event("Network_Sell_Structure", { Object, Find_Player("local") })
		end
	elseif TestValid(Object) then
		-- Process the click as if the corresponding button had been clicked!
		local type_to_build = source.Get_User_Data()
		
		-- If we click on a type that is already under construction do nothing.
		local actual_builder = Object.Get_Hardpoint_Builder(true)
		
		if actual_builder ~= nil then
			local construction_type = actual_builder.Get_Building_Object_Type()
			if construction_type ~= nil then
				return	-- building already in progress
			end
		end

		-- check for auto build		
		local builder = Object
		local hp_info = Object.Get_Next_Hard_Point_Tier_Upgrade( type_to_build )
		
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
	
	if Get_GUI_Variable("SellModeActive") == true then 
		-- RIGHT CLICKING ANYWHERE, CANCELS THE CLICK/SELL MODE.
		-- This will cause Sell Mode to be canceled!.
		Raise_Event_Immediate_All_Scenes("End_Sell_Mode", {})
	elseif Cancel_Upgrade(source.Get_User_Data())  == true then 
		Play_SFX_Event("GUI_Generic_Button_Select")
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Cancel_Upgrade 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Cancel_Upgrade(type_to_cancel)

	if TestValid(Object) then
		local actual_builder = Object.Get_Hardpoint_Builder(true)
		
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


function On_Hide_Scene()
	DebugMessage("Disabling Scene %i : %s", GetCurrentTime(), tostring(this))
	if Is_Power_On() then
		this.Enable(false)
	else
		this.Set_Hidden(false)
	end
end

function On_Power_Change()
	if not Is_Power_On() then
		this.Enable(true)
		this.Set_Hidden(false)
	else
		this.Set_Hidden(true)
		this.Enable(false)
	end
end

function Is_Power_On()

	if Object.Has_Behavior( BEHAVIOR_POWERED ) and Object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
		return false
	end
	return true
end