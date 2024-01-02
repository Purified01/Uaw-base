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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/Masari_Packaged_Research_Tree.lua 
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/02/24
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("Research_Common")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Research_Tree(tactical_only_game)
	
	SyncMessage("Masari_Packaged_Research_Tree::Init_Research_Tree -- tactical_only_game: %s, Player: %s\n", tostring(tactical_only_game), tostring(Player))
	
	Script.Set_Async_Data("AdditionalFacilityRequiredText", "TEXT_ADDITIONAL_RESEARCH_MASARI")
	
	Packages = {}
	Branch_FIRE = {}
	Branch_ICE = {}
	Branch_BALANCE = {}
	
	Branch_FIRE = 
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
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},				
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
				
					[1] = { 
							EffectName="MasariResearchBurningAuraEffectGenerator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_BURNING_BRILLIANCE",
							DescriptionTextID="TEXT_MASARI_RESEARCH_BURNING_BRILLIANCE", 
							IconName="i_icon_m_research_upgrade_burning_brilliance.tga" 
						},
					[2] = 
						{ 
							EffectName="Burning_Sight_Generator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_REMOTE_HARM",
							DescriptionTextID="TEXT_MASARI_RESEARCH_REMOTE_HARM", 
							IconName="i_icon_m_research_upgrade_remote_harm.tga" 
						},
				
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 40,
				ResearchCost = 100,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 1,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1,
				TextureMap = {"i_icon_m_research_offense_1_start.tga", "i_icon_m_research_offense_1_complete.tga"}
				-- --------------------------------
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				UnlocksTypes =
				{
					[1] = { 
							ObjectType=Find_Object_Type("Masari_Hero_Charos"), 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_HERO_CHAROS",
							DescriptionTextID="TEXT_MASARI_RESEARCH_HERO_CHAROS", 
							IconName="i_icon_m_research_upgrade_hero_charos.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					[1] = { 
							TypeName = "Masari_Enforcer", 
							AbilityName="Masari_Enforcer_Fire_Vortex_Ability", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_BURNING_FURY",
							DescriptionTextID="TEXT_MASARI_RESEARCH_BURNING_FURY", 
							IconName="i_icon_m_research_upgrade_burning_fury.tga" 
						},
					[2] = { 
							TypeName = "Masari_Elemental_Collector", 
							AbilityName="Matter_Engine_Self_Destruct_Ability", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_IMMOLATION",
							DescriptionTextID="TEXT_MASARI_RESEARCH_IMMOLATION", 
							IconName="i_icon_m_sa_matter_engine_detonate.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{

				},
				
				UnlocksEffects = 
				{
				
				},
			
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 55,
				ResearchCost = 150,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 2,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_offense_2_start.tga", "i_icon_m_research_offense_2_complete.tga"}
				-- --------------------------------
			},

		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					[1] = { 
							TypeName = "Masari_Peacebringer", 
							AbilityName="Masari_Peacebringer_Disintegrate_Unit_Ability", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_MOLECULAR_INSTABILITY",
							DescriptionTextID="TEXT_MASARI_RESEARCH_MOLECULAR_INSTABILITY", 
							IconName="i_icon_m_research_upgrade_molecular_instability.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="MasariSpawnPhoenixOnDeathGenerator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_PHOENIX",
							DescriptionTextID="TEXT_MASARI_RESEARCH_PHEONIX", 
							IconName="i_icon_m_research_upgrade_pheonix.tga"
						},
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 70,
				ResearchCost = 200,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 3,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_offense_3_start.tga", "i_icon_m_research_offense_3_complete.tga"}
				-- --------------------------------
			},
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					[1] = { 
							TypeName = "Masari_Natural_Interpreter", 
							AbilityName="Oracle_Piercing_Gaze_Light_Beam", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_PIERCING_GAZE",
							DescriptionTextID="TEXT_MASARI_RESEARCH_PIERCING_GAZE", 
							IconName="i_icon_m_piercing_gaze.tga" 
						},
					[2] = { TypeName = "Masari_Natural_Interpreter", AbilityName="Oracle_Piercing_Gaze_Dark_Beam", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities =
				{

				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="Masari_Magma_Channel_Upgrade_Generator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_BURST_THRESHOLD",
							DescriptionTextID="TEXT_MASARI_RESEARCH_BURST_THRESHOLD", 
							IconName="i_icon_m_research_upgrade_burst_threshold.tga" 
						},
				},

				LocksGenerators =
				{
					[1] = { EffectName="Masari_Magma_Channel_Generator", DescriptionTextID=nil, IconName=nil },
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 90,
				ResearchCost = 250,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "A",
				Index = 4,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_offense_4_start.tga", "i_icon_m_research_offense_4_complete.tga"}
				-- --------------------------------
			},
	}
	
	
	
	Branch_ICE = 
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
					[1] = { 
							TypeName = "Masari_Sky_Guardian", 
							AbilityName="Sky_Guardian_Gust_Unit_Ability", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_UNSEEN_BARRIER",
							DescriptionTextID="TEXT_MASARI_RESEARCH_UNSEEN_BARRIER", 
							IconName="i_icon_m_research_upgrade_unseen_barrier.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities =
				{
								
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
							
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="DMAStructureRegenGenerator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_ADVANCED_DARK_MATTER_ARMOR",
							DescriptionTextID="TEXT_MASARI_RESEARCH_ADVANCED_DARK_MATTER_ARMOR", 
							IconName="i_icon_m_research_advanced_dark_matter_armor.tga" 
						},
				},
				
				UnlocksEffects = 
				{
					
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 40,
				ResearchCost = 100,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 1,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_defense_1_start.tga", "i_icon_m_research_defense_1_complete.tga"}				
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
							ObjectType=Find_Object_Type("Masari_Hero_Alatea"), 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_HERO_ALTEA",
							DescriptionTextID="TEXT_MASARI_RESEARCH_HERO_ALTEA", 
							IconName="i_icon_m_research_upgrade_hero_altea.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{		
					[1] = { 
							TypeName = "Masari_Skylord", 
							AbilityName="Masari_Skylord_Screech_Attack",
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_AVERSION",							
							DescriptionTextID="TEXT_MASARI_RESEARCH_AVERSION", 
							IconName="i_icon_m_sa_screech.tga" 
						},

				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
										
				},
				
				UnlocksEffects = 
				{
					[1] = {
								EffectName="FireMineUpgradedDetonationEffect",
								TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_AREA_DENIAL",
								DescriptionTextID="TEXT_MASARI_RESEARCH_AREA_DENIAL_ALT",
								IconName="i_icon_m_sa_deploy_mine.tga",
							},
					
					[2] = {EffectName="IceMineUpgradedDetonationEffect", TitleTextID = nil, DescriptionTextID=nil, IconName=nil},
					[3] = {EffectName="IceMineUpgradedDetonationVisualEffect", TitleTextID = nil, DescriptionTextID=nil, IconName=nil},

				},
				
				LocksEffects=
				{
					[1] = { EffectName="FireMineDetonationEffect", DescriptionTextID=nil, IconName=nil },
					[2] = { EffectName="IceMineDetonationEffect", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="IceMineDetonationVisualEffect", DescriptionTextID=nil, IconName=nil },
				},
				

				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 55,
				ResearchCost = 150,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 2,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1,
				TextureMap = {"i_icon_m_research_defense_2_start.tga", "i_icon_m_research_defense_2_complete.tga"}				
				-- --------------------------------				
			},

		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="MasariSeekerAE_DMARegenGenerator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_FACILITATED_GROWTH",							
							DescriptionTextID="TEXT_MASARI_RESEARCH_FACILITATED_GROWTH", 
							IconName="i_icon_m_facilitated_growth.tga" 
						},
				},
				
				UnlocksEffects = 
				{
					[1] = { 
							EffectName="MasariFullArmorEffect", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_DARK_MATTER_AFINITY",							
							DescriptionTextID="TEXT_MASARI_RESEARCH_DARK_MATTER_AFINITY", 
							IconName="i_icon_m_research_dark_matter_afinity.tga" 
						},
				},
				
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 70,
				ResearchCost = 200,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 3,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_defense_3_start.tga", "i_icon_m_research_defense_3_complete.tga"}				
				-- --------------------------------
			},
			
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="Masari_Thermal_Vacuum_Upgrade_Generator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_DARK_EMBRACE",							
							DescriptionTextID="TEXT_MASARI_RESEARCH_DARK_EMBRACE", 
							IconName="i_icon_m_research_upgrade_dark_embrace.tga" 
							},
					
				},

				LocksGenerators =
				{
					[1] = { EffectName="Masari_Thermal_Vacuum_Generator", DescriptionTextID=nil, IconName=nil },
					
					[2] = {
							EffectName="DMARegenBlockerGenerator",
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_DARK_MATTER_MASTERY",
							DescriptionTextID="TEXT_MASARI_RESEARCH_DARK_MATTER_MASTERY", 
							IconName="i_icon_research_dark_matter_mastery.tga" 
							},
				},
				
				UnlocksEffects =
				{
					[1] = { EffectName="ThermalVacuumFriendlyAEEffect", DescriptionTextID=nil, IconName=nil },
				},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 90,
				ResearchCost = 250,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "B",
				Index = 4,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1,
				TextureMap = {"i_icon_m_research_defense_4_start.tga", "i_icon_m_research_defense_4_complete.tga"}				
				-- --------------------------------
			},
	}
	
	
	

	Branch_BALANCE = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{

				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="MasariStationaryRevelationGenerator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_STATIONARY_REVELATION",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_STATIONARY_REVELATION", 
							IconName="i_icon_m_research_upgrade_stationary_revelation.tga" 
						},
				
					[2] = { 
							EffectName="Masari_Sentry_Not_On_Radar_Upgrade_Effect_Generator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_METHODS_OF_DECEPTION",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_METHODS_OF_DECEPTION", 
							IconName="i_icon_m_research_upgrade_deception_methods.tga" 
						},
						
					[3] = { EffectName="Researched_Insignificance_Generator", DescriptionTextID=nil, IconName=nil },
				
				
				},
				
				LocksGenerators ={},
				
				UnlocksEffects ={},
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 40,
				ResearchCost = 100,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 1,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_balance_1_start.tga", "i_icon_m_research_balance_1_complete.tga"}				
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
							ObjectType=Find_Object_Type("Masari_Hero_Zessus"), 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_HERO_ZESSUS",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_HERO_ZESSUS", 
							IconName="i_icon_m_research_upgrade_hero_zessus.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities =
				{
					[1] = { 
							TypeName = "Masari_Architect", 
							AbilityName="Masari_Rebuild_Unit_Ability", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_RECONSTRUCTION",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_RECONSTRUCTION", 
							IconName="i_icon_recreate.tga" 
						},
				
					[2] = { 
							TypeName = "Masari_Seeker", 
							AbilityName="Inquisitor_Destabilize_Unit_Ability",
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_STASIS",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_STASIS", 
							IconName="i_icon_m_sa_destabilize.tga" 
						},

				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities =
				{
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators ={},

				LocksGenerators ={},
				
				UnlocksEffects ={},

				-- this sets it to default speed				
				ElementalModeModifer = 0.0,
								
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 55,
				ResearchCost = 150,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 2,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_balance_2_start.tga", "i_icon_m_research_balance_2_complete.tga"}				
				-- --------------------------------
			},


		Suite3 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="Matter_Engine_Researched_Leech_Effect", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_UNREGULATED_CONVERSION",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_UNREGULATED_CONVERSION", 
							IconName="i_icon_research_unregulated_conversion.tga" 
						},
				},

				LocksGenerators =
				{

				},
				
				UnlocksEffects =
				{
					[1] = { 
							EffectName="MasariSwitchCleanseEffect", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_CLEANSING_ENERGY",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_CLEANSING_ENERGY", 
							IconName="i_icon_m_research_cleansing_energy.tga" 
						},
				},

				-- elemental mode now changes 2x as fast
				ElementalModeModifer = 0.5,
				
				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 70,
				ResearchCost = 200,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 3,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_balance_3_start.tga", "i_icon_m_research_balance_3_complete.tga"}				
				-- --------------------------------
			},
			
			
		Suite4 =
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				--[[
					IMPORTANT : when determining which special ability to add to the table, do not forget to specify the 
					Object Type that special ability will affect!
					Eg. If we wanted to cancel the Special Ab.S pecial_Ability_Mech_Minirocket_Barrage then the entry 
					for that will look like:
						{Find_Object_Type("Novus_Hero_Mech"), "Special_Ability_Mech_Minirocket_Barrage"}
				
				]]--				
				UnlocksSpecialAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				--[[ SAME AS ABOVE ]]--
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators =
				{
					[1] = { 
							EffectName="MasariIncomeGenerator", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_ENERGY_STREAM",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_ENERGY_STREAM", 
							IconName="i_icon_research_energy_stream.tga" 
						},		
				},
				
				LocksGenerators =
				{

				},
				
				UnlocksEffects =
				{
					[1] = { 
							EffectName="Researched_Masari_Seer_Sight_Link_Cloaking_Effect", 
							TitleTextID = "TEXT_MASARI_RESEARCH_TITLE_SHADOWED_PERCEPTION",														
							DescriptionTextID="TEXT_MASARI_RESEARCH_SHADOWED_PERCEPTION", 
							IconName="i_icon_m_research_upgrade_shadowed_perception.tga" 
						},
					[2] = { EffectName="Masari_Seer_Cloaking_Effect", DescriptionTextID=nil, IconName=nil },
					[3] = { EffectName="DarkWeaponFriendlyHealEffect", DescriptionTextID=nil, IconName=nil },
				},
				

				-- DO NOT FORGET TO SET THE TIME IT WILL TAKE TO RESEARCH THIS SUITE
				TotalResearchTime = 90,
				ResearchCost = 250,
				-- -----------------------------------------------------------------------------------------------------------------
				-- TO BE DETERMINED BY DESIGN ---- END
				
				-- Internal Use
				-- --------------------------------
				Path = "C",
				Index = 4,
				Enabled = false,
				Completed = false,
				StartResearchTime = -1, 
				TextureMap = {"i_icon_m_research_balance_4_start.tga", "i_icon_m_research_balance_4_complete.tga"}				
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
	if not Branch_FIRE or not Branch_ICE or not Branch_BALANCE then
		return
	end
	
	Branches = {}
	Branches["A"] = { Name = Get_Game_Text("TEXT_MASARI_RESEARCH_BRANCH_A"), Icon = "i_icon_m_research_offense_branch.tga" }
	Branches[Branch_FIRE] = Branches["A"]
	
	Branches["B"] = { Name = Get_Game_Text("TEXT_MASARI_RESEARCH_BRANCH_B"), Icon = "i_icon_m_research_defense_branch.tga" }
	Branches[Branch_ICE] = Branches["B"]
	
	Branches["C"] = { Name = Get_Game_Text("TEXT_MASARI_RESEARCH_BRANCH_C"), Icon = "i_icon_m_research_balance_branch.tga" }
	Branches[Branch_BALANCE] = Branches["C"]
	
	PathToBranchMap = {}
	PathToBranchMap["A"] = Branch_FIRE
	PathToBranchMap["B"] = Branch_ICE
	PathToBranchMap["C"] = Branch_BALANCE 
end