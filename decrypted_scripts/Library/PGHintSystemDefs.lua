-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGHintSystemDefs.lua#33 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGHintSystemDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Gernert $
--
--            $Change: 76950 $
--
--          $DateTime: 2007/07/17 12:06:54 $
--
--          $Revision: #33 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGAchievementsCommon")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGHintSystemDefs_Init()
	Init_Hints()
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A C H I E V E M E N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Hints()

	PGAchievementsCommon_Init()

	-- ** Offline Achievement Map **
	HintSystemMap = {}

	-- ** IDs **
	TEST_HINT_ONE_ID								= Declare_Enum(1)
	HintSystemStart								= TEST_HINT_ONE_ID

	TEST_HINT_TWO_ID								= Declare_Enum()
	TEST_HINT_THREE_ID							= Declare_Enum()
	TEST_HINT_FOUR_ID								= Declare_Enum()

	HINT_BUILT_ALIEN_ARRIVAL_SITE				= Declare_Enum()
	HINT_BUILT_ALIEN_GRAVITIC_MANIPULATOR	= Declare_Enum()
	HINT_BUILT_ALIEN_SCAN_DRONE				= Declare_Enum()
	HINT_BUILT_ALIEN_MASS_DROP					= Declare_Enum()
	HINT_BUILT_ALIEN_RADIATION_SPITTER		= Declare_Enum()
	HINT_BUILT_ALIEN_RELOCATOR					= Declare_Enum()
	HINT_BUILT_ALIEN_WALKER_HABITAT			= Declare_Enum()
	HINT_BUILT_ALIEN_WALKER_ASSEMBLY			= Declare_Enum()
	HINT_BUILT_ALIEN_WALKER_SCIENCE			= Declare_Enum()
	
	HINT_BUILT_ALIEN_HERO_KAMAL_REX			= Declare_Enum()
	HINT_BUILT_ALIEN_HERO_NUFAI				= Declare_Enum()
	HINT_BUILT_ALIEN_HERO_ORLOK				= Declare_Enum()
	HINT_BUILT_ALIEN_BRUTE						= Declare_Enum()
	HINT_BUILT_ALIEN_GLYPH_CARVER				= Declare_Enum()
	HINT_BUILT_ALIEN_GRUNT						= Declare_Enum()
	HINT_BUILT_ALIEN_SCIENCE_TEAM				= Declare_Enum()
	HINT_BUILT_ALIEN_CYLINDER					= Declare_Enum()
	HINT_BUILT_ALIEN_DEFILER					= Declare_Enum()
	HINT_BUILT_ALIEN_SAUCER						= Declare_Enum()
	HINT_BUILT_ALIEN_REAPER_TURRET			= Declare_Enum()
	HINT_BUILT_ALIEN_TANK						= Declare_Enum()
	
	HINT_BUILT_NOVUS_AIRCRAFT_ASSEMBLY		= Declare_Enum()
	HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR	= Declare_Enum()
	HINT_BUILT_NOVUS_INPUT_STATION			= Declare_Enum()
	HINT_BUILT_NOVUS_POWER_NEXUS				= Declare_Enum()
	HINT_BUILT_NOVUS_REDIRECTION_TURRET		= Declare_Enum()
	HINT_BUILT_NOVUS_COMMAND_CORE				= Declare_Enum()
	HINT_BUILT_NOVUS_ROBOTIC_ASSEMBLY		= Declare_Enum()
	HINT_BUILT_NOVUS_SCIENCE_LAB				= Declare_Enum()
	HINT_BUILT_NOVUS_SIGNAL_TOWER				= Declare_Enum()
	HINT_BUILT_NOVUS_EMP_SUPERWEAPON			= Declare_Enum()
	HINT_BUILT_NOVUS_VEHICLE_ASSEMBLY		= Declare_Enum()
		
	HINT_BUILT_NOVUS_HERO_FOUNDER				= Declare_Enum()
	HINT_BUILT_NOVUS_HERO_MECH					= Declare_Enum()
	HINT_BUILT_NOVUS_HERO_VERTIGO				= Declare_Enum()
	HINT_BUILT_NOVUS_REFLEX_TROOPER			= Declare_Enum()
	HINT_BUILT_NOVUS_ROBOTIC_INFANTRY		= Declare_Enum()
	HINT_BUILT_NOVUS_VARIANT					= Declare_Enum()
	HINT_BUILT_NOVUS_AMPLIFIER					= Declare_Enum()
	HINT_BUILT_NOVUS_ANTIMATTER_TANK			= Declare_Enum()
	HINT_BUILT_NOVUS_CONSTRUCTOR				= Declare_Enum()
	HINT_BUILT_NOVUS_DERVISH_JET				= Declare_Enum()
	HINT_BUILT_NOVUS_FIELD_INVERTER			= Declare_Enum()
	HINT_BUILT_NOVUS_CORRUPTOR             = Declare_Enum()
	HINT_BUILT_NOVUS_HACKER                = Declare_Enum()
	
	HINT_BUILT_MASARI_AIR_INSPIRATION		= Declare_Enum()
	HINT_BUILT_MASARI_ELEMENTAL_COLLECTOR	= Declare_Enum()
	HINT_BUILT_MASARI_ELEMENTAL_CONTROLLER	= Declare_Enum()
	HINT_BUILT_MASARI_FOUNDATION				= Declare_Enum()
	HINT_BUILT_MASARI_GROUND_INSPIRATION	= Declare_Enum()
	HINT_BUILT_MASARI_GUARDIAN					= Declare_Enum()
	HINT_BUILT_MASARI_INFANTRY_INSPIRATION	= Declare_Enum()
	HINT_BUILT_MASARI_NEOPHYTES_LAB			= Declare_Enum()
	HINT_BUILT_MASARI_NATURAL_INTERPRETER	= Declare_Enum()
	HINT_BUILT_MASARI_SKY_GUARDIAN			= Declare_Enum()
	
	HINT_BUILT_MASARI_FIGMENT					= Declare_Enum()
	HINT_BUILT_MASARI_SEEKER					= Declare_Enum()
	HINT_BUILT_MASARI_SKYLORD					= Declare_Enum()
	HINT_BUILT_MASARI_HERO_ALATEA				= Declare_Enum()
	HINT_BUILT_MASARI_HERO_CHAROS				= Declare_Enum()
	HINT_BUILT_MASARI_HERO_ZESSUS				= Declare_Enum()
	HINT_BUILT_MASARI_ARCHITECT				= Declare_Enum()
	HINT_BUILT_MASARI_AVENGER					= Declare_Enum()
	HINT_BUILT_MASARI_DISCIPLE					= Declare_Enum()
	HINT_BUILT_MASARI_SEER						= Declare_Enum()
	HINT_BUILT_MASARI_ENFORCER					= Declare_Enum()
	HINT_BUILT_MASARI_PEACEBRINGER			= Declare_Enum()
	HINT_BUILT_MASARI_SENTRY					= Declare_Enum()

	HINT_SYSTEM_HINT_SYSTEM						= Declare_Enum()
	HINT_SYSTEM_OBJECTIVES		= Declare_Enum()
	HINT_SYSTEM_HEROES							= Declare_Enum()
	HINT_SYSTEM_SELECTING_HEROES				= Declare_Enum()
	HINT_SYSTEM_SCROLLING						= Declare_Enum()
	HINT_SYSTEM_SCROLLING_02					= Declare_Enum()
	HINT_SYSTEM_ROTATE_VIEW						= Declare_Enum()
	HINT_SYSTEM_ZOOMING							= Declare_Enum()
	HINT_SYSTEM_RESET_VIEW						= Declare_Enum()
	HINT_SYSTEM_UNIT_SELECTION					= Declare_Enum()
	HINT_SYSTEM_MOVING							= Declare_Enum()
	HINT_SYSTEM_FORCE_MARCH						= Declare_Enum()
	HINT_SYSTEM_ATTACKING						= Declare_Enum()
	HINT_SYSTEM_MULTIPLE_UNITS					= Declare_Enum()
	HINT_SYSTEM_SIMILAR_UNITS					= Declare_Enum()
	HINT_SYSTEM_ATTACKING_MULTIPLE			= Declare_Enum()
	HINT_SYSTEM_FORCE_FIRE						= Declare_Enum()
	HINT_SYSTEM_CONTROL_GROUPS					= Declare_Enum()
	HINT_SYSTEM_VIEWING_GROUPS					= Declare_Enum()
	HINT_SYSTEM_ABILITIES						= Declare_Enum()
	HINT_SYSTEM_UNTARGETED_ABILITIES			= Declare_Enum()
	HINT_SYSTEM_SHARED_ABILITIES				= Declare_Enum()
	HINT_SYSTEM_SHARED_TARGETING				= Declare_Enum()
	HINT_SYSTEM_RADAR								= Declare_Enum()
	HINT_SYSTEM_RADAR_MOVEMENT					= Declare_Enum()
	HINT_SYSTEM_GARRISONING						= Declare_Enum()
	HINT_SYSTEM_EXITING							= Declare_Enum()
	HINT_SYSTEM_CAPTURING						= Declare_Enum()
	HINT_SYSTEM_CONSTRUCTING_UNITS			= Declare_Enum()
	HINT_SYSTEM_RALLY_POINTS					= Declare_Enum()
	HINT_SYSTEM_RESOURCES						= Declare_Enum()
	HINT_SYSTEM_CONSTRUCTING_BUILDINGS		= Declare_Enum()
	HINT_SYSTEM_CONSTRUCTION					= Declare_Enum()
	HINT_SYSTEM_ROTATING							= Declare_Enum()
	HINT_SYSTEM_DEPENDENCIES					= Declare_Enum()
	HINT_SYSTEM_NOVUS_POWER						= Declare_Enum()
	HINT_SYSTEM_NOVUS_MULTIPLE_CONSTRUCTORS = Declare_Enum()
	HINT_SYSTEM_NOVUS_PATCHES					= Declare_Enum()
	
	HINT_TUT01_REINFORCEMENTS_HERE			= Declare_Enum()

	HINT_HM01_ORLOK_SIEGE_ABILITY				= Declare_Enum()
	HINT_HM01_WALKER_HARDPOINTS				= Declare_Enum()

	HINT_HM02_COWS									= Declare_Enum()
	HINT_HM02_WALL									= Declare_Enum()
	HINT_HM02_VIRUS								= Declare_Enum()
	
	HINT_TUT02_BUILDING_UNITS					= Declare_Enum()
	
	HINT_NM01_BUILDING_STRUCTURES				= Declare_Enum()
	HINT_NM01_POWER_NETWORK						= Declare_Enum()
	HINT_NM01_FLOW									= Declare_Enum()
	
	HINT_NM02_VERTIGO_UPLOAD					= Declare_Enum()
	HINT_NM02_VERTIGO_DOWNLOAD					= Declare_Enum()
	
	HINT_NM05_PATCHES								= Declare_Enum()
	
	HINT_MM01_MODES                        = Declare_Enum()

	HINT_NM02_HACKER_FIREWALL                        = Declare_Enum()
	HINT_NM03_VIRUS_EXPLOIT                        = Declare_Enum()
	
	HINT_MM02_ARCHITECTS                        = Declare_Enum()
	HINT_MM02_TRANSPORTS                        = Declare_Enum()
	HINT_MM02_RESEARCH                        = Declare_Enum()
	HINT_MM02_UNIT_MANAGEMENT                        = Declare_Enum()
	HINT_MM02_HOW_TO_BUILD_STRUCTURES                        = Declare_Enum()
	HINT_MM02_HOW_TO_BUILD_UNITS                        = Declare_Enum()
	HINT_MM02_MOVING_UNITS                        = Declare_Enum()
	HINT_MM02_RESEARCH_ADD                        = Declare_Enum()
	
	HINT_NM04_CAPTURING							= Declare_Enum()
	HINT_NM04_FIELDINVERTERS			= Declare_Enum()
	HINT_NM04_REPAIRING				= Declare_Enum()
	
	HINT_MM02_MISSION_COMPLETE                        = Declare_Enum()
	
	HINT_SYSTEM_END								= Declare_Enum()
	HintSystemEnd									= HINT_SYSTEM_END


-- **********************
-- ** Hint Definitions **
-- **********************
	local hint


-- Default Test Hints

	-- TEST_HINT_ONE
	hint = {}
	hint.Id = TEST_HINT_ONE_ID
	hint.Text = Create_Wide_String("Test Hint One Text.")
	HintSystemMap[TEST_HINT_ONE_ID] = hint

	-- TEST_HINT_TWO
	hint = {}
	hint.Id = TEST_HINT_TWO_ID
	hint.Text = Create_Wide_String("Test Hint Two Text.\nA\nA\nA\nA\nA\nA\nA\nA\nA\nA\nThis is a really long line so that we can test the width of these here hints.   Isn't it nice they resize now??")
	HintSystemMap[TEST_HINT_TWO_ID] = hint

	-- TEST_HINT_THREE
	hint = {}
	hint.Id = TEST_HINT_THREE_ID
	hint.Text = Create_Wide_String("Test Hint Three Text.")
	HintSystemMap[TEST_HINT_THREE_ID] = hint

	-- TEST_HINT_FOUR
	hint = {}
	hint.Id = TEST_HINT_FOUR_ID
	hint.Text = Create_Wide_String("Test Hint Four Text.")
	HintSystemMap[TEST_HINT_FOUR_ID] = hint


-- Alien Construction Hints

	-- HINT_BUILT_ALIEN_ARRIVAL_SITE
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_ARRIVAL_SITE
   hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_ARRIVAL_SITE")
	HintSystemMap[HINT_BUILT_ALIEN_ARRIVAL_SITE] = hint

	-- HINT_BUILT_ALIEN_GRAVITIC_MANIPULATOR
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_GRAVITIC_MANIPULATOR
   hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_GRAVITIC_MANIPULATOR")
	HintSystemMap[HINT_BUILT_ALIEN_GRAVITIC_MANIPULATOR] = hint

	-- HINT_BUILT_ALIEN_SCAN_DRONE
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_SCAN_DRONE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_SCAN_DRONE")
	HintSystemMap[HINT_BUILT_ALIEN_SCAN_DRONE] = hint

	-- HINT_BUILT_ALIEN_MASS_DROP
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_MASS_DROP
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_MASS_DROP")
	HintSystemMap[HINT_BUILT_ALIEN_MASS_DROP] = hint

	-- HINT_BUILT_ALIEN_RADIATION_SPITTER
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_RADIATION_SPITTER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_RADIATION_SPITTER")
	HintSystemMap[HINT_BUILT_ALIEN_RADIATION_SPITTER] = hint

	-- HINT_BUILT_ALIEN_RELOCATOR
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_RELOCATOR
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_RELOCATOR")
	HintSystemMap[HINT_BUILT_ALIEN_RELOCATOR] = hint

	-- HINT_BUILT_ALIEN_WALKER_HABITAT
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_WALKER_HABITAT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_WALKER_HABITAT")
	HintSystemMap[HINT_BUILT_ALIEN_WALKER_HABITAT] = hint

	-- HINT_BUILT_ALIEN_WALKER_ASSEMBLY
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_WALKER_ASSEMBLY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_WALKER_ASSEMBLY")
	HintSystemMap[HINT_BUILT_ALIEN_WALKER_ASSEMBLY] = hint

	-- HINT_BUILT_ALIEN_WALKER_SCIENCE
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_WALKER_SCIENCE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_WALKER_SCIENCE")
	HintSystemMap[HINT_BUILT_ALIEN_WALKER_SCIENCE] = hint

	-- HINT_BUILT_ALIEN_HERO_KAMAL_REX
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_HERO_KAMAL_REX
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_HERO_KAMAL_REX")
	HintSystemMap[HINT_BUILT_ALIEN_HERO_KAMAL_REX] = hint

	-- HINT_BUILT_ALIEN_HERO_NUFAI
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_HERO_NUFAI
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_HERO_NUFAI")
	HintSystemMap[HINT_BUILT_ALIEN_HERO_NUFAI] = hint

	-- HINT_BUILT_ALIEN_HERO_ORLOK
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_HERO_ORLOK
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_HERO_ORLOK")
	HintSystemMap[HINT_BUILT_ALIEN_HERO_ORLOK] = hint

	-- HINT_BUILT_ALIEN_BRUTE
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_BRUTE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_BRUTE")
	HintSystemMap[HINT_BUILT_ALIEN_BRUTE] = hint

	-- HINT_BUILT_ALIEN_GLYPH_CARVER
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_GLYPH_CARVER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_GLYPH_CARVER")
	HintSystemMap[HINT_BUILT_ALIEN_GLYPH_CARVER] = hint

	-- HINT_BUILT_ALIEN_GRUNT
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_GRUNT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_GRUNT")
	HintSystemMap[HINT_BUILT_ALIEN_GRUNT] = hint

	-- HINT_BUILT_ALIEN_SCIENCE_TEAM
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_SCIENCE_TEAM
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_SCIENCE_TEAM")
	HintSystemMap[HINT_BUILT_ALIEN_SCIENCE_TEAM] = hint

	-- HINT_BUILT_ALIEN_CYLINDER
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_CYLINDER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_CYLINDER")
	HintSystemMap[HINT_BUILT_ALIEN_CYLINDER] = hint

	-- HINT_BUILT_ALIEN_DEFILER
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_DEFILER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_DEFILER")
	HintSystemMap[HINT_BUILT_ALIEN_DEFILER] = hint

	-- HINT_BUILT_ALIEN_SAUCER
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_SAUCER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_SAUCER")
	HintSystemMap[HINT_BUILT_ALIEN_SAUCER] = hint

	-- HINT_BUILT_ALIEN_REAPER_TURRET
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_REAPER_TURRET
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_REAPER_TURRET")
	HintSystemMap[HINT_BUILT_ALIEN_REAPER_TURRET] = hint

	-- HINT_BUILT_ALIEN_TANK
	hint = {}
	hint.Id = HINT_BUILT_ALIEN_TANK
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_TANK")
	HintSystemMap[HINT_BUILT_ALIEN_TANK] = hint


-- Novus Construction Hints

	-- HINT_BUILT_NOVUS_AIRCRAFT_ASSEMBLY
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_AIRCRAFT_ASSEMBLY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_AIRCRAFT_ASSEMBLY")
	HintSystemMap[HINT_BUILT_NOVUS_AIRCRAFT_ASSEMBLY] = hint

	-- HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR")
	HintSystemMap[HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR] = hint

	-- HINT_BUILT_NOVUS_INPUT_STATION
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_INPUT_STATION
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_INPUT_STATION")
	HintSystemMap[HINT_BUILT_NOVUS_INPUT_STATION] = hint

	-- HINT_BUILT_NOVUS_POWER_NEXUS
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_POWER_NEXUS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_POWER_NEXUS")
	HintSystemMap[HINT_BUILT_NOVUS_POWER_NEXUS] = hint

	-- HINT_BUILT_NOVUS_REDIRECTION_TURRET
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_REDIRECTION_TURRET
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_REDIRECTION_TURRET")
	HintSystemMap[HINT_BUILT_NOVUS_REDIRECTION_TURRET] = hint

	-- HINT_BUILT_NOVUS_COMMAND_CORE
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_COMMAND_CORE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_COMMAND_CORE")
	HintSystemMap[HINT_BUILT_NOVUS_COMMAND_CORE] = hint

	-- HINT_BUILT_NOVUS_ROBOTIC_ASSEMBLY
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_ROBOTIC_ASSEMBLY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_ROBOTIC_ASSEMBLY")
	HintSystemMap[HINT_BUILT_NOVUS_ROBOTIC_ASSEMBLY] = hint

	-- HINT_BUILT_NOVUS_SCIENCE_LAB
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_SCIENCE_LAB
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_SCIENCE_LAB")
	HintSystemMap[HINT_BUILT_NOVUS_SCIENCE_LAB] = hint

	-- HINT_BUILT_NOVUS_SIGNAL_TOWER
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_SIGNAL_TOWER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_SIGNAL_TOWER")
	HintSystemMap[HINT_BUILT_NOVUS_SIGNAL_TOWER] = hint

	-- HINT_BUILT_NOVUS_EMP_SUPERWEAPON
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_EMP_SUPERWEAPON
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_EMP_SUPERWEAPON")
	HintSystemMap[HINT_BUILT_NOVUS_EMP_SUPERWEAPON] = hint

	-- HINT_BUILT_NOVUS_VEHICLE_ASSEMBLY
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_VEHICLE_ASSEMBLY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_VEHICLE_ASSEMBLY")
	HintSystemMap[HINT_BUILT_NOVUS_VEHICLE_ASSEMBLY] = hint

	-- HINT_BUILT_NOVUS_HERO_FOUNDER
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_HERO_FOUNDER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HERO_FOUNDER")
	HintSystemMap[HINT_BUILT_NOVUS_HERO_FOUNDER] = hint
		
	-- HINT_BUILT_NOVUS_HERO_MECH
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_HERO_MECH
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HERO_MECH")
	HintSystemMap[HINT_BUILT_NOVUS_HERO_MECH] = hint

	-- HINT_BUILT_NOVUS_HERO_VERTIGO
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_HERO_VERTIGO
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HERO_VERTIGO")
	HintSystemMap[HINT_BUILT_NOVUS_HERO_VERTIGO] = hint

	-- HINT_BUILT_NOVUS_REFLEX_TROOPER
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_REFLEX_TROOPER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_REFLEX_TROOPER")
	HintSystemMap[HINT_BUILT_NOVUS_REFLEX_TROOPER] = hint

	-- HINT_BUILT_NOVUS_ROBOTIC_INFANTRY
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_ROBOTIC_INFANTRY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_ROBOTIC_INFANTRY")
	HintSystemMap[HINT_BUILT_NOVUS_ROBOTIC_INFANTRY] = hint

	-- HINT_BUILT_NOVUS_VARIANT
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_VARIANT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_VARIANT")
	HintSystemMap[HINT_BUILT_NOVUS_VARIANT] = hint

	-- HINT_BUILT_NOVUS_AMPLIFIER
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_AMPLIFIER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_AMPLIFIER")
	HintSystemMap[HINT_BUILT_NOVUS_AMPLIFIER] = hint

	-- HINT_BUILT_NOVUS_ANTIMATTER_TANK
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_ANTIMATTER_TANK
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_ANTIMATTER_TANK")
	HintSystemMap[HINT_BUILT_NOVUS_ANTIMATTER_TANK] = hint

	-- HINT_BUILT_NOVUS_CONSTRUCTOR
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_CONSTRUCTOR
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_CONSTRUCTOR")
	HintSystemMap[HINT_BUILT_NOVUS_CONSTRUCTOR] = hint

	-- HINT_BUILT_NOVUS_DERVISH_JET
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_DERVISH_JET
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_DERVISH_JET")
	HintSystemMap[HINT_BUILT_NOVUS_DERVISH_JET] = hint

	-- HINT_BUILT_NOVUS_FIELD_INVERTER
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_FIELD_INVERTER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_FIELD_INVERTER")
	HintSystemMap[HINT_BUILT_NOVUS_FIELD_INVERTER] = hint

	-- HINT_BUILT_NOVUS_CORRUPTOR
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_CORRUPTOR
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_CORRUPTOR")
	HintSystemMap[HINT_BUILT_NOVUS_CORRUPTOR] = hint

	-- HINT_BUILT_NOVUS_HACKER
	hint = {}
	hint.Id = HINT_BUILT_NOVUS_HACKER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HACKER")
	HintSystemMap[HINT_BUILT_NOVUS_HACKER] = hint


	-- Masari Construction Hints
	
	-- HINT_BUILT_MASARI_AIR_INSPIRATION
	hint = {}
	hint.Id = HINT_BUILT_MASARI_AIR_INSPIRATION
   hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_AIR_INSPIRATION")
	HintSystemMap[HINT_BUILT_MASARI_AIR_INSPIRATION] = hint

	-- HINT_BUILT_MASARI_ELEMENTAL_COLLECTOR
	hint = {}
	hint.Id = HINT_BUILT_MASARI_ELEMENTAL_COLLECTOR
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ELEMENTAL_COLLECTOR")
	HintSystemMap[HINT_BUILT_MASARI_ELEMENTAL_COLLECTOR] = hint

	-- HINT_BUILT_MASARI_ELEMENTAL_CONTROLLER
	hint = {}
	hint.Id = HINT_BUILT_MASARI_ELEMENTAL_CONTROLLER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ELEMENTAL_CONTROLLER")
	HintSystemMap[HINT_BUILT_MASARI_ELEMENTAL_CONTROLLER] = hint

	-- HINT_BUILT_MASARI_FOUNDATION
	hint = {}
	hint.Id = HINT_BUILT_MASARI_FOUNDATION
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_FOUNDATION")
	HintSystemMap[HINT_BUILT_MASARI_FOUNDATION] = hint

	-- HINT_BUILT_MASARI_GROUND_INSPIRATION
	hint = {}
	hint.Id = HINT_BUILT_MASARI_GROUND_INSPIRATION
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_GROUND_INSPIRATION")
	HintSystemMap[HINT_BUILT_MASARI_GROUND_INSPIRATION] = hint

	-- HINT_BUILT_MASARI_GUARDIAN
	hint = {}
	hint.Id = HINT_BUILT_MASARI_GUARDIAN
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_GUARDIAN")
	HintSystemMap[HINT_BUILT_MASARI_GUARDIAN] = hint

	-- HINT_BUILT_MASARI_INFANTRY_INSPIRATION
	hint = {}
	hint.Id = HINT_BUILT_MASARI_INFANTRY_INSPIRATION
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_INFANTRY_INSPIRATION")
	HintSystemMap[HINT_BUILT_MASARI_INFANTRY_INSPIRATION] = hint

	-- HINT_BUILT_MASARI_NEOPHYTES_LAB
	hint = {}
	hint.Id = HINT_BUILT_MASARI_NEOPHYTES_LAB
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_NEOPHYTES_LAB")
	HintSystemMap[HINT_BUILT_MASARI_NEOPHYTES_LAB] = hint

	-- HINT_BUILT_MASARI_NATURAL_INTERPRETER
	hint = {}
	hint.Id = HINT_BUILT_MASARI_NATURAL_INTERPRETER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_NATURAL_INTERPRETER")
	HintSystemMap[HINT_BUILT_MASARI_NATURAL_INTERPRETER] = hint

	-- HINT_BUILT_MASARI_SKY_GUARDIAN
	hint = {}
	hint.Id = HINT_BUILT_MASARI_SKY_GUARDIAN
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SKY_GUARDIAN")
	HintSystemMap[HINT_BUILT_MASARI_SKY_GUARDIAN] = hint

	-- HINT_BUILT_MASARI_FIGMENT
	hint = {}
	hint.Id = HINT_BUILT_MASARI_FIGMENT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_FIGMENT")
	HintSystemMap[HINT_BUILT_MASARI_FIGMENT] = hint

	-- HINT_BUILT_MASARI_SEEKER
	hint = {}
	hint.Id = HINT_BUILT_MASARI_SEEKER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SEEKER")
	HintSystemMap[HINT_BUILT_MASARI_SEEKER] = hint

	-- HINT_BUILT_MASARI_SKYLORD
	hint = {}
	hint.Id = HINT_BUILT_MASARI_SKYLORD
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SKYLORD")
	HintSystemMap[HINT_BUILT_MASARI_SKYLORD] = hint

	-- HINT_BUILT_MASARI_HERO_ALATEA
	hint = {}
	hint.Id = HINT_BUILT_MASARI_HERO_ALATEA
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_HERO_ALATEA")
	HintSystemMap[HINT_BUILT_MASARI_HERO_ALATEA] = hint

	-- HINT_BUILT_MASARI_HERO_CHAROS
	hint = {}
	hint.Id = HINT_BUILT_MASARI_HERO_CHAROS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_HERO_CHAROS")
	HintSystemMap[HINT_BUILT_MASARI_HERO_CHAROS] = hint

	-- HINT_BUILT_MASARI_HERO_ZESSUS
	hint = {}
	hint.Id = HINT_BUILT_MASARI_HERO_ZESSUS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_HERO_ZESSUS")
	HintSystemMap[HINT_BUILT_MASARI_HERO_ZESSUS] = hint

	-- HINT_BUILT_MASARI_ARCHITECT
	hint = {}
	hint.Id = HINT_BUILT_MASARI_ARCHITECT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ARCHITECT")
	HintSystemMap[HINT_BUILT_MASARI_ARCHITECT] = hint

	-- HINT_BUILT_MASARI_DISCIPLE
	hint = {}
	hint.Id = HINT_BUILT_MASARI_DISCIPLE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_DISCIPLE")
	HintSystemMap[HINT_BUILT_MASARI_DISCIPLE] = hint

	-- HINT_BUILT_MASARI_SEER
	hint = {}
	hint.Id = HINT_BUILT_MASARI_SEER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SEER")
	HintSystemMap[HINT_BUILT_MASARI_SEER] = hint

	-- HINT_BUILT_MASARI_ENFORCER
	hint = {}
	hint.Id = HINT_BUILT_MASARI_ENFORCER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ENFORCER")
	HintSystemMap[HINT_BUILT_MASARI_ENFORCER] = hint

	-- HINT_BUILT_MASARI_PEACEBRINGER
	hint = {}
	hint.Id = HINT_BUILT_MASARI_PEACEBRINGER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_PEACEBRINGER")
	HintSystemMap[HINT_BUILT_MASARI_PEACEBRINGER] = hint

	-- HINT_BUILT_MASARI_SENTRY
	hint = {}
	hint.Id = HINT_BUILT_MASARI_SENTRY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SENTRY")
	HintSystemMap[HINT_BUILT_MASARI_SENTRY] = hint


	-- Basic Hint System Hints

	hint = {}
	hint.Id = HINT_SYSTEM_HINT_SYSTEM
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_HINT_SYSTEM")
	HintSystemMap[HINT_SYSTEM_HINT_SYSTEM] = hint
	
	hint = {}
	hint.Id = HINT_SYSTEM_OBJECTIVES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_OBJECTIVES")
	HintSystemMap[HINT_SYSTEM_OBJECTIVES] = hint
	
	hint = {}
	hint.Id = HINT_SYSTEM_HEROES
   hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_HEROES")
	HintSystemMap[HINT_SYSTEM_HEROES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_SELECTING_HEROES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SELECTING_HEROES")
	HintSystemMap[HINT_SYSTEM_SELECTING_HEROES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_SCROLLING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SCROLLING")
	HintSystemMap[HINT_SYSTEM_SCROLLING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_SCROLLING_02
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SCROLLING_02")
	HintSystemMap[HINT_SYSTEM_SCROLLING_02] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_ROTATE_VIEW
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ROTATE_VIEW")
	HintSystemMap[HINT_SYSTEM_ROTATE_VIEW] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_ZOOMING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ZOOMING")
	HintSystemMap[HINT_SYSTEM_ZOOMING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_RESET_VIEW
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RESET_VIEW")
	HintSystemMap[HINT_SYSTEM_RESET_VIEW] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_UNIT_SELECTION
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_UNIT_SELECTION")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_SYSTEM_UNIT_SELECTION] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_MOVING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_MOVING")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_SYSTEM_MOVING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_FORCE_MARCH
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_FORCE_MARCH")
	HintSystemMap[HINT_SYSTEM_FORCE_MARCH] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_ATTACKING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ATTACKING")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_SYSTEM_ATTACKING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_MULTIPLE_UNITS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_MULTIPLE_UNITS")
	HintSystemMap[HINT_SYSTEM_MULTIPLE_UNITS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_SIMILAR_UNITS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SIMILAR_UNITS")
	HintSystemMap[HINT_SYSTEM_SIMILAR_UNITS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_ATTACKING_MULTIPLE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ATTACKING_MULTIPLE")
	HintSystemMap[HINT_SYSTEM_ATTACKING_MULTIPLE] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_FORCE_FIRE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_FORCE_FIRE")
	HintSystemMap[HINT_SYSTEM_FORCE_FIRE] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_CONTROL_GROUPS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONTROL_GROUPS")
	HintSystemMap[HINT_SYSTEM_CONTROL_GROUPS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_VIEWING_GROUPS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_VIEWING_GROUPS")
	HintSystemMap[HINT_SYSTEM_VIEWING_GROUPS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_ABILITIES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ABILITIES")
	HintSystemMap[HINT_SYSTEM_ABILITIES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_UNTARGETED_ABILITIES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_UNTARGETED_ABILITIES")
	HintSystemMap[HINT_SYSTEM_UNTARGETED_ABILITIES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_SHARED_ABILITIES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SHARED_ABILITIES")
	HintSystemMap[HINT_SYSTEM_SHARED_ABILITIES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_SHARED_TARGETING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SHARED_TARGETING")
	HintSystemMap[HINT_SYSTEM_SHARED_TARGETING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_RADAR
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RADAR")
	HintSystemMap[HINT_SYSTEM_RADAR] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_RADAR_MOVEMENT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RADAR_MOVEMENT")
	HintSystemMap[HINT_SYSTEM_RADAR_MOVEMENT] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_GARRISONING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_GARRISONING")
	HintSystemMap[HINT_SYSTEM_GARRISONING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_EXITING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_EXITING")
	HintSystemMap[HINT_SYSTEM_EXITING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_CAPTURING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CAPTURING")
	HintSystemMap[HINT_SYSTEM_CAPTURING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_CONSTRUCTING_UNITS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONSTRUCTING_UNITS")
	HintSystemMap[HINT_SYSTEM_CONSTRUCTING_UNITS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_RALLY_POINTS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RALLY_POINTS")
	HintSystemMap[HINT_SYSTEM_RALLY_POINTS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_RESOURCES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RESOURCES")
	HintSystemMap[HINT_SYSTEM_RESOURCES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_CONSTRUCTING_BUILDINGS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONSTRUCTING_BUILDINGS")
	HintSystemMap[HINT_SYSTEM_CONSTRUCTING_BUILDINGS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_CONSTRUCTION
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONSTRUCTION")
	HintSystemMap[HINT_SYSTEM_CONSTRUCTION] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_ROTATING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ROTATING")
	HintSystemMap[HINT_SYSTEM_ROTATING] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_DEPENDENCIES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_DEPENDENCIES")
	HintSystemMap[HINT_SYSTEM_DEPENDENCIES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_NOVUS_POWER
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_NOVUS_POWER")
	HintSystemMap[HINT_SYSTEM_DEPENDENCIES] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_NOVUS_MULTIPLE_CONSTRUCTORS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_NOVUS_MULTIPLE_CONSTRUCTORS")
	HintSystemMap[HINT_SYSTEM_NOVUS_MULTIPLE_CONSTRUCTORS] = hint

	hint = {}
	hint.Id = HINT_SYSTEM_NOVUS_PATCHES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_NOVUS_PATCHES")
	HintSystemMap[HINT_SYSTEM_NOVUS_PATCHES] = hint


   -- Tutorial 01 Specific Hints

   hint = {}
	hint.Id = HINT_TUT01_REINFORCEMENTS_HERE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_TUT01_REINFORCEMENTS_HERE")
	HintSystemMap[HINT_TUT01_REINFORCEMENTS_HERE] = hint


	-- Hierarchy 01 Specific Hints
	
	hint = {}
	hint.Id = HINT_HM01_ORLOK_SIEGE_ABILITY
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM01_ORLOK_SIEGE_ABILITY")
	HintSystemMap[HINT_HM01_ORLOK_SIEGE_ABILITY] = hint

	hint = {}
	hint.Id = HINT_HM01_WALKER_HARDPOINTS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM01_WALKER_HARDPOINTS")
	HintSystemMap[HINT_HM01_WALKER_HARDPOINTS] = hint


	-- Hierarchy 02 Specific Hints
	
	hint = {}
	hint.Id = HINT_HM02_COWS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM02_COWS")
	HintSystemMap[HINT_HM02_COWS] = hint
	
	hint = {}
	hint.Id = HINT_HM02_WALL
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM02_WALL")
	HintSystemMap[HINT_HM02_WALL] = hint
		
	hint = {}
	hint.Id = HINT_HM02_VIRUS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM02_VIRUS")
	HintSystemMap[HINT_HM02_VIRUS] = hint

	-- Tutorial 02 Specific Hints
	
	hint = {}
	hint.Id = HINT_TUT02_BUILDING_UNITS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_TUT02_BUILDING_UNITS")
	HintSystemMap[HINT_TUT02_BUILDING_UNITS] = hint

	-- Novus 01 Specific Hints
	
	hint = {}
	hint.Id = HINT_NM01_BUILDING_STRUCTURES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM01_BUILDING_STRUCTURES")
	HintSystemMap[HINT_NM01_BUILDING_STRUCTURES] = hint
	
	hint = {}
	hint.Id = HINT_NM01_POWER_NETWORK
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM01_POWER_NETWORK")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM01_POWER_NETWORK] = hint
	
	hint = {}
	hint.Id = HINT_NM01_FLOW
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM01_FLOW_ALT")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM01_FLOW] = hint
	
	-- Novus 02 Specific Hints
	
	hint = {}
	hint.Id = HINT_NM02_VERTIGO_UPLOAD
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM02_VERTIGO_UPLOAD")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM02_VERTIGO_UPLOAD] = hint
	
	hint = {}
	hint.Id = HINT_NM02_VERTIGO_DOWNLOAD
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM02_VERTIGO_DOWNLOAD")
	HintSystemMap[HINT_NM02_VERTIGO_DOWNLOAD] = hint
	
	-- Novus 05 Specific Hints
	
	hint = {}
	hint.Id = HINT_NM05_PATCHES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM05_PATCHES")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM05_PATCHES] = hint
	
	-- Masari 01 Specific Hints
	
	hint = {}
	hint.Id = HINT_MM01_MODES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM01_MASARI_MODES")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_MM01_MODES] = hint

	-- Novus 02 Specific Hints
	
	hint = {}
	hint.Id = HINT_NM02_HACKER_FIREWALL
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM02_HACKER_FIREWALL")
	HintSystemMap[HINT_NM02_HACKER_FIREWALL] = hint

	-- Novus 03 Specific Hints
	
	hint = {}
	hint.Id = HINT_NM03_VIRUS_EXPLOIT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM03_VIRUS_EXPLOIT")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM03_VIRUS_EXPLOIT] = hint
	
	-- Masari Global Hints
	
	hint = {}
	hint.Id = HINT_MM02_ARCHITECTS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_ARCHITECTS")
	HintSystemMap[HINT_MM02_ARCHITECTS] = hint

	hint = {}
	hint.Id = HINT_MM02_TRANSPORTS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_TRANSPORTS")
	HintSystemMap[HINT_MM02_TRANSPORTS] = hint

	hint = {}
	hint.Id = HINT_MM02_RESEARCH
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_RESEARCH")
	HintSystemMap[HINT_MM02_RESEARCH] = hint

	hint = {}
	hint.Id = HINT_MM02_UNIT_MANAGEMENT
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_UNIT_MANAGEMENT")
	HintSystemMap[HINT_MM02_UNIT_MANAGEMENT] = hint

	hint = {}
	hint.Id = HINT_MM02_HOW_TO_BUILD_STRUCTURES
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_HOW_TO_BUILD_STRUCTURES")
	HintSystemMap[HINT_MM02_HOW_TO_BUILD_STRUCTURES] = hint

	hint = {}
	hint.Id = HINT_MM02_HOW_TO_BUILD_UNITS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_HOW_TO_BUILD_UNITS")
	HintSystemMap[HINT_MM02_HOW_TO_BUILD_UNITS] = hint

	hint = {}
	hint.Id = HINT_MM02_MOVING_UNITS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_MOVING_UNITS")
	HintSystemMap[HINT_MM02_MOVING_UNITS] = hint

	hint = {}
	hint.Id = HINT_MM02_RESEARCH_ADD
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_RESEARCH_ADD")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_MM02_RESEARCH_ADD] = hint
	
		-- Novus 04 Specific Hints
	hint = {}
	hint.Id = HINT_NM04_CAPTURING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CAPTURING")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM04_CAPTURING] = hint
	
	
	hint = {}
	hint.Id = HINT_NM04_FIELDINVERTERS
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_FIELD_INVERTER")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM04_FIELDINVERTERS] = hint
	
	
	hint = {}
	hint.Id = HINT_NM04_REPAIRING
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM04_REPAIRING")
	hint.IgnoreTracking = true
	HintSystemMap[HINT_NM04_REPAIRING] = hint
	
	
	hint = {}
	hint.Id = HINT_MM02_MISSION_COMPLETE
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_MISSION_COMPLETE")
	HintSystemMap[HINT_MM02_MISSION_COMPLETE] = hint
	

end