LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGCampaigns.lua#4 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGCampaigns.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGCampaigns_Init()

	-- The campaigns
	PG_CAMPAIGN_INVALID	= Declare_Enum(0)
	PG_CAMPAIGN_PRELUDE	= Declare_Enum()
	PG_CAMPAIGN_NOVUS		= Declare_Enum()
	PG_CAMPAIGN_ALIEN		= Declare_Enum()
	PG_CAMPAIGN_MASARI	= Declare_Enum()

	-- Mission numbers
	PG_CAMPAIGN_MISSION_INVALID = Declare_Enum(0)
	PG_CAMPAIGN_MISSION_01 = Declare_Enum()
	PG_CAMPAIGN_MISSION_02 = Declare_Enum()
	PG_CAMPAIGN_MISSION_03 = Declare_Enum()
	PG_CAMPAIGN_MISSION_04 = Declare_Enum()
	PG_CAMPAIGN_MISSION_05 = Declare_Enum()
	PG_CAMPAIGN_MISSION_06 = Declare_Enum()
	PG_CAMPAIGN_MISSION_07 = Declare_Enum()

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
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGCampaigns_Init = nil
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
