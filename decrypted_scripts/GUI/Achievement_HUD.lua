if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Achievement_HUD.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Achievement_HUD.lua $
--
--    Original Author: Joe Howes
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
require("PGDebug")
require("PGColors")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	-- This is a list of lists, keyed on player name and containing a list of each player's buffs.
	AchievementListModel = {}

	-- **** REQUIRE FILE INIT ****
	-- Global variables now MUST be initialized inside functions
	PGColors_Init()

	-- ********* GUI INIT **************
	DialogShowing = true

	Achievement_HUD.Set_Bounds(0, 0, 1, 1)

	-- Initialize the list box
	BUFF_COLUMN = Create_Wide_String("BUFF_COLUMN")
	Achievement_HUD.Achievement_List.Set_Header_Style("NONE") 
	Achievement_HUD.Achievement_List.Add_Column(BUFF_COLUMN)
	Achievement_HUD.Achievement_List.Refresh()

	-- Event handlers

	-- Profile population
	Refresh_UI()

end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	DialogShowing = true
	Refresh_UI(true)
end

-------------------------------------------------------------------------------
-- Back button
-------------------------------------------------------------------------------
function On_Ok_Clicked(event_name, source)
	DialogShowing = false
    if (Achievement_HUD ~= nil) then
        Achievement_HUD.Get_Containing_Component().Set_Hidden(true)
    end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Click() 
	Play_SFX_Event("GUI_Generic_Button_Select")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Alien_Steam() 
	Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Prepare_Fadeout()
	-- We can't call mapped functions from the GUI we have to go through this.
	Prepare_Fades()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Refresh_UI()

	Achievement_HUD.Achievement_List.Clear()

	if (AchievementListModel == nil) then
		return
	end

	for name, buff_list in pairs(AchievementListModel) do

		local new_row = Achievement_HUD.Achievement_List.Add_Row()
		local name_str = " " .. tostring(name)
		Achievement_HUD.Achievement_List.Set_Text_Data(BUFF_COLUMN, new_row, name_str)
		Achievement_HUD.Achievement_List.Set_Row_Color(new_row, tonumber(4))
		local has_buffs = false

			for _, buff in pairs(buff_list) do

				has_buffs = true
				local new_row = Achievement_HUD.Achievement_List.Add_Row()
				local buff_str = Create_Wide_String("   - ").append(Get_Game_Text(buff))
				Achievement_HUD.Achievement_List.Set_Text_Data(BUFF_COLUMN, new_row, buff_str)
				Achievement_HUD.Achievement_List.Set_Row_Color(new_row, tonumber(19))

			end

		if (has_buffs == false) then
			local new_row = Achievement_HUD.Achievement_List.Add_Row()
			local buff_str = Create_Wide_String("   - ").append(Get_Game_Text("TEXT_NO_BUFFS_SELECTED"))
			Achievement_HUD.Achievement_List.Set_Text_Data(BUFF_COLUMN, new_row, buff_str)
			Achievement_HUD.Achievement_List.Set_Row_Color(new_row, tonumber(9))
		end

	end

	Achievement_HUD.Achievement_List.Refresh()

end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------

function Set_Model(model)
	AchievementListModel = model
	Refresh_UI()
end

function Is_Showing()
	return DialogShowing
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Is_Showing = Is_Showing

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
	Get_Chat_Color_Index = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Prepare_Fadeout = nil
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
