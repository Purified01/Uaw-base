if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[123] = true
LuaGlobalCommandLinks[109] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Global_Hero_Manager.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Global_Hero_Manager.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 92893 $
--
--          $DateTime: 2008/02/08 11:49:59 $
--
--          $Revision: #14 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Init()

	Set_GUI_Variable("HeroObject", nil)
	Set_GUI_Variable("IsDummy", false)

	this.Register_Event_Handler("Selectable_Icon_Clicked", this.HeroButton, On_Hero_Button_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Double_Clicked", this.HeroButton, On_Hero_Button_Double_Clicked)
				
	this.Register_Event_Handler("Selection_Changed", nil, On_Selection_Changed)
	this.HeroButton.Set_Tab_Order(1)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Update_Respawning()
	local hero = Get_GUI_Variable("HeroObject")
	local respawn_percent = hero.Get_Respawn_Percent()
	if respawn_percent >= 1.0 then
		this.Set_State("Default")
		return
	end
	
	this.HeroButton.Set_Clock_Filled(1.0 - respawn_percent)
	local respawn_cost = hero.Get_Instant_Respawn_Cost()
	if respawn_cost then
		if respawn_cost > hero.Get_Owner().Get_Credits() then
			this.HeroButton.Set_Insufficient_Funds_Display(true)
		else
			this.HeroButton.Set_Insufficient_Funds_Display(false)
		end		
		
		this.HeroButton.Set_Cost(respawn_cost)
	end	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Begin_Respawning()
	Set_Dummy(true)
	this.HeroButton.Set_Clock_Filled(1.0)
	local hero = Get_GUI_Variable("HeroObject")
	local respawn_cost = hero.Get_Instant_Respawn_Cost()
	if respawn_cost then
		if respawn_cost > hero.Get_Owner().Get_Credits() then
			this.HeroButton.Set_Insufficient_Funds_Display(true)
		else
			this.HeroButton.Set_Insufficient_Funds_Display(false)
		end		
		
		this.HeroButton.Set_Cost(respawn_cost)
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_End_Respawning()
	Set_Dummy(false)
	this.HeroButton.Set_Clock_Filled(0.0)
	this.HeroButton.Clear_Cost()	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Clicked(event, source)
	if this.Get_Current_State_Name() == "Respawning" then
		local hero = Get_GUI_Variable("HeroObject")
		hero.Buy_Instant_Respawn()
	else
		if Get_GUI_Variable("IsDummy") then
			this.HeroButton.Set_Selected(not this.HeroButton.Is_Selected())
		end
		
		this.Get_Containing_Scene().Raise_Event_Immediate("Selectable_Icon_Clicked", this.Get_Containing_Component(), nil)
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Double_Clicked()
	this.Get_Containing_Scene().Raise_Event_Immediate("Selectable_Icon_Double_Clicked", this.Get_Containing_Component(), nil)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Closing_All_Displays()
	Set_Selected(false)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Hero(hero_object, hero_texture)
	Set_GUI_Variable("HeroObject", hero_object)
	this.HeroButton.Set_Texture(hero_texture)
	
	if TestValid(hero_object) then
		this.HeroButton.Set_Tooltip_Data({'object', {hero_object}})
	end
	
	if TestValid(hero_object) and hero_object.Get_Respawn_Percent() < 1.0 then
		this.Set_State("Respawning")
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Selected(selected)
	if selected ~= this.HeroButton.Is_Selected() then
		this.HeroButton.Set_Selected(selected)	
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Hero()
	return Get_GUI_Variable("HeroObject")
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Start_Icon_Flash(duration)
	this.HeroButton.Start_Flash()
	if duration then
		Set_GUI_Variable("StopFlashTime", GetCurrentTime() + duration)
		this.Register_Event_Handler("Selectable_Icon_Animation_Finished", this.HeroButton, On_Animation_Finished)
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Animation_Finished(event, source, data)
	local stop_flash_time = Get_GUI_Variable("StopFlashTime")
	if stop_flash_time then
		Stop_Icon_Flash()
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Stop_Icon_Flash()
	this.HeroButton.Stop_Flash()
	Set_GUI_Variable("StopFlashTime", nil)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Dummy(is_dummy)
	Set_GUI_Variable("IsDummy", is_dummy)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Fleet()
	local hero = Get_GUI_Variable("HeroObject")
	if TestValid(hero) then
		return hero.Get_Parent_Object()
	else
		return nil
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Health(health_percent)
	this.HeroButton.Set_Health(health_percent)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Clock_Filled(value)
	this.HeroButton.Set_Clock_Filled(value)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Selection_Changed
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Selection_Changed()
	local selected_objects = Get_Selected_Objects()
	Set_Selected(selected_objects and selected_objects[1] == Get_GUI_Variable("HeroObject"))
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Hero_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Hero_Button()
	return this.HeroButton
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE TABLE!!!!
-- -----------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Hero = Set_Hero
Interface.Get_Hero = Get_Hero
Interface.Set_Selected = Set_Selected
Interface.Start_Flash = Start_Icon_Flash
Interface.Stop_Flash = Stop_Icon_Flash
Interface.Set_Dummy = Set_Dummy
Interface.Get_Fleet = Get_Fleet
Interface.Set_Health = Set_Health
Interface.Set_Clock_Filled = Set_Clock_Filled
Interface.Get_Hero_Button = Get_Hero_Button
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
	On_Closing_All_Displays = nil
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
