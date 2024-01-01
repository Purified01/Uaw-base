-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGColors.lua#19 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGColors.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 81114 $
--
--          $DateTime: 2007/08/16 17:29:18 $
--
--          $Revision: #19 $
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

	-- Multiplayer Color triples
	PG_R = "r"
	PG_G = "g"
	PG_B = "b"
	PG_A = "a"
	
	-- Colors
	-- [7/31/2007 JLH]:  Try to keep these in sync with the script color constants in Colors.h
	COLOR_BLACK				= Declare_Enum(0)
	
	COLOR_WHITE				= Declare_Enum()
	COLOR_RED				= Declare_Enum()
	COLOR_ORANGE			= Declare_Enum()
	COLOR_YELLOW			= Declare_Enum()
	COLOR_GREEN				= Declare_Enum()
	COLOR_CYAN				= Declare_Enum()
	COLOR_BLUE				= Declare_Enum()
	COLOR_PURPLE			= Declare_Enum()
	COLOR_GRAY				= Declare_Enum()
	COLOR_GREY				= COLOR_GRAY
	
	COLOR_BRIGHT_RED		= Declare_Enum()	
	COLOR_BRIGHT_ORANGE		= Declare_Enum()
	COLOR_BRIGHT_YELLOW		= Declare_Enum()
	COLOR_BRIGHT_GREEN		= Declare_Enum()	
	COLOR_BRIGHT_CYAN		= Declare_Enum()	
	COLOR_BRIGHT_BLUE		= Declare_Enum()	
	COLOR_BRIGHT_PURPLE		= Declare_Enum()	
	COLOR_BRIGHT_GRAY		= Declare_Enum()
	COLOR_BRIGHT_GREY 		= COLOR_BRIGHT_GRAY
	
	COLOR_DARK_RED			= Declare_Enum()	
	COLOR_DARK_ORANGE		= Declare_Enum()
	COLOR_DARK_YELLOW		= Declare_Enum()
	COLOR_DARK_GREEN		= Declare_Enum()	
	COLOR_DARK_CYAN			= Declare_Enum()	
	COLOR_DARK_BLUE			= Declare_Enum()	
	COLOR_DARK_PURPLE		= Declare_Enum()	
	COLOR_DARK_GRAY			= Declare_Enum()
	COLOR_DARK_GREY 		= COLOR_DARK_GRAY

	COLOR_TOTAL				= Declare_Enum()

	PGCOLOR_WHITE_TRIPLE = {}
	PGCOLOR_WHITE_TRIPLE[PG_R] = 1.0
	PGCOLOR_WHITE_TRIPLE[PG_G] = 1.0
	PGCOLOR_WHITE_TRIPLE[PG_B] = 1.0
	PGCOLOR_WHITE_TRIPLE[PG_A] = 1.0
	
	PGCOLOR_BLACK_TRIPLE = {}
	PGCOLOR_BLACK_TRIPLE[PG_R] = 0.0
	PGCOLOR_BLACK_TRIPLE[PG_G] = 0.0
	PGCOLOR_BLACK_TRIPLE[PG_B] = 0.0
	PGCOLOR_BLACK_TRIPLE[PG_B] = 1.0

	-- Index lookup
	local index = 0;
	MP_COLORS_MIN = index
	MP_COLORS = {}
	MP_COLOR_INDICES = {}
	MP_COLORS[index] = COLOR_GRAY
	MP_COLOR_INDICES[COLOR_GRAY] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_BLUE
	MP_COLOR_INDICES[COLOR_BLUE] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_ORANGE
	MP_COLOR_INDICES[COLOR_ORANGE] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_YELLOW
	MP_COLOR_INDICES[COLOR_YELLOW] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_GREEN
	MP_COLOR_INDICES[COLOR_GREEN] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_CYAN
	MP_COLOR_INDICES[COLOR_CYAN] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_PURPLE
	MP_COLOR_INDICES[COLOR_PURPLE] = index
	index = index + 1;
	MP_COLORS[index] = COLOR_RED
	MP_COLOR_INDICES[COLOR_RED] = index
	NUM_MP_COLORS = index
	
	MP_DEFAULT_HOST_COLOR	= COLOR_BLUE
	MP_DEFAULT_GUEST_COLOR	= COLOR_RED

	-- Game Constant Labels
	MP_COLOR_LABEL_WHITE = "WHITE"
	MP_COLOR_LABEL_BLUE = "BLUE"
	MP_COLOR_LABEL_RED = "RED"
	MP_COLOR_LABEL_GREEN = "GREEN"
	MP_COLOR_LABEL_ORANGE = "ORANGE"
	MP_COLOR_LABEL_CYAN = "CYAN"
	MP_COLOR_LABEL_PURPLE = "PURPLE"
	MP_COLOR_LABEL_YELLOW = "YELLOW"
	MP_COLOR_LABEL_GRAY = "GRAY"
	MP_COLORS_LABEL_LOOKUP = {}
	MP_COLORS_LABEL_LOOKUP[COLOR_WHITE]		= MP_COLOR_LABEL_WHITE
	MP_COLORS_LABEL_LOOKUP[COLOR_BLUE] 		= MP_COLOR_LABEL_BLUE
	MP_COLORS_LABEL_LOOKUP[COLOR_RED] 		= MP_COLOR_LABEL_RED
	MP_COLORS_LABEL_LOOKUP[COLOR_GREEN] 	= MP_COLOR_LABEL_GREEN
	MP_COLORS_LABEL_LOOKUP[COLOR_ORANGE] 	= MP_COLOR_LABEL_ORANGE
	MP_COLORS_LABEL_LOOKUP[COLOR_CYAN] 		= MP_COLOR_LABEL_CYAN
	MP_COLORS_LABEL_LOOKUP[COLOR_PURPLE] 	= MP_COLOR_LABEL_PURPLE
	MP_COLORS_LABEL_LOOKUP[COLOR_YELLOW] 	= MP_COLOR_LABEL_YELLOW
	MP_COLORS_LABEL_LOOKUP[COLOR_GRAY] 		= MP_COLOR_LABEL_GRAY
	

	if (not TestValid(Net)) then
		Register_Net_Commands()
	end
	
	-- In-game unit coloring
	-- Cannot use Net != nil
	if (TestValid(Net)) then
		MP_COLOR_TRIPLES = Net.Get_MP_Color_Vector()
	else 
		MP_COLOR_TRIPLES = Create_Fallback_MP_Colors()
	end
	
	-- Chat window coloring (tweaked for visibility on a black background)
	if (TestValid(Net)) then
		MP_CHAT_COLOR_TRIPLES = Net.Get_MP_Chat_Color_Vector()
	else 
		MP_CHAT_COLOR_TRIPLES = Create_Fallback_MP_Colors()
	end
	-- Add the system message color
	MP_CHAT_COLOR_TRIPLES[MP_COLOR_LABEL_WHITE] = PGCOLOR_WHITE_TRIPLE
	

	-- Base Color RGBs
	PGCOLOR_BASE_COLORS = {}
	PGCOLOR_BASE_COLORS[COLOR_RED] 		= { [PG_R] = 1.0, [PG_G] = 0.0, [PG_B] = 0.0, [PG_A] = 1.0 }
	PGCOLOR_BASE_COLORS[COLOR_GREEN]	= { [PG_R] = 0.0, [PG_G] = 1.0, [PG_B] = 0.0, [PG_A] = 1.0 }
	PGCOLOR_BASE_COLORS[COLOR_BLUE]		= { [PG_R] = 0.0, [PG_G] = 0.0, [PG_B] = 1.0, [PG_A] = 1.0 }
	PGCOLOR_BASE_COLORS[COLOR_YELLOW]	= { [PG_R] = 1.0, [PG_G] = 1.0, [PG_B] = 0.0, [PG_A] = 1.0 }
	
	-- Render modes
	-- Mirrored from alprimtype.h
	ALPRIM_OPAQUE 					= Declare_Enum(0)
	ALPRIM_ADDITIVE 				= Declare_Enum()
	ALPRIM_ALPHA 					= Declare_Enum()
	ALPRIM_MODULATE 				= Declare_Enum()
	ALPRIM_DEPTHSPRITE_ADDITIVE 	= Declare_Enum()
	ALPRIM_DEPTHSPRITE_ALPHA 		= Declare_Enum()
	ALPRIM_DEPTHSPRITE_MODULATE 	= Declare_Enum()
	ALPRIM_DIFFUSE_ALPHA 			= Declare_Enum()
	ALPRIM_STENCIL_DARKEN 			= Declare_Enum()	
	ALPRIM_STENCIL_DARKEN_BLUR 		= Declare_Enum()
	ALPRIM_HEAT 					= Declare_Enum()
	ALPRIM_PARTICLE_BUMP_ALPHA 		= Declare_Enum()
	ALPRIM_DECAL_BUMP_ALPHA 		= Declare_Enum()
	ALPRIM_DECAL_PARALLAX_ALPHA 	= Declare_Enum()
	ALPRIM_ALPHA_SCANLINES 			= Declare_Enum()
	ALPRIM_SCREEN 					= Declare_Enum()
	ALPRIM_ALPHA_GRAYSCALE			= Declare_Enum()
	ALPRIM_OPAQUE_GRAYSCALE			= Declare_Enum()

	ALPRIM_COUNT 					= Declare_Enum()


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

	for i = 0, NUM_MP_COLORS do
		if (MP_COLORS[i] == color_index) then
			index = i
			break
		end
	end

	return index

end


function Create_Fallback_MP_Colors()

	local result = {}
	
	local triple = {}
	triple[PG_R] = 0.12
	triple[PG_G] = 0.12
	triple[PG_B] = 0.12
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_GRAY] = triple

	triple = {}
	triple[PG_R] = 0.31
	triple[PG_G] = 0.59
	triple[PG_B] = 1.0
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_BLUE] = triple

	triple = {}
	triple[PG_R] = 1.0
	triple[PG_G] = 0.58
	triple[PG_B] = 0.09
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_ORANGE] = triple

	triple = {}
	triple[PG_R] = 0.89
	triple[PG_G] = 0.87
	triple[PG_B] = 0.18
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_YELLOW] = triple

	triple = {}
	triple[PG_R] = 0.47
	triple[PG_G] = 1.0
	triple[PG_B] = 0.31
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_GREEN] = triple

	triple = {}
	triple[PG_R] = 0.44
	triple[PG_G] = 0.85
	triple[PG_B] = 0.88
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_CYAN] = triple

	triple = {}
	triple[PG_R] = 1.0
	triple[PG_G] = 0.44
	triple[PG_B] = 0.82
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_PURPLE] = triple

	triple = {}
	triple[PG_R] = 1.0
	triple[PG_G] = 0.09
	triple[PG_B] = 0.09
	triple[PG_A] = 1.0
	result[MP_COLOR_LABEL_RED] = triple
	
	return result
	
end
