if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Selectable_Icon.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 93395 $
--
--          $DateTime: 2008/02/14 16:35:20 $
--
--          $Revision: #32 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

function On_Init()
	Initialize_Selectable_Icon()
end

function Initialize_Selectable_Icon()
	
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Set_GUI_Variable("IsSelected", false)
	Set_GUI_Variable("Enabled", true)
	Set_GUI_Variable("FlashDuration", 0.0)
	Set_GUI_Variable("FlashStartTime", 0.0)
	Set_GUI_Variable("UseXOverlay", false)
	Set_GUI_Variable("SuppressPressSounds", false)

	local healthX = nil
	local healthY = nil
	local healthWidth = nil
	local healthHeight = nil
	local healthOrigWidth = nil;
		
	if TestValid(Scene.Group.health_bar) then
		Scene.Group.health_bar.Set_Hidden(true)
		Safe_Set_Hidden(Scene.Group.health_bar_back, true)
		healthX, healthY, healthWidth, healthHeight = Scene.Group.health_bar.Get_Bounds()
		healthOrigWidth = healthWidth
	end	
	
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
	
	Scene.Register_Event_Handler("Animation_Finished", Scene, On_Animation_Finished)
	
	Scene.Register_Event_Handler("Controller_A_Button_Press", Scene, On_Pushed)
	Scene.Register_Event_Handler("Controller_A_Button_Up", Scene, On_Click)
	Scene.Register_Event_Handler("Controller_X_Button_Up", Scene, On_Right_Click)
	Scene.Register_Event_Handler("Controller_X_Button_Press", Scene, On_Pushed)
	Scene.Register_Event_Handler("Controller_Left_Stick_Button_Up", Scene, On_Controller_Left_Stick_Click)

	Scene.Register_Event_Handler("Controller_A_Button_Double_Press", Scene, On_Double_Click)	
	Scene.Register_Event_Handler("Controller_X_Button_Double_Press", Scene, On_Right_Double_Click)	
	
	-- TODO: register to get called when anim finishes
	-- some selectable icons will need to display a clock!
	if TestValid(Scene.Group.Clock) then
		Scene.Group.Clock.Set_Filled(0.0)
		Scene.Group.Icon.Set_Hidden(false)
	end
	
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
	
	Embed_Gamepad_A_Button_Scene()
	Set_GUI_Variable("HasFocus", false)
	
	this.Register_Event_Handler("Key_Focus_Lost", this, On_Focus_Lost)
	this.Register_Event_Handler("Key_Focus_Gained", this, On_Focus_Gained)
	this.Register_Event_Handler("Carousel_Gain_Focus", this, On_Focus_Gained_No_Animation)
	this.Register_Event_Handler("Carousel_Lose_Focus", this, On_Focus_Lost)
	this.Register_Event_Handler("On_Display_Tooltip", this, On_Display_Tooltip)
	
	Safe_Set_Hidden(this.Group.Highlight, true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Embed_Gamepad_A_Button_Scene - 
-- ------------------------------------------------------------------------------------------------------------------
function Embed_Gamepad_A_Button_Scene()
	if not TestValid(this.Group.Gamepad_A_Button) then
		this.Group.Create_Embedded_Scene("Gamepad_A_Button_Scene", "Gamepad_A_Button")		
	end
	
	local x, y, w, h = this.Group.Gamepad_A_Button.Get_Bounds()
	local this_x, this_y,this_w, this_h = this.Group.Icon.Get_Bounds()
	this.Group.Gamepad_A_Button.Set_Bounds(this_x + (this_w/2.0) - (w/2.0), this_y + this_h, w, h)
	this.Group.Gamepad_A_Button.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Embed_Gamepad_X_Button_Scene - 
-- ------------------------------------------------------------------------------------------------------------------
function Embed_Gamepad_X_Button_Scene()
	if not TestValid(this.Group.Gamepad_X_Button) then
		this.Group.Create_Embedded_Scene("Gamepad_X_Button_Scene", "Gamepad_X_Button")		
	end
	
	local x, y, w, h = this.Group.Gamepad_X_Button.Get_Bounds()
	local this_x, this_y,this_w, this_h = this.Group.Icon.Get_Bounds()
	this.Group.Gamepad_X_Button.Set_Bounds(this_x + (this_w/2.0) - (w/2.0), this_y + this_h, w, h)
	this.Group.Gamepad_X_Button.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Process_Focus_Lost - 
-- ------------------------------------------------------------------------------------------------------------------
function Process_Focus_Lost(event, source)
	-- Sanity check: do not process trivial (multiple) calls!!
	if not Get_GUI_Variable("HasFocus") then
		return
	end
	
	Set_Focus(false)

	-- Let's just end the tooltip if we have tooltip data.
	if Scene.Get_Containing_Component().Get_Tooltip_Data() then
		End_Tooltip()
	end
	
	-- MARIA 10.02.2007 - Implementing 'Flash-Icon' functionality for designers.
	-- if the icon is flashing and has focus at the same time, losing focus will not stop the focus animation
	-- and the icon will remain messed up! Hence, we have to stop both of them.  In most cases, the flash
	-- animations get updated on a regular basis which means that the icon (if applicable) will regain
	-- its flash state soon enough after we have stoppped it.
	if this.Is_Animating("Focus_Gained") or this.Is_Animating("Flash") then
		this.Stop_Animation()
	end
	
	if TestValid(Scene.Group.Gamepad_A_Button) then
		Scene.Group.Gamepad_A_Button.Set_Hidden(true)
	end
	if TestValid(Scene.Group.Gamepad_X_Button) then
		Scene.Group.Gamepad_X_Button.Set_Hidden(true)
	end
	
	-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
	Raise_Event_All_Parents("Mouse_Off_Selectable_Icon", this.Get_Containing_Component(), this, nil)
	
	Set_GUI_Variable("HasFocus", false)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Lost - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Lost()
	Process_Focus_Lost()
	
	Raise_Event_All_Parents("Selectable_Icon_Lost_Focus", this.Get_Containing_Component(), this, nil)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Process_Focus_Gained - 
-- ------------------------------------------------------------------------------------------------------------------
function Process_Focus_Gained(play_focus_animation)

	-- Sanity check: do not process trivial (multiple) calls!!
	if Get_GUI_Variable("HasFocus") then
		return
	end
	
	Set_Focus(true)
	
	-- We have to make sure we stop all other animations!
	this.Stop_Animation()
	
	if play_focus_animation then
		-- enlarge the icon
		this.Play_Animation("Focus_Gained", false)
	
		-- when enlarge we want to try not to have them overlap!.
		this.Get_Containing_Component().Bring_To_Front()
	end
	
	--TODO: this should be handled by individual buttons, not here
	if not TestValid(Scene.Group.Gamepad_A_Button) then
		Embed_Gamepad_A_Button_Scene()
	end
	
	Play_SFX_Event("GUI_Generic_Mouse_Over")

	-- signal that the mouse is over the icon in case someone needs to process it! (eg. Production Icons!)
	Raise_Event_All_Parents("Mouse_Over_Selectable_Icon", Scene.Get_Containing_Component(), Scene, nil)
	
	-- if this icon has tooltip data assigned, dispkay its tooltip
	if  Scene.Get_Containing_Component().Get_Tooltip_Data() then 
		-- Start countdown for tooltip display
		Set_GUI_Variable("MouseOverSceneTime", GetCurrentTime())
		this.Raise_Event("On_Display_Tooltip", this, nil)
	end
	
	if not Get_GUI_Variable("HideAButtonOverlay") and Is_Enabled() then
		if Get_GUI_Variable("UseXOverlay") and TestValid(Scene.Group.Gamepad_X_Button) then
			Scene.Group.Gamepad_X_Button.Set_Hidden(false)
		elseif TestValid(Scene.Group.Gamepad_A_Button) then
			Scene.Group.Gamepad_A_Button.Set_Hidden(false)
		end			
	end
	
	Set_GUI_Variable("HasFocus", true)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Display_Tooltip - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Display_Tooltip(_, _)
	if Scene.Is_Visible() then
		-- is there a tooltip pending to be displayed!?
		local mouse_over_time = Get_GUI_Variable("MouseOverSceneTime")
		if mouse_over_time ~= nil then 
			if GetCurrentTime() - mouse_over_time > MouseOverSceneHoverTime then 
				-- display the tooltip
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Controller_Display_Tooltip_From_UI", nil, {Scene.Get_Containing_Component().Get_Tooltip_Data()})
				Set_GUI_Variable("MouseOverSceneTime", nil)
				return
			else
				this.Raise_Event("On_Display_Tooltip", this, nil)
			end
		end
	else
		Set_GUI_Variable("MouseOverSceneTime", nil)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Gained - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Gained()
	Process_Focus_Gained(true)
	
	Raise_Event_All_Parents("Selectable_Icon_Gained_Focus", this.Get_Containing_Component(), this, nil)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Focus_Gained_No_Animation - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Focus_Gained_No_Animation()
	Process_Focus_Gained(false)
	
	Raise_Event_All_Parents("Selectable_Icon_Gained_Focus", this.Get_Containing_Component(), this, nil)
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
	
	if name == "Unselected" then
		Safe_Set_Hidden(Scene.Group.notselected_notover_notclicked, false)
		Safe_Set_Hidden(Scene.Group.selected_notover_notclicked, true)
		this.Set_Grayscale(false)

	elseif name == "Selected" then
  		Safe_Set_Hidden(Scene.Group.notselected_notover_notclicked, true)
  		Safe_Set_Hidden(Scene.Group.selected_notover_notclicked, false)
  		this.Set_Grayscale(false)

	elseif name == "Disabled" then
		Safe_Set_Hidden(Scene.Group.notselected_notover_notclicked, true)
		Safe_Set_Hidden(Scene.Group.selected_notover_notclicked, true)
		this.Set_Grayscale(true)
	end
end


-- ----------------------------------------------------------------------------------------------
-- On_Animation_Finished
-- ----------------------------------------------------------------------------------------------
function On_Animation_Finished()
	Raise_Event_All_Parents("Selectable_Icon_Animation_Finished", Scene.Get_Containing_Component(), Scene, nil)
end

-- ----------------------------------------------------------------------------------------------
-- On_Pushed
-- ----------------------------------------------------------------------------------------------
function On_Pushed()
	if not this.Get_Hidden() and not Get_GUI_Variable("SuppressPressSounds") then
		if not Get_GUI_Variable("Enabled") then 
			Play_SFX_Event("GUI_Generic_Bad_Sound")
		else
			Play_SFX_Event("GUI_Generic_Button_Select")
		end		
	end
end

-- ----------------------------------------------------------------------------------------------
-- On_Click
-- ----------------------------------------------------------------------------------------------
function On_Click()
	if not this.Get_Hidden() and Get_GUI_Variable("Enabled") then 	
		Raise_Event_All_Parents("Selectable_Icon_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	end
end


-- ----------------------------------------------------------------------------------------------
-- On_Double_Click
-- ----------------------------------------------------------------------------------------------
function On_Double_Click()
	if not this.Get_Hidden() and Get_GUI_Variable("Enabled") then 
		Raise_Event_All_Parents("Selectable_Icon_Double_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	end
end

-- ----------------------------------------------------------------------------------------------
-- On_Right_Click
-- ----------------------------------------------------------------------------------------------
function On_Right_Click()
	-- Maria 01.11.2008
	-- Removing the 'Enabled' check because it is breaking the canceling of units from the build queues.
	-- In fact, the buttons receiving the event are not the ones in the queue but the button that is used to 
	-- purchase the unit.  Hence, when the queue is full the buy button becomes disabled and the scene cannot
	-- process the X button release.
	--if not this.Get_Hidden() and Get_GUI_Variable("Enabled") then 
	if not this.Get_Hidden() then 
		Raise_Event_All_Parents("Selectable_Icon_Right_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	end
end

-- ----------------------------------------------------------------------------------------------
-- On_Right_Double_Click
-- ----------------------------------------------------------------------------------------------
function On_Right_Double_Click()
	if not this.Get_Hidden() and Get_GUI_Variable("Enabled") then 
		Raise_Event_All_Parents("Selectable_Icon_Right_Double_Clicked", Scene.Get_Containing_Component(), Scene, nil)
	end
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

	if not Is_Enabled() then
		return
	end

	if selected then 
		Scene.Set_State("Selected")
	else
		Scene.Set_State("Unselected")
	end
	
	Set_GUI_Variable("IsSelected", selected)
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
		if TestValid(Scene.Group.Gamepad_A_Button) and Get_GUI_Variable("HasFocus") and not Get_GUI_Variable("HideAButtonOverlay")  then
			Scene.Group.Gamepad_A_Button.Set_Hidden(false)
		end
		if Is_Selected() then
			Scene.Set_State("Selected")
		else
			Scene.Set_State("Unselected")
		end
	else
		Scene.Set_State("Disabled")
		if TestValid(Scene.Group.Gamepad_A_Button) then
			Scene.Group.Gamepad_A_Button.Set_Hidden(true)
		end
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
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Controller_Display_Tooltip_From_UI", nil, {Scene.Get_Containing_Component().Get_Tooltip_Data()})
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
-- Is_Enabled
-- ----------------------------------------------------------------------------------------------
function Is_Enabled()
	return Get_GUI_Variable("Enabled")
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
function Set_Insufficient_Funds_Display(on_off, modify_grayscale)

	local ins_funds_on = Get_GUI_Variable("InsufficientFundsOn")
	if ins_funds_on == on_off then 
		-- do nothing
		return
	end
	
	-- default to true
	if modify_grayscale == nil then 
		modify_grayscale = true
	end
	
	-- We have to change the display font (and LATER put up the redish layer!.)
	if on_off == true then 
		Scene.Group.LowerText.Set_Font("Cost_Red")
		
		if modify_grayscale then
			this.Set_Grayscale(true)
		end
	else
		Scene.Group.LowerText.Set_Font("Cost_Green")
		
		if modify_grayscale then
			this.Set_Grayscale(false)
		end
	end
	
	Set_GUI_Variable("InsufficientFundsOn", on_off)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Health
-- ------------------------------------------------------------------------------------------------------------------
function Set_Health(health_percent)

	if not TestValid(Scene.Group.health_bar) then
		return
	end

	-- just hide the bar if we have zero health.
	if health_percent <= 0 then 
		Scene.Group.health_bar.Set_Hidden(true)
		Safe_Set_Hidden(Scene.Group.health_bar_back, true)
		return
	end
	
	if Scene.Group.health_bar.Get_Hidden() then
		Scene.Group.health_bar.Set_Hidden(false)
		Safe_Set_Hidden(Scene.Group.health_bar_back, false)
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
-- Hide_A_Button_Overlay -- Some buttons (for the controller version) do not process the A button
-- press, hence, we want to not display the A button overlay to avoid confussion.
-- ------------------------------------------------------------------------------------------------------------------
function Hide_A_Button_Overlay(new_hide)
	if new_hide == nil then
		new_hide = true
	end
	
	if TestValid(Scene.Group.Gamepad_A_Button) then
		Set_GUI_Variable("HideAButtonOverlay", new_hide)
		if new_hide then
			Scene.Group.Gamepad_A_Button.Set_Hidden(true)
			if TestValid(Scene.Group.Gamepad_X_Button) then
				Scene.Group.Gamepad_X_Button.Set_Hidden(true)
			end
		else
			if Get_GUI_Variable("HasFocus") then
				if Get_GUI_Variable("UseXOverlay") then
					if TestValid(Scene.Group.Gamepad_X_Button) then
						Scene.Group.Gamepad_X_Button.Set_Hidden(false)
					end
				else
					Scene.Group.Gamepad_A_Button.Set_Hidden(false)
				end
			end
		end
	end
end

-- ----------------------------------------------------------------------------------------------
-- Set_Clockwise
-- ----------------------------------------------------------------------------------------------
function Set_Clockwise(onoff)
	Scene.Group.Clock.Set_Clockwise(onoff)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Highlight -- Turn the highlight on/off
-- ------------------------------------------------------------------------------------------------------------------
function Highlight(onoff)
	if TestValid(this.Group.Highlight) then
		this.Group.Highlight.Set_Hidden(not onoff)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Controller_Left_Stick_Click
-- ------------------------------------------------------------------------------------------------------------------
function On_Controller_Left_Stick_Click()
	Raise_Event_All_Parents("Selectable_Icon_Left_Stick_Clicked", Scene.Get_Containing_Component(), Scene, nil)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Use_X_Overlay -- Use an X overlay instead of an A overlay
-- ------------------------------------------------------------------------------------------------------------------
function Use_X_Overlay(onoff)
	Set_GUI_Variable("UseXOverlay", onoff)
	Embed_Gamepad_X_Button_Scene()
	if not Get_GUI_Variable("HideAButtonOverlay") and Get_GUI_Variable("HasFocus") then
		if onoff then
			Scene.Group.Gamepad_A_Button.Set_Hidden(true)
			Scene.Group.Gamepad_X_Button.Set_Hidden(false)
		else
			Scene.Group.Gamepad_A_Button.Set_Hidden(false)
			Scene.Group.Gamepad_X_Button.Set_Hidden(true)
		end
	end		
end

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Overlay_Hidden -- Check to see if the A or X button overlay is hidden
-- ------------------------------------------------------------------------------------------------------------------
function Is_Overlay_Hidden()
	return Get_GUI_Variable("HideAButtonOverlay")
end

function Supress_Press_Sounds()
	Set_GUI_Variable("SuppressPressSounds", true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Texture = Set_Texture
Interface.Set_Selected = Set_Selected
Interface.Set_Button_Enabled = Set_Enabled
Interface.Is_Selected = Is_Selected
Interface.Is_Button_Enabled = Is_Enabled
Interface.Set_Clock_Filled = Set_Clock_Filled
Interface.Get_Clock_Filled = Get_Clock_Filled
Interface.Set_Text = Set_Text
Interface.Start_Flash = Start_Icon_Flash
Interface.Stop_Flash = Stop_Icon_Flash
Interface.Is_Flashing = Icon_Is_Flashing
Interface.Set_Clock_Tint = Set_Clock_Tint
Interface.Set_Cost = Set_Cost
Interface.Set_Percentage = Set_Percentage
Interface.Clear_Cost = Clear_Cost 
Interface.Set_Health = Set_Health
Interface.Set_Insufficient_Funds_Display = Set_Insufficient_Funds_Display
Interface.Set_Low_Power_Display = Set_Low_Power_Display
Interface.Set_Lower_Text = Set_Lower_Text
Interface.Highlight = Highlight
Interface.Set_Clockwise = Set_Clockwise

-- controller specific
Interface.Hide_A_Button_Overlay = Hide_A_Button_Overlay
Interface.Is_Overlay_Hidden = Is_Overlay_Hidden
Interface.Use_X_Overlay = Use_X_Overlay
Interface.Process_Focus_Gained = Process_Focus_Gained
Interface.Process_Focus_Lost = Process_Focus_Lost
Interface.Supress_Press_Sounds = Supress_Press_Sounds
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
	Raise_Event_Immediate_All_Parents = nil
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

