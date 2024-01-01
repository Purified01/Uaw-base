-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Mouse.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Mouse.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: James_Yarrow $
--
--            $Change: 56145 $
--
--          $DateTime: 2006/10/10 16:42:59 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- Mouse button constants
MOUSEBUTTON_LEFT = 0
MOUSEBUTTON_RIGHT = 1
MOUSEBUTTON_MIDDLE = 2

-- Is the button current down?
MouseButtonDown =     { [MOUSEBUTTON_LEFT]=false, [MOUSEBUTTON_RIGHT]=false, [MOUSEBUTTON_MIDDLE]=false }

-- Was it clicked since last frame?
MouseButtonClicked =  { [MOUSEBUTTON_LEFT]=false, [MOUSEBUTTON_RIGHT]=false, [MOUSEBUTTON_MIDDLE]=false }

-- Was it released since last frame?
MouseButtonReleased = { [MOUSEBUTTON_LEFT]=false, [MOUSEBUTTON_RIGHT]=false, [MOUSEBUTTON_MIDDLE]=false }

-- Should get called exactly once per frame, by any script instances that need mouse button input
function Update_Mouse_Buttons()
	-- Get current button states from the game
	_left = Get_Mouse_Button_Down(MOUSEBUTTON_LEFT)
	_right = Get_Mouse_Button_Down(MOUSEBUTTON_RIGHT)
	_middle = Get_Mouse_Button_Down(MOUSEBUTTON_MIDDLE)

	-- Which buttons have just been clicked?	
	MouseButtonClicked[MOUSEBUTTON_LEFT]   = not MouseButtonDown[MOUSEBUTTON_LEFT] and _left
	MouseButtonClicked[MOUSEBUTTON_RIGHT]  = not MouseButtonDown[MOUSEBUTTON_RIGHT] and _right
	MouseButtonClicked[MOUSEBUTTON_MIDDLE] = not MouseButtonDown[MOUSEBUTTON_MIDDLE] and _middle
	
	-- Which buttons have just been released?	
	MouseButtonReleased[MOUSEBUTTON_LEFT]   = MouseButtonDown[MOUSEBUTTON_LEFT] and not _left
	MouseButtonReleased[MOUSEBUTTON_RIGHT]  = MouseButtonDown[MOUSEBUTTON_RIGHT] and not _right
	MouseButtonReleased[MOUSEBUTTON_MIDDLE] = MouseButtonDown[MOUSEBUTTON_MIDDLE] and not _middle

	-- Update our button states	
	MouseButtonDown[MOUSEBUTTON_LEFT] = _left
	MouseButtonDown[MOUSEBUTTON_RIGHT] = _right
	MouseButtonDown[MOUSEBUTTON_MIDDLE] = _middle

end

function Init_Mouse_Buttons()
	MouseButtonDown =     { [MOUSEBUTTON_LEFT]=false, [MOUSEBUTTON_RIGHT]=false, [MOUSEBUTTON_MIDDLE]=false }
	MouseButtonClicked =  { [MOUSEBUTTON_LEFT]=false, [MOUSEBUTTON_RIGHT]=false, [MOUSEBUTTON_MIDDLE]=false }
	MouseButtonReleased = { [MOUSEBUTTON_LEFT]=false, [MOUSEBUTTON_RIGHT]=false, [MOUSEBUTTON_MIDDLE]=false }
end