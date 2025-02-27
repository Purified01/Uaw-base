if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[131] = true
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[6] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[84] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[111] = true
LuaGlobalCommandLinks[70] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_MainMenu.lua#90 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_MainMenu.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Nader_Akoury $
--
--            $Change: 97769 $
--
--          $DateTime: 2008/04/30 08:50:49 $
--
--          $Revision: #90 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGNetwork")
require("PGDebug")
require("PGCrontab")
require("PGPlayerProfile")
require("UIControl")

--Need these for Set_Player_Info_Table (used by the Play_Again button)
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")

-- Need this to launch the different campaigns.
require("Campaign_Missions_Data")

ScriptPoolCount = 0


function On_Init()

	Net.Initialize()
	PGNetwork_Init()
	PGCrontab_Init()
	PGPlayerProfile_Init_Constants()
	Net.Register_Event_Handler(On_Network_Event)
	
	-- Constants 
	ENABLE_NEW_MULTIPLAYER_FLOW = true 
	CAMPAIGN_LOAD_GAME = 1
	SKIRMISH_LOAD_GAME = 2
	MULTIPLAYER_LOAD_GAME = 3
	RANKED_NET_MATCH = 1
	QUICK_RANKED_NET_MATCH = 2
	QUICK_PLAYER_NET_MATCH = 3
	
	ATTRACT_MODE_DELAY = 110

	-- We have a max save game size of 12 MB
	MAX_SAVE_GAME_SIZE = 12 * 1024 * 1024
  	
	-- Variables
	Mainmenu.Text_Version_Info_String.Set_Text(Get_Full_Version_Info_String())
	DialogToOpen = nil
	Dialog_Box_Common_Init()
	CheckForNonLiveUpdates = true
	NonLiveUpdateAvailable = false
	CheckedForUPnP = false

	DebugMessage("Initializing Mainmenu.lua scene...\n");

	Mainmenu.Register_Event_Handler("Key_Press", Mainmenu, On_Key_Press)
	Mainmenu.Register_Event_Handler("Save_File_Deleted", nil, On_Save_File_Deleted)

	-- Main Menu Buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign, Main_Menu_Campaign_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish, Main_Menu_Skirmish_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer, Main_Menu_Multiplayer_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials, Main_Menu_Tutorials_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options, Main_Menu_Options_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Profile, Main_Menu_Profile_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Exit_Game, Main_Menu_Exit_Button_Clicked)
	if GOLD_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Hidden(true)
		Mainmenu.Text_Version_Info_String.Set_Hidden(true) --re-enabled while we are testing the patch code. Disable before delivering!!! -Eric
	else
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug, Main_Menu_Debug_Button_Clicked)
	end
	
	-- Campaign Buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign, Campaign_Continue_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Tutorial_Campaign, Campaign_Tutorial_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign, Campaign_Novus_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign, Campaign_Hierarchy_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign, Campaign_Masari_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Scenarios, Campaign_Scenario_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load, Campaign_Load_Game_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Back, Campaign_Back_Button_Clicked)

	-- Skirmish Buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_New_Game, Skirmish_New_Game_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load, Skirmish_Load_Game_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Back, Skirmish_Back_Button_Clicked)
	
	-- Quick Match Buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game, Multiplayer_QM_Ranked_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match, Multiplayer_QM_Player_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Quick_Match_Back, Multiplayer_QM_Back_Button_Clicked)
	
	-- Multiplayer Buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In, Multiplayer_Sign_In_Clicked)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Hidden(true)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World, Multiplayer_Conquer_The_World_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match, Multiplayer_Custom_Match_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game, Multiplayer_Ranked_Game_Clicked)
	--Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match, Main_Menu_Quick_Match_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards, Multiplayer_Leaderboards_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN, Multiplayer_LAN_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay, Multiplayer_Load_Replay_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Multiplayer_Back, Multiplayer_Back_Button_Clicked)
	
	-- Tutorial buttons
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Training, Tutorial_Button_Training_Clicked)
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_1, Tutorial_Button_1_Clicked)
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_2, Tutorial_Button_2_Clicked)
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_3, Tutorial_Button_3_Clicked)
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_4, Tutorial_Button_4_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_5, Tutorial_Button_5_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_6, Tutorial_Button_6_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_7, Tutorial_Button_7_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_8, Tutorial_Button_8_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_9, Tutorial_Button_9_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_10, Tutorial_Button_10_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_11, Tutorial_Button_11_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_12, Tutorial_Button_12_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_13, Tutorial_Button_13_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_14, Tutorial_Button_14_Clicked)
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_15, Tutorial_Button_15_Clicked)
--	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_16, Tutorial_Button_16_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_Back, Tutorial_Button_Back_Clicked)
	
	-- Options buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Audio_Options, Options_Audio_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Video_Options, Options_Video_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Network_Options, Options_Network_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Gamepad, Gamepad_Options_Dialog_Selected)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Keyboard_Options, Options_Keyboard_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Game_Options, Options_Game_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits, Options_Credits_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Options_Back, Options_Back_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer, Options_Trailer_Button_Clicked)

	-- Debug Buttons
	if not GOLD_BUILD then
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map, Debug_Load_Map_Button_Clicked)
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Milestone_Demo, Debug_Milestone_Button_Clicked)
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest, Multiplayer_Conquer_The_World_Button_Clicked)
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest, Debug_Achievement_Chest_Button_Clicked)
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Mission, Debug_Load_Mission_Button_Clicked)
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Old_LAN_Lobby, Multiplayer_LAN_Button_Clicked)
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Back, Debug_Back_Button_Clicked)
	end
	
	-- Back buttons attached to xbox "B" key
	Mainmenu.Register_Event_Handler("Controller_B_Button_Up", nil, Controller_Key_As_Back)
	Mainmenu.Register_Event_Handler("Controller_Back_Button_Up", nil, Controller_Key_As_Back)


	
	--Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Internet.Enable(false)

	-- *** TAB ORDERING ***
	-- Top Menu
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Tab_Order(Declare_Enum(0))
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Set_Tab_Order(Declare_Enum())
--	if not GOLD_BUILD and not BETA_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Tab_Order(Declare_Enum())
--	end

	-- Campaign Menu
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Tutorial_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Scenarios.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load.Set_Tab_Order(Declare_Enum())

	-- Skirmish Buttons
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_New_Game.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load.Set_Tab_Order(Declare_Enum())

	-- Multiplayer Menu
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Set_Tab_Order(Declare_Enum())
	--Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Set_Tab_Order(Declare_Enum())

	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Set_Tab_Order(Declare_Enum())

	-- Tutorials Menu
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Training.Set_Tab_Order(Declare_Enum())
--	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_1.Set_Tab_Order(Declare_Enum())
--	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_2.Set_Tab_Order(Declare_Enum())
--	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_3.Set_Tab_Order(Declare_Enum())
--	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_4.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_5.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_6.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_7.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_8.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_9.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_10.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_11.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_12.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_13.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_14.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_14.Set_Tab_Order(Declare_Enum())
--	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_15.Set_Tab_Order(Declare_Enum())
--	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_16.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_Back.Set_Tab_Order(Declare_Enum())

	-- Options Menu
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Audio_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Game_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits.Set_Tab_Order(Declare_Enum())

	-- Debug Menu
--	if not GOLD_BUILD and not BETA_BUILD then
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Milestone_Demo.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Enable(false)
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Set_Tab_Order(Declare_Enum())
		--Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Enable(false)
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Mission.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Old_LAN_Lobby.Set_Tab_Order(Declare_Enum())
		--Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Back.Set_Tab_Order(Declare_Enum())
--	end

	Mainmenu.FullScreenMovieScene.Set_Tab_Order(Declare_Enum())

	if BETA_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Hidden(true)

		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Enable(false)
		Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits.Enable(false)
	end

	-- Init our generic message box
	Init_Message_Box()

	LiveLogonState = 2
	NextTabOrder = Declare_Enum()

	-- Load Mission Buttons.
	Initialize_Load_Mission_Buttons()
	
	Mainmenu.Focus_First()

	Register_Game_Scoring_Commands()
	
	this.RolloverMovie.Set_Hidden(true)

	AllowAttractMode = true
	LastAllowAttractTime = GetCurrentRealTime()
	AttractModeSpawned = false
	
	-- [JLH 08/06/2007]:  Register for heavyweight embedded scenes closing so that we can start and stop our movies.
	Mainmenu.Register_Event_Handler("Heavyweight_Child_Scene_Closing", nil, Heavyweight_Child_Scene_Closing)
	
	this.Register_Event_Handler("Credits_Done", nil, On_Credits_Done)
	this.Register_Event_Handler("On_Menu_System_Activated", nil, On_Menu_System_Activated)
	
	-- BPK 01/17/2008
	-- on the XBox we are destroying the main menu, so we need to force simulate button clicks to get
	-- back to the appropriate screen of the type of game we just played
	Mainmenu.Register_Event_Handler("Restore_Menu_State_After_Game", nil, On_Restore_Menu_State_After_Game)
	
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Key_Focus()

	-- Assume these are true until proven false in the On_Update
	ValidGamerProfile = true
	ValidStorageDevice = true
	StorageDeviceUIActive = false
end

function On_Legal_Stuff_Done()
	Mainmenu.Focus_First()	
end

------------------------------------------------------------------------
-- Message Box Initializer
------------------------------------------------------------------------
function Init_Message_Box()

	if (TestValid(this.Yes_No_Ok_Dialog)) then
		DebugMessage("MAIN_MENU_MESSAGE: Already initted.  Bailing...")
		return
	end
	
	DebugMessage("MAIN_MENU_MESSAGE: Initializing main menu message.")
		
	-- Answer types
	YES_CLICKED						= Declare_Enum(1)
	NO_CLICKED						= Declare_Enum()
	OK_CLICKED						= Declare_Enum()
	
	-- Message types
	MSG_PLAYER_MATCH_QUESTION			= Declare_Enum(1)
	MSG_PROFILE_NEEDED					= Declare_Enum()
	MSG_STORAGE_DEVICE_NEEDED			= Declare_Enum()
	
	YesNoOkDialogState = nil

	-- Callbacks
	YesNoOkCallbacks = 
	{
		[MSG_PLAYER_MATCH_QUESTION]		= Player_Match_Question_Callback,
		[MSG_PROFILE_NEEDED]					= Profile_Needed_Callback,
		[MSG_STORAGE_DEVICE_NEEDED]		= Storage_Device_Needed_Callback,
	}
	
	-- Create!
	if (not TestValid(this.Yes_No_Ok_Dialog)) then
		DebugMessage("MAIN_MENU_MESSAGE: Creating dialog handle.")
		local handle = Create_Embedded_Scene("Yes_No_Ok_Dialog", this, "Yes_No_Ok_Dialog")
	end
	this.Yes_No_Ok_Dialog.Set_Hidden(true)		
	this.Yes_No_Ok_Dialog.Set_Screen_Position(0.5, 0.5)
	this.Register_Event_Handler("On_YesNoOk_Yes_Clicked", nil, On_YesNoOk_Yes_Clicked)
	this.Register_Event_Handler("On_YesNoOk_No_Clicked", nil, On_YesNoOk_No_Clicked)
	this.Register_Event_Handler("On_YesNoOk_Ok_Clicked", nil, On_YesNoOk_Ok_Clicked)
					
	DebugMessage("MAIN_MENU_MESSAGE: Main menu message initialized.")
	
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Show_Message_Box()
	DebugMessage("MAIN_MENU_MESSAGE: Showing main menu message box")
	this.Yes_No_Ok_Dialog.Set_Hidden(false)	
	this.Yes_No_Ok_Dialog.Bring_To_Front()
	this.Yes_No_Ok_Dialog.Start_Modal()
end

------------------------------------------------------------------------
--
------------------------------------------------------------------------
function Hide_Message_Box()
	this.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
	this.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)

	DebugMessage("MAIN_MENU_MESSAGE: Hiding main menu message box")
	this.Yes_No_Ok_Dialog.Set_Hidden(true)	
end
					
------------------------------------------------------------------------
-- Message Box User Response Processor
------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()
	this.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
	this.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)

	if (YesNoOkDialogState ~= nil) then
		YesNoOkCallbacks[YesNoOkDialogState](YES_CLICKED)
	end
	
end

------------------------------------------------------------------------
-- Message Box User Response Processor
------------------------------------------------------------------------
function On_YesNoOk_No_Clicked()
	this.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
	this.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)

	if (YesNoOkDialogState ~= nil) then
		YesNoOkCallbacks[YesNoOkDialogState](NO_CLICKED)
	end
	
end

------------------------------------------------------------------------
-- Message Box User Response Processor
------------------------------------------------------------------------
function On_YesNoOk_Ok_Clicked()
	this.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
	this.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)

	if (YesNoOkDialogState ~= nil) then
		YesNoOkCallbacks[YesNoOkDialogState](OK_CLICKED)
	end
	
end

------------------------------------------------------------------------
-- On_Mouse_Over_Button - Play SFX response
------------------------------------------------------------------------
function On_Mouse_Over_Button(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
		local x, _, w, movie_h = this.RolloverMovie.Get_World_Bounds()
		local _, y, _, source_h = source.Get_World_Bounds()
		y = y + source_h / 2 - movie_h / 2
		this.RolloverMovie.Set_World_Bounds(x, y, w, movie_h)	
		this.RolloverMovie.Set_Hidden(false)
		this.RolloverMovie.Play_Animation("Open", false)
		this.RolloverMovie.Set_Animation_Frame(0)
	end
end

------------------------------------------------------------------------
-- On_Button_Pushed - Play SFX response
------------------------------------------------------------------------
function On_Button_Pushed(event, source)
	Play_SFX_Event("GUI_Main_Menu_Button_Select")	
end


---------------------------------------
--
---------------------------------------
function On_Update()
	PGCrontab_Update()
	if not Is_Xbox() then
		if last_gamepad_state == Is_Gamepad_Active() then
			if Is_Gamepad_Active() then
				this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Enable(false)
				this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Set_Hidden(true)
				this.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Hidden(false)
				this.Menu_Buttons.Option_Buttons.Button_Gamepad.Enable(true)
			else --gamepad unplugged
				this.Menu_Buttons.Option_Buttons.Button_Gamepad.Enable(false)
				this.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Hidden(true)
				this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Set_Hidden(false)
				this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Enable(true)
			end
		end
	else
		this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Enable(false)
		this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Set_Hidden(true)
		this.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Hidden(false)
		this.Menu_Buttons.Option_Buttons.Button_Gamepad.Enable(true)
	end	
	last_gamepad_state = Is_Gamepad_Active()

	if (not TestValid(this.Yes_No_Ok_Dialog)) then
		Init_Message_Box()
	end

	if ( not something_has_focus ) then
		if ( TestValid( focus_handle ) ) then
			focus_handle.Set_Key_Focus()
		else
			this.Focus_First()
		end
		something_has_focus = true
	end

	if AllowAttractMode then
		local last_input_time = GetLastControllerInputTime()
		if LastAllowAttractTime > last_input_time then
			last_input_time = LastAllowAttractTime
		end
		local elapsed = GetCurrentRealTime() - last_input_time
		-- Only display the attract movie if nothing else is displaying
		-- on top of the main menu
		if not AttractModeSpawned then
			if elapsed > ATTRACT_MODE_DELAY and this.Is_Modal_Scene() then
				-- Go into attract mode
				AttractModeSpawned = true
				
				--Must stop the main menu background movie here
				Main_Menu_Passivate_Movies(true)

				if not TestValid(this.gamepad_Attract_Movie) then
					Create_Embedded_Scene("gamepad_Attract_Movie", this, "gamepad_Attract_Movie")
					this.gamepad_Attract_Movie.Set_Tab_Order(NextTabOrder)
					NextTabOrder = NextTabOrder + 1				
				else
					this.gamepad_Attract_Movie.Set_Hidden(false)
				end
				this.gamepad_Attract_Movie.Start_Modal(Exited_Attract_Movie)

			end
		end
	end
	
	if CloseBattleLoadDialog then	
		Close_Battle_Load_Dialog()
		CloseBattleLoadDialog = false
	end

	Enable_Gameplay_Buttons()

end

------------------------------------------------------------------------
-- Maria 12.12.2007
-- Exited_Attract_Movie: callback used by the End Modal
-- of gamepad_Attract_Movie
-- Moved this from the On_Update call because the 
-- Controller_As_Key_Back calls were being processed 
-- on each update call.  This caused the press of any button to 
-- fail since immediately after a press a Controller_As_Key_Back
-- would be processed which undid what the press had done.  Hence,
-- I moved it here so that it only gets processed once which is when
-- the Attrack Movie scene has been dismissed.
------------------------------------------------------------------------
function Exited_Attract_Movie()
	AttractModeSpawned = false
	Main_Menu_Activate_Movies()
	if AllowAttractMode then
		local last_input_time = GetLastControllerInputTime()
		if LastAllowAttractTime > last_input_time then
			last_input_time = LastAllowAttractTime
		end
		local elapsed = GetCurrentRealTime() - last_input_time
		
		-- Make sure we didn't miss a button press or something
		if elapsed < ATTRACT_MODE_DELAY then
			Skip_To_Main_Menu()
			
			something_has_focus = false
		end
	end
end

function On_Save_File_Deleted()
	Enable_Continue_Campaign_Button()
end

function Enable_Continue_Campaign_Button()
	local last_campaign = Get_Profile_Value(PP_LAST_PLAYED_CAMPAIGN, PG_CAMPAIGN_INVALID)
	if last_campaign == PG_CAMPAIGN_INVALID then
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Enable(false)
	else
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Enable(true)
	end
end

function Enable_Campaign_Buttons()
	if Get_Profile_Value(PP_CAMPAIGN_TUTORIAL_COMPLETED, false) then
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign.Enable(true)
	else
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign.Enable(false)
	end

	if Get_Profile_Value(PP_CAMPAIGN_NOVUS_COMPLETED, false) then
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign.Enable(true)
	else
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign.Enable(false)
	end

	if Get_Profile_Value(PP_CAMPAIGN_HIERARCHY_COMPLETED, false) then
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign.Enable(true)
	else
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign.Enable(false)
	end

	Enable_Continue_Campaign_Button()
	
	if not Mainmenu.Menu_Buttons.Load_Mission_Buttons.Get_Hidden() then
		Populate_Missions_Menu(true) -- true == update the missions count
	end	
end

---------------------------------------
-- Keyboard Events
---------------------------------------
function On_Key_Press(event, source, key)

	--Hard code 'a' and 't' to the audio/text validation dialogs, respectively
	if key == "a" then
		Open_Dialog("Audio_Validation")
	elseif key == "t" then
		Open_Dialog("Text_Validation")
	end
	
end

---------------------------------------
-- Main Menu Button Events
---------------------------------------

------------------------------------------------------------------------
-- If the user is not signed in to LIVE, we need to warn them they won't
-- earn achievements.
------------------------------------------------------------------------
function Main_Menu_Campaign_Button_Clicked(event_name, source)

	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(true)
	if not Ensure_Valid_Gamer_Profile() then
		SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
		return
	end

	if not Ensure_Valid_Storage_Device() then
		SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
		return
	end

	Enable_Campaign_Buttons()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(false)
	Mainmenu.Focus_First()
end

------------------------------------------------------------------------
-- If the user is not signed in to LIVE, we need to warn them they won't
-- earn achievements.
------------------------------------------------------------------------
function Main_Menu_Skirmish_Button_Clicked(event_name, source)

	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(true)
	if not Ensure_Valid_Gamer_Profile() then
		SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
		return
	end

	if not Ensure_Valid_Storage_Device() then
		SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
		return
	end

	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(false)
	Mainmenu.Focus_First()
	
end

------------------------------------------------------------------------
-- Called when the user answers the modal message dialog regarding
-- whether player match should be quick or custom.
------------------------------------------------------------------------
function Player_Match_Question_Callback(answer)

	if (answer == YES_CLICKED) then
		Start_Custom_Player_Match_Lobby()
	elseif (answer == OK_CLICKED) then
		Start_Quick_Player_Match_Lobby()
	elseif (answer == NO_CLICKED) then
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Set_Key_Focus()
	end

end

function Main_Menu_Multiplayer_Button_Clicked(event_name, source)

	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(true)
	if not Ensure_Valid_Gamer_Profile() then
		SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
		return
	end

	if not Ensure_Valid_Storage_Device() then
		SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
		return
	end

	Set_Menus_For_Live_Logon_State()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)
	Mainmenu.Focus_First()
end

function Main_Menu_Tutorials_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(false)
	Mainmenu.Focus_First()
end

function Main_Menu_Options_Button_Clicked(event_name, source)
	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(false)
	Mainmenu.Focus_First()
end

function Main_Menu_Profile_Button_Clicked(event_name, source)
	Net.Show_Guide_UI()
	Mainmenu.Focus_First()
end

function On_Beta_Splash_Notification_Clicked(event)
	if event == 1 then
		Net.Unregister_Event_Handler(On_Network_Event)
		Net.Shutdown()
		Quit_App_Now()
	elseif event == 2 then
		Net.Launch_URL("http://www.sega.com/games/title/universeatwar/uaw_betatest_feedback.php")
		Net.Unregister_Event_Handler(On_Network_Event)
		Net.Shutdown()
	elseif event == 3 then
		Net.Launch_URL("http://www.gamestop.com/product.asp?product%5Fid=646975")
		Net.Unregister_Event_Handler(On_Network_Event)
		Net.Shutdown()
	elseif event == 4 then
		Net.Launch_URL("http://www.amazon.com/Universe-At-War-Earth-Assault/dp/B000R2WI0G/ref=pd_bbs_sr_1/105-4555601-6077255?ie=UTF8&s=videogames&qid=1185985796&sr=8-1")
		Net.Unregister_Event_Handler(On_Network_Event)
		Net.Shutdown()
	end
end

function Main_Menu_Exit_Button_Clicked(event_name, source)
	if BETA_BUILD then
		local params = {}
		params.spawned_from_script = true
		params.use_bui_buttons = true
		params.callback = "On_Beta_Splash_Notification_Clicked"
		params.script = Script
		Spawn_Dialog_Box(params, "Beta_Exit_Screen", false)
	else
		Net.Unregister_Event_Handler(On_Network_Event)
		Net.Shutdown()
		Quit_App_Now()
	end
end

function Main_Menu_Debug_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Debug_Buttons.Set_Hidden(false)

	--
	-- MBL 09.07.2007: Had to add this to get debug menu working from main menu after the big integration
	--
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Key_Focus()
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Milestone_Demo.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Enable(false)
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Set_Tab_Order(Declare_Enum())
	--Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Enable(false)
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Mission.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Old_LAN_Lobby.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Back.Set_Tab_Order(Declare_Enum())
	--
	-- END MBL 09.07.2007: Had to add this to get debug menu working from main menu after the big integration
	--
end


---------------------------------------
-- Campaign Menu Button Events
---------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------
-- Campaign_Continue_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Continue_Button_Clicked(event_name, button)
	
	local last_campaign = Get_Profile_Value(PP_LAST_PLAYED_CAMPAIGN, PG_CAMPAIGN_INVALID)
	if last_campaign == PG_CAMPAIGN_INVALID then return end

	local mission_list = Missions[last_campaign]
	if not mission_list then return end

	local last_mission = Get_Profile_Value(PP_LAST_PLAYED_MISSION, PG_CAMPAIGN_MISSION_INVALID)
	if last_mission == PG_CAMPAIGN_MISSION_INVALID then return end

	local mission_data = mission_list[last_mission]
	if not mission_data then return end

	-- Should bring up the difficulty menu!.
	-- Store the name of the chosen mission
	CampaignUserInfo = {}
	CampaignUserInfo.CurrentCampaign =  last_campaign
	CampaignUserInfo.MissionName = mission_data.State
	CampaignUserInfo.FactionID =  mission_data.FactionID
	CampaignUserInfo.MissionText =  mission_data.Description
	CampaignUserInfo.CurrentMissionButton =  button
	
	-- A valid mission name has been passed down, so we have to bring up the difficulty menu now!.
	Display_Campaign_Difficulty_Menu()	
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Initialize_Load_Mission_Buttons
-- -----------------------------------------------------------------------------------------------------------------------------
function Initialize_Load_Mission_Buttons()

	-- Initialize the data for the loading of individual missions within a chosen campaign.
	Init_Campaign_Missions_Data()
	
	MissionButtons = {}
	MissionButtons = Find_GUI_Components(Mainmenu.Menu_Buttons.Load_Mission_Buttons, "Button_Mission_")
	
	for idx, button in pairs(MissionButtons) do
		button.Set_Hidden(true)
		Mainmenu.Register_Event_Handler("Button_Clicked", button, Mission_Button_Clicked)
		NextTabOrder = NextTabOrder + idx - 1
		button.Set_Tab_Order(NextTabOrder)
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Mission_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Mission_Button_Clicked(_, button)
	-- NOTE: Each button contains the name of the mission they are representing.
	if button.Get_Hidden() then 
		return
	end
	
	local mission_data = button.Get_User_Data()
	if not mission_data then 
		return
	end
	
	-- Should bring up the difficulty menu!.
	-- Store the name of the chosen mission
	CampaignUserInfo.MissionName = mission_data.State
	CampaignUserInfo.FactionID =  mission_data.FactionID
	CampaignUserInfo.MissionText =  mission_data.Description
	CampaignUserInfo.CurrentMissionButton =  button
	
	-- A valid mission name has been passed down, so we have to bring up the difficulty menu now!.
	Display_Campaign_Difficulty_Menu()	
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Load_Mission_Button_Back_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Load_Mission_Button_Back_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Load_Mission_Buttons.Set_Hidden(true)
	
	-- Reset the last mission button that has gained focus (if any)
	CampaignUserInfo.CurrentMissionButton = nil
	if TestValid(CampaignUserInfo.CurrentCampaignButton) then 
		CampaignUserInfo.CurrentCampaignButton.Set_Key_Focus()
	else
		Mainmenu.Focus_First()
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Execute_Play_Campaign
-- Do we have to display a list of all available missions for the currently selected campaign, or just the difficulty menu?
-- -----------------------------------------------------------------------------------------------------------------------------
function Execute_Play_Campaign()
	-- Pass the Campaign and Net data down to the dialog script.
	CampaignUserInfo.MissionCount = Get_Available_Missions_Count()
	if CampaignUserInfo.MissionCount > 0 then 
		-- Bring up the list of missions.
		Display_Load_Mission_Menu()
	else
		-- we can only launch the first mission for this campaign!
		-- Store the mission data for the mission
		CampaignUserInfo.MissionName = Missions[CampaignUserInfo.CurrentCampaign][1].State	
		CampaignUserInfo.FactionID = Missions[CampaignUserInfo.CurrentCampaign][1].FactionID
		CampaignUserInfo.MissionText = Missions[CampaignUserInfo.CurrentCampaign][1].Description
		Display_Campaign_Difficulty_Menu()
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Display_Load_Mission_Menu: Bring up the list of available missions.
-- -----------------------------------------------------------------------------------------------------------------------------
function Display_Load_Mission_Menu()	
	if Populate_Missions_Menu() then 
		Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Load_Mission_Buttons.Set_Hidden(false)
		MissionButtons[CampaignUserInfo.MissionCount].Set_Key_Focus()
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Get_Available_Missions_Count: Has the user unlocked any mission?
-- -----------------------------------------------------------------------------------------------------------------------------
function Get_Available_Missions_Count()
	if not CampaignUserInfo or not CampaignUserInfo.CurrentCampaign then 
		return 0
	end
	
	local mission_list = Missions[CampaignUserInfo.CurrentCampaign]
	if not mission_list then 
		return 0
	end

	-- If there are no available missions, we don't want to display the list box.
	local avaialable_missions_ct = 0
	for _, mission_data in pairs(mission_list) do
		-- Only add the new line if this mission is available (that is, have been completed or started!)
		if Get_Profile_Value(mission_data.PPKey, false) then   -- the bool param is for the default value!!!!!.
			avaialable_missions_ct = avaialable_missions_ct + 1
		end		
	end
	
	return avaialable_missions_ct
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Populate_Missions_Menu
-- -----------------------------------------------------------------------------------------------------------------------------
function Populate_Missions_Menu(update_missions_count)
	
	if not CampaignUserInfo then 
		--MessageBox("Populate_Missions_Menu::CampaignUserInfo is nil.")
		return false
	end
	
	if not CampaignUserInfo.CurrentCampaign then 
		--MessageBox("Populate_Missions_Menu::CampaignUserInfo.CurrentCampaign is nil.")
		return false
	end
	
	if update_missions_count then
		CampaignUserInfo.MissionCount = Get_Available_Missions_Count()
	end
	
	if not CampaignUserInfo.MissionCount or CampaignUserInfo.MissionCount <= 0 then 
		--MessageBox("Populate_Missions_Menu::(not CampaignUserInfo.MissionCount or CampaignUserInfo.MissionCount <= 0).")
		return false
	end
	
	if CampaignUserInfo.MissionCount > #MissionButtons then
		--MessageBox("There are more missions than buttons.  Aborting")
		return false
	end
	
	local mission_list = Missions[CampaignUserInfo.CurrentCampaign]
	if not mission_list then 
		--MessageBox("Populate_Missions_Menu::(not mission_list).")
		return false
	end

	-- If there are no available missions, we don't want the list box to get focus.
	local available_missions_ct = 0
	
	-- The list show start at the bottom so we must set the buttons from the higher one to the bottom one.
	local button_idx = CampaignUserInfo.MissionCount
	for _, mission_data in pairs(mission_list) do
		-- Only add the new line if this mission is available
		if Get_Profile_Value(mission_data.PPKey, false) then  -- the bool param is for the default value!!!!!.
			-- Display this mission!.
			local button = MissionButtons[button_idx]
			if TestValid(button) then 
				button.Set_Hidden(false)
				button.Set_Text(mission_data.Name)
				-- Each button carries the state name for the mission it represents.
				button.Set_User_Data(mission_data)
				available_missions_ct = available_missions_ct + 1
				
				button_idx = button_idx - 1
				-- make sure the button index is still legal.
				if button_idx < 1 then
					break
				end				
			end			
		end		
	end
	
	-- Hide the buttons that we don't need!!!!.
	for i = #MissionButtons, (CampaignUserInfo.MissionCount + 1), -1 do
		local button = MissionButtons[i]
		-- Do not do this because it resets the font assigned to the button!!!!.
		--button.Set_Text("")
		button.Set_Hidden(true)
		button.Set_User_Data(nil)	
	end
	
	return true
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Display_Campaign_Difficulty_Menu
-- -----------------------------------------------------------------------------------------------------------------------------
function Display_Campaign_Difficulty_Menu()
	
	this.Menu_Buttons.Load_Mission_Buttons.Back_Buttons.Set_Hidden(true)
	this.Menu_Buttons.Load_Mission_Buttons.Frame_1.Set_Hidden(true)
	this.Menu_Buttons.Campaign_Buttons.Back_Buttons.Set_Hidden(true)
	this.Menu_Buttons.Campaign_Buttons.Frame_1.Set_Hidden(true)

	-- We have to display the Load Mission Dialog.
	if not TestValid(this.Mission_Difficulty_Dialog) then 
		Create_Embedded_Scene("Gamepad_Mission_Difficulty_Dialog", this, "Mission_Difficulty_Dialog")
		this.Mission_Difficulty_Dialog.Set_Tab_Order(NextTabOrder)
		-- Update the tab order
		NextTabOrder = NextTabOrder + 1
		-- Position it centered on the screen.
		this.Mission_Difficulty_Dialog.Set_Screen_Position(0.5, 0.5)		
	else
		this.Mission_Difficulty_Dialog.Set_Hidden(false)
	end
	
	this.Mission_Difficulty_Dialog.Start_Modal(Launch_Mission)
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Launch_Mission
-- This function gets called whenever the Difficulty dialog ends modal.  It returns the difficulty
-- value selected for the current mission or nil to signal the process should be aborted.
-- -----------------------------------------------------------------------------------------------------------------------------
function Launch_Mission(dlg, difficulty)

	this.Menu_Buttons.Load_Mission_Buttons.Back_Buttons.Set_Hidden(false)
	this.Menu_Buttons.Load_Mission_Buttons.Frame_1.Set_Hidden(false)
	this.Menu_Buttons.Campaign_Buttons.Back_Buttons.Set_Hidden(false)
	this.Menu_Buttons.Campaign_Buttons.Frame_1.Set_Hidden(false)

	-- Hide the Difficulty Dialog.
	this.Mission_Difficulty_Dialog.Set_Hidden(true)
	
	if not difficulty then
		-- The Difficulty dialog has been dismissed.
		-- Restore focus
		if TestValid(CampaignUserInfo.CurrentMissionButton) then 
			CampaignUserInfo.CurrentMissionButton.Set_Key_Focus()
		elseif TestValid(CampaignUserInfo.CurrentCampaignButton) then 
			CampaignUserInfo.CurrentCampaignButton.Set_Key_Focus()
		else
			Mainmenu.Focus_First()
		end
		
		-- Done!
		return
	end
	
	-- Go ahead and start the currently selected mission with the currently selected difficulty.
	if not CampaignUserInfo then 
		MessageBox("Gamepad_Main_Menu::Launch_Mission: CampaignUserInfo is nil. ABORTING")
		return
	end
	
	if not CampaignUserInfo.MissionName or not CampaignUserInfo.CurrentCampaign then
		MessageBox("Gamepad_Main_Menu::Launch_Mission: No mission state name? or no Current Campaing name?")
		return
	end
	
	-- Insert the debug mission name into the game script data table
	local data_table = GameScoringManager.Get_Game_Script_Data_Table()
	if data_table == nil then
		data_table = { }
	end
	data_table.Start_Mission = CampaignUserInfo.MissionName
	data_table.Loading_Screen_Faction_ID = CampaignUserInfo.FactionID
	data_table.Loading_Screen_Mission_Text = CampaignUserInfo.MissionText
	GameScoringManager.Set_Game_Script_Data_Table(data_table)

	-- Launch the campaign for the selected mission	
	CampaignManager.Start_Campaign(Campaign_Name[CampaignUserInfo.CurrentCampaign], difficulty)
	
	Play_SFX_Event("GUI_Main_Menu_Button_Select")	
end


-- -----------------------------------------------------------------------------------------------------------------------------.
-- Campaign_Tutorial_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Tutorial_Button_Clicked(event_name, source)
	
	-- Start storing the data related to the currently selected campaign!	
	CampaignUserInfo = { }
	CampaignUserInfo.CurrentCampaign = PG_CAMPAIGN_PRELUDE
	CampaignUserInfo.CurrentCampaignButton = source
	
	Execute_Play_Campaign()	
end

-- -----------------------------------------------------------------------------------------------------------------------------.
-- Campaign_Novus_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Novus_Button_Clicked(event_name, source)
	-- Start storing the data related to the currently selected campaign!
	CampaignUserInfo = {}
	CampaignUserInfo.CurrentCampaign = PG_CAMPAIGN_NOVUS
	CampaignUserInfo.CurrentCampaignButton = source
	
	Execute_Play_Campaign()	
end


-- -----------------------------------------------------------------------------------------------------------------------------
-- Campaign_Hierarchy_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Hierarchy_Button_Clicked(event_name, source)

	-- Start storing the data related to the currently selected campaign!
	CampaignUserInfo = {}
	CampaignUserInfo.CurrentCampaign = PG_CAMPAIGN_ALIEN
	CampaignUserInfo.CurrentCampaignButton = source
	
	Execute_Play_Campaign()	
end

-- -----------------------------------------------------------------------------------------------------------------------------
-- Campaign_Masari_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Masari_Button_Clicked(event_name, source)

	-- Start storing the data related to the currently selected campaign!
	CampaignUserInfo = {}
	CampaignUserInfo.CurrentCampaign = PG_CAMPAIGN_MASARI
	CampaignUserInfo.CurrentCampaignButton = source
	
	Execute_Play_Campaign()		
end

function Campaign_Scenario_Button_Clicked(event_name, source)

	if not TestValid(this.Scenario_Setup_Dialog) then
		Create_Embedded_Scene("Scenario_Setup_Dialog", this, "Scenario_Setup_Dialog")
		this.Scenario_Setup_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1
	else
		this.Scenario_Setup_Dialog.Set_Hidden(false)
	end
	this.Scenario_Setup_Dialog.Start_Modal()
end

function Campaign_Load_Game_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Load_Campaign_Game_Dialog) then
		Create_Embedded_Scene("Load_Game_Dialog", Mainmenu, "Load_Campaign_Game_Dialog")
		this.Load_Campaign_Game_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1		
	else
		Mainmenu.Load_Campaign_Game_Dialog.Set_Hidden(false)
	end
	Load_Dialog_Call_From = CAMPAIGN_LOAD_GAME
	Mainmenu.Load_Campaign_Game_Dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	Mainmenu.Load_Campaign_Game_Dialog.Display_Dialog()
	Mainmenu.Load_Campaign_Game_Dialog.Start_Modal()
end

function Campaign_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Key_Focus()
	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
end

---------------------------------------
-- Skirmish Menu Button Events
---------------------------------------

function Skirmish_New_Game_Button_Clicked(event_name, source)
	Main_Menu_Passivate_Movies()
	if not TestValid(Mainmenu.Skirmish_Setup_Dialog) then
		local handle
		handle = Create_Embedded_Scene("Skirmish_Setup_Dialog", Mainmenu, "Skirmish_Setup_Dialog")
		this.Skirmish_Setup_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1				
	else
		Mainmenu.Skirmish_Setup_Dialog.Set_Hidden(false)
	end
	Mainmenu.Skirmish_Setup_Dialog.Start_Modal()
	Main_Menu_Passivate_Movies()
end

function Skirmish_Load_Game_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Load_Skirmish_Game_Dialog) then
		Create_Embedded_Scene("Load_Game_Dialog", Mainmenu, "Load_Skirmish_Game_Dialog")
		this.Load_Skirmish_Game_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1	
	else
		Mainmenu.Load_Skirmish_Game_Dialog.Set_Hidden(false)
	end
	Load_Dialog_Call_From = SKIRMISH_LOAD_GAME
	Mainmenu.Load_Skirmish_Game_Dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	Mainmenu.Load_Skirmish_Game_Dialog.Display_Dialog()
	Mainmenu.Load_Skirmish_Game_Dialog.Start_Modal()
end

function Skirmish_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Key_Focus()
	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
end

---------------------------------------
-- Debug Menu Button Events
---------------------------------------

function Debug_Milestone_Button_Clicked(event_name, source)
	CampaignManager.Start_Campaign("Even_Split_Global_Campaign_Novus")
end

function Debug_Load_Map_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Game_Map_Loader) then
		local handle = Create_Embedded_Scene("Game_Map_Loader", Mainmenu, "Game_Map_Loader")
		this.Game_Map_Loader.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1			
	else
		Mainmenu.Game_Map_Loader.Set_Hidden(false)
	end
	Mainmenu.Game_Map_Loader.Start_Modal() -- added at James' request 4/18/2007 8:38:09 PM -- NSA
	-- JLH [3/1/2007]:  Remove this after the load map dialog is proven.
	--Open_Dialog("Debug_Load_Map")
	--Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_MouseOff()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Debug_Achievement_Chest_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Achievement_Chest) then
		local handle = Create_Embedded_Scene("Achievement_Chest", Mainmenu, "Achievement_Chest")
		this.Achievement_Chest.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1
	else
		Mainmenu.Achievement_Chest.Set_Hidden(false)
	end
end

function Debug_Load_Mission_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Debug_Load_Mission_Dialog) then
		local handle = Create_Embedded_Scene("Debug_Load_Mission_Dialog", Mainmenu, "Debug_Load_Mission_Dialog")
		this.Debug_Load_Mission_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1		
	else
		Mainmenu.Debug_Load_Mission_Dialog.Set_Hidden(false)
	end
	Mainmenu.Debug_Load_Mission_Dialog.Start_Modal()
end

function Debug_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Debug_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Key_Focus()
end

---------------------------------------
-- Multi Player Menu Button Events
---------------------------------------


function Common_Ranked_Game_Clicked(match_mode)

	this.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(true)
	this.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(true)

	QuickMatchMode = match_mode
	-- If there is already a connection attempt in progress, don't respond to clicks
	local progress_dialog_busy = (TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy())
	local internet_dialog_busy = (TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy())
	if (progress_dialog_busy or internet_dialog_busy) then
		return
	end

	if Net.Get_Signin_State() ~= "online" then
		Net.Show_Signin_UI(true)
		return
	end
	
	-- Disable attract mode until ranked game dialog closes
	Allow_Attract_Mode(false)
	if not TestValid(Mainmenu.Network_Progress_Bar) then
		local handle = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
	else
		Mainmenu.Network_Progress_Bar.Set_Hidden(false)
	end

	Mainmenu.Network_Progress_Bar.Start()
	Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
	Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
	Mainmenu.Network_Progress_Bar.Start_Modal()
	PGCrontab_Schedule(Start_Ranked_Game, 0, 1)

end

---------------------------------------
--
---------------------------------------
function Multiplayer_Ranked_Game_Clicked(event_name, source)
	Common_Ranked_Game_Clicked(0)
	Net_Dialog_Call_From = RANKED_NET_MATCH
end

---------------------------------------
--
---------------------------------------
function Multiplayer_Sign_In_Clicked(event_name, source)
	Net.Show_Signin_UI(true)
end

---------------------------------------
--
---------------------------------------
function Multiplayer_Custom_Match_Clicked(event_name, source)

	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(true)

	-- We need to put up a dialog asking if they want a quick or custom match.
	
	if Accepting_Invitation then
		-- Make sure the right menus are showing
		Set_Menus_For_Live_Logon_State()
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Debug_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
		Mainmenu.Focus_First()

		Ensure_Valid_Storage_Device()
		Start_Custom_Player_Match_Lobby()
	else
		YesNoOkDialogState = MSG_PLAYER_MATCH_QUESTION

		if not TestValid(Mainmenu.Player_Match_Dialog) then
			Create_Embedded_Scene("Player_Match_Dialog", Mainmenu, "Player_Match_Dialog")
			this.Player_Match_Dialog.Set_Screen_Position(0.5, 0.5)
		end

		Mainmenu.Player_Match_Dialog.Set_Hidden(false)	
		Mainmenu.Player_Match_Dialog.Bring_To_Front()
		Mainmenu.Player_Match_Dialog.Start_Modal()
	end
	
end

---------------------------------------
--
---------------------------------------
function Start_Custom_Player_Match_Lobby()

	-- If there is already a connection attempt in progress, don't respond to clicks
	local progress_dialog_busy = (TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy())
	local internet_dialog_busy = (TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy())
	if (progress_dialog_busy or internet_dialog_busy) then
		return
	end

	if Net.Get_Signin_State() ~= "online" then
		Net.Show_Signin_UI(true)
		return
	end
	
	-- Attempt an internet connection.  If successful, the Multiplayer_Internet_Connect_Successful()
	-- function will be called, where we pop up the internet dialog.
	DebugMessage("Multiplayer_Internet_Button_Clicked():: Attempting to connect.  Please wait...\n");

	if not TestValid(Mainmenu.Network_Progress_Bar) then
		local handle = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
	else
		Mainmenu.Network_Progress_Bar.Set_Hidden(false)
	end

	Mainmenu.Network_Progress_Bar.Start()
	Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
	Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
	Mainmenu.Network_Progress_Bar.Start_Modal()
	PGCrontab_Schedule(Start_Internet_Lobby, 0, 1)

end

-------------------------------------------------------------------------------
-- Global conquest button clicked.
-------------------------------------------------------------------------------
function Multiplayer_Conquer_The_World_Button_Clicked(event_name, source)

	-- If there is already a connection attempt in progress, don't respond to clicks
	local progress_dialog_busy = (TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy())
	local internet_dialog_busy = (TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy())
	if (progress_dialog_busy or internet_dialog_busy) then
		return
	end

	if Net.Get_Signin_State() ~= "online" then
		Net.Show_Signin_UI(true)
		return
	end
	
	-- Attempt a LAN connection.  If successful, the On_LAN_Init()
	-- function will be called, and we will enter the global conquest lobby.

	if not TestValid(Mainmenu.Network_Progress_Bar) then
		local handle = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
	else
		Mainmenu.Network_Progress_Bar.Set_Hidden(false)
	end

	-- load the global conquest asset bank now
	Mainmenu.Network_Progress_Bar.Start({"Bank_Global_Conquest", "Bank_Map_Preview"})
	Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
	Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
	Mainmenu.Network_Progress_Bar.Start_Modal()

	--PGCrontab_Schedule(Start_Global_Conquest_Lobby, 0, 1)
	-- JAC - Immediately starting the global conquest lobby
	-- Hiding the multiplayer buttons
	Main_Menu_Passivate_Movies()
	Start_Global_Conquest_Lobby()

end

function Set_Menus_For_Live_Logon_State()
	local new_state
	local signin_state = Net.Get_Signin_State()
	if signin_state == "online" then
		new_state = 1
		if Net.Requires_Locator_Service() == false then
			new_state = 2
		end
	elseif signin_state == "local" or signin_state == "multi" or signin_state == "non-live" then
		new_state = 3
	end
   
	OutputDebug("Set_Menus_For_Live_Logon_State -- old_state: %s, new_state: %s\n", 
		tostring(LiveLogonState), tostring(new_state))
	
	if LiveLogonState ~= new_state then
		-- enable everything...
		LiveLogonState = new_state
		if BETA_BUILD ~= true then
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Enable(true)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Enable(true)
		end
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Enable(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Enable(true)
		--Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Enable(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Enable(true)
		if LiveLogonState == nil or LiveLogonState == 3 then
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Hidden(false)
		else
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Hidden(true)
		end

		if LiveLogonState ~= 2 then
			if BETA_BUILD ~= true then
				Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Enable(false)
			end
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Enable(false)
			--Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Enable(false)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Enable(false)
			if LiveLogonState == nil or LiveLogonState == 3 then
				Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Enable(false)
				if LiveLogonState == nil then
					if BETA_BUILD ~= true then
						Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Enable(false)
					end
				end
			end
		end
	end
end


-------------------------------------------------------------------------------
-- On_Network_Event()
-------------------------------------------------------------------------------
function On_Network_Event(event)
	if (event == nil) then
		DebugMessage("LUA_NET: ERROR: Got a nil network event!")
	elseif (event.type == NETWORK_EVENT_TASK_COMPLETE) then
		if event.task == "TASK_LIVE_CONNECTION_CHANGED" then
			OutputDebug("On_Network_Event::TASK_LIVE_CONNECTION_CHANGED\n")
			Set_Menus_For_Live_Logon_State()
		elseif event.task == "TASK_LIVE_SIGNIN_CHANGED" then
			OutputDebug("On_Network_Event::TASK_LIVE_SIGNIN_CHANGED\n")

			-- MLL: Close the stupid dialog box if the user opened the blade manually.
			if YesNoOkDialogState == MSG_PROFILE_NEEDED then
				if SaveLoadManager.Ensure_Valid_Gamer_Profile() then
					this.Yes_No_Ok_Dialog.End_Modal()
					this.Yes_No_Ok_Dialog.Set_Hidden(true)
				end
			end

			-- On a sign out back all the way out
			if event.state == nil then
				Skip_To_Main_Menu()
			end

			Set_Menus_For_Live_Logon_State()
		elseif event.task == "TASK_LIVE_UI_ACTIVE" then
			OutputDebug("On_Network_Event::TASK_LIVE_UI_ACTIVE\n")

			-- If we just closed the device selector UI do the check
			if StorageDeviceUIActive and (event.is_active == false) then
				StorageDeviceUIActive = false

				-- Needed to properly determine whether the storage device is invalid
				SaveLoadManager.Update()
				SaveLoadManager.Get_List_Needs_Refresh()

				local valid_storage_device = not SaveLoadManager.Get_Is_Storage_Device_Invalid()
				if not valid_storage_device and (ValidStorageDevice ~= valid_storage_device) then
					YesNoOkDialogState = MSG_STORAGE_DEVICE_NEEDED

					local model = {}
					model.Message = "TEXT_GAMEPAD_NO_STORAGE_DEVICE_WARNING"
					this.Yes_No_Ok_Dialog.Set_Model(model)
					this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
					this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(false)
					Show_Message_Box()
				end
				ValidStorageDevice = valid_storage_device
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Leaderboard button clicked.
-------------------------------------------------------------------------------
function Multiplayer_Leaderboards_Button_Clicked()
	Main_Menu_Passivate_Movies()
	if not TestValid(Mainmenu.Leaderboard_Dialog) then
		local handle = Create_Embedded_Scene("Leaderboard_Dialog", Mainmenu, "Leaderboard_Dialog")
	else
		Mainmenu.Leaderboard_Dialog.Set_Hidden(false)
	end
	Mainmenu.Leaderboard_Dialog.Start_Modal()
end

-------------------------------------------------------------------------------
-- Quick Match button clicked.
-------------------------------------------------------------------------------
function Main_Menu_Quick_Match_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Set_Key_Focus()
	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Set_Key_Focus()

	focus_handle = Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game

	something_has_focus = false

end

---------------------------------------
-- LAN play button clicked.
---------------------------------------
function Multiplayer_LAN_Button_Clicked(event_name, source)

	-- If there is already a connection attempt in progress, don't respond to clicks
	local progress_dialog_busy = (TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy())
	local internet_dialog_busy = (TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy())
	if (progress_dialog_busy or internet_dialog_busy) then
		return
	end

	if Net.Get_Signin_State() == nil then
		Net.Show_Signin_UI(true)
		return
	end

	-- Attempt a LAN connection.  If successful, the On_LAN_Init()
	-- function will be called, where we enter the LAN lobby dialog.

	if not TestValid(Mainmenu.Network_Progress_Bar) then
		local handle = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
	else
		Mainmenu.Network_Progress_Bar.Set_Hidden(false)
	end

	Mainmenu.Network_Progress_Bar.Start()
	Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
	Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
	Mainmenu.Network_Progress_Bar.Start_Modal()
	PGCrontab_Schedule(Start_LAN_Lobby, 0, 1)
	
end

-- TODO: Implement the load replay dialog and hook it in
function Multiplayer_Load_Replay_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Load_Replay_Dialog) then
		Create_Embedded_Scene("Load_Game_Dialog", Mainmenu, "Load_Replay_Dialog")
	else
		Mainmenu.Load_Replay_Dialog.Set_Hidden(false)
	end
	Load_Dialog_Call_From = MULTIPLAYER_LOAD_GAME
	Mainmenu.Load_Replay_Dialog.Set_Mode(SAVE_LOAD_MODE_REPLAY)
	Mainmenu.Load_Replay_Dialog.Display_Dialog()
	Mainmenu.Load_Replay_Dialog.Start_Modal()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_LAN_Lobby()

	Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing LAN lobby...")
	DebugMessage("Start_LAN_Lobby():: Successful LAN connection.\n");
	Main_Menu_Passivate_Movies()
	
	if (ENABLE_NEW_MULTIPLAYER_FLOW) then
	
		if not TestValid(Mainmenu.Live_Profile_Game_Dialog) then
			local handle = Create_Embedded_Scene("Live_Profile_Game_Dialog", Mainmenu, "Live_Profile_Game_Dialog")
			this.Live_Profile_Game_Dialog.Set_Tab_Order(NextTabOrder)
			NextTabOrder = NextTabOrder + 1					
		else
			Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(false)
		end

		Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(false)
		Mainmenu.Live_Profile_Game_Dialog.Set_Network_State_LAN()
	
	else
	
		if not TestValid(Mainmenu.LAN_Lobby_Dialog) then
			local handle = Create_Embedded_Scene("LAN_Lobby_Dialog", Mainmenu, "LAN_Lobby_Dialog")
			this.LAN_Lobby_Dialog.Set_Tab_Order(NextTabOrder)
			NextTabOrder = NextTabOrder + 1				
		else
			Mainmenu.LAN_Lobby_Dialog.Set_Hidden(false)
		end
		Mainmenu.LAN_Lobby_Dialog.Set_Network_State_LAN()
	end
	
	Mainmenu.Network_Progress_Bar.Stop()
	Mainmenu.Network_Progress_Bar.Set_Hidden(true)
	
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Ranked_Game()

	Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing Ranked lobby...")
	DebugMessage("Start_Ranked_Game():: Successful Internet connection.\n");
	
	if not TestValid(Mainmenu.Ranked_Game_Dialog) then
		local handle = Create_Embedded_Scene("Ranked_Game_Dialog", Mainmenu, "Ranked_Game_Dialog")
		this.Ranked_Game_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1					
	else
		Mainmenu.Ranked_Game_Dialog.Set_Hidden(false)
	end

	Mainmenu.Ranked_Game_Dialog.Start_Modal()
	Mainmenu.Ranked_Game_Dialog.Start_Quick_Match_Mode(QuickMatchMode)
	Mainmenu.Network_Progress_Bar.Stop()
	Mainmenu.Network_Progress_Bar.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Internet_Lobby_Active()
	if TestValid(Mainmenu.Live_Profile_Game_Dialog) then
		return Mainmenu.Live_Profile_Game_Dialog.Get_Hidden() ==  false
	end
	return false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Join_For_Invite()
	if Accepting_Invitation and TestValid(Mainmenu.Live_Profile_Game_Dialog) and Mainmenu.Live_Profile_Game_Dialog.Get_Hidden() == false then
		Accepting_Invitation = false
		Mainmenu.Live_Profile_Game_Dialog.Set_Is_Accepting_Invitation()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Internet_Lobby()

	Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing Internet lobby...")
	DebugMessage("Start_Internet_Lobby():: Successful Internet connection.\n");
	Main_Menu_Passivate_Movies()
	
	if (ENABLE_NEW_MULTIPLAYER_FLOW) then
	
		if not TestValid(Mainmenu.Live_Profile_Game_Dialog) then
			local handle = Create_Embedded_Scene("Live_Profile_Game_Dialog", Mainmenu, "Live_Profile_Game_Dialog")
			this.Live_Profile_Game_Dialog.Set_Tab_Order(NextTabOrder)
			NextTabOrder = NextTabOrder + 1					
			Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(true)
		end
		Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(false)
		Mainmenu.Live_Profile_Game_Dialog.Set_Network_State_Internet()
	
	else
	
		if not TestValid(Mainmenu.Internet_Lobby_Dialog) then
			local handle = Create_Embedded_Scene("Internet_Lobby_Dialog", Mainmenu, "Internet_Lobby_Dialog")
			this.Internet_Lobby_Dialog.Set_Tab_Order(NextTabOrder)
			NextTabOrder = NextTabOrder + 1					
		else
			Mainmenu.Internet_Lobby_Dialog.Set_Hidden(false)
		end
		Mainmenu.Internet_Lobby_Dialog.Set_Network_State_Internet()
		
	end
	
	Mainmenu.Network_Progress_Bar.Stop()
	Mainmenu.Network_Progress_Bar.Set_Hidden(true)
		
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Global_Conquest_Lobby()
	--Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing Global Conquest...")
	DebugMessage("LUA_LOBBY: Starting global conquest lobby...")
	
	-- if we haven't finished loading the asset bank, just reschedule again
	if not Mainmenu.Network_Progress_Bar.Is_Done() then
		PGCrontab_Schedule(Start_Global_Conquest_Lobby, 0, 1)
		return
	end
	
	if not TestValid(Mainmenu.Global_Conquest_Lobby) then
		local handle = Create_Embedded_Scene("Global_Conquest_Lobby", Mainmenu, "Global_Conquest_Lobby")
			this.Global_Conquest_Lobby.Set_Tab_Order(NextTabOrder)
			NextTabOrder = NextTabOrder + 1			
	else
		-- need to rebuild the graphics of the conquest lobby since there is no loading on demand for the XBOX
		-- the models in the asset bank had not been loaded when Rebuild_Graphics() was originally called
		-- so do it now to set the models (since the asset bank has been loaded by now)
		-- still happens for PC, but is trivial
		Mainmenu.Global_Conquest_Lobby.Rebuild_Graphics()
		Mainmenu.Global_Conquest_Lobby.Set_Hidden(false)
	end
	Mainmenu.Network_Progress_Bar.Stop()
	Mainmenu.Network_Progress_Bar.Set_Hidden(true)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Multiplayer_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer.Set_Key_Focus()
	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
end



---------------------------------------
-- Quick Match Menu Button Events
---------------------------------------


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Multiplayer_QM_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(true)
	--Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Multiplayer_QM_Player_Button_Clicked(event_name, source)
	Common_Ranked_Game_Clicked(1)
	Net_Dialog_Call_From = QUICK_PLAYER_NET_MATCH
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Quick_Player_Match_Lobby()
	Common_Ranked_Game_Clicked(1)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Multiplayer_QM_Ranked_Button_Clicked(event_name, source)
	Common_Ranked_Game_Clicked(2)
	Net_Dialog_Call_From = QUICK_RANKED_NET_MATCH
end

---------------------------------------
-- Tutorials Menu Button Events
---------------------------------------

function Load_Tutorial_Movie(state_name)
	-- Insert the tutorial name into the game script data table
	local data_table = GameScoringManager.Get_Game_Script_Data_Table()
	if data_table == nil then
		data_table = { }
	end
	data_table.Tutorial = state_name
	GameScoringManager.Set_Game_Script_Data_Table(data_table)

	-- Start the campaign for the selected mission
	CampaignManager.Start_Campaign("Tutorial_Cinematics")
end

function Tutorial_Button_1_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_1")
end

function Tutorial_Button_2_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_2")
end

function Tutorial_Button_3_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_3")
end

function Tutorial_Button_4_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_4")
end

function Tutorial_Button_5_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_5")
end

function Tutorial_Button_6_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_6")
end

function Tutorial_Button_7_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_7")
end

function Tutorial_Button_8_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_8")
end

function Tutorial_Button_9_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_9")
end

function Tutorial_Button_10_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_10")
end

function Tutorial_Button_11_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_11")
end

function Tutorial_Button_12_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_12")
end

function Tutorial_Button_13_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_13")
end

function Tutorial_Button_14_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_14")
end

function Tutorial_Button_15_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_15")
end

function Tutorial_Button_16_Clicked(event_name, source)
	Load_Tutorial_Movie("State_Tutorial_16")
end

function Tutorial_Button_Back_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Set_Key_Focus()
end

---------------------------------------
-- Options Menu Button Events
---------------------------------------

function Options_Audio_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Audio_Options_Dialog) then
		Create_Embedded_Scene("Audio_Options_Dialog", Mainmenu, "Audio_Options_Dialog")
	else
		Mainmenu.Audio_Options_Dialog.Set_Hidden(false)
	end
	Mainmenu.Audio_Options_Dialog.Start_Modal()
end

function Options_Video_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Video_Options_Dialog) then
		Create_Embedded_Scene("Video_Options_Dialog", Mainmenu, "Video_Options_Dialog")
	else
		Mainmenu.Video_Options_Dialog.Set_Hidden(false)
	end
	Mainmenu.Video_Options_Dialog.Start_Modal()
end

function Options_Network_Button_Clicked(event_name, source)
	-- GUIv2 Dialog
	--local handle = Create_Embedded_Scene("Network_Options_Dialog", Mainmenu, "Network_Options_Dialog")

	-- Old GUI Dialog
	-- Open_Dialog("Network_Options")
	Net.Show_Gamer_Card_UI()
end


function Options_Keyboard_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Keyboard_Options) then
		local handle = Create_Embedded_Scene("Keyboard_Configuration_Dialog", Mainmenu, "Keyboard_Options")
		this.Keyboard_Options.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1				
	else
		Mainmenu.Keyboard_Options.Set_Hidden(false)
	end
	Mainmenu.Keyboard_Options.Start_Modal()
end

function Gamepad_Options_Dialog_Selected()
-- Gamepad_ButtonMap.bui
	if not TestValid(Mainmenu.Gamepad_ButtonMap) then
		Create_Embedded_Scene("Gamepad_ButtonMap", Mainmenu, "Gamepad_ButtonMap")
		this.Gamepad_ButtonMap.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1				
	else
		Mainmenu.Gamepad_ButtonMap.Set_Hidden(false)
	end
	Mainmenu.Gamepad_ButtonMap.Start_Modal()
end

function Options_Game_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Gameplay_Options_Dialog) then
		Create_Embedded_Scene("Gameplay_Options_Dialog", Mainmenu, "Gameplay_Options_Dialog")
	else
		Mainmenu.Gameplay_Options_Dialog.Set_Hidden(false)
	end
	Mainmenu.Gameplay_Options_Dialog.Start_Modal()
end

function Options_Credits_Button_Clicked(event_name, source)
	Display_Credits()
end

function Display_Credits()
	--Must stop the main menu background movie here since
	--we're about to start a HUGE new movie on top
	Main_Menu_Passivate_Movies(true)
	Stop_All_Music()
	Roll_Credits()
end

function On_Credits_Done()
	Main_Menu_Activate_Movies()	
end

function Options_Trailer_Button_Clicked()
	Play_Full_Screen_Movie("Trailer.bik",false)
end

function Options_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Key_Focus()
	SaveLoadManager.Lock_Systems_To_Last_Active_Profile(false)
end

---------------------------------------
-- Utility functions
---------------------------------------

function Skip_To_Options_Dialog()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(false)
end

function Skip_To_Campaign_Dialog()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(false)
	Enable_Campaign_Buttons()
end

function Skip_To_Multiplayer_Dialog()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
end

function Skip_To_Main_Menu()
	while Mainmenu.Menu_Buttons.Main_Menu_Buttons.Get_Hidden() do
		Controller_Key_As_Back()
	end

	if TestValid(this.Mission_Difficulty_Dialog) then 
		this.Mission_Difficulty_Dialog.End_Modal()
	end
end

function Play_Click() 
	Play_SFX_Event("GUI_Generic_Button_Select")
end

function Play_Alien_Steam() 
	Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end

function Debug_Start_AI_Skirmish()

	ClientTable = {}

	-- Setup the local player
	ClientTable[1] = {}
	ClientTable[1].name = Create_Wide_String("LocalPlayer")
	ClientTable[1].common_addr = Net.Get_Local_Addr()
	ClientTable[1].faction = "Novus"
	ClientTable[1].color = 15
	ClientTable[1].is_ai = false
	ClientTable[1].team = 1
	LocalClient = ClientTable[1]

	-- Setup the AI Player
	ClientTable[2] = {}
	ClientTable[2].name = Create_Wide_String("AIPlayer")
	ClientTable[2].common_addr = "AIPlayer1"
	ClientTable[2].faction = "Alien"
	ClientTable[2].color = 2
	ClientTable[2].is_ai = true
	ClientTable[2].ai_difficulty = 1
	ClientTable[2].team = 2

	GameOptions.seed = 12345
	GameOptions.map_name = ".\\Data\\Art\\Maps\\M29_Brazillian_Highlands.ted"
	GameOptions.is_campaign = false
	GameOptions.is_lan = false
	GameOptions.is_internet = false
	
	GameScriptData.victory_condition = VICTORY_CONQUER	
	Net.MM_Start_Game(GameOptions, ClientTable)
	
	-- Now that the game is started, update the ClientTable with all the newly-assigned
	-- player IDs.
	for _, client in pairs(ClientTable) do
		client.PlayerID = Net.Get_Player_ID_By_Network_Address(client.common_addr)
		if (client.common_addr == LocalClient.common_addr) then
			LocalClient.PlayerID = client.PlayerID
		end
	end

	-- Hand off the client table to the game scoring script.
	Set_Player_Info_Table(ClientTable)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
end

function Set_State_Restart_Map()
	DebugMessage("LUA_MAIN_MENU: Set_State_Restart_Map().")
	Mainmenu.Skirmish_Setup_Dialog.Set_Restarting_Map(true)
	if Save_Restart_Map_Data() then
		this.Set_State("restart_map")
	end
end

function On_Enter_State_Restart_Map()
	DebugMessage("LUA_MAIN_MENU: Entering restart map state.")
	this.Set_State("default")
end

function On_Exit_State_Restart_Map()
	DebugMessage("LUA_MAIN_MENU: Exiting restart map state.")
	Restart_Map()
end

function Save_Restart_Map_Data()
	DebugMessage("LUA_MAIN_MENU: Saving restart map data.")
	Register_Game_Scoring_Commands()
	
	-- Grab the client table	
	local ctable = GameScoringManager.Get_Player_Info_Table()
	if ctable == nil or ctable.ClientTable == nil then return false end
	RestartClientTable = ctable.ClientTable
	
	-- Grab the local client table
	RestartLocalClientTable = GameScoringManager.Get_Local_Client_Table()
	if RestartLocalClientTable == nil then return false end

	-- Grab the game options
	RestartGameScriptData = GameScoringManager.Get_Game_Script_Data_Table()
	if RestartGameScriptData == nil or RestartGameScriptData.GameOptions == nil then return false end
	
	return true
end


function Restart_Map()

	DebugMessage("LUA_MAIN_MENU: ---> RESTARTING MAP <---")
	
	local itable = {}
	for _, client in pairs(RestartClientTable) do
		table.insert(itable, client)
	end

	Net.MM_Start_Game(RestartGameScriptData.GameOptions, itable)
	
	-- Now that the game is started, update the Client_Table with all the newly-assigned
	-- player IDs.
	for _, client in pairs(RestartClientTable) do
		if client.common_addr == RestartLocalClientTable.common_addr then
			client.PlayerID = RestartLocalClientTable.PlayerID
		else
			client.PlayerID = Net.Get_Player_ID_By_Network_Address(client.common_addr)
		end
	end	
	
	Set_Player_Info_Table(RestartClientTable)
	GameScoringManager.Set_Local_Client_Table(RestartLocalClientTable)
	GameScoringManager.Set_Game_Script_Data_Table(RestartGameScriptData)
	
	RestartClientTable = nil
	RestartGameScriptData = nil
	Mainmenu.Skirmish_Setup_Dialog.Set_Restarting_Map(false)

	RestartLocalClientTable = nil

	Mainmenu.Skirmish_Setup_Dialog.On_Play_Again_Restart()
	
end

function Accept_Invitation()

	Accepting_Invitation = true
	Multiplayer_Custom_Match_Clicked()

end

function On_Update_Notification_Clicked(event)
	if event == 1 then
		if (NonLiveUpdateAvailable == true) then
			Net.Open_Browser_For_Non_Live_Update();
			Net.Unregister_Event_Handler(On_Network_Event)
			Net.Shutdown()
			Quit_App_Now()
		end
	end
end

function Controller_Key_As_Back(event_name, source)
	local play_sfx = true
	if ( Mainmenu.Menu_Buttons.Campaign_Buttons.Get_Hidden() == false ) then
		Campaign_Back_Button_Clicked(event_name, source)
	elseif ( Mainmenu.Menu_Buttons.Skirmish_Buttons.Get_Hidden() == false ) then
		Skirmish_Back_Button_Clicked(event_name, source)
	elseif ( Mainmenu.Menu_Buttons.Debug_Buttons.Get_Hidden() == false ) then
		Debug_Back_Button_Clicked(event_name, source)
	elseif ( Mainmenu.Menu_Buttons.Multiplayer_Buttons.Get_Hidden() == false ) then
		Multiplayer_Back_Button_Clicked(event_name, source)
	elseif ( Mainmenu.Menu_Buttons.Tutorial_Buttons.Get_Hidden() == false ) then
		Tutorial_Button_Back_Clicked(event_name, source)
	elseif ( Mainmenu.Menu_Buttons.Option_Buttons.Get_Hidden() == false ) then
		Options_Back_Button_Clicked(event_name, source)
	elseif ( Mainmenu.Menu_Buttons.Main_Menu_Buttons.Get_Hidden() == false ) then
		--print( "Main_Menu_Buttons are visible" )
		play_sfx = false
	elseif ( Mainmenu.Menu_Buttons.Quick_Match_Buttons.Get_Hidden() == false ) then
		Multiplayer_QM_Back_Button_Clicked(event_name, source)
	--elseif ( Mainmenu.FullScreenMovieGroup.Get_Hidden() == false ) then
	--	Stop_Full_Screen_Movie()
	--	this.Focus_First()
	elseif (Mainmenu.Menu_Buttons.Load_Mission_Buttons.Get_Hidden() == false) then
		Load_Mission_Button_Back_Clicked()		
	else
		print( "ERROR: none of the MainMenu button groups are visible" )
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
		play_sfx = false
	end
	
	if play_sfx then 
		-- Play the Back button sound!
		Play_SFX_Event("GUI_Main_Menu_Back_Select")
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Heavyweight_Child_Scene_Closing(source, event, from_string)
	Main_Menu_Activate_Movies()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_MENU })
	if not Accepting_Invitation then
		if ( from_string == "Skirmish_Setup_Dialog" ) then
			Main_Menu_Skirmish_Button_Clicked()
			Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load.Set_Key_Focus()
			focus_handle = Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_New_Game
		elseif ( from_string == "Live_Profile_Game_Dialog" ) then
			Main_Menu_Multiplayer_Button_Clicked()
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)

			focus_handle = Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match
		elseif ( from_string == "Scenario_Setup_Dialog" ) then
			Main_Menu_Campaign_Button_Clicked()
			focus_handle = Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Scenarios
		elseif ( from_string == "Global_Conquest_Lobby" ) then
			Main_Menu_Multiplayer_Button_Clicked()
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Set_Key_Focus()
			focus_handle = Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World
		elseif ( from_string == "Leaderboard_Dialog" ) then
			Main_Menu_Multiplayer_Button_Clicked()
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)
			focus_handle = Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards
		elseif ( from_string == "Ranked_Game_Dialog" ) then
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Back_Buttons.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Frame_1.Set_Hidden(false)
			if ( Net_Dialog_Call_From == RANKED_NET_MATCH ) then
				Main_Menu_Multiplayer_Button_Clicked()
				focus_handle = Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game
			elseif ( Net_Dialog_Call_From == QUICK_PLAYER_NET_MATCH ) then
				Main_Menu_Quick_Match_Button_Clicked()
				Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Set_Key_Focus()
				Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Set_Key_Focus()
				focus_handle = Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match
			elseif ( Net_Dialog_Call_From == QUICK_RANKED_NET_MATCH ) then
				Main_Menu_Quick_Match_Button_Clicked()
				Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Set_Key_Focus()
				focus_handle = Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game
			end
			Net_Dialog_Call_From = -1
		elseif ( from_string == "Audio_Options_Dialog" ) then
			Main_Menu_Options_Button_Clicked()
			focus_handle = Mainmenu.Menu_Buttons.Option_Buttons.Button_Audio_Options
		elseif ( from_string == "Gamepad_ButtonMap" ) then
			Main_Menu_Options_Button_Clicked()
			focus_handle = Mainmenu.Menu_Buttons.Option_Buttons.Button_Gamepad
		elseif ( from_string == "Gameplay_Options_Dialog" ) then
			Main_Menu_Options_Button_Clicked()
			focus_handle = Mainmenu.Menu_Buttons.Option_Buttons.Button_Game_Options
		elseif ( from_string == "Load_Game_Dialog" ) then
			if ( Load_Dialog_Call_From == CAMPAIGN_LOAD_GAME ) then
				Main_Menu_Campaign_Button_Clicked()
				focus_handle = Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load
			elseif ( Load_Dialog_Call_From == SKIRMISH_LOAD_GAME ) then
				Main_Menu_Skirmish_Button_Clicked()
				focus_handle = Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load
			elseif ( Load_Dialog_Call_From == MULTIPLAYER_LOAD_GAME ) then
				Main_Menu_Multiplayer_Button_Clicked()
				focus_handle = Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay
			end
			Load_Dialog_Call_From = -1
		end
	end
	
	something_has_focus = false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Main_Menu_Activate_Movies()

	--See note in Main_Menu_Passivate_Movies: the background movie *probably*
	--hasn't been stopped, but if it has then we had better start it again
	if TestValid(Mainmenu.Movie_1) then 
		Mainmenu.Movie_1.Play()
	end
	
	if TestValid(Mainmenu.Text_Back_Movie) then
		Mainmenu.Text_Back_Movie.Play()
	end
	
	if TestValid(Mainmenu.Satellite) then 
		Mainmenu.Satellite.Play()
	end	
	
	--Attract mode should kick in for any menu where the main background movie is playing
	Allow_Attract_Mode(true)	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Main_Menu_Passivate_Movies(stop_background)

	-- [JLH 01/18/2008]:
	-- We have replaced the fullscreen background binks in the skirmish, scenario, CtW and custom lobbies
	-- with static textures to get around the fact that on the Xbox hardware movies take a couple seconds
	-- to spool up and start streaming, and this leaves us with an ugly, partially transparent black 
	-- background when switching back and forth between interfaces with fullscreen movies.
	-- Now, the background of the main menu is the only fullscreen background movie so we *rarely* need 
	-- to stop and start it.
	-- HOWEVER - in a select few cases (credits, attract movie, trailer) we really do need to stop the
	-- main menu background to avoid thrashing.
	if stop_background and TestValid(Mainmenu.Movie_1) then 
		Mainmenu.Movie_1.Pause()
	end
	
	if TestValid(Mainmenu.Text_Back_Movie) then
		Mainmenu.Text_Back_Movie.Pause()
	end
	
	if TestValid(Mainmenu.Satellite) then 
		Mainmenu.Satellite.Pause()
	end	
	
	--We're navigating away from the main menu proper (a lobby or some such)
	--and we shouldn't allow attract mode to kick in
	Allow_Attract_Mode(false)
end

-------------------------------------------------------------------------------
--Play_Full_Screen_Movie
-------------------------------------------------------------------------------
function Play_Full_Screen_Movie(movie_name, attract_mode)
	--Resize the movie quad based on screen aspect ratio
	--Must stop the menu background movie here since we're
	--about to play a HUGE new movie on top
	Main_Menu_Passivate_Movies(true)
	
	--Passivate_Movies may have disabled attract mode, but if this *is* attract mode
	--then we should fix the flag
	AllowAttractMode = attract_mode
	
	if TestValid(this.FullScreenMovieScene) then
		this.FullScreenMovieScene.Set_Hidden(false)
		this.FullScreenMovieScene.Setup_Movie_Display(movie_name, attract_mode)
		this.FullScreenMovieScene.Start_Modal(Stopped_Full_Screen_Movie)		
	end	
end


-------------------------------------------------------------------------------
--Stopped_Full_Screen_Movie (Callback used by the End_Modal of
-- this.FullScreenMovieScene
-------------------------------------------------------------------------------
function Stopped_Full_Screen_Movie()
	if TestValid(this.FullScreenMovieScene) then
		this.FullScreenMovieScene.Set_Hidden(true)
	end	
	
	Main_Menu_Activate_Movies()
	AttractModeSpawned = false
	focus_handle = Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer
	something_has_focus = false
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Allow_Attract_Mode(allow)
	if allow == AllowAttractMode then
		return
	end
	
	AllowAttractMode = allow
	if AllowAttractMode then
		LastAllowAttractTime = GetCurrentRealTime()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Valid_Achievement_Signin_State()
	local signin_state = Net.Get_Signin_State()
	if ((signin_state == "online") or (signin_state == "local") or (signin_state == "non-live")) then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Menu_System_Activated( _, _, display_credits )
	-- This auto enables/disables the various buttons on the campaign screen
	-- so when we return to the main menu from a campaign, the buttons should
	-- be in the proper state
	Enable_Campaign_Buttons()
	
	this.Movie_1.Set_Movie("360_Front_End9e")

	if display_credits then
		Display_Credits()
	end
	
	-- Maria 01.12.2008
	-- We cannot close the dialog here because when loading a game from inside another game we do a quit to main menu first
	-- and the the load.  Thus, if we were to close the load dialog here we would have a gap in the scene which we don't want.
	-- Hence, we set this flag that will be processed only when the main menu is fully activated and gets updated.
	CloseBattleLoadDialog = true
end

function Profile_Needed_Callback(answer)
	if (answer == YES_CLICKED) then
		Net.Show_Signin_UI()
	end
end

function Ensure_Valid_Gamer_Profile()
	local validgamerprofile = SaveLoadManager.Ensure_Valid_Gamer_Profile()
	if not validgamerprofile and (ValidGamerProfile ~= validgamerprofile) then
		-- Only pop this message up if it does not
		-- interfere with an existing message
		if this.Yes_No_Ok_Dialog.Get_Hidden() then
			YesNoOkDialogState = MSG_PROFILE_NEEDED
			local model = {}
			model.Message = "TEXT_GAMEPAD_NOT_SIGNED_IN"
			this.Yes_No_Ok_Dialog.Set_Model(model)
			this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
			Show_Message_Box()

			ValidGamerProfile = validgamerprofile
			return false
		end
	end

	ValidGamerProfile = validgamerprofile
	return true
end

function Ensure_Valid_Storage_Device()
	if ValidGamerProfile then
		-- Needed to properly determine whether the storage device is invalid
		SaveLoadManager.Update()
		SaveLoadManager.Get_List_Needs_Refresh()

		local valid_storage_device = not SaveLoadManager.Get_Is_Storage_Device_Invalid()
		if not valid_storage_device and (ValidStorageDevice ~= valid_storage_device) then
			StorageDeviceUIActive = true
			SaveLoadManager.Change_Storage_Selection(true, MAX_SAVE_GAME_SIZE)
			return false
		end

		ValidStorageDevice = valid_storage_device
	end
	return true
end

function Enable_Gameplay_Buttons()
	if SaveLoadManager.Ensure_Valid_Gamer_Profile() then
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load.Enable(true)
		Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load.Enable(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Enable(true)
	else
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load.Enable(false)
		Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Enable(false)
	end
end

function Storage_Device_Needed_Callback(answer)
	if (answer == YES_CLICKED) then
		SaveLoadManager.Change_Storage_Selection(true, MAX_SAVE_GAME_SIZE)
	end
end

-------------------------------------------------------------------------------
-- Checks what state we are trying to restore to then calls the matching
-- function to bring the main menu back to the correct screen
-------------------------------------------------------------------------------
function On_Restore_Menu_State_After_Game(_, _, restore_state)
	-- no restore state, being at start of main menu is fine
	if not restore_state or restore_state == "" then
		return
	end
	
	local is_gold = not Net.Requires_Locator_Service()
	local valid_profile = SaveLoadManager.Ensure_Valid_Gamer_Profile()

	-- check what state to restore to and call appropriate function
	if valid_profile and restore_state == "Campaign" then
		Restore_To_Campaign_Menu()
	elseif valid_profile and restore_state == "Tutorial" then
		Restore_To_Tutorial_Menu()
	elseif valid_profile and restore_state == "Skirmish" then
		Restore_State_To_Skirmish_Menu()
	elseif restore_state == "Multiplayer_Conquest" then
		Cleanup_Session_Due_To_Restore()
		if valid_profile and is_gold then
			Restore_State_To_Multiplayer_Conquest_Menu()
		end
	elseif restore_state == "Multiplayer" then
		Cleanup_Session_Due_To_Restore()
		if valid_profile then
			Restore_State_To_Multiplayer_Menu()
		end
	elseif restore_state == "Multiplayer_Custom" then
		Cleanup_Session_Due_To_Restore()
		if valid_profile and is_gold then
			Restore_State_To_Multiplayer_Custom_Menu()
		end
	end
end

function Restore_To_Campaign_Menu()
	-- fake a button click on the campaign button
	Main_Menu_Campaign_Button_Clicked()
end

function Restore_To_Tutorial_Menu()
	Main_Menu_Tutorials_Button_Clicked()
end

function Restore_State_To_Skirmish_Menu()
	-- fake a button press on the skirmish button
	Main_Menu_Skirmish_Button_Clicked()
	-- then fake a button press on the start skirmish game button
	Skirmish_New_Game_Button_Clicked()
end

function Restore_State_To_Multiplayer_Conquest_Menu()
	-- fake a button press on the multiplayer button
	Main_Menu_Multiplayer_Button_Clicked()
	-- then fake a button press on the CTW button
	Multiplayer_Conquer_The_World_Button_Clicked()
end

function Restore_State_To_Multiplayer_Menu()
	-- fake a button press on the multiplayer button
	Main_Menu_Multiplayer_Button_Clicked()
end

function Restore_State_To_Multiplayer_Custom_Menu()
	-- fake a button press on the multiplayer button
	Main_Menu_Multiplayer_Button_Clicked()
	-- then fake a button press on the custom player match button
	Start_Custom_Player_Match_Lobby()
end

function Cleanup_Session_Due_To_Restore()
	-- since we are destroying the main menu on the XBox, the embedded scenes that were
	-- created previously no longer exist, so they can't respond to the On_Menu_System_Activated
	-- event, so in the case of multiplayer ones, we need to make sure to leave the game and 
	-- stop the session
	Net.MM_Leave()
end

function Game_Ended_Profile_Signout()
	PGCrontab_Schedule(Display_Profile_Signout, 0, 1)
end

function Display_Profile_Signout()
	YesNoOkDialogState = nil
	local model = {}
	model.Message = "TEXT_GAMEPAD_ACTIVE_PROFILE_SIGNED_OUT"
	this.Yes_No_Ok_Dialog.Set_Model(model)
	this.Yes_No_Ok_Dialog.Set_Ok_Mode()
	Show_Message_Box()
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_Game_Kill_Countdown = nil
	Broadcast_Game_Settings = nil
	Broadcast_Game_Settings_Accept = nil
	Broadcast_Game_Start_Countdown = nil
	Broadcast_Heartbeat = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Broadcast_Stats_Registration_Begin = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Start_AI_Skirmish = nil
	DesignerMessage = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Hide_Message_Box = nil
	Is_Valid_Achievement_Signin_State = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Network_Add_AI_Player = nil
	Network_Add_Reserved_Players = nil
	Network_Assign_Host_Seat = nil
	Network_Broadcast_Reset_Start_Positions = nil
	Network_Calculate_Initial_Max_Player_Count = nil
	Network_Clear_All_Clients = nil
	Network_Do_Seat_Assignment = nil
	Network_Edit_AI_Player = nil
	Network_Get_Client_By_ID = nil
	Network_Get_Client_From_Seat = nil
	Network_Get_Client_Table_Count = nil
	Network_Get_Local_Username = nil
	Network_Get_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	Network_Kick_Player = nil
	Network_Refuse_Player = nil
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	Network_Update_Local_Common_Addr = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Legal_Stuff_Done = nil
	On_Remove_Xbox_Controller_Hint = nil
	On_Update_Notification_Clicked = nil
	PGHintSystem_Init = nil
	PGNetwork_Clear_Start_Positions = nil
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
	PGOfflineAchievementDefs_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Client_Table = nil
	Set_Local_User_Applied_Medals = nil
	Set_Objective_Text = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Skip_To_Campaign_Dialog = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Tutorial_Button_15_Clicked = nil
	Tutorial_Button_16_Clicked = nil
	Tutorial_Button_1_Clicked = nil
	Tutorial_Button_2_Clicked = nil
	Tutorial_Button_3_Clicked = nil
	Tutorial_Button_4_Clicked = nil
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Loading_Screen_Background = nil
	UI_Set_Loading_Screen_Faction_ID = nil
	UI_Set_Loading_Screen_Mission_Text = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

