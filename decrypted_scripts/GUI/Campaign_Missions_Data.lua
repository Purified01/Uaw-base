LUA_PREP = true

--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Campaign_Missions_Data.lua $
--
--    Original Author: Maria Teruel
--
--         DateTime: 2007/11/08
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGFactions")
require("PGCampaigns")
require("PGPlayerProfile")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function Init_Campaign_Missions_Data()
	
	PGFactions_Init()
	PGCampaigns_Init()
	PGPlayerProfile_Init_Constants()

	-- NOTE: PPKey = Player Profile Key (we need this to determine whether the mission has become available or not)
	
	Prelude_Missions = {}
	Prelude_Missions[PG_CAMPAIGN_MISSION_01] =
		{State = "State_Start_360Tutorial", Name = "TEXT_GAMEPAD_TUTORIAL00_NAME",
		 PPKey = PP_TUTORIAL_00_AVAILABLE, FactionID = PG_FACTION_NOVUS,
		 Description = "GAMEPAD_TEXT_SP_MISSION_360TUT_LOAD_SCREEN_TEXT"} -- first tutorial
	Prelude_Missions[PG_CAMPAIGN_MISSION_02] =
		{State = "State_Start_Tut01", Name = "TEXT_GAMEPAD_TUTORIAL01_NAME",
		 PPKey = PP_TUTORIAL_01_AVAILABLE, FactionID = PG_FACTION_MILITARY,
	 	 Description = "TEXT_SP_MISSION_TUT01_LOAD_SCREEN_TEXT"} -- first tutorial ... at capitol building
	Prelude_Missions[PG_CAMPAIGN_MISSION_03] =
		{State = "State_Start_Tut02", Name = "TEXT_GAMEPAD_TUTORIAL02_NAME",
		 PPKey = PP_TUTORIAL_02_AVAILABLE, FactionID = PG_FACTION_MILITARY,
	 	 Description = "TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT"} -- second tutorial ... at military base south of Capitol Building
	
	Novus_Missions = {}
	Novus_Missions[PG_CAMPAIGN_MISSION_01] =
		{State = "State_Start_NM01_Dialogue", Name = "TEXT_GAMEPAD_NM01_NAME",
		 PPKey = PP_NOVUS_MISSION_01_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = nil} --first Novus mission -- near the pyramids
	Novus_Missions[PG_CAMPAIGN_MISSION_02] =
		{State = "State_Start_NM02_Dialogue", Name = "TEXT_GAMEPAD_NM02_NAME",
		 PPKey = PP_NOVUS_MISSION_02_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = nil} -- second Novus mission -- in England
	Novus_Missions[PG_CAMPAIGN_MISSION_03] =
		{State = "State_Start_NM03_Dialogue", Name = "TEXT_GAMEPAD_NM03_NAME",
		 PPKey = PP_NOVUS_MISSION_03_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = nil} -- third novus -- Siberia
	Novus_Missions[PG_CAMPAIGN_MISSION_04] =
		{State = "State_Start_NM04_Dialogue", Name = "TEXT_GAMEPAD_NM04_NAME",
		 PPKey = PP_NOVUS_MISSION_04_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = nil} -- forth Novus -- TBD
	Novus_Missions[PG_CAMPAIGN_MISSION_05] =
		{State = "State_Start_NM05_Dialogue", Name = "TEXT_GAMEPAD_NM05_NAME",
		 PPKey = PP_NOVUS_MISSION_05_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = nil} -- fifth Novus -- South Africa
	Novus_Missions[PG_CAMPAIGN_MISSION_06] =
		{State = "State_Start_NM06_Dialogue", Name = "TEXT_GAMEPAD_NM06_NAME",
		 PPKey = PP_NOVUS_MISSION_06_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = nil} -- sixth Novus -- ZRH interior
	Novus_Missions[PG_CAMPAIGN_MISSION_07] =
		{State = "State_Start_NM07", Name = "TEXT_GAMEPAD_NM07_NAME",
		 PPKey = PP_NOVUS_MISSION_07_AVAILABLE, FactionID = PG_FACTION_NOVUS,
	 	 Description = "TEXT_SP_MISSION_NVS07_LOAD_SCREEN_TEXT"} -- Seventh Novus -- NM01 map ... near the pyramids
		
	Hierarchy_Missions = {}
	Hierarchy_Missions[PG_CAMPAIGN_MISSION_01] =
		{State = "State_Start_ZM01", Name = "TEXT_GAMEPAD_HM01_NAME",
		 PPKey = PP_HIERARCHY_MISSION_01_AVAILABLE, FactionID = PG_FACTION_ALIEN,
	 	 Description = "TEXT_SP_MISSION_HIE01_LOAD_SCREEN_TEXT"} -- first Hierarchy mission: (16) Sahara (Pyramids of Giza)
	Hierarchy_Missions[PG_CAMPAIGN_MISSION_02] =
		{State = "State_Start_ZM02_Dialogue", Name = "TEXT_GAMEPAD_HM02_NAME",
		 PPKey = PP_HIERARCHY_MISSION_02_AVAILABLE, FactionID = PG_FACTION_ALIEN,
	 	 Description = nil} -- second Hierarchy mission: (23) Gulf Coast (Florida)
	Hierarchy_Missions[PG_CAMPAIGN_MISSION_03] =
		{State = "State_Start_ZM03_Dialogue", Name = "TEXT_GAMEPAD_HM03_NAME",
		 PPKey = PP_HIERARCHY_MISSION_03_AVAILABLE, FactionID = PG_FACTION_ALIEN,
	 	 Description = nil} -- third Hierarchy mission: (22) Atlantic Ocean (Atlatea)
	Hierarchy_Missions[PG_CAMPAIGN_MISSION_04] =
		{State = "State_Start_ZM04_Dialogue", Name = "TEXT_GAMEPAD_HM04_NAME",
		 PPKey = PP_HIERARCHY_MISSION_04_AVAILABLE, FactionID = PG_FACTION_ALIEN,
	 	 Description = nil} -- forth Hierarchy mission: (30) Altiplano
	Hierarchy_Missions[PG_CAMPAIGN_MISSION_05] =
		{State = "State_Start_ZM05_Dialogue", Name = "TEXT_GAMEPAD_HM05_NAME",
		 PPKey = PP_HIERARCHY_MISSION_05_AVAILABLE, FactionID = PG_FACTION_ALIEN,
	 	 Description = nil} -- fifth Hierarchy mission: (13) Indochina (Masari Temple)
	Hierarchy_Missions[PG_CAMPAIGN_MISSION_06] =
		{State = "State_Start_ZM06", Name = "TEXT_GAMEPAD_HM06_NAME",
		 PPKey = PP_HIERARCHY_MISSION_06_AVAILABLE, FactionID = PG_FACTION_ALIEN,
	 	 Description = "TEXT_SP_MISSION_HIE06_LOAD_SCREEN_TEXT"} -- sixth Hierarchy mission: (35) Central America (Arecibo, Puerto Rico)
	
	Masari_Missions = {}
	Masari_Missions[PG_CAMPAIGN_MISSION_01] =
		{State = "State_Start_MM01", Name = "TEXT_GAMEPAD_MM01_NAME",
		 PPKey = PP_MASARI_MISSION_01_AVAILABLE, FactionID = PG_FACTION_MASARI,
	 	 Description = "TEXT_SP_MISSION_MAS01_LOAD_SCREEN_TEXT"} 
	Masari_Missions[PG_CAMPAIGN_MISSION_02] =
		{State = "State_Start_Global", Name = "TEXT_GAMEPAD_MMGL_NAME",
		 PPKey = PP_MASARI_GLOBAL_MISSION_AVAILABLE, FactionID = PG_FACTION_MASARI,
	 	 Description = "TEXT_SP_MISSION_MAS02_LOAD_SCREEN_TEXT"} -- Global Game
	Masari_Missions[PG_CAMPAIGN_MISSION_03] =
		{State = "State_Start_MM07", Name = "TEXT_GAMEPAD_MM07_NAME",
		 PPKey = PP_MASARI_MISSION_07_AVAILABLE, FactionID = PG_FACTION_MASARI,
	 	 Description = "TEXT_SP_MISSION_MAS10_LOAD_SCREEN_TEXT"}
	
	Missions = { }
	Missions[PG_CAMPAIGN_PRELUDE] = Prelude_Missions
	Missions[PG_CAMPAIGN_NOVUS] = Novus_Missions
	Missions[PG_CAMPAIGN_ALIEN] = Hierarchy_Missions
	Missions[PG_CAMPAIGN_MASARI] = Masari_Missions

	Campaign_Name = { }
	Campaign_Name[PG_CAMPAIGN_PRELUDE] = "TUTORIAL_Story_Campaign"
	Campaign_Name[PG_CAMPAIGN_NOVUS] = "NOVUS_Story_Campaign"
	Campaign_Name[PG_CAMPAIGN_ALIEN] = "Hierarchy_Story_Campaign"
	Campaign_Name[PG_CAMPAIGN_MASARI] = "MASARI_Story_Campaign"
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Commit_Profile_Values = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Localized_Faction_Name = nil
	Init_Campaign_Missions_Data = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGPlayerProfile_Init = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
