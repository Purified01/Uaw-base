if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[14] = true
LuaGlobalCommandLinks[148] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Post_Battle_Scene.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Post_Battle_Scene.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Init
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()

	TAB_ORDER_HERO_PANELS = 1
	
	TRAVERSE_DIRECTION_UP = Declare_Enum(0)
	TRAVERSE_DIRECTION_RIGHT = Declare_Enum()
	TRAVERSE_DIRECTION_DOWN = Declare_Enum()
	TRAVERSE_DIRECTION_LEFT = Declare_Enum()

	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Done)
	
	Player = Find_Player("local")
	HeroPanels = Find_GUI_Components(this, "HeroPanel")
	PanelToListIndex = {}
	for index, panel in pairs(HeroPanels) do
		panel.Set_Hidden(true)
		
		panel.Set_Tab_Order(TAB_ORDER_HERO_PANELS + index)
		
		-- Whenever a panel gains focus, it should be marked as selected and all the other panels as 
		-- deselected.
		this.Register_Event_Handler("Panel_Focus_Gained", panel, On_Panel_Focus_Gained)
		
		-- We are traversing the UI with the stick so we need to tell the parent scene that it needs to select
		-- the next/previous panel based on the direction of the traversal.
		this.Register_Event_Handler("Select_Panel", panel, On_Select_Panel)
		
		-- The player wants to transfer a unit into the fleet associated to the panel that is currently selected.
		this.Register_Event_Handler("Add_Unit_Of_Type", panel, Add_Unit_Of_Type_To_Fleet)
		
		-- The player wants to remove a unit from the fleet associated to the panel that is currently selected.
		-- All removed units go into the 'Left behind' unit pool.
		this.Register_Event_Handler("Remove_Unit_Of_Type", panel, Remove_Unit_Of_Type_From_Fleet)		
		
		-- We use this table to access panels by their index in the panels list instead of the UI objects.
		PanelToListIndex[panel] = index
	end
	
	-- Keeps track of the index associated to the panel that is currently selected (focused on)
	SelectedPanelIndex = nil
	
	FleetCount = 0
	Region = Get_Conflict_Location()
	local fleet_count = Region.Get_Number_Of_Fleets_Contained()
	AnyHeroes = false
	local hero_panel_index = 1
	StandingFleet = nil
	for i = 1, fleet_count do
		local fleet = Region.Get_Fleet_At(i - 1)
		if TestValid(fleet) and fleet.Get_Owner() == Player then
			if fleet.Is_Striker_Fleet() then
				local hero = fleet.Get_Fleet_Hero()
				local panel = HeroPanels[hero_panel_index]
				hero_panel_index = hero_panel_index + 1
				if TestValid(panel) then
					panel.Set_Hero(hero)
					panel.Set_Hidden(false)
					AnyHeroes = true
					FleetCount = FleetCount + 1
					panel.Set_Tab_Order(TAB_ORDER_HERO_PANELS + hero_panel_index)
				end
			else
				StandingFleet = fleet
			end
		end
	end
	
	if not AnyHeroes then
		return
	end				
	
	StandingFleet.Clear_Fleet_Ghosts()
	StandingFleet.Sort_Units_For_Salvage()
	
	for _, panel in pairs(HeroPanels) do
		local fleet = panel.Get_Fleet()
		if TestValid(fleet) and TestValid(StandingFleet) then
			fleet.Attempt_Recover_Ghosts(StandingFleet)	
			fleet.Clear_Fleet_Ghosts()
		end
	end	
	
	for _, panel in pairs(HeroPanels) do
		local fleet = panel.Get_Fleet()
		if TestValid(fleet) and TestValid(StandingFleet) then
			fleet.Auto_Fill_To_Pop_Cap(StandingFleet)
		end
		panel.Refresh()
	end		

	TypeButtons = Find_GUI_Components(this.UnitPoolGroup, "TypeButton")
	Update_Type_Buttons()
	
	-- this displays the hints for how to use transports and research trees in the masari campaign
 	if Is_Campaign_Game() and not Is_Scenario_Campaign() then
 		if true then
 			PGHintSystemDefs_Init()
 			PGHintSystem_Init()
 			Register_Hint_Context_Scene(this)			-- Set the scene to which independant hints will be attached.
 			Add_Independent_Hint(130)
 		end
 	end
	
	this.Register_Event_Handler("Hint_Activated", nil, On_Hint_Activated)
	this.Focus_First()	
end


-- -------------------------------------------------------------------------------
-- On_Hint_Activated
-- -------------------------------------------------------------------------------
function On_Hint_Activated(_, _, active_inactive)
	if not active_inactive then
		this.Focus_First()	
	end
end

-- -------------------------------------------------------------------------------
-- Remove_Unit_Of_Type_From_Fleet
-- -------------------------------------------------------------------------------
function Remove_Unit_Of_Type_From_Fleet(_, source_panel, type_to_remove)
	return Internal_Remove_Unit_Of_Type_From_Fleet(source_panel, type_to_remove, false) -- false = not a query but a command.
end

-- -------------------------------------------------------------------------------
-- Internal_Remove_Unit_Of_Type_From_Fleet
-- -------------------------------------------------------------------------------
function Internal_Remove_Unit_Of_Type_From_Fleet(source_panel, type_to_remove, query_only)
	if not TestValid(source_panel) or not type_to_remove then
		return false
	end
	
	-- SANITY CHECK: THE SOURCE PANEL HAS TO COINCIDE WITH THE 
	-- CURRENTLY SELECTED PANEL!!!!
	if PanelToListIndex[source_panel] ~= SelectedPanelIndex then
		MessageBox("The source panel doesn't coincide with the currently selected panel!!!!")
		return false
	end
	
	-- If we can find a unit of the specified type we will transfer it into the 
	-- UNITS POOL!! (or StandingFleet).
	local source_fleet = source_panel.Get_Fleet()
	
	if TestValid(source_fleet) and TestValid(StandingFleet) then
		local unit_to_remove = Find_Unit_Of_Type_To_Remove(type_to_remove, source_fleet)
		if TestValid(unit_to_remove) then 
			local can_remove = StandingFleet.Dispatch_Units(unit_to_remove, query_only)
			if not can_remove then
				if not query_only then 
					Play_Pop_Cap_Full_SFX()
					dest_panel.Stop_Animation()
					dest_panel.Play_Animation("No_Pop_Available", false)
				else
					return false
				end
			else
				if not query_only then 
					Update_Controller_Buttons_Display_For_Type(type_to_remove)
					Play_SFX_Event("GUI_Generic_Button_Select")
				else
					return true
				end
			end
		else
			if not query_only then 
				Play_SFX_Event("GUI_Generic_Bad_Sound")
			else
				return false
			end
		end	
	else 
		return false
	end
	
	if query_only then
		return true
	end
	
	for _, panel in pairs(HeroPanels) do
		panel.Refresh()
	end	
	
	Update_Type_Buttons()
end

-- -------------------------------------------------------------------------------
-- Add_Unit_Of_Type_To_Fleet
-- -------------------------------------------------------------------------------
function Add_Unit_Of_Type_To_Fleet(_, dest_panel, transfer_type)
	return Internal_Add_Unit_Of_Type_To_Fleet(dest_panel, transfer_type, false) -- false = not a query but a command.
end


-- -------------------------------------------------------------------------------
-- Internal_Add_Unit_Of_Type_To_Fleet
-- -------------------------------------------------------------------------------
function Internal_Add_Unit_Of_Type_To_Fleet(dest_panel, transfer_type, query_only)
	
	if not TestValid(dest_panel) or not transfer_type then
		return false
	end
	
	-- SANITY CHECK: THE SOURCE PANEL HAS TO COINCIDE WITH THE 
	-- CURRENTLY SELECTED PANEL!!!!
	if PanelToListIndex[dest_panel] ~= SelectedPanelIndex then
		MessageBox("The source panel doesn't coincide with the currently selected panel!!!!")
		return false
	end
	
	-- If we can find a unit of the specified type we will transfer it to 
	-- the source panel.
	local dest_fleet = dest_panel.Get_Fleet()
	-- Start the search with the StandingFleet (unit pool)
	local source_fleet = StandingFleet
	
	if TestValid(source_fleet) and TestValid(dest_fleet) then
		local transfer_unit = Get_Unit_To_Transfer(dest_panel, transfer_type, source_fleet, dest_fleet)
		
		if not TestValid(transfer_unit) then 
			if not query_only then 
				Play_SFX_Event("GUI_Generic_Bad_Sound")
			end
			
			return false
		else
			local can_add = dest_fleet.Dispatch_Units(transfer_unit, query_only)
			if not can_add then
				if not query_only then 
					Play_Pop_Cap_Full_SFX()
					dest_panel.Stop_Animation()
					dest_panel.Play_Animation("No_Pop_Available", false)
				else
					return false
				end				
			else
				if not query_only then 
					Update_Controller_Buttons_Display_For_Type(transfer_type)
					Play_SFX_Event("GUI_Generic_Button_Select")
				else
					return true
				end
			end
		end
	else
		return false
	end
	
	-- let's make sure we don't keep going if we are just querying!
	if query_only then
		return true
	end
	
	for _, panel in pairs(HeroPanels) do
		panel.Refresh()
	end	
	
	Update_Type_Buttons()
end

-- -------------------------------------------------------------------------------
-- Get_Unit_To_Transfer
-- -------------------------------------------------------------------------------
function Get_Unit_To_Transfer(dest_panel, transfer_type, source_fleet, dest_fleet)
	local transfer_unit = Find_Unit_Of_Type_To_Tramsfer(transfer_type, source_fleet, dest_fleet)
	if not TestValid(transfer_unit) then
		-- Search for a unit in the hero fleets (if any)
		for _, panel in pairs(HeroPanels) do
			if not panel.Get_Hidden() and panel ~= dest_panel then
				source_fleet = panel.Get_Fleet()
				if TestValid(source_fleet) then 
					transfer_unit = Find_Unit_Of_Type_To_Tramsfer(transfer_type, source_fleet, dest_fleet)
					if TestValid(transfer_unit) then 
						break
					end
				end
			end
		end
	end
	
	return transfer_unit
end

-- -------------------------------------------------------------------------------
-- On_Select_Panel
-- -------------------------------------------------------------------------------
function On_Select_Panel(_, source, direction)
	if not TestValid(source) then 
		return
	end
	
	if FleetCount and FleetCount <= 1 then
		-- no selection choice!
		return
	end
	
	-- SANITY CHECK!!!
	-- The source should be the currently selected panel
	local panel_idx = PanelToListIndex[source]
	if panel_idx then
		if panel_idx ~= SelectedPanelIndex then 
			MessageBox("The source is not the currently selected panel!!!!")
			return
		end
	else
		MessageBox("The source doesn't belong to PanelToListIndex")
		return
	end
	
	local success = false
	-- this changed becuase the top most panel is number 3 and the bottom is 1
	-- so this order had to change to reflect the swapping of the hero panels
	if direction ==		TRAVERSE_DIRECTION_DOWN then
		success = Traverse_Panels_Up(SelectedPanelIndex)
	elseif direction == TRAVERSE_DIRECTION_UP then
		success = Traverse_Panels_Down(SelectedPanelIndex)
	end
	
	if not success then
		MessageBox("On_Select_Panel::AHHHHH")
	end
end


-- -------------------------------------------------------------------------------
-- Traverse_Panels_Up
-- -------------------------------------------------------------------------------
function Traverse_Panels_Up( curr_idx )
	local new_index = curr_idx - 1
	if new_index == 0 then 
		new_index = #HeroPanels
	end
	
	if new_index < 0 or new_index > #HeroPanels then
		return false
	end
	
	local panel = HeroPanels[new_index]
	if TestValid(panel) then 
		-- if this panel is hidden, is not valid
		if panel.Get_Hidden() then 
			return Traverse_Panels_Up(new_index)
		else
			-- this panel is valid!
			Select_Panel_By_Index(new_index)
			return true
		end
	end
	
	return false	
end


-- -------------------------------------------------------------------------------
-- Traverse_Panels_Down
-- -------------------------------------------------------------------------------
function Traverse_Panels_Down( curr_idx )
	local new_index = curr_idx + 1
	if new_index > #HeroPanels then 
		new_index = 1
	end
	
	if new_index < 0 or new_index > #HeroPanels then
		return false
	end
	
	local panel = HeroPanels[new_index]
	if TestValid(panel) then 
		-- if this panel is hidden, is not valid
		if panel.Get_Hidden() then 
			return Traverse_Panels_Down(new_index)
		else
			-- this panel is valid!
			Select_Panel_By_Index(new_index)
			return true
		end
	end
	
	return false	
end

-- -------------------------------------------------------------------------------
-- On_Panel_Focus_Gained
-- -------------------------------------------------------------------------------
function On_Panel_Focus_Gained(_, source, select_panel, focused_unit_type)
	if not TestValid(source) then 
		return
	end
	if select_panel then
		Select_Panel_By_Index(PanelToListIndex[source])	
	end
	
	-- Now, we must update the A and X buttons display based on the button that
	-- has focus!.
	if focused_unit_type then
		Update_Controller_Buttons_Display_For_Type(focused_unit_type)
	end
end

-- -------------------------------------------------------------------------------
-- Update_Controller_Buttons_Display_For_Type
-- -------------------------------------------------------------------------------
function Update_Controller_Buttons_Display_For_Type(unit_type)
	if not unit_type then 
		return
	end
	
	-- Get the fleet this unit belongs to (it should be the fleet associated to the 
	-- currently selected panel)
	local panel = HeroPanels[SelectedPanelIndex]
	if panel then
		local add_unit = Internal_Add_Unit_Of_Type_To_Fleet(panel, unit_type, true) -- true == we are only querying!, no transfer required.
		this.AddUnitDisplay.Set_Hidden(not add_unit)
		
		local remove_unit = Internal_Remove_Unit_Of_Type_From_Fleet(panel, unit_type, true)	-- true == we are only querying!, no transfer required.
		this.RemoveUnitDisplay.Set_Hidden(not remove_unit)
	end
end

-- -------------------------------------------------------------------------------
-- Select_Panel
-- -------------------------------------------------------------------------------
function Select_Panel_By_Index( panel_idx )
	if panel_idx < 0 or panel_idx > #HeroPanels then
		return
	end
	
	if SelectedPanelIndex then 
		if SelectedPanelIndex == panel_idx then 
			-- this panel is already selected.
			return
		end
		HeroPanels[SelectedPanelIndex].Set_Selected(false)
	end
	
	SelectedPanelIndex = panel_idx
	HeroPanels[SelectedPanelIndex].Set_Selected(true)	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Done
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function On_Done()
	this.End_Modal()
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Type_Buttons
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Type_Buttons()
	if not TestValid(StandingFleet) then
		return
	end
	
	local buildable_units = Player.Get_Available_Buildable_Unit_Types(StandingFleet)
	--queue_index = buildable_units[i][5]
	buildable_units = Sort_Array_Of_Maps(buildable_units, 5)	
	
	local fleet_total_units = StandingFleet.Get_Contained_Object_Count()
	local types_table = {}
	for unit_index = 1, fleet_total_units do
		local unit = StandingFleet.Get_Fleet_Unit_At_Index(unit_index)	
		if TestValid(unit) then
			local unit_type = unit.Get_Type()
			if types_table[unit_type] then
				types_table[unit_type] = types_table[unit_type] + 1
			else
				types_table[unit_type] = 1
			end
		end	
	end
	
	for _, button in pairs(TypeButtons) do
		button.Set_Hidden(true)
	end
		
	for index, type_data in pairs(buildable_units) do
		local button = TypeButtons[index]
		local unit_type = type_data[1]
		local type_count = types_table[unit_type]
		
		if not type_count then
			type_count = 0
		end
		
		if button then
			button.Set_User_Data(unit_type)
			button.Set_Texture(unit_type.Get_Icon_Name())
			button.Set_Text(tostring(type_count))
			button.Set_Button_Enabled(true)
			button.Set_Hidden(type_count == 0)
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Find_Unit_Of_Type_To_Tramsfer
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Find_Unit_Of_Type_To_Tramsfer(type, source, dest)
	local best_unit = nil
	local best_health = nil
	local fleet_total_units = source.Get_Contained_Object_Count()
	for unit_index = 1, fleet_total_units do
		local unit = source.Get_Fleet_Unit_At_Index(unit_index)	
		if TestValid(unit) then
			local unit_type = unit.Get_Type()
			if unit_type == type then
				if not TestValid(best_unit) then
					best_unit = unit
					best_health = unit.Get_Health()
				elseif dest == StandingFleet and unit.Get_Health() < best_health then
					best_unit = unit
					best_health = unit.Get_Health()
				elseif dest ~= StandingFleet and unit.Get_Health() > best_health then
					best_unit = unit
					best_health = unit.Get_Health()
				end					
			end
		end	
	end
	
	return best_unit
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Find_Unit_Of_Type_To_Remove
-- We remove the worst units (ie the ones with the lowest health) first.
-- ALL REMOVED UNITS GET ADDED TO THE STANDING FLEET (I.E. UNITS POOL)
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Find_Unit_Of_Type_To_Remove(type, source)
	local best_unit = nil
	local best_health = nil
	local fleet_total_units = source.Get_Contained_Object_Count()
	for unit_index = 1, fleet_total_units do
		local unit = source.Get_Fleet_Unit_At_Index(unit_index)	
		if TestValid(unit) then
			local unit_type = unit.Get_Type()
			if unit_type == type then
				if not TestValid(best_unit) then
					best_unit = unit
					best_health = unit.Get_Health()
				elseif unit.Get_Health() < best_health then
					best_unit = unit
					best_health = unit.Get_Health()
				end					
			end
		end	
	end
	
	return best_unit
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Finalize_Init
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Finalize_Init()
	return AnyHeroes
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Scenario_Campaign
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Scenario_Campaign()
	local global_script = Get_Game_Mode_Script("Strategic")
	if TestValid(global_script) then
		return global_script.Get_Async_Data("IsScenarioCampaign")
	else
		return false
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Play_Pop_Cap_Full_SFX
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Play_Pop_Cap_Full_SFX()
	if Is_Player_Of_Faction(Player, "ALIEN") then
		Play_SFX_Event("HCO_POPCAP_1")
	elseif Is_Player_Of_Faction(Player, "NOVUS") then
		Play_SFX_Event("NCO_POPCAP_1")
	elseif Is_Player_Of_Faction(Player, "MASARI") then
		Play_SFX_Event("MCO_POPCAP_1")
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- --------------------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Finalize_Init = Finalize_Init


	
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	Commit_Profile_Values = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
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
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
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
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
