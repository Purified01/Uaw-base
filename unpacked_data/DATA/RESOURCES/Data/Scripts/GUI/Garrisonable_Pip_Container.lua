-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Garrisonable_Pip_Container.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Garrisonable_Pip_Container.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: bret_ambrose $
--
--            $Change: 61315 $
--
--          $DateTime: 2007/01/23 14:35:47 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

ScriptPoolCount = 15

function On_Init()

	PipCount = 0
	FilledPips = 0
	Pips = {}
	
	if Object then
	
		local x, y, width, height = Garrisonable_Pip_Container.Get_Bounds()
		
		PipCount = Object.Get_Max_Garrisoned()

		if PipCount < 1 then
			return
		end
		
		for i = 1, PipCount do
			local pip = Garrisonable_Pip_Container.Create_Embedded_Scene( "Garrisonable_Pip", "Pip"..i )
			
			local pip_x, pip_y, pip_width, pip_height = pip.Get_Bounds()
			local pip_spacing = pip_width / 2
			local total_pip_width = PipCount * pip_width + ( PipCount - 1 ) * pip_spacing
			local final_x = ( 1 - total_pip_width ) / 2 + ( i - 1 ) * ( pip_width + pip_spacing ) 
			
			pip.Set_Bounds( final_x, 0, pip_width, pip_height )
			
			Pips[ i ] = pip
		end
	end
end

-- Wherever possible avoid calls to game (non-lua) functions here for efficiency reasons. 
function On_Update()

	local current_filled_pips = Object.Get_Current_Garrisoned()
	
	if current_filled_pips ~= FilledPips then
		FilledPips = current_filled_pips
		
		for i, pip_scene in pairs( Pips ) do
			if i <= FilledPips then
				pip_scene.Set_State( "Filled" )
			else
				pip_scene.Set_State( "Empty" )
			end
		end
	end
	
end

function Set_State( state_name )
	Garrisonable_Pip_Container.Set_State( state_name )
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_State = Set_State




