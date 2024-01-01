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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Masari_Tactical_Upgrades_Menu.lua
--
--    Original Author: Maria Teruel
--
--          DateTime: 2007/06/07
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("Tactical_Upgrades_Menu")

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Faction_Display()
	Initialize_DMA_Bar_Display()
	Set_GUI_Variable("ControlGroupDisplayYOffset", 0.35)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_DMA_Bar_Display
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_DMA_Bar_Display()
	if not TestValid(this.DMABar) then return end
	
	DMABar_X, DMABar_Y, DMABar_Width, DMABar_Height = this.DMABar.Quad.Get_Bounds()
	Set_GUI_Variable("DMABar_X", DMABar_X)
	Set_GUI_Variable("DMABar_Y", DMABar_Y)
	Set_GUI_Variable("DMABar_Width", DMABar_Width)
	Set_GUI_Variable("DMABar_Height", DMABar_Height)
	Set_GUI_Variable("DMABar_OrigWidth", DMABar_Width)
	
	this.DMABar.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Display()
	Update_DMA_Display()
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_DMA_Display -- MOVE TO MASARI SPECIFIC FILE!
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_DMA_Display()

	if not TestValid(this.DMABar) then return end
	if not TestValid(Object) then return end
	
	if Object.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) == true and this.DMABar.Get_Hidden() == false then 
		this.DMABar.Set_Hidden(true)
		return 
	end
	
	if not Is_Player_Of_Faction(Object.Get_Owner(), "MASARI") then return end
	
	local DMA_percent = 0.0
	local should_hide = true
	
	if StringCompare( Object.Get_Owner().Get_Elemental_Mode(), "Ice" ) then
		
		-- Ok, we are masari and we are in Dark mode. We should display our DMA bar.		
		should_hide = false;
		local current_dma_level = Object.Get_Attribute_Value( "Current_DMA_Level" )
		local max_dma_level = Object.Get_Attribute_Value( "DMA_Max" )
		if max_dma_level and current_dma_level and max_dma_level ~= 0 then
			DMA_percent = current_dma_level / max_dma_level
		end
				
		-- If we don't have any more DMA left and we don't have regen, hide the bar.
		if DMA_percent <= 0.0 and Object.Is_Category("Stationary") and Object.Get_Owner().Is_Generator_Locked("DMAStructureRegenGenerator") then
			should_hide = true;
		end
		
	end -- if ice
	
	this.DMABar.Set_Hidden(should_hide)
	
	if not should_hide then
		--Show the bar at proper percent		
		local width = Get_GUI_Variable("DMABar_OrigWidth") * DMA_percent
		Set_GUI_Variable("DMABar_Width", width)
		this.DMABar.Quad.Set_Bounds(Get_GUI_Variable("DMABar_X"), 
								Get_GUI_Variable("DMABar_Y"),
								Get_GUI_Variable("DMABar_Width"), 
								Get_GUI_Variable("DMABar_Height"))
	end
end


