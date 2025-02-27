if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Command_Center_Scene_Build_Menu.lua 
--
--            Author: Maria Teruel
--
--          DateTime: 2007/09/24
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
	
	-- Command Center build buttons
	local build_buttons = Find_GUI_Components(this, "BuildButton")
	Set_GUI_Variable("BuildMenuButtons", build_buttons)
	
	BUTTONS_TAB_ORDER = Declare_Enum(0)
	for i, button in pairs(build_buttons) do
	     this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Button_Clicked)
	     button.Set_Clock_Filled(0.0)
	     button.Set_Tab_Order(BUTTONS_TAB_ORDER + i)
	end
	
	this.Register_Event_Handler("Faction_Changed", nil, On_Faction_Changed)	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Faction_Changed - make sure we hide all open scenes!
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Faction_Changed(event, source)
	this.Set_State("Closed")
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- One of the buttons to build a command center was clicked
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Build_Button_Clicked(event_name, source)

	if not TestValid(Object) then 
		MessageBox("NO OBJECT")
		return
	end
	
	local cc_type = source.Get_User_Data()	
	Send_GUI_Network_Event("Network_Global_Begin_Production", {Find_Player("local"), Object, cc_type})
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Display_Build_Menu
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Display_Build_Menu(display_hide, region_object)
	-- We need to display the menu, so we need to update its contents
	if display_hide then
		if not TestValid(region_object) then
			return
		end
	
		this.Set_State("Open")
		Object = region_object		
	else
		this.Set_State("Closed")
		Object = nil
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Command_Center_List
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Command_Center_List()
	
	if not TestValid(Object) then 
		return
	end
	
	local local_player = Find_Player("local") 
	local cc_list = local_player.Get_Command_Center_Types(Object)
	
	if cc_list == nil or table.getn(cc_list) <= 0 then
		MessageBox("The list of command center types is not valid!")
		return
	end
	
	--queue_index = cc_list[i][4]
	cc_list = Sort_Array_Of_Maps(cc_list, 4)
	
	local build_buttons = Get_GUI_Variable("BuildMenuButtons")
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
-- On_Update
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	
	-- If we owe the region and there is no command center then we need to display the Command Center scene so the 
	-- player can build a CC.
	if Object == nil then
		return
	end
	
	-- update the list! since there may have been changes that need to be reflected in the list
	Update_Command_Center_List()	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Is_Open
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Is_Open()
	return (Object ~= nil)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Focus
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Focus()
	this.Focus_First()
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Display_Build_Menu = Display_Build_Menu
Interface.Is_Open = Is_Open
Interface.Set_Focus = Set_Focus
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
