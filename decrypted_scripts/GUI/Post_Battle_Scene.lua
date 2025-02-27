if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[14] = true
LuaGlobalCommandLinks[148] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Post_Battle_Scene.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Post_Battle_Scene.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")

function On_Init()

	this.Register_Event_Handler("Button_Clicked", this.Done, On_Done_Clicked)
	this.Done.Set_Tab_Order(Declare_Enum(0))
	
	Player = Find_Player("local")
	HeroPanels = Find_GUI_Components(this, "HeroPanel")
	for _, panel in pairs(HeroPanels) do
		this.Register_Event_Handler("Drag_Drop", panel, On_Drop)
		panel.Set_Hidden(true)
		panel.Set_Tab_Order(Declare_Enum())
	end
	
	Region = Get_Conflict_Location()
	local fleet_count = Region.Get_Number_Of_Fleets_Contained()
	AnyHeroes = false
	local hero_panel_index = 1
	StandingFleet = Player.Get_Tactical_Standing_Fleet()
	if not StandingFleet then
		return
	end
	
	for i = 1, fleet_count do
		local fleet = Region.Get_Fleet_At(i - 1)
		if TestValid(fleet) and fleet.Get_Owner() == Player then
			if fleet.Is_Striker_Fleet() then
				local hero = fleet.Get_Fleet_Hero()
				local panel = HeroPanels[hero_panel_index]
				hero_panel_index = hero_panel_index + 1
				if panel then
					panel.Set_Hero(hero)
					panel.Set_Hidden(false)
					AnyHeroes = true
				end
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
	for index, button in pairs(TypeButtons) do
		this.Register_Event_Handler("Mouse_Left_Down", button, On_Type_Button_Mouse_Down)
		this.Register_Event_Handler("Drag_Drop", button, On_Drop)
		button.Set_Tab_Order(Declare_Enum())		
	end

	this.Register_Event_Handler("Drag_Drop", this.UnitPoolGroup, On_Drop)

	Update_Type_Buttons()
	
	-- this displays the hints for how to use transports and research trees in the masari campaign
 	if Is_Campaign_Game() and not Is_Scenario_Campaign() then
 		if true then
 			PGHintSystemDefs_Init()
 			PGHintSystem_Init()
 			--local scene = Get_Game_Mode_GUI_Scene()
 			Register_Hint_Context_Scene(this)			-- Set the scene to which independant hints will be attached.
 			
 			Add_Independent_Hint(130)
 		end
 	end
end

------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Generic_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Generic_Button_Select")
	end
end


function On_Done_Clicked()
	this.End_Modal()
end


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
			--button.Set_Button_Enabled(type_count > 0)
		end
	end
end

function On_Type_Button_Mouse_Down(_, button)
	if button.Is_Enabled() then
		button.Schedule_Drag(StandingFleet)
	end
end

function On_Drop(_, dropped_on, dragged_data, dragged_ui)
	local source_fleet = dragged_data
	local dest_fleet = nil
	if TestValid(dropped_on.Get_Fleet) then
		dest_fleet = dropped_on.Get_Fleet()
	else
		dest_fleet = StandingFleet
	end
	
	if dest_fleet == source_fleet then
		return
	end
	
	local transfer_type = dragged_ui.Get_User_Data()
	if TestValid(source_fleet) and TestValid(dest_fleet) then
		local transfer_unit = Find_Unit_Of_Type_To_Tramsfer(transfer_type, source_fleet, dest_fleet)
		if not dest_fleet.Dispatch_Units(transfer_unit, false) then
			Play_Pop_Cap_Full_SFX()
			dropped_on.Stop_Animation()
			dropped_on.Play_Animation("No_Pop_Available", false)
		end
	end
	
	for _, panel in pairs(HeroPanels) do
		panel.Refresh()
	end	
	
	Update_Type_Buttons()
end

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

function Finalize_Init()
	return AnyHeroes
end

function Is_Scenario_Campaign()
	local global_script = Get_Game_Mode_Script("Strategic")
	if TestValid(global_script) then
		return global_script.Get_Async_Data("IsScenarioCampaign")
	else
		return false
	end
end

function Play_Pop_Cap_Full_SFX()
	if Is_Player_Of_Faction(Player, "ALIEN") then
		Play_SFX_Event("HCO_POPCAP_1")
	elseif Is_Player_Of_Faction(Player, "NOVUS") then
		Play_SFX_Event("NCO_POPCAP_1")
	elseif Is_Player_Of_Faction(Player, "MASARI") then
		Play_SFX_Event("MCO_POPCAP_1")
	end
end

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
