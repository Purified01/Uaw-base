if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[115] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Post_Campaign_Scene.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Post_Campaign_Scene.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	-- register required event handlers
	this.Register_Event_Handler("Button_Clicked", this.Scene.Button_Okay, Okay_Clicked)

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- Initialize the results list boxes
	PLAYER_FACTION = Create_Wide_String("PLAYER_FACTION")
	UNITS_DESTROYED = Get_Game_Text("TEXT_HEADER_UNITS_DESTROYED")
	BUILDINGS_DESTROYED = Get_Game_Text("TEXT_HEADER_BUILDINGS_DESTROYED")
	HEROES_DESTROYED = Get_Game_Text("TEXT_HEADER_HEROES_DESTROYED")
	RESOURCES_COLLECTED = Get_Game_Text("TEXT_HEADER_RESOURCES_COLLECTED")

	this.Scene.List_Box_Results.Add_Column(PLAYER_FACTION, JUSTIFY_LEFT)
	this.Scene.List_Box_Results.Add_Column(UNITS_DESTROYED, JUSTIFY_CENTER)
	this.Scene.List_Box_Results.Add_Column(BUILDINGS_DESTROYED, JUSTIFY_CENTER)
	this.Scene.List_Box_Results.Add_Column(HEROES_DESTROYED, JUSTIFY_CENTER)
	this.Scene.List_Box_Results.Add_Column(RESOURCES_COLLECTED, JUSTIFY_CENTER)
	this.Scene.List_Box_Results.Set_Header_Style("TEXT")
	this.Scene.List_Box_Results.Set_Header_Style("NONE", PLAYER_FACTION)
	this.Scene.List_Box_Results.Refresh()
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end

function Okay_Clicked()
	this.End_Modal()
end

-- We should be getting this from XML, but it ends up in FactionClass, which isn't wrapped (yet)
function Get_Faction_Icon_Name(faction)
	if faction == "MASARI" then 
		return Create_Wide_String("i_logo_masari.tga")
	elseif faction == "ALIEN" then
		return Create_Wide_String("i_logo_aliens.tga")
	elseif faction == "NOVUS" then
		return Create_Wide_String("i_logo_novus.tga")
	else
		return Create_Wide_String("i_logo_military.tga")
	end
end

function Finalize_Init()
	this.Scene.List_Box_Results.Clear()
	this.Scene.List_Box_Results.Set_Hidden(true)

	local player = Find_Player("local")
	local winner = this.Get_User_Data().Winner
	if winner == player then
		this.Scene.Announcement.Set_Text(Get_Game_Text("TEXT_WIN_TACTICAL"))
	else
		this.Scene.Announcement.Set_Text(Get_Game_Text("TEXT_LOSE_TACTICAL"))
	end

	local scoring_script = Get_Game_Scoring_Script()
	if scoring_script == nil then
		Start_Fade_In()
		return
	end

	local user_data = this.Get_User_Data()
	local session_length = Get_Localized_Formatted_Number.Get_Time(user_data.GameEndTime)
	local session_length_string = Get_Game_Text("TEXT_SESSION_LENGTH")
	session_length_string.append(Create_Wide_String(" ")).append(session_length)
	this.Scene.Text_Session_Length.Set_Text(session_length_string)

	ResultsTable = scoring_script.Get_Variable("ResultsTable")

	if ResultsTable == nil then
		Start_Fade_In()
		return
	end

	Display_Dialog()
	
	return true
end

function Start_Fade_In()
	this.Scene.Play_Animation("SceneFadeIn", false)
	this.Scene.Set_Animation_Frame(0)
end

function Display_Dialog()
	local player = Find_Player("local")

	local new_row = this.Scene.List_Box_Results.Add_Row()
	this.Scene.List_Box_Results.Set_Texture(PLAYER_FACTION, new_row, Get_Faction_Icon_Name(player.Get_Faction_Name()))
	this.Scene.List_Box_Results.Set_Text_Data(UNITS_DESTROYED, new_row, Get_Localized_Formatted_Number(ResultsTable.units_destroyed))
	this.Scene.List_Box_Results.Set_Text_Data(BUILDINGS_DESTROYED, new_row, Get_Localized_Formatted_Number(ResultsTable.buildings_destroyed))
	this.Scene.List_Box_Results.Set_Text_Data(HEROES_DESTROYED, new_row, Get_Localized_Formatted_Number(ResultsTable.heroes_destroyed))
	this.Scene.List_Box_Results.Set_Text_Data(RESOURCES_COLLECTED, new_row, Get_Localized_Formatted_Number(player.Get_Total_Credits_Collected()))
	this.Scene.List_Box_Results.Set_Row_Background(new_row, player.Get_Color(),"score_screen_color.tga")

	this.Scene.List_Box_Results.Set_Hidden(false)

	Start_Fade_In()
end

Interface = {}
Interface.Finalize_Init = Finalize_Init
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
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
