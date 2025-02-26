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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Regional_Command_Center_Scene.lua 
--
--            Author: Maria Teruel
--
--          DateTime: 2006/05/31 
--
--	NOTE: Adpapted from RegionLabel.lua!
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Mouse")
require("Global_Icons")
require("PGUICommands")
	
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	
	--this.Register_Event_Handler("Faction_Changed", nil, On_Faction_Changed)
	--this.Register_Event_Handler("Close_All_Active_Displays", nil, On_Closing_All_Displays)
	--this.Register_Event_Handler("Global_Spy_Level_Changed", nil, On_Spy_Level_Changed)
	
	UpgradeMenus = Find_GUI_Components(this, "UpgradeMenu")
	for index, menu in pairs(UpgradeMenus) do
		this.Register_Event_Handler("Upgrade_Menu_Opened", menu, On_Upgrade_Menu_Opened)
		this.Register_Event_Handler("Update_Global_Upgrades_Menu", menu, On_Update_Global_Upgrades_Menu)
		
		menu.Set_Tab_Order(index)
	end
	
	IsOpen = false
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_Global_Upgrades_Menu
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update_Global_Upgrades_Menu(_, _, structure)
	if not IsOpen then 
		return
	end
	
	if not TestValid(Object) or Object ~=  structure then
		return
	end
	
	Setup_Menus()	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Display_Upgrade_Panel
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Display_Upgrade_Panel(display_hide, structure)
	
	if display_hide and (not TestValid(structure) or not structure.Has_Behavior(99)) then 
		return false
	end
	
	Object = structure
	
	if not display_hide then
		Close_Menus()
		IsOpen = false
	else
		Setup_Menus()
		this.Focus_First()
		IsOpen = true
	end	
	return true
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Close_Menus
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Close_Menus()
	for _, menu in pairs(UpgradeMenus) do
		menu.Close()
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup_Menus
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Setup_Menus()
	local upgrades = Object.Get_Strategic_Structure_Socket_Upgrades()
	if not upgrades then
		return false
	end
	
	for i, menu in pairs(UpgradeMenus) do
		menu.Set_Hard_Point(upgrades[i])
	end	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Display_Upgrade_Panel
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Upgrade_Menu_Opened(_, source)
	local menus = Get_GUI_Variable("UpgradeMenus")
	for _, menu in pairs(UpgradeMenus) do
		if menu ~= source then
			menu.Close()
		end
	end	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Display_Upgrade_Panel = Display_Upgrade_Panel
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Faction_Icon_Name = nil
	Get_Fleet_Icon_Name = nil
	Init_Mouse_Buttons = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Mouse_Buttons = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
