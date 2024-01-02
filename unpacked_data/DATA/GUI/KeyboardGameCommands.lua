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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/KeyboardGameCommands.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/03/28
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

--[[
	THIS TABLE CONTAINS ALL THE GAME COMMANDS THAT ARE LINKED TO THE KEYBOARD.  THIS DATA IS
	USED TO POPULATE AND MANAGE THE KEYBOARD CONFIGURATION MENU
	
]]--

-- The key to the table is the Command_Name (eg. COMMAND_GROUP_0_SELECT, etc.)
KeyboardGameCommands = {


-- ********************************************************************************************************
-- 				GENERIC INTERFACE (ie. good for both strategic and tactical modes)
-- ********************************************************************************************************

["Generic_Interface"] = 
{

	["COMMAND_SCROLL_UP"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_SCROLL_UP",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 0
		},
		
	["COMMAND_SCROLL_DOWN"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_SCROLL_DOWN",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 1
		},
		
	["COMMAND_SCROLL_LEFT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_SCROLL_LEFT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 2
		},
		
	["COMMAND_SCROLL_RIGHT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_SCROLL_RIGHT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 3
		},

	["COMMAND_TOGGLE_RESEARCH_TREE_DISPLAY"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_TOGGLE_RESEARCH_TREE_DISPLAY",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 4
		},

	-- COMMANDS USED TO ACCESS HEROES (by the order in which they appeared depicted through the corresponding hero buttons)
	["COMMAND_HERO_1"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACCESS_HERO_1",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 5
		},
		
	["COMMAND_HERO_2"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACCESS_HERO_2",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 6
		},
		
	["COMMAND_HERO_3"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACCESS_HERO_3",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 7
		},
		
	["COMMAND_SWITCH_TO_GAME_EVENT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_SWITCH_TO_GAME_EVENT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 0				
		},
				
	["COMMAND_QUICK_SAVE"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_QUICK_SAVE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 8
		},	

	-- THE FOLLOWING COMMANDS ARE HERE FOR DISPLAY PURPOSES BUT ARE NOT RE-ASSIGNABLE!.
	-- -----------------------------------------------------------------------------------------------------------------------
	["COMMAND_INITIATE_CHAT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_INITIATE_CHAT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 11
		},
		
	["COMMAND_INITIATE_TEAM_CHAT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_INITIATE_TEAM_CHAT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 12
		},
		
	["COMMAND_INITIATE_VOICECHAT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_INITIATE_VOICECHAT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 13
		},
		
	["COMMAND_DISMISS_DIALOG"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_DISMISS_DIALOG",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 14
		},	


},


-- ********************************************************************************************************
-- 			TACTICAL INTERFACE
-- ********************************************************************************************************
["Tactical_Interface"] = 
{
	["COMMAND_ACTIVATE_AIR_BUILD_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_AIR_BUILD_QUEUE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 1		
		},		

	["COMMAND_ACTIVATE_VEHICLE_BUILD_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_VEHICLE_BUILD_QUEUE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 2		
		},	
	
	["COMMAND_ACTIVATE_INFANTRY_BUILD_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_INFANTRY_BUILD_QUEUE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 3		
		},
		
	["COMMAND_ACTIVATE_COMMAND_BUILD_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_COMMAND_BUILD_QUEUE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 4	
		},
	
	["COMMAND_TOGGLE_SELL_MODE"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_TOGGLE_SELL_MODE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 5
		},
		
	["COMMAND_BATTLE_CAM"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_BATTLE_CAM",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 6			
		},
		
	["COMMAND_CINEMATIC_PREVIEW"] = 
	{
		-- Text ID to describe this command in the menu
		text_id = "TEXT_GAME_COMMAND_CINEMATIC_PREVIEW",
		icon_name = "",
		display = true,	
		can_be_re_assigned = true,
		sort_order = 7			
	},
	
	["COMMAND_CAMERA_RESET"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_CAMERA_RESET",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 8
		},
		
	["COMMAND_CAMERA_CENTER"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_CAMERA_CENTER",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 9
		},
		
	["COMMAND_TETHER_CAMERA"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_CAMERA_TETHER",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 10
		},

		
	["COMMAND_PLAYER_LIST"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_PLAYER_LIST",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 11
		},
		
	["COMMAND_REPLAY_TOGGLE_CAMERA"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_REPLAY_TOGGLE_CAMERA",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 12,
		},		
		
	["COMMAND_CAMERA_VIEW_ROTATE_LEFT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_CAMERA_ROTATE_LEFT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 13
		},
		
	["COMMAND_CAMERA_VIEW_ROTATE_RIGHT"] =
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_CAMERA_ROTATE_RIGHT",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 14
		},
},


-- ********************************************************************************************************
-- 				UNIT CONTROL
-- ********************************************************************************************************
["Unit_Control"] = 
{
	["COMMAND_SELECT_LIKE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_SELECT_LIKE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 0				
		},
	
	["COMMAND_SELECT_LAST_USED"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_SELECT_LAST_USED",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 1				
		},

	["COMMAND_SELECT_ALL"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_SELECT_ALL",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 2		
		},

	["COMMAND_FIND_BUILDER"] = 
		{
			text_id = "TEXT_UI_TACTICAL_IDLE_BUILDER_BUTTON",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 3
		},
	
	["COMMAND_STOP"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_STOP",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 4				
		},
		
	["COMMAND_GENERIC_LAND_ABILITY_1"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			generic_unit_ability_name = "Unit_Ability_Eject_Garrison",
			faction_to_unit_ability_name = 
				{
					["ALIEN"] = {unit_ability_name = "Alien_Unload_Transport_Ability"},
					["NOVUS"] = {unit_ability_name = "Novus_Unload_Transport_Ability"},
					["MASARI"] = {unit_ability_name = "Masari_Unload_Transport_Ability"}
				},
			sort_order = 5		
		},
	
	["COMMAND_PATROL"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_KEYBOARD_PATROL",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 6			
		},
	
	["COMMAND_GUARD"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_GUARD",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 7			
		},
	
	["COMMAND_ATTACK_MOVE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ATTACK_MOVE",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 8			
		},
	
	--[[ *****************************	GROUPING BEGINS!!!!!	*****************************************]]--
	--[[ 
		THE FOLLOWING COMMANDS HAVE THEIR DISPLAY FLAG SET TO FALSE SO THAT THEY DON'T GET
		SHOWN ---- TOO MUCH INFORMATION?????????	
		BESIDES, ONCE THE USER SETS THE NEW KEY MAPPING FOR THE GROUP SELECTION COMMAND, THESE ARE
		AUTOMATICALLY RE-MAPPED.
	]]--
	
	["COMMAND_GROUP_0_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_0_SELECT",
			icon_name = "i_icon_ctrl_0.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 9		
		},

	["COMMAND_GROUP_1_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_1_SELECT",
			icon_name = "i_icon_ctrl_1.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 10				
		},

	["COMMAND_GROUP_2_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_2_SELECT",
			icon_name = "i_icon_ctrl_2.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 11				
		},

	["COMMAND_GROUP_3_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_3_SELECT",
			icon_name = "i_icon_ctrl_3.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 12				
		},

	["COMMAND_GROUP_4_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_4_SELECT",
			icon_name = "i_icon_ctrl_4.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 13			
		},

	["COMMAND_GROUP_5_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_5_SELECT",
			icon_name = "i_icon_ctrl_5.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 14				
		},

	["COMMAND_GROUP_6_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_6_SELECT",
			icon_name = "i_icon_ctrl_6.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 15				
		},

	["COMMAND_GROUP_7_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_7_SELECT",
			icon_name = "i_icon_ctrl_7.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 16				
		},

	["COMMAND_GROUP_8_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_8_SELECT",
			icon_name = "i_icon_ctrl_8.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 17			
		},

	["COMMAND_GROUP_9_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_9_SELECT",
			icon_name = "i_icon_ctrl_9.tga",
			display = true,
			can_be_re_assigned = false,
			sort_order = 18				
		},	

	["COMMAND_GROUP_0_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_0",
			icon_name = "",
			display = false,	
			can_be_re_assigned = false,
			sort_order = 19				
		},
		
	["COMMAND_GROUP_1_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_1",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 20				
		},	

	["COMMAND_GROUP_2_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_2",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 21				
		},

	["COMMAND_GROUP_3_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_3",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 22				
		},

	["COMMAND_GROUP_4_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_4",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 23				
		},

	["COMMAND_GROUP_5_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_5",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 24				
		},

	["COMMAND_GROUP_6_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_6",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 25				
		},

	["COMMAND_GROUP_7_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_7",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 26				
		},

	["COMMAND_GROUP_8_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_8",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 27				
		},

	["COMMAND_GROUP_9_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ASSIGN_9",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 28				
		},

	["COMMAND_GROUP_0_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_0",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 29				
		},
		
	["COMMAND_GROUP_1_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_1",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 30				
		},
		
	["COMMAND_GROUP_2_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_2",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 31				
		},
		
	["COMMAND_GROUP_3_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_3",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 32				
		},
		
	["COMMAND_GROUP_4_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_4",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 33				
		},
		
	["COMMAND_GROUP_5_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_5",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 34				
		},
		
	["COMMAND_GROUP_6_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_6",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 35				
		},
		
	["COMMAND_GROUP_7_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_7",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 36				
		},
		
	["COMMAND_GROUP_8_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_8",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 37			
		},
		
	["COMMAND_GROUP_9_ADD_SELECT"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_SELECT_9",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 38				
		},
		
	["COMMAND_GROUP_0_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_0",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 39				
		},
		
	["COMMAND_GROUP_1_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_1",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 40				
		},
		
	["COMMAND_GROUP_2_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_2",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 41				
		},
		
	["COMMAND_GROUP_3_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_3",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 42				
		},
		
	["COMMAND_GROUP_4_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_4",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 43				
		},
		
	["COMMAND_GROUP_5_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_5",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 44				
		},
		
	["COMMAND_GROUP_6_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_6",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 45				
		},
		
	["COMMAND_GROUP_7_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_7",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 46				
		},
		
	["COMMAND_GROUP_8_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_8",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 47
		},
		
	["COMMAND_GROUP_9_ADD_ASSIGN"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GROUP_ADD_ASSIGN_9",
			icon_name = "",
			display = true,	
			can_be_re_assigned = false,
			sort_order = 48
		},
		
	--[[ *****************************	GROUPING ENDS!!!!!	*****************************************]]--
},


-- ********************************************************************************************************
-- 				MASARI
-- ********************************************************************************************************
["MASARI"] = 
{
-- ----------------------------------------------------------------
-- FACTION SPECIFIC INTERFACE COMMANDS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_TOGGLE_ELEMENTAL_MODE_MENU",
			icon_name = "i_icon_masari_elemental_mode_fire.tga",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 0
		},
	
-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE SUPERWEAPONS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_SUPERWEAPON_1"] =
		{
			sw_type_name = "MASARI_SW_MAGMA_CHANNEL_WEAPON",  -- PLEASE IF YOU NEED TO CHANGE THIS MAKE SURE YOU WRITE IT ALL IN CAPS!!!!
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_MASARI_SW_MAGMA_CHANNEL",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 1					
		},
	
	["COMMAND_ACTIVATE_SUPERWEAPON_2"] =
		{
			sw_type_name = "MASARI_SW_THERMAL_VACUUM_WEAPON",  -- PLEASE IF YOU NEED TO CHANGE THIS MAKE SURE YOU WRITE IT ALL IN CAPS!!!!
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_MASARI_SW_THERMAL_VACUUM",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 2		
		},

-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE UNIT ABILITIES
-- NOTE: all the remaining data pertaining special abilities
-- is stored in SpecialAbilities.lua
-- ----------------------------------------------------------------
	["COMMAND_LAND_ABILITY_1"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_STRUCTURE_MATTER_ENGINE",
			unit_ability_name = "Matter_Engine_Self_Destruct_Ability",
			sort_order = 15		
		},
		
	["COMMAND_LAND_ABILITY_2"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_DISCIPLE",
			unit_ability_name = "Disciple_Capture",
			sort_order = 16		
		},
		
	["COMMAND_LAND_ABILITY_3"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_STRUCTURE_SKY_GUARDIAN",
			unit_ability_name = "Sky_Guardian_Gust_Unit_Ability",
			sort_order = 20		
		},
		
	["COMMAND_LAND_ABILITY_4"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_ENFORCER",
			unit_ability_name = "Masari_Enforcer_Fire_Vortex_Ability",
			sort_order = 23		
		},
	
	["COMMAND_LAND_ABILITY_5"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_ARCHITECT",
			unit_ability_name = "Masari_Tactical_Build_Unit_Ability",
			sort_order = 14		
		},
		
	["COMMAND_LAND_ABILITY_6"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_FIGMENT",
			unit_ability_name = "Masary_Figment_Deploy_Mine_Ability",
			sort_order = 22		
		},
		
	["COMMAND_LAND_ABILITY_7"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_CHAROS",
			unit_ability_name = "Masari_Elemental_Fury_Ability",
			sort_order = 3		
		},
		
	["COMMAND_LAND_ABILITY_8"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_CHAROS",
			unit_ability_name = "Masari_Blaze_Of_Glory_Ability",
			sort_order = 4		
		},
		
	["COMMAND_LAND_ABILITY_9"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_CHAROS",
			unit_ability_name = "Masari_Ice_Crystals_Ability",
			sort_order = 5		
		},
		
	["COMMAND_LAND_ABILITY_10"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_CHAROS",
			unit_ability_name = "Masari_Charos_Retreat_From_Tactical_Ability",
			sort_order = 6		
		},
		
	["COMMAND_LAND_ABILITY_11"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ZESSUS",
			unit_ability_name = "Masari_Zessus_Blizzard_Unit_Ability",
			sort_order = 9		
		},
		
	["COMMAND_LAND_ABILITY_12"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ZESSUS",
			unit_ability_name = "Masari_Zessus_Teleportation_Unit_Ability",
			sort_order = 7		
		},
		
	["COMMAND_LAND_ABILITY_13"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ZESSUS",
			unit_ability_name = "Masari_Zessus_Explode_Unit_Ability",
			sort_order = 8		
		},
		
	["COMMAND_LAND_ABILITY_14"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ZESSUS",
			unit_ability_name = "Masari_Zessus_Retreat_From_Tactical_Unit_Ability",
			sort_order = 10		
		},
		
	["COMMAND_LAND_ABILITY_15"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_PEACEBRINGER",
			unit_ability_name = "Masari_Peacebringer_Disintegrate_Unit_Ability",
			sort_order = 19		
		},
	
	["COMMAND_LAND_ABILITY_16"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_SENTRY",
			unit_ability_name = "Masari_Sentry_Unload_Unit_Ability",
			sort_order = 21		
		},
		
	["COMMAND_LAND_ABILITY_17"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_SKY_LORD",
			unit_ability_name = "Masari_Skylord_Screech_Attack",
			sort_order = 18		
		},
		
	["COMMAND_LAND_ABILITY_18"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ALATEA",
			unit_ability_name = "Masari_Alatea_Unmake_Ability",
			sort_order = 11		
		},
		
	["COMMAND_LAND_ABILITY_19"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ALATEA",
			unit_ability_name = "Masari_Alatea_Peace_Ability",
			sort_order = 12		
		},
		
	["COMMAND_LAND_ABILITY_20"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_MASARI_HERO_ALATEA",
			unit_ability_name = "Masari_Alatea_Retreat_From_Tactical_Ability",
			sort_order = 13		
		},
		
	["COMMAND_LAND_ABILITY_21"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_MASARI_SEEKER",
			unit_ability_name = "Inquisitor_Destabilize_Unit_Ability",
			sort_order = 17		
		},
},

-- ********************************************************************************************************
-- 				NOVUS
-- ********************************************************************************************************
["NOVUS"] = 
{
-- ----------------------------------------------------------------
-- FACTION SPECIFIC INTERFACE COMMANDS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_PATCH_MENU",
			icon_name = "i_icon_n_patch_purchase.tga",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 0		
		},
	
-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE SUPERWEAPONS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_SUPERWEAPON_1"] =
		{
			sw_type_name = "NOVUS_SUPERWEAPON_EMP_WEAPON",  -- PLEASE IF YOU NEED TO CHANGE THIS MAKE SURE YOU WRITE IT ALL IN CAPS!!!!
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_NOVUS_SW_EMP",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 1		
			
		},
	
	["COMMAND_ACTIVATE_SUPERWEAPON_2"] =
		{
			sw_type_name = "NOVUS_SUPERWEAPON_GRAVITY_BOMB_WEAPON",  -- PLEASE IF YOU NEED TO CHANGE THIS MAKE SURE YOU WRITE IT ALL IN CAPS!!!!
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_NOVUS_SW_GRAVITY_BOMB",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 2		
		},

-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE UNIT ABILITIES
-- ----------------------------------------------------------------
	["COMMAND_LAND_ABILITY_1"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_ANTIMATTER_TANK",
			unit_ability_name = "Unit_Ability_Antimatter_Spray_Projectiles_Attack",
			sort_order = 19		
		},
		
	["COMMAND_LAND_ABILITY_2"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_OHM_ROBOT",
			unit_ability_name = "Robotic_Infantry_Swarm",
			sort_order = 16		
		},
		
	["COMMAND_LAND_ABILITY_3"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_OHM_ROBOT",
			unit_ability_name = "Robotic_Infantry_Capture",
			sort_order = 15		
		},
		
	["COMMAND_LAND_ABILITY_4"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_MECH",
			unit_ability_name = "Unit_Ability_Mech_Minirocket_Barrage",
			sort_order = 3		
		},
	
	["COMMAND_LAND_ABILITY_5"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_MECH",
			unit_ability_name = "Unit_Ability_Mech_Vehicle_Snipe_Attack",
			sort_order = 4		
		},
		
	["COMMAND_LAND_ABILITY_6"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_MECH",
			unit_ability_name = "Novus_Mech_Retreat_From_Tactical_Ability",
			sort_order = 5		
		},
		
	["COMMAND_LAND_ABILITY_7"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_FOUNDER",
			unit_ability_name = "Novus_Founder_Toggle_Modes_1",
			sort_order = 10		
		},
		
	["COMMAND_LAND_ABILITY_8"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_FOUNDER",
			unit_ability_name = "Novus_Founder_Signal_Tap_Ability",
			sort_order = 11		
		},
		
	["COMMAND_LAND_ABILITY_9"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_FOUNDER",
			unit_ability_name = "Novus_Founder_Rebuild_Unit_Ability",
			sort_order = 12		
		},
		
	["COMMAND_LAND_ABILITY_10"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_FOUNDER",
			unit_ability_name = "Novus_Founder_Retreat_From_Tactical_Ability",
			sort_order = 13		
		},
		
	["COMMAND_LAND_ABILITY_11"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_VARIANT",
			unit_ability_name = "Novus_Variant_Toggle_Weapon_Ability",
			sort_order = 21		
		},
		
	["COMMAND_LAND_ABILITY_12"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_DERVISH_JET",
			unit_ability_name = "Unit_Ability_Dervish_Spin_Attack",
			sort_order = 18		
		},
		
	["COMMAND_LAND_ABILITY_13"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_CORRUPTOR",
			unit_ability_name = "Corrupter_Virus_Infect",
			sort_order = 17		
		},
		
	["COMMAND_LAND_ABILITY_14"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_REFLEX_TROOPER",
			unit_ability_name = "Unit_Ability_Blackout_Bomb_Attack",
			sort_order = 24		
		},
		
	["COMMAND_LAND_ABILITY_15"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_REFLEX_TROOPER",
			unit_ability_name = "Unit_Ability_Spawn_Clones",
			sort_order = 23				
		},		
		
	["COMMAND_LAND_ABILITY_16"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_FIELD_INVERTER",
			unit_ability_name = "Novus_Inverter_Toggle_Shield_Mode",
			sort_order = 22		
		},
		
	["COMMAND_LAND_ABILITY_17"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_HACKER",
			unit_ability_name = "Novus_Hacker_Viral_Bomb_Unit_Ability",
			sort_order = 25		
		},

	["COMMAND_LAND_ABILITY_18"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_HACKER",
			unit_ability_name = "Novus_Hacker_Firewall",
			sort_order = 26
		},
		
	["COMMAND_LAND_ABILITY_19"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_VERTIGO",
			unit_ability_name = "Upload_Unit_Ability",
			sort_order = 7		
		},
		
	["COMMAND_LAND_ABILITY_20"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_VERTIGO",
			unit_ability_name = "Download_Unit_Ability",
			sort_order = 8		
		},
		
	["COMMAND_LAND_ABILITY_21"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_VERTIGO",
			unit_ability_name = "Viral_Control_Unit_Ability",
			sort_order = 6		
		},
		
	["COMMAND_LAND_ABILITY_22"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_NOVUS_HERO_VERTIGO",
			unit_ability_name = "Novus_Vertigo_Retreat_From_Tactical_Ability",
			sort_order = 9		
		},
		
	["COMMAND_LAND_ABILITY_23"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_CONSTRUCTOR",
			unit_ability_name = "Novus_Tactical_Build_Structure_Ability",
			sort_order = 14		
		},
		
	["COMMAND_LAND_ABILITY_24"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			object_text_id = "TEXT_UNIT_NOVUS_AMPLIFIER",
			unit_ability_name = "Novus_Amplifier_Harmonic_Pulse",
			sort_order = 20		
		},
},

-- ********************************************************************************************************
-- 				Military
-- ********************************************************************************************************
["MILITARY"] = 
{	
-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE SUPERWEAPONS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_SUPERWEAPON_1"] =
		{
			sw_type_name = "MILITARY_SUPERWEAPON_MISSILE_WEAPON",  -- PLEASE IF YOU NEED TO CHANGE THIS MAKE SURE YOU WRITE IT ALL IN CAPS!!!!
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_NOVUS_SW_EMP",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 1		
			
		},
},
-- ********************************************************************************************************
-- 				HIERARCHY
-- ********************************************************************************************************
["ALIEN"] = 
{

-- ----------------------------------------------------------------
-- FACTION SPECIFIC INTERFACE COMMANDS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE"] = 
		{
			-- Text ID to describe this command in the menu
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_WALKER_CUSTOMIZATION_MODE",
			icon_name = "i_icon_a_blueprint.tga",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 0		
		},
		
-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE SUPERWEAPONS
-- ----------------------------------------------------------------
	["COMMAND_ACTIVATE_SUPERWEAPON_1"] =
		{
			sw_type_name = "ALIEN_SUPERWEAPON_MASS_DROP_WEAPON", -- PLEASE IF YOU CHANGE THIS MAKE SURE THE NAME IS IN CAPS!!!!
			text_id = "TEXT_GAME_COMMAND_ACTIVATE_ALIEN_SW_MASS_DROP",
			icon_name = "",
			display = true,	
			can_be_re_assigned = true,
			sort_order = 2
		},

-- ----------------------------------------------------------------
-- COMMANDS USED TO ACTIVATE UNIT ABILITIES
-- ----------------------------------------------------------------
	["COMMAND_LAND_ABILITY_1"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Kamal_Rex_Abduction_Unit_Ability",
			object_text_id = "TEXT_ALIEN_HERO_KAMAL_REX",
			sort_order = 9		
		},
	
	["COMMAND_LAND_ABILITY_2"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Kamal_Rex_Force_Wall_Unit_Ability",
			object_text_id = "TEXT_ALIEN_HERO_KAMAL_REX",
			sort_order = 10		
		},
		
	["COMMAND_LAND_ABILITY_3"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Kamal_Rex_Retreat_From_Tactical_Ability",
			object_text_id = "TEXT_ALIEN_HERO_KAMAL_REX",
			sort_order = 11		
		},
		
	["COMMAND_LAND_ABILITY_4"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Orlok_Switch_To_Siege_Mode",
			object_text_id = "TEXT_ALIEN_HERO_ORLOK",
			sort_order = 3		
		},
		
	["COMMAND_LAND_ABILITY_5"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Orlok_Switch_To_Endure_Mode",
			object_text_id = "TEXT_ALIEN_HERO_ORLOK",
			sort_order = 4		
		},
		
	["COMMAND_LAND_ABILITY_6"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Orlok_Retreat_From_Tactical_Ability",
			object_text_id = "TEXT_ALIEN_HERO_ORLOK",
			sort_order = 5		
		},
		
	["COMMAND_LAND_ABILITY_7"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Nufai_Paranoia_Field_Ability",
			object_text_id = "TEXT_ALIEN_HERO_NUFAI",
			sort_order = 6		
		},
		
	["COMMAND_LAND_ABILITY_8"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Nufai_Tendrils_Ability",
			object_text_id = "TEXT_ALIEN_HERO_NUFAI",
			sort_order = 7		
		},
		
	["COMMAND_LAND_ABILITY_9"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Nufai_Retreat_From_Tactical_Ability",
			object_text_id = "TEXT_ALIEN_HERO_NUFAI",
			sort_order = 8		
		},
		
	["COMMAND_LAND_ABILITY_10"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Reaper_Auto_Gather_Resources",
			object_text_id = "TEXT_ALIEN_REAPER_TURRET",
			sort_order = 13		
		},
		
	["COMMAND_LAND_ABILITY_11"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Tank_Phase_Unit_Ability",
			object_text_id = "TEXT_ALIEN_TANK",
			sort_order = 21		
		},
		
	["COMMAND_LAND_ABILITY_12"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Unit_Ability_Foo_Core_Heal_Attack_Toggle",
			object_text_id = "TEXT_ALIEN_SAUCER",
			sort_order = 16		
		},
		
	["COMMAND_LAND_ABILITY_13"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Brute_Leap_Ability",
			object_text_id = "TEXT_ALIEN_BRUTE",
			sort_order = 24		
		},
		
	["COMMAND_LAND_ABILITY_14"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Brute_Death_From_Above",
			object_text_id = "TEXT_ALIEN_BRUTE",
			sort_order = 25		
		},
		
	["COMMAND_LAND_ABILITY_15"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Brute_Tackle_Ability",
			object_text_id = "TEXT_ALIEN_BRUTE",
			sort_order = 26		
		},
		
	["COMMAND_LAND_ABILITY_16"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Grunt_Capture",
			object_text_id = "TEXT_ALIEN_GRUNT",
			sort_order = 14		
		},
		
	["COMMAND_LAND_ABILITY_17"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Scan_Drone_Scan_Pulse",
			object_text_id = "TEXT_ALIEN_SCAN_DRONE",
			sort_order = 28		
		},
		
	["COMMAND_LAND_ABILITY_18"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Defiler_Radiation_Bleed",
			object_text_id = "TEXT_ALIEN_DEFILER",
			sort_order = 19	
		},
		
	["COMMAND_LAND_ABILITY_19"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Defiler_Radiation_Charge",
			object_text_id = "TEXT_ALIEN_DEFILER",
			sort_order = 20		
		},
		
	["COMMAND_LAND_ABILITY_20"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Radiation_Artillery_Cannon_Attack",
			object_text_id = "TEXT_UNIT_GIANT_HABITAT_SPIDER",
			sort_order = 17		
		},
		
	["COMMAND_LAND_ABILITY_21"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Assembly_Scarn_Beam",
			object_text_id = "TEXT_UNIT_GIANT_ASSEMBLY_SPIDER",
			sort_order = 18			
		},
		
	["COMMAND_LAND_ABILITY_22"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Radiation_Cascade_Unit_Ability",
			object_text_id = "TEXT_UNIT_GIANT_SCIENCE_SPIDER",
			sort_order = 1						
		},
		
	["COMMAND_LAND_ABILITY_23"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Walker_Science_Dark_Matter_Vent",
			object_text_id = "TEXT_UNIT_GIANT_SCIENCE_SPIDER",
			sort_order = 27						
		},
		
	["COMMAND_LAND_ABILITY_24"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Alien_Tactical_Build_Structure_Ability",
			object_text_id = "TEXT_ALIEN_GLYPH_CARVER",
			sort_order = 12			
		},
		
	["COMMAND_LAND_ABILITY_25"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Lost_One_Plasma_Bomb_Unit_Ability",
			object_text_id = "TEXT_UNIT_ALIEN_LOST_ONE",
			sort_order = 22			
		},
		
	["COMMAND_LAND_ABILITY_26"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Grey_Phase_Unit_Ability",
			object_text_id = "TEXT_UNIT_ALIEN_LOST_ONE",
			sort_order = 23			
		},
		
	["COMMAND_LAND_ABILITY_27"] = 
		{
			display = true,	
			can_be_re_assigned = true,
			unit_ability_name = "Monolith_Phase_Unit_Ability",
			object_text_id = "TEXT_ALIEN_CYLINDER",
			sort_order = 15				
		},
	},
}
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Kill_Unused_Global_Functions = nil
end

