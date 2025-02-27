if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[187] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Hero_Manager.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Tactical_Hero_Manager.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Init
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Init()

	Set_GUI_Variable("HeroObject", nil)

	-- Maria 10.09.2007
	-- In the gamepad version, the hero icons are not clickable, with the exception of the Research Button.
	-- In such case, since the button is not the one with focus but this scene is, we process the A Button Up as if
	-- the button has been clicked on.
	-- this.Register_Event_Handler("Selectable_Icon_Clicked", this.HeroButton, On_Hero_Button_Clicked)
	--this.Register_Event_Handler("Selectable_Icon_Double_Clicked", this.HeroButton, On_Hero_Button_Double_Clicked)	
	
	this.HeroButton.Set_Tab_Order(1)
	this.Register_Event_Handler("Carousel_Gain_Focus", this, On_Focus_Gained)
	this.Register_Event_Handler("Carousel_Lose_Focus", this, On_Focus_Lost)
	this.Register_Event_Handler("Controller_A_Button_Up", this, On_Hero_Button_Clicked)
	
	this.HeroButton.Set_Clock_Tint({0.0, 1.0, 0.0, 0.59})
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Focus_Gained
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Focus_Gained(_, _)
	this.HeroButton.Process_Focus_Gained()
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Focus_Lost
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Focus_Lost(_, _)
	this.HeroButton.Process_Focus_Lost()
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Maria 02.06.2007 - NOTE: in tactical mode one click selects the hero and 2 clicks center the camera on the hero!.
-- That processing is done in Tactical_Command_Bar_Common.lua (via HeroIcons.lua)
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Clicked()	
	this.Get_Containing_Scene().Raise_Event("Selectable_Icon_Clicked", this.Get_Containing_Component(), nil)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Hero_Button_Double_Clicked
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Double_Clicked()
	this.Get_Containing_Scene().Raise_Event("Selectable_Icon_Double_Clicked", this.Get_Containing_Component(), nil)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Selected
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Selected(selected)

	if this.HeroButton.Is_Selected() == selected then
		return
	end

	local hero = Get_GUI_Variable("HeroObject")
	if not TestValid(hero) then
		return
	end

	this.HeroButton.Set_Selected(selected)
end



-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Is_Selected
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Is_Selected(selected)
	return this.HeroButton.Is_Selected()
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Update_Tooltip_Data
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Update_Tooltip_Data(hero_priority)
	local hero_object = Get_GUI_Variable("HeroObject")
	if TestValid(hero_object) then
		if hero_object.Get_Script().Get_Async_Data("IS_SCIENTIST") == true then
			this.HeroButton.Set_Tooltip_Data({'ui', {"TEXT_UI_RESEARCH_TREE_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_TOGGLE_RESEARCH_TREE_DISPLAY", -1)}})
		else 
			local hotkey_command = Get_Game_Command_Mapped_Key_Text("COMMAND_HERO_"..hero_priority, -1)
			this.HeroButton.Set_Tooltip_Data({'object', {hero_object, hotkey_command}})
		end
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Hero
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Hero(hero_object, hero_texture, hero_priority)

	local current_hero = Get_GUI_Variable("HeroObject")
	if current_hero == hero_object then
		-- We may be coming from a switch sides call so we need to update the tooltip data just in case the other player made
		-- changes to the keyboard mappings!.
		return
	end
	
	if not TestValid(hero_object) then return end
	
	Set_GUI_Variable("HeroObject", hero_object)
	this.HeroButton.Set_Texture(hero_texture)

	Set_Tooltip_Data(hero_object, hero_texture, hero_priority)
	this.HeroButton.Set_Selected(false)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Tooltip_Data
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Tooltip_Data(hero_object, hero_texture, hero_priority)
	if TestValid(hero_object) then
		if hero_object.Get_Script().Get_Async_Data("IS_SCIENTIST") == true then
			this.HeroButton.Set_Tooltip_Data({'ui', {"TEXT_UI_RESEARCH_TREE_BUTTON", Get_Game_Command_Mapped_Key_Text("COMMAND_TOGGLE_RESEARCH_TREE_DISPLAY", -1)}})
		else 
			local hotkey_command = Get_Game_Command_Mapped_Key_Text("COMMAND_HERO_"..hero_priority, -1)
			this.HeroButton.Set_Tooltip_Data({'object', {hero_object, hotkey_command}})
		end
	end
end



-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Health
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Health(health_percent)
	this.HeroButton.Set_Health(health_percent)
end



-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Get_Hero
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Get_Hero()
	return Get_GUI_Variable("HeroObject")
end



-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Start_Icon_Flash
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Start_Icon_Flash(duration)
	this.HeroButton.Start_Flash()
	if duration then
		Set_GUI_Variable("StopFlashTime", GetCurrentTime() + duration)
		this.Register_Event_Handler("Selectable_Icon_Animation_Finished", this.HeroButton, On_Animation_Finished)
	end
end



-- -----------------------------------------------------------------------------------------------------------------------------------------
-- On_Animation_Finished
-- -----------------------------------------------------------------------------------------------------------------------------------------
function On_Animation_Finished(event, source, data)
	local stop_flash_time = Get_GUI_Variable("StopFlashTime")
	if stop_flash_time then
		Stop_Icon_Flash()
	end
end



-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Stop_Icon_Flash
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Stop_Icon_Flash()
	this.HeroButton.Stop_Flash()
	Set_GUI_Variable("StopFlashTime", nil)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Clock_Filled
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Clock_Filled(value)
	this.HeroButton.Set_Clock_Filled(value)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Set_Button_Enabled
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Set_Button_Enabled(on_off)
	this.HeroButton.Set_Button_Enabled(on_off)
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
Interface.Set_Selected = Set_Selected
Interface.Is_Selected = Is_Selected
Interface.Set_Hero = Set_Hero
Interface.Get_Hero = Get_Hero
Interface.Start_Flash = Start_Icon_Flash
Interface.Stop_Flash = Stop_Icon_Flash
Interface.Start_Movie = Start_Movie
Interface.Stop_Movie = Stop_Movie
Interface.Set_Health = Set_Health
Interface.Set_Clock_Filled = Set_Clock_Filled
Interface.Get_Hero_Button = Get_Hero_Button
Interface.Update_Tooltip_Data = Update_Tooltip_Data
Interface.Set_Button_Enabled = Set_Button_Enabled
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
	On_Hero_Button_Double_Clicked = nil
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
