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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tactical_Upgrades_Menu.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/02/24
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	if not TestValid(Object) then return end

	this.Register_Event_Handler("Component_Hidden", this, On_Hide_Scene)
	
	Initialize_Health_Bar_Display()
	
	-- Novus has the no power icon, Masari has the DMA bar
	if Initialize_Faction_Display then
		Initialize_Faction_Display()
	end	
	
	LetterBoxModeOn = false
	this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(event, source, on_off)
	LetterBoxModeOn = on_off
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_Health_Bar_Display
-- -------------------------------------------------------------------------------------------------------------------------------------
function Initialize_Health_Bar_Display()
	if not TestValid(this.HealthBar) then return end
	
	this.HealthBar.Set_Hidden(true)
	local healthX, healthY, healthWidth, healthHeight = this.HealthBar.Quad.Get_Bounds()
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
	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Health_Display
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Health_Display()

	if not TestValid(Object) then return end
	
	local health_percent = Object.Get_Hull()
	if not health_percent then health_percent = 0.0 end
	
	if this.HealthBar.Get_Hidden() == true and not LetterBoxModeOn then
		this.HealthBar.Set_Hidden(false)
	end
	
	-- just hide the bar if we have zero health.
	if health_percent <= 0 then 
		this.HealthBar.Set_Hidden(true)
		Set_GUI_Variable("LastUpdatedHealthPercent", health_percent)
		return
	end
	
	if Get_GUI_Variable("LastUpdatedHealthPercent") == health_percent then return end
	Set_GUI_Variable("LastUpdatedHealthPercent", health_percent)
	
	local orig_w = Get_GUI_Variable("HealthOrigWidth")
	local x = Get_GUI_Variable("HealthX")
	local y = Get_GUI_Variable("HealthY")
	local w = Get_GUI_Variable("HealthWidth")
	local h = Get_GUI_Variable("HealthHeight")
	
	-- update the width of the bar according to the health percent.
	w = orig_w * health_percent
	this.HealthBar.Quad.Set_Bounds(x, y, w, h)

	--Tint the health bar based on current health
	if health_percent > 0.66 then
		this.HealthBar.Quad.Set_Tint(COLOR_HEALTH_GOOD.R, COLOR_HEALTH_GOOD.G, COLOR_HEALTH_GOOD.B, COLOR_HEALTH_GOOD.A)
	elseif health_percent > 0.33 then
		this.HealthBar.Quad.Set_Tint(COLOR_HEALTH_MEDIUM.R, COLOR_HEALTH_MEDIUM.G, COLOR_HEALTH_MEDIUM.B, COLOR_HEALTH_MEDIUM.A)
	else
		this.HealthBar.Quad.Set_Tint(COLOR_HEALTH_LOW.R, COLOR_HEALTH_LOW.G, COLOR_HEALTH_LOW.B, COLOR_HEALTH_LOW.A)
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Active - EQUIVALENT TO ON_UPDATE
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Active()
	
	if LetterBoxModeOn then
		if not this.Get_Hidden() then 
			this.Set_Hidden(true)
		end
	elseif this.Get_Hidden() then 
		this.Set_Hidden(false)
	end
	
	-- Specific updates, eg., Novus has the no power icon, Masari has the DMA bar
	if Update_Faction_Display then 
		Update_Faction_Display()
	end
	
	-- All factions have health display.
	Update_Health_Display()	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- On_Hide_Scene 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function On_Hide_Scene()
	DebugMessage("Disabling Scene %i : %s", GetCurrentTime(), tostring(this))
	if Is_Power_On() then
		this.Enable(false)
	else
		this.Set_Hidden(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Power_On
-- ------------------------------------------------------------------------------------------------------------------
function Is_Power_On()

	if Object.Has_Behavior( 161 ) and Object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
		return false
	end
	return true
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
