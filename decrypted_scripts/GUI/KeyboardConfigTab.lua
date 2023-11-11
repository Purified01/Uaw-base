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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/KeyboardConfigTab.lua
--
--             Author: Maria Teruel
--
--          Date: 2007/04/05
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Set_GUI_Variable("IsSelected", false)
	Set_GUI_Variable("Enabled", true)
	
	this.Register_Event_Handler("Mouse_Left_Up", Scene, On_Click)
	this.Register_Event_Handler("Mouse_On", Scene, On_Mouse_Over)
	this.Register_Event_Handler("Mouse_Left_Down", Scene, On_Mouse_Button_Down)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over
-- ------------------------------------------------------------------------------------------------------------------
function On_Mouse_Over(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Button_Down
-- ------------------------------------------------------------------------------------------------------------------
function On_Mouse_Button_Down(event, source)
	if TestValid(this) and this.Get_Hidden() == false and this.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_State_Change
-- Called directly by the scene.
-- ------------------------------------------------------------------------------------------------------------------
function On_State_Change()
	local name = Scene.Get_Current_State_Name()
	if name == "Unselected" then
		Scene.notselected_notover_notclicked.Set_Hidden(false)
		Scene.notselected_over_notclicked.Set_Hidden(true)
		Scene.notselected_over_clicked.Set_Hidden(true)
		Scene.selected_notover_notclicked.Set_Hidden(true)
		Scene.selected_over_notclicked.Set_Hidden(true)
		Scene.selected_over_clicked.Set_Hidden(true)
		Scene.Disabled.Set_Hidden(true)
	elseif name == "Unselected_Over" then
		Scene.notselected_notover_notclicked.Set_Hidden(true)
		Scene.notselected_over_notclicked.Set_Hidden(false)
		Scene.notselected_over_clicked.Set_Hidden(true)
		Scene.selected_notover_notclicked.Set_Hidden(true)
		Scene.selected_over_notclicked.Set_Hidden(true)
		Scene.selected_over_clicked.Set_Hidden(true)
		Scene.Disabled.Set_Hidden(true)
	elseif name == "Unselected_Clicked" or name == "Unselected_Over_Clicked" then
		Scene.notselected_notover_notclicked.Set_Hidden(true)
		Scene.notselected_over_notclicked.Set_Hidden(true)
		Scene.notselected_over_clicked.Set_Hidden(false)
		Scene.selected_notover_notclicked.Set_Hidden(true)
		Scene.selected_over_notclicked.Set_Hidden(true)
		Scene.selected_over_clicked.Set_Hidden(true)
		Scene.Disabled.Set_Hidden(true)
	elseif name == "Selected" then
		Scene.notselected_notover_notclicked.Set_Hidden(true)
		Scene.notselected_over_notclicked.Set_Hidden(true)
		Scene.notselected_over_clicked.Set_Hidden(true)
		Scene.selected_notover_notclicked.Set_Hidden(false)
		Scene.selected_over_notclicked.Set_Hidden(true)
		Scene.selected_over_clicked.Set_Hidden(true)
		Scene.Disabled.Set_Hidden(true)
	elseif name == "Selected_Over" then
		Scene.notselected_notover_notclicked.Set_Hidden(true)
		Scene.notselected_over_notclicked.Set_Hidden(true)
		Scene.notselected_over_clicked.Set_Hidden(true)
		Scene.selected_notover_notclicked.Set_Hidden(true)
		Scene.selected_over_notclicked.Set_Hidden(false)
		Scene.selected_over_clicked.Set_Hidden(true)
		Scene.Disabled.Set_Hidden(true)
	elseif name == "Selected_Clicked" or name == "Selected_Over_Clicked" then
		Scene.notselected_notover_notclicked.Set_Hidden(true)
		Scene.notselected_over_notclicked.Set_Hidden(true)
		Scene.notselected_over_clicked.Set_Hidden(true)
		Scene.selected_notover_notclicked.Set_Hidden(true)
		Scene.selected_over_notclicked.Set_Hidden(true)
		Scene.selected_over_clicked.Set_Hidden(false)
		Scene.Disabled.Set_Hidden(true)
	elseif name == "Disabled" then
		Scene.notselected_notover_notclicked.Set_Hidden(true)
		Scene.notselected_over_notclicked.Set_Hidden(true)
		Scene.notselected_over_clicked.Set_Hidden(true)
		Scene.selected_notover_notclicked.Set_Hidden(true)
		Scene.selected_over_notclicked.Set_Hidden(true)
		Scene.selected_over_clicked.Set_Hidden(true)
		Scene.Disabled.Set_Hidden(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Click
-- ------------------------------------------------------------------------------------------------------------------
function On_Click()
	Raise_Event_Immediate_All_Parents("Tab_Clicked", Scene.Get_Containing_Component(), Scene, nil)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Selected
-- ------------------------------------------------------------------------------------------------------------------
function Set_Selected(selected)
	if Is_Selected() == selected then
		return
	end

	if Is_Enabled() == false then
		return
	end

	Set_GUI_Variable("IsSelected", selected)
	
	local current_state = Scene.Get_Current_State_Name()
	-- TODO: this is kinda cheesy...
	if selected then
		local new_state = string.gsub(current_state, "Unselected", "Selected")
		if new_state ~= current_state then
			Scene.Set_State(new_state)
		end
	else
		local new_state = string.gsub(current_state, "Selected", "Unselected")
		if new_state ~= current_state then
			Scene.Set_State(new_state)
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Selected
-- ------------------------------------------------------------------------------------------------------------------
function Is_Selected()
	return Get_GUI_Variable("IsSelected")
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Enabled
-- ------------------------------------------------------------------------------------------------------------------
function Set_Enabled(enabled)
	if enabled == Is_Enabled() then
		return
	else
		Set_GUI_Variable("Enabled", enabled)
	end

	if enabled then
		if Is_Selected() then
			Scene.Set_State("Selected")
		else
			Scene.Set_State("Unselected")
		end
	else
		Scene.Set_State("Disabled")
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Texture
-- ------------------------------------------------------------------------------------------------------------------
function Set_Texture(texture)
	Scene.Icon.Set_Texture(texture)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Text
-- ------------------------------------------------------------------------------------------------------------------
function Set_Text(text)
	if this.Text.Get_Hidden() == true then
		this.Text.Set_Hidden(false)
	end
	
	this.Text.Set_Text(text)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Enabled
-- ------------------------------------------------------------------------------------------------------------------
function Is_Enabled()
	return Get_GUI_Variable("Enabled")
end



Interface = {}
Interface.Set_Texture = Set_Texture
Interface.Set_Selected = Set_Selected
Interface.Set_Enabled = Set_Enabled
Interface.Is_Selected = Is_Selected
Interface.Is_Enabled = Is_Enabled
Interface.Set_Text = Set_Text