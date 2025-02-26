if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[110] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Lobby_Player_Info_Cluster.lua#41 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Lobby_Player_Info_Cluster.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Nader_Akoury $
--
--            $Change: 97651 $
--
--          $DateTime: 2008/04/28 11:52:11 $
--
--          $Revision: #41 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGColors")
require("PGFactions")
require("Lobby_Network_Logic")
require("PGOnlineAchievementDefs")
require("PGNetwork")

ScriptPoolCount = 0


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GUI_Init()

	-- Constants
	EMPTY_WIDE_STRING = Create_Wide_String("")

	Info_Controls = this.Info_Controls

	MEDAL_QUAD_MODEL = {}
	table.insert(MEDAL_QUAD_MODEL, { Quad = Info_Controls.Quad_Medal_1, Achievement = nil})
	table.insert(MEDAL_QUAD_MODEL, { Quad = Info_Controls.Quad_Medal_2, Achievement = nil})
	table.insert(MEDAL_QUAD_MODEL, { Quad = Info_Controls.Quad_Medal_3, Achievement = nil})
	
	ACCEPT_ICON = "i_objectives_checkbox_checked_square.tga"
	NO_ACCEPT_ICON = "i_objectives_checkbox_square.tga"
	BAD_CONNECTION_ICON = "no_connection.tga"
	
	CHAT_ON_ICON = "i_dialogue_radio_on.tga"
	CHAT_OFF_ICON = "i_dialogue_radio_off.tga"
	
	INVALID_DATA_MODEL = {}
	INVALID_DATA_MODEL.seat = nil
	INVALID_DATA_MODEL.name = Get_Game_Text("TEXT_OPEN_PLAYER")
	INVALID_DATA_MODEL.team = 1
	INVALID_DATA_MODEL.faction = nil
	INVALID_DATA_MODEL.color = nil
	INVALID_DATA_MODEL.applied_medals = nil
	INVALID_DATA_MODEL.AcceptsGameSettings = false
	
	FACTION_HIGHLIGHT = 1
	TEAM_HIGHLIGHT = 2
	COLOR_HIGHLIGHT = 3
	SPAWN_HIGHLIGHT = 4
	STATE_HIGHLIGHT = 5
	
	LOCAL_CLUSTER_STATE_OPEN = 1
	LOCAL_CLUSTER_STATE_CLOSED = 2
	LOCAL_CLUSTER_STATE_EASY_AI = 3
	LOCAL_CLUSTER_STATE_MED_AI = 4
	LOCAL_CLUSTER_STATE_HARD_AI = 5
	
	LOCAL_BUTTON_DELAY = .25
	LastButtonPress = 0
	
	SPAWN_LABEL_RANDOM		= Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_RANDOM")
	SPAWN_LABEL_LOOKUP = {}
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_A"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_B"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_C"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_D"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_E"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_F"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_G"))
	table.insert(SPAWN_LABEL_LOOKUP, Get_Game_Text("TEXT_GAMEPAD_SPAWN_POINT_H"))
				
	GAMER_PICTURE_STATE_PREMADE = Declare_Enum(1)				-- One of our faction emblems (ai or retrieve pending).
	GAMER_PICTURE_STATE_CUSTOM = Declare_Enum()					-- A custom LIVE gamer picture.
		
	CurrentLocalState = LOCAL_CLUSTER_STATE_OPEN
	ChangingCurrentLocalState = false

	Register_Event_Handlers()
		
	-- Library init
	PGFactions_Init()
	PGColors_Init()
	PGLobby_Constants_Init()
	PGOnlineAchievementDefs_Init()
	PGNetwork_Init()

	ClusterState = CLUSTER_STATE_OPEN
	DataModel = INVALID_DATA_MODEL
	ClientConnected = false
	IsReserved = false
	IsLocalClient = false
	IsBadConnection = false
	SeatNum = -1
	IsAI = false
	IsHost = false
	IsReady = false
	ClientEditingEnabled = false
	Lockdown = false
	GameIsStarting = false
	EnableSettingsAccept = false
	AcceptUIVisible = true
	Set_Medals_Visible(true)

	Refresh_UI()
	
end


function Register_Event_Handlers()

	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Faction_Up, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Faction_Down, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Team_Up, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Team_Down, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Color_Up, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Color_Down, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Quad_Faction_Icon, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Text_Player_Team, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Quad_Player_Color, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Spawn_Up, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Spawn, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Spawn_Down, On_Focus_On_Scene)

	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Next_State, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Previous_State, On_Focus_On_Scene)
	this.Register_Event_Handler("Key_Focus_Gained", this.Text_Status, On_Focus_On_Scene)

	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Dummy_Status, On_Focus_On_Dummy_Status)
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Dummy_Status_2, On_Focus_On_Dummy_Status_2)

	this.Register_Event_Handler("Key_Focus_Lost", this.Text_Status, On_Focus_Lost_From_State)
--	this.Register_Event_Handler("Key_Focus_Lost", Info_Controls.Button_Player_Spawn, On_Focus_Lost_From_State)

	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Down, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Down, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Down, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Button_Clicked", this.Button_Next_State, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", this.Button_Previous_State, Play_Option_Select_SFX)


	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Up, Player_Faction_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Down, Player_Faction_Down_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Up, Player_Team_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Down, Player_Team_Down_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Up, Player_Color_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Down, Player_Color_Down_Clicked)
	
	this.Register_Event_Handler("Button_Clicked", this.Button_Next_State, Local_State_Next_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Button_Previous_State, Local_State_Previous_Clicked)
	
	
	
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Up, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Quad_Faction_Icon, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Down, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Up, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Text_Player_Team, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Down, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Up, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Quad_Player_Color, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Down, Local_A_Button_Up)	
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Spawn_Up, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Spawn, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Spawn_Down, Local_A_Button_Up)	
	this.Register_Event_Handler("Button_Clicked", this.Button_Next_State, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", this.Text_Status, Local_A_Button_Up)
	this.Register_Event_Handler("Button_Clicked", this.Button_Previous_State, Local_A_Button_Up)
	
	
	this.Register_Event_Handler("Controller_A_Button_up", nil, Local_A_Button_Up)
	
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Faction_Up, On_Focus_On_Faction_Up)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Quad_Faction_Icon, On_Focus_On_Faction)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Faction_Down, On_Focus_On_Faction_Down)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Team_Up, On_Focus_On_Team_Up)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Text_Player_Team, On_Focus_On_Team)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Team_Down, On_Focus_On_Team_Down)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Color_Up, On_Focus_On_Color_Up)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Quad_Player_Color, On_Focus_On_Color)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Color_Down, On_Focus_On_Color_Down)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Spawn_Up, On_Focus_On_Spawn_Up)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Spawn, On_Focus_On_Spawn)
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Button_Player_Spawn_Down, On_Focus_On_Spawn_Down)
	
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Next_State, On_Focus_On_State_Up)
	this.Register_Event_Handler("Key_Focus_Gained", this.Text_Status, On_Focus_On_Status)
	this.Register_Event_Handler("Key_Focus_Gained", this.Button_Previous_State, On_Focus_On_State_Down)

	Declare_Enum(0)
	
	TEXT_STATUS_TAB_ORDER = Declare_Enum()
	NEXT_STATE_TAB_ORDER  = Declare_Enum()
	PREV_STATE_TAB_ORDER  = Declare_Enum()
	
	this.Text_Status.Set_Tab_Order(TEXT_STATUS_TAB_ORDER)
	this.Info_Controls.Quad_Faction_Icon.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Text_Player_Team.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Quad_Player_Color.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Spawn.Set_Tab_Order(Declare_Enum())

	this.Button_Next_State.Set_Tab_Order(NEXT_STATE_TAB_ORDER)
	this.Button_Previous_State.Set_Tab_Order(PREV_STATE_TAB_ORDER)
	this.Info_Controls.Button_Player_Faction_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Faction_Down.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Team_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Team_Down.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Color_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Color_Down.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Spawn_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Spawn_Down.Set_Tab_Order(Declare_Enum())
	
	this.Button_Dummy_Status.Set_Tab_Order(Declare_Enum())
	this.Button_Dummy_Status_2.Set_Tab_Order(Declare_Enum())
	
--	Info_Controls.Quad_Accept_Icon.Set_Tab_Order(Declare_Enum())

	Enable_Dummy_Button_2(false)


end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- On_Focus_On_Scene
-------------------------------------------------------------------------------
function On_Focus_On_Scene(_, source)
	-- Make sure we update the visual state of this component now that it
	-- has focus!.  However, do it only if this component is not the 
	-- currently selected one.
	if not Selected then 
		On_Scene_Clicked()
	end
	
	this.Get_Containing_Scene().Raise_Event_Immediate("Cluster_Claiming_Focus", nil, {SeatNum})
	
	if source and source.Is_Enabled()  then 
		Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
	end
end

function On_Focus_On_Dummy_Status()
	this.Focus_First()
end

function On_Focus_On_Dummy_Status_2()
	On_Focus_On_Scene()
	if ( not this.Info_Controls.Button_Player_Spawn_Up.Get_Hidden() ) then
		this.Info_Controls.Button_Player_Spawn_Up.Set_Key_Focus()
	end
end

function On_Focus_On_Fake_Focus_Quad()
	On_Focus_On_Scene()
end
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Scene_Clicked()
	this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Cluster_Clicked", nil, {DataModel.common_addr})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Ready_Clicked()
	if (IsAI or (not IsLocalClient) or (not EnableSettingsAccept) or (not ClientEditingEnabled)) then return end

	IsReady = not IsReady
	this.Get_Containing_Scene().Raise_Event_Immediate("Ready_Clicked", nil, {IsReady})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Faction_Up_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Faction_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Faction_Down_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Faction_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Team_Up_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Team_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Team_Down_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Team_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Color_Up_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Color_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Color_Down_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Color_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Difficulty_Up_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	if ( Get_Game_Text("TEXT_HARD_AI_PLAYER") == Info_Controls.Text_Player_Name.Get_Text() ) then
		this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Up_Clicked", nil, nil)
		State_Next_Clicked()
		return
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Difficulty_Down_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	IsReady = false
	if ( Get_Game_Text("TEXT_EASY_AI_PLAYER") == Info_Controls.Text_Player_Name.Get_Text() ) then
		this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Down_Clicked", nil, nil)
		State_Previous_Clicked()
		return
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function State_Previous_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	local new_state = ClusterState - 1

	if (new_state < CLUSTER_STATE_FIRST) then
		this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {new_state, SeatNum})
		Make_AI_Player()
		Player_Difficulty_Down_Clicked()
		return
	end

	this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {new_state, SeatNum})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function State_Next_Clicked()
	if GameIsStarting then return end
	if ( GetCurrentRealTime() < LastButtonPress + LOCAL_BUTTON_DELAY ) then
		return
	end
	LastButtonPress = GetCurrentRealTime()
	local new_state = ClusterState + 1
	if (new_state > CLUSTER_STATE_LAST) then
		new_state = CLUSTER_STATE_FIRST
		this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {new_state, SeatNum})
		Make_AI_Player()
		Player_Difficulty_Up_Clicked()
		return
	end

	this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {new_state, SeatNum})
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI()

	-- If the local DataModel is nil, fall back on the default INVALID_DATA_MODEL
	local data_model = INVALID_DATA_MODEL
	if (DataModel ~= data_model) then
		data_model = DataModel
	end
	
	-- Make sure the cluster label is always up to date.
	Update_Cluster_Name_Display(data_model)

	if (ClientConnected) then

		Info_Controls.Set_Hidden(false)

		if (IsReserved) then
	
			-- Name
			Info_Controls.Text_Player_Name.Set_Text("Reserved Slot") -- Get_Game_Text("TEXT_MULTIPLAYER_RESERVED_SLOT")

			-- Team
			Info_Controls.Text_Player_Team.Set_Hidden(true)

			-- Faction
			Info_Controls.Quad_Faction_Icon.Set_Hidden(true)

			-- Medals
			Set_Medals_Empty()
			Set_Medals_Visible(false)

			-- Color
			Info_Controls.Quad_Player_Color.Set_Hidden(true)

			-- Accept Icon
			Info_Controls.Quad_Accept_Icon.Set_Hidden(true)
			this.Fake_Focus_Quad.Set_Hidden(true)

			-- Accept Icon
			Info_Controls.Quad_Bad_Color.Set_Hidden(true)

		else

			-- Name
			-- Updated above with the call to Update_Cluster_Name_Display()

			-- Team
			local team_label = Get_Localized_Formatted_Number(data_model.team)
			Info_Controls.Text_Player_Team.Set_Text(team_label)

			-- Faction
			if (data_model.faction == nil) then
				Info_Controls.Quad_Faction_Icon.Set_Hidden(true)
			else
				local texture = PGFactionTextures[data_model.faction]
				if (texture ~= nil) then
					Info_Controls.Quad_Faction_Icon.Set_Texture("Normal_Middle", texture)
					Info_Controls.Quad_Faction_Icon.Set_Hidden(false)
				end
			end

			-- Color
			Set_Player_Color(data_model.color, data_model.color_valid)
			
			-- Spawn
			local spawn_label = SPAWN_LABEL_RANDOM
			if (data_model.start_marker_id ~= nil) then
				spawn_label = SPAWN_LABEL_LOOKUP[data_model.start_marker_id]
			end
			if (spawn_label == nil) then
				spawn_label = SPAWN_LABEL_RANDOM
			end
			Info_Controls.Text_Player_Spawn.Set_Text(spawn_label)

			-- Is this an AI?
			Set_Is_AI(data_model.is_ai)

			-- Medals
			Set_Medals_Empty()
			if (data_model.applied_medals ~= nil) then

				local quad_index = 1

				for _, id in ipairs(data_model.applied_medals) do
					if (quad_index <= #MEDAL_QUAD_MODEL) then
						local achievement = OnlineAchievementMap[id]
						if (achievement ~= nil) then
							local quad = MEDAL_QUAD_MODEL[quad_index].Quad
							MEDAL_QUAD_MODEL[quad_index].Achievement = achievement
							quad_index = quad_index + 1
							quad.Set_Texture(achievement.Texture)
							PGLobby_Set_Player_Solid_Color(quad, ({ a = 1, b = 1, g = 1, r = 1, }))
							quad.Set_Hidden(false)
						end
					end
				end

			end

			-- Bad Connection?
			if (data_model.is_bad_connection) then
				Info_Controls.Quad_Accept_Icon.Set_Texture(BAD_CONNECTION_ICON)
			else
				-- Accepts
				if (data_model.AcceptsGameSettings) then
					Info_Controls.Quad_Accept_Icon.Set_Texture(ACCEPT_ICON)
				else
					Info_Controls.Quad_Accept_Icon.Set_Texture(NO_ACCEPT_ICON)
				end
			end

		end
		
		Refresh_State_Buttons()
		Info_Controls.Button_Player_Faction_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Faction_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Team_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Team_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Color_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Color_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Spawn_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Spawn_Down.Set_Hidden(not ClientEditingEnabled)
		
		if ( ClientEditingEnabled ) then
			Info_Controls.Quad_Faction_Icon.Set_Tab_Order(Declare_Enum())
			Info_Controls.Text_Player_Team.Set_Tab_Order(Declare_Enum())
			Info_Controls.Quad_Player_Color.Set_Tab_Order(Declare_Enum())
			Info_Controls.Button_Player_Spawn.Set_Tab_Order(Declare_Enum())
			this.Button_Dummy_Status.Set_Tab_Order(-1)
		else
			Info_Controls.Quad_Player_Color.Set_Tab_Order(-1)
			Info_Controls.Text_Player_Team.Set_Tab_Order(-1)
			Info_Controls.Quad_Faction_Icon.Set_Tab_Order(-1)
			Info_Controls.Button_Player_Spawn.Set_Tab_Order(-1)
			this.Button_Dummy_Status.Set_Tab_Order(Declare_Enum())
		end

	else

		Set_Selected_State(false)
		Info_Controls.Set_Hidden(true)

	end
	
	
	Find_Correct_Highlight()

end

-------------------------------------------------------------------------------
-- Centralized function that ensures the cluster's label is always up-to-date
-- and accurate.
-------------------------------------------------------------------------------
function Update_Cluster_Name_Display(data_model)
		
	if (IsAI) then

		-- AI players should always have a name set.
		this.Text_Status.Set_Text(data_model.name)
		
	elseif ((CurrentLocalState == LOCAL_CLUSTER_STATE_OPEN) and ClientConnected) then
	
		-- If a human player is connected, use the human player's name.
		this.Text_Status.Set_Text(data_model.name)
		
	elseif ((CurrentLocalState == LOCAL_CLUSTER_STATE_OPEN) and (not ClientConnected)) then
	
		-- If this cluster is open and no one is connected, mark it as Open.
		this.Text_Status.Set_Text("TEXT_OPEN_PLAYER")
		
	elseif ( CurrentLocalState == LOCAL_CLUSTER_STATE_CLOSED ) then
	
		-- If this cluster is close, mark it as closed.
		this.Text_Status.Set_Text("TEXT_NO_PLAYER")
		
	end
			
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Is_AI(is_ai)

	if BETA_BUILD then
		is_ai = false
	end

	IsAI = is_ai
	if is_ai then
		Info_Controls.Quad_Accept_Icon.Set_Hidden(true)
		this.Fake_Focus_Quad.Set_Hidden(true)

		Set_Medals_Empty()
		Set_Medals_Visible(false)
	else
		Set_Medals_Visible(true)
		Info_Controls.Quad_Accept_Icon.Set_Hidden(not AcceptUIVisible)
		this.Fake_Focus_Quad.Set_Hidden(false)
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Player_Color(color, is_valid)

	local label = ({ [1] = "WHITE", [2] = "RED", [3] = "ORANGE", [4] = "YELLOW", [5] = "GREEN", [6] = "CYAN", [7] = "BLUE", [8] = "PURPLE", [9] = "GRAY", })[color] 
	local triple = ({ RED = { a = 1, b = 0.09, g = 0.09, r = 1, }, YELLOW = { a = 1, b = 0.18, g = 0.87, r = 0.89, }, PURPLE = { a = 1, b = 0.82, g = 0.44, r = 1, }, CYAN = { a = 1, b = 0.88, g = 0.85, r = 0.44, }, GREEN = { a = 1, b = 0.31, g = 1, r = 0.47, }, ORANGE = { a = 1, b = 0.09, g = 0.58, r = 1, }, BLUE = { a = 1, b = 1, g = 0.59, r = 0.31, }, GRAY = { a = 1, b = 0.12, g = 0.12, r = 0.12, }, })[label]
	if (triple == nil) then
		triple = ({ b = 1, g = 0, r = 0, })
	end

	Info_Controls.Quad_Player_Color.Set_Tint( triple["r"], triple["g"], triple["b"], 1 )

	if is_valid then
		Info_Controls.Quad_Bad_Color.Set_Hidden(true)
	else
		Info_Controls.Quad_Bad_Color.Set_Hidden(false)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Medals_Visible(value)
	
	for _, dao in ipairs(MEDAL_QUAD_MODEL) do
		dao.Quad.Set_Hidden(not value)
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Medals_Empty()
	
	for _, dao in ipairs(MEDAL_QUAD_MODEL) do
		dao.Quad.Set_Hidden(true)
		dao.Achievement = nil
		PGLobby_Set_Player_Solid_Color(dao.Quad, ({ b = 1, g = 0, r = 0, }))
	end

end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Mouse_On(event, source, key)

	local achievement = nil
	for _, dao in ipairs(MEDAL_QUAD_MODEL) do
		if (dao.Quad.Get_Name() == source.Get_Name()) then
			achievement = dao.Achievement
			break
		end
	end
	
	if (achievement ~= nil) then
		this.Get_Containing_Scene().Raise_Event_Immediate("On_Medal_Mouse_On", nil, {achievement.Id})
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Medal_Mouse_Off(event, source, key)
	this.Get_Containing_Scene().Raise_Event_Immediate("On_Medal_Mouse_Off", nil, {})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Player_Name_Mouse_On(event, source, key)
   	this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Name_Mouse_On", nil, {DataModel.common_addr})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Player_Name_Mouse_Off(event, source, key)
	this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Name_Mouse_Off", nil, {})
end


-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Model(model)

	DebugMessage("LUA_CLUSTER:                                                           ")
	DebugMessage("LUA_CLUSTER:  vvvvvvvvvvvvvvvvvvvvvvvvvvvv")
	DebugMessage("LUA_CLUSTER:  Setting new cluster model...")
		
	if (not Model_Has_Changed(model)) then
		DebugMessage("LUA_CLUSTER:  Model hasn't changed.  Early out!")
		return
	end

	if model == nil then
	
		DebugMessage("LUA_CLUSTER:  Model is nil.")
		DebugMessage("LUA_CLUSTER:  OLD DATA MODEL: " .. tostring(DataModel.name))
		ClientConnected = false
		DataModel = INVALID_DATA_MODEL
		this.Info_Controls.Gamer_Pic.Set_Texture("i_faction_novus.tga")
		GottenGamerPic = false
		RequestedGamerPic = false
		InvalidGamerPic = false
		
	else
	
		ClientConnected = true
		DataModel = model

		if (DataModel.is_ai) then
			Set_Is_AI(true)
			Set_Local_State_Based_On_AI_Name(DataModel.name)
		else
			Set_Is_AI(false)
			CurrentLocalState = LOCAL_CLUSTER_STATE_OPEN
		end

		DebugMessage("LUA_CLUSTER:  Valid client model -> " .. tostring(DataModel.name))
		Update_Gamer_Picture_State(DataModel)
		
		if (DataModel.gamer_picture_state == GAMER_PICTURE_STATE_PREMADE) then
		
			-- We're dealing with an AI so we'll be using faction emblems as the gamer picture.
			DebugMessage("LUA_CLUSTER:  Premade only...using faction emblems.")
			this.Info_Controls.Gamer_Pic.Set_Texture(PGGamerPictures[DataModel.faction])
			
		elseif (DataModel.gamer_picture_state == GAMER_PICTURE_STATE_CUSTOM) then

			DebugMessage("LUA_CLUSTER:  Custom picture...")
			if ((not GottenGamerPic) and (not RequestedGamerPic)) then
				DebugMessage("LUA_CLUSTER:  Requesting gamer picture.")
				RequestedGamerPic = true
				InvalidGamerPic = false
				Net.Get_Gamer_Picture(this.Info_Controls.Gamer_Pic, DataModel.common_addr)
			else
				DebugMessage("LUA_CLUSTER:  Gamer picture requested or retrieved.  Not requesting.")
			end
			
		end
		
	end

	Refresh_UI()

end

-------------------------------------------------------------------------------
-- We use our premade gamer pictures for AI players or players who are not
-- currently signed in (that is, profiles which would not normally have
-- a gamer picture).  We download a user's custom gamer picture when one is
-- available.
-------------------------------------------------------------------------------
function Update_Gamer_Picture_State(model)

	DebugMessage("LUA_CLUSTER:  Updating gamer picture state...")
	
	model.gamer_picture_state = GAMER_PICTURE_STATE_PREMADE
	
	-- If this cluster represents an AI, we're done.
	if (model.is_ai) then
		DebugMessage("LUA_CLUSTER:  Cluster is ai.  Early out!")
		return
	end
	
	-- If this cluster's gamer picture is invalid, we'll use faction emblems.
	if (InvalidGamerPic) then
		DebugMessage("LUA_CLUSTER:  INVALID GAMER PICTURE.  Using faction emblems...")
		return
	end
	
	-- Otherwise, check the signin state.
	local signin_state = Net.Get_Signin_State()
	if (signin_state == "online") or
		(signin_state == "local") or
		(signin_state == "non-live") then
		
		DebugMessage("LUA_CLUSTER:  Cluster will be custom!")
		model.gamer_picture_state = GAMER_PICTURE_STATE_CUSTOM
	
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Model_Has_Changed(model)

	if (model == nil) then
		return (DataModel ~= nil)
	end

	for k,v in pairs(model) do
	
		if (DataModel[k] ~= v) then
			return true
		end

	end
	
	return false
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Seat(seat_num)
	SeatNum = seat_num
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Seat()
	return SeatNum
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Selected_State(value)

	if (value) then
		this.Highlight.Set_Tint(1, 1, 1, 1)
	else
		this.Highlight.Set_Tint(0, 0, 0, 0)
		Find_Correct_Highlight()
	end
	Selected = value
	
	if not IsAI then
		this.Fake_Focus_Quad.Set_Hidden(Selected)	
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Clear_UI()
	DataModel = INVALID_DATA_MODEL
	IsReserved = false
	ClientConnected = false
	Set_Medals_Visible(true)
	this.Fake_Focus_Quad.Set_Hidden(true)
	Find_Correct_Highlight()
	
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Is_Reserved(bool)
	IsReserved = bool
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Editing_Enabled(enabled)
	ClientEditingEnabled = enabled
	
	Refresh_State_Buttons()
	
	Info_Controls.Button_Player_Faction_Up.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Faction_Down.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Team_Up.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Team_Down.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Color_Up.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Color_Down.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Spawn_Up.Set_Hidden(not ClientEditingEnabled)
	Info_Controls.Button_Player_Spawn_Down.Set_Hidden(not ClientEditingEnabled)
	
	if ( ClientEditingEnabled ) then
		Info_Controls.Quad_Faction_Icon.Set_Tab_Order(Declare_Enum())
		Info_Controls.Text_Player_Team.Set_Tab_Order(Declare_Enum())
		Info_Controls.Quad_Player_Color.Set_Tab_Order(Declare_Enum())
		Info_Controls.Button_Player_Spawn.Set_Tab_Order(Declare_Enum())
		this.Button_Dummy_Status.Set_Tab_Order(-1)
	else
		Info_Controls.Quad_Player_Color.Set_Tab_Order(-1)
		Info_Controls.Text_Player_Team.Set_Tab_Order(-1)
		Info_Controls.Quad_Faction_Icon.Set_Tab_Order(-1)
		Info_Controls.Button_Player_Spawn.Set_Tab_Order(-1)
		this.Button_Dummy_Status.Set_Tab_Order(Declare_Enum())
	end
	
	Update_Dummy_2_State()
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Update_Dummy_2_State()

	local enable = (ClientConnected and 		-- A client MUST be connected and...
						(ClientEditingEnabled or 	-- ...we can edit the client or...
						IsLocalClient or				-- ...the cluster is the local player's cluster or...
						(IsHost and IsAI)))			-- ...we're the host and the cluster is an AI.
	Enable_Dummy_Button_2(enable)

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Lockdown(lockdown)

	Lockdown = lockdown
	Refresh_State_Buttons()
	
end

-------------------------------------------------------------------------------
-- The state buttons at the top of the cluster have several complex conditions
-- which determine their visibility.
-------------------------------------------------------------------------------
function Refresh_State_Buttons()

	-- Non hosts are never able to change the state of a player cluster.
	if ((not IsHost) or Lockdown) then
		this.Button_Next_State.Set_Hidden(true)
		this.Button_Previous_State.Set_Hidden(true)
		return
	end
	
	-- WE ARE THE HOST

	-- If there's no client connected here, make sure they're up.
	if (not ClientConnected) then
		
		this.Button_Next_State.Set_Hidden(false)
		this.Button_Previous_State.Set_Hidden(false)
		return
	
	end

	-- If this cluster is an AI, we can change it's state.  If it's a human
	-- player (including ourselves), we can't change the cluster state.
	if ( IsAI ) then
		this.Button_Next_State.Set_Hidden(false)
		this.Button_Previous_State.Set_Hidden(false)
	else
		this.Button_Next_State.Set_Hidden(true)
		this.Button_Previous_State.Set_Hidden(true)
	end
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Is_Host(is_host)

	IsHost = is_host
	Refresh_State_Buttons()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Is_Local_Client(is_local)
	if ( is_local ) then
		this.Button_Next_State.Set_Tab_Order(-1)
		this.Button_Previous_State.Set_Tab_Order(-1)
		this.Text_Status.Set_Tab_Order(-1)
		this.Button_Next_State.Set_Hidden(true)
		this.Button_Previous_State.Set_Hidden(true)
		this.Button_Dummy_Status.Set_Hidden(false)
		Enable_Dummy_Button_2(true)
	else
		if ( not IsAI and ClientEditingEnabled ) then
			this.Button_Next_State.Set_Tab_Order(NEXT_STATE_TAB_ORDER)
			this.Button_Previous_State.Set_Tab_Order(PREV_STATE_TAB_ORDER)
			this.Text_Status.Set_Tab_Order(TEXT_STATUS_TAB_ORDER)
			this.Button_Next_State.Set_Hidden(false)
			this.Button_Previous_State.Set_Hidden(false)
		end
	end
	IsLocalClient = is_local
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_Lost_From_State()
	this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Cluster_Clicked", nil, {})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Cluster_State(state)

	ClusterState = state

	if ( not ChangingCurrentLocalState ) then 
		if ( state == CLUSTER_STATE_CLOSED and CurrentLocalState ~= LOCAL_CLUSTER_STATE_CLOSED) then
			CurrentLocalState = LOCAL_CLUSTER_STATE_CLOSED
			Local_Handle_State()
		elseif ( state == CLUSTER_STATE_OPEN and CurrentLocalState ~= LOCAL_CLUSTER_STATE_OPEN) then
			CurrentLocalState = LOCAL_CLUSTER_STATE_OPEN
			Local_Handle_State()
		end
	end
	
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Voice_Active(value)
	local texture = CHAT_OFF_ICON
	if (value) then
		texture = CHAT_ON_ICON
	end
	this.Info_Controls.Quad_Talk_Icon.Set_Texture(texture)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Game_Is_Starting(is_starting)

	if not ClientConnected and GameIsStarting ~= is_starting then
		if not ForcedFromClusterState and is_starting and ClusterState ~= CLUSTER_STATE_CLOSED then
			ForcedFromClusterState = ClusterState
			this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {CLUSTER_STATE_CLOSED, SeatNum})
		elseif ForcedFromClusterState and not is_starting and ClusterState == CLUSTER_STATE_CLOSED then
			local state = ForcedFromClusterState 
			ForcedFromClusterState = nil
			this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {state, SeatNum})
		end
	end

	GameIsStarting = is_starting
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Make_AI_Player(set_state)
	if GameIsStarting then return end
	IsAI = true
	this.Get_Containing_Scene().Raise_Event_Immediate("AI_Player_Added", nil, {SeatNum})
	this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Cluster_Clicked", nil, {DataModel.common_addr})
	Enable_Dummy_Button_2(true)
	if ( set_state ) then
		Set_Local_State_Based_On_AI_Name(DataModel.name)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_Client_Connected()
	return ClientConnected
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Enable_Settings_Accept(enable)
	EnableSettingsAccept = enable
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Show_Correct_Highlight(hilight_num)
	if ( hilight_num == nil ) then
		this.Quad_Highlight_State.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(true)
	elseif ( hilight_num == STATE_HIGHLIGHT ) then
		this.Quad_Highlight_State.Set_Hidden(false)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(true)
	elseif ( hilight_num == FACTION_HIGHLIGHT ) then
		this.Quad_Highlight_State.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(false)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(true)
	elseif ( hilight_num == TEAM_HIGHLIGHT ) then
		this.Quad_Highlight_State.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(false)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(true)
	elseif ( hilight_num == COLOR_HIGHLIGHT ) then
		this.Quad_Highlight_State.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(false)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(true)
	elseif ( hilight_num == SPAWN_HIGHLIGHT ) then
		this.Quad_Highlight_State.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(false)
	else
		this.Quad_Highlight_State.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Faction.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Team.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Color.Set_Hidden(true)
		Info_Controls.Quad_Highlight_Spawn.Set_Hidden(true)
	end
	
	LastHighlightDisplayed = hilight_num
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Find_Correct_Highlight()
	Show_Correct_Highlight(LastHighlightDisplayed)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Difficulty_Up()
	if ( not Info_Controls.Quad_Highlight_Difficulty.Get_Hidden() ) then
		Player_Difficulty_Up_Clicked()
	end
--	Info_Controls.Text_Player_Name.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Difficulty()
	Show_Correct_Highlight(STATE_HIGHLIGHT)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Difficulty_Down()
	if ( not Info_Controls.Quad_Highlight_Difficulty.Get_Hidden() ) then
		Player_Difficulty_Down_Clicked()
	end
--	Info_Controls.Text_Player_Name.Set_Key_Focus()
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Faction_Up()
	if ( not Info_Controls.Quad_Highlight_Faction.Get_Hidden() ) then
		Player_Faction_Up_Clicked()
	end
	Info_Controls.Quad_Faction_Icon.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Faction()
	Show_Correct_Highlight(FACTION_HIGHLIGHT)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Faction_Down()
	if ( not Info_Controls.Quad_Highlight_Faction.Get_Hidden() ) then
		Player_Faction_Down_Clicked()
	end
	Info_Controls.Quad_Faction_Icon.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Team_Up()
	if ( not Info_Controls.Quad_Highlight_Team.Get_Hidden() ) then
		Player_Team_Up_Clicked()
	end
	Info_Controls.Text_Player_Team.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Team()
	Show_Correct_Highlight(TEAM_HIGHLIGHT)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Team_Down()
	if ( not Info_Controls.Quad_Highlight_Team.Get_Hidden() ) then
		Player_Team_Down_Clicked()
	end
	Info_Controls.Text_Player_Team.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Color_Up()
	if ( not Info_Controls.Quad_Highlight_Color.Get_Hidden() ) then
		Player_Color_Up_Clicked()
	end
	Info_Controls.Quad_Player_Color.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Color()
	Show_Correct_Highlight(COLOR_HIGHLIGHT)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Color_Down()
	if ( not Info_Controls.Quad_Highlight_Color.Get_Hidden() ) then
		Player_Color_Down_Clicked()
	end
	Info_Controls.Quad_Player_Color.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Spawn_Up()
	if ( not Info_Controls.Quad_Highlight_Spawn.Get_Hidden() ) then
		-- signal next spawn location
		this.Get_Containing_Scene().Raise_Event_Immediate("Spawn_Location_Up", nil, {SeatNum})
	end
	Info_Controls.Button_Player_Spawn.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Spawn()
	Show_Correct_Highlight(SPAWN_HIGHLIGHT)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Spawn_Down()
	if ( not Info_Controls.Quad_Highlight_Spawn.Get_Hidden() ) then
		-- signal previous spawn location
		this.Get_Containing_Scene().Raise_Event_Immediate("Spawn_Location_Down", nil, {SeatNum})
	end
	Info_Controls.Button_Player_Spawn.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_State_Up()
	if ( not this.Quad_Highlight_State.Get_Hidden() ) then
		Local_State_Next_Clicked()
	end
	this.Text_Status.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_Status()
	Show_Correct_Highlight(STATE_HIGHLIGHT)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Focus_On_State_Down()
	if ( not this.Quad_Highlight_State.Get_Hidden() ) then
		Local_State_Previous_Clicked()
	end
	this.Text_Status.Set_Key_Focus()
end




-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Local_State_Next_Clicked()
	if GameIsStarting then return end
	CurrentLocalState = CurrentLocalState + 1
	if ( CurrentLocalState > LOCAL_CLUSTER_STATE_HARD_AI ) then
		CurrentLocalState = LOCAL_CLUSTER_STATE_OPEN
	end
	
	Local_Handle_State()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Local_State_Previous_Clicked()
	if GameIsStarting then return end
	CurrentLocalState = CurrentLocalState - 1
	if ( CurrentLocalState < LOCAL_CLUSTER_STATE_OPEN ) then
		CurrentLocalState = LOCAL_CLUSTER_STATE_HARD_AI
	end
	
	Local_Handle_State()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Local_Handle_State()

	ChangingCurrentLocalState = true
	
	if ( CurrentLocalState == LOCAL_CLUSTER_STATE_OPEN ) then
		-- if there is an AI, kick it and leave it open
		
		if ( DataModel ~= INVALID_DATA_MODEL and DataModel.common_addr ) then
			this.Get_Containing_Scene().Raise_Event_Immediate("AI_Player_Removed", nil, {DataModel.common_addr})
		end
		
		IsAI = false
		
		this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {CLUSTER_STATE_OPEN, SeatNum})
		
		Enable_Dummy_Button_2(false)

		Set_Model()

	elseif ( CurrentLocalState == LOCAL_CLUSTER_STATE_CLOSED ) then
		-- if there is an AI, kick it and close the seat
		
		if ( DataModel ~= INVALID_DATA_MODEL and DataModel.common_addr ) then
			this.Get_Containing_Scene().Raise_Event_Immediate("AI_Player_Removed", nil, {DataModel.common_addr})
		end
		
		IsAI = false
		
		this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {CLUSTER_STATE_CLOSED, SeatNum})
		
		Enable_Dummy_Button_2(false)

		Set_Model()

	elseif ( CurrentLocalState == LOCAL_CLUSTER_STATE_EASY_AI ) then
		-- if it is closed, open it and add the AI, then set it to easy

		if ( not IsAI ) then
			this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {CLUSTER_STATE_OPEN, SeatNum})
			Make_AI_Player()
		end

		Enable_Dummy_Button_2(true)

		this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Set", nil, {Difficulty_Easy})
		
	elseif ( CurrentLocalState == LOCAL_CLUSTER_STATE_MED_AI ) then
		-- simplpy set the ai to medium

		if ( not IsAI ) then
			Make_AI_Player()
		end
		
		Enable_Dummy_Button_2(true)

		this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Set", nil, {Difficulty_Normal})

	elseif ( CurrentLocalState == LOCAL_CLUSTER_STATE_HARD_AI ) then
		-- if it was open, add an AI player, then set it to hard.

		if ( not IsAI ) then
			Make_AI_Player()
		end
		
		Enable_Dummy_Button_2(true)

		this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Set", nil, {Difficulty_Hard})

	else
		-- borked

	end
	
	ChangingCurrentLocalState = false
	Refresh_State_Buttons()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Enable_Dummy_Button_2(enable)
	if ( enable ) then
		this.Button_Dummy_Status_2.Set_Tab_Order(Declare_Enum())
	else
		this.Button_Dummy_Status_2.Set_Tab_Order(-1)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Focus_Claimed_By(seat_num)
	if ( seat_num ~= SeatNum ) then
		Show_Correct_Highlight()
	else
		Show_Correct_Highlight(LastHighlightDisplayed)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Focus_First()
	On_Focus_On_Scene()
	this.Info_Controls.Quad_Faction_Icon.Set_Key_Focus()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Accept_UI_Visible(value)

	AcceptUIVisible = value
	this.Info_Controls.Quad_Accept_Icon.Set_Hidden(not AcceptUIVisible)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Reset_Gamer_Picture()
	GottenGamerPic = false
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Local_A_Button_Up()
	this.Get_Containing_Scene().Raise_Event_Immediate("Cluster_A_Button_up", nil, nil)
end

-------------------------------------------------------------------------------
-- The gamepad player clusters are designed to use focus as a method of determining input.
-- Unfortunately if they gain focus for a reason OTHER than input they will behave as if
-- the recieved input.  This hack just tells the first cluster to ignore the next focus event
-- so that the local player's faction doesn't change when they dismiss the "leaving" confirmation
-- dialog.
-------------------------------------------------------------------------------
function Clear_Highlight()
	Show_Correct_Highlight(nil)
end

-------------------------------------------------------------------------------
-- Called by the owning lobby once this cluster's gamer picture is retrieved.
-------------------------------------------------------------------------------
function On_Gamer_Picture_Retrieved(event)

	DebugMessage("LUA_CLUSTER:                                                           ")
	DebugMessage("LUA_CLUSTER:  vvvvvvvvvvvvvvvvvvvvvvvvvvvv")
	DebugMessage("LUA_CLUSTER:  =======> GAMER PICTURE CAME BACK [" .. tostring(DataModel.name) .. "] !!! <===========")
	
	if (event.success == false) then
		DebugMessage("LUA_CLUSTER:  FAILURE!!!  Noting invalid gamer pic.")
		InvalidGamerPic = true
		DebugMessage("LUA_CLUSTER:  We don't have a gamer pic so using faction emblem.")
		this.Info_Controls.Gamer_Pic.Set_Texture(PGGamerPictures[DataModel.faction])
		return
	end
				
	DebugMessage("LUA_CLUSTER:  SUCCESSFUL!!!")
	GottenGamerPic = true
	InvalidGamerPic = false
		
end

function Set_Local_State_Based_On_AI_Name(name)
	if ( name == Get_Game_Text("TEXT_EASY_AI_PLAYER") ) then
		CurrentLocalState = LOCAL_CLUSTER_STATE_EASY_AI
	elseif ( name == Get_Game_Text("TEXT_MEDIUM_AI_PLAYER") ) then
		CurrentLocalState = LOCAL_CLUSTER_STATE_MED_AI
	elseif ( name == Get_Game_Text("TEXT_HARD_AI_PLAYER") ) then
		CurrentLocalState = LOCAL_CLUSTER_STATE_HARD_AI
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Set_Seat = Set_Seat
Interface.Get_Seat = Get_Seat
Interface.Set_Selected_State = Set_Selected_State
Interface.Set_Focus_First = Set_Focus_First
Interface.Clear_UI = Clear_UI
Interface.Set_Is_Reserved = Set_Is_Reserved
Interface.Set_Editing_Enabled = Set_Editing_Enabled
Interface.Set_Lockdown = Set_Lockdown
Interface.Set_Is_Host = Set_Is_Host
Interface.Set_Is_Local_Client = Set_Is_Local_Client
Interface.Set_Cluster_State = Set_Cluster_State
Interface.Set_Voice_Active = Set_Voice_Active
Interface.Set_Game_Is_Starting = Set_Game_Is_Starting
Interface.Make_AI_Player = Make_AI_Player
Interface.Is_Client_Connected = Is_Client_Connected
Interface.Enable_Settings_Accept = Enable_Settings_Accept
Interface.Focus_Claimed_By = Focus_Claimed_By
Interface.Set_Accept_UI_Visible = Set_Accept_UI_Visible
Interface.Reset_Gamer_Picture = Reset_Gamer_Picture
Interface.Clear_Highlight = Clear_Highlight
Interface.On_Gamer_Picture_Retrieved = On_Gamer_Picture_Retrieved

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Are_Chat_Names_Unique = nil
	BlockOnCommand = nil
	Broadcast_AI_Game_Settings_Accept = nil
	Broadcast_Game_Kill_Countdown = nil
	Broadcast_Game_Settings = nil
	Broadcast_Game_Settings_Accept = nil
	Broadcast_Game_Start_Countdown = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	Create_Base_Boolean_Achievement_Definition = nil
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
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Is_Player_Of_Faction = nil
	Min = nil
	Network_Add_AI_Player = nil
	Network_Add_Reserved_Players = nil
	Network_Assign_Host_Seat = nil
	Network_Broadcast_Reset_Start_Positions = nil
	Network_Calculate_Initial_Max_Player_Count = nil
	Network_Clear_All_Clients = nil
	Network_Do_Seat_Assignment = nil
	Network_Edit_AI_Player = nil
	Network_Get_Client_By_ID = nil
	Network_Get_Client_From_Seat = nil
	Network_Get_Local_Username = nil
	Network_Get_Seat = nil
	Network_Kick_All_AI_Players = nil
	Network_Kick_All_Reserved_Players = nil
	Network_Kick_Player = nil
	Network_Refuse_Player = nil
	Network_Request_Clear_Start_Position = nil
	Network_Request_Start_Position = nil
	Network_Reseat_Guests = nil
	Network_Send_Recommended_Settings = nil
	On_Focus_On_Difficulty = nil
	On_Focus_On_Difficulty_Down = nil
	On_Focus_On_Difficulty_Up = nil
	On_Focus_On_Fake_Focus_Quad = nil
	OutputDebug = nil
	PGLobby_Activate_Movies = nil
	PGLobby_Begin_Stats_Registration = nil
	PGLobby_Convert_Faction_IDs_To_Strings = nil
	PGLobby_Convert_Faction_Strings_To_IDs = nil
	PGLobby_Create_Random_Game_Name = nil
	PGLobby_Create_Session = nil
	PGLobby_Display_Custom_Modal_Message = nil
	PGLobby_Display_NAT_Information = nil
	PGLobby_Generate_Map_Selection_Model = nil
	PGLobby_Get_Preferred_Color = nil
	PGLobby_Hide_Modal_Message = nil
	PGLobby_Init_Modal_Message = nil
	PGLobby_Is_Game_Joinable = nil
	PGLobby_Keepalive_Close_Bracket = nil
	PGLobby_Keepalive_Open_Bracket = nil
	PGLobby_Lookup_Map_DAO = nil
	PGLobby_Mouse_Move = nil
	PGLobby_Passivate_Movies = nil
	PGLobby_Print_Client_Table = nil
	PGLobby_Refresh_Available_Games = nil
	PGLobby_Request_All_Medals_Progress_Stats = nil
	PGLobby_Request_All_Required_Backend_Data = nil
	PGLobby_Request_Global_Conquest_Properties = nil
	PGLobby_Request_Stats_Registration = nil
	PGLobby_Reset = nil
	PGLobby_Restart_Networking = nil
	PGLobby_Save_Vanity_Game_Start_Data = nil
	PGLobby_Set_Dialog_Is_Hidden = nil
	PGLobby_Set_Player_BG_Gradient = nil
	PGLobby_Set_Tooltip_Model = nil
	PGLobby_Start_Heartbeat = nil
	PGLobby_Stop_Heartbeat = nil
	PGLobby_Update_NAT_Warning_State = nil
	PGLobby_Update_Player_Count = nil
	PGLobby_Validate_Client_Medals = nil
	PGLobby_Validate_Local_Session_Data = nil
	PGLobby_Validate_NAT_Type = nil
	PGLobby_Vars_Init = nil
	PGNetwork_Clear_Start_Positions = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Client_Table = nil
	Set_Local_User_Applied_Medals = nil
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
	Update_Clients_With_Player_IDs = nil
	Update_SA_Button_Text_Button = nil
	Validate_Achievement_Definition = nil
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	_TEMP_Make_Hack_Map_Model = nil
	Kill_Unused_Global_Functions = nil
end

