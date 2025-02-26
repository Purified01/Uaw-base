if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true


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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/Novus_Packaged_Research_Tree.lua 
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/10/05 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
	

require("Research_Common")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.07.2006
--
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Research_Tree(tactical_only_game)

	SyncMessage("Novus_Packaged_Research_Tree::Init_Research_Tree -- tactical_only_game: %s, Player: %s\n", tostring(tactical_only_game), tostring(Player))
	
	Script.Set_Async_Data("AdditionalFacilityRequiredText", "TEXT_ADDITIONAL_RESEARCH_NOVUS")
	
	Packages = {}
	-- is now Branch network
	Branch_SIGNAL = {}
	Branch_NANOTECH = {}
	Branch_COMPUTING = {}


	Branch_SIGNAL = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!		
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},				
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
							EffectName="NovusResearchRapidFlowEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_RAPID_FLOW",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_RAPID_FLOW_EFFECT", 
							IconName="i_icon_n_research_upgrade_rapid_flow.tga" 
						},
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Extrapolation"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_EXTRAPOLATION_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_EXTRAPOLATION_PATCH", 
							IconName="i_icon_n_research_upgrade_extrapolation_patch.tga" 
						},
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
				TextureMap = {"i_icon_n_research_signal_1_start.tga", "i_icon_n_research_signal_1_complete.tga"}
				-- --------------------------------
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				UnlocksTypes = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Hero_Founder"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_HERO_FOUNDER",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_HERO_FOUNDER", 
							IconName="i_hero_novus_founder.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
							EffectName="NovusShieldCloakEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_STEALTH_UPGRADES",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_STEALTH_UPGRADES", 
							IconName="i_icon_n_research_upgrade_stealth_upgrades.tga" 
						},
					[2] = { EffectName="NovusReflexTrooperCloakEffectGenerator", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Spectrum_Cycle"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_SPECTRUM_CYCLE_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_SPECTRUM_CYCLE_PATCH", 
							IconName="i_icon_n_research_upgrade_spectrum_cycle_patch.tga" 
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
				TextureMap = {"i_icon_n_research_signal_2_start.tga", "i_icon_n_research_signal_2_complete.tga"} 
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
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities =
				{
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {

				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
							EffectName="NovusResearchAdvancedFlowEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_ADVANCED_FLOW_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_ADVANCED_FLOW_EFFECT", 
							IconName="i_icon_n_research_upgrade_advanced_flow.tga" 
						},
						
					[2] = { 
							EffectName="NovusResearchPowerEfficiencyEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_POWER_EFFICIENCY_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_POWER_EFFICIENCY_EFFECT", 
							IconName="i_icon_n_research_upgrade_power_efficiency.tga" 
						},
						
					[3] = { 
							EffectName="NovusResearchNanitePurificationEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_NANITE_PURIFICATION",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_NANITE_PURIFICATION", 
							IconName="i_icon_n_research_upgrade_nanite_purification.tga" 
						},
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {},
				
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
				TextureMap = {"i_icon_n_research_signal_3_start.tga", "i_icon_n_research_signal_3_complete.tga"}  
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
				UnlocksUnitAbilities = {
				
					[1] = { 
							TypeName = "Novus_Amplifier", 
							AbilityName="Resonance_Cascade_Beam_Effect_Generator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_CASCADE_RESONANCE_BEAM_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_CASCADE_RESONANCE_BEAM_EFFECT", 
							IconName="i_icon_n_research_upgrade_cascade_resonance_beam.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities =
				{
					[1] = { TypeName = "Novus_Amplifier", AbilityName="Resonance_Beam_Effect_Generator", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Emergency_Power"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_EMERGENCY_POWER_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_EMERGENCY_POWER_PATCH", 
							IconName="i_icon_n_research_upgrade_emergency_power_patch.tga" 
						},
						
					[2] = { 	
							ObjectType=Find_Object_Type("Novus_Patch_Overclocking"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_OVERCLOCKING",
							DescriptionTextID="TEXT_NOVUS_PATCH_DESCRIPTION_OVERCLOCKING", 
							IconName="i_icon_n_patch_overclock.tga" 
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
				TextureMap = {"i_icon_n_research_signal_4_start.tga", "i_icon_n_research_signal_4_complete.tga"}  
				-- --------------------------------
			},
	}
	
	
	
	Branch_NANOTECH = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},

				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
					-- Maria 06.29.2007 - This ability got replaced by the generator "NovusReflexTrooperSpawnClonesUpgradeGenerator"
					-- so we are moving the unlock entry to the UnlockGenerator
					--[[
					[1] = { 
							TypeName = "Novus_Reflex_Trooper", 
							AbilityName="Unit_Ability_Spawn_Clones_Upgrade", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_SPAWN_CLONES_ABILITY",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_SPAWN_CLONES_ABILITY", 
							IconName="i_icon_n_research_upgrade_spawn_clones_ability.tga" 
						},
						]]--
					--CUT: [2] = { AbilityName="Novus_Variant_Sustained_Mimic_Ability", DescriptionTextID="TEXT_NOVUS_RESEARCH_VARIANT_SUSTAINED_MIMICRY", IconName="i_icon_n_research_upgrade_variant_sustained_mimicry.tga" },
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
					-- Maria 06.29.2007 - We don't need this now since we have only one ability and the generator is the one that takes care 
					-- of upgrading it!. So we only need to lock the generator. (see below)
					--[1] = { TypeName = "Novus_Reflex_Trooper", AbilityName="Unit_Ability_Spawn_Clones", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!	
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksSpecialAbilities = {
				},
							
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
								EffectName="NovusReflexTrooperSpawnClonesUpgradeGenerator",
								TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_SPAWN_CLONES_ABILITY",
								DescriptionTextID="TEXT_NOVUS_RESEARCH_SPAWN_CLONES_ABILITY", 
								IconName="i_icon_n_research_upgrade_spawn_clones_ability.tga" 
						},
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Backup_Systems"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_BACKUP_SYSTEMS_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_BACKUP_SYSTEMS_PATCH", 
							IconName="i_icon_n_research_upgrade_backup_systems_patch.tga" 
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
				TextureMap = {"i_icon_n_research_nanotech_1_start.tga", "i_icon_n_research_nanotech_1_complete.tga"}   
				-- --------------------------------				
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Hero_Mech"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_HERO_MIRABEL",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_HERO_MIRABEL",
							IconName="i_icon_nv_mirabel_viktor.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
							EffectName="NovusResearchCollectionEfficiencyEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_COLLECTOR_SPEED_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_COLLECTOR_SPEED_EFFECT", 
							IconName="i_icon_n_research_upgrade_collector_speed.tga" 
							},
				},

				LocksEffects =
				{
					[1] = { EffectName="NovusCollectorGatherResourcesVisualEffect", DescriptionTextID=nil, IconName=nil },
				},

				UnlocksEffects =
				{
					[1] = { EffectName="NovusCollectorGatherUpgradeVisualEffect", DescriptionTextID=nil, IconName=nil },
				},

				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Optimized_Collection"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_OPTIMIZED_COLLECTION_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_OPTIMIZED_COLLECTION_PATCH", 
							IconName="i_icon_n_research_upgrade_optimized_collection_patch.tga" 
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
				TextureMap = {"i_icon_n_research_nanotech_2_start.tga", "i_icon_n_research_nanotech_2_complete.tga"}   
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
				UnlocksUnitAbilities = {
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = {
							EffectName="NovusResearchMatterConversionBlockEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_MATTER_CONVERSION_ABILITY",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_MATTER_CONVERSION_ABILITY", 
							IconName="i_icon_n_research_upgrade_matter_conversion_ability.tga" 
						},
					[2] = { 
							EffectName="NovusResearchRapidRebuildEffectGenerator",
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_RAPID_REBUILD_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_RAPID_REBUILD_EFFECT", 
							IconName="i_icon_n_research_upgrade_rapid_rebuild.tga" 
						},
					[3] = { EffectName="NovusResearchRapidRebuildBlockEffectGenerator", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {		
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
				TextureMap = {"i_icon_n_research_nanotech_3_start.tga", "i_icon_n_research_nanotech_3_complete.tga"}    
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
				UnlocksUnitAbilities = {
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = {
							EffectName="NovusResearchNaniteRefinementEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_NANITE_REFINEMENT_ABILITY",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_NANITE_REFINEMENT_ABILITY", 
							IconName="i_icon_n_research_upgrade_nanite_refinement_ability.tga" 
						},
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Optimized_Assembly"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_OPTIMIZED_ASSEMBLY",
							DescriptionTextID="TEXT_NOVUS_PATCH_DESCRIPTION_OPTIMIZED_ASSEMBLY", 
							IconName="i_icon_n_patch_optimized_assembly.tga" 
						},
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
				TextureMap = {"i_icon_n_research_nanotech_4_start.tga", "i_icon_n_research_nanotech_4_complete.tga"}    
				-- --------------------------------
			},
	}
	
	
	

	Branch_COMPUTING = 
	{
		Suite1 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
							EffectName="NovusResearchRapidPatchingEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_RAPID_PATCHING_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_RAPID_PATCHING_EFFECT", 
							IconName="i_icon_n_research_upgrade_rapid_patching.tga" 
						},
					[2] = { 
							EffectName="VirusInfectAuraGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_VIRAL_CONTAGION",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_VIRAL_CONTAGION", 
							IconName="i_icon_n_research_upgrade_viral_contagion.tga" 
						},
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
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
				TextureMap = {"i_icon_n_research_computing_1_start.tga", "i_icon_n_research_computing_1_complete.tga"}    
				-- --------------------------------
			},

		Suite2 = 
			{
				-- TO BE DETERMINED BY DESIGN ---- BEGIN
				-- -----------------------------------------------------------------------------------------------------------------
				-- List of types that will be unlocked when research of this suite is completed!
				UnlocksTypes = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Hero_Vertigo"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_HERO_VERTIGO",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_HERO_VERTIGO", 
							IconName="i_icon_nv_vertigo.tga" 
						},
				},
				
				-- List of UNIT ABILITIES that will be UNLOCKED when research of this suite is completed!				
				UnlocksUnitAbilities = {
					[1] = { TypeName = "Novus_Hacker", AbilityName="Novus_Hacker_Lockdown_Area_Unit_Ability", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
					[1] = { TypeName = "Novus_Hacker", AbilityName="Novus_Hacker_Control_Turret_Unit_Ability", DescriptionTextID=nil, IconName=nil },
					[2] = { TypeName = "Novus_Hacker", AbilityName="Novus_Hacker_Lockdown_Unit_Ability", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
					[1] = { ObjectType=Find_Object_Type("Novus_Hacker"), AbilityName="Novus_Hacker_Control_Turret_Area_Special_Ability", DescriptionTextID=nil, IconName=nil },
					[2] = { ObjectType=Find_Object_Type("Novus_Hacker"), AbilityName="Novus_Hacker_Lockdown_Area_Special_Ability", DescriptionTextID=nil, IconName=nil },
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					[1] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Viral_Reboot"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_VIRAL_REBOOT_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_VIRAL_REBOOT_PATCH", 
							IconName="i_icon_n_research_upgrade_viral_reboot_patch.tga" 
						},
						
					[2] = { 
							ObjectType=Find_Object_Type("Novus_Patch_Reboot"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_REBOOT_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_REBOOT_PATCH", 
							IconName="i_icon_n_research_upgrade_reboot_patch.tga" 
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
				TextureMap = {"i_icon_n_research_computing_2_start.tga", "i_icon_n_research_computing_2_complete.tga"}     
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
				UnlocksUnitAbilities = {
				
				[1] = { 
							TypeName = "Novus_Hacker", 
							AbilityName="Novus_Hacker_Control_Turret_Area_Unit_Ability", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_IMPROVED_MANIPULATION",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_IMPROVED_MANIPULATION", 
							IconName="i_icon_n_research_upgrade_improved_manipulation.tga" 
						},
				
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				
				[1] = { ObjectType=Find_Object_Type("Novus_Field_Inverter_Shield_Mode"), AbilityName="Inverter_Shield_Redirect_Projectile", DescriptionTextID=nil, IconName=nil },
				
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
				
				[1] = { EffectName="NovusShieldRedirectionVisualGenerator", DescriptionTextID=nil, IconName=nil },
				
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {
					
					[1] = {
							ObjectType=Find_Object_Type("Novus_Patch_Viral_Cascade"), 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_VIRAL_CASCADE_PATCH",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_VIRAL_CASCADE_PATCH", 
							IconName="i_icon_n_research_upgrade_viral_cascade_patch.tga" 
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
				TextureMap = {"i_icon_n_research_computing_3_start.tga", "i_icon_n_research_computing_3_complete.tga"}     
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
				UnlocksUnitAbilities = {
				},
				
				-- List of UNIT ABILITIES that will be LOCKED when research of this suite is completed!				
				LocksUnitAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be UNLOCKED when research of this suite is completed!
				UnlocksSpecialAbilities = {
				},
				
				-- List of SPECIAL ABILITIES that will be LOCKED when research of this suite is completed!
				LocksSpecialAbilities = {
				},
				
				-- List of EEFECTS that will be UNLOCKED when research of this suite is completed!				
				UnlocksGenerators = {
					[1] = { 
							EffectName="NovusResearchViralMagneticsEffectGenerator", 
							TitleTextID = "TEXT_NOVUS_RESEARCH_TITLE_VIRAL_MAGNETICS_EFFECT",
							DescriptionTextID="TEXT_NOVUS_RESEARCH_VIRAL_MAGNETICS_EFFECT", 
							IconName="i_icon_n_research_upgrade_viral_magnetics.tga" 
						},
--					[2] = { EffectName="NovusRapidCompressionGenerator", DescriptionTextID="TEXT_NOVUS_RESEARCH_RAPID_COMPRESSION_EFFECT", IconName="i_icon_n_research_upgrade_rapid_compression.tga" },
				},
				
				-- List of PATCHES that will be UNLOCKED when research of this suite is completed!				
				UnlocksPatches = {},
				
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
				TextureMap = {"i_icon_n_research_computing_4_start.tga", "i_icon_n_research_computing_4_complete.tga"}     
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
	if not Branch_SIGNAL or not Branch_NANOTECH or not Branch_COMPUTING then
		return
	end
	
	Branches = {}
	Branches["A"] = { Name = Get_Game_Text("TEXT_NOVUS_RESEARCH_BRANCH_A"), Icon = "i_icon_n_research_signal_branch.tga" }
	Branches[Branch_SIGNAL] = Branches["A"]
	
	Branches["B"] = { Name = Get_Game_Text("TEXT_NOVUS_RESEARCH_BRANCH_B"), Icon = "i_icon_n_research_nanotech_branch.tga" }
	Branches[Branch_NANOTECH] = Branches["B"]
	
	Branches["C"] = { Name = Get_Game_Text("TEXT_NOVUS_RESEARCH_BRANCH_C"), Icon = "i_icon_n_research_computing_branch.tga" }
	Branches[Branch_COMPUTING] = Branches["C"]
	
	
	PathToBranchMap = {}
	PathToBranchMap["A"] = Branch_SIGNAL
	PathToBranchMap["B"] = Branch_NANOTECH
	PathToBranchMap["C"] = Branch_COMPUTING 
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

