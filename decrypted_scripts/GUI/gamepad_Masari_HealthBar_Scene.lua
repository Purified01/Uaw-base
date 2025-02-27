LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Masari_HealthBar_Scene.lua#4 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Masari_HealthBar_Scene.lua $
--
--    Original Author: Chris Brooks
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

require("gamepad_HealthBar_Scene")

-- =====================================================================================
function Initialize_DMA_Bar()
	if not TestValid(this.DMAQuad) then return end
	DMABar_X, DMABar_Y, DMABar_Width, DMABar_Height = this.DMAQuad.Get_Bounds()
	Set_GUI_Variable("DMABar_X", DMABar_X)
	Set_GUI_Variable("DMABar_Y", DMABar_Y)
	Set_GUI_Variable("DMABar_Width", DMABar_Width)
	Set_GUI_Variable("DMABar_Height", DMABar_Height)
	Set_GUI_Variable("DMABar_OrigWidth", DMABar_Width)
	
	this.DMAQuad.Set_Hidden(true)
	if TestValid(this.DMABGQuad) then
		this.DMABGQuad.Set_Hidden(true)
	end	
end

-- =====================================================================================
function Update_DMA_Bar()
	if not TestValid(this.DMABGQuad) then return end
	
	local DMA_percent = 0.0
	local should_hide = true
	
	--if Is_Player_Of_Faction(Object.Get_Owner(), "MASARI") then
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
	--end -- if masari
	
	--Display or hide the bar
	this.DMAQuad.Set_Hidden(should_hide)
	if TestValid(this.DMABGQuad) then
		this.DMABGQuad.Set_Hidden(should_hide)
	end

	if not should_hide then
		--Show the bar at proper percent		
		local width = Get_GUI_Variable("DMABar_OrigWidth") * DMA_percent
		Set_GUI_Variable("DMABar_Width", width)
		Scene.DMAQuad.Set_Bounds(	Get_GUI_Variable("DMABar_X"), 
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
