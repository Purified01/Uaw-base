-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Skirmish_Battle_Setup.lua#13 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Skirmish_Battle_Setup.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Chris_Rubyor $
--
--            $Change: 76916 $
--
--          $DateTime: 2007/07/17 09:33:25 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")
require("PGPlayerProfile")
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
require("PGFactions")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	MIN_AI_PLAYERS = 1
	MAX_AI_PLAYERS = 7

	PGNetwork_Init()
	PGPlayerProfile_Init_Constants()
	Register_Game_Scoring_Commands()

	SKIRMISH_CONFIGURATION_VERSION = "1.0"

	Skirmish_Configuration = Get_Profile_Value(PP_LAST_SKIRMISH_CONFIGURATION, {})
	if Skirmish_Configuration == nil or Skirmish_Configuration.Version ~= SKIRMISH_CONFIGURATION_VERSION then
		Skirmish_Configuration = {}
	end

	Client_Table = Skirmish_Configuration.Client_Table
	if Client_Table == nil then
		Client_Table = {}
	end

	-- register required event handlers
	this.Register_Event_Handler("Button_Clicked", this.Back_Button, Hide_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Start_Game_Button, Start_Game)
	this.Register_Event_Handler("Number_Edit_Box_Changed", this.AI_Number_Edit_Box, Number_Of_AI_Changed)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Victory_Condition, Victory_Condition_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Victory_Condition, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Map_List, Play_Option_Select_SFX)

	-- get the ai rows
	AI_Setup_Rows = {}
	AI_Setup_Rows = Find_GUI_Components(this, "AI_Setup_Row")

	-- Set the player row as the first row
	AI_Setup_Rows[1].Set_As_Player()

	for i, row in pairs(AI_Setup_Rows) do
		if Client_Table[i] ~= nil then
			row.Set_Client_Data(Client_Table[i])
		end
	end

	-- Setup the tab ordering
	this.AI_Number_Edit_Box.Set_Tab_Order(Declare_Enum(0))
	this.Combo_Victory_Condition.Set_Tab_Order(Declare_Enum())
	for index, row in pairs(AI_Setup_Rows) do
		row.Set_Tab_Order(Declare_Enum())
	end
	this.Map_List.Set_Tab_Order(Declare_Enum())
	this.Back_Button.Set_Tab_Order(Declare_Enum())
	this.Start_Game_Button.Set_Tab_Order(Declare_Enum())

	-- Initialize the Victory Condition combo
	Init_Victory_Condition_Constants()
	for _, condition in pairs(VictoryConditionNames) do
		this.Combo_Victory_Condition.Add_Item(condition)
	end

	local index = Skirmish_Configuration.Victory_Condition_Index
	if index == nil then
		Victory_Condition_Index = 0
		this.Combo_Victory_Condition.Set_Selected_Index(0)
	else
		Victory_Condition_Index = index
		this.Combo_Victory_Condition.Set_Selected_Index(index)
	end

	-- Initialize the min and max values of the number edit box
	this.AI_Number_Edit_Box.Initialize(MIN_AI_PLAYERS, MAX_AI_PLAYERS)
	if Skirmish_Configuration.Number_Of_AI ~= nil then
		this.AI_Number_Edit_Box.Set_Value(Skirmish_Configuration.Number_Of_AI)
	end

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	-- Initialize the map list box
	Map_List = this.Map_List
	MAP_NAME = Create_Wide_String("MAP_NAME")
	Map_List.Set_Header_Style("NONE")
	Map_List.Add_Column(MAP_NAME, JUSTIFY_LEFT)
	Map_List.Refresh()

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
		if source == this.Back_Button then 
			Play_SFX_Event("GUI_Main_Menu_Back_Select")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
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



function Get_Map_Names()
	Maps = {}
	table.insert(Maps, "Brazillian_Highlands_E3.ted")
	table.insert(Maps, "M07_Turkestan.ted")
	table.insert(Maps, "M29_Brazillian_Highlands.ted")
	table.insert(Maps, "M08_Eastern_Siberia.ted")
	table.insert(Maps, "M21_South_Africa.ted")
	table.insert(Maps, "M24_Midwest.ted")
	table.insert(Maps, "M15_Middle_East.ted")
	table.insert(Maps, "BMH_Multi_Test.ted")
	table.insert(Maps, "BMH_Multi_Test2.ted")
	table.insert(Maps, "Barebones_MP.ted")
	table.insert(Maps, "_Multi_Base_Test.ted")
end

function Populate_Map_List(map)
	Map_List.Clear()

	for _, map_name in pairs(Maps) do
		local new_row = Map_List.Add_Row()
		Map_List.Set_Text_Data(MAP_NAME, new_row, map_name)
	end
end

function Display_Dialog()
	this.AI_Number_Edit_Box.Set_Hidden(false)

	-- make this addition only once because the first index is the player
	Number_Of_AI = this.AI_Number_Edit_Box.Get_Value() + 1
	for i, row in pairs(AI_Setup_Rows) do
		if i <= Number_Of_AI then
			row.Set_Hidden(false)
		end
	end

	this.Focus_First()

	-- Initialize the Map list box
	Get_Map_Names()
	Populate_Map_List(Maps)

	local index = Skirmish_Configuration.Map_Index
	if index == nil then
		Map_List.Set_Selected_Row_Index(0)
	else
		Map_List.Set_Selected_Row_Index(index)
	end
end

function Hide_Dialog(event_name, source)
	this.AI_Number_Edit_Box.Set_Hidden(true)
	for _, row in pairs(AI_Setup_Rows) do
		row.Set_Hidden(true)
	end
	this.Set_Hidden(true)
	this.End_Modal()
end

-------------------------------------------------------------------------------
-- Victory Condition combo
-------------------------------------------------------------------------------
function Victory_Condition_Combo_Selection_Changed(event, source)
	Victory_Condition = this.Combo_Victory_Condition.Get_Selected_Text_Data()
	Victory_Condition_Index = this.Combo_Victory_Condition.Get_Selected_Index()
end

function Number_Of_AI_Changed(event_name, source, number)
	-- make this addition only once because the first index is the player
	Number_Of_AI = number + 1

	for index, row in pairs(AI_Setup_Rows) do
		if index <= Number_Of_AI then -- index starts at one
			row.Set_Hidden(false)
		else
			row.Set_Hidden(true)
		end
	end
	
	Play_Option_Select_SFX(nil, this.AI_Number_Edit_Box)
end

function Start_Game()
	Hide_Dialog()

	Client_Table = { }
	for index, row in pairs(AI_Setup_Rows) do
		if index > Number_Of_AI then break end

		 -- Setup the AI Player 
		 Client_Table[index] = row.Get_Client_Data()
		 Client_Table[index].common_addr = "AIPlayer" .. tostring(index)
		 Client_Table[index].name = Create_Wide_String("AIPlayer" .. tostring(index))
	end

	-- Setup the local player
	LocalClient = Client_Table[1]
	LocalClient.common_addr = Net.Get_Local_Addr()
	LocalClient.name = Get_Profile_Value(PP_NAME, Get_Game_Text("TEXT_DEFAULT_PLAYER_NAME"))

	GameOptions.seed = 12345
	GameOptions.is_lan = false
	GameOptions.is_campaign = false
	GameOptions.is_internet = false
	GameOptions.is_skirmish = true
	local map_index = Map_List.Get_Selected_Row_Index()
	local map_file = tostring(Map_List.Get_Text_Data(MAP_NAME, map_index))
	GameOptions.map_name = ".\\Data\\Art\\Maps\\" .. map_file
	
	--For some reason lookup isn't working here
	for condition_name, condition_constant in pairs(VictoryConditionConstants) do
		if condition_name == Victory_Condition then
			GameScriptData.victory_condition = condition_constant
		end
	end
	GameScriptData.GameOptions = GameOptions
	Net.MM_Start_Game(GameOptions, Client_Table)
	
	-- Now that the game is started, update the Client_Table with all the newly-assigned
	-- player IDs.
	for _, client in pairs(Client_Table) do
		client.PlayerID = Net.Get_Player_ID_By_Network_Address(client.common_addr)
		if (client.common_addr == LocalClient.common_addr) then
			LocalClient.PlayerID = client.PlayerID
		end
	end

	-- Hand off the client table to the game scoring script.
	Set_Player_Info_Table(Client_Table)
	GameScoringManager.Set_Local_Client_Table(LocalClient)
	GameScoringManager.Set_Game_Script_Data_Table(GameScriptData)

	-- While the map index might change if new maps are added, it is not super important
	-- to have the exact same map selected due to the search cost. This dialog is already slow enough...
	Skirmish_Configuration.Map_Index = map_index
	Skirmish_Configuration.Client_Table = Client_Table
	Skirmish_Configuration.Version = SKIRMISH_CONFIGURATION_VERSION
	Skirmish_Configuration.Number_Of_AI = Number_Of_AI - 1 -- number is actually one fewer because the first index is the player
	Skirmish_Configuration.Victory_Condition_Index = Victory_Condition_Index
	Set_Profile_Value(PP_LAST_SKIRMISH_CONFIGURATION, Skirmish_Configuration)
end
