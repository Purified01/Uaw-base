if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Novus_Patch_Menu_Manager.lua
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
	--this.BackgroundComponents.Set_Hidden(true)
	
	Clock = this.CooldownClock
	Clock.Set_Hidden(true)
	Clock.Set_Filled(0.0)
	Clock.Set_Tint(1.0, 0.0, 0.0, 120.0/255.0)
	
	-- Find all the patch menu buttons (all available patches)
	-- -----------------------------------------------------------------------
	PatchButtons = {}
	if TestValid(this.Patches) then 
		PatchButtons = Find_GUI_Components(this.Patches, "Patch")
	else
		PatchButtons = Find_GUI_Components(this, "Patch")
	end
	
	for index, button in pairs(PatchButtons) do
		button.Set_Hidden(true)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Patch_Button_Click)
		button.Set_Tab_Order(index)
	end
	-- -----------------------------------------------------------------------
	this.Register_Event_Handler("Patch_Lock_State_Changed", nil, Update_Patch_Menu)
	
	Queue = this.PatchQueue
	
	-- Maria 11.29.2007:  Per bug #376: Player should not be able to navigate the patch slots (Novus Faction). Player should not be able to navigate the patch slots when the patch menu is 
	--  accessed (it gives players the illusion of choice, when they really can only push things �through� both slots)
	--Queue.Set_Tab_Order(#PatchButtons + 1)
	
	MenuOpen = false
	MenuDisabled = false
	Animating = false
	UpdateFocus = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Process_Patch_Queueing_Complete
-- ------------------------------------------------------------------------------------------------------------------
function Process_Patch_Queueing_Complete()
	Animating = false
	Queue.Process_Patch_Queueing_Complete()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Size
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_Size(new_size)
	Queue.Update_Queue_Size(new_size)	
end
	
-- ------------------------------------------------------------------------------------------------------------------
-- Update_Patch_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Update_Patch_Menu(_, _, player)
	if player == Find_Player("local") then 
		Refresh_Menu()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Display_Menu -- It is hooked to ComponentUnhidden via the Editor
-- ------------------------------------------------------------------------------------------------------------------
function Display_Menu()
	
	if not MenuOpen then 
		-- retrieve the list of available patches
		Setup_Menu()
		
		-- when opening this menu we want to make sure that focus is on the first option in the menu!.
		UpdateFocus = true
	end
	MenuOpen = true
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Menu -- It is hooked to ComponentHidden via the Editor
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Menu()
	MenuOpen = false
	UpdateFocus = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Refresh_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Refresh_Menu()
	if MenuOpen then 
		Setup_Menu()	
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Update_Scene(player_credits_changed)

	if MenuOpen then 
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
		if player_credits_changed then 
			Refresh_Menu()
		end
		
		if UpdateFocus then 
			this.Focus_First()
			UpdateFocus = false
		end		
		
		-- If the menu is open, also update the 
		Queue.Update_Queue_Manager(player_credits_changed)
	end
	
	return MenuOpen
end


-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Menu()
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
				button.Set_Button_Enabled(false)
			else
				button.Set_Button_Enabled(can_produce)
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

	-- Reset the buttons' state.
	for i = button_index, #PatchButtons do
		local button = PatchButtons[i]
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
			--this.Get_Containing_Scene().Raise_Event_Immediate("Build_Patch_Button_Clicked", this.Get_Containing_Component(), { Find_Player("local"), p_type })
			Animating = Queue.Build_Patch_Button_Clicked(Find_Player("local"), p_type)
			Disable_Menu(Animating)
			-- As per Bug #3845: Patch menu should close after a patch is selected
			-- Maria 10.09.2007 -
			-- Since the queue is now displayed along with the menu, let's close the menu when the shift animation is finished!!!!.
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
				button.Set_Button_Enabled(false)
			else
				local data = button.Get_User_Data()
				if data and #data >= 2 then 
					button.Set_Button_Enabled(data[2])
				end
			end
		end
	end
	
	MenuDisabled = on_off
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Patches_Menu = Init_Patches_Menu
Interface.Update_Scene = Update_Scene
Interface.Display_Menu = Display_Menu
Interface.Update_Queue_Size = Update_Queue_Size
Interface.Process_Patch_Queueing_Complete = Process_Patch_Queueing_Complete
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
