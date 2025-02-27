if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Retry_Dialog.lua#4 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Retry_Dialog.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92481 $
--
--          $DateTime: 2008/02/05 12:16:28 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

function On_Retry_Clicked()
	this.End_Modal("Retry")
end

function On_Load_Clicked()
	this.End_Modal("Load")
end

function On_Quit_Clicked()
	this.End_Modal("Quit")
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
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Kill_Unused_Global_Functions = nil
end
