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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Global_Building_Progress_Bar.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

-- =====================================================================================
function On_Init()
	if TestValid(Object) then
		if ( Object.Is_Owned_By_Local_Player() ) then
			Set_GUI_Variable("OwnedLocaly", true)
			Set_GUI_Variable("Building_Object", Object.Get_Parent_Object())
			
			ProgX1, ProgY1, ProgWidth1, ProgHeight1 = Scene.ProgressBarQuad1.Get_Bounds()
			Set_GUI_Variable("ProgX1", ProgX1)
			Set_GUI_Variable("ProgY1", ProgY1)
			Set_GUI_Variable("ProgWidth1", ProgWidth1)
			Set_GUI_Variable("ProgHeight1", ProgHeight1)
			Set_GUI_Variable("ProgOrigWidth1", ProgWidth1)

			ProgX2, ProgY2, ProgWidth2, ProgHeight2 = Scene.ProgressBarQuad2.Get_Bounds()
			Set_GUI_Variable("ProgX2", ProgX2)
			Set_GUI_Variable("ProgY2", ProgY2)
			Set_GUI_Variable("ProgWidth2", ProgWidth2)
			Set_GUI_Variable("ProgHeight2", ProgHeight2)
			Set_GUI_Variable("ProgOrigWidth2", ProgWidth2)

			this.Set_Hidden(false)
		else
			Scene.ProgressBarQuad1.Set_Hidden(true)
			Scene.ProgressBarBGQuad1.Set_Hidden(true)
			Scene.ProgressBarQuad2.Set_Hidden(true)
			Scene.ProgressBarBGQuad2.Set_Hidden(true)
			Set_GUI_Variable("OwnedLocaly", false)
		end
	end
end


-- =====================================================================================
-- Wherever possible avoid calls to game (non-lua) functions here for efficiency reasons. 
function On_Update()

	if ( not Get_GUI_Variable("OwnedLocaly") ) then return end

	local building_obj = Get_GUI_Variable("Building_Object")
	
	if ( not building_obj ) then return end
	
	local socket_table = building_obj.Get_Strategic_Structure_Socket_Upgrades()
	
	if ( not socket_table ) then return end
	
	
	
	
	local build_time_total1 = Get_GUI_Variable("TotalBuildTime1")
	if ( socket_table[1].Has_Behavior(166) ) then
		local build_percent1 = socket_table[1].Get_Strategic_Build_Completion_Time()
		build_percent1 = 1-build_percent1
		if ( not build_percent1 or ( build_percent1 == 0 or build_percent1 == 1 ) ) then
			Scene.ProgressBarQuad1.Set_Hidden(true)
			Scene.ProgressBarBGQuad1.Set_Hidden(true)
		else
			Scene.ProgressBarQuad1.Set_Hidden(false)
			Scene.ProgressBarBGQuad1.Set_Hidden(false)
			local pwidth = Get_GUI_Variable("ProgOrigWidth1") * build_percent1
			Set_GUI_Variable("ProgWidth1", pwidth)
			Scene.ProgressBarQuad1.Set_Bounds(	Get_GUI_Variable("ProgX1"), 
												Get_GUI_Variable("ProgY1"),
												Get_GUI_Variable("ProgWidth1"), 
												Get_GUI_Variable("ProgHeight1"))
		end
		
	else
		Scene.ProgressBarQuad1.Set_Hidden(true)
		Scene.ProgressBarBGQuad1.Set_Hidden(true)
	end
	

	local build_time_total2 = Get_GUI_Variable("TotalBuildTime2")
	if ( socket_table[2].Has_Behavior(166) ) then
		local build_percent2 = socket_table[2].Get_Strategic_Build_Completion_Time()
		build_percent2 = 1-build_percent2
		if ( not build_percent2 or ( build_percent2 == 0 or build_percent2 == 1 ) ) then
			Scene.ProgressBarQuad2.Set_Hidden(true)
			Scene.ProgressBarBGQuad2.Set_Hidden(true)
		else
			Scene.ProgressBarQuad2.Set_Hidden(false)
			Scene.ProgressBarBGQuad2.Set_Hidden(false)
			local pwidth = Get_GUI_Variable("ProgOrigWidth2") * build_percent2
			Set_GUI_Variable("ProgWidth2", pwidth)
			Scene.ProgressBarQuad2.Set_Bounds(	Get_GUI_Variable("ProgX2"), 
												Get_GUI_Variable("ProgY2"),
												Get_GUI_Variable("ProgWidth2"), 
												Get_GUI_Variable("ProgHeight2"))
		end
		
	else
		Scene.ProgressBarQuad2.Set_Hidden(true)
		Scene.ProgressBarBGQuad2.Set_Hidden(true)
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
