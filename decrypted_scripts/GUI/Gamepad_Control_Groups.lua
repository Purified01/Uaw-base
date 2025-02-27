if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Control_Groups.lua#23 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Control_Groups.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Maria_Teruel $
--
--            $Change: 93041 $
--
--          $DateTime: 2008/02/08 22:12:37 $
--
--          $Revision: #23 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

function On_Init()

	this.Enable(true)

	Carousel = this.Carousel_ControlGroups	
	Carousel.Enable(true)
	Carousel.Set_Tab_Order(1)

	LocalPlayer = Find_Player("local")
	
	ControlGroupButtons = Find_GUI_Components(this.Carousel_ControlGroups, "CG_")
	ControlGroupButtonsUsed = { }

	this.Register_Event_Handler("Component_Unhidden", this, On_Component_Shown)
	
	for idx,button in pairs(ControlGroupButtons) do
		button.Set_User_Data(idx)
		-- Maria 02.07.2008
		-- Need to create the overlay prior to any kind of animation or its size will be messed up if we create it on the fly.
		button.Use_X_Overlay(false)
		this.Register_Event_Handler("Carousel_Gain_Focus", button, On_Change_Focus)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Control_Group_Button_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Double_Clicked", button, On_Control_Group_Button_Double_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Control_Group_Button_Right_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Left_Stick_Clicked", button, On_Control_Group_Button_Double_Clicked)		
	end
	
	-- Maria 02.08.2008
	-- Per task request: Add (Y) button functionality to disband (delete) the currently selected user-created control group
	this.Register_Event_Handler("Controller_Y_Button_Up", Carousel, On_Disband_User_Control_Group)		
	
	last_update_time = GetCurrentTime()
	
	this.Set_Hidden(true)
	
	Visible = false
	ExclusiveSelect = true

	-- this is used to keep track of the icons design wants to flash for the tutorials.
	ControlGroupIconsToFlash = {}
	CustomCGTooltipData = {'ui',{"TEXT_GAMEPAD_UI_USER_CREATED_CTRL_GROUP", false, "TEXT_GAMEPAD_UI_USER_CREATED_CTRL_GROUP_DESCRIPTION"}}
end

-- ---------------------------------------------------------------------------
-- On_Component_Shown
-- ---------------------------------------------------------------------------
function On_Component_Shown(event, source)
	-- initialize to true so the first control group select is always
	-- an exclusive selection
	ExclusiveSelect = true
	DebugMessage("CONTROL GROUP - exclusive selection ON")
end


-- ---------------------------------------------------------------------------
-- On_Disband_User_Control_Group
-- ---------------------------------------------------------------------------
function On_Disband_User_Control_Group(_, source)
	-- Get the current focused button.
	local cg_button = source.Get_Active_Component() 
	if TestValid(cg_button) then 
		local control_group = cg_button.Get_User_Data()
		LocalPlayer.Disband_User_Control_Group(control_group)
		ControlGroupIconsToFlash[control_group] = nil
	end
end

-- ---------------------------------------------------------------------------
-- On_Change_Focus
-- ---------------------------------------------------------------------------
function On_Change_Focus(event, source)
	DebugMessage("CONTROL GROUP - %i Selected", source.Get_User_Data())
	-- Display tooltip?
	local cg_index = source.Get_User_Data()	
	if LocalPlayer.Is_User_Control_Group(cg_index) then
		-- This is a player-created control group so we need to display a custom tooltip.
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Controller_Display_Tooltip_From_UI", nil, {CustomCGTooltipData})
	else
		local lead_object = LocalPlayer.Get_Control_Group_Tooltip_Object(cg_index)
		if TestValid(lead_object) then 
			local tooltip_data = {'object', {lead_object}}
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Controller_Display_Tooltip_From_UI", nil, {tooltip_data})
		end
	end
end

-- ---------------------------------------------------------------------------
-- On_Control_Group_Button_Clicked
-- ---------------------------------------------------------------------------
function On_Control_Group_Button_Clicked(event, source)
	if ExclusiveSelect then
		DebugMessage("CONTROL GROUP - %i clicked - exclusive selection ON", source.Get_User_Data())
	else
		DebugMessage("CONTROL GROUP - %i clicked - exclusive selection OFF", source.Get_User_Data())
	end

	local control_group = source.Get_User_Data()
	local add_to_selection = (not ExclusiveSelect) and (not LocalPlayer.Is_User_Control_Group(control_group)) -- only select user control groups
	LocalPlayer.Select_Control_Group(control_group, false, add_to_selection)  -- dont center camera, do add to selection
	ControlGroupIconsToFlash[control_group] = nil
	ExclusiveSelect = false -- after the first click this should always be false
end

-- ---------------------------------------------------------------------------
-- On_Control_Group_Button_Double_Clicked
-- ---------------------------------------------------------------------------
function On_Control_Group_Button_Double_Clicked(event, source)
	LocalPlayer.Select_Control_Group(source.Get_User_Data(), true, true) -- center camera, add to current selection
end

-- ---------------------------------------------------------------------------
-- On_Control_Group_Button_Right_Clicked
-- ---------------------------------------------------------------------------
function On_Control_Group_Button_Right_Clicked(event, source)
	local control_group = source.Get_User_Data()
	ControlGroupButtons[control_group].Highlight(false)
	LocalPlayer.Unselect_Control_Group(control_group)
	--Update_Control_Group_Text(control_group)
end

-- ---------------------------------------------------------------------------
-- Flash_Control_Group_Icon
-- ---------------------------------------------------------------------------
function Flash_Control_Group_Icon(cg_index)
	ControlGroupIconsToFlash[cg_index] = true
	
	if Visible then
		-- Refresh the scene.
		Refresh_Display()
	end
end

-- ---------------------------------------------------------------------------
-- Set_Quad_Texture_Source
-- ---------------------------------------------------------------------------
function Set_Quad_Texture_Source(quad_textures)

	Carousel.Set_Hidden(false)
	for _, button in pairs(ControlGroupButtons) do
		button.Set_Hidden(true)
	end

	for idx, texture in pairs(quad_textures) do
		local button = ControlGroupButtons[idx]
		button.Set_Hidden(false)
		button.Set_Texture(texture)
		ControlGroupButtonsUsed[idx] = button
	end		
	
	this.Focus_First()
	
	last_update_time = GetCurrentTime()
end


-- ---------------------------------------------------------------------------
-- Hide_Dialog
-- ---------------------------------------------------------------------------
function Hide_Dialog()
	this.Set_Hidden(true)
end

-- ---------------------------------------------------------------------------
-- Transverse_Gamepad_Control_Group
-- ---------------------------------------------------------------------------
function Transverse_Gamepad_Control_Group(go_forward)
	last_update_time = GetCurrentTime()
end

-- ---------------------------------------------------------------------------
-- Update_Flash_State
-- ---------------------------------------------------------------------------
function Update_Flash_State(ui_component, cg_index, reset_flash_state)
	if not TestValid(ui_component) then 
		return
	end
	
	-- do we have to flash this icon?
	if ControlGroupIconsToFlash[cg_index] then
		if reset_flash_state then 
			ControlGroupIconsToFlash[cg_index] = nil
			Stop_Flash(ui_component)
		elseif Visible and not Is_Flashing(ui_component) then
			Start_Flash(ui_component)
		end
	elseif Visible then
		Stop_Flash(ui_component)
	end
end

-- ---------------------------------------------------------------------------
-- Refresh_Display
-- ---------------------------------------------------------------------------
function Refresh_Display()
	for idx, button in pairs(ControlGroupButtonsUsed) do
		Update_Flash_State(button, idx)
	end
end


-- ---------------------------------------------------------------------------
-- On_Update
-- ---------------------------------------------------------------------------
function On_Update()
end


-- ---------------------------------------------------------------------------
-- Set_Visible
-- ---------------------------------------------------------------------------
function Set_Visible(on_off)
	this.Set_Hidden(not on_off)
	Visible = on_off
	if not Visible then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, {})
	end
	
	this.Enable(true)
	this.Focus_First()
end

-- ---------------------------------------------------------------------------
-- Update_Control_Group_Text
-- ---------------------------------------------------------------------------
function Update_Control_Group_Text(control_group)
	local button = ControlGroupButtons[control_group]
	button.Set_Text(string.format("%d / %d", LocalPlayer.Get_Control_Group_Selected_Unit_Count(control_group), LocalPlayer.Get_Control_Group_Size(control_group)))
end

-- ---------------------------------------------------------------------------
-- On_Control_Group_Selected
-- ---------------------------------------------------------------------------
function On_Control_Group_Selected(index, selected, unit_count)
	local button = ControlGroupButtons[index]
	button.Highlight(selected)
	if selected then
		button.Set_Text(string.format("%d / %d", unit_count, unit_count))
	else
		button.Set_Text(string.format("0 / %d", unit_count))
	end	
	
	-- Maria 02.07.2008 
	-- Per task request: In the control group menu, if more units can be added to the group,
	-- show the (A) button, if the group is ‘full’ (all units of type are selected in that group) show the (X) button to indicate deselect. 
	if selected then
		button.Use_X_Overlay(true)
	else
		button.Use_X_Overlay(false)
	end
end

-- ---------------------------------------------------------------------------
-- Set_Control_Group_Data
-- ---------------------------------------------------------------------------
function Set_Control_Group_Data(control_groups_sizes, control_groups_selected_unit_counts)
	local all_cg_empty = true
	
	for idx, size in pairs(control_groups_sizes) do
		if size > 0 then
			local button = ControlGroupButtons[idx]
			local selected_unit_count = control_groups_selected_unit_counts[idx]
		
			button.Set_Text(string.format("%d / %d", selected_unit_count,  size))
			
			-- Maria 02.07.2008 
			-- Per task request: In the control group menu, if more units can be added to the group,
			-- show the (A) button, if the group is ‘full’ (all units of type are selected in that group) show the (X) button to indicate deselect. 
			if selected_unit_count >= size then
				button.Use_X_Overlay(true)
			else
				button.Use_X_Overlay(false)
			end
		
			button.Highlight(size == selected_unit_count)
			all_cg_empty = false
		end
	end
	
	return not all_cg_empty
end

-- ---------------------------------------------------------------------------
-- Interface
-- ---------------------------------------------------------------------------
Interface = {}
Interface.Transverse_Gamepad_Control_Group = Transverse_Gamepad_Control_Group
Interface.Set_Quad_Texture_Source = Set_Quad_Texture_Source
Interface.Set_Control_Group_Selected = Set_Control_Group_Selected
Interface.Flash_Control_Group_Icon = Flash_Control_Group_Icon
Interface.Set_Visible = Set_Visible
Interface.On_Control_Group_Selected = On_Control_Group_Selected
Interface.Set_Control_Group_Data = Set_Control_Group_Data
Interface.Refresh_Display = Refresh_Display
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
	Update_Control_Group_Text = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
