if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[166] = true
LuaGlobalCommandLinks[190] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[165] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Tactical_Queue_Manager.lua#21 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Tactical_Queue_Manager.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #21 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

-- All the queue scenes, and other stuff.
Queues = {}

BuildingToQueueMap = {}
IsOpen = false
QueueType = nil
Buildings = {}
SelectedBuilding = nil
BuyMenu = nil   -- Shows list of units we can buy at this building
BuyButtons = {}
IsFlashingBuyButtons = false

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Queues = {}
	BuildingToQueueMap = {}
	IsOpen = false
	QueueType = nil
	Buildings = {}
	SelectedBuilding = nil
	BuyMenu = nil
	BuyButtons = {}
	IsFlashingBuyButtons = false
	FlashBuildingTypes = {}
	
	-- List of units we can buy at this building
	BuyMenu = Scene.BuyMenu
	Scene.Register_Event_Handler("Buy_Button_Clicked", BuyMenu, On_Buy_Button_Click)

	-- Find all buildings.
	Find_Tactical_Enablers()
	
	-- Find all queue scenes.
	Queues = {}
	BuildingToQueueMap = {}
	local queue_scenes = Find_GUI_Components(Scene, "Queue")
	for i, queue in pairs(queue_scenes) do
		table.insert(Queues, queue)
		queue.Init_Queue(table.getn(Queues))
		
		queue.Set_Tab_Order(i)
	end
	BuyMenu.Set_Tab_Order(#queue_scenes + 1)
	
	Scene.UnitTypeButton.Set_Hidden(true)
	Close()
	
	Scene.Register_Event_Handler("Construction_Complete", nil, On_Construction_Complete)
	Scene.Register_Event_Handler("Debug_Force_Completion", nil, On_Debug_Force_Production_Complete)	
	Scene.Register_Event_Handler("Networked_Build_Start", nil, On_Networked_Build_Start)
	Scene.Register_Event_Handler("Networked_Cancel_Build", nil, On_Networked_Cancel_Build)
	Scene.Register_Event_Handler("Queue_Building_Button_Clicked", nil, Building_Button_Clicked)
	
	-- for refreshes
	TacticalQueueUpdateTime = 0.0
	
	QueueTypeToBldgCount = {}

	-- We don't want to be comparing strings.  Until we remove the string queue type let's keep this map to do fast compares
	QueueTypeStrgToEnumValue = {}
	QueueTypeStrgToEnumValue['NonProduction'] = Declare_Enum(0)
	QueueTypeStrgToEnumValue['Command'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Infantry'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Vehicle'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Air'] = Declare_Enum()	
	
end




-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Build_Start - Issues the build in sync across all systems.
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Build_Start(event, source, builder, unit_type, player)

	-- SyncMessage("EnablerBegin -- builder: %s, unit_type: %s, player: %s\n", tostring(builder), tostring(unit_type), tostring(player))
	Tactical_Enabler_Begin_Production(builder, unit_type, 1, player)

	-- Refresh the build options if we actually issued the build.
	if player == Find_Player("local") then
		if IsFlashingBuyButtons then
			IsFlashingBuyButtons = false
		end

		-- if the button for this unit type is flashing, reset it
		local builder_type = builder.Get_Type()
		Raise_Event_Immediate_All_Scenes("UI_Stop_Flash_Queue_Buttons", {builder_type, unit_type})
		
		Refresh()
	end
end

   
-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Cancel_Build - Issues the build in sync across all systems.
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Cancel_Build(event, source, builder, unit_type, build_id, quantity, player)
	Tactical_Enabler_Cancel_Production_By_Build_ID(builder, unit_type, build_id, quantity)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Building_Button_Clicked - select the building
-- ------------------------------------------------------------------------------------------------------------------
function Building_Button_Clicked(event, source, building)
	FlashBuildingTypes[building.Get_Type()] = nil 
	if IsOpen then 
		Refresh()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_All - hides all UI elements
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All()
	for i, queue in pairs(Queues) do
		queue.Hide_Queue()
	end
	BuyMenu.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Remove_Building - 
-- ------------------------------------------------------------------------------------------------------------------
function Remove_Building(building)

	if not Buildings then return end
	
	for i = 1, #Buildings do
		if Buildings[i] == building then 
			building.Unregister_Signal_Handler(On_Production_Change, this)
			building.Unregister_Signal_Handler(On_Enabler_Destroyed, this)
			building.Unregister_Signal_Handler(On_Remove_Enabler, this)
			table.remove(Buildings, i)
			break
		end
	end
	
	if table.getn(Buildings) > 0 then
		Raise_Event_Immediate_All_Scenes("Update_Enablers_List", {Buildings})
	end
	
	local found_ct = 0
	for index, queue in pairs(Queues) do
		local q_bldg = queue.Get_Queue_Building()
		if TestValid(queue.Get_Queue_Building()) and building == queue.Get_Queue_Building() then
			queue.Reset_Queue_Building()
			found_ct = found_ct + 1
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Find_Tactical_Enablers - 
-- ------------------------------------------------------------------------------------------------------------------
function Find_Tactical_Enablers()

	-- Find all tactical enablers, and listen to signals we care about from them.
	-- NOTE: We need to make sure we get ONLY the buildings that belong to the active context!!!.
	-- Maria 08.07.2007
	-- When playing with the controller, this list will contain all the ground structures (event those that are not enablers!)
  	Buildings = Find_Tactical_Enablers_In_Active_Context(Find_Player("local"))

	for i, building in pairs(Buildings) do
		Listen_Building(building)
	end
	
	if table.getn(Buildings) > 0 then
		Raise_Event_Immediate_All_Scenes("Update_Enablers_List", {Buildings})
	end
	
	return Buildings
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
-- Get_Building_Queue_Type - what type is this building? air, infantry, vehicle, or nil
-- ------------------------------------------------------------------------------------------------------------------
function Get_Building_Queue_Type(building)
	if not TestValid(building) then 
		return
	end
	return building.Get_Type().Get_Building_Queue_Type()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Temp_Enable_Build_Item - enable the given object type for production.
-- ------------------------------------------------------------------------------------------------------------------
function Temp_Enable_Build_Item(object_type)
	BuyMenu.Temp_Enable_Build_Item(object_type)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Open - open up the queue manager
-- ------------------------------------------------------------------------------------------------------------------
function Open(queue_type, selected_building)
	IsOpen = true
	this.Enable(true)
	QueueType = queue_type
	SelectedBuilding = selected_building
	Update_Display_Focus()	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Open_Queue_At_Index
-- ------------------------------------------------------------------------------------------------------------------
function Open_Queue_At_Index(queue_type, bldg_index, is_double_key_press)
	
	-- Now, get the index of the building to select based on the tacked index value and the current number of buildings in the queue.
	local menu_count = Get_Queue_Type_Enabler_Count(queue_type)
	
	if menu_count and menu_count > 0 then 
		-- get the proper index value.
		if menu_count == 1 then
			bldg_index = 1
		end
		
		if bldg_index > menu_count and menu_count > 1 then
			bldg_index = Math.mod(bldg_index, menu_count)
		end
		
		if bldg_index > 0 and bldg_index <= #IndexToQueueMap then
			local queue_ui = IndexToQueueMap[bldg_index]
			if TestValid(queue_ui) then
				queue_ui.Hotkey_Activate_Queue(is_double_key_press)
			end		
		else
			MessageBox("Tactical_Queue_Manager::Open_Queue_At_Index: Wrong bldg index!!!")
		end
	end	
	
	return bldg_index
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Display_Focus
-- ------------------------------------------------------------------------------------------------------------------
function Update_Display_Focus()
	-- Clear the focus from any other UI component so that we can update the focus properly.
	if not WalkerCustomizationModeOn then 
		Clear_Key_Focus()
	end
	Refresh(true) -- true means the refresh function if being called from an open order and not an update.
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_Selected_Queue - 
-- ------------------------------------------------------------------------------------------------------------------
function Update_Selected_Queue()
	BuyMenu.Set_Hidden(true)

	controller_connected = Are_Any_Controllers_Connected()

	for index, queue in pairs(Queues) do
		local q_bldg = queue.Get_Queue_Building()
		if TestValid(SelectedBuilding) and SelectedBuilding == queue.Get_Queue_Building() then
			if IsOpen and not queue.Building_Button_Is_Hidden() then
				queue.Set_Building_Button_Selected(true)			
				local player = Find_Player("local")
				
				-- Show buttons for units we can buy from this building
				--local allowed_units = SelectedBuilding.Get_Tactical_Enabler_Supported_Units(player)
				-- NOTE: the output of the function below is a table of tables.  Each of the inner tables contains:
				-- inner_table[1] = type
				-- inner_table[2] = assigned queue index (order)
				-- inner_table[3] = bool can produce? (tech and popcap dependencies)
				-- inner_table[4] = bool player has enough credits?
				-- inner_table[5] = build cost of the specified type from this enabler.
				-- inner_table[6] = build time for the specified type at this enabler.
				-- inner_table[7] = build rate for the specified type at this enabler.
				-- inner_table[8] = build countdown for the specified type at this enabler.		
				
				-- THE FOLLOWING INFO IS NEEDED FOR TOOLTIP UPDATE!!!!
				-- inner_table[9] = lifetime build cap
				-- inner_table[10] = historically built count
				-- inner_table[11] = current build cap
				-- inner_table[12] = current build count
				
				local allowed_units = nil
				if QueueTypeStrgToEnumValue[QueueType] ~= QueueTypeStrgToEnumValue['NonProduction'] then 
					allowed_units = SelectedBuilding.Get_Tactical_Enabler_Build_Menu(player)
				end
				
				if allowed_units ~= nil or controller_connected then
					-- Show the buy menu for this queue. (Its building selected.)
					local screen_pos = queue.Get_Building_Button_Position()
					BuyMenu.Set_Screen_Position(screen_pos[1], screen_pos[2])
					
					BuyMenu.Set_Hidden(false)
					
					local structure_powered = true
					if Is_Player_Of_Faction(player, "NOVUS") == true then 
						structure_powered = (SelectedBuilding.Get_Attribute_Integer_Value( "Is_Powered" ) ~= 0.0)
					end
					
					BuyMenu.Populate_Buy_Menu(allowed_units, structure_powered, SpecialAbilities)
					
					-- JAC - Combine buy and upgrade onto same set of buttons when using a controller
					if controller_connected then
						BuyMenu.Update_Upgrade_Menu(SelectedBuilding,GetCurrentTime())
						BuyMenu.Update_Sell_Menu(SelectedBuilding)
					end
				end
			end
		else
			queue.Set_Building_Button_Selected(false)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Refresh - periodic update of refresh, normally only 1x a second unless constrcuting in which case 5x a second
-- ------------------------------------------------------------------------------------------------------------------
function Update_Refresh( cur_time )
	if TacticalQueueUpdateTime == 0.0 then 
		Find_Tactical_Enablers()
	end
	
	if cur_time >= TacticalQueueUpdateTime then
		if Refresh() then
			TacticalQueueUpdateTime = cur_time + 0.2
		else
			TacticalQueueUpdateTime = cur_time + 1.0
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Refresh - something has (possibly) changed, so refresh the UI elements.
-- ------------------------------------------------------------------------------------------------------------------
function Refresh(set_building_button_focus)
	BuyMenu.Set_Hidden(true)
	local is_building = false

	if IsOpen then
		-- Flash building icons? (leading user down path to buy units)
		local flash_all_buildings = IsFlashingBuyButtons
		local bldg_qtype = Get_Building_Queue_Type(SelectedBuilding)
		if flash_all_buildings and TestValid(SelectedBuilding) and  QueueTypeStrgToEnumValue[bldg_qtype] == QueueTypeStrgToEnumValue[QueueType] then
			flash_all_buildings = false
		end
	
		-- Start with all queues hidden.
		Hide_All() 
		
		BuildingToQueueMap = {}
		IndexToQueueMap = {}
	
		if QueueType then 
			QueueTypeToBldgCount[QueueType] = 0
		end	
		
		-- Assign them to queues
		local queue_index = 1
		local num_queues = table.getn(Queues)
		local local_player = Find_Player('local')
		local this_queue_count = QueueTypeToBldgCount[QueueType]
		for i, building in pairs(Buildings) do
			local bldg_qtype = Get_Building_Queue_Type(building)
			if TestValid(building) and building.Get_Owner() == local_player and QueueTypeStrgToEnumValue[bldg_qtype] == QueueTypeStrgToEnumValue[QueueType] then
				local queue_gui = Queues[queue_index]
				BuildingToQueueMap[building] = queue_gui
				IndexToQueueMap[this_queue_count+1] = queue_gui
				
				if queue_gui.Setup_Queue(building, (flash_all_buildings or FlashBuildingTypes[building.Get_Type()])) then
					is_building = true
				end
				
				if set_building_button_focus == true then 
					if (not TestValid(SelectedBuilding) and this_queue_count == 0) or (TestValid(SelectedBuilding) and SelectedBuilding == building) then
						-- we want the focus to be on the first building button
						queue_gui.Set_Building_Button_Focus()
					end
				end
					
				this_queue_count = this_queue_count + 1
				-- Next queue
				queue_index = queue_index + 1
				if queue_index > num_queues then
					break
				end
			end
		end	

		if QueueType then 
			QueueTypeToBldgCount[QueueType] = this_queue_count
		end		
	end
	
	
	
	-- TODO: clear out any queue_gui stuff past the end that is no longer referenced
	Update_Selected_Queue()
	
	return is_building
end


-- ------------------------------------------------------------------------------------------------------------------
-- Get_Queue_Type_Enabler_Count - given a queue type, return number of buildings matching that type
-- ------------------------------------------------------------------------------------------------------------------
function Get_Queue_Type_Enabler_Count(queue_type)
	local local_player = Find_Player('local')
  	local count = 0
  	for i, building in pairs(Buildings) do
 		if TestValid(building) and building.Get_Owner() == local_player and Get_Building_Queue_Type(building) == queue_type then
 			count = count + 1
  		end
 	end
  	return count
end


-- ------------------------------------------------------------------------------------------------------------------
-- Listen_Building - listen for signals on a new building
-- ------------------------------------------------------------------------------------------------------------------
function Listen_Building(building)
	if TestValid(building) then
		building.Register_Signal_Handler(On_Production_Change, "OBJECT_TACTICAL_QUEUE_CHANGED", this)
		building.Register_Signal_Handler(On_Enabler_Destroyed, "OBJECT_HEALTH_AT_ZERO", this)
		building.Register_Signal_Handler(On_Remove_Enabler, "OBJECT_SOLD", this)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Remove_Enabler - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Remove_Enabler(building)
	-- remove the enabler from the list.
	Remove_Building(building)
	-- update the menu if necessary.
	Refresh()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Enabler_Destroyed - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Enabler_Destroyed(building)
	-- remove the enabler from the list.
	Remove_Building(building)
	-- update the menu if necessary.
	Refresh()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Production_Change - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Production_Change(event, source)
	Refresh()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_In_List - 
-- ------------------------------------------------------------------------------------------------------------------
function Is_In_List(object)
	if not TestValid(object) then 
		return
	end
	
	for _, building in pairs(Buildings) do
		if building == object then
			return true
		end
	end
	
	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Construction_Complete - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Construction_Complete(event, source, object)
	if object.Has_Behavior(89) and not Is_In_List(object) then
		table.insert(Buildings, object)
		Listen_Building(object)
	end
	
	Refresh()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Close - close down the queue manager (hide it)
-- ------------------------------------------------------------------------------------------------------------------
function Close()
	local active_queue_type = QueueType
	Hide_All()
	IsOpen = false
	QueueType = nil
	BuyMenu.Set_Hidden(true)
	this.Enable(false)
	return active_queue_type
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Type - what type of queues are we showing? "air", "vehicle", or "infantry", or nil if closed
-- ------------------------------------------------------------------------------------------------------------------
function Get_Type()
	return QueueType
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Flashing_Buy_Buttons - 
-- ------------------------------------------------------------------------------------------------------------------
function Is_Flashing_Buy_Buttons()
	return IsFlashingBuyButtons
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Flashing_Buy_Buttons - 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Flashing_Buy_Buttons(value)
	if IsFlashingBuyButtons ~= value then
		IsFlashingBuyButtons = value
		BuyMenu.Set_Flashing_Buy_Buttons(value)
		Refresh()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Debug_Force_Production_Complete - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Debug_Force_Production_Complete(event, source)
	Refresh()	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Open - 
-- ------------------------------------------------------------------------------------------------------------------
function Is_Open()
	return IsOpen
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Flashing_Unit_Button - 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Flashing_Unit_Button(unit_type)
	BuyMenu.Set_Flashing_Unit_Button(unit_type)
	
	if IsOpen == true then 
		Refresh()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Stop_Flashing_Unit_Button 
-- ------------------------------------------------------------------------------------------------------------------
function Stop_Flashing_Unit_Button(unit_type)
	BuyMenu.Stop_Flashing_Unit_Button(unit_type)

	if IsOpen == true then 
		Refresh()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Flashing_Building_Button - 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Flashing_Building_Button(building_type)
	FlashBuildingTypes[building_type] = true
	
	if IsOpen == true then 
		Refresh()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Stop_Flashing_Building_Button 
-- ------------------------------------------------------------------------------------------------------------------
function Stop_Flashing_Building_Button(building_type)
	FlashBuildingTypes[building_type] = nil
	if IsOpen == true then 
		Refresh()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Walker_Customization_Mode_On
-- ------------------------------------------------------------------------------------------------------------------
function Set_Walker_Customization_Mode_On(on_off)
	WalkerCustomizationModeOn = on_off
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Show_Sell_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Show_Sell_Button()
	BuyMenu.UI_Show_Sell_Button()
	if IsOpen then	
		-- Force an update.
		Update_Selected_Queue()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Sell_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Hide_Sell_Button()
	BuyMenu.UI_Hide_Sell_Button()
	if IsOpen then	
		-- Force an update.
		Update_Selected_Queue()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Open = Open
Interface.Close = Close
Interface.Get_Type = Get_Type
Interface.Get_Queue_Type_Enabler_Count = Get_Queue_Type_Enabler_Count
Interface.Find_Tactical_Enablers = Find_Tactical_Enablers
Interface.Get_Building_Queue_Type = Get_Building_Queue_Type
Interface.Is_Flashing_Buy_Buttons = Is_Flashing_Buy_Buttons
Interface.Set_Flashing_Buy_Buttons = Set_Flashing_Buy_Buttons
Interface.Temp_Enable_Build_Item = Temp_Enable_Build_Item
Interface.Is_Open = Is_Open
Interface.Set_Flashing_Unit_Button = Set_Flashing_Unit_Button
Interface.Stop_Flashing_Unit_Button = Stop_Flashing_Unit_Button
Interface.Set_Flashing_Building_Button = Set_Flashing_Building_Button
Interface.Stop_Flashing_Building_Button = Stop_Flashing_Building_Button
Interface.Update_Refresh  = Update_Refresh
Interface.Update_Display_Focus = Update_Display_Focus
Interface.Open_Queue_At_Index = Open_Queue_At_Index
Interface.Set_Walker_Customization_Mode_On = Set_Walker_Customization_Mode_On
Interface.UI_Show_Sell_Button = UI_Show_Sell_Button
Interface.UI_Hide_Sell_Button = UI_Hide_Sell_Button
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

