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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Special_Ability_Brackets_Scene.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/04/24
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- Interface On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	this.LeftBracket.Set_Hidden(false)
	this.RightBracket.Set_Hidden(false)
	--this.UnitNameText.Set_Hidden(false)
	this.UnitNameText.Set_Word_Wrap(true)
	
	this.Register_Event_Handler("Key_Focus_Gained", this, On_Focus_Gained)
	this.Register_Event_Handler("Key_Focus_Lost", this, On_Focus_Lost)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Gained
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Gained(event, source)
	if not Is_Controller_Event() then return end
	this.Get_Containing_Scene().Raise_Event_Immediate("Ability_Group_Focus_Gained", this.Get_Containing_Component(), {})
	Start_Flash(this)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Lost
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Lost(event, source)
	if not Is_Controller_Event() then return end
	this.Get_Containing_Scene().Raise_Event_Immediate("Ability_Group_Focus_Lost", this.Get_Containing_Component(), {})
	Stop_Flash(this)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Text
-- ------------------------------------------------------------------------------------------------------------------
function Set_Text(text)
	--if not text then return end
	--this.UnitNameText.Set_Text(text)		
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Text = Set_Text


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
	Get_GUI_Variable = nil
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
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
