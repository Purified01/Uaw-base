-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Selectable_Icon.lua#44 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Selectable_Icon.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 90441 $
--
--          $DateTime: 2008/01/07 17:22:16 $
--
--          $Revision: #44 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGColors")


function On_Init()
	Initialize_Selectable_Icon()
end

function Initialize_Selectable_Icon()
		
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Set_GUI_Variable("IsSelected", false)
	Set_GUI_Variable("Enabled", true)
	Set_GUI_Variable("FlashDuration", 0.0)
	Set_GUI_Variable("FlashStartTime", 0.0)
	
	Scene.Group.health_bar.Set_Hidden(true)
	local healthX, healthY, healthWidth, healthHeight = Scene.Group.health_bar.Get_Bounds()
	local healthOrigWidth = healthWidth
	
	Set_GUI_Variable("HealthOrigWidth", healthOrigWidth)
	Set_GUI_Variable("HealthX", healthX)
	Set_GUI_Variable("HealthY", healthY)
	Set_GUI_Variable("HealthWidth", healthWidth)
	Set_GUI_Variable("HealthHeight", healthHeight)
	
	-- Colors for the health bar
	-- NOTE: we don't set them with Set_GUI_Variable since they are static
	COLOR_HEALTH_GOOD = { }
	COLOR_HEALTH_MEDIUM = { }
	COLOR_HEALTH_LOW = { }
	
	COLOR_HEALTH_GOOD.R = 0.125
	COLOR_HEALTH_GOOD.G = 1.0
	COLOR_HEALTH_GOOD.B = 0.125
	COLOR_HEALTH_GOOD.A = 1.0

	COLOR_HEALTH_MEDIUM.R = 1.0
	COLOR_HEALTH_MEDIUM.G = 1.0
	COLOR_HEALTH_MEDIUM.B = 0.125
	COLOR_HEALTH_MEDIUM.A = 1.0

	COLOR_HEALTH_LOW.R = 1.0
	COLOR_HEALTH_LOW.G = 0.125
	COLOR_HEALTH_LOW.B = 0.125
	COLOR_HEALTH_LOW.A = 1.0
	
	Scene.Register_Event_Handler("Mouse_Left_Up", Scene, On_Click)
	Scene.Register_Event_Handler("Mouse_Right_Up", Scene, On_Right_Click)
	Scene.Register_Event_Handler("Mouse_Left_Double_Click", Scene, On_Double_Click)
	Scene.Register_Event_Handler("Mouse_Right_Double_Click", Scene, On_Right_Double_Click)
	Scene.Register_Event_Handler("Animation_Finished", Scene, On_Animation_Finished)
	
	
	Scene.Register_Event_Handler("Mouse_Left_Down", Scene.Group.Disabled, On_Disabled_Pushed)
	
	-- TODO: register to get called when anim finishes
	-- some selectable icons will need to display a clock!
	Scene.Group.Clock.Set_Filled(0.0)
	Scene.Group.Icon.Set_Hidden(false)
	
	if TestValid(Scene.Group.UpperText) then
		Scene.Group.UpperText.Set_Hidden(false)
		Scene.Group.UpperText.Set_Text("")
	end	
	if TestValid(Scene.Group.LowerText) then
		Scene.Group.LowerText.Set_Hidden(false)
		Scene.Group.LowerText.Set_Text("")
	end
	
	-- needed for tooltip display
	-- -----------------------------------------------------
	MouseOverSceneHoverTime = 0.3
	Set_GUI_Variable("MouseOverSceneTime", nil)
	-- -----------------------------------------------------	
	
	if TestValid(Scene.Group) and TestValid(Scene.Group.FocusQuad) then
		Scene.Group.FocusQuad.Set_Hidden(true)
	elseif TestValid(Scene.FocusQuad) then 
		Scene.FocusQuad.Set_Hidden(true)
	end
	
	this.Register_Event_Handler("Key_Focus_Lost", this, On_Focus_Lost)
	this.Register_Event_Handler("Key_Focus_Gained", this, On_Focus_Gained)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Focus_Lost - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Lost()
	if not Is_Controller_Event() then return end
	Set_Focus(false)
	this.Get_Containing_Scene().Raise_Event_Immediate("Focus_Lost", this.Get_Containing_Component(), {})
	-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
	Raise_Event_All_Parents("Mouse_Off_Selectable_Icon", this.Get_Containing_Component(), this, nil)
	
	if this.Is_Animating("Focus_Gained") then
		this.Stop_Animation()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Focus_Gained - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Gained()
	if not Is_Controller_Event() then return end
	Set_Focus(true)
	this.Get_Containing_Scene().Raise_Event_Immediate("Focus_Gained", this.Get_Containing_Component(), {})
	-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
	Raise_Event_All_Parents("Mouse_Over_Selectable_Icon", this.Get_Containing_Component(), this, nil)
	
	-- enlarge the icon
	this.Play_Animation("Focus_Gained", false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Focus - Update the focus state for this scene
-- ------------------------------------------------------------------------------------------------------------------
function Set_Focus(on_off)
	if TestValid(Scene.Group) and TestValid(Scene.Group.FocusQuad) then 
		Scene.Group.FocusQuad.Set_Hidden(not on_off)
	elseif TestValid(Scene.FocusQuad) then
		Scene.FocusQuad.Set_Hidden(not on_off)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_State_Change - Called directly by the scene.
-- ------------------------------------------------------------------------------------------------------------------
function On_State_Change()
	local name = Scene.Get_Current_State_Name()
	if not ColorsInitialized then
		PGColors_Init_Constants()
		ColorsInitialized = true
	end
	
	if name == "Unselected" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(false)
		Scene.Group.notselected_over_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_clicked.Set_Hidden(true)
		Scene.Group.selected_notover_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_clicked.Set_Hidden(true)
		Scene.Group.Disabled.Set_Hidden(true)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA)
	elseif name == "Unselected_Over" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_notclicked.Set_Hidden(false)
		Scene.Group.notselected_over_clicked.Set_Hidden(true)
		Scene.Group.selected_notover_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_clicked.Set_Hidden(true)
		Scene.Group.Disabled.Set_Hidden(true)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA)
	elseif name == "Unselected_Clicked" or name == "Unselected_Over_Clicked" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_clicked.Set_Hidden(false)
		Scene.Group.selected_notover_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_clicked.Set_Hidden(true)
		Scene.Group.Disabled.Set_Hidden(true)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA)
	elseif name == "Selected" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_clicked.Set_Hidden(true)
		Scene.Group.selected_notover_notclicked.Set_Hidden(false)
		Scene.Group.selected_over_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_clicked.Set_Hidden(true)
		Scene.Group.Disabled.Set_Hidden(true)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA)
	elseif name == "Selected_Over" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_clicked.Set_Hidden(true)
		Scene.Group.selected_notover_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_notclicked.Set_Hidden(false)
		Scene.Group.selected_over_clicked.Set_Hidden(true)
		Scene.Group.Disabled.Set_Hidden(true)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA)
	elseif name == "Selected_Clicked" or name == "Selected_Over_Clicked" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_clicked.Set_Hidden(true)
		Scene.Group.selected_notover_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_clicked.Set_Hidden(false)
		Scene.Group.Disabled.Set_Hidden(true)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA)
	elseif name == "Disabled" then
		Scene.Group.notselected_notover_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_notclicked.Set_Hidden(true)
		Scene.Group.notselected_over_clicked.Set_Hidden(true)
		Scene.Group.selected_notover_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_notclicked.Set_Hidden(true)
		Scene.Group.selected_over_clicked.Set_Hidden(true)
		Scene.Group.Disabled.Set_Hidden(false)
		if TestValid(Scene.Group.Backdrop) then
			Scene.Group.Backdrop.Set_Render_Mode(ALPRIM_ALPHA_GRAYSCALE)
		end
		Scene.Group.Icon.Set_Render_Mode(ALPRIM_ALPHA_GRAYSCALE)
	end
end


-- ----------------------------------------------------------------------------------------------
-- On_Animation_Finished
-- ----------------------------------------------------------------------------------------------
function On_Animation_Finished()
	Raise_Event_All_Parents("Selectable_Icon_Animation_Finished", Scene.Get_Containing_Component(), Scene, nil)
end


-- ----------------------------------------------------------------------------------------------
-- On_Disabled_Pushed
-- ----------------------------------------------------------------------------------------------
function On_Disabled_Pushed()
	if not Scene.Get_Hidden() then
		Play_SFX_Event("GUI_Generic_Bad_Sound")
	end
end


-- ----------------------------------------------------------------------------------------------
-- On_Pushed
-- ----------------------------------------------------------------------------------------------
function On_Pushed()
	-- Maria 01.07.2007
	-- Per task request, we don't want the SFX to play on button down but only on button up to 
	-- let the player know that an action has taken place.
	--if not Scene.Get_Hidden() then
	--	Play_SFX_Event("GUI_Generic_Button_Select")
	--end
end

-- ----------------------------------------------------------------------------------------------
-- On_Click
-- ----------------------------------------------------------------------------------------------
function On_Click()
	
	if not Scene.Get_Hidden() then
		Play_SFX_Event("GUI_Generic_Button_Select")
	end
	
	Raise_Event_Immediate_All_Parents("Selectable_Icon_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	End_Tooltip()
end


-- ----------------------------------------------------------------------------------------------
-- On_Double_Click
-- ----------------------------------------------------------------------------------------------
function On_Double_Click()
	Raise_Event_Immediate_All_Parents("Selectable_Icon_Double_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	End_Tooltip()
end

-- ----------------------------------------------------------------------------------------------
-- On_Right_Click
-- ----------------------------------------------------------------------------------------------
function On_Right_Click()
	if not Scene.Get_Hidden() then
		Play_SFX_Event("GUI_Generic_Button_Select")
	end
	
	Raise_Event_Immediate_All_Parents("Selectable_Icon_Right_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	End_Tooltip()
end

-- ----------------------------------------------------------------------------------------------
-- On_Right_Double_Click
-- ----------------------------------------------------------------------------------------------
function On_Right_Double_Click()
	Raise_Event_Immediate_All_Parents("Selectable_Icon_Right_Double_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	End_Tooltip()
end

-- ----------------------------------------------------------------------------------------------
-- End_Tooltip
-- ----------------------------------------------------------------------------------------------
function End_Tooltip()
	-- if this icon has tooltip data assigned, end it
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, {})
	-- reset the mouse over time!.
	Set_GUI_Variable("MouseOverSceneTime", nil)
end


-- ----------------------------------------------------------------------------------------------
-- Set_Selected
-- ----------------------------------------------------------------------------------------------
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


-- ----------------------------------------------------------------------------------------------
-- Is_Selected
-- ----------------------------------------------------------------------------------------------
function Is_Selected()
	return Get_GUI_Variable("IsSelected")
end


-- ----------------------------------------------------------------------------------------------
-- Set_Enabled
-- ----------------------------------------------------------------------------------------------
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


-- ----------------------------------------------------------------------------------------------
-- Set_Texture
-- ----------------------------------------------------------------------------------------------
function Set_Texture(texture)
	Scene.Group.Icon.Set_Texture(texture)
end


-- ----------------------------------------------------------------------------------------------
-- Set_Clock_Filled
-- ----------------------------------------------------------------------------------------------
function Set_Clock_Filled(filled_value)
	if Scene.Group.Clock.Get_Hidden() == true then
		Scene.Group.Clock.Set_Hidden(false)
	end
	
	Scene.Group.Clock.Set_Filled(filled_value)
end


-- ----------------------------------------------------------------------------------------------
-- Set_Clock_Tint
-- ----------------------------------------------------------------------------------------------
function Set_Clock_Tint(rgba_table)
	if rgba_table == nil then
		return
	end
	if Scene.Group.Clock.Get_Hidden() == true then
		Scene.Group.Clock.Set_Hidden(false)
	end
	
	Scene.Group.Clock.Set_Tint(rgba_table[1], rgba_table[2], rgba_table[3], rgba_table[4])
end


-- ----------------------------------------------------------------------------------------------
-- Get_Clock_Filled
-- ----------------------------------------------------------------------------------------------
function Get_Clock_Filled()
	return Scene.Group.Clock.Get_Filled()
end


-- ----------------------------------------------------------------------------------------------
-- Set_Text
-- ----------------------------------------------------------------------------------------------
function Set_Text(text)
	if Scene.Group.UpperText.Get_Hidden() == true then
		Scene.Group.UpperText.Set_Hidden(false)
	end
	
	Scene.Group.UpperText.Set_Text(text)
end


-- ----------------------------------------------------------------------------------------------
-- On_Update
-- ----------------------------------------------------------------------------------------------
function On_Update()
	if not Scene.Get_Hidden() then
		-- is there a tooltip pending to be displayed!?
		local mouse_over_time = Get_GUI_Variable("MouseOverSceneTime")
		if mouse_over_time ~= nil and GetCurrentTime() - mouse_over_time > MouseOverSceneHoverTime then 
			-- display the tooltip
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {Scene.Get_Containing_Component().Get_Tooltip_Data()})
			Set_GUI_Variable("MouseOverSceneTime", nil)
		end
	end
end


-- ----------------------------------------------------------------------------------------------
-- On_Rollover
-- ----------------------------------------------------------------------------------------------
function On_Rollover()
	if not Scene.Get_Hidden() then
		Play_SFX_Event("GUI_Generic_Mouse_Over")
		
		-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
		Raise_Event_All_Parents("Mouse_Over_Selectable_Icon", Scene.Get_Containing_Component(), Scene, nil)
		
		-- if this icon has tooltip data assigned, dispkay its tooltip
		if  Scene.Get_Containing_Component().Get_Tooltip_Data() then 
			-- Start countdown for tooltip display
			Set_GUI_Variable("MouseOverSceneTime", GetCurrentTime())
		end
	end
end



-- ----------------------------------------------------------------------------------------------
-- On_Mouse_Off_Selectable_Icon
-- ----------------------------------------------------------------------------------------------
function On_Mouse_Off_Selectable_Icon()
	-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
	Raise_Event_All_Parents("Mouse_Off_Selectable_Icon", Scene.Get_Containing_Component(), Scene, nil)
	End_Tooltip()
end



-- ----------------------------------------------------------------------------------------------
-- Start_Icon_Flash
-- ----------------------------------------------------------------------------------------------
function Start_Icon_Flash()
	Start_Flash(Scene)
end


-- ----------------------------------------------------------------------------------------------
-- Stop_Icon_Flash
-- ----------------------------------------------------------------------------------------------
function Stop_Icon_Flash()
	Stop_Flash(Scene)
end


-- ----------------------------------------------------------------------------------------------
-- Icon_Is_Flashing
-- ----------------------------------------------------------------------------------------------
function Icon_Is_Flashing()
	return Is_Flashing(Scene)
end



-- ----------------------------------------------------------------------------------------------
-- Set_Cost
-- ----------------------------------------------------------------------------------------------
function Set_Cost(build_cost)
	Scene.Group.LowerText.Set_Text(Get_Localized_Formatted_Number(build_cost))
end



-- ----------------------------------------------------------------------------------------------
-- Clear_Cost
-- ----------------------------------------------------------------------------------------------
function Clear_Cost()
	Scene.Group.LowerText.Set_Text("")
end


-- ----------------------------------------------------------------------------------------------
-- Set_Percentage
-- ----------------------------------------------------------------------------------------------
function Set_Percentage(percent)
	if Scene.Group.LowerText.Get_Hidden() == true then
		Scene.Group.LowerText.Set_Hidden(false)
	end
	
	if percent ~= 0 then
		local wstr_percent = Get_Game_Text("TEXT_PERCENT")
		Replace_Token(wstr_percent, Get_Localized_Formatted_Number(percent),0)
		Scene.Group.LowerText.Set_Text(wstr_percent)
	else	
		Scene.Group.LowerText.Set_Text("")	
	end
end


-- ----------------------------------------------------------------------------------------------
-- Set_Clockwise
-- ----------------------------------------------------------------------------------------------
function Set_Clockwise(onoff)
	Scene.Group.Clock.Set_Clockwise(onoff)
end


-- ----------------------------------------------------------------------------------------------
-- Is_Enabled
-- ----------------------------------------------------------------------------------------------
function Is_Enabled()
	return Get_GUI_Variable("Enabled")
end


-- ----------------------------------------------------------------------------------------------
-- Show_Queue_Buy_Line
-- ----------------------------------------------------------------------------------------------
function Show_Queue_Buy_Line(show)
	if TestValid(Scene.queue_buy_line) then
		Scene.queue_buy_line.Set_Hidden(not show)
	elseif TestValid(Scene.Group) and TestValid(Scene.Group.queue_buy_line) then
		Scene.Group.queue_buy_line.Set_Hidden(not show)
	end
end

-- ----------------------------------------------------------------------------------------------
-- Show_Queue_Line
-- ----------------------------------------------------------------------------------------------
function Show_Queue_Line(show)
	if TestValid(Scene.queue_line) then
		Scene.queue_line.Set_Hidden(not show)
	elseif TestValid(Scene.Group) and TestValid(Scene.Group.queue_line) then
		Scene.Group.queue_line.Set_Hidden(not show)
	end
end


-- ----------------------------------------------------------------------------------------------
-- Set_Lower_Text
-- ----------------------------------------------------------------------------------------------
function Set_Lower_Text(text)
	Scene.Group.LowerText.Set_Text(text)
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
		Scene.Group.LowerText.Set_Font("Cost_Red")
	else
		Scene.Group.LowerText.Set_Font("Cost_Green")
	end
	
	Set_GUI_Variable("InsufficientFundsOn", on_off)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Health
-- ------------------------------------------------------------------------------------------------------------------
function Set_Health(health_percent)

	-- just hide the bar if we have zero health.
	if health_percent <= 0 then 
		Scene.Group.health_bar.Set_Hidden(true)
		return
	end
	
	if Scene.Group.health_bar.Get_Hidden() == true then
		Scene.Group.health_bar.Set_Hidden(false)
	end
	
	if not health_percent then health_percent = 0.0 end

	local orig_w = Get_GUI_Variable("HealthOrigWidth")
	local x = Get_GUI_Variable("HealthX")
	local y = Get_GUI_Variable("HealthY")
	local w = Get_GUI_Variable("HealthWidth")
	local h = Get_GUI_Variable("HealthHeight")
	
	-- update the width of the bar according to the health percent.
	w = orig_w * health_percent
	Scene.Group.health_bar.Set_Bounds(x, y, w, h)

	--Tint the health bar based on current health
	if health_percent > 0.66 then
		Scene.Group.health_bar.Set_Tint(COLOR_HEALTH_GOOD.R, COLOR_HEALTH_GOOD.G, COLOR_HEALTH_GOOD.B, COLOR_HEALTH_GOOD.A)
	elseif health_percent > 0.33 then
		Scene.Group.health_bar.Set_Tint(COLOR_HEALTH_MEDIUM.R, COLOR_HEALTH_MEDIUM.G, COLOR_HEALTH_MEDIUM.B, COLOR_HEALTH_MEDIUM.A)
	else
		Scene.Group.health_bar.Set_Tint(COLOR_HEALTH_LOW.R, COLOR_HEALTH_LOW.G, COLOR_HEALTH_LOW.B, COLOR_HEALTH_LOW.A)
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Low_Power_Display -- this one will be overriden by the useful one from novus!
-- we just put it here so we don't check for faction when updating buttons!
-- ------------------------------------------------------------------------------------------------------------------
function Set_Low_Power_Display()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Texture = Set_Texture
Interface.Set_Selected = Set_Selected
Interface.Set_Enabled = Set_Enabled
Interface.Is_Selected = Is_Selected
Interface.Is_Enabled = Is_Enabled
Interface.Set_Clock_Filled = Set_Clock_Filled
Interface.Get_Clock_Filled = Get_Clock_Filled
Interface.Set_Text = Set_Text
Interface.Start_Flash = Start_Icon_Flash
Interface.Stop_Flash = Stop_Icon_Flash
Interface.Is_Flashing = Icon_Is_Flashing
Interface.Set_Clock_Tint = Set_Clock_Tint
Interface.Set_Cost = Set_Cost
Interface.Set_Clockwise = Set_Clockwise
Interface.Set_Percentage = Set_Percentage
Interface.Clear_Cost = Clear_Cost 
Interface.Set_Health = Set_Health
Interface.Show_Queue_Line = Show_Queue_Line
Interface.Show_Queue_Buy_Line = Show_Queue_Buy_Line
Interface.Set_Insufficient_Funds_Display = Set_Insufficient_Funds_Display
Interface.Set_Low_Power_Display = Set_Low_Power_Display
Interface.Set_Lower_Text = Set_Lower_Text
