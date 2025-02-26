if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Staging_Settings_Panel.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Staging_Settings_Panel.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 95431 $
--
--          $DateTime: 2008/03/18 14:29:10 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGColors")


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	PGColors_Init_Constants()
	
	-- CONSTANTS
	VIEW_STATE_MUTABLE = Declare_Enum(1)
	VIEW_STATE_UNMUTABLE = Declare_Enum()
	
	TEXT_NO = Get_Game_Text("TEXT_NO")
	TEXT_YES = Get_Game_Text("TEXT_YES")
	
	WARNING_TINT = ({ [5] = { a = 1, b = 0, g = 1, r = 0, }, [2] = { a = 1, b = 0, g = 0, r = 1, }, [7] = { a = 1, b = 1, g = 0, r = 0, }, [4] = { a = 1, b = 0, g = 1, r = 1, }, })[4]
	STANDARD_TINT = ({ a = 1, b = 1, g = 1, r = 1, })
	
	-- GLOBALS
	_ViewStateRefreshProcessors = {}
	_ViewStateRefreshProcessors[VIEW_STATE_MUTABLE] = Refresh_UI_Mutable
	_ViewStateRefreshProcessors[VIEW_STATE_UNMUTABLE] = Refresh_UI_Unmutable
	
	_ViewState = VIEW_STATE_UNMUTABLE
	_EditModel = {}
	_ValueModel = {}
	_LastMapSelectionIndex = nil
	_PlayerCount = -1
	
	-- EVENTS
	this.Register_Event_Handler("Controller_A_Button_up", nil, On_Accept_Clicked)
	this.Register_Event_Handler("Controller_B_Button_up", nil, On_Cancel_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_up", nil, On_Cancel_Clicked)
	
	-- SETUP
	Initialize_Components()
	Set_Interactive(false)
	
	Refresh_View_State()

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Initialize_Components()

	-- Host Staging Area Game Settings Panel
	panel = this.Panel_Settings_Mutable
	_SettingsCombos = {}
	table.insert(_SettingsCombos, panel.Combo_Map)
	table.insert(_SettingsCombos, panel.Combo_Win_Condition)
	table.insert(_SettingsCombos, panel.Combo_DEFCON_Active)
	--table.insert(_SettingsCombos, panel.Combo_Alliances)
	table.insert(_SettingsCombos, panel.Combo_Hero_Respawn)
	table.insert(_SettingsCombos, panel.Combo_Starting_Credits)
	table.insert(_SettingsCombos, panel.Combo_Unit_Population_Limit)
	table.insert(_SettingsCombos, panel.Combo_Medals)
	
	Declare_Enum(1)
	for _, combo in ipairs(_SettingsCombos) do
		combo.Set_Tab_Order(Declare_Enum())
	end
	
end
	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	Refresh_UI()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- V I E W
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_View_State()

	if (_ViewState == VIEW_STATE_MUTABLE) then
		this.Panel_Settings_Mutable.Set_Hidden(false)
		this.Panel_Settings_Unmutable.Set_Hidden(true)
	elseif (_ViewState == VIEW_STATE_UNMUTABLE) then
		this.Panel_Settings_Mutable.Set_Hidden(true)
		this.Panel_Settings_Unmutable.Set_Hidden(false)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI()

	local view_processor = _ViewStateRefreshProcessors[_ViewState]
	view_processor()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI_Unmutable()

	if (_ValueModel == nil) then
		return
	end

	-- Win Condition
	this.Panel_Settings_Unmutable.Text_Win_Condition_Value.Set_Text(_ValueModel.WinConditionValue)
	
	-- DEFCON
	this.Panel_Settings_Unmutable.Text_DEFCON_Active_Value.Set_Text(_ValueModel.DEFCONValue)
	
	-- Alliances
	--this.Panel_Settings_Unmutable.Text_Alliances_Value.Set_Text(_ValueModel.AlliancesValue)
	
	-- Medals
	this.Panel_Settings_Unmutable.Text_Medals_Value.Set_Text(_ValueModel.MedalsValue)
	
	-- Hero Respawn
	this.Panel_Settings_Unmutable.Text_Hero_Respawn_Value.Set_Text(_ValueModel.HeroRespawnValue)
	
	-- Starting Credits
	this.Panel_Settings_Unmutable.Text_Starting_Credits_Value.Set_Text(_ValueModel.StartingCreditsValue)
	
	-- Pop Cap
	this.Panel_Settings_Unmutable.Text_Unit_Population_Limit_Value.Set_Text(_ValueModel.PopCapValue)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI_Mutable()

	if (_ValueModel == nil) then
		return
	end
	
	-- Map
	if (_ValueModel.MPMapModelIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Map.Set_Selected_Index(_ValueModel.MPMapModelIndex)
		_LastMapSelectionIndex = _ValueModel.MPMapModelIndex
	end
	
	-- Win Condition
	if (_ValueModel.WinConditionIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Win_Condition.Set_Selected_Index(_ValueModel.WinConditionIndex)
	end
	
	-- DEFCON
	if (_ValueModel.DEFCONIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_DEFCON_Active.Set_Selected_Index(_ValueModel.DEFCONIndex)
	end
	
	-- Alliances
	--[[if (_ValueModel.AlliancesIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Alliances.Set_Selected_Index(_ValueModel.AlliancesIndex)
	end--]]
	
	-- Medals
	if (_ValueModel.MedalsIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Medals.Set_Selected_Index(_ValueModel.MedalsIndex)
	end
	
	-- Hero Respawn
	if (_ValueModel.HeroRespawnIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Hero_Respawn.Set_Selected_Index(_ValueModel.HeroRespawnIndex)
	end
	
	-- Starting Credits
	if (_ValueModel.StartingCreditsIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Starting_Credits.Set_Selected_Index(_ValueModel.StartingCreditsIndex)
	end
	
	-- Pop Cap
	if (_ValueModel.PopCapIndex ~= nil) then
	
		-- Figure out the color.
		local tint = STANDARD_TINT
		if _ValueModel.PopCapMax then
			tint = WARNING_TINT
		end
		
		-- Init the combo contents.
		local handle = this.Panel_Settings_Mutable.Combo_Unit_Population_Limit
		handle.Clear()
		for i, value in ipairs(_EditModel.PopCapModel) do
			if not _ValueModel.PopCapMax or value.data <= _ValueModel.PopCapMax then
				local new_row = handle.Add_Item(value.display)
				handle.Set_Item_Color(new_row, tint["r"], tint["g"], tint["b"], tint["a"]) 
			end
		end
		local max_index = handle.Get_Item_Count() - 1
		if _ValueModel.PopCapIndex > max_index then
			_ValueModel.PopCapIndex = max_index
		end
		
		this.Panel_Settings_Mutable.Text_Unit_Population_Limit.Set_Tint(tint["r"], tint["g"], tint["b"], tint["a"])
		this.Panel_Settings_Mutable.Combo_Unit_Population_Limit.Set_Selected_Index(_ValueModel.PopCapIndex)
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Initialize_UI()

	if (_EditModel == nil) then
		return
	end

	-- Map
	local handle = this.Panel_Settings_Mutable.Combo_Map
	handle.Clear()
	local new_row = -1
	for _, dao in pairs(_EditModel.MPMapModel) do
		local display = Create_Wide_String()
		display.assign(dao.display_name)
		display.append(" (" .. dao.num_players .. ")")
		new_row = handle.Add_Item(display)
		if (_PlayerCount > dao.num_players) then
			handle.Set_Item_Color(new_row, 0.25, 0.25, 0.25, 1)
		else
			handle.Set_Item_Color(new_row, 1, 1, 1, 1)
		end
	end
	handle.Set_Selected_Index(0)

	-- Win Condition
	handle = this.Panel_Settings_Mutable.Combo_Win_Condition
	handle.Clear()
	for _, condition in pairs(_EditModel.VictoryConditionModel) do
		handle.Add_Item(condition)
	end
	handle.Set_Selected_Text_Data(_EditModel.VictoryConditionModel[_EditModel.VictoryConditionValue])
	
	-- DEFCON
	handle = this.Panel_Settings_Mutable.Combo_DEFCON_Active
	handle.Clear()
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(0)
	
	-- Alliances
	--[[handle = this.Panel_Settings_Mutable.Combo_Alliances
	handle.Clear()
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(0)--]]
	
	-- Hero Respawn
	handle = this.Panel_Settings_Mutable.Combo_Hero_Respawn
	handle.Clear()
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(0)

	-- Starting Credits
	handle = this.Panel_Settings_Mutable.Combo_Starting_Credits
	handle.Clear()
	for _, value in ipairs(_EditModel.StartingCreditsModel) do
		handle.Add_Item(value.display)
	end
	handle.Set_Selected_Index(0)

	-- Pop Cap
	handle = this.Panel_Settings_Mutable.Combo_Unit_Population_Limit
	handle.Clear()
	for _, value in ipairs(_EditModel.PopCapModel) do
		handle.Add_Item(value.display)
	end
	handle.Set_Selected_Index(0)

	-- Allow Medals
	handle = this.Panel_Settings_Mutable.Combo_Medals
	handle.Clear()
	handle.Add_Item(TEXT_NO)		-- COMBO_SELECTION_NO
	handle.Add_Item(TEXT_YES)		-- COMBO_SELECTION_YES
	handle.Set_Selected_Index(0)


end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Accept_Clicked()
	
	if (not _Interactive) then
		return
	end
	
	-- Map
	_ValueModel.MPMapModelIndex = this.Panel_Settings_Mutable.Combo_Map.Get_Selected_Index()
	
	-- Win Condition
	_ValueModel.WinConditionIndex = this.Panel_Settings_Mutable.Combo_Win_Condition.Get_Selected_Index()
	
	-- DEFCON
	_ValueModel.DEFCONIndex = this.Panel_Settings_Mutable.Combo_DEFCON_Active.Get_Selected_Index()
	
	-- Alliances
	--_ValueModel.AlliancesIndex = this.Panel_Settings_Mutable.Combo_Alliances.Get_Selected_Index()
	
	-- Hero Respawn
	_ValueModel.HeroRespawnIndex = this.Panel_Settings_Mutable.Combo_Hero_Respawn.Get_Selected_Index()
	
	-- Starting Credits
	_ValueModel.StartingCreditsIndex = this.Panel_Settings_Mutable.Combo_Starting_Credits.Get_Selected_Index()
	
	-- Population Cap
	_ValueModel.PopCapIndex = this.Panel_Settings_Mutable.Combo_Unit_Population_Limit.Get_Selected_Index()
	
	-- Medals
	_ValueModel.MedalsIndex = this.Panel_Settings_Mutable.Combo_Medals.Get_Selected_Index()
	
	-- Release all focus
	for _, combo in ipairs(_SettingsCombos) do
		combo.Clear_Key_Focus()
	end
	
	this.End_Modal()
	this.Get_Containing_Scene().Raise_Event_Immediate("Exit_Staging_Settings", nil, {new_settings_model})

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Cancel_Clicked()
	
	Restore_Panel_Model()
	this.End_Modal()
	this.Get_Containing_Scene().Raise_Event_Immediate("Exit_Staging_Settings", nil, {new_settings_model})
	
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- E V E N T S
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Map_Changed()

	-- First we need to make sure that the new map index is parked at a map which is valid for the number
	-- of players in the current session.  If it is not, we keep iterating in the direction the user is searching
	-- until we find a valid one and set the index to that.	
	local index = this.Panel_Settings_Mutable.Combo_Map.Get_Selected_Index()
	index = index + 1		-- UI is 0-based, model is 1-based
	local map_dao = _EditModel.MPMapModel[index]
	local map_count = #(_EditModel.MPMapModel) 
	
	if (_LastMapSelectionIndex ~= nil) then
	
		local ascending = ((index >= _LastMapSelectionIndex) or ((index == 1) and (_LastMapSelectionIndex == map_count)))
		_LastMapSelectionIndex = index
		
		if (map_dao.num_players < _PlayerCount) then
		
			-- POSSIBLE INFINITE LOOP:
			-- The assumption is that it would be impossible for there to be NO maps that don't have enough player slots,
			-- otherwise we could never have gotten here.  We just keep searching forever until we find a map with enough 
			-- player slots.
			while (map_dao.num_players < _PlayerCount) do
				
				-- Increment / decrement index.
				if (ascending) then
					index = index + 1
				else
					index = index - 1
				end
				
				-- Wrap the selection
				if (index > map_count) then
					index = 1
				elseif (index < 1) then
					index = map_count
				end
				
				-- Get the next DAO
				map_dao = _EditModel.MPMapModel[index]
	
			end
	
			-- Trigger this function being raised again, only this time we'll be dealing with a valid map.
			this.Panel_Settings_Mutable.Combo_Map.Set_Selected_Index(index - 1)		-- UI is 0-based, model is 1-based.
			
			return
			
		end
		
	end

	this.Get_Containing_Scene().Raise_Event_Immediate(
		"Staging_Settings_Combo_Map_Changed", 
		nil, 
		{this.Panel_Settings_Mutable.Combo_Map.Get_Selected_Index()})
		
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Win_Condition_Changed()
	-- Included for completeness.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_DEFCON_Active_Changed()
	-- Included for completeness.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Alliances_Changed()
	-- Included for completeness.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Hero_Respawn_Changed()
	-- Included for completeness.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Starting_Credits_Changed()
	-- Included for completeness.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Unit_Population_Limit_Changed()
	-- Included for completeness.
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Combo_Medals_Changed()
	-- Included for completeness.
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--	Sets the model that drives the population of all the combo boxes 
-- on the mutable panel.
-------------------------------------------------------------------------------
function Set_Edit_Model(model)
	_EditModel = model
	Initialize_UI()
end

-------------------------------------------------------------------------------
-- Sets the selection indices of all the combo boxes on the mutable panel,
-- or the value strings of all the value text components on the unmutable 
-- panel.
-------------------------------------------------------------------------------
function Set_Value_Model(model)
	_ValueModel = model
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Value_Model()
	return _ValueModel
end

-------------------------------------------------------------------------------
--	Shows the combo-box driven panel (intended for hosts only).
-------------------------------------------------------------------------------
function Set_Mutable_State()
	_ViewState = VIEW_STATE_MUTABLE
	Refresh_View_State()
end

-------------------------------------------------------------------------------
-- Shows the purely text driven panel (intended for guests only).
-------------------------------------------------------------------------------
function Set_Unmutable_State()
	_ViewState = VIEW_STATE_UNMUTABLE
	Refresh_View_State()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Interactive(value)

	_Interactive = value
	
	if (_Interactive) then
		Save_Panel_Model()
		this.Panel_Settings_Mutable.Combo_Map.Set_Key_Focus()
	end
	
	for _, combo in ipairs(_SettingsCombos) do
		combo.Set_Interactive(_Interactive)
	end
	
end

-------------------------------------------------------------------------------
-- Saves off a copy of the current model.
-------------------------------------------------------------------------------
function Save_Panel_Model()

	_SavedValueModel = {}
	
	-- Map
	_SavedValueModel.MPMapModelIndex = this.Panel_Settings_Mutable.Combo_Map.Get_Selected_Index()
	
	-- Win Condition
	_SavedValueModel.WinConditionIndex = this.Panel_Settings_Mutable.Combo_Win_Condition.Get_Selected_Index()
	
	-- DEFCON
	_SavedValueModel.DEFCONIndex = this.Panel_Settings_Mutable.Combo_DEFCON_Active.Get_Selected_Index()
	
	-- Alliances
	--_SavedValueModel.AlliancesIndex = this.Panel_Settings_Mutable.Combo_Alliances.Get_Selected_Index()
	
	-- Hero Respawn
	_SavedValueModel.HeroRespawnIndex = this.Panel_Settings_Mutable.Combo_Hero_Respawn.Get_Selected_Index()
	
	-- Starting Credits
	_SavedValueModel.StartingCreditsIndex = this.Panel_Settings_Mutable.Combo_Starting_Credits.Get_Selected_Index()
	
	-- Population Cap
	_SavedValueModel.PopCapIndex = this.Panel_Settings_Mutable.Combo_Unit_Population_Limit.Get_Selected_Index()
	
	-- Medals
	_SavedValueModel.MedalsIndex = this.Panel_Settings_Mutable.Combo_Medals.Get_Selected_Index()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Restore_Panel_Model()

	if (_SavedValueModel == nil) then
		DebugMessage("LUA_STAGING_SETTINGS: ERROR:  Call to restore settings when none are saved.")
		return
	end 

	-- Map
	if (_SavedValueModel.MPMapModelIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Map.Set_Selected_Index(_SavedValueModel.MPMapModelIndex)
	end
	
	-- Win Condition
	if (_SavedValueModel.WinConditionIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Win_Condition.Set_Selected_Index(_SavedValueModel.WinConditionIndex)
	end
	
	-- DEFCON
	if (_SavedValueModel.DEFCONIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_DEFCON_Active.Set_Selected_Index(_SavedValueModel.DEFCONIndex)
	end
	
	-- Alliances
	--[[if (_SavedValueModel.AlliancesIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Alliances.Set_Selected_Index(_SavedValueModel.AlliancesIndex)
	end--]]
	
	-- Hero Respawn
	if (_SavedValueModel.HeroRespawnIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Hero_Respawn.Set_Selected_Index(_SavedValueModel.HeroRespawnIndex)
	end
	
	-- Starting Credits
	if (_SavedValueModel.StartingCreditsIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Starting_Credits.Set_Selected_Index(_SavedValueModel.StartingCreditsIndex)
	end
	
	-- Population Cap
	if (_SavedValueModel.PopCapIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Unit_Population_Limit.Set_Selected_Index(_SavedValueModel.PopCapIndex)
	end
	
	-- Medals
	if (_SavedValueModel.MedalsIndex ~= nil) then
		this.Panel_Settings_Mutable.Combo_Medals.Set_Selected_Index(_SavedValueModel.MedalsIndex)
	end
	
	_SavedValueModel = nil
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Player_Count(value)
	_PlayerCount = value
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Edit_Model = Set_Edit_Model
Interface.Set_Value_Model = Set_Value_Model
Interface.Get_Value_Model = Get_Value_Model
Interface.Set_Mutable_State = Set_Mutable_State
Interface.Set_Unmutable_State = Set_Unmutable_State
Interface.Set_Interactive = Set_Interactive
Interface.Set_Player_Count = Set_Player_Count
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
