if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Skirmish_Setup_Dialog.lua#57 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Skirmish_Setup_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Joe_Howes $
--
--            $Change: 95987 $
--
--          $DateTime: 2008/03/31 09:49:26 $
--
--          $Revision: #57 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGNetwork")
require("PGColors")
require("PGCrontab")
require("PGPlayerProfile")
require("PGOnlineAchievementDefs")
require("PGOfflineAchievementDefs")
require("PGFactions")
require("Lobby_Network_Logic")
require("PGMapOverlayManager")

ScriptPoolCount = 0


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function GUI_Init()

	-- Library init
	PGColors_Init()
	PGNetwork_Init()
	PGFactions_Init()
	PGPlayerProfile_Init()
	PGCrontab_Init()
	PGOnlineAchievementDefs_Init()
	PGLobby_Vars_Init()
	PGMO_Initialize()

	-- Constants
	Constants_Init()
	
	-- Variables
	Variables_Init()
	
	-- Components
	Initialize_Components()
	Initialize_Traversal()
	LocalClient = {}
	Update_Local_Client()
	Set_Currently_Selected_Client(LocalClient)
	Update_Selected_Player_View()
	
	-- Event handlers
	this.Register_Event_Handler("Closing_All_Displays", nil, View_Back_Out)
	this.Register_Event_Handler("On_Player_Cluster_Clicked", nil, On_Player_Cluster_Clicked)
	this.Register_Event_Handler("On_Menu_System_Activated", nil, On_Menu_System_Activated)
	this.Register_Event_Handler("Component_Unhidden", this, On_Component_Shown)
	this.Register_Event_Handler("Component_Hidden", this, On_Component_Hidden)

	-- Maria 10.16.2007
	-- Integrating the latest changes in the MP lobbies from the PC branch.  For now, let's hide this button
	-- NOTE: this button is placed in the Skrimish setup scene in the PC version but not in the Gamepad version
	this.Button_Medal_Chest.Set_Hidden(true)
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Medal_Chest, Play_Mouse_Over_Button_SFX)
	
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Next, Play_Mouse_Over_Button_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Back, Play_Mouse_Over_Button_SFX)

	this.Register_Event_Handler("Mouse_Left_Down", this.Button_Next, Play_Button_Select_SFX)		
	this.Register_Event_Handler("Mouse_Left_Down", this.Button_Back, Play_Button_Select_SFX)
	this.Register_Event_Handler("Mouse_Left_Down", this.Button_Medal_Chest, Play_Button_Select_SFX)

	this.Register_Event_Handler("Ready_Clicked", nil, On_Ready_Clicked)
	this.Register_Event_Handler("Player_Faction_Up_Clicked", nil, On_Player_Faction_Up_Clicked)
	this.Register_Event_Handler("Player_Faction_Down_Clicked", nil, On_Player_Faction_Down_Clicked)
	this.Register_Event_Handler("Player_Team_Up_Clicked", nil, On_Player_Team_Up_Clicked)
	this.Register_Event_Handler("Player_Team_Down_Clicked", nil, On_Player_Team_Down_Clicked)
	this.Register_Event_Handler("Player_Color_Up_Clicked", nil, On_Player_Color_Up_Clicked)
	this.Register_Event_Handler("Player_Color_Down_Clicked", nil, On_Player_Color_Down_Clicked)
	this.Register_Event_Handler("Player_Difficulty_Up_Clicked", nil, On_Player_Difficulty_Up_Clicked)
	this.Register_Event_Handler("Player_Difficulty_Down_Clicked", nil, On_Player_Difficulty_Down_Clicked)
	this.Register_Event_Handler("Info_Cluster_State_Changed", nil, On_Info_Cluster_State_Changed)
	this.Register_Event_Handler("Player_Difficulty_Set", nil, On_Player_Difficulty_Set)
	
	this.Register_Event_Handler("Spawn_Location_Up", nil, On_Spawn_Location_Up)
	this.Register_Event_Handler("Spawn_Location_Down", nil, On_Spawn_Location_Down)
	
	this.Register_Event_Handler("AI_Player_Added", nil, On_AI_Player_Added)
	this.Register_Event_Handler("AI_Player_Removed", nil, On_AI_Player_Removed)

	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_Map, On_Combo_Map_Selection_Changed)

	this.Register_Event_Handler("Mouse_Move", nil, On_Mouse_Move)
	this.Register_Event_Handler("On_Medal_Mouse_On", nil, On_Medal_Mouse_On)
	this.Register_Event_Handler("On_Medal_Mouse_Off", nil, On_Medal_Mouse_Off)

	this.Register_Event_Handler("Mouse_Left_Up", this, On_Empty_Space_Clicked)
	
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Controller_A_Button_Up", nil, On_Next_Clicked)
	this.Register_Event_Handler("Controller_Start_Button_Up", nil, On_Controller_Start_Button_Up)
	this.Register_Event_Handler("Cluster_Claiming_Focus", nil, On_Cluster_Claiming_Focus)
	-- ----------------------------------------------------------------------------------------------------------------
	-- Network events to listen for (for skirmish we only care about LIVE signin / signout).
	-- ----------------------------------------------------------------------------------------------------------------
	Network_Event_Table = 
	{
		["TASK_LIVE_SIGNIN_CHANGED"]		= Network_On_Live_Signin_Changed,
	}
	Net.Register_Event_Handler(On_Network_Event)
	
	-- [NSA 08/30/2007]:  Register for heavyweight embedded scenes closing so that we can start and stop our movies.
	this.Register_Event_Handler("Heavyweight_Child_Scene_Closing", nil, Heavyweight_Child_Scene_Closing)
	
	Initialize_View_State(VIEW_STATE_GAME_OPTIONS_HOST)
	Refresh_UI()
	Populate_UI_From_Profile()
	PGLobby_Activate_Movies()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_SKIRMISH })

	--Only register for sfx handlers once everything is setup, otherwise there will be a flurry of sound when the dialog starts
	Register_SFX_Event_Handlers()

	SomethingHasFocus = false
	SuppressSFX = false
	
end

function Register_SFX_Event_Handlers()
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_Map, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Setup.Combo_Map, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_Win_Condition, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Setup.Combo_Win_Condition, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_DEFCON_Active, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Setup.Combo_DEFCON_Active, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_Hero_Respawn, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Setup.Combo_Hero_Respawn, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_Starting_Credits, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Setup.Combo_Starting_Credits, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Panel_Game_Setup.Combo_Unit_Population_Limit, Play_Option_Select_SFX)
	this.Register_Event_Handler("Key_Focus_Gained", this.Panel_Game_Setup.Combo_Unit_Population_Limit, Play_Mouse_Over_Option_SFX)
end

-------------------------------------------------------------------------------
-- Individually sets up every GUI component in the scene.
--
-- NOTE:::  By default, yes/no, on/off, enabled/disabled combos are populated
-- first with the off option.
-------------------------------------------------------------------------------
function Initialize_Components()

	PGLobby_Set_Dialog_Is_Hidden(false)

	-- --------------------------
	-- GAME SETUP PANEL
	-- --------------------------
	Initialize_Filters()
	
	-- --------------------------
	-- GAME STAGING PANEL
	-- --------------------------
	
	-- Set up the player clusters so they can be procedurally iterated over.
	local panel = this.Panel_Game_Staging
	local clusters = Find_GUI_Components(panel, "Player_Cluster_")
	
	for index, cluster in ipairs(clusters) do
	
		local map = {}
		map.Handle = cluster
		map.Handle.Set_Hidden(true)
		map.Handle.Set_Seat(index)
		map.Handle.Set_Accept_UI_Visible(false)
		table.insert(ViewPlayerInfoClusters, map)
	
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_Traversal()

	-- TAB ORDER --
	-- Setups Panel
	local panel = this.Panel_Game_Setup
	panel.Combo_Map.Set_Tab_Order(Declare_Enum())
	panel.Combo_Win_Condition.Set_Tab_Order(Declare_Enum())
	panel.Combo_DEFCON_Active.Set_Tab_Order(Declare_Enum())
	panel.Combo_Hero_Respawn.Set_Tab_Order(Declare_Enum())
	panel.Combo_Starting_Credits.Set_Tab_Order(Declare_Enum())
	panel.Combo_Unit_Population_Limit.Set_Tab_Order(Declare_Enum())

	
	-- Base Panel
	panel = this
--	panel.Button_Back.Set_Tab_Order(Declare_Enum())
--	panel.Button_Medal_Chest.Set_Tab_Order(Declare_Enum())
--	panel.Button_Next.Set_Tab_Order(Declare_Enum())	
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_Filters()

	--JSY: removed sfx event handler registration from this function since it's called multiple times

	ViewSetupComponents = {}
	
	-- Set up some defaults.
	HostGameDefaults = {}
	HostGameDefaults.VictoryCondition = 1
	HostGameDefaults.DEFCON = 0
	HostGameDefaults.HeroRespawn = 0
	HostGameDefaults.StartingCredits = 1
	HostGameDefaults.PopCap = 10
	
	-- Initialize the Map combo
	local new_row = -1
	local player_count = Network_Get_Client_Table_Count(true)
	local handle = this.Panel_Game_Setup.Combo_Map
	handle.Clear()
	for _, dao in pairs(MPMapModel) do
		local display = Create_Wide_String()
		display.assign(dao.display_name)
		display.append(" (" .. dao.num_players .. ")")
		new_row = handle.Add_Item(display)
		handle.Set_Item_Color(new_row, 1, 1, 1, 1)
	end
	table.insert(ViewSetupComponents, handle)
		
	--Initialize the victory condition combo
	handle = this.Panel_Game_Setup.Combo_Win_Condition
	handle.Clear()
	for _, condition in pairs(VictoryConditionNames) do
		handle.Add_Item(condition)
	end
	table.insert(ViewSetupComponents, handle)
	
	-- Initialize the DEFCON combo
	handle = this.Panel_Game_Setup.Combo_DEFCON_Active
	handle.Clear()
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	table.insert(ViewSetupComponents, handle)
	
	-- Initialize the hero respawn combo
	handle = this.Panel_Game_Setup.Combo_Hero_Respawn
	handle.Clear()
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	table.insert(ViewSetupComponents, handle)
	
	-- Initialize the starting credits combo
	handle = this.Panel_Game_Setup.Combo_Starting_Credits
	handle.Clear()
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_SMALL])
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_MEDIUM])
	handle.Add_Item(GAME_CREDITS_LEVEL_VIEW[PG_FACTION_CASH_LARGE])
	table.insert(ViewSetupComponents, handle)
		
	-- Initialize the population cap combo
	handle = this.Panel_Game_Setup.Combo_Unit_Population_Limit
	handle.Clear()
	for i = 40, 90, 5 do
		handle.Add_Item(Get_Localized_Formatted_Number(i))
	end
	table.insert(ViewSetupComponents, handle)
	
	Capture_Setup_Settings()
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Set_Host_Defaults()

	--We're changing combo boxes from script and don't want to cause a flurry of sound
	SuppressSFX = true

	local panel = this.Panel_Game_Setup
	
	panel.Combo_Win_Condition.Set_Selected_Index(HostGameDefaults.VictoryCondition)
	panel.Combo_DEFCON_Active.Set_Selected_Index(HostGameDefaults.DEFCON)
	panel.Combo_Hero_Respawn.Set_Selected_Index(HostGameDefaults.HeroRespawn)
	panel.Combo_Starting_Credits.Set_Selected_Index(HostGameDefaults.StartingCredits)
	panel.Combo_Unit_Population_Limit.Set_Selected_Index(HostGameDefaults.PopCap)
	
	SuppressSFX = false
end

------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
		end
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			if source == this.Button_Back then
				Play_SFX_Event("GUI_Main_Menu_Back_Select")
			else
				Play_SFX_Event("GUI_Main_Menu_Button_Select")
			end
		end
	end
end


------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			Play_SFX_Event("GUI_Main_Menu_Options_Select")
		end
	end
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Option_SFX(event, source)
	if not SuppressSFX then
		if source and source.Is_Enabled() == true then 
			Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
		end
	end
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Update_Selected_Player_View()

	if CurrentlySelectedClient == nil then return end

	-- Color
	local seat = Network_Get_Seat(CurrentlySelectedClient)
	PGMO_Set_Seat_Color(seat, CurrentlySelectedClient.color)
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Constants_Init()

	VIEW_STATE_GAME_OPTIONS_HOST = Declare_Enum(1)
	VIEW_STATE_GAME_OPTIONS_HOST_STAGING = Declare_Enum()
	VIEW_STATE_GAME_STAGING = Declare_Enum()
	
	SYSTEM_CHAT_COLOR = 1
	
	VIEW_CLUSTER_COLUMN_LEFT_X = 0.200
	VIEW_CLUSTER_COLUMN_LEFT_Y = 0.220
	VIEW_CLUSTER_COLUMN_RIGHT_X = 0.82
	VIEW_CLUSTER_COLUMN_RIGHT_Y = 0.220
	VIEW_CLUSTER_COLUMN_VERTICAL_DELTA = 0.130
	
	VIEW_MAX_TEAM = MAX_TEAMS
	
	VIEW_MAX_PLAYER_COUNT = MAP_MAX_PLAYER_COUNT
	
	AVAILABLE_SESSIONS_REFRESH_PERIOD = 3
	CLIENT_VALIDATION_PERIOD = 5
	
	LOBBY_DEFAULT_FACTION = PG_FACTION_NOVUS
	LOBBY_DEFAULT_TEAM = 1
	LOBBY_DEFAULT_COLOR = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[0]
	
	NO_MAP_PREVIEW_TEXTURE = "i_no_button.tga"
	SPINNER_UP_NORMAL = "i_combobox_small_up.tga"
	SPINNER_DOWN_NORMAL = "i_combobox_small_down.tga"
	SPINNER_UP_HIGHLIGHT = "i_combobox_small_up_mouse_over.tga"
	SPINNER_DOWN_HIGHLIGHT = "i_combobox_small_down_mouse_over.tga"
	
	TEXT_NO = Get_Game_Text("TEXT_NO")
	TEXT_YES = Get_Game_Text("TEXT_YES")
	LAUNCH_GAME = Get_Game_Text("TEXT_MULTIPLAYER_BUTTON_LAUNCH_GAME")
	NEXT = Get_Game_Text("TEXT_BUTTON_NEXT")

	COMBO_SELECTION_NO	= 0
	COMBO_SELECTION_YES	= 1
	
	GAME_COUNTDOWN_SECONDS = 5
	
	WARNING_TINT = ({ [5] = { a = 1, b = 0, g = 1, r = 0, }, [2] = { a = 1, b = 0, g = 0, r = 1, }, [7] = { a = 1, b = 1, g = 0, r = 0, }, [4] = { a = 1, b = 0, g = 1, r = 1, }, })[4]
	STANDARD_TINT = ({ a = 1, b = 1, g = 1, r = 1, })
	
end

-------------------------------------------------------------------------------
-- This function should only be called once, on initial creation of the scene.
-------------------------------------------------------------------------------
function Variables_Init()
	
	-- View Layer Variables
	ViewPlayerInfoClusters = {}
	MPMapModel = PGLobby_Generate_Map_Selection_Model()	-- List of multiplayer maps.
	ViewState = VIEW_STATE_GAME_OPTIONS_HOST
	StartingViewState = VIEW_STATE_GAME_OPTIONS_HOST
	ViewStateStack = {}
	PGMO_Clear()
	PGMO_Set_Justification(SCREEN_JUSTIFY_CENTER)
	
	-- Data Layer Variables
	Variables_Reset()
	IsShowing = true

	-- Needed for certain networking functions to behave properly
	HostingGame = true
	
	RestartingMap = false
	ConnectionChangeOccurred = false

end

-------------------------------------------------------------------------------
-- This function may be called multiple times in order to reset all variables.
-------------------------------------------------------------------------------
function Variables_Reset()

	ClientTable = {}
	GameScriptData = {}
	GameScriptData.victory_condition = VICTORY_CONQUER
	GameScriptData.is_defcon_game = false
	GameScriptData.medals_enabled = true

	CurrentlySelectedClient = nil
	CurrentlySelectedSession = nil
	GameIsStarting = false
	GameHasStarted = false
	ConnectionChangeOccurred = false
	ViewSetupsSettings = nil
	AIPlayerCount = 0
	
	LocalClient = {}
	Update_Local_Client()
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- V I E W   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()
	PGCrontab_Update()
	if ( not SomethingHasFocus ) then
		this.Focus_First()
		SomethingHasFocus = true
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Mouse_Move(event, source)
	PGLobby_Mouse_Move()
	PGMO_Mouse_Move()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Medal_Mouse_On(event, source, achievement_id)

	local achievement = OnlineAchievementMap[achievement_id]
	if (achievement ~= nil) then
		local model = {}
		model.text_title = Get_Game_Text(achievement.Name)
		model.text_body = Get_Game_Text(achievement.BuffDesc)
		model.icon_texture = achievement.Texture
		
		PGLobby_Set_Tooltip_Model(model)
		PGLobby_Set_Tooltip_Visible(true)
	end
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Medal_Mouse_Off(event, source)
	PGLobby_Set_Tooltip_Visible(false)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Empty_Space_Clicked()

	--[[ Removed by design
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		-- Deselect the currently selected client
		Set_Currently_Selected_Client()
		Update_Player_List()
	end
	]]

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Set_Default_Clicked()
	Set_Host_Defaults()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	Net.Register_Event_Handler(On_Network_Event)
	PGLobby_Set_Dialog_Is_Hidden(false)
	Variables_Reset()
	Initialize_Filters()
	Update_Selected_Player_View()
	Refresh_UI()
	Populate_UI_From_Profile()
	PGLobby_Activate_Movies()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_SKIRMISH })
	SomethingHasFocus = false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	Net.Unregister_Event_Handler(On_Network_Event)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Close_Dialog()
	if (TestValid(this.Achievement_Chest)) then
		this.Achievement_Chest.Set_Hidden(true)
		this.Achievement_Chest.End_Modal()
	end

	Clear_UI()
	this.End_Modal()
	this.Get_Containing_Component().Set_Hidden(true)
	PGLobby_Passivate_Movies()
	PGLobby_Set_Dialog_Is_Hidden(true)
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Skirmish_Setup_Dialog"})
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function View_Back_Out()

	-- If the achievement chest is showing hide it.
	if (TestValid(this.Achievement_Chest) and this.Achievement_Chest.Is_Showing()) then
		this.Achievement_Chest.Set_Hidden(true)
		return
	end
	
	-- Clear the map overlay.
	PGMO_Clear()
	
	-- Cleanup backouts.
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		Leave_Game()
	elseif (ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING) then
		Set_Currently_Selected_Client(LocalClient)
	end
	
	-- Get the last view state off the stack.
	local state = Pop_View_State()
	
	-- If there is no last view state, we go back to the main menu.
	if (state == nil) then
		Leave_Game()
		Close_Dialog()
		return
	end
	
	-- Set the view state (not with Set_View_State() ... would mess up the stack.)
	ViewState = state
	PGLobby_Set_Tooltip_Visible(false)

	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		Initialize_Filters()
		Populate_UI_From_Profile()
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
		Update_Player_List()
	end
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function View_Back_To_Start()

	-- If the achievement chest is showing hide it.
	if (TestValid(this.Achievement_Chest) and this.Achievement_Chest.Is_Showing()) then
		this.Achievement_Chest.Set_Hidden(true)
		this.Achievement_Chest.End_Modal()
	end
	
	-- Cleanup backouts.
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		Leave_Game()
	end
	
	Clear_View_Stack()
	Initialize_View_State(StartingViewState)
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Clear_View_Stack()
	ViewStateStack = {}
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Back_Clicked()
	Persist_UI_To_Profile()
	Populate_Setup_Settings()
	View_Back_Out()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function On_Medal_Chest_Clicked()

	if not TestValid(this.Achievement_Chest) then
		local handle = Create_Embedded_Scene("Achievement_Chest", this, "Achievement_Chest")
	else
		this.Achievement_Chest.Set_Hidden(false)
	end
	
	PGLobby_Passivate_Movies()
	MedalChestOpen = true

end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Next_Clicked()
	
	-- Is the go button enabled? 
	if ( this.Panel_Game_Setup.Get_Hidden() ) then
		return
	end

	Persist_UI_To_Profile()
		
	PGMO_Clear()
	Set_View_State(VIEW_STATE_GAME_STAGING)
	Capture_Setup_Settings()
	Populate_UI_From_Profile()
	Initialize_Game_Hosting()
	Do_Host_Game()
	Update_Player_List()
		
	Cluster_Need_Focus = true
		
	Update_Selected_Player_View()
	Refresh_UI()
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Controller_Start_Button_Up()

	-- Is the go button enabled? 
	local hidden = this.Panel_Game_Staging.Get_Hidden()
	local enabled = this.Panel_Game_Staging.Button_Launch_Game.Is_Enabled()
	if ( hidden or	not enabled ) then
		return
	end
	Persist_UI_To_Profile()	
	Commit_Profile_Values()
	Start_Game()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Ready_Clicked()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Info_Cluster_State_Changed(event, source, state, seat)

	if (not HostingGame) then return end

	local triple = { }
	if state == CLUSTER_STATE_OPEN then
		MaxPlayerCount = MaxPlayerCount + 1
		local client = ClientSeatAssignments[seat]
		if client ~= nil and client.common_addr ~= nil then
			Network_Remove_Client(client)
		end
		triple.is_closed = false
		ClientSeatAssignments[seat] = triple
	elseif state == CLUSTER_STATE_CLOSED then
		MaxPlayerCount = MaxPlayerCount - 1
		local client = ClientSeatAssignments[seat]
		if client ~= nil and client.common_addr ~= nil then
			Network_Remove_Client(client)
		end
		triple.is_closed = true
		ClientSeatAssignments[seat] = triple
--	elseif state == CLUSTER_STATE_RESERVED then
	end

	Update_Player_List()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_AI_Player_Added(event, source, seat)
	local ai_player = Network_Add_AI_Player(true)
	ai_player.seat = seat
	Network_Assign_Guest_Seat(ai_player, seat)
	Update_Player_List()

	Refresh_Game_Settings_Model(true)
	Refresh_Game_Settings_View()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_AI_Player_Removed(event, source, common_addr)

	local client = Network_Get_Client(common_addr)
	
	if client == nil then
		return
	end
	
	Network_Kick_AI_Player(client)
	Update_Player_List()

	Refresh_Game_Settings_Model(true)
	Refresh_Game_Settings_View()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Faction_Up_Clicked()

	local client = CurrentlySelectedClient

	client.faction = client.faction - 1
	if (client.faction < PG_SELECTABLE_FACTION_MIN) then
		client.faction = PG_SELECTABLE_FACTION_MAX
	end
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.faction = client.faction
	end
	
	Update_Local_Client()	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Faction_Down_Clicked()

	local client = CurrentlySelectedClient
		
	client.faction = client.faction + 1
	if (client.faction > PG_SELECTABLE_FACTION_MAX) then
		client.faction = PG_SELECTABLE_FACTION_MIN
	end
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.faction = client.faction
	end
	
	Update_Local_Client()	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Team_Up_Clicked()

	local client = CurrentlySelectedClient
	
	local team = client.team + 1
	if (team > VIEW_MAX_TEAM) then
		team = 1
	end
	client.team = team

	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.team = client.team
	end
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Team_Down_Clicked()

	local client = CurrentlySelectedClient
		
	local team = client.team - 1
	if (team < 1) then
		team = VIEW_MAX_TEAM
	end
	client.team = team
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.team = client.team
	end
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Color_Up_Clicked()

	local client = CurrentlySelectedClient
	
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[client.color]
	index = index - 1
	if (index < 0) then
		index = 7
	end
	client.color = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[index]
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.color = client.color
	end
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Color_Down_Clicked()

	local client = CurrentlySelectedClient
	
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[client.color]
	index = index + 1
	if (index > 7) then
		index = 0
	end
	client.color = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[index]
	
	if (client.common_addr == LocalClient.common_addr) then
		LocalClient.color = client.color
	end
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Difficulty_Up_Clicked()

	local client = CurrentlySelectedClient

	client.ai_difficulty = client.ai_difficulty + 1
	if (client.ai_difficulty > Difficulty_Hard) then
		client.ai_difficulty = Difficulty_Easy
	end
	client.name = Network_Get_AI_Name(client.ai_difficulty)
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Difficulty_Down_Clicked()

	local client = CurrentlySelectedClient

	client.ai_difficulty = client.ai_difficulty - 1
	if (client.ai_difficulty < Difficulty_Easy) then
		client.ai_difficulty = Difficulty_Hard
	end
	client.name = Network_Get_AI_Name(client.ai_difficulty)
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()

end		
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Difficulty_Set(event, source, new_level)

	local client = CurrentlySelectedClient

	client.ai_difficulty = new_level
	if (client.ai_difficulty < Difficulty_Easy) then
		client.ai_difficulty = Difficulty_Hard
	end
	if (client.ai_difficulty > Difficulty_Hard) then
		client.ai_difficulty = Difficulty_Easy
	end

	client.name = Network_Get_AI_Name(client.ai_difficulty)
	
	Update_Selected_Player_View()
	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()

end		

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Spawn_Location_Up(event, source, seat)

	Advance_Next_Spawn_Position(seat, false)		-- False means advance incrementally.
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Spawn_Location_Down(event, source, seat)

	Advance_Next_Spawn_Position(seat, true)		-- True means advance decrementally.

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Advance_Next_Spawn_Position(seat, reverse)

	-- You must be allowed to edit the selected client
	if Client_Editing_Enabled == false then
		return
	end

	-- Make sure there's a client selected.
	local target_client = CurrentlySelectedClient
	if (target_client == nil) then
		DebugMessage("LUA_LOBBY: ERROR: Unable to process start marker selection because the currently selected client is invalid.")
		return
	end
	
	if (reverse == nil) then
		reverse = false
	end
	
	-- Use the currently selected start marker (if any) to figure out what the new one should be.
	local cur_start_marker_id = PGMO_Get_Start_Marker_ID_From_Seat(seat)	-- this returns 1-8 (index number)
	local new_start_marker_id = -1
		
	if ( PGMO_Is_Seat_Assigned(seat) ) then
	
		-- seat is given a spawn, move to next
		if (reverse) then
			new_start_marker_id = PGMO_Get_Reverse_First_Empty_Start_Position(seat, cur_start_marker_id - 1)
		else
			new_start_marker_id = PGMO_Get_First_Empty_Start_Position(seat, cur_start_marker_id + 1)
		end
		
	else
	
		-- seat is free
		if (reverse) then
			new_start_marker_id = PGMO_Get_Reverse_First_Empty_Start_Position(seat)
		else
			new_start_marker_id = PGMO_Get_First_Empty_Start_Position(seat)
		end
		
	end
		
	-- If there's a new marker available, attempt to claim it, otherwise clear the current one.
	if ( new_start_marker_id ~= nil and new_start_marker_id ~= -1 ) then
	
		-- new seat was found
		target_client.start_marker_id = new_start_marker_id
		-- If we're the host and the target was an AI, the request will be processed and assigned.
		PGMO_Assign_Start_Position(new_start_marker_id, seat, target_client.color)
		
	else
	
		-- new seat not found above, clear for random start
		Clear_Start_Position(cur_start_marker_id, target_client)
		
	end
	
	Update_Player_List()

end

	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Combo_Map_Selection_Changed(_, source)

	local index = this.Panel_Game_Setup.Combo_Map.Get_Selected_Index() 
	local map_dao = MPMapModel[index + 1]		-- MPMapModel is 1-based
		
	-- If the dao is nil, show the spinning globe.  Otherwise show the map and overlay
	if ((map_dao == nil) or map_dao.incomplete) then
		
		PGMO_Set_Enabled(false)
		this.Panel_Game_Setup.Quad_Map_Preview.Set_Hidden(true)
		this.Panel_Game_Setup.Globe_Movie.Play()
		PGMO_Hide()
		this.Panel_Game_Setup.Text_Player_Count.Set_Text("")

	else

		this.Panel_Game_Setup.Quad_Map_Preview.Set_Hidden(false)
		this.Panel_Game_Setup.Globe_Movie.Stop()
		PGMO_Show()

		-- Preview quad texture
		local map_preview = map_dao.file_name_no_extension
		map_preview = map_preview .. ".tga"
		local player_count_text = Get_Game_Text("TEXT_GAMEPAD_MULTIPLAYER_MAP_PLAYER_COUNT")
		local localized_player_count = Get_Localized_Formatted_Number(map_dao.num_players)
		Replace_Token(player_count_text, localized_player_count, 1)

		-- Map Overlay
		PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions)
		PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)

		-- Update the preview textures.
		this.Panel_Game_Setup.Quad_Map_Preview.Set_Texture(tostring(map_preview))
		this.Panel_Game_Setup.Quad_Map_Preview.Set_Render_Mode(0)
		this.Panel_Game_Setup.Text_Player_Count.Set_Text(player_count_text)

	end
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Player_Cluster_Clicked(event_label, _, common_addr)

	if ( common_addr == nil ) then
		Update_Selected_Player_View()
		Update_Player_List()
	end

	local client = Network_Get_Client(common_addr)
	
	if client == nil then
		return
	end
	
	Set_Currently_Selected_Client(client)
	Update_Selected_Player_View()
	Update_Player_List()
	
	Refresh_UI()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_On_Start_Marker_Clicked(source)

	-- You must be allowed to edit the selected client
	if Client_Editing_Enabled == false then
		return
	end

	local target_client = CurrentlySelectedClient
	if (target_client == nil) then
		DebugMessage("LUA_LOBBY: ERROR: Unable to process start marker selection because the currently selected client is invalid.")
		return
	end

	-- If we haven't been assigned a seat yet, we can't choose a marker.
	local target_client_seat = Network_Get_Seat(target_client)
	if (target_client_seat == nil) then
		DebugMessage("LUA_LOBBY: User attempted to select a start position before seat assignment.")
		return
	end

	-- Is the start marker free?
	local start_marker_id = PGMO_Get_Start_Marker_ID(source)
	local start_marker_seat = PGMO_Get_Seat_Assignment(start_marker_id)
	
	-- Is this marker already taken?
	if (start_marker_seat ~= -1) then
	
		if (target_client_seat == start_marker_seat) then
			-- The user is giving up his start marker.
			DebugMessage("LUA_LOBBY: User is clearing their start marker.")
			Clear_Start_Position(start_marker_id, target_client)
			return
		else
			DebugMessage("LUA_LOBBY: User selected a start marker which is already taken by someone else.")
			return
		end
		
	end
	
	DebugMessage("LUA_LOBBY: User is requesting a start marker.")
	
	-- If we're the host and the target was an AI, the request will be processed and assigned.
	PGMO_Assign_Start_Position(start_marker_id, target_client_seat, target_client.color)
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Clear_Start_Position(start_marker_id, client)

	PGMO_Clear_Start_Position(start_marker_id) 
	client.start_marker_id = nil

end

-------------------------------------------------------------------------------
-- The first call to set the view state needs to avoid the traversal stack.
-------------------------------------------------------------------------------
function Initialize_View_State(state)
	ViewState = state
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_View_State(state)

	Push_View_State(ViewState)
	ViewState = state
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Push_View_State(state)
	if (state ~= nil) then
		table.insert(ViewStateStack, state)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Pop_View_State()

	if (#ViewStateStack <= 0) then
		return nil
	end

	local result = table.remove(ViewStateStack)
	return result
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Currently_Selected_Session(session)
	CurrentlySelectedSession = session	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Currently_Selected_Session()
	return CurrentlySelectedSession
end

-------------------------------------------------------------------------------
-- This function is the central locus of presentation for the entire lobby.
-- All code related to showing/hiding UI elements, population and configuration
-- of UI elements, or any view-layer functionality related to a view state 
-- change should be implemented here.
-------------------------------------------------------------------------------
function Refresh_UI()

	-- ------------------------------------------------------------------------
	-- Handle visibility of the tier 1 panels
	-- ------------------------------------------------------------------------
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
			
		this.Panel_Game_Setup.Set_Hidden(false)
		this.Panel_Game_Staging.Set_Hidden(true)
		PGMO_Bind_To_Quad(this.Panel_Game_Setup.Quad_Map_Preview)
		PGMO_Set_Enabled(true)
		PGMO_Set_Interactive(false)
		PGMO_Show()
		
		Set_Player_Clusters_Visible(false)

	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		-- General buttons
		this.Panel_Game_Setup.Set_Hidden(true)
		this.Panel_Game_Staging.Set_Hidden(false)
		PGMO_Bind_To_Quad(this.Panel_Game_Staging.Quad_Map_Preview)
		PGMO_Set_Enabled(true)
		PGMO_Set_Interactive(true)
		PGMO_Show()

		-- Can we edit the selected client?
		if (CurrentlySelectedClient == nil) then
		
			Set_Selected_Client_Editing_Enabled(false)
			
		else
		
			-- We're host.  We can select anyone in the game, but can only edit
			-- ourself or AIs.
			if (CurrentlySelectedClient.is_ai or (CurrentlySelectedClient.common_addr == LocalClient.common_addr)) then
				Set_Selected_Client_Editing_Enabled(true, CurrentlySelectedClient.is_ai)
			else
				Set_Selected_Client_Editing_Enabled(false)
			end
		
		end

		Refresh_Game_Settings_View()
		Update_Player_List()
		
	end

	-- ------------------------------------------------------------------------
	-- Make sure that movies that are NOT visible are stopped.
	-- ------------------------------------------------------------------------
	if (ViewState == VIEW_STATE_MAIN) then
	
		this.Panel_Game_Setup.Globe_Movie.Stop()
		
	elseif ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then

	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
	
		this.Panel_Game_Setup.Globe_Movie.Stop()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		this.Panel_Game_Setup.Globe_Movie.Stop()
		
	end
	
	if ( Cluster_Need_Focus ) then
		Skirmish_Setup_Dialog.Panel_Game_Staging.Player_Cluster_1.Set_Focus_First()
		Cluster_Need_Focus = false
	end
	
end

-------------------------------------------------------------------------------
-- Any UI elements which may be holding data that shouldn't persist when 
-- the lobby is backed out of should be cleared here.
-------------------------------------------------------------------------------
function Clear_UI()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Player_Clusters_Visible(value)

	local hidden = not value
	
	for _, map in ipairs(ViewPlayerInfoClusters) do
		map.Handle.Set_Hidden(hidden)
	end
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Capture_Setup_Settings()

	if (ViewSetupComponents == nil) then
		return
	end

	ViewSetupsSettings = {}
	
	for _, handle in ipairs(ViewSetupComponents) do
		ViewSetupsSettings[handle.Get_Name()] = handle.Get_Selected_Index()
	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Populate_Setup_Settings()

	if ((ViewSetupsSettings == nil) or (ViewSetupComponents == nil)) then
		return
	end

	--We're changing combo boxes from script and don't want to cause a flurry of sound
	SuppressSFX = true
	for _, handle in ipairs(ViewSetupComponents) do
		local index = ViewSetupsSettings[handle.Get_Name()]
		handle.Set_Selected_Index(index)
	end
	SuppressSFX = false	
    
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Game_Settings_View()

	-- Map
	local map = NO_MAP_PREVIEW_TEXTURE 
	if (GameOptions.map_filename_only ~= nil) then
		map = GameOptions.map_filename_only
	end
	
	local map_preview = map .. ".tga" 
	this.Panel_Game_Staging.Text_Map.Set_Text(map)
	this.Panel_Game_Staging.Quad_Map_Preview.Set_Texture(tostring(map_preview))
	this.Panel_Game_Staging.Quad_Map_Preview.Set_Render_Mode(0)
		
	-- Map Overlay
	local map_dao = MPMapLookup[GameOptions.map_filename_only]
	PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions, true)
	PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
	
	-- Starting Cash
	local starting_cash = GameOptions.starting_credit_level
	starting_cash = Get_Game_Text(GAME_CREDITS_LEVEL_VIEW[starting_cash])
	
	-- DEFCON
	local defcon = TEXT_NO
	if (GameScriptData.is_defcon_game) then
		defcon = TEXT_YES
	end
	
	-- Win Condition
	local win_condition = VictoryConditionNames[GameScriptData.victory_condition]
	
	-- Hero Respawn
	local hero_respawn = TEXT_NO
	if GameOptions.hero_respawn then
		hero_respawn = TEXT_YES
	end

	-- Pop Cap
	local pop_cap = tostring(GameOptions.pop_cap_override)

	-- Prepare the complete labels
	local map_label = Get_Game_Text("TEXT_INTERNET_MAP_NAME").append(GameOptions.map_display_name)
	local starting_cash_label = Get_Game_Text("TEXT_MULTIPLAYER_STARTING_CASH").append(": ").append(starting_cash)
	local defcon_label = Get_Game_Text("TEXT_MULTIPLAYER_DEFCON").append(": ").append(defcon)
	local win_condition_label = Get_Game_Text("TEXT_WIN_CONDITION").append(": ").append(win_condition)
	local hero_respawn_label = Get_Game_Text("TEXT_MULTIPLAYER_HERO_RESPAWN").append(": ").append(hero_respawn)
	local pop_cap_label = Get_Game_Text("TEXT_MULTIPLAYER_UNIT_POP_CAP").append(": ").append(pop_cap)
	

	-- Display!
	this.Panel_Game_Staging.Text_Map.Set_Text(map_label)
	this.Panel_Game_Staging.Quad_Map_Preview.Set_Texture(tostring(map_preview))
	this.Panel_Game_Staging.Quad_Map_Preview.Set_Render_Mode(0)
	this.Panel_Game_Staging.Panel_Settings.Text_Starting_Cash.Set_Text(starting_cash_label)
	this.Panel_Game_Staging.Panel_Settings.Text_DEFCON.Set_Text(defcon_label)
	this.Panel_Game_Staging.Panel_Settings.Text_Win_Condition.Set_Text(win_condition_label)
	this.Panel_Game_Staging.Panel_Settings.Text_Hero_Respawn.Set_Text(hero_respawn_label)
	this.Panel_Game_Staging.Panel_Settings.Text_Unit_Population_Limit.Set_Text(pop_cap_label)
	local tint = GameOptions.pop_cap_tint 
	this.Panel_Game_Staging.Panel_Settings.Text_Unit_Population_Limit.Set_Tint(tint["r"], tint["g"], tint["b"], tint["a"])

	
	-- Settings display planel
	--[[local starting_cash = this.Panel_Game_Setup.Combo_Starting_Credits.Get_Selected_Text_Data() 
	local defcon = this.Panel_Game_Setup.Combo_DEFCON_Active.Get_Selected_Text_Data() 
	defcon = Get_Game_Text(tostring(defcon))
	local win_condition = this.Panel_Game_Setup.Combo_Win_Condition.Get_Selected_Text_Data() 
	local hero_respawn = this.Panel_Game_Setup.Combo_Hero_Respawn.Get_Selected_Text_Data() 
	hero_respawn = Get_Game_Text(tostring(hero_respawn))

	local starting_cash_label = Get_Game_Text("TEXT_MULTIPLAYER_STARTING_CASH").append(": ").append(starting_cash)
	local defcon_label = Get_Game_Text("TEXT_MULTIPLAYER_DEFCON").append(": ").append(defcon)
	local win_condition_label = Get_Game_Text("TEXT_MULTIPLAYER_WIN_CONDITION").append(": ").append(win_condition)
	local hero_respawn_label = Get_Game_Text("TEXT_MULTIPLAYER_HERO_RESPAWN").append(": ").append(hero_respawn)

	this.Panel_Game_Staging.Panel_Settings.Text_Starting_Cash.Set_Text(starting_cash_label)
	this.Panel_Game_Staging.Panel_Settings.Text_DEFCON.Set_Text(defcon_label)
	this.Panel_Game_Staging.Panel_Settings.Text_Win_Condition.Set_Text(win_condition_label)
	this.Panel_Game_Staging.Panel_Settings.Text_Hero_Respawn.Set_Text(hero_respawn_label)--]]
	
end

------------------------------------------------------------------------------
-- Persist pertinent UI elements to the profile.
------------------------------------------------------------------------------
function Persist_UI_To_Profile()

	-- Player identity options
	if (ViewState == VIEW_STATE_GAME_STAGING) then
	
		local faction = Validate_Client_Faction(LocalClient.faction)

		Set_Profile_Value(PP_SKIRMISH_PLAYER_FACTION, faction)
		Set_Profile_Value(PP_SKIRMISH_PLAYER_TEAM, LocalClient.team)
		Set_Profile_Value(PP_COLOR_INDEX, LocalClient.color)
		
	end
	
	-- Game hosting options
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		
		local panel = this.Panel_Game_Setup
		Set_Profile_Value(PP_SKIRMISH_MAP, panel.Combo_Map.Get_Selected_Index())
		Set_Profile_Value(PP_SKIRMISH_WIN_CONDITION, panel.Combo_Win_Condition.Get_Selected_Index())
		Set_Profile_Value(PP_SKIRMISH_DEFCON, panel.Combo_DEFCON_Active.Get_Selected_Index())
		Set_Profile_Value(PP_SKIRMISH_HERO_RESPAWN, panel.Combo_Hero_Respawn.Get_Selected_Index())
		Set_Profile_Value(PP_SKIRMISH_STARTING_CREDITS, panel.Combo_Starting_Credits.Get_Selected_Index())
		Set_Profile_Value(PP_SKIRMISH_POP_CAP, panel.Combo_Unit_Population_Limit.Get_Selected_Index())
		
	end
		
	Commit_Profile_Values()
end

------------------------------------------------------------------------------
-- Persist pertinent UI elements to the profile.
------------------------------------------------------------------------------
function Populate_UI_From_Profile()

	local index = -1

	-- Player identity options
	if (ViewState == VIEW_STATE_GAME_STAGING) then
	
		LocalClient.faction = Get_Profile_Value(PP_SKIRMISH_PLAYER_FACTION, LOBBY_DEFAULT_FACTION)
		LocalClient.team = Get_Profile_Value(PP_SKIRMISH_PLAYER_TEAM, LOBBY_DEFAULT_TEAM)
		LocalClient.color = PGLobby_Get_Preferred_Color()

		LocalClient.faction = Validate_Client_Faction(LocalClient.faction)
		
	end

	-- Game hosting options
	if ((ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
		(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
		
		--We're changing combo boxes from script and don't want to cause a flurry of sound
		SuppressSFX = true
		local panel = this.Panel_Game_Setup
		
		index = Get_Profile_Value(PP_SKIRMISH_MAP, 0)
		if ((index >= 0) and (index < #MPMapModel)) then
			panel.Combo_Map.Set_Selected_Index(index)
		else
			panel.Combo_Map.Set_Selected_Index(0)
		end
		
		index = Get_Profile_Value(PP_SKIRMISH_WIN_CONDITION, HostGameDefaults.VictoryCondition)
		panel.Combo_Win_Condition.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_SKIRMISH_DEFCON, HostGameDefaults.DEFCON)
		panel.Combo_DEFCON_Active.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_SKIRMISH_HERO_RESPAWN, HostGameDefaults.HeroRespawn)
		panel.Combo_Hero_Respawn.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_SKIRMISH_STARTING_CREDITS, HostGameDefaults.StartingCredits)
		panel.Combo_Starting_Credits.Set_Selected_Index(index)

		index = Get_Profile_Value(PP_SKIRMISH_POP_CAP, HostGameDefaults.PopCap)
		panel.Combo_Unit_Population_Limit.Set_Selected_Index(index)
		SuppressSFX = false

	end
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_Player_List()

	Set_Player_Clusters_Visible(false)

	if (ClientTable == nil) then
		return
	end

	local has_players = false

	-- seat is 1-based so add one to max player count
	for seat = 1, MapPlayerLimit do
		local handle = ViewPlayerInfoClusters[seat].Handle
		handle.Set_Is_Host(HostingGame)
		handle.Clear_UI()
--		handle.Set_Model()
		handle.Set_Hidden(false)
		handle.Set_Tab_Order(Declare_Enum())
	end

	for seat, client in pairs(ClientSeatAssignments) do

		has_players = true

		if client and (seat <= #ViewPlayerInfoClusters) then
			local handle = ViewPlayerInfoClusters[seat].Handle
			
			if client.is_closed == true then
				handle.Set_Cluster_State(CLUSTER_STATE_CLOSED)
				handle.Set_Model()
			elseif client.is_closed == false then
				handle.Set_Cluster_State(CLUSTER_STATE_OPEN)
				handle.Set_Model()
			else
		
				local model = {}
				local display_valid = true

				if Is_Reserved_Player(client.common_addr) then
					handle.Clear_UI()
					handle.Set_Is_Reserved(true)
					handle.Set_Hidden(false)
				else
					-- Get the latest data from the client table
					client = Network_Get_Client(client.common_addr)

					-- Address
					model.common_addr = client.common_addr

					local is_local = LocalClient.common_addr == client.common_addr
					handle.Set_Is_Local_Client(is_local)

					-- Name
					model.name = "UNKNOWN"
					if (client.name ~= nil) then
						model.name = client.name
					else
						display_valid = false
					end

					-- Faction
					model.faction = "UNKNOWN"
					if (client.faction ~= nil) then
						model.faction = client.faction
					else
						display_valid = false
					end

					-- Team
					model.team = -1
					if (client.team ~= nil) then
						model.team = client.team
					else
						display_valid = false
					end

					-- Color
					model.color = -1
					model.color_valid = false
					if (client.color ~= nil) then
						model.color = client.color

						if (Check_Color_Is_Taken(client)) then
							display_valid = false
						else
							model.color_valid = true
						end
					else
						display_valid = false
					end

					-- Medals
					if (client.applied_medals ~= nil) then
						model.applied_medals = client.applied_medals
					end

					-- Start marker
					model.start_marker_id = client.start_marker_id

					-- Accepts
					model.AcceptsGameSettings = false
					if (client.AcceptsGameSettings ~= nil) then
						model.AcceptsGameSettings = client.AcceptsGameSettings
					else
						display_valid = false
					end

					-- Is it an AI?
					model.is_ai = false
					if client.is_ai then
						model.is_ai = true
						model.name = Network_Get_AI_Name(client.ai_difficulty)
					end

					-- Bad Connection?
					-- If the bad client list is nil, it means we don't have enough
					-- information yet to properly determine if the connection web
					-- is sound, so we default to displaying a "good" connection.
					if (PGLobbyBadClientList ~= nil) then
						local value = PGLobbyBadClientList[client.common_addr] 
						if (value == true) then
							model.is_bad_connection = true
						else
							-- False if false OR nil.
							model.is_bad_connection = false
						end
					else
						model.is_bad_connection = false
					end

					-- DISPLAY IT!
					--			if (not display_valid) then
					--				model = nil
					--			end
					handle.Clear_UI()
					if (is_local and ConnectionChangeOccurred) then
						ConnectionChangeOccurred = false
						handle.Reset_Gamer_Picture()
					end
					handle.Set_Model(model)
					handle.Set_Hidden(false)
				end

				-- Selected?
				if (CurrentlySelectedClient ~= nil) and (client.common_addr == CurrentlySelectedClient.common_addr) then
					handle.Set_Selected_State(true)
				else
					handle.Set_Selected_State(false)
				end

			end

		end

	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Selected_Player_Color(color)

end

---------------------------------------
--
---------------------------------------
function Set_Currently_Selected_Client(client)

	-- Stop editing the current client then start editing the new one
	Set_Selected_Client_Editing_Enabled(false)

	CurrentlySelectedClient = client
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Cluster_Claiming_Focus(event, scene, seat_num)
	for _, map in pairs(ViewPlayerInfoClusters) do
		map.Handle.Focus_Claimed_By(seat_num)
	end
end

---------------------------------------
--
---------------------------------------
function Set_Selected_Client_Editing_Enabled(enabled)

	-- [JLH 2/8/2008]
	-- On the gamepad ALL clusters are editable at ALL times.
	--[[if CurrentlySelectedClient == nil then return end

	Client_Editing_Enabled = enabled

	local seat = Network_Get_Seat(CurrentlySelectedClient)
	if seat then
		local handle = ViewPlayerInfoClusters[seat].Handle
		if TestValid(handle) then
			handle.Set_Editing_Enabled(enabled)
		end
	end--]]

end
				
---------------------------------------
--
---------------------------------------
function Get_Selected_Client()
	return CurrentlySelectedClient
end
	
---------------------------------------
--
---------------------------------------
function Set_Staging_System_Message(message)
	this.Panel_Game_Staging.Text_System_Message.Set_Text(message)
end

---------------------------------------
--
---------------------------------------
function Display_Modal_Message(message, message_only)

	if (not TestValid(this.Yes_No_Ok_Dialog)) then
		local handle = Create_Embedded_Scene("Yes_No_Ok_Dialog", this, "Yes_No_Ok_Dialog")
	else
		this.Yes_No_Ok_Dialog.End_Modal()
		this.Yes_No_Ok_Dialog.Set_Hidden(false)
	end
	this.Yes_No_Ok_Dialog.Start_Modal()
	this.Yes_No_Ok_Dialog.Set_Screen_Position(0.5, 0.5)
	
	local model = {}
	model.Message = message
	
	if message_only then
		this.Yes_No_Ok_Dialog.Set_Message_Mode()
	else
		this.Yes_No_Ok_Dialog.Set_Ok_Mode()
	end
	this.Yes_No_Ok_Dialog.Set_Model(model)
	
end

---------------------------------------
--
---------------------------------------
function Hide_Modal_Message()

	if (TestValid(this.Yes_No_Ok_Dialog)) then
		this.Yes_No_Ok_Dialog.Set_Hidden(true)
	end
	
end
				
---------------------------------------
--
---------------------------------------
function Refresh_Staging_System_Message()

	-- Start game?
	local can_start, messages = Check_Game_Start_Conditions()
	if (can_start and (not GameIsStarting)) then
		
		this.Panel_Game_Staging.Button_Launch_Game.Enable(true)
		Set_Staging_System_Message(Get_Game_Text("TEXT_MULTIPLAYER_READY_TO_START"))
			
	elseif (not can_start) then
		
		this.Panel_Game_Staging.Button_Launch_Game.Enable(false)
		-- If the game isn't ready to start, display the first error message.
		Set_Staging_System_Message(messages[1])
			
	end

	return can_start

end

-------------------------------------------------------------------------------
-- If the host has specified an AI players, they will be added after we
-- recieve the host joined notification.
-------------------------------------------------------------------------------
function Do_Host_Game()

	ClientTable = {}
	Network_Reset_Seat_Assignments()
	Reset_Local_Client()
	Update_Local_Client()
	Update_Selected_Player_View()
	Network_Calculate_Initial_Max_Player_Count()
	
	Finish_Host_Game()

end
	
function Finish_Host_Game()

	-- Always update our local client settings first (mainly to ensure our common_addr is up to date).
	Update_Local_Client()

	Set_Client_Table({ { ["common_addr"] = LocalClient.common_addr } } )
	-- The local address can sometimes change on session creation, so we have to refresh it again here.
	ClientSeatAssignments[HOST_SEAT_POSITION] = LocalClient
	Set_Currently_Selected_Client(LocalClient)
	Update_Selected_Player_View()
	
	-- Only add an AI player if the map has at least two start markers.
		-- Map Overlay
	local map_dao = MPMapLookup[GameOptions.map_filename_only]
	if ((map_dao.normalized_start_positions ~= nil) and #(map_dao.normalized_start_positions) >= 2) then
		Add_AI_Player() -- we have an AI player by default
	end

	-- Every few seconds, we are going to check our ClientTable and make sure we know everything
	-- about everyone and all the game settings.
	Start_Client_Validation_Checking()

	Update_Player_List()
	Refresh_Staging_System_Message()
	Refresh_UI()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Internet_On_Lobby_Init()
	DebugMessage("LUA_LOBBY:  Internet_On_Lobby_Init -- status: " .. tostring(event.status))
end

-------------------------------------------------------------------------------
-- This event is raised whenever the menu system is awakened after a game mode.
-- We're only interested in it if we have spawned a multiplayer game here, so
-- if that flag is not set, we ignore the event.
-------------------------------------------------------------------------------
function On_Menu_System_Activated()

	DebugMessage("LUA_LOBBY: Menu System Activated!!")
	
	PGLobby_Set_Tooltip_Visible(false)

	if (not GameHasStarted or RestartingMap) then
		DebugMessage("LUA_LOBBY: Game has not started or we are doing a map restart.  Early out...")
		return
	end
	

	-- Paranoia check...View_Back_Out() will call Leave_Game() for us, but just in
	-- case we'll make sure it happened.
	Leave_Game()
	GameHasStarted = false
	Variables_Reset()
	Initialize_Filters()
	Populate_UI_From_Profile()
	View_Back_To_Start()
	Set_Currently_Selected_Client(LocalClient)
	Update_Selected_Player_View()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_LOBBY,  [X_CONTEXT_GAME_MODE] = CONTEXT_GAME_MODE_SKIRMISH })
	
	-- Restart modality so this scene captures input
	this.Start_Modal()
	this.Focus_First()
		
end	


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Start_Game()

	GameIsStarting = false
	this.End_Modal()
	Stop_Client_Validation_Checking()
	
	-- Convert faction IDs to string constants
	PGLobby_Convert_Faction_IDs_To_Strings()
	
	On_Start_Game()

	-- Now that the game is started, update the ClientTable with all the newly-assigned
	-- player IDs.
	Update_Clients_With_Player_IDs()
	
	-- Assign start positions
	GameScriptData.start_positions = Build_Game_Start_Positions()
    
	-- Hand off the client table to the game scoring script.
	-- Need to store off the game options
	GameScriptData.GameOptions = GameOptions

	Set_Player_Info_Table(ClientTable)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
	GameScoringManager.Set_Is_Ranked_Game(false)
	GameScoringManager.Set_Is_Global_Conquest_Game(false)
	GameScoringManager.Set_Is_Custom_Multiplayer_Game(false)
	GameScoringManager.Set_Is_Disconnect_Detected(false)
	
	GameHasStarted = true
	return true
		
end

-------------------------------------------------------------------------------
-- Start game response for singleplayer skirmish.
-------------------------------------------------------------------------------
function On_Start_Game()
	GameOptions.seed = GameRandom.Free_Random(RANDOM_MIN, RANDOM_MAX)
	GameOptions.is_lan = false
	GameOptions.is_campaign = false
	GameOptions.is_internet = false
	GameOptions.is_skirmish = true

	local itable = {}
	local client_count = 0
	for _, client in pairs(ClientTable) do
		table.insert(itable, client)
	end

	Net.MM_Start_Game(GameOptions, itable)
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Reset_Local_Client()

	-- Start position
	LocalClient.start_marker_id = nil
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Update_Local_Client()

	-- Common Address
	LocalClient.common_addr = Net.Get_Local_Addr()
	
	-- Name
	if (LocalClient.name == nil) then
		LocalClient.name = Network_Get_Local_Username()		-- Will never return nil.
	end
	
	-- Faction
	if (LocalClient.faction == nil) then
		LocalClient.faction = Get_Preferred_Faction()
	end
	
	-- Team
	if (LocalClient.team == nil) then
		LocalClient.team = Get_Preferred_Team()
	end

	-- Color
	if (LocalClient.color == nil) then
		LocalClient.color = PGLobby_Get_Preferred_Color()
	end
	
	-- Medals
	LocalClient.applied_medals = Get_Locally_Applied_Medals(LocalClient.faction)
	
	DebugMessage("LOCAL_CLIENT:  Name: " .. tostring(LocalClient.name))
	DebugMessage("LOCAL_CLIENT:  Player_ID: " .. tostring(LocalClient.PlayerID))
	DebugMessage("LOCAL_CLIENT:  Faction: " .. tostring(LocalClient.faction))
	DebugMessage("LOCAL_CLIENT:  Team: " .. tostring(LocalClient.team))
	DebugMessage("LOCAL_CLIENT:  Color: " .. tostring(LocalClient.color))

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Leave_Game()

	Stop_Client_Validation_Checking()

	for seat = 1, MAP_MAX_PLAYER_COUNT do
		if (seat <= #ViewPlayerInfoClusters) then
			local handle = ViewPlayerInfoClusters[seat].Handle
			handle.Clear_UI()
			handle.Set_Model()
			handle.Set_Hidden(true)
			handle.Set_Cluster_State(CLUSTER_STATE_OPEN)
		end
	end

	CurrentlySelectedSession = nil
	Network_Clear_All_Clients()
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Initialize_Game_Hosting()
	
	for _, map in pairs(ViewPlayerInfoClusters) do
		map.Handle.Set_Editing_Enabled(true)
		map.Handle.Set_Lockdown(false)
		map.Handle.Set_Is_Host(true)
	end
	
	Refresh_Game_Settings_Model(true)
	
	Set_Currently_Selected_Client(LocalClient)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Reinitialize_Game_Hosting()

	Refresh_Game_Settings_Model(false)
	
end

-------------------------------------------------------------------------------
-- The host calls this to collect all the game settings from the setup screen
-- into the various data structures that will be used to broadcast the
-- settings to other players and to start the game.  The host IGNORES game
-- settings broadcasts altogether.
-------------------------------------------------------------------------------
function Refresh_Game_Settings_Model(full_reset)

	-- Victory Condition
	GameScriptData.victory_condition = nil
	local condition = this.Panel_Game_Setup.Combo_Win_Condition.Get_Selected_Text_Data()
	for condition_name, condition_constant in pairs(VictoryConditionConstants) do
		if condition_name == condition then
			GameScriptData.victory_condition = condition_constant
		end
	end

	-- DEFCON
	local index = this.Panel_Game_Setup.Combo_DEFCON_Active.Get_Selected_Index()
	GameScriptData.is_defcon_game = (index == COMBO_SELECTION_YES)

	-- Hero Respawn
	index = this.Panel_Game_Setup.Combo_Hero_Respawn.Get_Selected_Index()
	GameOptions.hero_respawn = (index == COMBO_SELECTION_YES)
	
	-- Map
	index = this.Panel_Game_Setup.Combo_Map.Get_Selected_Index() 
	local map_dao = MPMapModel[index + 1]		-- MPMapModel is 1-based
	GameOptions.map_name = MAP_DIRECTORY .. tostring(map_dao.file_name)
	GameOptions.map_display_name = map_dao.display_name
	GameOptions.map_filename_only = map_dao.file_name_no_extension
	GameOptions.map_preview = map_dao.file_name_no_extension .. ".tga"
	GameOptions.map_crc = map_dao.map_crc

	-- Start Markers
	if (full_reset or PrevMapIndex ~= GameOptions.map_crc) then
		PrevMapIndex = GameOptions.map_crc
		if (map_dao.incomplete) then
			PGMO_Set_Enabled(false)
		else
			PGMO_Set_Enabled(true)
			PGMO_Set_Neutral_Structure_Marker_Model(map_dao.normalized_capturable_structure_positions)
			local status, errors = PGMO_Set_Start_Marker_Model(map_dao.num_players, map_dao.normalized_start_positions, true)
			if (not status) then
				PGMO_Set_Enabled(false)
				Display_Modal_Message(errors)
			end
		end

		Network_Calculate_Initial_Max_Player_Count()
	end
	
	-- Starting Credits
	local credit_level = this.Panel_Game_Setup.Combo_Starting_Credits.Get_Selected_Index()
	GameOptions.starting_credit_level = credit_level

	-- Pop Cap Override
	local pop_cap = this.Panel_Game_Setup.Combo_Unit_Population_Limit.Get_Selected_Index()
	pop_cap = 40 + (5 * pop_cap) -- same as when we initialized the combo box

	if ((Network_Get_AI_Player_Count() >= 3) and (pop_cap > 60)) then
		GameOptions.pop_cap_override = 60
		GameOptions.pop_cap_tint = WARNING_TINT
	else
		GameOptions.pop_cap_override = pop_cap
		GameOptions.pop_cap_tint = STANDARD_TINT
	end

	GameScriptData.GameOptions = GameOptions
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Start_Client_Validation_Checking()
	ClientValidationChecking = true
	-- Unlike session polling, we don't want to do this right away, so
	-- schedule it out in the future.
	PGCrontab_Schedule(Do_Client_Validation, 0, CLIENT_VALIDATION_PERIOD, 1)	-- Call once, in n seconds.
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Do_Client_Validation()
	if (ClientValidationChecking) then
		PGLobby_Validate_Local_Session_Data()
		PGCrontab_Schedule(Do_Client_Validation, 0, CLIENT_VALIDATION_PERIOD, 1)	-- Call once, in n seconds.
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Stop_Client_Validation_Checking()
	ClientValidationChecking = false
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- M I S C 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
	
------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------
function Check_Game_Start_Conditions()

	local can_start = true
	local tmp = false
	local messages = {}

	if ((ClientTable == nil) or (ClientTable[LocalClient.common_addr] == nil)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_PLAYERS_TO_JOIN"))
	end
	
	-- Unique Colors
	tmp = Check_Unique_Colors()
	can_start = (can_start and tmp)
	if (tmp == false) then
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_START_COND_COLORS"))
	end
	
	-- At least two teams if there is more than one human player.
	local team_tally = {}
	local unique_team_count = 0
	local player_count = 0
	for _, client in pairs(ClientTable) do
	
		if (client.team ~= nil) then
	
			local tally = team_tally[client.team]
		
			if (tally == nil) then
				unique_team_count = unique_team_count + 1
				team_tally[client.team] = 1
			else
				team_tally[client.team] = tally + 1
			end
			
			player_count = player_count + 1
			
		end
		
	end
	if ((player_count > 1) and (unique_team_count <= 1)) then
		can_start = false
		table.insert(messages, Get_Game_Text("TEXT_MULTIPLAYER_UNIQUE_TEAMS"))
	end
	
	-- Chosen Start Positions
	--[[if (PGMO_Get_Enabled()) then
		for _, client in pairs(ClientTable) do
			local seat =  Network_Get_Seat(client)
			if (not PGMO_Is_Seat_Assigned(seat)) then
				can_start = false
				table.insert(messages, "Waiting for all players to choose start positions.")
				break
			end
		end 
	end--]]

	return can_start, messages

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Validate_Client_Faction(faction)

	if type(faction) == "string" then
		faction = Get_Faction_Numeric_Form(faction)
	end

	if (type(faction) ~= "number") or
		(faction < PG_SELECTABLE_FACTION_MIN) or
		(faction > PG_SELECTABLE_FACTION_MAX) then
		faction = PG_SELECTABLE_FACTION_MIN
	end

	return faction

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Preferred_Faction()

	local faction = Get_Profile_Value(PP_LAST_FACTION, PG_FACTION_NOVUS)
	
	if ((faction ~= PG_FACTION_NOVUS) and
		(faction ~= PG_FACTION_ALIEN) and
		(faction ~= PG_FACTION_MASARI)) then
		faction = PG_FACTION_NOVUS
	end
	
	return faction
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Preferred_Team()

	local team = tostring(Get_Profile_Value(PP_TEAM, 1))
	if ((team == nil) or (team == "-1") or (team == "")) then
		team = 1
	else
		team = tonumber(team)
	end
	
	return team
		
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Build_Game_Start_Positions()

	if (not PGMO_Get_Enabled()) then
		return nil
	end

	if (PGMO_Get_Assignment_Count() <= 0) then
		return nil
	end
 
	local result = {}
	for _, client in pairs(ClientTable) do
		local seat = Network_Get_Seat(client)
		-- The map overlay system works 1-based, but the actual positioning system is 0-based!!!!
		local marker_id = PGMO_Get_Start_Marker_ID_From_Seat(seat)
		if (marker_id == nil) then
			PGMO_Assign_Random_Start_Position(seat)
			marker_id = PGMO_Get_Start_Marker_ID_From_Seat(seat)
		end
		marker_id = marker_id - 1
		result[client.PlayerID] = marker_id 
	end
	
	return result

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Heavyweight_Child_Scene_Closing()

	PGLobby_Activate_Movies()
	
	-- Special Case:  Kick off the globe movies.
	if (ViewState == VIEW_STATE_MAIN) then
	
		this.Panel_Game_Setup.Globe_Movie.Stop()
		
	elseif ((ViewState == VIEW_STATE_GAME_FILTERS_JOIN) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST) or
			(ViewState == VIEW_STATE_GAME_OPTIONS_HOST_STAGING)) then
	
	elseif (ViewState == VIEW_STATE_GAME_CUSTOM_LOBBY) then
	
		this.Panel_Game_Setup.Globe_Movie.Stop()
		
	elseif (ViewState == VIEW_STATE_GAME_STAGING) then
	
		this.Panel_Game_Setup.Globe_Movie.Stop()
		
	end

	if MedalChestOpen == true then
		MedalChestOpen = false
		if (ViewState == VIEW_STATE_GAME_STAGING) then
			Update_Local_Client()
			Update_Player_List()
		end
	end
	
end

-------------------------------------------------------------------------------
-- Called when a network event is thrown into script.
-------------------------------------------------------------------------------
function On_Network_Event(event)

	if event.type == NETWORK_EVENT_TASK_COMPLETE then
		if (Network_Event_Table[event.task] ~= nil) then
			Network_Event_Table[event.task](event)
		end
	elseif event.type == NETWORK_EVENT_ERROR then
		DebugMessage("LUA_SKIRMISH:  Network Error %s", tostring(event.message))
	end

end

-------------------------------------------------------------------------------
-- Called when the backend has our profile achievement data ready for us.
-------------------------------------------------------------------------------
function Network_On_Live_Signin_Changed(event)

	-- If we're in a game, let the game logic handle the disaster.  We will respond here
	-- when the menu system is reawakened.
	if (GameHasStarted) then
		return
	end
	
	DebugMessage("LUA_SKIRMISH: Live signin state changed.")
	
	if (event.state == nil) then
		DebugMessage("LUA_SKIRMISH: Live signout occurred.")
		View_Back_To_Start()
		Close_Dialog()
		return
	elseif (event.state == "local") then
		DebugMessage("LUA_SKIRMISH: Live connection has been lost.")
	elseif (event.state == "online") then
		DebugMessage("LUA_SKIRMISH: Live connection has been established.")
	end
					
	-- Regardless of our signin state, we just want to refresh the local client.  
	-- Setting the name to nil will force Update_Local_Client() to determine what the
	-- present username should be ("Player" if signed out, gamertag otherwise).
	ConnectionChangeOccurred = true
	LocalClient.name = nil
	Update_Local_Client()
	if (ViewState == VIEW_STATE_GAME_STAGING) then
		Update_Player_List()
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Add_AI_Player()

	-- Seat 1 is for the local player
	for seat = 2, MapPlayerLimit do
		local handle = ViewPlayerInfoClusters[seat].Handle
		if not handle.Is_Client_Connected() then
			handle.Make_AI_Player(true)
			break
		end
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Restarting_Map(value)
	DebugMessage("LUA_SKIRMISH: Setting Restarting Flag: " .. tostring(value))
	RestartingMap = value
end
	

-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-- ------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Play_Again_Restart()
	GameHasStarted = true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.On_Play_Again_Restart = On_Play_Again_Restart
Interface.Set_Restarting_Map = Set_Restarting_Map
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_Game_Kill_Countdown = nil
	Broadcast_Game_Settings = nil
	Broadcast_Game_Settings_Accept = nil
	Broadcast_Game_Start_Countdown = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Check_Accept_Status = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Teams = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Currently_Selected_Session = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Get_Selected_Client = nil
	Hide_Modal_Message = nil
	Is_Player_Of_Faction = nil
	Min = nil
	Network_Add_Reserved_Players = nil
	Network_Assign_Host_Seat = nil
	Network_Broadcast_Reset_Start_Positions = nil
	Network_Do_Seat_Assignment = nil
	Network_Edit_AI_Player = nil
	Network_Get_Client_By_ID = nil
	Network_Get_Client_From_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	Network_Kick_Player = nil
	Network_Refuse_Player = nil
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	On_Medal_Chest_Clicked = nil
	OutputDebug = nil
	PGLobby_Begin_Stats_Registration = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Create_Session = nil
	PGLobby_Display_Custom_Modal_Message = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Hide_Modal_Message = nil
	PGLobby_Init_Modal_Message = nil
	PGLobby_Is_Game_Joinable = nil
	PGLobby_Keepalive_Close_Bracket = nil
	PGLobby_Keepalive_Open_Bracket = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Refresh_Available_Games = nil
	PGLobby_Request_All_Medals_Progress_Stats = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Request_Global_Conquest_Properties = nil
	PGLobby_Request_Stats_Registration = nil
	PGLobby_Reset = nil
	PGLobby_Restart_Networking = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Player_Solid_Color = nil
	PGLobby_Start_Heartbeat = nil
	PGLobby_Stop_Heartbeat = nil
	PGLobby_Update_NAT_Warning_State = nil
	PGLobby_Update_Player_Count = nil
	PGLobby_Validate_Client_Medals = nil
	PGLobby_Validate_NAT_Type = nil
	PGMO_Clear_Start_Position_By_Seat = nil
	PGMO_Clear_Start_Positions = nil
	PGMO_Disable_Neutral_Structure = nil
	PGMO_Enable_Neutral_Structure = nil
	PGMO_Get_Saved_Start_Pos_User_Data = nil
	PGMO_Restore_Start_Position_Assignments = nil
	PGMO_Save_Start_Position_Assignments = nil
	PGMO_Set_Marker_Size = nil
	PGNetwork_Clear_Start_Positions = nil
	PGOfflineAchievementDefs_Init = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Reinitialize_Game_Hosting = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Currently_Selected_Session = nil
	Set_Local_User_Applied_Medals = nil
	Set_Selected_Player_Color = nil
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
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	Kill_Unused_Global_Functions = nil
end

