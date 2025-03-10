if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Old_Selectable_Icon.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Old_Selectable_Icon.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

function On_Init()

	Set_GUI_Variable("IsSelected", false)
	Set_GUI_Variable("Enabled", true)
	Set_GUI_Variable("InsufficientFundsOn", false)

	Selectable_Icon.Register_Event_Handler("Button_Clicked", Selectable_Icon, On_Click)
	
	-- some selectable icons will need to display a clock!
	Selectable_Icon.Clock.Set_Filled(0.0)
	Selectable_Icon.Text.Set_Text("")
	
end

function On_Rollover()
	if not Selectable_Icon.Get_Hidden() then
		Play_SFX_Event("GUI_Generic_Mouse_Over")
		
		-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
		local parent_scene = Selectable_Icon.Get_Containing_Scene()
		if parent_scene then
			parent_scene.Raise_Event("Mouse_Over_Selectable_Icon", Selectable_Icon.Get_Containing_Component(), nil)
		end
		
	end
end

function On_Pushed()
	if not Selectable_Icon.Get_Hidden() then
		Play_SFX_Event("GUI_Generic_Button_Select")
	end
end


function On_Right_Click()
	local parent_scene = Selectable_Icon.Get_Containing_Scene()
	if parent_scene then
		parent_scene.Raise_Event("Selectable_Icon_Right_Clicked", Selectable_Icon.Get_Containing_Component(), nil)
	end
end

function On_Click()
	local parent_scene = Selectable_Icon.Get_Containing_Scene()
	if parent_scene then
		parent_scene.Raise_Event("Selectable_Icon_Clicked", Selectable_Icon.Get_Containing_Component(), nil)
	end
end

function Set_Selected(selected)
	if Get_GUI_Variable("IsSelected") == selected then
		return
	end

	if Get_GUI_Variable("Enabled") == false then
		return
	end

	Set_GUI_Variable("IsSelected", selected)
	
	current_state = Selectable_Icon.Get_Current_State_Name()
	-- TODO: this is kinda cheesy...
	if selected then
		local new_state = string.gsub(current_state, "Unselected", "Selected")
		if new_state ~= current_state then
			Selectable_Icon.Set_State(new_state)
		end
	else
		local new_state = string.gsub(current_state, "Selected", "Unselected")
		if new_state ~= current_state then
			Selectable_Icon.Set_State(new_state)
		end
	end
end

function Is_Selected()
	return Get_GUI_Variable("IsSelected")
end

function Set_Enabled(enabled)
	if enabled == Get_GUI_Variable("Enabled") then
		return
	end

	Set_GUI_Variable("Enabled", enabled)

	if enabled then
		if Get_GUI_Variable("IsSelected") then
			Selectable_Icon.Set_State("Selected")
		else
			Selectable_Icon.Set_State("Unselected")
		end
	else
		Selectable_Icon.Set_State("Disabled")
	end
end

function Set_Texture(texture)
	Selectable_Icon.Icon.Set_Texture(texture)
end

function Set_Clock_Filled(filled_value)
	if Selectable_Icon.Clock.Get_Hidden() == true then
		Selectable_Icon.Clock.Set_Hidden(false)
	end
	
	Selectable_Icon.Clock.Set_Filled(filled_value)
end

function Get_Clock_Filled()
	Selectable_Icon.Clock.Get_Filled()
end

function Set_Text(text)
	if Selectable_Icon.Text.Get_Hidden() == true then
		Selectable_Icon.Text.Set_Hidden(false)
	end
	
	Selectable_Icon.Text.Set_Text(text)
end

function On_Mouse_Off_Selectable_Icon()

	-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
	local parent_scene = Selectable_Icon.Get_Containing_Scene()
	if parent_scene then
		parent_scene.Raise_Event("Mouse_Off_Selectable_Icon", Selectable_Icon.Get_Containing_Component(), nil)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Insufficient_Funds_Display
-- ------------------------------------------------------------------------------------------------------------------
function Set_Insufficient_Funds_Display(on_off)

	local ins_funds_on = Get_GUI_Variable("InsufficientFundsOn")
	if ins_funds_on == on_off then 
		-- do nothing
		return
	end
	
	-- We have to change the display font (and LATER put up the redish layer!.)
	if on_off == true then 
		Selectable_Icon.Text.Set_Font("Command_Center_Cost_Red")
	else
		Selectable_Icon.Text.Set_Font("Command_Center_Cost")
	end
	
	Set_GUI_Variable("InsufficientFundsOn", on_off)
end

function Set_Cost(cost)
	Selectable_Icon.Text.Set_Text("$"..cost)
end

function Clear_Cost()
	Selectable_Icon.Text.Set_Text("")
end


Interface = {}
Interface.Set_Texture = Set_Texture
Interface.Set_Selected = Set_Selected
Interface.Set_Button_Enabled = Set_Enabled
Interface.Is_Selected = Is_Selected
Interface.Is_Button_Enabled = Is_Enabled
Interface.Set_Clock_Filled = Set_Clock_Filled
Interface.Get_Clock_Filled = Get_Clock_Filled
Interface.Set_Text = Set_Text
Interface.Set_Insufficient_Funds_Display = Set_Insufficient_Funds_Display
Interface.Set_Cost = Set_Cost
Interface.Clear_Cost = Clear_Cost
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
