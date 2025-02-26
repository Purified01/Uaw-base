if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGFactions.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGFactions.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGFactions_Init()

	-- THE BIG FACTIONS
	PG_FACTION_ALL		= Declare_Enum(1)
	PG_FACTION_NOVUS	= Declare_Enum()
	PG_FACTION_ALIEN	= Declare_Enum()
	PG_FACTION_MASARI	= Declare_Enum()
	PG_FACTION_MILITARY	= Declare_Enum()
	PG_FACTION_NEUTRAL	= Declare_Enum()
	
	PG_SELECTABLE_FACTION_MIN = PG_FACTION_NOVUS
	PG_SELECTABLE_FACTION_MAX = PG_FACTION_MASARI
	
	-- String form factions for networking
	PG_FACTION_NOVUS_STRING = "Novus"
	PG_FACTION_ALIEN_STRING = "Alien"
	PG_FACTION_MASARI_STRING = "Masari"
	PGFactionStringLookup = {}
	PGFactionStringLookup[PG_FACTION_NOVUS] = PG_FACTION_NOVUS_STRING
	PGFactionStringLookup[PG_FACTION_ALIEN] = PG_FACTION_ALIEN_STRING
	PGFactionStringLookup[PG_FACTION_MASARI] = PG_FACTION_MASARI_STRING
	

	-- Localized wide strings for user display.
	PGFactionLocalizedLookup = {}
	PGFactionLocalizedLookup[PG_FACTION_NOVUS] = Get_Game_Text("TEXT_FACTION_NOVUS")
	PGFactionLocalizedLookup[PG_FACTION_ALIEN] = Get_Game_Text("TEXT_FACTION_ALIEN")
	PGFactionLocalizedLookup[PG_FACTION_MASARI] = Get_Game_Text("TEXT_FACTION_MASARI")
	PGFactionLocalizedLookup[PG_FACTION_MILITARY] = Get_Game_Text("TEXT_FACTION_MILITARY")
	PGFactionLocalizedLookup[PG_FACTION_NEUTRAL] = Get_Game_Text("TEXT_FACTION_NEUTRAL")
	

	-- Textures
	PGFactionTextures = {}
	PGFactionTextures[PG_FACTION_NOVUS] = "i_logo_novus.tga"
	PGFactionTextures[PG_FACTION_ALIEN] = "i_logo_aliens.tga"
	PGFactionTextures[PG_FACTION_MASARI] = "i_logo_masari.tga"
	

	-- Gamer Pics
	PGGamerPictures = {}
	PGGamerPictures[PG_FACTION_NOVUS] = "i_faction_novus.tga"
	PGGamerPictures[PG_FACTION_ALIEN] = "i_faction_alien.tga"
	PGGamerPictures[PG_FACTION_MASARI] = "i_faction_masari.tga"
		
		
	-- Maria 07.03.2007
	PGFactionNameToFactionTexture = {}
	PGFactionNameToFactionTexture["NOVUS"]		= PGFactionTextures[PG_FACTION_NOVUS]
	PGFactionNameToFactionTexture["ALIEN"]		= PGFactionTextures[PG_FACTION_ALIEN]
	PGFactionNameToFactionTexture["MASARI"]	= PGFactionTextures[PG_FACTION_MASARI]

	-- Starting Cash
	-- These constants MUST stay syncronized with the same values in InvasionStartGameHandler.cpp
	PG_FACTION_CASH_SMALL		= Declare_Enum(0)	-- 0-based because we're going to be using combo boxes with this.
	PG_FACTION_CASH_MEDIUM		= Declare_Enum()
	PG_FACTION_CASH_LARGE		= Declare_Enum()

end

-------------------------------------------------------------------------------
-- Only returns a valid value for the big three factions: Novus, Alien and 
-- Masari.
--
-- NOTE: This is NOT a user-displayable string!  Use Get_Localized_Faction_Name().
-------------------------------------------------------------------------------
function Get_Faction_String_Form(numeric_faction_variable)
	return PGFactionStringLookup[numeric_faction_variable]
end

-------------------------------------------------------------------------------
-- Returns the numeric form of the faction.  Only works for the bug three 
-- factions.
-------------------------------------------------------------------------------
function Get_Faction_Numeric_Form(string_faction_variable)
	for index, value in pairs(PGFactionStringLookup) do
		if (value == string_faction_variable) then
			return index
		end
	end
	return nil
end

-------------------------------------------------------------------------------
-- Gets a user displayable form of the faction name.
-------------------------------------------------------------------------------
function Get_Faction_Numeric_Form_From_Localized(localized_form)
	for index, value in pairs(PGFactionLocalizedLookup) do
		if (value == localized_form) then
			return index
		end
	end
	return nil
end

-------------------------------------------------------------------------------
-- Gets a user displayable form of the faction name.
-------------------------------------------------------------------------------
function Get_Localized_Faction_Name(numeric_faction_variable)
	return PGFactionLocalizedLookup[numeric_faction_variable]
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
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Localized_Faction_Name = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGFactions_Init = nil
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
