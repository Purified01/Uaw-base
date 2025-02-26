if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Lobby_Player_Info_Cluster.lua#25 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Lobby_Player_Info_Cluster.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 99361 $
--
--          $DateTime: 2008/05/30 14:48:03 $
--
--          $Revision: #25 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGColors")
require("PGFactions")
require("Lobby_Network_Logic")
require("PGOnlineAchievementDefs")


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
	this.Register_Event_Handler("Key_Focus_Gained", Info_Controls.Quad_Accept_Icon, Play_Mouse_Over_Option_SFX)

	this.Register_Event_Handler("Mouse_On", this.Quad_Is_AI, Play_Mouse_Over_Option_SFX)
	this.Register_Event_Handler("Mouse_Left_Down", this.Quad_Is_AI, Play_Option_Select_SFX)
	this.Register_Event_Handler("Mouse_Left_Up", this.Quad_Is_AI, Toggle_AI)
	this.Register_Event_Handler("Key_Focus_Gained", this.Quad_Is_AI, Play_Mouse_Over_Option_SFX)

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
	
	this.State_Controls.Button_Previous_State.Set_Tab_Order(Declare_Enum(0))
	this.State_Controls.Button_Next_State.Set_Tab_Order(Declare_Enum())

	this.Info_Controls.Button_Player_Team_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Team_Down.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Faction_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Faction_Down.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Color_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Color_Down.Set_Tab_Order(Declare_Enum())
	
	this.Quad_Is_AI.Set_Tab_Order(Declare_Enum())
	
	Info_Controls.Quad_Accept_Icon.Set_Tab_Order(Declare_Enum())
	
	this.Info_Controls.Button_Player_Difficulty_Up.Set_Tab_Order(Declare_Enum())
	this.Info_Controls.Button_Player_Difficulty_Down.Set_Tab_Order(Declare_Enum())

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
				if (texture == nil) then
					Info_Controls.Quad_Faction_Icon.Set_Hidden(true)
				else
					Info_Controls.Quad_Faction_Icon.Set_Texture(texture)
					Info_Controls.Quad_Faction_Icon.Set_Hidden(false)
				end
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
						PGLobby_Set_Player_Solid_Color(quad, ({ a = 1, b = 1, g = 1, r = 1, }))
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
		Info_Controls.Quad_Accept_Icon.Set_Hidden(not AcceptUIVisible)
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

	if (not Model_Has_Changed(model)) then
		return
	end

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
	end

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Clear_UI()
	Set_Is_AI(false)
	DataModel = INVALID_DATA_MODEL
	IsReserved = false
	Set_Medals_Visible(true)
	Info_Controls.Quad_Player_Color.Set_Hidden(false)
	Info_Controls.Text_Player_Team.Set_Hidden(false)
	Info_Controls.Quad_Faction_Icon.Set_Hidden(false)
	Info_Controls.Clock_Download_Progress.Set_Hidden(true)
	Info_Controls.Quad_Accept_Icon.Set_Hidden(not AcceptUIVisible)
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

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Accept_UI_Visible(value)
	AcceptUIVisible = value
	this.Info_Controls.Quad_Accept_Icon.Set_Hidden(not AcceptUIVisible)
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
Interface.Set_Accept_UI_Visible = Set_Accept_UI_Visible
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
	PGNetwork_Init = nil
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

