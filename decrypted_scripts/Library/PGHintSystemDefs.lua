if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGHintSystemDefs.lua#27 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGHintSystemDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Gernert $
--
--            $Change: 93279 $
--
--          $DateTime: 2008/02/13 15:32:26 $
--
--          $Revision: #27 $
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
	HintSystemStart								= 1

-- The following 3 lines are required by the lua preprocessor.  1/22/2008 3:14:28 PM -- BMH
--[[




















































































































































































]]--
	HintSystemEnd									= 151


-- **********************
-- ** Hint Definitions **
-- **********************
	local hint


-- Default Test Hints

	-- TEST_HINT_ONE
	hint = {}
	hint.Id = 1
	hint.Text = Create_Wide_String("Test Hint One Text.")
	HintSystemMap[1] = hint

	-- TEST_HINT_TWO
	hint = {}
	hint.Id = 2
	hint.Text = Create_Wide_String("Test Hint Two Text.\nA\nA\nA\nA\nA\nA\nA\nA\nA\nA\nThis is a really long line so that we can test the width of these here hints.   Isn't it nice they resize now??")
	HintSystemMap[2] = hint

	-- TEST_HINT_THREE
	hint = {}
	hint.Id = 3
	hint.Text = Create_Wide_String("Test Hint Three Text.")
	HintSystemMap[3] = hint

	-- TEST_HINT_FOUR
	hint = {}
	hint.Id = 4
	hint.Text = Create_Wide_String("Test Hint Four Text.")
	HintSystemMap[4] = hint


-- Alien Construction Hints

	-- 5
	hint = {}
	hint.Id = 5
   hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_ARRIVAL_SITE")
	HintSystemMap[5] = hint

	-- 6
	hint = {}
	hint.Id = 6
   hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_GRAVITIC_MANIPULATOR")
	HintSystemMap[6] = hint

	-- 7
	hint = {}
	hint.Id = 7
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_SCAN_DRONE")
	HintSystemMap[7] = hint

	-- 8
	hint = {}
	hint.Id = 8
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_MASS_DROP")
	HintSystemMap[8] = hint

	-- 9
	hint = {}
	hint.Id = 9
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_RADIATION_SPITTER")
	HintSystemMap[9] = hint

	-- 10
	hint = {}
	hint.Id = 10
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_RELOCATOR")
	HintSystemMap[10] = hint

	-- 11
	hint = {}
	hint.Id = 11
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_WALKER_HABITAT")
	HintSystemMap[11] = hint

	-- 12
	hint = {}
	hint.Id = 12
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_WALKER_ASSEMBLY")
	HintSystemMap[12] = hint

	-- 13
	hint = {}
	hint.Id = 13
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_WALKER_SCIENCE")
	HintSystemMap[13] = hint

	-- 14
	hint = {}
	hint.Id = 14
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_HERO_KAMAL_REX")
	HintSystemMap[14] = hint

	-- 15
	hint = {}
	hint.Id = 15
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_HERO_NUFAI")
	HintSystemMap[15] = hint

	-- 16
	hint = {}
	hint.Id = 16
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_HERO_ORLOK")
	HintSystemMap[16] = hint

	-- 17
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 17
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_BRUTE")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_2D.tga"
	imagelist[2] = "Gamepad_HintImage_2E.tga"
	imagelist[3] = "Gamepad_HintImage_2F.tga"
	hint.Images = imagelist
	HintSystemMap[17] = hint
	


	-- 18
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 18
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_GLYPH_CARVER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_3D.tga"
	imagelist[2] = "Gamepad_HintImage_3E.tga"
	imagelist[3] = "Gamepad_HintImage_3F.tga"
	hint.Images = imagelist
	HintSystemMap[18] = hint

	-- 19
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 19
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_GRUNT")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_4D.tga"
	imagelist[2] = "Gamepad_HintImage_4E.tga"
	imagelist[3] = "Gamepad_HintImage_4F.tga"
	hint.Images = imagelist
	HintSystemMap[19] = hint

	-- 20
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 20
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_SCIENCE_TEAM")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_5D.tga"
	imagelist[2] = "Gamepad_HintImage_5E.tga"
	imagelist[3] = "Gamepad_HintImage_5F.tga"
	hint.Images = imagelist
	HintSystemMap[20] = hint

	-- 21
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 21
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_CYLINDER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_6D.tga"
	imagelist[2] = "Gamepad_HintImage_6E.tga"
	imagelist[3] = "Gamepad_HintImage_6F.tga"
	hint.Images = imagelist
	HintSystemMap[21] = hint

	-- 22
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 22
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_DEFILER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_7D.tga"
	imagelist[2] = "Gamepad_HintImage_7E.tga"
	imagelist[3] = "Gamepad_HintImage_7F.tga"
	hint.Images = imagelist
	HintSystemMap[22] = hint

	-- 23
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 23
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_SAUCER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_8D.tga"
	imagelist[2] = "Gamepad_HintImage_8E.tga"
	imagelist[3] = "Gamepad_HintImage_8F.tga"
	hint.Images = imagelist
	HintSystemMap[23] = hint

	-- 24
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 24
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_REAPER_TURRET")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_9D.tga"
	imagelist[2] = "Gamepad_HintImage_9E.tga"
	imagelist[3] = "Gamepad_HintImage_9F.tga"
	hint.Images = imagelist
	HintSystemMap[24] = hint

	-- 25
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 25
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_ALIEN_TANK")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_10D.tga"
	imagelist[2] = "Gamepad_HintImage_10E.tga"
	imagelist[3] = "Gamepad_HintImage_10F.tga"
	hint.Images = imagelist
	HintSystemMap[25] = hint


-- Novus Construction Hints

	-- 26
	hint = {}
	hint.Id = 26
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_AIRCRAFT_ASSEMBLY")
	HintSystemMap[26] = hint

	-- 27
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 27
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_11D.tga"
	imagelist[2] = "Gamepad_HintImage_11E.tga"
	imagelist[3] = "Gamepad_HintImage_11F.tga"
	hint.Images = imagelist
	HintSystemMap[27] = hint

	-- 28
	hint = {}
	hint.Id = 28
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_INPUT_STATION")
	HintSystemMap[28] = hint

	-- 29
	hint = {}
	hint.Id = 29
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_POWER_NEXUS")
	HintSystemMap[29] = hint

	-- 30
	hint = {}
	hint.Id = 30
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_REDIRECTION_TURRET")
	HintSystemMap[30] = hint

	-- 31
	hint = {}
	hint.Id = 31
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_COMMAND_CORE")
	HintSystemMap[31] = hint

	-- 32
	hint = {}
	hint.Id = 32
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_ROBOTIC_ASSEMBLY")
	HintSystemMap[32] = hint

	-- 33
	hint = {}
	hint.Id = 33
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_SCIENCE_LAB")
	HintSystemMap[33] = hint

	-- 34
	hint = {}
	hint.Id = 34
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_SIGNAL_TOWER")
	HintSystemMap[34] = hint

	-- 35
	hint = {}
	hint.Id = 35
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_EMP_SUPERWEAPON")
	HintSystemMap[35] = hint

	-- 36
	hint = {}
	hint.Id = 36
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_VEHICLE_ASSEMBLY")
	HintSystemMap[36] = hint

	-- 37
	hint = {}
	hint.Id = 37
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HERO_FOUNDER")
	HintSystemMap[37] = hint
		
	-- 38
	hint = {}
	hint.Id = 38
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HERO_MECH")
	HintSystemMap[38] = hint

	-- 39
	hint = {}
	hint.Id = 39
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HERO_VERTIGO")
	HintSystemMap[39] = hint

	-- 40
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 40
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_REFLEX_TROOPER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_12D.tga"
	imagelist[2] = "Gamepad_HintImage_12E.tga"
	imagelist[3] = "Gamepad_HintImage_12F.tga"
	hint.Images = imagelist
	HintSystemMap[40] = hint

	-- 41
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 41
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_ROBOTIC_INFANTRY")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_13D.tga"
	imagelist[2] = "Gamepad_HintImage_13E.tga"
	imagelist[3] = "Gamepad_HintImage_13F.tga"
	hint.Images = imagelist
	HintSystemMap[41] = hint

	-- 42
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 42
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_VARIANT")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_14D.tga"
	imagelist[2] = "Gamepad_HintImage_14E.tga"
	imagelist[3] = "Gamepad_HintImage_14F.tga"
	hint.Images = imagelist
	HintSystemMap[42] = hint

	-- 43
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 43
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_AMPLIFIER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_15D.tga"
	imagelist[2] = "Gamepad_HintImage_15E.tga"
	imagelist[3] = "Gamepad_HintImage_15F.tga"
	hint.Images = imagelist
	HintSystemMap[43] = hint

	-- 44
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 44
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_ANTIMATTER_TANK")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_16D.tga"
	imagelist[2] = "Gamepad_HintImage_16E.tga"
	imagelist[3] = "Gamepad_HintImage_16F.tga"
	hint.Images = imagelist
	HintSystemMap[44] = hint

	-- 45
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 45
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_CONSTRUCTOR")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_17D.tga"
	imagelist[2] = "Gamepad_HintImage_17E.tga"
	imagelist[3] = "Gamepad_HintImage_17F.tga"
	hint.Images = imagelist
	HintSystemMap[45] = hint

	-- 46
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 46
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_DERVISH_JET")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_18D.tga"
	imagelist[2] = "Gamepad_HintImage_18E.tga"
	imagelist[3] = "Gamepad_HintImage_18F.tga"
	hint.Images = imagelist
	HintSystemMap[46] = hint

	-- 47
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 47
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_FIELD_INVERTER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_19D.tga"
	imagelist[2] = "Gamepad_HintImage_19E.tga"
	imagelist[3] = "Gamepad_HintImage_19F.tga"
	hint.Images = imagelist
	HintSystemMap[47] = hint

	-- 48
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 48
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_CORRUPTOR")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_20D.tga"
	imagelist[2] = "Gamepad_HintImage_20E.tga"
	imagelist[3] = "Gamepad_HintImage_20F.tga"
	hint.Images = imagelist
	HintSystemMap[48] = hint

	-- 49
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 49
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_HACKER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_21D.tga"
	imagelist[2] = "Gamepad_HintImage_21E.tga"
	imagelist[3] = "Gamepad_HintImage_21F.tga"
	hint.Images = imagelist
	HintSystemMap[49] = hint


	-- Masari Construction Hints
	
	-- 50
	hint = {}
	hint.Id = 50
   hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_AIR_INSPIRATION")
	HintSystemMap[50] = hint

	-- 51
	hint = {}
	hint.Id = 51
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ELEMENTAL_COLLECTOR")
	HintSystemMap[51] = hint

	-- 52
	hint = {}
	hint.Id = 52
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ELEMENTAL_CONTROLLER")
	HintSystemMap[52] = hint

	-- 53
	hint = {}
	hint.Id = 53
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_FOUNDATION")
	HintSystemMap[53] = hint

	-- 54
	hint = {}
	hint.Id = 54
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_GROUND_INSPIRATION")
	HintSystemMap[54] = hint

	-- 55
	hint = {}
	hint.Id = 55
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_GUARDIAN")
	HintSystemMap[55] = hint

	-- 56
	hint = {}
	hint.Id = 56
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_INFANTRY_INSPIRATION")
	HintSystemMap[56] = hint

	-- 57
	hint = {}
	hint.Id = 57
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_NEOPHYTES_LAB")
	HintSystemMap[57] = hint

	-- 58
	hint = {}
	hint.Id = 58
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_NATURAL_INTERPRETER")
	HintSystemMap[58] = hint

	-- 59
	hint = {}
	hint.Id = 59
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SKY_GUARDIAN")
	HintSystemMap[59] = hint

	-- 60
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 60
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_FIGMENT")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_22D.tga"
	imagelist[2] = "Gamepad_HintImage_22E.tga"
	imagelist[3] = "Gamepad_HintImage_22F.tga"
	hint.Images = imagelist
	HintSystemMap[60] = hint

	-- 61
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 61
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SEEKER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_23D.tga"
	imagelist[2] = "Gamepad_HintImage_23E.tga"
	imagelist[3] = "Gamepad_HintImage_23F.tga"
	hint.Images = imagelist
	HintSystemMap[61] = hint

	-- 62
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 62
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SKYLORD")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_24D.tga"
	imagelist[2] = "Gamepad_HintImage_24E.tga"
	imagelist[3] = "Gamepad_HintImage_24F.tga"
	hint.Images = imagelist
	HintSystemMap[62] = hint

	-- 63
	hint = {}
	hint.Id = 63
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_HERO_ALATEA")
	HintSystemMap[63] = hint

	-- 64
	hint = {}
	hint.Id = 64
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_HERO_CHAROS")
	HintSystemMap[64] = hint

	-- 65
	hint = {}
	hint.Id = 65
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_HERO_ZESSUS")
	HintSystemMap[65] = hint

	-- 66
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 66
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ARCHITECT")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_25D.tga"
	imagelist[2] = "Gamepad_HintImage_25E.tga"
	imagelist[3] = "Gamepad_HintImage_25F.tga"
	hint.Images = imagelist
	HintSystemMap[66] = hint

	-- 68
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 68
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_DISCIPLE")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_26D.tga"
	imagelist[2] = "Gamepad_HintImage_26E.tga"
	imagelist[3] = "Gamepad_HintImage_26F.tga"
	hint.Images = imagelist
	HintSystemMap[68] = hint

	-- 69
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 69
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SEER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_27D.tga"
	imagelist[2] = "Gamepad_HintImage_27E.tga"
	imagelist[3] = "Gamepad_HintImage_27F.tga"
	hint.Images = imagelist
	HintSystemMap[69] = hint

	-- 70
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 70
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_ENFORCER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_28D.tga"
	imagelist[2] = "Gamepad_HintImage_28E.tga"
	imagelist[3] = "Gamepad_HintImage_28F.tga"
	hint.Images = imagelist
	HintSystemMap[70] = hint

	-- 71
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 71
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_PEACEBRINGER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_29D.tga"
	imagelist[2] = "Gamepad_HintImage_29E.tga"
	imagelist[3] = "Gamepad_HintImage_29F.tga"
	hint.Images = imagelist
	HintSystemMap[71] = hint

	-- 72
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 72
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_MASARI_SENTRY")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_30D.tga"
	imagelist[2] = "Gamepad_HintImage_30E.tga"
	imagelist[3] = "Gamepad_HintImage_30F.tga"
	hint.Images = imagelist
	HintSystemMap[72] = hint


	-- Basic Hint System Hints
	-- jdg 8.10.07 added image stuff for 360 hints
	hint = {}
	hint.Id = 73
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_HINT_SYSTEM")
	hint.Num_Images = 7
	imagelist = {}
	imagelist[1] = "Gamepad_Hint_Test01.tga"
	imagelist[2] = "Gamepad_Hint_Test02.tga"
	imagelist[3] = "Gamepad_Hint_Test03.tga"
	imagelist[4] = "Gamepad_Hint_Test04.tga"
	imagelist[5] = "Gamepad_Hint_Test05.tga"
	imagelist[6] = "Gamepad_Hint_Test06.tga"
	imagelist[7] = "Gamepad_Hint_Test07.tga"
	hint.Images = imagelist
	--end of new section
	HintSystemMap[73] = hint

	
	hint = {}
	hint.Id = 74
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_OBJECTIVES")
	HintSystemMap[74] = hint
	
	hint = {}
	hint.Id = 75
   hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_HEROES")
	hint.Num_Images = 1
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_03.tga" 
	hint.Images = imagelist
	HintSystemMap[75] = hint

	hint = {}
	hint.Id = 76
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SELECTING_HEROES")
	HintSystemMap[76] = hint

	hint = {}
	hint.Id = 77
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SCROLLING")
	HintSystemMap[77] = hint

	hint = {}
	hint.Id = 78
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SCROLLING_02")
	HintSystemMap[78] = hint

	hint = {}
	hint.Id = 79
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ROTATE_VIEW")
	HintSystemMap[79] = hint

	hint = {}
	hint.Id = 80
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ZOOMING")
	HintSystemMap[80] = hint

	hint = {}
	hint.Id = 81
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RESET_VIEW")
	HintSystemMap[81] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 82
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_UNIT_SELECTION")
	hint.IgnoreTracking = true
	hint.Num_Images = 2
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_31D.tga"
	imagelist[2] = "Gamepad_HintImage_31E.tga"
	hint.Images = imagelist
	HintSystemMap[82] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 83
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_MOVING")
	hint.IgnoreTracking = true
	hint.Num_Images = 2
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_32D.tga"
	imagelist[2] = "Gamepad_HintImage_32E.tga"
	hint.Images = imagelist
	HintSystemMap[83] = hint

	hint = {}
	hint.Id = 84
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_FORCE_MARCH")
	HintSystemMap[84] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 85
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ATTACKING")
	hint.IgnoreTracking = true
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_33D.tga"
	imagelist[2] = "Gamepad_HintImage_33E.tga"
	imagelist[3] = "Gamepad_HintImage_33F.tga"
	hint.Images = imagelist
	HintSystemMap[85] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 86
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_MULTIPLE_UNITS")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_34D.tga"
	imagelist[2] = "Gamepad_HintImage_34E.tga"
	imagelist[3] = "Gamepad_HintImage_34F.tga"
	hint.Images = imagelist
	HintSystemMap[86] = hint

	hint = {}
	hint.Id = 87
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SIMILAR_UNITS")
	HintSystemMap[87] = hint

	hint = {}
	hint.Id = 88
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ATTACKING_MULTIPLE")
	HintSystemMap[88] = hint

	hint = {}
	hint.Id = 89
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_FORCE_FIRE")
	HintSystemMap[89] = hint

	hint = {}
	hint.Id = 90
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONTROL_GROUPS")
	HintSystemMap[90] = hint

	hint = {}
	hint.Id = 91
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_VIEWING_GROUPS")
	HintSystemMap[91] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 92
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ABILITIES")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_35D.tga"
	imagelist[2] = "Gamepad_HintImage_35E.tga"
	imagelist[3] = "Gamepad_HintImage_35F.tga"
	hint.Images = imagelist
	HintSystemMap[92] = hint

	hint = {}
	hint.Id = 93
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_UNTARGETED_ABILITIES")
	HintSystemMap[93] = hint

	hint = {}
	hint.Id = 94
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SHARED_ABILITIES")
	HintSystemMap[94] = hint

	hint = {}
	hint.Id = 95
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_SHARED_TARGETING")
	HintSystemMap[95] = hint

	hint = {}
	hint.Id = 96
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RADAR")
	HintSystemMap[96] = hint

	hint = {}
	hint.Id = 97
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RADAR_MOVEMENT")
	HintSystemMap[97] = hint

	hint = {}
	hint.Id = 98
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_GARRISONING")
	HintSystemMap[98] = hint

	hint = {}
	hint.Id = 99
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_EXITING")
	HintSystemMap[99] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 100
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CAPTURING")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_36D.tga"
	imagelist[2] = "Gamepad_HintImage_36E.tga"
	imagelist[3] = "Gamepad_HintImage_36F.tga"
	hint.Images = imagelist
	HintSystemMap[100] = hint

	hint = {}
	hint.Id = 101
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONSTRUCTING_UNITS")
	HintSystemMap[101] = hint

	hint = {}
	hint.Id = 102
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RALLY_POINTS")
	HintSystemMap[102] = hint

	hint = {}
	hint.Id = 103
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_RESOURCES")
	HintSystemMap[103] = hint

	hint = {}
	hint.Id = 104
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONSTRUCTING_BUILDINGS")
	HintSystemMap[104] = hint

	hint = {}
	hint.Id = 105
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CONSTRUCTION")
	HintSystemMap[105] = hint

	hint = {}
	hint.Id = 106
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_ROTATING")
	HintSystemMap[106] = hint

	hint = {}
	hint.Id = 107
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_DEPENDENCIES")
	HintSystemMap[107] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 108
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_NOVUS_POWER")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_37D.tga"
	imagelist[2] = "Gamepad_HintImage_37E.tga"
	imagelist[3] = "Gamepad_HintImage_37F.tga"
	hint.Images = imagelist
	HintSystemMap[107] = hint

	-- jdg 10/13/07 this was a hint that was deleted from the PC build...adding back in for 360 version.
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 109
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_NOVUS_MULTIPLE_CONSTRUCTORS")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_66D.tga"
	imagelist[2] = "Gamepad_HintImage_66E.tga"
	imagelist[3] = "Gamepad_HintImage_66F.tga"
	hint.Images = imagelist
	HintSystemMap[109] = hint
	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 110
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_NOVUS_PATCHES")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_38D.tga"
	imagelist[2] = "Gamepad_HintImage_38E.tga"
	imagelist[3] = "Gamepad_HintImage_38F.tga"
	hint.Images = imagelist
	HintSystemMap[110] = hint


   -- Tutorial 01 Specific Hints

   hint = {}
	hint.Id = 111
	hint.Text = Get_Game_Text("TEXT_SP_HINT_TUT01_REINFORCEMENTS_HERE")
	HintSystemMap[111] = hint


	-- Hierarchy 01 Specific Hints
	
	hint = {}
	hint.Id = 112
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM01_ORLOK_SIEGE_ABILITY")
	HintSystemMap[112] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 113
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM01_WALKER_HARDPOINTS")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_39D.tga"
	imagelist[2] = "Gamepad_HintImage_39E.tga"
	imagelist[3] = "Gamepad_HintImage_39F.tga"
	hint.Images = imagelist
	HintSystemMap[113] = hint


	-- Hierarchy 02 Specific Hints
	
	hint = {}
	hint.Id = 114
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM02_COWS")
	HintSystemMap[114] = hint
	
	hint = {}
	hint.Id = 115
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM02_WALL")
	HintSystemMap[115] = hint
		
	hint = {}
	hint.Id = 116
	hint.Text = Get_Game_Text("TEXT_SP_HINT_HM02_VIRUS")
	HintSystemMap[116] = hint

	-- Tutorial 02 Specific Hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 117
	hint.Text = Get_Game_Text("TEXT_SP_HINT_TUT02_BUILDING_UNITS")
	hint.Num_Images = 2
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_40D.tga"
	imagelist[2] = "Gamepad_HintImage_40E.tga"
	hint.Images = imagelist
	HintSystemMap[117] = hint

	-- Novus 01 Specific Hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 118
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM01_BUILDING_STRUCTURES")
	hint.Num_Images = 2
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_41D.tga"
	imagelist[2] = "Gamepad_HintImage_41E.tga"
	hint.Images = imagelist
	HintSystemMap[118] = hint
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 119
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM01_POWER_NETWORK")
	hint.IgnoreTracking = true
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_42D.tga"
	imagelist[2] = "Gamepad_HintImage_42E.tga"
	imagelist[3] = "Gamepad_HintImage_42F.tga"
	hint.Images = imagelist
	HintSystemMap[119] = hint
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 120
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM01_FLOW_ALT")
	hint.IgnoreTracking = true
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_43D.tga"
	imagelist[2] = "Gamepad_HintImage_43E.tga"
	imagelist[3] = "Gamepad_HintImage_43F.tga"
	hint.Images = imagelist
	HintSystemMap[120] = hint
	
	-- Novus 02 Specific Hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 121
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM02_VERTIGO_UPLOAD")
	hint.IgnoreTracking = true
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_44D.tga"
	imagelist[2] = "Gamepad_HintImage_44E.tga"
	imagelist[3] = "Gamepad_HintImage_44F.tga"
	hint.Images = imagelist
	HintSystemMap[121] = hint
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 122
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM02_VERTIGO_DOWNLOAD")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_45D.tga"
	imagelist[2] = "Gamepad_HintImage_45E.tga"
	imagelist[3] = "Gamepad_HintImage_45F.tga"
	hint.Images = imagelist
	HintSystemMap[122] = hint
	
	-- Novus 05 Specific Hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 123
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM05_PATCHES")
	hint.IgnoreTracking = true
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_46D.tga"
	imagelist[2] = "Gamepad_HintImage_46E.tga"
	imagelist[3] = "Gamepad_HintImage_46F.tga"
	hint.Images = imagelist
	HintSystemMap[123] = hint
	
	-- Masari 01 Specific Hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 124
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM01_MASARI_MODES")
	hint.IgnoreTracking = true
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_47D.tga"
	imagelist[2] = "Gamepad_HintImage_47E.tga"
	imagelist[3] = "Gamepad_HintImage_47F.tga"
	hint.Images = imagelist
	HintSystemMap[124] = hint

	-- Novus 02 Specific Hints
	
	hint = {}
	hint.Id = 125
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM02_HACKER_FIREWALL")
	HintSystemMap[125] = hint

	-- Novus 03 Specific Hints
	
	hint = {}
	hint.Id = 126
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM03_VIRUS_EXPLOIT")
	hint.IgnoreTracking = true
	HintSystemMap[126] = hint
	
	-- Masari Global Hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 127
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_ARCHITECTS")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_48D.tga"
	imagelist[2] = "Gamepad_HintImage_48E.tga"
	imagelist[3] = "Gamepad_HintImage_48F.tga"
	hint.Images = imagelist
	HintSystemMap[127] = hint

	hint = {}
	hint.Id = 128
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_TRANSPORTS")
	HintSystemMap[128] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 129
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_RESEARCH")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_49D.tga"
	imagelist[2] = "Gamepad_HintImage_49E.tga"
	imagelist[3] = "Gamepad_HintImage_49F.tga"
	hint.Images = imagelist
	HintSystemMap[129] = hint

	-- jdg new hint images added 12/20/07
	-- jdg new hint images removed  1/21/08
	hint = {}
	hint.Id = 130
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_UNIT_MANAGEMENT")
	HintSystemMap[130] = hint

	hint = {}
	hint.Id = 131
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_HOW_TO_BUILD_STRUCTURES")
	HintSystemMap[131] = hint

	hint = {}
	hint.Id = 132
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_HOW_TO_BUILD_UNITS")
	HintSystemMap[132] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 133
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_MOVING_UNITS")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_51D.tga"
	imagelist[2] = "Gamepad_HintImage_51E.tga"
	imagelist[3] = "Gamepad_HintImage_51F.tga"
	hint.Images = imagelist
	HintSystemMap[133] = hint

	hint = {}
	hint.Id = 134
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_RESEARCH_ADD")
	hint.IgnoreTracking = true
	HintSystemMap[134] = hint
	
		-- Novus 04 Specific Hints
	hint = {}
	hint.Id = 135
	hint.Text = Get_Game_Text("TEXT_SP_HINT_SYSTEM_CAPTURING")
	hint.IgnoreTracking = true
	HintSystemMap[135] = hint
	
	
	hint = {}
	hint.Id = 136
	hint.Text = Get_Game_Text("TEXT_SP_HINT_BUILT_NOVUS_FIELD_INVERTER")
	hint.IgnoreTracking = true
	HintSystemMap[136] = hint
	
	
	hint = {}
	hint.Id = 137
	hint.Text = Get_Game_Text("TEXT_SP_HINT_NM04_REPAIRING")
	hint.IgnoreTracking = true
	HintSystemMap[137] = hint
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 138
	hint.Text = Get_Game_Text("TEXT_SP_HINT_MM02_MISSION_COMPLETE")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_52D.tga"
	imagelist[2] = "Gamepad_HintImage_52E.tga"
	imagelist[3] = "Gamepad_HintImage_52F.tga"
	hint.Images = imagelist
	HintSystemMap[138] = hint
	
	-- 360 only hint regarding the d-pad
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 139
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_D_PAD")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_55D.tga"
	imagelist[2] = "Gamepad_HintImage_55E.tga"
	imagelist[3] = "Gamepad_HintImage_55F.tga"
	hint.Images = imagelist
	HintSystemMap[139] = hint
	
	--jdg more 360 only hints
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 140
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_EXPANDED_RADAR")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_56D.tga"
	imagelist[2] = "Gamepad_HintImage_56E.tga"
	imagelist[3] = "Gamepad_HintImage_56F.tga"
	hint.Images = imagelist
	HintSystemMap[140] = hint
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 141
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_OPENING_SPECIAL_ABILITIES")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_57D.tga"
	imagelist[2] = "Gamepad_HintImage_57E.tga"
	imagelist[3] = "Gamepad_HintImage_57F.tga"
	hint.Images = imagelist
	HintSystemMap[141] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 142
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_OPENING_COMMAND_BAR")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_58D.tga"
	imagelist[2] = "Gamepad_HintImage_58E.tga"
	imagelist[3] = "Gamepad_HintImage_58F.tga"
	hint.Images = imagelist
	HintSystemMap[142] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 143
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_OPENING_CONSTRUCTION_MENU")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_59D.tga"
	imagelist[2] = "Gamepad_HintImage_59E.tga"
	imagelist[3] = "Gamepad_HintImage_59F.tga"
	hint.Images = imagelist
	HintSystemMap[143] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 144
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_BUILDING_ROBOTS")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_60D.tga"
	imagelist[2] = "Gamepad_HintImage_60E.tga"
	imagelist[3] = "Gamepad_HintImage_60F.tga"
	hint.Images = imagelist
	HintSystemMap[144] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 145
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_PAINT_SELECT")
	hint.Num_Images = 3
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_61D.tga"
	imagelist[2] = "Gamepad_HintImage_61E.tga"
	imagelist[3] = "Gamepad_HintImage_61F.tga"
	hint.Images = imagelist
	HintSystemMap[145] = hint

	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 146
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_OPENING_RESEARCH_TREE")
	hint.Num_Images = 2
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_62D.tga"
	imagelist[2] = "Gamepad_HintImage_62E.tga"
	hint.Images = imagelist
	HintSystemMap[146] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 147
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_360TUT_NOW_TEACHING_GROUPS")
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_63D.tga"
	imagelist[2] = "Gamepad_HintImage_63E.tga"
	imagelist[3] = "Gamepad_HintImage_63F.tga"
	hint.Images = imagelist
	HintSystemMap[147] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 148
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_360TUT_GROUPTOOL_TYPE_GROUPS")
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_64D.tga"
	imagelist[2] = "Gamepad_HintImage_64E.tga"
	imagelist[3] = "Gamepad_HintImage_64F.tga"
	hint.Images = imagelist
	HintSystemMap[148] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 149
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_360TUT_GROUPTOOL_CAMERA_CENTER_REMINDER")
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_65D.tga"
	imagelist[2] = "Gamepad_HintImage_65E.tga"
	imagelist[3] = "Gamepad_HintImage_65F.tga"
	hint.Images = imagelist
	HintSystemMap[149] = hint	
	
	-- jdg new hint images added 12/20/07
	hint = {}
	hint.Id = 150
	hint.Text = Get_Game_Text("GAMEPAD_TEXT_SP_HINT_SYSTEM_X360_SUPERWEAPONS_BUTTON_LOCATION")
	hint.IgnoreTracking = true
	imagelist = {}
	imagelist[1] = "Gamepad_HintImage_67D.tga"
	imagelist[2] = "Gamepad_HintImage_67E.tga"
	imagelist[3] = "Gamepad_HintImage_67F.tga"
	hint.Images = imagelist
	HintSystemMap[150] = hint	
	
	

end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGHintSystemDefs_Init = nil
	Remove_Invalid_Objects = nil
	Set_Achievement_Map_Type = nil
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

