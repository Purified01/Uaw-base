if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[124] = true
LuaGlobalCommandLinks[190] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[166] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[165] = true
LuaGlobalCommandLinks[117] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Queue_Manager.lua#24 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Queue_Manager.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #24 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Queues = { }
	IsOpen = false
	QueueType = nil
	Buildings = {}
	SelectedBuilding = nil
	BuyMenu = nil
	BuyButtons = {}
	FlashBuildingTypes = {}
	BuildingButtons = {} 
	SpecialAbilities = {}
	ActiveQueue = nil
	IsUpgrading = false
	IsSingleQueueMode = false
	IsEnabler = false
	LastSelectedBuilding = nil
	
	LocalPlayer = Find_Player("local")
	
	-- List of units we can buy at this building
	BuyMenu = Scene.BuyMenu
	Scene.Register_Event_Handler("Buy_Button_Clicked", BuyMenu, On_Buy_Button_Click)
	Scene.Register_Event_Handler("Buy_Button_Controller_X_Button_Up", BuyMenu, On_X_Button_Up)
	
	-- Find all buildings.
	Find_Tactical_Enablers()
	
	-- Find all queue scenes.
	Queues = Find_GUI_Components(Scene, "Queue")
	for idx, queue in pairs(Queues) do
		queue.Init_Queue(idx)
		queue.Set_Hidden(true)
	end
	
	this.Highlight.Set_Hidden(true)

	--Find all the building buttons
	BuildingButtons = Find_GUI_Components(Scene, "Building")
	for i, button in pairs(BuildingButtons) do
		button.Set_Hidden(true)
		button.Set_Clock_Tint({0.0, 1.0, 0.0, 150.0/255.0})
	end
	
	-- Register all events
	Scene.UnitTypeButton.Set_Hidden(true)
	Close()
	
	this.Register_Event_Handler("Construction_Complete", nil, On_Construction_Complete)
	this.Register_Event_Handler("Debug_Force_Completion", nil, On_Debug_Force_Production_Complete)	
	this.Register_Event_Handler("Networked_Build_Start", nil, On_Networked_Build_Start)
	this.Register_Event_Handler("Networked_Cancel_Build", nil, On_Networked_Cancel_Build)
	this.Register_Event_Handler("Queue_Building_Button_Clicked", nil, Building_Button_Clicked)
	
	--selecting buildings
--	this.Register_Event_Handler("Controller_Y_Button_Press", nil, On_Building_Button_Click)
--	this.Register_Event_Handler("Controller_Y_Button_Double_Press", nil, On_Building_Button_Double_Click)

	this.Register_Event_Handler("Queue_Buy_Controller_Left_Stick_Move", BuyMenu, On_Left_Stick_Move)
	
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
	
	--Current queue
	CurrentQueueID = 1
	STICK_DEAD_ZONE = 0.2
	
	if TestValid(this.XQuad) then
		XQuad = this.XQuad
		XQuad.Set_Hidden(true)
		_, _, Xw, Xh = XQuad.Get_Bounds()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_X_Button_Up - We need to cancel the last build in the queue.
-- ------------------------------------------------------------------------------------------------------------------
function On_X_Button_Up(_, _)

	if not IsOpen then 
		return 
	end
	
	if not TestValid(SelectedBuilding) then 
		return 
	end

	local queue = Queues[CurrentQueueID]
	if IsSingleQueueMode then
		queue = Queues[1]
	end
	
	queue.Process_X_Button_Up()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Build_Start - Issues the build in sync across all systems.
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Build_Start(event, source, builder, unit_type, player)

	-- SyncMessage("EnablerBegin -- builder: %s, unit_type: %s, player: %s\n", tostring(builder), tostring(unit_type), tostring(player))
	Tactical_Enabler_Begin_Production(builder, unit_type, 1, player)

	-- Refresh the build options if we actually issued the build.
	if player == LocalPlayer then
	
		Raise_Event_Immediate_All_Scenes("Tactical_Enabler_Production_Started", {builder})
		
		-- if the button for this unit type is flashing, reset it
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Internal_Stop_Queue_Buttons_Flash", nil, {builder.Get_Type(), unit_type})
		
		Refresh()
	end
end

   
-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Cancel_Build - Issues the build in sync across all systems.
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Cancel_Build(event, source, builder, unit_type, build_id, quantity, player)
	Tactical_Enabler_Cancel_Production_By_Build_ID(builder, unit_type, build_id, quantity)
	
	if player == LocalPlayer then
		Raise_Event_Immediate_All_Scenes("Tactical_Enabler_Production_Canceled", {builder})
		Refresh()
	end
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
	for _, queue in pairs(Queues) do 
		queue.Set_Hidden(true)
	end	

	for _,button in pairs(BuildingButtons) do
		button.Set_Hidden(true)
	end
	
	this.Highlight.Set_Hidden(true)
	BuyMenu.Set_Hidden(true)
	if TestValid(XQuad) then
		XQuad.Set_Hidden(true)
	end
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
	
	for _, queue in pairs(Queues) do
		local q_bldg = queue.Get_Queue_Building()
		if TestValid(q_bldg) and building == q_bldg then
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
  	Buildings = Find_Tactical_Enablers_In_Active_Context(LocalPlayer)

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
		
		if SelectedBuilding.Tactical_Enabler_Can_Produce(unit_type, LocalPlayer, 1) == true then 
			Send_GUI_Network_Event("Networked_Build_Start", { SelectedBuilding, unit_type, LocalPlayer })
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
function Open(queue_type, selected_buildings, special_abilities)
	IsOpen = true
	this.Enable(true)
	QueueType = queue_type
	if selected_buildings then
		SelectedBuilding = selected_buildings[1]
	else
		SelectedBuilding = nil
	end
	if SelectedBuilding and table.getn(selected_buildings) == 1 then
		IsSingleQueueMode = true
	else
		IsSingleQueueMode = false
	end
	SpecialAbilities = special_abilities
	CurrentQueueID = 1
	
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
		
	--	if bldg_index > 0 and bldg_index <= #IndexToButtonMap then
	--		local queue_ui = IndexToButtonMap[bldg_index]
	--		if TestValid(queue_ui) then
	--			queue_ui.Hotkey_Activate_Queue(is_double_key_press)
	--		end		
	--	else
	--		MessageBox("Tactical_Queue_Manager::Open_Queue_At_Index: Wrong bldg index!!!")
	--	end
		DebugMessage("Skipping Hotkey_Activate_Queue")
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
--	BuyMenu.Set_Hidden(true)

	if not IsOpen then
		return false
	end

	local local_player = Find_Player('local')
	local has_queue = true

	for index,button in pairs(BuildingButtons) do
		local q_bldg = button.Get_User_Data()
		if TestValid(SelectedBuilding) and SelectedBuilding == q_bldg then
			button.Set_Selected(true)

			local allowed_units = nil
			if QueueTypeStrgToEnumValue[QueueType] ~= QueueTypeStrgToEnumValue['NonProduction'] then 
				allowed_units = SelectedBuilding.Get_Tactical_Enabler_Build_Menu(local_player)
				-- only production buildings have actual queues
				ActiveQueue.Setup_Queue(SelectedBuilding, false)
				ActiveQueue.Set_Hidden(false)
			else
				ActiveQueue.Set_Hidden(true)
				this.Highlight.Set_Hidden(true)
				button.Set_Hidden(true)
				has_queue = false
			end
				
			local structure_powered = true
			if SelectedBuilding.Has_Behavior( 161 ) and SelectedBuilding.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
				structure_powered = false
			end
				
			-- Populate the buy and upgrades menu.
			IsUpgrading = BuyMenu.Populate_Buy_Menu(allowed_units, structure_powered, SelectedBuilding, GetCurrentTime(), SpecialAbilities)			
			
			
			BuyMenu.Set_Hidden(false)

			-- Spiiiiin the buy menu
			-- Maria 01.21.2008: Only do this if the bulding type has changed!. (Fix for bug 2966 sega db).
			if not TestValid(LastSelectedBuilding) or LastSelectedBuilding.Get_Type() ~= SelectedBuilding.Get_Type() then
				BuyMenu.Focus_On_First_Active()				
				LastSelectedBuilding = SelectedBuilding	
			end			

			BuyMenu.Focus()
		
			-- set the X quad
			if IsUpgrading and TestValid(XQuad) then
				local bds = { }
				bds.x, bds.y, bds.w, bds.h = button.Get_Bounds()
				XQuad.Set_Bounds(bds.x + 0.5 * (bds.w - Xw), bds.y + bds.h - 0.5 * Xh, Xw, Xh)							
			end
			
			if IsSingleQueueMode then
				break
			end
			
		else
			button.Set_Selected(false)
		end
	end
	
	ActiveQueue.Hide_X_Button(IsUpgrading)
	
	if TestValid(XQuad) and has_queue then
		XQuad.Set_Hidden(not IsUpgrading)	
	end
		
	return IsUpgrading
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
	--BuyMenu.Set_Hidden(true)
	local is_building = false
	
	if IsOpen then
		
		-- Flash building icons? (leading user down path to buy units)
		local bldg_qtype = Get_Building_Queue_Type(SelectedBuilding)
		
		-- Start with all queues hidden.
		-- Hide_All() 
		
		IndexToButtonMap = {}
	
		if QueueType then 
			QueueTypeToBldgCount[QueueType] = 0
		end	
		
		local button_index = 1;
		
			-- Assign them to building buttons
		local num_buttons = table.getn(BuildingButtons)
		local button_index = 1
		local local_player = Find_Player('local')
		local this_queue_count = QueueTypeToBldgCount[QueueType]
		local queue_index = 1
		
		
		if IsSingleQueueMode then
			local bldg_qtype = Get_Building_Queue_Type(SelectedBuilding)
			if TestValid(SelectedBuilding) and SelectedBuilding.Get_Owner() == local_player and QueueTypeStrgToEnumValue[bldg_qtype] == QueueTypeStrgToEnumValue[QueueType] then
				local building_button = BuildingButtons[button_index]
				local queue = Queues[queue_index]
				
				IndexToButtonMap[1] = building_button

				Setup_Building_Button(SelectedBuilding, building_button, FlashBuildingTypes[SelectedBuilding.Get_Type()])
				queue.Setup_Queue(SelectedBuilding, FlashBuildingTypes[SelectedBuilding.Get_Type()])
					
				queue.Hide_X_Button(false)
			
				-- Next queue
				button_index = button_index + 1
				queue_index = queue_index + 1		
			end

		else
			for i, building in pairs(Buildings) do
				local bldg_qtype = Get_Building_Queue_Type(building)
				if TestValid(building) and building.Get_Owner() == local_player and QueueTypeStrgToEnumValue[bldg_qtype] == QueueTypeStrgToEnumValue[QueueType] 
				then
					local building_button = BuildingButtons[button_index]
					local queue = Queues[queue_index]
					
					IndexToButtonMap[this_queue_count+1] = building_button
	
					Setup_Building_Button(building, building_button, FlashBuildingTypes[building.Get_Type()])
					queue.Setup_Queue(building, FlashBuildingTypes[building.Get_Type()])
						
					--if we dont have a selected building, select the last selected building
					if button_index == CurrentQueueID then
						SelectedBuilding = building
						queue.Hide_X_Button(false)
					else
						queue.Hide_X_Button(true)
					end
				
					this_queue_count = this_queue_count + 1
					-- Next queue
					button_index = button_index + 1
					if button_index > num_buttons then
						break
					end		
					
					queue_index = queue_index + 1		
				end
			end	
		end

		if QueueType then 
			QueueTypeToBldgCount[QueueType] = this_queue_count
		end		
			
		-- clamp current id
--		if CurrentQueueID >= queue_index then
--			CurrentQueueID = queue_index - 1
--		end
		
		if IsSingleQueueMode then
			ActiveQueue = Queues[1]
		else
			ActiveQueue = Queues[CurrentQueueID]
		end		

		if IsSingleQueueMode then
			-- set the highlight
			local queue_x, queue_y = Queues[1].Get_Screen_Position()
			this.Highlight.Set_Screen_Position(queue_x, queue_y)
		else
			-- set the highlight
			local queue_x, queue_y = Queues[CurrentQueueID].Get_Screen_Position()
			this.Highlight.Set_Screen_Position(queue_x, queue_y)
		end	

		this.Highlight.Set_Hidden(false)
	end
	
	
	
	-- TODO: clear out any queue_gui stuff past the end that is no longer referenced
	IsUpgrading = Update_Selected_Queue()

	
	return (is_building or IsUpgrading)
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
	this.Enable(false)
	this.Highlight.Set_Hidden(true)
	return active_queue_type
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Type - what type of queues are we showing? "air", "vehicle", or "infantry", or nil if closed
-- ------------------------------------------------------------------------------------------------------------------
function Get_Type()
	return QueueType
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
-- Setup_Building_Button
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Building_Button(building, building_button, flash_building_button)
	building_button.Set_User_Data(building)
	building_button.Set_Hidden(false)
	
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

function On_Building_X_Button_Up(_, source)
	DebugMessage("Building Button X Up %s", source.Get_Fully_Qualified_Name())
end

function On_Building_Button_Click(_, source)
	local building = BuildingButtons[CurrentQueueID].Get_User_Data()
	if not building then
		return
	end
	Set_Selected_Objects( {building} )
	Raise_Event_Immediate_All_Scenes("Queue_Building_Button_Clicked", {building})
end

function On_Building_Button_Double_Click(_, source)
	local building = BuildingButtons[CurrentQueueID].Get_User_Data()
	if not building then
		return
	end
	Point_Camera_At(building)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Left_Stick_Move
-- ------------------------------------------------------------------------------------------------------------------
function On_Left_Stick_Move(_, _, pos_x, pos_y, degrees)
	if Is_Open() and not IsSingleQueueMode then
		-- up
		if (degrees > 305 or degrees < 45) and pos_y > STICK_DEAD_ZONE then
			CurrentQueueID = CurrentQueueID + 1
			if CurrentQueueID > QueueTypeToBldgCount[QueueType] then
				CurrentQueueID = 1
			end
		end
		if degrees > 135 and degrees < 225 and pos_y < -STICK_DEAD_ZONE then
			CurrentQueueID = CurrentQueueID - 1
			if CurrentQueueID < 1  then
				CurrentQueueID = QueueTypeToBldgCount[QueueType]
			end
		end
	end
	Refresh(true)
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
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	On_Building_Button_Click = nil
	On_Building_Button_Double_Click = nil
	On_Building_X_Button_Up = nil
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

