if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[207] = true
LuaGlobalCommandLinks[118] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Save_Clicked)
	this.Register_Event_Handler("Controller_Y_Button_Up", nil, Change_Storage_Clicked)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, Delete_Clicked)

	Mode = SAVE_LOAD_MODE_INVALID

	SavePending = false
	SaveDelay = 0
	InsufficientSpace = false
	if TestValid(this.Controls.SaveMessage) then
		SaveMessage = this.Controls.SaveMessage
		SaveMessage.Set_Hidden(true)
	end

	if TestValid(this.Controls.StorageChangedMessage) then
		StorageChangedMessage = this.Controls.StorageChangedMessage
		StorageChangedMessage.Set_Hidden(true)
	end

	if TestValid(this.Controls.SaveGamesList) then
		Set_Keyboard_Focus(this.Controls.SaveGamesList)
	end

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	NumSaveGames = 0
	CheckingIndex = 1
	SavesList = this.Controls.SaveGamesList

	SAVE_GAME = Create_Wide_String("SAVE_GAME")
	TIMESTAMP = Create_Wide_String("TIMESTAMP")
	AUTO_SAVE_STRING = Create_Wide_String("[AutoSave]")
	QUICK_SAVE_STRING = Create_Wide_String("[QuickSave]")
	DEFAULT_AUTO_RECORD_NAME = Create_Wide_String("AutoSave")
	CORRUPT_FILE_STRING = Get_Game_Text("TEXT_GAMEPAD_SAVE_GAME_CORRUPT_FILENAME")

	-- Specify the column for the list box
	SavesList.Set_Header_Style("NONE")
	SavesList.Add_Column(SAVE_GAME, JUSTIFY_LEFT) -- The column for the save game name
	SavesList.Refresh()
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", SavesList, Play_Option_Select_SFX)	

	-- Tab order
	SavesList.Set_Tab_Order(Declare_Enum(0))

	Dialog_Box_Common_Init()

	Delete_Dialog_Params = { }
	Delete_Dialog_Params.script = Script
	Delete_Dialog_Params.spawned_from_script = true
	Delete_Dialog_Params.callback = "Delete_Confirm_Callback"
	Delete_Dialog_Params.caption = Get_Game_Text("TEXT_DELETE_CONFIRM")
	Delete_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Delete_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")

	Save_Dialog_Params = { }
	Save_Dialog_Params.script = Script
	Save_Dialog_Params.spawned_from_script = true
	Save_Dialog_Params.callback = "Save_Confirm_Callback"
	Save_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_CONFIRM")
	Save_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Save_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")

	Saving_Dialog_Params = { }
	Saving_Dialog_Params.spawned_from_script = true
	Saving_Dialog_Params.caption = Get_Game_Text("TEXT_SAVELOAD_SAVING_MSG")

	Saved_Ok_Dialog_Params = { }
	Saved_Ok_Dialog_Params.script = Script
	Saved_Ok_Dialog_Params.spawned_from_script = true
	Saved_Ok_Dialog_Params.callback = "Saved_OK_Callback"
	Saved_Ok_Dialog_Params.caption = Get_Game_Text("TEXT_SAVED_OK")
	Saved_Ok_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")

	Saved_Replay_Ok_Dialog_Params = { }
	Saved_Replay_Ok_Dialog_Params.script = Script
	Saved_Replay_Ok_Dialog_Params.spawned_from_script = true
	Saved_Replay_Ok_Dialog_Params.callback = "Saved_OK_Callback"
	Saved_Replay_Ok_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_REPLAY_OK")
	Saved_Replay_Ok_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")

	Max_Saves_Dialog_Params = { }
	Max_Saves_Dialog_Params.spawned_from_script = true
	Max_Saves_Dialog_Params.caption = Get_Game_Text("TEXT_SAVELOAD_MAX_SAVES_MSG")
	Max_Saves_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")

	Save_Failed_Dialog_Params = { }
	Save_Failed_Dialog_Params.spawned_from_script = true
	Save_Failed_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_FAILED")
	Save_Failed_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")

	Save_Replay_Failed_Dialog_Params = { }
	Save_Replay_Failed_Dialog_Params.spawned_from_script = true
	Save_Replay_Failed_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_REPLAY_FAILED")
	Save_Replay_Failed_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")

	Save_Failed_Invalid_Device_Dialog_Params = { }
	Save_Failed_Invalid_Device_Dialog_Params.spawned_from_script = true
	Save_Failed_Invalid_Device_Dialog_Params.caption = Get_Game_Text("TEXT_GAMEPAD_STORAGE_DEVICE_CHANGED")
	Save_Failed_Invalid_Device_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")

	Save_Failed_Insufficient_Space_Dialog_Params = { }
	Save_Failed_Insufficient_Space_Dialog_Params.script = Script
	Save_Failed_Insufficient_Space_Dialog_Params.spawned_from_script = true
	Save_Failed_Insufficient_Space_Dialog_Params.caption = Get_Game_Text("TEXT_SAVE_FAILED_INSUFFICIENT_SPACE")
	Save_Failed_Insufficient_Space_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")
	Save_Failed_Insufficient_Space_Dialog_Params.callback = "Change_Storage_Clicked"
	--- MARIA TEMP HACK!
	if not CurrentSaveName then
		CurrentSaveName = Create_Wide_String()
	end
	
	Default_Save_Game_Name = Create_Wide_String()
	Default_Save_Game_Seperator = Create_Wide_String(" - ")

	DontDisplayDialog = false

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
	if DontDisplayDialog or Mode == SAVE_LOAD_MODE_INVALID or (not SaveLoadManager.Ensure_Valid_Gamer_Profile()) then
		DontDisplayDialog = false
		Hide_Dialog()
		return
	end


	Display_Save_Games()

	CurrentSaveName = Get_Default_Save_Game_Name()

	if TestValid(this.Controls.SaveGamesList) then
		Set_Keyboard_Focus(this.Controls.SaveGamesList)
	end

	if not Is_Replay_Mode() and SaveLoadManager.Is_Game_List_Full() then
		Spawn_Dialog_Box(Delete_Dialog_Params)
	end
end

function Get_Default_Save_Game_Name()
	local player = Find_Player("local")
	local map = Get_Current_Map_Name()
	local level = Get_Level_Name()
	local seperator = Default_Save_Game_Seperator

	Default_Save_Game_Name.erase()
	if Is_Replay_Mode() then
		Default_Save_Game_Name.append(Get_Game_Text("TEXT_GAMEPAD_REPLAY_PREFIX")).append(seperator)
	end

	if level then
		-- MLL: The level name has the faction baked in.
		Default_Save_Game_Name.append(level)
	else
		Default_Save_Game_Name.append(player.Get_Faction_Display_Name())
		if map then
			Default_Save_Game_Name.append(seperator).append(map)
		end
	end

	Default_Save_Game_Name.append(seperator).append(Get_Localized_Formatted_Number.Get_Current_Date_Time())

	return Default_Save_Game_Name
end

function Hide_Dialog()
	if Is_Spawned_From_Battle_End then
		this.End_Modal()
	end
	GUI_Dialog_Raise_Parent()
end

function Display_Save_Games()
	NumSaveGames = 0
	CheckingIndex = 1
	Enable_Y_Button(false)

	SavesList.Clear()
	if InsufficientSpace then
		InsufficientSpace = false
	else
		SaveLoadManager.Init(Mode) -- init each time to refresh the game list
	end
	SaveGames = SaveLoadManager.Generate_Sorted_Save_Game_List(false)

	if not Is_Replay_Mode() then
		Highlighted_Slot = -1

		Empty_Slot = SaveLoadManager.Get_First_Empty_Slot()
		if Empty_Slot == -3 then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_GAMEPAD_SEARCHING_FOR_SAVED_GAMES"))
			SavesList.Set_Selected_Row_Index(-1)
		elseif Empty_Slot == -2 then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_GAMEPAD_NO_STORAGE_DEVICE"))
			SavesList.Set_Selected_Row_Index(-1)
		elseif Empty_Slot ~= -1 then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_EMPTY_SLOT"))
			SavesList.Set_Selected_Row_Index(0)
		end
	else
		Empty_Slot = -1

		SaveLoadManager.Update() -- required for determining if storage is valid
		if SaveLoadManager.Get_Is_Storage_Device_Invalid() then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_GAMEPAD_NO_STORAGE_DEVICE"))
			SavesList.Set_Selected_Row_Index(-1)
		end
		Highlighted_Replay = Create_Wide_String()
	end

	if SaveGames == nil then return end

	for key, save_data in pairs(SaveGames) do
		NumSaveGames = NumSaveGames + 1
		local new_row = SavesList.Add_Row()

		-- color replays by version
		if Is_Replay_Mode() then
			if save_data.IsCurrent then
				SavesList.Set_Row_Color(new_row, 1.0, 1.0, 1.0, 1.0)
			else
				SavesList.Set_Row_Color(new_row, 1.0, 0.0, 0.0, 1.0)
			end
		end

		-- Fill in the description later after we verify the file
		SavesList.Set_User_Data(new_row, save_data.Filename)
	end

	if NumSaveGames == 0 then
		Enable_Y_Button(true)
	end
end

function Save_Clicked(event_name, source)
	-- TODO - Support case where there are no save slots available
	if not Is_Replay_Mode() and SaveLoadManager.Is_Game_List_Full() and Highlighted_Slot == Empty_Slot then
		Spawn_Dialog_Box(Max_Saves_Dialog_Params)
		return
	end

	if not SaveLoadManager.Get_Is_Storage_Device_Invalid() then
		if not Is_Replay_Mode() then
			local description = CurrentSaveName
			if Need_To_Overwrite() then
				Save_Current(false)
			else
				Save_Slot = Empty_Slot
				Save_Current(true)
			end
		else
			Highlighted_Replay = CurrentSaveName
			Save_Current(true)
		end
	end
end

function Need_To_Overwrite()
	if not Is_Replay_Mode() and Highlighted_Slot ~= Empty_Slot then
		return true
	end

	return false
end

function Delete_Clicked(event_name, source)
	if not Is_Replay_Mode() and Highlighted_Slot ~= -1 and Highlighted_Slot ~= Empty_Slot then 
		Spawn_Dialog_Box(Delete_Dialog_Params)
	elseif Is_Replay_Mode() and Highlighted_Replay ~= nil and string.len(Highlighted_Replay) ~= 0 then
		Spawn_Dialog_Box(Delete_Dialog_Params)
	end
end

function Delete_Confirm_Callback(button)
	if button == 2 then
		if not Is_Replay_Mode() then
			SaveLoadManager.Delete(Highlighted_Slot)
		else
			SaveLoadManager.Delete(Highlighted_Replay)
		end
		Display_Save_Games()
		this.Get_Containing_Scene().Raise_Event("Save_File_Deleted", nil, nil)
		if TestValid(this.Controls.SaveGamesList) then
			Set_Keyboard_Focus(this.Controls.SaveGamesList)
		end
	end
end

function Save_Confirm_Callback(button)
	if button == 2 then
		Save_Current(true)
	end
end

function Saved_OK_Callback(button)
	DontDisplayDialog = true
end

function Save_Current(confirmed)
	if not SaveLoadManager.Get_Is_Storage_Device_Invalid() then
		if not Is_Replay_Mode() then
			local description = CurrentSaveName
			if description == AUTO_SAVE_STRING or description == QUICK_SAVE_STRING then
				return
			end

			SaveDescription = description

			if not Dialog_Box_Opened then
				Save_Slot = Highlighted_Slot
			end

			if confirmed or Save_Slot == Empty_Slot then
				SavePending = true
				SaveDelay = 2
				if TestValid(SaveMessage) then
					SaveMessage.Set_Hidden(false)
				end
				SaveMessageDisplayTime = GetCurrentRealTime() + 3 -- Min 3 second display as per TCRs
			else
				Spawn_Dialog_Box(Save_Dialog_Params)
			end
		else
			SaveDescription = Highlighted_Replay

			SavePending = true
			SaveDelay = 2
			if TestValid(SaveMessage) then
				SaveMessage.Set_Hidden(false)
			end
			SaveMessageDisplayTime = GetCurrentRealTime() + 3 -- Min 3 second display as per TCRs
		end
	end
end

function On_Update()
	-- Don't process unless we are visible
	if this.Get_Hidden() then return end

	if Dialog_Box_Opened then
		Save_Current(true)
		Dialog_Box_Opened = false
	end

	if SaveGames and NumSaveGames > 0 and CheckingIndex > 0 then
		local index = CheckingIndex
		if Is_Replay_Mode() or (Empty_Slot == -1) then
			index = CheckingIndex - 1
		end

		local is_valid = false
		if Is_Replay_Mode() then
			local replay_name = SavesList.Get_User_Data(index)
			if replay_name then
				is_valid = SaveLoadManager.Get_Is_Valid_Save(replay_name)
			end
		else
			is_valid = SaveLoadManager.Get_Is_Valid_Save(SaveGames[CheckingIndex].Slot)
		end

		if not is_valid then
			SavesList.Set_Text_Data(SAVE_GAME, index, CORRUPT_FILE_STRING)
		else
			local slot_data = SaveGames[CheckingIndex]
			if not Is_Replay_Mode() then
				-- Get the updated description
				slot_data = SaveLoadManager.Get_Slot_Description(slot_data.Slot)
			end

			if slot_data then
				SavesList.Set_Text_Data(SAVE_GAME, index, slot_data.Description)
			end
		end

		CheckingIndex = CheckingIndex + 1
		if CheckingIndex > NumSaveGames then
			CheckingIndex = 0
			Enable_Y_Button(true)
		end
	end
	
	-- Saves are delayed a few frames so the "Saving..." message can be displayed as per Xbox TRCs
	if SavePending then
		SaveDelay = SaveDelay - 1
		if SaveDelay <= 0 then
			SavePending = false
			Delayed_Save()
		end
	else
		local index = SavesList.Get_Selected_Row_Index()
		if SaveGames and NumSaveGames > 0 then
			if not Is_Replay_Mode() then
				if index == 0 then
					Highlighted_Slot = Empty_Slot
				elseif index ~= -1 and index <= NumSaveGames then
					Highlighted_Slot = SaveGames[index].Slot
				end
			else
				if index > -1 then
					Highlighted_Replay = SavesList.Get_User_Data(index)
					if Highlighted_Replay == nil then
						Highlighted_Replay = SavesList.Get_Text_Data(SAVE_GAME, index)
						Highlighted_Replay = SaveLoadManager.Get_Full_Replay_Name(Highlighted_Replay)
					end
				else
					Highlighted_Replay = Get_Default_Save_Game_Name()
				end
			end
		elseif not Is_Replay_Mode() then
			Highlighted_Slot = Empty_Slot
		end
	
		-- Check the SaveLoadManager to see if we have to show the warning message that the storage device
		-- used to save previously is no longer valid
		if SaveLoadManager.Get_Is_Storage_Device_Invalid() then
			SavesList.Set_Selected_Row_Index(-1)
			StorageChangedMessage.Set_Hidden(false)
		else
			StorageChangedMessage.Set_Hidden(true)
		end
		
		-- Needed for Xbox version
		SaveLoadManager.Update()
		-- On the Xbox, the user may change the storage device so the save list will also change
		if SaveLoadManager.Get_List_Needs_Refresh() then
			Display_Save_Games()
		end

		--if TestValid(this.Controls.SaveGamesList) then
		--	Set_Keyboard_Focus(this.Controls.SaveGamesList)
		--end
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


function Change_Storage_Clicked(event_name, source)
	if this.Controls.Y_ButtonText.Is_Enabled() then
		SaveLoadManager.Change_Storage_Selection(true)
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end

function Delayed_Save()
	local save_ok = false

	if Is_Replay_Mode() then
		save_ok = SaveLoadManager.Save(SaveDescription)
	else
		save_ok = SaveLoadManager.Save(Save_Slot, SaveDescription)
	end

	-- The saving message must be displayed for a minimum amount of time
	-- Is there a better way to do this?
	while SaveMessageDisplayTime > GetCurrentRealTime() do
	end

	local current_time = GetCurrentRealTime()

	if TestValid(SaveMessage) then
		SaveMessage.Set_Hidden(true)
	end

	if save_ok then
		if Is_Replay_Mode() then
			Spawn_Dialog_Box(Saved_Replay_Ok_Dialog_Params)
		else
			Spawn_Dialog_Box(Saved_Ok_Dialog_Params)
		end
	else
		local error_code = SaveLoadManager.Get_Error_Code()
		if error_code == 0 then
			Spawn_Dialog_Box(Save_Failed_Invalid_Device_Dialog_Params)
		elseif error_code == 1 then
			InsufficientSpace = true
			Spawn_Dialog_Box(Save_Failed_Insufficient_Space_Dialog_Params)
		end
	end
end

function Enable_Y_Button(enable)
	this.Controls.Y_ButtonText.Enable(enable)

	if enable then
		this.Controls.Y_ButtonText.Set_Tint(1, 1, 1, 1)
	else
		this.Controls.Y_ButtonText.Set_Tint(0.5, 0.5, 0.5, 0.5)
	end
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
	On_Key_Press = nil
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
