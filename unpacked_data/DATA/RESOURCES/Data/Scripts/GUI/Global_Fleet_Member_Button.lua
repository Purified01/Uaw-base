-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Fleet_Member_Button.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Fleet_Member_Button.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 84965 $
--
--          $DateTime: 2007/09/27 14:57:18 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Init()	
	Set_Type(nil)
	Set_Hero(nil)
	Set_GUI_Variable("CurrentRegion", nil)
	Set_GUI_Variable("Units", {})
	Set_GUI_Variable("UnderConstruction", {})
	Set_GUI_Variable("AllHealthy", true)
	
	this.Register_Event_Handler("Selectable_Icon_Clicked", this.Button, On_Click)
	this.Register_Event_Handler("Selectable_Icon_Double_Clicked", this.Button, On_Click)
	this.Register_Event_Handler("Selectable_Icon_Right_Clicked", this.Button, On_Right_Click)
	this.Register_Event_Handler("Selectable_Icon_Right_Double_Clicked", this.Button, On_Right_Click)
	this.Register_Event_Handler("Mouse_On", this.Button, On_Mouse_On_Button)
	this.Register_Event_Handler("Mouse_Off", this.Button, On_Mouse_Off_Button)
	this.Register_Event_Handler("Key_Focus_Gained", this.Button, On_Focus_On_Button)
	this.Register_Event_Handler("Key_Focus_Lost", this.Button, On_Focus_Off_Button)
	
	this.Button.Set_Tab_Order(1)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	Set_GUI_Variable("CurrentRegion", nil)
	local hero_object = Get_GUI_Variable("HeroObject")
	local build_type = Get_GUI_Variable("BuildType")
	local hero_fleet = Get_GUI_Variable("HeroFleet")

	if not TestValid(hero_object) then
		return
	end
	
	if not TestValid(build_type) then
		return
	end
	
	if not TestValid(hero_fleet) then
		return
	end
	
	Set_GUI_Variable("CurrentRegion", hero_fleet.Get_Parent_Object())
	
	Update_Construction_Progress()
	Update_Units()
	
	--Calling this will refresh the visual state of the button
	Set_New_Build_Enabled(Get_New_Build_Enabled())
	
	--Update the display of extended info about this button
	local now_showing_info = Get_GUI_Variable("ShowingInfo")
	local should_show_info = Get_GUI_Variable("HasMouseFocus") or Get_GUI_Variable("HasKeyFocus")
	if should_show_info ~= now_showing_info then
		this.Get_Containing_Scene().Raise_Event("Show_Hide_Info_Panel", this.Get_Containing_Component(), {should_show_info})
		Set_GUI_Variable("ShowingInfo", should_show_info)
	end
	this.HealthStack.Set_Hidden(not should_show_info or not Get_GUI_Variable("HasUnits") or Get_GUI_Variable("AllHealthy"))
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Click()
	--Don't allow management of enemy fleets when spying
	local hero_object = Get_GUI_Variable("HeroObject")
	if not TestValid(hero_object) or hero_object.Get_Owner() ~= Find_Player("local") then
		return
	end

	if not Get_New_Build_Enabled() then
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
		this.InvalidBuildIcon.Play_Animation("InvalidBuild", false)
		this.InvalidBuildIcon.Set_Animation_Frame(0.0)
		return
	end

	--Get building!
	local build_started = false
	local build_type = Get_GUI_Variable("BuildType")
	local current_region = Get_GUI_Variable("CurrentRegion")
	local hero_fleet = Get_GUI_Variable("HeroFleet")

	if TestValid(hero_fleet) and TestValid(build_type) and TestValid(current_region) then
		build_started = Global_Begin_Production(Find_Player("local"), current_region, build_type, hero_fleet)
	end
	
	if build_started then
		Play_SFX_Event("GUI_Generic_Button_Select")
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end
end

function On_Right_Click()
	--Don't allow management of enemy fleets when spying
	local hero_object = Get_GUI_Variable("HeroObject")
	if not TestValid(hero_object) or hero_object.Get_Owner() ~= Find_Player("local") then
		return
	end

	local best_unit
	local max_completion_time = -1.0
	local under_construction = Get_GUI_Variable("UnderConstruction")
	for _, unit in pairs(under_construction) do
		if TestValid(unit) then
			local completion_time = 0.0
			local unit_script = unit.Get_Script()
			if unit_script ~= nil then
				completion_time = unit_script.Call_Function("Get_Completion_Time")
			end
			if completion_time > max_completion_time then
				best_unit = unit
				max_completion_time = completion_time
			end
		end
	end
	
	if TestValid(best_unit) then
		local unit_script = best_unit.Get_Script()
		Cancel_Production_At_Location_Of_Unit(unit_script.Call_Function("Get_Build_Location"), unit_script.Call_Function("Get_Queue_ID"), unit_script.Call_Function("Get_Build_ID"))
		return
	end
	
	local min_health = 2.0
	local units = Get_GUI_Variable("Units")
	for _, unit in pairs(units) do
		if TestValid(unit) then
			local health = unit.Get_Health()
			if health < min_health then
				best_unit = unit
				min_health = health
			end
		end
	end
	
	if TestValid(best_unit) then
		best_unit.Sell()
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound")
	end
	
end

function Update_Construction_Progress()
	local under_construction = Get_GUI_Variable("UnderConstruction")
	local uc_count = 0
	local max_completion_time = 0.0
	local for_removal = {}
	for _, unit in pairs(under_construction) do
		if TestValid(unit) then
			local completion_time = 0.0
			local unit_script = unit.Get_Script()
			if unit_script ~= nil then
				completion_time = unit_script.Call_Function("Get_Completion_Time")
			end
			
			if completion_time > max_completion_time then
				if max_completion_time == 0.0 or completion_time < 1.0 then
					max_completion_time = completion_time
				end
			elseif completion_time > 0.0 and max_completion_time == 1.0 then
				max_completion_time = completion_time
			end
			uc_count = uc_count + 1	
		else
			table.insert(for_removal, unit)
		end
	end
	
	if uc_count > 0 then
		this.UCCount.Set_Hidden(false)
		this.UCCount.Set_Text(Get_Localized_Formatted_Number(uc_count))
		this.Button.Set_Clock_Filled(max_completion_time)
		Set_GUI_Variable("HasUC", true)
	else
		this.UCCount.Set_Hidden(true)
		this.Button.Set_Clock_Filled(0.0)
		Set_GUI_Variable("HasUC", false)
	end
	
	for _, bad_unit in pairs(for_removal) do
		under_construction[bad_unit] = nil
	end
	Set_GUI_Variable("UnderConstruction", under_construction)
end

function Update_Units()
	local units = Get_GUI_Variable("Units")
	local for_removal = {}
	local health_100_count = 0
	local health_80_count = 0
	local health_60_count = 0
	local health_40_count = 0
	local health_20_count = 0
	for _, unit in pairs(units) do
		if TestValid(unit) then
			local health = unit.Get_Health()
			if health == 1.0 then
				health_100_count = health_100_count + 1
			elseif health >= 0.8 then
				health_80_count = health_80_count + 1
			elseif health >= 0.6 then
				health_60_count = health_60_count + 1
			elseif health >= 0.4 then
				health_40_count = health_40_count + 1
			else
				health_20_count = health_20_count + 1
			end
		else 
			table.insert(for_removal, unit)
		end
	end
	
	this.HealthStack.Health100Label.Set_Text(Get_Localized_Formatted_Number(health_100_count))
	this.HealthStack.Health80Label.Set_Text(Get_Localized_Formatted_Number(health_80_count))
	this.HealthStack.Health60Label.Set_Text(Get_Localized_Formatted_Number(health_60_count))
	this.HealthStack.Health40Label.Set_Text(Get_Localized_Formatted_Number(health_40_count))
	this.HealthStack.Health20Label.Set_Text(Get_Localized_Formatted_Number(health_20_count))
	
	local total_unit_count = health_100_count + health_80_count + health_60_count + health_40_count + health_20_count
	this.Button.Set_Text(Get_Localized_Formatted_Number(total_unit_count))
	Set_GUI_Variable("HasUnits", total_unit_count > 0)
	
	for _, bad_unit in pairs(for_removal) do
		units[bad_unit] = nil
	end	
	Set_GUI_Variable("Units", units)
	
	if total_unit_count == health_100_count then
		Set_GUI_Variable("AllHealthy", true)
	else
		Set_GUI_Variable("AllHealthy", false)
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_On_Button()
	Set_GUI_Variable("HasMouseFocus", true)
end

function On_Mouse_Off_Button()
	Set_GUI_Variable("HasMouseFocus", false)
end

function On_Focus_On_Button()
	Set_GUI_Variable("HasKeyFocus", true)
end

function On_Focus_Off_Button()
	Set_GUI_Variable("HasKeyFocus", false)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Type(build_type)
	Set_GUI_Variable("BuildType", build_type)
	
	if not build_type then
		this.Set_Hidden(true)
		return
	else
		this.Set_Hidden(false)
	end
	
	local cost = build_type.Get_Build_Cost()
	this.Button.Set_Texture(build_type.Get_Icon_Name())
		
	this.Button.Set_Selected(false)	
end

function Get_Type()
	return Get_GUI_Variable("BuildType")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Hero(hero_object)
	Set_GUI_Variable("HeroObject", hero_object)
	if TestValid(hero_object) then
		Set_GUI_Variable("HeroFleet", hero_object.Get_Parent_Object())
	else
		Set_GUI_Variable("HeroFleet", nil)
	end
	Set_Type(nil)
	Set_GUI_Variable("CurrentRegion", nil)
	Set_GUI_Variable("Units", {})
	Set_GUI_Variable("UnderConstruction", {})	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_New_Build_Enabled(onoff)
	local has_units = Get_GUI_Variable("HasUnits")
	local has_uc = Get_GUI_Variable("HasUC")
	
	local final_button_state = onoff or has_units or has_uc
	this.Button.Set_Enabled(final_button_state)
	if not final_button_state then
		this.Button.Clear_Cost()
		this.Button.Set_Text("")
	end
end

function Get_New_Build_Enabled()
	return Get_GUI_Variable("DependenciesSatisfied") and Get_GUI_Variable("EnoughCredits") and Get_GUI_Variable("EnoughPop")	
end

function Add_Unit(unit)
	if unit.Get_Type() == Get_GUI_Variable("BuildType") then
		local units = Get_GUI_Variable("Units")
		units[unit] = unit
		Set_GUI_Variable("Units", units)
	else
		--Must be an under production unit
		local under_construction = Get_GUI_Variable("UnderConstruction")
		under_construction[unit] = unit
		Set_GUI_Variable("UnderConstruction", under_construction)
	end
end

function Set_Cost(cost)
	Set_GUI_Variable("BuildCost", cost)
end

function Set_Build_Time(build_time)
	Set_GUI_Variable("BuildTime", build_time)
end

function Set_Additional_Lock_Info(info)
	Set_GUI_Variable("AdditionalLockInfo", info)
end

function Generate_Tooltip()
	local tooltip_data = {}
	tooltip_data[1] = Get_GUI_Variable("BuildType")
	tooltip_data[2] = Get_GUI_Variable("BuildCost")
	tooltip_data[3] = Get_GUI_Variable("BuildTime")
	tooltip_data[4] = false
	tooltip_data[5] = false
	tooltip_data[6] = false
	tooltip_data[7] = false
	tooltip_data[8] = false
	tooltip_data[9] = false
	tooltip_data[10] = false
	tooltip_data[11] = false
	tooltip_data[12] = Get_GUI_Variable("AdditionalLockInfo")
	
	this.Button.Set_Tooltip_Data({'type', tooltip_data})	
end

function Get_Cost()
	return Get_GUI_Variable("BuildCost")
end

function Get_Sell_Price()
	local has_units = Get_GUI_Variable("HasUnits")
	local has_uc = Get_GUI_Variable("HasUC")
	if has_uc then
		return Get_GUI_Variable("BuildCost")
	elseif has_units then
		local type = Get_Type()
		return type.Get_Type_Value("Build_Cost_Credits") * type.Get_Type_Value("Strategic_Sell_Percentage")
	else
		return -1.0
	end
end

function Set_Dependencies_Satisfied(satisfied)
	Set_GUI_Variable("DependenciesSatisfied", satisfied)
end

function Set_Enough_Credits(enough)
	Set_GUI_Variable("EnoughCredits", enough)
end

function Set_Enough_Pop(enough)
	Set_GUI_Variable("EnoughPop", enough)
end

function Get_Dependencies_Satisfied()
	return Get_GUI_Variable("DependenciesSatisfied")
end

function Get_Enough_Credits()
	return Get_GUI_Variable("EnoughCredits")
end

function Get_Enough_Pop()
	return Get_GUI_Variable("EnoughPop")
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE TABLE!!!!
-- -----------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Type = Set_Type
Interface.Set_Hero = Set_Hero
Interface.Set_Type = Set_Type
Interface.Get_Type = Get_Type
Interface.Add_Unit = Add_Unit
Interface.Set_Cost = Set_Cost
Interface.Get_Cost = Get_Cost
Interface.Set_Build_Time = Set_Build_Time
Interface.Set_Dependencies_Satisfied = Set_Dependencies_Satisfied
Interface.Set_Enough_Credits = Set_Enough_Credits
Interface.Set_Enough_Pop = Set_Enough_Pop
Interface.Set_Additional_Lock_Info = Set_Additional_Lock_Info
Interface.Get_Dependencies_Satisfied = Get_Dependencies_Satisfied
Interface.Get_Enough_Credits = Get_Enough_Credits
Interface.Get_Enough_Pop = Get_Enough_Pop
Interface.Generate_Tooltip = Generate_Tooltip
Interface.Get_Sell_Price = Get_Sell_Price
