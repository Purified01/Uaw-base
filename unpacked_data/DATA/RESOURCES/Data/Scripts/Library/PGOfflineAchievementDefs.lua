-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGOfflineAchievementDefs.lua#12 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGOfflineAchievementDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 68901 $
--
--          $DateTime: 2007/04/26 11:14:15 $
--
--          $Revision: #12 $
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
	
	Set_Achievement_Map_Type(map, OFFLINE_ACHIEVEMENT)
	
	return map

end


