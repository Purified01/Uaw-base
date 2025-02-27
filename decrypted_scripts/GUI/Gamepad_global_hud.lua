if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[124] = true
LuaGlobalCommandLinks[188] = true
LuaGlobalCommandLinks[40] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[132] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[123] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[119] = true
LuaGlobalCommandLinks[126] = true
LuaGlobalCommandLinks[156] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[186] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_global_hud.lua#20 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_global_hud.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Kircher $
--
--            $Change: 93391 $
--
--          $DateTime: 2008/02/14 16:09:21 $
--
--          $Revision: #20 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Gamepad_Global_Mode_Colors")
require("Gamepad_HeroIcons")
require("PGUICommands")
require("PGHintSystem")
require("KeyboardMappingsHandler")
require("PGColors")
require("Gamepad_Contexts_Data")
require("Gamepad_Global_Regions_Connectivity")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.
CommandCenterType = nil
CursorOverObject = nil
Buttons = {}

MiniMapSectorNameToIndexMap = {}

ResearchTreesInitialized = false

-- UI Modes
MODE_NONE = nil
MODE_CC_PRODUCTION = nil
MODE_CC_RESOURCE = nil
MODE_CC_RESEARCH = nil
CurrentMode = MODE_NONE

-- Maria 04.11.2006 -- for milestone 4
ResearchQuadUpdated = false

FactionName = nil

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MODES INITIALIZATION
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Modes()
	MODE_NONE = { name = 'None', action = nil, allowed = nil }
	CurrentMode = MODE_NONE
end

	
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()

	--Tab order constants
	TAB_ORDER_HERO_BUTTONS = 1
	TAB_ORDER_MEGAWEAPON_BUTTONS = 50

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	SelectedObject = nil
	CommandCenterType = nil
	CursorOverObject = nil
	Buttons = {}
	
	MiniMapSectorNameToIndexMap = {}

	MODE_NONE = nil
	MODE_CC_PRODUCTION = nil
	MODE_CC_RESOURCE = nil
	MODE_CC_RESEARCH = nil
	CurrentMode = MODE_NONE

	LocalPlayer = Find_Player("local")
	LocalFaction = LocalPlayer.Get_Faction_Name()
	LastTravelDestination = nil
	DayCounter = nil
	PipMoviePlaying = false

	Init_Megaweapon_Data()
	Init_Global_Mode_Colors()

	DisplayCredits = true
	
	-- Set the global hud to initially hidden.
	this.BlankScreen.Set_Hidden(false)

	Init_Modes() 

	Regions = {}
	local num_regions = Globe.Get_Total_Regions()
	for i = 0, num_regions - 1 do
		local region = Globe.Get_Region_By_Index(i)
		table.insert(Regions, region)
	end

	-- Register to hear when the selected fleet changes, and when a fleet is clicked.
	this.Register_Event_Handler("Selection_Changed", nil, Selection_Changed)
	this.Register_Event_Handler("Minimap_Region_Clicked", this.Minimap, On_Minimap_Region_Clicked)
	
	-- Equivalent to Left mouse click
	this.Register_Event_Handler("GameplayUI_Controller_A_Button_Up", nil, GameplayUI_Controller_A_Button_Up)
	-- Equivalent to Right mouse click
	this.Register_Event_Handler("GameplayUI_Controller_X_Button_Up", nil, GameplayUI_Controller_X_Button_Up)
	
	Hero_Icons_Init(this)

	--Possibly not the final system for hotkey handling, but for now we'll listen for physical
	--key presses and translate them here
	this.Register_Event_Handler("Key_Press", this, On_Key_Press)
	
	-- Maria 07.06.2006
	-- Esc key should back out of all open HUD elements (socket schematic and purchase menus) before going to main menu
	this.Register_Event_Handler("Closing_All_Displays", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Closing_All_Displays)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Closing_All_Displays)
	
	CloseHuds = false
	
	this.Register_Event_Handler("Global_Megaweapon_Registration", nil, Register_Global_Megaweapon)
	this.Register_Event_Handler("Global_Megaweapon_Ready", nil, Global_Megaweapon_Timer_Remove)
	this.Register_Event_Handler("Global_Megaweapon_Not_Ready", nil, Global_Megaweapon_Timer_Add)
	
	if TestValid(this.Megaweapons.GlobalSpyButton) then 
		MegaweaponButtons["Spy"] = this.Megaweapons.GlobalSpyButton
		this.Megaweapons.GlobalSpyButton.Set_Tab_Order(TAB_ORDER_MEGAWEAPON_BUTTONS)
	else
		MegaweaponButtons["Spy"] = this.GlobalSpyButton
		this.GlobalSpyButton.Set_Tab_Order(TAB_ORDER_MEGAWEAPON_BUTTONS)
	end
	
	if TestValid(this.Megaweapons.ObliterateButton) then 
		MegaweaponButtons["Offensive"] = this.Megaweapons.ObliterateButton
		this.Megaweapons.ObliterateButton.Set_Tab_Order(TAB_ORDER_MEGAWEAPON_BUTTONS + 1)
	else 
		MegaweaponButtons["Offensive"] = this.ObliterateButton
		this.ObliterateButton.Set_Tab_Order(TAB_ORDER_MEGAWEAPON_BUTTONS + 1)
	end
	
	if TestValid(this.Megaweapons.RepairButton) then 
		MegaweaponButtons["Repair"] = this.Megaweapons.RepairButton
		this.Megaweapons.RepairButton.Set_Tab_Order(TAB_ORDER_MEGAWEAPON_BUTTONS + 2)
	else
		MegaweaponButtons["Repair"] = this.RepairButton
		this.RepairButton.Set_Tab_Order(TAB_ORDER_MEGAWEAPON_BUTTONS + 2)
	end
	
	MegaweaponTargeting["Spy"] = Global_Mode_Set_Spy_Targeting_Active
	MegaweaponTargeting["Offensive"] = Global_Mode_Set_Obliterate_Targeting_Active
	MegaweaponTargeting["Repair"] = Global_Mode_Set_Repair_Targeting_Active
	TargetingFunction = nil
	
	for type, button in pairs(MegaweaponButtons) do
		button.Set_Hidden(true)
		button.Set_User_Data(type)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Global_Megaweapon_Clicked)
	end
	this.Register_Event_Handler("Fire_Megaweapon_At_Region_Event", nil, Fire_Megaweapon_At_Region_Event)
	
	-- By default the megaweapon buttons are hidden!
	this.Megaweapons.Set_Hidden(true)
	
	-- Maria 10.18.2006
	-- Hooking up the hot key VK_W to hide the UI
	this.Register_Event_Handler("On_Hide_UI", nil, On_Hide_UI)	

	this.Register_Event_Handler("Send_GUI_Network_Event", nil, On_Send_GUI_Network_Event)
	
	this.Register_Event_Handler("Global_Icon_Drag_Begin", nil, On_Global_Icon_Drag_Begin)
	this.Register_Event_Handler("Global_Icon_Drag_End", nil, On_Global_Icon_Drag_End)
	DraggingGlobalIcon = false
	ValidMoveRegions = {}
	
	--Interface for strategic story script to color regions
	this.Register_Event_Handler("UI_Force_Region_Color", nil, On_Force_Region_Color)
	this.Register_Event_Handler("UI_Clear_Region_Color", nil, On_Clear_Region_Color)
	ForcedRegionColors = {}
	
	this.Register_Event_Handler("UI_Show_Start_Mission_Button", nil, Show_Start_Mission_Button)
	this.Register_Event_Handler("UI_Hide_Start_Mission_Button", nil, Hide_Start_Mission_Button)
	
	this.Register_Event_Handler("Controller_Display_Tooltip_From_UI", nil, On_Controller_Display_Tooltip_From_UI)
	this.Register_Event_Handler("Display_Tooltip", nil, On_Display_Tooltip)	
	this.Register_Event_Handler("End_Tooltip", nil, End_Tooltip)	
	MouseOverObjectTime = nil
	MouseOverHoverTime = 0.2
	
	this.Register_Event_Handler("Set_Minor_Announcement_Text", nil, Set_Minor_Announcement_Text)
	this.MinorAnnouncement.Announcement_bkg.Set_Hidden(true)
	
	-- Maria 06.18.2007
	-- *** HINT SYSTEM ***
	PGHintSystem_Init()
	Register_Hint_Context_Scene(this)
	Clear_Hint_Tracking_Map()

	Init_Keyboard_Mappings_Handler()
	
	--Subtitling support
	this.Register_Event_Handler("Speech_Event_Begin", nil, Subtitles_On_Speech_Event_Begin)
	this.Register_Event_Handler("Speech_Event_Done", nil, Subtitles_On_Speech_Event_Done)	
	
	if TestValid(this.EnemyMWTimers) then 
		Timers = {}
		Timers = Find_GUI_Components(this.EnemyMWTimers, "Timer")
		for _, timer in pairs(Timers) do
			timer.Set_Hidden(true)
		end
		
		TimersCount = 0
	end
	
	Init_Players_List()
	
	-- Designer's request.
	this.Register_Event_Handler("UI_Set_Display_Credits_Pop", nil,UI_Set_Display_Credits_Pop)
		
	if TestValid(this.RadarMap) then 
		RadarMap = this.RadarMap
		IsRadarOpen = false
		
		-- designer's request
		ShowRadarMap = true
		
		this.Register_Event_Handler("Enlarge_Radar_Map_Display", nil, On_Enlarge_Radar_Map_Display)		
	end
	
	if TestValid(this.CCBuildMenu) then 
		CCBuildMenu = this.CCBuildMenu
		CCBuildMenu.Set_Hidden(true)
	end
	
	if TestValid(this.StructureUpgradesMenu) then 
		UpgradesMenu = this.StructureUpgradesMenu
		UpgradesMenu.Set_Hidden(true)	
	end
	
	
	-- CONTROLLER INTERFACE
	-- ---------------------------------------------------------------------------------------------------------------------------
	this.Register_Event_Handler("Controller_Display_Selection_UI", nil, On_Display_Selection_UI)
	DisplayingSelectionUI = false
	
	this.Register_Event_Handler("Controller_Display_Megaweapons_UI", nil, On_Controller_Display_Megaweapons_UI)
	DisplayingMegaweaponsUI = false
	
	if TestValid(this.HeroMenu) then 
		this.HeroMenu.Set_Hidden(true)
	end
	
	this.Register_Event_Handler("Controller_Display_Hero_Selection_Menu", nil, On_Controller_Display_Hero_Selection_Menu)
	DisplayingHeroSelectionMenu = false
	
	-- Sub-Selection Data
	Initialize_Region_Connectivity_Data()
	this.Register_Event_Handler("Controller_Process_Sub_Select_Command", nil, On_Controller_Process_Sub_Select_Command)	
	CurrentSubSelectedObject = nil
	
	this.Register_Event_Handler("Controller_Update_Controls_Lock_State", nil, On_Controller_Update_Controls_Lock_State)
	
	-- ---------------------------------------------------------------------------------------------------------------------------
	-- GLOBAL IS STILL WORK IN PROGRESS SO, let's hide the context display in Global!!!!
	ShowContextDisplay = true
	Init_Gamepad_Contexts_Data()
	Controller_Update_Context()
	
	this.Register_Event_Handler("Debug_Force_Completion", nil, On_Debug_Force_Complete)	
	this.Register_Event_Handler("Network_Debug_Force_Complete", nil, Network_Debug_Force_Complete)
	this.Register_Event_Handler("Show_Game_End_Screen", nil, Show_Gane_End_Screen)	
	this.Register_Event_Handler("Network_Global_Begin_Production", nil, Network_Begin_Production)
	this.Register_Event_Handler("Network_Move_Fleet", nil, Network_Move_Fleet)
	this.Register_Event_Handler("Network_Global_Cancel_Production", nil, Network_Cancel_Production)
	this.Register_Event_Handler("Network_Sell_Object", nil, On_Network_Sell_Object)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Update_Controls_Lock_State
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Update_Controls_Lock_State(_, _, locked_unlocked)
	ControlsLocked = locked_unlocked	
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Process_Sub_Select_Command
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Process_Sub_Select_Command(_, _, in_direction, selected_object)
	-- 1.  DPad - Sub-select/snap to adjoining territories matching DPad direction press when nothing is selected 
	if TestValid(selected_object) then 
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
		return 
	end
	
	local starting_region = nil
	if TestValid(CursorOverObject) then
		if not CursorOverObject.Has_Behavior(74) then 
			local container = CursorOverObject.Get_Parent_Object()
			if TestValid(container) then
				if not container.Has_Behavior(74) then 
					container = container.Get_Parent_Object()
					if TestValid(container) and container.Has_Behavior(74) then 
						starting_region = container
					end
				else
					starting_region = container
				end			
			end
		else
			starting_region = CursorOverObject
		end	
	end
	
	local next_region = Find_Next_Subselectable_Region(starting_region, in_direction, selected_object)
	
	if TestValid(next_region) then 	
		Sub_Select_Region(next_region)
		Play_SFX_Event("GUI_Generic_Button_Select")
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Sub_Select_Region
-- ------------------------------------------------------------------------------------------------------------------
function Sub_Select_Region(region)
	Point_Camera_At(region)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Find_Next_Subselectable_Region
-- ------------------------------------------------------------------------------------------------------------------
function Find_Next_Subselectable_Region(starting_at, in_direction, selected_object)

	local next_region_name = nil
	local next_region = nil
	if TestValid(starting_at) then
		local region_name = starting_at.Get_Type().Get_Name()
		next_region_name = RegionConnectivity[region_name][in_direction]
		if not next_region_name then 
			return
		end
		next_region = Find_First_Object(next_region_name)
	else
		next_region = Controller_Find_Nearest_Region_To_Cursor_Position()
	end
	
	if not TestValid(next_region) then 
		return
	end
	
	-- Is this region valid for subselection?
	if TestValid(TargetingMegaweapon) then
		-- 2.	DPad - Sub-select/snap to valid attackable territories matching DPad direction 
		-- press when global strucure special abilities or megaweapon attack is selected
		
		local legal_target = false
		
		local script = TargetingMegaweapon.Get_Script()
		if script then 
			local target_enemies = script.Get_Async_Data("MegaweaponTargetsEnemies")
			legal_target = (target_enemies and LocalPlayer.Is_Enemy(next_region.Get_Owner())) or
					    (not target_enemies and LocalPlayer.Is_Ally(next_region.Get_Owner()))
		end
		
		if legal_target then 
			return next_region
		else
			return Find_Next_Subselectable_Region(next_region, in_direction, selected_object)
		end
	else
		-- 1.  DPad - Sub-select/snap to adjoining territories matching DPad direction press when nothing is selected 
		return next_region
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Hero_Selection_Menu
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Hero_Selection_Menu(_, _, display_hide)
	Display_Hero_Selection_Menu(display_hide)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Hero_Selection_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Display_Hero_Selection_Menu(display_hide)
	
	this.HeroMenu.Set_Hidden(not display_hide)
	if display_hide then
		if TestValid(this.GamepadContextDisplay)then
			this.GamepadContextDisplay.Set_Hidden(true)
		end
		this.HeroMenu.Display_Menu(true, IndexedHeroTable)		
	else 
		-- make sure the context display has not been hidden from script.
		if ShowContextDisplay and not IsLetterboxMode then 
			if TestValid(this.GamepadContextDisplay)then
				this.GamepadContextDisplay.Set_Hidden(false)
			end
		end
		
		this.HeroMenu.Display_Menu(false)		
	end
	DisplayingHeroSelectionMenu = display_hide	
	Controller_Update_Context()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Megaweapons_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Megaweapons_UI(_, _, display_hide)
	Display_Megaweapons_UI(display_hide)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Megaweapons_UI
-- ------------------------------------------------------------------------------------------------------------------
function Display_Megaweapons_UI(display_hide)
	
	if display_hide and not Should_Display_MW_UI() then
		-- There are no MWs to display so let's get out of here!.
		-- Report back to code.
		Controller_Set_Displaying_Megaweapons_UI(false)
		return
	end
	
	UpdateFocusOnNextService = true	
	this.Megaweapons.Set_Hidden(not display_hide)
	
	if display_hide then
		if TestValid(this.GamepadContextDisplay)then
			this.GamepadContextDisplay.Set_Hidden(true)
		end
	else 
		UpdateFocusOnNextService = false
		-- make sure the context display has not been hidden from script.
		if ShowContextDisplay and not IsLetterboxMode then 
			if TestValid(this.GamepadContextDisplay)then
				this.GamepadContextDisplay.Set_Hidden(false)
			end
		end
	end

	DisplayingMegaweaponsUI = display_hide
	-- Report back to code.
	Controller_Set_Displaying_Megaweapons_UI(DisplayingMegaweaponsUI)
	Controller_Update_Context()
end

-- ----------------------------------------------------------------------------------------------------------------
-- Should_Display_MW_UI
-- ------------------------------------------------------------------------------------------------------------------
function Should_Display_MW_UI()
	-- Does the player have any Megaweapons?
	if MegaweaponPlayer ~= nil and MegaweaponPlayer == Find_Player("local") then
		for _, type in pairs(MegaweaponTypes) do
			if Get_Current_Player_Megaweapons(type) > 0 then 
				return true
			end
		end
	end
	return false
end

	

-- ------------------------------------------------------------------------------------------------------------------
-- On_Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Display_Selection_UI(_, _, display_hide)
	-- Based on what's currently selected, display the proper UI.
	Display_Selection_UI(display_hide)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function Display_Selection_UI(display_hide)
	-- If a hero is selected, we display the fleet's unit panel.
	if not TestValid(SelectedObject) then
		return
	end

	UpdateFocusOnNextService = true
	if SelectedObject.Get_Type().Is_Hero() then
		if display_hide then
			if this.FleetPanel.Is_Open() then
				this.FleetPanel.Close()
			end
			this.FleetPanel.Set_Hero(SelectedObject)
			this.FleetPanel.Open()
			-- we want to set the focus on the first focusable component, to do so we need to 
			-- set the focus in the next frame to make sure the whole seen is enabled.
			UpdateFocusOnNextService = false
			
			-- Hide the radar map so that the menu doesn't overlap it!.
			if ShowRadarMap then
				this.RadarMap.Set_Hidden(true)
			end
		else
			this.FleetPanel.Close()
		end		
	elseif SelectedObject.Has_Behavior(99) then
		UpgradesMenu.Set_Hidden(not display_hide)
		local success = UpgradesMenu.Display_Upgrade_Panel(display_hide, SelectedObject)
		-- display the upgrades menu.
		if not success then 
			UpgradesMenu.Set_Hidden(true)
		end
		
	elseif SelectedObject.Has_Behavior(74) then
		-- MARIA TODO!!!!!! ---------------------   Do we own this thing? can we spy on it?
		-- display the command centers menu.
		CCBuildMenu.Set_Hidden(not display_hide)		
		CCBuildMenu.Display_Build_Menu(display_hide, SelectedObject)	
	end
	
	if display_hide then
		if TestValid(this.GamepadContextDisplay)then
			this.GamepadContextDisplay.Set_Hidden(true)
		end
	else 
		UpdateFocusOnNextService = false
		-- make sure the context display has not been hidden from script.
		if ShowContextDisplay and not IsLetterboxMode then 
			if TestValid(this.GamepadContextDisplay)then
				this.GamepadContextDisplay.Set_Hidden(false)
			end
		end
		
		-- Unhide the radar map so that the menu doesn't overlap it!.
		if ShowRadarMap then
			this.RadarMap.Set_Hidden(false)
		end
	end

	DisplayingSelectionUI = display_hide
	
	Controller_Update_Context()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Update_Context
-- First determine what the current context is and then update the display!.
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Update_Context()
	
	if not TestValid(this.GamepadContextDisplay) then
		return
	end
	
	-- Maria 01.22.2008
	-- Per task request: Need to remove button callouts in global transition scenes	
	if ControlsLocked then
		this.GamepadContextDisplay.Set_Hidden(true)
		return
	end
	
	if not ShowContextDisplay then 
		this.GamepadContextDisplay.Set_Hidden(true)
		return 
	elseif not (DisplayingSelectionUI or DisplayingMegaweaponsUI or DisplayingHeroSelectionMenu) then -- strategic mode.
		this.GamepadContextDisplay.Set_Hidden(false)
	end
	
	-- Reset all contexts.
	local gamepad_curr_contexts = {}
	
	if TestValid(SelectedObject) then 
		if SelectedObject.Get_Type().Is_Hero() then
			gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_ACCESS_HERO_FLEET_PANEL].Trigger] = GAMEPAD_CONTEXT_ACCESS_HERO_FLEET_PANEL
		elseif SelectedObject.Has_Behavior(99) then
			gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_GLOBAL_STRUCTURE_UPGRADES].Trigger] = GAMEPAD_CONTEXT_GLOBAL_STRUCTURE_UPGRADES
		elseif SelectedObject.Has_Behavior(74) and SelectedObject.Get_Owner() == Find_Player("local") then
			gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_COMMAND_CENTERS_MENU].Trigger] = GAMEPAD_CONTEXT_COMMAND_CENTERS_MENU
		end
	end

	-- If any UI menu is open, the B button can be used to close them down!.
	if DisplayingSelectionUI or DisplayingMegaweaponsUI or DisplayingHeroSelectionMenu then
		gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_EXIT_MENU].Trigger] = GAMEPAD_CONTEXT_EXIT_MENU
	elseif TestValid(SelectedObject) and SelectedObject.Get_Owner() == Find_Player("local") then  -- If something is currently selected, the B button can be used to deselect it.
		gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_DROP_SELECTION].Trigger] = GAMEPAD_CONTEXT_DROP_SELECTION
	end
	
	if Should_Display_MW_UI() then 
		gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_MEGAWEAPON_BUTTONS_MENU].Trigger] = GAMEPAD_CONTEXT_MEGAWEAPON_BUTTONS_MENU
	end
	
	-- RIGHT BUMPER
	gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_ZOOM_GLOBAL_CAMERA].Trigger] = GAMEPAD_CONTEXT_ZOOM_GLOBAL_CAMERA
	
	-- RIGHT TRIGGER
	gamepad_curr_contexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_HEROES_MENU].Trigger] = GAMEPAD_CONTEXT_HEROES_MENU
	
	this.GamepadContextDisplay.Update_Context_Display(gamepad_curr_contexts)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Enlarge_Radar_Map_Display
-- ------------------------------------------------------------------------------------------------------------------
function On_Enlarge_Radar_Map_Display(_, _, enlarge_shrink)

	if enlarge_shrink then
		-- if it is not already enlarged, go ahead and open it up.
		if not IsRadarOpen then
			Radar_Map_Enlarge()
			this.Tooltip.End_Tooltip()
		end
	else
		if IsRadarOpen then
			Radar_Map_Shrink()
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Enlarge
-- ------------------------------------------------------------------------------------------------------------------------------------
function Radar_Map_Enlarge()
	
	if not TestValid(RadarMap) then 
		return
	end
	
	-- In some cases design may want to hide the radar map so let's make sure this is not the case!.
	if not ShowRadarMap then 	
		return
	end
	
	-- Let's make sure the radar map is zoomed out
	if IsRadarOpen then 
		return 
	end
	
	if TestValid(this.GamepadContextDisplay) then 
		this.GamepadContextDisplay.Set_Hidden(true)
	end
	
	if TestValid(this.DayCounter) then 
		this.DayCounter.Set_Hidden(true)
	end
	
	-- Open the radar map
	RadarMap.Play_Animation("Enlarge", false)	
	
	IsRadarOpen = true
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Shrink
-- ------------------------------------------------------------------------------------------------------------------------------------
function Radar_Map_Shrink()
	
	-- In some cases design may want to hide the radar map so let's make sure this is not the case!.
	if not ShowRadarMap then 	
		return
	end
	
	-- Let's make sure that the map is zoomed in.
	if not IsRadarOpen then 
		return 
	end
	
	if TestValid(this.GamepadContextDisplay) and ShowContextDisplay then 
		this.GamepadContextDisplay.Set_Hidden(false)
	end
	
	if TestValid(this.DayCounter) then 
		this.DayCounter.Set_Hidden(false)
	end
	
	-- Close the radar map
	RadarMap.Play_Animation_Backwards("Enlarge", false)

	IsRadarOpen = false
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Is_Radar_Map_Open
-- ------------------------------------------------------------------------------------------------------------------------------------
function Is_Radar_Map_Open()
	return( IsRadarOpen )
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Is_Radar_Map_Animating
-- ------------------------------------------------------------------------------------------------------------------------------------
function Is_Radar_Map_Animating()
	return IsRadarAnimating
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Set_Display_Credits_Pop
-- ------------------------------------------------------------------------------------------------------------------
function UI_Set_Display_Credits_Pop(_, _, on_off)
	DisplayCredits = on_off
	this.creditsText.Set_Hidden(not DisplayCredits)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Players_List
-- ------------------------------------------------------------------------------------------------------------------
function Init_Players_List()

	MAX_PLAYERS = 7
	
	Players = {}	
	local local_player = Find_Player("local")
	if not local_player then return end
	local local_player_id = local_player.Get_ID()
		
	for player_index = 0, MAX_PLAYERS - 1 do
		local enemy = Find_Player(player_index)
		if enemy and enemy.Is_AI_Player() then
			table.insert(Players, {enemy, enemy.Get_Use_Colorization()})
		end
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Selection_Changed
-- ------------------------------------------------------------------------------------------------------------------
function Selection_Changed()
	--Only support single select in global
	local selected_objects = Get_Selected_Objects()
	if selected_objects then
		SelectedObject = selected_objects[1]
	end
	
	ValidMoveRegions = {}
	Hide_Travel_Preview()
	TargetingMegaweapon = nil
	TargetingFunction = nil
	for _, func in pairs(MegaweaponTargeting) do
		func(false, false)
	end


	if TestValid(SelectedObject) then
		local script = SelectedObject.Get_Script()
		if script then
			local weapon_type = script.Get_Async_Data("WeaponType")
			if weapon_type then
				TargetingMegaweapon = SelectedObject
				TargetingFunction = MegaweaponTargeting[weapon_type]
				return
			end
		end
	end
	
	if TestValid(SelectedObject) and SelectedObject.Get_Owner() == Find_Player("local") then 
		local source_region = SelectedObject.Get_Region_In()
		if not TestValid(source_region) then
			return
		end	
	
		ValidMoveRegions = Regions --source_region.Find_Regions_Within(SelectedObject.Get_Type().Get_Type_Value("Travel_Range"))	
		LastTravelDestination = nil
	end
	
	-- Now that the UI has been updated, let's update the controller's context display!.
	-- Also, if selection has changed, update the context display for the controller!.
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Megaweapon_Data
-- ------------------------------------------------------------------------------------------------------------------
function Init_Megaweapon_Data()
	MegaweaponTypes = { "Offensive", "Spy", "Repair" }
	
	MegaweaponOwners = {}
	MegaweaponTimer = {}
	MegaweaponChange = {}
	MegaweaponReady = {}
	MegaweaponButtons = {}
	MegaweaponTargeting = {}
	TargetingFunction = nil
	for _, type in pairs(MegaweaponTypes) do
		MegaweaponOwners[type] = {}
		MegaweaponTimer[type] = {}
		MegaweaponChange[type] = false
	end
		
	TargetingMegaweapon = nil
	MegaweaponPlayer = nil	
end


-- -----------------------------------------------------------------------------------------------------------------
-- On_Receive_GUI_Network_Event(args): Called when we receive a GUI Network event.
-- ------------------------------------------------------------------------------------------------------------------
function On_Receive_GUI_Network_Event(args)
	Raise_Event_Immediate_All_Scenes(args[1], args[2])
end


-- -----------------------------------------------------------------------------------------------------------------
-- On_Send_GUI_Network_Event(): Called when we want to send a synchronized GUI Network event.
-- ------------------------------------------------------------------------------------------------------------------
function On_Send_GUI_Network_Event(event, source, event_name, args)
	Internal_Send_GUI_Network_Event("On_Receive_GUI_Network_Event", { event_name, args })
end


-- ------------------------------------------------------------------------------------------------------------------
-- Maria 10.18.2006
-- On_Hide_UI -- Attached to HOT KEY VK_W
-- ------------------------------------------------------------------------------------------------------------------
function On_Hide_UI(event, source, onoff)

	if onoff == true then -- i.e., hide
		On_Closing_All_Displays()
	end
	
	this.Set_Hidden(onoff)
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Key_Press
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Key_Press(event, source, key)
	-- Toggle debug display
	if key == "n" then
		local new_hidden = not this.DebugInfo.text.Get_Hidden()
		this.DebugInfo.text.Set_Hidden(new_hidden)
		this.DebugInfo.backdrop.Set_Hidden(new_hidden)
		this.DebugInfo.text.Set_Text("")
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- Process_Fade
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function Process_Fade()

	-- Update fade out UI
	local fade_percent = Get_Fade_Screen_Percent()
	if fade_percent > 0 then
		this.BlankScreen.Set_Hidden(false)
		this.BlankScreen.Set_Tint(0.0, 0.0, 0.0, fade_percent)
	else
		this.BlankScreen.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function Begin_Production(region, unit_type, into_fleet)
	local success = true
	local local_player = Find_Player("local")

	-- Must build into a region you own, or into a fleet you own
	if not into_fleet then 
		success = region.Get_Owner().Is_Ally(local_player)
	else
		success = into_fleet.Get_Owner().Is_Ally(local_player)
	end

	-- If ok so far, try to build.
	if success then
		Send_GUI_Network_Event("Network_Global_Begin_Production", { LocalPlayer, region, unit_type, into_fleet })
	end
end

function Network_Begin_Production(_, _, player, region, type, dest, socket)
	local success = Global_Begin_Production(player, region, type, dest, socket)
	
	if LocalPlayer == player then
		if success then
			Play_SFX_Event("GUI_Generic_Button_Select")
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	end
end

function Network_Cancel_Production(_, _, object)
	local success = Cancel_Production_At_Location_Of_Unit(object)
	
	if LocalPlayer == object.Get_Owner() then
		if success then 
			Play_SFX_Event("GUI_Generic_Button_Select")
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end	
	end
end 

-- -----------------------------------------------------------------------------------------------------------------
-- On_Network_Sell_Object
-- -----------------------------------------------------------------------------------------------------------------
function On_Network_Sell_Object(event, source, object, player)
	if TestValid(object) then 
		object.Sell()	
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function Move_Fleet(fleet, region, into_fleet)

	if fleet.Is_Fleet_Locked_By_Production() then
		local fleet_hero = fleet.Get_Fleet_Hero()
		if TestValid(fleet_hero) then
			Play_SFX_Event(fleet_hero.Get_Type().Get_Type_Value("SFXEvent_Cant_Move_Unit_In_Production"))
		end
		return
	end

	Send_GUI_Network_Event("Network_Move_Fleet", { fleet, region, into_fleet })
end

function Network_Move_Fleet(_, _, fleet, region, into_fleet)
	local success = fleet.Move_Fleet_To_Region(region, into_fleet)
	if fleet.Get_Owner() == LocalPlayer then
		if success then
			Play_SFX_Event("GUI_Generic_Button_Select")
			
			-- Deselect the fleet.
			Set_Selected_Objects({})
		else
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Comm_Officer_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Comm_Officer_Clicked(hero)
	this.Objectives.Toggle()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Comm_Officer_Double_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Comm_Officer_Double_Clicked(hero)
	this.Objectives.Toggle()
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- User has left-clicked a region.
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Left_Clicked_Region(region)
	if TestValid(TargetingMegaweapon) then
		local script = TargetingMegaweapon.Get_Script()
		if script then
			local target_enemies = script.Get_Async_Data("MegaweaponTargetsEnemies")
			if (target_enemies and LocalPlayer.Is_Enemy(region.Get_Owner())) or
				(not target_enemies and LocalPlayer.Is_Ally(region.Get_Owner())) then
				Fire_Megaweapon_At_Region( region )
				TargetingMegaweapon = nil
				Set_Selected_Objects({})
			end
		end
	else
		--Point_Camera_At(region)
	end	
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Left_Clicked_Command_Center
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Left_Clicked_Command_Center(cc_object)
	--Point_Camera_At(CursorOverObject)	
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- GameplayUI_Controller_A_Button_Up	-- EQUIVALENT TO LEFT CLICK
-- ------------------------------------------------------------------------------------------------------------------------------------
function GameplayUI_Controller_A_Button_Up(_, source, clicked_and_release_same_gameobject)
	if clicked_and_release_same_gameobject and TestValid(CursorOverObject) then
		if CursorOverObject.Has_Behavior(74) then
			On_Left_Clicked_Region(CursorOverObject)
		elseif CursorOverObject.Has_Behavior(116) or CursorOverObject.Get_Type().Is_Dummy_Global_Icon() then
			-- We are clicking on an object over the region label (or the region label itself!). Thus, get the parent object and 
			-- process the click according to it!.
			local parent_object = CursorOverObject.Get_Parent_Object()
			if parent_object ~= nil then
				if parent_object.Has_Behavior(74) then
					-- clicked region label itself.
					On_Left_Clicked_Region(parent_object)
					
				elseif parent_object.Has_Behavior(99) then
					if parent_object.Get_Owner() == LocalPlayer and not TargetingMegaweapon then
						On_Left_Clicked_Command_Center(parent_object)
					else
						--Treat clicks on enemy command centers as a click on the region
						On_Left_Clicked_Region(parent_object.Get_Region_In())
					end		
				elseif parent_object.Has_Behavior(4) then
					if TargetingMegaweapon then
						On_Left_Clicked_Region(parent_object.Get_Parent_Object())
					end
				end
			end
		end		
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- GameplayUI_Controller_X_Button_Up	-- EQUIVALENT TO RIGHT CLICK
-- ------------------------------------------------------------------------------------------------------------------------------------
function GameplayUI_Controller_X_Button_Up(_, source, clicked_and_release_same_gameobject)

	if clicked_and_release_same_gameobject and TestValid(CursorOverObject) then
		if TestValid(TargetingMegaweapon) then
			Set_Selected_Objects({})
		end
	end		
end

-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	
	local update_command_bar = true
	
	Process_Fade()
	
	if UpdateFocusOnNextService then
		if this.FleetPanel.Is_Open() then
			this.FleetPanel.Set_Focus()
		elseif CCBuildMenu.Is_Open() then
			CCBuildMenu.Set_Focus()
		else 
			this.Focus_First()			
		end
		UpdateFocusOnNextService = false
	end
	
	-- Update debug display of what we're over
	if not this.DebugInfo.text.Get_Hidden() then
		local text = ""
		if TestValid(CursorOverObject) then
			text = string.format("Cursor over '%s'", CursorOverObject.Get_Type().Get_Name())
			this.DebugInfo.text.Set_Text(text)
		end
	end

	Update_Mouse_Over()

	Update_Credits_Display()
	Update_Day_Counter()

	Update_Region_Textures()
	Update_Region_Colors()
	
	Update_Hero_Icons({SelectedObject})

	Update_Travel_Preview()

	for _, type in pairs(MegaweaponTypes) do
		Update_Megaweapon(type)
	end
	
	Update_Enemy_Megaweapons_Data()
	
	CloseHuds = ( DisplayingSelectionUI or DisplayingMegaweaponsUI or DisplayingHeroSelectionMenu ) or
		(TestValid(this.full_screen_movie) and this.full_screen_movie.Has_Movie())
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Day_Counter
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Day_Counter()
	local day_counter = Get_Day_Counter()
	if not DayCounter or DayCounter ~= day_counter then
		DayCounter = day_counter
		this.DayCounter.Set_Text(Replace_Token(Get_Game_Text("TEXT_GLOBAL_DAY_COUNTER"), Get_Localized_Formatted_Number(DayCounter), 0))
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Display_Object_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Display_Object_Tooltip()

	local ans = 	( DisplayingSelectionUI or DisplayingMegaweaponsUI or DisplayingHeroSelectionMenu )
	return not ans
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Mouse_Over
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Mouse_Over()
	
	if IsRadarOpen then
		-- do not update the object under the cursor for it is of no use in this mode!.
		CursorOverObject = nil
		return
	end
	
	local old_cursor_over = CursorOverObject
	local mouse_over_ui = false
	CursorOverObject, mouse_over_ui = Get_Object_At_Cursor()
	
	if not TestValid(CursorOverObject) then
		CursorOverObject = RadarMap.Minimap.Get_Mouse_Over_Region()
	end
	
	if TestValid(TargetingMegaweapon) then
		local legal_target = false
		if TestValid(CursorOverObject) then
			local script = TargetingMegaweapon.Get_Script()
			if script then 
				local region = CursorOverObject.Get_Region_In()
				local target_enemies = script.Get_Async_Data("MegaweaponTargetsEnemies")
				legal_target = (target_enemies and LocalPlayer.Is_Enemy(region.Get_Owner())) or
									(not target_enemies and LocalPlayer.Is_Ally(region.Get_Owner()))
			end
		end
		TargetingFunction(true, legal_target)
	end	
	
	if not TestValid(this.Tooltip) then
		return
	end
	
	local time_now = GetCurrentTime()
	if old_cursor_over == CursorOverObject then
		local tooltip_object = Determine_Tooltip_Object(CursorOverObject)
		if TestValid(tooltip_object) and tooltip_object.Get_Type().Requires_Expanded_Tooltip_Display() then
			if time_now - MouseOverObjectTime > MouseOverHoverTime then
				if not mouse_over_ui and Display_Object_Tooltip() then
					Display_Tooltip({'object', {tooltip_object}}, true)
				end
			end
		end
	else
		MouseOverObjectTime = time_now
		this.Tooltip.End_Tooltip()
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Determine_Tooltip_Object
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Determine_Tooltip_Object(cursor_over_object)
	if not TestValid(cursor_over_object) then
		return nil
	end

	if cursor_over_object.Get_Type().Get_Type_Value("Is_Dummy_Global_Icon") then
		local parent = cursor_over_object.Get_Parent_Object()
		if TestValid(parent) then
			if parent.Has_Behavior(4) then
				return parent.Get_Fleet_Hero()
			else
				return parent
			end
		end
	end
	
	if cursor_over_object.Get_Owner().Is_Enemy(LocalPlayer) then
		return cursor_over_object.Get_Region_In()
	end
	
	return cursor_over_object
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A GameObject was clicked.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Clicked_Object(object)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A GameObject was clicked and released, as you would a button.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Released_Object(object)
	if CurrentMode.action ~= nil then
		CurrentMode.action(object)
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- If we're already in this mode, go to MODE_NONE;
-- otherwise switch to this new mode
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Toggle_Mode(mode)
	if CurrentMode == mode then
		CurrentMode = MODE_NONE
	else
		CurrentMode = mode
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Region_Colors: Update all region colors based on game and UI state
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Region_Colors()
	for _, region in pairs(Regions) do
		local color = Get_Region_Color(region)
		if color then
			local r, g, b = color[1], color[2], color[3]
			region.Set_Region_Color(r, g, b)
			RadarMap.Minimap.Set_Region_Color(region, r, g, b)
		end
	end
end

function Is_Cursor_Over_Region(region)
	if not TestValid(CursorOverObject) then
		return false
	end
	
	if (CursorOverObject == region) then
		return true
	end
	
	if not CursorOverObject.Has_Behavior(74) then 
		local container = CursorOverObject.Get_Parent_Object()
		if TestValid(container) then
			if container == region then 
				return true
			else
				container = container.Get_Parent_Object()
				if TestValid(container) and container == region then 
					return true
				end
			end			
		end
	end
	return false
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Region_Textures: Update all region textures based on game and UI state
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Region_Textures()
	
	--if TestValid(SelectedObject) and SelectedObject.Get_Type().Is_Hero() and TestValid(SelectedObject.Get_Region_In()) then
		for _, region in pairs(Regions) do
			if Is_Cursor_Over_Region(region) or (TestValid(SelectedObject) and SelectedObject == region) then 
				region.Set_Region_Texture(region.Get_Owner().Get_Faction_Value("Region_Texture_Solid"))
			else
				region.Set_Region_Texture(region.Get_Owner().Get_Faction_Value("Region_Texture"))
			end
		end
	--	for _, valid_region in pairs(ValidMoveRegions) do
	--		valid_region.Set_Region_Texture(valid_region.Get_Owner().Get_Faction_Value("Region_Texture"))
	--	end		
	--else
	--	for _, region in pairs(Regions) do
	--		region.Set_Region_Texture(region.Get_Owner().Get_Faction_Value("Region_Texture"))
	--	end	
	--end	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Travel_Preview
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Travel_Preview()

	-- Maria 10.01.2007
	-- It is possible that we have selected an enemy's fleet (spying).  In that case, we don't show the travel preview data for
	-- we cannot access that data.
	if not TestValid(SelectedObject) or SelectedObject.Get_Owner() ~= Find_Player("local") then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end
	
	if not TestValid(CursorOverObject) then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end
	
	local target_region = CursorOverObject.Get_Region_In()
	if not TestValid(target_region) then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end

	if not SelectedObject.Get_Type().Is_Hero() then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end
	
	local icon_object = SelectedObject.Get_Global_Icon()
	if not TestValid(icon_object) then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end		

	local source_region = SelectedObject.Get_Region_In()
	if not TestValid(source_region) then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end
	
	local source_fleet = SelectedObject.Get_Parent_Object()
	if not TestValid(source_fleet) or not source_fleet.Can_Move() then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end		
	
	if source_region == target_region then
		LastTravelDestination = nil
		Hide_Travel_Preview()
		return
	end

	if target_region == LastTravelDestination and this.Tooltip.Is_Open() then
		MouseOverObjectTime = GetCurrentTime()
		return
	end

	LastTravelDestination = target_region
	
	local regions_passed_through = Show_Travel_Preview(icon_object, target_region, SelectedObject.Get_Type().Get_Type_Value("Travel_Range"))
	local tooltip_text = Get_Game_Text("TEXT_REGIONS_PASSED_THROUGH")
	Replace_Token(tooltip_text, Get_Localized_Formatted_Number(regions_passed_through), 0)
	Set_Travel_Preview_Color(unpack(ROUTE_COLOR_PREVIEW))
	
	MouseOverObjectTime = GetCurrentTime()
	this.Tooltip.Display_Tooltip({"object", { target_region, false, false, tooltip_text }})
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Credits_Display
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Credits_Display()
	if not DisplayCredits then 
		return 
	end
	
	local credits = LocalPlayer.Get_Credits()
	local credit_cap = LocalPlayer.Get_Credit_Cap()
	if not LastCredits or credits ~= LastCredits or not LastCreditCap or credit_cap ~= LastCreditCap then
		LastCredits = credits
		LastCreditCap = credit_cap
		local wstr_credits = Get_Game_Text("TEXT_CURRENT_STRATEGIC_RESOURCES_WITH_CAP")
		Replace_Token(wstr_credits, Get_Localized_Formatted_Number(credits), 0)
		Replace_Token(wstr_credits, Get_Localized_Formatted_Number(credit_cap), 1)
		this.creditsText.Set_Text(wstr_credits)
		
		if credits >= credit_cap then
			Start_Flash(this.creditsText)
		else
			Stop_Flash(this.creditsText)
		end			
	end
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get_Region_Color
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Get_Region_Color(region)
	
	--If an external script has asked for a specific color then use that
	if ForcedRegionColors[region] then
		return ForcedRegionColors[region]
	end
	
	-- Territory ownership	
	local faction_name = region.Get_Owner().Get_Faction_Name()
	local is_valid_region = true
	if TestValid(SelectedObject) and SelectedObject.Get_Type().Is_Hero() then
		is_valid_region = false
		for _, valid_region in pairs(ValidMoveRegions) do
			if valid_region == region then
				is_valid_region = true
			end
		end
	end	
	
	if TestValid(SelectedObject) and SelectedObject == region then
		return REGION_COLOR_SELECTED[faction_name]
	elseif Is_Cursor_Over_Region(region) and is_valid_region then		
		return REGION_COLOR_ROLLOVER[faction_name]
	elseif is_valid_region then
		return REGION_COLOR[faction_name]
	else
		return REGION_COLOR_INVALID_TARGET[faction_name]
	end

end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 04.06.2006
-- Clicking the Scientist Button displays the Tech Tree from which the player can see and determine what his research options are
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Scientist_Button_Clicked()
	-- First close the fleet rollouts if necessary
	Raise_Event_Immediate_All_Scenes("Close_All_Active_Displays", {});
	
	Toggle_Research_Tree_Display()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Research_Tree_Display
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Research_Tree_Display()
	
	if not TestValid(this.Research_Tree) then return end
	
	if this.Research_Tree.Is_Open() == false then
		-- Go ahead and open the tree
		Open_Research_Tree()		
	else
		this.Research_Tree.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Open_Research_Tree
-- ------------------------------------------------------------------------------------------------------------------
function Open_Research_Tree()
	if not TestValid(this.Research_Tree) then return end
	
	-- If there's any fleet panel open, let's close it so that they don't overlap!.
	if TestValid(this.FleetPanel) then
		this.FleetPanel.Close()
	end

	this.Research_Tree.Set_Hidden(false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Closing_All_Displays
-- ------------------------------------------------------------------------------------------------------------------
function On_Closing_All_Displays(event, source)
	
	-- Hide close the research tree, if necessary
	Hide_Research_Tree()
		
	-- Close the fleet rollouts, if necessary
	Raise_Event_Immediate_All_Scenes("Close_All_Active_Displays", {});
	Play_SFX_Event("GUI_Generic_Close_Window")
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Research_Tree
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Research_Tree()
	if not TestValid(this.Research_Tree) then return end
	if this.Research_Tree.Is_Open() == true then 
		this.Research_Tree.Set_Hidden(true)
	end	
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 04.26.2006
-- On_Minimap_Camera_Control_Clicked - Identify which sector has been clicked and move the camera so that it points at the center of the 
-- specified sector on the globe!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Minimap_Camera_Control_Clicked(event, source)

	local name = source.Get_Fully_Qualified_Name()
	local sector_index = MiniMapSectorNameToIndexMap[name]
	
	local success = Move_Camera_To_Sector(sector_index)
	
	if success == false then
		MessageBox("On_Minimap_Camera_Control_Clicked: Could not complete the Move_Camera_To_Sector command!")
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Global_Icon_Drag_Begin
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Global_Icon_Drag_Begin(event, source, object)
	DraggingGlobalIcon = true
	local source_fleet = object.Get_Parent_Object()
	local source_hero = source_fleet.Get_Fleet_Hero()
	local source_region = source_fleet.Get_Parent_Object()
	ValidMoveRegions = Regions --source_region.Find_Regions_Within(source_hero.Get_Type().Get_Type_Value("Travel_Range"))
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Global_Icon_Drag_Begin
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Global_Icon_Drag_End(event, source)
	DraggingGlobalIcon = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Register_Global_Megaweapon
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Register_Global_Megaweapon(_, _, object, weapon_type)
	if object ~= nil and TestValid(object) then
		local player = object.Get_Owner()
		-- key == object, value == player
		if player ~= nil then
		
			-- need something to tell us we lost the repair object
			Set_Megaweapon_Change(weapon_type, true)
			if player == LocalPlayer then
				MegaweaponButtons[weapon_type].Set_Texture(object.Get_Type().Get_Icon_Name())
			end
	
			object.Register_Signal_Handler(Global_Megaweapon_Delete_Pending, "OBJECT_DELETE_PENDING", this)
	
			if MegaweaponOwners[weapon_type][player] == nil then
				MegaweaponOwners[weapon_type][player] = {}
				MegaweaponOwners[weapon_type][player].Count = 1
				MegaweaponOwners[weapon_type][player][1] = {}
				MegaweaponOwners[weapon_type][player][1].Object = object
				MegaweaponOwners[weapon_type][player][object] = 1
			elseif MegaweaponOwners[weapon_type][player][object] == nil then
				local new_count = MegaweaponOwners[weapon_type][player].Count + 1
				MegaweaponOwners[weapon_type][player].Count = new_count
				MegaweaponOwners[weapon_type][player][new_count] = {}
				MegaweaponOwners[weapon_type][player][new_count].Index = new_count
				MegaweaponOwners[weapon_type][player][new_count].Object = object
				MegaweaponOwners[weapon_type][player][object] = new_count
			end
		end
	end
	
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Global_Megaweapon_Delete_Pending
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Global_Megaweapon_Delete_Pending(object)
	if object ~= nil then
		local player = object.Get_Owner()
		local weapon_script = object.Get_Script()
		local weapon_type = nil
		if weapon_script then
			weapon_type = weapon_script.Get_Async_Data("WeaponType")
		end
		if player ~= nil and weapon_type ~= nil then
			if MegaweaponOwners[weapon_type][player] ~= nil and MegaweaponOwners[weapon_type][player][object] ~= nil then
			
				Set_Megaweapon_Change(weapon_type, true)
				
				-- remove it from any timers that it might be using
				Global_Megaweapon_Timer_Remove( nil, nil, object, weapon_type )
				
				local index = MegaweaponOwners[weapon_type][player][object]
				table.remove(MegaweaponOwners[weapon_type][player], index)
				MegaweaponOwners[weapon_type][player].Count = MegaweaponOwners[weapon_type][player].Count - 1
				
				if MegaweaponOwners[weapon_type][player].Count > 0 then
					for i = 1, MegaweaponOwners[weapon_type][player].Count do
						MegaweaponOwners[weapon_type][player][i].Index = i
					end
					
					MegaweaponOwners[weapon_type][player][object] = nil
				else
					MegaweaponOwners[weapon_type][player] = nil
				end
				
			end
		end
	end
	
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Global_Megaweapon_Timer_Add
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Global_Megaweapon_Timer_Add(_, _, object, weapon_type)
	if object ~= nil then
		local player = object.Get_Owner()
		if player ~= nil then
			Set_Megaweapon_Change(weapon_type, true)
			if MegaweaponTimer[weapon_type][player] == nil then
				MegaweaponTimer[weapon_type][player] = {}
				MegaweaponTimer[weapon_type][player].Count = 1
				MegaweaponTimer[weapon_type][player][1] = {}
				MegaweaponTimer[weapon_type][player][1].Object = object
				MegaweaponTimer[weapon_type][player][object] = 1
			elseif MegaweaponTimer[weapon_type][player][object] == nil then
				local new_count = MegaweaponTimer[weapon_type][player].Count + 1
				MegaweaponTimer[weapon_type][player].Count = new_count
				MegaweaponTimer[weapon_type][player][new_count] = {}
				MegaweaponTimer[weapon_type][player][new_count].Index = new_count
				MegaweaponTimer[weapon_type][player][new_count].Object = object
				MegaweaponTimer[weapon_type][player][object] = new_count
			end
		end
	end	
end

-- ----------------------------------------------------------------------------------------------------------------
-- Global_Megaweapon_Timer_Remove
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Global_Megaweapon_Timer_Remove(_, _, object, weapon_type)
	if object ~= nil then
		local player = object.Get_Owner()
		if player ~= nil then
			if MegaweaponTimer[weapon_type][player] and MegaweaponTimer[weapon_type][player][object] then
				Set_Megaweapon_Change(weapon_type, true)
				local index = MegaweaponTimer[weapon_type][player][object]
				table.remove(MegaweaponTimer[weapon_type][player], index)
				MegaweaponTimer[weapon_type][player][object] = nil
				MegaweaponTimer[weapon_type][player].Count = MegaweaponTimer[weapon_type][player].Count - 1
				for i = 1, MegaweaponTimer[weapon_type][player].Count do
					local time_object = MegaweaponTimer[weapon_type][player][index].Object
					MegaweaponTimer[weapon_type][player][time_object] = index
				end
			end
		end
	end	
end

-- ----------------------------------------------------------------------------------------------------------------
-- On_Global_Megaweapon_Clicked
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function On_Global_Megaweapon_Clicked(event, button)
	local weapon_type = button.Get_User_Data()
	local weapon = Get_Ready_Megaweapon_System(weapon_type)
	if weapon ~= nil then
		Set_Selected_Objects( {weapon} )
	end
end

-- ----------------------------------------------------------------------------------------------------------------
-- Fire_Megaweapon_At_Region_Event
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Fire_Megaweapon_At_Region_Event(_, _, weapon_object, weapon_target)
	--This Call_Function should be safe because it occurs in response to a network event
	if weapon_object ~= nil and weapon_target ~= nil then
		local script = weapon_object.Get_Script()
		if script ~= nil then
			script.Call_Function("Fire_Megaweapon_At_Region", weapon_target)
		end
	end
end

-- ----------------------------------------------------------------------------------------------------------------
-- Fire_Megaweapon_At_Region
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Fire_Megaweapon_At_Region( region )
	if region ~= nil and TargetingMegaweapon ~= nil then
		local weapon_data = {}
		weapon_data[1] = TargetingMegaweapon
		weapon_data[2] = region
		Set_Selected_Objects( {nil} )
		Send_GUI_Network_Event( "Fire_Megaweapon_At_Region_Event", weapon_data )
	end
end

-- ----------------------------------------------------------------------------------------------------------------
-- Update_Megaweapon
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Update_Megaweapon(weapon_type)
	Check_Megaweapon_Player(weapon_type)
	Make_Tooltip_For_Megaweapon_Button(weapon_type)
	if Megaweapon_Change(weapon_type) or Megaweapon_Refresh(weapon_type) then
		Set_Megaweapon_Change(weapon_type, false)
		local number_weapons = Get_Current_Player_Megaweapons(weapon_type)
		local button = MegaweaponButtons[weapon_type]
		if number_weapons > 0 then
			button.Set_Hidden(false)
			local percent_ready = Get_Current_Player_Megaweapon_Percent_Ready(weapon_type)
			if number_weapons > 1 then
				local number_ready = Get_Current_Player_Megaweapons_Ready(weapon_type)
				if number_ready < number_weapons then
					-- show number ready / number total
					-- show countdown timer
					local wstr_display = Get_Game_Text("TEXT_FRACTION")
					Replace_Token(wstr_display, Get_Localized_Formatted_Number(number_ready), 0)
					Replace_Token(wstr_display, Get_Localized_Formatted_Number(number_weapons), 1)
					button.Set_Text(wstr_display)
				else
					-- show full number
					button.Set_Text(Get_Localized_Formatted_Number(number_ready))
				end
			else
				-- just one weapon system
			end
			if percent_ready < 1.0 then
				-- fill button with percent
				button.Set_Clock_Filled(1.0 - percent_ready)
			else
				button.Set_Clock_Filled(0.0)
			end
		else
			button.Set_Hidden(true)		
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Timers
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Timers()
	for _, timer in pairs(Timers) do
		timer.Set_Hidden(true)
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Enemy_Megaweapons_Data
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Enemy_Megaweapons_Data()
	if not TestValid(this.EnemyMWTimers) then return end
	
	Reset_Timers()
	TimersCount = 0
	
	for _, player_data in pairs(Players) do 
		Update_MW_Timers_For_Player(player_data)
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_MW_Timers_For_Player
-- ------------------------------------------------------------------------------------------------------------------
function Update_MW_Timers_For_Player(player_data)
	
	if not player_data then return end
	
	local player = player_data[1]
	local player_script = player.Get_Script()
	if not player_script then return end
	
	local mw_object = Get_First_Megaweapon_For_Player(player, "Offensive")
	if not TestValid(mw_object) then 
		return
	end	
	
	-- Maria 07.03.2007
	if TimersCount >= MAX_PLAYERS then
		return
	end
	
	TimersCount = TimersCount + 1
	local timer = Timers[TimersCount]
	timer.Set_Hidden(false)
	timer.Set_MW_Data(player, player_data[2], mw_object)
end



function Make_Tooltip_For_Megaweapon_Button(weapon_type)
	local weapon_object = Get_First_Megaweapon(weapon_type)
	local button = MegaweaponButtons[weapon_type]
	local time_remaining = nil

	if not TestValid(weapon_object) then
		return
	end
		
	local script = weapon_object.Get_Script()
	if script ~= nil then
		local megaweapon_cooldown_data = script.Get_Async_Data("MegaweaponCooldown")
		if megaweapon_cooldown_data and megaweapon_cooldown_data.EndTime > 0.0 then
			time_remaining = megaweapon_cooldown_data.EndTime - GetCurrentTime()
			if time_remaining <= 0.0 then
				time_remaining = nil
			end
		end
	end
	
	local tooltip_text = nil
	if time_remaining then
		local time_string = Get_Localized_Formatted_Number.Get_Time(time_remaining)
		tooltip_text = Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), time_string, 0)
	end
	button.Set_Tooltip_Data({"object", { weapon_object, false, false, tooltip_text }})
end

function Get_First_Megaweapon(weapon_type)
	if MegaweaponOwners[weapon_type][LocalPlayer] then
		return MegaweaponOwners[weapon_type][LocalPlayer][1].Object
	end
	
	return nil
end


function Get_First_Megaweapon_For_Player(player, weapon_type)
	if not player then return end
	
	if MegaweaponOwners[weapon_type][player] then
		return MegaweaponOwners[weapon_type][player][1].Object
	end
	
	return nil
end


-- ----------------------------------------------------------------------------------------------------------------
-- Set_Megaweapon_Change
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Set_Megaweapon_Change(weapon_type, on_off)
	MegaweaponChange[weapon_type] = on_off
end

-- ----------------------------------------------------------------------------------------------------------------
-- Megaweapon_Change
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Megaweapon_Change(weapon_type)
	return MegaweaponChange[weapon_type]
end

-- ----------------------------------------------------------------------------------------------------------------
-- Get_Current_Player_Megaweapons
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Get_Current_Player_Megaweapons(weapon_type)

	if MegaweaponPlayer ~= nil then
		if MegaweaponOwners[weapon_type][MegaweaponPlayer] ~= nil then
			return MegaweaponOwners[weapon_type][MegaweaponPlayer].Count
		end
	end
	
	return 0
end

-- ----------------------------------------------------------------------------------------------------------------
-- Check_Megaweapon_Player
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Check_Megaweapon_Player(weapon_type)
	local player = Find_Player("local")
	
	if MegaweaponPlayer == nil or MegaweaponPlayer ~= player then
		Set_Megaweapon_Change(weapon_type, true)
		MegaweaponPlayer = player
	end
end

-- ----------------------------------------------------------------------------------------------------------------
-- Get_Current_Player_Megaweapons_Ready
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Get_Current_Player_Megaweapons_Ready(weapon_type)
	local num = 0
	if MegaweaponPlayer ~= nil and MegaweaponOwners[weapon_type][MegaweaponPlayer] ~= nil then
		num = MegaweaponOwners[weapon_type][MegaweaponPlayer].Count
		if MegaweaponTimer[weapon_type][MegaweaponPlayer] ~= nil then
			num = num - MegaweaponTimer[weapon_type][MegaweaponPlayer].Count
		end
	end
	
	return num
end

-- ----------------------------------------------------------------------------------------------------------------
-- Megaweapon_Refresh
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Megaweapon_Refresh(weapon_type)
	local refresh = false
	if MegaweaponPlayer ~= nil then
		local current_time = GetCurrentTime()
		if MegaweaponTimer[weapon_type][MegaweaponPlayer] ~= nil and MegaweaponTimer[weapon_type][MegaweaponPlayer].Count > 0 then
			refresh = true
		end
	end
	return refresh
end

-- ----------------------------------------------------------------------------------------------------------------
-- Get_Current_Player_Megaweapon_Percent_Ready
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Get_Current_Player_Megaweapon_Percent_Ready(weapon_type)
	local ready = 1.0
	local time_remaining = 0.0
	if MegaweaponPlayer ~= nil then
		if MegaweaponTimer[weapon_type][MegaweaponPlayer] ~= nil then
			local num_timers = MegaweaponTimer[weapon_type][MegaweaponPlayer].Count
			if num_timers > 0 then
				-- get the 1st timer as it has ther least deal
				local megaweapon_object = MegaweaponTimer[weapon_type][MegaweaponPlayer][1].Object
				if TestValid(megaweapon_object) then
					local script = megaweapon_object.Get_Script()
					if script ~= nil then
						local megaweapon_cooldown_data = script.Get_Async_Data("MegaweaponCooldown")
						if megaweapon_cooldown_data.EndTime > 0.0 then
							local total_time = megaweapon_cooldown_data.EndTime - megaweapon_cooldown_data.StartTime
							local dif = GetCurrentTime() - megaweapon_cooldown_data.StartTime
							ready = dif / total_time
						end
					end
				end
			end
		end
	end
	return ready
end

-- ----------------------------------------------------------------------------------------------------------------
-- Get_Ready_Megaweapon_System
-- JSY 3/16/2007 - Adapted from Keith's spy stuff so that we can support all types of megaweapons with one set of functions
-- ------------------------------------------------------------------------------------------------------------------
function Get_Ready_Megaweapon_System(weapon_type)
	if MegaweaponPlayer ~= nil and MegaweaponOwners[weapon_type][MegaweaponPlayer] ~= nil then
		for i = 1, MegaweaponOwners[weapon_type][MegaweaponPlayer].Count do
			local cur_weapon = MegaweaponOwners[weapon_type][MegaweaponPlayer][i].Object
			if MegaweaponTimer[weapon_type][MegaweaponPlayer] == nil or MegaweaponTimer[weapon_type][MegaweaponPlayer][cur_weapon] == nil then
				return cur_weapon
			end
		end
	end
	return nil
end

-- ----------------------------------------------------------------------------------------------------------------
-- On_Force_Region_Color
-- ----------------------------------------------------------------------------------------------------------------
function On_Force_Region_Color(event, source, region, color)
	ForcedRegionColors[region] = color
end

-- ----------------------------------------------------------------------------------------------------------------
-- On_Clear_Region_Color
-- ----------------------------------------------------------------------------------------------------------------
function On_Clear_Region_Color(event, source, region)
	ForcedRegionColors[region] = nil
end

-- ----------------------------------------------------------------------------------------------------------------
-- Show_Start_Mission_Button
-- ----------------------------------------------------------------------------------------------------------------
function Show_Start_Mission_Button()
	if TestValid(this.StartMissionButton) then
		this.StartMissionButton.Set_Hidden(false)
	end
end

-- ----------------------------------------------------------------------------------------------------------------
-- Hide_Start_Mission_Button
-- ----------------------------------------------------------------------------------------------------------------
function Hide_Start_Mission_Button()
	if TestValid(this.StartMissionButton) then
		this.StartMissionButton.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Tooltip_From_UI
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Tooltip_From_UI(_, _, tooltip_data)
	Display_Tooltip(tooltip_data, true)
end

-- ----------------------------------------------------------------------------------------------------------------
-- On_Display_Tooltip
-- ----------------------------------------------------------------------------------------------------------------
function On_Display_Tooltip(_, _, tooltip_data)
	Display_Tooltip(tooltip_data, false)
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Display_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function Display_Tooltip(tooltip_data, hide_floating_tooltip)
	if tooltip_data == nil then return end
	
	if this.Tooltip.Get_Hidden() then 
		this.Tooltip.Set_Hidden(false)
	end
	
	this.Tooltip.Display_Tooltip(tooltip_data, hide_floating_tooltip)
end

-- ----------------------------------------------------------------------------------------------------------------
-- End_Tooltip
-- ----------------------------------------------------------------------------------------------------------------
function End_Tooltip()
	MouseOverObjectTime = GetCurrentTime()
	this.Tooltip.End_Tooltip()
end


-- ----------------------------------------------------------------------------------------------------------------
-- Set_Minor_Announcement_Text
-- ----------------------------------------------------------------------------------------------------------------
function Set_Minor_Announcement_Text(event, source, text_string)
	this.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(false)
	this.MinorAnnouncement.Announcement_bkg.Set_Hidden(false)
	if text_string then
		this.MinorAnnouncement.MinorAnnouncementText.Set_Text(text_string)
		this.MinorAnnouncement.Play_Animation("MinorAnnouncementFade", false)
		this.MinorAnnouncement.Set_Animation_Frame(0)
	else
		this.MinorAnnouncement.MinorAnnouncementText.Set_Text("")
		this.MinorAnnouncement.Announcement_bkg.Set_Hidden(true)
	end
end


-- ----------------------------------------------------------------------------------------------------------------
-- On_Minimap_Region_Clicked
-- ----------------------------------------------------------------------------------------------------------------
function On_Minimap_Region_Clicked(_, _, region)
	if not TestValid(SelectedObject) then
		return
	end
		
	if SelectedObject.Get_Type().Is_Hero() then
		local hero_fleet = SelectedObject.Get_Parent_Object()
		
		if TestValid(hero_fleet) and hero_fleet.Has_Behavior(4) then
			Move_Fleet(hero_fleet, region)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Subtitles_On_Speech_Event_Begin.
-- ------------------------------------------------------------------------------------------------------------------
function Subtitles_On_Speech_Event_Begin(_, _, _, _, text_id)
	--Use different text objects for full screen movies vs in-game speech
	local subtitle_object = nil
	if not this.BlankScreen.Get_Hidden() then
		subtitle_object = this.CinematicSubtitle
	else
		subtitle_object = this.Subtitle	
	end
	
	--If subtitles are disabled then the text_id parameter will be nil
	if text_id and TestValid(subtitle_object) then
		subtitle_object.Set_PreRender(true)
		subtitle_object.Set_Text(text_id)
		subtitle_object.Bring_To_Front()
		subtitle_object.Set_Hidden(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Subtitles_On_Speech_Event_End.
-- ------------------------------------------------------------------------------------------------------------------
function Subtitles_On_Speech_Event_Done(_, _)
	if TestValid(this.Subtitle) then
		this.Subtitle.Set_Hidden(true)
	end
	
	if TestValid(this.CinematicSubtitle) then
		this.CinematicSubtitle.Set_Hidden(true)
	end
end

function Network_Debug_Force_Complete()
	--This Call_Function should be safe because it occurs in response to a network event
	local weapon = Get_First_Megaweapon("Offensive")
	if TestValid(weapon) then
		weapon.Get_Script().Call_Function("Debug_Force_Complete")
	end
	
	weapon = Get_First_Megaweapon("Spy")
	if TestValid(weapon) then
		weapon.Get_Script().Call_Function("Debug_Force_Complete")
	end
	
	weapon = Get_First_Megaweapon("Repair")
	if TestValid(weapon) then
		weapon.Get_Script().Call_Function("Debug_Force_Complete")
	end	
end

function On_Debug_Force_Complete()
	Send_GUI_Network_Event("Network_Debug_Force_Complete", nil)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Pip_Movie_Playing
-- ------------------------------------------------------------------------------------------------------------------
function Set_Pip_Movie_Playing(on_off)
	if PipMoviePlaying == on_off then
		return
	end
	
	PipMoviePlaying = on_off
	this.Tooltip.Set_Pip_Movie_Playing(on_off)
end

function Show_Gane_End_Screen(_, _, scene_name, winner, to_main_menu, destroy_loser, build_temp_cc, game_end)
	local quit_params = {}
	quit_params.Winner = winner
	quit_params.DestroyLoser = destroy_loser
	quit_params.ToMainMenu = to_main_menu
	quit_params.BuildTempCC = build_temp_cc
	quit_params.GameEndTime = game_end
	
	local post_game_ui = this[scene_name]
	if not TestValid(post_game_ui) then
		post_game_ui = this.Create_Embedded_Scene(scene_name, scene_name)
	end
	post_game_ui.Set_Bounds(0.0, 0.0, 1.0, 1.0)
	post_game_ui.Set_Hidden(false)
	post_game_ui.Bring_To_Front()
	post_game_ui.Set_User_Data(quit_params)
	if post_game_ui.Finalize_Init() then
		post_game_ui.Start_Modal(Really_Quit)
	else
		_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc)
	end	
end

function Really_Quit(post_game_ui)
	local quit_params = post_game_ui.Get_User_Data()
	_Quit_Game_Now(quit_params.Winner, quit_params.ToMainMenu, quit_params.DestroyLoser, quit_params.BuildTempCC)
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Activate_Superweapon_By_Index = nil
	Begin_Production = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Can_Access_Research = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
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
	Find_Hero_Button = nil
	GUI_Cancel_Talking_Head = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Clicked_Object = nil
	On_Mouse_Off_Hero_Button = nil
	On_Mouse_Over_Hero_Button = nil
	On_Released_Object = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGColors_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Post_Load_Game = nil
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
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Toggle_Mode = nil
	Update_Hero_Icons_Tooltip_Data = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

