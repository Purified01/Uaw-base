-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Achievement_Chest.lua#64 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Achievement_Chest.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 90448 $
--
--          $DateTime: 2008/01/07 17:42:45 $
--
--          $Revision: #64 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGColors")
require("PGPlayerProfile")
require("PGAchievementsCommon")
require("Achievement_Common")
require("PGOnlineAchievementDefs")
require("PGFactions")
require("PGNetwork")
require("PGCrontab")
require("Lobby_Network_Logic")		-- For retriving XLive achievement data.


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	-- **** REQUIRE FILE INIT ****
	-- Global variables now MUST be initialized inside functions
	PGPlayerProfile_Init()
	PGNetwork_Init()
	PGColors_Init()
	PGAchievementsCommon_Init()
	Achievement_Common_Init(ShowUnachievedAchievements)
	PGOnlineAchievementDefs_Init()
	PGFactions_Init()
	PGLobby_Vars_Init()
	PGCrontab_Init()

	PGLobby_Set_Dialog_Is_Hidden(false)

	Achievement_Display.Start_Modal()

	MEDALS_BETA_FLAG = BETA_BUILD
	
	VANITY_STATS_VIEW_RANKED = Declare_Enum(1)
	VANITY_STATS_VIEW_UNRANKED = Declare_Enum()
	
	WIDE_STAT_SEPARATOR = Create_Wide_String(": ")
	LINEFEED = "\n"
	WIDE_DOUBLE_DASH = Create_Wide_String("--")
	
	NO_MEDAL_TEXTURE = "i_no_medal"
	
	ACHIEVEMENT_VERIFY_INTERVAL = 15		-- We verify that we have the results back in 10 seconds.

	ShowUnachievedAchievements = true
	DragDropMedal = nil

	-- Achievement progress fields.
	Net.Register_XLive_Constants()
	INCREMENT_MEDAL_LOOKUP = {
		[ACHIEVEMENT_MP_CANT_STOP_NOVUS]				= PROPERTY_MEDAL_CANT_STOP_NOVUS,
		[ACHIEVEMENT_MP_WHIRLING_DERVISH] 			= PROPERTY_MEDAL_WHIRLING_DERVISH,
		[ACHIEVEMENT_MP_THE_POWER_MUST_FLOW] 		= PROPERTY_MEDAL_THE_POWER_MUST_FLOW,
		[ACHIEVEMENT_MP_PURE_OHMAGE] 					= PROPERTY_MEDAL_PURE_OHMAGE,
		[ACHIEVEMENT_MP_DARK_MATTER_FTW] 			= PROPERTY_MEDAL_DARK_MATTER_FTW,
		[ACHIEVEMENT_MP_BLINDED_BY_THE_LIGHT] 		= PROPERTY_MEDAL_BLINDED_BY_THE_LIGHT,
		[ACHIEVEMENT_MP_THE_SACRED_COW] 				= PROPERTY_MEDAL_THE_SACRED_COW,
		[ACHIEVEMENT_MP_PEACE_THROUGH_POWER] 		= PROPERTY_MEDAL_PEACE_THROUGH_POWER,
		[ACHIEVEMENT_MP_MUTATION_IS_GOOD] 			= PROPERTY_MEDAL_MUTATION_MADNESS,
		[ACHIEVEMENT_MP_TECHNOLOGICAL_TERROR] 		= PROPERTY_MEDAL_TECHNOLOGICAL_TERROR,
		[ACHIEVEMENT_MP_RESEARCH_IS_KEY] 			= PROPERTY_MEDAL_RESEARCH_IS_KEY,
		[ACHIEVEMENT_MP_TIME_MEANS_NOTHING] 		= PROPERTY_MEDAL_TIME_MEANS_NOTHING,
		[ACHIEVEMENT_MP_HIERARCHY_DOMINATION] 		= PROPERTY_MEDAL_HIERARCHY_DOMINATION,
		[ACHIEVEMENT_MP_CUSTOMIZATION_MADE_EASY]	= PROPERTY_MEDAL_CUSTOMIZATION_MADE_EASY,
	}
	-- Thresholds can be found in the Achievements and Medals document (see Joe Howes)
	MEDAL_STAT_REQUEST_THRESHOLDS = {
		[PROPERTY_MEDAL_CANT_STOP_NOVUS]				= 5,
		[PROPERTY_MEDAL_WHIRLING_DERVISH]			= 100,
		[PROPERTY_MEDAL_THE_POWER_MUST_FLOW]		= 50,
		[PROPERTY_MEDAL_PURE_OHMAGE]					= 5,
		[PROPERTY_MEDAL_DARK_MATTER_FTW]				= 4,
		[PROPERTY_MEDAL_BLINDED_BY_THE_LIGHT]		= 4,
		[PROPERTY_MEDAL_THE_SACRED_COW]				= 200,
		[PROPERTY_MEDAL_PEACE_THROUGH_POWER]		= 3,
		[PROPERTY_MEDAL_MUTATION_MADNESS]			= 3,
		[PROPERTY_MEDAL_TECHNOLOGICAL_TERROR]		= 3,
		[PROPERTY_MEDAL_RESEARCH_IS_KEY]				= 5,
		[PROPERTY_MEDAL_TIME_MEANS_NOTHING]			= 5,
		[PROPERTY_MEDAL_HIERARCHY_DOMINATION]		= 5,
		[PROPERTY_MEDAL_CUSTOMIZATION_MADE_EASY]	= 3,
	}


	-- ********* GUI INIT **************
	PGLobby_Init_Modal_Message(Achievement_Display)
	DialogShowing = true
	CurrentFaction = Get_Last_Current_Faction()
	AppliedMedalsModel = Create_Empty_Applied_Medals_Model()

	Achievement_Display.Set_Bounds(0, 0, 1, 1)

	-- Texture References
	AppliedMedals = {}		-- Binds the applied quads to medals.
	SharedMedals = {}		-- Binds the shared quads to medals.
	FactionMedals = {}		-- Binds the faction-specific quads to medals.
	AllMedals = {}			-- All of 'em together.
	MasterMedals = {}		-- Lookup table of all the above.
	VanityStatsView = VANITY_STATS_VIEW_RANKED
	VanityStatsReports = {
		[VANITY_STATS_VIEW_RANKED] = "",
		[VANITY_STATS_VIEW_UNRANKED] = ""
	}
	ProgressStats = nil
	ProfileAchievementsCounter = 0
	ProfileMedalsProgressCounter = 0
	NumMedalsUnlocked = 5			-- Everyone starts off with 5 medals.  This will be updated when the backend returns data.
	VanityStatsCache = {}

	-- Initialize the offline achievements box
	ACHIEVEMENT_LIST_ICON = Create_Wide_String("ACHIEVEMENT_LIST_ICON")
	ACHIEVEMENT_LIST_NAME = Create_Wide_String("ACHIEVEMENT_LIST_NAME")
	ACHIEVEMENT_LIST_PROGRESS = Create_Wide_String("ACHIEVEMENT_LIST_PROGRESS") 
	ACHIEVEMENT_LIST_BUFF_DESC = Create_Wide_String("ACHIEVEMENT_LIST_BUFF_DESC")

	-- Event handlers
	--Achievement_Display.Register_Event_Handler("Closing_All_Displays", nil, Close_Dialog)

	-- Tab order.
	Achievement_Display.Button_Back.Set_Tab_Order(Declare_Enum(0))
	
	-- Manual events.
	Achievement_Display.Register_Event_Handler("Key_Focus_Lost", nil, On_Focus_Lost)
	Achievement_Display.Register_Event_Handler("Key_Focus_Gained", nil, On_Focus_Gained)
	Achievement_Display.Register_Event_Handler("Drag_Drop", nil, On_Applied_Quad_Drop)
	Achievement_Display.Register_Event_Handler("On_YesNoOk_Yes_Clicked", nil, On_YesNoOk_Yes_Clicked)
	Achievement_Display.Register_Event_Handler("On_YesNoOk_Ok_Clicked", nil, On_YesNoOk_Ok_Clicked)

	-- Model initialization.
	Load_Applied_Medal_Settings()
	Initialize_Texture_Reference_Models()
	Setup_Mouse_Pointers()

	-- Misc.
	Load_Vanity_Stats()
	Achievement_Display.Focus_First()
	Refresh_View()
	
	-- Request achievement data from the backend.
	Register_For_Network_Events(CONNECTION_TYPE_INTERNET)
	-- JOE TEXT: TEXT_MULTIPLAYER_DOWNLOADING_PROFILE_DATA
	if (MEDALS_BETA_FLAG) then
		PGAchievement_Merge_Live_Backend_Data(OnlineAchievementsModel, OnlineAchievementsModel)
		Refresh_View()
	else
		PGLobby_Display_Custom_Modal_Message("TEXT_MULTIPLAYER_DOWNLOADING_PROFILE_DATA", "", "TEXT_BUTTON_CANCEL", "")
		Request_Achievement_Data()
	end
	Activate_Movies()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()
	PGCrontab_Update()
end

------------------------------------------------------------------------
-- On_Mouse_Over_Button - Play SFX response
------------------------------------------------------------------------
function On_Mouse_Over_Button(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- On_Button_Pushed - Play SFX response
------------------------------------------------------------------------
function On_Button_Pushed(event, source)
	if source and source.Is_Enabled() == true then 
		if source == this.Button_Back then
			-- Play SFX response
			Play_SFX_Event("GUI_Main_Menu_Back_Select")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
	end
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Initialize_Texture_Reference_Models()

	local medal_chooser = Achievement_Display.Medal_Chooser
	local panel_progress = Achievement_Display.Panel_Progress
	
	-- Applied Medals
	AppliedMedals = {}
	table.insert(AppliedMedals, medal_chooser.Quad_Buff0_Texture)
	table.insert(AppliedMedals, medal_chooser.Quad_Buff1_Texture)
	table.insert(AppliedMedals, medal_chooser.Quad_Buff2_Texture)

	-- Shared Medals
	SharedMedals = {}
	table.insert(SharedMedals, medal_chooser.Quad_Medal0_Texture)
	table.insert(SharedMedals, medal_chooser.Quad_Medal1_Texture)
	table.insert(SharedMedals, medal_chooser.Quad_Medal2_Texture)
	table.insert(SharedMedals, medal_chooser.Quad_Medal3_Texture)
	table.insert(SharedMedals, medal_chooser.Quad_Medal4_Texture)
	
	-- Faction Medals
	FactionMedals = {}
	table.insert(FactionMedals, medal_chooser.Quad_Medal5_Texture)
	table.insert(FactionMedals, medal_chooser.Quad_Medal6_Texture)
	table.insert(FactionMedals, medal_chooser.Quad_Medal7_Texture)
	table.insert(FactionMedals, medal_chooser.Quad_Medal8_Texture)
	table.insert(FactionMedals, medal_chooser.Quad_Medal9_Texture)
	table.insert(FactionMedals, medal_chooser.Quad_Medal10_Texture)
	table.insert(FactionMedals, medal_chooser.Quad_Medal11_Texture)

	-- ALL the above in one table for easy iteration.
	AllMedals = {}
	table.insert(AllMedals, medal_chooser.Quad_Buff0_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Buff1_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Buff2_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal0_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal1_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal2_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal3_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal4_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal5_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal6_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal7_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal8_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal9_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal10_Texture)
	table.insert(AllMedals, medal_chooser.Quad_Medal11_Texture)
	
	-- Master Medals - A quad name -> pair lookup.
	MasterMedals = {}
	Store_Medal(MasterMedals, medal_chooser.Quad_Buff0_Texture, true)
	Store_Medal(MasterMedals, medal_chooser.Quad_Buff1_Texture, true)
	Store_Medal(MasterMedals, medal_chooser.Quad_Buff2_Texture, true)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal0_Texture, false)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal1_Texture, false)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal2_Texture, false)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal3_Texture, false)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal4_Texture, false)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal5_Texture, false, panel_progress.Progress_0, panel_progress.Progress_Text_0)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal6_Texture, false, panel_progress.Progress_1, panel_progress.Progress_Text_1)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal7_Texture, false, panel_progress.Progress_2, panel_progress.Progress_Text_2)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal8_Texture, false, panel_progress.Progress_3, panel_progress.Progress_Text_3)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal9_Texture, false, panel_progress.Progress_4, panel_progress.Progress_Text_4)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal10_Texture, false, panel_progress.Progress_5, panel_progress.Progress_Text_5)
	Store_Medal(MasterMedals, medal_chooser.Quad_Medal11_Texture, false, panel_progress.Progress_6, panel_progress.Progress_Text_6)
	
	-- Progress Bars
	ProgressBars = {}
	table.insert(ProgressBars, panel_progress.Progress_0)
	table.insert(ProgressBars, panel_progress.Progress_1)
	table.insert(ProgressBars, panel_progress.Progress_2)
	table.insert(ProgressBars, panel_progress.Progress_3)
	table.insert(ProgressBars, panel_progress.Progress_4)
	table.insert(ProgressBars, panel_progress.Progress_5)
	table.insert(ProgressBars, panel_progress.Progress_6)

	-- Progress Text
	ProgressText = {}
	table.insert(ProgressText, panel_progress.Progress_Text_0)
	table.insert(ProgressText, panel_progress.Progress_Text_1)
	table.insert(ProgressText, panel_progress.Progress_Text_2)
	table.insert(ProgressText, panel_progress.Progress_Text_3)
	table.insert(ProgressText, panel_progress.Progress_Text_4)
	table.insert(ProgressText, panel_progress.Progress_Text_5)
	table.insert(ProgressText, panel_progress.Progress_Text_6)
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Setup_Mouse_Pointers()

	for _, quad in ipairs(SharedMedals) do
		quad.Set_Mouse_Pointer(POINTER_CAN_GRAB)
	end

	for _, quad in ipairs(FactionMedals) do
		local dao = MasterMedals[quad.Get_Name()]
		local can_grab = Is_Medal_Achieved(dao.Achievement)
		if (can_grab) then
			quad.Set_Mouse_Pointer(POINTER_CAN_GRAB)
		else
			quad.Set_Mouse_Pointer(POINTER_NORMAL)
		end
	end

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Store_Medal(store, quad, is_applied_quad, progress_bar, progress_text)
	local dao = { 
		Quad = quad, 
		Achievement = nil, 
		IsAppliedQuad = is_applied_quad, 
		ProgressBar = progress_bar,
		ProgressText = progress_text
	}
	store[dao.Quad.Get_Name()] = dao
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Cleanup_Dialog()
	PGLobby_Set_Dialog_Is_Hidden(true)
	DialogShowing = false
	ProfileAchievementsCounter = 0
	ProfileMedalsProgressCounter = 0
	Unregister_For_Network_Events()
	Passivate_Movies()
	PGLobby_Hide_Modal_Message()
	this.Get_Containing_Scene().Raise_Event_Immediate("Heavyweight_Child_Scene_Closing", nil, {})
	this.Get_Containing_Scene().Raise_Event_Immediate("Medal_Chest_Closing", nil, {})
	Achievement_Display.End_Modal()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Close_Dialog(event, source, key)
	Achievement_Display.Get_Containing_Component().Set_Hidden(true)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()

	PGLobby_Set_Dialog_Is_Hidden(false)
	ProfileAchievementsCounter = 0
	ProfileMedalsProgressCounter = 0
	
	Register_For_Network_Events(CONNECTION_TYPE_INTERNET)
	
	-- Request achievement data from the backend.
	-- JOE TEXT: TEXT_MULTIPLAYER_DOWNLOADING_PROFILE_DATA
	ProgressStats = nil
	if (MEDALS_BETA_FLAG) then
		PGAchievement_Merge_Live_Backend_Data(OnlineAchievementsModel, OnlineAchievementsModel)
		Refresh_View()
	else
		PGLobby_Display_Custom_Modal_Message("TEXT_MULTIPLAYER_DOWNLOADING_PROFILE_DATA", "", "TEXT_BUTTON_CANCEL", "")
		Request_Achievement_Data()
	end
	
	CurrentFaction = Get_Last_Current_Faction()
	Achievement_Display.Start_Modal()
	DialogShowing = true
	Load_Applied_Medal_Settings()
	Achievement_Common_Init(ShowUnachievedAchievements)
	Initialize_Texture_Reference_Models()
	Load_Vanity_Stats()
	Refresh_View()
	Activate_Movies()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	Cleanup_Dialog()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_All_Clicked()
	-- Currently we don't want to do anything.
	--[[CurrentFaction = PG_FACTION_ALL
	Set_Profile_Value(PP_LAST_MEDAL_CHEST_FACTION, CurrentFaction)
	Refresh_View()--]]
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Novus_Clicked()
	CurrentFaction = PG_FACTION_NOVUS
	Set_Profile_Value(PP_LAST_MEDAL_CHEST_FACTION, CurrentFaction)
	Refresh_View()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Alien_Clicked()
	CurrentFaction = PG_FACTION_ALIEN
	Set_Profile_Value(PP_LAST_MEDAL_CHEST_FACTION, CurrentFaction)
	Refresh_View()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Masari_Clicked()
	CurrentFaction = PG_FACTION_MASARI
	Set_Profile_Value(PP_LAST_MEDAL_CHEST_FACTION, CurrentFaction)
	Refresh_View()
end

-------------------------------------------------------------------------------
-- Back button
-------------------------------------------------------------------------------
function On_Back_Clicked(event_name, source)
	Close_Dialog()
	if (Achievement_Display ~= nil) then
		Achievement_Display.Get_Containing_Component().Set_Hidden(true)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_View()

	--Net.Get_Gamer_Picture(Achievement_Display.Faction_Chooser.Quad_All_Icon)
	local desc = Create_Wide_String()
	local username = Network_Get_Local_Username()
	desc.assign(username)
	
	local report = Get_Current_Vanity_Stats_Report()
	Achievement_Display.Faction_Chooser.Text_Breakdown.Set_Text(report)

	if (VanityStatsView == VANITY_STATS_VIEW_RANKED) then
		Achievement_Display.Faction_Chooser.Ranked_Highlight.Set_Hidden(false)
		Achievement_Display.Faction_Chooser.Unranked_Highlight.Set_Hidden(true)
	elseif (VanityStatsView == VANITY_STATS_VIEW_UNRANKED) then
		Achievement_Display.Faction_Chooser.Ranked_Highlight.Set_Hidden(true)
		Achievement_Display.Faction_Chooser.Unranked_Highlight.Set_Hidden(false)
	end
	
	Refresh_Medals()
	Setup_Mouse_Pointers()
	Update_Medal_Details(nil)
	
	if (CurrentFaction == PG_FACTION_ALL) then
		
	elseif (CurrentFaction == PG_FACTION_NOVUS) then
	
		Achievement_Display.Faction_Chooser.Quad_Faction_Icon.Set_Texture(PGFactionTextures[PG_FACTION_NOVUS])
		
		Achievement_Display.Faction_Chooser.Novus_Highlight.Set_Hidden(false)
		Achievement_Display.Faction_Chooser.Hierarchy_Highlight.Set_Hidden(true)
		Achievement_Display.Faction_Chooser.Masari_Highlight.Set_Hidden(true)
		
	elseif (CurrentFaction == PG_FACTION_ALIEN) then
	
		Achievement_Display.Faction_Chooser.Quad_Faction_Icon.Set_Texture(PGFactionTextures[PG_FACTION_ALIEN])
		
		Achievement_Display.Faction_Chooser.Novus_Highlight.Set_Hidden(true)
		Achievement_Display.Faction_Chooser.Hierarchy_Highlight.Set_Hidden(false)
		Achievement_Display.Faction_Chooser.Masari_Highlight.Set_Hidden(true)
		
	elseif (CurrentFaction == PG_FACTION_MASARI) then
	
		Achievement_Display.Faction_Chooser.Quad_Faction_Icon.Set_Texture(PGFactionTextures[PG_FACTION_MASARI])
		
		Achievement_Display.Faction_Chooser.Novus_Highlight.Set_Hidden(true)
		Achievement_Display.Faction_Chooser.Hierarchy_Highlight.Set_Hidden(true)
		Achievement_Display.Faction_Chooser.Masari_Highlight.Set_Hidden(false)
		
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Current_Vanity_Stats_Report()
	return VanityStatsReports[VanityStatsView]
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_Medals()

	-- Clear everything (does not affect display).
	for _, quad in ipairs(AllMedals) do
		local dao = MasterMedals[quad.Get_Name()]
		dao.Achievement = nil
		if (CurrentFaction == PG_FACTION_ALL) then
			Set_Quad_Alpha(quad, 0.25)
		else
			Set_Quad_Alpha(quad, 1.0)
		end
	end
	
	-- Reset the progress bars
	for _, progress in ipairs(ProgressBars) do
		progress.Set_Hidden(true)
		progress.Set_Filled(0)
	end
	
	-- Reset the progress text
	for _, progress_text in ipairs(ProgressText) do
		progress_text.Set_Text("")
	end
	
	-- *** APPLIED ***
	local quad_lookup = AppliedMedalsModel[CurrentFaction] 
	if (quad_lookup ~= nil) then
		for quad_name, map in pairs(quad_lookup) do
			local master_medal_map = MasterMedals[quad_name]
			master_medal_map.Achievement = OnlineAchievementsModel[map.AchievementId]
		end
	end
	
	-- *** SHARED / FACTION ***
	-- Bind achievements to medal textures.
	local shared_index = 1
	local faction_index = 1
	for _, achievement in pairs(OnlineAchievementsModel) do

		-- Which model are we looking at?
		local model = nil
		local quad_name = nil
		if (achievement.Faction == CurrentFaction) then
		
			if (faction_index > #FactionMedals) then
				DebugMessage("LUA_ACHIEVEMENTS: ERROR: We do not have enough quads to display all medals for this faction.") 
			else
				model = FactionMedals
				quad_name = model[faction_index].Get_Name()
				faction_index = faction_index + 1
			end
			
		elseif (achievement.Faction == PG_FACTION_ALL) then
		
			if (shared_index > #SharedMedals) then
				DebugMessage("LUA_ACHIEVEMENTS: ERROR: We do not have enough quads to display all shared medals.") 
			else
				model = SharedMedals
				quad_name = model[shared_index].Get_Name()
				shared_index = shared_index + 1
			end
			
		end
		
		-- If this medal is a faction-specific medal that differs from the currently viewed faction,
		-- or there are not enough quads in the display given the model we're trying to present, ignore it.
		if (model ~= nil) then
			local dao = MasterMedals[quad_name]
			dao.Achievement = achievement
		end

	end
	
	-- Display the correct textures  and progress across the board.
	for key, dao in pairs(MasterMedals) do
	
		-- If there is an achievement dao bound to the quad, set it's texture.
		if (dao.Achievement == nil) then
			dao.Quad.Set_Texture(NO_MEDAL_TEXTURE)
		else
			dao.Quad.Set_Texture(dao.Achievement.Texture)
		end
		
		local is_medal_achieved = Is_Medal_Achieved(dao.Achievement)
		
		-- If this is an applied medal or an achieved medal, give it full alpha, otherwise grey it out.
		dao.Quad.Set_Render_Mode(ALPRIM_ALPHA)
		if (dao.IsAppliedQuad and (dao.Achievement ~= nil)) then
			Set_Quad_Alpha(dao.Quad, 1.0)
		elseif (dao.IsAppliedQuad and (dao.Achievement == nill)) then
			Set_Quad_Alpha(dao.Quad, 0.0)
		elseif (dao.Achievement ~= nil) then
			if (is_medal_achieved) then
				Set_Quad_Alpha(dao.Quad, 1.0)
			else
				Set_Quad_Alpha(dao.Quad, 0.5)
				dao.Quad.Set_Render_Mode(ALPRIM_ALPHA_GRAYSCALE)
			end
		end
		
		-- If there is a progress bar associated with this medal, update it.
		if ((dao.ProgressBar ~= nil) and 						-- This quad is tied to a progress bar.
			(ProgressStats ~= nil) and							-- Stats are back from the server.
			(dao.Achievement ~= nil) and						-- There is an achievement bound to the quad.
			(dao.Achievement.Faction ~= PG_FACTION_ALL)) then	-- The achievement is faction-specific.
		
			local enable_medal = Is_Medal_Achieved(dao.Achievement)
			local normalized_progress = 0
			local progress_text_numerator = 0
			local progress_text_denominator = 1
			
			-- Is there a progress property associated?
			local property_id = INCREMENT_MEDAL_LOOKUP[dao.Achievement.Id]
			if (property_id ~= nil) then
			
				local progress = ProgressStats[property_id]
				local threshold = MEDAL_STAT_REQUEST_THRESHOLDS[property_id]
				normalized_progress = progress / threshold
				if (normalized_progress < 0) then
					normalized_progress = 0
				elseif (normalized_progress > 1) then
					normalized_progress = 1
				end
				progress_text_numerator = progress
				progress_text_denominator = threshold
				
			else	
			
				--progress_text_numerator = nil
					
				if (enable_medal) then
					normalized_progress = 1
				else
					normalized_progress = 0
				end

			end
			
			-- Set the bar progress.
			if (is_medal_achieved or (normalized_progress <= 0) or (normalized_progress >= 1)) then
				dao.ProgressBar.Set_Hidden(true)
			else
				dao.ProgressBar.Set_Hidden(false)
				dao.ProgressBar.Set_Filled(normalized_progress)
			end
			
			-- Set the fraction text.
			if (enable_medal or (progress_text_numerator == nil) or (progress_text_denominator == nil)) then
				dao.ProgressText.Set_Text("")
			else
				progress_text_numerator = Get_Localized_Formatted_Number(progress_text_numerator)
				progress_text_denominator = Get_Localized_Formatted_Number(progress_text_denominator)
				local message = Create_Wide_String("")
				message.append(progress_text_numerator)
				message.append("/")
				message.append(progress_text_denominator)
				dao.ProgressText.Set_Text(message)
			end
			
		end
		
		-- Hide progress in Beta
		if ((dao.ProgressBar ~= nil) and MEDALS_BETA_FLAG) then
			dao.ProgressBar.Set_Hidden(true)	
		end
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_Gained(event, source, key)
	if (source ~= nil) then
		-- JOE DBG::::  Have to pulse these!! source.Set_Focus_State(true)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_Lost(event, source, key)
	if (source ~= nil) then
		-- JOE DBG::::  Have to pulse these!! source.Set_Focus_State(false)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Button_Ranked_Clicked()
	VanityStatsView = VANITY_STATS_VIEW_RANKED
	Refresh_View()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Button_Unranked_Clicked()
	VanityStatsView = VANITY_STATS_VIEW_UNRANKED
	Refresh_View()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Mouseover(event, source, key)

	local pair = MasterMedals[source.Get_Name()]
	if (pair.Achievement ~= nil) then
		Set_Medal_Highlight(pair, true)
	else
		Set_Medal_Highlight(pair, false)
	end
		
	Play_SFX_Event("GUI_Generic_Mouse_Over")	
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Mouseout(event, source, key)

	local pair = MasterMedals[source.Get_Name()]
	
	Set_Medal_Highlight(pair, false)
	--pair.Quad.Set_Render_Mode(ALPRIM_ALPHA)
	Update_Medal_Details(nil)
	--this.Set_Mouse_Pointer(POINTER_NORMAL)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Clicked(event, source, key)
	-- Nothing for now.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Unapply_Medal(quad_name)
	AppliedMedalsModel[CurrentFaction][quad_name] = nil
	Save_Applied_Medal_Settings()
	Refresh_Medals()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Buff_Primary_Mouse_Up(event, source, key)
	local pair = MasterMedals[source.Get_Name()]
	if (pair.IsAppliedQuad) then
		Unapply_Medal(source.Get_Name())
		DragDropMedal = nil
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Buff_Drop(event, source, key)
	local pair = MasterMedals[source.Get_Name()]
	if (Medal_Is_Dragging() and pair.IsAppliedQuad) then
		End_Medal_Drag_Drop(pair)
	else
		pair.Achievement = nil	
		Refresh_Medals()
	end
	Play_SFX_Event("GUI_Generic_Drop")	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Applied_Quad_Drop(event, source, key)
	if (Medal_Is_Dragging() and DragDropMedal.IsAppliedQuad) then
		Unapply_Medal(DragDropMedal.Quad.Get_Name())
		DragDropMedal = nil
		Play_SFX_Event("GUI_Generic_Drop")	
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Primary_Mouse_Down(event, source, key)
	if (CurrentFaction == PG_FACTION_ALL) then
		return
	end
	local pair = MasterMedals[source.Get_Name()]
	local medal_enabled = Is_Medal_Achieved(pair.Achievement)
	if (medal_enabled) then
		source.Schedule_Drag(pair)
		Start_Medal_Drag_Drop(pair)
	end
	Play_SFX_Event("GUI_Generic_Drag")	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Buff_Mouse_Down(event, source, key)
	if (CurrentFaction == PG_FACTION_ALL) then
		return
	end
	local pair = MasterMedals[source.Get_Name()]
	local medal_enabled = Is_Medal_Achieved(pair.Achievement)
	if (pair.IsAppliedQuad and medal_enabled) then
		source.Schedule_Drag(pair)
		Start_Medal_Drag_Drop(pair)
	end
	Play_SFX_Event("GUI_Generic_Drag")	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Click() 
	Play_SFX_Event("GUI_Generic_Button_Select")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Alien_Steam() 
	Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Prepare_Fadeout()
	-- We can't call mapped functions from the GUI we have to go through this.
	Prepare_Fades()
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Updates the medal info tooltip.
-------------------------------------------------------------------------------
function Update_Medal_Details(achievement)

	local desc = Create_Wide_String()
	local status = Create_Wide_String()
	local req = Create_Wide_String("")

	if (achievement ~= nil) then
	
		local name = Get_Game_Text(achievement.Name)
		local buff_desc = Get_Game_Text(achievement.BuffDesc)

		desc.assign(name)
		desc.append(": ")
		desc.append(buff_desc)
		if (achievement.Faction ~= PG_FACTION_ALL) then
			local ach_req = Get_Game_Text(achievement.Requirements)
			req.append(Get_Game_Text("TEXT_ACHIEVEMENT_REQUIREMENTS"))
			req.append(": ")
			req.append(ach_req)
		end
		local medal_enabled = Is_Medal_Achieved(achievement)
		if (medal_enabled) then
			status = Get_Game_Text("TEXT_ACHIEVEMENT_STATUS_OPEN")
		else
			status = Get_Game_Text("TEXT_ACHIEVEMENT_STATUS_LOCKED")
		end
		
	end

	Achievement_Display.Achievement_Details.Text_Achievement_Desc.Set_Text(desc)
	Achievement_Display.Achievement_Details.Text_Achievement_Req.Set_Text(req)
	Achievement_Display.Achievement_Details.Text_Achievement_Status.Set_Text(status)

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Medal_Highlight(map, value)

	local render_mode = ALPRIM_ALPHA
	local achievement = nil
	
	if (value) then
		achievement = map.Achievement
	end
	Update_Medal_Details(achievement)
	
	if (map.Achievement ~= nil) then
	
		local medal_enabled = Is_Medal_Achieved(map.Achievement)
		if (medal_enabled) then
			if (value) then
				render_mode = ALPRIM_ADDITIVE
			else
				render_mode = ALPRIM_ALPHA
			end
			map.Quad.Set_Render_Mode(render_mode)
		end
		
	end
	
	--[[local achievement = nil
	if (value) then
		render_mode = ALPRIM_ADDITIVE
		achievement = map.Achievement
	else
		render_mode = ALPRIM_ALPHA
		achievement = nil
	end--]]
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Medal_Drag_Drop(map)
	if (map.Achievement ~= nil) then
		DragDropMedal = map
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function End_Medal_Drag_Drop(pair)

	if (DragDropMedal ~= nil) then
	
		local achievement_id = DragDropMedal.Achievement.Id
	
		-- Are we dragging from one applied quad to the other?
		if (DragDropMedal.IsAppliedQuad) then
		
			-- We're just moving the spot the medal is in.
			Unapply_Medal(DragDropMedal.Quad.Get_Name())
			
		else
		
			local not_applied, quad_name = Verify_Applied_Medal(DragDropMedal)
			
			if (not_applied == false) then
				Unapply_Medal(quad_name)
			end
			
		end
		
		Set_Applied_Medal_Data(achievement_id, pair)
		DragDropMedal = nil
		Save_Applied_Medal_Settings()
		Refresh_Medals()
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Medal_Is_Dragging()
	return (DragDropMedal ~= nil)
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Request_Achievement_Data()

	DebugMessage("LUA_LOBBY: Requesting achievement data from the backend.")
	local addr = Net.Get_Local_Addr()
	PGLobby_Request_Profile_Achievements(addr)
	ProfileAchievementsCounter = ProfileAchievementsCounter + 1
	PGLobby_Request_Medals_Progress_Stats(addr)
	ProfileMedalsProgressCounter = ProfileMedalsProgressCounter + 1
	PGCrontab_Schedule(Verify_Achievement_Data, 0, ACHIEVEMENT_VERIFY_INTERVAL)
	
end
		
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Verify_Achievement_Data()

	-- If we have waited ACHIEVEMENT_VERIFY_INTERVAL seconds and heard nothing from the server, we're
	-- hooped.
	if ((ProfileAchievementsCounter > 0) or (ProfileMedalsProgressCounter > 0)) then
		DebugMessage("LUA_LOBBY: Backend failed to deliver requested data.  Displaying error.")
		DebugMessage("LUA_LOBBY: ProfileAchievementsCounter: " .. tostring(ProfileAchievementsCounter))
		DebugMessage("LUA_LOBBY: ProfileMedalsProgressCounter: " .. tostring(ProfileMedalsProgressCounter))
		PGLobby_Display_Modal_Message("TEXT_COMMS_ERROR_GENERIC_02")
		return
	end
	
	DebugMessage("LUA_LOBBY: Backend successfully reported back achievement data.")
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Check_Backend_Request_Status()
	if ((ProfileAchievementsCounter <= 0) and (ProfileMedalsProgressCounter <= 0)) then
		PGLobby_Hide_Modal_Message()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_YesNoOk_Yes_Clicked()
	-- Currently do nothing
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_YesNoOk_Ok_Clicked()
	-- Currently do nothing
end

-------------------------------------------------------------------------------
-- Called when the backend has our achievement data ready for us.
-- Note that this call clobbers the OnlineAchievementsModel with status values
-- from the backend!
-------------------------------------------------------------------------------
function On_Enumerate_Achievements(event)

	-- If this is for anyone but the locally signed-in user, ignore it.
	local local_common_addr = Net.Get_Local_Addr()
	if (event.common_addr ~= local_common_addr) then
		DebugMessage("LUA_MEDAL_CHEST: Received achievement enumeration for someone else.  Ignoring...")
		Setup_Mouse_Pointers()
		return
	end
		
	DebugMessage("LUA_MEDAL_CHEST: Received achievement enumeration!!!")
	ProfileAchievementsCounter = ProfileAchievementsCounter - 1
	Check_Backend_Request_Status()
	
	if (MEDALS_BETA_FLAG) then
		return
	end

	if (event.type == NETWORK_EVENT_TASK_COMPLETE) then
	
		BackendStatus, NumMedalsUnlocked = PGAchievement_Merge_Live_Backend_Data(event.achievements, OnlineAchievementsModel)
		if (BackendStatus) then
			Refresh_View()
		else
			-- JOE TEXT: TEXT_ACHIEVEMENT_SERVER_PROBLEM 
			PGLobby_Display_Modal_Message("TEXT_COMMS_ERROR_GENERIC_02")
		end
		
	end
	
	Refresh_Vanity_Stats()
	Refresh_View()
	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Query_Medals_Progress_Stats(event)

	-- If this is for anyone but the locally signed-in user, ignore it.
	local local_common_addr = Net.Get_Local_Addr()
	local local_xuid = Net.Get_XUID_By_Network_Address(local_common_addr)
	if (event.xuid ~= local_xuid) then
		DebugMessage("LUA_MEDAL_CHEST: Received achievement progress stats for someone else.  Ignoring...")
		Setup_Mouse_Pointers()
		return
	end
		
	DebugMessage("LUA_MEDAL_CHEST: Received achievement progress stats!!!")
	ProfileMedalsProgressCounter = ProfileMedalsProgressCounter - 1
	Check_Backend_Request_Status()
	
	if (MEDALS_BETA_FLAG) then
		return
	end

	if (event.type == NETWORK_EVENT_TASK_COMPLETE) then
	
		ProgressStats = event.stats
		
		if (BackendStatus) then
			Refresh_View()
		end
		
	end
	
end	


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Quad_Alpha(quad, alpha)
	if (quad == nil) then
		return
	end
	quad.Set_Vertex_Color(0, 1, 1, 1, alpha)
	quad.Set_Vertex_Color(1, 1, 1, 1, alpha)
	quad.Set_Vertex_Color(2, 1, 1, 1, alpha)
	quad.Set_Vertex_Color(3, 1, 1, 1, alpha)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Achievement_Applied(achievement)

	for quad_name, map in pairs(AppliedMedalsModel[CurrentFaction]) do
		if (map.AchievementId == achievement.Id) then
			return true
		end
	end
	
	return false
	
end
			
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Last_Current_Faction()
	local current_faction = Get_Profile_Value(PP_LAST_MEDAL_CHEST_FACTION, PG_FACTION_NOVUS)
	if (current_faction == nil) then
		current_faction = PG_FACTION_ALL
	end
	return current_faction
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Verify_Applied_Medal(pair)

	for _, map in pairs(AppliedMedalsModel[CurrentFaction]) do
		if (map.AchievementId == pair.Achievement.Id) then
			-- This medal is already applied.
			return false, map.QuadName
		end
	end
	return true

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Create_Empty_Applied_Medals_Model()
	local model = {}
	model[PG_FACTION_ALL] = {}
	model[PG_FACTION_NOVUS] = {}
	model[PG_FACTION_ALIEN] = {}
	model[PG_FACTION_MASARI] = {}
	return model
end

-------------------------------------------------------------------------------
-- Set the data in the registry-safe AppliedMedalsModel.
-------------------------------------------------------------------------------
function Set_Applied_Medal_Data(achievement_id, dest_pair)
	
	-- Find the right data member, and change the achievement association.
	local map = AppliedMedalsModel[CurrentFaction][dest_pair.Quad.Get_Name()]
	if (map == nil) then
		map = {}
	end
	map.QuadName = dest_pair.Quad.Get_Name()
	map.AchievementId = achievement_id
	AppliedMedalsModel[CurrentFaction][dest_pair.Quad.Get_Name()] = map
	
end

-------------------------------------------------------------------------------
-- Persists the applied multiplayer medal settings to the registry.
-- When we persist a table to the registry, we CANNOT use map-style tables, 
-- only arrays, so we divorce data from display in this function by translating
-- the data stored in the map-driven AppliedMedalsModel and turning it into
-- a registry-safe array-driven table.
-------------------------------------------------------------------------------
function Save_Applied_Medal_Settings()

	local applied_medals = {}
	local index = 1

	for faction, quad_lookup in ipairs(AppliedMedalsModel) do
	
		local arr = {}
		applied_medals[faction] = arr
		
		-- Iterate through all the buff textures, saving off the associated achievements.
		--for _, data in ipairs(AppliedMedalsModel) do
		for quad_name, map in pairs(quad_lookup) do
		
			local data = {}
			data[1] = map.QuadName
			data[2] = map.AchievementId
			table.insert(arr, data)
	
		end
		
	end
	
	Set_Local_User_Applied_Medals(applied_medals)
	
end


-------------------------------------------------------------------------------
-- Loads the applied multiplayer medal settings from the registry.
-- When we persist a table to the registry, we CANNOT use map-style tables, 
-- only arrays, so we divorce data from display in this function by translating
-- the data stored in the map-driven AppliedMedalsModel and turning it into
-- a registry-safe array-driven table.
-------------------------------------------------------------------------------
function Load_Applied_Medal_Settings()

	AppliedMedalsModel = Create_Empty_Applied_Medals_Model()
	local applied_medals = Get_Local_User_Applied_Medals()
	
	if (#applied_medals == 0) then
		-- User hasn't set any applied medals.  Set up an empty model.
		return
	end
	
	-- Bind the textures to the specified medals in MasterMedals
	local index = 1
	
	-- Go through the applied medals for each faction.	
	for faction, array in ipairs(applied_medals) do
	
		AppliedMedalsModel[faction] = {}
		
		-- Each medal in the array is represented by a 2-element data table.
		for _, data in ipairs(array) do
	
			local map = {}
			map.QuadName = data[1]
			map.AchievementId = data[2]
			AppliedMedalsModel[faction][map.QuadName] = map
			
		end

	end
	
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Load_Vanity_Stats()

	VanityStatsCache = Net.Get_Vanity_Stats_Data()
	
	-- Stick in a couple stats that aren't filled in by the backend
	-- JLH 12/12/2007
	-- It is a TCR violation to store gamertags!
	--VanityStatsCache.ranked.last_opponent = Get_Profile_Value(PP_VANITY_LAST_RANKED_OPPONENT, WIDE_DOUBLE_DASH)
	--VanityStatsCache.unranked.last_opponent = Get_Profile_Value(PP_VANITY_LAST_UNRANKED_OPPONENT, WIDE_DOUBLE_DASH)
	VanityStatsCache.ranked.last_tournament_game = Get_Profile_Value(PP_VANITY_LAST_RANKED_MATCH_DATETIME, WIDE_DOUBLE_DASH)
	VanityStatsCache.unranked.last_tournament_game = Get_Profile_Value(PP_VANITY_LAST_UNRANKED_MATCH_DATETIME, WIDE_DOUBLE_DASH)
	VanityStatsCache.ranked.total_medals_unlocked = NumMedalsUnlocked
	VanityStatsCache.unranked.total_medals_unlocked = NumMedalsUnlocked
	
	VanityStatsReports[VANITY_STATS_VIEW_RANKED] = Prepare_Vanity_Report(VanityStatsCache.ranked)
	VanityStatsReports[VANITY_STATS_VIEW_UNRANKED] = Prepare_Vanity_Report(VanityStatsCache.unranked)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_Vanity_Stats()

	-- Stick in a couple stats that aren't filled in by the backend
	VanityStatsCache.ranked.total_medals_unlocked = NumMedalsUnlocked
	VanityStatsCache.unranked.total_medals_unlocked = NumMedalsUnlocked
	
	VanityStatsReports[VANITY_STATS_VIEW_RANKED] = Prepare_Vanity_Report(VanityStatsCache.ranked)
	VanityStatsReports[VANITY_STATS_VIEW_UNRANKED] = Prepare_Vanity_Report(VanityStatsCache.unranked)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Prepare_Vanity_Report(map)

	local report = Create_Wide_String("")
	
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TOTAL_MEDALS_UNLOCKED"), map.total_medals_unlocked)
	Append_Report_Time(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TIME_ONLINE"), (map.time_online))
	Append_Report_String(report)	-- Linefeed
	--Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_LEADER_BOARD_RANK"), map.leader_board_rank)
	Append_Report_String(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_LAST_TOURNAMENT_GAME"), map.last_tournament_game)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TOTAL_MATCHES_PLAYED"), map.matches_played)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_CAREER_WINS"), map.career_wins)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_CAREER_LOSSES"), map.career_losses)
	-- JLH 12/12/2007
	-- It is a TCR violation to store gamertags!
	--Append_Report_String(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_LAST_OPPONENT"), map.last_opponent)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_CURRENT_WIN_STREAK"), map.current_win_streak)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_LONGEST_WIN_STREAK"), map.longest_win_streak)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_LONGEST_LOSING_STREAK"), map.longest_losing_streak)
	Append_Report_Time(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_AVERAGE_GAME_LENGTH"), map.average_game_length)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TOTAL_UNITS_BUILT"), map.units_built)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TOTAL_UNITS_LOST"), map.units_lost)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TOTAL_STRUCTURES_BUILT"), map.structures_built)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_TOTAL_STRUCTURES_LOST"), map.structures_lost)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_HEROES_BUILT"), map.heroes_built)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_ENEMY_UNITS_DESTROYED"), map.enemy_units_destroyed)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_ENEMY_STRUCTURES_DESTROYED"), map.enemy_structures_destroyed)
	Append_Report_Number(report, Get_Game_Text("TEXT_MULTIPLAYER_VANITY_ENEMY_HEROES_DESTROYED"), map.enemy_heroes_destroyed)


	return report
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Append_Report_Number(report, stat_label, stat_value)

	if (stat_label == nil or stat_value == nil) then
		report = report.append(LINEFEED)
		return
	end
	
	if (stat_value == nil) then
		stat_value = Get_Localized_Formatted_Number(0)
	else
		stat_value = Get_Localized_Formatted_Number(stat_value)
	end
	
	report = report.append(stat_label).append(WIDE_STAT_SEPARATOR).append(stat_value).append(LINEFEED)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Append_Report_String(report, stat_label, stat_value)

	if (stat_label == nil or stat_value == nil) then
		report = report.append(LINEFEED)
		return
	end
	
	if (stat_value == nil) then
		stat_value = WIDE_DOUBLE_DASH
	end
	
	report = report.append(stat_label).append(WIDE_STAT_SEPARATOR).append(stat_value).append(LINEFEED)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Append_Report_Time(report, stat_label, stat_value)

	if (stat_label == nil or stat_value == nil) then
		report = report.append(LINEFEED)
		return
	end
	
	if (stat_value == nil) then
		stat_value = Get_Localized_Formatted_Number.Get_Time(0)
	else
		stat_value = Get_Localized_Formatted_Number.Get_Time(stat_value)
	end
	
	report = report.append(stat_label).append(WIDE_STAT_SEPARATOR).append(stat_value).append(LINEFEED)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Medal_Achieved(dao)
	if (MEDALS_BETA_FLAG) then
		return true
	end
	if ((dao ~= nil) and dao.Achieved) then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Activate_Movies()
	if (TestValid(this.Movie_1)) then
		this.Movie_1.Play()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Passivate_Movies()
	if (TestValid(this.Movie_1)) then
		this.Movie_1.Stop()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Showing()
	return DialogShowing
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Showing = Is_Showing

