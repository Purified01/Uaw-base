-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGOnlineAchievementDefs.lua#34 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGOnlineAchievementDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 84713 $
--
--          $DateTime: 2007/09/24 17:27:51 $
--
--          $Revision: #34 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGAchievementsCommon")
require("PGFactions")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGOnlineAchievementDefs_Init()
	PGFactions_Init()
	Init_Online_Achievements()
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A C H I E V E M E N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Online_Achievements()

	PGAchievementsCommon_Init()
	
	-- JOE DELETE:::  Included for compatibility with the old disk-driven system.
	OnlineAchievementStart			= 1
	OnlineAchievementEnd			= 26
	
	--[[ JOE DELETE::::  This legacy block is from the old disk-driven dev system.
	-- ** IDs **
	OnlineAchievementStart			= Declare_Enum(1)
	-- Shared
	LEADERSHIP_ID					= OnlineAchievementStart
	PROTECTOR_ID					= Declare_Enum()
	RESEARCHER_ID					= Declare_Enum()
	ALLIANCE_ID						= Declare_Enum()
	RAW_POWER_ID					= Declare_Enum()
	-- Novus
	NANITE_MASTERY_ID				= Declare_Enum()
	HERO_MASTERY_ID					= Declare_Enum()
	WEAPON_MASTERY_ID				= Declare_Enum()
	FLIGHT_MASTERY_ID				= Declare_Enum()
	SIGNAL_MASTERY_ID				= Declare_Enum()
	ROBOTIC_MASTERY_ID				= Declare_Enum()
	SCIENCE_MASTERY_ID				= Declare_Enum()
	-- Hierarchy
	BOVINE_DEFENDER_ID				= Declare_Enum()
	ASSAULT_SPECIALIST_ID			= Declare_Enum()
	MUTAGEN_SPECIALIST_ID			= Declare_Enum()
	QUANTUM_SPECIALIST_ID			= Declare_Enum()
	SOCKET_EMBLEM_ID				= Declare_Enum()
	INSIGNIA_OF_CORRUPTION_ID		= Declare_Enum()
	KAMALS_BLESSING_ID				= Declare_Enum()
	-- Masari
	KINETIC_SEER_ID					= Declare_Enum()
	TIME_MANIPULATOR_ID				= Declare_Enum()
	DARK_STRATEGIST_ID				= Declare_Enum()
	LIGHTBRINGER_ID					= Declare_Enum()
	MODULAR_PROFICIENCY_ID			= Declare_Enum()
	MASARI_PROTECTUS_ID				= Declare_Enum()
	GIFT_OF_THE_ARCHITECT_ID		= Declare_Enum()
	OnlineAchievementEnd			= GIFT_OF_THE_ARCHITECT_ID
	--]]
	
	-- Non-achievement medals
	-- These medals are awarded to all players automatically.  They are not reflected on GFWLive.
	ACHIEVEMENT_MP_LEADERSHIP					= Declare_Enum(10100) 
	NonAchievementMedalsStart					= ACHIEVEMENT_MP_LEADERSHIP
	ACHIEVEMENT_MP_PROTECTOR					= Declare_Enum()
	ACHIEVEMENT_MP_RESEARCHER					= Declare_Enum()
	ACHIEVEMENT_MP_ALLIANCE						= Declare_Enum()
	ACHIEVEMENT_MP_RAW_POWER					= Declare_Enum()
	NonAchievementMedalsEnd 					= ACHIEVEMENT_MP_RAW_POWER
	TOTAL_MEDALS_PER_FACTION					= 7		-- 7 per faction
	TOTAL_FACTION_MEDALS_COUNT					= 21	-- ...times 3 factions

	-- ** Online Achievement Map **
	Register_Net_Commands() -- need to make sure Net is defined
	Net.Register_XLive_Constants()
	OnlineAchievementMap = _PG_Create_Base_Online_Achievement_Map()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PG_Create_Base_Online_Achievement_Map()

	-- ** Achievement Definitions **
	local map = {}
	local achievement


	-- *************************************************
	-- ********************** ALL **********************
	-- *************************************************
	
	-- LEADERSHIP
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_LEADERSHIP,		-- ID
		PG_FACTION_ALL,																			-- Faction
		true,																					-- Is Medal?
		false,																					-- Is Achievement?
		1,																						-- Completion target  
		"TEXT_ACHIEVEMENT_LEADERSHIP_NAME",														-- Name
		"i_icon_medals_shared_leadership.tga",													-- Texture
		"TEXT_ACHIEVEMENT_LEADERSHIP_REQUIREMENTS_DESC",										-- Requirements desc.
		"TEXT_ACHIEVEMENT_LEADERSHIP_BUFF_DESC",												-- Buff desc.
		"Achievement_Leadership")																-- XML Effect Label
	map[achievement.Id] = achievement
	
	-- PROTECTOR
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_PROTECTOR,
		PG_FACTION_ALL,
		true,
		false,
		1,
		"TEXT_ACHIEVEMENT_PROTECTOR_NAME",
		"i_icon_medals_shared_protector.tga",
		"TEXT_ACHIEVEMENT_PROTECTOR_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_PROTECTOR_BUFF_DESC",
		"Achievement_Protector")
	map[achievement.Id] = achievement
	
	-- RESEARCHER
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_RESEARCHER, 	
		PG_FACTION_ALL,   
		true,   
		false,
		1,   
		"TEXT_ACHIEVEMENT_RESEARCHER_NAME",   
		"i_icon_medals_shared_researcher.tga",   
		"TEXT_ACHIEVEMENT_RESEARCHER_REQUIREMENTS_DESC",   
		"TEXT_ACHIEVEMENT_RESEARCHER_BUFF_DESC",   
		"Achievement_Researcher") 
	achievement.BuffValue = 0.95
	map[achievement.Id] = achievement
	
	-- ALLIANCE
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_ALLIANCE, 	
		PG_FACTION_ALL,   
		true,   
		false,
		1,   
		"TEXT_ACHIEVEMENT_ALLIANCE_NAME",   
		"i_icon_medals_shared_alliance.tga",   
		"TEXT_ACHIEVEMENT_ALLIANCE_REQUIREMENTS_DESC",   
		"TEXT_ACHIEVEMENT_ALLIANCE_BUFF_DESC",   
		"Achievement_Alliance")   
	map[achievement.Id] = achievement
	
	-- RAW_POWER
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_RAW_POWER, 	
		PG_FACTION_ALL,   
		true,   
		false,
		1,   
		"TEXT_ACHIEVEMENT_RAW_POWER_NAME",   
		"i_icon_medals_shared_raw_power.tga",   
		"TEXT_ACHIEVEMENT_RAW_POWER_REQUIREMENTS_DESC",   
		"TEXT_ACHIEVEMENT_RAW_POWER_BUFF_DESC",   
		"Achievement_Raw_Power")   
	map[achievement.Id] = achievement


	-- ***************************************************
	-- ********************** NOVUS **********************
	-- ***************************************************

	-- NANITE_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_BUILDING_THE_NETWORK,
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_NANITE_MASTERY_NAME",
		"i_icon_medals_novus_nanite_mastery.tga",
		"TEXT_ACHIEVEMENT_BUILDING_THE_NETWORK_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_NANITE_MASTERY_BUFF_DESC",
		"Achievement_Nanite_Mastery")
	map[achievement.Id] = achievement
	
	-- HERO_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_UNDER_NOVUS_CONTROL, 	
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_HERO_MASTERY_NAME",
		"i_icon_medals_novus_hero_mastery.tga",
		"TEXT_ACHIEVEMENT_UNDER_NOVUS_CONTROL_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_HERO_MASTERY_BUFF_DESC",
		"Achievement_Hero_Mastery")
	map[achievement.Id] = achievement
	
	-- WEAPON_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_CANT_STOP_NOVUS, 	
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_WEAPON_MASTERY_NAME",
		"i_icon_medals_novus_weapon_mastery.tga",
		"TEXT_ACHIEVEMENT_CANT_STOP_NOVUS_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_WEAPON_MASTERY_BUFF_DESC",
		"Achievement_Weapon_Mastery")
	map[achievement.Id] = achievement
	
	-- FLIGHT_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_WHIRLING_DERVISH, 	
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_FLIGHT_MASTERY_NAME",
		"i_icon_medals_novus_flight_mastery.tga",
		"TEXT_ACHIEVEMENT_WHIRLING_DERVISH_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_FLIGHT_MASTERY_BUFF_DESC",
		"Achievement_Flight_Mastery")
	map[achievement.Id] = achievement
	
	-- SIGNAL_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_THE_POWER_MUST_FLOW, 
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_SIGNAL_MASTERY_NAME",
		"i_icon_medals_novus_signal_mastery.tga",
		"TEXT_ACHIEVEMENT_POWER_MUST_FLOW_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_SIGNAL_MASTERY_BUFF_DESC",
		"Achievement_Signal_Mastery")
	map[achievement.Id] = achievement
	
	-- ROBOTIC_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_PURE_OHMAGE, 
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_ROBOTIC_MASTERY_NAME",
		"i_icon_medals_novus_robotic_mastery.tga",
		"TEXT_ACHIEVEMENT_PURE_OHMAGE_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_ROBOTIC_MASTERY_BUFF_DESC",
		"Achievement_Robotic_Mastery")
	map[achievement.Id] = achievement
	
	-- SCIENCE_MASTERY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_RESEARCH_IS_KEY, 
		PG_FACTION_NOVUS,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_SCIENCE_MASTERY_NAME",
		"i_icon_medals_novus_science_mastery.tga",
		"TEXT_ACHIEVEMENT_RESEARCH_IS_KEY_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_SCIENCE_MASTERY_BUFF_DESC",
		"Achievement_Science_Mastery")
	map[achievement.Id] = achievement
	

	-- *******************************************************
	-- ********************** HIERARCHY **********************
	-- *******************************************************
	
	-- BOVINE_DEFENDER
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_THE_SACRED_COW, 	
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_BOVINE_DEFENDER_NAME",
		"i_icon_medals_alien_bovine_defender.tga",
		"TEXT_ACHIEVEMENT_SACRED_COW_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_BOVINE_DEFENDER_BUFF_DESC",
		"Achievement_Bovine_Defender")
	map[achievement.Id] = achievement
	
	-- ASSAULT_SPECIALIST
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_PEACE_THROUGH_POWER, 
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_ASSAULT_SPECIALIST_NAME",
		"i_icon_medals_alien_assault_specialist.tga",
		"TEXT_ACHIEVEMENT_PEACE_THROUGH_POWER_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_ASSAULT_SPECIALIST_BUFF_DESC",
		"Achievement_Assault_Specialist")
	map[achievement.Id] = achievement
	
	-- MUTAGEN_SPECIALIST
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_MUTATION_IS_GOOD, 
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_MUTAGEN_SPECIALIST_NAME",
		"i_icon_medals_alien_mutagen_specialist.tga",
		"TEXT_ACHIEVEMENT_MUTATION_MADNESS_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_MUTAGEN_SPECIALIST_BUFF_DESC",
		"Achievement_Mutagen_Specialist")
	map[achievement.Id] = achievement
	
	-- QUANTUM_SPECIALIST
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_TECHNOLOGICAL_TERROR, 
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_QUANTUM_SPECIALIST_NAME",
		"i_icon_medals_alien_quantum_specialist.tga",
		"TEXT_ACHIEVEMENT_TECHNOLOGICAL_TERROR_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_QUANTUM_SPECIALIST_BUFF_DESC",
		"Achievement_Quantum_Specialist")
	map[achievement.Id] = achievement
	
	-- SOCKET_EMBLEM
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_CUSTOMIZATION_MADE_EASY,
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_SOCKET_EMBLEM_NAME",
		"i_icon_medals_alien_socket_emblem.tga",
		"TEXT_ACHIEVEMENT_CUSTOMIZATION_MADE_EASY_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_SOCKET_EMBLEM_BUFF_DESC",
		"Achievement_Socket_Emblem")
	map[achievement.Id] = achievement
	
	-- INSIGNIA_OF_CORRUPTION
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_MY_WISH_IS_YOUR_COMMAND, 
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_INSIGNIA_OF_CORRUPTION_NAME",
		"i_icon_medals_alien_corruption_insignia.tga",
		"TEXT_ACHIEVEMENT_MY_WISH_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_INSIGNIA_OF_CORRUPTION_BUFF_DESC",
		"Achievement_Insignia_Of_Corruption")
	map[achievement.Id] = achievement
	
	-- KAMALS_BLESSING
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_HIERARCHY_DOMINATION,
		PG_FACTION_ALIEN,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_KAMALS_BLESSING_NAME",
		"i_icon_medals_alien_kamals_blessing.tga",
		"TEXT_ACHIEVEMENT_HIERARCHY_DOMINATION_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_KAMALS_BLESSING_BUFF_DESC",
		"Achievement_Kamals_Blessing")
	map[achievement.Id] = achievement


	-- ****************************************************
	-- ********************** MASARI **********************
	-- ****************************************************
	
	-- KINETIC_SEER
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_CLOAKING_IS_GOOD,
		PG_FACTION_MASARI,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_KINETIC_SEER_NAME",
		"i_icon_medals_masari_kinetic_seer.tga",
		"TEXT_ACHIEVEMENT_CLOAKING_IS_GOOD_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_KINETIC_SEER_BUFF_DESC",
		"Achievement_Kinetic_Seer")
	map[achievement.Id] = achievement
	
	-- TIME_MANIPULATOR
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_TIME_MEANS_NOTHING,
		PG_FACTION_MASARI,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_TIME_MANIPULATOR_NAME",
		"i_icon_medals_masari_time_manipulator.tga",
		"TEXT_ACHIEVEMENT_TIME_MEANS_NOTHING_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_TIME_MANIPULATOR_BUFF_DESC",
		"Achievement_Time_Manipulator")
	map[achievement.Id] = achievement
	
	-- DARK_STRATEGIST
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_DARK_MATTER_FTW,
		PG_FACTION_MASARI,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_DARK_STRATEGIST_NAME",
		"i_icon_medals_masari_dark_strategist.tga",
		"TEXT_ACHIEVEMENT_DARK_MATTER_FTW_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_DARK_STRATEGIST_BUFF_DESC",
		"Achievement_Dark_Strategist")
	map[achievement.Id] = achievement
	
	-- LIGHTBRINGER
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_BLINDED_BY_THE_LIGHT,
		PG_FACTION_MASARI,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_LIGHTBRINGER_NAME",
		"i_icon_medals_masari_light_bringer.tga",
		"TEXT_ACHIEVEMENT_BLINDED_BY_THE_LIGHT_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_LIGHTBRINGER_BUFF_DESC",
		"Achievement_Lightbringer")
	map[achievement.Id] = achievement
	
	-- MODULAR_PROFICIENCY
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_UNLIMITED_POWER,
		PG_FACTION_MASARI,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_MODULAR_PROFICIENCY_NAME",
		"i_icon_medals_masari_modular_proficiency.tga",
		"TEXT_ACHIEVEMENT_UNLIMITED_POWER_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_MODULAR_PROFICIENCY_BUFF_DESC",
		"Achievement_Modular_Proficiency")
	achievement.BuffValue = 0.15
	map[achievement.Id] = achievement
	
	-- MASARI_PROTECTUS
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_MASARI_GLOBAL_INFLUENCE,
		PG_FACTION_MASARI,
		true,
		true,
		1,
		"TEXT_ACHIEVEMENT_MASARI_PROTECTUS_NAME",
		"i_icon_medals_masari_masari_protectus.tga",
		"TEXT_ACHIEVEMENT_MASARI_GLOBAL_INFLUENCE_REQUIREMENTS_DESC",
		"TEXT_ACHIEVEMENT_MASARI_PROTECTUS_BUFF_DESC",
		"Achievement_Masari_Protectus")
	map[achievement.Id] = achievement
	
	-- GIFT_OF_THE_ARCHITECT
	achievement = Create_Base_Increment_Achievement_Definition(ACHIEVEMENT_MP_GIFTS_ARE_NICE, 	
		PG_FACTION_MASARI,   
		true,   
		true,
		1,   
		"TEXT_ACHIEVEMENT_GIFT_OF_THE_ARCHITECT_NAME",   
		"i_icon_medals_masari_architect_gift.tga",   
		"TEXT_ACHIEVEMENT_GIFTS_ARE_NICE_REQUIREMENTS_DESC",   
		"TEXT_ACHIEVEMENT_GIFT_OF_THE_ARCHITECT_BUFF_DESC",   
		"Achievement_Gift_Of_The_Architect")   
	map[achievement.Id] = achievement

	Set_Achievement_Map_Type(map, ONLINE_ACHIEVEMENT)

	return map

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- U T I L I T I E S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Returns an iarray of achievement ids indicating applied medals for the
-- current faction.
--
-- REQUIREMENTS:  In the running script context PGPlayerProfile should be 
-- loaded and initialized.
------------------------------------------------------------------------------
function Get_Locally_Applied_Medals(faction)

	local applied_medals = Get_Local_User_Applied_Medals()
	local medals = {}

	if (applied_medals == nil) then
		ScriptError("LUA_ACHIEVEMENTS: ERROR: Unable to get applied medals model from the registry!")
		return medals
	end

	if (#applied_medals == 0) then
		return medals
	end
	
	-- Get the applied medals for the current faction.
	local array = applied_medals[faction]

	if (array == nil) then
		return medals
	end
	
	-- Populate the medals array...
	for _, data in ipairs(array) do
		table.insert(medals, data[2])
	end
		
	return medals
	
end
  

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Create_Default_Applied_Medals_Table()

	local result = {}
	local user_id = Net.Get_Offline_XUID()
	result[user_id] = {}
	return result
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Local_User_Applied_Medals()

	-- The model stored in the registry is a map keyed by gamertag whose values
	-- are maps keyed by faction whose values are iarrays.  Confusing?
	local default_model = Create_Default_Applied_Medals_Table() 
	local user_models = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS, default_model)
	local user_id = Net.Get_Offline_XUID()
	if (user_models[user_id] == nil) then
		-- New user
		user_models[user_id] = {}
	end
	local applied_medals = user_models[user_id]
	return applied_medals
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Local_User_Applied_Medals(applied_medals)

	-- The model stored in the registry is a map keyed by gamertag whose values
	-- are maps keyed by faction whose values are iarrays.  Confusing?
	local default_model = Create_Default_Applied_Medals_Table() 
	local user_models = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS, default_model)
	local user_id = Net.Get_Offline_XUID()
	user_models[user_id] = applied_medals
	Set_Profile_Value(PP_APPLIED_LIVE_MEDALS, user_models)

end


