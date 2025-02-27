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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Global_Progress_Bar.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Joe_Howes $
--
--            $Change: 92711 $
--
--          $DateTime: 2008/02/07 11:39:16 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

-- =====================================================================================
function On_Init()
	if TestValid(Object) then
		Set_GUI_Variable("Fleet_Object", Object.Get_Parent_Object())
		
		ProgX, ProgY, ProgWidth, ProgHeight = Scene.ProgressBarQuad.Get_Bounds()
		Set_GUI_Variable("ProgX", ProgX)
		Set_GUI_Variable("ProgY", ProgY)
		Set_GUI_Variable("ProgWidth", ProgWidth)
		Set_GUI_Variable("ProgHeight", ProgHeight)
		Set_GUI_Variable("ProgOrigWidth", ProgWidth)

		this.Set_Hidden(false)
	end
end


-- =====================================================================================
-- Wherever possible avoid calls to game (non-lua) functions here for efficiency reasons. 
function On_Update()
	
	local fleet_obj = Get_GUI_Variable("Fleet_Object")
	
	local build_percent = fleet_obj.Get_Fleet_Build_Percentage()
	
	if (build_percent ~= nil) then
	
		if ( build_percent == 0 or build_percent == 1 ) then
			Scene.ProgressBarQuad.Set_Hidden(true)
			Scene.ProgressBarBGQuad.Set_Hidden(true)
		else
			Scene.ProgressBarQuad.Set_Hidden(false)
			Scene.ProgressBarBGQuad.Set_Hidden(false)
		end
		
		local pwidth = Get_GUI_Variable("ProgOrigWidth") * build_percent
		Set_GUI_Variable("ProgWidth", pwidth)
		Scene.ProgressBarQuad.Set_Bounds(	Get_GUI_Variable("ProgX"), 
											Get_GUI_Variable("ProgY"),
											Get_GUI_Variable("ProgWidth"), 
											Get_GUI_Variable("ProgHeight"))
					
	end
	
end


function On_Show()

end
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
