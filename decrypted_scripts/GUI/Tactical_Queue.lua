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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tactical_Queue.lua
--
--    Original Author: Chris_Brooks
--
--          DateTime: 2006/11/29 16:55:44 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- On_Init - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Queue(queue_index)

	local queue = {}
	BuildingButton = Scene.Building
	-- the tint for the clock is green.
	BuildingButton.Set_Clock_Tint({0.0, 1.0, 0.0, 150.0/255.0})
	UnitButtons = Find_GUI_Components(Scene, "Unit")
	
	BuildingButton.Set_Tab_Order(0)
	for i, unit_button in pairs(UnitButtons) do
		Scene.Register_Event_Handler("Selectable_Icon_Right_Clicked", unit_button, On_Unit_Right_Click)
		--Register on double click too since these will come through (with no click) when the user clicks fast.		
		Scene.Register_Event_Handler("Selectable_Icon_Right_Double_Clicked", unit_button, On_Unit_Right_Click)
		
		-- we need this button to have a non-negative tab order so that we can navigate the buy menu with the game controller and/or
		-- the keyboard!.
		unit_button.Set_Tab_Order(i)	
		
		-- the timers are progress timers so they should be green.
		unit_button.Set_Clock_Tint({0.0, 1.0, 0.0, 110.0/255.0})		
	end
	
	BuildingButton.Set_User_Data(queue_index) -- building button user data is index of its queue
	
	-- we need this button to have a non-negative tab order so that we can navigate the buy menu with the game controller and/or
	-- the keyboard!.
	
	Scene.Register_Event_Handler("Selectable_Icon_Clicked", BuildingButton, On_Building_Button_Click)
	Scene.Register_Event_Handler("Selectable_Icon_Double_Clicked", BuildingButton, On_Building_Button_Double_Click)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Unit_Right_Click - cancel production of the unit
-- ------------------------------------------------------------------------------------------------------------------
function On_Unit_Right_Click(event, source)
	DebugMessage("On_Unit_Right_Click")
	local user_data = source.Get_User_Data()
	local building = user_data[1]
	local build_id = user_data[2]
	local obj_type = user_data[3]
	
	if TestValid(building) then
		Send_GUI_Network_Event("Networked_Cancel_Build", { building, obj_type, build_id, 1, Find_Player("local") })
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Queue_Building - 
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Queue_Building()
	QueueBuilding = nil
	Scene.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Queue - 
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Queue()
	Scene.Set_Hidden(true)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Hotkey_Activate_Queue
-- ------------------------------------------------------------------------------------------------------------------
function Hotkey_Activate_Queue(is_double_key_press)

	if not is_double_key_press then -- mimic single click
		Select_Builing(QueueBuilding)
	else	-- mimic double click
		Point_Camera_At_Building(QueueBuilding)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Select_Builing
-- ------------------------------------------------------------------------------------------------------------------
function Select_Builing(building)
	if not building then return end
	Set_Selected_Objects( {building} )
	Raise_Event_Immediate_All_Scenes("Queue_Building_Button_Clicked", {building})
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Building_Button_Click - select the building
-- ------------------------------------------------------------------------------------------------------------------
function On_Building_Button_Click(event, source)
	Select_Builing(source.Get_User_Data())	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Point_Camera_At_Building
-- ------------------------------------------------------------------------------------------------------------------
function Point_Camera_At_Building(building)
	if not building then return end
	--Set_Selected_Objects( {building} )
	Point_Camera_At(building)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Building_Button_Double_Click - select and center camera on building
-- ------------------------------------------------------------------------------------------------------------------
function On_Building_Button_Double_Click(event, source)
	Point_Camera_At_Building(source.Get_User_Data())	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Building_Button_Texture_And_Clock - 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Building_Button_Texture_And_Clock()
	-- first let's get the building assigned to this guy
	local building = BuildingButton.Get_User_Data()
	if TestValid(building) then
		-- is it building any upgrades?
		construction_type = building.Get_Building_Object_Type( true )
		if construction_type then 
			-- show timer
			BuildingButton.Set_Clock_Filled(building.Get_Tactical_Build_Percent_Done( true ))
			texture_name = construction_type.Get_Icon_Name()
		else
			BuildingButton.Set_Clock_Filled(0.0)			
			texture_name = building.Get_Structure_Icon_Name()
		end
		BuildingButton.Set_Texture(texture_name)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Queue - 
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Queue(building, flash_all_building_button)

	local is_building = false
	QueueBuilding = building
	Scene.Set_Hidden(false)
	BuildingButton.Set_User_Data(building)
	
	local player = Find_Player("local")
	if building.Has_Behavior( BEHAVIOR_POWERED ) and building.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
		BuildingButton.Set_Low_Power_Display(true)
	else
		BuildingButton.Set_Low_Power_Display(false)
	end
	
	Set_Building_Button_Texture_And_Clock()
	
	BuildingButton.Set_Tooltip_Data({'object', {building}})
	
	-- Go through the objects under construction in this queue, and assign them to buttons.
	local build_queue = building.Tactical_Enabler_Get_Queued_Objects()
	if not build_queue then build_queue = {} end
	
	local button_index = 1
	local button_count = table.getn(UnitButtons)
	if build_queue then
		-- we have a cue, update more often
		is_building = true
		for i, build_info in pairs(build_queue) do
			local button = UnitButtons[button_index]
			
			-- Show/hide, texture
			button.Set_Hidden(false)
			button.Set_Texture(build_info.Type.Get_Icon_Name())
						
			-- Clock
			button.Set_Clock_Filled( build_info.Percent_Complete )

			-- Text (quantity)
			if build_info.Quantity > 1 then
				button.Set_Text(Get_Localized_Formatted_Number(build_info.Quantity))
			else
				button.Set_Text("")
			end
	
			-- Set user data to point to build id.
			button.Set_User_Data({building, build_info.Build_ID, build_info.Type})
			
			-- Next button, please.
			button_index = button_index + 1
			if button_index > button_count then
				break
			end
		end
	end
	
	-- Hide any remaining buttons.
	if button_index <= button_count then
		for i=button_index, button_count do
			local button = UnitButtons[i]
			button.Set_Hidden(true)
		end
	end
	
	if flash_all_building_button then
		BuildingButton.Start_Flash()
	else
		BuildingButton.Stop_Flash()
	end	
	
	return is_building
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Get_Queue_Building
-- ------------------------------------------------------------------------------------------------------------------
function Get_Queue_Building()
	local test = BuildingButton.Get_User_Data()
	return QueueBuilding
end


-- ------------------------------------------------------------------------------------------------------------------
-- Building_Button_Is_Hidden
-- ------------------------------------------------------------------------------------------------------------------
function Building_Button_Is_Hidden()
	return Scene.Get_Hidden()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Get_Building_Button_Position
-- ------------------------------------------------------------------------------------------------------------------
function Get_Building_Button_Position()
	local posx, posy = Scene.Building.Get_Screen_Position()
	return {posx, posy}
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Building_Button_Selected
-- ------------------------------------------------------------------------------------------------------------------
function Set_Building_Button_Selected(onoff)
	BuildingButton.Set_Selected(onoff)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Building_Button_Focus
-- ------------------------------------------------------------------------------------------------------------------
function Set_Building_Button_Focus()
	BuildingButton.Set_Key_Focus()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Queue = Init_Queue
Interface.Hide_Queue = Hide_Queue
Interface.Setup_Queue = Setup_Queue
Interface.Get_Queue_Building = Get_Queue_Building
Interface.Building_Button_Is_Hidden = Building_Button_Is_Hidden
Interface.Get_Building_Button_Position = Get_Building_Button_Position
Interface.Set_Building_Button_Selected = Set_Building_Button_Selected
Interface.Set_Building_Button_Focus = Set_Building_Button_Focus
Interface.Reset_Queue_Building = Reset_Queue_Building
Interface.Hotkey_Activate_Queue = Hotkey_Activate_Queue
