if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Mainmenu_Button.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Mainmenu_Button.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--^
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Raise_Event_All_Scenes
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Raise_Event_All_Scenes(event_name, args)
	local num_scenes = Get_Total_Active_Scenes()
	for i=0,num_scenes-1 do
		local scene = Get_Active_Scene_At(i)
		scene.Raise_Event(event_name, nil, args)
	end
end


function On_Init()
	HasFocus = false
	Mainmenu_Button.Register_Event_Handler("Button_Clicked", Mainmenu_Button, Button_Clicked)
end

function On_Update()

end

function Play_Click_SFX()
	Play_SFX_Event("GUI_Main_Menu_Button_Select")
end

function Play_Rollover_SFX()
	Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
end

function Button_Clicked()
	Raise_Event_Immediate_All_Parents("Mainmenu_Button_Clicked", Mainmenu_Button.Get_Containing_Component(), Mainmenu_Button, nil)
end

function Set_MouseOff() 
	Mainmenu_Button.Button_MouseOver.Set_Hidden(true)
end

function Set_Button_Name(str)
	Mainmenu_Button.Scriptable.Name.Set_Text(str)
end

function Enable()
	Mainmenu_Button.Set_State("Mouse_Off")
end

function Disable()
	Mainmenu_Button.Set_State("Disabled")
end

function Set_Focus_State(value)
	HasFocus = value
	if (HasFocus) then
		Mainmenu_Button.Set_State("Mouse_Over")
	else
		Mainmenu_Button.Set_State("Mouse_Off")
	end
end

Interface = {}
Interface.Set_Button_Name = Set_Button_Name
Interface.Set_MouseOff = Set_MouseOff
Interface.Enable = Enable
Interface.Disable = Disable
Interface.Set_Focus_State = Set_Focus_State
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
	Raise_Event_All_Scenes = nil
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
