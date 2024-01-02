-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Lobby_Player_Info_Cluster.lua#34 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Lobby_Player_Info_Cluster.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 90747 $
--
--          $DateTime: 2008/01/10 14:38:09 $
--
--          $Revision: #34 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGColors")
require("PGFactions")
require("PGHintSystem")
require("PGHintSystemDefs")
require("Lobby_Network_Logic")
require("PGOnlineAchievementDefs")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GUI_Init()

	-- Constants
	EMPTY_WIDE_STRING = Create_Wide_String("")

	Info_Controls = this.Info_Controls
	State_Controls = this.State_Controls

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
	INVALID_DATA_MODEL.name = Get_Game_Text("TEXT_MULTIPLAYER_WAITING_FOR_PLAYER_DATA")
	INVALID_DATA_MODEL.team = 1
	INVALID_DATA_MODEL.faction = nil
	INVALID_DATA_MODEL.color = nil
	INVALID_DATA_MODEL.alliances = false
	INVALID_DATA_MODEL.applied_medals = nil
	INVALID_DATA_MODEL.AcceptsGameSettings = false

	Register_Event_Handlers()
		
	-- Library init
	PGFactions_Init()
	PGColors_Init()
	PGLobby_Constants_Init()
	PGOnlineAchievementDefs_Init()

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
	GameIsStarting = false
	EnableSettingsAccept = false
	Set_Medals_Visible(true)
	Refresh_UI()
	
end


function Register_Event_Handlers()
	this.Register_Event_Handler("Mouse_Left_Up", nil, On_Scene_Clicked)

	this.Register_Event_Handler("Mouse_On", Info_Controls.Quad_Accept_Icon, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_Left_Down", Info_Controls.Quad_Accept_Icon, Play_Option_Select_SFX)
	this.Register_Event_Handler("Mouse_Left_Up", Info_Controls.Quad_Accept_Icon, Ready_Clicked)

	this.Register_Event_Handler("Mouse_On", this.Quad_Is_AI, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_Left_Down", this.Quad_Is_AI, Play_Option_Select_SFX)
	this.Register_Event_Handler("Mouse_Left_Up", this.Quad_Is_AI, Toggle_AI)

	this.Register_Event_Handler("Mouse_On", State_Controls.Button_Previous_State, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", State_Controls.Button_Next_State, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Faction_Up, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Faction_Down, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Team_Up, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Team_Down, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Color_Up, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Color_Down, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Difficulty_Up, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_On", Info_Controls.Button_Player_Difficulty_Down, Play_Mouse_Over_Option_SFX)

	this.Register_Event_Handler("Button_Clicked", State_Controls.Button_Previous_State, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", State_Controls.Button_Next_State, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Down, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Down, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Down, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Difficulty_Up, Play_Option_Select_SFX)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Difficulty_Down, Play_Option_Select_SFX)

	this.Register_Event_Handler("Button_Clicked", State_Controls.Button_Previous_State, State_Previous_Clicked)
	this.Register_Event_Handler("Button_Clicked", State_Controls.Button_Next_State, State_Next_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Up, Player_Faction_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Faction_Down, Player_Faction_Down_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Up, Player_Team_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Team_Down, Player_Team_Down_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Up, Player_Color_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Color_Down, Player_Color_Down_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Difficulty_Up, Player_Difficulty_Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", Info_Controls.Button_Player_Difficulty_Down, Player_Difficulty_Down_Clicked)
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Faction_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Faction_Down_Clicked()
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Faction_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Team_Up_Clicked()
	if GameIsStarting then return end
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Team_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Team_Down_Clicked()
	if GameIsStarting then return end
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Team_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Color_Up_Clicked()
	if GameIsStarting then return end
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Color_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Color_Down_Clicked()
	if GameIsStarting then return end
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Color_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Difficulty_Up_Clicked()
	if GameIsStarting then return end
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Up_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Player_Difficulty_Down_Clicked()
	if GameIsStarting then return end
	IsReady = false
	this.Get_Containing_Scene().Raise_Event_Immediate("Player_Difficulty_Down_Clicked", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function State_Previous_Clicked()
	if GameIsStarting then return end
	local new_state = ClusterState - 1
	if (new_state < CLUSTER_STATE_FIRST) then
		new_state = CLUSTER_STATE_LAST
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {new_state, SeatNum})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function State_Next_Clicked()
	if GameIsStarting then return end
	local new_state = ClusterState + 1
	if (new_state > CLUSTER_STATE_LAST) then
		new_state = CLUSTER_STATE_FIRST
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("Info_Cluster_State_Changed", nil, {new_state, SeatNum})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Toggle_AI()

	if GameIsStarting then return end
	if BETA_BUILD then return end

	local is_ai = not IsAI

	if is_ai then
		this.Get_Containing_Scene().Raise_Event_Immediate("AI_Player_Added", nil, {SeatNum})
		this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Cluster_Clicked", nil, {DataModel.common_addr})
	else
		this.Get_Containing_Scene().Raise_Event_Immediate("AI_Player_Removed", nil, {DataModel.common_addr})
	end
	
end

------------------------------------------------------------------------
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Option_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
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


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI()

	this.Text_Is_AI.Set_Hidden(true)
	this.Quad_Is_AI.Set_Hidden(true)

	if (ClientConnected) then

		Info_Controls.Set_Hidden(false)
		State_Controls.Set_Hidden(true)

		Info_Controls.Button_Player_Faction_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Faction_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Color_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Color_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Color_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Color_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Team_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Team_Down.Set_Hidden(not ClientEditingEnabled)

		if (IsAI) then
			Info_Controls.Button_Player_Difficulty_Up.Set_Hidden(not ClientEditingEnabled)
			Info_Controls.Button_Player_Difficulty_Down.Set_Hidden(not ClientEditingEnabled)
		else
			Info_Controls.Button_Player_Difficulty_Up.Set_Hidden(true)
			Info_Controls.Button_Player_Difficulty_Down.Set_Hidden(true)
		end

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

			-- Accept Icon
			Info_Controls.Quad_Bad_Color.Set_Hidden(true)

			-- Download Progress
			Info_Controls.Clock_Download_Progress.Set_Hidden(true)

		else

			local data_model = INVALID_DATA_MODEL
			if (DataModel ~= data_model) then
				data_model = DataModel
			end

			-- Name
			Info_Controls.Text_Player_Name.Set_Text(data_model.name)

			-- Team
			local team_label = Get_Localized_Formatted_Number(data_model.team)
			Info_Controls.Text_Player_Team.Set_Text(team_label)

			-- Faction
			if (data_model.faction == nil) then
				Info_Controls.Quad_Faction_Icon.Set_Hidden(true)
			else
				local texture = PGFactionTextures[data_model.faction]
				Info_Controls.Quad_Faction_Icon.Set_Texture(texture)
				Info_Controls.Quad_Faction_Icon.Set_Hidden(false)
			end

			-- Color
			Set_Player_Color(data_model.color, data_model.color_valid)

			-- Is this an AI?
			Set_Is_AI(data_model.is_ai)

			-- Set alliance mode
			Set_Alliance_Mode(data_model.alliances)

			-- Medals
			Set_Medals_Empty()
			if (data_model.applied_medals ~= nil) then

				local quad_index = 1

				for _, id in ipairs(data_model.applied_medals) do
					if (quad_index <= #MEDAL_QUAD_MODEL) then
						local achievement = OnlineAchievementMap[id]
						local quad = MEDAL_QUAD_MODEL[quad_index].Quad
						MEDAL_QUAD_MODEL[quad_index].Achievement = achievement
						quad_index = quad_index + 1
						quad.Set_Texture(achievement.Texture)
						PGLobby_Set_Player_Solid_Color(quad, PGCOLOR_WHITE_TRIPLE)
						quad.Set_Hidden(false)
					end
				end

			end

			if (data_model.download_progress ~= nil) then
				-- Download Progress
				Info_Controls.Quad_Accept_Icon.Set_Hidden(true)
				Info_Controls.Clock_Download_Progress.Set_Hidden(false)
				Info_Controls.Clock_Download_Progress.Set_Filled(data_model.download_progress)
			else
				Info_Controls.Quad_Accept_Icon.Set_Hidden(false)
				Info_Controls.Clock_Download_Progress.Set_Hidden(true)
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

		end
	else

		Set_Selected_State(false)
		Info_Controls.Set_Hidden(true)
		State_Controls.Set_Hidden(false)

		if (IsAI) then
			this.Quad_Is_AI.Set_Texture(ACCEPT_ICON)
		else
			this.Quad_Is_AI.Set_Texture(NO_ACCEPT_ICON)
		end

		if (IsHost) then
			if GameIsStarting then
				this.Text_Is_AI.Set_Hidden(true)
				this.Quad_Is_AI.Set_Hidden(true)
				State_Controls.Button_Next_State.Set_Hidden(true)
				State_Controls.Button_Previous_State.Set_Hidden(true)
				State_Controls.Text_Status.Set_Text("TEXT_NO_PLAYER")
			else
				State_Controls.Button_Next_State.Set_Hidden(false)
				State_Controls.Button_Previous_State.Set_Hidden(false)
				if (ClusterState == CLUSTER_STATE_OPEN) then
					this.Text_Is_AI.Set_Hidden(false)
					this.Quad_Is_AI.Set_Hidden(false)
					State_Controls.Text_Status.Set_Text("TEXT_OPEN_PLAYER")
				elseif (ClusterState == CLUSTER_STATE_CLOSED) then
					this.Text_Is_AI.Set_Hidden(true)
					this.Quad_Is_AI.Set_Hidden(true)
					State_Controls.Text_Status.Set_Text("TEXT_NO_PLAYER")
				--elseif (ClusterState == CLUSTER_STATE_RESERVED) then
					--State_Controls.Text_Status.Set_Text("TEXT_RESERVED_PLAYER")
				end
			end
		else
			State_Controls.Button_Next_State.Set_Hidden(true)
			State_Controls.Button_Previous_State.Set_Hidden(true)
			if (ClusterState == CLUSTER_STATE_OPEN) then
				State_Controls.Text_Status.Set_Text("TEXT_OPEN_PLAYER")
			elseif (ClusterState == CLUSTER_STATE_CLOSED) then
				State_Controls.Text_Status.Set_Text("TEXT_NO_PLAYER")
			-- elseif (ClusterState == CLUSTER_STATE_RESERVED) then
			-- 	State_Controls.Text_Status.Set_Text("TEXT_RESERVED_PLAYER")
			end
		end

	end

	if BETA_BUILD then
		this.Text_Is_AI.Set_Hidden(true)
		this.Quad_Is_AI.Set_Hidden(true)
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
		this.Text_Is_AI.Set_Hidden(false)
		this.Quad_Is_AI.Set_Hidden(false)
		this.Quad_Is_AI.Set_Texture(ACCEPT_ICON)
		Info_Controls.Button_Player_Difficulty_Up.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Button_Player_Difficulty_Down.Set_Hidden(not ClientEditingEnabled)
		Info_Controls.Quad_Accept_Icon.Set_Hidden(true)
		Info_Controls.Clock_Download_Progress.Set_Hidden(true)

		Set_Medals_Empty()
		Set_Medals_Visible(false)
	else
		Set_Medals_Visible(true)
		this.Quad_Is_AI.Set_Texture(NO_ACCEPT_ICON)
		Info_Controls.Button_Player_Difficulty_Up.Set_Hidden(true)
		Info_Controls.Button_Player_Difficulty_Down.Set_Hidden(true)
		Info_Controls.Quad_Accept_Icon.Set_Hidden(false)
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Player_Color(color, is_valid)

	local label = MP_COLORS_LABEL_LOOKUP[color] 
	local triple = MP_COLOR_TRIPLES[label]
	if (triple == nil) then
		triple = PGCOLOR_BLACK_TRIPLE
	end

	PGLobby_Set_Player_Solid_Color(Info_Controls.Quad_Player_Color, triple)

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
		PGLobby_Set_Player_Solid_Color(dao.Quad, PGCOLOR_BLACK_TRIPLE)
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
	if model == nil then
		ClientConnected = false
		DataModel = INVALID_DATA_MODEL
	else
		ClientConnected = true
		DataModel = model
	end
	Refresh_UI()
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
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Clear_UI()
	DataModel = INVALID_DATA_MODEL
	IsReserved = false
	Set_Medals_Visible(true)
	Info_Controls.Quad_Player_Color.Set_Hidden(false)
	Info_Controls.Text_Player_Team.Set_Hidden(false)
	Info_Controls.Quad_Faction_Icon.Set_Hidden(false)
	Info_Controls.Quad_Accept_Icon.Set_Hidden(false)
	Info_Controls.Clock_Download_Progress.Set_Hidden(true)
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
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Is_Host(is_host)
	IsHost = is_host
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Is_Local_Client(is_local)
	IsLocalClient = is_local
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Cluster_State(state)
	ClusterState = state
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
function Make_AI_Player()
	IsAI = true
	this.Get_Containing_Scene().Raise_Event_Immediate("AI_Player_Added", nil, {SeatNum})
	this.Get_Containing_Scene().Raise_Event_Immediate("On_Player_Cluster_Clicked", nil, {DataModel.common_addr})
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
function Set_Alliance_Mode(hide)
	Info_Controls.Text_Player_Team.Set_Hidden(hide)
	Info_Controls.Text_Team_Header.Set_Hidden(hide)

	hide = hide or (not ClientEditingEnabled)
	Info_Controls.Button_Player_Team_Up.Set_Hidden(hide)
	Info_Controls.Button_Player_Team_Down.Set_Hidden(hide)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Set_Seat = Set_Seat
Interface.Get_Seat = Get_Seat
Interface.Set_Selected_State = Set_Selected_State
Interface.Clear_UI = Clear_UI
Interface.Set_Is_Reserved = Set_Is_Reserved
Interface.Set_Editing_Enabled = Set_Editing_Enabled
Interface.Set_Is_Host = Set_Is_Host
Interface.Set_Is_Local_Client = Set_Is_Local_Client
Interface.Set_Cluster_State = Set_Cluster_State
Interface.Set_Voice_Active = Set_Voice_Active
Interface.Set_Game_Is_Starting = Set_Game_Is_Starting
Interface.Make_AI_Player = Make_AI_Player
Interface.Is_Client_Connected = Is_Client_Connected
Interface.Enable_Settings_Accept = Enable_Settings_Accept
