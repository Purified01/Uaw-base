LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGColors.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGColors.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

function PGColors_Init()
	PGColors_Init_Constants()
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- C O N S T A N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PGColors_Init_Constants()
-- The following 3 lines are required by the lua preprocessor.  1/22/2008 3:14:28 PM -- BMH
--[[








































































































































































]]--

end

-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- V A R I A B L E S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

function Get_Chat_Color_Index(color_index)

	local index = -1

	for i = 0, 7 do
		if (({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[i] == color_index) then
			index = i
			break
		end
	end

	return index

end


function Create_Fallback_MP_Colors()

	local result = {}
	
	local triple = {}
	triple["r"] = 0.12
	triple["g"] = 0.12
	triple["b"] = 0.12
	triple["a"] = 1.0
	result["GRAY"] = triple

	triple = {}
	triple["r"] = 0.31
	triple["g"] = 0.59
	triple["b"] = 1.0
	triple["a"] = 1.0
	result["BLUE"] = triple

	triple = {}
	triple["r"] = 1.0
	triple["g"] = 0.58
	triple["b"] = 0.09
	triple["a"] = 1.0
	result["ORANGE"] = triple

	triple = {}
	triple["r"] = 0.89
	triple["g"] = 0.87
	triple["b"] = 0.18
	triple["a"] = 1.0
	result["YELLOW"] = triple

	triple = {}
	triple["r"] = 0.47
	triple["g"] = 1.0
	triple["b"] = 0.31
	triple["a"] = 1.0
	result["GREEN"] = triple

	triple = {}
	triple["r"] = 0.44
	triple["g"] = 0.85
	triple["b"] = 0.88
	triple["a"] = 1.0
	result["CYAN"] = triple

	triple = {}
	triple["r"] = 1.0
	triple["g"] = 0.44
	triple["b"] = 0.82
	triple["a"] = 1.0
	result["PURPLE"] = triple

	triple = {}
	triple["r"] = 1.0
	triple["g"] = 0.09
	triple["b"] = 0.09
	triple["a"] = 1.0
	result["RED"] = triple
	
	return result
	
end
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
	PGColors_Init = nil
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
