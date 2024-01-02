-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Post_Battle_Hero_Panel.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Post_Battle_Hero_Panel.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 83716 $
--
--          $DateTime: 2007/09/13 14:25:24 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

function On_Init()
	MAX_POP_CAP = 70
	local _, _, width, _ = this.PopGroup.PopBar.Get_Bounds()
	Set_GUI_Variable("OriginalPopBarWidth", width)
	
	local type_buttons = Find_GUI_Components(this, "TypeButton")
	Set_GUI_Variable("TypeButtons", type_buttons)
	
	for index, button in pairs(type_buttons) do
		this.Register_Event_Handler("Mouse_Left_Down", button, On_Type_Button_Mouse_Down)
		button.Set_Tab_Order(index)
	end
end

function Update_Type_Buttons()
	local fleet = Get_GUI_Variable("FleetObject")
	if not fleet then
		return
	end
	
	local player = Find_Player("local")
	local buildable_units = player.Get_Available_Buildable_Unit_Types(fleet)
	--queue_index = buildable_units[i][5]
	buildable_units = Sort_Array_Of_Maps(buildable_units, 5)	
	
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
			button.Set_Enabled(true)
			button.Set_Hidden(type_count == 0)
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

function Find_Button_For_Unit(unit)
	local type_buttons = Get_GUI_Variable("TypeButtons")
	local unit_type = unit.Get_Type()
	
	for _, button in pairs(type_buttons) do
		if button.Get_User_Data() == unit_type then
			return button
		end
	end
	
	return nil	
end

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
			this.HeroPortrait.Set_Model(hero_script.Call_Function("Get_Head_Model"))
			this.HeroPortrait.Play_Randomized_Animation("notalk")
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

function Get_Fleet()
	return Get_GUI_Variable("FleetObject")
end

function On_Type_Button_Mouse_Down(_, button)
	button.Schedule_Drag(Get_GUI_Variable("FleetObject"))
end

function Refresh()
	Update_Type_Buttons()
end

Interface = {}
Interface.Set_Hero = Set_Hero
Interface.Get_Fleet = Get_Fleet
Interface.Refresh = Refresh
