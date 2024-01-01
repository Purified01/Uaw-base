-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Fleet_Panel.lua#28 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Fleet_Panel.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 83516 $
--
--          $DateTime: 2007/09/11 19:33:14 $
--
--          $Revision: #28 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("Global_Mode_Colors")


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	MAX_POP_CAP = 70
	Init_Global_Mode_Colors()

	MouseOverSceneHoverTime = 0.3

	local _, _, width, _ = this.PopBar.Get_Bounds()
	Set_GUI_Variable("OriginalPopBarWidth", width)

	Set_GUI_Variable("FleetObject", nil)
	Set_GUI_Variable("HeroObject", nil)
	Set_GUI_Variable("FleetCapacity", 0)
	Set_GUI_Variable("FleetPop", 0)
	Set_GUI_Variable("MouseOverButton", nil)
	
	local type_buttons = Find_GUI_Components(this.TypeButtonGroup, "TypeButton")
	for index, button in pairs(type_buttons) do
		this.Register_Event_Handler("Show_Hide_Info_Panel", button, On_Show_Hide_Info_Panel)
		button.Set_Tab_Order(index)
	end
	Set_GUI_Variable("TypeButtons", type_buttons)
	
	this.Register_Event_Handler("Mouse_On", this.FreeBuilderIcon, Mouse_On_Builder_Icon)
	this.Register_Event_Handler("Mouse_Off", this.FreeBuilderIcon, Mouse_Off_Builder_Icon)	
	this.Register_Event_Handler("Mouse_On", this.NoFreeBuilderIcon, Mouse_On_Builder_Icon)
	this.Register_Event_Handler("Mouse_Off", this.NoFreeBuilderIcon, Mouse_Off_Builder_Icon)		
end


function On_Show_Hide_Info_Panel(_, button, show_or_hide)
	if show_or_hide then
		Set_GUI_Variable("MouseOverButton", button)
	elseif Get_GUI_Variable("MouseOverButton") == button then
		Set_GUI_Variable("MouseOverButton", nil)
	end	
end

function Update_Mouse_Over_Button()
	local button = Get_GUI_Variable("MouseOverButton")
	if not TestValid(button) then
		this.BuySellGroup.Set_Hidden(true)	
		return
	end
	
	local cost = button.Get_Cost()
	local type = button.Get_Type()
	local sell_price = button.Get_Sell_Price()

	if cost > 0.0 then
		this.BuySellGroup.BuyText.Set_Hidden(false)
		this.BuySellGroup.BuyIcon.Set_Hidden(false)
		this.BuySellGroup.BuyText.Set_Text(Get_Localized_Formatted_Number(cost))
		if button.Get_Enough_Credits() then
			this.BuySellGroup.BuyText.Set_Tint(unpack(GOOD_PRICE_COLOR))
		else
			this.BuySellGroup.BuyText.Set_Tint(unpack(BAD_PRICE_COLOR))
		end
	else
		this.BuySellGroup.BuyText.Set_Hidden(true)
		this.BuySellGroup.BuyIcon.Set_Hidden(true)
	end
	
	if sell_price >= 0.0 then
		this.BuySellGroup.SellText.Set_Hidden(false)
		this.BuySellGroup.SellIcon.Set_Hidden(false)
		this.BuySellGroup.SellText.Set_Text(Get_Localized_Formatted_Number(sell_price))
		this.BuySellGroup.SellText.Set_Tint(unpack(GOOD_PRICE_COLOR))
	else
		this.BuySellGroup.SellText.Set_Hidden(true)
		this.BuySellGroup.SellIcon.Set_Hidden(true)
	end
	
	this.BuySellGroup.NoPopIcon.Set_Hidden(button.Get_Enough_Pop())
	this.BuySellGroup.DependencyIcon.Set_Hidden(button.Get_Dependencies_Satisfied())
	
	this.BuySellGroup.Set_Hidden(false)	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	Update_Button_Types()
	Update_Fleet_Contents()
	Update_Mouse_Over_Button()
	
	local mouse_over_builder_time = Get_GUI_Variable("MouseOnBuilderIconTime")
	if mouse_over_builder_time and GetCurrentTime() - mouse_over_builder_time > MouseOverSceneHoverTime then
		if this.NoFreeBuilderIcon.Get_Hidden() then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {this.FreeBuilderIcon.Get_Tooltip_Data()})
		else
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {this.NoFreeBuilderIcon.Get_Tooltip_Data()})
		end			
	end
end

function Update_Button_Types()
	local hero = Get_GUI_Variable("HeroObject")
	local player = hero.Get_Owner()
	local type_buttons = Get_GUI_Variable("TypeButtons")
	
	if not TestValid(hero) then
		return
	end
	
	local buildable_units = player.Get_Available_Buildable_Unit_Types(hero.Get_Parent_Object())
	if not buildable_units then
		return
	end
		
	--queue_index = buildable_units[i][5]
	buildable_units = Sort_Array_Of_Maps(buildable_units, 5)
	
	local button_index = 1
	for _, unit_description_table in pairs(buildable_units) do
		type_buttons[button_index].Set_Type(unit_description_table[1])
		type_buttons[button_index].Set_Dependencies_Satisfied(unit_description_table[2])		
		type_buttons[button_index].Set_Enough_Credits(unit_description_table[3])
		type_buttons[button_index].Set_Enough_Pop(unit_description_table[4])
		type_buttons[button_index].Set_Cost(unit_description_table[6])
		type_buttons[button_index].Set_Build_Time(unit_description_table[7])
		if unit_description_table[12] then
			type_buttons[button_index].Set_Additional_Lock_Info(nil)
		else
			type_buttons[button_index].Set_Additional_Lock_Info(Get_Game_Text("TEXT_NO_AVAILABLE_SUPPLY_LINE"))
		end		
		
		type_buttons[button_index].Generate_Tooltip()
		button_index = button_index + 1
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Update_Fleet_Contents()
	local fleet = Get_GUI_Variable("FleetObject")
	if not fleet then
		return
	end
	
	--Start at 2 to skip the hero
	local fleet_total_units = fleet.Get_Contained_Object_Count()
	local fleet_population = 0
	local hero = Get_GUI_Variable("HeroObject")
	
	for unit_index = 2, fleet_total_units do
		local unit = fleet.Get_Fleet_Unit_At_Index(unit_index)	
		if TestValid(unit) then
			local button = Find_Button_For_Unit(unit)
			if button then
				button.Add_Unit(unit)	
			end	
		end	
	end
	
	local fleet_capacity = Get_GUI_Variable("FleetCapacity")
	local fleet_pop = fleet.Get_Number_Fleet_Slots_Occupied()
	Set_GUI_Variable("FleetPop", fleet_pop)
	this.PopBar.Set_Filled(fleet_pop / fleet_capacity)
	
	local pop_text = Get_Game_Text("TEXT_FRACTION")
	Replace_Token(pop_text, Get_Localized_Formatted_Number(fleet_pop), 0)
	Replace_Token(pop_text, Get_Localized_Formatted_Number(fleet_capacity), 1)
	this.PopText.Set_Text(pop_text)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Find_Button_For_Unit(unit)
	local type_buttons = Get_GUI_Variable("TypeButtons")
	local unit_type = unit.Get_Type()
	local unit_script = unit.Get_Script()
	if unit_script ~= nil and GUI_Does_Object_Have_Lua_Behavior(unit, "UnitInProduction") then
		unit_type = unit_script.Call_Function("Get_Unit_Type")
	end
	
	for _, button in pairs(type_buttons) do
		if button.Get_Type() == unit_type then
			return button
		end
	end
	
	return nil
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Open()
	this.Set_State("Open")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Close()
	this.Set_State("Closed")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Is_Open()
	return this.Get_Current_State_Name() ~= "Closed"
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Hero(hero_object)

	if Get_GUI_Variable("HeroObject") == hero_object then
		return
	end

	if not TestValid(hero_object) then 
		return
	end
	
	-- do not set the fleet panel if the hero is the science officer!
	local obj_script = hero_object.Get_Script()
	if obj_script then 
		if obj_script.Get_Variable("IS_SCIENTIST") == true then 
			return
		end
	end
		
	if not TestValid(hero_object) then
		Set_GUI_Variable("FleetObject", nil)
		Set_GUI_Variable("HeroObject", nil)
		Close()
	else
		Set_GUI_Variable("HeroObject", hero_object)
		
		this.HeroName.Set_Text(hero_object.Get_Type().Get_Display_Name())
		local hero_script = hero_object.Get_Script()
		if hero_script then
			this.HeroPortrait.Set_Model(hero_script.Call_Function("Get_Head_Model"))
			this.HeroPortrait.Play_Randomized_Animation("notalk")
		end
		
		local free_units = hero_object.Get_Type().Get_Type_Value("Starting_Tactical_Units")
		if free_units and #free_units > 0 then
			this.FreeBuilderIcon.Set_Hidden(false)
			this.NoFreeBuilderIcon.Set_Hidden(true)
			this.FreeBuilderIcon.Set_Tooltip_Data({"ui", {"TEXT_GLOBAL_BUILDER_IN_FLEET"}})
		else
			this.FreeBuilderIcon.Set_Hidden(true)
			this.NoFreeBuilderIcon.Set_Hidden(false)
			this.NoFreeBuilderIcon.Set_Tooltip_Data({"ui", {"TEXT_GLOBAL_NO_BUILDER_IN_FLEET"}})
		end
		Set_GUI_Variable("MouseOnBuilderIconTime", nil)

		local fleet_object = hero_object.Get_Parent_Object()
		if TestValid(fleet_object) then 
			Set_GUI_Variable("FleetObject", fleet_object)
			Set_GUI_Variable("FleetCapacity", fleet_object.Get_Fleet_Capacity())
		end
		
		local width_fraction = Get_GUI_Variable("FleetCapacity") / MAX_POP_CAP
		local x, y, _, height = this.PopBar.Get_Bounds()
		local actual_pop_bar_width = width_fraction * Get_GUI_Variable("OriginalPopBarWidth")
		this.PopBar.Set_Bounds(x, y, actual_pop_bar_width, height)
		this.PopFrame.Set_Bounds(x, y, actual_pop_bar_width, height)
		
		local type_buttons = Get_GUI_Variable("TypeButtons")
		for _, button in pairs(type_buttons) do
			button.Set_Hero(hero_object)
		end
	end
end

function Get_Hero()
	return Get_GUI_Variable("HeroObject")
end

function Mouse_On_Builder_Icon()
	Set_GUI_Variable("MouseOnBuilderIconTime", GetCurrentTime())
end

function Mouse_Off_Builder_Icon()
	Set_GUI_Variable("MouseOnBuilderIconTime", nil)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, {})
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE TABLE!!!!
-- -----------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Open = Open
Interface.Close = Close
Interface.Is_Open = Is_Open
Interface.Set_Hero = Set_Hero
Interface.Get_Hero = Get_Hero
