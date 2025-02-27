if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Mod_Dialog.lua#3 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Mod_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92481 $
--
--          $DateTime: 2008/02/05 12:16:28 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

function On_Init()
	this.Register_Event_Handler("Closing_All_Displays", nil, Close_Dialog)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.BackButton, Back_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.PlayButton, Play_Clicked)
end

function Display_Dialog()
end

function Close_Dialog()
	this.End_Modal()
	this.Set_Hidden(true)
end

function Back_Clicked()
	Close_Dialog()
end

function Play_Clicked()
	ClientTable = {}

	-- Setup the local player
	ClientTable[1] = {}
	ClientTable[1].name = Create_Wide_String("LocalPlayer")
	ClientTable[1].common_addr = Net.Get_Local_Addr()
	ClientTable[1].faction = "Novus"
	ClientTable[1].color = 15
	ClientTable[1].is_ai = false
	ClientTable[1].team = 1
	LocalClient = ClientTable[1]

	-- Setup the AI Player
	ClientTable[2] = {}
	ClientTable[2].name = Create_Wide_String("AIPlayer")
	ClientTable[2].common_addr = "AIPlayer1"
	ClientTable[2].faction = "Alien"
	ClientTable[2].color = 2
	ClientTable[2].is_ai = true
	ClientTable[2].ai_difficulty = 1
	ClientTable[2].team = 2

	GameOptions = {}
	GameOptions.seed = 12345
	GameOptions.map_name = ".\\Data\\Art\\Maps\\M29_Brazillian_Highlands.ted"
	GameOptions.is_campaign = false
	GameOptions.is_lan = false
	GameOptions.is_internet = false
	
	GameScriptData = {}
	GameScriptData.victory_condition = VICTORY_CONQUER	
	GameScriptData.is_defcon_game = true
	GameScriptData.GameOptions = GameOptions

	Net.MM_Start_Game(GameOptions, ClientTable)
	
	-- Now that the game is started, update the ClientTable with all the newly-assigned
	-- player IDs.
	for _, client in pairs(ClientTable) do
		client.PlayerID = Net.Get_Player_ID_By_Network_Address(client.common_addr)
		if (client.common_addr == LocalClient.common_addr) then
			LocalClient.PlayerID = client.PlayerID
		end
	end

	-- Hand off the client table to the game scoring script.
	Set_Player_Info_Table(ClientTable)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)
	GameScoringManager.Set_Is_Ranked_Game(false)
	GameScoringManager.Set_Is_Global_Conquest_Game(false)

	Close_Dialog()
end

function Set_Player_Info_Table(client_table)
 
      Register_Game_Scoring_Commands()
      
      local player_info_table = Create_Player_Info_Table(client_table) 
      local unmutable_player_info_table = Create_Player_Info_Table(client_table)
      
      GameScoringManager.Set_Player_Info_Table(player_info_table, false)      -- Sets the table that will be used in game script.
      GameScoringManager.Set_Player_Info_Table(unmutable_player_info_table, true)   -- Sets the table that will be used to init replays.
end
 
function Create_Player_Info_Table(client_table)
     -- Build the buff models
      player_display = {}
      faction_display = {}
      buff_display = {}
      buff_label = {}
 
      -- Here we are building an array whose keys are the player ID.
      for _, client in pairs(client_table) do
            player_display[client.PlayerID] = client.name
            faction_display[client.PlayerID] = client.faction
            buff_display[client.PlayerID] = {}
            buff_label[client.PlayerID] = {}
 
      end
      
      local result = 
      {
            ClientTable = client_table,
            PlayerDisplayModel = player_display,
            FactionDisplayModel = faction_display,
            BuffDisplayModel = buff_display,
            BuffLabelModel = buff_label
      }     
      
      return result
 
end

Interface = { }
Interface.Display_Dialog = Display_Dialog
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Kill_Unused_Global_Functions = nil
end
