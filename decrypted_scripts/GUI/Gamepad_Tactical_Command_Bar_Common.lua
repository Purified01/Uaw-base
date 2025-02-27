if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[30] = true
LuaGlobalCommandLinks[201] = true
LuaGlobalCommandLinks[204] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[148] = true
LuaGlobalCommandLinks[1] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[119] = true
LuaGlobalCommandLinks[14] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[40] = true
LuaGlobalCommandLinks[123] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[195] = true
LuaGlobalCommandLinks[37] = true
LuaGlobalCommandLinks[156] = true
LuaGlobalCommandLinks[79] = true
LuaGlobalCommandLinks[124] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[132] = true
LuaGlobalCommandLinks[187] = true
LUA_PREP = true

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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Tactical_Command_Bar_Common.lua
--
--    Original Author: Maria_Teruel
--
--          DateTime: 2007/08/20
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("PGBase")
require("PGUICommands")
require("Mouse")
require("SpecialAbilities")
require("PGCommands")
require("PGHintSystem")
require("PGColors")
require("RetryMission")

-- Gamepad specific scripts.
-- ------------------------------------
require("Gamepad_HeroIcons")
require("Gamepad_Superweapons")
require("Gamepad_Contexts_Data")
require("PGPlayerProfile")

-- Maria 09.12.2007
-- In this file you will find all the accessors designers use to control the state of the UI from their mission scripts.
require("Gamepad_Design_UI_Control")


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
	
	TAB_ORDER_SELL_BUTTON = 1100
	
	TAB_ORDER_RESEARCH_TREE = 400
	TAB_ORDER_QUEUE_BUTTONS = 500	
	TAB_ORDER_FACTION_SPECIFIC_BUTTON = 600
	TAB_ORDER_SUPERWEAPON_BUTTONS =	700 
	TAB_ORDER_ABILITY_GROUPS = 800	
	
	TAB_ORDER_COMMAND_BAR = 850
	
	TAB_ORDER_BATTLE_CAM_BUTTON = 900
	
	TAB_ORDER_CONTROLLER_SINGLE_PRODUCTION_MENU = 1000
	


	TAB_ORDER_CONTROLLER_REINFORCEMENTS_MENU = 2000
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
	
	ShowSpecialAbilityButtons = false
	SelectedSpecialAbilities = { }
	
	PGPlayerProfile_Init()
	
	--init render modes
	PGColors_Init_Constants()	

	--init render modes
	PGColors_Init_Constants()

	--------------OLD GUI ELEMENTS THESE SHOULD BE REMOVED FROM THE BUI FILE ------
	if TestValid(this.CommandBar.BuildButtons) then
		this.CommandBar.BuildButtons.Set_Hidden(true)
	end	
	
	this.Register_Event_Handler("Local_Building_Force_Health_Display", nil, Building_Under_Half_Health)
	this.Register_Event_Handler("Local_Building_Force_Health_Hide", nil, Building_Over_Half_Health)
	this.Register_Event_Handler("Tooltip_Delay_Reload_Needed", nil, Reload_Tooltip_Delay)
	
	-- Register for hide notifications
	this.Register_Event_Handler("Component_Hidden", nil, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden", nil, Enable_UI_Element_Event)
	
	Register_Hidden_Events()
	
	this.Register_Event_Handler("Faction_Changed", nil, On_Player_Faction_Changed)	
	
	this.Register_Event_Handler("Activate_Special_Ability", nil, On_Unit_Special_Ability_Clicked)
	
	-- Get the VideoSettingsManager object - Oksana
	Register_Video_Commands()
	
	-- VERY IMPORTANT!!! we need to initialize the list of special abilities manually!.
	Initialize_Special_Abilities(true) -- false = do not initialize the key mapping data for the abilities (we don't need it if we are 
	-- using the gamepad!)

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
	SelectedBuildings =  { }
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
	MouseOverRootObject = nil
	MouseOverHoverTime = Get_Profile_Value(PP_TOOLTIP_HINT_DELAY, .5)
	MouseOverHoverTime_Extended = Get_Profile_Value(PP_TOOLTIP_EXPANDED_HINT_DELAY, 1)

--	MouseOverHoverTime = 0.2
	ConstructorTypeToFlash = {}
	
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
	
	-- Carousel menues
	CarouselBuildMenu = nil

	CommandBar = this.CommandBar.Carousel_CommandBar
	
	Init_Mouse_Buttons()
	
	QueueTypesToFlash = {}

	Set_Announcement_Text("")

	Tooltip = Scene.Tooltip
	this.Register_Event_Handler("Display_Tooltip", nil, On_Display_Tooltip)	

	this.Register_Event_Handler("End_Tooltip", nil, End_Tooltip)

	
	Init_Minor_Announcement_Text()
	
	-- Maria 07.06.2006
	-- Esc key should back out of all open HUD elements (socket schematic and purchase menus) before going to main menu
	Scene.Register_Event_Handler("Closing_All_Displays", nil, On_Closing_All_Displays)
  	Scene.Register_Event_Handler("Controller_B_Button_Up", nil, On_Controller_B_Button)
  	Scene.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Closing_All_Displays)
	
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
	SpecialAbilityButtons = {}
	SpecialAbilityButtons = Find_GUI_Components(Scene.CommandBar.Carousel_SpecialAbilityButtons, "SpecialAbilityButton")
	SAButtonIdxToOrigBoundsMap = {}
	for idx, button in pairs(SpecialAbilityButtons) do
		button.Set_Hidden(true)
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Unit_Special_Ability_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Unit_Special_Ability_Right_Clicked)
		-- button.Set_Tab_Order(TAB_ORDER_ABILITY_BUTTONS + idx)
		
		--SAButtonIdxToOrigBoundsMap[idx] = {}
		--SAButtonIdxToOrigBoundsMap[idx].x, SAButtonIdxToOrigBoundsMap[idx].y, SAButtonIdxToOrigBoundsMap[idx].w, SAButtonIdxToOrigBoundsMap[idx].h = button.Get_Bounds()	
	end
	
	SpecialAbilityCarousel = Scene.CommandBar.Carousel_SpecialAbilityButtons
	
	--Special ability carousel
	SpecialAbilityCarousel.Set_Tab_Order(TAB_ORDER_ABILITY_BUTTONS)
	
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
	
	ABILITIES_PER_ROW = 7
	
	Init_Hunt_And_Guard_Buttons()
	-- ******************	ABILITY BUTTONS SETUP	- END		**************************************************

	-- This is needed for the alien faction to determine whether to show/hide the reticles on a walker
	CustomizationModeOn = false
	
	-- Find all the build buttons (for constructing buildings)
	CarouselBuildMenu = Scene.CommandBar.CarouselButtons
	if TestValid(CarouselBuildMenu) then
		CarouselBuildMenu.Set_Tab_Order(TAB_ORDER_BUILDING_BUTTONS)
		BuildButtons = Find_GUI_Components(Scene.CommandBar.CarouselButtons, "Button")
	end
	
	for index, button in pairs(BuildButtons) do
		button.Set_Hidden(true)
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Build_Button_Click)
		--Scene.Register_Event_Handler("Carousel_Gain_Focus", button, On_Build_Button_Focus_Gained)
	end
	
	LastFocusedBuildButton = nil
	
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
	this.Register_Event_Handler("Animation_Finished", this.MinorAnnouncement.MoveText, Minor_Announcement_Anim_Finished)
	MinorAnnouncementQueue = {}
	
	Scene.Register_Event_Handler("Send_GUI_Network_Event", nil, On_Send_GUI_Network_Event)
	Scene.Register_Event_Handler("Network_Activate_Ability", nil, On_Network_Activate_Ability)
	Scene.Register_Event_Handler("Network_Deactivate_Ability", nil, On_Network_Deactivate_Ability)
	Scene.Register_Event_Handler("Network_Build_Hard_Point", nil, On_Network_Build_Hard_Point)
	Scene.Register_Event_Handler("Network_Cancel_Build_Hard_Point", nil, On_Network_Cancel_Build_Hard_Point)
	Scene.Register_Event_Handler("Networked_Mode_Switch", nil, On_Networked_Mode_Switch)
	Scene.Register_Event_Handler("Networked_Select_Next_Builder", nil, On_Networked_Select_Next_Builder)
	Scene.Register_Event_Handler("Network_Forfeit_Game", nil, On_Network_Forfeit_Game)
	
	Init_Queues_Interface()
	QueueButtons = Find_GUI_Components(Scene.CommandBar.Carousel_CommandBar, "QueueType")
	QueueButtonsByType = {}
	for index, button in pairs(QueueButtons) do 
		button.Set_User_Data(QueueTypes[index])
		QueueButtonsByType[QueueTypes[index]] = button
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Queue_Button_Clicked)
		
		-- tooltip data
		button.Set_Tooltip_Data({'ui', QueueTypeToTooltipDataMap[QueueTypes[index]]})
		
		-- tab order for hotkey navigation
--		button.Set_Tab_Order(index + TAB_ORDER_QUEUE_BUTTONS)
	end
	
	--QueueManager.Set_Tab_Order(TAB_ORDER_QUEUE_BUTTONS + #QueueButtons + 1)
	
	Update_Queue_Textures()

	-- MARIA 01.31.2007 - Disabling this as per assigned task.  I will keep it here though in case they want this enabled again.
	BuildModeOn = false
	
	--Hide letterbox quads by default	
	Scene.LetterboxTop.Set_Hidden(true)
	Scene.LetterboxBottom.Set_Hidden(true)
	
	Scene.Register_Event_Handler("Hard_Point_Detachment", nil, On_Hard_Point_Detachment)
	Scene.Register_Event_Handler("Hard_Point_Attachment", nil, On_Hard_Point_Attached)
	
	Scene.Register_Event_Handler("Update_Tree_Scenes", nil, On_Update_Tree_Scenes)
	Scene.Register_Event_Handler("Close_Research_Tree", nil, Hide_Research_Tree)
	
	-- functionality for designers
	Scene.Register_Event_Handler("Display_Build_Menu", nil, Display_Build_Menu)	
	
	-- Register the handler for the network event Start/Cancel Research here so that all players get it
	Scene.Register_Event_Handler("Network_Start_Research", nil, Network_Start_Research)
	Scene.Register_Event_Handler("Network_Cancel_Research", nil, Network_Cancel_Research)
	
	Update_Tree_Scenes(LocalPlayer, true)

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
	
	HardPointConfigurationMode = false	
	Scene.Register_Event_Handler("Network_Sell_Object", nil, On_Network_Sell_Object)
	
	-- When zooming the radar map in, we want all other capabilities of the command bar to be disabled.
	CommandBarEnabled = true
	
	--RADAR stuff
	RADAR_MAP_ANIMATION_LENGTH = 3.0/30.0 --[ 7 frames] - Maria 08.14.2007 AS PER TASK REQUEST, CHANGED THE ANIMATION LENGTH TO 4 FRAMES!.
	RADAR_MAP_ENLARGE_FACTOR = 2.25 -- enlarge the map by this much.
	
	-- this variables determine the position of the radar map on the screen 
	-- and are used to rsize the rada map and create its animations!!!!.
	TOP_RIGHT_RADAR_MAP = Declare_Enum(0)
	BOTTOM_RIGHT_RADAR_MAP = Declare_Enum()
	
	-- SET THIS VARIABLE TO LET CODE KNOW WHERE THE RADAR MAP IS LOCATED
	CURRENT_RADAR_MAP_POSITION = TOP_RIGHT_RADAR_MAP
	
	IsRadarOpen = false
	IsRadarAnimating = false
	RadarMap.Resume()
	
	if this.RadarTray then
		Scene.Register_Event_Handler("Animation_Finished", this.RadarTray, Unlock_Command_Bar)	
	end
	
	if this.RadarBackground then
		this.RadarBackground.Set_Hidden(true)
	end
	
	if this.RadarOverlay then
		this.RadarOverlay.Set_Hidden(true)
	end
	
	-- Moved to Update_Common_Scene - Oksana
	--Update_Radar_Map_Bounds()
	IsRadarInitialized = false
	
	-- Maria 04.13.2007 - CLICK/SELL functionality
	SellModeOn = false
	if TestValid(this.CommandBar.Carousel_CommandBar.SellModeButton) then
		SellButton = this.CommandBar.Carousel_CommandBar.SellModeButton
		SellButton.Set_Hidden(false)
		SellButton.Set_Texture("i_icon_sell.tga")
		this.Register_Event_Handler("Selectable_Icon_Clicked", SellButton, On_Toggle_Sell_Mode)
	
		-- tooltip data
		SellButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_SELL_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_TOGGLE_SELL_MODE", 1)}})
	end
	
	this.Register_Event_Handler("End_Sell_Mode", nil, On_End_Sell_Mode)
	
	if TestValid(this.Research_Tree) then 
		this.Research_Tree.Set_Hidden(true)
		this.Research_Tree.Set_Tab_Order(TAB_ORDER_RESEARCH_TREE)
	end
	
	FactionButtons = this.FactionButtons.Carousel
	
	this.FactionButtons.Carousel.Set_Tab_Order(TAB_ORDER_HERO_BUTTONS)
	
	Initialize_Reinforcements_UI()
	
	--Subtitling support
	this.Register_Event_Handler("Speech_Event_Begin", nil, Subtitles_On_Speech_Event_Begin)
	this.Register_Event_Handler("Speech_Event_Done", nil, Subtitles_On_Speech_Event_Done)
	
	-- DEFCON Multiplayer Mode Support
	this.Register_Event_Handler("DEFCON_Set_Enabled", nil, DEFCON_Set_Enabled)
	this.Register_Event_Handler("DEFCON_Set_Model", nil, DEFCON_Set_Model)
	
	--Scroll visualization support
	this.Register_Event_Handler("Begin_Mouse_Button_Scroll", nil, On_Begin_Mouse_Button_Scroll)
	this.Register_Event_Handler("End_Mouse_Button_Scroll", nil, On_End_Mouse_Button_Scroll)
	
	if TestValid(this.CommandBar.Carousel_CommandBar.BuilderButton) then
		BuilderButton = this.CommandBar.Carousel_CommandBar.BuilderButton
		BuilderButton.Set_Button_Enabled(false)
		this.Register_Event_Handler("Selectable_Icon_Clicked", BuilderButton, On_Builder_Button_Clicked)
		this.Register_Event_Handler("Selectable_Icon_Double_Clicked", BuilderButton, On_Builder_Button_Double_Clicked)
		
		-- Set the tab order so that we can come to this button while navigating the UI!
		-- BuilderButton.Set_Tab_Order(TAB_ORDER_QUEUE_BUTTONS)
		Init_Idle_Builder_Textures()
		
		-- tooltip data
		BuilderButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_IDLE_BUILDER_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_FIND_BUILDER", 1)}})
		
		-- Set the proper texture for this button!.
		BuilderButton.Set_Texture(PlayerToIdleBuilderTexturesMap[LocalPlayer.Get_Faction_Name()])
	end	
	
	Gamepad_Init_Control_Groups_UI()
	
	this.Focus_First()
	
	-- EMP 7/6/07
 	-- Set up text pre-rendering 
 	Scene.MaterialsText.Set_PreRender(true)
 	Scene.PopText.Set_PreRender(true)

	-- Maria 07.19.2007: The Hierarchy needs to keep track of the walker pop cap (which is independent from the regular units pop cap)
	if TestValid(this.WalkerPopText) then
 		this.WalkerPopText.Set_Hidden(not DisplayCreditsPop)
	end

	Initialize_Credits_Popcap_Tooltip_Data()	
	
	-- Initialize the UI components specific to the controller's tactical UI.
	-- Controller specific UI
	if TestValid(this.RadarZoomButton) then
		this.RadarZoomButton.Set_Hidden(false)
	end
	
	if TestValid(this.RadarZoomButtonContext) then
		this.RadarZoomButtonContext.Set_Hidden(false)
	end
	
	this.Register_Event_Handler("Controller_Display_Selection_UI", nil, On_Controller_Display_Selection_UI)
	this.Register_Event_Handler("Controller_Display_Command_Bar", nil, On_Controller_Display_Command_Bar)
	
	if TestValid(this.CommandBar.Carousel_CommandBar.BattleCam) then
		Init_Battle_Cam_Button()
	end
	
	this.Register_Event_Handler("Controller_Display_Research_And_Faction_UI", nil, On_Controller_Display_Research_And_Faction_UI)
	-- Maria 08.07.2007: needed for the XBOX so that we don't display the floating tooltip!
	this.Register_Event_Handler("Controller_Display_Tooltip_From_UI", nil, On_Controller_Display_Tooltip_From_UI)	
	
	ShowContextDisplay = true
	-- -----------------------------------------------------------------
	LastSelectedBuilder = nil
	LastSelectedBuilderTime = nil
	LAST_SELECTED_BUILDER_RESET_DELAY = 4.0
	-- -----------------------------------------------------------------
	Init_Gamepad_Contexts_Data()
	Update_Controller_Display(false)
	
	-- Register all the handlers designers need to be able to control the state of the UI from the mission scripts.
	Register_UI_Control_Handlers()
	
	-- Hide carousels
	this.CommandBar.CarouselButtons.Set_Hidden(true)
	this.CommandBar.Carousel_CommandBar.Set_Hidden(true)
	this.CommandBar.Carousel_BuildQueue.Set_Hidden(true)
	this.CommandBar.Carousel_SpecialAbilityButtons.Set_Hidden(true)
	this.Carousel_ControlGroups.Set_Hidden(true)
	
	if TestValid(this.CommandBar.Carousel_CommandBar) then
		Init_Carousel_Command_Bar()
	end
	
	this.Register_Event_Handler("Show_Game_End_Screen", nil, Show_Game_End_Screen)	
	this.Register_Event_Handler("Objectives_Changed", nil, On_Objectives_Changed)
	this.Register_Event_Handler("Suspend_Objectives", nil, On_Suspend_Objectives)	
	this.Register_Event_Handler("Show_Retry_Mission_Screen", nil, Show_Retry_Mission_Screen)
	
	-- TEMP TILL ART FIL
	if TestValid(this.Single_Production_Menu) then
		this.Single_Production_Menu.Set_Hidden(true)
	end
	
	this.Register_Event_Handler("Controller_Set_Game_Paused", nil, On_Controller_Set_Game_Paused)	
	
	-- Maria 01.17.2008
	-- We use will finish initializing the UI when we get our first service.  We do it then because if we did it know
	-- we may not be getting all the proper information.  Indeed, menus like the reinforements and the tactical queues
	-- are intialized based on existing structures and at this time those structures may not have been placed on the 
	-- map which would cause the menus to have missing information.
	FirstService = true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Hunt_And_Guard_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Init_Hunt_And_Guard_Buttons()
	
	-- HUNT MODE
	-- ---------------------------------------------------------------------------------------------------------------------------------
	FactionToHuntTexturesMap = {}
	FactionToHuntTexturesMap["ALIEN"] = {}
	FactionToHuntTexturesMap["ALIEN"][true] = "i_icon_a_sa_patrol_on.tga"
	FactionToHuntTexturesMap["ALIEN"][false] = "i_icon_a_sa_patrol_off.tga" 
	
	FactionToHuntTexturesMap["NOVUS"] = {}
	FactionToHuntTexturesMap["NOVUS"][true] = "i_icon_n_sa_patrol_on.tga"
	FactionToHuntTexturesMap["NOVUS"][false] = "i_icon_n_sa_patrol_off.tga" 
	
	FactionToHuntTexturesMap["MASARI"] = {}
	FactionToHuntTexturesMap["MASARI"][true] = "i_icon_m_sa_patrol_on.tga"
	FactionToHuntTexturesMap["MASARI"][false] = "i_icon_m_sa_patrol_off.tga" 
	
	HuntModeOn = false
	HuntModeStateToTooltipDataMap = {}
	HuntModeStateToTooltipDataMap[true] = {'ui', {"TEXT_GAMEPAD_ABILITY_PATROL_ON", false, "TEXT_GAMEPAD_TOOLTIP_DESCRIPTION_ABILITY_PATROL_ON"}}
	HuntModeStateToTooltipDataMap[false] = {'ui', {"TEXT_GAMEPAD_ABILITY_PATROL_OFF", false, "TEXT_GAMEPAD_TOOLTIP_DESCRIPTION_ABILITY_PATROL_OFF"}}

	if TestValid(this.CommandBar.Carousel_SpecialAbilityButtons.HuntButton) then
		HuntButton = this.CommandBar.Carousel_SpecialAbilityButtons.HuntButton
		HuntButton.Set_Hidden(true)		
		this.Register_Event_Handler("Selectable_Icon_Clicked", HuntButton, On_Hunt_Button_Clicked)
	end

	-- Have to do this every time, not just if we have a hunt button.
	this.Register_Event_Handler("Network_Toggle_Hunt_Mode", nil, On_Network_Toggle_Hunt_Mode)
	-- ---------------------------------------------------------------------------------------------------------------------------------
	
	-- GUARD FUNCTIONALITY
	-- ---------------------------------------------------------------------------------------------------------------------------------
	FactionToGuardTexturesMap = {}
	FactionToGuardTexturesMap["ALIEN"] = "i_icon_a_sa_gaurd.tga"
	FactionToGuardTexturesMap["NOVUS"] = "i_icon_n_sa_gaurd.tga"
	FactionToGuardTexturesMap["MASARI"] = "i_icon_m_sa_gaurd.tga"
	-- There's no specific texture for the military for now so I'm using the one for the masari.
	FactionToGuardTexturesMap["MILITARY"] = "i_icon_m_sa_gaurd.tga"
	
	if TestValid(this.CommandBar.Carousel_SpecialAbilityButtons.GuardButton) then
		GuardButton = this.CommandBar.Carousel_SpecialAbilityButtons.GuardButton
		GuardButton.Set_Hidden(true)
		-- TODO
		GuardButton.Set_Texture(FactionToGuardTexturesMap[LocalPlayer.Get_Faction_Name()])
		GuardButton.Set_Tooltip_Data({'ui', {"TEXT_GAMEPAD_ABILITY_GUARD", false, "TEXT_GAMEPAD_TOOLTIP_DESCRIPTION_ABILITY_GUARD"}})
		this.Register_Event_Handler("Selectable_Icon_Clicked", GuardButton, On_Guard_Button_Clicked)
	end	
	-- ---------------------------------------------------------------------------------------------------------------------------------
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Guard_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Guard_Button_Clicked(_, _)
	-- Tell code that we are targeting while in guard mode.
	Activate_Guard_Mode()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Hunt_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Hunt_Button_Clicked(_, _)
	-- Toggle the hunt mode for the selected units.
	Send_GUI_Network_Event("Network_Toggle_Hunt_Mode", { Find_Player("local") })	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Network_Toggle_Hunt_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_Network_Toggle_Hunt_Mode(_, _, player)
	Toggle_Hunt_Mode(player)
	if player == Find_Player("local") then
		Update_Hunt_Button()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Hunt_Mode_Texture_And_Tooltip_Data
-- ------------------------------------------------------------------------------------------------------------------
function Get_Hunt_Mode_Texture_And_Tooltip_Data()
	local texture = "W_Generic_White.tga"
	if LocalPlayer then
		texture = FactionToHuntTexturesMap[LocalPlayer.Get_Faction_Name()][HuntModeOn]
	end
	
	return texture, HuntModeStateToTooltipDataMap[HuntModeOn]
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Set_Game_Paused
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Set_Game_Paused(_, _, paused_resumed)
	if TestValid(this.GamepadContextDisplay) then
		if paused_resumed then
			this.GamepadContextDisplay.Set_Hidden(true)
			End_Tooltip()
		elseif ShowContextDisplay then
			this.GamepadContextDisplay.Set_Hidden(false)
			Controller_Update_Context()
		end		
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Reinforcements_UI
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Reinforcements_UI()
	
	-- Button that yields access to the reinforcements menu.
	if TestValid(FactionButtons.ReinforcementsMenuButton) then 
		ReinforcementsMenuButton = FactionButtons.ReinforcementsMenuButton
		ReinforcementsMenuButton.Set_Texture("i_icon_reinforcements.tga")
		ReinforcementsMenuButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_REINFORCEMENTS_MENU", false, "TEXT_UI_TACTICAL_REINFORCEMENTS_MENU_DESCRIPTION"}})	
		this.Register_Event_Handler("Selectable_Icon_Clicked", ReinforcementsMenuButton, Toggle_Reinforcements_Menu)
		ReinforcementsMenuButton.Set_Hidden(true)
	end
	
	-- Maria 08.30.2006	- Reinforcements menu manager!
	if TestValid(this.ReinforcementsMenu) then 
		ReinforcementsMenuManager = this.ReinforcementsMenu
		ReinforcementsMenuManager.Set_Tab_Order(TAB_ORDER_CONTROLLER_REINFORCEMENTS_MENU)
		ReinforcementsMenuManager.Set_Hidden(true)
		-- Make sure the menu starts off closed.
		ReinforcementsMenuManager.Close()
	end
	
	this.Register_Event_Handler("Network_Get_Reinforcements", nil, On_Network_Get_Reinforcements)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Reinforcements_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Reinforcements_Menu(_, _)
	if not TestValid(ReinforcementsMenuManager) then 
		return
	end
	
	if not ReinforcementsMenuManager.Conditional_Show() then 
		-- there has been a mistake and there are no reinforcements, shut the menu down
		-- and hide the toggle button
		ReinforcementsMenuButton.Set_Hidden(true)
		ReinforcementsMenuManager.Close()
		return
	end
	
	local is_open = ReinforcementsMenuManager.Toggle_Menu_Display()
	if is_open then 
		-- disable the carousel
		if TestValid(FactionButtons) then
			FactionButtons.Enable(false)
		end
	end
end

-- ---------------------------------------------------------------------------------------------
-- On_Network_Get_Reinforcements
-- ---------------------------------------------------------------------------------------------
function On_Network_Get_Reinforcements(_, _, player, cost, object, enabler)

	local success = false
	if cost then
		local player_cash = player.Get_Credits()
		if player_cash < cost then
			Play_SFX_Event("GUI_Generic_Bad_Sound")
			return
		end
	end

	if not TestValid(object) then 
		Play_SFX_Event("GUI_Generic_Bad_Sound")
		return
	end
	
	if object.Get_Type().Is_Hero() then
		success = object.Get_Parent_Object().Request_Strike_Force_Reinforcement()
	elseif TestValid(enabler) then 
		
		if enabler.Get_Are_Reinforcements_In_Transit(object) then
			success = enabler.Tactical_Enabler_Deploy_Ready_Reinforcements_From(object)
		else
			success = enabler.Tactical_Enabler_Begin_Reinforcement(object, LocalPlayer)
		end
	end
	
	if success then
		player.Add_Credits(-cost)
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound")
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Credits_Popcap_Tooltip_Data
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Credits_Popcap_Tooltip_Data()

	-- Called when a masari light sw is created
	Scene.Register_Event_Handler("Network_Select_Super_Weapon", nil, Select_Super_Weapon)
	
	if TestValid(this.MPBeaconContext) then 
		MPBeaconContext = this.MPBeaconContext
		MPBeaconContext.Set_Hidden(true)
	end	
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
--  Gamepad_Init_Control_Groups_UI
-- ------------------------------------------------------------------------------------------------------------------
function Gamepad_Init_Control_Groups_UI()
	
--	if not TestValid(this.CommandBar.Gamepad_Control_Groups) then
--		this.CommandBar.Create_Embedded_Scene("Gamepad_Control_Groups", "Gamepad_Control_Groups")		
--	end

	this.Register_Event_Handler("Control_Group_Icon_Source_List", nil, On_Control_Group_Icon_Source_List)
	this.Register_Event_Handler("Set_Control_Group_GUI_Visible", nil, On_Set_Control_Group_GUI_Visible)
	this.Register_Event_Handler("Select_Control_Group", nil, On_Control_Group_Selected)
	this.Register_Event_Handler("Control_Group_Data", nil, On_Control_Group_Data)
end

-- -----------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Icon_Source_List
-- ------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Icon_Source_List(event, source, icon_list)
	this.Carousel_ControlGroups.Set_Quad_Texture_Source(icon_list)
end


-- -----------------------------------------------------------------------------------------------------------------
-- On_Set_Control_Group_GUI_Visible
-- ------------------------------------------------------------------------------------------------------------------
function On_Set_Control_Group_GUI_Visible(event, source, visible)
	if visible and Is_Controller_Displaying_UI() then
		-- there's some other UI up, so we cannot display a new one!.
		return 
	end
	

	this.Carousel_ControlGroups.Enable(true)
	this.Carousel_ControlGroups.Set_Visible(visible)
	
	ControllerDisplayingControlGroupsUI = visible
	
	-- if we are displaying the control groups UI then let's hide the Context display.
	if not visible and ShowContextDisplay and not IsLetterboxMode and not Is_Controller_Displaying_UI() then 
		this.GamepadContextDisplay.Set_Hidden(false)
	else
		this.GamepadContextDisplay.Set_Hidden(true)
	end
	
	UpdateFocusOnNextService = true
end

-- -----------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Selected
-- ------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Selected(_, _, index, selected, unit_count)
	this.Carousel_ControlGroups.On_Control_Group_Selected(index, selected, unit_count)
end

-- -----------------------------------------------------------------------------------------------------------------
-- On_Control_Group_Selected
-- ------------------------------------------------------------------------------------------------------------------
function On_Control_Group_Data(_, _, cg_size_table, cg_units_selected_table)
	local display_cg_context = this.Carousel_ControlGroups.Set_Control_Group_Data(cg_size_table, cg_units_selected_table)

	-- if there's at least one control group we should display the control group context
	if ShowContextDisplay then
		if display_cg_context then
			-- Are there any control groups to display?
			if GamepadCurrentContexts and not GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_CONTROL_GROUPS].Trigger] then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_CONTROL_GROUPS].Trigger] = GAMEPAD_CONTEXT_CONTROL_GROUPS
				this.GamepadContextDisplay.Update_Context_Display(GamepadCurrentContexts)
			end		
		end
		
		DisplayCGContext = display_cg_context
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Update_Context
-- First determine what the current context is and then update the display!.
-- RECALL: the Research and Customization context is always UP (unless the Research button is hidden 
-- from script)
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Update_Context()
	
	if not TestValid(this.GamepadContextDisplay) then
		return
	end
	
	-- Maria 11.26.2007
	-- Moving below to make sure we update the ShowSpecialAbilityButtons before quitting this function!!!.  In fact, designers may want the context 
	-- display not to show.  However, we still need to update the ShowSpecialAbilityButtons
	-- otherwise, we won't be able to access the Special Abilities UI whenever ShowContextDisplay == false!.
	-- if not ShowContextDisplay then 
	--	this.GamepadContextDisplay.Set_Hidden(true)
	--	return 
	-- end
	
	-- Reset all contexts.
	GamepadCurrentContexts = {}
	ShowSpecialAbilityButtons = false
	
	local should_display_abilities = Controller_Should_Display_Selection_UI()
	
	if TestValid(SelectedBuildings[1]) then
		local bldg_qtype = SelectedBuildings[1].Get_Type().Get_Building_Queue_Type()
		local bldq_qtype_value = QueueTypeStrgToEnumValue[bldg_qtype]
		
		if ShowContextDisplay and bldq_qtype_value == QueueTypeStrgToEnumValue['NonProduction'] then
			if (#SelectedBuildings == 1) then -- only show the upgrades/abilities menu for non production buildings if there's only one selected.
				if should_display_abilities then
					GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_UPGRADE_SELL_AND_ABILITIES].Trigger] = GAMEPAD_CONTEXT_UPGRADE_SELL_AND_ABILITIES
				else 
					GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_UPGRADE_AND_SELL].Trigger] = GAMEPAD_CONTEXT_UPGRADE_AND_SELL
				end			
			end
		elseif ShowContextDisplay and bldq_qtype_value then -- it has some kind of queu type!
			-- are there any abilities up?
			if should_display_abilities then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_PRODUCTION_AND_ABILITIES].Trigger] = GAMEPAD_CONTEXT_PRODUCTION_AND_ABILITIES
			else
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_PRODUCTION].Trigger] = GAMEPAD_CONTEXT_PRODUCTION
			end				
		else -- it is a building with no queue type, so it may be considered as a unit
			if should_display_abilities then 
				if ShowContextDisplay then 
					GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_SPECIAL_ABILITIES].Trigger] = GAMEPAD_CONTEXT_SPECIAL_ABILITIES
				end
				
				ShowSpecialAbilityButtons = true -- only show special abilities in gamepad if it is the ONLY thing on the context button
			end
		end						
	else
		if should_display_abilities then 
			
			if ShowContextDisplay and BuilderMenuOpen then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_BUILD_MODE].Trigger] = GAMEPAD_CONTEXT_BUILD_MODE
			else
				if ShowContextDisplay then 
					GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_SPECIAL_ABILITIES].Trigger] = GAMEPAD_CONTEXT_SPECIAL_ABILITIES
				end
				
				ShowSpecialAbilityButtons = true 
			end
		else
			-- if there are any objects selected and cannot display abilities, we should not display the command bar context because it is not right.
			-- If the selected units have no abilities, the trigger should display NOTHING!.
			if ShowContextDisplay and not ForceHideCommandBar and (not selectedObjects or #selectedObjects <= 0) then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_COMMAND].Trigger] = GAMEPAD_CONTEXT_COMMAND
			end
		end		
	end
	
	-- Maria 11.26.2007: Now that we have updated the proper values, we need not proceed if we are not displaying the context data.
	if not ShowContextDisplay then 
		this.GamepadContextDisplay.Set_Hidden(true)
		return 
	end
	
	-- since we are clearing the GamepadCurrentContexts table we need to check for specific cases all the same.
	if Update_HP_Sub_Selection_Context_Display then
		if Controller_Get_Can_Activate_HP_Sub_Selection_Mode() then
			if HPSubSelectCategory == INVALID_HARD_POINT then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER].Trigger] = GAMEPAD_CUSTOMIZE_WALKER
			elseif HPSubSelectCategory == BODY_HARD_POINT then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER_UP].Trigger] = GAMEPAD_CUSTOMIZE_WALKER_UP
			elseif HPSubSelectCategory == LEG_HARD_POINT then
				GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER_DOWN].Trigger] = GAMEPAD_CUSTOMIZE_WALKER_DOWN
			end	
			CanActivateHPSubSelection = true
		else
			CanActivateHPSubSelection = false
		end		
	end
	
	if Can_Access_Research() then 
		GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_RESEARCH_AND_CUSTOMIZATION].Trigger] = GAMEPAD_CONTEXT_RESEARCH_AND_CUSTOMIZATION
	end
	
	if DisplayCGContext then
		GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_CONTROL_GROUPS].Trigger] = GAMEPAD_CONTEXT_CONTROL_GROUPS
	end
	
	-- For now, the right trigger and right bumper are always assigned to the same contexts and they are not determined dynamically.
	if ShowRadarMap then
		GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_RADAR_MAP].Trigger] = GAMEPAD_CONTEXT_RADAR_MAP
	end
	
	if SellModeOn then 
		GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_SELL_MODE].Trigger] = GAMEPAD_CONTEXT_SELL_MODE		
	elseif InHPSubSelectionMode then 
		GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_EXIT_WALKER_CUSTOMIZATION_MODE].Trigger] = GAMEPAD_CONTEXT_EXIT_WALKER_CUSTOMIZATION_MODE
	elseif selectedObjects and #selectedObjects > 0 then
		GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CONTEXT_DROP_SELECTION].Trigger] = GAMEPAD_CONTEXT_DROP_SELECTION	
	end
	
	this.GamepadContextDisplay.Update_Context_Display(GamepadCurrentContexts)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Gamepad_Point_Camera_At_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Gamepad_Point_Camera_At_Next_Builder()
	-- this check is needed since we may be trying to select a builder via a hot key!
	if not TestValid(BuilderButton) or BuilderButton.Get_Hidden() == true or (not BuilderButton.Is_Button_Enabled())  then 
		-- no builders to select!
		return
	end
	
	local player = Find_Player("local")
	if player then
		local script = player.Get_Script()
		if script then
			local builder = script.Get_Async_Data("SelectedBuilder")
			if TestValid(builder) then
				if LastSelectedBuilder ~= builder then
					Point_Camera_At(builder)
					LastSelectedBuilder = builder
					LastSelectedBuilderTime = GetCurrentTime()
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Command_Bar -- Maria: it would be 1,000 times easier to have all these components
-- as part of the same scriptable but that would break the current setup of the command bar for the PC 
-- version.  If we ever come up with a Tactical command specially designed for the 360 then we should
-- definitely consider that!.
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Command_Bar(_, _, on_off)
	Controller_Display_Command_Bar(on_off)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Command_Bar
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Command_Bar(on_off)
	
	if  on_off and Is_Controller_Displaying_UI() then
		-- there's some other UI up, so we cannot display a new one!.
		Controller_Display_Command_Bar(false)
		return 
	end
	
	local hide = not on_off
	-- Maria 08.08.2007
	-- If we are hiding, let's clear the focus now so that all components receive the clear focus order
	-- in a state in which they can process it (that is, before they get disabled and cannot handle the event)
	if hide then 
		Clear_Key_Focus()
	end
	
	if not hide then 
		-- Also, end whatever the current tooltip is if we are not in the Display Selection mode.
		if not ControllerDisplayingSelectionUI then
			End_Tooltip()
		end
	else
		if ControllerDisplayingSelectionUI then 	
			-- close it too!.
			Controller_Display_Selection_UI(on_off)
		end
	end
	
	
	local show_all_command_bar = not ControllerDisplayingSelectionUI
	if not hide then
		if SelectedBuildings[1] then
			-- there's a building selected. If it is a production 
			-- building, then just show the build queue (but not the rest of the command bar)
			local bldg_qtype = SelectedBuildings[1].Get_Type().Get_Building_Queue_Type()
			local bldq_qtype_value = QueueTypeStrgToEnumValue[bldg_qtype]
			-- If we have a building with a valid queue type, let's show the single produciton 
			-- menu!.
			
			-- Maria 01.12.2008
			-- If we have multiple Nonproduction buildings selected (eg. turrets) then we don't display the tactical queue but just go ahead and display the regular
			-- command bar.
			if (#SelectedBuildings <= 1 or bldq_qtype_value ~= QueueTypeStrgToEnumValue['NonProduction']) then 
				show_all_command_bar = false
				
				if TestValid(QueueManager) then 
					-- We want to display the special upgrades menu for this type of structures!.
					QueueManager.Open(bldg_qtype, SelectedBuildings, Get_Unit_Special_Abilities(SelectedBuildings, true, false))
				end
			else
				if TestValid(QueueManager) and QueueManager.Is_Open() then
					QueueManager.Close()
				end
				
				-- there's nothing to display so let's get out!
				-- Before let code know that nothing is displaying
				Controller_Set_Display_Command_Bar_UI(false)
				return
			end
		end
	else
		if TestValid(QueueManager) and QueueManager.Is_Open() then
			QueueManager.Close()
		end
	end
	
	-- We may need to preempt this call.
	if not hide and show_all_command_bar and ForceHideCommandBar then
		if TestValid(CommandBar) then
			CommandBar.Set_Hidden(true)
		end
		
		if TestValid(QueueManager) and hide then
			QueueManager.Close()
		end
		
		ControllerDisplayingCommandBar = false
		ControllerDisplayingSingleProductionMenu = false

		-- Let code know that nothing is displaying
		Controller_Set_Display_Command_Bar_UI(false)
		
		-- nothing to do
		return
	end
	
	if hide or show_all_command_bar then 
		
		if TestValid(CommandBar) then
			CommandBar.Set_Hidden(hide)
		end
		
		if TestValid(QueueManager) and hide then
			QueueManager.Close()
		end
		
		if TestValid(SellButton) then 
			if not ForceHideSellButton and not hide then
				SellButton.Set_Hidden(false)
			end
		end	
	end
	
	if not hide then
		if show_all_command_bar then 
			ControllerDisplayingCommandBar = true
			ControllerDisplayingSingleProductionMenu = false
		else
			ControllerDisplayingCommandBar = false
			ControllerDisplayingSingleProductionMenu = true
		end
	else
		ControllerDisplayingCommandBar = false
		ControllerDisplayingSingleProductionMenu = false
	end
	
	Controller_Set_Display_Command_Bar_UI(ControllerDisplayingCommandBar or ControllerDisplayingSingleProductionMenu)
	
	if hide then
		UpdateFocusOnNextService = false
		BuildModeOn = false
		-- Make sure the context display has not been hidden from script!.
		if ShowContextDisplay and not IsLetterboxMode and not Is_Controller_Displaying_UI() then
			this.GamepadContextDisplay.Set_Hidden(false)
		end
	else
		UpdateFocusOnNextService = true		
		-- Hide the context display!
		if TestValid(this.GamepadContextDisplay)then
			this.GamepadContextDisplay.Set_Hidden(true)
		end
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Research_And_Faction_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Research_And_Faction_UI(_, _, on_off)
	Controller_Display_Research_And_Faction_UI(on_off)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Research_And_Faction_UI
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Research_And_Faction_UI(on_off, force_update)
	
	if on_off and Is_Controller_Displaying_UI() then
		-- there's some other UI up, so we cannot display a new one!.
		Controller_Set_Display_Research_And_Faction_UI(false)
		return 
	end
	
	if ControllerDisplayingResearchAndFactionUI == on_off and not force_update then
		return
	end
	
	if not TestValid(FactionButtons) then
		Controller_Set_Display_Research_And_Faction_UI(false)
		return
	end
	
	-- show the Research tree button and the faction specific buttons if they exist!.
	local hide = not on_off
	
	local requires_faction_display = false
	-- Update the display state of the research tree button
	if TestValid(FactionButtons.ResearchButton) then 
		if not Can_Access_Research() then
			FactionButtons.ResearchButton.Set_Hidden(true)			
		else
			FactionButtons.ResearchButton.Set_Hidden(false)
			requires_faction_display = true
		end
	end

	-- Update the display of the Reinforcements menu button
	if TestValid(ReinforcementsMenuButton) and TestValid(ReinforcementsMenuManager) then 
		if ReinforcementsMenuManager.Conditional_Show() then 
			ReinforcementsMenuButton.Set_Hidden(false)
			requires_faction_display = true
		else
			ReinforcementsMenuButton.Set_Hidden(true)			
		end
	end
	
	-- does it have any SW's?
	if not requires_faction_display and SuperweaponButtons and #SuperweaponButtons > 0 then
		requires_faction_display = (not SuperweaponButtons[1].Get_Hidden())
	end
	
	if not requires_faction_display and not hide then
		-- Abort, there's nothing to display.
		Controller_Set_Display_Research_And_Faction_UI(false)
		return
	end
	
	FactionButtons.Enable(on_off)
	FactionButtons.Set_Hidden(hide)
	ControllerDisplayingResearchAndFactionUI = on_off
	
	-- let code know that we have handled this event by updating the proper flags states.
	Controller_Set_Display_Research_And_Faction_UI(ControllerDisplayingResearchAndFactionUI)
	
	if hide then	
		UpdateFocusOnNextService = false		
		-- make sure we close the research tree!!!!
		Hide_Research_Tree()		
		
		if Hide_Patch_Menu then 
			Hide_Patch_Menu()
		end
		
		-- make sure the context display has not been hidden from script.
		if ShowContextDisplay and not IsLetterboxMode and not Is_Controller_Displaying_UI() then 
			this.GamepadContextDisplay.Set_Hidden(false)
		end
		
		if TestValid(ReinforcementsMenuManager) then 
			ReinforcementsMenuManager.Close()
		end
	else
		UpdateFocusOnNextService = true
		this.GamepadContextDisplay.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Controller_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Controller_Display(on_off)
	Controller_Display_Selection_UI(on_off)
	Controller_Display_Command_Bar(on_off)
	Controller_Display_Research_And_Faction_UI(on_off)
end
	

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Controller_Displaying_UI
-- ------------------------------------------------------------------------------------------------------------------
function Is_Controller_Displaying_UI()
	return (	
			ControllerDisplayingResearchAndFactionUI or 
			ControllerDisplayingCommandBar or 
			ControllerDisplayingSelectionUI or
			ControllerDisplayingSingleProductionMenu or
			ControllerDisplayingControlGroupsUI
		)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Selection_UI(event, source, on_off)
	Controller_Display_Selection_UI(on_off)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Should_Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Should_Display_Selection_UI()
	-- if there's not one ability button showing, turn this mode off!.
	local ab_button = SpecialAbilityButtons[1]
	if TestValid(ab_button) and ab_button.Get_Hidden() then
		-- Force this to be hidden since there's nothing to display!.
		-- If we don't do that, the controls to navigate the map will remain locked until the 
		-- user toggles the menu off and on again!.  So, to avoid confusion we force the
		-- mode to be off if there's nothing to display.
		
		if BuilderMenuOpen then 
			return true
		end
		
		if TestValid(GuardButton) and not GuardButton.Get_Hidden() then
			return true
		end
		
		if TestValid(HuntButton) and not HuntButton.Get_Hidden() then
			return true
		end
		
		return false	
	end
	
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Selection_UI
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Selection_UI(on_off)
	
	if on_off and Is_Controller_Displaying_UI() then
		-- there's some other UI up, so we cannot display a new one!.
		return 
	end
	
	if ControllerDisplayingSelectionUI == on_off then
		return
	end
	
	local hide = not on_off
	
	if not hide then
		if not Controller_Should_Display_Selection_UI() then 
			Controller_Set_Display_Unit_GUI_Menu_Display(false)
			-- Nothing to show so get out.
			return
		elseif not ControllerDisplayingCommandBar then
			-- Also, end whatever the current tooltip is if we are not in the Display Command bar mode.
			End_Tooltip()
		end			
	else
		-- Maria 08.08.2007
		-- If we are hiding, let's clear the focus now so that all components receive the clear focus order
		-- in a state in which they can process it (that is, before they get disabled and cannot handle the event)
		Clear_Key_Focus()
	end
	
	if TestValid(SpecialAbilityCarousel) and ShowSpecialAbilityButtons then
		if not hide and SpecialAbilityCarousel.Get_Active_Child_Count() > 0 then
			SpecialAbilityCarousel.Set_Hidden(false)
		else
			SpecialAbilityCarousel.Set_Hidden(true)
		end
	end
	
	if TestValid(CarouselBuildMenu) and CarouselBuildMenu.Get_Active_Child_Count() > 0 then
		if not hide or not ControllerDisplayingCommandBar then 
			CarouselBuildMenu.Set_Hidden(hide)
		end	
	end
	
	ControllerDisplayingSelectionUI = on_off
	-- Let code know that we have succeeded.
	Controller_Set_Display_Unit_GUI_Menu_Display(ControllerDisplayingSelectionUI)

	if not hide then
		UpdateFocusOnNextService = true
		if TestValid(this.GamepadContextDisplay)then
			this.GamepadContextDisplay.Set_Hidden(true)
		end
	else 
		UpdateFocusOnNextService = false
		-- make sure the context display has not been hidden from script.
		if ShowContextDisplay and not IsLetterboxMode and not Is_Controller_Displaying_UI() then 
			if TestValid(this.GamepadContextDisplay)then
				this.GamepadContextDisplay.Set_Hidden(false)
			end
		end
	end

end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Controller_Display_Tooltip_From_UI
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Controller_Display_Tooltip_From_UI(_, _, tooltip_data)
	Display_Tooltip(tooltip_data, true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Selection_Changed : this function handles the updating of the UI when selection changes when
-- the controller is connected.
-- ------------------------------------------------------------------------------------------------------------------
function Selection_Changed(update_focus)
	-- Also in case faction changed.
	QueueManager.Find_Tactical_Enablers()
	
	-- Hide health bar for old selected objects.
	for index, object in pairs(SelectedObjects) do
		if TestValid(object) then
			if not InHPSubSelectionMode or ParentObjectForHardPointSubSelection ~= object then
				Show_Object_Attached_UI(object, false)
			end
			
			object.Unregister_Signal_Handler(On_Object_Removed_From_Selection_List, this)
			object.Unregister_Signal_Handler(On_Switch_Type, this)
		end
	end
	
	UpdateFocus = update_focus
	SelectedBuildings = { }
	BuildersAreSelected = false
	CurrentConstructorsList = {}
	SelectedObjectsByType = {}
	SelectedObjects = {}
	selectedObjects = Get_Selected_Objects()
	CurrentSelectionNumTypes = 0

	-- A SW may be selected so let's update the local SW data first.
	Update_Local_SW_Data()
	
	for index, object in pairs(selectedObjects) do
		if TestValid(object) then
			-- Don't include team members (which have BEHAVIOR_TEAM)
			local parent = object.Get_Parent_Object()
			if not parent or not parent.Has_Behavior(22) then
				table.insert(SelectedObjects, object)
				object.Register_Signal_Handler(On_Object_Removed_From_Selection_List, "OBJECT_HEALTH_AT_ZERO", this)
				object.Register_Signal_Handler(On_Object_Removed_From_Selection_List, "OBJECT_SOLD", this)
				object.Register_Signal_Handler(On_Switch_Type, "OBJECT_SWITCH_TYPE", this)
				
				
				if object.Get_Type().Get_Type_Value("Is_Tactical_Base_Builder") then
					table.insert(CurrentConstructorsList, object)
				end
				
				-- Maria 08.07.2007: when using the controller, all ground structures are considered part of the tactical queue.
				if object.Has_Behavior(99) then		
					table.insert(SelectedBuildings, object)
				end
				
				-- Add units that have a special ability to SelectedObjectsByType
				if Get_Unit_Special_Abilities({object}, true) or SWEnablers[object] then
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
-- Update_UI_After_Selection_Change()
-- ------------------------------------------------------------------------------------------------------------------
function Update_UI_After_Selection_Change()

	for index, object in pairs(SelectedObjects) do
		if TestValid(object) then
			-- show reticles/health bar/etc.
			-- Maria 01.12.2007
			-- Per design request: for walkers we only display their UI on Mouse_Over
			if not CustomizationModeOn and Is_Walker(object) and (not InHPSubSelectionMode or ParentObjectForHardPointSubSelection ~= object) then 
				Show_Object_Attached_UI(object, false)
			elseif not CustomizationModeOn and object.Has_Behavior(68) and Is_Walker(object.Get_Highest_Level_Hard_Point_Parent()) then 
				Show_Object_Attached_UI(object, false)
			else
				if not InHPSubSelectionMode or ParentObjectForHardPointSubSelection ~= object then
					-- If we are in HP Sub select mode we are hidding some of the walker's UI so we don't want it popping up out of nowhere!.
					Show_Object_Attached_UI(object, true)
				end
			end
		end
	end

	Mode = MODE_INVALID
	local num_constructors_selected = Update_Constructors_List()
	
	-- If selection has changed, let's clear the saved focus!.
	-- If the selection changed while the command bar is up we may be cycling through the builders (via builder button) so 
	-- we don't want the focus to be cleared from the builder button.
	if UpdateFocus and not CustomizationModeOn and not Is_Controller_Displaying_UI() then
		Clear_Key_Focus(false) -- false = do not save the last focus! We want to clear all type of focus because selection has changed!.
		-- This is mainly used to prevent focus to remain on special ability buttons!.		
	end
	
	if UpdateFocus == true and CustomizationModeOn == false then 
		-- selection has actually changed, so let's close all open displays!.
		Close_All_Displays(true)
	end
	
	if num_constructors_selected ~= 0 then
		if (BuilderMenuOpen == true or num_constructors_selected == #SelectedObjects) then
			-- Only if constructors are selected, pop this menu open!.
			Mode = MODE_CONSTRUCTION
		end
	else
		BuilderMenuOpen = false
	end
	
	-- If a building was selected, show the appropriate queue
	local building_type = nil
	
	if SelectedBuildings[1] then
		building_type = QueueManager.Get_Building_Queue_Type(SelectedBuildings[1])
	end
	
	-- note: we can only open the build queue if the blueprint menu is not up!.
	if building_type then
		local button = QueueButtonsByType[building_type]
		if button and (ControllerDisplayingCommandBar or ControllerDisplayingSingleProductionMenu) then
			CommandBar.Set_Hidden(true)
			QueueManager.Close()
			--QueueManager.Set_Screen_Position(button.Get_Screen_Position())
			QueueManager.Open(building_type, SelectedBuildings, Get_Unit_Special_Abilities(SelectedBuildings, true, false))
		end
	elseif not ControllerDisplayingCommandBar then
		QueueManager.Close()
	end
	
	Update_Mode()
	
	Update_Hero_Icons(SelectedObjects)
	
	-- Now that the UI has been updated, let's update the controller's context display!.
	-- Also, if selection has changed, update the context display for the controller!.
	Controller_Update_Context()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Build_Button_Focus_Gained
-- ------------------------------------------------------------------------------------------------------------------
function On_Build_Button_Focus_Gained(_, source)
	LastFocusedBuildButton = source
end


-- ------------------------------------------------------------------------------------------------------------------
-- Gamepad_Update_Common_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Gamepad_Update_Common_Scene(cur_time)

	if UpdateFocusOnNextService then
		-- Maria 12.20.2007
		-- We have to make sure the scenes are enabled before trying to set the focus.  In some cases, the service call comes before the
		-- Enable ui event has been handled which means that the Set_Key_Focus call will fail!.  Hence, let's keep checking for the Focus First
		-- call to be successful before resetting this flag!.
		UpdateFocusOnNextService = (not this.Focus_First())		
	end
	
	
	-- Do we need to clear the last selected builder pointer?
	if LastSelectedBuilderTime then
		if LastSelectedBuilderTime + LAST_SELECTED_BUILDER_RESET_DELAY <= GetCurrentTime() then 
			LastSelectedBuilder = nil
			LastSelectedBuilderTime = nil
		end
	end
	
	if TestValid(BuilderButton) then 
		local player_script = LocalPlayer.Get_Script()
		local hide_builder_button = true
		if player_script then
			local builder_count = player_script.Get_Async_Data("BuildersCount")
			if builder_count and builder_count > 0 then
				hide_builder_button = false
			end
		end
		
		BuilderButton.Set_Button_Enabled(not hide_builder_button)
	end
	
	-- Flash control group icons
	this.Carousel_ControlGroups.Refresh_Display()	
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
	if on_off then
		this.Objectives.Hide()
	else
		this.Objectives.Show()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Compute_SA_Buttons_Gap
-- ------------------------------------------------------------------------------------------------------------------
function Compute_SA_Buttons_Gap()
	if TestValid(this.CommandBar.SpecialAbilityButtons.SAButtonGapMarker) then
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = this.CommandBar.SpecialAbilityButtons.SAButtonGapMarker.Get_Bounds()
		SA_BUTTONS_GAP = bds.w
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Minor_Announcement_Text
-- ------------------------------------------------------------------------------------------------------------------
function Init_Minor_Announcement_Text()
	
	if TestValid(this.MinorAnnouncement.Frame) then 
		this.MinorAnnouncement.Frame.Set_Hidden(true)
		OrigFrameX, OrigFrameY, OrigFrameWidth, OrigFrameHeight = Scene.MinorAnnouncement.Frame.Get_World_Bounds()
		
		-- Size the text frame according to the text in it!.
		local _, ty, _, _ = this.MinorAnnouncement.MinorAnnouncementText.Get_World_Bounds()
		if OrigFrameY > ty then 
			MarginHeight = OrigFrameY - ty
		else
			MarginHeight = ty - OrigFrameY
		end
		
		-- double the margin to have the same distance at the bottom.
		MarginHeight = MarginHeight*2.0		
	end
	
	
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
	
	MinorAnnouncementFading = false
	
	-- Whenever a hint is activated/de-activated we need to stop/resume the fading of the minor
	-- announcement text.
	this.Register_Event_Handler("Hint_Activated", nil, On_Hint_Activated)
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Hint_Activated
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Hint_Activated(_, _, active_inactive)
	HintsActive = active_inactive
	
	if MinorAnnouncementFading then
		if HintsActive then
			-- We need to pause the animation so that the player can continue reading the objective whenever the hint has been
			-- dismissed.
			Scene.MinorAnnouncement.Pause_Animation()
		else
			-- The hints have been dismissed, we can go ahead and resume the fade animation for the minor annuouncement text.
			Scene.MinorAnnouncement.Resume_Animation()
		end
	end
	
	-- we have to let the post battle scene that a hint has been activated/deactivated so that the scene can update
	-- its focus state properly.
	if TestValid(post_game_ui) then 
		post_game_ui.Raise_Event("Hint_Activated", {active_inactive})
	end
	
	if HintsActive then 
		Update_Controller_Display(false)
	end	
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Debug_Switch_Sides
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Debug_Switch_Sides()
	Close_All_Displays()
	End_Tooltip()	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Battle_Cam_Button
-- ------------------------------------------------------------------------------------------------------------------
function Init_Battle_Cam_Button()
	Init_Battle_Cam_Textures()
	BattleCamButton = this.CommandBar.Carousel_CommandBar.BattleCam
	BattleCamButton.Set_Texture(FactionToBattleCamTextureMap[Find_Player("local").Get_Faction_Name()])
	BattleCamButton.Set_Tooltip_Data({'ui', {"TEXT_BATTLE_CAM_BUTTON"}})
--	this.CommandBar.BattleCam.Set_Tab_Order(TAB_ORDER_BATTLE_CAM_BUTTON)
	this.Register_Event_Handler("Selectable_Icon_Clicked", BattleCamButton, On_Handle_BattleCam_Button_Down)
--	this.Register_Event_Handler("Controller_A_Button_Up", BattleCamButton, On_Handle_BattleCam_Button_Up)
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
	Process_Battle_Cam_Command(false)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Handle_BattleCam_Button_Up
-- ------------------------------------------------------------------------------------------------------------------
function On_Handle_BattleCam_Button_Up(event, source)
end

-- ******** CONTROL GROUPS UI MANAGEMENT - BEGIN ******** --

--
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
-- On_Builder_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Builder_Button_Clicked(event, source)
	if not source or source.Get_Hidden() or not source.Is_Button_Enabled() then 
		return
	end
	
	Select_Next_Builder()
	FlashBuilderButton = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Builder_Button_Double_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Builder_Button_Double_Clicked(event, source)
	Point_Camera_At_Next_Builder()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Select_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Select_Next_Builder()
	-- this check is needed since we may be trying to select a builder via a hot key!
	if not TestValid(BuilderButton) or BuilderButton.Get_Hidden() == true or (not BuilderButton.Is_Button_Enabled()) then 
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
-- Point_Camera_At_Next_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Point_Camera_At_Next_Builder()
	-- this check is needed since we may be trying to select a builder via a hot key!
	if not TestValid(BuilderButton) or BuilderButton.Get_Hidden() == true or (not BuilderButton.Is_Button_Enabled()) then 
		-- no builders to select!
		return
	end
	
	-- With a double click, the single click gets processed first which means that the next idle builder will already had been selected
	-- by the time we get here.  Hence, just have the camera point at him.
	local player = Find_Player("local")
	if player then
		local script = player.Get_Script()
		if script then
			local builder = script.Get_Async_Data("SelectedBuilder")
			if TestValid(builder) then
				Point_Camera_At(builder)
			end
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
	
	-- If there is a scenario script call it for tutorial
	game_mode_script = Get_Game_Mode_Script()
	if game_mode_script and not Is_Multiplayer_Or_Replay() then
		game_mode_script.Call_Function("Game_Mode_Research_Panel_Open")
	end

	if On_Research_Tree_Open then
		On_Research_Tree_Open()
	end
	
	-- disable the carousel
	if TestValid(FactionButtons) then
		FactionButtons.Enable(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Research_Tree_Display
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Research_Tree_Display()
	
	-- if the research tree button is hidden, then we cannot toggle the RT display.	
	if not CommandBarEnabled then 
		return
	end
	
	if not Can_Access_Research() then
		return
	end
	
	local tree_was_open = this.Research_Tree.Is_Open()
	if tree_was_open == false then
		
		-- Let's hide the (other player's) SW data
		if TestValid(this.EnemySWTimers) then 
			this.EnemySWTimers.Set_Hidden(true)
		end
		
		-- If the Reinforcements menu happens to be up, close it.
		if TestValid(ReinforcementsMenuManager) then
			ReinforcementsMenuManager.Close()
		end
		
		-- Go ahead and open the tree
		Open_Research_Tree()			
	else
		this.Research_Tree.Set_Hidden(true)
		
		-- Let's un-hide the (other player's) SW data
		if TestValid(this.EnemySWTimers) then 
			this.EnemySWTimers.Set_Hidden(false)
		end	
	end

	-- this is the flag we use to determine which menus to close so that menus don't overlap!.	
	BuildModeOn = (not tree_was_open)
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
	end
	
	if ControllerDisplayingResearchAndFactionUI then
		FactionButtons.Enable(true)
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
	
	SellModeOn = Toggle_Sell_Mode()
	SellButton.Set_Selected(SellModeOn)
	Raise_Event_Immediate_All_Scenes("Refresh_Sell_Mode", {SellModeOn})
	
	if SellModeOn == true then
		-- Close all other menus, end any other modes!.
		Close_All_Displays()	
	end
	
	Controller_Update_Context()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Show_Radar_Map
--  - Oksana
-- ------------------------------------------------------------------------------------------------------------------
function Show_Radar_Map() 
	
	if not ShowRadarMap then
		-- do not unhide it!
		return
	end
	
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
		this.RadarZoomButton.Set_Hidden(false)			
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
	local AnchorX
	local AnchorY
	if CURRENT_RADAR_MAP_POSITION == BOTTOM_RIGHT_RADAR_MAP then
		AnchorX = CurrentX + CurrentWidth 
		AnchorY = CurrentY + CurrentHeight -- Note that screen coords grow downwards (upside down)	
	elseif CURRENT_RADAR_MAP_POSITION == TOP_RIGHT_RADAR_MAP then
		AnchorX = CurrentX + CurrentWidth 
		AnchorY = CurrentY
	end
		
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
	local ActualX
	local ActualY
	if CURRENT_RADAR_MAP_POSITION == BOTTOM_RIGHT_RADAR_MAP then
		ActualX = AnchorX - ActualWidth 
		ActualY = AnchorY - ActualHeight
	elseif CURRENT_RADAR_MAP_POSITION == TOP_RIGHT_RADAR_MAP then
		ActualX = AnchorX - ActualWidth 
		ActualY = AnchorY
	end
	
	-- Update main quad
	this.RadarMap.Set_World_Bounds(ActualX, ActualY, ActualWidth, ActualHeight)

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
		
		if CURRENT_RADAR_MAP_POSITION == BOTTOM_RIGHT_RADAR_MAP then	
			AnchorX = TrayX + TrayWidth 
			AnchorY = TrayY + TrayHeight -- Note that screen coords grow downwards (upside down)	

			ActualX = AnchorX - ActualWidth  - TrayWidthDiff
			ActualY = AnchorY - ActualHeight - TrayHeightDiff
		elseif CURRENT_RADAR_MAP_POSITION == TOP_RIGHT_RADAR_MAP then
			AnchorX = TrayX + TrayWidth 
			AnchorY = TrayY

			ActualX = AnchorX - ActualWidth  - TrayWidthDiff
			ActualY = AnchorY
		end

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
	
	if CURRENT_RADAR_MAP_POSITION == BOTTOM_RIGHT_RADAR_MAP and TestValid(this.top_backdrop) then -- this is the top backdrop in which we display the credits, pop cap, etc.
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

  	local delta_x, delta_x
  	if CURRENT_RADAR_MAP_POSITION == BOTTOM_RIGHT_RADAR_MAP then
  		delta_x = rW - (radar_enlarge_factor*rW)
  		delta_y = rH - (radar_enlarge_factor*rH)
  	elseif CURRENT_RADAR_MAP_POSITION == TOP_RIGHT_RADAR_MAP then
  		delta_x = rW - (radar_enlarge_factor*rW)
  		delta_y = 0.0
  	end

	open_anim = Create_Animation("Open")
	open_anim.Add_Key_Frame("Size", 0.0, { 1.0, 1.0 }) -- full size
	open_anim.Add_Key_Frame("Size", RADAR_MAP_ANIMATION_LENGTH, { radar_enlarge_factor, radar_enlarge_factor }) -- double the size
	-- reposition the map as it gets enlarged
	-- we only need to specify the "delta" to be considered when setting the new position.
	-- Note, for the radar map we also want to make sure that the lower-right corner stays put since it functions as the anchor point for the radar map scene.
	open_anim.Add_Key_Frame("Position", 0.0, { 0.0, 0.0 })
	open_anim.Add_Key_Frame("Position", RADAR_MAP_ANIMATION_LENGTH, { delta_x, delta_y })

	if TestValid(this.RadarMap) then
		this.RadarMap.Add_Animation(open_anim)
	end
	
	-- Now the Tray - it must wrap around the radar map quads precisely.
	-- Note that width will fit because of the way we calculated radar_enlarge_factor above,
	-- so we will only need to adjust the heigh
	local enlarge_factor_h = (rH*radar_enlarge_factor+TrayHeightDiff) / h
	local enlarge_factor_w
		
  	if CURRENT_RADAR_MAP_POSITION == BOTTOM_RIGHT_RADAR_MAP then
  		enlarge_factor_w = enlarge_factor
  		delta_x = w - (enlarge_factor_w*w)
  		delta_y = h - (enlarge_factor_h*h)
  	elseif CURRENT_RADAR_MAP_POSITION == TOP_RIGHT_RADAR_MAP then
  		enlarge_factor_w = (rW*radar_enlarge_factor+TrayWidthDiff) / w
  		delta_x = w - (enlarge_factor_w*w)
  		delta_y = 0.0
  	end
			
	local open_anim = Create_Animation("Open")
	open_anim.Add_Key_Frame("Size", 0.0, { 1.0, 1.0 }) -- full size
	open_anim.Add_Key_Frame("Size", RADAR_MAP_ANIMATION_LENGTH, { enlarge_factor_w, enlarge_factor_h }) -- double the size
	-- reposition the map as it gets enlarged
	-- we only need to specify the "delta" to be considered when setting the new position.
	-- Note, for the radar map we also want to make sure that the lower-right corner stays put since it functions as the anchor point for the radar map scene.
	open_anim.Add_Key_Frame("Position", 0.0, { 0.0, 0.0 })
	open_anim.Add_Key_Frame("Position", RADAR_MAP_ANIMATION_LENGTH, { delta_x, delta_y})
	
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
	-- Before we set the animation to have finished we need to let a frame pass so that
	-- we don't experience any hiccups in the last frame.  Indeed, when the animation is
	-- finished the radar map needs to be re-rendered which causes the frame rate to go down
	-- which makes the animations hiccup for they are frame-rate-dependent.
	RadarMapAnimationFinishedFrame = GetCurrentTime.Frame()
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
	
	-- In some cases design may want to hide the radar map so let's make sure this is not the case!.
	if not ShowRadarMap then 	
		return
	end
	
	-- Let's make sure the radar map is zoomed out
	if IsRadarOpen then 
		return 
	end
	
	-- Shutdown any display in the tactical command bar.
	-- NOTE: If the controller is connected, then we shut everything down from code!.
	if TestValid(this.GamepadContextDisplay) then 
		this.GamepadContextDisplay.Set_Hidden(true)
	end
	
	--EMP 11/7/07 - Also hide the hero buttons and SW timers when radar is up
	if TestValid(this.HeroButtons) then
		this.HeroButtons.Set_Hidden(true)
	end
	
	-- Maria 02.07.2008
	-- Per task request: Expanding the radar map should only hide the button callouts not the current patches/research and enemy superweapon timers
	--if TestValid(this.EnemySWTimers) then 
	--	this.EnemySWTimers.Set_Hidden(true)
	--end
	
	--if TestValid(this.ResearchProgressDisplay) then
	--	this.ResearchProgressDisplay.Set_Hidden(true)
	--end
	
	-- Lock the Command Bar
	CommandBarEnabled = false
	-- refresh the selection data just in case.
	Update_Mode()
	-- Open the radar map
	this.RadarTray.Play_Animation("Open", false)	
	this.RadarMap.Play_Animation("Open", false)	
	
	IsRadarOpen = true
	
	--Only suspend is not already suspended - Oksana
	if IsRadarAnimating == false then
		RadarMap.Suspend()
	end
	IsRadarAnimating = true
	RadarMapAnimationFinishedFrame = nil
	End_Tooltip()
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Radar_Map_Zoom_Out
-- ------------------------------------------------------------------------------------------------------------------------------------
function Radar_Map_Zoom_Out()
	
	-- In some cases design may want to hide the radar map so let's make sure this is not the case!.
	if not ShowRadarMap then 	
		return
	end
	
	-- Let's make sure that the map is zoomed in.
	if IsRadarOpen == false then 
		return 
	end
	
	if TestValid(this.GamepadContextDisplay) then
		if ShowContextDisplay and not Is_Controller_Displaying_UI() then 
			this.GamepadContextDisplay.Set_Hidden(false)
		end		
	end
	
		--EMP 11/7/07 - Also hide the hero buttons and SW timers when radar is up
	if TestValid(this.HeroButtons) then
		this.HeroButtons.Set_Hidden(false)
	end
	
	-- Maria 02.07.2008
	-- Per task request: Expanding the radar map should only hide the button callouts not the current patches/research and enemy superweapon timers
	--if TestValid(this.EnemySWTimers) then 
	--	this.EnemySWTimers.Set_Hidden(false)
	--end

	--if TestValid(this.ResearchProgressDisplay) then
	--	this.ResearchProgressDisplay.Set_Hidden(false)
	--end
		
	-- If applicable, hide the MP Beacon Display.
	if TestValid(MPBeaconContext) then 
		MPBeaconContext.Set_Hidden(true)
	end
	
	-- Close the radar map
	this.RadarTray.Play_Animation_Backwards("Open", false)	
	this.RadarMap.Play_Animation_Backwards("Open", false)	

	IsRadarOpen = false
	
	--Only suspend is not already suspended - Oksana
	if IsRadarAnimating == false then
		RadarMap.Suspend()
	end
	IsRadarAnimating = true
	RadarMapAnimationFinishedFrame = nil	
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Is_Radar_Map_Open
-- ------------------------------------------------------------------------------------------------------------------------------------
function Is_Radar_Map_Open()
	return( IsRadarOpen )
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Display_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Display_Tooltip(event, source, tooltip_data)
	Display_Tooltip(tooltip_data, false)
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Display_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function Display_Tooltip(tooltip_data, hide_floating_tooltip)
	if tooltip_data == nil then return end
	
	if Tooltip.Get_Hidden() then 
		Tooltip.Set_Hidden(false)
	end
	
	Tooltip.Display_Tooltip(tooltip_data, hide_floating_tooltip, MouseOverHoverTime_Extended)
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- End_Tooltip
-- ------------------------------------------------------------------------------------------------------------------------------------
function End_Tooltip(event, source)
	if not TestValid(Tooltip) then 
		return
	end
	
	-- Hide the tooltip
	Tooltip.End_Tooltip()
end

-- -----------------------------------------------------------------------------------------------------------------
-- On_Network_Sell_Object
-- -----------------------------------------------------------------------------------------------------------------
function On_Network_Sell_Object(event, source, object, player)
	if TestValid(object) then 
		local success = object.Sell()	
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

	if not BuilderMenuOpen then
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
	
	if TestValid(QueueManager) and QueueManager.Is_Open() == true then
		QueueManager.Close()		
	end
	
	if TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open() then
		ReinforcementsMenuManager.Close()
	end
	
	if not IsReplay then
		Hide_Research_Tree()
	end
	
	if close_faction_specific then 
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
		if SelectedBuildings[1] ~= nil then 
			structure = SelectedBuildings[1]
		else
			-- no structure specified, so let's get the first one in the list of all enabling structures.
			local all_buildings = QueueManager.Find_Tactical_Enablers()
			if all_buildings and table.getn(all_buildings) ~= 0 then 
				structure = all_buildings[1]
			end
		end
	end

	if structure ~= nil then 
		
		if not structure.Has_Behavior(89) then 
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
-- Init_Queues_Interface
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Queues_Interface()
	-- Init the map of textures (one per faction)
	Init_Queue_Textures()

	-- Initialize buttons for different types of queues
	QueueTypes = { 'Command', 'Infantry', 'Vehicle', 'Air', 'NonProduction' }
	
	-- We don't want to be comparing strings.  Until we remove the string queue type let's keep this map to do fast compares
	QueueTypeStrgToEnumValue = {}
	QueueTypeStrgToEnumValue['NonProduction'] = Declare_Enum(0)
	QueueTypeStrgToEnumValue['Command'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Infantry'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Vehicle'] = Declare_Enum()
	QueueTypeStrgToEnumValue['Air'] = Declare_Enum()
	
	-- Update their tooltip info
	Update_Queues_Tooltip_Data()
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Update_Queues_Tooltip_Data
-- ------------------------------------------------------------------------------------------------------------------------------------
function Update_Queues_Tooltip_Data()
	QueueTypeToTooltipDataMap = {}
	QueueTypeToTooltipDataMap['Air'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_AIR"}		
	QueueTypeToTooltipDataMap['Vehicle'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_VEHICLE"}
	QueueTypeToTooltipDataMap['Infantry'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_INFANTRY"}
	QueueTypeToTooltipDataMap['Command'] = {"TEXT_UI_TACTICAL_BUILD_QUEUE_COMMAND"}
	-- Maria Remove key mapping.
	QueueTypeToTooltipDataMap['NonProduction'] = {"TEXT_UI_TACTICAL_RAW_MATERIALS_DISPLAY"}
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Maria 07.11.2006 - the textures for the tactical queue buttons change based on the owning faction
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Queue_Textures()
	PlayerToQueueTexturesMap = {}

	PlayerToQueueTexturesMap["ALIEN"] = {}
	PlayerToQueueTexturesMap["ALIEN"]['Command'] 	= 'i_icon_a_build_tab_command.tga' 
	PlayerToQueueTexturesMap["ALIEN"]['Air'] 		= 'i_icon_a_build_tab_air.tga' 
	PlayerToQueueTexturesMap["ALIEN"]['Infantry'] 	= 'i_icon_a_build_tab_infantry.tga' 
	PlayerToQueueTexturesMap["ALIEN"]['Vehicle'] 		= 'i_icon_a_build_tab_vehicle.tga' 

	PlayerToQueueTexturesMap["MILITARY"] = {}
	PlayerToQueueTexturesMap["MILITARY"]['Command'] 	= 'i_icon_command.tga'
	PlayerToQueueTexturesMap["MILITARY"]['Air'] 		= 'i_icon_ca.tga'
	PlayerToQueueTexturesMap["MILITARY"]['Infantry'] 	= 'i_icon_ci.tga'
	PlayerToQueueTexturesMap["MILITARY"]['Vehicle'] 	= 'i_icon_cv.tga'


	PlayerToQueueTexturesMap["NOVUS"] = {}
	PlayerToQueueTexturesMap["NOVUS"]['Command'] 	= 'i_icon_n_build_tab_command.tga'
	PlayerToQueueTexturesMap["NOVUS"]['Air'] 		= 'i_icon_n_build_tab_air.tga'
	PlayerToQueueTexturesMap["NOVUS"]['Infantry'] 	= 'i_icon_n_build_tab_infantry.tga'
	PlayerToQueueTexturesMap["NOVUS"]['Vehicle'] 		= 'i_icon_n_build_tab_vehicle.tga'

	PlayerToQueueTexturesMap["MASARI"] = {}
	PlayerToQueueTexturesMap["MASARI"]['Command'] 	= 'i_icon_m_build_tab_command.tga'
	PlayerToQueueTexturesMap["MASARI"]['Air'] 		= 'i_icon_m_build_tab_air.tga'
	PlayerToQueueTexturesMap["MASARI"]['Infantry'] 	= 'i_icon_m_build_tab_infantry.tga'
	PlayerToQueueTexturesMap["MASARI"]['Vehicle'] 		= 'i_icon_m_build_tab_vehicle.tga'
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
	PlayerToIdleBuilderTexturesMap["ALIEN"] = "i_icon_a_idle_builder.tga"
	PlayerToIdleBuilderTexturesMap["NOVUS"] = "i_icon_n_idle_builder.tga"
	PlayerToIdleBuilderTexturesMap["MASARI"] = "i_icon_m_idle_builder.tga"
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
function Get_Unit_Special_Abilities(units_list, include_locked, story_locks_only)
	if not units_list then
		return
	end
	
	-- default to story locks only if include locks is on
	if story_locks_only == nil then
		story_locks_only = true
	end
	
	-- default: do not include locked abs.
	if include_locked == nil then 
		include_locked = false
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
		local player = unit.Get_Owner()
		local unit_type = unit.Get_Type()
		
		local unit_ability_names = unit.Get_Ability_Names(include_locked)
		if not unit_ability_names then
			return
		end
		
		-- go through each ability name
		for _, unit_ability_name in pairs(unit_ability_names) do
		
			local count = 0
						
			-- get the special ability by the name
			local ability = SpecialAbilities[unit_ability_name]
			if ability then
			
				local unit_has_ability = true
				local multi_exclude_ability = false
				
				if Is_Campaign_Game() == false and ability.campaign_game_only == true then
					unit_has_ability = false
					multi_exclude_ability = true
				end
				
				if unit_has_ability then 			
					if include_locked then
						-- For now all we care about is abilities locked from story.
						if player.Is_Unit_Ability_Locked(unit_ability_name) and story_locks_only then
							if player.Is_Unit_Ability_Locked(unit_ability_name, STORY) then
								local object_type_name = unit_type.Get_Name()
								
								if ForceAbilityDisplay and (not ForceAbilityDisplay[ object_type_name ] or not ForceAbilityDisplay[ object_type_name ][unit_ability_name]) then
									unit_has_ability = false
								else
									-- this will allow us to distinguish between abilities that belong to an individual object and those attached to an object
									-- by other objects attached to it (eg. the walker doesn't have a Jammer ability unless it has the Jammer hp attached to it)
									CurrentAbilityCount[unit_ability_name] = -1
									ability.AbilityOwner = unit
								end
							else
								unit_has_ability = false
							end
						else
							-- this will allow us to distinguish between abilities that belong to an individual object and those attached to an object
							-- by other objects attached to it (eg. the walker doesn't have a Jammer ability unless it has the Jammer hp attached to it)
							CurrentAbilityCount[unit_ability_name] = -1
							ability.AbilityOwner = unit
						end					
					else
						-- this will allow us to distinguish between abilities that belong to an individual object and those attached to an object
						-- by other objects attached to it (eg. the walker doesn't have a Jammer ability unless it has the Jammer hp attached to it)
						CurrentAbilityCount[unit_ability_name] = -1
						ability.AbilityOwner = unit
					end
				end
				
				-- MARIA: MAY NEED TO DO!!!: the same check for the abilities on HP's being locked from story!!!!!!.
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
	
	if not IsLetterboxMode then
		-- Show buttons for queue types that have buildings
		for i, queue_type in pairs(QueueTypes) do
			local button = QueueButtons[i]
			if TestValid(button) then 
				count = QueueManager.Get_Queue_Type_Enabler_Count(queue_type)
				if QueueTypesToFlash[queue_type] then
					button.Start_Flash()
				else
					button.Stop_Flash()
				end
				
				if count == 0 then
					button.Set_Hidden(not Faction_Has_Queue_Type(queue_type))
					button.Set_Button_Enabled(false)
					if queue_type == current_queue_type then
						QueueManager.Close()
					end
				else
					button.Set_Hidden(false)
					button.Set_Button_Enabled(true)
					button.Set_Selected(current_queue_type == queue_type)
				end
			end
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Queue_Button_Clicked(event, button)

	if CommandBarEnabled == false then return end
	
	-- since we may be issuing this event without the button having been clicked make sure the button is in a valid state
	if button.Get_Hidden() or not button.Is_Button_Enabled() then 
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
		
		QueueManager.Close()		
--		QueueManager.Set_Screen_Position(button.Get_Screen_Position())
		
		-- if there's no valid building selected, we'll open just the building queue.  Otherwise, we'll also
		-- display the building's buy queue and build queue.
		
		local building = nil
		
		if QueueTypesToFlash[queue_type] then 
			QueueTypesToFlash[queue_type] = nil
		end
		
		-- If there's already a valid building selected, we open its queue.
		if SelectedBuildings[1] then
			local building_type = QueueManager.Get_Building_Queue_Type(SelectedBuildings[1])
			
			if building_type == queue_type then 
				building = SelectedBuildings[1]
			else
				QueueManager.Close()
			end
		end

		QueueManager.Open(queue_type, building, Get_Unit_Special_Abilities({building}, true, false))
		if ControllerDisplayingCommandBar then
			CommandBar.Set_Hidden(true)
		end
		BuildModeOn = (not Is_Walker(building))
	else
		QueueManager.Close()
		BuildModeOn = false
		if ControllerDisplayingCommandBar then
			CommandBar.Set_Hidden(false)
		end
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
---		-- Reset their formatting as well
--		if SAButtonIdxToOrigBoundsMap[index] then 
--			local bds = SAButtonIdxToOrigBoundsMap[index]
--			button.Set_Bounds(bds.x, bds.y, bds.w, bds.h)
--		end
	end
	
	if TestValid(GuardButton) then
		GuardButton.Set_Hidden(true)
	end
	
	if TestValid(HuntButton) then 
		HuntButton.Set_Hidden(true)
	end
	
	-- Build Buttons
	
	for index, button in pairs(BuildButtons) do
		button.Set_Hidden(true)
		-- reset their enabled state as well!.
		button.Set_Button_Enabled(true)
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

	local all_constructors_flowing = true
	local total = table.getn(CurrentConstructorsList)
	for idx = total, 1, -1 do
		local constructor = CurrentConstructorsList[idx]
		
		if Is_Selected(constructor) == false then 
			table.remove(CurrentConstructorsList, idx)
		elseif constructor.Is_Flowing() == false then 
			all_constructors_flowing = false
		end
	end
	
	--gray out build menu when they are flowing
	if all_constructors_flowing and total > 0 then
		for _, button in pairs(BuildButtons) do
			button.Hide_A_Button_Overlay(true)
			button.Set_Grayscale(true)
			button.Enable(false)
		end	
	else
		for _, button in pairs(BuildButtons) do
			button.Hide_A_Button_Overlay(false)
			button.Set_Grayscale(false)
			button.Enable(true)
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
	
	-- this is not valid for the gamepad.
	--if TestValid(this.Research_Tree) and this.Research_Tree.Is_Open() == true and not IsReplay then 
	--	Hide_Research_Tree()
	--end
	
	-- Let the specific scene hide whatever it needs to.
	if Hide_Faction_Specific_Buttons then
		Hide_Faction_Specific_Buttons()
	end
	
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
						button.Set_Button_Enabled(false)
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
		
		if BuildModeOn and not CarouselBuildMenu.Get_Hidden() then
			-- hide the build carousel for there's something else open
			CarouselBuildMenu.Set_Hidden(true)
			return
		end
		
		if ControllerDisplayingSelectionUI and CarouselBuildMenu.Get_Hidden() then		
			-- Sometimes the build menu can be opened from the special abilities carousel. 
			-- In such cases we have to make sure we hide the latter so that we can set
			-- the focus on the build menu carousel.
			if not SpecialAbilityCarousel.Get_Hidden() then 
				SpecialAbilityCarousel.Set_Hidden(true) 
			end
			
			CarouselBuildMenu.Set_Hidden(false)
			UpdateFocusOnNextService = true
		end				
	else
		BuilderMenuOpen = false
		
		if not CarouselBuildMenu.Get_Hidden() then
			CarouselBuildMenu.Set_Hidden(true)
		end	
	end
	
	if button_index > 1 then 
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
-- On_Build_Button_Focus_Gained
-- ------------------------------------------------------------------------------------------------------------------
function On_Build_Button_Focus_Gained(_, source)
	LastFocusedBuildButton = source
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
	if selection_data == nil then
		return
	end
	
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
		if ability_data[1].sw_type_name then
			count = count + #objects
		else
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
	end
	return count
end

-- ------------------------------------------------------------------------------------------------------------------
-- Show selected units, and their special abilities
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Mode_Selection()
	
	if CommandBarEnabled == false then return end
	Hide_All_Buttons()
	
	if BuilderMenuOpen then 
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
			
			local abilities = {}
			local object_type_name = objects[ 1 ].Get_Type().Get_Name()
			
			if ForceAbilityDisplay and ForceAbilityDisplay[ object_type_name ] then			
				abilities = Get_Unit_Special_Abilities(objects, true) -- true = inlcude locked by story abilities.
			else
				-- do not include locked abilities.
				abilities = Get_Unit_Special_Abilities(objects)
				
				if not abilities then 
					-- Is this a SW enabler?
					if SWEnablers[objects[1]] then 
						abilities = Get_SW_Ability_Data(objects)
					end
				end
			end
			
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
	
	-- Update the states of the Hunt and Guard buttons
	-- --------------------------------------------------------------------------------------------------
	Update_Guard_Button()
	Update_Hunt_Button()	
	-- --------------------------------------------------------------------------------------------------
	
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
-- Update_Guard_Button
-- ----------------------------------------------------------------------------------------------------------------------------------------------
function Update_Guard_Button()
	if TestValid(GuardButton) then
		if #SelectedObjects > 0 and Get_Selection_Allows_Guard() then
			GuardButton.Set_Hidden(false)
		else
			GuardButton.Set_Hidden(true)				
		end
	end	
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Hunt_Button
-- ----------------------------------------------------------------------------------------------------------------------------------------------
function Update_Hunt_Button()
	if TestValid(HuntButton) then
		local can_hunt, all_hunting = Get_Hunt_Mode_State()
		if can_hunt then
			HuntButton.Set_Hidden(false)	
			if HuntModeState ~= all_hunting then
				HuntModeOn = not all_hunting
				local texture, tooltip_data = Get_Hunt_Mode_Texture_And_Tooltip_Data()
				
				-- Swap the texture!.
				if texture then 
					HuntButton.Set_Texture(texture)
				end
				
				-- Update the tooltip data
				if tooltip_data then 
					HuntButton.Set_Tooltip_Data(tooltip_data)
				end
			end
			
		else
			HuntButton.Set_Hidden(true)	
		end
	end
end


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
function Is_First_Button(bttn_idx)
	
	if bttn_idx == 9 or bttn_idx == 17 then
		local j = 0
		if j ==1 then
			return
		end
	end
	
	local num_rows =  #SpecialAbilityButtons/ABILITIES_PER_ROW
	for i = 1, num_rows do
		if (bttn_idx == (ABILITIES_PER_ROW * (i - 1)) + 1) then
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
			
--			if not Is_First_Button(button_index) then
				
				-- Position the button.
--				if LastSAButtonPosition then
					-- position the button properly
--					button.Set_Bounds(LastSAButtonPosition, SAButtonIdxToOrigBoundsMap[button_index].y, SAButtonIdxToOrigBoundsMap[button_index].w, SAButtonIdxToOrigBoundsMap[button_index].h )
--					LastSAButtonPosition = LastSAButtonPosition + SAButtonIdxToOrigBoundsMap[button_index].w + SA_BUTTONS_GAP
--				else
--					MessageBox("NO START POSITION FOR THE AB BUTTON!")
--				end
				
				-- if we are the first button of the set, let's place the separator between us and the previous button.
			
-- 				if button_index == ab_button_index then
					-- HERE WE HAVE TO PLACE THE SEPARATORS!!!!!.
					-- Place the separator half way between the last button and where the new button will go.
--					local last_button = SpecialAbilityButtons[ab_button_index - 1]
					
--					if last_button then
--						LastSeparatorIndex = LastSeparatorIndex + 1 
--						if LastSeparatorIndex <= #AbSeparators then
--							local separator = AbSeparators[LastSeparatorIndex]
--							local last_bds = {}
--							last_bds.x, last_bds.y, last_bds.w, last_bds.h = last_button.Get_World_Bounds()
--							local last_pivot = {}
--							last_pivot.x = last_bds.x + (last_bds.w / 2.0)
--							last_pivot.y = last_bds.y + (last_bds.h / 2.0)
							
--							local our_bds = {}
--							our_bds.x, our_bds.y, our_bds.w, our_bds.h = button.Get_World_Bounds()
--							local our_pivot = {}
--							our_pivot.x = our_bds.x + (our_bds.w / 2.0)
--							our_pivot.y = our_bds.y + (our_bds.h / 2.0)
--							
--							separator.Set_Screen_Position((last_pivot.x + our_pivot.x)/2.0, (last_pivot.y + our_pivot.y)/2.0)
--							separator.Set_Hidden(false)							
--						end
--					end					
--				end				
--			else
--				LastSAButtonPosition =  SAButtonIdxToOrigBoundsMap[button_index].x + SAButtonIdxToOrigBoundsMap[button_index].w + SA_BUTTONS_GAP
--			end
			
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
			if objects[1].Has_Behavior(68) then
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
				button.Set_Button_Enabled(false)
			else
				button.Set_Button_Enabled(true)
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
	end -- for abilitieso
	
	-- Set the proper 'grouping quad' on top of these buttons.
	local num_abs = button_index - ab_button_index
	_PG_Hint_Refresh_GUI_Hints()
	return (button_index - ab_button_index) -- return the number of abilities just added!.
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_SA_Button_Text
-- ------------------------------------------------------------------------------------------------------------------
function Update_SA_Button_Text(button_idx)
	if not button_idx then return end
	
	if button_idx < 1 or button_idx > #SpecialAbilityButtons then
		MessageBox("Update_Special_Ability_Text::Invalid index for ability button.")
		return
	end
	
	local button = SpecialAbilityButtons[button_idx]

	local user_data = button.Get_User_Data()
	if user_data then	
		local selected_objects_data = SelectedObjectsByType[user_data.type_name]
		
		if not selected_objects_data then
			return
		end
		
		local selected_objects = {}
		for idx = 1, table.getn(selected_objects_data) do
			if TestValid(selected_objects_data[idx].Object) then
				table.insert(selected_objects, selected_objects_data[idx].Object)
			else
				table.remove(SelectedObjectsByType[user_data.type_name], idx)
			end
		end
		
		-- Maria 12.05.2007
		-- if this is a SW launch button, let's update its state here for it is not a valid ability.
		if user_data.ability.sw_type_name then 	
			local count = #selected_objects
			local enabled, num_ready, progress = Get_SW_Launch_Ability_Data(selected_objects)
			if num_ready ~= count then
				local wstr_fraction = Get_Game_Text("TEXT_FRACTION")
				Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(num_ready), 0)
				Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(count), 1)
				button.Set_Text(wstr_fraction)
			else
				button.Set_Text(Get_Localized_Formatted_Number(count))
			end	
			
			if progress > 0 then
				button.Set_Clock_Tint(RechargingAbilityClockTint)
				button.Set_Clock_Filled(progress)
			else
				button.Set_Clock_Filled(0.0)
			end
			button.Set_Button_Enabled(enabled)		
			button.Set_Tooltip_Data({'object', {selected_objects[1], false, false}})
		else
			Update_SA_Button_Text_Button(button, selected_objects, AbButtonsToFlash)
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
	
	-- Also update the states of the Hunt and Guard buttons
	-- --------------------------------------------------------------------------------------------------
	Update_Guard_Button()
	Update_Hunt_Button()
	-- --------------------------------------------------------------------------------------------------
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
-- Display_Object_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Display_Object_Tooltip()

	local ans = (	
				ControllerDisplayingSelectionUI or 
				ControllerDisplayingCommandBar or 
				ControllerDisplayingResearchAndFactionUI or
				ControllerDisplayingControlGroupsUI or
				CustomizationModeOn		
			) 
	return not ans
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Mouse_Over
-- ------------------------------------------------------------------------------------------------------------------
function Update_Mouse_Over()

	local cursorOverObject = nil
	local tooltip_target = nil -- we want to display the hard point's tooltip and not its parent's!
	local build_list = nil
	local mouse_over_ui, object_owns_ui
	local gui_scene_owner = nil
	if not Is_Letter_Box_On() then
		cursorOverObject = Get_Object_At_Cursor()
		
		-- if this object is a hard point built on a socket then we want to display its tooltip information!
		if TestValid(cursorOverObject) then
			tooltip_target = cursorOverObject
			if cursorOverObject.Has_Behavior(68) then 
				-- Maria 12.11.2006 - commenting this out since we want each individual (attackable) hard point socket to display
				-- its own tooltip so that we can keep track of walker components taking damage.
				--  cursorOverObject.Has_Behavior(40) then 
		 
				-- Only hard points with text assigned are the ones that get their tooltips displayed!
				local name = cursorOverObject.Get_Type().Get_Display_Name()
				if name.empty() == false then 
					tooltip_target = cursorOverObject
				end				
			else
				local parent = cursorOverObject.Get_Parent_Object()
				if TestValid(parent) and parent.Has_Behavior(22) then
					cursorOverObject = parent
					tooltip_target = cursorOverObject
				end
			end
		end
	end
	
	local curtime = GetCurrentRealTime()
	if cursorOverObject == MouseOverObject then
		if cursorOverObject and MouseOverObjectTime > 0 and MouseOverHoverTime >= 0 and curtime - MouseOverObjectTime > MouseOverHoverTime then
			-- Show health bar for new moused-over object
			
			if TestValid(MouseOverRootObject) then 
				-- If we are subselection hard points on a walker, we should not mess with the display of the object's UI!!!!.
				if not InHPSubSelectionMode or ParentObjectForHardPointSubSelection ~= MouseOverRootObject then
					Show_Object_Attached_UI(MouseOverRootObject, true)
				end
			end
			
			if TestValid(tooltip_target) and Display_Object_Tooltip() then 
				Display_Tooltip({'object', {tooltip_target}})
				MouseOverObjectTime = 0
			end
		end
	else
		local old_root_object = MouseOverRootObject
		
		MouseOverObjectTime = curtime
		MouseOverObject = cursorOverObject
		MouseOverRootObject = Get_Root_Object(MouseOverObject)		
		
		if TestValid(old_root_object) then
			if old_root_object ~= MouseOverRootObject and 
					(not InHPSubSelectionMode or ParentObjectForHardPointSubSelection ~= old_root_object) and
					not Is_Selected(old_root_object) then 
				Show_Object_Attached_UI(old_root_object, false)
			end
			End_Tooltip()
		end		
	end	
	
	if Update_HP_Sub_Selection_Context_Display then
		Update_HP_Sub_Selection_Context_Display()
	end
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
function Update_Tree_Scenes(player, during_init)
	if player == LocalPlayer then 
		if during_init then
			Raise_Event_All_Scenes("Update_Tree_Scene", nil)
		else
			Raise_Event_Immediate_All_Scenes("Update_Tree_Scene", nil)
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function Update_Common_Scene()

	--Only update the local player if really necessary
	if not LocalPlayer then
		LocalPlayer = Find_Player("local")
	end
	
	if FirstService then 
		-- Figure out current mode, based on selected objects
		Selection_Changed()
		FirstService = false
	end
	
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
	
		-- Update once on second frame (after things are initialized) -Oksana
	if nice_service_time and not IsRadarInitialized then
		Update_Radar_Map_Bounds()
		IsRadarInitialized = true	
	end

	
	if RadarMapAnimationFinishedFrame and GetCurrentTime.Frame() > RadarMapAnimationFinishedFrame then
		RadarMap.Resume()
 		IsRadarAnimating = false
 		RadarMapAnimationFinishedFrame = nil
		
		if IsRadarOpen then
			-- Display the MP Beacon context
			if TestValid(MPBeaconContext) and Can_Place_MP_Beacon() then 
				MPBeaconContext.Set_Hidden(false)
			end
		end
 	end


	if LocalPlayer.Is_Build_Types_List_Initialized() == true and ResearchTreesInitialized == false then
		Raise_Event_All_Scenes("Initialize_Tree_Scenes", nil)
		ResearchTreesInitialized = true
	end
	
	if not CurrentConflictLocation then
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
			Tooltip.Force_Hide(true)
			
			Set_Hint_System_Visible(false)
			
			-- Hide queue manager. 
			QueueManager.Close()
			
			Refresh_Queue_Buttons()
			Hide_Radar_Map()
			
			-- If the research tree is up when we go into letterbox mode, let's just shutting down so it doesn't
			-- show up (blocking the view) when the letterbox is over. (bug #482)
			Hide_Research_Tree()
			
			Scene.MinorAnnouncement.MinorAnnouncementText.Set_Text("")	
			if TestValid(this.MinorAnnouncement.Frame) then 
				Scene.MinorAnnouncement.Frame.Set_Hidden(true)
			end	
			Scene.MinorAnnouncement.Stop_Animation()	
			
			--Hide any non-cinematic subtitle
			if TestValid(this.Subtitle) then
				this.Subtitle.Set_Hidden(true)
			end
			
			-- Let other UI scenes know that they should be hidden while the cinematic plays
			Raise_Event_All_Scenes("Update_LetterBox_Mode_State", {true})
			
			--Set the active animation to letterbox but don't let it run free.  We'll manually update the frame
			--based on the letterbox state as determined by game code
			Scene.LetterboxTop.Set_Hidden(false)
			Scene.LetterboxBottom.Set_Hidden(false)
			Scene.Play_Animation("Letterbox", false)
			Scene.Pause_Animation()
		end
		local anim_length = Scene.Get_Animation_Length()
		Scene.Set_Animation_Frame(letter_box_percent * anim_length)
	elseif IsLetterboxMode then
		-- Just ending letterbox
		IsLetterboxMode = false
		
		-- Let other UI scenes know that they should be fine now!
		Raise_Event_All_Scenes("Update_LetterBox_Mode_State", {false})
		
		-- let the tooltip scene know that letterbox mode is over so that we can display tooltips again!.
		-- We only enable the tooltip if the minor announcement text has not been set yet!.
		Tooltip.Force_Hide(MinorAnnouncementFading)
		
		-- Make sure we reset whatever data made it to the tooltip!.
		Tooltip.End_Tooltip()
		
		Set_Hint_System_Visible(true)
		
		Show_Radar_Map()
		Scene.Stop_Animation()
		Scene.LetterboxTop.Set_Hidden(true)
		Scene.LetterboxBottom.Set_Hidden(true)		
		
		if not Is_Controller_Displaying_UI() and ShowContextDisplay then
			this.GamepadContextDisplay.Set_Hidden(false)
		end
		
		-- could have ended the battlecam by pulling the trigger
		if ControllerDisplayingCommandBar then
			this.GamepadContextDisplay.Set_Hidden(true)
			CommandBar.Set_Hidden(false)
		end
		
		--Start any announcements that were queued up during the cinematic
		if #MinorAnnouncementQueue > 0 then
			local text = MinorAnnouncementQueue[1] 
			table.remove(MinorAnnouncementQueue, 1)
			this.Raise_Event("Set_Minor_Announcement_Text", nil, { text })
		end		
		
		-- force an update on everything so that the hidden/displayed state of buttons is refreshed immediately.
		nice_service_time = true
	end
	
	-- Update fade out UI
	local fade_percent = Get_Fade_Screen_Percent()
	if fade_percent > 0 then
		Scene.FadeQuad.Set_Hidden(false)
		Scene.FadeQuad.Set_Tint(0.0, 0.0, 0.0, fade_percent)
	else
		Scene.FadeQuad.Set_Hidden(true)
	end

	Update_Mouse_Over()

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
		Superweapon_Update()
		Update_Button_Flash_State()
	end

	-- refresh as needed
	if QueueManager ~= nil and QueueManager.Update_Refresh ~= nil then
		QueueManager.Update_Refresh( cur_time )
	end
	
	Gamepad_Update_Common_Scene(cur_time)
	
	if UpdateHeroTooltips then 
		Update_Hero_Icons_Tooltip_Data()
		UpdateHeroTooltips = false
	end
	
	-- Maria 07.05.2007 - Removing the nice_Service_time check because it was causing the update of the hero button (from not selected to selected)
	-- lag way behind the actual selection of the hero.
	Update_Hero_Icons(nil) -- Need to update the health bars for all present heroes.  Pass nil so that we don't update selected state.
	
	-- let the main scene know whether we have GUI elements to close.
	local intercept_close_command = QueueManager.Is_Open() or
						(TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open()) or
						(TestValid(this.full_screen_movie) and this.full_screen_movie.Has_Movie())
	return intercept_close_command, credits_changed
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

	if ObjectivesSuspended then
		return
	end
	
	if not text_string then
		text_string = ""
	end
	
	if IsLetterboxMode or this.MinorAnnouncement.MoveText.Is_Animating() then
		table.insert(MinorAnnouncementQueue, text_string)
		return
	end

	this.MinorAnnouncement.MinorAnnouncementText.Set_Text(text_string)
	MinorAnnouncementFading = false
	
	if TestValid(this.MinorAnnouncement.Frame) then
		if text_string ~= "" then 		
			-- Size the text frame according to the text in it!.
			local new_height = this.MinorAnnouncement.MinorAnnouncementText.Get_Text_Height()
			local margin = MarginHeight
			if new_height < OrigFrameHeight then 
				new_height = OrigFrameHeight
				margin = MarginHeight * 0.5
			end
			
			Scene.MinorAnnouncement.Frame.Set_World_Bounds(OrigFrameX, OrigFrameY, OrigFrameWidth, new_height + margin)
			Scene.MinorAnnouncement.Frame.Set_Hidden(false)
			this.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(false)
			Scene.MinorAnnouncement.Play_Animation("MinorAnnouncementFade", false)
			Scene.MinorAnnouncement.Set_Animation_Frame(0)	
			MinorAnnouncementFading = true
		else
			Scene.MinorAnnouncement.Frame.Set_Hidden(true)
			this.MinorAnnouncement.MinorAnnouncementText.Set_Hidden(true)
		end
	end		
	
	-- Maria 01.22.2008: Per task request: "'New Objective' text can't hide the cursor"
	-- Controller_Display_Center_Cursor(not MinorAnnouncementFading)
	Tooltip.Force_Hide(MinorAnnouncementFading)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Minor_Announcement_Anim_Finished
-- ------------------------------------------------------------------------------------------------------------------
function Minor_Announcement_Anim_Finished()
	if #MinorAnnouncementQueue > 0 then
		local text = MinorAnnouncementQueue[1] 
		table.remove(MinorAnnouncementQueue, 1)
		this.Raise_Event("Set_Minor_Announcement_Text", nil, { text })
	end
	Controller_Display_Center_Cursor(true)
	MinorAnnouncementFading = false
	Tooltip.Force_Hide(MinorAnnouncementFading)
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
-- On_Suspend_Objectives
-- ------------------------------------------------------------------------------------------------------------------
function On_Suspend_Objectives(_, _, on_off)
	Scene.Objectives.Raise_Event_Immediate("Suspend_Objectives", {on_off })

	if on_off then
		-- Clear the minor announcement text!!!!!!
		MinorAnnouncementQueue = {}
		this.MinorAnnouncement.MinorAnnouncementText.Set_Text("")
		MinorAnnouncementFading = false
	end
	
	ObjectivesSuspended = on_off
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Objectives_Changed
-- ------------------------------------------------------------------------------------------------------------------
function On_Objectives_Changed(_, _, adding, remove_at_index)
	Scene.Objectives.Raise_Event_Immediate("Objectives_Changed", { adding, remove_at_index })
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
		
		if TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open() then
			ReinforcementsMenuManager.Close()
		end
		
		Hide_Research_Tree()
	end
	
	if Hide_All_Faction_Specific_UI then
		Hide_All_Faction_Specific_UI(onoff)
	end
	
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


-- ------------------------------------------------------------------------------------------------------------------
-- Returns true if all game objects have the requested behavior.
-- MLL
-- ------------------------------------------------------------------------------------------------------------------
function Do_Units_Have_Behavior(objects, behavior)
    for index, object in pairs(objects) do
        if not object.Has_Behavior(behavior) then
            return false
        end
    end

    return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Returns true if all game objects have enough health.
-- MLL
-- ------------------------------------------------------------------------------------------------------------------
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

	if not BuilderMenuOpen and not ControllerDisplayingCommandBar then 
		-- there are no buttons being displayed, so nothing to refresh!
		return
	end
	
	for i, button in pairs(BuildButtons) do
		if Mode == MODE_CONSTRUCTION and CommandBarEnabled == true then
			local building_type = button.Get_User_Data()
			if building_type then
				local building_type_name = building_type.Get_Name()
				if button.Is_Button_Enabled() and BuildingTypesToFlash[building_type_name] then
					button.Start_Flash()
				else
					button.Stop_Flash()
				end
			end
		else
			button.Stop_Flash()
		end
	end
	
	-- Do we have to flash the builder button too?	
	if TestValid(BuilderButton) then 
		if FlashBuilderButton and not BuilderButton.Get_Hidden() then 
			BuilderButton.Start_Flash()
		elseif not FlashBuilderButton then
			BuilderButton.Stop_Flash()
		end
	else
		FlashBuilderButton = false
	end		
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
	
	if not button or button.Get_Hidden() or not button.Is_Button_Enabled() then 
		return
	end
	
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
	
	if button.Get_Hidden() or not button.Is_Button_Enabled() then
		return
	end
	
	local user_data = button.Get_User_Data()
	
	-- Since we can activate abilities without clicking on the button (keyboard mappings) it may happen that we are coming through 
	-- with an ability button that is disabled, thus, do not process it!.
	if not user_data then 
		return
	end

	local type_name = user_data.type_name
	local ability = user_data.ability
	
	-- Maria 12.05.2007
	-- The launching of a SW is a 'fake' ability so we handle it differently.
	if ability.sw_type_name then
		Process_Launch_SW_Ability(ability)
	else
		Activate_Ability(ability.unit_ability_name, type_name)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Process_Launch_SW_Ability
-- ------------------------------------------------------------------------------------------------------------------
function Process_Launch_SW_Ability(ability)
	if not ability.sw_type_name then
		return
	end
	if not TestValid(ability.AbilityOwner) then 
		return
	end
	
	if GUI_Can_Fire_Superweapon(ability.sw_type_name, ability.AbilityOwner) then
		-- this weapon can be fired so go ahead.
		local weapon_type = Find_Object_Type(ability.sw_type_name)
		GUI_Begin_Spawn_Superweapon_Targeting(weapon_type, {ability.AbilityOwner})
	end
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
			
			if unit_has_ability then 
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
			if success == true and objects[1].Has_Behavior(68) then
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
			if success == true and objects[1].Has_Behavior(68) then
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
	for _, building in pairs(SelectedBuildings) do
		if building == parent_object then
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
		if parent_object.Has_Behavior(89) then
			for _, building in pairs(SelectedBuildings) do
				if building == parent_object then
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
			if object.Has_Behavior(68) then 
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
			object.Unregister_Signal_Handler(On_Object_Removed_From_Selection_List, this)
			object.Unregister_Signal_Handler(On_Switch_Type, this)
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

-- ------------------------------------------------------------------------------------------------------------------
--  On_Network_Forfeit_Game
-- ------------------------------------------------------------------------------------------------------------------
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

	-- Disable everything except camera control
	Controller_Set_Tactical_Component_Lock("ALL",true)
	Controller_Set_Tactical_Component_Lock("LEFT_STICK",false)
	Controller_Set_Tactical_Component_Lock("RIGHT_STICK",false)
	Controller_Set_Tactical_Component_Lock("RIGHT_TRIGGER",false)
end


-- ------------------------------------------------------------------------------------------------------------------
--  Building_Under_Half_Health - so display the health bar
-- ------------------------------------------------------------------------------------------------------------------
function Building_Under_Half_Health(event, source, object)
	if TestValid(object) then
		local scenes = object.Get_GUI_Scenes()
		if scenes then 
			scenes[1].Set_State("active")
			scenes[1].Enable(true)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
--  Building_Over_Half_Health - so hide the health bar
-- ------------------------------------------------------------------------------------------------------------------
function Building_Over_Half_Health(event, source, object)
	if TestValid(object) then
		local scenes = object.Get_GUI_Scenes()
		if scenes then 
			scenes[1].Set_State("inactive")
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
--  Init_Carousel_Command_Bar - Initilize the gamepad only carousel
-- ------------------------------------------------------------------------------------------------------------------
function Init_Carousel_Command_Bar()
	CommandBar.Set_Hidden(true)
	CommandBar.Set_Tab_Order(TAB_ORDER_COMMAND_BAR)
end


function Reload_Tooltip_Delay()
	MouseOverHoverTime = Get_Profile_Value(PP_TOOLTIP_HINT_DELAY, .5)
	MouseOverHoverTime_Extended = Get_Profile_Value(PP_TOOLTIP_EXPANDED_HINT_DELAY, 1)	
end

-- ------------------------------------------------------------------------------------------------------------------
--  On_Controller_B_Button - B button pressed on the gamepad
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_B_Button() 
	
	if TestValid(QueueManager) and QueueManager.Is_Open() then
		QueueManager.Close()
		if ControllerDisplayingCommandBar then
			CommandBar.Set_Hidden(false)
			UpdateFocusOnNextService = true
		end
	end

	if TestValid(this.Research_Tree) and this.Research_Tree.Is_Open() then
		Hide_Research_Tree()
		UpdateFocusOnNextService = true
	end
	
	if TestValid(ReinforcementsMenuManager) and ReinforcementsMenuManager.Is_Open() then
		ReinforcementsMenuManager.Close()
		
		-- We need to enable the carousel (recall, it was disabled when the menu was opened)
		if ControllerDisplayingResearchAndFactionUI then
			FactionButtons.Enable(true)
		end
	
		UpdateFocusOnNextService = true
	end
	
	-- Faction specific stuff
	if Faction_On_Controller_B_Button and Faction_On_Controller_B_Button() then	
		UpdateFocusOnNextService = true	
	end
end

-- ------------------------------------------------------------------------------------------------------------------
--  On_Player_Faction_Changed
-- ------------------------------------------------------------------------------------------------------------------
function On_Player_Faction_Changed()
	LocalPlayer = Find_Player("local")
	
	if TestValid(GuardButton) and LocalPlayer then
		GuardButton.Set_Texture(FactionToGuardTexturesMap[LocalPlayer.Get_Faction_Name()])
	end
end


-- ------------------------------------------------------------------------------------------------------------------
--  Show_Game_End_Screen
-- ------------------------------------------------------------------------------------------------------------------
function Show_Game_End_Screen(_, _, scene_name, winner, to_main_menu, destroy_loser, build_temp_cc, game_end, for_multiplayer)

	if (for_multiplayer == nil) then
		for_multiplayer = false
	end
	
	local quit_params = {}
	quit_params.Winner = winner
	quit_params.DestroyLoser = destroy_loser
	quit_params.ToMainMenu = to_main_menu
	quit_params.BuildTempCC = build_temp_cc
	quit_params.GameEndTime = game_end
	
	post_game_ui = this[scene_name]
	if not TestValid(post_game_ui) then
		post_game_ui = this.Create_Embedded_Scene(scene_name, scene_name)
	end
	post_game_ui.Set_Bounds(0.0, 0.0, 1.0, 1.0)
	
	-- Maria 01.23.2008
	-- In cases when there are no heroes, this scene is not displayed.  However, it takes a sec to determine that fact which 
	-- causes this scene to be shortly shown.  So, let's hide it as soon as it is created and just unhide it if the scene has
	-- finalized its initialization properly.
	post_game_ui.Set_Hidden(true)
	post_game_ui.Bring_To_Front()
	post_game_ui.Set_User_Data(quit_params)
	if (for_multiplayer) then
		post_game_ui.Set_Dialog_For_Multiplayer(for_multiplayer)
	end
	if post_game_ui.Finalize_Init() then
		post_game_ui.Set_Hidden(false)
		post_game_ui.Start_Modal(Really_Quit)
	else
		_Quit_Game_Now(winner, to_main_menu, destroy_loser, build_temp_cc)
	end	
end

function Really_Quit(post_game_ui)
	local quit_params = post_game_ui.Get_User_Data()
	_Quit_Game_Now(quit_params.Winner, quit_params.ToMainMenu, quit_params.DestroyLoser, quit_params.BuildTempCC)
	post_game_ui = nil
end

function Show_Retry_Mission_Screen(_, _, scene_file, scene_name)

	local retry_dialog = nil
	local game_scene = Get_Game_Mode_GUI_Scene()
	if TestValid(game_scene.RetryDialog) then
		retry_dialog = game_scene.RetryDialog
		retry_dialog.Set_Hidden(false)
	else
		retry_dialog = game_scene.Create_Embedded_Scene(scene_file, scene_name)
		retry_dialog.Set_Can_Be_Disabled(false)
	end
	retry_dialog.Set_Screen_Position(0.5, 0.5)
	retry_dialog.Start_Modal(On_Retry_Response)

end

-- ------------------------------------------------------------------------------------------------------------------
--  Register_Hidden_Events
-- ------------------------------------------------------------------------------------------------------------------
function Register_Hidden_Events()
	-- EMP these components were not getting the global events because the animation is stealing them
	-- Todo: put this in code.
	this.Register_Event_Handler("Component_Hidden",		this.FactionButtons.Carousel, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden",	this.FactionButtons.Carousel, Enable_UI_Element_Event)
	this.Register_Event_Handler("Component_Hidden",		this.CommandBar.Carousel_CommandBar, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden",	this.CommandBar.Carousel_CommandBar, Enable_UI_Element_Event)
	this.Register_Event_Handler("Component_Hidden",		this.CommandBar.Carousel_BuildQueue, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden",	this.CommandBar.Carousel_BuildQueue, Enable_UI_Element_Event)
	this.Register_Event_Handler("Component_Hidden",		this.CommandBar.Carousel_SpecialAbilityButtons, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden",	this.CommandBar.Carousel_SpecialAbilityButtons, Enable_UI_Element_Event)
	this.Register_Event_Handler("Component_Hidden",		this.CommandBar.CarouselButtons, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden",	this.CommandBar.CarouselButtons, Enable_UI_Element_Event)
end



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
	Debug_Switch_Sides = nil
	Define_Retry_State = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Hero_Button = nil
	GUI_Cancel_Talking_Head = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Pool_Free = nil
	Gamepad_Point_Camera_At_Next_Builder = nil
	Get_Button_Index_For_Unit_Type = nil
	Get_Chat_Color_Index = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Selected_Unit_Type_For_Button_Index = nil
	Hot_Key_Activate_Unit_Ability = nil
	Init_Control_Group_Textures_Prefix_Map = nil
	Init_Tab_Orders = nil
	Init_Tactical_Command_Bar_Common = nil
	Is_First_Button = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Build_Button_Focus_Gained = nil
	On_Handle_BattleCam_Button_Up = nil
	On_Mouse_Off_Hero_Button = nil
	On_Mouse_Over_Hero_Button = nil
	On_Remove_Xbox_Controller_Hint = nil
	On_Set_Achievement_Buff_Display_Model = nil
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
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Show_Retry_Dialog = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Common_Scene = nil
	Update_Mouse_Buttons = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

