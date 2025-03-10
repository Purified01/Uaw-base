if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[6] = true
LuaGlobalCommandLinks[83] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[84] = true
LuaGlobalCommandLinks[79] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[70] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/MainMenu.lua#38 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/MainMenu.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Nader_Akoury $
--
--            $Change: 96950 $
--
--          $DateTime: 2008/04/14 17:15:42 $
--
--          $Revision: #38 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGNetwork")
require("PGDebug")
require("PGCrontab")
require("PGPlayerProfile")

--Need these for Set_Player_Info_Table (used by the Play_Again button)
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")

ScriptPoolCount = 0


function On_Init()
	Net.Initialize()
	PGNetwork_Init()
	PGCrontab_Init()
	PGPlayerProfile_Init_Constants()
	Net.Register_Event_Handler(On_Network_Event)
	
	-- Constants 
	ENABLE_NEW_MULTIPLAYER_FLOW = true 
	
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
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod, Main_Menu_Mod_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Exit_Game, Main_Menu_Exit_Button_Clicked)
	if GOLD_BUILD or BETA_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Hidden(true)
	else
		Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug, Main_Menu_Debug_Button_Clicked)
	end

	if MOD_ENABLED then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Enable(true)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Set_Hidden(false)
	else
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Set_Hidden(true)
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
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match, Main_Menu_Quick_Match_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards, Multiplayer_Leaderboards_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN, Multiplayer_LAN_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay, Multiplayer_Load_Replay_Button_Clicked)
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Multiplayer_Back, Multiplayer_Back_Button_Clicked)

	if MOD_ENABLED then
		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Enable(false)
		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Enable(false)
	end
	
	-- Tutorial buttons
	Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Training, Tutorial_Button_Training_Clicked)
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
	if not GOLD_BUILD and not BETA_BUILD then
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
	
	--Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Internet.Enable(false)

	-- *** TAB ORDERING ***
	-- Top Menu
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Tab_Order(Declare_Enum(0))
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Profile.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Exit_Game.Set_Tab_Order(Declare_Enum())
	if not GOLD_BUILD and not BETA_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Tab_Order(Declare_Enum())
	end

	-- Campaign Menu
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Tutorial_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Scenarios.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Back.Set_Tab_Order(Declare_Enum())

	-- Skirmish Buttons
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_New_Game.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Back.Set_Tab_Order(Declare_Enum())

	-- Multiplayer Menu
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Multiplayer_Back.Set_Tab_Order(Declare_Enum())

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
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Video_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Network_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Game_Options.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits.Set_Tab_Order(Declare_Enum())
	Mainmenu.Menu_Buttons.Option_Buttons.Button_Options_Back.Set_Tab_Order(Declare_Enum())

	-- Debug Menu
	if not GOLD_BUILD and not BETA_BUILD then
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Milestone_Demo.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Enable(false)
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Set_Tab_Order(Declare_Enum())
		--Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Enable(false)
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Mission.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Old_LAN_Lobby.Set_Tab_Order(Declare_Enum())
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Back.Set_Tab_Order(Declare_Enum())
	end

	if BETA_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Enable(false)
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Enable(false)

		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Enable(false)
		Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits.Enable(false)
		Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer.Enable(false)
	end

	-- Init our generic message box
	Init_Message_Box()

	LiveLogonState = 2
	NextTabOrder = Declare_Enum()

	Mainmenu.Focus_First()

	Register_Game_Scoring_Commands()
	
	this.RolloverMovie.Stop()
	
	-- [JLH 08/06/2007]:  Register for heavyweight embedded scenes closing so that we can start and stop our movies.
	Mainmenu.Register_Event_Handler("Heavyweight_Child_Scene_Closing", nil, Heavyweight_Child_Scene_Closing)
	
	this.Register_Event_Handler("Movie_Finished", this.FullScreenMovieGroup.Movie, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Closing_All_Displays", nil, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Credits_Done", nil, On_Credits_Done)
	this.Register_Event_Handler("On_Menu_System_Activated", nil, On_Menu_System_Activated)
	
	-- The game will no longer crash in the case where the Live dialog is not embedded,
	-- and by postponing it we improve load time to the main menu
	--Embed_Heavyweight_Scenes()
end

function Embed_Heavyweight_Scenes()

	if not TestValid(Mainmenu.Live_Profile_Game_Dialog) then
		local handle = Create_Embedded_Scene("Live_Profile_Game_Dialog", Mainmenu, "Live_Profile_Game_Dialog")
		this.Live_Profile_Game_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1					
	end
	Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(true)
		
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
	
	-- Message types
	MSG_UPNP_FIREWALL				= Declare_Enum(1)
	MSG_UPDATE_AVAILABLE			= Declare_Enum()
	MSG_CAMPAIGN_ACHIEVEMENTS		= Declare_Enum()
	MSG_SKIRMISH_ACHIEVEMENTS		= Declare_Enum()
	
	YesNoOkDialogState = nil

	-- Callbacks
	YesNoOkCallbacks = 
	{
		[MSG_UPNP_FIREWALL] 				= UPNP_Dialog_Callback,
		[MSG_UPDATE_AVAILABLE] 				= Update_Available_Dialog_Callback,
		[MSG_CAMPAIGN_ACHIEVEMENTS]			= Campaign_Achievements_Dialog_Callback,
		[MSG_SKIRMISH_ACHIEVEMENTS]			= Skirmish_Achievements_Dialog_Callback,
	}
	
	-- Create!
	if (not TestValid(this.Yes_No_Ok_Dialog)) then
		DebugMessage("MAIN_MENU_MESSAGE: Creating dialog handle.")
		local handle = Create_Embedded_Scene("Yes_No_Ok_Dialog", this, "Yes_No_Ok_Dialog")
	end
	this.Yes_No_Ok_Dialog.Set_Hidden(true)	
	this.Yes_No_Ok_Dialog.End_Modal()
	this.Yes_No_Ok_Dialog.Set_Screen_Position(0.5, 0.5)
	this.Register_Event_Handler("On_YesNoOk_Yes_Clicked", nil, On_YesNoOk_Yes_Clicked)
	this.Register_Event_Handler("On_YesNoOk_No_Clicked", nil, On_YesNoOk_No_Clicked)
					
	DebugMessage("MAIN_MENU_MESSAGE: Main menu message initialized.")
	
end

------------------------------------------------------------------------
-- Message Box User Response Processor
------------------------------------------------------------------------
function Show_Message_Box()
	DebugMessage("MAIN_MENU_MESSAGE: Showing main menu message box")
	this.Yes_No_Ok_Dialog.Set_Hidden(false)	
	this.Yes_No_Ok_Dialog.Start_Modal()
end
					
------------------------------------------------------------------------
-- Message Box User Response Processor
------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()

	if (YesNoOkDialogState ~= nil) then
		YesNoOkCallbacks[YesNoOkDialogState](YES_CLICKED)
	end
	
end

------------------------------------------------------------------------
-- Message Box User Response Processor
------------------------------------------------------------------------
function On_YesNoOk_No_Clicked()

	if (YesNoOkDialogState ~= nil) then
		YesNoOkCallbacks[YesNoOkDialogState](NO_CLICKED)
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
		this.RolloverMovie.Restart()
	end
end

------------------------------------------------------------------------
-- On_Button_Pushed - Play SFX response
------------------------------------------------------------------------
function On_Button_Pushed(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		-- If this is a 'Back" button, play a special sound
		if source == this.Menu_Buttons.Campaign_Buttons.Button_Campaign_Back or
		  source == this.Menu_Buttons.Multiplayer_Buttons.Button_Multiplayer_Back or
		  source == this.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Back or
		  source == this.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_Back or
		  source == this.Menu_Buttons.Option_Buttons.Button_Options_Back or
		  source == this.Menu_Buttons.Debug_Buttons.Button_Debug_Back then
		  
			Play_SFX_Event("GUI_Main_Menu_Back_Select")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
	end
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
	
	if (CheckForNonLiveUpdates == true) then
		
		local product_code = Net.Check_For_Non_Live_Updates()

		if (product_code ~= -1) then

			NonLiveUpdateAvailable = true
			
			YesNoOkDialogState = MSG_UPDATE_AVAILABLE
			local model = {}
			local show_dialog = true
			if (product_code == 0) then
				show_dialog = Get_Profile_Value(PP_ENABLE_UPDATE_DOWNLOAD, true)
				model.Message = "TEXT_DOWNLOADABLE_UPDATE_AVAILABLE"
			elseif (product_code == 1) then
				show_dialog = Get_Profile_Value(PP_ENABLE_LIVE_UPDATE_DOWNLOAD, true)
				model.Message = "TEXT_DOWNLOADABLE_LIVE_UPDATE_AVAILABLE"
			end

			if (show_dialog == true) then
				this.Yes_No_Ok_Dialog.Set_Model(model)
				this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
				this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
				Show_Message_Box()
			end
			CheckForNonLiveUpdates = false
		end
	end

	if (NonLiveUpdateAvailable == false) then

		if (CheckedForUPnP == false) then

			CheckedForUPnP = true

			local show_dialog = Get_Profile_Value(PP_WARNING_UPNP_FIREWALL, true)
			if (show_dialog == true) then

				if (Net.Check_For_Open_UPnP() == true) then
				
					YesNoOkDialogState = MSG_UPNP_FIREWALL

					local model = {}
					model.Message = "TEXT_OPEN_FIREWALL_UPNP"
					this.Yes_No_Ok_Dialog.Set_Model(model)
					this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
					this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
					Show_Message_Box()

				end
			end
		end
	end

end

------------------------------------------------------------------------
-- Called when the user dismisses the UPNP warning dialog box.
------------------------------------------------------------------------
function UPNP_Dialog_Callback(answer)

	if (answer == YES_CLICKED) then
	
		Net.Open_UPnP()
		
	end
	
	local checkbox = this.Yes_No_Ok_Dialog.Get_Checkbox_State()
	if (checkbox == true) then
		Set_Profile_Value(PP_WARNING_UPNP_FIREWALL, false)
	end

end

------------------------------------------------------------------------
-- Called when the user clicks on the update dialog box
------------------------------------------------------------------------
function Update_Available_Dialog_Callback(answer)

	if (answer == YES_CLICKED) then
		if (NonLiveUpdateAvailable == true) then
			Net.Open_Browser_For_Non_Live_Update();
			Net.Unregister_Event_Handler(On_Network_Event)
			Net.Shutdown()
			Quit_App_Now()
		end
	
	elseif (answer == NO_CLICKED) then 
	
		NonLiveUpdateAvailable = false
		local checkbox = this.Yes_No_Ok_Dialog.Get_Checkbox_State()
		if (checkbox == true) then
			local product_code = Net.Check_For_Non_Live_Updates()
			if (product_code == 0) then
				Set_Profile_Value(PP_ENABLE_UPDATE_DOWNLOAD, false)
			elseif (product_code == 1) then
				Set_Profile_Value(PP_ENABLE_LIVE_UPDATE_DOWNLOAD, false)
			end
		end

	end

end


function On_Save_File_Deleted()
	Enable_Campaign_Autosave_Button()
end

function Enable_Campaign_Autosave_Button()
	Register_Save_Load_Commands()
	if SaveLoadManager.Autosave_Exists() then
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Enable(true)
	else
		Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Enable(false)
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

	Enable_Campaign_Autosave_Button()
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

	local show_it = Get_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, true)
		
	if (Is_Valid_Achievement_Signin_State() or (not show_it)) then
		Enter_Campaign_Menu()
		return
	end
	
	YesNoOkDialogState = MSG_CAMPAIGN_ACHIEVEMENTS

	local model = {}
	model.Message = "TEXT_ACHIEVEMENTS_SINGLE_PLAYER_SIGNED_OUT_WARNING"
	this.Yes_No_Ok_Dialog.Set_Model(model)
	this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
	this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
	Show_Message_Box()
	
end

------------------------------------------------------------------------
-- Called when the user answers the modal message dialog regarding
-- campaign achievements.
------------------------------------------------------------------------
function Campaign_Achievements_Dialog_Callback(answer)

	if (answer == YES_CLICKED) then
		Net.Show_Signin_UI()
	end
	Enter_Campaign_Menu()
	
	local checkbox = this.Yes_No_Ok_Dialog.Get_Checkbox_State()
	if (checkbox == true) then
		Set_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, false)
	end
		
end

------------------------------------------------------------------------
-- Enters the Campaign submenu.
------------------------------------------------------------------------
function Enter_Campaign_Menu()
	Enable_Campaign_Buttons()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(false)
end

------------------------------------------------------------------------
-- If the user is not signed in to LIVE, we need to warn them they won't
-- earn achievements.
------------------------------------------------------------------------
function Main_Menu_Skirmish_Button_Clicked(event_name, source)

	local show_it = Get_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, true)
		
	if (Is_Valid_Achievement_Signin_State() or (not show_it)) then
		Enter_Skirmish_Menu()
		return
	end
	
	YesNoOkDialogState = MSG_SKIRMISH_ACHIEVEMENTS

	local model = {}
	model.Message = "TEXT_ACHIEVEMENTS_SINGLE_PLAYER_SIGNED_OUT_WARNING"
	this.Yes_No_Ok_Dialog.Set_Model(model)
	this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
	this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
	Show_Message_Box()
	
end

------------------------------------------------------------------------
-- Called when the user answers the modal message dialog regarding
-- single player achievements.
------------------------------------------------------------------------
function Skirmish_Achievements_Dialog_Callback(answer)

	if (answer == YES_CLICKED) then
		Net.Show_Signin_UI()
	end
	Enter_Skirmish_Menu()
	
	local checkbox = this.Yes_No_Ok_Dialog.Get_Checkbox_State()
	if (checkbox == true) then
		Set_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, false)
	end
		
end

------------------------------------------------------------------------
-- Enters the Skirmish submenu.
------------------------------------------------------------------------
function Enter_Skirmish_Menu()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(false)
end

function Main_Menu_Multiplayer_Button_Clicked(event_name, source)
	Set_Menus_For_Live_Logon_State()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
end

function Main_Menu_Tutorials_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(false)
end

function Main_Menu_Options_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(false)
end

function Main_Menu_Profile_Button_Clicked(event_name, source)
	Net.Show_Guide_UI()
end

function Main_Menu_Mod_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Mod_Dialog) then
		Create_Embedded_Scene("Mod_Dialog", Mainmenu, "Mod_Dialog")
		this.Mod_Dialog.Set_Tab_Order(NextTabOrder)
		NextTabOrder = NextTabOrder + 1	
	else
		Mainmenu.Mod_Dialog.Set_Hidden(false)
	end
	Mainmenu.Mod_Dialog.Display_Dialog()
	Mainmenu.Mod_Dialog.Start_Modal()
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
	if not GOLD_BUILD and not BETA_BUILD then
		Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
		Mainmenu.Menu_Buttons.Debug_Buttons.Set_Hidden(false)

		--
		-- MBL 09.07.2007: Had to add this to get debug menu working from main menu after the big integration
		--
		Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Key_Focus()
	end
end


---------------------------------------
-- Campaign Menu Button Events
---------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------
-- Campaign_Continue_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Continue_Button_Clicked(event_name, source)
	SaveLoadManager.Auto_Load()
end

-- -----------------------------------------------------------------------------------------------------------------------------.
-- Campaign_Tutorial_Button_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------
function Campaign_Tutorial_Button_Clicked(event_name, source)
	-- TODO: Launch campaign difficulty dialog
	CampaignManager.Start_Campaign("Tutorial_Story_Campaign") -- use default difficulty from profile
end

function Campaign_Novus_Button_Clicked(event_name, source)
	-- TODO: Launch campaign difficulty dialog
	CampaignManager.Start_Campaign("NOVUS_Story_Campaign") -- use default difficulty from profile
end

function Campaign_Hierarchy_Button_Clicked(event_name, source)
	-- TODO: Launch campaign difficulty dialog
	CampaignManager.Start_Campaign("Hierarchy_Story_Campaign") -- use default difficulty from profile
end

function Campaign_Masari_Button_Clicked(event_name, source)
	-- TODO: Launch campaign difficulty dialog
	CampaignManager.Start_Campaign("MASARI_Story_Campaign") -- use default difficulty from profile
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
	Mainmenu.Load_Campaign_Game_Dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	Mainmenu.Load_Campaign_Game_Dialog.Display_Dialog()
	Mainmenu.Load_Campaign_Game_Dialog.Start_Modal()
end

function Campaign_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Key_Focus()
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
	Mainmenu.Load_Skirmish_Game_Dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	Mainmenu.Load_Skirmish_Game_Dialog.Display_Dialog()
	Mainmenu.Load_Skirmish_Game_Dialog.Start_Modal()
end

function Skirmish_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Key_Focus()
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
	QuickMatchMode = match_mode
	-- If there is already a connection attempt in progress, don't respond to clicks
	local progress_dialog_busy = (TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy())
	local internet_dialog_busy = (TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy())
	if (progress_dialog_busy or internet_dialog_busy) then
		return
	end

	if Net.Get_Signin_State() ~= "online" then
		Net.Show_Signin_UI()
		return
	end
	
	if not TestValid(Mainmenu.Network_Progress_Bar) then
		local handle = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
	else
		Mainmenu.Network_Progress_Bar.Set_Hidden(false)
	end

	Mainmenu.Network_Progress_Bar.Start()
	Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
	Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
	PGCrontab_Schedule(Start_Ranked_Game, 0, 1)

end

---------------------------------------
--
---------------------------------------
function Multiplayer_Ranked_Game_Clicked(event_name, source)
	Common_Ranked_Game_Clicked(0)
end

---------------------------------------
--
---------------------------------------
function Multiplayer_Sign_In_Clicked(event_name, source)
	Net.Show_Signin_UI()
end

---------------------------------------
--
---------------------------------------
function Multiplayer_Custom_Match_Clicked(event_name, source)

	-- If there is already a connection attempt in progress, don't respond to clicks
	local progress_dialog_busy = (TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy())
	local internet_dialog_busy = (TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy())
	if (progress_dialog_busy or internet_dialog_busy) then
		return
	end

	if Net.Get_Signin_State() ~= "online" then
		Net.Show_Signin_UI()
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
		Net.Show_Signin_UI()
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
	PGCrontab_Schedule(Start_Global_Conquest_Lobby, 0, 1)

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
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Enable(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Enable(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Enable(true)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Enable(true)
		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Enable(true)
		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Enable(true)

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
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Enable(false)
			Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Enable(false)
			Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Enable(false)
			if LiveLogonState == nil or LiveLogonState == 3 then
				Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Enable(false)
				Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Enable(false)
				if LiveLogonState == nil then
					if BETA_BUILD ~= true then
						Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Enable(false)
					end
				end
			end
		end
	end

	if MOD_ENABLED then
		if Net.Allow_User_Created_Content() then
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Profile.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Set_Hidden(false)
		else
			-- Display the base main menu
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
			Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(true)

			-- The only option available should be the exit game option
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Profile.Set_Hidden(true)
			Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Mod.Set_Hidden(true)

			if (not TestValid(this.Yes_No_Ok_Dialog)) then
				Init_Message_Box()
			end

			YesNoOkDialogState = nil
			local model = {}
			model.Message = "TEXT_MOD_DISABLED_CANNOT_CONTINUE"
			this.Yes_No_Ok_Dialog.Set_Model(model)
			this.Yes_No_Ok_Dialog.Set_Ok_Mode()
			this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(false)
			Show_Message_Box()
		end

		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game.Enable(false)
		Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Enable(false)
		Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Enable(false)
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
			Set_Menus_For_Live_Logon_State()
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
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(false)
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
		Net.Show_Signin_UI()
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
	PGCrontab_Schedule(Start_LAN_Lobby, 0, 1)
	
end

-- TODO: Implement the load replay dialog and hook it in
function Multiplayer_Load_Replay_Button_Clicked(event_name, source)
	if not TestValid(Mainmenu.Load_Replay_Dialog) then
		Create_Embedded_Scene("Load_Game_Dialog", Mainmenu, "Load_Replay_Dialog")
	else
		Mainmenu.Load_Replay_Dialog.Set_Hidden(false)
	end
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
	
	Main_Menu_Passivate_Movies()
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
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Set_Key_Focus()
end


function Multiplayer_QM_Player_Button_Clicked(event_name, source)
	Common_Ranked_Game_Clicked(1)
end

function Multiplayer_QM_Ranked_Button_Clicked(event_name, source)
	Common_Ranked_Game_Clicked(2)
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

function Tutorial_Button_Training_Clicked(event_name, source)
	-- MLL: Disable the auto save for the interactive tutorial.
	SaveLoadManager.Disable_Auto_Save()
	CampaignManager.Start_Campaign("TUTORIAL_NEW_Story_Campaign") -- use default difficulty from profile
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
	Main_Menu_Passivate_Movies()
	Roll_Credits()
end

function On_Credits_Done()
	Main_Menu_Activate_Movies()	
end

function Options_Trailer_Button_Clicked()
	Play_Full_Screen_Movie("Trailer.bik")
end

function Options_Back_Button_Clicked(event_name, source)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
	Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Key_Focus()
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
end

function Skip_To_Multiplayer_Dialog()
	Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
	Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
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
	Raise_Event_Immediate_All_Scenes("Close_Dialog_For_Invitation", {})
	Multiplayer_Custom_Match_Clicked()

end


function Controller_Key_As_Back(event_name, source)
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
	else
		print( "ERROR: none of the MainMenu button groups are visible" )
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Heavyweight_Child_Scene_Closing()
	Main_Menu_Activate_Movies()
	Net.Set_User_Info({ [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_MENU })
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Main_Menu_Activate_Movies()

	if TestValid(Mainmenu.Movie_1) then 
		Mainmenu.Movie_1.Play()
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Main_Menu_Passivate_Movies()

	if TestValid(Mainmenu.Movie_1) then 
		Mainmenu.Movie_1.Stop()
	end
	
end

-------------------------------------------------------------------------------
--Play_Full_Screen_Movie
-------------------------------------------------------------------------------
function Play_Full_Screen_Movie(movie_name)
	--Resize the movie quad based on screen aspect ratio
	Main_Menu_Passivate_Movies()
	Register_Video_Commands()
	local settings = VideoSettingsManager.Get_Current_Settings()
	local width = settings.Screen_Width
	local height = settings.Screen_Height	
	
	local movie_height = (width / height) / (16.0 / 9.0)
	local y_offset = (1.0 - movie_height) / 2.0;

	this.FullScreenMovieGroup.Movie.Set_World_Bounds(0.0, y_offset, 1.0, movie_height)

	Stop_All_Music()
	this.FullScreenMovieGroup.Movie.Set_Movie(movie_name)
	this.FullScreenMovieGroup.Set_Hidden(false)
	Play_Music("Main_Menu_Music_Event")
end

-------------------------------------------------------------------------------
--Stop_Full_Screen_Movie
-------------------------------------------------------------------------------
function Stop_Full_Screen_Movie()
	this.FullScreenMovieGroup.Movie.Stop()
	this.FullScreenMovieGroup.Set_Hidden(true)
	Main_Menu_Activate_Movies()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Valid_Achievement_Signin_State()
	if ((Net.Get_Signin_State() == "online") or (Net.Get_Signin_State() == "local")) then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Menu_System_Activated()
	-- This auto enables/disables the various buttons on the campaign screen
	-- so when we return to the main menu from a campaign, the buttons should
	-- be in the proper state
	Enable_Campaign_Buttons()
end
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
	Broadcast_Heartbeat = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Broadcast_Stats_Registration_Begin = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Start_AI_Skirmish = nil
	DesignerMessage = nil
	Disable_UI_Element_Event = nil
	Embed_Heavyweight_Scenes = nil
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
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
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
	On_Legal_Stuff_Done = nil
	PGNetwork_Clear_Start_Positions = nil
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
	PGOfflineAchievementDefs_Init = nil
	PGPlayerProfile_Init = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Client_Table = nil
	Set_Local_User_Applied_Medals = nil
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
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

