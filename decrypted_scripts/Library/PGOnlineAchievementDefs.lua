if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[193] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGOnlineAchievementDefs.lua#21 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGOnlineAchievementDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Jonathan_Burgess $
--
--            $Change: 92931 $
--
--          $DateTime: 2008/02/08 14:52:05 $
--
--          $Revision: #21 $
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
	
	-- Create lookups of all medals in the game for validation.
	UNBOUND_MEDALS = {}		-- Medals not bound to any achievements.
	UNBOUND_MEDALS[ACHIEVEMENT_MP_LEADERSHIP] = true
	UNBOUND_MEDALS[ACHIEVEMENT_MP_PROTECTOR] 	= true
	UNBOUND_MEDALS[ACHIEVEMENT_MP_RESEARCHER] = true
	UNBOUND_MEDALS[ACHIEVEMENT_MP_ALLIANCE] 	= true
	UNBOUND_MEDALS[ACHIEVEMENT_MP_RAW_POWER] 	= true
	
	BOUND_MEDALS = {}			-- Medals which are bound to achievements.
	-- ASSUMPTION: If one of the bound IDs has been mapped into script, they all have been.
	-- Otherwise none have been.
	if (ACHIEVEMENT_MP_BUILDING_THE_NETWORK ~= nil) then
		BOUND_MEDALS[ACHIEVEMENT_MP_BUILDING_THE_NETWORK]			= true
		BOUND_MEDALS[ACHIEVEMENT_MP_UNDER_NOVUS_CONTROL]			= true
		BOUND_MEDALS[ACHIEVEMENT_MP_CANT_STOP_NOVUS]					= true
		BOUND_MEDALS[ACHIEVEMENT_MP_WHIRLING_DERVISH]				= true
		BOUND_MEDALS[ACHIEVEMENT_MP_THE_POWER_MUST_FLOW]			= true
		BOUND_MEDALS[ACHIEVEMENT_MP_PURE_OHMAGE]						= true
		BOUND_MEDALS[ACHIEVEMENT_MP_RESEARCH_IS_KEY]					= true
		BOUND_MEDALS[ACHIEVEMENT_MP_CLOAKING_IS_GOOD]				= true
		BOUND_MEDALS[ACHIEVEMENT_MP_TIME_MEANS_NOTHING]				= true
		BOUND_MEDALS[ACHIEVEMENT_MP_DARK_MATTER_FTW]					= true
		BOUND_MEDALS[ACHIEVEMENT_MP_BLINDED_BY_THE_LIGHT]			= true
		BOUND_MEDALS[ACHIEVEMENT_MP_UNLIMITED_POWER]					= true
		BOUND_MEDALS[ACHIEVEMENT_MP_MASARI_GLOBAL_INFLUENCE]		= true
		BOUND_MEDALS[ACHIEVEMENT_MP_GIFTS_ARE_NICE]					= true
		BOUND_MEDALS[ACHIEVEMENT_MP_THE_SACRED_COW]					= true
		BOUND_MEDALS[ACHIEVEMENT_MP_PEACE_THROUGH_POWER]			= true
		BOUND_MEDALS[ACHIEVEMENT_MP_MUTATION_IS_GOOD]				= true
		BOUND_MEDALS[ACHIEVEMENT_MP_TECHNOLOGICAL_TERROR]			= true
		BOUND_MEDALS[ACHIEVEMENT_MP_CUSTOMIZATION_MADE_EASY]		= true
		BOUND_MEDALS[ACHIEVEMENT_MP_MY_WISH_IS_YOUR_COMMAND]		= true
		BOUND_MEDALS[ACHIEVEMENT_MP_HIERARCHY_DOMINATION]			= true
	end
	

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

	Set_Achievement_Map_Type(map, 2)

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

	if ( Is_Gamepad_Active() ) then
		local profile_value = nil

		local novus_medals = {}
		novus_medals[1] = {}
		novus_medals[1][1] = "Quad_Buff0_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_0, -1)
		if (Validate_Applied_Medal(profile_value)) then
			novus_medals[1][2] = profile_value
		end

		novus_medals[2] = {}
		novus_medals[2][1] = "Quad_Buff1_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_1, -1)
		if (Validate_Applied_Medal(profile_value)) then
			novus_medals[2][2] = profile_value
		end

		novus_medals[3] = {}
		novus_medals[3][1] = "Quad_Buff2_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_2, -1)
		if (Validate_Applied_Medal(profile_value)) then
			novus_medals[3][2] = profile_value
		end


		local alien_medals = {}
		alien_medals[1] = {}
		alien_medals[1][1] = "Quad_Buff0_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_0, -1)
		if (Validate_Applied_Medal(profile_value)) then
			alien_medals[1][2] = profile_value
		end

		alien_medals[2] = {}
		alien_medals[2][1] = "Quad_Buff1_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_1, -1)
		if (Validate_Applied_Medal(profile_value)) then
			alien_medals[2][2] = profile_value
		end

		alien_medals[3] = {}
		alien_medals[3][1] = "Quad_Buff2_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_2, -1)
		if (Validate_Applied_Medal(profile_value)) then
			alien_medals[3][2] = profile_value
		end


		local masari_medals = {}
		masari_medals[1] = {}
		masari_medals[1][1] = "Quad_Buff0_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_0, -1)
		if (Validate_Applied_Medal(profile_value)) then
			masari_medals[1][2] = profile_value
		end

		masari_medals[2] = {}
		masari_medals[2][1] = "Quad_Buff1_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_1, -1)
		if (Validate_Applied_Medal(profile_value)) then
			masari_medals[2][2] = profile_value
		end

		masari_medals[3] = {}
		masari_medals[3][1] = "Quad_Buff2_Texture"
		profile_value = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_2, -1)
		if (Validate_Applied_Medal(profile_value)) then
			masari_medals[3][2] = profile_value
		end


		local applied_medals = {}
		applied_medals[PG_FACTION_ALL] = {}
		applied_medals[PG_FACTION_NOVUS] = novus_medals
		applied_medals[PG_FACTION_ALIEN] = alien_medals
		applied_medals[PG_FACTION_MASARI] = masari_medals

		return applied_medals
	end



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
-- Makes sure that the medal data we're getting back from the profile store
-- is good.
-------------------------------------------------------------------------------
function Validate_Applied_Medal(medal_id)
	return ((UNBOUND_MEDALS[medal_id] ~= nil) or (BOUND_MEDALS[medal_id] ~= nil))
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Local_User_Applied_Medals(applied_medals)
	
	if ( Is_Gamepad_Active() ) then

		if ( ( applied_medals[PG_FACTION_NOVUS][1] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_0, applied_medals[PG_FACTION_NOVUS][1][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_0, 0)
		end
		if ( ( applied_medals[PG_FACTION_NOVUS][2] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_1, applied_medals[PG_FACTION_NOVUS][2][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_1, 0)
		end
		if ( ( applied_medals[PG_FACTION_NOVUS][3] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_2, applied_medals[PG_FACTION_NOVUS][3][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_NOVUS_2, 0)
		end
		
		if ( ( applied_medals[PG_FACTION_ALIEN][1] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_0, applied_medals[PG_FACTION_ALIEN][1][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_0, 0)
		end
		if ( ( applied_medals[PG_FACTION_ALIEN][2] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_1, applied_medals[PG_FACTION_ALIEN][2][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_1, 0)
		end
		if ( ( applied_medals[PG_FACTION_ALIEN][3] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_2, applied_medals[PG_FACTION_ALIEN][3][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_ALIEN_2, 0)
		end
		
		if ( ( applied_medals[PG_FACTION_MASARI][1] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_0, applied_medals[PG_FACTION_MASARI][1][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_0, 0)
		end
		if ( ( applied_medals[PG_FACTION_MASARI][2] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_1, applied_medals[PG_FACTION_MASARI][2][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_1, 0)
		end
		if ( ( applied_medals[PG_FACTION_MASARI][3] ) ) then
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_2, applied_medals[PG_FACTION_MASARI][3][2])
		else
			Set_Profile_Value(PP_APPLIED_LIVE_MEDALS_MASARI_2, 0)
		end
		
		Commit_Profile_Values()
		return
	end
	

	-- The model stored in the registry is a map keyed by gamertag whose values
	-- are maps keyed by faction whose values are iarrays.  Confusing?
	local default_model = Create_Default_Applied_Medals_Table() 
	local user_models = Get_Profile_Value(PP_APPLIED_LIVE_MEDALS, default_model)
	local user_id = Net.Get_Offline_XUID()
	user_models[user_id] = applied_medals
	Set_Profile_Value(PP_APPLIED_LIVE_MEDALS, user_models)

end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Create_Base_Boolean_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Set_Local_User_Applied_Medals = nil
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
