-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/HealthBar_Scene.lua#30 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/HealthBar_Scene.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 84600 $
--
--          $DateTime: 2007/09/22 16:38:03 $
--
--          $Revision: #30 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 1

-- Since there are likely to be a BUNCH of these, On_Update only is called when we are in the "active" 
-- state. The tactical hud script puts us in that state if we ought to show up. 
-- The states show or hide our UI as well, so we don't need to do that here. -CSB
-- =====================================================================================
function On_Init()

	-- Disable health bars when hidden
	this.Register_Event_Handler("Component_Hidden", this, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden", this, Enable_UI_Element_Event)

	-- We want to color the health bar based on the amount of health the object has at any given time
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
	
	HealthX, HealthY, HealthWidth, HealthHeight = Scene.HealthBarQuad.Get_Bounds()
	Set_GUI_Variable("HealthX", HealthX)
	Set_GUI_Variable("HealthY", HealthY)
	Set_GUI_Variable("HealthWidth", HealthWidth)
	Set_GUI_Variable("HealthHeight", HealthHeight)
	Set_GUI_Variable("HealthOrigWidth", HealthWidth)
	
	
	Initialize_Ammo_Bar()
	Initialize_Shield_Bar()
	Initialize_Control_Group_Display()

	-- Oksana: need for DMA display
	Initialize_DMA_Bar()
	
	if TestValid(this.ControlGroup) then
		this.Register_Event_Handler("Object_Control_Group_Assignment_Changed", nil, On_Control_Group_Assignment_Changed)
	end
	
	if TestValid(Object) then
		local pip_count = Object.Get_Max_Garrisoned()
		local spacing_constant = 5
		
		if pip_count > 0 and Object.Should_Show_Pips() then
			local garrisonable_pip_container = Scene.Create_Embedded_Scene( "Garrisonable_Pip_Container", "Garrisonable_Pip_Container" )
			
			local container_x, container_y, container_width, container_height = garrisonable_pip_container.Get_Bounds()
			
			local container_x_offset = ( HealthWidth - container_width ) / 2
			garrisonable_pip_container.Set_Bounds( HealthX + container_x_offset, HealthY + HealthHeight * 2, container_width, container_height )

			Set_GUI_Variable("GarrisonablePipContainer", garrisonable_pip_container)
			
			local garrisonable_exit = Scene.Create_Embedded_Scene( "Exit_Icon", "Exit_Icon" )
			local exit_x, exit_y, exit_width, exit_height = garrisonable_exit.Get_Bounds()
			local exit_x_offset = ( HealthWidth - exit_width ) / 2
			
			garrisonable_exit.Set_Bounds( HealthX + exit_x_offset, HealthY - exit_height * 2, exit_width, exit_height )

			Set_GUI_Variable("GarrisonableExit", garrisonable_exit)				
		end
		
		Set_GUI_Variable("RequiresAmmoBar", Object.Has_Behavior(BEHAVIOR_ENERGY_POOL))
		Set_GUI_Variable("RequiresShieldBa", Object.Has_Behavior(BEHAVIOR_SHIELDED))
		
		-- In some cases, the health bar is attached to a hard point and we may need to keep track of its parent.
		if Object.Has_Behavior(BEHAVIOR_HARD_POINT) then
			Set_GUI_Variable("HighestLevelParent", Object)
		end		
	end
	
	Set_GUI_Variable("FirstServiceInit", true)
	
	LetterBoxModeOn = false
	this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	this.Register_Event_Handler("Reset_Last_Service", nil, On_Reset_Last_Service)
	
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Reset_Last_Service
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Reset_Last_Service(event, source, val)
	Set_GUI_Variable("LastServiceTime", 0)
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(event, source, on_off)
	LetterBoxModeOn = on_off
end


-- =====================================================================================
function Initialize_Control_Group_Display()
	if not TestValid(this.ControlGroup) then return end
	Set_GUI_Variable("ControlGroupIndex", -1)
	Update_Control_Group_Display()
end


-- =====================================================================================
function On_Control_Group_Assignment_Changed(event, source, object, group_id)
	Process_Control_Group_Assignment_Change(object, group_id)	
end


-- =====================================================================================
function Process_Control_Group_Assignment_Change(object, group_id)
	if object ~= Object then 
		local parent_object = Get_GUI_Variable("HighestLevelParent")
		if not parent_object or parent_object ~= object then
			return
		end
	end
	
	Set_GUI_Variable("ControlGroupIndex", group_id)
	Update_Control_Group_Display()
end

-- =====================================================================================
function Update_Control_Group_Display()
	if not TestValid(this.ControlGroup) then return end
	local group_id = Get_GUI_Variable("ControlGroupIndex")
	-- if we are not the local player or the object is not assigned to any control group then hide the display!.
	if Object.Get_Owner() ~= Find_Player("local") or group_id <= -1 then 
		this.ControlGroup.Set_Hidden(true)
	else
		this.ControlGroup.Set_Hidden(false)
		local texture_name = "I_icon_ctrl_"..group_id..".tga"
		this.ControlGroup.CtrlGQuad.Set_Texture(texture_name)
	end
end


-- =====================================================================================
function Initialize_Shield_Bar()
	if not TestValid(this.ShieldBarQuad) then return end
	ShieldsX, ShieldsY, ShieldsWidth, ShieldsHeight = this.ShieldBarQuad.Get_Bounds()
	Set_GUI_Variable("ShieldsX", ShieldsX)
	Set_GUI_Variable("ShieldsY", ShieldsY)
	Set_GUI_Variable("ShieldsWidth", ShieldsWidth)
	Set_GUI_Variable("ShieldsHeight", ShieldsHeight)
	Set_GUI_Variable("ShieldsOrigWidth", ShieldsWidth)
end


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
function Initialize_Ammo_Bar()
	
	if TestValid( this.AmmoBar) then
		local AmmoSlots = Find_GUI_Components(this.AmmoBar, "Ammo0")
		for _, ammo_unit in pairs(AmmoSlots) do
			ammo_unit.Set_Hidden(true)
		end
		Set_GUI_Variable("AmmoSlots", AmmoSlots)
	end
end


-- =====================================================================================
function Set_Ammo_Units(num_units)
	if TestValid( this.AmmoBar) then
		local ammo_slots = Get_GUI_Variable("AmmoSlots")
		for i = 1, #ammo_slots do
			ammo_slots[i].Set_Hidden(i > num_units)
		end	
		Set_GUI_Variable("AmmoSlots", ammo_slots)
	end	
end

-- =====================================================================================
-- Wherever possible avoid calls to game (non-lua) functions here for efficiency reasons. 
function On_Update()
	if TestValid(Object) then
		if LetterBoxModeOn then
			if not this.Get_Hidden() then 
				this.Set_Hidden(true)
			end
		elseif this.Get_Hidden() then 
			this.Set_Hidden(false)
		end
		
		First_Service_Init()
		
		local cur_time = GetCurrentTime()
		local nice_service_time = false
		local last_time = Get_GUI_Variable("LastServiceTime")
		if last_time == nil then 
			last_time = cur_time - 0.3
			Set_GUI_Variable("LastServiceTime", last_time)
		end
	
		if cur_time - last_time > 0.3 then
			last_time = cur_time
			Set_GUI_Variable("LastServiceTime", last_time)
			nice_service_time = true
		end

		if nice_service_time then
			Update_Health_Bar()
			Update_Ammo_Bar()
			Update_Shield_Bar()
			Update_DMA_Bar()
		end	
	end
end

-- =====================================================================================
function First_Service_Init()
	if Get_GUI_Variable("FirstServiceInit") then
		local relevant_object = Update_Parent_Object_Pointer()
		
		if TestValid(this.ControlGroup) and Object.Get_Owner() == Find_Player("local") then
			-- NOTE: we need to do it here because some objects need to check for
			-- Ctrl. gp assignment on their parents.
			Check_For_Existing_Control_Group_Assignment(relevant_object)
		end
		
		Set_GUI_Variable("FirstServiceInit", false)
	end
end


-- =====================================================================================
function Check_For_Existing_Control_Group_Assignment(object)
	local cg_assignment = object.Get_Control_Group_Assignment()
	if cg_assignment ~= -1.0 then
		-- Update the object's UI to reflect the control group assignment.
		Process_Control_Group_Assignment_Change(object, cg_assignment)	
	end
end


-- =====================================================================================
function Update_Parent_Object_Pointer()
	-- Make sure we update this pointer on the first service!.
	local parent_object = Get_GUI_Variable("HighestLevelParent")
	if not TestValid(parent_object) then
		return Object
	elseif parent_object == Object then 
		-- we need to update it!
		parent_object = Object.Get_Highest_Level_Hard_Point_Parent()
		if TestValid(parent_object) then 
			Set_GUI_Variable("HighestLevelParent", parent_object)						
		end
		return parent_object
	end
end


-- =====================================================================================
function Debug_Switch_Sides()
	Update_Control_Group_Display()
end


-- =====================================================================================
function Update_Ammo_Bar()
	if TestValid(this.AmmoBar) then
		local ammo = 0
		if Get_GUI_Variable("RequiresAmmoBar") == true then
			ammo = Object.Get_Ammo()
		end
		Set_Ammo_Units(ammo)
	end
end


-- =====================================================================================
function Update_Health_Bar()
	local health_percent = Object.Get_Health()
	if not health_percent then
		health_percent = 0.0
	end
	local hwidth = Get_GUI_Variable("HealthOrigWidth") * health_percent
	Set_GUI_Variable("HealthWidth", hwidth)
	Scene.HealthBarQuad.Set_Bounds(	Get_GUI_Variable("HealthX"), 
							Get_GUI_Variable("HealthY"),
							Get_GUI_Variable("HealthWidth"), 
							Get_GUI_Variable("HealthHeight"))
							
	--Tint the health bar based on current health
	if health_percent > 0.66 then
		this.HealthBarQuad.Set_Tint(COLOR_HEALTH_GOOD.R, COLOR_HEALTH_GOOD.G, COLOR_HEALTH_GOOD.B, COLOR_HEALTH_GOOD.A)
	elseif health_percent > 0.33 then
		this.HealthBarQuad.Set_Tint(COLOR_HEALTH_MEDIUM.R, COLOR_HEALTH_MEDIUM.G, COLOR_HEALTH_MEDIUM.B, COLOR_HEALTH_MEDIUM.A)
	else
		this.HealthBarQuad.Set_Tint(COLOR_HEALTH_LOW.R, COLOR_HEALTH_LOW.G, COLOR_HEALTH_LOW.B, COLOR_HEALTH_LOW.A)
	end
end


-- =====================================================================================
function Update_DMA_Bar()
	if not TestValid(this.DMABGQuad) then return end
	
	local DMA_percent = 0.0
	local should_hide = true
	
	if Is_Player_Of_Faction(Object.Get_Owner(), "MASARI") then
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
	end -- if masari
	
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



-- =====================================================================================
function Update_Shield_Bar()
  	
	if not TestValid(this.ShieldBarQuad) or Get_GUI_Variable("RequiresShieldBar") == false then
		return
	end
	
	-- Maria 09.27.2006	-- TEMPORARY TO SHOW SHIELD HEALTH (for shield effect)
   	-- If the object has a shield effect, then use the bar to show the charge of the shield
   	local energy_percent = Object.Get_Shield()	
	if not energy_percent then
   		energy_percent = 0.0			
   	end

	local shields_width = Get_GUI_Variable("ShieldsOrigWidth") * energy_percent
	Set_GUI_Variable("ShieldsWidth", shields_width)
	local test = Get_GUI_Variable("ShieldsWidth")
	this.ShieldBarQuad.Set_Bounds(	Get_GUI_Variable("ShieldsX"),
					Get_GUI_Variable("ShieldsY"),
					Get_GUI_Variable("ShieldsWidth"),
					Get_GUI_Variable("ShieldsHeight"))
end


-- =====================================================================================
function On_Enter_Active_State()
	if Get_GUI_Variable("GarrisonablePipContainer") then
		Get_GUI_Variable("GarrisonablePipContainer").Set_State( "Visible" )
	end
end

-- =====================================================================================
function On_Enter_Inactive_State()
	if Get_GUI_Variable("GarrisonablePipContainer") then
		Get_GUI_Variable("GarrisonablePipContainer").Set_State( "Hidden" )
	end
end
