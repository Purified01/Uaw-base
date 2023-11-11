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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Novus_Patch_Menu_Manager.lua
--
--            Author: Keith_Brors
--
--          DateTime: 2006/06/26 16:13:57
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- current patch building object
-- This is required to get the buttons activcated for building patches

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Patches_Menu - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Patches_Menu()
	
	-- All the UI elements that 'beautify' the scene (background quads, text, etc.)
	this.BackgroundComponents.Set_Hidden(true)
	
	Clock = this.CooldownClock
	Clock.Set_Hidden(true)
	Clock.Set_Filled(0.0)
	-- this is a cooldown clock so it must be red and go backwards!
	Clock.Set_Clockwise(true)	
	Clock.Set_Tint(1.0, 0.0, 0.0, 120.0/255.0)
	
	-- Find all the patch menu buttons (all available patches)
	-- -----------------------------------------------------------------------
	PatchButtons = Find_GUI_Components(this, "Patch")
	for index, button in pairs(PatchButtons) do
		button.Set_Hidden(true)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Patch_Button_Click)
		button.Set_Tab_Order(index)
	end
	-- -----------------------------------------------------------------------
	MenuOpen = false
	MenuDisabled = false
	Animating = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Refresh_Focus
-- ------------------------------------------------------------------------------------------------------------------
function Refresh_Focus()
	-- when opening this menu we want to make sure that focus is on the first option in the menu!.
	this.Focus_First()	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Display_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Display_Menu(on_off)
	if on_off then 
		-- retrieve the list of available patches
		Setup_Menu()
		
		-- when opening this menu we want to make sure that focus is on the first option in the menu!.
		this.Focus_First()		
	else
		-- just  close down the menu display!.
		Reset_Menu()
		Clock.Set_Hidden(true)
		Clock.Set_Filled(0.0)
	end
	
	this.BackgroundComponents.Set_Hidden(not on_off)	
	MenuOpen = on_off
end


-- ------------------------------------------------------------------------------------------------------------------
-- Refresh_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Refresh_Menu()
	if MenuOpen == true then 
		Setup_Menu()	
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Update_Scene(player_credits_changed)
	-- Do we have to update the cooldown timer!?
	local player = Find_Player("local")
	local script = player.Get_Script()
	
	local cooldown_left = 0.0
	if script then 
		cooldown_left = script.Get_Async_Data("CooldownPercentLeft")
	end
	
	Clock.Set_Filled(cooldown_left)
	Clock.Set_Hidden(cooldown_left == 0.0)
	
	if Animating == false then
		-- make sure we update the state 'enabled' of the menu
		if cooldown_left == 0.0 and MenuDisabled == true then
			-- Put the menu back up!.
			Disable_Menu(false)
		end	
	end
	
	-- do we need to refresh the contents of the menu?
	if player_credits_changed == true then 
		Refresh_Menu()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Menu()
	-- Reset any old configuration
	Reset_Menu()

	-- update the list of available patches!.
	local menu = Retrieve_Patches_Menu()
	
	-- Now, let's put the buttons up!.
	local button_index = 1
	for idx, patch_data in pairs(menu) do 
		-- patch_data contains the following information:
		-- patch_data[1] = patch type
		-- patch_data[2] = can_produce
		-- patch_data[3] = enough_credits
		-- patch_data[4] = build cost
		-- patch_data[5]  = patch_duration
	
		local obj_type = patch_data[1] 
		local can_produce = patch_data[2] 
		local enough_credits = patch_data[3] 
		local build_cost = patch_data[4] 
		local patch_duration = patch_data[5] 
		
		if obj_type ~= nil then
			button = PatchButtons[button_index]
			
			local icon_name = obj_type.Get_Icon_Name()
			button.Set_Hidden(false)
			button.Set_Texture( icon_name )
			
			button.Set_User_Data({obj_type, can_produce, button_index})
			
			-- enable the button only if the player has enough credits to purchase this unit.
			if MenuDisabled == true then 
				button.Set_Enabled(false)
			else
				button.Set_Enabled(can_produce)
			end
			
			if build_cost > 0.0 then 
				button.Set_Cost(build_cost)
			else
				button.Clear_Cost()
			end		
			
			if enough_credits == false then 
				button.Set_Insufficient_Funds_Display(true)
			else
				button.Set_Insufficient_Funds_Display(false)
			end
			
			-- Tooltip data: tooltip mode, type, cost, build time, warm up time, duration time.
			button.Set_Tooltip_Data({'type', {obj_type, build_cost, patch_duration}})								
			button_index = button_index + 1	

			if button_index > #PatchButtons then 
				break
			end
		end
	end		
end


-- ------------------------------------------------------------------------------------------------------------------
-- Retrieve_Patches_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Menu()
	for _, button in pairs(PatchButtons) do
		button.Set_Hidden(true)
		button.Set_Enabled(true)
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Retrieve_Patches_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Retrieve_Patches_Menu()

	local player = Find_Player("local")
	if not player then return end
	
	local script = player.Get_Script()
	
	local menu = {}
	if script then 
		menu = script.Get_Async_Data("CachedPatchMenu")
	end
	return menu
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Menu_Open
-- ------------------------------------------------------------------------------------------------------------------
function Is_Menu_Open( )
	return MenuOpen
end


-- ------------------------------------------------------------------------------------------------------------------
-- GUI_Can_Build_Patch_Of_Type -- Multiplayer safe player script query.  5/31/2007 10:23:33 AM -- BMH
-- ------------------------------------------------------------------------------------------------------------------
function GUI_Can_Build_Patch_Of_Type(p_type)
	local player = Find_Player("local")
	if player == nil then return false end
	local p_script = player.Get_Script()
	if p_script == nil then return false end

	local cooldowndata = p_script.Get_Async_Data("CooldownData")
	if cooldowndata == nil then return false end

	-- If we are in cooldown time, then nothing can be built!
	if cooldowndata.CooldownTimeLeft and cooldowndata.CooldownTimeLeft > 0.0 then return end

	local ptypetodata = p_script.Get_Async_Data("PatchTypeToData")
	if ptypetodata == nil then return false end
	-- First check to see whether the player can produce and afford this guy!.
	local data = ptypetodata[p_type]
	if data.CanBuild == false then return false end
	
	local activepatches = p_script.Get_Async_Data("ActivePatches")
	-- Now, we have to make sure there is no other valid active patch of this type!!!!.
	for _, data in pairs(activepatches) do
		if data.Type and data.Type == p_type then	
			if TestValid(data.Object) then 
				-- Found a patch already active.  Return false.
				return false
			end
		end
	end
	-- Good to go...
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Build_Patch_Button_Click
-- ------------------------------------------------------------------------------------------------------------------
function On_Build_Patch_Button_Click(event, source)
	
	local data = source.Get_User_Data()
	local p_type = data[1]
	
	if p_type ~= nil then
		if GUI_Can_Build_Patch_Of_Type(p_type) == true then 
			-- We will start building the patch once the animation is done!.
			-- Hence, the cooldown timer will go be activated until the build goes through, so let's DISABLE all components
			-- in this menu to prevent skipping the cooldown wait!
			this.Get_Containing_Scene().Raise_Event_Immediate("Build_Patch_Button_Clicked", this.Get_Containing_Component(), { Find_Player("local"), p_type })
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Menu(on_off)

	for _, button in pairs(PatchButtons) do
		if button.Get_Hidden() == false then
			if on_off then 
				button.Set_Enabled(false)
			else
				local data = button.Get_User_Data()
				if data and #data >= 2 then 
					button.Set_Enabled(data[2])
				end
			end
		end
	end
	
	MenuDisabled = on_off
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Animating
-- ------------------------------------------------------------------------------------------------------------------
function Set_Animating(on_off)
	Animating = on_off
	
	if Animating then
		Disable_Menu(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Patches_Menu = Init_Patches_Menu
Interface.Display_Menu = Display_Menu
Interface.Is_Menu_Open = Is_Menu_Open
Interface.Update_Scene = Update_Scene
Interface.Refresh_Menu = Refresh_Menu
Interface.Refresh_Focus = Refresh_Focus
Interface.Set_Animating = Set_Animating