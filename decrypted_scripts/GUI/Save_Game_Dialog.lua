if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[33] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[207] = true
LuaGlobalCommandLinks[118] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Button_Clicked", this.Controls.SaveButton, Save_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.DeleteButton, Delete_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.CancelButton, Hide_Dialog)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Key_Press", this.Controls.SaveGameEditBox, On_Key_Press)

	Mode = SAVE_LOAD_MODE_INVALID

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	SavesList = this.Controls.SaveGamesList
	SaveGameEditBox = this.Controls.SaveGameEditBox

	SAVE_GAME = Create_Wide_String("SAVE_GAME")
	TIMESTAMP = Create_Wide_String("TIMESTAMP")
	AUTO_SAVE_STRING = Create_Wide_String("[AutoSave]")
	QUICK_SAVE_STRING = Create_Wide_String("[QuickSave]")
	DEFAULT_AUTO_RECORD_NAME = Create_Wide_String("AutoSave")

	-- Specify the column for the list box
	SavesList.Set_Header_Style("NONE")
	SavesList.Add_Column(SAVE_GAME, JUSTIFY_LEFT) -- The column for the save game name
	SavesList.Add_Column(TIMESTAMP, JUSTIFY_RIGHT) -- The column for the time stamp
	SavesList.Set_Column_Width(SAVE_GAME, 0.65)
	SavesList.Refresh()
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", SavesList, Play_Option_Select_SFX)	

	-- Tab order
	-- This seems to be the reverse order of what I want, but it works properly, weird...
	this.Controls.SaveGameEditBox.Set_Tab_Order(Declare_Enum(0))
	this.Controls.CancelButton.Set_Tab_Order(Declare_Enum())
	this.Controls.DeleteButton.Set_Tab_Order(Declare_Enum())
	this.Controls.SaveButton.Set_Tab_Order(Declare_Enum())

	Dialog_Box_Common_Init()

	Delete_Dialog_Params = { }
	Delete_Dialog_Params.script = Script
	Delete_Dialog_Params.spawned_from_script = true
	Delete_Dialog_Params.callback = "Delete_Confirm_Callback"
	Delete_Dialog_Params.caption = Get_Game_Text("TEXT_DELETE_CONFIRM")
	Delete_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Delete_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_YES")

	Save_Dialog_Params = { }
	Save_Dialog_Params.script = Script
	Save_Dialog_Params.spawned_from_script = true
	Save_Dialog_Params.callback = "Save_Confirm_Callback"
	Save_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_CONFIRM")
	Save_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Save_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_YES")

	Saving_Dialog_Params = { }
	Saving_Dialog_Params.spawned_from_script = true
	Saving_Dialog_Params.caption = Get_Game_Text("TEXT_SAVELOAD_SAVING_MSG")

	Saved_Ok_Dialog_Params = { }
	Saved_Ok_Dialog_Params.script = Script
	Saved_Ok_Dialog_Params.spawned_from_script = true
	Saved_Ok_Dialog_Params.callback = "Saved_OK_Callback"
	Saved_Ok_Dialog_Params.caption = Get_Game_Text("TEXT_SAVED_OK")
	Saved_Ok_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")

	Saved_Replay_Ok_Dialog_Params = { }
	Saved_Replay_Ok_Dialog_Params.script = Script
	Saved_Replay_Ok_Dialog_Params.spawned_from_script = true
	Saved_Replay_Ok_Dialog_Params.callback = "Saved_OK_Callback"
	Saved_Replay_Ok_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_REPLAY_OK")
	Saved_Replay_Ok_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")

	Max_Saves_Dialog_Params = { }
	Max_Saves_Dialog_Params.spawned_from_script = true
	Max_Saves_Dialog_Params.caption = Get_Game_Text("TEXT_SAVELOAD_MAX_SAVES_MSG")
	Max_Saves_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")

	Save_Failed_Dialog_Params = { }
	Save_Failed_Dialog_Params.spawned_from_script = true
	Save_Failed_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_FAILED")
	Save_Failed_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")

	Save_Replay_Failed_Dialog_Params = { }
	Save_Replay_Failed_Dialog_Params.spawned_from_script = true
	Save_Replay_Failed_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_REPLAY_FAILED")
	Save_Replay_Failed_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_OK")

	Default_Save_Game_Name = Create_Wide_String()
	Default_Save_Game_Seperator = Create_Wide_String(" - ")
	SaveGameEditBox.Set_Text_Limit(50) -- MLL: Clamp the text so that it won't get cut off in the Load_Game_Dialog.

	DontDisplayDialog = false
	Overwrite = false

	if SaveLoadManager == nil then
		Register_Save_Load_Commands()
	end
	SaveLoadManager.Reset()
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

function Spawned_From_Battle_End()
	Is_Spawned_From_Battle_End = true
end

function Display_Dialog()
	if DontDisplayDialog then
		DontDisplayDialog = false
		Hide_Dialog()
		return
	end


	Display_Save_Games()

	SaveGameEditBox.Set_Text(Get_Default_Save_Game_Name())

	if not Is_Replay_Mode() and SaveLoadManager.Is_Game_List_Full() then
		Spawn_Dialog_Box(Delete_Dialog_Params, "SimpleDialogBox")
		this.Controls.SaveGameButton.Enable(false)
	end

	-- So this editbox can get keyboard focus
	this.Focus_First()
end

function Get_Default_Save_Game_Name()
	local player = Find_Player("local")
	local map = Get_Current_Map_Name()
	local level = Get_Level_Name()
	local seperator = Default_Save_Game_Seperator

	if level then
		-- MLL: The level name has the faction baked in.
		Default_Save_Game_Name.assign(level)
	else
		Default_Save_Game_Name.assign(player.Get_Faction_Display_Name())
		if map then
			Default_Save_Game_Name.append(seperator).append(map)
		end
	end

	--[[
	if Mode == SAVE_LOAD_MODE_REPLAY then
		Default_Save_Game_Name.append(seperator).append(Get_Localized_Formatted_Number.Get_Current_Date_Time())
	end
	]]

	return Default_Save_Game_Name
end

function Hide_Dialog()
	if Is_Spawned_From_Battle_End then
		this.End_Modal()
	end
	GUI_Dialog_Raise_Parent()
end

function Display_Save_Games()
	SavesList.Clear()
	SaveLoadManager.Init(Mode) -- init each time to refresh the game list
	SaveGames = SaveLoadManager.Generate_Sorted_Save_Game_List()

	if not Is_Replay_Mode() then
		Highlighted_Slot = -1

		Empty_Slot = SaveLoadManager.Get_First_Empty_Slot()
		if Empty_Slot ~= -1 then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_EMPTY_SLOT"))
			SavesList.Set_Selected_Row_Index(0)
		end
	elseif Mode == SAVE_LOAD_MODE_REPLAY then
		Highlighted_Replay = Create_Wide_String()
		local new_row = SavesList.Add_Row()
		SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_EMPTY_SLOT"))
		SavesList.Set_Selected_Row_Index(0)
	end

	if SaveGames == nil then return end

	for key, save_data in pairs(SaveGames) do
		local new_row = SavesList.Add_Row()
		-- color replays by version
		if Mode == SAVE_LOAD_MODE_REPLAY then
			if save_data.IsCurrent then
				SavesList.Set_Row_Color(new_row, 1.0, 1.0, 1.0, 1.0)
			else
				SavesList.Set_Row_Color(new_row, 1.0, 0.0, 0.0, 1.0)
			end
		end
		SavesList.Set_Text_Data(SAVE_GAME, new_row, save_data.Description)
		SavesList.Set_Text_Data(TIMESTAMP, new_row, save_data.Timestamp)
	end
end

function Save_Clicked(event_name, source)
	-- TODO - Support case where there are no save slots available
	if not Is_Replay_Mode() and SaveLoadManager.Is_Game_List_Full() and Highlighted_Slot == Empty_Slot then
		Spawn_Dialog_Box(Max_Saves_Dialog_Params)
		return
	end

	if not Is_Replay_Mode() then
		local description = SaveGameEditBox.Get_Text()
		if Is_Multiplayer_Skirmish() or Need_To_Overwrite() then
			Save_Current(false)
		elseif not description.empty() then
			Save_Slot = Empty_Slot
			-- Spawn_Dialog_Box(Saving_Dialog_Params)
			-- Dialog_Box_Opened = true
			Save_Current(true)
		end
	elseif Mode == SAVE_LOAD_MODE_REPLAY then
		Highlighted_Replay = SaveGameEditBox.Get_Text()
		if Highlighted_Replay.compare(DEFAULT_AUTO_RECORD_NAME) ~= 0 then
			if Need_To_Overwrite() then
				Save_Current(false)
			elseif not Highlighted_Replay.empty() then
				Save_Current(true)
			end
		end
	end
end

function Need_To_Overwrite()
	if not Is_Replay_Mode() and Highlighted_Slot ~= Empty_Slot then
		local description = SaveGameEditBox.Get_Text()
		local slot_data = SaveLoadManager.Get_Slot_Description(Highlighted_Slot)
		if description == slot_data.Description then
			return true
		end
	elseif Mode == SAVE_LOAD_MODE_REPLAY then
		for key, save_data in pairs(SaveGames) do
			if Highlighted_Replay == save_data.Description then
				return true
			end
		end
	else -- MLL: Since the save game descriptions are now the same as their save file names, there can't be duplicate descriptions.
		local description = SaveGameEditBox.Get_Text()
		for key, save_data in pairs(SaveGames) do
			if description == save_data.Description then
				return true
			end
		end
	end

	return false
end

function Delete_Clicked(event_name, source)
	if not Is_Replay_Mode() and Highlighted_Slot ~= -1 and Highlighted_Slot ~= Empty_Slot then 
		Spawn_Dialog_Box(Delete_Dialog_Params, "SimpleDialogBox")
	elseif Mode == SAVE_LOAD_MODE_REPLAY and Highlighted_Index > 0 and
		not Highlighted_Replay.empty() and Highlighted_Replay.compare(DEFAULT_AUTO_RECORD_NAME) ~= 0 then
		Spawn_Dialog_Box(Delete_Dialog_Params, "SimpleDialogBox")
	end
end

function Delete_Confirm_Callback(button)
	if button == 1 then
		if not Is_Replay_Mode() then
			SaveLoadManager.Delete(Highlighted_Slot)
		elseif Mode == SAVE_LOAD_MODE_REPLAY then
			SaveLoadManager.Delete(SaveLoadManager.Get_Full_Replay_Name(Highlighted_Replay))
		end
		Display_Save_Games()
		this.Get_Containing_Scene().Raise_Event("Save_File_Deleted", nil, nil)
	end
end

function Save_Confirm_Callback(button)
	if button == 1 then
		if not Is_Replay_Mode() and Is_Multiplayer_Skirmish() then
			SaveLoadManager.Send_Save_Game_Event(Save_Slot, SaveDescription)
		else
			-- Deactivate the current DialogBox
			-- Spawn_Dialog_Box(Saving_Dialog_Params)
			-- Dialog_Box_Opened = true
			--The Raise_Parent from the confirmation dialog box will have unhidden this dialog,
			--which we probably don't want
			this.Set_Hidden(true)
			Overwrite = true
			Save_Current(true)
			Overwrite = false
		end
	end
end

function Saved_OK_Callback(button)
	DontDisplayDialog = true
end

function Save_Current(confirmed)
	local save_ok = false
	local tried_to_save = false
	if not Is_Replay_Mode() then
		local description = SaveGameEditBox.Get_Text()
		if description == AUTO_SAVE_STRING or description == QUICK_SAVE_STRING then
			SaveGameEditBox.Set_Text("")
			return
		end

		if Highlighted_Index ~= -1 then
			SaveDescription = description

			if not Dialog_Box_Opened then
				Save_Slot = Highlighted_Slot
			end

			-- MLL: The user has changed the name of an existing save.
			if confirmed and Save_Slot ~= Empty_Slot then
				local slot_data = SaveLoadManager.Get_Slot_Description(Save_Slot)
				if description ~= slot_data.Description then
					Save_Slot = Empty_Slot
				end
			end

			if confirmed then
				tried_to_save = true
				if Is_Multiplayer_Skirmish() then
					save_ok = SaveLoadManager.Send_Save_Game_Event(Save_Slot, SaveDescription)
					return
				else
					save_ok = SaveLoadManager.Save(Save_Slot, SaveDescription, Overwrite)
				end
			else
				Spawn_Dialog_Box(Save_Dialog_Params, "SimpleDialogBox")
			end
		end
	elseif Mode == SAVE_LOAD_MODE_REPLAY then
		if Highlighted_Index ~= -1 then
			SaveDescription = Highlighted_Replay

			if confirmed then
				tried_to_save = true
				save_ok = SaveLoadManager.Save(SaveDescription)
			else
				Spawn_Dialog_Box(Save_Dialog_Params, "SimpleDialogBox")
			end
		end
	end

	if tried_to_save then
		if save_ok then
			if Is_Replay_Mode() then
				Spawn_Dialog_Box(Saved_Replay_Ok_Dialog_Params, "SimpleDialogBox")
			else
				Spawn_Dialog_Box(Saved_Ok_Dialog_Params, "SimpleDialogBox")
			end
		else
			if Is_Replay_Mode() then
				Spawn_Dialog_Box(Save_Replay_Failed_Dialog_Params, "SimpleDialogBox")
			else
				Spawn_Dialog_Box(Save_Failed_Dialog_Params, "SimpleDialogBox")
			end			
		end
	end
end

function On_Update()
	if Dialog_Box_Opened then
		Save_Current(true)
		Dialog_Box_Opened = false
	end

	Last_Selected = Highlighted_Index
	Highlighted_Index = SavesList.Get_Selected_Row_Index()
	if SaveGames ~= nil then
		if not Is_Replay_Mode() then
			if Highlighted_Index == 0 then
				Highlighted_Slot = Empty_Slot
			elseif Highlighted_Index ~= -1 then
				Highlighted_Slot = SaveGames[Highlighted_Index].Slot
			end
		elseif Mode == SAVE_LOAD_MODE_REPLAY then
			if Highlighted_Index > 0 then
				Highlighted_Replay = SavesList.Get_Text_Data(SAVE_GAME, Highlighted_Index)
			else
				Highlighted_Replay = Get_Default_Save_Game_Name()
			end
		end
	end

	if Highlighted_Index ~= Last_Selected then
		Last_Selected = Highlighted_Index
		if not Is_Replay_Mode() then
			if Highlighted_Slot ~= Empty_Slot then
				local slot_data = SaveLoadManager.Get_Slot_Description(Highlighted_Slot)
				if slot_data then
					SaveGameEditBox.Set_Text(slot_data.Description)
				else
					SaveGameEditBox.Set_Text(Get_Default_Save_Game_Name())
				end
			else
				SaveGameEditBox.Set_Text(Get_Default_Save_Game_Name())
			end
		elseif Mode == SAVE_LOAD_MODE_REPLAY then
			SaveGameEditBox.Set_Text(Highlighted_Replay)
		end
	end

	-- Needed for Xbox version
	SaveLoadManager.Update()
	-- On the Xbox, the user may change the storage device so the save list will also change
	if this.Is_Modal_Scene() then
		if SaveLoadManager.Get_List_Needs_Refresh() then
			Display_Save_Games()
		end
	end
end

function On_Key_Press(event_name, source, key)
	if (string.byte(key, 1) == 13) then
		Save_Clicked(event_name, source)
	end
end

function Set_Mode(mode)
	Mode = mode
	
	if(Is_Replay_Mode()) then
		this.Controls.Text_1.Set_Text("TEXT_BUTTON_SAVE_REPLAY_UPPER")
	else
		this.Controls.Text_1.Set_Text("TEXT_SAVE_GAME_TITLE")
	end
end

function Is_Replay_Mode()
	return Mode == SAVE_LOAD_MODE_REPLAY
end

Interface = { }
Interface.Set_Mode = Set_Mode
Interface.Display_Dialog = Display_Dialog
Interface.Spawned_From_Battle_End = Spawned_From_Battle_End
Interface.Hide_Dialog = Hide_Dialog
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
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
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
