if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Post_Battle_Hero_Panel.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Post_Battle_Hero_Panel.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")


-- -----------------------------------------------------------------------------
-- On_Init
-- -----------------------------------------------------------------------------
function On_Init()
	
	MAX_POP_CAP = 70
	
	TRAVERSE_DIRECTION_UP = Declare_Enum(0)
	TRAVERSE_DIRECTION_RIGHT = Declare_Enum()
	TRAVERSE_DIRECTION_DOWN = Declare_Enum()
	TRAVERSE_DIRECTION_LEFT = Declare_Enum()
	
	local _, _, width, _ = this.PopGroup.PopBar.Get_Bounds()
	Set_GUI_Variable("OriginalPopBarWidth", width)
	
	-- Maria 11.01.2007
	-- This quad is used to represent the selection of this panel when navigating the unit management screen.
	if TestValid(this.SelectedQuad) then 
		this.SelectedQuad.Set_Hidden(true)
	end
	
	local type_buttons = Find_GUI_Components(this, "TypeButton")
	Set_GUI_Variable("TypeButtons", type_buttons)
	
	for index, button in pairs(type_buttons) do
		this.Register_Event_Handler("Selectable_Icon_Gained_Focus", button, On_Button_Key_Focus_Gained)
		
		-- We want to handle the stick movement ourselves so that we can wrap around and things like that.
		this.Register_Event_Handler("Controller_Left_Stick_Move", button, On_Left_Stick_Move)
		
		-- With the A button we manage the transfer of units.
		this.Register_Event_Handler("Controller_A_Button_Up", button, On_Add_Unit)
		
		-- With the X button we remove the worst units in the fleet and put them into the unit pool.
		this.Register_Event_Handler("Controller_X_Button_Up", button, On_Remove_Unit)
		
		-- Given that the overlay overlaps other parts of the UI we don't want the buttons to display it
		-- whenever they gain focus.
		button.Hide_A_Button_Overlay()
		
		-- We will play the proper SFX sound here since it is allowed to click on disabled buttons and this may
		-- also yield a valid transfer.
		button.Supress_Press_Sounds()
		
		button.Set_Tab_Order(index)
	end
	
	Set_GUI_Variable("TypesCount", 0)
	Set_GUI_Variable("CurrentButtonIndex", 0)
	Set_GUI_Variable("Selected", false)
	
	STICK_DEAD_ZONE = 0.2
end


-- -----------------------------------------------------------------------------
-- On_Remove_Unit.
--  Remove the worst unit (ie the one with the lowest health) from this
-- fleet and put it into the unit pool!.
-- -----------------------------------------------------------------------------
function On_Remove_Unit(_, source)
	if not TestValid(source) then 
		return
	end
	
	-- Get the type of unit we are interested in.
	local unit_type = source.Get_User_Data()
	if not unit_type then 
		return
	end
	
	-- Now we have to find a unit of this type in the unit pool
	-- or in any of the other hero fleets ( see (*) above ).
	-- Since this information lies in the Post Battle scene, we raise
	-- an event here with all the information needed to proceed.
	this.Get_Containing_Scene().Raise_Event("Remove_Unit_Of_Type", this.Get_Containing_Component(), {unit_type})
end


-- -----------------------------------------------------------------------------
-- On_Add_Unit.
-- (*)  (A) Button should add available unit types (from the unit pool or 
-- other Hero Fleets) to the currently focused on Hero Fleet.
-- Rule: draw from unit pool first, then from other Hero Fleets from 
-- top to bottom.
-- -----------------------------------------------------------------------------
function On_Add_Unit(_, source)
	if not TestValid(source) then 
		return
	end
	
	-- Get the type of unit we are interested in.
	local unit_type = source.Get_User_Data()
	if not unit_type then 
		return
	end
	
	-- Now we have to find a unit of this type in the unit pool
	-- or in any of the other hero fleets ( see (*) above ).
	-- Since this information lies in the Post Battle scene, we raise
	-- an event here with all the information needed to proceed.
	this.Get_Containing_Scene().Raise_Event("Add_Unit_Of_Type", this.Get_Containing_Component(), {unit_type})
end

-- -----------------------------------------------------------------------------
-- On_Left_Stick_Move
-- We want to handle the stick movement here so that we can 
-- wrap around the scene whenever possible.
-- -----------------------------------------------------------------------------
function On_Left_Stick_Move(_, _, pos_x, pos_y, degrees)
	-- We only care about left-right moves.
	if not Get_GUI_Variable("Selected") then
		return
	end

	-- UP
	if (degrees > 305 or degrees < 45) and pos_y  > STICK_DEAD_ZONE then 
		Traverse(TRAVERSE_DIRECTION_UP)
		return
	end
	
	-- RIGHT
	if (degrees > 45 and degrees < 135) and pos_x  > STICK_DEAD_ZONE then 
		Traverse(TRAVERSE_DIRECTION_RIGHT)
		return
	end
	
	-- DOWN
	if (degrees > 135 and degrees < 225) and pos_y  < -STICK_DEAD_ZONE then 
		Traverse(TRAVERSE_DIRECTION_DOWN)
		return
	end
	
	-- LEFT
	if (degrees < 305 and degrees > 225) and pos_x  < -STICK_DEAD_ZONE then 
		Traverse(TRAVERSE_DIRECTION_LEFT)
		return
	end	
end


-- -----------------------------------------------------------------------------
-- Traverse_Left
-- -----------------------------------------------------------------------------
function Traverse( direction )

	-- Starting at the currently focused button we have to find the next valid
	-- button (ie it has to be an enabled button) to our left.
	if direction == TRAVERSE_DIRECTION_LEFT or direction == TRAVERSE_DIRECTION_RIGHT then
	
		local current_index = Get_GUI_Variable("CurrentButtonIndex")
		if current_index == 0 then 	
			MessageBox("The index should not be 0")
			current_index = 1
		end

		local button_list = Get_GUI_Variable("TypeButtons")
		-- Make sure we have a valid list.
		if not button_list or #button_list < 1 then
			return
		end
		
		local success = false 
		if direction == TRAVERSE_DIRECTION_LEFT then 
			success = Get_Previous(current_index, Get_GUI_Variable("TypesCount"))	
		else
			success = Get_Next(current_index, Get_GUI_Variable("TypesCount"))	
		end
		
		if not success then
			MessageBox("Hero_Panel::Traverse: AHHHHH")
		end
		
	elseif direction == TRAVERSE_DIRECTION_UP or direction == TRAVERSE_DIRECTION_DOWN then
		-- The parent scene will handle the up and down events!.
		this.Get_Containing_Scene().Raise_Event("Select_Panel", this.Get_Containing_Component(), {direction})
	end	
end


-- -----------------------------------------------------------------------------
-- Get_Previous
-- -----------------------------------------------------------------------------
function Get_Previous( start_index , max_number )
	local new_index = start_index - 1
	-- Update the index properly.
	if new_index == 0 then
		-- If we are at the first button, point to the last button.
		new_index = max_number		
	end
	
	if new_index > max_number or new_index < 0 then
		return false
	end
	
	local button_list = Get_GUI_Variable("TypeButtons")
	local button = button_list[new_index]
	if TestValid(button) then 
		button.Set_Key_Focus()
		Set_GUI_Variable("CurrentButtonIndex", new_index)
		return true
	end
	
	return false
end

-- -----------------------------------------------------------------------------
-- Traverse_Right
-- -----------------------------------------------------------------------------
function Traverse_Right()
	-- Starting at the currently focused button we have to find the next valid
	-- button (ie it has to be an enabled button) to our left.
	local current_index = Get_GUI_Variable("CurrentButtonIndex")
	
	local button_list = Get_GUI_Variable("TypeButtons")
	-- Make sure we have a valid list.
	if not button_list or #button_list < 1 then
		return
	end
	
	local success = Get_Next(current_index, #button_list)	
	if not success then
		MessageBox("AHHHHH")
	end
end



-- -----------------------------------------------------------------------------
-- Get_Next
-- -----------------------------------------------------------------------------
function Get_Next( start_index , max_number )
	local new_index = start_index + 1
	-- Update the index properly.
	if new_index > max_number then
		-- If we are at the first button, point to the last button.
		new_index = 1		
	end
	
	if new_index > max_number or new_index < 0 then
		return false
	end
	
	local button_list = Get_GUI_Variable("TypeButtons")
	local button = button_list[new_index]
	if TestValid(button) then 
		button.Set_Key_Focus()
		Set_GUI_Variable("CurrentButtonIndex", new_index)
		return true
	end
	
	return false
end


-- -----------------------------------------------------------------------------
-- On_Button_Key_Focus_Gained
-- -----------------------------------------------------------------------------
function On_Button_Key_Focus_Gained(_, source)
	local select_panel = ( not Get_GUI_Variable("Selected") )
	local unit_type = source.Get_User_Data()
	--let the parent scene know we now have focus.
	this.Get_Containing_Scene().Raise_Event_Immediate("Panel_Focus_Gained", this.Get_Containing_Component(), {select_panel, unit_type})	
end


-- -----------------------------------------------------------------------------
-- Update_Type_Buttons
-- -----------------------------------------------------------------------------
function Update_Type_Buttons()
	local fleet = Get_GUI_Variable("FleetObject")
	if not fleet then
		return
	end
	
	local player = Find_Player("local")
	local buildable_units = player.Get_Available_Buildable_Unit_Types(fleet)
	--queue_index = buildable_units[i][5]
	buildable_units = Sort_Array_Of_Maps(buildable_units, 5)	
	
	if Get_GUI_Variable("TypesCount") == 0 then 
		Set_GUI_Variable("TypesCount", #buildable_units)
	end
	
	--Start at 2 to skip the hero
	local fleet_total_units = fleet.Get_Contained_Object_Count()
	local types_table = {}
	for unit_index = 2, fleet_total_units do
		local unit = fleet.Get_Fleet_Unit_At_Index(unit_index)	
		if TestValid(unit) then
			local unit_type = unit.Get_Type()
			if types_table[unit_type] then
				types_table[unit_type] = types_table[unit_type] + 1
			else
				types_table[unit_type] = 1
			end
		end	
	end
	
	local type_buttons = Get_GUI_Variable("TypeButtons")
	for _, button in pairs(type_buttons) do
		button.Set_Hidden(true)
	end
		
	for index, type_data in pairs(buildable_units) do
		local button = type_buttons[index]
		local unit_type = type_data[1]
		local type_count = types_table[unit_type]
		if not type_count then
			type_count = 0
		end
		if button then
			button.Set_User_Data(unit_type)
			button.Set_Texture(unit_type.Get_Icon_Name())
			button.Set_Text(Get_Localized_Formatted_Number(type_count))
			button.Set_Hidden(false)
			-- Maria 11.02.2007
			-- We want to display all available types.  However, those that do not exist in the
			-- fleet should bre grayed out.
			button.Set_Button_Enabled(type_count ~= 0)
		end
	end	
	
	local fleet_pop = fleet.Get_Number_Fleet_Slots_Occupied()
	local fleet_capacity = Get_GUI_Variable("FleetCapacity")
	local capacity_used = fleet_pop / fleet_capacity
	this.PopGroup.PopBar.Set_Filled(capacity_used)
	
	local pop_text = Get_Game_Text("TEXT_CURRENT_POP_CAP")
	Replace_Token(pop_text, Get_Localized_Formatted_Number(fleet_pop), 0)
	Replace_Token(pop_text, Get_Localized_Formatted_Number(fleet_capacity), 1)
	this.PopGroup.PopText.Set_Text(pop_text)	
end

-- -----------------------------------------------------------------------------
-- Set_Hero
-- -----------------------------------------------------------------------------
function Set_Hero(hero_object)
	if Get_GUI_Variable("HeroObject") == hero_object then
		return
	end
		
	if not TestValid(hero_object) then
		Set_GUI_Variable("FleetObject", nil)
		Set_GUI_Variable("HeroObject", nil)
	else
		Set_GUI_Variable("HeroObject", hero_object)
		
		this.HeroName.Set_Text(hero_object.Get_Type().Get_Display_Name())
		local hero_script = hero_object.Get_Script()
		if hero_script then
			this.AALogic_HeroPortrait.HeroPortrait.Set_Model(hero_script.Get_Async_Data("HeadModel"))
			this.AALogic_HeroPortrait.HeroPortrait.Play_Randomized_Animation("notalk")
		end
		
		local fleet_object = hero_object.Get_Parent_Object()
		if TestValid(fleet_object) then 
			Set_GUI_Variable("FleetObject", fleet_object)
			Set_GUI_Variable("FleetCapacity", fleet_object.Get_Fleet_Capacity())
		
			local width_fraction = Get_GUI_Variable("FleetCapacity") / MAX_POP_CAP
			local x, y, _, height = this.PopGroup.PopBar.Get_Bounds()
			local actual_pop_bar_width = width_fraction * Get_GUI_Variable("OriginalPopBarWidth")
			this.PopGroup.PopBar.Set_Bounds(x, y, actual_pop_bar_width, height)
			this.PopGroup.PopFrame.Set_Bounds(x, y, actual_pop_bar_width, height)
		end
		
		Update_Type_Buttons()
	end
end

-- -----------------------------------------------------------------------------
-- Get_Fleet
-- -----------------------------------------------------------------------------
function Get_Fleet()
	return Get_GUI_Variable("FleetObject")
end

-- -----------------------------------------------------------------------------
-- Refresh
-- -----------------------------------------------------------------------------
function Refresh()
	Update_Type_Buttons()
end

-- -----------------------------------------------------------------------------
-- Set_Selected
-- -----------------------------------------------------------------------------
function Set_Selected(on_off)
	if not TestValid(this.SelectedQuad) then 
		return
	end
	this.SelectedQuad.Set_Hidden(not on_off)
	Set_GUI_Variable("Selected", on_off)
	if on_off then 
		-- Always start focused on the next button.
		local types = Get_GUI_Variable("TypesCount")
		if types > 1 then	
			-- Focus on the first valid button
			Get_Next(types, types)	
		end
	end
end


-- -----------------------------------------------------------------------------
-- INTERFACE
-- -----------------------------------------------------------------------------
Interface = {}
Interface.Set_Hero = Set_Hero
Interface.Get_Fleet = Get_Fleet
Interface.Refresh = Refresh
Interface.Set_Selected = Set_Selected
Interface.Get_Unit_Of_Type = Get_Unit_Of_Type
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
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Traverse_Right = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
