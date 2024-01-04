if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/MilitaryResearchTree_Offensive.lua 
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/06/07 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
	

require("Research_Common")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.07.2006
--
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Research_Tree(tactical_only_game)
	
	MessageBox("Military_Packaged_Research_Tree: Actived")
	SyncMessage("Military_Packaged_Research_Tree::Init_Research_Tree -- tactical_only_game: %s, Player: %s\n", tostring(tactical_only_game), tostring(Player))
	
	Script.Set_Async_Data("AdditionalFacilityRequiredText", "TEXT_ADDITIONAL_RESEARCH_NOVUS")

	Packages = {}
	Branch_THERMODYNAMICS = {} -- Assault
	Branch_RADIOACTIVITY = {}	-- Mutagen
	Branch_QUANTUM = {}			
	
	-- This branch is now called Assault
	Branch_THERMODYNAMICS = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes =  
				{  
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = 
				{
					[1] = { 
							ObjectType=Find_Object_Type("Military_Apache"), 
							AbilityName="Special_Ability_Apache_Rocket_Barrage", 
							TitleTextID="TEXT_MILITARY_RESEARCH_TITLE_APACHE_MISSILES",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_APACHE_MISSILES",
							IconName="militaryi_sa_Missile Strike.tga" 
						},
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},				
				
				-- List of Generators that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="MilitaryAccuracyBoostEffectGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_ACCURACY_BOOST",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_ACCURACY_BOOST", 
							IconName="i_icon_hv_apache.tga" 
						},					
				},
				
				-- List of effects that will be UNLOCKED when research of this suite is completed!				
				UnlocksEffects = 
				{
					--[1] = {EffectName="TestRadiationChargeRaiseDeadEffect", TitleTextID = nil, DescriptionTextID=nil, IconName=nil},
					--[1] = { EffectName="WalkerVolatileReactorExplosionVisualEffect", DescriptionTextID=nil, IconName=nil },
					--[2] = { EffectName="WalkerVolatileReactorGammaExplosionVisualEffect", DescriptionTextID=nil, IconName=nil },
					--[3] = { EffectName="WalkerVolatileReactorDamageEffect", DescriptionTextID=nil, IconName=nil },
					--[3] = { EffectName="WalkerVolatileReactorGammaDamageEffect", DescriptionTextID=nil, IconName=nil },
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 40,
				ResearchCost = 1000,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 1,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1,
				TextureMap = {"militaryi_sa_Missile Strike.tga", "militaryi_sa_Missile Strike.tga"}
				-- --------------------------------
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				UnlocksTypes =
				{
					[1] = { 
							ObjectType=Find_Object_Type("Military_Hero_Randal_Moore"), 
							TitleTextID = "TEXT_MILITARY_HERO_RANDAL_MOORE",
							DescriptionTextID="TEXT_TOOLTIP_DESCRIPTION_MILITARY_HERO_COL_MOORE", 
							IconName="i_hero_military_moore.tga" 
							},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					[1] = { 
							TypeName = "Military_Defender_APC", 
							AbilityName="Military_APC_Marine_Ability", 
							TitleTextID = "TEXT_ABILITY_APC_RESEARCH_MARINES_TITLE",
							DescriptionTextID="TEXT_ABILITY_APC_RESEARCH_MARINES", 
							IconName="I_ICON_MILITARY_APC.TGA" 
						},
				},
				
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities =
				{
				
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = 
				{
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				LocksEffects = 
				{											
					[1] = { EffectName="Disable_APC_Squad_Effect", 
							TitleTextID = "TEXT_ABILITY_APC_RESEARCH_MARINES_TITLE",
							DescriptionTextID="TEXT_ABILITY_APC_RESEARCH_MARINES",
							IconName="I_ICON_MILITARY_APC.TGA"
						},
				},				
				
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 55,
				ResearchCost = 1500,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 2,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_hero_military_moore.tga", "i_hero_military_moore.tga"}
				-- --------------------------------
			},

		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes =
				{				

				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities ={},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
				
					[1] = { 
							EffectName="MilitaryFireRateBoostEffectGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_FIRE_RATE",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_FIRE_RATE", 
							IconName="i_icon_tank.tga" 
						},
				},

				LocksGenerators = {
				
					[1] = { 
							EffectName="Disable_APC_Laser_Effect_Generator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_APC_LASER",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_APC_LASER", 
							IconName="I_ICON_MILITARY_APC.tga" 
						},
				},
		
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE 
				TotalResearchTime = 70,
				ResearchCost = 2000,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 3,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_military_turret_research.tga", "i_icon_military_turret_research.tga"}
				-- --------------------------------
			},
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
										
					--[2] = { ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Jump_Module"), DescriptionTextID="TEXT_ALIEN_RESEARCH_ASSEMBLY_HP_JUMP_MODULE", IconName="i_icon_a_research_upgrade_assembly_hp_jump_module.tga" },
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
				--Ability
				},
				
				UnlocksEffects = 
				{
					--[1] = { EffectName="Spawn_Rocket_Team_Effect", 
					--		TitleTextID = "TEXT_ABILITY_APC_RESEARCH_MARINES_TITLE",
					--		DescriptionTextID="TEXT_ABILITY_APC_RESEARCH_ROCKET_SQUAD",
					--		IconName="I_ICON_MILITARY_APC.TGA"
					--	},
				},
				
				LocksEffects=
				{
					--[1] = { EffectName="Spawn_Marine_Team_Effect", 
					--		TitleTextID = "TEXT_ABILITY_APC_RESEARCH_MARINES_TITLE",
					--		DescriptionTextID="TEXT_ABILITY_APC_RESEARCH_MARINES",
					--		IconName="I_ICON_MILITARY_APC.TGA"
					--	},
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				
						--[1] = { 
						--	TypeName = "Military_Defender_APC", 
						--	AbilityName="Military_APC_Marine_Ability", 
						--	TitleTextID = "TEXT_ABILITY_APC_RESEARCH_MARINES_TITLE",
						--	DescriptionTextID="TEXT_ABILITY_APC_RESEARCH_MARINES", 
						--	IconName="I_ICON_MILITARY_APC.TGA" 
						--},
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = 
				{										
											
					[1] = { 
							EffectName="MilitaryDamageIncreaseEffectGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_DAMAGE_BOOST_2",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_DAMAGE_BOOST_2", 
							IconName="i_icon_saturate_area.tga"
						},
							
				},

				LocksGenerators = 
				{
					[1] = { 
							EffectName="Disable_Tank_Gunner_Effect_Generator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_TANK_GUNNER",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_TANK_GUNNER", 
							IconName="i_icon_tank.tga" 
						},
			
				},
				
				
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 90,
				ResearchCost = 2500,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 4,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_Damage_Research.tga", "i_icon_Damage_Research.tga"}
				-- --------------------------------
			},
	}
	
	
	-- This branch is now called Defense
	
	Branch_RADIOACTIVITY = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes =  {
					-- Walker socket option:  EM field generator	

				},

				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
							
				-- List of Generators that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = 
				{
					[1] = { 
							EffectName="MilitaryUAVSpeedBoostEffectGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_UAV_SPEED",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_UAV_SPEED", 
							IconName="i_icon_dragonfly.TGA"
						},
					
					[2] = { 
							EffectName="MilitaryStationaryRevelationGenerator", 
							TitleTextID = "TEXT_MILITARY_RESEARCH_SIGHT_RANGE",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_STATIONARY_REVELATION", 
							IconName="I_ICON_DRAGOON_SCAN.TGA" 
						},
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksEffects = 
				{
				
				},
				
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 40,
				ResearchCost = 1000,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 1,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_research_Radar.tga", "i_icon_research_Radar.tga"}				
				-- --------------------------------				
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				
					[1] = { 	
							ObjectType=Find_Object_Type("Military_Hero_Tank"), 
							TitleTextID = "TEXT_MILITARY_HERO_TANK",
							DescriptionTextID="TEXT_TOOLTIP_DESCRIPTION_MILITARY_HERO_SGT_WOOLARD", 
							IconName="i_button_mv_tank4.tga" 
							},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = 
				{
				
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
				
					[1] = { 
							EffectName="MilitaryResearchRapidRebuildEffectGenerator",
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_RAPID_REBUILD_EFFECT",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_BUILD_HEALTH", 
							IconName="I_ICON_BUILD.TGA" 
						},
						
					--[2] = { 
					--		EffectName="MilitaryTurretAccuracyBoostEffectGenerator",
					--		TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_DEFENSE_FIRE_RATE",
					--		DescriptionTextID="TEXT_MILITARY_RESEARCH_DEFSENSE_FIRE_RATE", 
					--		IconName="I_CG_M_Turret.tga" 
					--	},
				},
				
				UnlocksEffects = 
				{
					[1] = {
							EffectName="MTRVScanPulseFriendlyEffect", 
							TitleTextID = "TEXT_MILITARY_PURGE_SCAN_TITLE_EFFECT", 
							DescriptionTextID= "TEXT_MILITARY_PURGE_SCAN_EFFECT", 
							IconName="I_ICON_DRAGOON_SCAN.TGA"
					},
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 55,
				ResearchCost = 1500,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 2,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1,
				TextureMap = {"i_button_mv_tank4.tga", "i_button_mv_tank4.tga"}				
				-- --------------------------------				
			},

		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes =
				{
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed! 
				LocksSpecialAbilities = {},
				
				-- A list of effect generators to be locked 
				LocksGenerators = 
				{
					[1] = { 
							EffectName="Disable_Hero_Tank_Gunner_Effect_Generator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_THUMPER_GUNNER",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_THUMPER_GUNNER", 
							IconName="i_button_mv_tank4.tga" 
						},
				},
				
				UnlocksGenerators = 
				{
					[1] = { 
							EffectName="MilitaryInfrantryBoostArmorGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_INFRANTRY_ARMOR",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_INFRANTRY_ARMOR", 
							IconName="i_icon_rocketlauncher.TGA"
						},
					
					[2] = { 
							EffectName="MilitaryStructureBoostArmorEffect",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_STRUCTURAL_SUPPORT",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_STRUCTURAL_SUPPORT", 
							IconName="i_icon_vtol_factory.TGA"
						},
											
				},

				-- List of effects that will be UNLOCKED when research of this suite is completed!				
				UnlocksEffects = 
				{

				},

				LocksEffects=
				{
				},
				
				
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 70,
				ResearchCost = 2000,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 3,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_armor_research.tga", "i_icon_armor_research.tga"}				
				-- --------------------------------
			},
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes =
				{
					[1] = { 
							ObjectType=Find_Object_Type("Military_Hero_Jet"), 
							TitleTextID = "TEXT_UNIT_MILITARY_HERO_JET",
							DescriptionTextID="TEXT_TOOLTIP_DESCRIPTION_MILITARY_HERO_JET", 
							IconName="I_ICON_MILITARY_JET.tga" 
							},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
				
					[1] = { 
							EffectName="MilitaryManufactoringImprovementsEffectGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_MANUFACTURING_IMPROVEMENTS",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_MANUFACTURING_IMPROVEMENTS", 
							IconName="i_icon_sell.tga" 
						},
						
					[2] = { 
							EffectName="MilitaryVehicleBoostArmorGenerator",
							TitleTextID = "TEXT_MILITARY_RESEARCH_TITLE_ARMOR_BOOST",
							DescriptionTextID="TEXT_MILITARY_RESEARCH_ARMOR_BOOST", 
							IconName="i_icon_tank.tga" 
						},
				},
				
				LocksGenerators = {
				
					
				},
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 90,
				ResearchCost = 2500,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 4,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1,
				TextureMap = {"i_icon_Jet_Research.tga", "i_icon_Jet_Research.tga"}				
				-- --------------------------------
			},
	}


	Branch_QUANTUM = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {},	
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
				
				
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of Generators that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {},
				
				UnlocksEffects = 
				{
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 40,
				ResearchCost = 1000,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 1,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_a_research_quantum_1_start.tga", "i_icon_a_research_quantum_1_complete.tga"}				
				-- --------------------------------
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = 
				{ 
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators ={
				
				},					
	
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 55,
				ResearchCost = 1500,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 2,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_a_research_quantum_2_start.tga", "i_icon_a_research_quantum_2_complete.tga"}				
				-- --------------------------------
			},

		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes ={},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
		
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
		
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators ={},
--				
				UnlocksEffects = 
				{

				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 70,
				ResearchCost = 2000,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 3,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_a_research_quantum_3_start.tga", "i_icon_a_research_quantum_3_complete.tga"}				
				-- --------------------------------
			},
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
					-- Walker socket option:  dark matter
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 90,
				ResearchCost = 2500,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 4,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_a_research_quantum_4_start.tga", "i_icon_a_research_quantum_4_complete.tga"}				
				-- --------------------------------
			},
	}
	
	Initialize_Branch_Data()	
	Init_Research_Common(tactical_only_game)
end


-- ---------------------------------------------------------------------------------------------
-- Initialize_Branch_Data
-- ---------------------------------------------------------------------------------------------
function Initialize_Branch_Data()
	if not Branch_THERMODYNAMICS or not Branch_RADIOACTIVITY or not Branch_QUANTUM then
		return
	end
	Branches = {}
	Branches["A"] = { Name = Get_Game_Text("TEXT_ALIEN_RESEARCH_BRANCH_A"), Icon = "i_logo_military.tga" }
	Branches[Branch_THERMODYNAMICS] = Branches["A"]
	
	Branches["B"] = { Name = Get_Game_Text("TEXT_MILITARY_RESEARCH_BRANCH_B"), Icon = "i_logo_military.tga" }
	Branches[Branch_RADIOACTIVITY] = Branches["B"]
	
	Branches["C"] = { Name = Get_Game_Text("TEXT_ALIEN_RESEARCH_BRANCH_C"), Icon = "i_icon_a_research_quantum_branch.tga" }
	Branches[Branch_QUANTUM] = Branches["C"]
	
	PathToBranchMap = {}
	PathToBranchMap["A"] = Branch_THERMODYNAMICS
	PathToBranchMap["B"] = Branch_RADIOACTIVITY
	PathToBranchMap["C"] = Branch_QUANTUM 
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Achievement_Buff_Display_Model = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Get_Player_By_Faction = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGAchievementAward_Init = nil
	Persist_Online_Achievements = nil
	Player_Earned_Offline_Achievements = nil
	Process_Research_Complete = nil
	Remove_Invalid_Objects = nil
	Set_Local_User_Applied_Medals = nil
	Set_Online_Player_Info_Models = nil
	Show_Earned_Offline_Achievements = nil
	Show_Earned_Online_Achievements = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Offline_Achievement = nil
	Update_Research_Progress = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

