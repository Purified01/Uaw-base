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
	local upgrade_buttons = Find_GUI_Components(this.UpgradesGroup, "UpgradeButton")
	Set_GUI_Variable("UpgradeButtons", upgrade_buttons)
	
	for _, button in pairs(upgrade_buttons) do
		button.Set_Hidden(true)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Upgrade_Button_Clicked)
	end
	
	this.Register_Event_Handler("Selectable_Icon_Clicked", this.SocketButton, On_Socket_Button_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Right_Clicked", this.SocketButton, On_Socket_Button_Right_Clicked)
	
	this.Register_Event_Handler("Close_All_Active_Displays", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Mouse_Non_Client_Right_Up", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Mouse_Non_Client_Right_Down", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Mouse_Non_Client_Left_Down", nil, On_Closing_All_Displays)
		
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
	
	if not region.Has_Behavior(BEHAVIOR_REGION) or region.Get_Owner() ~= local_player then
		MessageBox("The structure %s has an invalid parent object:  %s", tostring(structure), tostring(region))
		return
	end
	
	local socket_index = Get_GUI_Variable("SocketIndex")
	success = Global_Begin_Production(local_player, region, build_type, structure, socket_index)
	
	-- Play a sound.
	if success then
		Play_SFX_Event("GUI_Generic_Button_Select")
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end
	
end

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
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("Upgrade_Menu_Opened", this.Get_Containing_Component(), nil)
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Socket_Button_Right_Clicked - We want to cancel construction underway at this spot (if any)
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Socket_Button_Right_Clicked(event, source)
	local hard_point = Get_GUI_Variable("HardPoint")
	local unit_script = hard_point.Get_Script()
	if TestValid(unit_script) then
		Cancel_Production_At_Location_Of_Unit(unit_script.Call_Function("Get_Build_Location"), unit_script.Call_Function("Get_Queue_ID"), unit_script.Call_Function("Get_Build_ID"))
	end
end

-- -----------------------------------------------------------------------------------------------------
-- Update_Open
-- -----------------------------------------------------------------------------------------------------
function Update_Open()	
	Setup_Socket_Button()
	Setup_Upgrade_Buttons()
end

function Update_Closed()
	Setup_Socket_Button()	
end

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
				button.Set_Enabled(true)
				local build_cost = upgrade_type.Get_Type_Value("Build_Cost_Credits")
				button.Set_Cost(build_cost)
				button.Set_Insufficient_Funds_Display(build_cost > player_credits)
				button.Set_Tooltip_Data({"type", {upgrade_type, build_cost, upgrade_type.Get_Type_Value("Build_Time_Seconds")}})	
			else
				button.Set_Enabled(false)
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
	
	for i = button_index, #upgrade_buttons do
		upgrade_buttons[i].Set_Hidden(true)
	end	
end

function Setup_Socket_Button()
	local hard_point = Get_GUI_Variable("HardPoint")
	if not TestValid(hard_point) then
		return
	end
	
	local type = hard_point.Get_Type()
	local time_to_completion = 0.0
	if type == Get_GUI_Variable("InProductionType") then
		local script = hard_point.Get_Script()
		if script then
			type = script.Call_Function("Get_Unit_Type")
			time_to_completion = script.Call_Function("Get_Completion_Time")
		end
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

function On_Closing_All_Displays()
	this.Set_State("Closed")
end

function Close()
	this.Set_State("Closed")
end

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
	
	local in_production_type = structure.Get_Type().Get_Type_Value("In_Production_Upgrade_Socket_Type")
	Set_GUI_Variable("InProductionType", in_production_type)	
	
	--if hard_point.Get_Type() == in_production_type then
	--	this.Set_State("Open")
	--end	
end

Interface = {}
Interface.Close = Close
Interface.Set_Hard_Point = Set_Hard_Point