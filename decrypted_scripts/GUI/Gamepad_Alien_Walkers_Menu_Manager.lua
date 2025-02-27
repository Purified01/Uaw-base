if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[22] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Alien_Blueprint_Menu_Manager.lua
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/06/19 17:13:57
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


-- IMPORTANT.......
-- THIS FILE IS REQUIRED BY Gamepad_Alien_Tactical_Command_Bar.lua!!!!!!!!!!!!!!!!!!!.
-- ------------------------------------------------------------------------------------------------------------------
-- Init_Walkers_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Init_Walkers_Menu()
	
	-- For the Aliens, the walker are tactical enablers!! .... so get all the walkers by getting all the tactical enablers!.
	Walkers = {}
	
	-- List of walkers
	WalkerButtons = {}
	
	-- Local Player
	LocalPlayer = Find_Player("local")
	
	-- Buttons for the list of walkers!
	if TestValid(this.FactionButtons.Carousel) then
		WalkerButtons = Find_GUI_Components(this.FactionButtons.Carousel, "Walker")

		for idx, button in pairs(WalkerButtons) do
			button.Set_Hidden(true)
			this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Walker_Button_Left_Clicked)
		end
	end
	
	-- We have to know when a new walker is constructed! (so that we can add it to the list!)
	this.Register_Event_Handler("Update_Enablers_List", nil, On_Update_Enablers_List)
	this.Register_Event_Handler("Construction_Complete", nil, On_Construction_Complete)
	
	EnablersListChanged = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Walker_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Walker_Menu()
	for _, button in pairs(WalkerButtons) do
		button.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Walker_Button_Left_Clicked - select the walker and start its customization mode.
-- ------------------------------------------------------------------------------------------------------------------
function On_Walker_Button_Left_Clicked(event, source)
	
	local walker = source.Get_User_Data()
	if not TestValid(walker) then return end
	
	-- FORCE THE HP SUB SELECT MODE (note: we do it here becuase once we go in code it will get set to the
	-- proper value but it won't be set on time since it comes through an event)
	InHPSubSelectionMode = true
	
	-- Make sure we pop the walker's UI so that all reticles are active!
	Show_Object_Attached_UI(walker, true)
	
	-- We will select the walker, move the camera to it and open up the customization menu for
	-- one (any) of its crown hp's.
	Controller_Start_On_Demand_Walker_Customization(walker)
	
	-- Snap the camera to the walker so that it doesn't go slowly to the HP when we kick the HP sub
	-- select mode.
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
	if object.Is_Walker() and object.Get_Owner() == LocalPlayer then
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
		
		-- Hide the rest of the buttons.
		for _, button in pairs(WalkerButtons) do
			button.Set_Hidden(true)
		end
		return
	end
	
	-- clean the table so that there are only walkers! (i.e., mobile structures)
	local clean_list = {}
	for i = 1, table.getn(enablers_table) do
		local obj = enablers_table[i]
		
		if obj.Get_Type().Is_Walker() == true then 
			table.insert(clean_list, obj)
		end	
	end
	
	if  Valid_Table(clean_list) then -- only use it if it is different from the one we already have!
		Walkers = clean_list
		Setup_Scene(true)
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
		
		button.Set_User_Data(walker)
		--WalkerToButtonMap[walker] = button
		
		button.Set_Texture(walker.Get_Type().Get_Icon_Name())
		button.Set_Hidden(false)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Scene()
	
	if table.getn(Walkers) == 0 then
		return
	end
	
	Set_Up_Button_List()
	return	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Up_Button_List
-- ------------------------------------------------------------------------------------------------------------------
function Set_Up_Button_List()
	local idx = 1
	local num_walkers = #(Walkers)
	
	for idx = 1, num_walkers do
		if idx >  #(WalkerButtons) then
			break
		end
		
		local button = WalkerButtons[idx]
		local walker = Walkers[idx]
		
		if walker.Get_Owner() == Find_Player('local') then
			button.Set_User_Data(walker)
			--WalkerToButtonMap[walker] = button
			button.Set_Texture(walker.Get_Type().Get_Icon_Name())
			button.Set_Hidden(false)	
			
			-- we want tooltip for this button, so set the info!
			button.Set_Tooltip_Data({'object', {walker}})		
		end
	end	
	
	-- Hide the rest of the buttons.
	for i = num_walkers + 1, #(WalkerButtons) do
		WalkerButtons[i].Set_Hidden(true)
	end
	
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Walkers_Menu - We need to constantly check the validity of the enablers in the list since
-- they may be detroyed thus leaving a NULL entry in the list! (which we here get rid of)
-- ------------------------------------------------------------------------------------------------------------------
function Update_Walkers_Menu()
	Validate_Enablers_List()	
	
	if EnablersListChanged then
		Setup_Scene()
	end
	
	EnablersListChanged = false
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Hide_Walker_Menu = nil
	Init_Walkers_Menu = nil
	Set_Walker_For_Customization = nil
	Update_Walkers_Menu = nil
	Kill_Unused_Global_Functions = nil
end
