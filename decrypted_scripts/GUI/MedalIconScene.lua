if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[109] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/MedalIconScene.lua 
--
--    Original Author: Maria Teruel
--
--          Date: 2007/07/20
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- ------------------------------------------------------------------------
--On_Init
-- ------------------------------------------------------------------------
function On_Init()
	Set_GUI_Variable("MouseOverStartTime", nil)
	Set_GUI_Variable("TextureSet", false)
	Set_GUI_Variable("TextureName", nil)
	Set_GUI_Variable("MedalTextID", nil)
	MOUSE_OVER_HOVER_TIME = 0.2
end


-- ------------------------------------------------------------------------
--On_Update
-- ------------------------------------------------------------------------
function On_Update()

	if not Get_GUI_Variable("TextureSet") and this.Get_User_Data() then
		local data = this.Get_User_Data()
		Set_GUI_Variable("TextureName", data[1])
		
		if #data >= 2 then
			Set_GUI_Variable("MedalTextID", data[2])
		end
		
		Set_Texture(data[1])
		Set_GUI_Variable("TextureSet", true)
	end

	-- is there a tooltip pending to be displayed!?
	local mouse_over_time = Get_GUI_Variable("MouseOverStartTime")
	if mouse_over_time ~= nil and GetCurrentTime() - mouse_over_time > MOUSE_OVER_HOVER_TIME then 
		-- display the tooltip
		this.Get_Containing_Scene().Raise_Event_Immediate("Display_Buff_Tooltip", this.Get_Containing_Component(), {})
		Set_GUI_Variable("MouseOverStartTime", nil)
	end
end

-- ------------------------------------------------------------------------
--Set_Texture
-- ------------------------------------------------------------------------
function Set_Texture(texture_name)
	this.MedalQuad.Set_Texture(texture_name)
end


-- ------------------------------------------------------------------------
--On_Mouse_Off
-- ------------------------------------------------------------------------
function On_Mouse_Off(_, _)
	-- if this icon has tooltip data assigned, end it
	this.Get_Containing_Scene().Raise_Event_Immediate("End_Buff_Tooltip", this.Get_Containing_Component(), {})
	-- reset the mouse over time!.
	Set_GUI_Variable("MouseOverStartTime", nil)
end


-- ------------------------------------------------------------------------
--On_Mouse_Over
-- ------------------------------------------------------------------------
function On_Mouse_Over(_, _)
	Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	
	-- if this icon has tooltip data assigned, dispkay its tooltip
	if Get_GUI_Variable("MedalTextID") then 
		-- Start countdown for tooltip display
		Set_GUI_Variable("MouseOverStartTime", GetCurrentTime())
	end
end


-- ------------------------------------------------------------------------
-- INTERFACE
-- ------------------------------------------------------------------------
Interface = {}
Interface.Set_Texture = Set_Texture
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
