-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/UIControl.lua#24 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/UIControl.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Maria_Teruel $
--
--            $Change: 77186 $
--
--          $DateTime: 2007/07/18 15:46:32 $
--
--          $Revision: #24 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Hero - 
--     hero - NAME of hero to start flashing.
--     duration - if passed in, number of seconds to flash for. If not set, will flash until hero is clicked.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Hero(hero, duration)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Start_Flash_Hero", nil, { hero, duration })
		return true
	end

	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Hero - 
--     hero - NAME of hero to stop flashing.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Hero(hero)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Stop_Flash_Hero", nil, { hero })
		return true
	end

	return false
end



-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Construct_Building - 
--     building - NAME of building to start flashing build button for.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Construct_Building(building)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Start_Flash_Construct_Building", nil, { building })
		return true
	end

	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Construct_Building - 
--     building - NAME of building to stop flashing build button for.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Construct_Building(building)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Stop_Flash_Construct_Building", nil, { building })
		return true
	end

	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Temp_Enable_Build_Item - Enable this unit for production.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Temp_Enable_Build_Item(object_type)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Temp_Enable_Build_Item", nil, { object_type })
		return true
	end

	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Produce_Units - flash buttons to get user to produce units. 
--   Stops flashing when they've clicked through the UI to produce a unit. 
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Produce_Units(building)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Start_Flash_Produce_Units", nil, nil)
		return true
	end

	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Produce_Units - stop flashing buttons to produce units.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Produce_Units(building)
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Stop_Flash_Produce_Units", nil, nil)
		return true
	end

	return false
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Patch_Menu_Button_Flash - flash button(s) that give access to the patch menu.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Patch_Menu_Button_Flash()
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Start_Patch_Menu_Button_Flash", nil, nil)
		return true
	end

	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Patch_Menu_Button_Flash - stop flashing the button(s) that give access to the patch menu.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Patch_Menu_Button_Flash()
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("UI_Stop_Patch_Menu_Button_Flash", nil, nil)
		return true
	end

	return false
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Enable_For_Object - enable / disable UI elements for an object.
-- ------------------------------------------------------------------------------------------------------------------
function UI_Enable_For_Object(object, on_off)
	if not TestValid(object) then
		return
	end

	local hp_parent = object.Get_Highest_Level_Hard_Point_Parent()
	if TestValid(hp_parent) then
		object = hp_parent
	end

	object.Enable_Behavior(BEHAVIOR_GUI, on_off)
	hp_table = object.Get_All_Hard_Points()
	
	if hp_table then
		for i,hard_point in pairs(hp_table) do
			hard_point.Enable_Behavior(BEHAVIOR_GUI, on_off)
		end
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.13.2006
-- UI_Start_Flash_Button_For_Unit
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Button_For_Unit(unit_type_name)
	if unit_type_name == nil then 
		return false
	end
	
	local unit_type = Find_Object_Type(unit_type_name)
	if unit_type == nil then 
		return false
	end
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event_Immediate("UI_Start_Flash_Produce_Unit", nil, {unit_type})
		return true
	end
	
	return false
end



-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.13.2006
-- UI_Stop_Flash_Button_For_Unit
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Button_For_Unit(unit_type_name)
	if unit_type_name == nil then 
		return false
	end
	
	local unit_type = Find_Object_Type(unit_type_name)
	if unit_type == nil then 
		return false
	end
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event_Immediate("UI_Stop_Flash_Produce_Unit", nil, {unit_type})
		return true
	end
	
	return false	
end



-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.14.2006
-- UI_Start_Flash_Queue_Buttons
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Queue_Buttons(building_type_name, unit_type_name)
	if building_type_name == nil or unit_type_name == nil then 
		return false
	end
	
		
	local building_type = Find_Object_Type(building_type_name)
	if building_type == nil then return false end
	
	local unit_type = Find_Object_Type(unit_type_name)
	if unit_type == nil then return false end
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event_Immediate("UI_Start_Flash_Queue_Buttons", nil, {building_type, unit_type})
		return true
	end
	
	return false	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.14.2006
-- UI_Close_All_Displays
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Close_All_Displays()
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event_Immediate("Closing_All_Displays", nil, nil)
		return true
	end
	
	return false
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Set_Region_Color
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Set_Region_Color(region, color)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Force_Region_Color", nil, {region, color})
		return true
	end
	
	return false
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Clear_Region_Color
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Clear_Region_Color(region)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Clear_Region_Color", nil, {region})
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Show_Start_Mission_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Show_Start_Mission_Button()
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Show_Start_Mission_Button", nil, nil)
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Start_Mission_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Hide_Start_Mission_Button()
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Hide_Start_Mission_Button", nil, nil)
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Show_Sell_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Show_Sell_Button()
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Show_Sell_Button", nil, nil)
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Sell_Buttonn
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Hide_Sell_Button()
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Hide_Sell_Button", nil, nil)
		return true
	end
	
	return false	
end

function UI_Start_Flash_Superweapon(weapon_type_name)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Superweapon", nil, {weapon_type_name})
		return true
	end
	
	return false	
end

function UI_Stop_Flash_Superweapon(weapon_type_name)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Stop_Flash_Superweapon", nil, {weapon_type_name})
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Research_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Hide_Research_Button()
	--Easiest way to do this is probably despawn the scientist object.
	local player = Find_Player("local")
	local scientist_name = player.Get_Faction_Name() .. "_Hero_Chief_Scientist_PIP_Only"
	local scientist_type = Find_Object_Type(scientist_name)
	if not TestValid(scientist_type) then
		return
	end
	
	local scientists = Find_All_Objects_Of_Type(scientist_name, player)
	
	for _, unit in pairs(scientists) do
		unit.Despawn()
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Set_Loading_Screen_Background
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Set_Loading_Screen_Background(background)
	Register_Game_Scoring_Commands()

	local data_table = GameScoringManager.Get_Game_Script_Data_Table()

	if data_table == nil then
		data_table = { }
	end
	data_table.Loading_Screen_Background = background

	GameScoringManager.Set_Game_Script_Data_Table(data_table)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Set_Loading_Screen_Mission_Text
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Set_Loading_Screen_Mission_Text(text_id)
	Register_Game_Scoring_Commands()

	local data_table = GameScoringManager.Get_Game_Script_Data_Table()

	if data_table == nil then
		data_table = { }
	end
	data_table.Loading_Screen_Mission_Text = text_id

	GameScoringManager.Set_Game_Script_Data_Table(data_table)
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Set_Loading_Screen_Faction_ID
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Set_Loading_Screen_Faction_ID(faction_id)
	Register_Game_Scoring_Commands()

	local data_table = GameScoringManager.Get_Game_Script_Data_Table()

	if data_table == nil then
		data_table = { }
	end
	data_table.Loading_Screen_Faction_ID = faction_id

	GameScoringManager.Set_Game_Script_Data_Table(data_table)
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- This function lets the Tooltip now whether to display the resources data or not.
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Display_Tooltip_Resources(on_off)

	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event_Immediate("UI_Display_Tooltip_Resources", nil, {on_off})
	end
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Ability_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Ability_Button(ab_text_id)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Ability_Button", nil, {ab_text_id})
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Ability_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Ability_Button(ab_text_id)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Stop_Flash_Ability_Button", nil, {ab_text_id})
		return true
	end
	
	return false	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Set_Display_Credits_Pop
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Set_Display_Credits_Pop(on_off)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Set_Display_Credits_Pop", nil, {on_off})
		return true
	end
	
	return false	
end
