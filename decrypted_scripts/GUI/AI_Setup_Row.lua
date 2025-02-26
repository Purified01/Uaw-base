if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/AI_Setup_Row.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/AI_Setup_Row.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #5 $
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
	for i = 0, 7 do
		this.Combo_Color.Add_Texture(Create_Wide_String("chat_color_rect.tga"))
		local label = ({ [1] = "WHITE", [2] = "RED", [3] = "ORANGE", [4] = "YELLOW", [5] = "GREEN", [6] = "CYAN", [7] = "BLUE", [8] = "PURPLE", [9] = "GRAY", })[({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[i]]
		local dao = ({ RED = { a = 1, b = 0.09, g = 0.09, r = 1, }, YELLOW = { a = 1, b = 0.18, g = 0.87, r = 0.89, }, PURPLE = { a = 1, b = 0.82, g = 0.44, r = 1, }, CYAN = { a = 1, b = 0.88, g = 0.85, r = 0.44, }, GREEN = { a = 1, b = 0.31, g = 1, r = 0.47, }, ORANGE = { a = 1, b = 0.09, g = 0.58, r = 1, }, BLUE = { a = 1, b = 1, g = 0.59, r = 0.31, }, GRAY = { a = 1, b = 0.12, g = 0.12, r = 0.12, }, })[label]
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
	for _, color_index in pairs(({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })) do
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
		local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[old]
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
	Client_Data.color = ({ [1] = 7, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 2, [0] = 9, })[this.Combo_Color.Get_Selected_Index()]
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
	
	local index = ({ [6] = 5, [7] = 1, [8] = 6, [3] = 2, [2] = 7, [4] = 3, [9] = 0, [5] = 4, })[data.color]
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
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
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
	Get_GUI_Variable = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
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
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
