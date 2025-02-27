if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[187] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/NovusPatchesQueue.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/05/21
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("PGBase")
require("PGUICommands")

-- ---------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------------------------------------------------------
function Init_Patch_Queue_Manager()

	-- WE MAY NEED TO RESIZE THE QUAD DEPENDING ON THE NUMBER OF QUEUES AVAILABLE?
	-- OR WE SHOULD DISPLAY THE CUTE EMPTY TEXT FOR THE EMPTY QUEUE SLOT!.
	
	Queue = this.CommandBar.NovusPatchesQueue	
	-- clicking anywhere within the PatchQueue toggles the Patch menu
	this.Register_Event_Handler("Mouse_Left_Up", Queue.PatchQueueQuad, Toggle_Patches_Menu_Display)
	Queue.PatchQueueQuad.Set_Tab_Order(TAB_ORDER_FACTION_SPECIFIC_BUTTON)
	Queue.Set_Hidden(true)	
	this.Register_Event_Handler("Key_Focus_Lost", Queue.PatchQueueQuad, On_Focus_Lost)
	this.Register_Event_Handler("Key_Focus_Gained", Queue.PatchQueueQuad, On_Focus_Gained)
	Focus = Queue.PatchQueueFocusQuad
	Focus.Set_Hidden(true)

	local key_map_text = Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE", 1)
	if key_map_text == nil then 
		key_map_text = false
	end
	
	FloatingTooltipData = {"TEXT_UI_TACTICAL_NOVUS_PATCH_MENU", key_map_text, "TEXT_UI_TACTICAL_NOVUS_PATCH_MENU_DESCRIPTION"}
	local tooltip_data = {}
	table.insert(tooltip_data, FloatingTooltipData)
	QButtons = Find_GUI_Components(Queue, "PatchesQueueButton")
	for index, button in pairs(QButtons) do
		button.Set_Hidden(true)
		button.Set_Tooltip_Data({'patch_queue', tooltip_data})	
		-- this is a progress clock so it should be green!
		button.Set_Clock_Tint({0.0, 1.0, 0.0, 170.0/255.0})
		
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, Toggle_Patches_Menu_Display)
		this.Register_Event_Handler("Animation_Finished", button, On_Animation_Finished)
	end
	
	this.Register_Event_Handler("Update_Patch_Queue_Size", nil, On_Update_Patch_Queue_Size)
	this.Register_Event_Handler("Patch_Lock_State_Changed", nil, Update_Patch_Menu)
	
	this.Register_Event_Handler("UI_Start_Patch_Menu_Button_Flash", nil, On_UI_Start_Patch_Menu_Button_Flash)
	this.Register_Event_Handler("UI_Stop_Patch_Menu_Button_Flash", nil, On_UI_Stop_Patch_Menu_Button_Flash)	
	
	QueueSize = 0
	FlashQueue = false
	BuildingPatchData = nil
	PatchMenu = this.NovusPatchMenu
	PatchMenu.Init_Patches_Menu()
	PatchMenu.Set_Tab_Order(TAB_ORDER_FACTION_SPECIFIC_BUTTON + 3)	
	
	PATCH_STATE_ACTIVE = Declare_Enum(0)
	PATCH_STATE_INACTIVE = Declare_Enum()

	this.Register_Event_Handler("Build_Patch_Button_Clicked", PatchMenu, On_Build_Patch_Button_Clicked)
	this.Register_Event_Handler("On_Patch_Queueing_Complete", nil, On_Patch_Queueing_Complete)
	
	-- We may be loading a game so let's ee if there are slots enabled already!
	local player = Find_Player("local")
	if player then 
		local script = player.Get_Script()
		if script then 
			Update_Queue_Size(script.Get_Async_Data("AvaialableQueueSlots"))
		end
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Animation_Finished
-- ------------------------------------------------------------------------------------------------------------------
function On_Animation_Finished(_, source)
	
	if not BuildingPatchData then 
		return
	end
	
	local src_data = source.Get_User_Data()
	if source.Is_Animating("Slide_left") then
		-- now the last button gets this button's texture
		local next_button_idx = src_data[1]+1
		if next_button_idx > #QButtons then
			return 
		end
		
		local button = QButtons[next_button_idx]
		button.Stop_Animation()
		button.Set_Texture(src_data[2])
		
		-- Now replace this button's texture with the patch to be built.
		source.Stop_Animation()
		source.Set_Texture(BuildingPatchData[2].Get_Icon_Name())
		source.Play_Animation("fade_in", false)
		
	elseif source.Is_Animating("fade_out") then
		-- We have to mover the previous button!.
		local prev_button_idx = src_data[1] - 1
		if prev_button_idx < 1 then
			return 
		end
		local button = QButtons[prev_button_idx]
		button.Stop_Animation()
		button.Play_Animation("Slide_left", false)
		
	elseif source.Is_Animating("fade_in") then
		Send_GUI_Network_Event("Build_Patch_Now", BuildingPatchData)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Patch_Queueing_Complete -- We cannot wait for the nice service time in the common command
-- bar so we are forcing an update here so that we can finally hide the animated quads in the menu.
-- ------------------------------------------------------------------------------------------------------------------
function On_Patch_Queueing_Complete(_, _, player)
	if player ~= Find_Player("local") then 
		return
	end

	PatchMenu.Set_Animating(false)
	BuildingPatchData = nil	
	Update_Queue_Buttons()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Build_Patch_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Build_Patch_Button_Clicked(_, source, player, p_type)
	
	-- Let's retrieve the active patches data so that we can properly set the stage for the animations.
	if player == nil or p_type == nil then 
		return
	end
	
	BuildingPatchData = {player, p_type}
	
	local found = false
	local max_q_size = #QButtons
	if max_q_size <= 0 then
		return
	end
	
	for i = max_q_size, 1, -1 do
		local button = QButtons[i]
		if button.Get_User_Data() then
			button.Stop_Animation()
			if i == max_q_size then
				button.Play_Animation("fade_out", false)	
				found = true
				break
			elseif i == 1 and QueueSize > 1 then
				button.Play_Animation("Slide_left", false)	
				found = true
				break
			end			
		end	
	end
	
	if not found then
		local button = QButtons[1]
		button.Set_Texture(p_type.Get_Icon_Name())
		button.Stop_Animation()
		button.Play_Animation("fade_in", false)	
	end
	
	PatchMenu.Set_Animating(true)
	-- As per Bug #3845: Patch menu should close after a patch is selected
	PatchMenu.Display_Menu(false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Specific_Tooltip_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Specific_Tooltip_Data()
	local key_map_text = Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE", 1)
	if key_map_text == nil then 
		key_map_text = false
	end
	
	FloatingTooltipData = {"TEXT_UI_TACTICAL_NOVUS_PATCH_MENU", key_map_text, "TEXT_UI_TACTICAL_NOVUS_PATCH_MENU_DESCRIPTION"}
	local tooltip_data = {}
	table.insert(tooltip_data, FloatingTooltipData)
	
	for index, button in pairs(QButtons) do
		button.Set_Tooltip_Data({'patch_queue', tooltip_data})
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Start_Patch_Menu_Button_Flash
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Start_Patch_Menu_Button_Flash(event, source)
	FlashQueue = true	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_UI_Stop_Patch_Menu_Button_Flash
-- ------------------------------------------------------------------------------------------------------------------
function On_UI_Stop_Patch_Menu_Button_Flash(event, source)
	FlashQueue = false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Lost
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Lost(event, source)
	if not Is_Controller_Event() then return end
	Focus.Set_Hidden(true)
	
	-- Stop the animation on the queue buttons
	-- Start the animation on the queue buttons
	for _, button in pairs(QButtons) do
		if button.Is_Animating("Focus_Gained") then
			button.Stop_Animation()
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Gained
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Gained(event, source)
	if not Is_Controller_Event() then return end
	Focus.Set_Hidden(false)
	
	-- Start the animation on the queue buttons
	for _, button in pairs(QButtons) do
		button.Play_Animation("Focus_Gained", false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Patch_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Update_Patch_Menu(event, source, player)
	if player == Find_Player("local") then 
		PatchMenu.Refresh_Menu()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Patch_Queue_Size
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Patch_Queue_Size(event, source, player, new_size)
	if player == Find_Player("local") then
		Update_Queue_Size(new_size)		
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Size
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_Size(new_size)
	-- hide/unhide based on the number of patch enabling structures.
	local old_size = QueueSize
	QueueSize = new_size
	Update_Queue_State()
	
	-- If the patch menu happens to be open and we ran out of enablers then close it!.
	if QueueSize < 1 and PatchMenu.Is_Menu_Open() == true then
		PatchMenu.Display_Menu(false)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_State
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_State()
	local hide_queue = (QueueSize < 1)
	Queue.Set_Hidden(hide_queue)
	
	for idx = #QButtons, (QueueSize + 1), -1 do
		Reset_Button_At_Index(idx)
	end
	
	if hide_queue then
		BuildingPatchData = nil
	end	
end



-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Button_At_Index
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Button_At_Index(index)

	if not QButtons then return end
	local button = QButtons[index]
	-- Set it as empty!
	button.Set_Texture("i_icon_n_patch_empty_slot.tga")
	button.Set_Clock_Filled(0.0)
	button.Set_Hidden(true)
	button.Set_Button_Enabled(true)
	button.Set_User_Data(nil)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Specific_UI(on_off)
	-- There are not enough patch enablers to enable the queue so there's nothing to do!
	if QueueSize < 1 then return true end
	PatchMenu.Set_Hidden(not on_off)
	
	if on_off and PatchMenu.Is_Menu_Open() then
		PatchMenu.Refresh_Focus()
		return false
	end
	return true
end



-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Faction_Specific_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Faction_Specific_Menu()
	Toggle_Patches_Menu_Display()	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Patches_Menu_Display
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Patches_Menu_Display(event, source)
	if CommandBarEnabled == false then return end
	
	-- There are not enough patch enablers to enable the queue so there's nothing to do!
	if QueueSize < 1 then return end
	
	End_Sell_Mode()
	
	-- Close all displays
	Hide_Research_Tree()
	
	-- close common displays.
	Close_All_Displays(false) -- false = do not close faction specific displays
	
	-- now process the order on the patch menu
	PatchMenu.Set_Hidden(false)
	Display_Patch_Menu(not PatchMenu.Is_Menu_Open())
	
	FlashQueue	= false	
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Update_Patch_Queue_Manager
-- ---------------------------------------------------------------------------------------------------------------------------
function Update_Patch_Queue_Manager(player_credits_changed)
	
	-- Update the data displayed by the queue buttons, based on the contents of the queue.
	Update_Queue_Buttons()	
	
	-- Must return a bool determining whether the menu is open or not (so that we can determine if there are any huds open for the ESC key!)
	local is_menu_open = PatchMenu.Is_Menu_Open()
	if is_menu_open == true then 
		PatchMenu.Update_Scene(player_credits_changed)
	end
	
	if FlashQueue and not Is_Flashing(Queue) and Queue.Get_Hidden() == false then
		Start_Flash(Queue)
	elseif not FlashQueue and Is_Flashing(Queue) then 
		Stop_Flash(Queue)
	end
	
	return is_menu_open
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function  Update_Queue_Buttons()
	
	-- we are in the middle of the animation of a new patch being built so let's not mess up with the contents
	-- of the buttons!.
	if BuildingPatchData then 
		return
	end
	
	if not QButtons then 
		return
	end
	
	local player = Find_Player("local")
	if not player then return end
	
	local script = player.Get_Script()
	if not script then return end
	
	-- Update the state of the queue based on the current size and active patches!.
	local active_patches_data = script.Get_Async_Data("CachedActivePatchesData")
	
	if QueueSize < 1 then return end
	
	local button_idx = 1
	local ptypetodata
	
	if #active_patches_data > 0 then
		ptypetodata = script.Get_Async_Data("PatchTypeToData")
	end
	
	for i = 1, #active_patches_data do 	
		local data = active_patches_data[i]
		
		-- active_patches_data[1] = type
		-- active_patches_data[2] = is the patch object valid? (it may have expired)
		-- active_patches_data[3] = if a valid object and it has duration, what's its time left?	
		local p_type = data[1]
		
		if p_type then
			local button = QButtons[button_idx]
			button.Set_Hidden(false)
			
			local texture_name = p_type.Get_Icon_Name()
			button.Set_Texture(texture_name)
			button.Set_User_Data({i, texture_name})
	
			
			local patch_active_state = PATCH_STATE_ACTIVE
			local is_object_valid = data[2]
			if is_object_valid == true and data[3] >= 0 then 
				button.Set_Clock_Filled(data[3])
			elseif is_object_valid == false then
				button.Set_Clock_Filled(0.0)
				patch_active_state = PATCH_STATE_INACTIVE
			end

			button.Set_Button_Enabled(patch_active_state == PATCH_STATE_ACTIVE)
			
			local tooltip_data = {}
			-- floating tooltip data
			table.insert(tooltip_data, FloatingTooltipData)
			-- expanded tooltip data			
			local patch_data = ptypetodata[p_type]
			if patch_data then
				table.insert(tooltip_data, {'type', {p_type, patch_data.Cost, patch_data.Duration, false, false, false, false, false, false, false, false, false, patch_active_state}})
			else
				table.insert(tooltip_data, {'type', {p_type, false, false, false, false, false, false, false, false, false, false, false, patch_active_state}})
			end
			
			button.Set_Tooltip_Data({'patch_queue', tooltip_data})			
			
			button_idx = button_idx + 1
			
			if button_idx > #QButtons then
				break
			end
		end		
	end	
	
	for i = button_idx, #QButtons do
		local button = QButtons[i]
		
		if i <= QueueSize then
			button.Set_Hidden(false)
			-- Set them all as empty!
			button.Set_Texture("i_icon_n_patch_empty_slot.tga")
			button.Set_Clock_Filled(0.0)
			button.Set_User_Data(nil)
		else
			button.Set_Hidden(true)
		end		
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Patch_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Display_Patch_Menu(on_off)
	if CommandBarEnabled == false then return end
		
	if QueueSize >= 1 then		
		local curr_state = PatchMenu.Is_Menu_Open()
		
		if curr_state ~= on_off then
			BuildModeOn = on_off
			UpdatingSelection = true
		end
		
		PatchMenu.Display_Menu(on_off)	
		
		if UpdatingSelection == true then 
			if on_off == false and BuilderMenuOpen == true then 
				Mode = MODE_CONSTRUCTION
			end
			
			if Mode == MODE_CONSTRUCTION and CurrentSelectionNumTypes == 1 and #CurrentConstructorsList > 0 then 
				-- if there's only constructor(s) selected, we want to be able to go back to its build menu is no other selection order is issued.
				-- If more than one constructor and we go back with no new selection, then we will go back to the ability buttons.
				Setup_Mode_Construction()	
			else -- if there's more than one constructor or no constructor selected, then just update the selection mode dislpay.
				Mode = MODE_SELECTION
				Setup_Mode_Selection()
			end
			
			UpdatingSelection = false
		end
	elseif PatchMenu.Is_Menu_Open() == true or Queue.Get_Hidden() == false then
		-- make sure nothing is showing for we don't have any enabling structures!.
		Queue.Set_Hidden(true)
		PatchMenu.Display_Menu(false)		
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Faction_Specific_Menu_Open
-- ------------------------------------------------------------------------------------------------------------------
function Is_Faction_Specific_Menu_Open()
	if not TestValid(PatchMenu) then return false end
	return PatchMenu.Is_Menu_Open()
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Controller_Display_Specific_UI = nil
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
	Init_Patch_Queue_Manager = nil
	Is_Faction_Specific_Menu_Open = nil
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
	Toggle_Faction_Specific_Menu = nil
	Update_Faction_Specific_Tooltip_Data = nil
	Update_Patch_Queue_Manager = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
