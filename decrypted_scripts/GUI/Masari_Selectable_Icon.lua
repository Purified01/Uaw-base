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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Masari_Selectable_Icon.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 71509 $
--
--          $DateTime: 2007/05/29 13:25:52 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("Selectable_Icon")

-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	Initialize_Selectable_Icon()
	-- Oksana: need for DMA display
	Initialize_DMA_Bar()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_DMA_Bar
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_DMA_Bar()
	if not TestValid(Scene.Group.DMAQuad) then return end
	DMABar_X, DMABar_Y, DMABar_Width, DMABar_Height = Scene.Group.DMAQuad.Get_Bounds()
	Set_GUI_Variable("DMABar_X", DMABar_X)
	Set_GUI_Variable("DMABar_Y", DMABar_Y)
	Set_GUI_Variable("DMABar_Width", DMABar_Width)
	Set_GUI_Variable("DMABar_Height", DMABar_Height)
	Set_GUI_Variable("DMABar_OrigWidth", DMABar_Width)
	
	Hide_DMA_Bar(true)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hide_DMA_Bar
-- ------------------------------------------------------------------------------------------------------------------
function Hide_DMA_Bar( should_hide )
	if TestValid(Scene.Group.DMABGQuad) then
		Scene.Group.DMABGQuad.Set_Hidden(should_hide)
	end
	
	if TestValid(Scene.Group.DMAQuad) then
		Scene.Group.DMAQuad.Set_Hidden(should_hide)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_DMA_Percent
-- ------------------------------------------------------------------------------------------------------------------
function Set_DMA_Percent( DMA_percent )

	--Show the bar at proper percent		
	local width = Get_GUI_Variable("DMABar_OrigWidth") * DMA_percent
	Set_GUI_Variable("DMABar_Width", width)
	Scene.Group.DMAQuad.Set_Bounds(Get_GUI_Variable("DMABar_X"), 
							Get_GUI_Variable("DMABar_Y"),
							Get_GUI_Variable("DMABar_Width"), 
							Get_GUI_Variable("DMABar_Height"))
end



-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
-- Interface = {} DO NOT ADD THIS LINE BECAUSE THIS SELECTABLE ICON IS DERIVED FROM
-- THE BASE SELECTABLE ICON AND WE WANT TO ADD TO ITS INTERFACE TABLE!!!!!!.
Interface.Hide_DMA_Bar = Hide_DMA_Bar
Interface.Set_DMA_Percent = Set_DMA_Percent
