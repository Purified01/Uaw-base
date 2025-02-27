if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[109] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/Strategic_Upgrades_Purchase_Menu_Scene.lua
--
--           Author: Maria_Teruel 
--
--     	  DateTime: 2006/09/21 
--
--////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initializing the Scene
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	this.Register_Event_Handler("Controller_A_Button_Up", this.SocketButton, On_Socket_Button_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", this.SocketButton, On_Socket_Button_Right_Clicked)
	this.SocketButton.Set_Clock_Tint({0.0, 1.0, 0.0, 150.0/255.0})	
	this.SocketButton.Set_Tab_Order(0)
	
	local upgrade_buttons = Find_GUI_Components(this.UpgradesGroup, "UpgradeButton")
	Set_GUI_Variable("UpgradeButtons", upgrade_buttons)
	
	for index, button in pairs(upgrade_buttons) do
		button.Set_Hidden(true)
		button.Set_Tab_Order(index)
		
		this.Register_Event_Handler("Controller_A_Button_Up", button, On_Upgrade_Button_Clicked)
		this.Register_Event_Handler("Controller_X_Button_Up", button, On_Socket_Button_Right_Clicked)
	end
	
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Closing_All_Displays)

	Set_GUI_Variable("SetFocus", false)
	Set_GUI_Variable("UpdateMenuStartTime", nil)	
	this.Set_Animation_Frame(15.0)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Upgrade_Button_Clicked - select the chosen type
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Upgrade_Button_Clicked(event, source)

	local build_type = source.Get_User_Data()
	if not build_type then
		return
	end
	
	local success = true
	local local_player = Find_Player("local")
	
	if not TestValid(local_player) then
		return
	end
	
	-- Try to purchase the upgrade.
	local structure = Get_GUI_Variable("Structure")
	local region = structure.Get_Parent_Object()
	
	if structure.Get_Owner() ~= local_player then
		return
	end
	
	if not region.Has_Behavior(74) or region.Get_Owner() ~= local_player then
		MessageBox("The structure %s has an invalid parent object:  %s", tostring(structure), tostring(region))
		return
	end
	
	local socket_index = Get_GUI_Variable("SocketIndex")
	Send_GUI_Network_Event("Network_Global_Begin_Production", { local_player, region, build_type, structure, socket_index })
	Set_GUI_Variable("UpdateMenuStartTime", GetCurrentTime())			
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Socket_Button_Clicked - 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Socket_Button_Clicked()
	local local_player = Find_Player("local")
	local structure = Get_GUI_Variable("Structure")
	if structure.Get_Owner() ~= local_player then
		return
	end

	if this.Get_Current_State_Name() == "Open" then
		this.Set_State("Closed")
	elseif Get_GUI_Variable("Structure") then
		this.Set_State("Open")
		Set_GUI_Variable("SetFocus", true)
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("Upgrade_Menu_Opened", this.Get_Containing_Component(), nil)
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Socket_Button_Right_Clicked - We want to cancel construction underway at this spot (if any)
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Socket_Button_Right_Clicked(event, source)
	local hard_point = Get_GUI_Variable("HardPoint")
	if TestValid(hard_point) then
		Send_GUI_Network_Event("Network_Global_Cancel_Production", {hard_point})
		Set_GUI_Variable("UpdateMenuStartTime", GetCurrentTime())	
	end	
end


-- -----------------------------------------------------------------------------------------------------
-- Update_Open
-- -----------------------------------------------------------------------------------------------------
function Update_Open()
	if Get_GUI_Variable("UpdateMenuStartTime") and GetCurrentTime() - Get_GUI_Variable("UpdateMenuStartTime") > 1.0/30.0 then
		this.Get_Containing_Scene().Raise_Event("Update_Global_Upgrades_Menu", this.Get_Containing_Component(), {Get_GUI_Variable("Structure")})
		Set_GUI_Variable("UpdateMenuStartTime", nil)
		return
	end
	
	Setup_Socket_Button()
	Setup_Upgrade_Buttons()
end


-- -----------------------------------------------------------------------------------------------------
-- Update_Closed
-- -----------------------------------------------------------------------------------------------------
function Update_Closed()
	if Get_GUI_Variable("UpdateMenuStartTime") and GetCurrentTime() - Get_GUI_Variable("UpdateMenuStartTime") > 1.0/30.0 then
		this.Get_Containing_Scene().Raise_Event("Update_Global_Upgrades_Menu", this.Get_Containing_Component(), {Get_GUI_Variable("Structure")})
		Set_GUI_Variable("UpdateMenuStartTime", nil)
		return
	end	
	Setup_Socket_Button()	
end

-- -----------------------------------------------------------------------------------------------------
-- Setup_Upgrade_Buttons
-- -----------------------------------------------------------------------------------------------------
function Setup_Upgrade_Buttons()

	local structure = Get_GUI_Variable("Structure")
	if not TestValid(structure) then
		Close()
		return
	end

	local upgrade_buttons = Get_GUI_Variable("UpgradeButtons")
	local upgrades_list = structure.Get_Available_Strategic_Buildable_Upgrades(Get_GUI_Variable("SocketIndex"))
	if not upgrades_list then
		for _, button in pairs(upgrade_buttons) do
			button.Set_Hidden(true)
		end	
		return
	end
	
	local button_index = 1
	local player_credits = Find_Player("local").Get_Credits()
	for _, type_info in pairs(upgrades_list) do
		local button = upgrade_buttons[button_index]
		if button then
			local upgrade_type = type_info[1]
			button.Set_User_Data(upgrade_type)
			button.Set_Texture(upgrade_type.Get_Icon_Name())
			button.Set_Hidden(false)
			
			if type_info[2] then
				button.Set_Button_Enabled(true)
				local build_cost = upgrade_type.Get_Type_Value("Build_Cost_Credits")
				button.Set_Cost(build_cost)
				button.Set_Insufficient_Funds_Display(build_cost > player_credits)
				button.Set_Tooltip_Data({"type", {upgrade_type, build_cost, upgrade_type.Get_Type_Value("Build_Time_Seconds")}})	
			else
				button.Set_Button_Enabled(false)
				button.Clear_Cost()
				
				local lock_reason = nil
				if type_info[3] then
					lock_reason = Get_Game_Text("TEXT_ONLY_ONE_UPGRADE_ALLOWED")
				end
				button.Set_Tooltip_Data({"type", {upgrade_type, upgrade_type.Get_Type_Value("Build_Cost_Credits"), upgrade_type.Get_Type_Value("Build_Time_Seconds"), false, false, false, false, false, false, false, false, lock_reason}})
			end
			
			button_index = button_index + 1
		end
	end
	
	if Get_GUI_Variable("SetFocus") then
		if button_index > 1 then
			local button = upgrade_buttons[1]
			button.Set_Key_Focus()
		end
		Set_GUI_Variable("SetFocus", false)
	end
	
	for i = button_index, #upgrade_buttons do
		upgrade_buttons[i].Set_Hidden(true)
	end	
end


-- -----------------------------------------------------------------------------------------------------
-- Setup_Socket_Button
-- -----------------------------------------------------------------------------------------------------
function Setup_Socket_Button()
	local hard_point = Get_GUI_Variable("HardPoint")
	if not TestValid(hard_point) then
		return
	end
	
	local type = hard_point.Get_Type()
	local time_to_completion = 0.0
	if hard_point.Has_Behavior(166) then
		time_to_completion = hard_point.Get_Strategic_Build_Completion_Time()
		local time_in_seconds = time_to_completion * type.Get_Type_Value("Build_Time_Seconds")
		local tooltip_text = type.Get_Display_Name()
		tooltip_text.append(Create_Wide_String("\n"))
		tooltip_text.append(Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), Get_Localized_Formatted_Number.Get_Time(time_in_seconds), 0))
		this.SocketButton.Set_Tooltip_Data({"custom", tooltip_text})
	else
		this.SocketButton.Set_Tooltip_Data({"object", {hard_point}})
		
	end
	
	this.SocketButton.Set_User_Data(type)
	this.SocketButton.Set_Texture(type.Get_Icon_Name())
	this.SocketButton.Set_Clock_Filled(time_to_completion)
	this.SocketButton.Set_Hidden(false)	
end


-- -----------------------------------------------------------------------------------------------------
-- On_Closing_All_Displays
-- -----------------------------------------------------------------------------------------------------
function On_Closing_All_Displays()
	this.Set_State("Closed")
end

-- -----------------------------------------------------------------------------------------------------
-- Close
-- -----------------------------------------------------------------------------------------------------
function Close()
	this.Set_State("Closed")
end

-- -----------------------------------------------------------------------------------------------------
-- Set_Hard_Point
-- -----------------------------------------------------------------------------------------------------
function Set_Hard_Point(hard_point)
	Set_GUI_Variable("HardPoint", hard_point)
	
	if not TestValid(hard_point) then
		Set_GUI_Variable("SocketIndex", nil)
		Set_GUI_Variable("Structure", nil)
		return
	end
	
	local structure = hard_point.Get_Parent_Object()
	
	Set_GUI_Variable("SocketIndex", hard_point.Get_Strategic_Socket_Index())
	Set_GUI_Variable("Structure", structure)	
end

-- -----------------------------------------------------------------------------------------------------
-- INTERFACE
-- -----------------------------------------------------------------------------------------------------
Interface = {}
Interface.Close = Close
Interface.Set_Hard_Point = Set_Hard_Point
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
