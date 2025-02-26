if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Scenario_Setup_Dialog.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Scenario_Setup_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Maria_Teruel $
--
--            $Change: 93394 $
--
--          $DateTime: 2008/02/14 16:35:15 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	PGNetwork_Init()

	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Faction, Faction_Combo_Selection_Changed)
	this.Register_Event_Handler("Key_Focus_Gained", this.Combo_Faction, Play_Mouse_Over_Option_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Difficulty, Difficulty_Combo_Selection_Changed)
	this.Register_Event_Handler("Key_Focus_Gained", this.Combo_Difficulty, Play_Mouse_Over_Option_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Scenario_Combo_Box, Scenario_Combo_Selection_Changed)
	this.Register_Event_Handler("Key_Focus_Gained", this.Scenario_Combo_Box, Play_Mouse_Over_Option_SFX)
	
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, Hide_Dialog)
	
	this.Register_Event_Handler("Controller_A_Button_Up", nil, Start_Scenario)

	-- Tab order
	this.Combo_Difficulty.Set_Tab_Order(Declare_Enum(0))
	this.Combo_Faction.Set_Tab_Order(Declare_Enum())
	this.Scenario_Combo_Box.Set_Tab_Order(Declare_Enum())

	RowIndexToFactionName = {}
	-- Initialize the Faction combo
	Factions = CampaignManager.Generate_Faction_List()
	for _, faction in pairs(Factions) do
		local row_val = this.Combo_Faction.Add_Item(faction.Display_Name)
		RowIndexToFactionName[row_val] = faction.Display_Name		
	end
	this.Combo_Faction.Set_Selected_Index(0)

	
	-- Initialize the Difficulty combo
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_EASY_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_NORMAL_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_HARD_NAME"))
	
	Display_Dialog()
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Select_Button_SFX
------------------------------------------------------------------------
function Play_Select_Button_SFX(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end

------------------------------------------------------------------------
-- Play_Mouse_Over_Option_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Option_SFX(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Select_Option_SFX
------------------------------------------------------------------------
function Play_Select_Option_SFX(event, source)
	if TestValid(source) and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end



------------------------------------------------------------------------
-- Display_Dialog
------------------------------------------------------------------------
function Display_Dialog()
	Difficulty = 0
	Selected_Scenario = nil

	-- Always start as the faction displayed in the combo box.	
	-- Else, default to the first faction on the list.
	local selected_index = this.Combo_Faction.Get_Selected_Index() + 1
	if selected_index > 0 then
		Faction = Factions[selected_index].Index
	else
		Faction = Factions[1].Index
	end
	
	this.Combo_Difficulty.Set_Selected_Index(Get_Difficulty())	

	-- XXX: Need to be able to get preview images
	this.Preview_Image.Set_Hidden(true)

	Show_Official_Maps()
	this.Focus_First()
end

------------------------------------------------------------------------
-- Update_Map_Preview
------------------------------------------------------------------------
function Update_Map_Preview()
	if not Selected_Scenario or not Faction then 
		return
	end
	
	local texture_name = CampaignManager.Get_Texture_For_Campaign(Selected_Scenario.Name, Faction)	
	if texture_name then
		this.Earth_Image.Set_Texture(texture_name)
	end
end


------------------------------------------------------------------------
-- Show_Official_Maps
------------------------------------------------------------------------
function Show_Official_Maps()
	Generate_Map_List(false)
	Display_Scenarios()
end

------------------------------------------------------------------------
-- Generate_Map_List
------------------------------------------------------------------------
function Generate_Map_List(custom)
	if custom then
		Scenarios = CampaignManager.Generate_Campaign_List(false)
	else
		Scenarios = CampaignManager.Generate_Campaign_List(false)
	end
end


------------------------------------------------------------------------
-- Display_Scenarios
------------------------------------------------------------------------
function Display_Scenarios()
	this.Scenario_Combo_Box.Clear()

	local new_row = -1
	for _, scenario in pairs(Scenarios) do
		new_row = this.Scenario_Combo_Box.Add_Item(scenario.Display_Name)
		this.Scenario_Combo_Box.Set_Item_Color(new_row, 1, 1, 1, 1)		
	end
	
	this.Scenario_Combo_Box.Set_Selected_Index(0)
	Scenario_Combo_Selection_Changed()
end


------------------------------------------------------------------------
-- Start_Scenario
------------------------------------------------------------------------
function Start_Scenario(event_name, source)
	-- Start the campaign for the selected mission
	if Selected_Scenario ~= nil then
		CampaignManager.Start_Campaign(Selected_Scenario.Name, Difficulty, Faction)
		Hide_Dialog()
	end
end

------------------------------------------------------------------------
-- Hide_Dialog
------------------------------------------------------------------------
function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
	this.Get_Containing_Scene().Raise_Event("Heavyweight_Child_Scene_Closing", nil, {"Scenario_Setup_Dialog"})
end


-------------------------------------------------------------------------------
-- Faction_Combo_Selection_Changed
-------------------------------------------------------------------------------
function Faction_Combo_Selection_Changed(event, source)
	-- Faction table uses 1-based indexing
	local selected_index = this.Combo_Faction.Get_Selected_Index() + 1

	if selected_index > 0 then
		Faction = Factions[selected_index].Index
		Update_Map_Preview()
		Play_Select_Option_SFX(event, source)
	end
end

-------------------------------------------------------------------------------
-- Difficulty_Combo_Selection_Changed
-------------------------------------------------------------------------------
function Difficulty_Combo_Selection_Changed(event, source)
	Difficulty = this.Combo_Difficulty.Get_Selected_Index()
	Play_Select_Option_SFX(event, source)
end

-------------------------------------------------------------------------------
-- Scenario_Combo_Selection_Changed
-------------------------------------------------------------------------------
function Scenario_Combo_Selection_Changed(event, source)
	-- The Scenarios table uses 1-based indexing
	local highlighted_scenario = this.Scenario_Combo_Box.Get_Selected_Index() + 1
	if highlighted_scenario == 0 then
		Selected_Scenario = nil
		return
	end

	Selected_Scenario = Scenarios[highlighted_scenario]
	this.Text_Description.Set_Text(Selected_Scenario.Description)
	Update_Map_Preview()
	Play_Select_Option_SFX(event, source)
end


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
	Broadcast_Heartbeat = nil
	Broadcast_Host_Disconnected = nil
	Broadcast_IArray_In_Chunks = nil
	Broadcast_Multiplayer_Winner = nil
	Broadcast_Stats_Registration_Begin = nil
	Check_Accept_Status = nil
	Check_Color_Is_Taken = nil
	Check_Guest_Accept_Status = nil
	Check_Stats_Registration_Status = nil
	Check_Unique_Colors = nil
	Check_Unique_Teams = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Client_Table_Count = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Is_Player_Of_Faction = nil
	Max = nil
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
	Network_Get_Client_Table_Count = nil
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
	Network_Update_Local_Common_Addr = nil
	OutputDebug = nil
	PGNetwork_Clear_Start_Positions = nil
	PGNetwork_Internet_Init = nil
	PGNetwork_LAN_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Send_User_Settings = nil
	Set_All_AI_Accepts = nil
	Set_All_Client_Accepts = nil
	Set_Client_Table = nil
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
	Validate_Player_Uniqueness = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
