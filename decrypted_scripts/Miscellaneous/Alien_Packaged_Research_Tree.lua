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
	
	SyncMessage("Alien_Packaged_Research_Tree::Init_Research_Tree -- tactical_only_game: %s, Player: %s\n", tostring(tactical_only_game), tostring(Player))
	
	Script.Set_Async_Data("AdditionalFacilityRequiredText", "TEXT_ADDITIONAL_RESEARCH_HIERARCHY")

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
				UnlocksTypes =  {  
					[1] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Range_Enhancer"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_WALKER_HP_RANGE_ENHANCER",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_RANGE_ENHANCER", 
							IconName="i_icon_a_walker_hp_Range_Enhancer.tga" 
						},
					[2] = { ObjectType=Find_Object_Type("Alien_Walker_Habitat_HP_Range_Enhancer"), DescriptionTextID=nil, IconName=nil },
					[3] = { ObjectType=Find_Object_Type("Alien_Walker_Science_HP_Range_Enhancer"), DescriptionTextID=nil, IconName=nil },

					[4] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Arc_Trigger"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_WALKER_HP_ARC_TRIGGER",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_ARC_TRIGGER", 
							IconName="i_icon_a_walker_hp_arc_trigger.tga" 
						},
					[5] = { ObjectType=Find_Object_Type("Alien_Walker_Habitat_HP_Arc_Trigger"), DescriptionTextID=nil, IconName=nil },
					[6] = { ObjectType=Find_Object_Type("Alien_Walker_Science_HP_Arc_Trigger"), DescriptionTextID=nil, IconName=nil },
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
							ObjectType=Find_Object_Type("Alien_Grunt"), 
							AbilityName="Grunt_Grenade_Attack", 
							TitleTextID="TEXT_ALIEN_RESEARCH_TITLE_GRUNT_GRENADE",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_GRUNT_GRENADE",
							IconName="i_icon_a_research_grunt_grenade.tga" 
						},
					[2] = { ObjectType=Find_Object_Type("Alien_Lost_One"), AbilityName="Lost_One_Plasma_Bomb_Ability", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},				
				
				-- List of Generators that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
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
				TextureMap = {"i_icon_a_research_assault_1_start.tga", "i_icon_a_research_assault_1_complete.tga"}
				-- --------------------------------
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				UnlocksTypes =
				{
					[1] = { 
							ObjectType=Find_Object_Type("Alien_Hero_Orlok"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HERO_ORLOK",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_HERO_ORLOK", 
							IconName="i_icon_a_research_hero_orlok.tga" 
							},

				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
				
					[1] = { 
								TypeName = "Alien_Brute", 
								AbilityName="Brute_Death_From_Above", 
								TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_DEATH_FROM_ABOVE",
								DescriptionTextID="TEXT_ALIEN_RESEARCH_BRUTE_DEATH_FROM_ABOVE", 
								IconName="i_icon_a_research_brute_death_from_above.tga" 
							},
					
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities =
				{
				
					[1] = { TypeName = "Alien_Brute", AbilityName="Brute_Leap_Ability", DescriptionTextID=nil, IconName=nil },
				
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = 
				{
					[1] = { 
							EffectName="Alien_Foo_Fighter_Upgraded_Effect_Generator",
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_FOO_LONGEVITY",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_FOO_LONGEVITY", 
							IconName="i_icon_a_research_foo_longevity.tga" 
						},
				
					[2] = { EffectName="Brute_Leap_Landing_Effect_Generator", DescriptionTextID=nil, IconName=nil },
				
				},
				
				UnlocksEffects = 
				{
					[1] = {EffectName="Brute_DFA_Leap_Landing_Effect", TitleTextID = nil, DescriptionTextID=nil, IconName=nil},
					[2] = {EffectName="Brute_DFA_Landing_VisualEffect", TitleTextID = nil, DescriptionTextID=nil, IconName=nil},
				},
				
				LocksEffects=
				{
					[1] = { EffectName="Brute_Leap_Landing_Effect", DescriptionTextID=nil, IconName=nil },
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
				TextureMap = {"i_icon_a_research_assault_2_start.tga", "i_icon_a_research_assault_2_complete.tga"}
				-- --------------------------------
			},

		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes =
				{

					[1] = { 	
							ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Mass_Driver"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_MASS_DRIVER",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_MASS_DRIVER", 
							IconName="i_icon_a_walker_hp_Mass_Driver.tga" 
							},
				
					[2] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Science_HP_Scanning_Node"),
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_SCANNING_RELAY",
							DescriptionTextID="TEXT_TOOLTIP_DESCRIPTION_ALIEN_HP_SCANNING_RELAY",
							IconName="i_icon_a_walker_hp_scanning_relay.tga"
							},

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
				UnlocksGenerators = {},
		
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
				TextureMap = {"i_icon_a_research_assault_3_start.tga", "i_icon_a_research_assault_3_complete.tga"}
				-- --------------------------------
			},
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
					[1] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Scarn_Beam"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_SCARN_BEAM",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_ASSEMBLY_HP_SCARN_BEAM", 
							IconName="i_icon_a_research_walker_hp_scarn_beam.tga" 
						},
										
					--[2] = { ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Jump_Module"), DescriptionTextID="TEXT_ALIEN_RESEARCH_ASSEMBLY_HP_JUMP_MODULE", IconName="i_icon_a_research_upgrade_assembly_hp_jump_module.tga" },
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = 
				{
					[1] = { 
							EffectName="AssemblyWalkerSpeedIncreaseGenerator", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_WALKER_SPEED",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_SPEED", 
							IconName="i_icon_a_research_walker_speed.tga" 
						},
					[2] = { EffectName="HabitatWalkerSpeedIncreaseGenerator", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="ScienceWalkerSpeedIncreaseGenerator", DescriptionTextID=nil, IconName=nil },
				},

				LocksGenerators = 
				{

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
				TextureMap = {"i_icon_a_research_assault_4_start.tga", "i_icon_a_research_assault_4_complete.tga"}
				-- --------------------------------
			},
	}
	
	
	-- This branch is now called Mutagen
	
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
							EffectName="AlienTankOnDeathExplosionGenerator", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_VOLATILE_REACTORS",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_VOLATILE_REACTORS", 
							IconName="i_icon_a_research_volatile_reactors.tga" 
						},
					[2] = { EffectName="DefilerOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="ReaperOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
					[4] = { EffectName="ScanDroneOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
					[5] = { EffectName="AssemblyOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
					[6] = { EffectName="HabitatOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
					[7] = { EffectName="ScienceWalkerOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
					[8] = { EffectName="OrlokOnDeathExplosionGenerator", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksEffects = 
				{
					[1] = { 
							EffectName="AlienRadiatedShotsImpactEffect", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_RADIATED_SHOT",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_RADIATED_SHOT", 
							IconName="i_icon_a_research_radiated_shot.tga" 
						},
				
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
				TextureMap = {"i_icon_a_research_mutagen_1_start.tga", "i_icon_a_research_mutagen_1_complete.tga"}				
				-- --------------------------------				
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
					[1] = { 
							ObjectType=Find_Object_Type("Alien_Hero_Nufai"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HERO_NUFAI",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_HERO_NUFAI", 
							IconName="i_icon_a_research_hero_nufai.tga" 
						},
					-- Walker socket option:  Terrain Conditioner
					[2] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_BRUTE_MUTATOR",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_BRUTE_MUTATOR", 
							IconName="i_icon_a_walker_hp_pod_brute.tga" 
						},
					[3] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_TERRAIN_CONDITIONER",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_TERRAIN_CONDITIONER", 
							IconName="i_icon_a_research_walker_hp_terrain_conditioner.tga" 
						},
					
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{									
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {},
				
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
				TextureMap = {"i_icon_a_research_mutagen_2_start.tga", "i_icon_a_research_mutagen_2_complete.tga"}				
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
				UnlocksGenerators = 
				{
					-- Maria 09.07.07 (as per bugs 3996 and 3997)
					-- commenting this out because I have replaced this with the proper effects that have to be locked/unlocked (see below)
					--[[
					[1] = { 
							EffectName="RadiationSpitterGamaFieldGenerator", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_GAMMA_RADIATION",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_GAMMA_RADIATION", 
							IconName="i_icon_a_research_gamma_radiation.tga", 
						},
					]]--
				},

				LocksGenerators = 
				{
				},

				-- List of effects that will be UNLOCKED when research of this suite is completed!				
				UnlocksEffects = 
				{
					[1] = { 
							EffectName="AlienGammaRadiatedShotsImpactEffect", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_GAMMA_RADIATION",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_GAMMA_RADIATION", 
							IconName="i_icon_a_research_gamma_radiation.tga", 
							LockThisEffect="AlienRadiatedShotsImpactEffect"
						},
						
					[2] = { EffectName="CylinderGamaRadiationBeamEffect", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="MutantSlowDyingEffect", DescriptionTextID=nil, IconName=nil },

					-- Defiler's Bleed
					[4] = { EffectName="GammaRadiationBleedVisualEffect", DescriptionTextID=nil, IconName=nil },
					[5] = { EffectName="GammaRadiationBleedMovedEffect", DescriptionTextID=nil, IconName=nil },
					[6] = { EffectName="GammaRadiationBleedVisualExpandOneEffect", DescriptionTextID=nil, IconName=nil },
					[7] = { EffectName="GammaRadiationBleedVisualExpandTwoEffect", DescriptionTextID=nil, IconName=nil },
					[8] = { EffectName="GammaRadiationChargeCreateRadiatingObjectEffect", DescriptionTextID=nil, IconName=nil },

					[9] = { EffectName="VehicleVolatileReactorGammaExplosionVisualEffect", DescriptionTextID=nil, IconName=nil },
					[10] = { EffectName="VehicleVolatileReactorGammaDamageEffect", DescriptionTextID=nil, IconName=nil },
					[11] = { EffectName="WalkerVolatileReactorGammaExplosionVisualEffect", DescriptionTextID=nil, IconName=nil },
					[12] = { EffectName="WalkerVolatileReactorGammaDamageEffect", DescriptionTextID=nil, IconName=nil },
					
					-- Radiation spitter					
					[13] = { EffectName="RadiationSpitterGamaFieldDamageEffect", DescriptionTextID=nil, IconName=nil },
					[14] = { EffectName="RadiationSpitterGamaFieldHealEffect", DescriptionTextID=nil, IconName=nil },
					[15] = { EffectName="RadiationSpitterGamaFieldVisualEffect", DescriptionTextID=nil, IconName=nil },

					-- Walker Habitat's terrain conditioner HP
					[16] = { EffectName="AlienWalkerGamaTerrainConditionerEffect", DescriptionTextID=nil, IconName=nil },
					[17] = { EffectName="AlienWalkerGamaTerrainConditionerSelfEffect", DescriptionTextID=nil, IconName=nil },

					[18] = { 
							EffectName="RadiationChargeRaiseDeadEffect", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_ADVANCED_MUTAGENS",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_ADVANCED_MUTAGENS",
							IconName="i_icon_a_research_advanced_mutagens.tga" 
						},
				},

				LocksEffects=
				{
					-- Defiler's Bleed
					[1] = { EffectName="RadiationBleedVisualEffect", DescriptionTextID=nil, IconName=nil },
					[2] = { EffectName="RadiationBleedMovedEffect", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="RadiationBleedVisualExpandOneEffect", DescriptionTextID=nil, IconName=nil },
					[4] = { EffectName="RadiationBleedVisualExpandTwoEffect", DescriptionTextID=nil, IconName=nil },
					[5] = { EffectName="RadiationChargeCreateRadiatingObjectEffect", DescriptionTextID=nil, IconName=nil },
					
					[6] = { EffectName="VehicleVolatileReactorExplosionVisualEffect", DescriptionTextID=nil, IconName=nil },
					[7] = { EffectName="VehicleVolatileReactorDamageEffect", DescriptionTextID=nil, IconName=nil },
					[8] = { EffectName="WalkerVolatileReactorExplosionVisualEffect", DescriptionTextID=nil, IconName=nil },
					[9] = { EffectName="WalkerVolatileReactorDamageEffect", DescriptionTextID=nil, IconName=nil },
					
					[10] = { EffectName="CylinderRadiationBeamEffect", DescriptionTextID=nil, IconName=nil },
					
					-- Radiation spitter	
					[11] = { EffectName="RadiationSpitterFieldDamageEffect", DescriptionTextID=nil, IconName=nil },
					[12] = { EffectName="RadiationSpitterFieldHealEffect", DescriptionTextID=nil, IconName=nil },
					[13] = { EffectName="RadiationSpitterFieldVisualEffect", DescriptionTextID=nil, IconName=nil },
					
					-- Walker Habitat's terrain conditioner HP
					[14] = { EffectName="AlienWalkerTerrainConditionerEffect", DescriptionTextID=nil, IconName=nil },
					[15] = { EffectName="AlienWalkerTerrainConditionerSelfEffect", DescriptionTextID=nil, IconName=nil },
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
				TextureMap = {"i_icon_a_research_mutagen_3_start.tga", "i_icon_a_research_mutagen_3_complete.tga"}				
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
							ObjectType=Find_Object_Type("Alien_Walker_Science_HP_Radiation_Wake"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_RADIATION_CASCADE",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_RADIATION_CASCADE", 
							IconName="i_icon_a_research_walker_hp_radiation_cascade.tga" 
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
				UnlocksGenerators = {},
				
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
				TextureMap = {"i_icon_a_research_mutagen_4_start.tga", "i_icon_a_research_mutagen_4_complete.tga"}				
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
				
					[1] = {  
							TypeName = "Alien_Lost_One", 
							AbilityName="Grey_Phase_Unit_Ability", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_PHASE_MODULE",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_PHASE_MODULE", 
							IconName="i_icon_a_sa_phase_self.tga" 
						},
					[2] = {  TypeName = "Alien_Cylinder", AbilityName="Monolith_Phase_Unit_Ability", DescriptionTextID=nil, IconName=nil },
				
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
					[1] = { 
							EffectName="ScanDroneScanPulseEnemyUpgradeEffect", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_MENTAL_FREQUENCY",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_MENTAL_FREQUENCY", 
							IconName="i_icon_a_research_mental_frequency.tga" 
						},
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
					[1] = { 
							ObjectType=Find_Object_Type("Alien_Hero_Kamal_Rex"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HERO_KAMAL_REX",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_HERO_KAMAL_REX", 
							IconName="i_icon_a_research_hero_kamal_rex.tga" 
						},
					-- Walker socket option:  Phase Tank Assembly Pod
					[2] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_PHASE_TANK",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_PHASE_TANK", 
							IconName="i_icon_a_walker_hp_pod_phase_tank.tga" 
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
				UnlocksGenerators ={
				
				[1] = { 
						EffectName="AlienFastOrderingGenerator", 
						TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_FAST_ORDERING",
						DescriptionTextID="TEXT_ALIEN_RESEARCH_FAST_ORDERING", 
						IconName="i_icon_a_research_fast_ordering.tga" 
					},
				
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
					[1] = { 
							EffectName="GruntPlasmaAEImpactEffect", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_QUANTUM_PLASMA",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_QUANTUM_PLASMA", 
							IconName="i_icon_a_research_quantum_plasma.tga" 
						},
						
					[2] = { EffectName="GruntPlasmaAEExplosionEffect", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="GruntPlasmaAEImpactVisualEffect", DescriptionTextID=nil, IconName=nil },					
					
					[4] = { EffectName="LostPlasmaAEImpactEffect", DescriptionTextID=nil, IconName=nil },
					[5] = { EffectName="LostPlasmaAEExplosionEffect", DescriptionTextID=nil, IconName=nil },
					[6] = { EffectName="LostPlasmaAEImpactVisualEffect", DescriptionTextID=nil, IconName=nil },					
					
					[7] = { EffectName="AlienTankPlasmaAEImpactEffect", DescriptionTextID=nil, IconName=nil },
					[8] = { EffectName="AlienTankPlasmaAEExplosionEffect", DescriptionTextID=nil, IconName=nil },
					[9] = { EffectName="AlienTankPlasmaAEImpactVisualEffect", DescriptionTextID=nil, IconName=nil },					
					
					[10] = { EffectName="AssemblyPlasmaAEImpactEffect", DescriptionTextID=nil, IconName=nil },
					[11] = { EffectName="AssemblyPlasmaAEExplosionEffect", DescriptionTextID=nil, IconName=nil },
					[12] = { EffectName="AssemblyPlasmaAEImpactVisualEffect", DescriptionTextID=nil, IconName=nil },					
				
					[13] = { EffectName="HabitatPlasmaAEImpactEffect", DescriptionTextID=nil, IconName=nil },
					[14] = { EffectName="HabitatPlasmaAEExplosionEffect", DescriptionTextID=nil, IconName=nil },
					[15] = { EffectName="HabitatPlasmaAEImpactVisualEffect", DescriptionTextID=nil, IconName=nil },
					
					[16] = { 
							EffectName="WalkerHardPointArmorEffect", 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_MOLECULAR_ARMOR",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_MOLECULAR_ARMOR", 
							IconName="i_icon_a_research_walker_molecular_armor.tga" 
						},					
				
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
					[1] = { 
							ObjectType=Find_Object_Type("Alien_Walker_Science_HP_Dark_Matter_Vent"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_DARK_MATTER",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_DARK_MATTER", 
							IconName="i_icon_a_research_walker_hp_dark_matter_vent.tga" 
						},
					
					[2] = {
							ObjectType=Find_Object_Type("Alien_Walker_Science_HP_Mind_Magnet"), 
							TitleTextID = "TEXT_ALIEN_RESEARCH_TITLE_HP_CONTROL_MAGNETS",
							DescriptionTextID="TEXT_ALIEN_RESEARCH_WALKER_HP_CONTROL_MAGNETS", 
							IconName="i_icon_a_walker_hp_control_magnet.tga"
						},

					[3] = { ObjectType=Find_Object_Type("Alien_Walker_Science_HP_AI_Magnet"), DescriptionTextID=nil, IconName=nil },

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
	Branches["A"] = { Name = Get_Game_Text("TEXT_ALIEN_RESEARCH_BRANCH_A"), Icon = "i_icon_a_research_assault_branch.tga" }
	Branches[Branch_THERMODYNAMICS] = Branches["A"]
	
	Branches["B"] = { Name = Get_Game_Text("TEXT_ALIEN_RESEARCH_BRANCH_B"), Icon = "i_icon_a_research_mutagen_branch.tga" }
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

