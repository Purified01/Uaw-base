-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/global_hud.lua#157 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/global_hud.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: gary_cox $
--
--            $Change: 85492 $
--
--          $DateTime: 2007/10/04 14:32:37 $
--
--          $Revision: #157 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Global_Mode_Colors")
require("HeroIcons")
require("PGUICommands")
require("PGHintSystem")
require("KeyboardMappingsHandler")
require("PGColors")

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
	TAB_ORDER_RESEARCH_TREE = 100

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	SelectedObject = nil
	CommandCenterType = nil
	CursorOverObject = nil
	Buttons = {}
	
	MiniMapSectorNameToIndexMap = {}
	ResearchTreesInitialized = false
	MODE_NONE = nil
	MODE_CC_PRODUCTION = nil
	MODE_CC_RESOURCE = nil
	MODE_CC_RESEARCH = nil
	CurrentMode = MODE_NONE
	ResearchQuadUpdated = false
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

	this.BuildingUnitIcon.Set_Hidden(true)

	-- Register to hear when the selected fleet changes, and when a fleet is clicked.
	this.Register_Event_Handler("Selection_Changed", nil, Selection_Changed)
	this.Register_Event_Handler("Fleet_Right_Clicked", nil, On_Fleet_Right_Clicked)
	this.Register_Event_Handler("Minimap_Region_Clicked", this.Minimap, On_Minimap_Region_Clicked)
	
	this.Register_Event_Handler("GameplayUI_Mouse_Clicked", nil, GameplayUI_Mouse_Clicked)
			
	this.Register_Event_Handler("Update_Tree_Scenes", nil, On_Update_Tree_Scenes)
	
	this.Research_Tree.Set_Hidden(true)
	this.Research_Tree.Set_Tab_Order(TAB_ORDER_RESEARCH_TREE)
	
	this.Register_Event_Handler("Close_Research_Tree", nil, Hide_Research_Tree)
	-- ------------------------------------------------------------------------------------------------------------------------------------

	Hero_Icons_Init(this)
			
	--Possibly not the final system for hotkey handling, but for now we'll listen for physical
	--key presses and translate them here
	this.Register_Event_Handler("Key_Press", this, On_Key_Press)
	
	-- Maria 07.06.2006
	-- Esc key should back out of all open HUD elements (socket schematic and purchase menus) before going to main menu
	this.Register_Event_Handler("Closing_All_Displays", nil, On_Closing_All_Displays)
	
	CloseHuds = false
	
	this.Register_Event_Handler("Global_Megaweapon_Registration", nil, Register_Global_Megaweapon)
	this.Register_Event_Handler("Global_Megaweapon_Ready", nil, Global_Megaweapon_Timer_Remove)
	this.Register_Event_Handler("Global_Megaweapon_Not_Ready", nil, Global_Megaweapon_Timer_Add)
	
	MegaweaponButtons["Spy"] = this.GlobalSpyButton
	MegaweaponButtons["Offensive"] = this.ObliterateButton
	MegaweaponButtons["Repair"] = this.RepairButton
	MegaweaponTargeting["Spy"] = Global_Mode_Set_Spy_Targeting_Active
	MegaweaponTargeting["Offensive"] = Global_Mode_Set_Obliterate_Targeting_Active
	MegaweaponTargeting["Repair"] = Global_Mode_Set_Repair_Targeting_Active
	TargetingFunction = nil
	
	for type, button in pairs(MegaweaponButtons) do
		button.Set_Hidden(true)
		button.Set_User_Data(type)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Global_Megaweapon_Clicked)
	end
	
	-- Maria 10.18.2006
	-- Hooking up the hot key VK_W to hide the UI
	this.Register_Event_Handler("On_Hide_UI", nil, On_Hide_UI)	
			
	this.Register_Event_Handler("Send_GUI_Network_Event", nil, On_Send_GUI_Network_Event)
			
	-- Register the handler for the network event Start_Undo_Research here so that all players get it
	this.Register_Event_Handler("Network_Start_Research", nil, Network_Start_Research)
	this.Register_Event_Handler("Network_Cancel_Research", nil, Network_Cancel_Research)
	Update_Tree_Scenes(LocalPlayer)
	
	this.Register_Event_Handler("Fire_Megaweapon_At_Region_Event", nil, Fire_Megaweapon_At_Region_Event)
	
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
	if TestValid(this.StartMissionButton) then
		this.Register_Event_Handler("Button_Clicked", this.StartMissionButton, Start_Mission_Clicked)
	end
	
	this.Register_Event_Handler("Display_Tooltip", nil, On_Display_Tooltip)	
	this.Register_Event_Handler("End_Tooltip", nil, End_Tooltip)	
	MouseOverObjectTime = nil
	MouseOverHoverTime = 0.2
	
	--Scroll visualization support
	this.Register_Event_Handler("Begin_Mouse_Button_Scroll", nil, On_Begin_Mouse_Button_Scroll)
	this.Register_Event_Handler("End_Mouse_Button_Scroll", nil, On_End_Mouse_Button_Scroll)	
	
	this.Register_Event_Handler("Set_Minor_Announcement_Text", nil, Set_Minor_Announcement_Text)
	
	-- Maria 06.18.2007
	-- *** HINT SYSTEM ***
	PGHintSystem_Init()
	Register_Hint_Context_Scene(this)
		
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
	
	this.Register_Event_Handler("Debug_Force_Completion", nil, On_Debug_Force_Complete)	
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

	if not TestValid(SelectedObject) or not SelectedObject.Get_Type().Is_Hero() then
	
		--If we're spying we can have the fleet panel open for an object that's not logically selected.
		--If that's the object our click hit, then we'll get a Selection_Changed but we don't want
		--to close out the panel.
		local current_hero = this.FleetPanel.Get_Hero()
		if not TestValid(current_hero) or current_hero.Get_Owner() == LocalPlayer then
			this.FleetPanel.Close()
		elseif not TestValid(CursorOverObject) or CursorOverObject.Get_Parent_Object() ~= current_hero.Get_Parent_Object() then
			this.FleetPanel.Close()			
		end
		
		if TestValid(SelectedObject) then
			local script = SelectedObject.Get_Script()
			if script then
				local weapon_type = script.Call_Function("Get_Weapon_Type")
				if weapon_type then
					TargetingMegaweapon = SelectedObject
					TargetingFunction = MegaweaponTargeting[weapon_type]
				end
			end
		end
					
		return
	end
	
	-- Hide the Research tree if it's open before opening the roll out
	Hide_Research_Tree()
	
	this.FleetPanel.Set_Hero(SelectedObject)
	this.FleetPanel.Open()
	
	local source_region = SelectedObject.Get_Region_In()
	if not TestValid(source_region) then
		return
	end	
	
	ValidMoveRegions = source_region.Find_Regions_Within(SelectedObject.Get_Type().Get_Type_Value("Travel_Range"))	
	LastTravelDestination = nil
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Network_Start_Research - we need to send a network event so that we do not go out of sync!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Network_Start_Research(_, _, player, path, index)
	
	local player_script = player.Get_Script()
	if player_script ~= nil then 
		player_script.Call_Function("Start_Research", {path, index})
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Network_Cancel_Research - we need to send a network event so that we do not go out of sync!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Network_Cancel_Research(_, _, player, path, index)
	
	local player_script = player.Get_Script()
	if player_script ~= nil then 
		player_script.Call_Function("Cancel_Research", {path, index})
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Tree_Scenes
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Tree_Scenes(event, source, player)
	Update_Tree_Scenes(player)
end

-- -----------------------------------------------------------------------------------------------------------------
-- Update_Tree_Scenes
-- ------------------------------------------------------------------------------------------------------------------
function Update_Tree_Scenes(player)
	if player == Find_Player("local") then
		Raise_Event_Immediate_All_Scenes("Update_Tree_Scene", nil)
	end
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
-- Someone clicked a fleet
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Fleet_Clicked(fleet)
	if not TestValid(fleet) then
		return
	end
		
	if not fleet.Is_Fleet_Moving() then
		-- Hide the Research tree if it's open before opening the roll out
		Hide_Research_Tree()
		
		-- Open/Create the contents window for its fleet!.
		if fleet.Is_Striker_Fleet() then
			local hero = fleet.Get_Fleet_Hero()
			if hero.Get_Owner() == LocalPlayer then
				Set_Selected_Objects({hero})
			else
				--Must be spying!  Show the fleet contents directly
				this.FleetPanel.Set_Hero(hero)
				this.FleetPanel.Open()
			end
		end
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
	success = success and Global_Begin_Production(Find_Player("local"), region, unit_type, into_fleet)
	
	-- Play a sound.
	if success then
		Play_SFX_Event("GUI_Generic_Button_Select")
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
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

	-- Fire an event for the scenario script that research has completed.
	local game_mode_script = Get_Game_Mode_Script()
	if game_mode_script then 
		local ret = game_mode_script.Call_Function("On_Fleet_Move_Begin", fleet, region, into_fleet)
		if ret == false then
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
			return
		end
	end
	
	-- Maria 05.03.2006
	-- Cancel all the units in production that are coming to this fleet!.
	Raise_Event_Immediate_All_Scenes("On_Move_Fleet", { fleet, fleet.Get_Parent_Object() })

	
	local success = fleet.Move_Fleet_To_Region(region, into_fleet)
	if success then
		Play_SFX_Event("GUI_Generic_Button_Select")
		
		-- Deselect the fleet.
		Set_Selected_Objects({})
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound") 
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Someone right-clicked a fleet
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Fleet_Right_Clicked(_, _, fleet_id)
	if not TestValid(SelectedObject) then
		return
	end

	if not fleet_id then
		return
	end
	
	local fleet = Get_Object_From_ID(fleet_id)
	local region = fleet.Get_Parent_Object()
	
	if SelectedObject.Get_Type().Is_Hero() then
		local hero_fleet = SelectedObject.Get_Parent_Object()
		
		if TestValid(hero_fleet) and hero_fleet ~= fleet and hero_fleet.Has_Behavior(BEHAVIOR_FLEET) then
			Move_Fleet(hero_fleet, region)
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
		if script and script.Call_Function("Is_Legal_Megaweapon_Target", region) then
			Fire_Megaweapon_At_Region( region )
			TargetingMegaweapon = nil
		end
		Set_Selected_Objects({})
	elseif region.Get_Owner() == LocalPlayer then
		local command_center = region.Get_Command_Center()
		if TestValid(command_center) then
			On_Left_Clicked_Command_Center(command_center)
		else
			Set_Selected_Objects({})	
			Point_Camera_At(region)
		end
	else
		Set_Selected_Objects({})	
		Point_Camera_At(region)
	end	
end

function On_Left_Clicked_Command_Center(cc_object)
	Point_Camera_At(CursorOverObject)
	if cc_object.Has_Behavior(BEHAVIOR_SELECTABLE) then
		if cc_object ~= SelectedObject then
			Set_Selected_Objects({cc_object})	
			local region = cc_object.Get_Region_In()
			if TestValid(region) then
				local cc_scene = region.Get_GUI_Scenes()[1]
				cc_scene.Raise_Event_Immediate("Request_Toggle_Build_Menu", nil, nil)
			end
		else
			Set_Selected_Objects({})	
		end	
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Right_Clicked_Region(region)
	if not TestValid(SelectedObject) then
		return
	end
		
	if SelectedObject.Get_Type().Is_Hero() then
		local hero_fleet = SelectedObject.Get_Parent_Object()
		
		if TestValid(hero_fleet) and hero_fleet ~= fleet and hero_fleet.Has_Behavior(BEHAVIOR_FLEET) then
			Move_Fleet(hero_fleet, region)
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function Get_Was_Mouse_Clicked(button)
	if Get_Input_Scene() == this then
		return wasmouseclicked
	else
		return Get_Input_Scene().Call_Function("Get_Was_...")
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function GameplayUI_Mouse_Clicked(event_name, source, button, clicked_and_release_same_gameobject)
	if clicked_and_release_same_gameobject and TestValid(CursorOverObject) then
		local close_upgrade_menu = true
		if button == 1 then
			if CursorOverObject.Has_Behavior(BEHAVIOR_REGION) then
				On_Left_Clicked_Region(CursorOverObject)
			elseif CursorOverObject.Has_Behavior(BEHAVIOR_REGION_LABEL) or  CursorOverObject.Get_Type().Is_Dummy_Global_Icon() == true then
				-- We are clicking on an object over the region label (or the region label itself!). Thus, get the parent object and 
				-- process the click according to it!.
				local parent_object = CursorOverObject.Get_Parent_Object()
				if parent_object ~= nil then
					if parent_object.Has_Behavior(BEHAVIOR_REGION) then
						-- clicked region label itself.
						On_Left_Clicked_Region(parent_object)
						
					elseif parent_object.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) then
						if parent_object.Get_Owner() == LocalPlayer and not TargetingMegaweapon then
							On_Left_Clicked_Command_Center(parent_object)
						else
							--Treat clicks on enemy command centers as a click on the region
							On_Left_Clicked_Region(parent_object.Get_Region_In())
						end		
					elseif parent_object.Has_Behavior(BEHAVIOR_HARD_POINT) then
					
						local upgrade_scene = CursorOverObject.Get_GUI_Scenes()[1]
						if upgrade_scene.Get_Current_State_Name() == "Closed" then
							this.Raise_Event_Immediate("Closing_All_Displays", nil, nil)
							Point_Camera_At(CursorOverObject)
							upgrade_scene.Set_State("Open")
						else
							upgrade_scene.Set_State("Closed")
						end						
						
					elseif parent_object.Has_Behavior(BEHAVIOR_FLEET) then
						if TargetingMegaweapon then
							On_Left_Clicked_Region(parent_object.Get_Parent_Object())
						else
							On_Fleet_Clicked(parent_object)
						end
					end
				end
			end
		elseif button == 2 then
			if TestValid(TargetingMegaweapon) then
				Set_Selected_Objects({})
			elseif SelectedObject then
				local region = CursorOverObject.Get_Region_In()
				if TestValid(region) then
					On_Right_Clicked_Region(region)
				end
			end
		end
		
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Update()

	local player = Find_Player("local")
	if player.Is_Build_Types_List_Initialized() == true and ResearchTreesInitialized == false then
		Raise_Event_Immediate_All_Scenes("Update_Tree_Scene", nil)
		ResearchTreesInitialized = true
	end
	
	local update_command_bar = true
	
	local player = Find_Player("local")

	Process_Fade()
	
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
	
	CloseHuds = Is_Tree_Scene_Open()
end

function Update_Day_Counter()
	local day_counter = Get_Day_Counter()
	if not DayCounter or DayCounter ~= day_counter then
		DayCounter = day_counter
		this.DayCounter.Set_Text(Replace_Token(Get_Game_Text("TEXT_GLOBAL_DAY_COUNTER"), Get_Localized_Formatted_Number(DayCounter), 0))
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Mouse_Over
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Mouse_Over()
	local old_cursor_over = CursorOverObject
	local mouse_over_ui = false
	CursorOverObject, mouse_over_ui = Get_Object_At_Cursor()
	if not TestValid(CursorOverObject) then
		CursorOverObject = this.Minimap.Get_Mouse_Over_Region()
	end
	
	if TestValid(TargetingMegaweapon) then
		local legal_target = false
		if TestValid(CursorOverObject) then
			local script = TargetingMegaweapon.Get_Script()
			if script then 
				legal_target = script.Call_Function("Is_Legal_Megaweapon_Target", CursorOverObject.Get_Region_In())
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
		if TestValid(tooltip_object) then
			if time_now - MouseOverObjectTime > MouseOverHoverTime then
				if not mouse_over_ui then
					this.Tooltip.Display_Tooltip({'object', {tooltip_object}})
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
			if parent.Has_Behavior(BEHAVIOR_FLEET) then
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
-- Is_Tree_Scene_Open
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Tree_Scene_Open()
	return not this.Research_Tree.Get_Hidden()
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
-- Build_Command_Center
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Build_Command_Center(region, cc_type)
   if not region.Has_Command_Center() and not region.Is_Command_Center_Under_Construction() then
      region.Start_Command_Center_Construction(cc_type, Find_Player("local"))
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
-- Update all region colors based on game and UI state
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Region_Colors()
	for _, region in pairs(Regions) do
		local color = Get_Region_Color(region)
		if color then
			local r, g, b = color[1], color[2], color[3]
			region.Set_Region_Color(r, g, b)
			this.Minimap.Set_Region_Color(region, r, g, b)
		end
	end
end

function Update_Region_Textures()
	if TestValid(SelectedObject) and SelectedObject.Get_Type().Is_Hero() and TestValid(SelectedObject.Get_Region_In()) then
		for _, region in pairs(Regions) do
			region.Set_Region_Texture(region.Get_Owner().Get_Faction_Value("Region_Texture_Solid"))
		end
		for _, valid_region in pairs(ValidMoveRegions) do
			valid_region.Set_Region_Texture(valid_region.Get_Owner().Get_Faction_Value("Region_Texture"))
		end		
	else
		for _, region in pairs(Regions) do
			region.Set_Region_Texture(region.Get_Owner().Get_Faction_Value("Region_Texture"))
		end	
	end	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Travel_Preview
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Travel_Preview()

	if not TestValid(SelectedObject) then
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

	local is_valid_region = false
	for _, valid_region in pairs(ValidMoveRegions) do
		if valid_region == target_region then
			is_valid_region = true
		end
	end
	
	local regions_passed_through = Show_Travel_Preview(icon_object, target_region)
	local tooltip_text = nil
	if not is_valid_region then
		tooltip_text = Get_Game_Text("TEXT_REGION_UNREACHABLE")
		Set_Travel_Preview_Color(unpack(ROUTE_COLOR_PREVIEW_INVALID))
	else
		tooltip_text = Get_Game_Text("TEXT_REGIONS_PASSED_THROUGH")
		Replace_Token(tooltip_text, Get_Localized_Formatted_Number(regions_passed_through), 0)
		Set_Travel_Preview_Color(unpack(ROUTE_COLOR_PREVIEW))
	end
	
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
	if CursorOverObject == region and is_valid_region then		
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
	ValidMoveRegions = source_region.Find_Regions_Within(source_hero.Get_Type().Get_Type_Value("Travel_Range"))
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
	
			object.Register_Signal_Handler(Global_Megaweapon_Delete_Pending, "OBJECT_DELETE_PENDING")
	
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
			weapon_type = weapon_script.Call_Function("Get_Weapon_Type")
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
		local megaweapon_cooldown_data = script.Call_Function("Get_Megaweapon_Cooldown")
		if megaweapon_cooldown_data.EndTime > 0.0 then
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
						local megaweapon_cooldown_data = script.Call_Function("Get_Megaweapon_Cooldown")
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

-- ----------------------------------------------------------------------------------------------------------------
-- Start_Mission_Clicked
-- ----------------------------------------------------------------------------------------------------------------
function Start_Mission_Clicked()
	Get_Game_Mode_Script().Call_Function("Request_Start_Mission")
end

-- ----------------------------------------------------------------------------------------------------------------
-- On_Display_Tooltip
-- ----------------------------------------------------------------------------------------------------------------
function On_Display_Tooltip(_, _, tooltip_data)
	if tooltip_data then
		this.Tooltip.Display_Tooltip(tooltip_data)
	end
end

-- ----------------------------------------------------------------------------------------------------------------
-- End_Tooltip
-- ----------------------------------------------------------------------------------------------------------------
function End_Tooltip()
	MouseOverObjectTime = GetCurrentTime()
	this.Tooltip.End_Tooltip()
end

function On_Begin_Mouse_Button_Scroll(_, _, anchor_x, anchor_y)
	this.ScrollAnchor.Set_Screen_Position(anchor_x, anchor_y)
	this.ScrollAnchor.Set_Hidden(false)
end

function On_End_Mouse_Button_Scroll()
	this.ScrollAnchor.Set_Hidden(true)
end

function Set_Minor_Announcement_Text(event, source, text_string)
	this.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(false)
	this.MinorAnnouncement.MinorAnnouncementFrame.Set_Hidden(false)	
	if text_string then
		this.MinorAnnouncement.MinorAnnouncementText.Set_Text(text_string)
		this.MinorAnnouncement.Play_Animation("MinorAnnouncementFade", false)
		this.MinorAnnouncement.Set_Animation_Frame(0)
	else
		this.MinorAnnouncement.MinorAnnouncementText.Set_Text("")
		this.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(true)
		this.MinorAnnouncement.MinorAnnouncementFrame.Set_Hidden(true)
	end
end

function On_Minimap_Region_Clicked(_, _, region)
	if not TestValid(SelectedObject) then
		return
	end
		
	if SelectedObject.Get_Type().Is_Hero() then
		local hero_fleet = SelectedObject.Get_Parent_Object()
		
		if TestValid(hero_fleet) and hero_fleet.Has_Behavior(BEHAVIOR_FLEET) then
			Move_Fleet(hero_fleet, region)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Subtitles_On_Speech_Event_Begin.
-- ------------------------------------------------------------------------------------------------------------------
function Subtitles_On_Speech_Event_Begin(_, _, _, _, text_id)
	--If subtitles are disabled then the text_id parameter will be nil
	if text_id and TestValid(this.Subtitle) then
		this.Subtitle.Set_Text(text_id)
		this.Subtitle.Bring_To_Front()
		this.Subtitle.Set_Hidden(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Subtitles_On_Speech_Event_End.
-- ------------------------------------------------------------------------------------------------------------------
function Subtitles_On_Speech_Event_Done(_, _)
	if TestValid(this.Subtitle) then
		this.Subtitle.Set_Hidden(true)
	end
end

function On_Debug_Force_Complete()
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