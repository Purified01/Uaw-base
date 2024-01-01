-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Debug_Load_Mission_Dialog.lua#9 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Debug_Load_Mission_Dialog.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Maria_Teruel $
--
--            $Change: 74336 $
--
--          $DateTime: 2007/06/25 18:20:45 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGNetwork")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Back_Button, Hide_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Novus_Button, Show_Novus_Missions)
	this.Register_Event_Handler("Button_Clicked", this.Hierarchy_Button, Show_Hierarchy_Missions)
	this.Register_Event_Handler("Button_Clicked", this.Masari_Button, Show_Masari_Missions)
	this.Register_Event_Handler("Button_Clicked", this.Start_Mission_Button, Start_Mission)
	this.Register_Event_Handler("Mouse_Left_Double_Click", this.Mission_List, Start_Mission)

	-- Tab order
	this.Novus_Button.Set_Tab_Order(Declare_Enum(0))
	this.Hierarchy_Button.Set_Tab_Order(Declare_Enum())
	this.Masari_Button.Set_Tab_Order(Declare_Enum())
	this.Mission_List.Set_Tab_Order(Declare_Enum())
	this.Back_Button.Set_Tab_Order(Declare_Enum())
	this.Start_Mission_Button.Set_Tab_Order(Declare_Enum())

	-- Text formatting
	-- Duplicated from GUIFont.h
	JUSTIFY_LEFT = Declare_Enum(0)
	JUSTIFY_CENTER = Declare_Enum()
	JUSTIFY_RIGHT = Declare_Enum()

	MISSION = Create_Wide_String("MISSION")
	this.Mission_List.Set_Header_Style("NONE")
	this.Mission_List.Add_Column(MISSION, JUSTIFY_LEFT)
	this.Mission_List.Refresh()

	Novus_Campaign = "NOVUS"
	Hierarchy_Campaign = "ALIEN"
	Masari_Campaign = "MASARI"

	Novus_Missions = {}
	table.insert(Novus_Missions, "State_Start_Tut01") -- first tutorial ... at capitol building
	table.insert(Novus_Missions, "State_Start_Tut02") -- second tutorial ... at military base south of Capitol Building
	table.insert(Novus_Missions, "State_Start_NM01") --first Novus mission -- near the pyramids
	table.insert(Novus_Missions, "State_Start_NM01_Dialogue") --first Novus mission -- near the pyramids
	table.insert(Novus_Missions, "State_Start_NM02") -- second Novus mission -- in England
	table.insert(Novus_Missions, "State_Start_NM02_Dialogue") -- second Novus mission -- in England
	table.insert(Novus_Missions, "State_Start_NM03") -- third novus -- Siberia
	table.insert(Novus_Missions, "State_Start_NM03_Dialogue") -- third novus -- Siberia
	table.insert(Novus_Missions, "State_Start_NM04") -- forth Novus -- TBD
	table.insert(Novus_Missions, "State_Start_NM04_Dialogue") -- forth Novus -- TBD
	table.insert(Novus_Missions, "State_Start_NM05") -- fifth Novus -- South Africa
	table.insert(Novus_Missions, "State_Start_NM05_Dialogue") -- fifth Novus -- South Africa
	table.insert(Novus_Missions, "State_Start_NM06") -- sixth Novus -- ZRH interior
	table.insert(Novus_Missions, "State_Start_NM06_Dialogue") -- sixth Novus -- ZRH interior
	table.insert(Novus_Missions, "State_Start_NM07") -- Seventh Novus -- NM01 map ... near the pyramids
	table.insert(Novus_Missions, "State_Novus_Campaign_Over") -- goto ZRH campaign -- right now just exits to main menu
	
	Hierarchy_Missions = {}
	table.insert(Hierarchy_Missions, "State_Start_ZM01") -- first Hierarchy mission: (16) Sahara (Pyramids of Giza)
	table.insert(Hierarchy_Missions, "State_Start_ZM02_Dialogue")
	table.insert(Hierarchy_Missions, "State_Start_ZM02") -- second Hierarchy mission: (23) Gulf Coast (Florida)
	table.insert(Hierarchy_Missions, "State_Start_ZM03_Dialogue")
	table.insert(Hierarchy_Missions, "State_Start_ZM03") -- third Hierarchy mission: (22) Atlantic Ocean (Atlatea)
	table.insert(Hierarchy_Missions, "State_Start_ZM04_Dialogue")
	table.insert(Hierarchy_Missions, "State_Start_ZM04") -- forth Hierarchy mission: (30) Altiplano
	table.insert(Hierarchy_Missions, "State_Start_ZM05_Dialogue")
	table.insert(Hierarchy_Missions, "State_Start_ZM05") -- fifth Hierarchy mission: (13) Indochina (Masari Temple)
	table.insert(Hierarchy_Missions, "State_Start_ZM06") -- sixth Hierarchy mission: (35) Central America (Arecibo, Puerto Rico)
	table.insert(Hierarchy_Missions, "State_Hierarchy_Campaign_Over") -- goto Masari campaign -- right now just exits to main menu
	
	Masari_Missions = {}
	table.insert(Masari_Missions, "State_Start_MM01") -- TBD Anahuac
	table.insert(Masari_Missions, "State_Start_Global") -- Global Game
	table.insert(Masari_Missions, "State_Start_MM07") -- 34 - Anahuac
	table.insert(Masari_Missions, "State_Masari_Campaign_Over") -- right now just exits to main menu

	Campaigns = { }
	Campaigns[Novus_Campaign] = Novus_Missions
	Campaigns[Hierarchy_Campaign] = Hierarchy_Missions
	Campaigns[Masari_Campaign] = Masari_Missions

	Campaign_Name = { }
	Campaign_Name[Novus_Campaign] = "NOVUS_Story_Campaign"
	Campaign_Name[Hierarchy_Campaign] = "Hierarchy_Story_Campaign"
	Campaign_Name[Masari_Campaign] = "MASARI_Story_Campaign"

	Current_Campaign = Novus_Campaign
	Register_Game_Scoring_Commands()

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


------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		if source == this.Back_Button then 
			Play_SFX_Event("GUI_Main_Menu_Back_Select ")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
	end
end


function Display_Dialog()
	Display_Current_Missions()
end

function Display_Current_Missions()
	this.Mission_List.Clear()
	
	local mission_list = Campaigns[Current_Campaign]

	for _, mission_name in pairs(mission_list) do
		local new_row = this.Mission_List.Add_Row()
		this.Mission_List.Set_Text_Data(MISSION, new_row, mission_name)
	end
end

function Start_Mission(event_name, source)
	local highlighted = this.Mission_List.Get_Selected_Row_Index()

	if highlighted == -1 then return end

	local mission_name = this.Mission_List.Get_Text_Data(MISSION, highlighted)

	-- Insert the debug mission name into the game script data table
	local data_table = GameScoringManager.Get_Game_Script_Data_Table()
	if data_table == nil then
		data_table = { }
	end
	data_table.Debug_Start_Mission = mission_name
	GameScoringManager.Set_Game_Script_Data_Table(data_table)

	-- Start the campaign for the selected mission
	CampaignManager.Start_Campaign(Campaign_Name[Current_Campaign])
	Hide_Dialog()
end

function Hide_Dialog()
	GUI_Dialog_Raise_Parent()

	-- Hide this dialog
	this.Set_Hidden(true)

	-- Release the keyboard focus
	this.End_Modal()
end

function Show_Novus_Missions()
	Current_Campaign = Novus_Campaign
	Display_Current_Missions()
end

function Show_Hierarchy_Missions()
	Current_Campaign = Hierarchy_Campaign
	Display_Current_Missions()
end

function Show_Masari_Missions()
	Current_Campaign = Masari_Campaign
	Display_Current_Missions()
end
