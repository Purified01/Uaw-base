if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[122] = true
LuaGlobalCommandLinks[98] = true
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

require("PGBase")
require("PGUICommands")
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Load_Clicked)
	this.Register_Event_Handler("Controller_Y_Button_Up", nil, Change_Storage_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, Delete_Clicked)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)

	this.Register_Event_Handler("List_Selected_Index_Changed", this.List_Games, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)

	Mode = SAVE_LOAD_MODE_INVALID

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

	SavesList = this.Controls.SaveGamesList

	SAVE_GAME = Create_Wide_String("SAVE_GAME")
	CORRUPT_FILE_STRING = Get_Game_Text("TEXT_GAMEPAD_SAVE_GAME_CORRUPT_FILENAME")
	--TIMESTAMP = Create_Wide_String("TIMESTAMP")

	-- Specify the column for the list box
	SavesList.Set_Header_Style("NONE")
	SavesList.Add_Column(SAVE_GAME, JUSTIFY_LEFT) -- The column for the save game name
	--SavesList.Add_Column(TIMESTAMP, JUSTIFY_RIGHT) -- The column for the time stamp
	SavesList.Refresh()

	-- Tab order
	-- This seems to be the reverse order of what I want, but it works properly, weird...
	this.Controls.SaveGamesList.Set_Tab_Order(Declare_Enum(0))

	Dialog_Box_Common_Init()

	Delete_Dialog_Params = { }
	Delete_Dialog_Params.script = Script
	Delete_Dialog_Params.spawned_from_script = true
	Delete_Dialog_Params.callback = "Delete_Confirm_Callback"
	Delete_Dialog_Params.caption = Get_Game_Text("TEXT_DELETE_CONFIRM")
	Delete_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Delete_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")

	Load_Dialog_Params = { }
	Load_Dialog_Params.script = Script
	Load_Dialog_Params.spawned_from_script = true
	Load_Dialog_Params.callback = "Load_Confirm_Callback"
	Load_Dialog_Params.caption = Get_Game_Text("TEXT_MESSAGE_SAVE_GAME_WARNING")
	Load_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Load_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")

	Achievements_Dialog_Params = { }
	Achievements_Dialog_Params.script = Script
	Achievements_Dialog_Params.spawned_from_script = true
	Achievements_Dialog_Params.callback = "Achievements_Confirm_Callback"
	Achievements_Dialog_Params.caption = Get_Game_Text("TEXT_WARNING_NO_ACHIEVEMENTS_WITH_SAVE")
	Achievements_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Achievements_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")

	Loading_Dialog_Params = { }
	Loading_Dialog_Params.script = Script
	Loading_Dialog_Params.spawned_from_script = true
	Loading_Dialog_Params.callback = "Load_Confirm_Callback"
	Loading_Dialog_Params.spawned_from_script = true
	Loading_Dialog_Params.caption = Get_Game_Text("TEXT_GAMEPAD_CONFIRM_LOAD_MSG")
	Loading_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Loading_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")

	Bad_Save_Dialog_Params = { }
	Bad_Save_Dialog_Params.script = Script
	Bad_Save_Dialog_Params.spawned_from_script = true
	Bad_Save_Dialog_Params.caption = Get_Game_Text("TEXT_GAMEPAD_SAVE_GAME_CORRUPT")
	Bad_Save_Dialog_Params.left_button = Get_Game_Text("TEXT_BUTTON_OK")
	Bad_Save_Dialog_Params.callback = "Unhide_And_Set_Focus"

	CheckingIndex = 1
	NumSaveGames = 0

	DontDisplayDialog = false
	In_Retry_Dialog = false

	if SaveLoadManager == nil then
		Register_Save_Load_Commands()
	end
	SaveLoadManager.Reset()
end


------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end


function Display_Dialog()
	if DontDisplayDialog or Mode == SAVE_LOAD_MODE_INVALID or (not SaveLoadManager.Ensure_Valid_Gamer_Profile()) then
		DontDisplayDialog = false
		Hide_Dialog()
		return
	end

	this.Set_Can_Be_Disabled(false)
	this.Enable(true)
	this.Set_Hidden(false)

	Display_Save_Games()

	-- So this listbox can get focus
	this.Focus_First()
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Load_Game_Dialog"})
	Play_SFX_Event("GUI_Main_Menu_Back_Select")
end

function Display_Save_Games()
	NumSaveGames = 0
	CheckingIndex = 1
	Enable_Y_Button(false)

	SavesList.Clear()
	SaveLoadManager.Init(Mode) -- init each time to refresh the game list
	SaveGames = SaveLoadManager.Generate_Sorted_Save_Game_List()

	if not Is_Replay_Mode() then
		Highlighted_Slot = -1

		local empty_slot = SaveLoadManager.Get_First_Empty_Slot()
		if empty_slot == -3 then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_GAMEPAD_SEARCHING_FOR_SAVED_GAMES"))
			SavesList.Set_Selected_Row_Index(-1)
		elseif empty_slot == -2 then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_GAMEPAD_NO_STORAGE_DEVICE"))
			SavesList.Set_Selected_Row_Index(-1)
		end
	else
		Highlighted_Replay = nil

		SaveLoadManager.Update() -- required for determining if storage is valid
		if SaveLoadManager.Get_Is_Storage_Device_Invalid() then
			local new_row = SavesList.Add_Row()
			SavesList.Set_Text_Data(SAVE_GAME, new_row, Get_Game_Text("TEXT_GAMEPAD_NO_STORAGE_DEVICE"))
			SavesList.Set_Selected_Row_Index(-1)
		end
	end

	if SaveGames == nil then return end

	for key, save_data in pairs(SaveGames) do
		NumSaveGames = NumSaveGames + 1
		local new_row = SavesList.Add_Row()

		-- Color replays by version
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

	if NumSaveGames > 0 then
		SavesList.Set_Selected_Row_Index(0)
	end

	if NumSaveGames == 0 then
		Enable_Y_Button(true)
	end
end

function Load_Clicked(event_name, source)
	if (not Is_Replay_Mode() and Highlighted_Slot ~= -1) or
		(Is_Replay_Mode() and Highlighted_Replay ~= nil and string.len(Highlighted_Replay) ~= 0) then

		Play_SFX_Event("GUI_Main_Menu_Button_Select")

		local game_mode = Get_Game_Mode()
		if not In_Retry_Dialog and (game_mode == "Strategic" or game_mode == "Land") then
			if SaveLoadManager.Get_Is_Valid_Save(Highlighted_Slot) then
				Spawn_Dialog_Box(Loading_Dialog_Params)
			else
				Spawn_Dialog_Box(Bad_Save_Dialog_Params)
			end
			return
		end

		-- Dialog_Box_Opened = true
		-- Spawn_Dialog_Box(Loading_Dialog_Params)


		-- I have to hide the Ingame_Global_Dialog_Wrapper or else CloseHuds will stay true and
		-- the GUIInputHandler will steal the escape key instead of letting the DialogInputHandler
		-- take it, thus causing the in game options screen to not show up. I have to raise the
		-- event immediately or else the load will clobber the event
		-- this.Set_Hidden(true)
		-- this.Get_Containing_Scene().Raise_Event_Immediate("Request_Hide", nil, nil)
		-- this.End_Modal()

		if not Is_Replay_Mode() then
			if At_Front_End() or In_Retry_Dialog then
				if SaveLoadManager.Can_Earn_Achievements(Highlighted_Slot) then
					this.Get_Containing_Scene().Raise_Event_Immediate("Request_Hide", nil, nil)
					if SaveLoadManager.Get_Is_Valid_Save(Highlighted_Slot) then
						In_Retry_Dialog = false
						this.Set_Hidden(true)
						this.End_Modal()
						SaveLoadManager.Load(Highlighted_Slot)
  					else
  						-- SKY 1/21/08 - only need this so that we don't call the end_modal callback on the load dialog
  						-- by passing in 'true' as the last parameter
  						this.Set_Hidden(true)
						Spawn_Dialog_Box(Bad_Save_Dialog_Params, "DialogBox", false)
					end
				else
					Spawn_Dialog_Box(Achievements_Dialog_Params)
				end
			else
				this.Set_Hidden(true)
				this.End_Modal()
				if SaveLoadManager.Can_Earn_Achievements(Highlighted_Slot) then
					Spawn_Dialog_Box(Load_Dialog_Params)
				else
					Spawn_Dialog_Box(Achievements_Dialog_Params)
				end
			end
		else
			if SaveLoadManager.Get_Is_Valid_Save(Highlighted_Replay) then
				this.Set_Hidden(true)
				this.Get_Containing_Scene().Raise_Event_Immediate("Request_Hide", nil, nil)
				this.End_Modal()
				Net.Start_Replay(Highlighted_Replay)
			else
				Spawn_Dialog_Box(Bad_Save_Dialog_Params)
			end
		end
	end
end

function Delete_Clicked(event_name, source)
	if (not Is_Replay_Mode() and Highlighted_Slot ~= -1) or
		(Is_Replay_Mode() and Highlighted_Replay ~= nil and string.len(Highlighted_Replay) ~= 0) then
 		-- SKY 1/21/08 - only need this so that we don't call the end_modal callback on the load dialog
  		-- by passing in 'true' as the last parameter
		this.Set_Hidden(true)
		Spawn_Dialog_Box(Delete_Dialog_Params, "DialogBox", false)
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
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
	Unhide_And_Set_Focus()
end

function Load_Confirm_Callback(button)
	if button == 2 then
		this.Set_Hidden(true)
		this.Get_Containing_Scene().Raise_Event_Immediate("Request_Hide", nil, nil)
		this.End_Modal()

		if not Is_Replay_Mode() then
			SaveLoadManager.Load(Highlighted_Slot)
		else
			Net.Start_Replay(Highlighted_Replay)
		end
	end
	DontDisplayDialog = true
end

function Achievements_Confirm_Callback(button)
	if button == 2 then
		this.Set_Hidden(true)
		this.Get_Containing_Scene().Raise_Event_Immediate("Request_Hide", nil, nil)
		this.End_Modal()
		SaveLoadManager.Load(Highlighted_Slot)
	end
	DontDisplayDialog = true
end


function On_Update()
	-- Don't process unless we are visible
	if this.Get_Hidden() then return end

	if Dialog_Box_Opened then
		Dialog_Box_Opened = false

		-- Close the Loading... dialog box
		local parent = this.Get_Containing_Scene()
		if parent == nil then
			parent = this
		end
		parent.DialogBox.Set_Hidden(true)

		if not Is_Replay_Mode() then
			SaveLoadManager.Load(Highlighted_Slot)
		else
			Net.Start_Replay(Highlighted_Replay)
		end
	end

	if SaveGames and NumSaveGames > 0 then
		if CheckingIndex > 0 then
			local index = CheckingIndex - 1

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

		local index = SavesList.Get_Selected_Row_Index()
		if index > -1 and index <= NumSaveGames then
			-- Need the plus one because the first index is 1 in the SaveGames table
			-- while SavesList is has a zero based indexing
			if not Is_Replay_Mode() then
				Highlighted_Slot = SaveGames[index+1].Slot
			else
				Highlighted_Replay = SavesList.Get_User_Data(index)
				if Highlighted_Replay == nil then
					Highlighted_Replay = SavesList.Get_Text_Data(SAVE_GAME, index)
					Highlighted_Replay = SaveLoadManager.Get_Full_Replay_Name(Highlighted_Replay)
				end
			end
		end
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
end

function Set_Mode(mode)
	Mode = mode

	if Is_Replay_Mode() and Net == nil then
		Register_Net_Commands()
	end

	if Is_Replay_Mode() then
		-- Also make sure we change the header text of the window (otherwise it will say LOAD GAME)
		this.Controls.Text_1.Set_Text("TEXT_BUTTON_LOAD_REPLAY")
	else
		this.Controls.Text_1.Set_Text("TEXT_LOAD_GAME_TITLE")
	end	
end

function Set_In_Retry_Dialog()
	In_Retry_Dialog = true
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

function Unhide_And_Set_Focus()
	this.Set_Hidden(false)
	this.Focus_First()
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
Interface.Set_In_Retry_Dialog = Set_In_Retry_Dialog
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
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGOfflineAchievementDefs_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_Local_User_Applied_Medals = nil
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
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
