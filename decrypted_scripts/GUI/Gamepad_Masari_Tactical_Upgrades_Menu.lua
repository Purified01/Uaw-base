LUA_PREP = true

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

require("Gamepad_Tactical_Upgrades_Menu")

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Faction_Display()
	Initialize_DMA_Bar_Display()
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
	
	if Object.Has_Behavior(39) == true and this.DMABar.Get_Hidden() == false then 
		this.DMABar.Set_Hidden(true)
		return 
	end
		
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


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
