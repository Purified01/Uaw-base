if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/HP_Configuration_Radial_Menu_Scene.lua
--
--            Author: Maria_Teruel
--
--          Date: 2006/12/20
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")


function Init_Radial_Menu_Scene(object)

	if not TestValid(object) then return end
	
	this.Set_Hidden(true)
	this.Enable(false)
	
	local build_buttons = Find_GUI_Components(Scene, "BuildOption")
	Set_GUI_Variable("BuildOptionButtons", build_buttons)
	
	MENU_OPTIONS_TAB_ORDER = Declare_Enum(0)
	ButtonToIndexMap = {}
	for index, button in pairs(build_buttons) do
		ButtonToIndexMap[button] = index
		button.Set_Hidden(true)
		button.Enable(false)
		-- Maria 02.07.2008
		-- we need to call this here to make sure the x overlay is created when the button is not animated.
		-- In fact, if we try to create the X overlay while the button has focus, the button that gets to create the 
		-- X overlay will have it in the wrong size because the overlay is created afetr the button has gained
		-- focus.
		button.Use_X_Overlay(false)
		button.Set_Tab_Order(MENU_OPTIONS_TAB_ORDER + index)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Option_Button_Clicked)	
		this.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Right_Click)	
	end
	
	Init_Radial_Navigation_Data()
	
	this.Register_Event_Handler("Type_Lock_State_Changed", nil, Refresh_Menu)
	this.Register_Event_Handler("Player_Credits_Changed", nil, Refresh_Menu)
	
	Set_GUI_Variable("SocketObject", object)
	Set_GUI_Variable("Player", object.Get_Owner())
	Set_GUI_Variable("TypeSelected", nil)
	Set_GUI_Variable("Displaying", false)
end


-- **************************************************************************************************************
-- ---------------------------- 	BEGIN CONTROLLER MENU NAVIGATION		------------------------------
-- **************************************************************************************************************

function Init_Radial_Navigation_Data()
	-- Compute the angle at which the buttons are set.  Indeed, to get a button index based on the 
	-- degrees that stick moved we need to do:
	-- raw_idx = ((degress/BASE_DIVISION_ANGLE) +- 1 (based on .5 diff))+1 (since the degrees value ranges from (0, 360]
	-- Hence, idx = (raw_idx == 8 ? 8 : raw_idx % #options).
	TOTAL_NUM_OPTIONS = #Get_GUI_Variable("BuildOptionButtons")
	if TOTAL_NUM_OPTIONS == 0 then 
		MessageBox("The menu doesn't have any option buttons.")
		return
	end
	
	BASE_DIVISION_ANGLE = 360.0/TOTAL_NUM_OPTIONS
	
	-- Register for the stick move events
	this.Register_Event_Handler("Controller_Left_Stick_Move", nil, On_Controller_Stick_Move)
	this.Register_Event_Handler("Controller_Right_Stick_Move", nil, On_Controller_Stick_Move)
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Controller_Stick_Move
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Controller_Stick_Move(_, _, x_percent, y_percent, degrees)

	if degrees == 0.0 then 
		-- the stick has been released, no movement to process.
		return
	end
	
	-- NOTE: 0 < degress < 360 clockwise
	-- raw_idx = ((degress/BASE_DIVISION_ANGLE) +- 1 (based on .5 diff))+1 (since the degrees value ranges from (0, 360]
	-- Hence, idx = (raw_idx == 8 ? 8 : raw_idx % #options).
	local raw_index = (degrees/BASE_DIVISION_ANGLE) + 0.5
	raw_index = Math.floor(raw_index) + 1
	
	if (raw_index > TOTAL_NUM_OPTIONS) then
		raw_index = 1
	end
	
	-- Now, if the button associated to that index is hidden we will have to snap to the closest unhidden button
	local buttons_list = Get_GUI_Variable("BuildOptionButtons")
	local button = buttons_list[raw_index]
	if TestValid(button) then 
		if button.Get_Hidden() then 
			raw_index = Fix_Index(raw_index)
			button = buttons_list[raw_index]
			if button.Get_Hidden() then 
				return
			else
				button.Set_Key_Focus()
			end			
		else
			-- this is the button we are looking for, so let's set the focus on it!.
			button.Set_Key_Focus()
		end
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Fix_Index
-- -------------------------------------------------------------------------------------------------------------------------------------
function Fix_Index(raw_index)
	
	local move_up_units = Get_Move_Up_Units_From(raw_index)
	local move_down_units = Get_Move_Down_Units_From(raw_index)
	
	if move_up_units == -1 or move_down_units == -1 then 
		MessageBox("BAD")
		return
	end
	
	if move_up_units < move_down_units then
		-- move up
		if move_up_units == 0 then 
			-- if move_up_units = 0 then the next index should be the first one!.
			raw_index = 1
		else
			raw_index = raw_index + move_up_units
		end
	else
		raw_index = raw_index - move_down_units			
	end
	
	return raw_index
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Get_Move_Up_Units_From
-- -------------------------------------------------------------------------------------------------------------------------------------
function Get_Move_Up_Units_From(raw_index)
	if raw_index > TOTAL_NUM_OPTIONS then
		return -1
	end
	
	local count = 0
	local bttn_list = Get_GUI_Variable("BuildOptionButtons")
	for i = raw_index + 1, TOTAL_NUM_OPTIONS do
		local button = bttn_list[i]
		if TestValid(button) then
			count = count + 1
			if not button.Get_Hidden() then 
				break
			end
		end
	end
	
	return count
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Get_Move_Down_Units_From
-- -------------------------------------------------------------------------------------------------------------------------------------
function Get_Move_Down_Units_From(raw_index)
	if raw_index > TOTAL_NUM_OPTIONS then
		return -1
	end
	
	local count = 0
	local bttn_list = Get_GUI_Variable("BuildOptionButtons")
	for i = raw_index - 1, 1, -1 do
		local button = bttn_list[i]
		if TestValid(button) then
			count = count + 1
			if not button.Get_Hidden() then 
				break
			end
		end
	end
	
	return count
end

-- **************************************************************************************************************
-- ---------------------------- 	END CONTROLLER MENU NAVIGATION		------------------------------
-- **************************************************************************************************************


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_Build_Options
-- ------------------------------------------------------------------------------------------------------------------------------------
function Initialize_Build_Options()
	
	-- we need to know what (if anything) is built on this socket.
	local socket = Get_GUI_Variable("SocketObject")
	Set_GUI_Variable("BuildPadContents", socket.Get_Build_Pad_Contents())
	
	local build_options = {}
	local index_to_type_map = {}
	local indeces = {}
	local upgrades_list = socket.Get_Tactical_Hardpoint_Upgrades(true, false, true)

	-- Populate the list based in the order they elements are given in xml.
	for _, hp_type in pairs(upgrades_list) do
		local queue_index = hp_type.Get_Type_Value("Tactical_UI_Build_Queue_Order")
		
		if index_to_type_map[queue_index] == nil then 
			index_to_type_map[queue_index]  = {}
			table.insert(indeces, queue_index)
		end
		table.insert(index_to_type_map[queue_index], hp_type)
	end
	
	-- Sort the indeces in increasing order.
	table.sort(indeces)
	
	for i, q_idx in ipairs(indeces) do
		local types_list = index_to_type_map[q_idx]
		for _, hp_type in pairs(types_list) do
			table.insert(build_options, hp_type)
		end
	end
	
	Set_GUI_Variable("BuildOptions", build_options)
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Right_Click
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Right_Click(_, _)
	-- A right click on this menu translates into a right click onto the hard point reticle.
	this.Get_Containing_Scene().Raise_Event_Immediate("Buy_Menu_Right_Clicked", this.Get_Containing_Component(), nil)
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Build_Option_Button_Clicked - Start building this object onto the current socket (if possible)
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Build_Option_Button_Clicked(event, source)
	
	if source.Is_Selected() then 
		-- this button represents what's already built on the socket so do not do anything with this order
		return
	end
	
	-- RECALL: since button presses are handled by focused components, the disabled state will still get them 
	-- if the button has focus!.  Hence we have to filter them here.
	if not source.Is_Button_Enabled() then
		-- Play bad sound
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
		
		-- do nohing else
		return
	end
	
	local player = Get_GUI_Variable("Player")
	if player ~= Find_Player("local") then return end 
	local button_data = source.Get_User_Data()
	local build_type = button_data[1]
	
	-- if we have a valid socket and construction is allowed, go ahead and send the network event.
	local socket = Get_GUI_Variable("SocketObject")
	if TestValid(socket) and socket.Can_Build( build_type, true, true ) == true then 
	
		Send_GUI_Network_Event("Network_Build_Hard_Point", { socket, build_type, player})
		Play_SFX_Event("GUI_Generic_Button_Select")
		
		-- Now we close the radial menu.
		-- Close()
		-- we have to let the handler know that a HP configuration menu is open!
		-- Controller_Set_HP_Configuration_Menu_Active(false)		
		-- Reset ALL the reticles
		-- Raise_Event_All_Scenes("HP_Selection_Changed", nil)		
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Reset_Buttons
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Reset_Buttons()
	local build_buttons = Get_GUI_Variable("BuildOptionButtons")
	for _, button in pairs(build_buttons) do
		button.Set_Hidden(true)
		button.Enable(false)
		button.Set_Selected(false)
	end	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Deselect_Buttons
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Deselect_Buttons()
	local build_buttons = Get_GUI_Variable("BuildOptionButtons")
	for _, button in pairs(build_buttons) do
		button.Set_Selected(false)
	end	
end


-- -----------------------------------------------------------------------------------------------------
-- Refresh_Menu - we need to update the scene since
-- the state of the types in the list of build options for the sockets MAY have changed!
-- -----------------------------------------------------------------------------------------------------
function Refresh_Menu(event, source)
	if Get_GUI_Variable("Displaying") == true then
		Reset_Buttons()
		Setup_Scene(false)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Display_Menu()
	
	if not TestValid(Get_GUI_Variable("SocketObject")) then
		return
	end
	
	if TestValid(this.GamePadDesc) then 
		local it_has_it = true
		if not it_has_it then
			return
		end
	end
	Setup_Scene()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Scene 
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Scene()
	
	local player = Get_GUI_Variable("Player")
	if not player then return end
	
	local player_credits = player.Get_Credits()
	
	this.Enable(true)
	this.Set_Hidden(false)
	
	Set_GUI_Variable("Displaying", true)
	
	Reset_Buttons()
	
	local build_options = Get_GUI_Variable("BuildOptions")
	if not build_options then 
		Initialize_Build_Options()
		build_options = Get_GUI_Variable("BuildOptions")
	end
	
	-- if there's already something built on this socket, we must set the proper button as selected.
	-- Thus, clicks on the aforementioned button will be ignored.
	local build_pad_contents_type = nil
	local build_pad_contents_object = Get_GUI_Variable("BuildPadContents")
	if TestValid(build_pad_contents_object) then 
		build_pad_contents_type = build_pad_contents_object.Get_Type()
	end	
	
	local button_index = 1
	local build_option_buttons = Get_GUI_Variable("BuildOptionButtons")
	for _, buildable_type in pairs(build_options) do
				
		-- We don't want types locked from STORY to show up in the menu!!!!.
		if player.Is_Object_Type_Locked(buildable_type, STORY) == false then 
			if buildable_type ~= nil then 
			
				local button = build_option_buttons[button_index]
				if button then 
					button.Enable(true)
					button.Set_Hidden(false)

					local type_enabled = (player.Is_Object_Type_Locked(buildable_type) == false)
					-- store the type this button is linked to.
					button.Set_User_Data({buildable_type, type_enabled})
					
					button.Set_Texture(buildable_type.Get_Icon_Name())
					
					local build_cost = buildable_type.Get_Tactical_Build_Cost() 
						
					-- set up the tooltip data for this button.
					-- Tooltip data: tooltip mode, type, cost, build time, (warm up time, cooldown time for superweapom buttons)
					button.Set_Tooltip_Data({'type', {buildable_type, build_cost, buildable_type.Get_Tactical_Build_Time()}})
					
					button.Set_Insufficient_Funds_Display(build_cost > player_credits)
					
					if type_enabled then
						button.Set_Button_Enabled(true)
						button.Set_Cost(build_cost)
					else
						button.Set_Button_Enabled(false)					
					end

					if build_pad_contents_type == buildable_type then 
						button.Set_Selected(true)
					end
					
					-- advance the index for the buttons to display.
					button_index = button_index + 1	
				else
					break
				end
			end
		end
	end
end


-- -----------------------------------------------------------------------------------------------------
-- Close
-- -----------------------------------------------------------------------------------------------------
function Close()
	this.Set_Hidden(true)
	this.Enable(false)
	Reset_Buttons()
	Set_GUI_Variable("Displaying", false)

	-- reset the menu to enabled!
	Enable_Menu(true)
end


-- -----------------------------------------------------------------------------------------------------
-- Reset_Buttons
-- -----------------------------------------------------------------------------------------------------
function Reset_Buttons()
	local build_option_buttons = Get_GUI_Variable("BuildOptionButtons")
	for _, button in pairs(build_option_buttons) do
		button.Set_Hidden(true)
		button.Enable(false)
		button.Set_Button_Enabled(true)		
		button.Set_Selected(false)	
		button.Clear_Cost()
	end
end

-- -----------------------------------------------------------------------------------------------------
-- Is_Menu_Open
-- -----------------------------------------------------------------------------------------------------
function Is_Menu_Open()
	return Get_GUI_Variable("Displaying")
end

-- -----------------------------------------------------------------------------------------------------
-- Is_Menu_Enabled
-- -----------------------------------------------------------------------------------------------------
function Is_Menu_Enabled()
	return Get_GUI_Variable("Enabled")
end


-- -----------------------------------------------------------------------------------------------------
-- Enable_Menu
-- -----------------------------------------------------------------------------------------------------
function Enable_Menu(on_off)
	
	if Get_GUI_Variable("Enabled") == on_off then 
		-- do nothing
		return 
	end
	
	Set_GUI_Variable("Enabled", on_off)
	-- Go ahead and update the state of the menu
	local build_option_buttons = Get_GUI_Variable("BuildOptionButtons")
	if on_off then
		for _, button in pairs(build_option_buttons) do
			local button_data = button.Get_User_Data()
			if button_data then 
				local type_enabled = button_data[2]
				button.Set_Button_Enabled(type_enabled)
			end
		end		
	else	
		for _, button in pairs(build_option_buttons) do
			button.Set_Button_Enabled(false)
		end		
	end	
end

-- -----------------------------------------------------------------------------------------------------
-- Set_Focus
-- -----------------------------------------------------------------------------------------------------
function Set_Focus()
	this.Focus_First()
end

-- -----------------------------------------------------------------------------------------------------
-- Update_Buttons_Overlay
-- -----------------------------------------------------------------------------------------------------
function Update_Buttons_Overlay(uc_type)
	local build_option_buttons = Get_GUI_Variable("BuildOptionButtons")
	for _, button in pairs(build_option_buttons) do
		local button_data = button.Get_User_Data()
		if button_data then 
			if button_data[1] == uc_type then
				button.Use_X_Overlay(true)
			else
				button.Use_X_Overlay(false)
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Radial_Menu_Scene = Init_Radial_Menu_Scene
Interface.Close = Close
Interface.Reset_Selection = Reset_Selection
Interface.Is_Menu_Open = Is_Menu_Open
Interface.Is_Menu_Enabled = Is_Menu_Enabled
Interface.Display_Menu = Display_Menu
Interface.Enable_Menu = Enable_Menu
Interface.Set_Focus = Set_Focus
Interface.Update_Buttons_Overlay = Update_Buttons_Overlay
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Deselect_Buttons = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
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
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
