-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGFactions.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGFactions.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Maria_Teruel $
--
--            $Change: 75418 $
--
--          $DateTime: 2007/07/03 18:18:52 $
--
--          $Revision: #5 $
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
	PG_FACTION_PROTO	= Declare_Enum()
	PG_FACTION_MILITARY	= Declare_Enum()
	PG_FACTION_NEUTRAL	= Declare_Enum()
	
	PG_SELECTABLE_FACTION_MIN = PG_FACTION_NOVUS
	PG_SELECTABLE_FACTION_MAX = PG_FACTION_PROTO
	
	-- String form factions for networking
	PG_FACTION_NOVUS_STRING = "Novus"
	PG_FACTION_ALIEN_STRING = "Alien"
	PG_FACTION_MASARI_STRING = "Masari"
	PG_FACTION_PROTO_STRING = "Proto"
	PGFactionStringLookup = {}
	PGFactionStringLookup[PG_FACTION_NOVUS] = PG_FACTION_NOVUS_STRING
	PGFactionStringLookup[PG_FACTION_ALIEN] = PG_FACTION_ALIEN_STRING
	PGFactionStringLookup[PG_FACTION_MASARI] = PG_FACTION_MASARI_STRING
	PGFactionStringLookup[PG_FACTION_PROTO] = PG_FACTION_PROTO_STRING
	

	-- Localized wide strings for user display.
	PGFactionLocalizedLookup = {}
	PGFactionLocalizedLookup[PG_FACTION_NOVUS] = Get_Game_Text("TEXT_FACTION_NOVUS")
	PGFactionLocalizedLookup[PG_FACTION_ALIEN] = Get_Game_Text("TEXT_FACTION_ALIEN")
	PGFactionLocalizedLookup[PG_FACTION_PROTO] = Get_Game_Text("TEXT_FACTION_ALIEN")
	PGFactionLocalizedLookup[PG_FACTION_MASARI] = Get_Game_Text("TEXT_FACTION_MASARI")
	PGFactionLocalizedLookup[PG_FACTION_MILITARY] = Get_Game_Text("TEXT_FACTION_MILITARY")
	PGFactionLocalizedLookup[PG_FACTION_NEUTRAL] = Get_Game_Text("TEXT_FACTION_NEUTRAL")
	

	-- Textures
	PGFactionTextures = {}
	PGFactionTextures[PG_FACTION_NOVUS] = "i_logo_novus.tga"
	PGFactionTextures[PG_FACTION_ALIEN] = "i_logo_aliens.tga"
	PGFactionTextures[PG_FACTION_MASARI] = "i_logo_masari.tga"
	PGFactionTextures[PG_FACTION_PROTO] = "i_icon_hazard.tga"
		
		
	-- Maria 07.03.2007
	PGFactionNameToFactionTexture = {}
	PGFactionNameToFactionTexture["NOVUS"]		= PGFactionTextures[PG_FACTION_NOVUS]
	PGFactionNameToFactionTexture["ALIEN"]		= PGFactionTextures[PG_FACTION_ALIEN]
	PGFactionNameToFactionTexture["MASARI"]	= PGFactionTextures[PG_FACTION_MASARI]
	PGFactionNameToFactionTexture["PROTO"]		= PGFactionTextures[PG_FACTION_ALIEN]

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


