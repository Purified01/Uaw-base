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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Masari_Selectable_Icon.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
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
	Get_Chat_Color_Index = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGColors_Init = nil
	Remove_Invalid_Objects = nil
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
