-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Scenario_Setup_Dialog.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Scenario_Setup_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Nader_Akoury $
--
--            $Change: 87256 $
--
--          $DateTime: 2007/11/02 15:10:03 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	PGNetwork_Init()

	this.Register_Event_Handler("Button_Clicked", this.Button_Cancel, Hide_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Button_Start_Game, Start_Scenario)
	this.Register_Event_Handler("Button_Clicked", this.Button_Official_Maps, Show_Official_Maps)
	this.Register_Event_Handler("Button_Clicked", this.Button_Custom_Maps, Show_Custom_Maps)
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Faction, Faction_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Faction, Play_Select_Option_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Difficulty, Difficulty_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Difficulty, Play_Select_Option_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Scenario_List_Box, Scenario_Selection_Changed)
	this.Register_Event_Handler("List_Box_Scroll_Bar_Changed", this.Scenario_List_Box, Play_Select_Option_SFX)	
	
	this.Register_Event_Handler("Mouse_Left_Double_Click", this.Scenario_List_Box, Start_Scenario)
	
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	
	-- Tab order
	this.Button_Official_Maps.Set_Tab_Order(Declare_Enum(0))
	this.Button_Custom_Maps.Set_Tab_Order(Declare_Enum())
	this.Scenario_List_Box.Set_Tab_Order(Declare_Enum())
	this.Combo_Difficulty.Set_Tab_Order(Declare_Enum())
	this.Combo_Faction.Set_Tab_Order(Declare_Enum())
	this.Button_Cancel.Set_Tab_Order(Declare_Enum())
	this.Button_Start_Game.Set_Tab_Order(Declare_Enum())

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	SCENARIO = Create_Wide_String("SCENARIO")
	this.Scenario_List_Box.Set_Header_Style("NONE")
	this.Scenario_List_Box.Add_Column(SCENARIO, JUSTIFY_LEFT)
	this.Scenario_List_Box.Refresh()

	-- Initialize the Faction combo
	Factions = CampaignManager.Generate_Faction_List()
	for _, faction in pairs(Factions) do
		this.Combo_Faction.Add_Item(faction.Display_Name)
	end
	this.Combo_Faction.Set_Selected_Index(0)

	-- Initialize the Difficulty combo
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_EASY_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_NORMAL_NAME"))
	this.Combo_Difficulty.Add_Item(Get_Game_Text("TEXT_DIFFICULTY_HARD_NAME"))
	
	--Default to normal difficulty
	this.Combo_Difficulty.Set_Selected_Index(1)

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




function Display_Dialog()
	Difficulty = 0
	Selected_Scenario = nil
	Faction = Factions[1].Index

	-- XXX: Properly hook this in
	if not Custom_Maps_Available then
		this.Button_Custom_Maps.Enable(false)
	end

	-- XXX: Need to be able to get preview images
	this.Preview_Image.Set_Hidden(true)

	Show_Official_Maps()
end

function Generate_Map_List(custom)
	if custom then
		Scenarios = CampaignManager.Generate_Campaign_List(false)
	else
		Scenarios = CampaignManager.Generate_Campaign_List(false)
	end
end

function Display_Scenarios()
	this.Scenario_List_Box.Clear()

	for _, scenario in pairs(Scenarios) do
		local new_row = this.Scenario_List_Box.Add_Row()
		this.Scenario_List_Box.Set_Text_Data(SCENARIO, new_row, scenario.Display_Name)
	end
	this.Scenario_List_Box.Set_Selected_Row_Index(0)
	Scenario_Selection_Changed()
end

function Start_Scenario(event_name, source)
	-- Start the campaign for the selected mission
	if Selected_Scenario ~= nil then
		CampaignManager.Start_Campaign(Selected_Scenario.Name, Difficulty, Faction)
		Hide_Dialog()
	end
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()
end

function Show_Official_Maps()
	Generate_Map_List(false)
	Display_Scenarios()
end

function Show_Custom_Maps()
	Generate_Map_List(true)
	Display_Scenarios()
end

-------------------------------------------------------------------------------
-- Faction combo
-------------------------------------------------------------------------------
function Faction_Combo_Selection_Changed(event, source)
	-- Faction table uses 1-based indexing
	local selected_index = this.Combo_Faction.Get_Selected_Index() + 1

	if selected_index > 0 then
		Faction = Factions[selected_index].Index
	end
end

-------------------------------------------------------------------------------
-- Difficulty combo
-------------------------------------------------------------------------------
function Difficulty_Combo_Selection_Changed(event, source)
	Difficulty = this.Combo_Difficulty.Get_Selected_Index()
end

function Scenario_Selection_Changed(event, source)
	-- The Scenarios table uses 1-based indexing
	local highlighted_scenario = this.Scenario_List_Box.Get_Selected_Row_Index() + 1

	if highlighted_scenario == 0 then
		Selected_Scenario = nil
		return
	end

	Selected_Scenario = Scenarios[highlighted_scenario]
	this.Text_Description.Set_Text(Selected_Scenario.Description)
end
