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
	for index, button in pairs(build_buttons) do
		button.Set_Hidden(true)
		button.Enable(false)
		button.Set_Tab_Order(MENU_OPTIONS_TAB_ORDER + index)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Option_Button_Clicked)
	end
	
	this.Register_Event_Handler("Type_Lock_State_Changed", nil, Refresh_Menu)
	this.Register_Event_Handler("Player_Credits_Changed", nil, Refresh_Menu)
	
	Set_GUI_Variable("SocketObject", object)
	Set_GUI_Variable("Player", object.Get_Owner())
	Set_GUI_Variable("TypeSelected", nil)
	Set_GUI_Variable("Displaying", false)
end

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
-- On_Build_Option_Button_Clicked - Start building this object onto the current socket (if possible)
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Build_Option_Button_Clicked(event, source)
	
	if source.Is_Selected() == true then 
		-- this button represents what's already built on the socket so do not do anything with this order
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
		Close()
		
		-- Reset ALL the reticles
		Raise_Event_Immediate_All_Scenes("HP_Selection_Changed", nil)		
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
-- Owner_Changed
-- -----------------------------------------------------------------------------------------------------
function Owner_Changed()
	local socket_object = Get_GUI_Variable("SocketObject")
	if TestValid(socket_object) then
		Set_GUI_Variable("Player", socket_object.Get_Owner())
		if Get_GUI_Variable("Displaying") then 
			-- Upate the menu for the type locks may have changed.
			Setup_Scene()
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
Interface.Owner_Changed = Owner_Changed
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
