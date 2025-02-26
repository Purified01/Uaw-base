if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[109] = true
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
--              File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Prod_Structure_Menu.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/08/23
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	Menu = this.BuyMenu
	Menu.Set_Hidden(true)
	Menu.Set_Tab_Order(1)
	
	Queue = this.BuildQueue
	Queue.Init_Queue(1)
	--Queue.Set_Tab_Order(2)
	
	BuildingButton = this.Building
	BuildingButton.Enable(true)
	
	SelectedBuilding = nil
	UpdateTime = 0.0
	Owner = nil
	QueueType = nil
	
	-- We don't want to be comparing strings.  Until we remove the string queue type let's keep this map to do fast compares
	QueueTypeStrgToEnumValue = {}
	QueueTypeStrgToEnumValue['NonProduction'] = Declare_Enum(0)
	QueueTypeStrgToEnumValue['Command'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Infantry'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Vehicle'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Air'] = Declare_Enum()	
	
	this.Register_Event_Handler("Buy_Button_Clicked", Menu, On_Buy_Button_Click)
	this.Register_Event_Handler("Buy_Button_Controller_X_Button_Up", Menu, On_X_Button_Up)
	
	-- Refresh the menus once production is started or canceled
	this.Register_Event_Handler("Tactical_Enabler_Production_Started", nil, Force_Update_Menus)
	this.Register_Event_Handler("Tactical_Enabler_Production_Canceled", nil, Force_Update_Menus)	
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Force_Update_Menus
-- ------------------------------------------------------------------------------------------------------------------
function Force_Update_Menus(_, _, enabler)
	if TestValid(enabler) and enabler.Get_Owner() == Find_Player("local") then 
		if enabler == SelectedBuilding and IsOpen then
			Refresh_Menu()
		end	
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_X_Button_Up - We need to cancel the last build in the queue.
-- ------------------------------------------------------------------------------------------------------------------
function On_X_Button_Up(_, _)
	if not IsOpen then 
		MessageBox("This menu is not being displayed!")
		return
	end
	
	if TestValid(Queue) then 
		Queue.Process_X_Button_Up()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Buy_Button_Click - produce a unit from the selected building.
-- ------------------------------------------------------------------------------------------------------------------
function On_Buy_Button_Click(event, source, unit_type)
	if TestValid(SelectedBuilding) and unit_type then
		-- End sell mode!
		Raise_Event_Immediate_All_Scenes("End_Sell_Mode", {})
		
		local player = Find_Player("local")
		if SelectedBuilding.Tactical_Enabler_Can_Produce(unit_type, player, 1) == true then 
			Send_GUI_Network_Event("Networked_Build_Start", { SelectedBuilding, unit_type, player })			
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Display_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Display_Menu(on_off, building, bldg_qtype, special_abilities)
	if on_off then
		if not TestValid(building) or not QueueTypeStrgToEnumValue[bldg_qtype] then 
			return
		end
	end
	
	Menu.Set_Hidden(not on_off)
	BuildingButton.Set_Hidden(true)  --Always hide in single production menu
	if on_off then
		if building ~= SelectedBuilding then 
			-- clear the saved focus!
			Clear_Key_Focus(false)
		end
		
		SelectedBuilding = building
		Owner = SelectedBuilding.Get_Owner()
		QueueType = bldg_qtype
		
		-- Populate the build queue.
		Queue.Setup_Queue(SelectedBuilding) 
		
		Setup_Build_Menu(special_abilities)
		Setup_Building_Button(SelectedBuilding, BuildingButton, false)
	else
		-- reset the menus!.
		Menu.Populate_Buy_Menu()		
		Queue.Reset_Queue_Building()
	end	
	IsOpen = on_off
end


-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Build_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Build_Menu(special_abilities)
	
	local allowed_units
	if QueueTypeStrgToEnumValue[QueueType] ~= QueueTypeStrgToEnumValue['NonProduction'] then 
		allowed_units = SelectedBuilding.Get_Tactical_Enabler_Build_Menu(Owner)
	end
	
	if allowed_units == nil then 
		allowed_units = false
	end
	
	local structure_powered = true
	if Is_Player_Of_Faction(Owner, "NOVUS") == true then 
		structure_powered = (SelectedBuilding.Get_Attribute_Integer_Value( "Is_Powered" ) ~= 0.0)
	end
	
	-- there's no buy menu, so this call will reset it and leave it all ready for the
	-- upgrade and sell mode update!.	
	local is_upgrading = Menu.Populate_Buy_Menu(allowed_units, structure_powered, SelectedBuilding, GetCurrentTime(), special_abilities)
	return is_upgrading
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Open
-- ------------------------------------------------------------------------------------------------------------------
function Is_Open()
	return IsOpen
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Focus
-- ------------------------------------------------------------------------------------------------------------------
function Set_Focus()
	this.Focus_First()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update
-- ------------------------------------------------------------------------------------------------------------------
function Update(cur_time, special_abilities)
	if not IsOpen then
		return
	end
	
	if cur_time >= UpdateTime then
		
		local is_uprading = Refresh_Menu(special_abilities)
		
		if is_uprading then
			UpdateTime = cur_time + 0.1
		elseif IsOpen then
			UpdateTime = cur_time + 1.0
		end
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Refresh_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Refresh_Menu(special_abilities)
	local is_upgrading = false
	if TestValid(SelectedBuilding) then 
		-- Populate the build queue.
		Queue.Setup_Queue(SelectedBuilding) 
		-- Populate the buy and upgrades menus.
		is_upgrading = Setup_Build_Menu(special_abilities)
	end
	return is_upgrading
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Flashing_Unit_Button - 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Flashing_Unit_Button(unit_type)
	Menu.Set_Flashing_Unit_Button(unit_type)
	
	if IsOpen == true then 
		Refresh_Menu()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Stop_Flashing_Unit_Button 
-- ------------------------------------------------------------------------------------------------------------------
function Stop_Flashing_Unit_Button(unit_type)
	Menu.Stop_Flashing_Unit_Button(unit_type)

	if IsOpen == true then 
		Refresh_Menu()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Building_Button
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Building_Button(building, building_button, flash_building_button)
	building_button.Set_User_Data(building)
	building_button.Set_Hidden(true) -- always hidden in single production menu
	building_button.Enable(true)
	building_button.Set_Clock_Tint({0.0, 1.0, 0.0, 150.0/255.0})

	
	if building.Has_Behavior( 161 ) and building.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
		building_button.Set_Low_Power_Display(true)
	else
		building_button.Set_Low_Power_Display(false)
	end

	building_button.Set_Tooltip_Data({'object', {building}})
	
	-- is it building any upgrades?
	construction_type = building.Get_Building_Object_Type( true )
	if construction_type then 
		-- show timer
		building_button.Set_Clock_Filled(building.Get_Tactical_Build_Percent_Done( true ))
		texture_name = construction_type.Get_Icon_Name()
	else
		building_button.Set_Clock_Filled(0.0)			
		texture_name = building.Get_Structure_Icon_Name()
	end
	building_button.Set_Texture(texture_name)

	if flash_building_button then
		building_button.Start_Flash()
	else
		building_button.Stop_Flash()
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Display_Menu = Display_Menu
Interface.Is_Open = Is_Open
Interface.Set_Focus = Set_Focus
Interface.Update = Update
Interface.Set_Flashing_Unit_Button = Set_Flashing_Unit_Button
Interface.Stop_Flashing_Unit_Button = Stop_Flashing_Unit_Button

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
	Get_GUI_Variable = nil
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
