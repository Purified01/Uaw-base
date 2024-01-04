-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Achievement_Won_List.lua#9 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Achievement_Won_List.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Maria_Teruel $
--
--            $Change: 72945 $
--
--          $DateTime: 2007/06/12 12:58:52 $
--
--          $Revision: #9 $
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

	--OfflineModel = {}
	--OnlineModel = {}

	-- **** REQUIRE FILE INIT ****
	-- Global variables now MUST be initialized inside functions
	PGColors_Init()

	-- ********* GUI INIT **************
	DialogShowing = true

	Achievement_Won_List.Set_Bounds(0, 0, 1, 1)

	-- Buttons
	Achievement_Won_List.Button_Ok.Set_Button_Name("Ok")

	-- Initialize the offline achievements box
	ACHIEVEMENT_LIST_NAME = Create_Wide_String("ACHIEVEMENT_LIST_NAME")
	ACHIEVEMENT_LIST_BUFF_DESC = Create_Wide_String("ACHIEVEMENT_LIST_BUFF_DESC")
	Achievement_Won_List.List_Won_Achievements.Set_Header_Style("NONE") 
	Achievement_Won_List.List_Won_Achievements.Add_Column(ACHIEVEMENT_LIST_NAME)
	Achievement_Won_List.List_Won_Achievements.Add_Column(ACHIEVEMENT_LIST_BUFF_DESC)
	Achievement_Won_List.List_Won_Achievements.Refresh()

	-- Event handlers

	-- Profile population
	Register_Game_Scoring_Commands()
	Refresh_UI()

end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------
-- On_Mouse_Over_Button - Play SFX response
------------------------------------------------------------------------
function On_Mouse_Over_Button(event, source)
	Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
end

------------------------------------------------------------------------
-- On_Button_Pushed - Play SFX response
------------------------------------------------------------------------
function On_Button_Pushed(event, source)
	Play_SFX_Event("GUI_Main_Menu_Button_Select")
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	DialogShowing = true
	Refresh_UI(true)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	DialogShowing = false
	Achievement_Won_List.End_Modal()
end

-------------------------------------------------------------------------------
-- Back button
-------------------------------------------------------------------------------
function On_Ok_Clicked(event_name, source)
	DialogShowing = false
    if (TestValid(Achievement_Won_List)) then
        Achievement_Won_List.Get_Containing_Component().Set_Hidden(true)
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
-- We either need to display a list of offline achievements, or a list of
-- online achievements for a particular player.  We discriminate using
-- Get_Local_Player_Details().
------------------------------------------------------------------------------
function Refresh_UI()

	Achievement_Won_List.List_Won_Achievements.Clear()

	local model = nil

	if (OfflineModel ~= nil) then
		-- Display a list of offline achievements.
		model = OfflineModel
	elseif (OnlineModel ~= nil) then
		-- Display a particular player's online achievements.
		local player_id = Get_Local_Player_Details()
		model = OnlineModel[player_id]
	end

	if (model == nil) then
		-- No achievements.
		local new_row = Achievement_Won_List.List_Won_Achievements.Add_Row()
		Achievement_Won_List.List_Won_Achievements.Set_Text_Data(ACHIEVEMENT_LIST_NAME, new_row, Get_Game_Text("TEXT_NO_ACHIEVEMENTS_AWARDED"))
		Achievement_Won_List.List_Won_Achievements.Set_Text_Data(ACHIEVEMENT_LIST_BUFF_DESC, new_row, Create_Wide_String(""))
		Achievement_Won_List.List_Won_Achievements.Set_Row_Color(new_row, tonumber(COLOR_GRAY))
	else
		-- Iterate and display achievements.
		for key, achievement in pairs(model) do
			local new_row = Achievement_Won_List.List_Won_Achievements.Add_Row()
			Achievement_Won_List.List_Won_Achievements.Set_Text_Data(ACHIEVEMENT_LIST_NAME, new_row, achievement.Name)
			Achievement_Won_List.List_Won_Achievements.Set_Text_Data(ACHIEVEMENT_LIST_BUFF_DESC, new_row, Get_Game_Text(achievement.BuffDesc))
			Achievement_Won_List.List_Won_Achievements.Set_Row_Color(new_row, tonumber(COLOR_GREEN))
		end
	end

	Achievement_Won_List.List_Won_Achievements.Refresh()

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

------------------------------------------------------------------------------
-- The GameScoring system stored all the local player's information from
-- the lobby.  Use that to determine the ID of the local player.
------------------------------------------------------------------------------
function Get_Local_Player_Details()
	local local_client = GameScoringManager.Get_Local_Client_Table()
	DebugMessage("WARNING:  LOCAL PLAYER ID SHOULD BE: " .. tostring(local_client.PlayerID))
	return local_client.common_addr, local_client.PlayerID
end

------------------------------------------------------------------------------
-- Accessor for the offline model.  Note that it nukes the online model
-- (We only ever display one type).
------------------------------------------------------------------------------
function Set_Offline_Model(model)
	OfflineModel = model
	OnlineModel = nil
	Refresh_UI()
end

------------------------------------------------------------------------------
-- Accessor for the online model.  Note that it nukes the offline model
-- (We only ever display one type).
------------------------------------------------------------------------------
function Set_Online_Model(model)
	OfflineModel = nil
	OnlineModel = model
	Refresh_UI()
end

------------------------------------------------------------------------------
-- We either need to display a list of offline achievements, or a list of
-- online achievements for a particular player.  We discriminate using
-- Get_Local_Player_Details().
------------------------------------------------------------------------------
function Is_Showing()
	return DialogShowing
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Offline_Model = Set_Offline_Model
Interface.Set_Online_Model = Set_Online_Model
Interface.Is_Showing = Is_Showing

