-- filename: 
-- version: lua51
-- line: [0, 0] id: 0
if LuaGlobalCommandLinks == nil then
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
require("PGBase")
require("PGUICommands")
require("PGNetwork")
require("PGDebug")
require("PGCrontab")
require("PGPlayerProfile")
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
ScriptPoolCount = 0
function On_Init()
  -- line: [74, 328] id: 1
  Net.Initialize()
  PGNetwork_Init()
  PGCrontab_Init()
  PGPlayerProfile_Init_Constants()
  Net.Register_Event_Handler(On_Network_Event)
  ENABLE_NEW_MULTIPLAYER_FLOW = true
  Mainmenu.Text_Version_Info_String.Set_Text(Get_Full_Version_Info_String() .. " | Community Patch 4 by Rosie. | Alternate Hierarchy Faction by Purified")
  DialogToOpen = nil
  Dialog_Box_Common_Init()
  CheckForNonLiveUpdates = true
  NonLiveUpdateAvailable = false
  CheckedForUPnP = false
  DebugMessage("Initializing Mainmenu.lua scene...\n")
  Mainmenu.Register_Event_Handler("Key_Press", Mainmenu, On_Key_Press)
  Mainmenu.Register_Event_Handler("Save_File_Deleted", nil, On_Save_File_Deleted)
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
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign, Campaign_Continue_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Tutorial_Campaign, Campaign_Tutorial_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign, Campaign_Novus_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign, Campaign_Hierarchy_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign, Campaign_Masari_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Scenarios, Campaign_Scenario_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load, Campaign_Load_Game_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Back, Campaign_Back_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_New_Game, Skirmish_New_Game_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load, Skirmish_Load_Game_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Back, Skirmish_Back_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Ranked_Game, Multiplayer_QM_Ranked_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Player_Match, Multiplayer_QM_Player_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Quick_Match_Buttons.Button_Quick_Match_Back, Multiplayer_QM_Back_Button_Clicked)
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
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Training, Tutorial_Button_Training_Clicked)
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
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_Back, Tutorial_Button_Back_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Audio_Options, Options_Audio_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Video_Options, Options_Video_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Network_Options, Options_Network_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Gamepad, Gamepad_Options_Dialog_Selected)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Keyboard_Options, Options_Keyboard_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Game_Options, Options_Game_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits, Options_Credits_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Options_Back, Options_Back_Button_Clicked)
  Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer, Options_Trailer_Button_Clicked)
  if not GOLD_BUILD and not BETA_BUILD then
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map, Debug_Load_Map_Button_Clicked)
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Milestone_Demo, Debug_Milestone_Button_Clicked)
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest, Multiplayer_Conquer_The_World_Button_Clicked)
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest, Debug_Achievement_Chest_Button_Clicked)
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Mission, Debug_Load_Mission_Button_Clicked)
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Old_LAN_Lobby, Multiplayer_LAN_Button_Clicked)
    Mainmenu.Register_Event_Handler("Button_Clicked", Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Back, Debug_Back_Button_Clicked)
  end
  Mainmenu.Register_Event_Handler("Controller_B_Button_Up", nil, Controller_Key_As_Back)
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
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Tutorial_Campaign.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Novus_Campaign.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Hierarchy_Campaign.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Masari_Campaign.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Scenarios.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Load.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Campaign_Back.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_New_Game.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Load.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Back.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Sign_In.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Conquer_The_World.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Ranked_Game.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Custom_Match.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Leaderboards.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Load_Replay.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Multiplayer_Back.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Training.Set_Tab_Order(Declare_Enum())
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
  Mainmenu.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_Back.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Audio_Options.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Video_Options.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Network_Options.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Game_Options.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Trailer.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Credits.Set_Tab_Order(Declare_Enum())
  Mainmenu.Menu_Buttons.Option_Buttons.Button_Options_Back.Set_Tab_Order(Declare_Enum())
  if not GOLD_BUILD and not BETA_BUILD then
    Mainmenu.Menu_Buttons.Debug_Buttons.Button_Milestone_Demo.Set_Tab_Order(Declare_Enum())
    Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Tab_Order(Declare_Enum())
    Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Set_Tab_Order(Declare_Enum())
    Mainmenu.Menu_Buttons.Debug_Buttons.Button_Global_Conquest.Enable(false)
    Mainmenu.Menu_Buttons.Debug_Buttons.Button_AchievementChest.Set_Tab_Order(Declare_Enum())
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
  Init_Message_Box()
  LiveLogonState = 2
  NextTabOrder = Declare_Enum()
  Mainmenu.Focus_First()
  Register_Game_Scoring_Commands()
  this.RolloverMovie.Stop()
  Mainmenu.Register_Event_Handler("Heavyweight_Child_Scene_Closing", nil, Heavyweight_Child_Scene_Closing)
  this.Register_Event_Handler("Movie_Finished", this.FullScreenMovieGroup.Movie, Stop_Full_Screen_Movie)
  this.Register_Event_Handler("Closing_All_Displays", nil, Stop_Full_Screen_Movie)
  this.Register_Event_Handler("Credits_Done", nil, On_Credits_Done)
  this.Register_Event_Handler("On_Menu_System_Activated", nil, On_Menu_System_Activated)
end
function Embed_Heavyweight_Scenes()
  -- line: [330, 339] id: 2
  if not TestValid(Mainmenu.Live_Profile_Game_Dialog) then
    local r0_2 = Create_Embedded_Scene("Live_Profile_Game_Dialog", Mainmenu, "Live_Profile_Game_Dialog")
    this.Live_Profile_Game_Dialog.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  end
  Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(true)
end
function On_Legal_Stuff_Done()
  -- line: [341, 343] id: 3
  Mainmenu.Focus_First()
end
function Init_Message_Box()
  -- line: [348, 391] id: 4
  if TestValid(this.Yes_No_Ok_Dialog) then
    DebugMessage("MAIN_MENU_MESSAGE: Already initted.  Bailing...")
    return 
  end
  DebugMessage("MAIN_MENU_MESSAGE: Initializing main menu message.")
  YES_CLICKED = Declare_Enum(1)
  NO_CLICKED = Declare_Enum()
  MSG_UPNP_FIREWALL = Declare_Enum(1)
  MSG_UPDATE_AVAILABLE = Declare_Enum()
  MSG_CAMPAIGN_ACHIEVEMENTS = Declare_Enum()
  MSG_SKIRMISH_ACHIEVEMENTS = Declare_Enum()
  YesNoOkDialogState = nil
  YesNoOkCallbacks = {
    [MSG_UPNP_FIREWALL] = UPNP_Dialog_Callback,
    [MSG_UPDATE_AVAILABLE] = Update_Available_Dialog_Callback,
    [MSG_CAMPAIGN_ACHIEVEMENTS] = Campaign_Achievements_Dialog_Callback,
    [MSG_SKIRMISH_ACHIEVEMENTS] = Skirmish_Achievements_Dialog_Callback,
  }
  if not TestValid(this.Yes_No_Ok_Dialog) then
    DebugMessage("MAIN_MENU_MESSAGE: Creating dialog handle.")
    local r0_4 = Create_Embedded_Scene("Yes_No_Ok_Dialog", this, "Yes_No_Ok_Dialog")
  end
  this.Yes_No_Ok_Dialog.Set_Hidden(true)
  this.Yes_No_Ok_Dialog.End_Modal()
  this.Yes_No_Ok_Dialog.Set_Screen_Position(0.5, 0.5)
  this.Register_Event_Handler("On_YesNoOk_Yes_Clicked", nil, On_YesNoOk_Yes_Clicked)
  this.Register_Event_Handler("On_YesNoOk_No_Clicked", nil, On_YesNoOk_No_Clicked)
  DebugMessage("MAIN_MENU_MESSAGE: Main menu message initialized.")
end
function Show_Message_Box()
  -- line: [396, 400] id: 5
  DebugMessage("MAIN_MENU_MESSAGE: Showing main menu message box")
  this.Yes_No_Ok_Dialog.Set_Hidden(false)
  this.Yes_No_Ok_Dialog.Start_Modal()
end
function On_YesNoOk_Yes_Clicked()
  -- line: [405, 411] id: 6
  if YesNoOkDialogState ~= nil then
    YesNoOkCallbacks[YesNoOkDialogState](YES_CLICKED)
  end
end
function On_YesNoOk_No_Clicked()
  -- line: [416, 422] id: 7
  if YesNoOkDialogState ~= nil then
    YesNoOkCallbacks[YesNoOkDialogState](NO_CLICKED)
  end
end
function On_Mouse_Over_Button(r0_8, r1_8)
  -- line: [428, 437] id: 8
  if TestValid(r1_8) and r1_8.Is_Enabled() == true then
    Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
    local r2_8, r3_8, r4_8, r5_8 = this.RolloverMovie.Get_World_Bounds()
    local r6_8, r7_8, r8_8, r9_8 = r1_8.Get_World_Bounds()
    this.RolloverMovie.Set_World_Bounds(r2_8, r7_8 + r9_8 / 2 - r5_8 / 2, r4_8, r5_8)
    this.RolloverMovie.Restart()
  end
end
function On_Button_Pushed(r0_9, r1_9)
  -- line: [442, 457] id: 9
  if TestValid(r1_9) and r1_9.Is_Enabled() == true then
    if r1_9 == this.Menu_Buttons.Campaign_Buttons.Button_Campaign_Back or r1_9 == this.Menu_Buttons.Multiplayer_Buttons.Button_Multiplayer_Back or r1_9 == this.Menu_Buttons.Skirmish_Buttons.Button_Skirmish_Back or r1_9 == this.Menu_Buttons.Tutorial_Buttons.Button_Tutorial_Back or r1_9 == this.Menu_Buttons.Option_Buttons.Button_Options_Back or r1_9 == this.Menu_Buttons.Debug_Buttons.Button_Debug_Back then
      Play_SFX_Event("GUI_Main_Menu_Back_Select")
    else
      Play_SFX_Event("GUI_Main_Menu_Button_Select")
    end
  end
end
function On_Update()
  -- line: [463, 545] id: 10
  PGCrontab_Update()
  if not Is_Xbox() then
    if last_gamepad_state == Is_Gamepad_Active() then
      if Is_Gamepad_Active() then
        this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Enable(false)
        this.Menu_Buttons.Option_Buttons.Button_Keyboard_Options.Set_Hidden(true)
        this.Menu_Buttons.Option_Buttons.Button_Gamepad.Set_Hidden(false)
        this.Menu_Buttons.Option_Buttons.Button_Gamepad.Enable(true)
      else
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
  if not TestValid(this.Yes_No_Ok_Dialog) then
    Init_Message_Box()
  end
  if CheckForNonLiveUpdates == true then
    local r0_10 = Net.Check_For_Non_Live_Updates()
    if r0_10 ~= -1 then
      NonLiveUpdateAvailable = true
      YesNoOkDialogState = MSG_UPDATE_AVAILABLE
      local r1_10 = {}
      local r2_10 = true
      if r0_10 == 0 then
        r2_10 = Get_Profile_Value(PP_ENABLE_UPDATE_DOWNLOAD, true)
        r1_10.Message = "TEXT_DOWNLOADABLE_UPDATE_AVAILABLE"
      elseif r0_10 == 1 then
        r2_10 = Get_Profile_Value(PP_ENABLE_LIVE_UPDATE_DOWNLOAD, true)
        r1_10.Message = "TEXT_DOWNLOADABLE_LIVE_UPDATE_AVAILABLE"
      end
      if r2_10 == true then
        this.Yes_No_Ok_Dialog.Set_Model(r1_10)
        this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
        this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
        Show_Message_Box()
      end
      CheckForNonLiveUpdates = false
    end
  end
  if NonLiveUpdateAvailable == false and CheckedForUPnP == false then
    CheckedForUPnP = true
    if Get_Profile_Value(PP_WARNING_UPNP_FIREWALL, true) == true and Net.Check_For_Open_UPnP() == true then
      YesNoOkDialogState = MSG_UPNP_FIREWALL
      this.Yes_No_Ok_Dialog.Set_Model({
        Message = "TEXT_OPEN_FIREWALL_UPNP",
      })
      this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
      this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
      Show_Message_Box()
    end
  end
end
function UPNP_Dialog_Callback(r0_11)
  -- line: [550, 563] id: 11
  if r0_11 == YES_CLICKED then
    Net.Open_UPnP()
  end
  if this.Yes_No_Ok_Dialog.Get_Checkbox_State() == true then
    Set_Profile_Value(PP_WARNING_UPNP_FIREWALL, false)
  end
end
function Update_Available_Dialog_Callback(r0_12)
  -- line: [568, 593] id: 12
  if r0_12 == YES_CLICKED and NonLiveUpdateAvailable == true then
    Net.Open_Browser_For_Non_Live_Update()
    Net.Unregister_Event_Handler(On_Network_Event)
    Net.Shutdown()
    Quit_App_Now()
  elseif r0_12 == NO_CLICKED then
    NonLiveUpdateAvailable = false
    if this.Yes_No_Ok_Dialog.Get_Checkbox_State() == true then
      local r2_12 = Net.Check_For_Non_Live_Updates()
      if r2_12 == 0 then
        Set_Profile_Value(PP_ENABLE_UPDATE_DOWNLOAD, false)
      elseif r2_12 == 1 then
        Set_Profile_Value(PP_ENABLE_LIVE_UPDATE_DOWNLOAD, false)
      end
    end
  end
end
function On_Save_File_Deleted()
  -- line: [596, 598] id: 13
  Enable_Campaign_Autosave_Button()
end
function Enable_Campaign_Autosave_Button()
  -- line: [600, 607] id: 14
  Register_Save_Load_Commands()
  if SaveLoadManager.Autosave_Exists() then
    Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Enable(true)
  else
    Mainmenu.Menu_Buttons.Campaign_Buttons.Button_Continue_Campaign.Enable(false)
  end
end
function Enable_Campaign_Buttons()
  -- line: [609, 629] id: 15
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
function On_Key_Press(r0_16, r1_16, r2_16)
  -- line: [634, 643] id: 16
  if r2_16 == "a" then
    Open_Dialog("Audio_Validation")
  elseif r2_16 == "t" then
    Open_Dialog("Text_Validation")
  end
end
function Main_Menu_Campaign_Button_Clicked(r0_17, r1_17)
  -- line: [653, 671] id: 17
  local r2_17 = Get_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, true)
  if Is_Valid_Achievement_Signin_State() or not r2_17 then
    Enter_Campaign_Menu()
    return 
  end
  YesNoOkDialogState = MSG_CAMPAIGN_ACHIEVEMENTS
  this.Yes_No_Ok_Dialog.Set_Model({
    Message = "TEXT_ACHIEVEMENTS_SINGLE_PLAYER_SIGNED_OUT_WARNING",
  })
  this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
  this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
  Show_Message_Box()
end
function Campaign_Achievements_Dialog_Callback(r0_18)
  -- line: [677, 689] id: 18
  if r0_18 == YES_CLICKED then
    Net.Show_Signin_UI()
  end
  Enter_Campaign_Menu()
  if this.Yes_No_Ok_Dialog.Get_Checkbox_State() == true then
    Set_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, false)
  end
end
function Enter_Campaign_Menu()
  -- line: [694, 698] id: 19
  Enable_Campaign_Buttons()
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(false)
end
function Main_Menu_Skirmish_Button_Clicked(r0_20, r1_20)
  -- line: [704, 722] id: 20
  local r2_20 = Get_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, true)
  if Is_Valid_Achievement_Signin_State() or not r2_20 then
    Enter_Skirmish_Menu()
    return 
  end
  YesNoOkDialogState = MSG_SKIRMISH_ACHIEVEMENTS
  this.Yes_No_Ok_Dialog.Set_Model({
    Message = "TEXT_ACHIEVEMENTS_SINGLE_PLAYER_SIGNED_OUT_WARNING",
  })
  this.Yes_No_Ok_Dialog.Set_Yes_No_Mode()
  this.Yes_No_Ok_Dialog.Set_Checkbox_Visible(true)
  Show_Message_Box()
end
function Skirmish_Achievements_Dialog_Callback(r0_21)
  -- line: [728, 740] id: 21
  if r0_21 == YES_CLICKED then
    Net.Show_Signin_UI()
  end
  Enter_Skirmish_Menu()
  if this.Yes_No_Ok_Dialog.Get_Checkbox_State() == true then
    Set_Profile_Value(PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS, false)
  end
end
function Enter_Skirmish_Menu()
  -- line: [745, 748] id: 22
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(false)
end
function Main_Menu_Multiplayer_Button_Clicked(r0_23, r1_23)
  -- line: [750, 754] id: 23
  Set_Menus_For_Live_Logon_State()
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
end
function Main_Menu_Tutorials_Button_Clicked(r0_24, r1_24)
  -- line: [756, 759] id: 24
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(false)
end
function Main_Menu_Options_Button_Clicked(r0_25, r1_25)
  -- line: [761, 764] id: 25
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(false)
end
function Main_Menu_Profile_Button_Clicked(r0_26, r1_26)
  -- line: [766, 768] id: 26
  Net.Show_Guide_UI()
end
function Main_Menu_Mod_Button_Clicked(r0_27, r1_27)
  -- line: [770, 780] id: 27
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
function On_Beta_Splash_Notification_Clicked(r0_28)
  -- line: [782, 800] id: 28
  if r0_28 == 1 then
    Net.Unregister_Event_Handler(On_Network_Event)
    Net.Shutdown()
    Quit_App_Now()
  elseif r0_28 == 2 then
    Net.Launch_URL("http://www.sega.com/games/title/universeatwar/uaw_betatest_feedback.php")
    Net.Unregister_Event_Handler(On_Network_Event)
    Net.Shutdown()
  elseif r0_28 == 3 then
    Net.Launch_URL("http://www.gamestop.com/product.asp?product%5Fid=646975")
    Net.Unregister_Event_Handler(On_Network_Event)
    Net.Shutdown()
  elseif r0_28 == 4 then
    Net.Launch_URL("http://www.amazon.com/Universe-At-War-Earth-Assault/dp/B000R2WI0G/ref=pd_bbs_sr_1/105-4555601-6077255?ie=UTF8&s=videogames&qid=1185985796&sr=8-1")
    Net.Unregister_Event_Handler(On_Network_Event)
    Net.Shutdown()
  end
end
function Main_Menu_Exit_Button_Clicked(r0_29, r1_29)
  -- line: [802, 815] id: 29
  if BETA_BUILD then
    Spawn_Dialog_Box({
      spawned_from_script = true,
      use_bui_buttons = true,
      callback = "On_Beta_Splash_Notification_Clicked",
      script = Script,
    }, "Beta_Exit_Screen", false)
  else
    Net.Unregister_Event_Handler(On_Network_Event)
    Net.Shutdown()
    Quit_App_Now()
  end
end
function Main_Menu_Debug_Button_Clicked(r0_30, r1_30)
  -- line: [817, 827] id: 30
  if not GOLD_BUILD and not BETA_BUILD then
    Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
    Mainmenu.Menu_Buttons.Debug_Buttons.Set_Hidden(false)
    Mainmenu.Menu_Buttons.Debug_Buttons.Button_Debug_Load_Map.Set_Key_Focus()
  end
end
function Campaign_Continue_Button_Clicked(r0_31, r1_31)
  -- line: [837, 839] id: 31
  SaveLoadManager.Auto_Load()
end
function Campaign_Tutorial_Button_Clicked(r0_32, r1_32)
  -- line: [844, 847] id: 32
  CampaignManager.Start_Campaign("Tutorial_Story_Campaign")
end
function Campaign_Novus_Button_Clicked(r0_33, r1_33)
  -- line: [849, 852] id: 33
  CampaignManager.Start_Campaign("NOVUS_Story_Campaign")
end
function Campaign_Hierarchy_Button_Clicked(r0_34, r1_34)
  -- line: [854, 857] id: 34
  CampaignManager.Start_Campaign("Hierarchy_Story_Campaign")
end
function Campaign_Masari_Button_Clicked(r0_35, r1_35)
  -- line: [859, 862] id: 35
  CampaignManager.Start_Campaign("MASARI_Story_Campaign")
end
function Campaign_Scenario_Button_Clicked(r0_36, r1_36)
  -- line: [864, 873] id: 36
  if not TestValid(this.Scenario_Setup_Dialog) then
    Create_Embedded_Scene("Scenario_Setup_Dialog", this, "Scenario_Setup_Dialog")
    this.Scenario_Setup_Dialog.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    this.Scenario_Setup_Dialog.Set_Hidden(false)
  end
  this.Scenario_Setup_Dialog.Start_Modal()
end
function Campaign_Load_Game_Button_Clicked(r0_37, r1_37)
  -- line: [875, 886] id: 37
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
function Campaign_Back_Button_Clicked(r0_38, r1_38)
  -- line: [888, 892] id: 38
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Campaign.Set_Key_Focus()
end
function Skirmish_New_Game_Button_Clicked(r0_39, r1_39)
  -- line: [898, 910] id: 39
  Main_Menu_Passivate_Movies()
  if not TestValid(Mainmenu.Skirmish_Setup_Dialog) then
    local r2_39 = nil
    r2_39 = Create_Embedded_Scene("Skirmish_Setup_Dialog", Mainmenu, "Skirmish_Setup_Dialog")
    this.Skirmish_Setup_Dialog.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Skirmish_Setup_Dialog.Set_Hidden(false)
  end
  Mainmenu.Skirmish_Setup_Dialog.Start_Modal()
  Main_Menu_Passivate_Movies()
end
function Skirmish_Load_Game_Button_Clicked(r0_40, r1_40)
  -- line: [912, 923] id: 40
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
function Skirmish_Back_Button_Clicked(r0_41, r1_41)
  -- line: [925, 929] id: 41
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Skirmish_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Skirmish.Set_Key_Focus()
end
function Debug_Milestone_Button_Clicked(r0_42, r1_42)
  -- line: [935, 937] id: 42
  CampaignManager.Start_Campaign("Even_Split_Global_Campaign_Novus")
end
function Debug_Load_Map_Button_Clicked(r0_43, r1_43)
  -- line: [939, 951] id: 43
  if not TestValid(Mainmenu.Game_Map_Loader) then
    local r2_43 = Create_Embedded_Scene("Game_Map_Loader", Mainmenu, "Game_Map_Loader")
    this.Game_Map_Loader.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Game_Map_Loader.Set_Hidden(false)
  end
  Mainmenu.Game_Map_Loader.Start_Modal()
end
function Debug_Achievement_Chest_Button_Clicked(r0_44, r1_44)
  -- line: [956, 964] id: 44
  if not TestValid(Mainmenu.Achievement_Chest) then
    local r2_44 = Create_Embedded_Scene("Achievement_Chest", Mainmenu, "Achievement_Chest")
    this.Achievement_Chest.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Achievement_Chest.Set_Hidden(false)
  end
end
function Debug_Load_Mission_Button_Clicked(r0_45, r1_45)
  -- line: [966, 975] id: 45
  if not TestValid(Mainmenu.Debug_Load_Mission_Dialog) then
    local r2_45 = Create_Embedded_Scene("Debug_Load_Mission_Dialog", Mainmenu, "Debug_Load_Mission_Dialog")
    this.Debug_Load_Mission_Dialog.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Debug_Load_Mission_Dialog.Set_Hidden(false)
  end
  Mainmenu.Debug_Load_Mission_Dialog.Start_Modal()
end
function Debug_Back_Button_Clicked(r0_46, r1_46)
  -- line: [977, 981] id: 46
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Debug_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Debug.Set_Key_Focus()
end
function Common_Ranked_Game_Clicked(r0_47)
  -- line: [988, 1013] id: 47
  QuickMatchMode = r0_47
  local r1_47 = TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy()
  local r2_47 = TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy()
  if r1_47 or r2_47 then
    return 
  end
  if Net.Get_Signin_State() ~= "online" then
    Net.Show_Signin_UI()
    return 
  end
  if not TestValid(Mainmenu.Network_Progress_Bar) then
    local r3_47 = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
  else
    Mainmenu.Network_Progress_Bar.Set_Hidden(false)
  end
  Mainmenu.Network_Progress_Bar.Start()
  Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
  Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
  PGCrontab_Schedule(Start_Ranked_Game, 0, 1)
end
function Multiplayer_Ranked_Game_Clicked(r0_48, r1_48)
  -- line: [1018, 1020] id: 48
  Common_Ranked_Game_Clicked(0)
end
function Multiplayer_Sign_In_Clicked(r0_49, r1_49)
  -- line: [1025, 1027] id: 49
  Net.Show_Signin_UI()
end
function Multiplayer_Custom_Match_Clicked(r0_50, r1_50)
  -- line: [1032, 1061] id: 50
  local r2_50 = TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy()
  local r3_50 = TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy()
  if r2_50 or r3_50 then
    return 
  end
  if Net.Get_Signin_State() ~= "online" then
    Net.Show_Signin_UI()
    return 
  end
  DebugMessage("Multiplayer_Internet_Button_Clicked():: Attempting to connect.  Please wait...\n")
  if not TestValid(Mainmenu.Network_Progress_Bar) then
    local r4_50 = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
  else
    Mainmenu.Network_Progress_Bar.Set_Hidden(false)
  end
  Mainmenu.Network_Progress_Bar.Start()
  Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
  Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
  PGCrontab_Schedule(Start_Internet_Lobby, 0, 1)
end
function Multiplayer_Conquer_The_World_Button_Clicked(r0_51, r1_51)
  -- line: [1066, 1095] id: 51
  local r2_51 = TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy()
  local r3_51 = TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy()
  if r2_51 or r3_51 then
    return 
  end
  if Net.Get_Signin_State() ~= "online" then
    Net.Show_Signin_UI()
    return 
  end
  if not TestValid(Mainmenu.Network_Progress_Bar) then
    local r4_51 = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
  else
    Mainmenu.Network_Progress_Bar.Set_Hidden(false)
  end
  Mainmenu.Network_Progress_Bar.Start({
    "Bank_Global_Conquest",
    "Bank_Map_Preview"
  })
  Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
  Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
  PGCrontab_Schedule(Start_Global_Conquest_Lobby, 0, 1)
end
function Set_Menus_For_Live_Logon_State()
  -- line: [1097, 1199] id: 52
  local r1_52 = Net.Get_Signin_State()
  local r0_52 = nil	-- notice: implicit variable refs by block#[7, 8]
  if r1_52 == "online" then
    r0_52 = 1
    if Net.Requires_Locator_Service() == false then
      r0_52 = 2
    end
  elseif r1_52 == "local" or r1_52 == "multi" or r1_52 == "non-live" then
    r0_52 = 3
  end
  OutputDebug("Set_Menus_For_Live_Logon_State -- old_state: %s, new_state: %s\n", tostring(LiveLogonState), tostring(r0_52))
  if LiveLogonState ~= r0_52 then
    LiveLogonState = r0_52
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
        if LiveLogonState == nil and BETA_BUILD ~= true then
          Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_LAN.Enable(false)
        end
      end
    end
  end
end
function On_Network_Event(r0_53)
  -- line: [1205, 1217] id: 53
  if r0_53 == nil then
    DebugMessage("LUA_NET: ERROR: Got a nil network event!")
  elseif r0_53.type == NETWORK_EVENT_TASK_COMPLETE then
    if r0_53.task == "TASK_LIVE_CONNECTION_CHANGED" then
      OutputDebug("On_Network_Event::TASK_LIVE_CONNECTION_CHANGED\n")
      Set_Menus_For_Live_Logon_State()
    elseif r0_53.task == "TASK_LIVE_SIGNIN_CHANGED" then
      OutputDebug("On_Network_Event::TASK_LIVE_SIGNIN_CHANGED\n")
      Set_Menus_For_Live_Logon_State()
    end
  end
end
function Multiplayer_Leaderboards_Button_Clicked()
  -- line: [1222, 1230] id: 54
  Main_Menu_Passivate_Movies()
  if not TestValid(Mainmenu.Leaderboard_Dialog) then
    local r0_54 = Create_Embedded_Scene("Leaderboard_Dialog", Mainmenu, "Leaderboard_Dialog")
  else
    Mainmenu.Leaderboard_Dialog.Set_Hidden(false)
  end
  Mainmenu.Leaderboard_Dialog.Start_Modal()
end
function Main_Menu_Quick_Match_Button_Clicked(r0_55, r1_55)
  -- line: [1235, 1238] id: 55
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(false)
end
function Multiplayer_LAN_Button_Clicked(r0_56, r1_56)
  -- line: [1243, 1271] id: 56
  local r2_56 = TestValid(Mainmenu.Network_Progress_Bar) and Mainmenu.Network_Progress_Bar.Is_Busy()
  local r3_56 = TestValid(Mainmenu.Internet_Dialog) and Mainmenu.Internet_Dialog.Is_Busy()
  if r2_56 or r3_56 then
    return 
  end
  if Net.Get_Signin_State() == nil then
    Net.Show_Signin_UI()
    return 
  end
  if not TestValid(Mainmenu.Network_Progress_Bar) then
    local r4_56 = Create_Embedded_Scene("Network_Progress_Bar", Mainmenu, "Network_Progress_Bar")
  else
    Mainmenu.Network_Progress_Bar.Set_Hidden(false)
  end
  Mainmenu.Network_Progress_Bar.Start()
  Mainmenu.Network_Progress_Bar.Set_Message(Get_Game_Text("TEXT_MESSAGE_CONNECT_TO_NETWORK"))
  Mainmenu.Network_Progress_Bar.Hide_Cancel_Button()
  PGCrontab_Schedule(Start_LAN_Lobby, 0, 1)
end
function Multiplayer_Load_Replay_Button_Clicked(r0_57, r1_57)
  -- line: [1274, 1283] id: 57
  if not TestValid(Mainmenu.Load_Replay_Dialog) then
    Create_Embedded_Scene("Load_Game_Dialog", Mainmenu, "Load_Replay_Dialog")
  else
    Mainmenu.Load_Replay_Dialog.Set_Hidden(false)
  end
  Mainmenu.Load_Replay_Dialog.Set_Mode(SAVE_LOAD_MODE_REPLAY)
  Mainmenu.Load_Replay_Dialog.Display_Dialog()
  Mainmenu.Load_Replay_Dialog.Start_Modal()
end
function Start_LAN_Lobby()
  -- line: [1288, 1323] id: 58
  Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing LAN lobby...")
  DebugMessage("Start_LAN_Lobby():: Successful LAN connection.\n")
  Main_Menu_Passivate_Movies()
  if ENABLE_NEW_MULTIPLAYER_FLOW then
    if not TestValid(Mainmenu.Live_Profile_Game_Dialog) then
      local r0_58 = Create_Embedded_Scene("Live_Profile_Game_Dialog", Mainmenu, "Live_Profile_Game_Dialog")
      this.Live_Profile_Game_Dialog.Set_Tab_Order(NextTabOrder)
      NextTabOrder = NextTabOrder + 1
    else
      Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(false)
    end
    Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(false)
    Mainmenu.Live_Profile_Game_Dialog.Set_Network_State_LAN()
  else
    if not TestValid(Mainmenu.LAN_Lobby_Dialog) then
      local r0_58 = Create_Embedded_Scene("LAN_Lobby_Dialog", Mainmenu, "LAN_Lobby_Dialog")
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
function Start_Ranked_Game()
  -- line: [1328, 1346] id: 59
  Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing Ranked lobby...")
  DebugMessage("Start_Ranked_Game():: Successful Internet connection.\n")
  if not TestValid(Mainmenu.Ranked_Game_Dialog) then
    local r0_59 = Create_Embedded_Scene("Ranked_Game_Dialog", Mainmenu, "Ranked_Game_Dialog")
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
function Is_Internet_Lobby_Active()
  -- line: [1351, 1356] id: 60
  if TestValid(Mainmenu.Live_Profile_Game_Dialog) then
    return Mainmenu.Live_Profile_Game_Dialog.Get_Hidden() == false
  end
  return false
end
function Start_Join_For_Invite()
  -- line: [1361, 1366] id: 61
  if Accepting_Invitation and TestValid(Mainmenu.Live_Profile_Game_Dialog) and Mainmenu.Live_Profile_Game_Dialog.Get_Hidden() == false then
    Accepting_Invitation = false
    Mainmenu.Live_Profile_Game_Dialog.Set_Is_Accepting_Invitation()
  end
end
function Start_Internet_Lobby()
  -- line: [1371, 1404] id: 62
  Mainmenu.Network_Progress_Bar.Set_Message("Connected.  Preparing Internet lobby...")
  DebugMessage("Start_Internet_Lobby():: Successful Internet connection.\n")
  Main_Menu_Passivate_Movies()
  if ENABLE_NEW_MULTIPLAYER_FLOW then
    if not TestValid(Mainmenu.Live_Profile_Game_Dialog) then
      local r0_62 = Create_Embedded_Scene("Live_Profile_Game_Dialog", Mainmenu, "Live_Profile_Game_Dialog")
      this.Live_Profile_Game_Dialog.Set_Tab_Order(NextTabOrder)
      NextTabOrder = NextTabOrder + 1
      Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(true)
    end
    Mainmenu.Live_Profile_Game_Dialog.Set_Hidden(false)
    Mainmenu.Live_Profile_Game_Dialog.Set_Network_State_Internet()
  else
    if not TestValid(Mainmenu.Internet_Lobby_Dialog) then
      local r0_62 = Create_Embedded_Scene("Internet_Lobby_Dialog", Mainmenu, "Internet_Lobby_Dialog")
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
function Start_Global_Conquest_Lobby()
  -- line: [1410, 1436] id: 63
  DebugMessage("LUA_LOBBY: Starting global conquest lobby...")
  if not Mainmenu.Network_Progress_Bar.Is_Done() then
    PGCrontab_Schedule(Start_Global_Conquest_Lobby, 0, 1)
    return 
  end
  Main_Menu_Passivate_Movies()
  if not TestValid(Mainmenu.Global_Conquest_Lobby) then
    local r0_63 = Create_Embedded_Scene("Global_Conquest_Lobby", Mainmenu, "Global_Conquest_Lobby")
    this.Global_Conquest_Lobby.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Global_Conquest_Lobby.Rebuild_Graphics()
    Mainmenu.Global_Conquest_Lobby.Set_Hidden(false)
  end
  Mainmenu.Network_Progress_Bar.Stop()
  Mainmenu.Network_Progress_Bar.Set_Hidden(true)
end
function Multiplayer_Back_Button_Clicked(r0_64, r1_64)
  -- line: [1441, 1445] id: 64
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Multiplayer.Set_Key_Focus()
end
function Multiplayer_QM_Back_Button_Clicked(r0_65, r1_65)
  -- line: [1457, 1461] id: 65
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Quick_Match_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Button_Quick_Match.Set_Key_Focus()
end
function Multiplayer_QM_Player_Button_Clicked(r0_66, r1_66)
  -- line: [1464, 1466] id: 66
  Common_Ranked_Game_Clicked(1)
end
function Multiplayer_QM_Ranked_Button_Clicked(r0_67, r1_67)
  -- line: [1468, 1470] id: 67
  Common_Ranked_Game_Clicked(2)
end
function Load_Tutorial_Movie(r0_68)
  -- line: [1476, 1487] id: 68
  local r1_68 = GameScoringManager.Get_Game_Script_Data_Table()
  if r1_68 == nil then
    r1_68 = {}
  end
  r1_68.Tutorial = r0_68
  GameScoringManager.Set_Game_Script_Data_Table(r1_68)
  CampaignManager.Start_Campaign("Tutorial_Cinematics")
end
function Tutorial_Button_Training_Clicked(r0_69, r1_69)
  -- line: [1489, 1493] id: 69
  SaveLoadManager.Disable_Auto_Save()
  CampaignManager.Start_Campaign("TUTORIAL_NEW_Story_Campaign")
end
function Tutorial_Button_1_Clicked(r0_70, r1_70)
  -- line: [1495, 1497] id: 70
  Load_Tutorial_Movie("State_Tutorial_1")
end
function Tutorial_Button_2_Clicked(r0_71, r1_71)
  -- line: [1499, 1501] id: 71
  Load_Tutorial_Movie("State_Tutorial_2")
end
function Tutorial_Button_3_Clicked(r0_72, r1_72)
  -- line: [1503, 1505] id: 72
  Load_Tutorial_Movie("State_Tutorial_3")
end
function Tutorial_Button_4_Clicked(r0_73, r1_73)
  -- line: [1507, 1509] id: 73
  Load_Tutorial_Movie("State_Tutorial_4")
end
function Tutorial_Button_5_Clicked(r0_74, r1_74)
  -- line: [1511, 1513] id: 74
  Load_Tutorial_Movie("State_Tutorial_5")
end
function Tutorial_Button_6_Clicked(r0_75, r1_75)
  -- line: [1515, 1517] id: 75
  Load_Tutorial_Movie("State_Tutorial_6")
end
function Tutorial_Button_7_Clicked(r0_76, r1_76)
  -- line: [1519, 1521] id: 76
  Load_Tutorial_Movie("State_Tutorial_7")
end
function Tutorial_Button_8_Clicked(r0_77, r1_77)
  -- line: [1523, 1525] id: 77
  Load_Tutorial_Movie("State_Tutorial_8")
end
function Tutorial_Button_9_Clicked(r0_78, r1_78)
  -- line: [1527, 1529] id: 78
  Load_Tutorial_Movie("State_Tutorial_9")
end
function Tutorial_Button_10_Clicked(r0_79, r1_79)
  -- line: [1531, 1533] id: 79
  Load_Tutorial_Movie("State_Tutorial_10")
end
function Tutorial_Button_11_Clicked(r0_80, r1_80)
  -- line: [1535, 1537] id: 80
  Load_Tutorial_Movie("State_Tutorial_11")
end
function Tutorial_Button_12_Clicked(r0_81, r1_81)
  -- line: [1539, 1541] id: 81
  Load_Tutorial_Movie("State_Tutorial_12")
end
function Tutorial_Button_13_Clicked(r0_82, r1_82)
  -- line: [1543, 1545] id: 82
  Load_Tutorial_Movie("State_Tutorial_13")
end
function Tutorial_Button_14_Clicked(r0_83, r1_83)
  -- line: [1547, 1549] id: 83
  Load_Tutorial_Movie("State_Tutorial_14")
end
function Tutorial_Button_15_Clicked(r0_84, r1_84)
  -- line: [1551, 1553] id: 84
  Load_Tutorial_Movie("State_Tutorial_15")
end
function Tutorial_Button_16_Clicked(r0_85, r1_85)
  -- line: [1555, 1557] id: 85
  Load_Tutorial_Movie("State_Tutorial_16")
end
function Tutorial_Button_Back_Clicked(r0_86, r1_86)
  -- line: [1559, 1563] id: 86
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Tutorial_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Tutorials.Set_Key_Focus()
end
function Options_Audio_Button_Clicked(r0_87, r1_87)
  -- line: [1569, 1576] id: 87
  if not TestValid(Mainmenu.Audio_Options_Dialog) then
    Create_Embedded_Scene("Audio_Options_Dialog", Mainmenu, "Audio_Options_Dialog")
  else
    Mainmenu.Audio_Options_Dialog.Set_Hidden(false)
  end
  Mainmenu.Audio_Options_Dialog.Start_Modal()
end
function Options_Video_Button_Clicked(r0_88, r1_88)
  -- line: [1578, 1585] id: 88
  if not TestValid(Mainmenu.Video_Options_Dialog) then
    Create_Embedded_Scene("Video_Options_Dialog", Mainmenu, "Video_Options_Dialog")
  else
    Mainmenu.Video_Options_Dialog.Set_Hidden(false)
  end
  Mainmenu.Video_Options_Dialog.Start_Modal()
end
function Options_Network_Button_Clicked(r0_89, r1_89)
  -- line: [1587, 1594] id: 89
  Net.Show_Gamer_Card_UI()
end
function Options_Keyboard_Button_Clicked(r0_90, r1_90)
  -- line: [1597, 1606] id: 90
  if not TestValid(Mainmenu.Keyboard_Options) then
    local r2_90 = Create_Embedded_Scene("Keyboard_Configuration_Dialog", Mainmenu, "Keyboard_Options")
    this.Keyboard_Options.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Keyboard_Options.Set_Hidden(false)
  end
  Mainmenu.Keyboard_Options.Start_Modal()
end
function Gamepad_Options_Dialog_Selected()
  -- line: [1608, 1618] id: 91
  if not TestValid(Mainmenu.Gamepad_ButtonMap) then
    Create_Embedded_Scene("Gamepad_ButtonMap", Mainmenu, "Gamepad_ButtonMap")
    this.Gamepad_ButtonMap.Set_Tab_Order(NextTabOrder)
    NextTabOrder = NextTabOrder + 1
  else
    Mainmenu.Gamepad_ButtonMap.Set_Hidden(false)
  end
  Mainmenu.Gamepad_ButtonMap.Start_Modal()
end
function Options_Game_Button_Clicked(r0_92, r1_92)
  -- line: [1620, 1627] id: 92
  if not TestValid(Mainmenu.Gameplay_Options_Dialog) then
    Create_Embedded_Scene("Gameplay_Options_Dialog", Mainmenu, "Gameplay_Options_Dialog")
  else
    Mainmenu.Gameplay_Options_Dialog.Set_Hidden(false)
  end
  Mainmenu.Gameplay_Options_Dialog.Start_Modal()
end
function Options_Credits_Button_Clicked(r0_93, r1_93)
  -- line: [1629, 1632] id: 93
  Main_Menu_Passivate_Movies()
  Roll_Credits()
end
function On_Credits_Done()
  -- line: [1634, 1636] id: 94
  Main_Menu_Activate_Movies()
end
function Options_Trailer_Button_Clicked()
  -- line: [1638, 1640] id: 95
  Play_Full_Screen_Movie("Trailer.bik")
end
function Options_Back_Button_Clicked(r0_96, r1_96)
  -- line: [1642, 1646] id: 96
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(false)
  Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Button_Options.Set_Key_Focus()
end
function Skip_To_Options_Dialog()
  -- line: [1652, 1655] id: 97
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Option_Buttons.Set_Hidden(false)
end
function Skip_To_Campaign_Dialog()
  -- line: [1657, 1660] id: 98
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Campaign_Buttons.Set_Hidden(false)
end
function Skip_To_Multiplayer_Dialog()
  -- line: [1662, 1665] id: 99
  Mainmenu.Menu_Buttons.Main_Menu_Buttons.Set_Hidden(true)
  Mainmenu.Menu_Buttons.Multiplayer_Buttons.Set_Hidden(false)
end
function Play_Click()
  -- line: [1667, 1669] id: 100
  Play_SFX_Event("GUI_Generic_Button_Select")
end
function Play_Alien_Steam()
  -- line: [1671, 1673] id: 101
  Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end
function Debug_Start_AI_Skirmish()
  -- line: [1675, 1721] id: 102
  ClientTable = {}
  ClientTable[1] = {}
  ClientTable[1].name = Create_Wide_String("LocalPlayer")
  ClientTable[1].common_addr = Net.Get_Local_Addr()
  ClientTable[1].faction = "Novus"
  ClientTable[1].color = 15
  ClientTable[1].is_ai = false
  ClientTable[1].team = 1
  LocalClient = ClientTable[1]
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
  for r3_102, r4_102 in pairs(ClientTable) do
    r4_102.PlayerID = Net.Get_Player_ID_By_Network_Address(r4_102.common_addr)
    if r4_102.common_addr == LocalClient.common_addr then
      LocalClient.PlayerID = r4_102.PlayerID
    end
  end
  Set_Player_Info_Table(ClientTable)
  GameScoringManager.Set_Local_Client_Table(LocalClient)
  GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
end
function Set_State_Restart_Map()
  -- line: [1723, 1729] id: 103
  DebugMessage("LUA_MAIN_MENU: Set_State_Restart_Map().")
  Mainmenu.Skirmish_Setup_Dialog.Set_Restarting_Map(true)
  if Save_Restart_Map_Data() then
    this.Set_State("restart_map")
  end
end
function On_Enter_State_Restart_Map()
  -- line: [1731, 1734] id: 104
  DebugMessage("LUA_MAIN_MENU: Entering restart map state.")
  this.Set_State("default")
end
function On_Exit_State_Restart_Map()
  -- line: [1736, 1739] id: 105
  DebugMessage("LUA_MAIN_MENU: Exiting restart map state.")
  Restart_Map()
end
function Save_Restart_Map_Data()
  -- line: [1741, 1759] id: 106
  DebugMessage("LUA_MAIN_MENU: Saving restart map data.")
  Register_Game_Scoring_Commands()
  local r0_106 = GameScoringManager.Get_Player_Info_Table()
  if r0_106 == nil or r0_106.ClientTable == nil then
    return false
  end
  RestartClientTable = r0_106.ClientTable
  RestartLocalClientTable = GameScoringManager.Get_Local_Client_Table()
  if RestartLocalClientTable == nil then
    return false
  end
  RestartGameScriptData = GameScoringManager.Get_Game_Script_Data_Table()
  if RestartGameScriptData == nil or RestartGameScriptData.GameOptions == nil then
    return false
  end
  return true
end
function Restart_Map()
  -- line: [1762, 1794] id: 107
  DebugMessage("LUA_MAIN_MENU: ---> RESTARTING MAP <---")
  local r0_107 = {}
  for r4_107, r5_107 in pairs(RestartClientTable) do
    table.insert(r0_107, r5_107)
  end
  Net.MM_Start_Game(RestartGameScriptData.GameOptions, r0_107)
  for r4_107, r5_107 in pairs(RestartClientTable) do
    if r5_107.common_addr == RestartLocalClientTable.common_addr then
      r5_107.PlayerID = RestartLocalClientTable.PlayerID
    else
      r5_107.PlayerID = Net.Get_Player_ID_By_Network_Address(r5_107.common_addr)
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
  -- line: [1796, 1802] id: 108
  Accepting_Invitation = true
  Raise_Event_Immediate_All_Scenes("Close_Dialog_For_Invitation", {})
  Multiplayer_Custom_Match_Clicked()
end
function Controller_Key_As_Back(r0_109, r1_109)
  -- line: [1805, 1823] id: 109
  if Mainmenu.Menu_Buttons.Campaign_Buttons.Get_Hidden() == false then
    Campaign_Back_Button_Clicked(r0_109, r1_109)
  elseif Mainmenu.Menu_Buttons.Skirmish_Buttons.Get_Hidden() == false then
    Skirmish_Back_Button_Clicked(r0_109, r1_109)
  elseif Mainmenu.Menu_Buttons.Debug_Buttons.Get_Hidden() == false then
    Debug_Back_Button_Clicked(r0_109, r1_109)
  elseif Mainmenu.Menu_Buttons.Multiplayer_Buttons.Get_Hidden() == false then
    Multiplayer_Back_Button_Clicked(r0_109, r1_109)
  elseif Mainmenu.Menu_Buttons.Tutorial_Buttons.Get_Hidden() == false then
    Tutorial_Button_Back_Clicked(r0_109, r1_109)
  elseif Mainmenu.Menu_Buttons.Option_Buttons.Get_Hidden() == false then
    Options_Back_Button_Clicked(r0_109, r1_109)
  elseif Mainmenu.Menu_Buttons.Main_Menu_Buttons.Get_Hidden() ~= false then
    print("ERROR: none of the MainMenu button groups are visible")
  end
end
function Heavyweight_Child_Scene_Closing()
  -- line: [1828, 1831] id: 110
  Main_Menu_Activate_Movies()
  Net.Set_User_Info({
    [X_CONTEXT_PRESENCE] = CONTEXT_PRESENCE_MENU,
  })
end
function Main_Menu_Activate_Movies()
  -- line: [1836, 1842] id: 111
  if TestValid(Mainmenu.Movie_1) then
    Mainmenu.Movie_1.Play()
  end
end
function Main_Menu_Passivate_Movies()
  -- line: [1847, 1853] id: 112
  if TestValid(Mainmenu.Movie_1) then
    Mainmenu.Movie_1.Stop()
  end
end
function Play_Full_Screen_Movie(r0_113)
  -- line: [1858, 1875] id: 113
  Main_Menu_Passivate_Movies()
  Register_Video_Commands()
  local r1_113 = VideoSettingsManager.Get_Current_Settings()
  local r4_113 = r1_113.Screen_Width / r1_113.Screen_Height / 1.7777777910232544
  this.FullScreenMovieGroup.Movie.Set_World_Bounds(0, (1 - r4_113) / 2, 1, r4_113)
  Stop_All_Music()
  this.FullScreenMovieGroup.Movie.Set_Movie(r0_113)
  this.FullScreenMovieGroup.Set_Hidden(false)
  Play_Music("Main_Menu_Music_Event")
end
function Stop_Full_Screen_Movie()
  -- line: [1880, 1884] id: 114
  this.FullScreenMovieGroup.Movie.Stop()
  this.FullScreenMovieGroup.Set_Hidden(true)
  Main_Menu_Activate_Movies()
end
function Is_Valid_Achievement_Signin_State()
  -- line: [1889, 1894] id: 115
  if Net.Get_Signin_State() == "online" or Net.Get_Signin_State() == "local" then
    return true
  end
  return false
end
function On_Menu_System_Activated()
  -- line: [1899, 1904] id: 116
  Enable_Campaign_Buttons()
end
function Kill_Unused_Global_Functions()
  -- line: [1905, 2010] id: 117
  local r0_117 = nil	-- notice: implicit variable refs by block#[0]
  Abs = r0_117
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
  r0_117 = nil
  Kill_Unused_Global_Functions = r0_117
end
