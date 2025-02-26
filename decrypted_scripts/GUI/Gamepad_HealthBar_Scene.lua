if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_HealthBar_Scene.lua $
--
--    Original Author: Chris Brooks
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
	
	-- Oksana: need for DMA display
	if Initialize_DMA_Bar then
		Initialize_DMA_Bar()
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
		
		Set_GUI_Variable("RequiresAmmoBar", Object.Has_Behavior(15))
		Set_GUI_Variable("RequiresShieldBar", false)
		
		-- In some cases, the health bar is attached to a hard point and we may need to keep track of its parent.
		if Object.Has_Behavior(68) then
			Set_GUI_Variable("HighestLevelParent", Object)
		end		
	end
	
	LetterBoxModeOn = false
	this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	
	Set_GUI_Variable("InitHasRun", true)
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(event, source, on_off)
	LetterBoxModeOn = on_off
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
			Update_Parent_Object_Pointer()
			Update_Health_Bar()
			Update_Ammo_Bar()
			Update_Shield_Bar()
			
			-- Do we have a DMA bar to refresh?
			if Update_DMA_Bar then
				Update_DMA_Bar()
			end
		end
	end
end

-- =====================================================================================
function Update_Parent_Object_Pointer()
	-- Make sure we update this pointer on the first service!.
	local parent_object = Get_GUI_Variable("HighestLevelParent")
	if parent_object then
		if parent_object == Object then 
			-- we need to update it!
			parent_object = Object.Get_Highest_Level_Hard_Point_Parent()
			if TestValid(parent_object) then 
				Set_GUI_Variable("HighestLevelParent", parent_object)
			end
		end
	end
end

-- =====================================================================================
function Update_Ammo_Bar()
	if ( not Has_Run_Init() ) then
		On_Init()
		return
	end
	
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
	if ( not Has_Run_Init() ) then
		On_Init()
		return
	end
	
	local health_percent = Object.Get_Health()
	if not health_percent then
		health_percent = 0.0
	end
	
	local HlthOrgWdth = Get_GUI_Variable("HealthOrigWidth")
	if ( not HlthOrgWdth ) then
		HlthOrgWdth = 1.0
	end
	
	local hwidth = HlthOrgWdth * health_percent
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
function Update_Shield_Bar()
	if ( not Has_Run_Init() ) then
		On_Init()
		return
	end
	
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

function Has_Run_Init()
	local init_run = Get_GUI_Variable("InitHasRun")
	if ( init_run ) then
		return true
	else
		return false
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
