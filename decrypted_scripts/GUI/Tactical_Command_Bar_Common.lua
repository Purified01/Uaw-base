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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tactical_Command_Bar_Common.lua
--
--    Original Author: Maria_Teruel
--
--          DateTime: 2006/12/01 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("HeroIcons")
require("Mouse")
require("SpecialAbilities")
require("PGCommands")
require("Superweapons")
require("PGHintSystem")
require("KeyboardMappingsHandler")
require("PGColors")

MODE_INVALID = -1
MODE_CONSTRUCTION = 1 -- can make buildings
MODE_SELECTION = 2    -- can control units
Mode = MODE_CONSTRUCTION

function Init_Tab_Orders()
	-- Tab order: Sell button, hero buttons, queue buttons, faction specific button, superweapon buttons, special ability groups
	
	-- When the build menu is open we want it to have the highest tab priority!.
	TAB_ORDER_ABILITY_BUTTONS = 1
	TAB_ORDER_BUILDING_BUTTONS = 100
	
	TAB_ORDER_HERO_BUTTONS = 200
	
	TAB_ORDER_CONTROL_GROUP_BUTTONS = 250
	
	TAB_ORDER_SELL_BUTTON = 300
	
	TAB_ORDER_RESEARCH_TREE = 400
	TAB_ORDER_QUEUE_BUTTONS = 500	
	TAB_ORDER_FACTION_SPECIFIC_BUTTON = 600
	TAB_ORDER_SUPERWEAPON_BUTTONS =	700 
	TAB_ORDER_ABILITY_GROUPS = 800	
	TAB_ORDER_BATTLE_CAM_BUTTON = 900
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------------------------------------------------------
function Init_Tactical_Command_Bar_Common(scene, owner)

	if scene == nil or owner == nil then 
		return
	end
	Scene = scene
	LocalPlayer = owner
	DisplayCreditsPop = true
	

	-- Register for hide notifications
	this.Register_Event_Handler("Component_Hidden", nil, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden", nil, Enable_UI_Element_Event)
	
	-- Get the VideoSettingsManager object - Oksana
	Register_Video_Commands()
	
	-- VERY IMPORTANT!!! we need to initialize the list of special abilities manually!.
	Initialize_Special_Abilities(true) -- true = init the key mapping data for the abilities (we need it for the tooltip display!)

	-- store the original bounds of the letterbox quads
	LBBottom = {}
	LBBottom.x, LBBottom.y, LBBottom.w, LBBottom.h = this.LetterboxBottom.Get_Bounds()
	
	LBTop = {}
	LBTop.x, LBTop.y, LBTop.w, LBTop.h = this.LetterboxTop.Get_Bounds()

	CurrentSelectionNumTypes = 0
	
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	-- Timer to reduce calls for update_upgrade
	IsLetterboxMode = false
	BuildButtons = {}
	UpgradeButtons = {}
	Mode = MODE_CONSTRUCTION
	SelectedObjects = {}
	SelectedObjectsByType = {}
	SelectedBuilding = nil
	BuildersAreSelected = false
	CurrentSpecialAbilityUnitTypeName = nil
	CurrentSpecialAbilityName = nil
	CurrentTargetingAbilityButton = nil
	QueueManager = nil
	QueueTypes = {}
	QueueButtons = {}
	QueueButtonsByType = {}
	QueueBuyMenu = nil
	MouseOverObjectTime = 0
	MouseOverObject = nil
	MouseOverHoverTime = 0.05
	BuildingTypesToFlash = {}
	ConstructorTypeToFlash = {}
	last_time = nil
	LastWalkerPop = nil
	
	
	DefaultAbilityClockTint = {0.0, 1.0, 0.0, 0.43137254} -- alpha = 110/255
	RechargingAbilityClockTint = {1.0, 0.0, 0.0, 0.43137254} -- alpha = 110/255
	
	
	SpecialAbilityButtonPool = nil
	SpecialAbilityButtons = {}
	SpecialAbilityButtonBasePos = {}
	SpecialAbilityButtonXOffset = 0
	SpecialAbilityButtonBigXOffset = 0
	LeftBrackets = {}
	LeftBracketPool = nil
	LeftBracketBasePos = nil
	LeftBracketXOffset = 0
	RightBrackets = {}
	RightBracketPool = nil
	RightBracketBasePos = nil
	RightBracketXOffset = 0
	SpecialAbilityTexts = {}
	SpecialAbilityTextPool = nil
	SpecialAbilityBasePos = nil
	SpecialAbilityXOffset = nil
	
	ResearchTreesInitialized = false
	CurrentConflictLocation = nil
	LastRawMaterials = nil	-- keep track of the amount of tactical credits this player has.
	LastUsedPopCap = nil
	LastTotalPopCap = nil
	LastRMCap = nil

	-- Is this a replay game?
	IsReplay = nil -- we need to check this during service, the game does not know yet at this point
		
	-- if a constructor has started building or finished construction its build menu will close.
	-- This happens because we need to update UI for all abilities.  Thus, in order to prevent that from 
	-- happening, we keep track of constructors that may have opened up the menu so that when the scene
	-- is refreshed we know not to close the menu.
	CurrentConstructorsList = {}
	BuilderMenuOpen = false
	
	Init_Mouse_Buttons()
	
	QueueTypesToFlash = {}

	Set_Announcement_Text("")

	Tooltip = Scene.Tooltip
	this.Register_Event_Handler("Display_Tooltip", nil, On_Display_Tooltip)	
	this.Register_Event_Handler("End_Tooltip", nil, End_Tooltip)
	this.Register_Event_Handler("UI_Display_Tooltip_Resources", nil, Set_UI_Display_Tooltip_Resources)
	
	Init_Minor_Announcement_Text()
	
	-- Maria 07.06.2006
	-- Esc key should back out of all open HUD elements (socket schematic and purchase menus) before going to main menu
	Scene.Register_Event_Handler("Closing_All_Displays", nil, On_Closing_All_Displays)
	
	-- Maria 08.09.2006
	-- Hooking up the hot key VK_W to hide the UI
	Scene.Register_Event_Handler("On_Hide_UI", nil, On_Hide_UI)	

	Scene.Register_Event_Handler("Special_Ability_Targeting_Ended", nil, On_Special_Ability_Targeting_Ended)

	-- Get the queue manager.
	QueueManager = Scene.Tactical_Queue_Manager
	QueueManager.Close()
	
	-- Superweapons
	Superweapons_Init(Scene)
	
	-- ******************	ABILITY BUTTONS SETUP	- BEGIN	**************************************************
	-- Create special ability button pool.
	this.Register_Event_Handler("UI_Start_Flash_Ability_Button", nil, UI_Start_Flash_Ability_Button)
	this.Register_Event_Handler("UI_Stop_Flash_Ability_Button", nil,UI_Stop_Flash_Ability_Button)
	
	SpecialAbilityButtons = {}
	SpecialAbilityButtons = Find_GUI_Components(Scene.CommandBar.SpecialAbilityButtons, "SpecialAbilityButton")
	SAButtonIdxToOrigBoundsMap = {}
	for idx, button in pairs(SpecialAbilityButtons) do
		button.Set_Hidden(true)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Unit_Special_Ability_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Unit_Special_Ability_Right_Clicked)
		button.Set_Tab_Order(TAB_ORDER_ABILITY_BUTTONS + idx)
		
		SAButtonIdxToOrigBoundsMap[idx] = {}
		SAButtonIdxToOrigBoundsMap[idx].x, SAButtonIdxToOrigBoundsMap[idx].y, SAButtonIdxToOrigBoundsMap[idx].w, SAButtonIdxToOrigBoundsMap[idx].h = button.Get_Bounds()	
	end
	
	Compute_SA_Buttons_Gap()
	AbButtonsToFlash = {}
	
	-- All ab groups scriptables.
	AbGroups = {}
	AbSeparators = {}
	LastSeparatorIndex = 0
	AbSeparators = Find_GUI_Components(this.CommandBar.SpecialAbilityButtons, "Separator")	
	for _, sep in pairs(AbSeparators) do
		sep.Set_Hidden(true)
	end		
	
	ABILITIES_PER_ROW = 10
	-- ******************	ABILITY BUTTONS SETUP	- END		**************************************************
	
	-- Maria 08.30.2006	- Reinforcements menu manager!
	ReinforcementsMenuManager = Scene.ReinforcementsMenu
	
	--Do this to avoid an anooying script error on shutdown.
	if not TestValid(ReinforcementsMenuManager) then
		ReinforcementsMenuManager = nil
	end
	
	-- This is needed for the alien faction to determine whether to show/hide the reticles on a walker
	CustomizationModeOn = false
	
	-- Find all the build buttons (for constructing buildings)
	if TestValid(Scene.CommandBar.BuildButtons) then
		BuildButtons = Find_GUI_Components(Scene.CommandBar.BuildButtons, "BuildButton")
	else
		BuildButtons = Find_GUI_Components(Scene.CommandBar, "BuildButton")
	end
	
	for index, button in pairs(BuildButtons) do
		button.Set_Hidden(true)
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Button_Click)
		button.Set_Tab_Order(TAB_ORDER_BUILDING_BUTTONS + index)
	end
	
	-- Start flashing a button to build a building.
	Scene.Register_Event_Handler("UI_Start_Flash_Construct_Building", nil, UI_Start_Flash_Construct_Building)

	-- Stop flashing a button to build a building.
	Scene.Register_Event_Handler("UI_Stop_Flash_Construct_Building", nil, UI_Stop_Flash_Construct_Building)
	
	-- Register to hear when the list of selected objects changed
	Scene.Register_Event_Handler("Selection_Changed", nil, Selection_Changed)

	Hero_Icons_Init(Scene)
	
	-- Register for updates on development feedback test
	Scene.Register_Event_Handler("Stub_Text", nil, Stub_Text)
	Scene.StubText.Set_Hidden(true)

	-- Used for things like "VICTORY!"
	Scene.Register_Event_Handler("Set_Announcement_Text", nil, Set_Announcement_Text)
	Scene.Register_Event_Handler("Set_Skirmish_Game_End_Announcement_Text", nil, Set_Skirmish_Game_End_Announcement_Text)

	-- Used for things like "Objective Completed"
	Scene.Register_Event_Handler("Set_Minor_Announcement_Text", nil, Set_Minor_Announcement_Text)
	
	Scene.Register_Event_Handler("Send_GUI_Network_Event", nil, On_Send_GUI_Network_Event)
	Scene.Register_Event_Handler("Network_Activate_Ability", nil, On_Network_Activate_Ability)
	Scene.Register_Event_Handler("Network_Deactivate_Ability", nil, On_Network_Deactivate_Ability)
	Scene.Register_Event_Handler("Network_Build_Hard_Point", nil, On_Network_Build_Hard_Point)
	Scene.Register_Event_Handler("Network_Cancel_Build_Hard_Point", nil, On_Network_Cancel_Build_Hard_Point)
	Scene.Register_Event_Handler("Networked_Mode_Switch", nil, On_Networked_Mode_Switch)
	Scene.Register_Event_Handler("Networked_Select_Next_Builder", nil, On_Networked_Select_Next_Builder)
	Scene.Register_Event_Handler("Networked_Point_Camera_At_Next_Builder", nil, On_Networked_Point_Camera_At_Next_Builder)	
	Scene.Register_Event_Handler("Network_Forfeit_Game", nil, On_Network_Forfeit_Game)
	
	-- Figure out current mode, based on selected objects
	Selection_Changed()
	Mode = MODE_INVALID
	Update_Mode()
	
	Init_Queues_Interface()
	QueueButtons = Find_GUI_Components(Scene.CommandBar, "QueueType")
	QueueButtonsByType = {}
	for index, button in pairs(QueueButtons) do 
		button.Set_User_Data(QueueTypes[index])
		button.Show_Queue_Line(false)
		button.Show_Queue_Buy_Line(false)
		QueueButtonsByType[QueueTypes[index]] = button
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Queue_Button_Clicked)
		
		-- tooltip data
		button.Set_Tooltip_Data({'ui', QueueTypeToTooltipDataMap[QueueTypes[index]]})
		
		-- tab order for hotkey navigation
		button.Set_Tab_Order(index + TAB_ORDER_QUEUE_BUTTONS)
	end
	
	QueueManager.Set_Tab_Order(TAB_ORDER_QUEUE_BUTTONS + #QueueButtons + 1)
	
	Update_Queue_Textures()

	-- MARIA 01.31.2007 - Disabling this as per assigned task.  I will keep it here though in case they want this enabled again.
	BuildModeOn = false
	
	--Hide letterbox quads by default	
	Scene.LetterboxTop.Set_Hidden(true)
	Scene.LetterboxBottom.Set_Hidden(true)
	
	Scene.Register_Event_Handler("UI_Start_Flash_Produce_Units", nil, UI_Start_Flash_Produce_Units)
	Scene.Register_Event_Handler("UI_Stop_Flash_Produce_Units", nil, UI_Stop_Flash_Produce_Units)
	Scene.Register_Event_Handler("UI_Temp_Enable_Build_Item", nil, UI_Temp_Enable_Build_Item)
	
	Scene.Register_Event_Handler("UI_Start_Flash_Produce_Unit", nil, UI_Start_Flash_Produce_Unit)
	Scene.Register_Event_Handler("UI_Stop_Flash_Produce_Unit", nil, UI_Stop_Flash_Produce_Unit)
	Scene.Register_Event_Handler("UI_Start_Flash_Queue_Buttons", nil, UI_Start_Flash_Queue_Buttons)
	Scene.Register_Event_Handler("UI_Stop_Flash_Queue_Buttons", nil, UI_Stop_Flash_Queue_Buttons)
	
	Scene.Register_Event_Handler("Hard_Point_Detachment", nil, On_Hard_Point_Detachment)
	Scene.Register_Event_Handler("Hard_Point_Attachment", nil, On_Hard_Point_Attached)
	
	Scene.Register_Event_Handler("Update_Tree_Scenes", nil, On_Update_Tree_Scenes)
	Scene.Register_Event_Handler("Close_Research_Tree", nil, Hide_Research_Tree)
	
	-- functionality for designers
	Scene.Register_Event_Handler("Display_Build_Menu", nil, Display_Build_Menu)	
	Scene.Register_Event_Handler("Displaying_HP_Menu", nil, On_Displaying_HP_Menu)
	
	-- Register the handler for the network event Start/Cancel Research here so that all players get it
	Scene.Register_Event_Handler("Network_Start_Research", nil, Network_Start_Research)
	Scene.Register_Event_Handler("Network_Cancel_Research", nil, Network_Cancel_Research)
	
	Update_Tree_Scenes(LocalPlayer)

	-- when a button to build a patch is pressed this event is raised
	-- this will take the event and send it on to Novus_player	
	Scene.Register_Event_Handler("Build_Patch_Now", nil, Network_Build_Patch)

	-- JLH 01.04.2007
	-- Visibility of the achievement buff window
	Scene.Register_Event_Handler("Toggle_Achievement_Buff_Window", nil, On_Toggle_Achievement_Buff_Window)
	
	-- JLH 01.18.2007
	-- *** HINT SYSTEM ***
	PGHintSystem_Init()
	Register_Hint_Context_Scene(Scene)
	
	Scene.Register_Event_Handler("Type_Lock_State_Changed", nil, On_Update_Construction_Mode)
	Scene.Register_Event_Handler("Resource_Harvested", nil, On_Resource_Harvested)
	
	HardPointConfigurationMode = false	
	Scene.Register_Event_Handler("Network_Sell_Structure", nil, On_Network_Sell_Structure)
	
	Init_Keyboard_Mappings_Handler()
	
	-- When zooming the radar map in, we want all other capabilities of the command bar to be disabled.
	CommandBarEnabled = true
	
	--RADAR stuff
	RADAR_MAP_ANIMATION_LENGTH = 7.0/30.0 -- 7 frames
	RADAR_MAP_ENLARGE_FACTOR = 2.0 -- enlarge the map by this much.
	IsRadarOpen = false
	IsRadarAnimating = false
	
	if this.RadarTray then
		Scene.Register_Event_Handler("Animation_Finished", this.RadarTray, Unlock_Command_Bar)	
	end
	
	--if this.RadarBackground then
		--background_texture = RadarMap.Get_Background_Texture_Name()
		--if background_texture then
			--this.RadarBackground.Set_Texture(background_texture)
			--this.RadarBackground.Set_Render_Mode(0) --ALPRIM_OPAQUE
			--Scene.Register_Event_Handler("Radar_Map_Show_Terrain", nil, Radar_Map_Show_Terrain)
			--Scene.Register_Event_Handler("Radar_Map_Hide_Terrain", nil, Radar_Map_Hide_Terrain)
		--end
		--
		--Radar_Map_Hide_Terrain()
	--end
	
	if this.RadarBackground then
		this.RadarBackground.Set_Hidden(true)
	end
	
	if this.RadarOverlay then
		this.RadarOverlay.Set_Hidden(true)
	end
	
	Update_Radar_Map_Bounds()
	
	-- Maria 04.13.2007 - CLICK/SELL functionality
	SellModeOn = false
	if TestValid(this.SellModeButton) then
		SellButton = this.SellModeButton
		SellButton.Set_Hidden(false)
		
		if Is_Player_Of_Faction(LocalPlayer, "Alien") then
			SellButton.Set_Texture("i_icon_sell_alien.tga")
		elseif Is_Player_Of_Faction(LocalPlayer, "Masari") then
			SellButton.Set_Texture("i_icon_sell_masari.tga")
		end
		
		this.Register_Event_Handler("Selectable_Icon_Clicked", SellButton, On_Toggle_Sell_Mode)
		-- Tab order: Sell button, hero buttons, queue buttons, faction specific button, superweapon buttons, special ability groups
		SellButton.Set_Tab_Order(TAB_ORDER_SELL_BUTTON)
		
		-- tooltip data
		SellButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_SELL_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_TOGGLE_SELL_MODE", 1)}})
	end
	

	this.Register_Event_Handler("End_Sell_Mode", nil, On_End_Sell_Mode)
	
	if TestValid(this.Research_Tree) then 
		this.Research_Tree.Set_Hidden(true)
		this.Research_Tree.Set_Tab_Order(TAB_ORDER_RESEARCH_TREE)
	end
	
	--Subtitling support
	this.Register_Event_Handler("Speech_Event_Begin", nil, Subtitles_On_Speech_Event_Begin)
	this.Register_Event_Handler("Speech_Event_Done", nil, Subtitles_On_Speech_Event_Done)
	
	--Show/hide sell button from script
	this.Register_Event_Handler("UI_Show_Sell_Button", nil, UI_Show_Sell_Button)
	this.Register_Event_Handler("UI_Hide_Sell_Button", nil, UI_Hide_Sell_Button)
	
	this.Register_Event_Handler("UI_Start_Flash_Superweapon", nil, UI_Start_Flash_Superweapon)
	this.Register_Event_Handler("UI_Stop_Flash_Superweapon", nil, UI_Stop_Flash_Superweapon)	
	
	-- DEFCON Multiplayer Mode Support
	this.Register_Event_Handler("DEFCON_Set_Enabled", nil, DEFCON_Set_Enabled)
	this.Register_Event_Handler("DEFCON_Set_Model", nil, DEFCON_Set_Model)
	
	--Scroll visualization support
	this.Register_Event_Handler("Begin_Mouse_Button_Scroll", nil, On_Begin_Mouse_Button_Scroll)
	this.Register_Event_Handler("End_Mouse_Button_Scroll", nil, On_End_Mouse_Button_Scroll)
	
	if TestValid(this.CommandBar.BuilderButton) then
		BuilderButton = this.CommandBar.BuilderButton
		BuilderButton.Set_Hidden(true)
		this.Register_Event_Handler("Selectable_Icon_Clicked", BuilderButton, On_Builder_Button_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Double_Clicked", BuilderButton, On_Builder_Button_Double_Clicked)
		
		-- Set the tab order so that we can come to this button while navigating the UI!
		BuilderButton.Set_Tab_Order(TAB_ORDER_QUEUE_BUTTONS)
		Init_Idle_Builder_Textures()
		
		-- tooltip data
		BuilderButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_IDLE_BUILDER_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_FIND_BUILDER", 1)}})
		
		-- Set the proper texture for this button!.
		BuilderButton.Set_Texture(PlayerToIdleBuilderTexturesMap[LocalPlayer.Get_Faction_Name()])
	end	
	
	
	if TestValid(this.CommandBar.ControlGroups) then
		Init_Control_Group_Textures_Prefix_Map()
		-- if the control group was initially attacked but there has not been an attack update 
		-- in the last CONTROL_GROUP_ATTACKED_FLASH_DELAY seconds, stop the 
		-- flashing of the button!.
		CONTROL_GROUP_ATTACKED_FLASH_DELAY = 5.0
		CtrlGroupButtons = {}
		CtrlGroupButtons = Find_GUI_Components(this.CommandBar.ControlGroups, "CtrlGp_")
		
		local faction = LocalPlayer.Get_Faction_Name()
		for index = 1, #CtrlGroupButtons do
			
			local button = CtrlGroupButtons[index]
			
			if TestValid(button) then 
				-- We'll use the index value to access the proper control group!.
				button.Set_User_Data(index)
				button.Set_Hidden(true)
				button.Set_Tab_Order(TAB_ORDER_CONTROL_GROUP_BUTTONS + index)	
				local texture_name
				local tooltip_text 
				local game_command_txt
				if index < 10 then 
					texture_name = FactionToCtrlGpTexturePrefix[faction].."0"..index..".tga"
					tooltip_text = "TEXT_GROUP_"..index.."_SELECT"
					game_command_txt = "COMMAND_GROUP_"..index.."_SELECT"
				else
					texture_name = FactionToCtrlGpTexturePrefix[faction]..index..".tga"
					tooltip_text = "TEXT_GROUP_0_SELECT"
					game_command_txt = "COMMAND_GROUP_0_SELECT"
				end
				button.Set_Tooltip_Data({'ui', {tooltip_text, Get_Game_Command_Mapped_Key_Text(game_command_txt, 1)}})
				button.Set_Texture(texture_name)
				this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Control_Group_Button_Clicked)
				this.Register_Event_Handler("Selectable_Icon_Double_Clicked", button, On_Control_Group_Button_Double_Clicked)
			end			
		end	
		
		CGButtonIdxToLastAttackTime = {}
		this.Register_Event_Handler("Update_Control_Group_UI", nil, On_Update_Control_Group_UI)
		this.Register_Event_Handler("Control_Group_Unit_Under_Attack", nil, On_Control_Group_Unit_Under_Attack)
		
		-- Update the UI just in case we are loading a saved game.
		On_Init_Update_Control_Groups_UI()

	end
	
	-- Maria 07.09.2007
	-- We will be using this to toggle the visibility and focus of the special ability/production GUIs when a controller is detected as well as to 
	-- hide/display the radar map zoom button (since this one should be hidden when no controllers are connected)
	AreAnyControllersConnected = Are_Any_Controllers_Connected()
	if TestValid(this.RadarZoomButton) then
		this.RadarZoomButton.Set_Hidden(true)
	end
	
	-- Maria 07.09.2007
	-- this can only be used if there are controllers connected!!!!!!.
	-- By default we always hide the selection UI
	Controller_Display_Selection_UI(not AreAnyControllersConnected)
	
	this.Register_Event_Handler("Controller_Display_Selection_UI", nil, On_Controller_Display_Selection_UI)
	
	if TestValid(this.BattleCam) then
		Init_Battle_Cam_Button()
	end
	
	this.Focus_First()
	
	this.Register_Event_Handler("Key_Mappings_Data_Changed", nil, On_Key_Mappings_Data_Changed)
	
	-- EMP 7/6/07
 	-- Set up text pre-rendering 
 	Scene.MaterialsText.Set_PreRender(true)
 	Scene.PopText.Set_PreRender(true)

	-- Maria 07.19.2007: The Hierarchy needs to keep track of the walker pop cap (which is independent from the regular units pop cap)
	if TestValid(this.WalkerPopText) then
 		this.WalkerPopText.Set_Hidden(not DisplayCreditsPop)
	end

	-- This is for designer's use!
	this.Register_Event_Handler("UI_Set_Display_Credits_Pop", nil,UI_Set_Display_Credits_Pop)
	
	-- We want to display tooltips for the raw materials and pop cap display
	-- --------------------------------------------------------------------------------------------------------
	-- Raw materials display
	this.Register_Event_Handler("Mouse_On", this.RMQuad, On_Mouse_Over_Credits_Pop_Cap_Display)
	this.Register_Event_Handler("Mouse_Off", this.RMQuad,On_Mouse_Off_Credits_Pop_Cap_Display)
	this.RMQuad.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_RAW_MATERIALS_DISPLAY", false, "TEXT_UI_TACTICAL_RAW_MATERIALS_DISPLAY_DESCRIPTION", true}})
	
	-- Pop Cap display
	this.Register_Event_Handler("Mouse_On", this.PopCapQuad, On_Mouse_Over_Credits_Pop_Cap_Display)
	this.Register_Event_Handler("Mouse_Off", this.PopCapQuad,On_Mouse_Off_Credits_Pop_Cap_Display)
	this.PopCapQuad.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_POP_CAP_DISPLAY", false, "TEXT_UI_TACTICAL_POP_CAP_DISPLAY_DESCRIPTION", true}})
	
	if TestValid(this.WalkerPopQuad) then
		this.Register_Event_Handler("Mouse_On", this.WalkerPopQuad, On_Mouse_Over_Credits_Pop_Cap_Display)
		this.Register_Event_Handler("Mouse_Off", this.WalkerPopQuad,On_Mouse_Off_Credits_Pop_Cap_Display)
		this.WalkerPopQuad.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_WALKER_POP_CAP_DISPLAY", false, "TEXT_UI_TACTICAL_WALKER_POP_CAP_DISPLAY_DESCRIPTION", true}})	
	end
	
	CreditsPopCapDisplayMouseOverStartTime = nil
	CreditsPopCapDisplayMouseOverComponent = nil
	-- --------------------------------------------------------------------------------------------------------
	
	-- Called when a masari light sw is created
	Scene.Register_Event_Handler("Network_Select_Super_Weapon", nil, Select_Super_Weapon)

end

-- ------------------------------------------------------------------------------------------------------------------
-- Select_Super_Weapon
-- ------------------------------------------------------------------------------------------------------------------
function Select_Super_Weapon(event,source,weapon_object)
	if TestValid(weapon_object) and Player == weapon_object.Get_Owner() then
		Set_Selected_Objects({weapon_object})
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
	Tooltip.Set_Pip_Movie_Playing(on_off)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over_Credits_Pop_Cap_Display
-- ------------------------------------------------------------------------------------------------------------------
function On_Mouse_Over_Credits_Pop_Cap_Display(_, source)
	if source.Get_Tooltip_Data() then
		CreditsPopCapDisplayMouseOverComponent = source
		CreditsPopCapDisplayMouseOverStartTime = GetCurrentTime()
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_Credits_Pop_Cap_Display
-- ------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off_Credits_Pop_Cap_Display(_, _)
	CreditsPopCapDisplayMouseOverStartTime = nil
	CreditsPopCapDisplayMouseOverComponent = nil
	End_Tooltip()
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Set_Display_Credits_Pop
-- ------------------------------------------------------------------------------------------------------------------
function UI_Set_Display_Credits_Pop(_, _, on_off)
	DisplayCreditsPop = on_off
	Scene.PopIcon.Set_Hidden(not DisplayCreditsPop)
	Scene.PopText.Set_Hidden(not DisplayCreditsPop)
	Scene.MaterialsText.Set_Hidden(not DisplayCreditsPop)
	Scene.RMIcon.Set_Hidden(not DisplayCreditsPop)
	if TestValid(this.WalkerPopText) then
		this.WalkerPopText.Set_Hidden(not DisplayCreditsPop)
	end
	
	if on_off then
		--Force an immediate update of the display
		LastRawMaterials = nil
		LastUsedPopCap = nil
		Update_Credits_Display()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Key_Mappings_Data_Changed
-- ------------------------------------------------------------------------------------------------------------------
function Compute_SA_Buttons_Gap()
	if TestValid(this.CommandBar.SpecialAbilityButtons.SAButtonGapMarker) then
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = this.CommandBar.SpecialAbilityButtons.SAButtonGapMarker.Get_Bounds()
		SA_BUTTONS_GAP = bds.w
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Key_Mappings_Data_Changed
-- ------------------------------------------------------------------------------------------------------------------
function On_Key_Mappings_Data_Changed()
	Update_Key_Mappings_Data(false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Key_Mappings_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Key_Mappings_Data(switching_sides)

	Init_Abilities_Key_Mappings()
	Init_SW_Type_Name_To_Game_Command_Map()
	
	if not switching_sides then 
		Update_Hero_Icons_Tooltip_Data()
	else
		-- if we do it here it won't get done properly for this call (that of debug switch sides) is made before the hero icons
		-- are re-created and therefore the data is not processed on time.  Thus, we will flag it so that it is done in the next
		-- service call!.
		UpdateHeroTooltips = true
	end
	
	Update_Queues_Tooltip_Data()
	for index, button in pairs(QueueButtons) do 
		button.Set_Tooltip_Data({'ui', QueueTypeToTooltipDataMap[QueueTypes[index]]})
	end

	if TestValid(SellButton) then
		SellButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_SELL_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_TOGGLE_SELL_MODE", 1)}})
	end
	
	if TestValid(BuilderButton) then
		BuilderButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_IDLE_BUILDER_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_FIND_BUILDER", 1)}})
	end	
	
	if TestValid(this.CommandBar.ControlGroups) then
		for index = 1, #CtrlGroupButtons do
			local button = CtrlGroupButtons[index]
			if TestValid(button) then 
				local tooltip_text
				local game_command_txt
				if index < 10 then 
					tooltip_text = "TEXT_GROUP_"..index.."_SELECT"
					game_command_txt = "COMMAND_GROUP_"..index.."_SELECT"
				else
					tooltip_text = "TEXT_GROUP_0_SELECT"
					game_command_txt = "COMMAND_GROUP_0_SELECT"
				end
				button.Set_Tooltip_Data({'ui', {tooltip_text, Get_Game_Command_Mapped_Key_Text(game_command_txt, 1)}})
			end			
		end			
	end

	if TestValid(this.BattleCam) then
		this.BattleCam.Set_Tooltip_Data({'ui', {"TEXT_BATTLE_CAM_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_BATTLE_CAM", 1)}})
	end
	
	Update_Special_Ability_Text()
	
	if Update_Faction_Specific_Tooltip_Data then
		Update_Faction_Specific_Tooltip_Data()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Minor_Announcement_Text
-- ------------------------------------------------------------------------------------------------------------------
function Init_Minor_Announcement_Text()
	
	this.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(false)
	this.MinorAnnouncement.MinorAnnouncementText.Set_Text("")
	
	-- USE THESE VALUES TO TUNE HOW LONG THE CHANGE OF COLOR TAKES
	-- AND WHAT THE FLASHY AND DEFAULT COLORS SHOULD BE!!!!!
	-- -------------------------------------------------------------------------------------
	MINOR_ANNOUNCEMENT_TEXT_FLASH_INTRO = 1.0 
	MINOR_ANNOUNCEMENT_TEXT_FLASH_DELAY = 4.0 
	MINOR_ANNOUNCEMENT_TEXT_FLASH_OUTRO = 1.0 
	START_TINT = {r = 0, g = 0, b = 0, a = 0}	-- BLACK!
	MID_TINT = {r = 1, g = 1, b = 0, a = 1} -- Yellow!
	END_TINT = {r = 0, g = 0, b = 0, a = 0}	-- BLACK!
	-- -------------------------------------------------------------------------------------
	
	DELTA_TINT_START = 
			{	
				r = MID_TINT.r - START_TINT.r, 
				g = MID_TINT.g - START_TINT.g, 
				b = MID_TINT.b - START_TINT.b,
				a = MID_TINT.a - START_TINT.a
			}

	DELTA_TINT_END = 
			{	
				r = END_TINT.r - MID_TINT.r, 
				g = END_TINT.g - MID_TINT.g, 
				b = END_TINT.b - MID_TINT.b,
				a = END_TINT.a - MID_TINT.a
			}
			
	MinorAnnouncementTextFadeStartTime= nil
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Debug_Switch_Sides
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Debug_Switch_Sides()
	Close_All_Displays()
	Update_Key_Mappings_Data(true)
	End_Tooltip()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Minor_Announcement_Text_Fade
-- ------------------------------------------------------------------------------------------------------------------
function Update_Minor_Announcement_Text_Fade()
	if not MinorAnnouncementTextFadeStartTime then
		return
	end
	
	local curr_time = GetCurrentTime()
	if (MinorAnnouncementTextFadeStartTime + MINOR_ANNOUNCEMENT_TEXT_FLASH_INTRO) > curr_time then
		local time_elapsed = (curr_time - MinorAnnouncementTextFadeStartTime)/MINOR_ANNOUNCEMENT_TEXT_FLASH_INTRO
		local new_rgb = 
				{
					r = START_TINT.r + (DELTA_TINT_START.r*time_elapsed), 
					g = START_TINT.g + (DELTA_TINT_START.g*time_elapsed),
					b = START_TINT.b + (DELTA_TINT_START.b*time_elapsed),
					a = START_TINT.a + (DELTA_TINT_START.a*time_elapsed)
				}
		-- keep 'disolving' the tint.				
		this.MinorAnnouncement.MinorAnnouncementText.Set_Tint(new_rgb.r, new_rgb.g, new_rgb.b, new_rgb.a)
	elseif (MinorAnnouncementTextFadeStartTime + MINOR_ANNOUNCEMENT_TEXT_FLASH_INTRO + MINOR_ANNOUNCEMENT_TEXT_FLASH_DELAY) > curr_time then
		local new_rgb = 
				{
					r = MID_TINT.r, 
					g = MID_TINT.g,
					b = MID_TINT.b,
					a = MID_TINT.a
				}
		-- keep 'disolving' the tint.				
		this.MinorAnnouncement.MinorAnnouncementText.Set_Tint(new_rgb.r, new_rgb.g, new_rgb.b, new_rgb.a)
	elseif (MinorAnnouncementTextFadeStartTime + MINOR_ANNOUNCEMENT_TEXT_FLASH_INTRO + MINOR_ANNOUNCEMENT_TEXT_FLASH_DELAY + MINOR_ANNOUNCEMENT_TEXT_FLASH_OUTRO) > curr_time then
		local time_elapsed = (curr_time - (MinorAnnouncementTextFadeStartTime + MINOR_ANNOUNCEMENT_TEXT_FLASH_INTRO + MINOR_ANNOUNCEMENT_TEXT_FLASH_DELAY))/(MINOR_ANNOUNCEMENT_TEXT_FLASH_OUTRO)
		local new_rgb = 
				{
					r = MID_TINT.r + (DELTA_TINT_END.r*time_elapsed), 
					g = MID_TINT.g + (DELTA_TINT_END.g*time_elapsed),
					b = MID_TINT.b + (DELTA_TINT_END.b*time_elapsed),
					a = MID_TINT.a + (DELTA_TINT_END.a*time_elapsed)
				}
		-- keep 'disolving' the tint.				
		this.MinorAnnouncement.MinorAnnouncementText.Set_Tint(new_rgb.r, new_rgb.g, new_rgb.b, new_rgb.a)
	else
		-- we are done!.
		this.MinorAnnouncement.MinorAnnouncementText.Set_Tint(END_TINT.r, END_TINT.g, END_TINT.b, END_TINT.a)
		MinorAnnouncementTextFadeStartTime = nil
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Selection_UI(event, source, on_off)
	if not AreAnyControllersConnected then
		if not ControllerDisplayingSelectionUI then 
			-- make sure everything is back up!.
			Controller_Display_Selection_UI(true)
		end		
		return
	end	
	Controller_Display_Selection_UI(on_off)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Selection_UI(on_off)
	if ControllerToggleUIDisplay == on_off then return end
	
	local hide = not on_off
	QueueManager.Set_Hidden(hide)
	this.CommandBar.SpecialAbilityButtons.Set_Hidden(hide)
	
	local update_local_focus = true
	if Controller_Display_Specific_UI then
		update_local_focus = Controller_Display_Specific_UI(on_off)
	end
	
	if TestValid(this.CommandBar.BuildButtons) then
		this.CommandBar.BuildButtons.Set_Hidden(hide)
	end
	
	if not hide then 
		if QueueManager.Is_Open() then
			QueueManager.Update_Display_Focus()
		elseif update_local_focus then
			this.Focus_First()
		end
	end
	
	ControllerDisplayingSelectionUI = on_off
end

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Battle_Cam_Button
-- ------------------------------------------------------------------------------------------------------------------
function Init_Battle_Cam_Button()
	Init_Battle_Cam_Textures()
	this.BattleCam.Set_Texture(FactionToBattleCamTextureMap[Find_Player("local").Get_Faction_Name()])
	this.BattleCam.Set_Tooltip_Data({'ui', {"TEXT_BATTLE_CAM_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_BATTLE_CAM", 1)}})
	this.BattleCam.Set_Tab_Order(TAB_ORDER_BATTLE_CAM_BUTTON)
	this.Register_Event_Handler("Mouse_Left_Down", this.BattleCam, On_Handle_BattleCam_Button_Down)
	this.Register_Event_Handler("Mouse_Left_Up", this.BattleCam, On_Handle_BattleCam_Button_Up)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Battle_Cam_Textures
-- ------------------------------------------------------------------------------------------------------------------
function Init_Battle_Cam_Textures()
	FactionToBattleCamTextureMap = {}
	FactionToBattleCamTextureMap["ALIEN"] = "i_button_battlecam_alien.tga"
	FactionToBattleCamTextureMap["NOVUS"] = "i_button_battlecam_novus.tga"
	FactionToBattleCamTextureMap["MASARI"] = "i_button_battlecam_masari.tga"
	FactionToBattleCamTextureMap["MILITARY"] = "i_button_battlecam_military.tga"
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Handle_BattleCam_Button_Down
-- ------------------------------------------------------------------------------------------------------------------
function On_Handle_BattleCam_Button_Down(event, source)
	Process_Battle_Cam_Command(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Handle_BattleCam_Button_Up
-- ------------------------------------------------------------------------------------------------------------------
function On_Handle_BattleCam_Button_Up(event, source)
	Process_Battle_Cam_Command(false)
end

-- ******** CONTROL GROUPS UI MANAGEMENT - BEGIN ******** --

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Control_Group_Texture_Prefix
-- ------------------------------------------------------------------------------------------------------------------
function Init_Control_Group_Textures_Prefix_Map()
	FactionToCtrlGpTexturePrefix = {}
	FactionToCtrlGpTexturePrefix["ALIEN"] = "i_icon_a_ctrl_"
	FactionToCtrlGpTexturePrefix["NOVUS"] = "i_icon_n_ctrl_"
	FactionToCtrlGpTexturePrefix["MASARI"] = "i_icon_m_ctrl_"
	FactionToCtrlGpTexturePrefix["MILITARY"] = "i_icon_m_ctrl_"
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init_Update_Control_Groups_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Init_Update_Control_Groups_UI()
	local player = Find_Player("local")
	if player then 
		local used_cgs = player.Get_Control_Group_Assignments()
		if used_cgs then
			for _, cg_idx in pairs(used_cgs) do
				Update_Control_Group_Display(cg_idx, false)
			end
		end		
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Unit_Under_Attack
-- ------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Unit_Under_Attack(event, source, index)
	if not TestValid(this.CommandBar.ControlGroups) then return end
	if index < 1 or index > #CtrlGroupButtons then
		local mssg = "On_Control_Group_Unit_Under_Attack: We got an invalid control group.  Index =  "..index
		MessageBox(mssg)
		return
	end
	
	local button = CtrlGroupButtons[index]
	if not button.Is_Flashing() then 
		button.Start_Flash()	
	end	
	CGButtonIdxToLastAttackTime[index] = GetCurrentTime()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Control_Group_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Update_Control_Group_Buttons(cur_time)
	if not TestValid(this.CommandBar.ControlGroups) then return end	
	for index = 1, #CtrlGroupButtons do
		local last_attack_time = CGButtonIdxToLastAttackTime[index] 
		if last_attack_time then
			if cur_time - last_attack_time >= CONTROL_GROUP_ATTACKED_FLASH_DELAY then
				local button = CtrlGroupButtons[index]
				button.Stop_Flash()
				CGButtonIdxToLastAttackTime[index] = nil
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Control_Group_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Control_Group_UI(event, source, index, hide_display)
	Update_Control_Group_Display(index, hide_display)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Control_Group_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Control_Group_Display(index, hide_display)
	
	if not TestValid(this.CommandBar.ControlGroups) then return end
	
	if index < 1 or index > #CtrlGroupButtons then
		local mssg = "On_Update_Control_Group_UI: We got an invalid control group.  Index =  "..index
		MessageBox(mssg)
		return
	end
	CtrlGroupButtons[index].Set_Hidden(hide_display)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Button_Clicked(event, source)
	-- We don't need to send a network event here because the code queues an event for it!.
	local ctrl_gp_index = source.Get_User_Data()
	if ctrl_gp_index == 10 then 
		ctrl_gp_index = 0
	end
	
	Control_Group.Select(ctrl_gp_index)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Button_Double_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Button_Double_Clicked(event, source)
	-- We don't need to send a network event here because the code queues an event for it!.
	local ctrl_gp_index = source.Get_User_Data()
	if ctrl_gp_index == 10 then 
		ctrl_gp_index = 0
	end
	
	Control_Group.Point_Camera_At(ctrl_gp_index)
end


-- ******** CONTROL GROUPS UI MANAGEMENT - END ******** --

-- ------------------------------------------------------------------------------------------------------------------
-- On_Builder_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Builder_Button_Clicked(event, source)
	Select_Next_Builder()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Select_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Select_Next_Builder()
	-- this check is needed since we may be trying to select a builder via a hot key!
	if not TestValid(BuilderButton) or BuilderButton.Get_Hidden() == true then 
		-- no builders to select!
		return
	end
	
	Send_GUI_Network_Event("Networked_Select_Next_Builder", { Find_Player("local"), Get_Cursor_World_Position(), Is_Shift_Key_Down() })	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Select_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Select_Next_Builder(event, source, player, position, shift_key)
	if player then
		local script = player.Get_Script()
		if script then
			-- If the click comes with the SHIFT key down, then select ALL idle builders
			local builders = script.Call_Function("Select_Next_Idle_Builder", position, shift_key)
			if player == Find_Player("local") then
				if builders and #builders then
					Set_Selected_Objects(builders)
					
					-- Make sure we reset the BuildMode flag so that we can successfully open the 
					-- builder's menu!
					BuildModeOn = false
				end
			end
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Builder_Button_Double_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Builder_Button_Double_Clicked(event, source)
	Point_Camera_At_Next_Builder()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Point_Camera_At_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Point_Camera_At_Next_Builder()
	-- this check is needed since we may be trying to select a builder via a hot key!
	if not TestValid(BuilderButton) or BuilderButton.Get_Hidden() == true then 
		-- no builders to select!
		return
	end
	
	-- Maria 09.07.07 (fix prompted by bug #954 (SEGA DB): Double-tapping the Find Idle Builder command or its hotkey does 
	-- not consistently center on the selected unit).
	-- FIX: We need to make this a networked event to make sure it gets executed after the single click originated by the double
	-- click (which is also networked).  Otherwise, the double click will pick the wrong selected builder since the single 
	-- click has not been processed yet (this discrepancy is more easily experience in MP games).
	Send_GUI_Network_Event("Networked_Point_Camera_At_Next_Builder", { Find_Player("local")})	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Point_Camera_At_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Point_Camera_At_Next_Builder(event, source, player)
	if not player or player ~= Find_Player("local") then
		return
	end
	
	-- With a double click, the single click gets processed first which means that the next idle builder will already had been selected
	-- by the time we get here.  Hence, just have the camera point at him.
	local script = player.Get_Script()
	if script then
		local builder = script.Get_Async_Data("SelectedBuilder")
		if TestValid(builder) then
			Point_Camera_At(builder)
		end
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 04.10.2006
-- Clicking the Scientist Button toggles the display of the Tech Tree from which the player can see and determine what his research options are
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Scientist_Button_Clicked()
	Toggle_Research_Tree_Display()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Open_Research_Tree
-- ------------------------------------------------------------------------------------------------------------------
function Open_Research_Tree()
	if not this.Research_Tree then return end
	
	-- We have made the research tree modal so that we can navigate it with the controller (or keyboard) without having an
	-- issue with the tab orders throught the rest of the tactical command bar.
	this.Research_Tree.Set_Hidden(false)
	
	if On_Research_Tree_Open then
		On_Research_Tree_Open()
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Can_Toggle_Research_Tree_Display
-- ------------------------------------------------------------------------------------------------------------------
function Can_Toggle_Research_Tree_Display()

	if not TestValid(this.Research_Tree) or not CommandBarEnabled then 
		return false
	end
	
	-- Do we have a research scientist?
	local research_button = HeroIconTable[1]
	if TestValid(research_button) and not research_button.Get_Hidden() then
		return true
	else
		return false
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Research_Tree_Display
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Research_Tree_Display()
	
	-- if the research tree button is hidden, then we cannot toggle the RT display.
	if not Can_Toggle_Research_Tree_Display() then
		return 
	end
	
	End_Sell_Mode()
	
	local tree_was_open = this.Research_Tree.Is_Open()
	if tree_was_open == false then
		-- The queue manager may be open so we close it down!
		local queue_closed = QueueManager.Close()
		if queue_closed then 
			-- reset the index used to visit the buildings in this queue via hotkey.
			QueueTypeToLastQueueIndex[queue_closed] = 0
		end	
	
		-- Let's hide the (other player's) SW data
		if TestValid(this.EnemySWTimers) then 
			this.EnemySWTimers.Set_Hidden(true)
		end
		
		if TestValid(ReinforcementsMenuManager) then
			ReinforcementsMenuManager.Close()
			ReinforcementsMenuManager.Set_Hidden(true)
		end
		
		-- Go ahead and open the tree
		Open_Research_Tree()			
	else
		this.Research_Tree.Set_Hidden(true)
		
		-- Let's un-hide the (other player's) SW data
		if TestValid(this.EnemySWTimers) then 
			this.EnemySWTimers.Set_Hidden(false)
		end
		
		-- update the mode
		if BuilderMenuOpen == true then 
			Mode = MODE_CONSTRUCTION
		end
		
		if TestValid(ReinforcementsMenuManager) then
			if ReinforcementsMenuManager.Conditional_Show() then
				--Do the unhide at this level so the animation is updated correctly
				ReinforcementsMenuManager.Set_Hidden(false)
			end
		end		
	end

	-- this is the flag we use to determine which menus to close so that menus don't overlap!.	
	BuildModeOn = (not tree_was_open)
	
	if Mode == MODE_CONSTRUCTION and CurrentSelectionNumTypes == 1 and #CurrentConstructorsList > 0 then 
		-- if there's only constructor(s) selected, we want to be able to go back to its build menu is no other selection order is issued.
		-- If more than one constructor and we go back with no new selection, then we will go back to the ability buttons.
		Setup_Mode_Construction()	
	else -- if there's more than one constructor or no constructor selected, then just update the selection mode dislpay.
		Mode = MODE_SELECTION
		Setup_Mode_Selection()
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Research_Tree
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Research_Tree()
	if not TestValid(this.Research_Tree) then return end
	if this.Research_Tree.Is_Open() == true then 
		this.Research_Tree.Set_Hidden(true)
		
		-- Let's put the (other player's) SW data back! (if applicable)
		if TestValid(this.EnemySWTimers) then 
			this.EnemySWTimers.Set_Hidden(false)
		end		
		
		if TestValid(ReinforcementsMenuManager) then
			if ReinforcementsMenuManager.Conditional_Show() then
				--Do the unhide at this level so the animation is updated correctly
				ReinforcementsMenuManager.Set_Hidden(false)
			end
		end			
	end
	
	BuildModeOn = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_End_Sell_Mode 
-- ------------------------------------------------------------------------------------------------------------------
function On_End_Sell_Mode(event, source)
	End_Sell_Mode()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Toggle_Sell_Mode 
-- ------------------------------------------------------------------------------------------------------------------
function On_Toggle_Sell_Mode(event, source)
	Toggle_Sell_Mode_State()		
end

-- ------------------------------------------------------------------------------------------------------------------
-- End_Sell_Mode 
-- ------------------------------------------------------------------------------------------------------------------
function End_Sell_Mode()
	if SellModeOn == true then 
		Toggle_Sell_Mode_State()		
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Sell_Mode_State 
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Sell_Mode_State()
	if not Are_Any_Controllers_Connected() then
		-- Make sure we have a valid Sell Button and it is not hidden!.
		-- NOTE: this call may be made from the Keyboard Mappings Handler since Toggling the Sell mode can 
		-- be linked to a hotkey!.
		if TestValid(SellButton) and not SellButton.Get_Hidden() then 
			SellModeOn = Toggle_Sell_Mode()
			SellButton.Set_Selected(SellModeOn)
			Raise_Event_Immediate_All_Scenes("Refresh_Sell_Mode", {SellModeOn})
		
			if SellModeOn == true then
				-- Close all other menus, end any other modes!.
				Close_All_Displays()	
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Show_Terrain 
--  - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function Radar_Map_Show_Terrain() 
	--if this.RadarBackground then
		--this.RadarBackground.Set_Hidden(false)
	--end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Hide_Terrain 
--  - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function Radar_Map_Hide_Terrain() 
	--if this.RadarBackground then
		--this.RadarBackground.Set_Hidden(true)
	--end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Show_Radar_Map
--  - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function Show_Radar_Map() 
	
	if TestValid(this.RadarBackground) then
		this.RadarBackground.Set_Hidden(true)
	end
	
	--Hide overlay - not currently used (Oksana)
	if TestValid(this.RadarOverlay) then
		this.RadarOverlay.Set_Hidden(true)
	end
	
	if TestValid(this.RadarTray) then
		this.RadarTray.Set_Hidden(false)
	end
	
	if TestValid(this.RadarMap) then
		this.RadarMap.Set_Hidden(false)
	end
	
	if TestValid(this.RadarZoomButton) then
		if AreAnyControllersConnected then
			this.RadarZoomButton.Set_Hidden(false)			
		end
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Radar_Map 
--  - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Radar_Map() 

	if TestValid(this.RadarBackground) then
		this.RadarBackground.Set_Hidden(true)
	end
	
	if TestValid(this.RadarOverlay) then
		this.RadarOverlay.Set_Hidden(true)
	end
	
	if TestValid(this.RadarTray) then
		this.RadarTray.Set_Hidden(true)
	end
	
	if TestValid(this.RadarMap) then
		this.RadarMap.Set_Hidden(true)
	end
	
	if TestValid(this.RadarZoomButton) then
		this.RadarZoomButton.Set_Hidden(true)
	end
end





-- ------------------------------------------------------------------------------------------------------------------
-- Update_Radar_Map_Bounds - Snaps the Radar Map quads to actual Radar Map size 
--  - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function Update_Radar_Map_Bounds()
	
	if not TestValid(this.RadarMap) then 
		return 
	end
	
	--Get the actual quad bounds. 
	local CurrentX, 
		CurrentY, 
		CurrentWidth, 
		CurrentHeight = this.RadarMap.Get_World_Bounds()


	-- What is our anchor point? Assume lower right right now (Novus).
	local AnchorX = CurrentX + CurrentWidth 
	local AnchorY = CurrentY + CurrentHeight -- Note that screen coords grow downwards (upside down)	

	--Computes actual map size
	local MapWidth, MapHeight = RadarMap.Get_Map_Extents()
	local ActualWidth = CurrentWidth
	local ActualHeight = CurrentHeight

	local allocated_height_to_width = CurrentHeight / CurrentWidth
	local actual_height_to_width = MapHeight / MapWidth
	
	if (allocated_height_to_width > actual_height_to_width) then
		-- We are good, we can fit this map into allocated quad without changing the width
		-- Just re-calculate new screen height (preserving height to width ratio)
		ActualHeight = actual_height_to_width * ActualWidth
	else
		ActualWidth = ActualHeight / actual_height_to_width
	end
	
	-- We have anchor point, compute new center based on anchor and actual height/width
	-- This will change depending where our anchor point is
	local ActualX = AnchorX - ActualWidth  
	local ActualY = AnchorY - ActualHeight 

	-- Update main quad
	this.RadarMap.Set_World_Bounds(ActualX, ActualY, ActualWidth, ActualHeight)


	---- Do we have a background quad? Must match in size to RadarMap
	--if this.RadarBackground then
		--this.RadarBackground.Set_World_Bounds(ActualX, ActualY, ActualWidth, ActualHeight)
	--end
	
	-- Do we have an overlay? Must match in size to RadarMap
	--if this.RadarOverlay then
		--this.RadarOverlay.Set_World_Bounds(ActualX, ActualY, ActualWidth, ActualHeight)
	--end


	-- Do we have the tray?
	if TestValid(this.RadarTray) then
		-- Update Tray quad. Note that the difference does not scale, as we don't want to scale the boundary textures.
		-- Compute Tray bounds and padding
		local  TrayX, 
			TrayY, 
			TrayWidth, 
			TrayHeight = this.RadarTray.Get_World_Bounds()
		
		local TrayWidthDiff   = TrayWidth  - CurrentWidth
		local TrayHeightDiff  = TrayHeight - CurrentHeight

		AnchorX = TrayX + TrayWidth 
		AnchorY = TrayY + TrayHeight -- Note that screen coords grow downwards (upside down)	

		ActualX = AnchorX - ActualWidth  - TrayWidthDiff
		ActualY = AnchorY - ActualHeight - TrayHeightDiff

		this.RadarTray.Set_World_Bounds(ActualX, ActualY, ActualWidth+TrayWidthDiff, ActualHeight+TrayHeightDiff)
	
	end
		
	-- Now that the radar map has been resized, go ahead and create the map's open animation.
	Create_Radar_Map_Animation()
	
end




-- ------------------------------------------------------------------------------------------------------------------
-- Create_Radar_Map_Animation - Once the radar map has been resized to fit the current map, create
-- its open animation.
-- ------------------------------------------------------------------------------------------------------------------
function Create_Radar_Map_Animation()

	local x, y, w, h = this.RadarTray.Get_World_Bounds()
	
	local max_height = 1.0
	if TestValid(this.top_backdrop) then -- this is the top backdrop in which we display the credits, pop cap, etc.
		local tx, ty, tw, th = this.top_backdrop.Get_World_Bounds()
		max_height = max_height - th
	end
	
	local enlarge_factor_w = RADAR_MAP_ENLARGE_FACTOR -- default
	if enlarge_factor_w*w > max_height then -- we need to work on this so that the radar map doesn't go out of the screen
		enlarge_factor_w = max_height/w
	end
	
	local enlarge_factor_h = RADAR_MAP_ENLARGE_FACTOR -- default
	if enlarge_factor_h*h > max_height then
		enlarge_factor_h = max_height/h
	end
	
	-- make the enlarge factor the smaller of the two.
	local enlarge_factor = enlarge_factor_w
	if enlarge_factor_h < enlarge_factor_w then 
		enlarge_factor = enlarge_factor_h
	end	
	
	
	--Now actual radar quad - we MUST reserve the border sizes so there is no texture stretching
	local rX,rY,rW,rH = this.RadarMap.Get_World_Bounds()

	local TrayWidthDiff   = w  - rW
	local TrayHeightDiff  = h - rH

	local radar_enlarge_factor = (w*enlarge_factor - TrayWidthDiff)/rW


	open_anim = Create_Animation("Open")
	open_anim.Add_Key_Frame("Size", 0.0, { 1.0, 1.0 }) -- full size
	open_anim.Add_Key_Frame("Size", RADAR_MAP_ANIMATION_LENGTH, { radar_enlarge_factor, radar_enlarge_factor }) -- double the size
	-- reposition the map as it gets enlarged
	-- we only need to specify the "delta" to be considered when setting the new position.
	-- Note, for the radar map we also want to make sure that the lower-right corner stays put since it functions as the anchor point for the radar map scene.
	open_anim.Add_Key_Frame("Position", 0.0, { 0.0, 0.0 })
	open_anim.Add_Key_Frame("Position", RADAR_MAP_ANIMATION_LENGTH, { rW - (radar_enlarge_factor*rW), rH - (radar_enlarge_factor*rH) })

	---- Do we have a background quad? Must match in size to RadarMap
	--if this.RadarBackground then
		--this.RadarBackground.Add_Animation(open_anim)
	--end

	-- Do we have an overlay? Must match in size to RadarMap
	--if this.RadarOverlay then
		--this.RadarOverlay.Add_Animation(open_anim)
	--end
	
	if TestValid(this.RadarMap) then
		this.RadarMap.Add_Animation(open_anim)
	end
		
	
	-- Now the Tray - it must wrap around the radar map quads precisely.
	-- Note that width will fit because of the way we calculated radar_enlarge_factor above,
	-- so we will only need to adjust the heigh
	local enlarge_factor_h = (rH*radar_enlarge_factor+TrayHeightDiff) / h
	
	local open_anim = Create_Animation("Open")
	open_anim.Add_Key_Frame("Size", 0.0, { 1.0, 1.0 }) -- full size
	open_anim.Add_Key_Frame("Size", RADAR_MAP_ANIMATION_LENGTH, { enlarge_factor, enlarge_factor_h }) -- double the size
	-- reposition the map as it gets enlarged
	-- we only need to specify the "delta" to be considered when setting the new position.
	-- Note, for the radar map we also want to make sure that the lower-right corner stays put since it functions as the anchor point for the radar map scene.
	open_anim.Add_Key_Frame("Position", 0.0, { 0.0, 0.0 })
	open_anim.Add_Key_Frame("Position", RADAR_MAP_ANIMATION_LENGTH, { w - (enlarge_factor*w), h - (enlarge_factor_h*h) })
	
	this.RadarTray.Add_Animation(open_anim)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Unlock_Command_Bar - This event has been registered in the GUI Editor!
-- This is called when the Close animation finishes.
-- ------------------------------------------------------------------------------------------------------------------
function Unlock_Command_Bar(event, source)
	if IsRadarOpen == false then	
		-- Enable the tactical command bar
		CommandBarEnabled = true
		-- refresh the selection data just in case.
		Update_Mode()
	end
	IsRadarAnimating = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Radar_Zoom_Button_Clicked - This event has been registered in the GUI Editor!
-- ------------------------------------------------------------------------------------------------------------------
function On_Radar_Zoom_Button_Clicked(event, source)

	End_Sell_Mode()
	
	if IsRadarOpen == false then	
		-- Separating the toggle into 2 diff functions so that they can be accessed from code independently (MLL's request for 360 support)
		Radar_Map_Zoom_In()
	else
		Radar_Map_Zoom_Out()
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Zoom_In
-- ------------------------------------------------------------------------------------------------------------------------------------
function Radar_Map_Zoom_In()
	-- Let's make sure the radar map is zoomed out
	if IsRadarOpen then 
		return 
	end
	
	-- Shutdown any display in the tactical command bar.
	Close_All_Displays()
	-- Lock the Command Bar
	CommandBarEnabled = false
	-- refresh the selection data just in case.
	Update_Mode()
	-- Open the radar map
	this.RadarTray.Play_Animation("Open", false)	
	--this.RadarBackground.Play_Animation("Open", false)	
	--this.RadarOverlay.Play_Animation("Open", false)	
	this.RadarMap.Play_Animation("Open", false)	
	
	IsRadarOpen = true
	IsRadarAnimating = true
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Zoom_Out
-- ------------------------------------------------------------------------------------------------------------------------------------
function Radar_Map_Zoom_Out()
	-- Let's make sure that the map is zoomed in.
	if IsRadarOpen == false then 
		return 
	end
	-- Close the radar map
	this.RadarTray.Play_Animation_Backwards("Open", false)	
	--this.RadarBackground.Play_Animation_Backwards("Open", false)	
	--this.RadarOverlay.Play_Animation_Backwards("Open", false)	
	this.RadarMap.Play_Animation_Backwards("Open", false)	

	IsRadarOpen = false
	IsRadarAnimating = true
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

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Set_UI_Display_Tooltip_Resources
-- ------------------------------------------------------------------------------------------------------------------------------------
function Set_UI_Display_Tooltip_Resources(_, _, on_off)
	Tooltip.Set_Display_Tooltip_Resources(on_off)
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Display_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Display_Tooltip(event, source, tooltip_data)
	Display_Tooltip(tooltip_data)
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Display_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function Display_Tooltip(tooltip_data)
	if tooltip_data == nil then return end
	
	if Tooltip.Get_Hidden() then 
		Tooltip.Set_Hidden(false)
	end
	
	Tooltip.Display_Tooltip(tooltip_data)
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- End_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function End_Tooltip(event, source)
	-- Hide the tooltip
	Tooltip.End_Tooltip()
end



-- -----------------------------------------------------------------------------------------------------------------
-- On_Network_Sell_Structure
-- -----------------------------------------------------------------------------------------------------------------
function On_Network_Sell_Structure(event, source, building, player)
	if TestValid(building) then 
		local success = building.Sell()	
		if success == false then 	
			MessageBox("UGH?!")
		end
		
		Selection_Changed()
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Construction_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Construction_Mode()

	-- let's not do anything if the buider's menu is not totally up!.
	local is_tree_open = false	
	if TestValid(this.Research_Tree) then is_tree_open = this.Research_Tree.Is_Open() end
	local is_faction_specific_menu_open = false
	if Is_Faction_Specific_Menu_Open then is_faction_specific_menu_open = Is_Faction_Specific_Menu_Open() end
	
	if is_tree_open == true or is_faction_specific_menu_open == true then 
		return
	end
	
	-- We have completed building a structure which can reveal new structures (due to the build dependencies)
	-- so we want to make sure that we update the build list properly.
	if Mode == MODE_CONSTRUCTION then 
		Deselect_All_Buttons()
		if CommandBarEnabled == true then 
			Setup_Mode_Construction()	
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Displays(close_faction_specific)

	if close_faction_specific == nil then 
		close_faction_specific = true -- default value!
	end
	
	if QueueManager.Is_Open() == true then
		QueueManager.Close()		
	end
	
	if TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open() == true then
		-- Only close the rollout scene (ie. leave the location buttons)
		ReinforcementsMenuManager.Close()
	end
	
	if not IsReplay then
		Hide_Research_Tree()
	end
	
	if close_faction_specific == true then 
		-- this will also end the walker customization mode if applicable.
		Close_All_Specific_Displays()
	end
	
	BuildModeOn = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Closing_All_Displays
-- ------------------------------------------------------------------------------------------------------------------
function On_Closing_All_Displays(event, source)
	
	Close_All_Displays()
	Play_SFX_Event("GUI_Generic_Close_Window")
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over_RM_Text
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Over_RM_Text(event, source)
	Display_Tooltip({'ui', 'TEXT_UI_TACTICAL_RAW_MATERIALS_DISPLAY'})
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_RM_Text
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off_RM_Text(event, source)
	End_Tooltip()
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_Pop_Text
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off_Pop_Text(event, source)
	End_Tooltip()
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over_Pop_Text
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Over_Pop_Text(event, source)
	Display_Tooltip({'ui', 'TEXT_UI_TACTICAL_POP_CAP_DISPLAY'})	
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Maria 11.13.2006 - the textures for the tactical queue buttons change based on the owning faction
-- This function is used by desginers to open up specific build menus
-- ------------------------------------------------------------------------------------------------------------------------------------
function Display_Build_Menu(event, source, structure)
	if CommandBarEnabled == false then return end
	if structure == nil then 
		if SelectedBuilding ~= nil then 
			structure = SelectedBuilding
		else
			-- no structure specified, so let's get the first one in the list of all enabling structures.
			local all_buildings = QueueManager.Find_Tactical_Enablers()
			if all_buildings and table.getn(all_buildings) ~= 0 then 
				structure = all_buildings[1]
			end
		end
	end

	if structure ~= nil then 
		
		if not structure.Has_Behavior(BEHAVIOR_TACTICAL_ENABLER) then 
			MessageBox("Tactical_Command_Bar::Display_Build_Menu - The specified structure is not a tactical enabler!. Aborting command")
			return
		end
		
		Set_Selected_Objects({structure})
		Selection_Changed()
		
		-- Maria 11.13.2006	- if you want to point the camera at the building, add the command here!
		--Point_Camera_At(structure)
	else
		MessageBox("Tactical_Command_Bar::Display_Build_Menu - Could not find enablers!")
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Displaying_HP_Menu
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Displaying_HP_Menu(event, source)
	if CommandBarEnabled == false then return end
	if QueueManager.Is_Open() then 
		local queue_closed = QueueManager.Close()
		if queue_closed then 
			-- reset the index used to visit the buildings in this queue via hotkey.
			QueueTypeToLastQueueIndex[queue_closed] = 0
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Init_Queues_Interface
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Queues_Interface()
	-- Init the map of textures (one per faction)
	Init_Queue_Textures()

	-- Initialize buttons for different types of queues
	QueueTypes = { 'Command', 'Infantry', 'Vehicle', 'Air' }
	
	-- Update their tooltip info
	Update_Queues_Tooltip_Data()
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Update_Queues_Tooltip_Data
-- ------------------------------------------------------------------------------------------------------------------------------------
function Update_Queues_Tooltip_Data()
	QueueTypeToTooltipDataMap = {}
	QueueTypeToTooltipDataMap['Air'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_AIR", Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_AIR_BUILD_QUEUE", 1)}		
	QueueTypeToTooltipDataMap['Vehicle'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_VEHICLE", Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_VEHICLE_BUILD_QUEUE", 1)}
	QueueTypeToTooltipDataMap['Infantry'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_INFANTRY", Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_INFANTRY_BUILD_QUEUE", 1)}
	QueueTypeToTooltipDataMap['Command'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_COMMAND", Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_COMMAND_BUILD_QUEUE", 1)}

end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Maria 07.11.2006 - the textures for the tactical queue buttons change based on the owning faction
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Queue_Textures()
	PlayerToQueueTexturesMap = {}

	local faction_name = Find_Player("Alien").Get_Faction_Name()
	PlayerToQueueTexturesMap[faction_name] = {}
	PlayerToQueueTexturesMap[faction_name]['Command'] 	= 'i_icon_a_build_tab_command.tga' 
	PlayerToQueueTexturesMap[faction_name]['Air'] 		= 'i_icon_a_build_tab_air.tga' 
	PlayerToQueueTexturesMap[faction_name]['Infantry'] 	= 'i_icon_a_build_tab_infantry.tga' 
	PlayerToQueueTexturesMap[faction_name]['Vehicle'] 		= 'i_icon_a_build_tab_vehicle.tga' 
	

	faction_name = Find_Player("Military").Get_Faction_Name()
	PlayerToQueueTexturesMap[faction_name] = {}
	PlayerToQueueTexturesMap[faction_name]['Command'] 	= 'i_icon_ca.tga'
	PlayerToQueueTexturesMap[faction_name]['Air'] 		= 'i_icon_ca.tga'
	PlayerToQueueTexturesMap[faction_name]['Infantry'] 	= 'i_icon_ci.tga'
	PlayerToQueueTexturesMap[faction_name]['Vehicle'] 		= 'i_icon_cv.tga'
	
	
	faction_name = Find_Player("Novus").Get_Faction_Name()
	PlayerToQueueTexturesMap[faction_name] = {}
	PlayerToQueueTexturesMap[faction_name]['Command'] 	= 'i_icon_n_build_tab_command.tga'
	PlayerToQueueTexturesMap[faction_name]['Air'] 		= 'i_icon_n_build_tab_air.tga'
	PlayerToQueueTexturesMap[faction_name]['Infantry'] 	= 'i_icon_n_build_tab_infantry.tga'
	PlayerToQueueTexturesMap[faction_name]['Vehicle'] 		= 'i_icon_n_build_tab_vehicle.tga'
	
	
	faction_name = Find_Player("Masari").Get_Faction_Name()
	PlayerToQueueTexturesMap[faction_name] = {}
	PlayerToQueueTexturesMap[faction_name]['Command'] 	= 'i_icon_m_build_tab_command.tga'
	PlayerToQueueTexturesMap[faction_name]['Air'] 		= 'i_icon_m_build_tab_air.tga'
	PlayerToQueueTexturesMap[faction_name]['Infantry'] 	= 'i_icon_m_build_tab_infantry.tga'
	PlayerToQueueTexturesMap[faction_name]['Vehicle'] 		= 'i_icon_m_build_tab_vehicle.tga'
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Maria 07.11.2006 - Update the textures of the buttons when the faction changes!
-- ------------------------------------------------------------------------------------------------------------------------------------
function Update_Queue_Textures()
	local queue_textures = PlayerToQueueTexturesMap[LocalPlayer.Get_Faction_Name()]
	
	if queue_textures then
		for index, button in pairs(QueueButtons) do 
			local queue_name = button.Get_User_Data()
			button.Set_Texture(queue_textures[queue_name])
		end
	end
end



-- ------------------------------------------------------------------------------------------------------------------------------------
-- The textures for the idle builder button change based on the owning faction
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Idle_Builder_Textures()
	PlayerToIdleBuilderTexturesMap = {}
	PlayerToIdleBuilderTexturesMap[Find_Player("Alien").Get_Faction_Name()] = "i_icon_a_idle_builder.tga"
	PlayerToIdleBuilderTexturesMap[Find_Player("Novus").Get_Faction_Name()] = "i_icon_n_idle_builder.tga"
	PlayerToIdleBuilderTexturesMap[Find_Player("Masari").Get_Faction_Name()] = "i_icon_m_idle_builder.tga"
end


-- -----------------------------------------------------------------------------------------------------------------
--  On_Special_Ability_Targeting_Ended
--  Gets called whenever GameplayUI ends special ability targeting, for whatever reason.
-- ------------------------------------------------------------------------------------------------------------------
function On_Special_Ability_Targeting_Ended(event_name, source)
	CurrentSpecialAbilityUnitTypeName = nil
	
	if CurrentTargetingAbilityButton ~= nil then
		CurrentTargetingAbilityButton.Stop_Flash()
	end
	
	if Mode == MODE_SELECTION then	
		-- Eventually, when we have builder units, you'll have to have one selected to stay in this mode.
		Deselect_All_Buttons()
	elseif Mode == MODE_CONSTRUCTION then
		Update_Build_Ability_Data()
	end
end



-- -----------------------------------------------------------------------------------------------------------------
-- Returns either nil if this unit has no special ability, or a table of all special abilities this unit has.
-- ------------------------------------------------------------------------------------------------------------------
function Get_Unit_Special_Abilities(units_list)
	if not units_list then
		return
	end
	
	-- TODO: this should be just one call to code, not one per type of special ability.
	local abilities = nil
	
	-- Maria 07.10.2007 - we only use the list to determine how many (if any) are actually enabled!.
	local unit = units_list[1]
	
	-- MARIA 07.11.2006 - this table is VALID when used right after invoking Get_Unit_Special_Abilities(unit)
	-- and thus it reflects the number of special abilities for the given unit
	CurrentAbilityCount = {}
	local has_priorities = false
	if TestValid(unit) then
		for unit_ability_name, ability in pairs(SpecialAbilities) do
			
			local count = 0
			
			local unit_has_ability = unit.Has_Ability(unit_ability_name)
			local multi_exclude_ability = false

			if Is_Campaign_Game() == false and ability.campaign_game_only == true then
				unit_has_ability = false
				multi_exclude_ability = true
			end
			
			if unit_has_ability == true then 
				-- this will allow us to distinguish between abilities that belong to an individual object and those attached to an object
				-- by other objects attached to it (eg. the walker doesn't have a Jammer ability unless it has the Jammer hp attached to it)
				CurrentAbilityCount[unit_ability_name] = -1
				ability.AbilityOwner = unit
			end
			
			hardpoints = unit.Get_All_Hard_Points()
			if hardpoints and multi_exclude_ability == false then
				for _, hp in pairs(hardpoints) do
					if TestValid(hp) then
						unit_has_ability = (unit_has_ability or hp.Has_Ability(unit_ability_name))
						
						if hp.Has_Ability(unit_ability_name) then
							count = count + 1
							CurrentAbilityCount[unit_ability_name] = count
							
							if not ability.AbilityOwner then 
								ability.AbilityOwner = hp
							end
						end
					end
				end
			end
			
			if unit_has_ability then
				if not abilities then 
					abilities = {}
				end
				
				-- is this ability enabled!?
				local enabled = Is_Ability_Ready(units_list, unit_ability_name)
				ability.unit_ability_name = unit_ability_name
				table.insert(abilities, {ability, enabled})
				
				if ability.priority then
					has_priorities = true
				end
			end
		end
	end
	
	-- coming out of this function, 'abilities' will contain all the special abilities sorted based on the
	-- priority value they have been assigned (if, any)
	-- Since many abilities have no priorities set we only do this if at least one of the abilities has a priority value.
	if has_priorities == true then 
		Sort_Special_Abilities_By_Priority(abilities)
	end
	return abilities
end


-- -----------------------------------------------------------------------------------------------------------------
-- Is_Ability_Ready - Returns true if at least one of the units in the list has the 
-- ability ready!
-- ------------------------------------------------------------------------------------------------------------------
function Is_Ability_Ready(units, unit_ability_name)
	if not units or not unit_ability_name then
		return false
	end
	
	for _, unit in pairs(units) do
		if TestValid(unit) and unit.Is_Ability_Ready(unit_ability_name, false) then
			return true
		end
	end
	
	return false
end


-- -----------------------------------------------------------------------------------------------------------------
-- Sort_By_Priority
-- ------------------------------------------------------------------------------------------------------------------
function Sort_Special_Abilities_By_Priority(ab_list)
	local priorities = {}
	local priority_to_ab_data = {}
	for i = #ab_list, 1, -1 do
	--for _, ab_data in pairs(ab_list) do
		local ab_data = ab_list[i][1]
		local priority = ab_data.priority
		if not priority then 
			priority = 0
		end
		
		if priority_to_ab_data[priority] == nil then 
			priority_to_ab_data[priority]  = {}
			table.insert(priorities, priority)
		end
		
		table.insert(priority_to_ab_data[priority], ab_list[i])
		
		table.remove(ab_list, i)
	end
	
	-- Sort the priorities in increasing order.
	table.sort(priorities)
	
	-- now re-build the list of special abilities but now sorted by priority.
	for i, p in ipairs(priorities) do
		local priority_ab_data = priority_to_ab_data[p]
		for list_idx, ab_data in pairs(priority_ab_data) do
			table.insert(ab_list, ab_data)
		end
	end	
end

-- -----------------------------------------------------------------------------------------------------------------
-- Is_Unit_Special_Ability_Active(): Returns true if this unit's special ability is active; false if it isn't.
-- returns false if any hard point with ability isn't active
-- ------------------------------------------------------------------------------------------------------------------
function Is_Unit_Special_Ability_Active(unit, unit_ability_name, toggle)
	local hp_active = false
	
	if unit and unit_ability_name then
		if unit.Is_Ability_Active(unit_ability_name) and (not toggle or unit.Is_Ability_Ready(unit_ability_name, true)) then
			hp_active = true
		end
	
		hardpoints = unit.Get_All_Hard_Points()
		if hardpoints then
			for _, hp in pairs(hardpoints) do
				if hp.Has_Ability(unit_ability_name) then
					if hp.Is_Ability_Active(unit_ability_name) and (not toggle or unit.Is_Ability_Ready(unit_ability_name, true)) then
						hp_active = true
					else
						return false
					end
				end
			end
		end
	end	

	return hp_active
	
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Network_Start_Research - we need to send a network event so that we do not go out of sync!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Network_Start_Research(event, source, player, path, index)
	if IsDEFCONMode then
		Raise_Game_Event("Research_Lockout", player, nil, nil)
		return 
	end
	
	local player_script = player.Get_Script()
	if player_script ~= nil then 
		player_script.Call_Function("Start_Research", {path, index})
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Network_Cancel_Research - we need to send a network event so that we do not go out of sync!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Network_Cancel_Research(event, source, player, path, index)
	if IsDEFCONMode then 
		Raise_Game_Event("Research_Lockout", player, nil, nil)
		return 
	end
	
	local player_script = player.Get_Script()
	if player_script ~= nil then 
		player_script.Call_Function("Cancel_Research", {path, index})
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Is_Selected
-- ------------------------------------------------------------------------------------------------------------------
function Is_Selected(object)
	for index, obj in pairs(SelectedObjects) do
		if obj == object then
			return true
		end
	end
	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Refresh_Queue_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Refresh_Queue_Buttons()
	local current_queue_type = QueueManager.Get_Type()
	local flash = QueueManager.Is_Flashing_Buy_Buttons() and QueueManager.Get_Type() == nil
	
	if IsLetterboxMode then
		for i, queue_type in pairs(QueueTypes) do
			local button = QueueButtons[i]
			button.Set_Hidden(true)
		end
	else
		-- Show buttons for queue types that have buildings
		for i, queue_type in pairs(QueueTypes) do
			local button = QueueButtons[i]
			count = QueueManager.Get_Queue_Type_Enabler_Count(queue_type)
			if flash or QueueTypesToFlash[queue_type] then
				button.Start_Flash()
			else
				button.Stop_Flash()
			end
			
			if count == 0 then
				button.Set_Hidden(true)
				if queue_type == current_queue_type then
					QueueManager.Close()
				end
			else
				button.Set_Hidden(false)
				button.Set_Selected(current_queue_type == queue_type)
			end
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Queue_Button_Clicked(event, button)

	if CommandBarEnabled == false or IsLetterboxMode then return end
	
	-- since we may be issuing this event without the button having been clicked make sure the button is in a valid state
	if button.Get_Hidden() == true or button.Is_Enabled() == false then 
		return
	end
	
	-- The faction specific command bar may need to do something so let it know that the queue button has been clicked.
	if Process_Build_Queue_Button_Clicked then
		Process_Build_Queue_Button_Clicked()
	end
	
	-- Close all research trees that are up.
	-- EMP 7/14/07 Do not hide research tree during replays unless the observer hides it himself
	if not IsReplay then
		Hide_Research_Tree()
	end
	
	-- Reset HP customization mode in case it may be on.
	Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)

	local queue_type = button.Get_User_Data()
	local current_queue_type = QueueManager.Get_Type()
	
	if queue_type ~= current_queue_type then
		
		if current_queue_type then
			QueueTypeToLastQueueIndex[current_queue_type] = 0
		end
		
		QueueManager.Close()		
		QueueManager.Set_Screen_Position(button.Get_Screen_Position())
		
		-- if there's no valid building selected, we'll open just the building queue.  Otherwise, we'll also
		-- display the building's buy queue and build queue.
		
		local building = nil
		
		if QueueTypesToFlash[queue_type] then 
			QueueTypesToFlash[queue_type] = nil
		end
		
		-- If there's already a valid building selected, we open its queue.
		if SelectedBuilding then
			local building_type = QueueManager.Get_Building_Queue_Type(SelectedBuilding)
			
			if building_type == queue_type then 
				building = SelectedBuilding
			else
				QueueManager.Close()
			end
		end

		QueueManager.Open(queue_type, building)
		BuildModeOn = (not Is_Walker(building))
	else
		-- reset the index used to visit the buildings in this queue via hotkey.
		if current_queue_type then
			QueueTypeToLastQueueIndex[current_queue_type] = 0
		end
		QueueManager.Close()
		BuildModeOn = false
	end

	Refresh_Queue_Buttons()
	
	if Mode == MODE_CONSTRUCTION and CurrentSelectionNumTypes == 1 and #CurrentConstructorsList > 0 then 
		-- if there's only constructor(s) selected, we want to be able to go back to its build menu is no other selection order is issued.
		-- If more than one constructor and we go back with no new selection, then we will go back to the ability buttons.
		Setup_Mode_Construction()	
	else -- if there's more than one constructor or no constructor selected, then just update the selection mode dislpay.
		Mode = MODE_SELECTION
		Setup_Mode_Selection()
	end
end


	
-- ------------------------------------------------------------------------------------------------------------------
-- Deselect_All_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Deselect_All_Buttons()
	for index, button in pairs(SpecialAbilityButtons) do
		button.Set_Selected(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Reset_SA_Separators_State
-- ------------------------------------------------------------------------------------------------------------------
function Reset_SA_Separators_State()

	for _, sep in pairs(AbSeparators) do
		sep.Set_Hidden(true)
	end
	
	LastSeparatorIndex = 0
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hide_All_Buttons - hide build and special ability buttons
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Buttons()
	
	if Reset_SA_Separators_State then
		Reset_SA_Separators_State()
	end

	-- Special ability buttons
	for index, button in pairs(SpecialAbilityButtons) do
		button.Set_Hidden(true)
		-- Reset their formatting as well
		if SAButtonIdxToOrigBoundsMap[index] then 
			local bds = SAButtonIdxToOrigBoundsMap[index]
			button.Set_Bounds(bds.x, bds.y, bds.w, bds.h)
		end
	end
	
	-- Build Buttons
	for index, button in pairs(BuildButtons) do
		button.Set_Hidden(true)
		-- reset their enabled state as well!.
		button.Set_Enabled(true)
	end

	_PG_Hint_Refresh_GUI_Hints()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Networked_Mode_Switch - Issues the elemental mode switch in sync across all systems.
-- ------------------------------------------------------------------------------------------------------------------
function On_Networked_Mode_Switch(event, source, player, type)
	if player then
		player.Set_Elemental_Mode( type )
	end
end

   
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Network_Build_Hard_Point
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Network_Build_Hard_Point(event, source, socket_object, type_to_build, player)
	socket_object.Build( type_to_build, true, true )-- bool 1 = data validating, bool 2 = replace existing structure			
end

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Network_Cancel_Build_Hard_Point
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Network_Cancel_Build_Hard_Point(event, source, socket_object, player)
	socket_object.Cancel_Build()
end

-- ------------------------------------------------------------------------------------------------------------------
-- This should get called whenever the user changes what is selected.
-- Updates SelectedObjects[], and various flags about what's selected.
-- ------------------------------------------------------------------------------------------------------------------
function Selection_Changed(event, source, update_focus)
	-- Also in case faction changed.
	QueueManager.Find_Tactical_Enablers()
	
	-- Hide health bar for old selected objects.
	for index, object in pairs(SelectedObjects) do
		if TestValid(object) then
			Show_Object_Attached_UI(object, false)
			object.Unregister_Signal_Handler(On_Object_Removed_From_Selection_List)
			object.Unregister_Signal_Handler(On_Switch_Type)
		end
	end
	
	UpdateFocus = update_focus
	SelectedBuilding = nil
	BuildersAreSelected = false
	CurrentConstructorsList = {}
	SelectedObjectsByType = {}
	SelectedObjects = {}
	selectedObjects = Get_Selected_Objects()
	CurrentSelectionNumTypes = 0
	
	for index, object in pairs(selectedObjects) do
		if TestValid(object) then
			-- Don't include team members (which have BEHAVIOR_TEAM)
			local parent = object.Get_Parent_Object()
			if not parent or not parent.Has_Behavior(BEHAVIOR_TEAM) then
				table.insert(SelectedObjects, object)
				object.Register_Signal_Handler(On_Object_Removed_From_Selection_List, "OBJECT_HEALTH_AT_ZERO")
				object.Register_Signal_Handler(On_Object_Removed_From_Selection_List, "OBJECT_SOLD")
				object.Register_Signal_Handler(On_Switch_Type, "OBJECT_SWITCH_TYPE")
				
				
				if object.Get_Type().Get_Type_Value("Is_Tactical_Base_Builder") then
					table.insert(CurrentConstructorsList, object)
				end
				
				if object.Has_Behavior(BEHAVIOR_TACTICAL_ENABLER) then		
					SelectedBuilding = object
				end
				
				if object.Has_Behavior(BEHAVIOR_TACTICAL_BUILD_OBJECTS) and object.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) then
					SelectedBuilding = object
				end
				
				-- Add units that have a special ability to SelectedObjectsByType
				if Get_Unit_Special_Abilities({object}) then
					local type_name = object.Get_Type().Get_Name()
					if not SelectedObjectsByType[type_name] then
						SelectedObjectsByType[type_name] = { }
						CurrentSelectionNumTypes = CurrentSelectionNumTypes + 1
					end
					table.insert(SelectedObjectsByType[type_name], {Object = object, AbilityCount = CurrentAbilityCount})
				end
			end
		end
	end

	Update_UI_After_Selection_Change()
	UpdateFocus = nil
end

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Walker()
-- ------------------------------------------------------------------------------------------------------------------
function Is_Walker(object)
	if TestValid(object) then 
		return(object.Is_Walker())
	end
	return false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Constructors_List()
-- ------------------------------------------------------------------------------------------------------------------
function Update_Constructors_List()

	local total = table.getn(CurrentConstructorsList)
	for idx = total, 1, -1 do
		local constructor = CurrentConstructorsList[idx]
		
		if Is_Selected(constructor) == false then 
			table.remove(CurrentConstructorsList, idx)
		elseif constructor.Is_Flowing() == true then 
			table.remove(CurrentConstructorsList, idx)
		end
	end
	
	return table.getn(CurrentConstructorsList)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Remove_Constructor()
-- ------------------------------------------------------------------------------------------------------------------
function Remove_Constructor(object)

	if not TestValid(object) then return end
	if not object.Get_Type().Get_Type_Value("Is_Tactical_Base_Builder") then return end
	if not CurrentConstructorsList then return end
	
	for idx = 1, #CurrentConstructorsList do
		if CurrentConstructorsList[idx] == object then 
			table.remove(CurrentConstructorsList, idx)
			break
		end
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_UI_After_Selection_Change()
-- ------------------------------------------------------------------------------------------------------------------
function Update_UI_After_Selection_Change()

	for index, object in pairs(SelectedObjects) do
		if TestValid(object) then
			-- show reticles/health bar/etc.
			-- Maria 01.12.2007
			-- Per design request: for walkers we only display their UI on Mouse_Over
			if CustomizationModeOn == false and Is_Walker(object) and object ~= MouseOverObject then 
				Show_Object_Attached_UI(object, false)
			elseif CustomizationModeOn == false and object.Has_Behavior(BEHAVIOR_HARD_POINT) and Is_Walker(object.Get_Highest_Level_Hard_Point_Parent()) then 
				Show_Object_Attached_UI(object, false)
			else
				Show_Object_Attached_UI(object, true)
			end
		end
	end

	Mode = MODE_INVALID
	local is_tree_open = false
	local is_faction_specific_menu_open = false	
	local num_constructors_selected = Update_Constructors_List()
	

	if UpdateFocus == true and CustomizationModeOn == false then 
		-- selection has actually changed, so let's close all open displays!.
		Close_All_Displays(true)
	else
		if TestValid(this.Research_Tree) then 
			is_tree_open = this.Research_Tree.Is_Open()
		end
		
		if Is_Faction_Specific_Menu_Open then 
			is_faction_specific_menu_open = Is_Faction_Specific_Menu_Open()
		end	
	end
	
	if num_constructors_selected ~= 0 then
		if not is_tree_open and not is_faction_specific_menu_open then 
			if (BuilderMenuOpen == true or num_constructors_selected == #SelectedObjects) then
				-- Only if constructors are selected, pop this menu open!.
				Mode = MODE_CONSTRUCTION
			end
		end
	else
		BuilderMenuOpen = false
	end
	
	-- If a building was selected, show the appropriate queue
	local building_type = nil
	
	-- close the reinforcements display, if open
	if TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open() == true then
		ReinforcementsMenuManager.Close()
	end

	if SelectedBuilding then
		building_type = QueueManager.Get_Building_Queue_Type(SelectedBuilding)
	elseif UpdateFocus == true then
		Update_Faction_Specific_UI()
	end
	
	BuildModeOn = false
	
	-- only open the new queue if we are not in letter box mode!.
	if not IsLetterboxMode then 
		-- note: we can only open the build queue if the blueprint menu is not up!.
		if not Is_Player_Of_Faction(LocalPlayer, "Alien") or CustomizationModeOn == false then 
			if building_type and CommandBarEnabled == true and (not is_tree_open and not is_faction_specific_menu_open) then -- and BuildModeOn == true then 
				local button = QueueButtonsByType[building_type]
				if button then
					local queue_closed = QueueManager.Close()
					if queue_closed and building_type ~= queue_closed then 
						-- reset the index used to visit the buildings in this queue via hotkey.
						QueueTypeToLastQueueIndex[queue_closed] = 0
					end
					
					QueueManager.Set_Screen_Position(button.Get_Screen_Position())
					QueueManager.Open(building_type, SelectedBuilding)
					-- BuildModeOn = true
				end
			else
				local queue_closed = QueueManager.Close()
				if queue_closed then 
					-- reset the index used to visit the buildings in this queue via hotkey.
					QueueTypeToLastQueueIndex[queue_closed] = 0
				end
				BuildModeOn = false
			end
		end	
	end
	
	Update_Mode()
	
	Update_Hero_Icons(SelectedObjects)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Based on game state, update current game mode
-- ------------------------------------------------------------------------------------------------------------------
function Update_Mode()
	if Mode == MODE_CONSTRUCTION then	
		-- Eventually, when we have builder units, you'll have to have one selected to stay in this mode.
		Deselect_All_Buttons()
		Setup_Mode_Construction()
	else
		Mode = MODE_SELECTION
		Setup_Mode_Selection()
	end
	
	Update_Button_Flash_State()	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Show buildings that selected builders can build
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Mode_Construction()
	Hide_All_Buttons()

	if CommandBarEnabled == false then return end
	if #CurrentConstructorsList <= 0 then return end
	
	if BuildModeOn == true then
		-- since the build menus (for structures) run horizontally, we have to hide this menu so that there's no overlapping!.
		return
	end

	if TestValid(this.Research_Tree) and this.Research_Tree.Is_Open() == true and not IsReplay then 
		Hide_Research_Tree()
	end
	
	-- Let the specific scene hide whatever it needs to.
	Hide_Faction_Specific_Buttons()
	
	local player = Find_Player("local")
	local structures_data = nil
	if player ~= nil then
		-- NOTE: structures_data is a table of tables.  Each inner table contains:
		-- inner_table[1] = structure type
		-- inner_table[2] = assigned queue index (order)
		-- inner_table[3] = bool can produce? (tech and popcap dependencies)
		-- inner_table[4] = bool player has enough credits?
		
		-- THE FOLLOWING INFO IS NEEDED FOR TOOLTIP UPDATE!!!!
		-- inner_table[5] = lifetime build cap
		-- inner_table[6] = historically built count
		-- inner_table[7] = current build cap
		-- inner_table[8] = current build count
		-- inner_table[9] = pop cap category
		-- inner_table[10] = build time (this includes the pre-build time required for this object type)
		
		structures_data = player.Get_Available_Buildable_Structure_Types()
	end
	if structures_data == nil then return end
	
	local indeces = {}
	local object_type
	local can_produce
	local enough_credits
	local index_to_type_info_map = {}
	local types_count = 0
	local life_build_cap = -1
	local life_build_count = 0
	local curr_build_cap = -1
	local curr_build_count = 0
	local pop_cap_category = -1
	local build_time = 0
	local pre_build_time = 0
	
	
	
	for _, inner_table in pairs(structures_data) do
		object_type = inner_table[1]
		local queue_index = inner_table[2]
		
		can_produce = inner_table[3]
		enough_credits = inner_table[4]
		life_build_cap = inner_table[5]
		life_build_count = inner_table[6]
		curr_build_cap = inner_table[7]
		curr_build_count = inner_table[8]	
		pop_cap_category = inner_table[9]		
		build_time = inner_table[10]	
		pre_build_time = inner_table[11]	
		
		
		if index_to_type_info_map[queue_index] == nil then 
			index_to_type_info_map[queue_index]  = {}
			table.insert(indeces, queue_index)
		end
		-- just in case we have duplicate indeces we store the data in a table.
		table.insert(index_to_type_info_map[queue_index], {object_type, can_produce, enough_credits, life_build_cap, life_build_count, curr_build_cap, curr_build_count, pop_cap_category, build_time, pre_build_time})
		types_count = types_count + 1
	end
	
	-- Sort the indeces in increasing order.
	table.sort(indeces)
	
	if types_count > #BuildButtons then 
		MessageBox("There are not enough buttons to accomodate all options")
	end
	
	local build_rate = 1.0
	local builder = CurrentConstructorsList[1]
	if TestValid(builder) then
		build_rate = build_rate * (1.0 + builder.Get_Attribute_Value("Structure_Speed_Build"))
	end
	
	
	local button_index = 1
	for i, q_idx in ipairs(indeces) do
		local index_data = index_to_type_info_map[q_idx]
		
		for list_idx, type_data in pairs(index_data) do
			object_type = type_data[1]
			can_produce = type_data[2] -- takes precedence over enough_credits
			enough_credits = type_data[3]
			life_build_cap = type_data[4]
			life_build_count = type_data[5]
			curr_build_cap = type_data[6]
			curr_build_count = type_data[7]
			pop_cap_category = type_data[8]
			build_time = type_data[9]	
			pre_build_time = type_data[10]	
			
			if object_type then 
				icon_name = object_type.Get_Icon_Name()
				if icon_name ~= "" then
					local button = BuildButtons[button_index]
					button.Set_Texture(icon_name)
					button.Set_Hidden(false)
					button.Set_Text("")
					button.Set_User_Data(object_type)
					
					-- reset some of the data.
					button.Clear_Cost()
					button.Set_Insufficient_Funds_Display(false)
					
					-- Maria 09.18.2006
					-- If this a structure that counts towards pop cap (eg. the walkers) then, if there's not
					-- enough pop cap for it to be built, disbale its button!.
					if can_produce == false then 
						-- disable the button
						button.Set_Enabled(false)
					elseif not enough_credits then 
						-- the button should display a redish border and the cost should be displayed in red.
						button.Set_Insufficient_Funds_Display(true)
					end	

					local cost = object_type.Get_Tactical_Build_Cost(nil,player)
					if can_produce then 
						button.Set_Cost(cost)
					end
					
					local updated_build_time = (build_time/build_rate) + pre_build_time
					-- Tooltip data: tooltip mode, type, builder, cost, build time, warm up time, cooldown time.
					button.Set_Tooltip_Data({'type', {object_type, cost, updated_build_time, -1.0, -1.0, -1.0, life_build_cap, life_build_count, curr_build_cap, curr_build_count, pop_cap_category}})

					button_index = button_index + 1
					if button_index > table.getn(BuildButtons) then
						break
					end
				end
			end		
		end
	end
	
	if types_count > 0 then
		BuilderMenuOpen = true
	else
		BuilderMenuOpen = false
	end
	
	if button_index > 1 then 
		-- to avoid overlapping of UI components, close the tactical queue manager if open.
		if QueueManager.Is_Open() == true then
			local queue_closed = QueueManager.Close()
			if queue_closed then 
				-- reset the index used to visit the buildings in this queue via hotkey.
				QueueTypeToLastQueueIndex[queue_closed] = 0
			end
		end
		
		if UpdateFocus and ControllerDisplayingSelectionUI then
			this.Focus_First()
		end	
	end		
end
	
-- ------------------------------------------------------------------------------------------------------------------
-- Update_Build_Ability_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Build_Ability_Data()
	
	if BuilderMenuOpen then
		-- get the builder's ability data.
		if #CurrentConstructorsList < 1 then
			BuilderMenuOpen = false
			return false
		end
		
		local a_builder = CurrentConstructorsList[1]
		local script = a_builder.Get_Script()
		if script then 
			local ability_name = script.Get_Async_Data("BUILDER_DATA").ABILITY_NAME
			local ability = SpecialAbilities[ability_name]
		
			CurrentSpecialAbilityUnitTypeName = ability_name
			CurrentSpecialAbilityName = ability.special_ability_name
		end			
	end
	
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Build_Button_Click
-- ------------------------------------------------------------------------------------------------------------------
function On_Build_Button_Click(event, source)
	if CommandBarEnabled == false then return end
	
	End_Sell_Mode()
	
	local building_type = source.Get_User_Data()
	local building_type_name = building_type.Get_Name()
	if building_type then
		local player = Find_Player("local")
		if not player.Can_Produce_Object(building_type) then 
			-- we cannot produce this object so do nothing!.
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
			return
		end
		
		if BuildingTypesToFlash[building_type_name] then
			BuildingTypesToFlash[building_type_name] = nil
			Update_Button_Flash_State()
		end
		
		if Update_Build_Ability_Data()	 then
			GUI_Begin_Tactical_Base_Building_Mode(building_type, CurrentSpecialAbilityUnitTypeName, CurrentSpecialAbilityName)	
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Retrieve_Object_List - Needed to get the list of objects in SelectedObjectsByType.  This is necessary
-- given that SelectedObjectsByType[i] = {Object, AbilityCount} (where AbilityCount[ability_name] = count
-- ------------------------------------------------------------------------------------------------------------------
function Retrieve_Object_List(selection_data)
	local objects = {}
	for idx = 1, table.getn(selection_data) do
		-- For UI purposes we discard mind controlled units.
		local object = selection_data[idx].Object
		if object.Get_Attribute_Value( "Is_Mind_Controlled" ) <= 0 then 
			table.insert(objects, selection_data[idx].Object)
		end
	end
	
	return objects
end

-- ------------------------------------------------------------------------------------------------------------------
-- Return number of these abilities that will actually be visible.
-- ------------------------------------------------------------------------------------------------------------------
function Get_Num_Shown_Abilities(objects, abilities)
	local count = 0
	for i, ability_data in pairs(abilities) do
		-- Abilities with the "hide_when_active" flag which are active, don't get shown.
		local ability_active = Get_Units_Special_Ability_Active(objects, ability_data[1].unit_ability_name)
		if ability_data[1].hide_when_active and ability_active then
			-- not shown
		else
			if ability_data[1].hide_with_behavior then
				if not Do_Units_Have_Behavior(objects, ability_data[1].hide_with_behavior) then
					count = count + 1
				end
			elseif ability_data[1].hide_without_behavior then
				if Do_Units_Have_Behavior(objects, ability_data[1].hide_without_behavior) then
					count = count + 1
				end
			else
			    count = count + 1
			end
		end
	end
	return count
end

-- ------------------------------------------------------------------------------------------------------------------
-- Show selected units, and their special abilities
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Mode_Selection()
	
	if CommandBarEnabled == false then return end
	Hide_All_Buttons()
	
	if BuildModeOn == true then 
		-- when the build menus are up we want to hide the ability buttons to avoid overlapping of UI elements.
		-- As soon as the build menu is closed, the ability buttons will be disalayed again
		return
	end
	
	
	CurrentSelectionNumTypes = 0
	local sort_order_to_ab_data = {}
	local sort_indeces = {}
	
	for type_name, selection_data in pairs(SelectedObjectsByType) do
	
		local objects = Retrieve_Object_List(selection_data)		
		Remove_Invalid_Objects(objects)

		local count = table.getn(objects)
		if count > 0 then
		
			CurrentSelectionNumTypes = CurrentSelectionNumTypes + 1
			
			local abilities = Get_Unit_Special_Abilities(objects)
			if abilities and #abilities > 0 then
				local num_shown_abilities = Get_Num_Shown_Abilities(objects, abilities)
				
				local sort_value
				local ability = abilities[1]
				if ability then 
					sort_value = ability[1].sort_order
				end
				
				if sort_value == nil then 
					sort_value = 0
				end
				
				if sort_order_to_ab_data[sort_value] == nil then 
					sort_order_to_ab_data[sort_value] = {}
					table.insert(sort_indeces, sort_value)
				end
				
				table.insert(sort_order_to_ab_data[sort_value], {Objects = objects, Abilities = abilities, NumAbs = num_shown_abilities})				
			end
		end
	end
	
	if not CurrentSelectionNumTypes or CurrentSelectionNumTypes <= 0 then return end
	
	table.sort(sort_indeces)
	
	local num_rows = #SpecialAbilityButtons/ABILITIES_PER_ROW
	local ab_button_index = 1
	local row_ab_count = 0
	row = 1
	ab_button_index = ((row - 1)*ABILITIES_PER_ROW) + (row_ab_count+1)

	LastSAButtonPosition = nil
	for _, sort_val in pairs(sort_indeces) do
		local ab_data_list = sort_order_to_ab_data[sort_val]
		
		for _, ab_data in pairs(ab_data_list) do
			
			if ab_data.NumAbs <= ABILITIES_PER_ROW - row_ab_count then
				row_ab_count = row_ab_count + Add_Ability_Group_To_Display(ab_data.Objects, ab_data.Abilities, ab_button_index)
				ab_button_index = ((row - 1)*ABILITIES_PER_ROW) + (row_ab_count+1)
				
			else
				-- we have to move to the next row!.
				row = row + 1
				if row > num_rows then
					break
				end
				row_ab_count = 0
				ab_button_index = ((row - 1)*ABILITIES_PER_ROW) + (row_ab_count+1)
				
				-- Now place these guys and go on to the next entry.
				row_ab_count = row_ab_count + Add_Ability_Group_To_Display(ab_data.Objects, ab_data.Abilities, ab_button_index)
				ab_button_index = ((row - 1)*ABILITIES_PER_ROW) + (row_ab_count+1)				
			end		
		end -- for _, ab_data in pairs(ab_data_list) do	
	
	end -- for _, sort_val in pairs(sort_indeces) do	
	LastSAButtonPosition = nil
end -- function Setup_Mode_Selection()


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Add_Ability_Group_To_Display
-- ----------------------------------------------------------------------------------------------------------------------------------------------
function Is_First_Button(bttn_idx)
	
	if (bttn_idx == 1) then
		return true
	end
	
	local num_rows =  #SpecialAbilityButtons/ABILITIES_PER_ROW
	for i = 1, (num_rows - 1) do
		if (bttn_idx == (i * (ABILITIES_PER_ROW + 1))) then
			return true
		end
	end 
	
	return false
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Add_Ability_Group_To_Display
-- ----------------------------------------------------------------------------------------------------------------------------------------------
function Add_Ability_Group_To_Display(objects, abilities, ab_button_index)
	
	if objects == nil or #objects <= 0 then return end
	if ab_button_index <= 0 or ab_button_index > #SpecialAbilityButtons then return end
	
	local type_name = objects[1].Get_Type().Get_Name()

	-- *************************************************************
	
	local button_index = ab_button_index
	local num_abilities_assigned = 0
	for i, ability_data in pairs(abilities) do
		local ability = ability_data[1]
		local ability_active = Get_Units_Special_Ability_Active(objects, ability.unit_ability_name)
		local hide_with_behavior = false

		if ability.hide_with_behavior then
			hide_with_behavior = Do_Units_Have_Behavior(objects, ability.hide_with_behavior)
		end

		if ability.hide_without_behavior and not hide_with_behavior then
			hide_with_behavior = Do_Units_Have_Behavior(objects, ability.hide_without_behavior)
			hide_with_behavior = not hide_with_behavior
		end
		
		-- since these abilities will not be active, we need to keep track of the count af enabled vs disabled abs. ourselves.
		ready_to_activate_unit_count = -1
		local disable_without_behavior = false
		if ability.disable_without_behavior then
			ready_to_activate_unit_count = Number_Of_Units_With_Behavior(objects, ability.disable_without_behavior)
			disable_without_behavior = (ready_to_activate_unit_count == 0)
		end
		
		if ability.hide_when_active and ability_active then
			-- Abilities with the "hide_when_active" flag which are active, don't get shown.
		elseif hide_with_behavior then
			-- MLL: Some abilities are hidden with certain behaviors.
		else
			-- Everything else does get shown.		
			local button = SpecialAbilityButtons[button_index]
			if not button then 
				MessageBox("No Ability Button?????") 
				return 
			end
			
			if not Is_First_Button(button_index) then
				
				-- Position the button.
				if LastSAButtonPosition then
					-- position the button properly
					button.Set_Bounds(LastSAButtonPosition, SAButtonIdxToOrigBoundsMap[button_index].y, SAButtonIdxToOrigBoundsMap[button_index].w, SAButtonIdxToOrigBoundsMap[button_index].h )
					LastSAButtonPosition = LastSAButtonPosition + SAButtonIdxToOrigBoundsMap[button_index].w + SA_BUTTONS_GAP
				else
					MessageBox("NO START POSITION FOR THE AB BUTTON!")
				end
				
				-- if we are the first button of the set, let's place the separator between us and the previous button.
				if button_index == ab_button_index then
					-- HERE WE HAVE TO PLACE THE SEPARATORS!!!!!.
					-- Place the separator half way between the last button and where the new button will go.
					local last_button = SpecialAbilityButtons[ab_button_index - 1]
					
					if last_button then
						LastSeparatorIndex = LastSeparatorIndex + 1 
						if LastSeparatorIndex <= #AbSeparators then
							local separator = AbSeparators[LastSeparatorIndex]
							local last_bds = {}
							last_bds.x, last_bds.y, last_bds.w, last_bds.h = last_button.Get_World_Bounds()
							local last_pivot = {}
							last_pivot.x = last_bds.x + (last_bds.w / 2.0)
							last_pivot.y = last_bds.y + (last_bds.h / 2.0)
							
							local our_bds = {}
							our_bds.x, our_bds.y, our_bds.w, our_bds.h = button.Get_World_Bounds()
							local our_pivot = {}
							our_pivot.x = our_bds.x + (our_bds.w / 2.0)
							our_pivot.y = our_bds.y + (our_bds.h / 2.0)
							
							separator.Set_Screen_Position((last_pivot.x + our_pivot.x)/2.0, (last_pivot.y + our_pivot.y)/2.0)
							separator.Set_Hidden(false)							
						end
					end					
				end				
			else
				LastSAButtonPosition =  SAButtonIdxToOrigBoundsMap[button_index].x + SAButtonIdxToOrigBoundsMap[button_index].w + SA_BUTTONS_GAP
			end
			
			if button.Is_Flashing() == true then
				button.Stop_Flash()
			end
			
			-- What is this button associated with? (unit type and special ability)
			local user_data = {}
			user_data.type_name = type_name
			user_data.ability = ability
			user_data.active = ability_active
			
			if ability.disable_without_behavior then 
				user_data.disable_without_behavior_data = ready_to_activate_unit_count
			end
			
			button.Set_User_Data(user_data)
			
			-- Is this button's special ability the currently enabled one?
			if type_name == CurrentSpecialAbilityUnitTypeName and ability.unit_ability_name == CurrentSpecialAbilityName then
				button.Set_Selected(true)
			end

			-- Start flashing this button if the owner is a hard point only! and the ability has a targeting type!
			if objects[1].Has_Behavior(BEHAVIOR_HARD_POINT) then
				if ability.action == SPECIALABILITYACTION_TARGET_TERRAIN or ability.action == SPECIALABILITYACTION_TARGET_OBJECT then
					CurrentTargetingAbilityButton = button
					CurrentTargetingAbilityButton.Start_Flash()
				end
			end
			
			button.Set_Hidden(false)
			button.Set_Text("")
		
			local tooltip_ab_object = objects[1]
			if ability.AbilityOwner ~= tooltip_ab_object then
				tooltip_ab_object = ability.AbilityOwner
			end
			
			if ability_active and ability.alt_icon then
				button.Set_Texture(ability.alt_icon)				
			else
				button.Set_Texture(ability.icon)
			end
			
			if ability_data[2] == false or disable_without_behavior then -- this ability is disabled so disable its button
				button.Set_Enabled(false)
			else
				button.Set_Enabled(true)
			end 
		
			local object_type = objects[1].Get_Type()
			if (object_type.Get_Type_Value("Is_Tactical_Base_Builder") and ConstructorTypeToFlash[object_type] == true) 
				or (AbButtonsToFlash[ability.text_id] == true) then 
				button.Start_Flash()
			else
				button.Stop_Flash()
			end
			
			Update_SA_Button_Text(button_index)
			
			button_index = button_index + 1
		end -- passed "hide_when_active" check.
	end -- for abilities
	
	-- Set the proper 'grouping quad' on top of these buttons.
	local num_abs = button_index - ab_button_index
	_PG_Hint_Refresh_GUI_Hints()
	return (button_index - ab_button_index) -- return the number of abilities just added!.
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_SA_Button_Text
-- ------------------------------------------------------------------------------------------------------------------
function Update_SA_Button_Text(button_idx)
	if CommandBarEnabled == false then return end
	
	if not button_idx then return end
	
	if button_idx < 1 or button_idx > #SpecialAbilityButtons then
		MessageBox("Update_Special_Ability_Text::Invalid index for ability button.")
		return
	end
	
	local button = SpecialAbilityButtons[button_idx]
	
	-- if we have no valid button or the button is hidden, then do nothing.
	if not button or button.Get_Hidden() == true then return end
	
	local user_data = button.Get_User_Data()
	if user_data then 
		local selected_objects_data = SelectedObjectsByType[user_data.type_name]
		
		local selected_objects = {}
		for idx = 1, table.getn(selected_objects_data) do
			if TestValid(selected_objects_data[idx].Object) then
				table.insert(selected_objects, selected_objects_data[idx].Object)
			else
				table.remove(SelectedObjectsByType[user_data.type_name], idx)
			end
		end
		
		local is_toggle = (user_data.ability.action == SPECIALABILITYACTION_TOGGLE ) or
					(user_data.ability.action == SPECIALABILITYACTION_TARGET_TERRAIN_FORWARD_TOGGLE ) 
					
		-- Number of units ready to use this ability *right now*, added count here as hard points are now included
		local num_ready, count, percent_done, time_left, time_total, at_least_one_expiring
			= Get_Number_Units_Ready_For_Special_Ability(selected_objects, user_data.ability.unit_ability_name, is_toggle)
		
		-- Override the count if necessary, for the ability may appear enabled but it is actually disabled from its SpecialAbilities definition
		-- (eg. the sentry's unload ability)
		if user_data.disable_without_behavior_data then
			if user_data.disable_without_behavior_data == 0 and count == 1 then
				count = 0
			end		
		end
		
		-- MLL: Enable/disable the button when state changes.
		if time_left == nil then
			if count > 0 then
				button.Set_Enabled(true)
			else
				button.Set_Enabled(false)
			end
		end

		-- Wait, if we have a disable withouth behavior we must take that into account as well
		if user_data.disable_without_behavior_data and user_data.disable_without_behavior_data <= 0 then
			button.Set_Enabled(false)
		end
		
		--Make sure we always pass a reasonable value for the time_left parameter or silly LUA will
		--compact the table down.
		if not time_left then
			time_left = 0.0
		end
		
		local tooltip_data = {}
		tooltip_data[1] = user_data.ability.AbilityOwner
		tooltip_data[2] = user_data.ability.unit_ability_name
		if user_data.active and user_data.ability.alt_icon then
			tooltip_data[3] = user_data.ability.alt_text_id
			tooltip_data[4] = user_data.ability.alt_tooltip_description_text_id		
		else
			tooltip_data[3] = user_data.ability.text_id
			tooltip_data[4] = user_data.ability.tooltip_description_text_id
		end	
		tooltip_data[5] = user_data.ability.tooltip_category_id
		tooltip_data[6] = time_left
		tooltip_data[7] = Get_Ability_Key_Mapping_Text(LocalPlayer, user_data.ability.unit_ability_name)
		tooltip_data[8] = user_data.ability.types_to_spawn
		
		
		button.Set_Tooltip_Data({'ability', tooltip_data})

		if not user_data.disable_without_behavior_data and num_ready ~= count then
			local wstr_fraction = Get_Game_Text("TEXT_FRACTION")
			Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(num_ready), 0)
			Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(count), 1)
			button.Set_Text(wstr_fraction)
		else
			if user_data.disable_without_behavior_data then 
				if user_data.disable_without_behavior_data ~= count then
					local wstr_fraction = Get_Game_Text("TEXT_FRACTION")
					Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(user_data.disable_without_behavior_data), 0)
					Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(count), 1)
					button.Set_Text(wstr_fraction)
				else
					button.Set_Text(Get_Localized_Formatted_Number(user_data.disable_without_behavior_data))
				end
			else
				button.Set_Text(Get_Localized_Formatted_Number(count))
			end
		end



		-- Recharge clock.
		if percent_done then
			button.Set_Clock_Filled(percent_done)
			
			if at_least_one_expiring then
				button.Set_Clock_Tint(DefaultAbilityClockTint)
			else
				button.Set_Clock_Tint(RechargingAbilityClockTint)
			end

		else
			button.Set_Clock_Filled(0.0)
		end
	end		
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_Special_Ability_Text
-- ------------------------------------------------------------------------------------------------------------------
function Update_Special_Ability_Text()
	for idx, button in pairs(SpecialAbilityButtons) do
		Update_SA_Button_Text(idx)
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- GUI_Get_Maximum_Tactical_Resources -- Multiplayer safe player script query.  5/31/2007 10:23:33 AM -- BMH
-- ------------------------------------------------------------------------------------------------------------------
function GUI_Get_Maximum_Tactical_Resources()
	local script = LocalPlayer.Get_Script()
	if script == nil then return end
	return script.Get_Async_Data("CachedMaximumTacticalResourcesStorage")
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_Credits_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Credits_Display()
	-- Maria 10.19.2006
	-- There are two separate CREDIT pools.
	-- To pay for strategic stuff the player has CREDITS or strategic money, whereas to pay for
	-- tactical stuff the player has RAW MATERIALS or tactical money!.
	-- We want to display both for now in the tactical command bar.
	-- NOTE: Raw materials are re-initialized every time a new tactical battle begins.
	-- JSY: Removed the strategic display per design
	local credits_changed = false
		
	-- Set resource materials display - this is the player's TACTICAL MONEY!
	local new_raw_materials = LocalPlayer.Get_Raw_Materials()
	-- if the player has a cap on raw materials display it.
	local new_cap = GUI_Get_Maximum_Tactical_Resources()
	
	if (not LastRawMaterials or new_raw_materials ~= LastRawMaterials) or (new_cap ~= LastRMCap) then
	   
		if DisplayCreditsPop then
			local wstr_raw_mats
			if new_cap and new_cap >= 0 then
				wstr_raw_mats = Get_Game_Text("TEXT_FRACTION")
				Replace_Token(wstr_raw_mats, Get_Localized_Formatted_Number(new_raw_materials), 0)
				Replace_Token(wstr_raw_mats, Get_Localized_Formatted_Number(new_cap), 1)
			else
				wstr_raw_mats = Get_Localized_Formatted_Number(new_raw_materials)
			end
			
			if Scene.MaterialsText.Get_Hidden() then
				Scene.MaterialsText.Set_Hidden(false)
			end
			
			Scene.MaterialsText.Set_Text(wstr_raw_mats)
		end
		
		LastRawMaterials = new_raw_materials
		LastRMCap = new_cap
		credits_changed = true
	end
	
	if LocalPlayer and DisplayCreditsPop then
		if Scene.PopText.Get_Hidden() and DisplayCreditsPop then
			Scene.PopText.Set_Hidden(false)
		end
		
		local pop_cap_info = LocalPlayer.Get_Tactical_Popcap_Information()
		if not LastUsedPopCap or pop_cap_info.Used ~= LastUsedPopCap then
			local wstr_pop_cap = Get_Game_Text("TEXT_FRACTION")
			Replace_Token(wstr_pop_cap, Get_Localized_Formatted_Number(pop_cap_info.Used), 0)
			Replace_Token(wstr_pop_cap, Get_Localized_Formatted_Number(pop_cap_info.Total), 1)
			Scene.PopText.Set_Text(wstr_pop_cap)
			LastUsedPopCap = pop_cap_info.Used
			LastTotalPopCap = pop_cap_info.Total
		end
		if not LastTotalPopCap or pop_cap_info.Total ~= LastTotalPopCap then
			local wstr_pop_cap = Get_Game_Text("TEXT_FRACTION")
			Replace_Token(wstr_pop_cap, Get_Localized_Formatted_Number(pop_cap_info.Used), 0)
			Replace_Token(wstr_pop_cap, Get_Localized_Formatted_Number(pop_cap_info.Total), 1)
			Scene.PopText.Set_Text(wstr_pop_cap)
			LastUsedPopCap = pop_cap_info.Used
			LastTotalPopCap = pop_cap_info.Total
		end
		
		if pop_cap_info.WalkerTotal and TestValid(this.WalkerPopText) then
			if this.WalkerPopText.Get_Hidden() and DisplayCreditsPop then
				this.WalkerPopText.Set_Hidden(false)
			end
		
			if not LastWalkerPop or LastWalkerPop ~= pop_cap_info.WalkerUsed then
				local wstr_pop_cap = Get_Game_Text("TEXT_FRACTION")
				Replace_Token(wstr_pop_cap, Get_Localized_Formatted_Number(pop_cap_info.WalkerUsed), 0)
				Replace_Token(wstr_pop_cap, Get_Localized_Formatted_Number(pop_cap_info.WalkerTotal), 1)
				this.WalkerPopText.Set_Text(wstr_pop_cap)
				LastWalkerPop = pop_cap_info.WalkerUsed
			end			
		end		
	end
	return credits_changed -- did the amount of tactical money change?
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Mouse_Over
-- ------------------------------------------------------------------------------------------------------------------
function Update_Mouse_Over()

	-- Update mouse button states
	Update_Mouse_Buttons()

	local cursorOverObject = nil
	local tooltip_target = nil -- we want to display the hard point's tooltip and not its parent's!
	local build_list = nil
	local mouse_over_ui, object_owns_ui
	local gui_scene_owner = nil
	if not Is_Letter_Box_On() then
		cursorOverObject, mouse_over_ui, object_owns_ui, gui_scene_owner = Get_Object_At_Cursor()
		
		-- if this object is a hard point built on a socket then we want to display its tooltip information!
		if cursorOverObject and cursorOverObject.Has_Behavior(BEHAVIOR_HARD_POINT) then 
		 -- Maria 12.11.2006 - commenting this out since we want each individual (attackable) hard point socket to display
		 -- its own tooltip so that we can keep track of walker components taking damage.
		 --  cursorOverObject.Has_Behavior(BEHAVIOR_TACTICAL_SELL) then 
		 
		 -- Only hard points with text assigned are the ones that get their tooltips displayed!
			local name = cursorOverObject.Get_Type().Get_Display_Name()
			if name.empty() == false then 
				tooltip_target = cursorOverObject
			end
		end
		
		cursorOverObject = Get_Root_Object(cursorOverObject)
		if not TestValid(cursorOverObject) then 
			cursorOverObject = nil 
		end
	end
	
	local curtime = GetCurrentTime()
	if cursorOverObject == MouseOverObject then
		if cursorOverObject and MouseOverObjectTime > 0 and curtime - MouseOverObjectTime > MouseOverHoverTime then
			-- Show health bar for new moused-over object
			Show_Object_Attached_UI(MouseOverObject, true)
			
			-- Maria 10.30.2006
			-- Also show the object's tooltip, if applicable.
			if tooltip_target == nil then 
				local parent_object = MouseOverObject.Get_Parent_Object()
				if parent_object ~= nil and parent_object.Has_Behavior(BEHAVIOR_TEAM) then
					tooltip_target = parent_object
				else 
					tooltip_target = MouseOverObject				
				end
			end
			
			if tooltip_target ~= nil then 
				if not mouse_over_ui then 
					Display_Tooltip({'object', {tooltip_target}})
					MouseOverObjectTime = 0
				end
			end
		end
		
		if not TestValid(MouseOverObject) then 
			if TestValid(GUISceneOwner) and not TestValid(gui_scene_owner) then
				Process_Mouse_Off_Object(GUISceneOwner)
			end			
		end
		
	else
		MouseOverObjectTime = curtime
		-- If we were cursored over something and now we aren't, hide its health bar
		if (TestValid(MouseOverObject) and not TestValid(gui_scene_owner)) then 
			Process_Mouse_Off_Object(MouseOverObject)		
		end
		
		MouseOverObject = cursorOverObject
		
		if TestValid(GUISceneOwner) and not TestValid(gui_scene_owner) then
			Process_Mouse_Off_Object(GUISceneOwner)
		end			
	end	
	GUISceneOwner = gui_scene_owner
end


-- ------------------------------------------------------------------------------------------------------------------
-- Process_Mouse_Off_Object
-- ------------------------------------------------------------------------------------------------------------------
function Process_Mouse_Off_Object(object)
	if not object.Has_Behavior(BEHAVIOR_HARD_POINT) and not Is_Selected(object) then 
		Show_Object_Attached_UI(object, false)
	else
		if CustomizationModeOn == false and Is_Walker(object) then 
			Show_Object_Attached_UI(object, false)
		elseif CustomizationModeOn == false and object.Has_Behavior(BEHAVIOR_HARD_POINT) and Is_Walker(object.Get_Highest_Level_Hard_Point_Parent()) then 
			Show_Object_Attached_UI(object, false)
		end
	end
	
	-- Hide the tooltip
	End_Tooltip()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Tree_Scenes
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Tree_Scenes(event, source, player)
	Update_Tree_Scenes(player)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Tree_Scenes
-- ------------------------------------------------------------------------------------------------------------------
function Update_Tree_Scenes(player)
	if player == Find_Player("local") then 
		Raise_Event_Immediate_All_Scenes("Update_Tree_Scene", nil)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function Update_Common_Scene()

	LocalPlayer = Find_Player("local")
	local cur_time = GetCurrentTime()
	local nice_service_time = false
	if last_time == nil then 
		last_time = cur_time - 1
	elseif IsReplay == nil then
		IsReplay = Is_Replay()  -- hack to make this run on the SECOND service as this is called before the schedule event manager is initialized
		if IsReplay then
			Disable_GUI_For_Replay()
			--Lock_Camera(true)  --Changed 9/4/07 start with camera unlocked in replays
		end
	end


	if cur_time - last_time > 1 then
		last_time = cur_time
		nice_service_time = true
	end
	
	if LocalPlayer.Is_Build_Types_List_Initialized() == true and ResearchTreesInitialized == false then
		Raise_Event_Immediate_All_Scenes("Initialize_Tree_Scenes", nil)
		ResearchTreesInitialized = true
	end
	
	if CurrentConflictLocation ~= Get_Conflict_Location() then
		CurrentConflictLocation = Get_Conflict_Location()
	end
	
	-- Update letterbox UI
	local letter_box_percent = Get_Letter_Box_Percent()
	
	if letter_box_percent > 0 then
		-- Just starting letterbox?
		if not IsLetterboxMode then
				
				-- Oksana and Maria: do not show letterbox for certain (widescreen) resolution
			local settings = VideoSettingsManager.Get_Current_Settings()
			local width = settings.Screen_Width
			local height = settings.Screen_Height
			if width == 1600 and height == 900 then
				-- set the letterbox bounds so that it falls off the screen
				this.LetterboxBottom.Set_Bounds(LBBottom.x, LBBottom.y + LBBottom.h + 1, LBBottom.w, LBBottom.h)
				this.LetterboxTop.Set_Bounds(LBTop.x, LBTop.y - LBTop.h - 1, LBTop.w, LBTop.h)
			else
				this.LetterboxBottom.Set_Bounds(LBBottom.x, LBBottom.y, LBBottom.w, LBBottom.h)
				this.LetterboxTop.Set_Bounds(LBTop.x, LBTop.y, LBTop.w, LBTop.h)
			end
			
			
			IsLetterboxMode = true
			
			-- let the tooltip scene know that we are in letterbox mode so that we don't display any tooltips!.
			Tooltip.Set_Letterbox_Mode(true)
			
			-- We should also clear the data related to the object under the cursor so that we don't
			-- display wrong info when coming out of the letterbox mode (for the cursor may have moved!)
			MouseOverObject = nil
			MouseOverObjectTime = nil
			
			Set_Hint_System_Visible(false)
			
			-- Hide queue manager. 
			local queue_closed = QueueManager.Close()
			if queue_closed then 
				-- reset the index used to visit the buildings in this queue via hotkey.
				QueueTypeToLastQueueIndex[queue_closed] = 0
			end
			
			Refresh_Queue_Buttons()
			Hide_Radar_Map()
			
			-- Let other UI scenes know that they should be hidden while the cinematic plays
			Raise_Event_All_Scenes("Update_LetterBox_Mode_State", {true})
			
			--Set the active animation to letterbox but don't let it run free.  We'll manually update the frame
			--based on the letterbox state as determined by game code
			Scene.LetterboxTop.Set_Hidden(false)
			Scene.LetterboxBottom.Set_Hidden(false)
			Scene.Play_Animation("Letterbox", false)
			Scene.Pause_Animation()
			Scene.MinorAnnouncement.MinorAnnouncementText.Set_Text("")	
		end
		local anim_length = Scene.Get_Animation_Length()
		Scene.Set_Animation_Frame(letter_box_percent * anim_length)
	elseif IsLetterboxMode then
		-- Just ending letterbox
		IsLetterboxMode = false
		
		-- Let other UI scenes know that they should be fine now!
		Raise_Event_All_Scenes("Update_LetterBox_Mode_State", {false})
		
		-- let the tooltip scene know that letterbox mode is over so that we can display tooltips again!.
		Tooltip.Set_Letterbox_Mode(false)
		-- Make sure we clear out any tooltip information at this time.
		Tooltip.End_Tooltip()
		
		Set_Hint_System_Visible(true)
		
		for i, button in pairs(QueueButtons) do
			button.Set_Hidden(false)
		end
		
		Show_Radar_Map();
		Scene.Stop_Animation()
		Scene.LetterboxTop.Set_Hidden(true)
		Scene.LetterboxBottom.Set_Hidden(true)		
		
		-- Update the state of the UI based on the current selection
		Selection_Changed()
		
		-- force an update on everything so that the hidden/displayed state of buttons is refreshed immediately.
		nice_service_time = true
	end
	
	-- Update minor announcement text fade
	if not IsLetterboxMode then
		Update_Minor_Announcement_Text_Fade()
	end
	
	-- Update fade out UI
	local fade_percent = Get_Fade_Screen_Percent()
	if fade_percent > 0 then
		Scene.FadeQuad.Set_Hidden(false)
		Scene.FadeQuad.Set_Tint(0.0, 0.0, 0.0, fade_percent)
	else
		Scene.FadeQuad.Set_Hidden(true)
	end

	if nice_service_time then 
		Update_Are_Any_Controllers_Connected()
	end
	
	if not IsLetterboxMode then
		Update_Mouse_Over()
	end

	local credits_changed = false
	if nice_service_time then
		credits_changed = Update_Credits_Display()
	end
	
	if credits_changed then	
		if Mode == MODE_CONSTRUCTION then 
			-- Since we are disabling build buttons based on the cost of the associated structures and the player's money
			-- we need to update this accordingly.
			Setup_Mode_Construction()
		end
		
		-- Other scenes may need to be refreshed when the amount of credits for the local player changes.
		Raise_Event_Immediate_All_Scenes("Player_Credits_Changed", nil)
	end
	
	if Mode == MODE_SELECTION and nice_service_time then	
		Update_Special_Ability_Text()
	end

	if nice_service_time then
		Refresh_Queue_Buttons()
	end

	-- refresh as needed
	if QueueManager ~= nil and QueueManager.Update_Refresh ~= nil then
		QueueManager.Update_Refresh( cur_time )
	end
	
	-- Let the superweapon manager update.
	if nice_service_time then
		Superweapon_Update()
	end
	
	if TestValid(BuilderButton) then 
		local player_script = LocalPlayer.Get_Script()
		local hide_builder_button = true
		if player_script and player_script.Get_Async_Data("BuildersCount") > 0 then
			hide_builder_button = false
		end
		
		if hide_builder_button ~= BuilderButton.Get_Hidden() then 
			BuilderButton.Set_Hidden(hide_builder_button)					
		end				
	end
	
	-- JAC - Sell functionality is different if controller is connected
	if TestValid(SellButton) then 
		if AreAnyControllersConnected then
			SellButton.Set_Hidden(true)
		end
	end

	if UpdateHeroTooltips then 
		Update_Hero_Icons_Tooltip_Data()
		UpdateHeroTooltips = false
	end
	
	-- Maria 07.05.2007 - Removing the nice_Service_time check because it was causing the update of the hero button (from not selected to selected)
	-- lag way behind the actual selection of the hero.
	Update_Hero_Icons(nil) -- Need to update the health bars for all present heroes.  Pass nil so that we don't update selected state.
	Update_Control_Group_Buttons(cur_time)
	Update_Credits_Popcap_Tooltip_Display(cur_time)
	
	-- let the main scene know whether we have GUI elements to close.
	local intercept_close_command = QueueManager.Is_Open() or
						(TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open()) or
						(TestValid(this.full_screen_movie) and this.full_screen_movie.Has_Movie())
	return intercept_close_command, credits_changed
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Credits_Popcap_Tooltip_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Credits_Popcap_Tooltip_Display(cur_time)
	-- Tooltip management for the pop cap and raw materials displays.
	if CreditsPopCapDisplayMouseOverStartTime and CreditsPopCapDisplayMouseOverStartTime + MouseOverHoverTime <= cur_time then
		if CreditsPopCapDisplayMouseOverComponent then
			Display_Tooltip(CreditsPopCapDisplayMouseOverComponent.Get_Tooltip_Data())
			CreditsPopCapDisplayMouseOverComponent = nil
		end	
		CreditsPopCapDisplayMouseOverStartTime = nil
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Are_Any_Controllers_Connected
-- ------------------------------------------------------------------------------------------------------------------
function Update_Are_Any_Controllers_Connected()
	if IsLetterboxMode then return end
	
	local new_state = Are_Any_Controllers_Connected()
	if new_state ~= AreAnyControllersConnected then 
		this.RadarZoomButton.Set_Hidden(not new_state)
		AreAnyControllersConnected = new_state
		
		if not AreAnyControllersConnected and not ControllerDisplayingSelectionUI then 
			Controller_Display_Selection_UI(true)
		elseif AreAnyControllersConnected and ControllerDisplayingSelectionUI then
			-- by default we hide the selection UI
			Controller_Display_Selection_UI(false)
		end
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Announcement Text is a big text string centered on the screen.
-- Handy for things like "You are Victorious!"
-- ------------------------------------------------------------------------------------------------------------------
function Set_Announcement_Text(event, source, text_string)
	if text_string then
		Scene.AnnouncementGroup.AnnouncementText.Set_Text(text_string)
		Scene.AnnouncementGroup.Set_Hidden(false)
	else
		Scene.AnnouncementGroup.AnnouncementText.Set_Text("")
		Scene.AnnouncementGroup.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Announcement Text for the game end. It can't be in DefaultLandScript because
-- it queries the local player which causes an out of sync.
-- ------------------------------------------------------------------------------------------------------------------
function Set_Skirmish_Game_End_Announcement_Text(event, source, winner)
	if winner.Is_Ally(Find_Player("local")) then
		Set_Announcement_Text(event, source, Get_Game_Text("TEXT_WIN_TACTICAL"))
	else
		Set_Announcement_Text(event, source, Get_Game_Text("TEXT_LOSE_TACTICAL"))
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Minor Announcement Text is a slightly smaller text string centered on the screen.
-- Handy for things like "Objective Completed"
-- ------------------------------------------------------------------------------------------------------------------
function Set_Minor_Announcement_Text(event, source, text_string)
	Scene.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(false)
	if text_string then
		Scene.MinorAnnouncement.MinorAnnouncementText.Set_Text(text_string)
		Scene.MinorAnnouncement.Play_Animation("MinorAnnouncementFade", false)
		Scene.MinorAnnouncement.Set_Animation_Frame(0)
		
		MinorAnnouncementTextFadeStartTime = GetCurrentTime()
	else
		Scene.MinorAnnouncement.MinorAnnouncementText.Set_Text("")
		MinorAnnouncementTextFadeStartTime = nil
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Stub text is just a development tool
-- ------------------------------------------------------------------------------------------------------------------
function Stub_Text(event, source, text_string)
	if text_string then
		Scene.StubText.Set_Hidden(false)
		Scene.StubText.Set_Text(text_string)
	else
		Scene.StubText.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Comm_Officer_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Comm_Officer_Clicked(hero)
	Scene.Objectives.Toggle()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Comm_Officer_Double_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Comm_Officer_Double_Clicked(hero)
	Scene.Objectives.Toggle()
end



-- ------------------------------------------------------------------------------------------------------------------
-- Maria 08.09.2006
-- On_Hide_UI -- Attached to HOT KEY VK_W
-- ------------------------------------------------------------------------------------------------------------------
function On_Hide_UI(event, source, onoff)

	if onoff == true then -- i.e., hide
		-- Close all the huds first and then hide them!
		if QueueManager.Is_Open() == true then
			QueueManager.Close()
		end
		
		if TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open() == true then
			ReinforcementsMenuManager.Close()
		end
		
		Hide_Research_Tree()
	end
	
	Hide_All_Faction_Specific_UI(onoff)
	Scene.Set_Hidden(onoff)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Button_Index_For_Unit_Type
--   Given the name of a unit type, return the button index (a number) of the command bar button; 
--   if none, returns nil.
-- ------------------------------------------------------------------------------------------------------------------
function Get_Button_Index_For_Unit_Type(type_name)
	if Mode ~= MODE_SELECTION then
		return nil
	end
	
	local index = 1
	for name, objects in pairs(SelectedObjectsByType) do
		if name == type_name then
			return index
		end
		index = index + 1
	end
	return nil
end



-- ------------------------------------------------------------------------------------------------------------------
-- Get_Units_Special_Ability_Active - 
-- If *all* units at the given button index have their special ability active, returns true. Else, returns false.
-- ------------------------------------------------------------------------------------------------------------------
function Get_Units_Special_Ability_Active(objects, unit_ability_name)
	for index, object in pairs(objects) do
		if not Is_Unit_Special_Ability_Active(object, unit_ability_name) then
			return false
		end
	end
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Returns the number of units within the list have the specified behavior
-- ------------------------------------------------------------------------------------------------------------------
function Number_Of_Units_With_Behavior(objects, behavior)
   local count = 0
   for index, object in pairs(objects) do
        if object.Has_Behavior(behavior) then
            count = count + 1 
        end
    end
    return count
end


-- Returns true if all game objects have the requested behavior.
-- MLL
function Do_Units_Have_Behavior(objects, behavior)
    for index, object in pairs(objects) do
        if not object.Has_Behavior(behavior) then
            return false
        end
    end

    return true
end

-- Returns true if all game objects have enough health.
-- MLL
function Do_Units_Have_Enough_Health(objects, min_health)
    for index, object in pairs(objects) do
        if object.Get_Hull() < min_health then
            return false
        end
    end

    return true
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_Button_Flash_State - make the buttons we want flashing, flash.
-- ------------------------------------------------------------------------------------------------------------------
function Update_Button_Flash_State()
	for i, button in pairs(BuildButtons) do
		if Mode == MODE_CONSTRUCTION and CommandBarEnabled == true then
			local building_type = button.Get_User_Data()
			if building_type then
				local building_type_name = building_type.Get_Name()
				if BuildingTypesToFlash[building_type_name] then
					button.Start_Flash()
				else
					button.Stop_Flash()
				end
			end
		else
			button.Stop_Flash()
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Construct_Building - 
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Construct_Building(event, source, building_name)
	BuildingTypesToFlash[Find_Object_Type(building_name).Get_Name()] = true
	Update_Button_Flash_State()
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Construct_Building - 
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Construct_Building(event, source, building_name)
	BuildingTypesToFlash[Find_Object_Type(building_name).Get_Name()] = nil
	Update_Button_Flash_State()
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_Button_Flash_State - make the buttons we want flashing, flash.
-- ------------------------------------------------------------------------------------------------------------------
function Update_Button_Flash_State()
	for i, button in pairs(BuildButtons) do
		if Mode == MODE_CONSTRUCTION and CommandBarEnabled == true then
			local building_type = button.Get_User_Data()
			if building_type then
				local building_type_name = building_type.Get_Name()
				if button.Is_Enabled() == true and BuildingTypesToFlash[building_type_name] then
					button.Start_Flash()
				else
					button.Stop_Flash()
				end
			end
		else
			button.Stop_Flash()
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Mission_Text_User_Event ---- TBI
-- ------------------------------------------------------------------------------------------------------------------
function Mission_Text_User_Event( event_name, source, bool_use_gui, header_text, user_message, briefing_text01, briefing_text02, briefing_text03, briefing_text04, status_text, bool_hide_background, bool_victory, bool_defeat)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Get_Selected_Unit_Type_For_Button_Index - 
--   Given an index for a button on the command bar, return the string name of the type of unit(s) assigned
--   to that button.
-- ------------------------------------------------------------------------------------------------------------------
function Get_Selected_Unit_Type_For_Button_Index(index)
	for type_name, objects in pairs(SelectedObjectsByType) do
		if index <= 1 then 
			return type_name
		end
		index = index - 1
	end
	return nil
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Network_Activate_Ability
-- ------------------------------------------------------------------------------------------------------------------
function On_Network_Activate_Ability(event, source, toggle, objects, unit_ability_name, player)
	if toggle then
		local was_active = Get_Units_Special_Ability_Active(objects, unit_ability_name)
	
		-- If all were on before, turn all off; otherwise turn all which aren't on, on
		for index, unit in pairs(objects) do
			-- Toggle if it was on and is on, or was off and is off
			local now_active = Is_Unit_Special_Ability_Active(unit, unit_ability_name, toggle)
			if now_active == was_active then
				unit.Activate_Ability(unit_ability_name, not was_active, nil, true)
			end
		end
	else
		for i, unit in pairs(objects) do
			unit.Activate_Ability(unit_ability_name, true)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Network_Deactivate_Ability
-- ------------------------------------------------------------------------------------------------------------------
function On_Network_Deactivate_Ability(event, source, objects, unit_ability_name, player)
	
	for i, unit in pairs(objects) do
		unit.Activate_Ability(unit_ability_name, false, nil, true)
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Unit_Special_Ability_Right_Clicked - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function On_Unit_Special_Ability_Right_Clicked(event, button)
	
	if CommandBarEnabled == false then return end
	
	End_Sell_Mode()
	
	local user_data = button.Get_User_Data()
	
	-- Since we can activate abilities without clicking on the button (keyboard mappings) it may happen that we are coming through 
	-- with an ability button that is disabled, thus, do not process it!.
	if not user_data then 
		return
	end

	local type_name = user_data.type_name
	local ability = user_data.ability
	
	Deactivate_Ability(ability.unit_ability_name, type_name)
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Unit_Special_Ability_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Unit_Special_Ability_Clicked(event, button)
	
	if CommandBarEnabled == false then return end
	
	End_Sell_Mode()
	
	local user_data = button.Get_User_Data()
	
	-- Since we can activate abilities without clicking on the button (keyboard mappings) it may happen that we are coming through 
	-- with an ability button that is disabled, thus, do not process it!.
	if not user_data then 
		return
	end

	local type_name = user_data.type_name
	local ability = user_data.ability
	
	Activate_Ability(ability.unit_ability_name, type_name)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Selection_Allows_Ability_Activation
-- ------------------------------------------------------------------------------------------------------------------
function Selection_Allows_Ability_Activation(objects_list, ability_name)
	
	if SpecialAbilities[ability_name].campaign_game_only and not Is_Campaign_Game() then
		return false
	end

	for _, unit in pairs(objects_list) do
	
		if TestValid(unit) then
			local unit_has_ability = unit.Has_Ability(ability_name)
			
			if unit_has_ability == true then 
				return true, unit.Get_Type()
			end
			
			hardpoints = unit.Get_All_Hard_Points()
			if hardpoints then
				for _, hp in pairs(hardpoints) do
					if TestValid(hp) then
						unit_has_ability = (unit_has_ability or hp.Has_Ability(ability_name))
						
						if unit_has_ability then
							return true, unit.Get_Type()
						end
					end
				end
			end
		end
	end -- end for ...objects_list
	
	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hot_Key_Activate_Unit_Ability
-- ------------------------------------------------------------------------------------------------------------------
function Hot_Key_Activate_Unit_Ability(unit_ability_name)

	-- before activating the ability make sure that we have at least one selected object with the ability!
	local can_activate, unit_type = Selection_Allows_Ability_Activation(SelectedObjects, unit_ability_name)
	
	-- if we cannot activate or do not have a valid activation type, do nothing!.
	if can_activate == false or unit_type == nil then 
		return
	end
	
	End_Sell_Mode()
	
	Activate_Ability(unit_ability_name, unit_type.Get_Name())
end


-- ------------------------------------------------------------------------------------------------------------------
-- Activate_Ability
-- ------------------------------------------------------------------------------------------------------------------
function Activate_Ability(unit_ability_name, type_name)
	if unit_ability_name == nil or type_name == nil then return end
	
	local selection_data = SelectedObjectsByType[type_name]
	
	local objects = Retrieve_Object_List(selection_data)
	Remove_Invalid_Objects(objects)
	
	local count = table.getn(objects)
	
	-- retrieve the ability data
	local ability = SpecialAbilities[unit_ability_name]
	
	if not ability then
		-- Hmm, that's weird...
		return
	end	
	
	-- if the button is clicked and it is flashing then remove it from the list of flashing ab. buttons.
	if AbButtonsToFlash[ability.text_id] then
		AbButtonsToFlash[ability.text_id] = nil
	end
	
	local ability_action = ability.action
	
	-- Oksana: for toggle_forward, we need to override action
	if(ability_action == SPECIALABILITYACTION_TARGET_TERRAIN_FORWARD_TOGGLE) then
		local all_were_active = Get_Units_Special_Ability_Active(objects, unit_ability_name)

		-- If all were on before, turn all off; otherwise begin targeting for those that are not on
		for index, unit in pairs(objects) do
			-- Toggle if it was on and is on, or was off and is off
			local now_active = Is_Unit_Special_Ability_Active(unit, unit_ability_name)
			if all_were_active and now_active then
				--de-activate
				--unit.Activate_Ability(unit_ability_name, false)
				ability_action = SPECIALABILITYACTION_TOGGLE
			else 
				--begin targeting 
				ability_action = SPECIALABILITYACTION_TARGET_TERRAIN
			end
		end		
	end
		
	if ability_action == SPECIALABILITYACTION_TOGGLE then

		-- Send an activate ability network event.
		Send_GUI_Network_Event("Network_Activate_Ability", { true, objects, unit_ability_name, Find_Player("local") })

	elseif ability_action == SPECIALABILITYACTION_TARGET_TERRAIN then
		Deselect_All_Buttons()
		
		-- Toggle targeting
		if CurrentSpecialAbilityUnitTypeName and type_name == CurrentSpecialAbilityUnitTypeName and
			CurrentSpecialAbilityName == unit_ability_name
		then
			CurrentSpecialAbilityUnitTypeName = nil
			CurrentSpecialAbilityName = nil
			GUI_End_Special_Ability_Targeting()
		else
			CurrentSpecialAbilityUnitTypeName = type_name
			CurrentSpecialAbilityName = unit_ability_name
			local success = GUI_Begin_Special_Ability_Passable_Terrain_Targeting(objects, unit_ability_name)
			if success == true and objects[1].Has_Behavior(BEHAVIOR_HARD_POINT) then
				CurrentTargetingAbilityButton = button
				CurrentTargetingAbilityButton.Start_Flash()
			end
		end

	elseif ability_action == SPECIALABILITYACTION_TARGET_OBJECT then
		Deselect_All_Buttons()
		
		-- Toggle targetting
		if CurrentSpecialAbilityUnitTypeName and type_name == CurrentSpecialAbilityUnitTypeName and
			CurrentSpecialAbilityName == unit_ability_name
		then
			CurrentSpecialAbilityUnitTypeName = nil
			CurrentSpecialAbilityName = nil
			GUI_End_Special_Ability_Targeting()
		else
			CurrentSpecialAbilityUnitTypeName = type_name
			CurrentSpecialAbilityName = unit_ability_name
			
			ability_min_range = 0
			if ability.min_range then
				ability_min_range = ability.min_range
			end
			
			local success = GUI_Begin_Special_Ability_Object_Targeting(objects, unit_ability_name, ability.special_ability_name, ability.max_range, ability_min_range)
			if success == true and objects[1].Has_Behavior(BEHAVIOR_HARD_POINT) then
				CurrentTargetingAbilityButton = button
				CurrentTargetingAbilityButton.Start_Flash()
			end
		end
	elseif ability.action == SPECIALABILITYACTION_INSTANT then
		-- Send an activate ability network event.
		Send_GUI_Network_Event("Network_Activate_Ability", { false, objects, unit_ability_name, Find_Player("local") })
		
	elseif ability_action == SPECIALABILITYACTION_ENABLE_BUILD_MODE then
		
		--Oksana - enable build mode
		CurrentSpecialAbilityUnitTypeName = unit_ability_name
  		CurrentSpecialAbilityName = ability.special_ability_name
		Mode = MODE_CONSTRUCTION		
		CurrentConstructorsList = objects
		if objects[1] then 
			ConstructorTypeToFlash[objects[1].Get_Type()] = nil
		end
		
		Update_Mode()
	end
	
	-- Make sure display updates to reflect changed icons (if any).
	if Mode == MODE_SELECTION and CommandBarEnabled == true then
		Setup_Mode_Selection()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Deactivate_Ability
-- ------------------------------------------------------------------------------------------------------------------
function Deactivate_Ability(unit_ability_name, type_name)
	if unit_ability_name == nil or type_name == nil then return end
	
	local selection_data = SelectedObjectsByType[type_name]
	
	local objects = Retrieve_Object_List(selection_data)
	Remove_Invalid_Objects(objects)
	
	local count = table.getn(objects)
	
	-- retrieve the ability data
	local ability = SpecialAbilities[unit_ability_name]
	
	if not ability then
		-- Hmm, that's weird...
		return
	end	
	
	-- Send an activate ability network event.
	Send_GUI_Network_Event("Network_Deactivate_Ability", { objects, unit_ability_name, Find_Player("local") })
end




-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Produce_Units
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Produce_Units()
	if CommandBarEnabled == false then return end
	QueueManager.Set_Flashing_Buy_Buttons(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Produce_Units
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Produce_Units()
	QueueManager.Set_Flashing_Buy_Buttons(false)
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Produce_Unit
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Produce_Unit(event, source, unit_type)
	if CommandBarEnabled == false then return end
	QueueManager.Set_Flashing_Unit_Button(unit_type)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Stop_Flashing_Unit_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Produce_Unit(event, source, unit_type)
	QueueManager.Stop_Flashing_Unit_Button(unit_type)
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Temp_Enable_Build_Item
-- ------------------------------------------------------------------------------------------------------------------
function UI_Temp_Enable_Build_Item(event, source, object_type)
	QueueManager.Temp_Enable_Build_Item(object_type)
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Queue_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Queue_Buttons(event, source, builder_type, object_type)
	if builder_type == nil or object_type == nil then 
		return
	end
	
	-- is this a constructor?
	if builder_type.Get_Type_Value("Is_Tactical_Base_Builder") == true then 
		BuildingTypesToFlash[object_type.Get_Name()] = true
		ConstructorTypeToFlash[builder_type] = true
		
		Update_Button_Flash_State()
		
		if SelectedObjectsByType[builder_type.Get_Name()] ~= nil then 
			Setup_Mode_Selection()		
		end
		
		return
	end
	
	local queue_type = builder_type.Get_Building_Queue_Type()
	if queue_type == nil then 
		return		
	end
	
	-- just in case close all other displays!
	Close_All_Displays()
	
	QueueTypesToFlash[queue_type] = true
	QueueManager.Set_Flashing_Unit_Button(object_type)
	QueueManager.Set_Flashing_Building_Button(builder_type)
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Queue_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Queue_Buttons(event, source, building_type, object_type)
	
	if building_type.Get_Type_Value("Is_Tactical_Base_Builder") == true then 
		BuildingTypesToFlash[object_type.Get_Name()] = nil
		ConstructorTypeToFlash[building_type] = nil
		Update_Button_Flash_State()
		
		if SelectedObjectsByType[building_type.Get_Name()] ~= nil then 
			Setup_Mode_Selection()		
		end
		return
	end
	
	local queue_type = building_type.Get_Building_Queue_Type()
	
	if queue_type == nil then
		return
	end
	
	QueueTypesToFlash[queue_type] = nil
	QueueManager.Stop_Flashing_Unit_Button(object_type)
	QueueManager.Stop_Flashing_Building_Button(building_type)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Object_Removed_From_Selection_List - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Object_Removed_From_Selection_List(object)
	-- NOTE: inside the Detach_Object function we update the UI!.
	Detach_Object(object)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Hard_Point_Detachment - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Hard_Point_Detachment(event, source, parent_object, hp_object)
	
	-- Update the special abilities data (if necessary)
	if SelectedBuilding == parent_object then
		for unit_ability_name, ability in pairs(SpecialAbilities) do
			if hp_object.Has_Ability(unit_ability_name) then
				-- update the ability count!.
				local type_name = parent_object.Get_Type().Get_Name()
				
				if SelectedObjectsByType[type_name] == nil then
					Selection_Changed()
				end
				
				--update the ability count!
				local selected_data = SelectedObjectsByType[type_name]
				local found = false
				for idx = 1, table.getn(selected_data) do
					if selected_data[idx].Object == parent_object then
						local old_ab_ct = selected_data[idx].AbilityCount[unit_ability_name]
						selected_data[idx].AbilityCount[unit_ability_name] = old_ab_ct - 1
						found = true
						break
					end
				end
				
				if not found then 
					--MessageBox("BAD!!!! Contact Maria.")
				end			
			end
		end
	end	

	Detach_Object(hp_object)
	
	if Mode == MODE_SELECTION then
		Setup_Mode_Selection()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Hard_Point_Attached - If the object that has a new hard point is the one that is selected, 
-- check to see if this new hard point endows the object with a special ability. If so, update the 
-- special ability buttons accordingly.
-- ------------------------------------------------------------------------------------------------------------------
function On_Hard_Point_Attached(event, source, parent_object)
	if parent_object ~= nil then
		-- does this HP give the object a new ability!?. If so, add units that have a special ability to SelectedObjectsByType
		if parent_object.Has_Behavior(BEHAVIOR_TACTICAL_ENABLER) then
			if SelectedBuilding == parent_object then
				local type_name = parent_object.Get_Type().Get_Name()
				if Get_Unit_Special_Abilities({parent_object}) then
					if SelectedObjectsByType[type_name] == nil then 
						SelectedObjectsByType[type_name] = {}
						table.insert(SelectedObjectsByType[type_name], { Object = parent_object, AbilityCount = CurrentAbilityCount })
					else
						--update the ability count!
						local selected_data = SelectedObjectsByType[type_name]
						local found = false
						for idx = 1, table.getn(selected_data) do
							if selected_data[idx].Object == parent_object then
								selected_data[idx].AbilityCount = CurrentAbilityCount	
								found = true
								break
							end
						end
						
						if not found then 
						end
						
					end
				end
			end
		end
		
		-- Refresh the scene
		if Mode == MODE_SELECTION then
			Setup_Mode_Selection()
		end
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Can_Reset_Attached_UI_Display - 
-- ------------------------------------------------------------------------------------------------------------------
function Can_Reset_Attached_UI_Display(object)

	if CustomizationModeOn == true then 
		-- is the object part of the current walker being configured?
		if WalkerConfigurationData then
			if object.Has_Behavior(BEHAVIOR_HARD_POINT) then 
				object = object.Get_Highest_Level_Hard_Point_Parent()
			end
			if not TestValid(object) then return false end
			
			if WalkerConfigurationData.Parent == object then
				return false
			end
		else
			MessageBox("Customization mode is ON but WalkerConfigurationData is NIL????")
		end
	end
	
	return true
end

-- ------------------------------------------------------------------------------------------------------------------
-- Detach_Object - 
-- ------------------------------------------------------------------------------------------------------------------
function Detach_Object(object)
	
	-- Hide health bar
	if TestValid(object) and Can_Reset_Attached_UI_Display(object) == true then
		Show_Object_Attached_UI(object, false)
	end
	
	-- Remove this unit from selected objects list
	for i, obj in pairs(SelectedObjects) do
		if obj == object then
			table.remove(SelectedObjects, i)
			object.Unregister_Signal_Handler(On_Object_Removed_From_Selection_List)
			object.Unregister_Signal_Handler(On_Switch_Type)
			break
		end
	end

	if TestValid(object) then
		local type_name = object.Get_Type().Get_Name()
		if SelectedObjectsByType[type_name] then
			for i, data in pairs(SelectedObjectsByType[type_name]) do
				if data.Object == object then
					table.remove(SelectedObjectsByType[type_name], i)
					break
				end
			end
		end
	end
	
	-- Is it a constructor? if so, remove it from the (selected) constructor's list
	Remove_Constructor(object)
	Update_UI_After_Selection_Change()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Switch_Type - called when something changes types (for instance, alien tanks switch into flying tanks, and back)
-- ------------------------------------------------------------------------------------------------------------------
function On_Switch_Type(object)
	Selection_Changed()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Network_Build_Patch
-- ------------------------------------------------------------------------------------------------------------------
function Network_Build_Patch(event,source,player,object_type)
	if player ~= nil then
		local player_script = player.Get_Script()
		if player_script ~= nil then 
			player_script.Call_Function("Build_Patch", object_type)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- JLH 01-04-2007
-- This event reponse populates the achievement buff display window.
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Set_Achievement_Buff_Display_Model(event, source, constructed_model)

	-- JLH TEMP: Herb isn't able to check in the alien tactical bar yet, so the
	-- alien achievement HUD won't have the Achievement_HUD.
	if not TestValid(Scene.Achievement_HUD) then
		return
	end

	-- Merge the two models into the model for the HUD
	local player_names = constructed_model[1]
	local buff_lists = constructed_model[2]
	local model = {}

	for i = 1, table.getn(player_names) do
		local index = player_names[i]
		local value = buff_lists[i]
		model[player_names[i]] = buff_lists[i]
	end

	Scene.Achievement_HUD.Set_Model(model)
	AchievementBuffWindowHidden = true
	Scene.Achievement_HUD.Set_Hidden(AchievementBuffWindowHidden)

end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 01-05-2007
-- Toggles the visibility of the achievement buff window
-- ------------------------------------------------------------------------------------------------------------------
function On_Toggle_Achievement_Buff_Window()

	if not TestValid(Scene.Achievement_HUD) then
		return
	end

	if (AchievementBuffWindowHidden) then
		AchievementBuffWindowHidden = false
	else
		AchievementBuffWindowHidden = true
	end

	Scene.Achievement_HUD.Set_Hidden(AchievementBuffWindowHidden)

end

-- ------------------------------------------------------------------------------------------------------------------
-- 2/2/2007 2:18:49 PM -- BMH
-- Event response that gets fired when a harvester harvests a resource.
-- ------------------------------------------------------------------------------------------------------------------
function On_Resource_Harvested(event, source, object, harvester, units)

	local local_player = Find_Player('local')
	
	if harvester.Get_Owner() == local_player then
	    local particle = Create_Generic_Object(Find_Object_Type("Resource_Floaty"), harvester.Get_Position(), harvester.Get_Owner())
       local scene = particle.Get_GUI_Scenes()[1]
       scene.Text.Set_Text(Get_Localized_Formatted_Number(units))
	end
	
end	

-- ------------------------------------------------------------------------------------------------------------------
-- Subtitles_On_Speech_Event_Begin.
-- ------------------------------------------------------------------------------------------------------------------
function Subtitles_On_Speech_Event_Begin(_, _, _, _, text_id)
	--Use different text objects for full screen movies vs in-game speech
	local subtitle_object = nil
	if IsLetterboxMode or not this.FadeQuad.Get_Hidden() then
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

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Show_Sell_Button.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Show_Sell_Button()
	if TestValid(this.SellModeButton) then
		this.SellModeButton.Set_Hidden(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Sell_Button.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Hide_Sell_Button()
	if TestValid(this.SellModeButton) then
		this.SellModeButton.Set_Hidden(true)
	end	
end


-------------------------------------------------------------------------------
-- UI_Start_Flash_Superweapon
-------------------------------------------------------------------------------
function UI_Start_Flash_Superweapon(_, _, weapon_type_name)
	if SuperweaponButtons then
		for _, button in pairs(SuperweaponButtons) do
			if button.Get_User_Data() == weapon_type_name then
				Start_Flash(button)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- UI_Stop_Flash_Superweapon
-------------------------------------------------------------------------------
function UI_Stop_Flash_Superweapon(_, _, weapon_type_name)
	if SuperweaponButtons then
		for _, button in pairs(SuperweaponButtons) do
			if button.Get_User_Data() == weapon_type_name then
				Stop_Flash(button)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- UI_Start_Flash_Ability_Button
-------------------------------------------------------------------------------
function UI_Start_Flash_Ability_Button(_, _, ab_text_id)
	AbButtonsToFlash[ab_text_id] = true
	Update_Ability_Buttons_Flash_State()
end


-------------------------------------------------------------------------------
-- UI_Stop_Flash_Ability_Button
-------------------------------------------------------------------------------
function UI_Stop_Flash_Ability_Button(_, _, ab_text_id)

	if AbButtonsToFlash[ab_text_id] then
		AbButtonsToFlash[ab_text_id] = nil
		Update_Ability_Buttons_Flash_State()
	end
end


-------------------------------------------------------------------------------
-- Update_Ability_Buttons_Flash_State
-------------------------------------------------------------------------------
function Update_Ability_Buttons_Flash_State()

	for _, button in ipairs(SpecialAbilityButtons) do
		-- Since the ability buttons are un-hidden in order, we can safely break 
		-- when finding the first hidden button.
		if button.Get_Hidden() == true then break end
		
		local user_data = button.Get_User_Data()
		if (user_data ~= nil) then
			if AbButtonsToFlash[ab_text_id] and not button.Is_Flashing() then
				button.Start_Flash()
			elseif not AbButtonsToFlash[ab_text_id] and button.Is_Flashing() then
				button.Stop_Flash()
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- DEFCON:  Set_Enabled
-- ------------------------------------------------------------------------------------------------------------------
function DEFCON_Set_Enabled(_, _, value)

	if (value) then
		IsDEFCONMode = value
		if (not TestValid(this.DEFCON_Overlay)) then
			local handle = this.Create_Embedded_Scene("DEFCON_Overlay", "DEFCON_Overlay")
		else
			this.DEFCON_Overlay.Set_Hidden(false)
		end		
	else
	
		if (TestValid(Mainmenu.Game_Map_Loader)) then
			this.DEFCON_Overlay.Set_Hidden(true)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- DEFCON:  Set_Enabled
-- ------------------------------------------------------------------------------------------------------------------
function DEFCON_Set_Model(_, _, model)

	local map_model = {}
	map_model.DEFCONLevel = model[1]
	map_model.DEFCONCountdown = model[2]

   	if (TestValid(this.DEFCON_Overlay)) then
		this.DEFCON_Overlay.Set_Model(map_model)
	else
		MessageBox("ERROR: Attempt to set DEFCON overlay data model before DEFON overlay creation.")
	end

end

-- ------------------------------------------------------------------------------------------------------------------
--  On_Begin_Mouse_Button_Scroll
-- ------------------------------------------------------------------------------------------------------------------
function On_Begin_Mouse_Button_Scroll(_, _, anchor_x, anchor_y)
	this.ScrollAnchor.Set_Screen_Position(anchor_x, anchor_y)
	this.ScrollAnchor.Set_Hidden(false)
end


-- ------------------------------------------------------------------------------------------------------------------
--  On_End_Mouse_Button_Scroll
-- ------------------------------------------------------------------------------------------------------------------
function On_End_Mouse_Button_Scroll()
	this.ScrollAnchor.Set_Hidden(true)
end

function On_Network_Forfeit_Game(_, _, player)
	Get_Game_Mode_Script().Call_Function("Kill_All_Units_Of_Player", player)
end

-- ------------------------------------------------------------------------------------------------------------------
--  Disable_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_GUI_For_Replay()
	--this.Research_Tree.Enable(false)
	this.CommandBar.Enable(false)
	this.SellModeButton.Enable(false)
	this.Tactical_Queue_Manager.Enable(false)
	if Disable_Faction_GUI_For_Replay then
		Disable_Faction_GUI_For_Replay()
	end
end
