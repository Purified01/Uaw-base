if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[133] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[148] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Reinforcement_Manager.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Reinforcement_Manager.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")


-- ---------------------------------------------------------------------------------------------
-- On_Init
-- ---------------------------------------------------------------------------------------------
function On_Init()

	TAB_ORDER_TOGGLE_BUTTON = 1
	TAB_ORDER_PANE = 50
	
	if not Is_Scenario_Campaign() then
		this.Set_State("Closed")
		this.Set_Hidden(true)
		return
	end

	ReinforcementPanes = Find_GUI_Components(this.PanesGroup, "Pane")
	
	for index, pane in pairs(ReinforcementPanes) do
		pane.Set_Tab_Order(TAB_ORDER_PANE + index)	
	end
	
	LocalPlayer = Find_Player("local")
	UpdateFocus = false
	
	this.Register_Event_Handler("Update_Enablers_List", nil, On_Enablers_List_Updated)
	
	this.Register_Event_Handler("Close_All_Active_Displays", this, Close)
	this.Register_Event_Handler("Mouse_Non_Client_Left_Up", this, Close)
	this.Register_Event_Handler("Component_Hidden", nil, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden", nil, Enable_UI_Element_Event)	
	
	-- Maria 01.15.2008
	-- Given that the UI is set up before the game is started (because of the loading threads) we won't be able to initialize this scene
	-- before all the forces have been created.  Hence, we will listen for this event which will be sent as a first service to the scene and 
	-- will ensure proper initialization.
	this.Register_Event_Handler("Initialize_Reinforcement_Objects", nil, On_Initialize_Reinforcement_Objects)
	this.Raise_Event("Initialize_Reinforcement_Objects", nil, nil)
end

-- ---------------------------------------------------------------------------------------------
-- On_Initialize_Reinforcement_Objects
-- ---------------------------------------------------------------------------------------------
function On_Initialize_Reinforcement_Objects(_, _)
	Init_Reinforcement_Objects()
end

-- ---------------------------------------------------------------------------------------------
-- Toggle_Menu_Display - Returns true if the menu is open, false otherwise.
-- ---------------------------------------------------------------------------------------------
function Toggle_Menu_Display()
	if this.Get_Current_State_Name() == "Open" then
		this.Set_State("Closed")
	else
		this.Set_State("Open")
		UpdateFocus = true
		return true
	end	
	return false
end


-- ---------------------------------------------------------------------------------------------
-- Update_Open
-- ---------------------------------------------------------------------------------------------
function Update_Open()
	
	if UpdateFocus then 
		this.Focus_First()
		UpdateFocus = false
	end
	
	for i, pane in pairs(ReinforcementPanes) do
		pane.Update()
	end
end


-- ---------------------------------------------------------------------------------------------
-- Init_Reinforcement_Objects
-- ---------------------------------------------------------------------------------------------
function Init_Reinforcement_Objects()
	ReinforcementObjects = Get_Conflict_Location().Get_Neighboring_Regions_Owned_By_Player(LocalPlayer)
	local hero_reinforcement_objects = Find_Objects_With_Behavior(160, LocalPlayer)
	for _, hero in pairs(hero_reinforcement_objects) do
		if hero.Get_Ghosted_Object().Get_Type().Is_Hero() then
			hero.Register_Signal_Handler(On_Reinforcement_Object_Destroyed, "OBJECT_DELETE_PENDING", this)
			if not ReinforcementObjects then
				ReinforcementObjects = {}
			end
			table.insert(ReinforcementObjects, hero)
		end
	end
	
	Setup_Reinforcement_Panes()
end


-- ---------------------------------------------------------------------------------------------
-- Setup_Reinforcement_Panes
-- ---------------------------------------------------------------------------------------------
function Setup_Reinforcement_Panes()
	if not Conditional_Show() then
		this.Set_Hidden(true)
		return
	end
	
	local pane_index = 1
	for _, object in pairs(ReinforcementObjects) do
		if TestValid(object) then
			if object.Has_Behavior(160) then
				ReinforcementPanes[pane_index].Set_Object(object.Get_Ghosted_Object())
				ReinforcementPanes[pane_index].Set_Hidden(false)
				pane_index = pane_index + 1
			elseif TestValid(Enabler) and TestValid(object.Get_Command_Center()) then
				ReinforcementPanes[pane_index].Set_Object(object)
				ReinforcementPanes[pane_index].Set_Enabler(Enabler)
				ReinforcementPanes[pane_index].Set_Hidden(false)
				pane_index = pane_index + 1
			end
		end
	end	
	
	for i = pane_index, #ReinforcementPanes do
		ReinforcementPanes[i].Set_Object(nil)
		ReinforcementPanes[i].Set_Hidden(true)
	end
end


-- ---------------------------------------------------------------------------------------------
-- On_Reinforcement_Object_Destroyed
-- ---------------------------------------------------------------------------------------------
function On_Reinforcement_Object_Destroyed(object)
	for i, reinforcement_object in pairs(ReinforcementObjects) do
		if reinforcement_object == object then
			table.remove(ReinforcementObjects, i)
			break
		end
	end
	
	Setup_Reinforcement_Panes()
end


-- ---------------------------------------------------------------------------------------------
-- Is_Open
-- ---------------------------------------------------------------------------------------------
function Is_Open()
	return this.Get_Current_State_Name() == "Open"
end

-- ---------------------------------------------------------------------------------------------
-- Close
-- ---------------------------------------------------------------------------------------------
function Close()
	this.Set_State("Closed")
end

-- ---------------------------------------------------------------------------------------------
-- On_Enablers_List_Updated
-- ---------------------------------------------------------------------------------------------
function On_Enablers_List_Updated(_, _, enablers)
	for _, enabler in pairs(enablers) do
		if enabler.Get_Type().Enables_Reinforcements() then
			if Enabler ~= enabler then
				Enabler = enabler
				Setup_Reinforcement_Panes()
			end
			return
		end
	end
	
	Enabler = nil
	Setup_Reinforcement_Panes()
end


-- ---------------------------------------------------------------------------------------------
-- Is_Scenario_Campaign
-- ---------------------------------------------------------------------------------------------
function Is_Scenario_Campaign()
	local global_script = Get_Game_Mode_Script("Strategic")
	if TestValid(global_script) then
		return global_script.Get_Async_Data("IsScenarioCampaign")
	else
		return false
	end
end

-- ---------------------------------------------------------------------------------------------
-- Conditional_Show
-- ---------------------------------------------------------------------------------------------
function Conditional_Show()
	if Is_Scenario_Campaign() and ReinforcementObjects then
		for _, reinforcement_object in pairs(ReinforcementObjects) do
			if reinforcement_object.Has_Behavior(160) or Enabler then
				return true		
			end
		end
	end
	
	return false
end


-- ---------------------------------------------------------------------------------------------
-- INTERFACE
-- ---------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Open = Is_Open
Interface.Close = Close
Interface.Conditional_Show = Conditional_Show
Interface.Toggle_Menu_Display = Toggle_Menu_Display
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
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
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
