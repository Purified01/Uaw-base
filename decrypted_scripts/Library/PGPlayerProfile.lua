if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[193] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGPlayerProfile.lua#24 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGPlayerProfile.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #24 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

function PGPlayerProfile_Init()
	PGPlayerProfile_Init_Constants()
	
	-- [6/12/2007 JLH]:  Nuke deprecated keys.  This can be deleted any time...
	if (PlayerProfile ~= nil) then
		PlayerProfile.Set_Value(PP_NAME, "")
		PlayerProfile.Set_Value(PP_PASSWORD, "")
		PlayerProfile.Set_Value(PP_LAST_GAME_NAME, "")
		PlayerProfile.Set_Value(PP_LAST_MAP, "")
		PlayerProfile.Set_Value(PP_LAST_FACTION, "")
		--PlayerProfile.Set_Value(PP_LAST_CHAT_NAME, "")
		--PlayerProfile.Set_Value(PP_COLOR_INDEX, "")   not deprecated anymore
		PlayerProfile.Set_Value(PP_TEAM, "")
	end
	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- C O N S T A N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PGPlayerProfile_Init_Constants()

	-- ******** IMPORTANT NOTE *******
	-- This function is often called from contexts where the PlayerProfile code object has
	-- not been exposed to script, so ** DO NOT ASSUME THE PlayerProfile OBJECT IS AVAILABLE **.

	-- *** KEYS ***
	-- ALL these keys need to be found in PlayerProfile.cpp (starting at line 139)
	-- if you add to this list you MUST add it to the PlayerProfile.cpp in two places
	-- #define it first with the same string as you have on the right
	-- then add to the RegistryKeyNames array for the xbox to work
	
	-- Multiplayer Lobby
	PP_LOBBY_PLAYER_FACTION								= "PP_LOBBY_PLAYER_FACTION"
	PP_LOBBY_PLAYER_TEAM								= "PP_LOBBY_PLAYER_TEAM"
	PP_LOBBY_PLAYER_COLOR								= "PP_LOBBY_PLAYER_COLOR"
	PP_COLOR_INDEX											= "PP_COLOR_INDEX"
	PP_LOBBY_HOST_MAP									= "PP_LOBBY_HOST_MAP"
	PP_LOBBY_HOST_WIN_CONDITION							= "PP_LOBBY_HOST_WIN_CONDITION"
	PP_LOBBY_HOST_DEFCON								= "PP_LOBBY_HOST_DEFCON"
	PP_LOBBY_HOST_ALLIANCES								= "PP_LOBBY_HOST_ALLIANCES"
	PP_LOBBY_HOST_OBSERVER								= "PP_LOBBY_HOST_OBSERVER"
	PP_LOBBY_HOST_ACHIEVEMENTS							= "PP_LOBBY_HOST_ACHIEVEMENTS"
	PP_LOBBY_HOST_HERO_RESPAWN							= "PP_LOBBY_HOST_HERO_RESPAWN"
	PP_LOBBY_HOST_STARTING_CREDITS						= "PP_LOBBY_HOST_STARTING_CREDITS"
	PP_LOBBY_HOST_POP_CAP								= "PP_LOBBY_HOST_POP_CAP"
	PP_LOBBY_HOST_AI_SLOTS								= "PP_LOBBY_HOST_AI_SLOTS"
	PP_LOBBY_HOST_INTEROPERABLE							= "PP_LOBBY_HOST_INTEROPERABLE"
	PP_LOBBY_HOST_RESERVE_SLOTS							= "PP_LOBBY_HOST_RESERVE_SLOTS"
	PP_LOBBY_HOST_PRIVATE_GAME							= "PP_LOBBY_HOST_PRIVATE_GAME"
	PP_LOBBY_HOST_GOLD_ONLY								= "PP_LOBBY_HOST_GOLD_ONLY"
	PP_LOBBY_FILTER_MAP									= "PP_LOBBY_FILTER_MAP"
	PP_LOBBY_FILTER_WIN_CONDITION						= "PP_LOBBY_FILTER_WIN_CONDITION"
	PP_LOBBY_FILTER_DEFCON								= "PP_LOBBY_FILTER_DEFCON"
	PP_LOBBY_FILTER_ALLIANCES							= "PP_LOBBY_FILTER_ALLIANCES"
	PP_LOBBY_FILTER_OBSERVER							= "PP_LOBBY_FILTER_OBSERVER"
	PP_LOBBY_FILTER_ACHIEVEMENTS						= "PP_LOBBY_FILTER_ACHIEVEMENTS"
	PP_LOBBY_FILTER_HERO_RESPAWN						= "PP_LOBBY_FILTER_HERO_RESPAWN"
	PP_LOBBY_FILTER_STARTING_CREDITS					= "PP_LOBBY_FILTER_STARTING_CREDITS"
	PP_LOBBY_FILTER_POP_CAP								= "PP_LOBBY_FILTER_POP_CAP"
	PP_LOBBY_FILTER_AI_SLOTS							= "PP_LOBBY_FILTER_AI_SLOTS"
	PP_LOBBY_FILTER_INTEROPERABLE						= "PP_LOBBY_FILTER_INTEROPERABLE"
	PP_LOBBY_FILTER_GOLD_ONLY							= "PP_LOBBY_FILTER_GOLD_ONLY"
	PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS					= "PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS"
	PP_LOBBY_RESET_CONQUERED_GLOBE						= "PP_LOBBY_RESET_CONQUERED_GLOBE"
	PP_LOBBY_RESET_CONQUERED_GLOBE_NOVUS				= "PP_LOBBY_RESET_CONQUERED_GLOBE_NOVUS"
	PP_LOBBY_RESET_CONQUERED_GLOBE_ALIEN				= "PP_LOBBY_RESET_CONQUERED_GLOBE_ALIEN"
	PP_LOBBY_RESET_CONQUERED_GLOBE_MASARI				= "PP_LOBBY_RESET_CONQUERED_GLOBE_MASARI"
	PP_LOBBY_SHOW_GAMES_IN_PROGRESS						= "PP_LOBBY_SHOW_GAMES_IN_PROGRESS"
	PP_LOBBY_SORT_GAMES									= "PP_LOBBY_SORT_GAMES"
	PP_LOBBY_MATCHING_STATE								= "PP_LOBBY_MATCHING_STATE"
	PP_WARNING_UPNP_FIREWALL							= "PP_WARNING_UPNP_FIREWALL"
	PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS				= "PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS"
	PP_ENABLE_UPDATE_DOWNLOAD							= "PP_ENABLE_UPDATE_DOWNLOAD"
	PP_ENABLE_LIVE_UPDATE_DOWNLOAD							= "PP_ENABLE_LIVE_UPDATE_DOWNLOAD"

	-- Hint System
	PP_HINT_SYSTEM_ENABLED												= "PP_HINT_SYSTEM_ENABLED"
	PP_HINT_TRACK_MAP														= "PP_HINT_TRACK_MAP"
	PP_HINT_TRACKING_ENABLED											= "PP_HINT_TRACKING_ENABLED"
	
	-- Medals
	PP_APPLIED_MULTIPLAYER_MEDALS						= "PP_APPLIED_MULTIPLAYER_MEDALS"
	PP_APPLIED_LIVE_MEDALS								= "PP_APPLIED_LIVE_MEDALS"
	PP_APPLIED_LIVE_MEDALS_NOVUS_0						= "PP_APPLIED_LIVE_MEDALS_NOVUS_0"
	PP_APPLIED_LIVE_MEDALS_NOVUS_1						= "PP_APPLIED_LIVE_MEDALS_NOVUS_1"
	PP_APPLIED_LIVE_MEDALS_NOVUS_2						= "PP_APPLIED_LIVE_MEDALS_NOVUS_2"
	PP_APPLIED_LIVE_MEDALS_ALIEN_0						= "PP_APPLIED_LIVE_MEDALS_ALIEN_0"
	PP_APPLIED_LIVE_MEDALS_ALIEN_1						= "PP_APPLIED_LIVE_MEDALS_ALIEN_1"
	PP_APPLIED_LIVE_MEDALS_ALIEN_2						= "PP_APPLIED_LIVE_MEDALS_ALIEN_2"
	PP_APPLIED_LIVE_MEDALS_MASARI_0						= "PP_APPLIED_LIVE_MEDALS_MASARI_0"
	PP_APPLIED_LIVE_MEDALS_MASARI_1						= "PP_APPLIED_LIVE_MEDALS_MASARI_1"
	PP_APPLIED_LIVE_MEDALS_MASARI_2						= "PP_APPLIED_LIVE_MEDALS_MASARI_2"

	PP_LAST_MEDAL_CHEST_FACTION							= "PP_LAST_MEDAL_CHEST_FACTION"
	
	-- Global Conquest Lobby
	PP_LAST_GLOBAL_CONQUEST_FACTION									= "PP_LAST_GLOBAL_CONQUEST_FACTION"
	
	-- Skirmish
	PP_LAST_SKIRMISH_CONFIGURATION						= "PP_LAST_SKIRMISH_CONFIGURATION"
	PP_SKIRMISH_PLAYER_FACTION							= "PP_SKIRMISH_PLAYER_FACTION"
	PP_SKIRMISH_PLAYER_TEAM								= "PP_SKIRMISH_PLAYER_TEAM"
	PP_SKIRMISH_PLAYER_COLOR							= "PP_SKIRMISH_PLAYER_COLOR"
	PP_SKIRMISH_MAP										= "PP_SKIRMISH_MAP"
	PP_SKIRMISH_WIN_CONDITION							= "PP_SKIRMISH_WIN_CONDITION"
	PP_SKIRMISH_DEFCON									= "PP_SKIRMISH_DEFCON"
	PP_SKIRMISH_ALLIANCES								= "PP_SKIRMISH_ALLIANCES"
	PP_SKIRMISH_ACHIEVEMENTS							= "PP_SKIRMISH_ACHIEVEMENTS"
	PP_SKIRMISH_HERO_RESPAWN							= "PP_SKIRMISH_HERO_RESPAWN"
	PP_SKIRMISH_STARTING_CREDITS						= "PP_SKIRMISH_STARTING_CREDITS"
	PP_SKIRMISH_POP_CAP									= "PP_SKIRMISH_POP_CAP"
	PP_SKIRMISH_AI_SLOTS									= "PP_SKIRMISH_AI_SLOTS"

	-- Campaigns
	PP_CAMPAIGN_TUTORIAL_COMPLETED						= "CAMPAIGN_TUTORIAL_COMPLETED"
	PP_CAMPAIGN_NOVUS_COMPLETED							= "CAMPAIGN_NOVUS_COMPLETED"
	PP_CAMPAIGN_HIERARCHY_COMPLETED						= "CAMPAIGN_HIERARCHY_COMPLETED"
	PP_CAMPAIGN_MASARI_COMPLETED							= "CAMPAIGN_MASARI_COMPLETED"
	
	-- Missions (for the Gamepad version)
	-- PRELUDE MISSIONS
	-- -------------------------
	PP_TUTORIAL_00_AVAILABLE					= "PP_TUTORIAL_00_AVAILABLE"
	PP_TUTORIAL_01_AVAILABLE					= "PP_TUTORIAL_01_AVAILABLE"
	PP_TUTORIAL_02_AVAILABLE					= "PP_TUTORIAL_02_AVAILABLE"
	
	-- NOVUS MISSIONS
	-- -------------------------
	PP_NOVUS_MISSION_01_AVAILABLE				= "PP_NOVUS_MISSION_01_AVAILABLE"
	PP_NOVUS_MISSION_02_AVAILABLE				= "PP_NOVUS_MISSION_02_AVAILABLE"
	PP_NOVUS_MISSION_03_AVAILABLE				= "PP_NOVUS_MISSION_03_AVAILABLE"
	PP_NOVUS_MISSION_04_AVAILABLE				= "PP_NOVUS_MISSION_04_AVAILABLE"
	PP_NOVUS_MISSION_05_AVAILABLE				= "PP_NOVUS_MISSION_05_AVAILABLE"
	PP_NOVUS_MISSION_06_AVAILABLE				= "PP_NOVUS_MISSION_06_AVAILABLE"
	PP_NOVUS_MISSION_07_AVAILABLE				= "PP_NOVUS_MISSION_07_AVAILABLE"
	
	-- HIERARCHY MISSIONS
	-- -------------------------
	PP_HIERARCHY_MISSION_01_AVAILABLE		= "PP_HIERARCHY_MISSION_01_AVAILABLE"
	PP_HIERARCHY_MISSION_02_AVAILABLE		= "PP_HIERARCHY_MISSION_02_AVAILABLE"
	PP_HIERARCHY_MISSION_03_AVAILABLE		= "PP_HIERARCHY_MISSION_03_AVAILABLE"
	PP_HIERARCHY_MISSION_04_AVAILABLE		= "PP_HIERARCHY_MISSION_04_AVAILABLE"
	PP_HIERARCHY_MISSION_05_AVAILABLE		= "PP_HIERARCHY_MISSION_05_AVAILABLE"
	PP_HIERARCHY_MISSION_06_AVAILABLE		= "PP_HIERARCHY_MISSION_06_AVAILABLE"
	
	-- MASARI MISSIONS
	-- -------------------------
	PP_MASARI_MISSION_01_AVAILABLE			= "PP_MASARI_MISSION_01_AVAILABLE"
	PP_MASARI_GLOBAL_MISSION_AVAILABLE		= "PP_MASARI_GLOBAL_MISSION_AVAILABLE"
	PP_MASARI_MISSION_07_AVAILABLE			= "PP_MASARI_MISSION_07_AVAILABLE"
	
	
	-- Simple Vanity Stats

	-- JLH 12/12/2007
	-- It is a TCR violation to store gamertags!
	--PP_VANITY_LAST_RANKED_OPPONENT					= "PP_VANITY_LAST_RANKED_OPPONENT"
	--PP_VANITY_LAST_UNRANKED_OPPONENT					= "PP_VANITY_LAST_UNRANKED_OPPONENT"
	PP_VANITY_LAST_RANKED_MATCH_DATETIME			= "PP_VANITY_LAST_RANKED_MATCH_DATETIME"
	PP_VANITY_LAST_UNRANKED_MATCH_DATETIME			= "PP_VANITY_LAST_UNRANKED_MATCH_DATETIME"

	PP_TOOLTIP_HINT_DELAY								= "PP_TOOLTIP_HINT_DELAY"
	PP_TOOLTIP_EXPANDED_HINT_DELAY					= "PP_TOOLTIP_EXPANDED_HINT_DELAY"

	-- The mission to continue from
	PP_LAST_PLAYED_MISSION								= "PP_LAST_PLAYED_MISSION"
	PP_LAST_PLAYED_CAMPAIGN								= "PP_LAST_PLAYED_CAMPAIGN"

	-- JLH 12/19/2007
	-- The defaults for custom lobby got lost before ship, so for the week 1 patch we're
	-- putting in a registry flag.  If it doesn't exist, we're going to set host settings
	-- and filters to the proper defaults.
	PP_W1P_DEFAULT_MP_SETTINGS							= "PP_W1P_DEFAULT_MP_SETTINGS"


	-- Versions
	_PGPPVersions = {}
	_PGPPVersions[PP_LOBBY_PLAYER_FACTION]  						= 2
	_PGPPVersions[PP_LOBBY_PLAYER_TEAM] 							= 1
	_PGPPVersions[PP_LOBBY_PLAYER_COLOR]							= 2
	_PGPPVersions[PP_LOBBY_HOST_MAP]									= 1
	_PGPPVersions[PP_LOBBY_HOST_WIN_CONDITION]  					= 2
	_PGPPVersions[PP_LOBBY_HOST_DEFCON] 							= 1
	_PGPPVersions[PP_LOBBY_HOST_ALLIANCES]  						= 1
	_PGPPVersions[PP_LOBBY_HOST_OBSERVER]	  						= 1
	_PGPPVersions[PP_LOBBY_HOST_ACHIEVEMENTS]   					= 2
	_PGPPVersions[PP_LOBBY_HOST_HERO_RESPAWN]   					= 1
	_PGPPVersions[PP_LOBBY_HOST_STARTING_CREDITS]   			= 2
	_PGPPVersions[PP_LOBBY_HOST_POP_CAP]							= 1
	_PGPPVersions[PP_LOBBY_HOST_AI_SLOTS]   						= 1
	_PGPPVersions[PP_LOBBY_HOST_INTEROPERABLE]  					= 1
	_PGPPVersions[PP_LOBBY_HOST_RESERVE_SLOTS]  					= 1
	_PGPPVersions[PP_LOBBY_HOST_PRIVATE_GAME]   					= 1
	_PGPPVersions[PP_LOBBY_HOST_GOLD_ONLY]   						= 1
	_PGPPVersions[PP_LOBBY_FILTER_MAP]  							= 1
	_PGPPVersions[PP_LOBBY_FILTER_WIN_CONDITION]					= 1
	_PGPPVersions[PP_LOBBY_FILTER_DEFCON]   						= 1
	_PGPPVersions[PP_LOBBY_FILTER_ALLIANCES]						= 1
	_PGPPVersions[PP_LOBBY_FILTER_ACHIEVEMENTS] 					= 1
	_PGPPVersions[PP_LOBBY_FILTER_HERO_RESPAWN] 					= 1
	_PGPPVersions[PP_LOBBY_FILTER_STARTING_CREDITS] 			= 1
	_PGPPVersions[PP_LOBBY_FILTER_POP_CAP]  						= 1
	_PGPPVersions[PP_LOBBY_FILTER_AI_SLOTS] 						= 1
	_PGPPVersions[PP_LOBBY_FILTER_INTEROPERABLE]					= 1
	_PGPPVersions[PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS]			= 2
	_PGPPVersions[PP_LOBBY_SHOW_GAMES_IN_PROGRESS]				= 2
	_PGPPVersions[PP_LOBBY_SORT_GAMES]								= 1
	_PGPPVersions[PP_LOBBY_MATCHING_STATE]  						= 1
	_PGPPVersions[PP_LOBBY_RESET_CONQUERED_GLOBE]				= 3		-- **** THIS IS THE ONLY CHANGE ****
	_PGPPVersions[PP_HINT_SYSTEM_ENABLED] 							= 1
	_PGPPVersions[PP_HINT_TRACK_MAP]  								= 1
	_PGPPVersions[PP_HINT_TRACKING_ENABLED]   					= 1
	_PGPPVersions[PP_APPLIED_MULTIPLAYER_MEDALS]  				= 2
	_PGPPVersions[PP_APPLIED_LIVE_MEDALS]		  					= 5
	_PGPPVersions[PP_LAST_GLOBAL_CONQUEST_FACTION]				= 1
	_PGPPVersions[PP_LAST_MEDAL_CHEST_FACTION]					= 1
	_PGPPVersions[PP_LAST_SKIRMISH_CONFIGURATION] 				= 1
	_PGPPVersions[PP_CAMPAIGN_TUTORIAL_COMPLETED]				= 1
	_PGPPVersions[PP_CAMPAIGN_NOVUS_COMPLETED]					= 1
	_PGPPVersions[PP_CAMPAIGN_HIERARCHY_COMPLETED]				= 1
	_PGPPVersions[PP_CAMPAIGN_MASARI_COMPLETED]					= 1
	_PGPPVersions[PP_SKIRMISH_PLAYER_FACTION]  					= 1
	_PGPPVersions[PP_SKIRMISH_PLAYER_TEAM] 						= 1
	_PGPPVersions[PP_SKIRMISH_PLAYER_COLOR]						= 1
	_PGPPVersions[PP_SKIRMISH_MAP]  									= 1
	_PGPPVersions[PP_SKIRMISH_WIN_CONDITION]						= 1
	_PGPPVersions[PP_SKIRMISH_DEFCON]   							= 1
	_PGPPVersions[PP_SKIRMISH_ALLIANCES]							= 1
	_PGPPVersions[PP_SKIRMISH_ACHIEVEMENTS] 						= 1
	_PGPPVersions[PP_SKIRMISH_HERO_RESPAWN] 						= 1
	_PGPPVersions[PP_SKIRMISH_STARTING_CREDITS] 					= 1
	_PGPPVersions[PP_SKIRMISH_POP_CAP]  							= 1
	_PGPPVersions[PP_SKIRMISH_AI_SLOTS] 							= 1
	_PGPPVersions[PP_WARNING_UPNP_FIREWALL]						= 1
	_PGPPVersions[PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS]		= 1
	_PGPPVersions[PP_ENABLE_UPDATE_DOWNLOAD]						= 1
	_PGPPVersions[PP_ENABLE_LIVE_UPDATE_DOWNLOAD]				= 1
	-- JLH 12/12/2007
	-- It is a TCR violation to store gamertags!
	--_PGPPVersions[PP_VANITY_LAST_RANKED_OPPONENT]				= 1
	--_PGPPVersions[PP_VANITY_LAST_UNRANKED_OPPONENT]				= 1
	_PGPPVersions[PP_VANITY_LAST_RANKED_MATCH_DATETIME]		= 1
	_PGPPVersions[PP_VANITY_LAST_UNRANKED_MATCH_DATETIME]		= 1
	_PGPPVersions[PP_TOOLTIP_HINT_DELAY] 							= 1
	_PGPPVersions[PP_TOOLTIP_EXPANDED_HINT_DELAY] 				= 1	
	_PGPPVersions[PP_TUTORIAL_00_AVAILABLE] 						= 1
	_PGPPVersions[PP_TUTORIAL_01_AVAILABLE] 						= 1
	_PGPPVersions[PP_TUTORIAL_02_AVAILABLE] 						= 1
	_PGPPVersions[PP_NOVUS_MISSION_01_AVAILABLE] 				= 1
	_PGPPVersions[PP_NOVUS_MISSION_02_AVAILABLE] 				= 1
	_PGPPVersions[PP_NOVUS_MISSION_03_AVAILABLE] 				= 1
	_PGPPVersions[PP_NOVUS_MISSION_04_AVAILABLE] 				= 1
	_PGPPVersions[PP_NOVUS_MISSION_05_AVAILABLE] 				= 1
	_PGPPVersions[PP_NOVUS_MISSION_06_AVAILABLE] 				= 1
	_PGPPVersions[PP_NOVUS_MISSION_07_AVAILABLE] 				= 1
	_PGPPVersions[PP_HIERARCHY_MISSION_01_AVAILABLE]			= 1
	_PGPPVersions[PP_HIERARCHY_MISSION_02_AVAILABLE]			= 1
	_PGPPVersions[PP_HIERARCHY_MISSION_03_AVAILABLE]			= 1
	_PGPPVersions[PP_HIERARCHY_MISSION_04_AVAILABLE]			= 1
	_PGPPVersions[PP_HIERARCHY_MISSION_05_AVAILABLE]			= 1
	_PGPPVersions[PP_HIERARCHY_MISSION_06_AVAILABLE]			= 1
	_PGPPVersions[PP_MASARI_MISSION_01_AVAILABLE] 				= 1
	_PGPPVersions[PP_MASARI_GLOBAL_MISSION_AVAILABLE]			= 1
	_PGPPVersions[PP_MASARI_MISSION_07_AVAILABLE] 				= 1
	_PGPPVersions[PP_LAST_PLAYED_MISSION]			 				= 1
	_PGPPVersions[PP_LAST_PLAYED_CAMPAIGN]			 				= 1
	_PGPPVersions[PP_COLOR_INDEX]						 				= 2
	_PGPPVersions[PP_W1P_DEFAULT_MP_SETTINGS]						= 1
	
	
	-- Deprecated keys
	PP_NAME																	= "PP_NAME"
	PP_PASSWORD																= "PP_PASSWORD"
	PP_LAST_GAME_NAME														= "PP_LAST_INTERNET_GAME_NAME"
	PP_LAST_MAP																= "PP_LAST_INTERNET_MAP"
	PP_LAST_FACTION														= "PP_LAST_INTERNET_FACTION"
	PP_LAST_CHAT_NAME														= "PP_LAST_CHAT_NAME"
	PP_TEAM																	= "PP_TEAM"
	

	PROFILE_HINT_MAP = {}
	PROFILE_HINT_MAP[1]			= "LUAHintMap1"
	PROFILE_HINT_MAP[2]			= "LUAHintMap2"
	PROFILE_HINT_MAP[3]			= "LUAHintMap3"
	PROFILE_HINT_MAP[4]			= "LUAHintMap4"
	PROFILE_HINT_MAP[5]			= "LUAHintMap5"
	PROFILE_HINT_MAP[6]			= "LUAHintMap6"
	PROFILE_HINT_MAP[7]			= "LUAHintMap7"
	PROFILE_HINT_MAP[8]			= "LUAHintMap8"
	PROFILE_HINT_MAP[9]			= "LUAHintMap9"
	PROFILE_HINT_MAP[10]		= "LUAHintMap10"
	PROFILE_HINT_MAP[11]		= "LUAHintMap11"
	PROFILE_HINT_MAP[12]		= "LUAHintMap12"
	PROFILE_HINT_MAP[13]		= "LUAHintMap13"
	PROFILE_HINT_MAP[14]		= "LUAHintMap14"
	PROFILE_HINT_MAP[15]		= "LUAHintMap15"
	PROFILE_HINT_MAP[16]		= "LUAHintMap16"
	PROFILE_HINT_MAP[17]		= "LUAHintMap17"
	PROFILE_HINT_MAP[18]		= "LUAHintMap18"
	PROFILE_HINT_MAP[19]		= "LUAHintMap19"
	PROFILE_HINT_MAP[20]		= "LUAHintMap20"
	PROFILE_HINT_MAP[21]		= "LUAHintMap21"
	PROFILE_HINT_MAP[22]		= "LUAHintMap22"
	PROFILE_HINT_MAP[23]		= "LUAHintMap23"
	PROFILE_HINT_MAP[24]		= "LUAHintMap24"
	PROFILE_HINT_MAP[25]		= "LUAHintMap25"
	PROFILE_HINT_MAP[26]		= "LUAHintMap26"
	PROFILE_HINT_MAP[27]		= "LUAHintMap27"
	PROFILE_HINT_MAP[28]		= "LUAHintMap28"
	PROFILE_HINT_MAP[29]		= "LUAHintMap29"
	PROFILE_HINT_MAP[30]		= "LUAHintMap30"
	PROFILE_HINT_MAP[31]		= "LUAHintMap31"
	PROFILE_HINT_MAP[32]		= "LUAHintMap32"
	PROFILE_HINT_MAP[33]		= "LUAHintMap33"
	PROFILE_HINT_MAP[34]		= "LUAHintMap34"
	PROFILE_HINT_MAP[35]		= "LUAHintMap35"
	PROFILE_HINT_MAP[36]		= "LUAHintMap36"
	PROFILE_HINT_MAP[37]		= "LUAHintMap37"
	PROFILE_HINT_MAP[38]		= "LUAHintMap38"
	PROFILE_HINT_MAP[39]		= "LUAHintMap39"
	PROFILE_HINT_MAP[40]		= "LUAHintMap40"
	PROFILE_HINT_MAP[41]		= "LUAHintMap41"
	PROFILE_HINT_MAP[42]		= "LUAHintMap42"
	PROFILE_HINT_MAP[43]		= "LUAHintMap43"
	PROFILE_HINT_MAP[44]		= "LUAHintMap44"
	PROFILE_HINT_MAP[45]		= "LUAHintMap45"
	PROFILE_HINT_MAP[46]		= "LUAHintMap46"
	PROFILE_HINT_MAP[47]		= "LUAHintMap47"
	PROFILE_HINT_MAP[48]		= "LUAHintMap48"
	PROFILE_HINT_MAP[49]		= "LUAHintMap49"
	PROFILE_HINT_MAP[50]		= "LUAHintMap50"
	PROFILE_HINT_MAP[51]		= "LUAHintMap51"
	PROFILE_HINT_MAP[52]		= "LUAHintMap52"
	PROFILE_HINT_MAP[53]		= "LUAHintMap53"
	PROFILE_HINT_MAP[54]		= "LUAHintMap54"
	PROFILE_HINT_MAP[55]		= "LUAHintMap55"
	PROFILE_HINT_MAP[56]		= "LUAHintMap56"
	PROFILE_HINT_MAP[57]		= "LUAHintMap57"
	PROFILE_HINT_MAP[58]		= "LUAHintMap58"
	PROFILE_HINT_MAP[59]		= "LUAHintMap59"
	PROFILE_HINT_MAP[60]		= "LUAHintMap60"
	PROFILE_HINT_MAP[61]		= "LUAHintMap61"
	PROFILE_HINT_MAP[62]		= "LUAHintMap62"
	PROFILE_HINT_MAP[63]		= "LUAHintMap63"
	PROFILE_HINT_MAP[64]		= "LUAHintMap64"
	PROFILE_HINT_MAP[65]		= "LUAHintMap65"
	PROFILE_HINT_MAP[66]		= "LUAHintMap66"
	PROFILE_HINT_MAP[67]		= "LUAHintMap67"
	PROFILE_HINT_MAP[68]		= "LUAHintMap68"
	PROFILE_HINT_MAP[69]		= "LUAHintMap69"
	PROFILE_HINT_MAP[70]		= "LUAHintMap70"
	PROFILE_HINT_MAP[71]		= "LUAHintMap71"
	PROFILE_HINT_MAP[72]		= "LUAHintMap72"
	PROFILE_HINT_MAP[73]		= "LUAHintMap73"
	PROFILE_HINT_MAP[74]		= "LUAHintMap74"
	PROFILE_HINT_MAP[75]		= "LUAHintMap75"
	PROFILE_HINT_MAP[76]		= "LUAHintMap76"
	PROFILE_HINT_MAP[77]		= "LUAHintMap77"
	PROFILE_HINT_MAP[78]		= "LUAHintMap78"
	PROFILE_HINT_MAP[79]		= "LUAHintMap79"
	PROFILE_HINT_MAP[80]		= "LUAHintMap80"
	PROFILE_HINT_MAP[81]		= "LUAHintMap81"
	PROFILE_HINT_MAP[82]		= "LUAHintMap82"
	PROFILE_HINT_MAP[83]		= "LUAHintMap83"
	PROFILE_HINT_MAP[84]		= "LUAHintMap84"
	PROFILE_HINT_MAP[85]		= "LUAHintMap85"
	PROFILE_HINT_MAP[86]		= "LUAHintMap86"
	PROFILE_HINT_MAP[87]		= "LUAHintMap87"
	PROFILE_HINT_MAP[88]		= "LUAHintMap88"
	PROFILE_HINT_MAP[89]		= "LUAHintMap89"
	PROFILE_HINT_MAP[90]		= "LUAHintMap90"
	PROFILE_HINT_MAP[91]		= "LUAHintMap91"
	PROFILE_HINT_MAP[92]		= "LUAHintMap92"
	PROFILE_HINT_MAP[93]		= "LUAHintMap93"
	PROFILE_HINT_MAP[94]		= "LUAHintMap94"
	PROFILE_HINT_MAP[95]		= "LUAHintMap95"
	PROFILE_HINT_MAP[96]		= "LUAHintMap96"
	PROFILE_HINT_MAP[97]		= "LUAHintMap97"
	PROFILE_HINT_MAP[98]		= "LUAHintMap98"
	PROFILE_HINT_MAP[99]		= "LUAHintMap99"
	PROFILE_HINT_MAP[100]		= "LUAHintMap100"
	PROFILE_HINT_MAP[101]		= "LUAHintMap101"
	PROFILE_HINT_MAP[102]		= "LUAHintMap102"
	PROFILE_HINT_MAP[103]		= "LUAHintMap103"
	PROFILE_HINT_MAP[104]		= "LUAHintMap104"
	PROFILE_HINT_MAP[105]		= "LUAHintMap105"
	PROFILE_HINT_MAP[106]		= "LUAHintMap106"
	PROFILE_HINT_MAP[107]		= "LUAHintMap107"
	PROFILE_HINT_MAP[108]		= "LUAHintMap108"
	PROFILE_HINT_MAP[109]		= "LUAHintMap109"
	PROFILE_HINT_MAP[110]		= "LUAHintMap110"
	PROFILE_HINT_MAP[111]		= "LUAHintMap111"
	PROFILE_HINT_MAP[112]		= "LUAHintMap112"
	PROFILE_HINT_MAP[113]		= "LUAHintMap113"
	PROFILE_HINT_MAP[114]		= "LUAHintMap114"
	PROFILE_HINT_MAP[115]		= "LUAHintMap115"
	PROFILE_HINT_MAP[116]		= "LUAHintMap116"
	PROFILE_HINT_MAP[117]		= "LUAHintMap117"
	PROFILE_HINT_MAP[118]		= "LUAHintMap118"
	PROFILE_HINT_MAP[119]		= "LUAHintMap119"
	PROFILE_HINT_MAP[120]		= "LUAHintMap120"
	PROFILE_HINT_MAP[121]		= "LUAHintMap121"
	PROFILE_HINT_MAP[122]		= "LUAHintMap122"
	PROFILE_HINT_MAP[123]		= "LUAHintMap123"
	PROFILE_HINT_MAP[124]		= "LUAHintMap124"
	PROFILE_HINT_MAP[125]		= "LUAHintMap125"
	PROFILE_HINT_MAP[126]		= "LUAHintMap126"
	PROFILE_HINT_MAP[127]		= "LUAHintMap127"
	PROFILE_HINT_MAP[128]		= "LUAHintMap128"
	PROFILE_HINT_MAP[129]		= "LUAHintMap129"
	PROFILE_HINT_MAP[130]		= "LUAHintMap130"
	PROFILE_HINT_MAP[131]		= "LUAHintMap131"
	PROFILE_HINT_MAP[132]		= "LUAHintMap132"
	PROFILE_HINT_MAP[133]		= "LUAHintMap133"
	PROFILE_HINT_MAP[134]		= "LUAHintMap134"
	PROFILE_HINT_MAP[135]		= "LUAHintMap135"
	PROFILE_HINT_MAP[136]		= "LUAHintMap136"
	PROFILE_HINT_MAP[137]		= "LUAHintMap137"
	PROFILE_HINT_MAP[138]		= "LUAHintMap138"
	PROFILE_HINT_MAP[139]		= "LUAHintMap139"
	PROFILE_HINT_MAP[140]		= "LUAHintMap140"
	PROFILE_HINT_MAP[141]		= "LUAHintMap141"
	PROFILE_HINT_MAP[142]		= "LUAHintMap142"
	PROFILE_HINT_MAP[143]		= "LUAHintMap143"
	PROFILE_HINT_MAP[144]		= "LUAHintMap144"
	PROFILE_HINT_MAP[145]		= "LUAHintMap145"
	PROFILE_HINT_MAP[146]		= "LUAHintMap146"
	PROFILE_HINT_MAP[147]		= "LUAHintMap147"
	PROFILE_HINT_MAP[148]		= "LUAHintMap148"
	PROFILE_HINT_MAP[149]		= "LUAHintMap149"
	PROFILE_HINT_MAP[150]		= "LUAHintMap150"
	PROFILE_HINT_MAP[151]		= "LUAHintMap151"
	PROFILE_HINT_MAP[152]		= "LUAHintMap152"
	PROFILE_HINT_MAP[153]		= "LUAHintMap153"
	PROFILE_HINT_MAP[154]		= "LUAHintMap154"
	PROFILE_HINT_MAP[155]		= "LUAHintMap155"
	PROFILE_HINT_MAP[156]		= "LUAHintMap156"
	PROFILE_HINT_MAP[157]		= "LUAHintMap157"
	PROFILE_HINT_MAP[158]		= "LUAHintMap158"
	PROFILE_HINT_MAP[159]		= "LUAHintMap159"
	PROFILE_HINT_MAP[160]		= "LUAHintMap160"
	PROFILE_HINT_MAP[161]		= "LUAHintMap161"
	PROFILE_HINT_MAP[162]		= "LUAHintMap162"
	PROFILE_HINT_MAP[163]		= "LUAHintMap163"
	PROFILE_HINT_MAP[164]		= "LUAHintMap164"
	PROFILE_HINT_MAP[165]		= "LUAHintMap165"
	PROFILE_HINT_MAP[166]		= "LUAHintMap166"
	PROFILE_HINT_MAP[167]		= "LUAHintMap167"
	PROFILE_HINT_MAP[168]		= "LUAHintMap168"
	PROFILE_HINT_MAP[169]		= "LUAHintMap169"
	PROFILE_HINT_MAP[170]		= "LUAHintMap170"
	PROFILE_HINT_MAP[171]		= "LUAHintMap171"
	PROFILE_HINT_MAP[172]		= "LUAHintMap172"
	PROFILE_HINT_MAP[173]		= "LUAHintMap173"
	PROFILE_HINT_MAP[174]		= "LUAHintMap174"
	PROFILE_HINT_MAP[175]		= "LUAHintMap175"
	PROFILE_HINT_MAP[176]		= "LUAHintMap176"
	PROFILE_HINT_MAP[177]		= "LUAHintMap177"
	PROFILE_HINT_MAP[178]		= "LUAHintMap178"
	PROFILE_HINT_MAP[179]		= "LUAHintMap179"
	PROFILE_HINT_MAP[180]		= "LUAHintMap180"
	PROFILE_HINT_MAP[181]		= "LUAHintMap181"
	PROFILE_HINT_MAP[182]		= "LUAHintMap182"
	PROFILE_HINT_MAP[183]		= "LUAHintMap183"
	PROFILE_HINT_MAP[184]		= "LUAHintMap184"
	PROFILE_HINT_MAP[185]		= "LUAHintMap185"
	PROFILE_HINT_MAP[186]		= "LUAHintMap186"
	PROFILE_HINT_MAP[187]		= "LUAHintMap187"
	PROFILE_HINT_MAP[188]		= "LUAHintMap188"
	PROFILE_HINT_MAP[189]		= "LUAHintMap189"
	PROFILE_HINT_MAP[190]		= "LUAHintMap190"
	PROFILE_HINT_MAP[191]		= "LUAHintMap191"
	PROFILE_HINT_MAP[192]		= "LUAHintMap192"
	PROFILE_HINT_MAP[193]		= "LUAHintMap193"
	PROFILE_HINT_MAP[194]		= "LUAHintMap194"
	PROFILE_HINT_MAP[195]		= "LUAHintMap195"
	PROFILE_HINT_MAP[196]		= "LUAHintMap196"
	PROFILE_HINT_MAP[197]		= "LUAHintMap197"
	PROFILE_HINT_MAP[198]		= "LUAHintMap198"
	PROFILE_HINT_MAP[199]		= "LUAHintMap199"
	PROFILE_HINT_MAP[200]		= "LUAHintMap200"
	
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- V A R I A B L E S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Sets a profile key with versioning information.  If the format of your
-- key is likely to change in the future, it is advised to give it versioning
-- so that inconsistencies can be caught in a nonfatal manner.
------------------------------------------------------------------------------
function Set_Profile_Value(key, value)
	
	if ( Is_Gamepad_Active() ) then
		if ( type(value) == "number" or type(value) == "boolean" ) then
			PlayerProfile.Set_Xbox_Value(key, value, type(value))
			return
		end
	
		_CustomScriptMessage("_JonathanTest.txt", string.format("=-=-=-=-=-=-=-=-=-= Set_Profile_Value %q - %s", key, type(value)))
	end

	local packed_value = Pack_Versioned_Profile_Value(key, value)
	PlayerProfile.Set_Value(key, packed_value)
end

function Commit_Profile_Values()
	PlayerProfile.Save_Xbox_Values()
end

------------------------------------------------------------------------------
-- Gets a profile key with a version check.  If the value to be returned is
-- not in keeping with the current version, nil is returned.
------------------------------------------------------------------------------
function Get_Profile_Value(key, default)

	if (default == nil) then
		ScriptError("SCRIPTING ERROR:  You must supply a default value to Get_Profile_Value().")
		MessageBox("SCRIPTING ERROR:  You must supply a default value to Get_Profile_Value().")
		DebugMessage("LUA_PLAYER_PROFILE:  You must supply a default value to Get_Profile_Value().")
		return nil
	end
	
	if ( Is_Gamepad_Active() ) then
		if ( type(default) == "number" or type(default) == "boolean" ) then
			local return_val = PlayerProfile.Get_Xbox_Value(key, default, type(default))
			if ( return_val == nil ) then
				return default
			else
				return return_val
			end
		end
	
		_CustomScriptMessage("_JonathanTest.txt", string.format("=-=-=-=-=-=-=-=-=-= Get_Profile_Value %q - %s", key, type(default)))
	end

	local packed_value = PlayerProfile.Get_Value(key, default)
	local value = Unpack_Versioned_Profile_Value(key, packed_value, default)
	return value
	
end

------------------------------------------------------------------------------
-- Adds versioning information to a value.
------------------------------------------------------------------------------
function Pack_Versioned_Profile_Value(key, value)
	local result = {}
	result[0] = _PGPPVersions[key]
	result[1] = value
	return result
end

------------------------------------------------------------------------------
-- Returns the packed value if the version is current, nil otherwise. 
------------------------------------------------------------------------------
function Unpack_Versioned_Profile_Value(key, raw, default) 

	if ((raw == nil) or (type(raw) ~= "table")) then
		return default
	end
	
	if (#raw == 0) then
		return default
	end
	
	local packed_version
	local current_version = _PGPPVersions[key]
	packed_version = raw[0]
	if (packed_version ~= current_version) then
		DebugMessage("PGPlayerProfile:  Stored key '" .. tostring(key) .. " is out-of-date.  Returning nil...")
		return default
	end
	return raw[1]	
	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Commit_Profile_Values = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
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

