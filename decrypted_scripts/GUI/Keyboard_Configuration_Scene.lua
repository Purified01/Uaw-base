if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[187] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Keyboard_Configuration_Scene.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/03/27
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("KeyboardGameCommands")
require("SpecialAbilities")
require("PGUICommands")

-- -------------------------------------------------------------------------------
-- On_Init
-- -------------------------------------------------------------------------------
function On_Init()

	-- Text formatting
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- Game Mode Type
	-- (-1) = none, 0 = strategic, 1 = land]
	-- WARNING: this definition should match the definition of the sub game mode enum in code!!!!
	GAME_MODE_NONE = Declare_Enum(-1)
	GAME_MODE_STRATEGIC = Declare_Enum(0)
	GAME_MODE_LAND = Declare_Enum()
	
	-- Message Type
	-- WARNING: this definition should match the definition of the message type in code!!!!!!
	MESSAGE_TYPE_NONE = Declare_Enum(-1)
	MODE_INDEPENDENT_TO_MODE_DEPENDENT = Declare_Enum(0)
	MODE_DEPENDENT_TO_MODE_INDEPENDENT = Declare_Enum(1)
	GENERIC_TO_FACTION_BASED = Declare_Enum(2)
	FACTION_BASED_TO_GENERIC = Declare_Enum(3)
	
	-- Global variables now MUST be initialized inside functions
	PGColors_Init()
	
	-- VERY IMPORTANT!!! we need to initialize the list of special abilities manually!.
	Initialize_Special_Abilities(false) -- false do not init the key mapping data for the abilities (it is not needed here!)

	DialogShowing = true
	KeyboardConfig.Set_Active(true)
	
	this.Set_Bounds(0, 0, 1, 1)

	List = this.CommandsList
	-- Specify the columns of our menu
	LEFT_MARGIN_COMPONENT = Create_Wide_String("LEFT_MARGIN_COMPONENT")
	UI_COMPONENT_DESCRIPTION = Create_Wide_String("UI_COMPONENT_DESCRIPTION")
	KEY_MAPPING = Create_Wide_String("KEY_MAPPING")
	
	-- Add the columns to the list
	List.Set_Header_Style("NONE") 
	List.Add_Column(LEFT_MARGIN_COMPONENT, JUSTIFY_CENTER) -- we want the icon to be centered.
	List.Add_Column(UI_COMPONENT_DESCRIPTION, JUSTIFY_LEFT, true) -- we want the description text to be left justified and wrapped.
	List.Add_Column(KEY_MAPPING, JUSTIFY_CENTER) -- we want the key mappings to be center justified.
	
	List.Set_Column_Width(LEFT_MARGIN_COMPONENT, 0.05)
	List.Set_Column_Width(UI_COMPONENT_DESCRIPTION, 0.65)
	List.Set_Column_Width(KEY_MAPPING, 0.3)
	List.Refresh()
	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", List, Play_Option_Select_SFX)

	-- allow key navigation
	List.Set_Tab_Order(Declare_Enum(0))
	this.Restore_Defaults_Button.Set_Tab_Order(Declare_Enum())
	this.Apply_Button.Set_Tab_Order(Declare_Enum())
	this.Cancel_Button.Set_Tab_Order(Declare_Enum())
	this.Focus_First()

	Tabs = {}
	Tabs = Find_GUI_Components(this, "Tab")
	for index, tab in pairs(Tabs) do
		this.Register_Event_Handler("Tab_Clicked", tab, On_Tab_Clicked)
	end
	
	this.Tab1.Set_User_Data({"Generic_Interface", GAME_MODE_NONE})
	this.Tab1.Set_Text("TEXT_KEY_CONFIG_TAB_GENERIC_INTERFACE")
	
	-- Rick: Strategic keys are either mirrored by primary controls or aren't yet needed. We should remove this tab if not used.
	-- this.Tab2.Set_User_Data({"Strategic_Interface", GAME_MODE_STRATEGIC})
	-- this.Tab2.Set_Text("TEXT_KEY_CONFIG_TAB_STRATEGIC_INTERFACE")

	this.Tab2.Set_User_Data({"Tactical_Interface", GAME_MODE_LAND})
	this.Tab2.Set_Text("TEXT_KEY_CONFIG_TAB_TACTICAL_INTERFACE")
	
	this.Tab3.Set_User_Data({"Unit_Control", GAME_MODE_LAND})
	this.Tab3.Set_Text("TEXT_KEY_CONFIG_TAB_UNIT_CONTROL")
	
	this.Tab4.Set_User_Data({"NOVUS", GAME_MODE_LAND, "NOVUS"})
	this.Tab4.Set_Text("TEXT_FACTION_NOVUS")
	
	this.Tab5.Set_User_Data({"ALIEN", GAME_MODE_LAND,  "ALIEN"})
	this.Tab5.Set_Text("TEXT_FACTION_ALIEN")
	
	this.Tab6.Set_User_Data({"MASARI", GAME_MODE_LAND, "MASARI"})
	this.Tab6.Set_Text("TEXT_FACTION_MASARI")
	
	this.Tab7.Set_Text("")
	this.Tab7.Set_Hidden(true)
	
	-- Commands that are re-assignable will be displayed in EnabledFont.
	EnabledFont = "KeyboardConfigMenu_Enabled"
	-- Commands that cannot be reassigned will be displayed using DisabledFont.
	DisabledFont = "KeyboardConfigMenu_Disabled"
	
	Update_Apply_Button_State()
	
	GameModeTypeToCommandListName = {}
	GameModeTypeToCommandListName[GAME_MODE_NONE] = {"Generic_Interface"}
	GameModeTypeToCommandListName[GAME_MODE_LAND] = {"Tactical_Interface", "Unit_Control", "ALIEN", "NOVUS", "MASARI"}
	GameModeTypeToCommandListName[GAME_MODE_STRATEGIC] = {"Strategic_Interface"}
	
	GameModeTypeToGameModeText = {}
	GameModeTypeToGameModeText[GAME_MODE_NONE] = Get_Game_Text("TEXT_GENERIC")
	GameModeTypeToGameModeText[GAME_MODE_LAND] = Get_Game_Text("TEXT_TACTICAL")
	GameModeTypeToGameModeText[GAME_MODE_STRATEGIC] = Get_Game_Text("TEXT_STRATEGIC")
	
	this.Register_Event_Handler("Process_New_Key_Combination", nil, On_Process_New_Key_Combination)
	
	-- By default, the Units Tab starts active, thus we get the game mode to LAND. [RECALL: (-1) = none, 0 = strategic, 1 = land]
	CurrentlyProcessing = {}
	CurrentDisplay = "Unit_Control"
	CurrentGameModeType = GAME_MODE_LAND
	CurrentFaction = nil
	SelectedRow = -1
	
	DisplayToDisplayTextID = {}
	DisplayToDisplayTextID["Unit_Control"] = "TEXT_KEY_CONFIG_TAB_UNIT_CONTROL"
	DisplayToDisplayTextID["Generic_Interface"] = "TEXT_KEY_CONFIG_TAB_GENERIC_INTERFACE"
	DisplayToDisplayTextID["Tactical_Interface"] = "TEXT_KEY_CONFIG_TAB_TACTICAL_INTERFACE"
	DisplayToDisplayTextID["Strategic_Interface"] = "TEXT_KEY_CONFIG_TAB_STRATEGIC_INTERFACE"
	DisplayToDisplayTextID["MASARI"] = "TEXT_FACTION_MASARI"
	DisplayToDisplayTextID["NOVUS"] = "TEXT_FACTION_NOVUS"
	DisplayToDisplayTextID["ALIEN"] = "TEXT_FACTION_ALIEN"
	DisplayToDisplayTextID["MILITARY"] = "TEXT_FACTION_MILITARY"
	
	KeyboardConfig.Set_Game_Mode_And_Faction_Modifier(CurrentGameModeType, CurrentFaction)
	Display_List(KeyboardGameCommands[CurrentDisplay])
	-- set the "Unit Control" tab to selected.
	this.Tab3.Set_Selected(true)	
	
	this.Register_Event_Handler("Closing_All_Displays", nil, Esc_Pressed)
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end



-- -------------------------------------------------------------------------------
-- Deselect_All_Tabs
-- -------------------------------------------------------------------------------
function Deselect_All_Tabs()
	for index, tab in pairs(Tabs) do
		tab.Set_Selected(false)
	end
end

-- -------------------------------------------------------------------------------
-- Update_Apply_Button_State
-- -------------------------------------------------------------------------------
function Update_Apply_Button_State()
	this.Apply_Button.Enable(KeyboardConfig.Can_Apply_Changes())
end

-- -------------------------------------------------------------------------------
-- On_Tab_Clicked
-- -------------------------------------------------------------------------------
function On_Tab_Clicked(event, source)

	local user_data = source.Get_User_Data()
	if not user_data then return end
	
	local display = user_data[1]
	if CurrentDisplay == display then return end
	
	local game_mode = user_data[2]
	local faction_modifier = user_data[3]	-- it may be nil!.
	Deselect_All_Tabs()
	
	-- (-1) = none, 0 = strategic, 1 = land
	KeyboardConfig.Set_Game_Mode_And_Faction_Modifier(game_mode, faction_modifier)
	CurrentDisplay = display
	CurrentGameModeType = game_mode
	CurrentFaction = faction_modifier
	List.Set_Selected_Row_Index(-1)
	Display_List(KeyboardGameCommands[CurrentDisplay])
	source.Set_Selected(true)
end


-- -------------------------------------------------------------------------------
-- Get_Folder_Name
-- -------------------------------------------------------------------------------
function Get_Folder_Name(command_table_name)
	local folder_name = Create_Wide_String(" ")
	folder_name.append(Get_Game_Text("TEXT_KEY_CONFIG_REFER_TO_TAB"))
	Replace_Token(folder_name, Get_Game_Text(DisplayToDisplayTextID[command_table_name]), 1)
	return folder_name
end


-- -------------------------------------------------------------------------------
-- Get_Warning_Text
-- -------------------------------------------------------------------------------
function Get_Warning_Text(mssg_type)

	if mssg_type ~= MESSAGE_TYPE_NONE then 
		if mssg_type == MODE_INDEPENDENT_TO_MODE_DEPENDENT then
			CurrentlyProcessing.Text = Get_Game_Text("TEXT_KEY_CONFIG_WARNING_NO_MODE_TO_MODE")			
		elseif mssg_type == MODE_DEPENDENT_TO_MODE_INDEPENDENT then 
			CurrentlyProcessing.Text = Get_Game_Text("TEXT_KEY_CONFIG_WARNING_MODE_TO_NO_MODE")			
		elseif mssg_type == GENERIC_TO_FACTION_BASED then
			CurrentlyProcessing.Text = Get_Game_Text("TEXT_KEY_CONFIG_WARNING_GENERIC_TO_FACTION")
		elseif mssg_type == FACTION_BASED_TO_GENERIC then
			CurrentlyProcessing.Text = Get_Game_Text("TEXT_KEY_CONFIG_WARNING_FACTION_TO_GENERIC")
		else
			MessageBox("No WARNING text?")
		end
		
		Replace_Token(CurrentlyProcessing.Text, CurrentlyProcessing.KeyMapText, 1)
	end	
end

-- -------------------------------------------------------------------------------
-- On_Process_New_Key_Combination - The user has pressed keys as
-- to reassign the current selection's (if any) key bindings.  
-- -------------------------------------------------------------------------------
function On_Process_New_Key_Combination(event, source, key_map_text, bound_commands_list, mssg_type)
	CurrentlyProcessing = {}
	
	-- Set the key map text for the current key combination.
	CurrentlyProcessing.KeyMapText = Create_Wide_String("'")
	CurrentlyProcessing.KeyMapText.append(key_map_text)
	CurrentlyProcessing.KeyMapText.append(Create_Wide_String("'"))
	
	-- It applicable, get the warning text for the notification window.
	Get_Warning_Text(mssg_type)	
	
	local row_index = List.Get_Selected_Row_Index()
	if (row_index == -1) then return end
	
	SelectedRow = row_index
	
	if CurrentDisplay then 
		local selected_command = DisplayedKeys[SelectedRow+1]	
		local commands_list = KeyboardGameCommands[CurrentDisplay]
		local sel_command_data = commands_list[selected_command]
		
		-- if we are trying to assign the same key mapping, just quit!.
		local sel_key_map_text = KeyboardConfig.Get_Game_Command_Mapped_Key_Text(selected_command)
		if sel_key_map_text == key_map_text then
			return
		end
		
		-- Let's make sure the 'seleceted command' is a valid one.
		if not sel_command_data or sel_command_data.can_be_re_assigned == false then 
			-- Play Bad sound?
			local w_sc_description
			local ability_name
			if sel_command_data.text_id then 
				w_sc_description = Get_Game_Text(sel_command_data.text_id)
			elseif sel_command_data.generic_unit_ability_name then
				ability_name = sel_command_data.generic_unit_ability_name
			elseif sel_command_data.unit_ability_name then 
				ability_name = sel_command_data.unit_ability_name
			end
			
			if ability_name then
				local ab = SpecialAbilities[ability_name]
				if ab.text_id then 
					w_sc_description = Get_Game_Text(ab.text_id)
				end		
			end
			
			if w_sc_description then 
				Report_Invalid_Command_Selection(w_sc_description)
			end
			return
		end
		
		CurrentlyProcessing.SelectedCommand = selected_command
		
		-- Now go through the list of bound commands (if any) and check to see whether they are assignable or not. 
		-- Also, retrieve any information pertaining them.
		if bound_commands_list and #bound_commands_list > 0 then
			for i = 1, #bound_commands_list do
				local data = bound_commands_list[i]
				local bc_name = data.CommandName
				
				if data.Faction then 
					local command_table = KeyboardGameCommands[data.Faction]
					if command_table then 
						bc_data = command_table[bc_name]
						if bc_data then 
						
							local w_bc_description
							local ability_name
							if bc_data.text_id then 
								w_bc_description = Get_Game_Text(bc_data.text_id)
							elseif bc_data.unit_ability_name then 
								ability_name = bc_data.unit_ability_name
							elseif bc_data.generic_unit_ability_name then
								ability_name = bc_data.generic_unit_ability_name							
							end
							
							if ability_name then
								local ab = SpecialAbilities[ability_name]
								if ab.text_id then 
									w_bc_description = Get_Game_Text(ab.text_id)
								end	
							end
							
							if bc_data.can_be_re_assigned == false then

								local folder_name = nil
								if bc_data.display == true and data.Faction ~= CurrentDisplay then
									folder_name = data.Faction
								end
								local no_show = (not bc_data.display)
								
								Report_Invalid_Key_Mapping(CurrentlyProcessing.KeyMapText, w_bc_description, folder_name, no_show)							
								return					
							else
								-- start creating the text that will be displayed in the confirmation window.
								if not CurrentlyProcessing.Text then 
									CurrentlyProcessing.Text = Create_Wide_String("")
								end
								
								local w_text
								if mssg_type ~= MESSAGE_TYPE_NONE then 
									w_text = Get_Game_Text("TEXT_KEY_CONFIG_ASSIGNED_COMMAND")
									Replace_Token(w_text, Get_Game_Text(DisplayToDisplayTextID[data.Faction]), 1)
									w_text.append(Create_Wide_String("\n"))
								else
									w_text = Get_Game_Text("TEXT_IS_ALREADY_ASSIGNED_TO")							
									Replace_Token(w_text, CurrentlyProcessing.KeyMapText, 1)
								end
								Replace_Token(w_text, w_bc_description, 2)
								CurrentlyProcessing.Text.append(w_text)
							end
						end
					end
				else
					-- we must locate the proper table by going through all the tables associated to the specified game mode type.
					for _, command_table_name in pairs(GameModeTypeToCommandListName[data.GameMode]) do
						local command_table = KeyboardGameCommands[command_table_name]
						local bc_data = command_table[bc_name]
						if bc_data then 
						
							local w_bc_description
							if bc_data.text_id then 
								w_bc_description = Get_Game_Text(bc_data.text_id)
							elseif bc_data.unit_ability_name then 
								ability_name = bc_data.unit_ability_name
							elseif bc_data.generic_unit_ability_name then
								ability_name = bc_data.generic_unit_ability_name							
							end
							
							if ability_name then
								local ab = SpecialAbilities[ability_name]
								if ab.text_id then 
									w_bc_description = Get_Game_Text(ab.text_id)
								end	
							end
							
							if bc_data.can_be_re_assigned == false then 
								
								local folder_name = nil
								if bc_data.display == true and command_table_name ~= CurrentDisplay then
									folder_name = command_table_name
								end
								local no_show = (not bc_data.display)
								
								Report_Invalid_Key_Mapping(CurrentlyProcessing.KeyMapText, w_bc_description, folder_name, no_show)							
								return					
							else
								-- start creating the text that will be displayed in the confirmation window.
								if not CurrentlyProcessing.Text then 
									CurrentlyProcessing.Text = Create_Wide_String("")
								end
								
								local w_text
								if mssg_type ~= MESSAGE_TYPE_NONE then 
									w_text = Get_Game_Text("TEXT_KEY_CONFIG_ASSIGNED_COMMAND")
									Replace_Token(w_text, GameModeTypeToGameModeText[data.GameMode], 1)
								else
									w_text = Get_Game_Text("TEXT_IS_ALREADY_ASSIGNED_TO")							
									Replace_Token(w_text, CurrentlyProcessing.KeyMapText, 1)
								end
								Replace_Token(w_text, w_bc_description, 2)
								
								if bc_data.display == true and command_table_name ~= CurrentDisplay then 
									-- Point the user as to where to find the offending command.
									w_text.append(Get_Folder_Name(command_table_name))
								elseif bc_data.display == false then
									w_text.append(Get_Game_Text("TEXT_KEY_CONFIG_COMMAND_NOT_SHOWN"))
									w_text.append(Create_Wide_String("\n"))
								else
									w_text.append(Create_Wide_String("\n"))
								end
								
								CurrentlyProcessing.Text.append(w_text)
								break
							end
						end
					end	
				end
			end
			Prompt_Confirm_Changes()
		else
			-- just go ahead and set up this new mapping
			Set_Current_Key_Mapping()
		end
	end
end


-- -------------------------------------------------------------------------------
-- Report_Invalid_Key_Mapping
-- -------------------------------------------------------------------------------
function Report_Invalid_Key_Mapping(key_map, command_desc, folder_name, no_show)

	local message = Get_Game_Text("TEXT_KEY_CONFIG_INVALID_KEY_MAPPING")
	Replace_Token(message, Get_Game_Text("TEXT_KEY_CONFIG_IS_BOUND_TO_NON_ASSIGNABLE_COMMAND"), 1)
	Replace_Token(message, key_map, 1)
	local quoted_desc = Create_Wide_String("'")
	command_desc.append(quoted_desc)
	quoted_desc.append(command_desc)
	Replace_Token(message, quoted_desc, 2)
	
	if folder_name then 
		-- Point the user as to where to find the offending command.
		message.append(Get_Folder_Name(folder_name))
	elseif no_show == true then
		message.append(Get_Game_Text("TEXT_KEY_CONFIG_COMMAND_NOT_SHOWN"))
	else
		message.append(Create_Wide_String("\n"))
	end
	
	-- Play bad sound?	
	Open_Notification_Dialog(message)
end



-- -------------------------------------------------------------------------------
-- Report_Invalid_Command_Selection
-- -------------------------------------------------------------------------------
function Report_Invalid_Command_Selection(command_description)

	local message = Get_Game_Text("TEXT_KEY_CONFIG_INVALID_COMMAND_SELECTION")
	Replace_Token(message, Get_Game_Text("TEXT_KEY_CONFIG_COMMAND_CANNOT_BE_REASSIGNED"), 1)
	local quoted_desc = Create_Wide_String("'")
	command_description.append(quoted_desc)
	quoted_desc.append(command_description)
	Replace_Token(message, quoted_desc, 1) 
	
	-- Play bad sound?	
	Open_Notification_Dialog(message)
end


-- -------------------------------------------------------------------------------
-- Open_Notification_Dialog
-- -------------------------------------------------------------------------------
function Open_Notification_Dialog(message)
	if not TestValid(this.Confirm_Report_Changes_Dlg) then
		local handle = Create_Embedded_Scene("KC_Confirm_Changes_Dialog", this, "Confirm_Report_Changes_Dlg")
		this.Confirm_Report_Changes_Dlg.Set_Screen_Position(0.5, 0.5)		
	else
		this.Confirm_Report_Changes_Dlg.Set_Hidden(false)
	end
	-- De-activate the KC dialog so that it doesn't process any keys until this dialog is closed.
	KeyboardConfig.Set_Ok_Cancel_Dialog_Active(true)
	this.Confirm_Report_Changes_Dlg.Start_Modal(Notification_Dialog_Closed)
	this.Confirm_Report_Changes_Dlg.Set_Reporting_Mode()
	this.Confirm_Report_Changes_Dlg.Setup_Display(message)
end


-- -------------------------------------------------------------------------------
-- Notification_Dialog_Closed
-- -------------------------------------------------------------------------------
function Notification_Dialog_Closed()
	KeyboardConfig.Set_Ok_Cancel_Dialog_Active(false)
end

-- -------------------------------------------------------------------------------
-- Prompt_Confirm_Changes
-- -------------------------------------------------------------------------------
function Prompt_Confirm_Changes(mssg)
	if not TestValid(this.Confirm_Report_Changes_Dlg) then
		local handle = Create_Embedded_Scene("KC_Confirm_Changes_Dialog", this, "Confirm_Report_Changes_Dlg")
		this.Confirm_Report_Changes_Dlg.Set_Screen_Position(0.5, 0.5)		
	else
		this.Confirm_Report_Changes_Dlg.Set_Hidden(false)
	end
	-- De-activate the KC dialog so that it doesn't process any keys until this dialog is closed.
	KeyboardConfig.Set_Ok_Cancel_Dialog_Active(true)
	this.Confirm_Report_Changes_Dlg.Start_Modal(Confirm_Changes)
	this.Confirm_Report_Changes_Dlg.Setup_Display(CurrentlyProcessing.Text)
end
	
-- -------------------------------------------------------------------------------
-- Confirm_Changes
-- -------------------------------------------------------------------------------
function Confirm_Changes(dlg, ok_cancel)
	if ok_cancel == nil then return end
	
	if ok_cancel == true then -- the user pressed the OK button
		Set_Current_Key_Mapping()
	end
	
	KeyboardConfig.Set_Ok_Cancel_Dialog_Active(false)
end

-- -------------------------------------------------------------------------------
-- Set_Current_Key_Mapping
-- -------------------------------------------------------------------------------
function Set_Current_Key_Mapping()
	-- If we can go ahead, then report back to code with the command to be
	-- re-mapped.
	if CurrentlyProcessing.SelectedCommand ~= nil then 
		
		KeyboardConfig.Bind_Current_Key_Assignment_To_Command(CurrentlyProcessing.SelectedCommand)
		
		-- Update the display status of the apply button
		Update_Apply_Button_State()
		
		-- Refresh the list display since key bindings must be updated
		Display_List(KeyboardGameCommands[CurrentDisplay])
	end
end

-- -------------------------------------------------------------------------------
-- On_Restore_Defaults_Button_Clicked
-- -------------------------------------------------------------------------------
function On_Restore_Defaults_Button_Clicked(event, source)
	KeyboardConfig.Restore_Defaults()
	
	-- Refresh the display since key bindings must be updated
	Display_List(KeyboardGameCommands[CurrentDisplay])
	
	-- Update the display status of the apply button
	Update_Apply_Button_State()
end


-- -------------------------------------------------------------------------------
-- On_Cancel_Button_Clicked
-- -------------------------------------------------------------------------------
function On_Cancel_Button_Clicked(event, source)
	if (this ~= nil) then
		On_Dialog_Hidden()
	end
end

-- -------------------------------------------------------------------------------
-- On_Apply_Button_Clicked
-- -------------------------------------------------------------------------------
function On_Apply_Button_Clicked(event, source)
	KeyboardConfig.Apply_Changes()
	if (this ~= nil) then
		On_Dialog_Hidden()
	end
	Raise_Event_Immediate_All_Scenes("Key_Mappings_Data_Changed", nil)
end

-- -------------------------------------------------------------------------------
-- On_Dialog_Hidden
-- -------------------------------------------------------------------------------
function On_Dialog_Hidden(event, source)
	DialogShowing = false
	KeyboardConfig.Set_Active(false)

	-- Raise parent dialog -- NADER [4/13/2007]
	GUI_Dialog_Raise_Parent()
end


-- -------------------------------------------------------------------------------
-- On_Dialog_Displayed
-- -------------------------------------------------------------------------------
function On_Dialog_Displayed(event, source)
	DialogShowing = true
	KeyboardConfig.Set_Active(true)
	Display_List(KeyboardGameCommands[CurrentDisplay])
	Update_Apply_Button_State()
end

-- ------------------------------------------------------------------------------
-- Display_List
-- ------------------------------------------------------------------------------
function Display_List(commands_list)
	
	List.Clear()
	
	if not commands_list then return end
	
	if CurrentDisplay == "Strategic_Interface" then
		local new_row = List.Add_Row()
		local w_desc = Create_Wide_String("Strategic Commands COMING SOON!")
		List.Set_Text_Data(UI_COMPONENT_DESCRIPTION, new_row, w_desc)
		return
	end
	
	local all_keys = {}
	DisplayedKeys = {}
	
	for key, val in pairs(commands_list) do
		table.insert(all_keys, key)
	end
	
	table.sort(all_keys)
	
	local enable_text = true
	local key_sort_count = #all_keys
	local key_sort_value = 0
	while key_sort_count > 0 do
	   for i = 1, #all_keys do
		   local key = all_keys[i]
		   local command_data = commands_list[key]
		   if command_data.sort_order == key_sort_value then
		      key_sort_count = key_sort_count - 1
		      if command_data.display == true then 
			      table.insert(DisplayedKeys, key)
			      local new_row = List.Add_Row()
      			
			      if command_data.can_be_re_assigned == true then 
				      List.Set_Row_Font(new_row, EnabledFont)
			      else
				      List.Set_Row_Font(new_row, DisabledFont)
			      end
      			
			      Add_Description(new_row, command_data)
			      Add_Key_Mapping(new_row, key)
		      end		
		   end
		end
	   key_sort_value = key_sort_value + 1
	end
		
	List.Refresh()
end


-- -------------------------------------------------------------------------------
-- Add_Description
-- -------------------------------------------------------------------------------
function Add_Description(row, command_data)


	local w_desc = Create_Wide_String("")
	local ability_name
	-- If Ability, add the prefix : ACTIVATE
	if command_data.unit_ability_name then 
		ability_name = command_data.unit_ability_name
	elseif command_data.generic_unit_ability_name then
		ability_name = command_data.generic_unit_ability_name							
	elseif command_data.hero_name then -- If hero, add the prefix : ACCESS
	
		w_desc = Get_Game_Text("TEXT_KEY_CONFIG_HERO_ACCESS")
		if command_data.text_id then
			Replace_Token(w_desc, Get_Game_Text(command_data.text_id), 1)
		else
			Replace_Token(w_desc, Create_Wide_String(""), 1)
		end
	elseif command_data.text_id then 	
		w_desc = Get_Game_Text(command_data.text_id)	
	end
	
	if ability_name then 
		local ab_data = SpecialAbilities[ability_name]
		
		if ab_data then
			if command_data.object_text_id then 
				w_desc.append(Get_Game_Text(command_data.object_text_id)) 
				w_desc.append(Create_Wide_String(": "))
			end
			
			if ab_data.text_id then
				w_desc.append(Get_Game_Text(ab_data.text_id))
			end		
		end				
	end
	
	List.Set_Text_Data(UI_COMPONENT_DESCRIPTION, row, w_desc)
end


-- -------------------------------------------------------------------------------
-- Add_Key_Mapping
-- -------------------------------------------------------------------------------
function Add_Key_Mapping(row, command_name)
	local key_map_text = KeyboardConfig.Get_Game_Command_Mapped_Key_Text(command_name)
	
	if key_map_text then 
		List.Set_Text_Data(KEY_MAPPING, row, key_map_text)
	else
		List.Set_Text_Data(KEY_MAPPING, row, "TEXT_KEY_CONFIG_UNASIGNED_COMMAND")
	end
end


------------------------------------------------------------------------------
-- Is_Showing
------------------------------------------------------------------------------
function Is_Showing()
	return DialogShowing
end

------------------------------------------------------------------------------
-- Esc_Pressed
------------------------------------------------------------------------------
function Esc_Pressed()
	--Only respond to Esc if we're not part of the in-game dialog stack - in that
	--case Esc is handled elsewhere
	local user_data = this.Get_User_Data()
	if not user_data or not TestValid(user_data.Parent_Dialog) then
		On_Dialog_Hidden()
	end 	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Showing = Is_Showing

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
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_GUI_Variable = nil
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

