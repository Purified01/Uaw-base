-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/AI_Setup_Row.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/AI_Setup_Row.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Maria_Teruel $
--
--            $Change: 74360 $
--
--          $DateTime: 2007/06/26 09:45:52 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGColors")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	Register_User_Event("Swap_Client_Color")
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Team, Team_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Team, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Color, Color_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Color, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Skill, Skill_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Skill, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("List_Selected_Index_Changed", this.Combo_Faction, Faction_Combo_Selection_Changed)
	this.Register_Event_Handler("List_Display_State_Changed", this.Combo_Faction, Play_Option_Select_SFX)
	
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)

	this.Combo_Skill.Set_Tab_Order(Declare_Enum(0))
	this.Combo_Faction.Set_Tab_Order(Declare_Enum())
	this.Combo_Team.Set_Tab_Order(Declare_Enum())
	this.Combo_Color.Set_Tab_Order(Declare_Enum())

	-- Find other rows in the scene
	Find_Other_Rows()

	-- Register event handlers for the other rows
	for _, row in pairs(Other_Rows) do
		this.Register_Event_Handler("Swap_Client_Color", nil, Swap_Client_Color)
	end

	-- Setup the AI Player
	Client_Data = {}
	Client_Data.is_ai = true
	Client_Data.name = Create_Wide_String("AIPlayer")

	-- Initialize the color list
	PGColors_Init()
	for i = 0, NUM_MP_COLORS do
		this.Combo_Color.Add_Texture(Create_Wide_String("chat_color_rect.tga"))
		local label = MP_COLORS_LABEL_LOOKUP[MP_COLORS[i]]
		local dao = MP_COLOR_TRIPLES[label]
		this.Combo_Color.Set_Item_Color(i, dao.r, dao.g, dao.b, dao.a)
	end

	-- Setup faction lookup table which is required to map the name "Hierarchy" to the name "Alien"
	-- which is used internally. It is the only faction that has this problem but I need to do
	-- the lookup in general. This is the way Brian wanted it done. 4/24/2007 5:39:35 PM -- NSA
	Alien_Display_Name = Get_Game_Text("TEXT_FACTION_ALIEN")
	Masari_Display_Name = Get_Game_Text("TEXT_FACTION_MASARI")
	Novus_Display_Name = Get_Game_Text("TEXT_FACTION_NOVUS")

	Alien_Name = "ALIEN"
	Masari_Name = "MASARI"
	Novus_Name = "NOVUS"

	Faction_Lookup_Table = { }
	Faction_Lookup_Table[tostring(Alien_Display_Name)] = Alien_Name
	Faction_Lookup_Table[tostring(Masari_Display_Name)] = Masari_Name
	Faction_Lookup_Table[tostring(Novus_Display_Name)] = Novus_Name

	Reverse_Faction_Lookup_Table = { }
	Reverse_Faction_Lookup_Table[Alien_Name] = 0
	Reverse_Faction_Lookup_Table[Masari_Name] = 1
	Reverse_Faction_Lookup_Table[Novus_Name] = 2

	-- Initialize the Faction combo
	this.Combo_Faction.Add_Item(Alien_Display_Name)
	this.Combo_Faction.Add_Item(Masari_Display_Name)
	this.Combo_Faction.Add_Item(Novus_Display_Name)

	-- Initialize the Skill combo
	this.Combo_Skill.Add_Item(Get_Game_Text("TEXT_EASY_AI_PLAYER"))
	this.Combo_Skill.Add_Item(Get_Game_Text("TEXT_MEDIUM_AI_PLAYER"))
	this.Combo_Skill.Add_Item(Get_Game_Text("TEXT_HARD_AI_PLAYER"))

	-- Initialize the Team combo
	NUM_TEAMS = 8
	for i = 1, NUM_TEAMS do
		local Numbered_Team = Get_Game_Text("TEXT_TEAM_NUMBERED")
		this.Combo_Team.Add_Item(Replace_Token(Numbered_Team, Get_Localized_Formatted_Number(i), 0))
	end

	Initialize_Default_Selections()
	Display_Dialog()
end

-- I couldn't think of a quick way to do this procedurally...
function Initialize_Default_Selections()
	if Client_Data_Set then return end

	Default_Color_Map = {}
	local combo_index = 0
	for _, color_index in pairs(MP_COLOR_INDICES) do
		Default_Color_Map[combo_index] = color_index
		combo_index = combo_index + 1
	end

	this.Combo_Team.Set_Selected_Index(This_Index)
	this.Combo_Skill.Set_Selected_Index(1) -- default to medium
	this.Combo_Faction.Set_Selected_Index(Math.mod(This_Index,3))
	this.Combo_Color.Set_Selected_Index(Default_Color_Map[This_Index])
end

------------------------------------------------------------------------
-- Play_Option_Select_SFX
------------------------------------------------------------------------
function Play_Option_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
end



function Swap_Client_Color(event, source, new, old)
	if new == this.Combo_Color.Get_Selected_Item_Color() then
		local index = MP_COLOR_INDICES[old]
		if (index == nil) then
			index = 0
		end
		this.Combo_Color.Set_Selected_Index(index)
		this.Combo_Color.Refresh()
	end
end

function Find_Other_Rows()
	Other_Rows = Find_GUI_Components(this.Get_Containing_Scene(), "AI_Setup_Row")
	for i, row in ipairs(Other_Rows) do
		if row == this.Get_Containing_Component() then
			table.remove(Other_Rows, i)
			This_Index = i - 1 -- all combo boxes are zero based so I might as well
			break
		end
	end
end

function Display_Dialog()
end

function Hide_Dialog(event_name, source)
  this.Set_Hidden(true)
  this.End_Modal()
end

function Set_As_Player()
  -- Remove the skill combo box
  this.Combo_Skill.Enable(false)
  this.Combo_Skill.Set_Hidden(true)

  -- Set the appropriate client data
  Client_Data.is_ai = false
  Client_Data.name = Create_Wide_String("LocalPlayer")
end

-------------------------------------------------------------------------------
-- Faction combo
-------------------------------------------------------------------------------
function Faction_Combo_Selection_Changed(event, source)
  local faction = this.Combo_Faction.Get_Selected_Text_Data()
  Client_Data.faction = Faction_Lookup_Table[tostring(faction)]
end

-------------------------------------------------------------------------------
-- Color combo
-------------------------------------------------------------------------------
function Color_Combo_Selection_Changed(event, source)
	local old = Client_Data.color
	Client_Data.color = MP_COLORS[this.Combo_Color.Get_Selected_Index()]
	if old ~= nil and old ~= Client_Data.color then
		for _, row in pairs(Other_Rows) do
			row.Raise_Event_Immediate("Swap_Client_Color", {Client_Data.color, old})
		end
	end
end

-------------------------------------------------------------------------------
-- Team combo
-------------------------------------------------------------------------------
function Team_Combo_Selection_Changed(event, source)
  local team_index = this.Combo_Team.Get_Selected_Index()
  Client_Data.team = team_index + 1		-- Index is zero-based, combo starts a Team 1
end

-------------------------------------------------------------------------------
-- Skill combo
-------------------------------------------------------------------------------
function Skill_Combo_Selection_Changed(event, source)
  Client_Data.ai_difficulty = this.Combo_Skill.Get_Selected_Index()
end

function Get_Client_Data()
  return Client_Data
end

function Set_Client_Data(data)
	Client_Data = data
	Client_Data_Set = true

	this.Combo_Team.Set_Selected_Index(data.team-1)		-- Index is zero-based, combo starts a Team 1
	this.Combo_Skill.Set_Selected_Index(data.ai_difficulty)
	this.Combo_Faction.Set_Selected_Index(Reverse_Faction_Lookup_Table[data.faction])
	
	local index = MP_COLOR_INDICES[data.color]
	if (index == nil) then
		this.Combo_Color.Set_Selected_Index(0)
	else
		this.Combo_Color.Set_Selected_Index(index)
	end
end

Interface = {}
Interface.Set_As_Player = Set_As_Player
Interface.Get_Client_Data = Get_Client_Data
Interface.Set_Client_Data = Set_Client_Data
