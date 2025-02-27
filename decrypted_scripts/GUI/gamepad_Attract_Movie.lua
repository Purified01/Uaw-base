if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[79] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Attract_Movie.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Attract_Movie.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Nader_Akoury $
--
--            $Change: 96165 $
--
--          $DateTime: 2008/04/02 14:07:22 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGPlayerProfile")

ScriptPoolCount = 0


function On_Init()
	this.Register_Event_Handler("Controller_A_Button_Up", nil, On_Hide)
	this.Register_Event_Handler("Controller_Start_Button_Up", nil, On_Hide)
	this.Register_Event_Handler("Closing_All_Displays", nil, On_Close_Requested)
	
	this.Register_Event_Handler("Animation_Finished", nil, On_Animation_Finished)
	
	this.Scriptable_1.Set_Tab_Order(0)
	
	On_Show()

end

function On_Show()
	Register_Video_Commands()
	local settings = VideoSettingsManager.Get_Current_Settings()
	local width = settings.Screen_Width
	local height = settings.Screen_Height	
	
	local movie_height = (width / height) / (16.0 / 9.0)
	local y_offset = (1.0 - movie_height) / 2.0;

	this.Movie_1.Set_World_Bounds(0.0, y_offset, 1.0, movie_height)
	this.Movie_1.Set_Loop(true)
	this.Movie_1.Play()
	
	this.Play_Animation("Fade_Up", false)

	this.Scriptable_1.Play_Animation("Flash_Buttons", true)

	this.Focus_First()
end

function On_Hide()
	if not is_closing then
		is_closing = true
		this.Stop_Animation()
		this.Play_Animation_Backwards("Fade_Up", false)
	end
end

function On_Close_Requested(event, source, suppress_prompts)
	if suppress_prompts then
		On_Hide()
	end
end

function On_Animation_Finished(_, _)
	if ( is_closing ) then
		On_Final_Hide()
		is_closing = false
	end
end

function On_Final_Hide()
	this.Stop_Animation()
	this.Movie_1.Stop()
	this.Set_Hidden(true)
	this.End_Modal()

end

Interface = {}
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Commit_Profile_Values = nil
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
	PGPlayerProfile_Init = nil
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
