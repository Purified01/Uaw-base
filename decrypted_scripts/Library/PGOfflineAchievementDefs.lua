LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGOfflineAchievementDefs.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGOfflineAchievementDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGAchievementsCommon")
require("PGFactions")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGOfflineAchievementDefs_Init()
	Init_Offline_Achievements()
	PGFactions_Init()
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A C H I E V E M E N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Offline_Achievements()

	PGAchievementsCommon_Init()


	-- ** IDs **
	--FIRST_NOVUS_MISSION_COMPLETE_ID		= Declare_Enum(1)
	
	TUT01_SCHOOLCHILDREN_RESCUED_ID		= Declare_Enum(1)
	OfflineAchievementStart				= TUT01_SCHOOLCHILDREN_RESCUED_ID
	BUILT_N_MARINE_SQUADS_ID			= Declare_Enum()
	KILLED_N_GREY_UNITS_ID				= Declare_Enum()
	OfflineAchievementEnd				= KILLED_N_GREY_UNITS_ID

	-- ** Offline Achievement Map **
	OfflineAchievementMap = _PG_Create_Base_Offline_Achievement_Map()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PG_Create_Base_Offline_Achievement_Map()

	-- ** Achievement Definitions **
	local map = {}
	local achievement


	-- FIRST_NOVUS_MISSION_COMPLETE
	--jdg 3/30/07 bastardizing to give achievement when schoolchildren are rescued
	achievement = Create_Base_Boolean_Achievement_Definition(TUT01_SCHOOLCHILDREN_RESCUED_ID, 
		PG_FACTION_ALL,
		false,
		"Think of the Children",
		"tmp_medal",
		"Rescue some school children.",
		"25% unit speed increase.",
		"Achievement_Effect_25_Percent_Speed_Increase")
	map[achievement.Id] = achievement;

	-- BUILT_N_BUILDINGS_IN_GAME_ID
	achievement = Create_Base_Achievement_Definition(BUILT_N_MARINE_SQUADS_ID,
		PG_FACTION_ALL,
		false,
		3,
		"Marine Strategist",
		"tmp_medal",
		"Build 3 marine squads.",
		"Constant health regeneration.",
		"Achievement_Effect_Constant_Health_Regenerate")
	map[achievement.Id] = achievement;

	-- KILLED_N_GREY_UNITS_ID
	achievement = Create_Base_Achievement_Definition(KILLED_N_GREY_UNITS_ID,
		PG_FACTION_ALL,
		false,
		3,
		"Grey Killer",
		"tmp_medal",
		"Kill 3 greys.",
		"Minor unit speed increase.",
		"Achievement_Effect_35_Percent_Speed_Increase")
	map[achievement.Id] = achievement;
	
	Set_Achievement_Map_Type(map, 1)
	
	return map

end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Localized_Faction_Name = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGOfflineAchievementDefs_Init = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
