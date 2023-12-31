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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Walker_HardPoint_Button.lua 
--
--    Original Author: Maria Teruel
--
--          DateTime: 2006/11/02 15:36:32 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("Selectable_Icon")

-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	Initialize_Selectable_Icon()
	this.Group.CrownOverlay.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Show_Crown_Overlay
-- ------------------------------------------------------------------------------------------------------------------
function Show_Crown_Overlay(on_off)
	this.Group.CrownOverlay.Set_Hidden(not on_off)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface.Show_Crown_Overlay = Show_Crown_Overlay
