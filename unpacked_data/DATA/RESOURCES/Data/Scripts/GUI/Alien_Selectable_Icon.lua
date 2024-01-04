-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Alien_Selectable_Icon.lua#19 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Alien_Selectable_Icon.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 72168 $
--
--          $DateTime: 2007/06/05 11:38:01 $
--
--          $Revision: #19 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("Selectable_Icon")

-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	Initialize_Selectable_Icon()
	-- Used for the blueprints button menu
	Scene.Group.MarkerQuad.Set_Hidden(true)
	Scene.Group.Play_Animation("Zoom_Out", false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Marker_Texture(texture)
	
	if Scene.Group.MarkerQuad.Get_Hidden() == true then
		Scene.Group.MarkerQuad.Set_Hidden(false)
	end
	
	Scene.Group.MarkerQuad.Set_Texture(texture)
end

-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Marker(onoff)
	Scene.Group.MarkerQuad.Set_Hidden(onoff)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
-- Interface = {} DO NOT ADD THIS LINE BECAUSE THIS SELECTABLE ICON IS DERIVED FROM
-- THE BASE SELECTABLE ICON AND WE WANT TO ADD TO ITS INTERFACE TABLE!!!!!!.
Interface.Set_Marker_Texture = Set_Marker_Texture
Interface.Hide_Marker = Hide_Marker
