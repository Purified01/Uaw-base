-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Game_Map_Loader.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Game_Map_Loader.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Maria_Teruel $
--
--            $Change: 74336 $
--
--          $DateTime: 2007/06/25 18:20:45 $
--
--          $Revision: #5 $
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

	-- **** REQUIRE FILE INIT ****
	-- Global variables now MUST be initialized inside functions
	PGColors_Init()

	-- ********* GUI INIT **************
	DialogShowing = true

	Game_Map_Loader.Set_Bounds(0, 0, 1, 1)

	-- Initialize the offline achievements box
	GAME_LIST_NAME = Create_Wide_String("GAME_LIST_NAME")
	Game_Map_Loader.List_Games.Set_Header_Style("NONE") 
	Game_Map_Loader.List_Games.Add_Column(GAME_LIST_NAME)
	Game_Map_Loader.List_Games.Refresh()

	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.List_Games, Play_Option_Select_SFX)	
	
	-- Tab order.
	Game_Map_Loader.List_Games.Set_Tab_Order(Declare_Enum(0))
	Game_Map_Loader.Button_Load.Set_Tab_Order(Declare_Enum())
	Game_Map_Loader.Button_Playback.Set_Tab_Order(Declare_Enum())
	Game_Map_Loader.Button_Cancel.Set_Tab_Order(Declare_Enum())

	Game_Map_Loader.Focus_First()

	LoadableMapFiles = Get_Loadable_Map_Files()
	--table.sort(LoadableMapFiles)
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
	-- Commented out for now for performance reasons.  
	-- The contents of the map directory don't really change now...
	--Refresh_UI()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	DialogShowing = false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function On_Cancel_Clicked(event_name, source)
	DialogShowing = false
    if (Game_Map_Loader ~= nil) then
        Game_Map_Loader.Get_Containing_Component().Set_Hidden(true)
    end
    this.End_Modal() -- added at James' request 4/18/2007 8:38:35 PM -- NSA
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function On_Playback_Clicked(event_name, source)
	MessageBox("NOT IMPLEMENTED YET")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function On_Load_Clicked(event_name, source)

	DialogShowing = false
    if (Game_Map_Loader ~= nil) then
        Game_Map_Loader.Get_Containing_Component().Set_Hidden(true)
    end

	-- Get the selected file path.
	local row_index = Game_Map_Loader.List_Games.Get_Selected_Row_Index()
	if (row_index == -1) then
		return
	end
	local file_path = LoadableMapFiles[row_index+1]		-- The row_index is zero-based, AvailableGames is 1-based.
	Game_Map_Loader.End_Modal()
	Load_Map_File(file_path)

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
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Option_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
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

	Game_Map_Loader.List_Games.Clear()

	-- Iterate and display achievements.
	for _, filename in ipairs(LoadableMapFiles) do
		local new_row = Game_Map_Loader.List_Games.Add_Row()
		Game_Map_Loader.List_Games.Set_Text_Data(GAME_LIST_NAME, new_row, filename)
		Game_Map_Loader.List_Games.Set_Row_Color(new_row, tonumber(COLOR_CYAN))
	end

	Game_Map_Loader.List_Games.Refresh()
	--Game_Map_Loader.List_Games.Set_Selected_Row_Index(50)	-- HACK to temporarily select the minimal map for now!

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
--
------------------------------------------------------------------------------
function Is_Showing()
	return DialogShowing
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Showing = Is_Showing

