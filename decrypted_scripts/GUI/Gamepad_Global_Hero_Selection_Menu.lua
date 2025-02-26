if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[124] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Global_Hero_Selection_Menu.lua
--
--    Original Author: Maria_Teruel
--
--          DateTime: 2007/10/01
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	
	Buttons = Find_GUI_Components(this, "Hero")
	
	for idx, button in pairs(Buttons) do
		-- Set the tab order.
		button.Set_Tab_Order(idx)
		
		-- This buttons should be focusable because we need to be able to click on them
		button.Set_Is_Focusable(true)
		
		this.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Hero_Button_Clicked)
	end
	
	IsOpen = false
end

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- Display_Menu
-- ------------------------------------------------------------------------------------------------------------------------------------------
function Display_Menu(on_off, hero_list)

	if on_off == IsOpen then 
		return
	end
	
	if on_off and not hero_list then 
		return
	end
	
	if on_off then
		HeroList = hero_list
		UpdateFocus = true
		Update_Buttons()
	else
		HeroList = {}
	end
	
	IsOpen = on_off
end


-- ------------------------------------------------------------------------------------------------------------------------------------------
-- On_Hero_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Clicked(_, button)
	if not TestValid(button) then 
		return
	end
	
	local hero = button.Get_Hero()
	if TestValid(hero) then 
		Set_Selected_Objects({hero})
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- Refresh_Display
-- ------------------------------------------------------------------------------------------------------------------------------------------
function Refresh_Display(fresh_list)
	if not IsOpen or not fresh_list then 
		return
	end
	
	HeroList = fresh_list
	Update_Buttons()
end

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Buttons
-- ------------------------------------------------------------------------------------------------------------------------------------------
function Update_Buttons()
	if not HeroList then
		return
	end
	
	local empty_display = true
	local selected_count = 0
	-- Assign the hero the button based on its priority value
	for button_index = 1, #Buttons do
		-- object_data[1] = hero object
		-- object_data[2] = hero texture
		-- object_data[3] = can the hero be selected? (if his fleet is moving he won't be selectable.)
		-- object_data[4] = is the hero selected?
		-- NOTE: the hero priority is the index of the table element.
		local button = Buttons[button_index]
		local object_data = HeroList[button_index]
		if not object_data then
			button.Set_Hidden(true)
		else
			local hero = object_data[1]
			if TestValid(hero) then 
				button.Set_Hidden(false)
				empty_display = false
				local display_health = button.Set_Hero(hero, object_data[2], priority_idx)

				local health = 0.0
				if display_health then 
					health = hero.Get_Hull()
				end			
				button.Set_Health(health)
				
				if hero.Is_Selected() and UpdateFocus then
					button.Set_Key_Focus()
					UpdateFocus = false
					selected_count = selected_count + 1
				end
				
				-- Update the enabled state.
				button.Set_Button_Enabled(object_data[3])
				
				-- Update the selection state.
				button.Set_Selected(object_data[4])
				
				button_index = button_index + 1 
				if button_index > #Buttons then 
					break
				end	
			else
				button.Set_Hidden(true)
			end
		end
	end
	
	if not empty_display and selected_count == 0 and UpdateFocus then
		this.Focus_First()
		UpdateFocus = false
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Open
-- ------------------------------------------------------------------------------------------------------------------------------------------
function Is_Open()
	return IsOpen
end

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- ------------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Display_Menu = Display_Menu
Interface.Is_Open = Is_Open
Interface.Refresh_Display = Refresh_Display

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
	Get_GUI_Variable = nil
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
