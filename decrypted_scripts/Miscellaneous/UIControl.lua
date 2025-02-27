if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[175] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[94] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[51] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/UIControl.lua#20 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/UIControl.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #20 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("PGHintSystem")
require("PGObjectives")
require("PGMovieCommands")

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

	object.Enable_Behavior(85, on_off)
	hp_table = object.Get_All_Hard_Points()
	
	if hp_table then
		for i,hard_point in pairs(hp_table) do
			hard_point.Enable_Behavior(85, on_off)
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
		gui_scene.Raise_Event("UI_Start_Flash_Produce_Unit", nil, {unit_type})
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
		gui_scene.Raise_Event("UI_Stop_Flash_Produce_Unit", nil, {unit_type})
		return true
	end
	
	return false	
end



-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 11.14.2006
-- UI_Start_Flash_Queue_Buttons
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Queue_Buttons(building_type_name, unit_type_name)
	
	-- NOTE: object_type MAY be null for designers may only want to flash the building button 
	-- and none of the buy buttons.
	
	if not building_type_name then
		return false
	end
	
	
	local building_type = Find_Object_Type(building_type_name)
	if building_type == nil then return false end
	
	local unit_type = nil
	if unit_type_name and unit_type_name ~= "" then
		unit_type = Find_Object_Type(unit_type_name)
	end
	
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Queue_Buttons", nil, {building_type, unit_type})
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
		gui_scene.Raise_Event("Closing_All_Displays", nil, nil)
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


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Superweapon
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Superweapon(weapon_type_name)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Superweapon", nil, {weapon_type_name})
		return true
	end
	
	return false	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Superweapon
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Superweapon(weapon_type_name)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Stop_Flash_Superweapon", nil, {weapon_type_name})
		return true
	end
	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Command_Bar
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Hide_Command_Bar(hide_unhide)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Hide_Command_Bar", nil, {hide_unhide})
		return true
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Hide_Research_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Hide_Research_Button(hide_unhide)
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Hide_Research_Button", nil, {hide_unhide})
		return true
	end
	
	-- Let's not do this because the missions may call the Hide button function before the science guy is 
	-- even created and thus it will have no effect.
	--[[
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
	]]--
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
		gui_scene.Raise_Event("UI_Display_Tooltip_Resources", nil, {on_off})
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


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Show_Radar_Map
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Show_Radar_Map(show)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Show_Radar_Map", nil, {show})
		return true
	end	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Show_Controller_Context_Display
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Show_Controller_Context_Display(show)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Show_Controller_Context_Display", nil, {show})
		return true
	end	
	return false	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Show_BattleCam_Button
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Show_BattleCam_Button(show)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Show_BattleCam_Button", nil, {show})
		return true
	end	
	return false	
end


-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Flash_Control_Group_Containing_Unit
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Flash_Control_Group_Containing_Unit(unit_ptr)
	local gui_scene = Get_Game_Mode_GUI_Scene()
	
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Flash_Control_Group_Containing_Unit", nil, {unit_ptr})
		return true
	end	
	return false	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- UI_Radar_Map_Zoom_Out
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function UI_Radar_Map_Zoom_Out()

	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Radar_Map_Zoom_Out", nil, {})
		return true
	end	
	return false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Builder_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Builder_Button(_, _)

	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Builder_Button", nil, {})
		return true
	end	
	return false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Builder_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Builder_Button(_, _)

	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Stop_Flash_Builder_Button", nil, {})
		return true
	end	
	return false	
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Research_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Research_Button(_, _)

	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Research_Button", nil, {})
		return true
	end	
	return false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Research_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Research_Button(_, _)

	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Stop_Flash_Research_Button", nil, {})
		return true
	end	
	return false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Research_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Research_Option(branch, suite)
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Start_Flash_Research_Option", nil, {branch, suite})
		return true
	end	
	return false	
end


-- ------------------------------------------------------------------------------------------------------------------
-- UI_Force_Display_Ability
-- ------------------------------------------------------------------------------------------------------------------
function UI_Force_Display_Ability(unit_type_name, ability_name, on_off)
	if not unit_type_name or not ability_name then
		return
	end
	
	local unit_type = Find_Object_Type(unit_type_name)
	if not unit_type then
		return
	end
	
	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("UI_Force_Display_Ability", nil, {unit_type, ability_name, on_off})
		return true
	end	
	return false	
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Update_Selection_Abilities
-- Update units to reflect their newly unlocked or added abilities
-- ------------------------------------------------------------------------------------------------------------------
function UI_Update_Selection_Abilities()
	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene ~= nil then 
		gui_scene.Raise_Event("Selection_Changed", nil, {false})
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Pre_Mission_End
-- ------------------------------------------------------------------------------------------------------------------
function UI_Pre_Mission_End()
	Suspend_Objectives(true) 
	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene then
		gui_scene.Raise_Event("Suspend_Objectives", nil, {true})
	end
	Stop_All_Speech()
	Flush_PIP_Queue()
	Suspend_Hint_System(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_On_Mission_End
-- ------------------------------------------------------------------------------------------------------------------
function UI_On_Mission_End()
	Suspend_Objectives(true) 
	local gui_scene = Get_Game_Mode_GUI_Scene()
	if gui_scene then
		gui_scene.Raise_Event("Suspend_Objectives", nil, {true})
	end
	Stop_All_Speech()
	Flush_PIP_Queue()
	Allow_Speech_Events(false)
	Suspend_Hint_System(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_On_Mission_Start
-- ------------------------------------------------------------------------------------------------------------------
function UI_On_Mission_Start()
	Suspend_Objectives(false) 
	Stop_All_Speech()
	Flush_PIP_Queue()
	Allow_Speech_Events(true)
	Suspend_Hint_System(false)
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	Commit_Profile_Values = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
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
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGHintSystem_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Objective_Text = nil
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
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Loading_Screen_Background = nil
	UI_Set_Loading_Screen_Faction_ID = nil
	UI_Set_Loading_Screen_Mission_Text = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

