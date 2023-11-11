-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGPlayerProfile.lua#42 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGPlayerProfile.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 90377 $
--
--          $DateTime: 2008/01/07 11:47:13 $
--
--          $Revision: #42 $
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
		PlayerProfile.Set_Value(PP_COLOR_INDEX, "")
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
	
	-- Multiplayer Lobby
	PP_LOBBY_PLAYER_FACTION												= "PP_LOBBY_PLAYER_FACTION"
	PP_LOBBY_PLAYER_TEAM													= "PP_LOBBY_PLAYER_TEAM"
	PP_LOBBY_PLAYER_COLOR												= "PP_LOBBY_PLAYER_COLOR"
	PP_LOBBY_HOST_MAP														= "PP_LOBBY_HOST_MAP"
	PP_LOBBY_HOST_WIN_CONDITION										= "PP_LOBBY_HOST_WIN_CONDITION"
	PP_LOBBY_HOST_DEFCON													= "PP_LOBBY_HOST_DEFCON"
	PP_LOBBY_HOST_ALLIANCES												= "PP_LOBBY_HOST_ALLIANCES"
	PP_LOBBY_HOST_OBSERVER												= "PP_LOBBY_HOST_OBSERVER"
	PP_LOBBY_HOST_ACHIEVEMENTS											= "PP_LOBBY_HOST_ACHIEVEMENTS"
	PP_LOBBY_HOST_HERO_RESPAWN											= "PP_LOBBY_HOST_HERO_RESPAWN"
	PP_LOBBY_HOST_STARTING_CREDITS									= "PP_LOBBY_HOST_STARTING_CREDITS"
	PP_LOBBY_HOST_POP_CAP												= "PP_LOBBY_HOST_POP_CAP"
	PP_LOBBY_HOST_AI_SLOTS												= "PP_LOBBY_HOST_AI_SLOTS"
	PP_LOBBY_HOST_INTEROPERABLE										= "PP_LOBBY_HOST_INTEROPERABLE"
	PP_LOBBY_HOST_RESERVE_SLOTS										= "PP_LOBBY_HOST_RESERVE_SLOTS"
	PP_LOBBY_HOST_PRIVATE_GAME											= "PP_LOBBY_HOST_PRIVATE_GAME"
	PP_LOBBY_HOST_GOLD_ONLY												= "PP_LOBBY_HOST_GOLD_ONLY"
	PP_LOBBY_FILTER_MAP													= "PP_LOBBY_FILTER_MAP"
	PP_LOBBY_FILTER_WIN_CONDITION										= "PP_LOBBY_FILTER_WIN_CONDITION"
	PP_LOBBY_FILTER_DEFCON												= "PP_LOBBY_FILTER_DEFCON"
	PP_LOBBY_FILTER_ALLIANCES											= "PP_LOBBY_FILTER_ALLIANCES"
	PP_LOBBY_FILTER_OBSERVER											= "PP_LOBBY_FILTER_OBSERVER"
	PP_LOBBY_FILTER_ACHIEVEMENTS										= "PP_LOBBY_FILTER_ACHIEVEMENTS"
	PP_LOBBY_FILTER_HERO_RESPAWN										= "PP_LOBBY_FILTER_HERO_RESPAWN"
	PP_LOBBY_FILTER_STARTING_CREDITS									= "PP_LOBBY_FILTER_STARTING_CREDITS"
	PP_LOBBY_FILTER_POP_CAP												= "PP_LOBBY_FILTER_POP_CAP"
	PP_LOBBY_FILTER_AI_SLOTS											= "PP_LOBBY_FILTER_AI_SLOTS"
	PP_LOBBY_FILTER_INTEROPERABLE										= "PP_LOBBY_FILTER_INTEROPERABLE"
	PP_LOBBY_FILTER_GOLD_ONLY											= "PP_LOBBY_FILTER_GOLD_ONLY"
	PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS								= "PP_LOBBY_DISPLAY_LOCAL_NAT_WARNINGS"
	PP_LOBBY_RESET_CONQUERED_GLOBE									= "PP_LOBBY_RESET_CONQUERED_GLOBE"
	PP_LOBBY_SHOW_GAMES_IN_PROGRESS									= "PP_LOBBY_SHOW_GAMES_IN_PROGRESS"
	PP_LOBBY_SORT_GAMES													= "PP_LOBBY_SORT_GAMES"
	PP_LOBBY_MATCHING_STATE												= "PP_LOBBY_MATCHING_STATE"
	PP_WARNING_UPNP_FIREWALL											= "PP_WARNING_UPNP_FIREWALL"
	PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS							= "PP_WARNING_SINGLE_PLAYER_ACHIEVEMENTS"
	PP_ENABLE_UPDATE_DOWNLOAD											= "PP_ENABLE_UPDATE_DOWNLOAD"
	PP_ENABLE_LIVE_UPDATE_DOWNLOAD									= "PP_ENABLE_LIVE_UPDATE_DOWNLOAD"

	-- Hint System
	PP_HINT_SYSTEM_ENABLED												= "PP_HINT_SYSTEM_ENABLED"
	PP_HINT_TRACK_MAP														= "PP_HINT_TRACK_MAP"
	PP_HINT_TRACKING_ENABLED											= "PP_HINT_TRACKING_ENABLED"
	
	-- Medals
	PP_APPLIED_MULTIPLAYER_MEDALS										= "PP_APPLIED_MULTIPLAYER_MEDALS"
	PP_APPLIED_LIVE_MEDALS												= "PP_APPLIED_LIVE_MEDALS"
	PP_LAST_MEDAL_CHEST_FACTION										= "PP_LAST_MEDAL_CHEST_FACTION"
	
	-- Global Conquest Lobby
	PP_LAST_GLOBAL_CONQUEST_FACTION									= "PP_LAST_GLOBAL_CONQUEST_FACTION"
	
	-- Skirmish
	PP_LAST_SKIRMISH_CONFIGURATION									= "PP_LAST_SKIRMISH_CONFIGURATION"
	PP_SKIRMISH_PLAYER_FACTION											= "PP_SKIRMISH_PLAYER_FACTION"
	PP_SKIRMISH_PLAYER_TEAM												= "PP_SKIRMISH_PLAYER_TEAM"
	PP_SKIRMISH_PLAYER_COLOR											= "PP_SKIRMISH_PLAYER_COLOR"
	PP_SKIRMISH_MAP														= "PP_SKIRMISH_MAP"
	PP_SKIRMISH_WIN_CONDITION											= "PP_SKIRMISH_WIN_CONDITION"
	PP_SKIRMISH_DEFCON													= "PP_SKIRMISH_DEFCON"
	PP_SKIRMISH_ALLIANCES												= "PP_SKIRMISH_ALLIANCES"
	PP_SKIRMISH_ACHIEVEMENTS											= "PP_SKIRMISH_ACHIEVEMENTS"
	PP_SKIRMISH_HERO_RESPAWN											= "PP_SKIRMISH_HERO_RESPAWN"
	PP_SKIRMISH_STARTING_CREDITS										= "PP_SKIRMISH_STARTING_CREDITS"
	PP_SKIRMISH_POP_CAP													= "PP_SKIRMISH_POP_CAP"
	PP_SKIRMISH_AI_SLOTS													= "PP_SKIRMISH_AI_SLOTS"

	-- Campaigns
	PP_CAMPAIGN_TUTORIAL_COMPLETED									= "CAMPAIGN_TUTORIAL_COMPLETED"
	PP_CAMPAIGN_NOVUS_COMPLETED										= "CAMPAIGN_NOVUS_COMPLETED"
	PP_CAMPAIGN_HIERARCHY_COMPLETED									= "CAMPAIGN_HIERARCHY_COMPLETED"
	PP_CAMPAIGN_MASARI_COMPLETED										= "CAMPAIGN_MASARI_COMPLETED"
	
	-- Simple Vanity Stats
	-- JLH 12/12/2007
	-- It is a TCR violation to store gamertags!
	--PP_VANITY_LAST_RANKED_OPPONENT									= "PP_VANITY_LAST_RANKED_OPPONENT"
	--PP_VANITY_LAST_UNRANKED_OPPONENT									= "PP_VANITY_LAST_UNRANKED_OPPONENT"
	PP_VANITY_LAST_RANKED_MATCH_DATETIME							= "PP_VANITY_LAST_RANKED_MATCH_DATETIME"
	PP_VANITY_LAST_UNRANKED_MATCH_DATETIME							= "PP_VANITY_LAST_UNRANKED_MATCH_DATETIME"
	
	-- JLH 12/19/2007
	-- The defaults for custom lobby got lost before ship, so for the week 1 patch we're
	-- putting in a registry flag.  If it doesn't exist, we're going to set host settings
	-- and filters to the proper defaults.
	PP_W1P_DEFAULT_MP_SETTINGS											= "PP_W1P_DEFAULT_MP_SETTINGS"

	-- Versions
	_PGPPVersions = {}
	_PGPPVersions[PP_LOBBY_PLAYER_FACTION]  						= 1
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
	_PGPPVersions[PP_LAST_MEDAL_CHEST_FACTION]					= 2
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
	_PGPPVersions[PP_W1P_DEFAULT_MP_SETTINGS]						= 1
	
	-- Deprecated keys
	PP_NAME																	= "PP_NAME"
	PP_PASSWORD																= "PP_PASSWORD"
	PP_LAST_GAME_NAME														= "PP_LAST_INTERNET_GAME_NAME"
	PP_LAST_MAP																= "PP_LAST_INTERNET_MAP"
	PP_LAST_FACTION														= "PP_LAST_INTERNET_FACTION"
	PP_LAST_CHAT_NAME														= "PP_LAST_CHAT_NAME"
	PP_COLOR_INDEX															= "PP_COLOR_INDEX"
	PP_TEAM																	= "PP_TEAM"
	
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
	local packed_value = Pack_Versioned_Profile_Value(key, value)
	PlayerProfile.Set_Value(key, packed_value)
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
