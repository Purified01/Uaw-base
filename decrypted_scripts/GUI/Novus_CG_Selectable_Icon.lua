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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Novus_CG_Selectable_Icon.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("Selectable_Icon")

-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	SkipFocusGainedAnimation = true
	Initialize_Selectable_Icon()
	Scene.Group.LowPower.Set_Hidden(true)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Low_Power_Display
-- ------------------------------------------------------------------------------------------------------------------
function Set_Low_Power_Display(on_off)
	Scene.Group.LowPower.Set_Hidden(not on_off)
end

function Display_A_Button_Layer(on_off)
	if TestValid(Scene.Group.Gamepad_A_Button) then
		Scene.Group.Gamepad_A_Button.Set_Hidden(not on_off)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
-- Interface = {} DO NOT ADD THIS LINE BECAUSE THIS SELECTABLE ICON IS DERIVED FROM
-- THE BASE SELECTABLE ICON AND WE WANT TO ADD TO ITS INTERFACE TABLE!!!!!!.
Interface.Set_Low_Power_Display = Set_Low_Power_Display
-- MARIA 08.30.2007 -- This is only here for the usability test and mock up of the new control group radial display
Interface.Display_A_Button_Layer = Display_A_Button_Layer
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
	Get_Chat_Color_Index = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGColors_Init = nil
	Remove_Invalid_Objects = nil
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
