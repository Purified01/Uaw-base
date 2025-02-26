if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[33] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[98] = true
LuaGlobalCommandLinks[209] = true
LuaGlobalCommandLinks[32] = true
LuaGlobalCommandLinks[195] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[31] = true
LuaGlobalCommandLinks[30] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[40] = true
LuaGlobalCommandLinks[77] = true
LuaGlobalCommandLinks[47] = true
LUA_PREP = true

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Button_Clicked", this.Controls.SaveGameButton, Save_Game_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.LoadGameButton, Load_Game_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.OptionsButton, Options_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.QuitGameButton, Quit_Game_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.ResumeGameButton, Hide_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Controls.ForfeitGameButton, Forfeit_Game_Clicked)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Start_Button_Up", nil, Hide_Dialog)

	this.Controls.ResumeGameButton.Set_Tab_Order(Declare_Enum(0))
	this.Controls.SaveGameButton.Set_Tab_Order(Declare_Enum())
	this.Controls.LoadGameButton.Set_Tab_Order(Declare_Enum())
	this.Controls.OptionsButton.Set_Tab_Order(Declare_Enum())
	this.Controls.ForfeitGameButton.Set_Tab_Order(Declare_Enum())
	this.Controls.QuitGameButton.Set_Tab_Order(Declare_Enum())

	Dialog_Box_Common_Init()
	Forfeit_Callback_Params = {}
	Forfeit_Callback_Params.script = Script
	Forfeit_Callback_Params.spawned_from_script = true
	Forfeit_Callback_Params.callback = "Forfeit_Confirm_Callback"
	Forfeit_Callback_Params.caption = Get_Game_Text("TEXT_GAME_DIALOG_FORFEIT_BATTLE")
	if not Is_Multiplayer_Skirmish() and not Is_Scenario() then
		Forfeit_Callback_Params.user_string_1 = Get_Game_Text("TEXT_WARNING_PROGRESS_LOST")
	end
	Forfeit_Callback_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")
	Forfeit_Callback_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	
	Profile_Failure_Dialog_Params = { }
	Profile_Failure_Dialog_Params.caption = Get_Game_Text("TEXT_GAMEPAD_SAVE_GAME_DATA_WARNING")
	Profile_Failure_Dialog_Params.script = Script
	Profile_Failure_Dialog_Params.spawned_from_script = true
	Profile_Failure_Dialog_Params.middle_button = Get_Game_Text("TEXT_BUTTON_YES")
	Profile_Failure_Dialog_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	Profile_Failure_Dialog_Params.callback = "Profile_Failure_Callback"

	Display_Dialog()

	if SaveLoadManager == nil then
		Register_Save_Load_Commands()
	end

end

------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
	if Is_Gamepad_Active() then
		this.Focus_First()
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


function Save_Game_Clicked(event_name, source)
	
	if not SaveLoadManager.Ensure_Valid_Gamer_Profile() then
		Spawn_Dialog_Box(Profile_Failure_Dialog_Params)
		return
	end

	local save_game_dialog = Spawn_Dialog("Save_Game_Dialog", true)
	if Is_Single_Player_Skirmish() then
		save_game_dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	else
		save_game_dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	end
	save_game_dialog.Display_Dialog()
end

function Load_Game_Clicked(event_name, source)
	if not SaveLoadManager.Ensure_Valid_Gamer_Profile() then
		Spawn_Dialog_Box(Profile_Failure_Dialog_Params)
		return
	end

	local load_game_dialog = Spawn_Dialog("Load_Game_Dialog", true)
	if Is_Single_Player_Skirmish() then
		load_game_dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	else
		load_game_dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	end
	load_game_dialog.Display_Dialog()
end

function Options_Clicked(event_name, source)
	handle = Spawn_Dialog("Options_Dialog", true)
end

function Quit_Game_Clicked(event_name, source)
	Spawn_Dialog_Box({}, "Quit_DialogBox")
end

function Forfeit_Game_Clicked()
	Spawn_Dialog_Box(Forfeit_Callback_Params)
end

function Forfeit_Confirm_Callback(button)
	if button == 2 then
		Send_GUI_Network_Event("Network_Forfeit_Game", { Find_Player("local") })
		Hide_Dialog()
	end
end

function Profile_Failure_Callback(button)
	if button == 2 then
		SaveLoadManager.Sign_In_Gamer_Profile()
	end
end


function Display_Dialog()

	this.Controls.QuitGameButton.Enable(true)

	if handle ~= nil then
		handle.Set_Hidden(true)
		handle = nil
	end
	
	if Get_Fade_Screen_Percent() > 0 or Is_Letter_Box_On() or Is_Multiplayer_Skirmish() or
		Is_Cinematic_Playing() or (not SaveLoadManager.Ensure_Valid_Gamer_Profile()) then
		this.Controls.LoadGameButton.Enable(false)
		this.Controls.SaveGameButton.Enable(false)
	else
		this.Controls.LoadGameButton.Enable(true)
		this.Controls.SaveGameButton.Enable(true)
	end

	if Is_Multiplayer_Skirmish() then
		this.PausePanel.Set_Hidden(true)
	else
		this.PausePanel.Set_Hidden(false)
	end

	local forfeit_enabled = true
	
	local local_player = Find_Player("local")	
	if Get_Fade_Screen_Percent() > 0 or Is_Letter_Box_On() or Is_Cinematic_Playing() or Get_Game_Mode() == "Strategic" or local_player.Is_Observer() or Is_Replay() then
		forfeit_enabled = false
		this.Controls.ForfeitGameButton.Enable(false)
	else
		--Allow the game mode script to prevent forfeiting the battle (default is to allow forfeit)
		local mode_script = Get_Game_Mode_Script()
		if TestValid(mode_script) and mode_script.Get_Async_Data("PreventForfeit") then
			forfeit_enabled = false
			this.Controls.ForfeitGameButton.Enable(false)
		else
			this.Controls.ForfeitGameButton.Enable(true)
		end
	end

	-- Only allow disabling the quit button if forfeiting is disabled. Otherwise there is
	-- the potential for a soft-lock where the player has no way of quiting the game
	if forfeit_enabled then
		if Is_Multiplayer_Skirmish() and not Is_Replay() then
			local num_enemy_players = 0
			local local_player = Find_Player("local")
			local enemy_players = local_player.Get_All_Enemy_Players()
			for idx, enemy_player in pairs(enemy_players) do
				if enemy_player.Is_Human() or enemy_player.Is_AI_Player() then
					num_enemy_players = num_enemy_players + 1
				end
			end

			if num_enemy_players == 1 then
				this.Controls.QuitGameButton.Enable(false)
			end
		end
	end


	if Mouse_Pointer.Is_Enabled() == false and Is_Gamepad_Active() == false then
		Mouse_Pointer.Enable(true)
	end
	
	this.Controls.ResumeGameButton.Set_Key_Focus()
	this.Focus_First()
end

function Hide_Dialog(event_name, source)
	this.Controls.ResumeGameButton.Set_Key_Focus()
	this.Focus_First()
	if Is_Cinematic_Playing() then
		Mouse_Pointer.Enable(false)
	end
	this.Get_Containing_Scene().Raise_Event("Request_Hide", nil, nil)

	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Tooltip_Delay_Reload_Needed", nil, false)

end

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
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
