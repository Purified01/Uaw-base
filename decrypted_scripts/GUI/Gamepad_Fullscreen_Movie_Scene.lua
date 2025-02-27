if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[84] = true
LuaGlobalCommandLinks[79] = true
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
--              File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Fullscreen_Movie_Scene.lua 
--
--    	    Author: Maria_Teruel
--
--          Date: 2007/12/12
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

-------------------------------------------------------------------------------
-- On_Init
-------------------------------------------------------------------------------
function On_Init()
	
	this.Movie.Set_Tab_Order(0)
	
	this.Register_Event_Handler("Movie_Finished", this.Movie, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Closing_All_Displays", nil, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Stop_Full_Screen_Movie)
	this.Register_Event_Handler("Controller_Start_Button_Up", nil, Stop_Full_Screen_Movie)	
end

-------------------------------------------------------------------------------
-- Setup_Movie_Display (Interface)
-------------------------------------------------------------------------------
function Setup_Movie_Display(movie_name, attract_mode)
	Register_Video_Commands()
	local settings = VideoSettingsManager.Get_Current_Settings()
	local width = settings.Screen_Width
	local height = settings.Screen_Height	
	
	local movie_height = (width / height) / (16.0 / 9.0)
	local y_offset = (1.0 - movie_height) / 2.0;

	this.Movie.Set_World_Bounds(0.0, y_offset, 1.0, movie_height)
	this.Movie.Set_Loop(attract_mode)
	if attract_mode == true then
		this.UaW_Logo.Set_Hidden(false)
	else
		this.UaW_Logo.Set_Hidden(true)
	end

	Stop_All_Music()
	this.Movie.Set_Movie(movie_name)

	--Don't play music here - we'll leave that to the movie itself

	this.Enable(true)
	this.Focus_First()
end

-------------------------------------------------------------------------------
-- Stop_Full_Screen_Movie
-------------------------------------------------------------------------------
function Stop_Full_Screen_Movie(_, _)
	this.Movie.Stop()
	this.End_Modal()	
end

-------------------------------------------------------------------------------
-- Interface
-------------------------------------------------------------------------------
Interface = {}
Interface.Setup_Movie_Display = Setup_Movie_Display
Interface.Stop_Full_Screen_Movie = Stop_Full_Screen_Movie
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
