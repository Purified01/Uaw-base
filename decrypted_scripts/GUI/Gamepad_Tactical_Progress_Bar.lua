if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[37] = true
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Progress_Bar.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
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
		if ( Object.Is_Owned_By_Local_Player() ) then
			Set_GUI_Variable("Building_Object", Object)
			
			ProgX, ProgY, ProgWidth, ProgHeight = Scene.TacProgressBarQuad.Get_Bounds()
			Set_GUI_Variable("ProgX", ProgX)
			Set_GUI_Variable("ProgY", ProgY)
			Set_GUI_Variable("ProgWidth", ProgWidth)
			Set_GUI_Variable("ProgHeight", ProgHeight)
			Set_GUI_Variable("ProgOrigWidth", ProgWidth)
		else
			Scene.TacProgressBarQuad.Set_Hidden(true)
			Scene.TacProgressBarBGQuad.Set_Hidden(true)
			Set_GUI_Variable("NOT_LOCAL_OBJECT", true)
		end
	end
end


-- =====================================================================================
-- Wherever possible avoid calls to game (non-lua) functions here for efficiency reasons. 
function On_Update()
	
	if ( Get_GUI_Variable("NOT_LOCAL_OBJECT") ) then return end
	
	local building_obj = Get_GUI_Variable("Building_Object")
	
	local build_percent = 0
	local build_percent2 = building_obj.Get_Tactical_Build_Percent_Done()
	
	local build_queue = building_obj.Tactical_Enabler_Get_Queued_Objects()
	if ( build_queue and build_queue[1] ) then
		build_percent = build_queue[1].Percent_Complete
	end
	
	if ( build_percent2 and build_percent2 < 1 and build_percent2 > 0 ) then
		build_percent = build_percent2
	end
	
	--Make sure to hide the progress bar during cinematic sequences
	if ( build_percent <= 0 or build_percent >= 1 or Get_Letter_Box_Percent() > 0.0 ) then
		Scene.TacProgressBarQuad.Set_Hidden(true)
		Scene.TacProgressBarBGQuad.Set_Hidden(true)
		return
	else
		Scene.TacProgressBarQuad.Set_Hidden(false)
		Scene.TacProgressBarBGQuad.Set_Hidden(false)
	end
	
	local pwidth = Get_GUI_Variable("ProgOrigWidth") * build_percent
	Set_GUI_Variable("ProgWidth", pwidth)
	Scene.TacProgressBarQuad.Set_Bounds(	Get_GUI_Variable("ProgX"), 
										Get_GUI_Variable("ProgY"),
										Get_GUI_Variable("ProgWidth"), 
										Get_GUI_Variable("ProgHeight"))
	
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
