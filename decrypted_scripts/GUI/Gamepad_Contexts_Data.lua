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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Contexts_Data.lua
--
--    Original Author: Maria_Teruel
--
--          DateTime: 2007/09/18
--	WE HAVE THIS DATA HERE SO THAT WE CAN INCLUDE THIS FILE IN THE FILES THAT NEED
-- 	TO HAVE ACCESS TO THIS INFORMATION.
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Init_Gamepad_Contexts_Data
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Gamepad_Contexts_Data()
	
	GamepadContextToDisplayData = {}
	Init_Tactical_Data()
	Init_Strategic_Data()
	Init_Generic_Data()
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Init_Tactical_Data
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Tactical_Data()
	
	-- Possible Context Values
	-- ------------------------------------------------------------------------------------------------------------------------------------
	GAMEPAD_CONTEXT_RESEARCH_AND_CUSTOMIZATION = Declare_Enum(0)
	GAMEPAD_CONTEXT_UPGRADE_SELL_AND_ABILITIES = Declare_Enum()
	GAMEPAD_CONTEXT_PRODUCTION_AND_ABILITIES = Declare_Enum()
	GAMEPAD_CONTEXT_UPGRADE_AND_SELL = Declare_Enum()
	GAMEPAD_CONTEXT_SPECIAL_ABILITIES = Declare_Enum()
	GAMEPAD_CONTEXT_PRODUCTION = Declare_Enum()
	GAMEPAD_CONTEXT_BUILD_MODE = Declare_Enum()
	GAMEPAD_CONTEXT_COMMAND = Declare_Enum()	
	GAMEPAD_CONTEXT_CONTROL_GROUPS = Declare_Enum()	
	GAMEPAD_CONTEXT_SELL_MODE = Declare_Enum()	
	GAMEPAD_CONTEXT_PLACE_MP_BEACON = Declare_Enum()	
	GAMEPAD_CONTEXT_RADAR_MAP = Declare_Enum()
	GAMEPAD_CUSTOMIZE_WALKER = Declare_Enum()
	-- Used for customization of Walker Crowns
	GAMEPAD_CUSTOMIZE_WALKER_UP = Declare_Enum()
	-- Used for customization of Walker Legs
	GAMEPAD_CUSTOMIZE_WALKER_DOWN = Declare_Enum()
	GAMEPAD_CONTEXT_EXIT_WALKER_CUSTOMIZATION_MODE = Declare_Enum()
	
	-- Context Value Data
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- LEFT TRIGGER/BUMPER
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_RESEARCH_AND_CUSTOMIZATION] = {Trigger = 'LB', TextID = "TEXT_GAMEPAD_RESEARCH_AND_CUSTOMIZATION_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_UPGRADE_SELL_AND_ABILITIES] = {Trigger =  'LT', TextID = "TEXT_GAMEPAD_UPGRADE_SELL_AND_ABILITIES_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_PRODUCTION_AND_ABILITIES] = {Trigger =  'LT', TextID = "TEXT_GAMEPAD_PRODUCTION_AND_ABILITIES_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_UPGRADE_AND_SELL] = {Trigger =  'LT', TextID = "TEXT_GAMEPAD_UPGRADE_AND_SELL_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_SPECIAL_ABILITIES] = {Trigger =  'LT', TextID = "TEXT_GAMEPAD_SPECIAL_ABILITIES_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_PRODUCTION] = {Trigger =  'LT', TextID = "TEXT_GAMEPAD_PRODUCTION_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_BUILD_MODE] ={Trigger =  'LT', TextID = "TEXT_GAMEPAD_BUILD_MENU_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_COMMAND] ={Trigger =  'LT', TextID = "TEXT_GAMEPAD_COMMAND_BAR_CONTEXT"}

	-- RIGHT TRIGGER/BUMPER
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_RADAR_MAP] =	{Trigger =  'RT', TextID = "TEXT_GAMEPAD_RADAR_MAP_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_CONTROL_GROUPS] ={Trigger =  'RB', TextID = "TEXT_GAMEPAD_CONTROL_GROUPS_CONTEXT"}

	-- DPAD 
	GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER] = {Trigger =  'Dpad', TextID = "TEXT_GAMEPAD_CUSTOMIZE_WALKER"}	
	GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER_UP] = {Trigger =  'DpadUp', TextID = "TEXT_GAMEPAD_UI_CUSTOMIZE_WALKER_NAVIGATION"}	
	GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER_DOWN] = {Trigger =  'DpadDown', TextID = "TEXT_GAMEPAD_UI_CUSTOMIZE_WALKER_NAVIGATION"}	
	
	-- B BUTTON
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_SELL_MODE] ={Trigger =  'B', TextID = "TEXT_GAMEPAD_SELL_MODE_CONTEXT"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_EXIT_WALKER_CUSTOMIZATION_MODE] ={Trigger =  'B', TextID = "TEXT_GAMEPAD_EXIT_MODE"}
	
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Init_Strategic_Data
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Strategic_Data()
	-- Possible Context Values
	-- ------------------------------------------------------------------------------------------------------------------------------------
	GAMEPAD_CONTEXT_ACCESS_HERO_FLEET_PANEL = Declare_Enum()
	GAMEPAD_CONTEXT_GLOBAL_STRUCTURE_UPGRADES = Declare_Enum()
	GAMEPAD_CONTEXT_COMMAND_CENTERS_MENU = Declare_Enum()
	GAMEPAD_CONTEXT_MEGAWEAPON_BUTTONS_MENU = Declare_Enum()
	GAMEPAD_CONTEXT_ZOOM_GLOBAL_CAMERA = Declare_Enum()
	GAMEPAD_CONTEXT_HEROES_MENU = Declare_Enum()
	
	-- B Button should back out of current menu (this applies to hero fleet panel, global structure upgrades menu, command center menus)
	GAMEPAD_CONTEXT_EXIT_MENU = Declare_Enum()	
	GAMEPAD_CONTEXT_DROP_SELECTION = Declare_Enum()	 

	-- Context Value Data
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- LEFT TRIGGER
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_ACCESS_HERO_FLEET_PANEL] = 	{Trigger = 'LT', TextID = "TEXT_GAMEPAD_CONTEXT_ACCESS_HERO_FLEET_PANEL"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_GLOBAL_STRUCTURE_UPGRADES] = 	{Trigger =  'LT', TextID = "TEXT_GAMEPAD_CONTEXT_GLOBAL_STRUCTURE_UPGRADES"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_COMMAND_CENTERS_MENU] = 	{Trigger =  'LT', TextID = "TEXT_GAMEPAD_CONTEXT_COMMAND_CENTERS_MENU"}

	-- LEFT BUMPER
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_MEGAWEAPON_BUTTONS_MENU] = 	{Trigger = 'LB', TextID = "TEXT_GAMEPAD_CONTEXT_MEGAWEAPON_BUTTONS_MENU"}
	
	-- RIGHT TRIGGER/BUMPER
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_ZOOM_GLOBAL_CAMERA] = {Trigger =  'RT', TextID = "TEXT_GAMEPAD_CONTEXT_ZOOM_GLOBAL_CAMERA"}
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_HEROES_MENU] = {Trigger =  'RB', TextID = "TEXT_GAMEPAD_CONTEXT_HEROES_MENU"}
	
	-- B BUTTON
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_EXIT_MENU] = {Trigger =  'B', TextID = "TEXT_GAMEPAD_GLOBAL_MODE_CONTEXT_EXIT_MENU"}
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Init_Generic_Data
-- ------------------------------------------------------------------------------------------------------------------------------------
function Init_Generic_Data()
	-- ANYTHING THAT WILL REMAIN CONSTANT IN TACTICAL AND STRATEGIC MODE.
	-- B BUTTON
	GamepadContextToDisplayData[GAMEPAD_CONTEXT_DROP_SELECTION] = {Trigger =  'B', TextID = "TEXT_GAMEPAD_CONTEXT_DROP_SELECTION"}
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Init_Gamepad_Contexts_Data = nil
	Kill_Unused_Global_Functions = nil
end
