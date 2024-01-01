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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Alien_Blueprint_Menu_Manager.lua
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/06/19 17:13:57
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Blueprints_List - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Blueprints_Menu()
	
	if MenuScene == nil then
		return
	end
	
	-- For the Aliens, the walker are tactical enablers!! .... so get all the walkers by getting all the tactical enablers!.
	Walkers = {}
	
	if MenuScene == nil then
		MessageBox("DARN IT!")
		return
	end
	
	MenuScene.Set_Hidden(true)
	
	-- List of walkers
	WalkerButtons = {}
	
	-- Buttons for the list of walkers!
	WalkerButtons = Find_GUI_Components(MenuScene, "Walker")
	
	for idx, button in pairs(WalkerButtons) do
		button.Set_Hidden(true)
		button.Set_Tab_Order(idx)
		MenuScene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Walker_Button_Left_Clicked)
		MenuScene.Register_Event_Handler("Selectable_Icon_Double_Clicked", button, On_Walker_Button_Double_Click)
	end
	
	WalkerToButtonMap = {}
	
	BlueprintOpen = false
	ListOpen = false
	
	-- We have to know when a new walker is constructed! (so that we can add it to the list!)
	MenuScene.Register_Event_Handler("Update_Enablers_List", nil, On_Update_Enablers_List)
	MenuScene.Register_Event_Handler("Construction_Complete", nil, On_Construction_Complete)
	
	SelectedObject = nil
	EnablersListChanged = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Components
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Components(all_scenes)
	
	for _, button in pairs(WalkerButtons) do
		button.Set_Hidden(true)
		button.Set_User_Data(nil)
		button.Set_Selected(false)
	end
	
	if all_scenes == true then
		SelectedObject = nil
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Walker_Button_Left_Clicked - select the walker and start its customization mode.
-- ------------------------------------------------------------------------------------------------------------------
function On_Walker_Button_Left_Clicked(event, source)
	local walker = source.Get_User_Data()
	if not TestValid(walker) then return end
	Set_Selected_Objects( {walker} )	
	Set_Walker_For_Customization(walker)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Walker_Button_Double_Click - point the camera at the currently selected walker.
-- ------------------------------------------------------------------------------------------------------------------
function On_Walker_Button_Double_Click(event, source)
	local walker = source.Get_User_Data()
	if not TestValid(walker) then return end
	-- Point the camera at the walker.
	Point_Camera_At(walker)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Walker_For_Customization - we select the walker and point the camera at it.
-- ------------------------------------------------------------------------------------------------------------------
function Set_Walker_For_Customization(walker)
	
	if walker ~= nil then
		-- If some other walker's blueprint is up, close it so that we can display this guy's blueprint!
		if SelectedObject and SelectedObject ~= walker then
			-- deselect this button!
			if WalkerToButtonMap[SelectedObject] then
				WalkerToButtonMap[SelectedObject].Set_Selected(false)
			end
		end
		
		Raise_Event_Immediate_All_Scenes("Close_HP_Configuration_Menu", nil)
		
		SelectedObject = walker
		-- Set the button for this walker as selected.
		if WalkerToButtonMap[SelectedObject] then 
			WalkerToButtonMap[SelectedObject].Set_Selected(true)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Construction_Complete - A new walker has been added to the scene so update the list
-- of walkers by adding this new enabler!
-- ------------------------------------------------------------------------------------------------------------------
function On_Construction_Complete(event, source, object)
	if object.Has_Behavior(BEHAVIOR_TACTICAL_ENABLER) then
		-- insert the new element at the tail!
		local pos = table.getn(Walkers)
		table.insert(Walkers, pos+1, object)
	
		Update_Button_List()
	end
end

-- -----------------------------------------------------------------------------------------------------------------
-- The enablers may be destroyed and their entry will remain in the list as NULL!!!!!
-- ------------------------------------------------------------------------------------------------------------------
function Validate_Enablers_List()
	local num_enablers = table.getn(Walkers)
	if num_enablers > 0 then
		local idx = num_enablers
		while idx >= 1 do
			if not TestValid(Walkers[idx]) then
				table.remove(Walkers, idx)
				EnablersListChanged = true
			end
			idx = idx - 1
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Enablers_List - From the tactical command bar we have received a notice that the 
-- list of enablers may have changed!, therefore, update the list!
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Enablers_List(event, source, enablers_table)
	
	if Is_Player_Of_Faction(Find_Player("local"), "Alien") == false then
		Walkers = {}
		
		if ListOpen == true then
			Hide_Menu()
		end
		
		return
	end
	
	-- clean the table so that there are only walkers! (i.e., mobile structures)
	local clean_list = {}
	for i = 1, table.getn(enablers_table) do
		local obj = enablers_table[i]
		
		if obj.Get_Type().Is_Mobile_Structure() == true then 
			table.insert(clean_list, obj)
		end	
	end
	
	if  Valid_Table(clean_list) then -- only use it if it is different from the one we already have!
		Walkers = clean_list
		
		if ListOpen == true then
			Setup_Scene(true)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Valid_Table -- We do this so that we keep the walkers buttons in order!. 
-- ------------------------------------------------------------------------------------------------------------------
function Valid_Table(enablers_table)
	local our_table_ct = table.getn(Walkers)
	local new_table_ct = table.getn(enablers_table)	
	
	if our_table_ct ~= new_table_ct then
		return true
	end

	for widx = 1, our_table_ct do
		local object = Walkers[widx]
		local found = false
		
		for eidx = 1, new_table_ct do
			local in_object = enablers_table[eidx]
			
			if in_object == object then
				found = true
				break
			end	
		end
		
		if found == false then
			-- the new list differs from ours so it is valid!
			return true
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Button_List - if a  new enabler has been added to the list, add the new button to the button
-- list!
-- ------------------------------------------------------------------------------------------------------------------
function Update_Button_List()

	local index = table.getn(Walkers)
	
	if index <= table.getn(WalkerButtons) then
		local button = WalkerButtons[index]
		local walker = Walkers[index]
		
		-- only display WALKERS!
		if walker.Get_Type().Is_Mobile_Structure() == true then 
			button.Set_User_Data(walker)
			WalkerToButtonMap[walker] = button
			
			if ListOpen == true then
				button.Set_Texture(walker.Get_Type().Get_Icon_Name())
				button.Set_Hidden(false)
			end
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Walker_List
-- ------------------------------------------------------------------------------------------------------------------
function Display_Walker_List()

	local local_player = Find_Player('local')
	
	if Is_Player_Of_Faction(local_player, "Alien") == false then
		return
	end
	
	ListOpen = true
	MenuScene.Set_Hidden(false)
	return(Setup_Scene(true))
end



-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Scene(set_up_all_scenes)
	
	Hide_Components(set_up_all_scenes)
	
	if table.getn(Walkers) == 0 then
		ListOpen = false
		return false
	end
	
	Set_Up_Button_List()
	return true	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Up_Button_List
-- ------------------------------------------------------------------------------------------------------------------
function Set_Up_Button_List()
	local idx = 1
	local num_walkers = table.getn(Walkers)
	
	for idx = 1, num_walkers do
		if idx >  table.getn(WalkerButtons) then
			break
		end
		
		local button = WalkerButtons[idx]
		local walker = Walkers[idx]
		
		-- only display WALKERS!
		if walker.Get_Type().Is_Mobile_Structure() == true then 
			if walker.Get_Owner() == Find_Player('local') then
				button.Set_User_Data(walker)
				WalkerToButtonMap[walker] = button
				button.Set_Texture(walker.Get_Type().Get_Icon_Name())
				button.Set_Hidden(false)	
				
				-- we want tooltip for this button, so set the info!
				button.Set_Tooltip_Data({'object', {walker}})
				
				if idx == 1 then
					button.Set_Key_Focus()
				end
				
				if num_walkers == 1 then 
					-- if we only have one walker and we go into customization mode, we automatically 
					-- set this walker as selected and point the camera at it.
					Set_Walker_For_Customization(walker)
					WalkerToButtonMap[SelectedObject].Set_Selected(true)
				end
			end
		end
	end	
	return true
end


	
-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Menu(force_hide)
	if ListOpen == true or force_hide == true then
		ListOpen = false
		Hide_Components(true)
		
		--Hide the entire scene in case there are decorative elements that have been missed by Hide_Components
		MenuScene.Set_Hidden(true)
		
		-- turn off the walker customization mode
		Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Is_List_Open
-- ------------------------------------------------------------------------------------------------------------------
function Is_List_Open()
	return ListOpen
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Scene_Hidden
-- ------------------------------------------------------------------------------------------------------------------
function Is_Scene_Hidden()
	return (not ListOpen )
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Initialized
-- ------------------------------------------------------------------------------------------------------------------
function Is_Initialized()
	return( table.getn(Walkers) > 0)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update - We need to constantly check the validity of the enablers in the list since they may be detroyed
-- thus leaving a NULL entry in the list! (which we here get rid of)
-- ------------------------------------------------------------------------------------------------------------------
function Update()
	Validate_Enablers_List()	
	
	if EnablersListChanged == true and ListOpen == true then
		Setup_Scene(true)
	end
	
	EnablersListChanged = false
	
	if table.getn(Walkers) == 0 then
		return true
	else 
		return false
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Refresh_Focus
-- ------------------------------------------------------------------------------------------------------------------
function Refresh_Focus()
	if #WalkerButtons > 1 and WalkerButtons[1].Get_Hidden() == false then
		WalkerButtons[1].Set_Key_Focus()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Blueprints_Menu = Init_Blueprints_Menu
Interface.Display_Walker_List = Display_Walker_List
Interface.Hide_Menu = Hide_Menu
Interface.Is_List_Open = Is_List_Open
Interface.Is_Scene_Hidden = Is_Scene_Hidden
Interface.Is_Initialized  = Is_Initialized
Interface.Update = Update
Interface.Refresh_Focus = Refresh_Focus