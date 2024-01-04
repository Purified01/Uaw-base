-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Hint_Text.lua#9 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Hint_Text.lua $
--
--    Original Author: Joe Howes
--
--            $Author: James_Yarrow $
--
--            $Change: 79571 $
--
--          $DateTime: 2007/08/02 14:45:56 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGHintSystemDefs")
require("PGHintSystem")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	PGHintSystemDefs_Init()
	PGHintSystem_Init()
	Register_Hint_Context_Scene(Hint_Text.Get_Containing_Scene())			-- Set the scene which all hints will be attached to / removed from.

	-- ********* GUI INIT **************
	DISMISSAL_TIMEOUT = 5
	HINT_BG_GUTTER = 0.035
	HINT_CLOSE_BUTTON_WIDTH = 0.038 

	Scene = nil
	HintID = nil
	DataModel = nil
	IsShowing = true
	DismissalTimer = -1
	DismissalCountdown = -1
	DefaultVerticalDelta = 0

	--Start_Dismissal_Countdown()
	
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	IsShowing = false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	IsShowing = true
	Start_Dismissal_Countdown()
	-- Play a 2D sound
	Play_SFX_Event("GUI_Hint_Text_Shown")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Close_Clicked(event_name, source)
	IsShowing = false
	Dismiss_Hint()	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Disable_Hints_Clicked(event, source, game_object)
	MessageBox("NIY")
	--Set_Hint_System_Enabled(false)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Mouse_On(event_name, source)
	DismissalCountdown = -1
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Mouse_Off(event_name, source)
	DismissalCountdown = DISMISSAL_TIMEOUT
	DismissalTimer = GetCurrentTime()
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
	--Hint_Text.Title_Text.Set_Text(DataModel.Name)
	Hint_Text.Body_Text.Set_Text(DataModel.Text)
end   

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Reset_Text_Window()
	Hint_Text.Body_Text.Set_World_Bounds(DefaultTextX, DefaultTextY, DefaultTextW, DefaultTextH)
	Hint_Text.Frame.Set_World_Bounds(DefaultBGX, DefaultBGY, DefaultBGW, DefaultBGH)
	Hint_Text.Quad_Close.Set_World_Bounds(DefaultClsX, DefaultClsY, DefaultClsW, DefaultClsH)
end
	
------------------------------------------------------------------------------
-- Given the dimensions of the text block for the hint, resize the containing
-- art so that it fits snugly against the text.
------------------------------------------------------------------------------
function Resize_Text_Window()

	local text_width = Hint_Text.Body_Text.Get_Text_Width()
	local text_height = Hint_Text.Body_Text.Get_Text_Height()
	local txtx, txty, txtw, txth = Hint_Text.Body_Text.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = Hint_Text.Frame.Get_World_Bounds()
	local clsx, clsy, clsw, clsh = Hint_Text.Quad_Close.Get_World_Bounds()
	
	-- Width
	-- Adjust the left side of the background to match the width of the text.
	local new_bgw = text_width + HINT_BG_GUTTER + HINT_CLOSE_BUTTON_WIDTH
	local bgw_delta = DefaultBGW - new_bgw
	
	-- Height
	-- We want to keep the upper bounds in place and move the lower bounds to accomodate.
	local new_bgh = text_height + HINT_BG_GUTTER
	local bgh_delta = DefaultBGH - new_bgh
	
	-- Horizontal adjustments
	local new_bgx = DefaultBGX + bgw_delta
	local new_txtx = DefaultTextX + bgw_delta
	
	-- Vertical adjustments
	local new_txty = txty + DefaultVerticalDelta
	local new_bgy = bgy + DefaultVerticalDelta
	local new_clsy = clsy + DefaultVerticalDelta

	Hint_Text.Body_Text.Set_World_Bounds(new_txtx, new_txty, txtw, text_height)
	Hint_Text.Frame.Set_World_Bounds(new_bgx, new_bgy, new_bgw, new_bgh)
	Hint_Text.Quad_Close.Set_World_Bounds(clsx, new_clsy, clsw, clsh)
	
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

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Start_Dismissal_Countdown()
	DismissalCountdown = DISMISSAL_TIMEOUT
	DismissalTimer = GetCurrentTime()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Dismiss_Hint()
	if (DataModel ~= nil) then
		Remove_Independent_Hint(DataModel.Id)
		Invoke_Hint_Dismissal_Callback(DataModel.Id)
		-- Play a 2D sound
		Play_SFX_Event("GUI_Hint_Text_Closed")
	end
end


-------------------------------------------------------------------------------
-- On_Close_Button_Pushed
-------------------------------------------------------------------------------
function On_Close_Button_Pushed(event, source)
	Play_SFX_Event("GUI_Generic_Button_Select")
end

-------------------------------------------------------------------------------
-- Call to set the parent scene of this icon.
-------------------------------------------------------------------------------
function Set_Model(hint_id)
	HintID = hint_id
	DataModel = HintSystemMap[HintID]
	Reset_Text_Window()
	Refresh_UI()
	Resize_Text_Window()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Model_ID()
	return HintID
end

-------------------------------------------------------------------------------
-- Call to tell if this hint text is currently visible.
-------------------------------------------------------------------------------
function Is_Showing()
	return IsShowing
end

-------------------------------------------------------------------------------
-- Call to set the parent scene of this icon.
-------------------------------------------------------------------------------
function Set_Scene(scene)
	Scene = scene
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Mark_Default_World_Bounds()
	DefaultTextX, DefaultTextY, DefaultTextW, DefaultTextH = Hint_Text.Body_Text.Get_World_Bounds()
	DefaultBGX, DefaultBGY, DefaultBGW, DefaultBGH = Hint_Text.Frame.Get_World_Bounds()
	DefaultClsX, DefaultClsY, DefaultClsW, DefaultClsH = Hint_Text.Quad_Close.Get_World_Bounds()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Default_Vertical_Position(ypos)
	DefaultVerticalDelta = ypos - DefaultClsY
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Get_Model_ID = Get_Model_ID
Interface.Is_Showing = Is_Showing
Interface.Set_Scene = Set_Scene
Interface.Mark_Default_World_Bounds = Mark_Default_World_Bounds
Interface.Set_Default_Vertical_Position = Set_Default_Vertical_Position

