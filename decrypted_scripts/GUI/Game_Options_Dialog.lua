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

	this.Controls.SaveGameButton.Set_Tab_Order(Declare_Enum(0))
	this.Controls.LoadGameButton.Set_Tab_Order(Declare_Enum())
	this.Controls.OptionsButton.Set_Tab_Order(Declare_Enum())
	this.Controls.ForfeitGameButton.Set_Tab_Order(Declare_Enum())
	this.Controls.QuitGameButton.Set_Tab_Order(Declare_Enum())
	this.Controls.ResumeGameButton.Set_Tab_Order(Declare_Enum())

	Dialog_Box_Common_Init()
	Forfeit_Callback_Params = {}
	Forfeit_Callback_Params.script = Script
	Forfeit_Callback_Params.spawned_from_script = true
	Forfeit_Callback_Params.callback = "Forfeit_Confirm_Callback"
	Forfeit_Callback_Params.caption = Get_Game_Text("TEXT_GAME_DIALOG_FORFEIT_BATTLE")
	if not Is_Multiplayer_Skirmish() then
		Forfeit_Callback_Params.user_string_1 = Get_Game_Text("TEXT_WARNING_PROGRESS_LOST")
	end
	Forfeit_Callback_Params.left_button = Get_Game_Text("TEXT_BUTTON_YES")
	Forfeit_Callback_Params.right_button = Get_Game_Text("TEXT_BUTTON_NO")
	
	Display_Dialog()
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


function Save_Game_Clicked(event_name, source)
	local save_game_dialog = Spawn_Dialog("Save_Game_Dialog", true)
	if Is_Single_Player_Skirmish() then
		save_game_dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	else
		save_game_dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	end
	save_game_dialog.Display_Dialog()
end

function Load_Game_Clicked(event_name, source)
	local load_game_dialog = Spawn_Dialog("Load_Game_Dialog", true)
	if Is_Single_Player_Skirmish() then
		load_game_dialog.Set_Mode(SAVE_LOAD_MODE_SKIRMISH)
	else
		load_game_dialog.Set_Mode(SAVE_LOAD_MODE_CAMPAIGN)
	end
	load_game_dialog.Display_Dialog()
end

function Options_Clicked(event_name, source)
	Spawn_Dialog("Options_Dialog", true)
end

function Quit_Game_Clicked(event_name, source)
	Spawn_Dialog_Box({}, "Quit_DialogBox")
end

function Forfeit_Game_Clicked()
	Spawn_Dialog_Box(Forfeit_Callback_Params)
end

function Forfeit_Confirm_Callback(button)
	if button == DIALOG_RESULT_LEFT then
		Send_GUI_Network_Event("Network_Forfeit_Game", { Find_Player("local") })
		Hide_Dialog()
	end
end

function Display_Dialog()
	this.Controls.QuitGameButton.Enable(true)

	if Is_Letter_Box_On() or Is_Multiplayer_Skirmish() or Is_Cinematic_Playing() then
		this.Controls.LoadGameButton.Enable(false)
		this.Controls.SaveGameButton.Enable(false)
	else
		this.Controls.LoadGameButton.Enable(true)
		this.Controls.SaveGameButton.Enable(true)
	end

	local forfeit_enabled = true
	local local_player = Find_Player("local")	
	if Is_Letter_Box_On() or Is_Cinematic_Playing() or Get_Game_Mode() == "Strategic" or local_player.Is_Observer() or Is_Replay() then
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

			if num_enemy_players >= 1 then
				this.Controls.QuitGameButton.Enable(false)
			end
		end
	end


	if Mouse_Pointer.Is_Enabled() == false then
		Mouse_Pointer.Enable(true)
	end

	this.Focus_First()
end

function Hide_Dialog(event_name, source)
	if Is_Cinematic_Playing() then
		Mouse_Pointer.Enable(false)
	end
	this.Set_Hidden(true)
	this.Get_Containing_Scene().Raise_Event_Immediate("Request_Hide", nil, nil)
	this.End_Modal()
end
