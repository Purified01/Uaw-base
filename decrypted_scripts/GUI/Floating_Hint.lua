-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Floating_Hint.lua#15 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Floating_Hint.lua $
--
--    Original Author: Joe Howes
--
--            $Author: James_Yarrow $
--
--            $Change: 85052 $
--
--          $DateTime: 2007/09/28 14:59:34 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGHintSystem")
require("PGHintSystemDefs")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	PGHintSystem_Init()
	PGHintSystemDefs_Init()
	Register_Hint_Context_Scene(Floating_Hint.Get_Containing_Scene())			-- Set the scene which all hints will be attached to / removed from.


	-- ********* GUI INIT **************
	DISMISSAL_TIMEOUT = 5
	INVALID_DATA_MODEL_STRING = Create_Wide_String("INVALID_DATA_MODEL")
	HINT_BG_GUTTER = 0.035
	HINT_CLOSE_BUTTON_WIDTH = 0.038 
	
	DismissalTimer = -1
	DismissalCountdown = -1
	GameObject = nil
	DataModel = nil
	IsShowing = true
	
	Floating_Hint.Hint.Set_Hidden(true)
	Floating_Hint.Icon.Set_Hidden(false)

	--It actually improves performance to specifically hide the text object.
	Floating_Hint.Hint.Text_Hint.Set_Hidden(true)

	-- ********* EVENT HANDLERS ***********
	Floating_Hint.Register_Event_Handler("On_Set_Model", nil, On_Set_Model)
	Floating_Hint.Register_Event_Handler("On_Set_Game_Object", nil, On_Set_Game_Object)
	Floating_Hint.Register_Event_Handler("Animation_Finished", Floating_Hint.Icon, On_Icon_Animation_Finished)
	Floating_Hint.Register_Event_Handler("Rebuild_Graphics", nil, Resize_Text_Window)	
	
	-- Prerender text (EMP 7/6/07)
	--JSY: Took floating text off pre-render - the rebuild is tripping too often
	--and causing a worse hit to the framerate than just drawing the text.
	--Floating_Hint.Hint.Text_Hint.Set_PreRender(true)
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
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Icon_Clicked(event_name, source)
	IsShowing = false
	
	-- if the hint text is not showing then show it.
	-- else close it down and dismiss this hint
	if Floating_Hint.Hint.Get_Hidden() then
		Floating_Hint.Hint.Set_Hidden(false)
		Floating_Hint.Hint.Text_Hint.Set_Hidden(false)
		DismissalCountdown = DISMISSAL_TIMEOUT
		DismissalTimer = GetCurrentTime()
		Invoke_Hint_Activation_Callback(DataModel.Id)
		-- Play a 2D sound
		Play_SFX_Event("GUI_Hint_Text_Shown")
	else
		Dismiss_Hint()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Close_Clicked(event_name, source)
	Dismiss_Hint()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Text_Mouse_On(event_name, source)
	DismissalCountdown = -1
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Text_Mouse_Off(event_name, source)
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

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Set_Model(event, source, hint_id)
	Set_Model(hint_id)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Set_Game_Object(event, source, game_object)
	Set_Game_Object(game_object)
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Disable_Hints_Clicked(event, source, game_object)
	MessageBox("NIY")
	--Set_Hint_System_Enabled(false)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- On_Close_Button_Pushed
-------------------------------------------------------------------------------
function On_Close_Button_Pushed(event, source)
	Play_SFX_Event("GUI_Generic_Button_Select")
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function On_Icon_Animation_Finished()
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Refresh_UI()
	--Floating_Hint.Title_Text.Set_Text(DataModel.Name)
	local text = INVALID_DATA_MODEL_STRING
	if (DataModel ~= nil) then
		text = DataModel.Text
	end
	Floating_Hint.Hint.Text_Hint.Set_Text(text)
end

------------------------------------------------------------------------------
-- Given the dimensions of the text block for the hint, resize the containing
-- art so that it fits snugly against the text.
------------------------------------------------------------------------------
function Resize_Text_Window()

	local text_width = Floating_Hint.Hint.Text_Hint.Get_Text_Width()
	local text_height = Floating_Hint.Hint.Text_Hint.Get_Text_Height()
	local txtx, txty, txtw, txth = Floating_Hint.Hint.Text_Hint.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = Floating_Hint.Hint.Frame.Get_World_Bounds()
	local clsx, clsy, clsw, clsh = Floating_Hint.Hint.Quad_Close.Get_World_Bounds()
	
	-- Width
	-- Adjust the right side of the background to match the width of the text.
	local new_bgw = text_width + HINT_BG_GUTTER + HINT_CLOSE_BUTTON_WIDTH 
	local bgw_delta = bgw - new_bgw
	
	-- Height
	-- We want to keep the lower bounds in place and move the upper bounds to accomodate.
	local new_bgh = text_height + HINT_BG_GUTTER
	local bgh_delta = bgh - new_bgh
	
	-- Horizontal adjustments
	--local new_bdrw = bdrw - bgw_delta	-- Adjust the hint border.
	local new_clsx = clsx - bgw_delta	-- Adjust the horizontal position of the close button.
	
	-- Vertical adjustments
	local new_txth = txth
	if (bgh_delta < 0) then
		-- We are making the text box LARGER vertically.
		new_txth = text_height
	else
		-- We are making the text box SMALLER vertically.
	end
	local new_txty = txty + bgh_delta	-- Adjust the vertical position of the hint text.
	local new_bgy = bgy + bgh_delta		-- Adjust the vertical position of the hint background.
	local new_clsy = clsy + bgh_delta	-- Adjust the vertical position of the close button.

	Floating_Hint.Hint.Text_Hint.Set_World_Bounds(txtx, new_txty, txtw, new_txth)
	Floating_Hint.Hint.Frame.Set_World_Bounds(bgx, new_bgy, new_bgw, new_bgh)
	Floating_Hint.Hint.Quad_Close.Set_World_Bounds(new_clsx, new_clsy, clsw, clsh)
	
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
function Dismiss_Hint()
    if (Floating_Hint ~= nil) then
	Remove_Attached_Hint(DataModel.Id)
	Invoke_Hint_Dismissal_Callback(DataModel.Id)
	-- Play a 2D sound
	Play_SFX_Event("GUI_Hint_Text_Closed")
    end
end

-------------------------------------------------------------------------------
-- Call to set the parent scene of this icon.
-------------------------------------------------------------------------------
function Set_Model(model_id)
	DataModel = HintSystemMap[model_id]
	Refresh_UI()
	Resize_Text_Window()
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
function Set_Game_Object(game_object)
	GameObject = game_object
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Is_Showing = Is_Showing
Interface.Set_Game_Object = Set_Game_Object

