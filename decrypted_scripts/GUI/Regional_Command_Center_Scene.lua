if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[43] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Regional_Command_Center_Scene.lua 
--
--            Author: Maria Teruel
--
--          DateTime: 2006/05/31 
--
--	NOTE: Adpapted from RegionLabel.lua!
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Mouse")
require("Global_Icons")
require("PGUICommands")
	
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	
	Reset_Scene()
	
	-- Command Center button
	this.Register_Event_Handler("Selectable_Icon_Clicked", Regional_Command_Center_Scene.CommandCenterIcon, On_Command_Center_Icon_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Right_Clicked", Regional_Command_Center_Scene.CommandCenterIcon, On_Request_Cancel_Command_Center_Construction)
	this.CommandCenterIcon.Set_Tab_Order(Declare_Enum(0))
	
	-- Command Center build buttons
	local build_buttons = Find_GUI_Components(Regional_Command_Center_Scene.Menu, "BuildButton")
	Set_GUI_Variable("CommandCenterBuildButtons", build_buttons)
	
	for i, button in pairs(build_buttons) do
	     this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Button_Clicked)
	     button.Set_Tab_Order(Declare_Enum())
	end

	this.Register_Event_Handler("Faction_Changed", nil, On_Faction_Changed)
	
	if TestValid(Object) then 
		Object.Register_Signal_Handler(On_CC_Construction_Canceled, "COMMAND_CENTER_CONSTRUCTION_CANCELED", this)
		Object.Register_Signal_Handler(On_Region_Owner_Changed, "OBJECT_OWNER_CHANGED", this)
		
		--Since we're listening on signals with a shared script we must hold a ref to the object wrapper
		--so it doesn't get garbage collected while another scene instance is using the script.  Ugh.
		Set_GUI_Variable("Object", Object)
	end
		
	this.Register_Event_Handler("Close_All_Active_Displays", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Mouse_Non_Client_Right_Up", this, On_Closing_All_Displays)
	this.Register_Event_Handler("Mouse_Non_Client_Left_Up", this, On_Closing_All_Displays)	
	this.Register_Event_Handler("Request_Toggle_Build_Menu", nil, On_Command_Center_Icon_Clicked)
	this.Register_Event_Handler("Global_Spy_Level_Changed", nil, On_Spy_Level_Changed)
	
	this.RegionName.Set_Text(Object.Get_Type().Get_Type_Value("Text_ID"))
	
	local upgrade_menus = Find_GUI_Components(this.UpgradesGroup, "UpgradeMenu")
	for _, menu in pairs(upgrade_menus) do
		this.Register_Event_Handler("Upgrade_Menu_Opened", menu, On_Upgrade_Menu_Opened)
	end
	Set_GUI_Variable("UpgradeMenus", upgrade_menus)
	
	--This applies to all scenes, so no need to use Set_GUI_Variable
	LocalPlayer = Find_Player("local")
	On_Region_Owner_Changed()
end



-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Faction_Changed - make sure we hide all open scenes!
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Faction_Changed(event, source)
	LocalPlayer = Find_Player("local")
	On_Region_Owner_Changed()
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- One of the buttons to build a command center was clicked
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Build_Button_Clicked(event_name, source)
	local cc_type = source.Get_User_Data()
	Send_GUI_Network_Event("Network_Global_Begin_Production", {Find_Player("local"), Object, cc_type})
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_CC_Construction_Canceled
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_CC_Construction_Canceled(region)
	Reset_Scene()
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Reset_Scene
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Reset_Scene()
	this.CommandCenterIcon.Set_Texture("i_button_uea_cc_region_build.tga")
	this.CommandCenterIcon.Set_Clock_Filled(0.0)
--	this.CommandCenterIcon.Set_Clockwise(false)
	this.Menu.Set_Hidden(true)
	this.UpgradesGroup.Set_Hidden(true)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Show command centers to build at this region (if we are allowed to build any)
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Command_Center_Icon_Clicked()
	if this.Menu.Get_Hidden() == false then
		this.Menu.Set_Hidden(true)
	else
		Update_Command_Center_List()
	end
end



-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Command_Center_List
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Command_Center_List()
	
	local local_player = Find_Player("local") 
	local cc_list = local_player.Get_Command_Center_Types(Object)
	
	if cc_list == nil or table.getn(cc_list) <= 0 then
		MessageBox("The list of command center types is not valid!")
		return
	end
	
	--queue_index = cc_list[i][4]
	cc_list = Sort_Array_Of_Maps(cc_list, 4)
	
	this.Menu.Set_Hidden(false)
	this.Set_Sort_To_Front(true)
	
	local build_buttons = Get_GUI_Variable("CommandCenterBuildButtons")
	if table.getn(build_buttons) < table.getn(cc_list) then
		MessageBox("There are more cc types than cc buttons in the scene!. Aborting.")
		return
	end
	
	--There are a couple of special reasons why a command center may not be buildable that
	--we'll look for here so as to more easily expose the reason why in the tooltip.
	local lock_existing = false
	local lock_reason = false
	local existing_command_center = Object.Get_Command_Center()
	if TestValid(existing_command_center) then
		if existing_command_center.Get_Type() == local_player.Get_Faction_Value("Headquarters_Type") then
			lock_existing = true
			lock_reason = Get_Game_Text("TEXT_CANT_REPLACE_HQ")
		elseif existing_command_center.Get_Type().Get_Type_Value("Enables_Research") then
			local points_data = local_player.Get_Script().Get_Async_Data("CachedPointsDataForGUI")
			if points_data[0] >= points_data[1] then
				lock_existing = true
				lock_reason = Get_Game_Text("TEXT_REQUIRES_UNDO_RESEARCH")
			end
		end
	end	
	
	local button_index = 1
	for i = 1, table.getn(cc_list) do 
		local cc_type_info = cc_list[i]
		
		-- NOTE: 
		-- cc_type_info[1] = type
		-- cc_type_info[2] = can produce
		-- cc_type_info[3] = enough credits
		local cc_type = cc_type_info[1]
		local button = build_buttons[button_index]
		local can_produce = cc_type_info[2]
		local enough_credits = cc_type_info[3]
		if lock_existing then
			can_produce = false
		end
		
		if cc_type and cc_type.Get_Type_Value("Is_Strategic_Buildable_Type") and button then 
			button.Set_Hidden(false)
			-- Reset button state
			button.Set_Button_Enabled(true)
			button.Clear_Cost()
			button.Set_Insufficient_Funds_Display(false)
			
			-- Initialize the button with the data
			button.Set_User_Data(cc_type)
			button.Set_Texture(cc_type.Get_Icon_Name())			
			
			if can_produce == false then 
				-- disable the button
				button.Set_Button_Enabled(can_produce)				
			elseif not enough_credits then 
				-- the button should display a redish border and the cost should be displayed in red.
				button.Set_Insufficient_Funds_Display(true)
			end	

			local build_cost = cc_type.Get_Build_Cost()
			if can_produce then 
				button.Set_Cost(build_cost)
			end
			
			--All the falses are for filling in entries expected by the tooltip.  Ugh
			button.Set_Tooltip_Data({'type', {cc_type, build_cost, cc_type.Get_Type_Value("Build_Time_Seconds"), false, false, false, false, false, false, false, false, lock_reason}})
			
			button_index = button_index + 1
		end		
	end
	
	for i = button_index, #build_buttons do
		build_buttons[i].Set_Hidden(true)
	end
end



-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Request_Cancel_Command_Center_Construction
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Request_Cancel_Command_Center_Construction(event, source)
	Send_GUI_Network_Event("Network_Global_Cancel_Production", {Object})
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Command_Center_Icon
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Command_Center_Icon(has_command_center, cc_under_construction)
	local ccQuad = this.CommandCenterIcon
	
	local percent = 0
	if has_command_center then
		Hide_Empty_CC_Icon(true)
		Hide_Upgrade_Panel(false)
		return
	elseif cc_under_construction then
		-- Command center in progress
		local cc_type = Object.Get_Command_Center_Under_Construction_Type()
		local command_center_icon_name = cc_type.Get_Icon_Name()
		ccQuad.Set_Texture(command_center_icon_name)
		percent = Object.Get_Command_Center_Percent_Complete()
		
		local time_in_seconds = (1.0 - percent) * cc_type.Get_Type_Value("Build_Time_Seconds")
		local tooltip_text = cc_type.Get_Display_Name()
		tooltip_text.append(Create_Wide_String("\n"))
		tooltip_text.append(Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), Get_Localized_Formatted_Number.Get_Time(time_in_seconds), 0))
		ccQuad.Set_Tooltip_Data({"custom", tooltip_text})	
				
		percent = percent * 100.0
		percent = Dirty_Floor(percent)
	end
	
	this.CommandCenterIcon.Set_Percentage(percent)	
	
	Hide_Empty_CC_Icon(false)
	Hide_Upgrade_Panel(true)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Update
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	
	-- If we owe the region and there is no command center then we need to display the Command Center scene so the 
	-- player can build a CC.
	if Object == nil then
		return
	end
	
	local has_command_center = Object.Has_Command_Center()
	local cc_under_construction = Object.Is_Command_Center_Under_Construction()

	if cc_under_construction == true then
		-- Stop the clock!
		this.CommandCenterIcon.Set_Clock_Filled(0.0)
	elseif has_command_center then
		Hide_Empty_CC_Icon(true)
	end
	
	Update_Command_Center_Icon(has_command_center, cc_under_construction)
	
	local fade_upgrades = Zoom_Camera.Get_Current() - 0.6
	fade_upgrades = fade_upgrades / 0.1
	if fade_upgrades < 0.0 then
		fade_upgrades = 0.0
	elseif fade_upgrades > 1.0 then
		fade_upgrades = 1.0
	end
	
	local r,g,b = this.UpgradesGroup.Get_Tint()
	this.UpgradesGroup.Set_Tint(r, g, b, fade_upgrades)	
	
	if Regional_Command_Center_Scene.Menu.Get_Hidden() == false then
		-- update the list! since there may have been changes that need to be reflected in the list
		Update_Command_Center_List()
		Hide_Upgrade_Panel(true)
	elseif has_command_center then
		Hide_Upgrade_Panel(fade_upgrades <= 0.0)
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Hide_Scene
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Hide_All_Build_Options(hide)
	if hide and this.CommandCenterIcon.Get_Hidden() == hide then
		return
	end

	this.CommandCenterIcon.Set_Hidden(hide)
	if hide then
		this.Menu.Set_Hidden(hide)
		this.CommandCenterIcon.Set_Clock_Filled(0.0)
		this.CommandCenterIcon.Set_Percentage(0.0)
	end
end

function Hide_Empty_CC_Icon(hide)
	this.CommandCenterIcon.Set_Hidden(hide)	
end

function Hide_Upgrade_Panel(hide)
	if hide and this.UpgradesGroup.Get_Hidden() == hide then
		return
	end
	
	this.UpgradesGroup.Set_Hidden(hide)
	local menus = Get_GUI_Variable("UpgradeMenus")
	if hide then
		for _, menu in pairs(menus) do
			menu.Close()
		end
		this.Set_Sort_To_Front(not this.Menu.Get_Hidden())
	else
		local menus = Get_GUI_Variable("UpgradeMenus")
		local upgrades = Object.Get_Command_Center().Get_Strategic_Structure_Socket_Upgrades()
		if not upgrades then
			this.UpgradesGroup.Set_Hidden(true)
			return
		end
		for i, menu in pairs(menus) do
			menu.Set_Hard_Point(upgrades[i])
		end	
	end
end

function On_Upgrade_Menu_Opened(_, source)
	local menus = Get_GUI_Variable("UpgradeMenus")
	for _, menu in pairs(menus) do
		if menu ~= source then
			menu.Close()
		end
	end
	this.Menu.Set_Hidden(true)
	this.Set_Sort_To_Front(true)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Closing_All_Displays
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Closing_All_Displays()
	this.Menu.Set_Hidden(true)	
	this.Set_Sort_To_Front(false)
end

function On_Region_Owner_Changed()
	if Object.Get_Owner() == LocalPlayer then
		this.Set_State("Default")
	else
		this.Set_State("Sleeping")
		Hide_All_Build_Options(true)	
			
		On_Spy_Level_Changed()
	end
end

function On_Spy_Level_Changed()
	if Object.Get_Owner() == LocalPlayer then
		return
	end

	if Object.Get_Strategic_FOW_Level(LocalPlayer) > 0 and Object.Has_Command_Center() then
		this.Set_State("Default")
		Hide_Upgrade_Panel(false)
	else
		this.Set_State("Sleeping")
		Hide_Upgrade_Panel(true)
	end
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Faction_Icon_Name = nil
	Get_Fleet_Icon_Name = nil
	Init_Mouse_Buttons = nil
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
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Mouse_Buttons = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
