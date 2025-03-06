-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/SpecialAbilities.lua#232 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/SpecialAbilities.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Mike_Lytle $
--
--            $Change: 89085 $
--
--          $DateTime: 2007/12/05 11:48:37 $
--
--          $Revision: #232 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

function Initialize_Special_Abilities(init_key_mappings)

	SPECIALABILITYACTION_INVALID = -1
	SPECIALABILITYACTION_TOGGLE = 1
	SPECIALABILITYACTION_TARGET_TERRAIN = 2
	SPECIALABILITYACTION_TARGET_OBJECT = 3
	SPECIALABILITYACTION_INSTANT = 4
	SPECIALABILITYACTION_ENABLE_BUILD_MODE = 5
	SPECIALABILITYACTION_TARGET_TERRAIN_FORWARD_TOGGLE = 6

	INVALID_FACTION_ID = Declare_Enum(-1)
	ALIEN_FACTION_ID = Declare_Enum(0)
	NOVUS_FACTION_ID = Declare_Enum()
	MASARI_FACTION_ID = Declare_Enum()
	PROTO_FACTION_ID = Declare_Enum()
	
	SpecialAbilities = 
	{
		-- Key the Special Abilities by name so that we can later map the game commands associated to them by keying the other table on the 
		-- game command.
		----------------------------------------
		-- Universal Special Abilities
		----------------------------------------
		["Unit_Ability_Eject_Garrison"] = 
			{ 
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_undeploy.tga",       
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ID_UNIT_ABILITY_UNLOAD_TRANSPORT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_UNLOAD_TRANSPORT",
				tooltip_category_id = "",
				sort_order = 0
			},
			
		-- ************************************************************************************************
		-- 			MILITARY SPECIAL ABILITIES
		-- ************************************************************************************************
		-- Dragoon Scan
		["Dragoon_Scan"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				-- Maria 08.29.2006	- Discarding the target entry because I added field in the XML specs of the unit ability so that the targeting type can be accessed
				-- from code!.  Thus, when activating the special ability from LUA, the inovked function in code will take care of
				-- retrieving the ability's targeting type!
				--target="LAND_ANY_LOCATION",
				icon="i_icon_dragoon_scan.tga",  
				-- TOOLTIP RELATED DATA
				text_id = "",
				tooltip_description_text_id = "",
				tooltip_category_id = "",
				sort_order = 3	
			},

		-- Dragoon Deploy	
		["Dragoon_Deploy"] = 
			{
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_Deploy.tga",        
				alt_icon="i_icon_undeploy.tga" ,
				-- TOOLTIP RELATED DATA
				text_id = "",
				tooltip_description_text_id = "",
				tooltip_category_id = "",
				sort_order = 4	
			},
			
		-- Tank Hero barrage
		["Thumper_Saturate_Area"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_saturate_area.tga", 
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MILITARY_SATURATE_AREA",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MILITARY_SATURATE_AREA",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 2	
			},
			
		-- Add Medic
		["Add_Medic"] = 
			{
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_medic.tga",  
				-- TOOLTIP RELATED DATA
				text_id = "",
				tooltip_description_text_id = "",
				tooltip_category_id = "",
				sort_order = 5			
			},


		["Randal_Moore_MedPac_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_h_sa_med_pack.tga",
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MILITARY_MOORE_MEDPACK",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MILITARY_MEDPACK",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 1	
			},

		-- Randal Moore Grenade Attack
		["Randal_Moore_Grenade_Attack_Ability"] = 
			{ 
				special_ability_name="Randal_Moore_Grenade_Attack_Special_Ability",   
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_h_sa_throw_grenade.tga", 
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MILITARY_MOORE_GRENADE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MILITARY_GRENADE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 1		
			},

		-- Randal Moore Grenade Attack
		["Aggressor_Grenade_Attack_Ability"] = 
			{ 
				special_ability_name="Aggressor_Grenade_Attack_Special_Ability",   
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="ABILITY_AGGRESSOR_INTERDICT.TGA", 
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_PLASMA_BOMB_AGGRESSOR",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PLASMA_BOMB_AGGRESSOR",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 18		
			},

		-- Apache Helicopter Rocket Barrage
		["Unit_Ability_Apache_Rocket_Barrage"] = 	
			{ 
				special_ability_name="Special_Ability_Apache_Rocket_Barrage",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				--action=SPECIALABILITYACTION_TARGET_OBJECT,    
				max_range=400.0,
				icon="militaryi_sa_Missile Strike.tga", 
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MILITARY_MISSILE_STRIKE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MILITARY_MISSILE_STRIKE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 6
			},



		-- ************************************************************************************************
		-- 			NOVUS SPECIAL ABILITIES
		-- ************************************************************************************************	
		-- Antimatter Tank: Vent Core
		["Unit_Ability_Antimatter_Spray_Projectiles_Attack"] = 
			{ 
				special_ability_name="Antimatter_Spray_Projectiles_Attack",     
				action=SPECIALABILITYACTION_INSTANT,    
				max_range=180.0,
				icon="i_icon_n_Antimatter_Tank_Vent_Core.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_VENT_CORE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_VENT_REACTOR",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 4		
			},

		-- Robotic infantry
		["Robotic_Infantry_Swarm"] = 
			{ 
				special_ability_name="Robotic_Infantry_Activate_Leap_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=80.0,
				icon="i_icon_n_Robotic_Infantry_Swarm_Attack.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_SWARM",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_DETONATE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_INITIATE",
				sort_order = 5
			},
			
		["Robotic_Infantry_Capture"] = 	
			{ 
				special_ability_name="Robotic_Infantry_Capture_Ability", 
				action=SPECIALABILITYACTION_TARGET_OBJECT,   
				max_range=2000.0,
				icon="i_icon_n_sa_capture.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_CAPTURE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_CAPTURE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_INITIATE",
				sort_order = 5
			},
			
		-- Mech Hero: mini-rocket barrage
		["Unit_Ability_Mech_Minirocket_Barrage"] = 	
			{ 
				special_ability_name="Special_Ability_Mech_Minirocket_Barrage",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				--action=SPECIALABILITYACTION_TARGET_OBJECT,    
				max_range=400.0,
				icon="i_icon_n_Heroine_Mecha_Missile_Barrage.tga", 
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_MISSILE_BARRAGE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_MISSILE_BARRAGE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				priority = 1,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
			},

		-- Mech Hero: vehicle snipe attack
		["Unit_Ability_Mech_Vehicle_Snipe_Attack"] = 	
			{ 
				special_ability_name="Mech_Vehicle_Snipe_Attack",    
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=400.0,
				icon="i_icon_n_Heroine_Mecha_Vehicle_Snipe.tga",

				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_VEHICLE_SNIPE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_SNIPE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_INITIATE", 
				priority = 2,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
			},
			
			
		-- Mech Hero: retreat from tactical ability
		["Novus_Mech_Retreat_From_Tactical_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_n_sa_xport_evac.tga",
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_HERO_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_MIRABEL_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_INITIATE",
				priority = 3,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
				
			},	

		-- Novus Founder hero: switch between prowess and performance
		["Novus_Founder_Toggle_Modes_1"] = 
			{
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_n_sa_reformat_performance.tga", 
				alt_icon="i_icon_n_sa_reformat_prowess.tga", 
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_PERFORMANCE_MODE",
				alt_text_id = "TEXT_ABILITY_NOVUS_PROWESS_MODE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_REFORMAT_PERFORMANCE",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_REFORMAT_PROWESS",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				priority = 1,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
			},
			
		-- Novus Founder hero: Signal Tap - acts like signal tower
		["Novus_Founder_Signal_Tap_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_n_sa_signal_tap_on.tga",
				alt_icon="i_icon_n_sa_signal_tap_off.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_SIGNAL_TAP_ON",
				alt_text_id = "TEXT_ABILITY_NOVUS_SIGNAL_TAP_OFF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_SIGNAL_TAP_ON",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_SIGNAL_TAP_OFF",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				priority = 2,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
			},
			
		-- Novus Founder hero: Rebuild
		["Novus_Founder_Rebuild_Unit_Ability"] =
			{
				special_ability_name="Novus_Founder_Rebuild_Special_Ability",
				action=SPECIALABILITYACTION_INSTANT,   
				icon="i_icon_n_sa_rebuild.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_REBUILD",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_RECYCLE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
			},

		-- Novus Founder: retreat from tactical ability
		["Novus_Founder_Retreat_From_Tactical_Ability"] =
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_n_sa_xport_evac.tga",
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_HERO_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_FOUNDER_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_INITIATE",
				priority = 4,	-- NOTE: this determines the order in which to display the abilities of each unit (whenever specified)
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.
			},


		-- Novus Variant toggle weapon ability
		["Novus_Variant_Toggle_Weapon_Ability"] =
			{ 
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_n_sa_weapon_off.tga", 
				alt_icon="i_icon_n_sa_weapon_on.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_WEAPON_OFF",
				alt_text_id = "TEXT_ABILITY_NOVUS_WEAPON_ON",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_WEAPON_OFF",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_WEAPON_ON_FIXED",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 6 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},	

		-- Novus Variant toggle weapon ability
		["Variant_Variant_Mode"] =
			{ 
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_n_sa_weapon_off.tga", 
				alt_icon="i_icon_n_sa_weapon_on.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_WEAPON_OFF",
				alt_text_id = "TEXT_ABILITY_NOVUS_WEAPON_ON",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_WEAPON_OFF",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_WEAPON_ON_FIXED",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 6 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},	
			
		-- Novus Variant toggle weapon ability
		["Variant_Mode"] =
			{ 
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_n_sa_weapon_on.tga", 
				alt_icon="i_icon_n_sa_weapon_off.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_WEAPON_ON",
				alt_text_id = "TEXT_ABILITY_NOVUS_WEAPON_ON",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_WEAPON_ON_FIXED",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_WEAPON_ON_FIXED",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 6 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},				

		-- Novus Dervish Jet: Dervish Spin Attack
		["Unit_Ability_Dervish_Spin_Attack"] =
			{ 
				special_ability_name="Dervish_Spin_Attack", 
				action=SPECIALABILITYACTION_INSTANT,    
				max_range = 2000.0,
				icon="i_icon_n_Dervish_Jet_Spin_Attack.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_SPIN_ATTACK",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_SPIN",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 7 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Novus Corruptor : Virus infection 
		["Corrupter_Virus_Infect"] =
			{
				special_ability_name="Corruptor_Virus_Infect_Ability", 
				action=SPECIALABILITYACTION_TARGET_OBJECT,   
				max_range=2000.0,
				icon="i_icon_n_sa_corrupt.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_CORRUPT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_CORRUPT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 8 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 	   
			},

		-- Novus Agent: Blackout Bomb
		["Unit_Ability_Blackout_Bomb_Attack"] =
			{ 
				specail_ability_name="Blackout_Bomb_Attack_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range = 300.0,
				icon="i_icon_n_sa_blackout_bomb.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_BLACKOUT_BOMB",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_BLACKOUT_BOMB",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 9 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 	   
			},	
			
		-- Novus Agent: Spawn Clones
		["Unit_Ability_Spawn_Clones"] =
			{ 
				action=SPECIALABILITYACTION_INSTANT,
				icon="i_icon_n_sa_duplicate.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_DUPLICATE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_DUPLICATE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_SPAWN",	   
				types_to_spawn = {"Novus_Reflex_Trooper_Clone"},
				sort_order = 9 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},			
		
		-- Novus Field Invertor: toggle between modes
		["Novus_Inverter_Toggle_Shield_Mode"] =
			{
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_n_sa_invert_to_shield.tga",
				alt_icon="i_icon_n_sa_invert_to_cannon.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_SHIELD_MODE",
				alt_text_id = "TEXT_ABILITY_NOVUS_CANNON_MODE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_INVERT_FIELD_SHIELD",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_INVERT_FIELD_CANNON",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 10 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 	   
			},

		-- Novus Hacker: Viral Bomb	
		["Novus_Hacker_Viral_Bomb_Unit_Ability"] = 
			{
				special_ability_name="Novus_Hacker_Viral_Bomb_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_n_sa_viral_bomb.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_VIRAL_BOMB",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_VIRAL_BOMB",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 11 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Novus Hacker: Viral Bomb	
		["Novus_Corruptor_Viral_Bomb_Unit_Ability"] = 
			{
				special_ability_name="Novus_Corruptor_Viral_Bomb_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_n_sa_viral_bomb.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_VIRAL_BOMB",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_VIRAL_BOMB",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 11 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
						
			
			
			-- Novus Hacker: Firewall Blast	
		["Novus_Hacker_Firewall"] = 
			{
				special_ability_name="Novus_Hacker_Firewall_Special_Ability",
				action=SPECIALABILITYACTION_INSTANT,
				max_range=200.0,
				icon="i_icon_n_sa_firewall.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_FIREWALL",
				tooltip_description_text_id = "TEXT_FIREWALL_HACKER",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 12 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Novus Evictor: Spawn Flow
		["Unit_Ability_Spawn_Flow"] =
			{ 
				action=SPECIALABILITYACTION_INSTANT,
				icon="I_ICON_N_RESEARCH_SIGNAL_BRANCH.TGA",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_HOTSPOT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_SPAWN_FLOW",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_SPAWN",	   
				types_to_spawn = {"Novus_Signal_Tower_Evictor"},
				sort_order = 12 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},						
			
		-- Novus Vertigo upload ability
		["Upload_Unit_Ability"] = 
			{ 
				special_ability_name="Upload_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,    
				max_range=2000.0,
				icon="i_icon_n_sa_upload.tga", 
				hide_with_behavior = BEHAVIOR_DATA_MATRIX,  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_UPLOAD",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_UPLOAD",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 1,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Novus Vertigo download ability
		["Download_Unit_Ability"] = 
			{
				special_ability_name="Download_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range=2000.0,
				icon="i_icon_n_sa_download.tga", 
				hide_without_behavior = BEHAVIOR_DATA_MATRIX,  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_DOWNLOAD",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_DOWNLOAD",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 2,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 

			},

		-- Novus Vertigo viral control ability
		["Viral_Control_Unit_Ability"] = 
			{  
				special_ability_name="Viral_Control_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,    
				max_range=2000.0,
				icon="i_icon_n_sa_viral_control.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_VIRAL_CONTROL",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_VIRAL_CONTROL",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Novus Vertigo retreat from tactical ability
		["Novus_Vertigo_Retreat_From_Tactical_Ability"] = 
			{  
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_n_sa_xport_evac.tga",  
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_HERO_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_VERTIGO_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 4,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Novus Constructor ability
		["Novus_Tactical_Build_Structure_Ability"] = 
			{ 
				special_ability_name="Novus_Constructor_Build_Ability",
				action=SPECIALABILITYACTION_ENABLE_BUILD_MODE,    
				max_range=2000.0,
				icon="i_icon_n_sa_construct.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_CONSTRUCT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_BUILD",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 12 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	    
			},

		-- Novus Amplifier ability
		["Novus_Amplifier_Harmonic_Pulse"] = 
			{ 
				special_ability_name="NovusAmplifierHarmonicPulseGeneratorAbility",
				action=SPECIALABILITYACTION_TOGGLE,
				--max_range = 2000.0,
				icon="i_icon_n_sa_harmonic_pulse_on.tga",
				alt_icon="i_icon_n_sa_harmonic_pulse_off.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_NOVUS_AMPLIFY_ON",
				alt_text_id = "TEXT_ABILITY_NOVUS_AMPLIFY_OFF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_HARMONIC_PULSE",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_NOVUS_RESONATE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 13 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	  
			},

		["Novus_Unload_Transport_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_n_sa_xport_unload.tga",       
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ID_UNIT_ABILITY_UNLOAD_TRANSPORT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_UNLOAD_TRANSPORT",
				tooltip_category_id = "",
				sort_order = 0
			},		
			
		-- ************************************************************************************************
		-- 			ALIEN SPECIAL ABILITIES
		-- ************************************************************************************************
		-- Alien reaper turret abilities
		["Reaper_Auto_Gather_Resources"] = 
			{
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_a_sa_auto_gather_on.tga",
				alt_icon="i_icon_a_sa_auto_gather_off.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_AUTO_GATHER_ON",
				alt_text_id = "TEXT_ABILITY_ALIEN_AUTO_GATHER_OFF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_AUTOGATHER",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_AUTOGATHER",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 4 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},


		-- Phase Tank personal phasing.
		["Tank_Phase_Unit_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_a_sa_phase_self.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_PHASE_SELF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PHASE_SELF",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 5 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	  
			},

			
		-- Foo Core/Foo Fighter abilities
		["Unit_Ability_Foo_Core_Heal_Attack_Toggle"] = 
			{
				special_ability_name="Special_Ability_Foo_Core_Heal_Attack_Toggle",
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_a_sa_repair_mode.tga",
				alt_icon="i_icon_a_sa_attack_mode.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_REPAIR_MODE",
				alt_text_id = "TEXT_ABILITY_ALIEN_ATTACK_MODE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_FOO_ATTACK_REPAIR",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_FOO_ATTACK_REPAIR",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 6 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	  
			},
		
		-- Kamal Re'x abilities
		["Kamal_Rex_Abduction_Unit_Ability"] = 
			{
				special_ability_name="Kamal_Rex_Abduction_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range = 150.0,
				icon="i_icon_a_sa_abduction.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_KAMAL_ABDUCT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_KAMAL_ABDUCT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 1,
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 				
			},

		["Kamal_Rex_Force_Wall_Unit_Ability"] = 
			{ 
				special_ability_name="Kamal_Rex_Force_Wall_Special_Ability", 
				action=SPECIALABILITYACTION_INSTANT,    
				max_range = 2000.0,
				icon="i_icon_a_sa_force_wall.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_KAMAL_FORCE_WALL",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_KAMAL_FORCE_WALL",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 2,
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Kamal Rex retreat from tactical ability
		["Kamal_Rex_Retreat_From_Tactical_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_a_sa_xport_evac.tga",
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_HERO_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_KAMAL_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_INITIATE",
				priority = 3,
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},	
			
		-- Brute abilities
		["Brute_Leap_Ability"] = 
			{ 
				special_ability_name="Alien_Brute_Leap_Special_Ability", 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range = 300.0,
				icon="i_icon_a_Brute_Jump.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_JUMP",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_LEAP",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 7 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		["Brute_Death_From_Above"] = 
			{ 
				special_ability_name="Alien_Brute_Activate_Death_From_Above_Ability",    
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range = 2000.0,
				icon="i_icon_a_Brute_Death_Jump.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_DEATH_FROM_ABOVE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_DEATH_FROM_ABOVE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 7 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	   
			},
			
		["Brute_Tackle_Ability"] = 
			{ 
				special_ability_name="Alien_Brute_Tackle_Special_Ability", 
				action=SPECIALABILITYACTION_TARGET_OBJECT,   
				max_range=2000.0,
				icon="i_icon_a_Brute_Charge_Attack.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_CHARGE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_TACKLE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 7 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},

		-- Alien Grunt abilities KDB 01-25-2007
		["Grunt_Capture"] = 
			{   
				special_ability_name="Alien_Grunt_Capture_Ability", 
				action=SPECIALABILITYACTION_TARGET_OBJECT,   
				max_range=2000.0,
				icon="i_icon_a_sa_capture.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_CAPTURE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_CAPTURE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 8 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	       
			},
			
		-- Alien scan drone abilities KDB 02-07-2007
		["Scan_Drone_Scan_Pulse"] = 	
			{ 
				special_ability_name="Alien_Scan_Drone_Scan_Pulse_Ability", 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_a_sa_scan_pulse.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_SCAN_PULSE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_SCAN_PULSE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 9 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	       
			},

		-- Alien detection array abilities KDB 07-10-2007 (this is a capturable structure and therefore needs to have art available from all factions)
		["Detection_Array_Scan_Pulse_Unit_Ability"] = 	
			{ 
				special_ability_name="Detection_Array_Scan_Pulse_Special_Ability", 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_a_sa_scan_pulse.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_SCAN_PULSE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_SCAN_PULSE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 9 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	       
			},

		
		-- Alien Defiler KDB 08-08-2006
		["Defiler_Radiation_Bleed"] = 	
			{
				special_ability_name="Alien_Defiler_Radiation_Bleed_Ability",
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_a_sa_bleed_mode.tga",  
				alt_icon="i_icon_a_sa_bleed_mode_off.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_BLEED_MODE_ON",
				alt_text_id = "TEXT_ABILITY_ALIEN_BLEED_MODE_OFF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_BLEED_MODE",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_BLEED_MODE_OFF",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 10 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},

		["Defiler_Radiation_Charge"] = 
			{ 
				special_ability_name="Alien_Defiler_Radiation_Charge_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,
				icon="i_icon_a_sa_project_radiation.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_PROJECT_RADIATION",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PROJECT_RADIATION",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 11 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},
			
		["Radiation_Artillery_Cannon_Attack"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range = 1000.0,
				icon="i_icon_a_sa_Launch_warhead.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_LAUNCH_RADIATION_WARHEAD",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_TERRAIN_CONDITIONER",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 12 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	   
			},
			
		["Assembly_Scarn_Beam"] = 
			{ 
				special_ability_name="Assembly_Scarn_Beam_Ability",    
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range = 2000.0,
				icon="i_icon_a_sa_scarn_beam.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_FIRE_SCARN_BEAM",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ALIEN_HP_SCARN_BEAM",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 13 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	    
			},			

		-- Walker science HP abilities
		-- Alien radiation wave
		["Alien_Radiation_Cascade_Unit_Ability"] = 	
			{
				special_ability_name="Alien_Radiation_Cascade_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,
				icon="i_icon_a_sw_radiation_wake.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_ACTIVATE_RADIATION_CASCADE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_RADIATION_CASCADE_GENERATOR",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 14 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},
			
		["Alien_Walker_Science_Dark_Matter_Vent"] = 
			{  
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_a_sa_Dark_Matter.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_VENT_DARK_MATTER",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_DARK_MATTER_VENT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 14 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	   
			},
			
		-- Alien Glyph Carver ability
		["Alien_Tactical_Build_Structure_Ability"] = 
			{ 
				special_ability_name="Alien_Glyph_Carver_Build_Ability",
				action=SPECIALABILITYACTION_ENABLE_BUILD_MODE,    
				max_range=2000.0,
				icon="i_icon_a_sa_carve.tga", 
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_CARVE_BROKEN_TEXT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_CARVE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 15 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- ALIEN Lost Ones plasma bomb.
		["Lost_One_Plasma_Bomb_Unit_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_a_sa_plasma_bomb.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_PLASMA_BOMB",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PLASMA_BOMB",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 16 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	   
			},

		-- ALIEN Lost One personal phasing.
		["Grey_Phase_Unit_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_a_sa_phase_self.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_PHASE_SELF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PHASE_SELF",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 16 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	    
			},

		-- ALIEN Monolith personal phasing.
		["Monolith_Phase_Unit_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_a_sa_phase_self.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_PHASE_SELF",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PHASE_SELF",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 17 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	    
			},

		-- Alien Orlok Hero Switch_To_Siege
		["Alien_Orlok_Switch_To_Siege_Mode"] = 
			{
				action=SPECIALABILITYACTION_TARGET_TERRAIN_FORWARD_TOGGLE,
				max_range=300.0,           
				icon="i_icon_a_sa_seige_mode.tga",  
				alt_icon="i_icon_a_sa_assault_mode.tga",  
			
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_ORLOK_SEIGE_MODE",
				alt_text_id = "TEXT_ABILITY_ALIEN_ORLOK_ASSAULT_MODE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_SIEGE_MODE",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_ASSAULT_MODE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				priority = 1,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 				
			},
			
		-- Alien Orlok Hero Switch_To_Endure
		["Alien_Orlok_Switch_To_Endure_Mode"] = 
			{       
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_a_sa_endure_mode.tga", 
				alt_icon="i_icon_a_sa_assault_mode.tga",  
		 
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_ORLOK_ENDURE_MODE",
				alt_text_id = "TEXT_ABILITY_ALIEN_ORLOK_ASSAULT_MODE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_ENDURE_MODE",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_ASSAULT_MODE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				priority = 2,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Alien Orlok Hero Retreat_From_Tactical
		["Alien_Orlok_Retreat_From_Tactical_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_a_sa_xport_evac.tga", 
				campaign_game_only = true,		
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_HERO_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_ORLOK_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},
			
		-- Alien hero Nufai: Paranoia Field ability
		["Alien_Nufai_Paranoia_Field_Ability"] = 
			{   
				special_ability_name="Alien_Nufai_Paranoia_Field_Special_Ability", 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_a_sa_paranoia.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_NUFAI_PARANOIA",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_PARANOIA",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 1,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Alien hero Nufai: Tendrils attack ability
		["Alien_Nufai_Tendrils_Ability"] = 
			{    		
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_a_sa_tendrils.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_NUFAI_TENDRILS",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_TENDRILS",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 2,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Alien hero Nufai: retreat from tactical ability
		["Alien_Nufai_Retreat_From_Tactical_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_a_sa_xport_evac.tga", 
				campaign_game_only = true,		
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_HERO_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_ALIEN_NUFAI_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		["Alien_Unload_Transport_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_a_sa_xport_unload.tga",       
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ID_UNIT_ABILITY_UNLOAD_TRANSPORT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_UNLOAD_TRANSPORT",
				tooltip_category_id = "",
				sort_order = 0
			},

			-- ************************************************************************************************
		-- 			MASARI SPECIAL ABILITIES
		-- ************************************************************************************************
		-- Masari Matter Engine
		["Matter_Engine_Self_Destruct_Ability"] = 
			{
				special_ability_name="Matter_Engine_Self_Destruct_Special_Ability", 
				action=SPECIALABILITYACTION_INSTANT,   
				icon="i_icon_m_sa_matter_engine_detonate.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_MATTER_ENGINE_DETONATE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_MATTER_ENGINE_DETONATE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 4 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},

		-- Masari Disciple
		["Disciple_Capture"] = 
			{
				special_ability_name="Masari_Disciple_Capture_Ability", 
				action=SPECIALABILITYACTION_TARGET_OBJECT,   
				max_range=2000.0,
				icon="i_icon_m_sa_capture.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_ALIEN_CAPTURE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_CAPTURE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 5 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},

		-- Masari Sky_Guardian_Gust
		["Sky_Guardian_Gust_Unit_Ability"] = 
			{ 
				special_ability_name="Sky_Guardian_Gust_Ability", 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_gust.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_GUST",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_MASARI_SKY_GUARDIAN_GUST",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 6 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	      
			},

		-- Masari Enforcer turns into Fire Vortex	
		["Masari_Enforcer_Fire_Vortex_Ability"] = 
			{
				action=SPECIALABILITYACTION_TOGGLE,    
				icon="i_icon_m_sa_vortex_on.tga", 
				alt_icon="i_icon_m_sa_vortex_off.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_ENERGY_VORTEX",
				alt_text_id = "TEXT_ABILITY_MASARI_ENERGY_VORTEX",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_ENERGY_VORTEX",
				alt_tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_ENERGY_VORTEX",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_TOGGLE",
				sort_order = 7 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	     
			},

		-- Masari Architect create structure ability
		["Masari_Tactical_Build_Unit_Ability"] = 
			{ 
				special_ability_name="Masari_Architect_Build_Ability",
				action=SPECIALABILITYACTION_ENABLE_BUILD_MODE,    
				max_range=2000.0,
				icon="I_icon_m_idle_builder.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_CREATE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_CREATE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 8 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	      
			},

		-- Masari Seeker destabilize ability
		["Inquisitor_Destabilize_Unit_Ability"] = 
			{
				special_ability_name="Inquisitor_Destabilize_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_m_sa_destabilize.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_DESTABILIZE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_DESTABILIZE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 9 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	   
			},


		--Masari Figment Deploy mine ability
		["Masary_Figment_Deploy_Mine_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_deploy_mine.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_DEPLOY_MINE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_DEPLOY_MINE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 10 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	   
			},

		-- Masari Hero Charos: Masari_Elemental_Fury_Ability
		["Masari_Elemental_Fury_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_elemental_fury.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_FRENZY",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_FRENZY",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 2,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
					
		-- Masari Hero Charos: Masari_Blaze_Of_Glory_Ability
		["Masari_Blaze_Of_Glory_Ability"] = 
			{  
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_blaze_of_glory.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_BLAZE_OF_GLORY",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_BLAZE_OF_GLORY",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Masari Hero Charos: Masari_Ice_Crystals_Ability
		["Masari_Ice_Crystals_Ability"] = 
			{  
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_ice_crystals.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_DARK_VORTEX",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_DARK_VORTEX",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 4,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

				
		-- Masari Hero Charos: retreat from tactical ability
		["Masari_Charos_Retreat_From_Tactical_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_m_sa_xport_evac.tga",  
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_CHAROS_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 5,
				sort_order = 1 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		-- Masari Hero Zessus: Blizzard_Ability
		["Masari_Zessus_Blizzard_Unit_Ability"] = 
			{ 
				special_ability_name="Masari_Zessus_Blizzard_Ability",
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_blizzard.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_DARK_MIASMA",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_MATTER_STORM",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 2,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},					
		-- Masari Hero Zessus: Heal
		["Masari_Zessus_Explode_Unit_Ability_Heal"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_blizzard.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_TRANSFUSION",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_TRANSFUSION",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 2,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},			
		-- Masari Hero Zessus: Teleportation ability
		["Masari_Zessus_Teleportation_Unit_Ability"] = 
		    { 
				special_ability_name="Masari_Zessus_Teleport_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				max_range=1000.0,
				icon="i_icon_m_sa_teleportation.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_TELEPORTATION",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_TELEPORTATION",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 1,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Masari Hero Zessus: Explode ability
		["Masari_Zessus_Explode_Unit_Ability"] = 
		    { 
				special_ability_name="Masari_Zessus_Explode_Ability",
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_explode.tga",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_EXPLODE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_EXPLODE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE", 
				priority = 2,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Masari Hero Zessus: Retreat from tactical ability
		["Masari_Zessus_Retreat_From_Tactical_Unit_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_m_sa_xport_evac.tga",  
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_ZESSUS_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,
				sort_order = 3 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},


		--Masari Peacebringer Disintegrate  ability 	
		["Masari_Peacebringer_Disintegrate_Unit_Ability"] = 
			{
				special_ability_name="Masari_Peacebringer_Disintegrate_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_m_sa_disintegrate.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_DISINTEGRATE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_DISINTEGRATE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 11 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Masari Sentry Unload ability
		["Masari_Sentry_Unload_Unit_Ability"] = 
			{
				special_ability_name="Masari_Sentry_Unload_Special_Ability",
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_unload.tga", 
				
				-- changing this one from hide_without_behavior to disable_without_behavior since
				-- this ability doesn't have a load counterpart.  Hence, we want to show the button
				-- but disabled.
				disable_without_behavior = BEHAVIOR_DATA_MATRIX,  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_UNLOAD",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_UNLOAD",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 12 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	    
			},
			
		-- Masari Skylord: Screech attack ability
		["Masari_Skylord_Screech_Attack"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_screech.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_SCREECH",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_SCREECH",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				sort_order = 13 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	  
			},
			
		-- Masari Templar: Sprinting ability
		["Unit_Ability_Zeal"] =
			{ 
				action=SPECIALABILITYACTION_INSTANT,
				icon="ABILITY_SPRINT_YELLOW.TGA",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_FLASH",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_FLASH",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",	   
				types_to_spawn = {"Invisible_Redirection_Field"},
				sort_order = 13 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},											
			
		["Unit_Ability_Zeale"] =
			{ 
				action=SPECIALABILITYACTION_INSTANT,
				icon="ABILITY_SPRINT_YELLOW.TGA",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_FLASH",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_FLASH",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",	   
				types_to_spawn = {"Invisible_Redirection_Field"},
				priority = 2,								
				sort_order = 15 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},									
			
		-- Masari Templar: Impervious Bubble Shield ability
		["Unit_Ability_Dark_Shield"] =
			{ 
				action=SPECIALABILITYACTION_INSTANT,
				icon="ABILITY_TEMPLAR_SHIELD_GLOW.TGA",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_DARK_SHIELD",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_DARK_SHIELD",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",	   
				types_to_spawn = {"Invisible_Redirection_Field"},
				priority = 3,								
				sort_order = 14 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},										
		["Unit_Ability_Stun_Shot"] =
			{ 
				special_ability_name="Stun_Shot_Special_Ability",   
				action=SPECIALABILITYACTION_TARGET_OBJECT,  
				icon="ARREST.TGA", 
				max_range=400.0,				

				text_id = "TEXT_ABILITY_MASARI_STUN_SHOT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_SNARE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				priority = 1,				
				sort_order = 1		
			},									
--[[		["Unit_Ability_Flashpoint"] =
			{ 
				action=SPECIALABILITYACTION_INSTANT,
				icon="ABILITY_FLASHPOINT.TGA",
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_FLASHPOINT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_FLASHPOINT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",	   
				types_to_spawn = {"Invisible_Redirection_Field"},
				sort_order = 16 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 		
			},										]]									
			
		["Unit_Ability_Phosphor_Shot"] =
			{ 
				special_ability_name="Phosphor_Shot_Special_Ability",   
				action=SPECIALABILITYACTION_TARGET_OBJECT,  
				icon="ABILITY_OVERKILL.tga", 
				max_range=400.0,				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_PHOSPHOR_ROCKET",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_PHOSPHOR_ROCKET",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_LAUNCH",
				sort_order = 17		
			},								

					
						
			
		-- Masari Hero Alatea: Unmake ability
		["Masari_Alatea_Unmake_Ability"] = 
			{ 
				special_ability_name="Masari_Alatea_Unmake_Special_Ability", 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,       
				icon="i_icon_m_sa_unmake.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_UNMAKE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_UNMAKE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 1,
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Masari Hero Alatea: peace ability
		["Masari_Alatea_Peace_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_INSTANT,    
				icon="i_icon_m_sa_peace.tga",  
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_PEACE",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_PEACE",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE", 
				priority = 2,
				sort_order = 2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},

		-- Masari Hero Alatea: retreat from tactical ability
		["Masari_Alatea_Retreat_From_Tactical_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TARGET_TERRAIN,    
				icon="i_icon_m_sa_xport_evac.tga",  
				campaign_game_only = true,
				
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ABILITY_MASARI_ALTEA_RETREAT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_MASARI_RETREAT",
				tooltip_category_id = "TEXT_TOOLTIP_CATEGORY_ACTIVATE",
				priority = 3,
				sort_order =2 -- NOTE: sort order determines the order in which to place the abilities for the unit type associated to them.	 
			},
			
		["Masari_Unload_Transport_Ability"] = 
			{ 
				action=SPECIALABILITYACTION_TOGGLE,            
				icon="i_icon_m_sa_xport_unload.tga",       
				-- TOOLTIP RELATED DATA
				text_id = "TEXT_ID_UNIT_ABILITY_UNLOAD_TRANSPORT",
				tooltip_description_text_id = "TEXT_TOOLTIP_DESCRIPTION_ABILITY_UNLOAD_TRANSPORT",
				tooltip_category_id = "",
				sort_order = 0
			},			


		-- ************************************************************************************************
		-- 			TEST SPECIAL ABILITIES
		-- PLEASE DON'T ADD ANY NON-TEST SPECIAL ABILITIES BEYOND THIS LINE!!!!
		-- ALSO, WHEN ADDING AN ABILITY, MAKE SURE YOU PLACE IT IN THE PROPER 
		-- FACTION GROUPING.  THANKS.
		-- ************************************************************************************************
			
		["Test_UI_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},

		["Location_Targeted_AE_Channeled_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},

		["Location_Targeted_AE_One_Shot_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_TERRAIN,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},

		["Enemy_Targeted_Channeled_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},
			
		["Enemy_Targeted_One_Shot_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},
			
		["Friendly_Targeted_Channeled_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},
			
		["Friendly_Targeted_One_Shot_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},	
			
		["Prevent_Special_Ability_Unit_Ability"] = 
			{
				text_id = "",
				special_ability_name="Prevent_Special_Ability_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_a_Brute_Charge_Attack.tga",
			},

		["Phasing_Test_Effect_Generator_Unit_Ability"] = 
			{
				text_id = "",
				special_ability_name="Phasing_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=30000.0,
				min_range=0.0,
				icon="i_icon_saturate_area.tga",
			},

		["Toggled_Aura_Channeled_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_saturate_area.tga",
			},
			
		["Toggled_Aura_One_Shot_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TOGGLE,
				icon="i_icon_saturate_area.tga",
			},	

		["Friendly_Targeted_One_Shot_Remove_Test_Effect_Generator"] = 
			{
				text_id = "",
				special_ability_name="Test_Effect_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},

		["Mind_Control_Unit_Ability_Test"] = 
			{
				text_id = "",
				special_ability_name="Mind_Control_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				max_range=300.0,
				icon="i_icon_saturate_area.tga",
			},

		["Apply_Generator_Unit_Ability_Test"] = 
			{
				text_id = "",
				special_ability_name="Apply_Generator_Special_Ability",
				action=SPECIALABILITYACTION_TARGET_OBJECT,
				range=300.0,
				icon="i_icon_saturate_area.tga",
			},	
			
			
		-- ************************************************************************************************
		-- 			TEST SPECIAL ABILITIES
		-- PLEASE DON'T ADD ANY NON-TEST SPECIAL ABILITIES BEYOND THIS LINE!!!!
		-- ALSO, WHEN ADDING AN ABILITY, MAKE SURE YOU PLACE IT IN THE PROPER 
		-- FACTION GROUPING.  THANKS.
		-- ************************************************************************************************		
	}
	
	
	if init_key_mappings then
		Init_Abilities_Key_Mappings()
	end	
end


-- ----------------------------------------------------------------
-- Get_Ability_Key_Mapping_Text
-- ----------------------------------------------------------------
function Get_Ability_Key_Mapping_Text(player, ability_name)
	local faction_id = Get_Player_Faction_ID(Find_Player("local"))
	if faction_id == INVALID_FACTION_ID then 
		return
	end
	
	return SANameToKeyMappingList[faction_id][ability_name]
end

-- ----------------------------------------------------------------
-- Init_Abilities_Key_Mappings
-- ----------------------------------------------------------------
function Init_Abilities_Key_Mappings()
	SANameToKeyMappingList = {}
	local faction_id = Get_Player_Faction_ID(Find_Player("local"))
	if  faction_id == ALIEN_FACTION_ID then
		Init_Alien_Abilities_Key_Mappings()
	elseif  faction_id == NOVUS_FACTION_ID then
		Init_Novus_Abilities_Key_Mappings()
	elseif  faction_id == PROTO_FACTION_ID then
		Init_Proto_Abilities_Key_Mappings()
	elseif faction_id == MASARI_FACTION_ID then
		Init_Masari_Abilities_Key_Mappings()
	end	
end

-- ----------------------------------------------------------------
-- Init_Abilities_Key_Mappings
-- ----------------------------------------------------------------
function Get_Player_Faction_ID(player)
	if Is_Player_Of_Faction(player, "ALIEN") then
		return ALIEN_FACTION_ID
	elseif Is_Player_Of_Faction(player, "NOVUS") then
		return NOVUS_FACTION_ID	
	elseif Is_Player_Of_Faction(player, "PROTO") then
		return PROTO_FACTION_ID	
	elseif Is_Player_Of_Faction(player, "MASARI") then
		return MASARI_FACTION_ID
	end	
	
	return INVALID_FACTION_ID
end

-- ----------------------------------------------------------------
-- Init_Novus_Abilities_Key_Mappings
-- ----------------------------------------------------------------
function Init_Novus_Abilities_Key_Mappings()
	SANameToKeyMappingList[NOVUS_FACTION_ID] = 
	{
		----------------------------------------
		-- Universal Special Abilities
		----------------------------------------
		["Novus_Unload_Transport_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_GENERIC_LAND_ABILITY_1", 1),
		
		-- ************************************************************************************************
		-- 			NOVUS SPECIAL ABILITIES
		-- ************************************************************************************************	
		-- Antimatter Tank: Vent Core
		["Unit_Ability_Antimatter_Spray_Projectiles_Attack"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_1", 1),
			
		-- Robotic infantry
		["Robotic_Infantry_Swarm"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_2", 1),
		["Robotic_Infantry_Capture"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_3", 1),
			
		-- Mech Hero
		["Unit_Ability_Mech_Minirocket_Barrage"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_4", 1),
		["Unit_Ability_Mech_Vehicle_Snipe_Attack"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_5", 1),
		["Novus_Mech_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_6", 1),
		
		-- Novus Founder hero
		["Novus_Founder_Toggle_Modes_1"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_7", 1),
		["Novus_Founder_Signal_Tap_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_8", 1),
		["Novus_Founder_Rebuild_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_9", 1),
		["Novus_Founder_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_10", 1),

		-- Novus Variant
		["Novus_Variant_Toggle_Weapon_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_11", 1),

		-- Novus Dervish Jet
		["Unit_Ability_Dervish_Spin_Attack"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_12", 1),
		
		-- Novus Corruptor : Virus infection 
		["Corrupter_Virus_Infect"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_13", 1),
		
		-- Novus Agent
		["Unit_Ability_Blackout_Bomb_Attack"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_14", 1),
		["Unit_Ability_Spawn_Clones"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_15", 1),
		
		-- Novus Field Inverter
		["Novus_Inverter_Toggle_Shield_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_16", 1),

		-- Novus Hacker
		["Novus_Hacker_Viral_Bomb_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_17", 1),	
		["Novus_Hacker_Firewall"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_18", 1),			

		-- Novus Vertigo
		["Upload_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_19", 1),
		["Download_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_20", 1),
		["Viral_Control_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_21", 1),
		["Novus_Vertigo_Retreat_From_Tactical_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_22", 1),
		
		-- Novus Constructor
		["Novus_Tactical_Build_Structure_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_23", 1),		

		-- Novus Amplifier
		["Novus_Amplifier_Harmonic_Pulse"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_24", 1)
	}
end

-- ----------------------------------------------------------------
-- Init_Alien_Abilities_Key_Mappings
-- ----------------------------------------------------------------
function Init_Alien_Abilities_Key_Mappings()
	SANameToKeyMappingList[ALIEN_FACTION_ID] = 	
	{
		----------------------------------------
		-- Universal Special Abilities
		----------------------------------------
		["Alien_Unload_Transport_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_GENERIC_LAND_ABILITY_1", 1),
		
		-- Kamal Re'x abilities			
		["Kamal_Rex_Abduction_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_1", 1),
		["Kamal_Rex_Force_Wall_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_2", 1),				
		["Kamal_Rex_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_3", 1),
		
		-- Alien Orlok Hero
		["Alien_Orlok_Switch_To_Siege_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_4", 1),	
		["Alien_Orlok_Switch_To_Endure_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_5", 1),	
		["Alien_Orlok_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_6", 1),	
		
		-- Alien hero Nufai
		["Alien_Nufai_Paranoia_Field_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_7", 1),	
		["Alien_Nufai_Tendrils_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_8", 1),	
		["Alien_Nufai_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_9", 1),	
		
		-- Alien reaper turret abilities
		["Reaper_Auto_Gather_Resources"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_10", 1),	
		
		-- Phase Tank personal phasing.
		["Tank_Phase_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_11", 1),					
		
		-- Foo Core/Foo Fighter abilities
		["Unit_Ability_Foo_Core_Heal_Attack_Toggle"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_12", 1),	
		["Alien_Ship_Toggle_Fire_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_28", 1),			
		
		-- Brute abilities
		["Brute_Leap_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_13", 1),	 
		["Brute_Death_From_Above"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_14", 1),	 
		["Brute_Tackle_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_15", 1),	 
		
		-- Alien Grunt abilities KDB 01-25-2007
		["Grunt_Capture"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_16", 1),	
			
		-- Alien scan drone abilities KDB 02-07-2007
		["Scan_Drone_Scan_Pulse"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_17", 1),		
			
		-- Alien detection array abilities KDB 07-10-2007 (this is a capturable structure and therefore needs to have art available from all factions)
		--["Detection_Array_Scan_Pulse_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_23", 1)		
		
		-- Alien Defiler KDB 08-08-2006
		["Defiler_Radiation_Bleed"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_18", 1),	
		["Defiler_Radiation_Charge"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_19", 1),	
		
		-- Artillery cannon
		["Radiation_Artillery_Cannon_Attack"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_20", 1),	
		
		["Assembly_Scarn_Beam"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_21", 1),	

		-- Walker science HP abilities
		-- Alien radiation wave
		["Alien_Radiation_Cascade_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_22", 1),		
		["Alien_Walker_Science_Dark_Matter_Vent"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_23", 1),	
		
		-- Alien Glyph Carver ability
		["Alien_Tactical_Build_Structure_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_24", 1),	
		
		-- ALIEN Lost Ones plasma bomb.
		["Lost_One_Plasma_Bomb_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_25", 1),	
		["Grey_Phase_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_26", 1),	
		
		-- ALIEN Monolith personal phasing.
		["Monolith_Phase_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_27", 1),	
		
		["Aggressor_Grenade_Attack_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_29", 1)			
	}
end

-- ----------------------------------------------------------------
-- Init_Masari_Abilities_Key_Mappings
-- ----------------------------------------------------------------
function Init_Masari_Abilities_Key_Mappings()
	SANameToKeyMappingList[MASARI_FACTION_ID] =
	{
		----------------------------------------
		-- Universal Special Abilities
		----------------------------------------
		["Masari_Unload_Transport_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_GENERIC_LAND_ABILITY_1", 1),
		
		-- Masari Matter Engine
		["Matter_Engine_Self_Destruct_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_1", 1),

		-- Masari Disciple
		["Disciple_Capture"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_2", 1), 

		-- Masari Sky Guardian
		["Sky_Guardian_Gust_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_3", 1), 
		
		-- Masari Enforcer
		["Masari_Enforcer_Fire_Vortex_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_4", 1),
		
		-- Masari Architect create structure ability
		["Masari_Tactical_Build_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_5", 1),

		--Masari Figment Deploy mine ability
		["Masary_Figment_Deploy_Mine_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_6", 1), 
			
		-- Masari Hero Charos
		["Masari_Elemental_Fury_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_7", 1), 
		["Masari_Blaze_Of_Glory_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_8", 1) ,
		["Masari_Ice_Crystals_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_9", 1), 
		["Masari_Charos_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_10", 1), 
		
		-- Masari Hero Zessus
		["Masari_Zessus_Blizzard_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_11", 1),
		["Masari_Zessus_Teleportation_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_12", 1),
		["Masari_Zessus_Explode_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_13"),
		["Masari_Zessus_Retreat_From_Tactical_Unit_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_14", 1),
		
		--Masari Peacebringer Disintegrate  ability 	
		["Masari_Peacebringer_Disintegrate_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_15", 1), 
		
		-- Masari Sentry Unload ability
		["Masari_Sentry_Unload_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_16", 1), 
		
		-- Masari Skylord: Screech attack ability
		["Masari_Skylord_Screech_Attack"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_17", 1),
		
		-- Masari Hero Alatea
		["Masari_Alatea_Unmake_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_18", 1),
		["Masari_Alatea_Peace_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_19", 1),
		["Masari_Alatea_Retreat_From_Tactical_Ability"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_20", 1),
		
		-- Masari Seeker destabilize ability
		["Inquisitor_Destabilize_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_21", 1),
		
		-- Masari Seeker destabilize ability
		["Unit_Ability_Dark_Shield"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_23", 1), 		
		["Unit_Ability_Phosphor_Shot"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_24", 1), 		
		["Unit_Ability_Zeal"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_22", 1), 				
	}		
end

-- ----------------------------------------------------------------
-- Init_Alien_Abilities_Key_Mappings
-- ----------------------------------------------------------------
function Init_Proto_Abilities_Key_Mappings()
	SANameToKeyMappingList[PROTO_FACTION_ID] = 	
	{
		----------------------------------------
		-- Universal Special Abilities
		----------------------------------------
		["Alien_Unload_Transport_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_GENERIC_LAND_ABILITY_1", 1),
		
		-- Kamal Re'x abilities			
		["Kamal_Rex_Abduction_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_1", 1),
		["Kamal_Rex_Force_Wall_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_2", 1),				
		["Kamal_Rex_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_3", 1),
		
		-- Alien Orlok Hero
		["Alien_Orlok_Switch_To_Siege_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_4", 1),	
		["Alien_Orlok_Switch_To_Endure_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_5", 1),	
		["Alien_Orlok_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_6", 1),	
		
		-- Alien hero Nufai
		["Alien_Nufai_Paranoia_Field_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_7", 1),	
		["Alien_Nufai_Tendrils_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_8", 1),	
		["Alien_Nufai_Retreat_From_Tactical_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_9", 1),	
		
		-- Alien reaper turret abilities
		["Reaper_Auto_Gather_Resources"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_10", 1),	
		
		-- Phase Tank personal phasing.
		["Tank_Phase_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_11", 1),					
		
		-- Foo Core/Foo Fighter abilities
		["Unit_Ability_Foo_Core_Heal_Attack_Toggle"] =  Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_12", 1),	
		["Alien_Ship_Toggle_Fire_Mode"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_28", 1),			
		
		-- Brute abilities
		["Brute_Leap_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_13", 1),	 
		["Brute_Death_From_Above"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_14", 1),	 
		["Brute_Tackle_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_15", 1),	 
		
		-- Alien Grunt abilities KDB 01-25-2007
		["Grunt_Capture"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_16", 1),	
			
		-- Alien scan drone abilities KDB 02-07-2007
		["Scan_Drone_Scan_Pulse"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_17", 1),		
			
		-- Alien detection array abilities KDB 07-10-2007 (this is a capturable structure and therefore needs to have art available from all factions)
		--["Detection_Array_Scan_Pulse_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_23", 1)		
		
		-- Alien Defiler KDB 08-08-2006
		["Defiler_Radiation_Bleed"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_18", 1),	
		["Defiler_Radiation_Charge"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_19", 1),	
		
		-- Artillery cannon
		["Radiation_Artillery_Cannon_Attack"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_20", 1),	
		
		["Assembly_Scarn_Beam"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_21", 1),	

		-- Walker science HP abilities
		-- Alien radiation wave
		["Alien_Radiation_Cascade_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_22", 1),		
		["Alien_Walker_Science_Dark_Matter_Vent"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_23", 1),	
		
		-- Alien Glyph Carver ability
		["Alien_Tactical_Build_Structure_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_24", 1),	
		
		-- ALIEN Lost Ones plasma bomb.
		["Lost_One_Plasma_Bomb_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_25", 1),	
		["Grey_Phase_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_26", 1),	
		
		-- ALIEN Monolith personal phasing.
		["Monolith_Phase_Unit_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_27", 1),	
		
		["Aggressor_Grenade_Attack_Ability"] = Get_Game_Command_Mapped_Key_Text("COMMAND_LAND_ABILITY_29", 1)			
	}
end
