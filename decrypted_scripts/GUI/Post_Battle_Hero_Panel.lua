if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[208] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Post_Battle_Hero_Panel.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Post_Battle_Hero_Panel.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 94057 $
--
--          $DateTime: 2008/02/26 14:18:49 $
--
--          $Revision: #10 $
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
			button.Set_Button_Enabled(true)
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
			local hero_model = hero_script.Get_Async_Data("HeadModel")
			if not hero_model and Is_Non_Render_Thread_Save_Game() then
				hero_model = hero_script.Call_Function("Get_Head_Model")
			end
			this.HeroPortrait.Set_Model(hero_model)
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
	Find_Button_For_Unit = nil
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
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
