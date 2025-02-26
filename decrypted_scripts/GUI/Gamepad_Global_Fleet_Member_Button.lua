if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Global_Fleet_Member_Button.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Global_Fleet_Member_Button.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 93543 $
--
--          $DateTime: 2008/02/16 17:05:57 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Init
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
		
	-- Maria 11.02.2007
 	-- The Key_Focus_<Gained/Lost> event will be eaten up by the Selectable icon so, if we 
 	-- want to handle the event, we need to instead register for the mouse over event issued from it!.
 	this.Register_Event_Handler("Mouse_Over_Selectable_Icon", this.Button, On_Focus_On_Button)
 	this.Register_Event_Handler("Mouse_Off_Selectable_Icon", this.Button, On_Focus_Off_Button)


	this.Register_Event_Handler("Controller_A_Button_Up", this, On_Click)
	this.Register_Event_Handler("Controller_X_Button_Up", this, On_Right_Click)
	
	this.Button.Set_Tab_Order(1)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Update
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
	local should_show_info = Get_GUI_Variable("HasKeyFocus")
	if should_show_info ~= now_showing_info then
		this.Get_Containing_Scene().Raise_Event("Show_Hide_Info_Panel", this.Get_Containing_Component(), {should_show_info})
		Set_GUI_Variable("ShowingInfo", should_show_info)
	end
	
	--We don't want to ever see the health bars
	this.HealthStack.Set_Hidden(true)
	--this.HealthStack.Set_Hidden(not should_show_info or not Get_GUI_Variable("HasUnits") or Get_GUI_Variable("AllHealthy"))
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Click
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
		this.InvalidBuildIcon.Bring_To_Front()
		return
	end

	--Get building!
	local build_started = false
	local build_type = Get_GUI_Variable("BuildType")
	local current_region = Get_GUI_Variable("CurrentRegion")
	local hero_fleet = Get_GUI_Variable("HeroFleet")

	Send_GUI_Network_Event("Network_Global_Begin_Production", { Find_Player("local"), current_region, build_type, hero_fleet })
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Right_Click
-- -----------------------------------------------------------------------------------------------------------------------------------------
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
			local completion_time = unit.Get_Strategic_Build_Completion_Time()
			if completion_time > max_completion_time then
				best_unit = unit
				max_completion_time = completion_time
			end
		end
	end
	
	if TestValid(best_unit) then
		Send_GUI_Network_Event("Network_Global_Cancel_Production", {best_unit})
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
		Send_GUI_Network_Event("Network_Sell_Object", {best_unit})
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound")
	end
	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Update_Construction_Progress
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Update_Construction_Progress()
	local under_construction = Get_GUI_Variable("UnderConstruction")
	local uc_count = 0
	local max_completion_time = 0.0
	local for_removal = {}
	for _, unit in pairs(under_construction) do
		if TestValid(unit) then
			local completion_time = unit.Get_Strategic_Build_Completion_Time()
			
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


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Update_Units
-- -----------------------------------------------------------------------------------------------------------------------------------------
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
-- On_Focus_On_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Focus_On_Button()
	Set_GUI_Variable("HasKeyFocus", true)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Focus_Off_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Focus_Off_Button()
	Set_GUI_Variable("HasKeyFocus", false)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Type
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
-- Set_Hero
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
-- Set_New_Build_Enabled
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_New_Build_Enabled(onoff)
	local has_units = Get_GUI_Variable("HasUnits")
	local has_uc = Get_GUI_Variable("HasUC")
	
	local final_button_state = onoff or has_units or has_uc
	this.Button.Set_Button_Enabled(final_button_state)
	if not final_button_state then
		this.Button.Clear_Cost()
		this.Button.Set_Text("")
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_New_Build_Enabled
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_New_Build_Enabled()
	return Get_GUI_Variable("DependenciesSatisfied") and Get_GUI_Variable("EnoughCredits") and Get_GUI_Variable("EnoughPop")	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Add_Unit
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Add_Unit(unit)
	if not unit.Has_Behavior(166) then
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


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Cost
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Cost(cost)
	Set_GUI_Variable("BuildCost", cost)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Build_Time
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Build_Time(build_time)
	Set_GUI_Variable("BuildTime", build_time)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Additional_Lock_Info
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Additional_Lock_Info(info)
	Set_GUI_Variable("AdditionalLockInfo", info)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Generate_Tooltip
-- -----------------------------------------------------------------------------------------------------------------------------------------
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


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Cost
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Cost()
	return Get_GUI_Variable("BuildCost")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Sell_Price
-- -----------------------------------------------------------------------------------------------------------------------------------------
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


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Dependencies_Satisfied
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Dependencies_Satisfied(satisfied)
	Set_GUI_Variable("DependenciesSatisfied", satisfied)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Enough_Credits
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Enough_Credits(enough)
	Set_GUI_Variable("EnoughCredits", enough)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Enough_Pop
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Enough_Pop(enough)
	Set_GUI_Variable("EnoughPop", enough)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Dependencies_Satisfied
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Dependencies_Satisfied()
	return Get_GUI_Variable("DependenciesSatisfied")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Enough_Credits
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Enough_Credits()
	return Get_GUI_Variable("EnoughCredits")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Enough_Pop
-- -----------------------------------------------------------------------------------------------------------------------------------------
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
