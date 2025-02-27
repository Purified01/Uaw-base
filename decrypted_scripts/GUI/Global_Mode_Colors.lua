LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Global_Mode_Colors.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Global_Mode_Colors.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 92481 $
--
--          $DateTime: 2008/02/05 12:16:28 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- This file contains the colors that the global mode HUD uses for regions, depending
-- on their state. (Format is R, G, B, all values 0.0 to 1.0. All colors additive.)
-- -CSB 03/03/2006

function Init_Global_Mode_Colors()

	REGION_COLOR = {}
	REGION_COLOR_ROLLOVER = {}
	REGION_COLOR_INVALID_TARGET = {}
	
	REGION_COLOR["ALIEN"] = { 0.70, .30, 0.0 }
	REGION_COLOR_ROLLOVER["ALIEN"] = { 0.99, 0.66, 0.18 }
	REGION_COLOR_INVALID_TARGET["ALIEN"] = { 0.0, 0.0, 0.0 } --{ 0.4, 0.3, 0.1 }
	
	REGION_COLOR["NOVUS"] = { 0.0, 0.31, 0.66 }
	REGION_COLOR_ROLLOVER["NOVUS"] = {  0.37, 0.63, 0.75 }
	REGION_COLOR_INVALID_TARGET["NOVUS"] = { 0.0, 0.0, 0.0 } --{ 0.15, 0.25, 0.3 }

	REGION_COLOR["MASARI"] = { 0.30, 0.44, 0.20 }
	REGION_COLOR_ROLLOVER["MASARI"] = { 0.88, 0.85, 0.35 }
	REGION_COLOR_INVALID_TARGET["MASARI"] = { 0.0, 0.0, 0.0 } --{ 0.4, 0.3, 0.15 }
	
	REGION_COLOR["NEUTRAL"] = { 0.3, 0.3, 0.3 }
	REGION_COLOR_ROLLOVER["NEUTRAL"] = { 0.65, 0.65, 0.65 }
	REGION_COLOR_INVALID_TARGET["NEUTRAL"] = { 0.0, 0.0, 0.0 }

	ROUTE_COLOR_PREVIEW = { 0.0, 1.0, 0.0 }
	ROUTE_COLOR_PREVIEW_INVALID = { 1.0, 0.0, 0.0 }

	GOOD_PRICE_COLOR = { 0.0, 1.0, 0.0, 1.0 }
	BAD_PRICE_COLOR = { 1.0, 0.0, 0.0, 1.0 }
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Init_Global_Mode_Colors = nil
	Kill_Unused_Global_Functions = nil
end
