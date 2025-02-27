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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Novus_Patch_Queue_Manager.lua
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
function Init_Queue()

	QButtons = Find_GUI_Components(this, "PatchesQueueButton")
	for index, button in pairs(QButtons) do
		button.Set_Hidden(true)
		
		-- this is a progress clock so it should be green!
		button.Set_Clock_Tint({0.0, 1.0, 0.0, 170.0/255.0})
		
		-- Maria 11.29.2007:  Per bug #376: Player should not be able to navigate the patch slots (Novus Faction). Player should not be able to navigate the patch slots when the patch menu is 
		--  accessed (it gives players the illusion of choice, when they really can only push things ‘through’ both slots)
		--button.Set_Tab_Order(index)
		this.Register_Event_Handler("Animation_Finished", button, On_Animation_Finished)
	end
	
	QueueSize = 0
	BuildingPatchData = nil
	
	PATCH_STATE_ACTIVE = Declare_Enum(0)
	PATCH_STATE_INACTIVE = Declare_Enum()
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
-- Process_Patch_Queueing_Complete
-- ------------------------------------------------------------------------------------------------------------------
function Process_Patch_Queueing_Complete()
	BuildingPatchData = nil	
	Update_Queue_Buttons()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Build_Patch_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Build_Patch_Button_Clicked(player, p_type)
	
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
	
	return true
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Lost
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Lost(event, source)
	if not Is_Controller_Event() then return end
	Focus.Set_Hidden(true)
	
	local tooltip_data = source.Get_Tooltip_Data()
	if tooltip_data then
		End_Tooltip()
	end
	
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
	
	local tooltip_data = source.Get_Tooltip_Data()
	if tooltip_data then
		Display_Tooltip(tooltip_data, true) -- true: is controller tooltip from a UI element.
	end
	
	-- Start the animation on the queue buttons
	for _, button in pairs(QButtons) do
		button.Play_Animation("Focus_Gained", false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Size
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_Size(new_size)
	QueueSize = new_size
	Update_Queue_State()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_State
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_State()
	local hide_queue = (QueueSize < 1)
	
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

-- ---------------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Manager
-- ---------------------------------------------------------------------------------------------------------------------------
function Update_Queue_Manager(player_credits_changed)
	-- Update the data displayed by the queue buttons, based on the contents of the queue.
	Update_Queue_Buttons()	
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
			
			local patch_data = ptypetodata[p_type]
			if patch_data then
				button.Set_Tooltip_Data({'type', {p_type, patch_data.Cost, patch_data.Duration, false, false, false, false, false, false, false, false, false, patch_active_state}})			
			end
			
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
			button.Set_Tooltip_Data({'ui', {"TEXT_GAMEPAD_PATCH_QUEUE_SLOT_EMPTY"}})
			button.Set_Clock_Filled(0.0)
			button.Set_User_Data(nil)
		else
			button.Set_Hidden(true)
		end		
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Size
-- ------------------------------------------------------------------------------------------------------------------
function Get_Size() 
	return QueueSize
end

-- ------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Get_Size = Get_Size
Interface.Update_Queue_Size = Update_Queue_Size
Interface.Build_Patch_Button_Clicked = On_Build_Patch_Button_Clicked
Interface.Process_Patch_Queueing_Complete = Process_Patch_Queueing_Complete
Interface.Update_Queue_Manager = Update_Queue_Manager
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
	On_Focus_Gained = nil
	On_Focus_Lost = nil
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
