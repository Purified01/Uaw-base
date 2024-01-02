-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Reinforcement_Manager.lua#13 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Reinforcement_Manager.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 85634 $
--
--          $DateTime: 2007/10/06 12:50:31 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

function On_Init()
	if not Is_Scenario_Campaign() then
		this.Set_State("Closed")
		this.ToggleButton.Set_Hidden(true)
		this.Set_Hidden(true)
		return
	end

	ReinforcementPanes = Find_GUI_Components(this.PanesGroup, "Pane")
	LocalPlayer = Find_Player("local")
	
	this.Register_Event_Handler("Update_Enablers_List", nil, On_Enablers_List_Updated)
	Init_Reinforcement_Objects()
	
	this.Register_Event_Handler("Selectable_Icon_Clicked", this.ToggleButton, On_Toggle_Button_Clicked)
	this.Register_Event_Handler("Close_All_Active_Displays", this, Close)
	this.Register_Event_Handler("Mouse_Non_Client_Left_Up", this, Close)
	this.Register_Event_Handler("Component_Hidden", nil, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden", nil, Enable_UI_Element_Event)	
	
	this.ToggleButton.Set_Texture("i_icon_reinforcements.tga")
	this.ToggleButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_REINFORCEMENTS_MENU", false, "TEXT_UI_TACTICAL_REINFORCEMENTS_MENU_DESCRIPTION"}})	
end

function On_Toggle_Button_Clicked()
	if this.Get_Current_State_Name() == "Open" then
		this.Set_State("Closed")
	else
		this.Set_State("Open")
	end
end

function Update_Open()
	for i, pane in pairs(ReinforcementPanes) do
		pane.Update()
	end
end

function Init_Reinforcement_Objects()
	ReinforcementObjects = Get_Conflict_Location().Get_Neighboring_Regions_Owned_By_Player(LocalPlayer)
	local hero_reinforcement_objects = Find_Objects_With_Behavior(BEHAVIOR_GHOST, LocalPlayer)
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

function Setup_Reinforcement_Panes()
	if not Conditional_Show() then
		this.ToggleButton.Set_Hidden(true)
		this.Set_Hidden(true)
		return
	end
	
	this.ToggleButton.Set_Hidden(false)

	local pane_index = 1
	for _, object in pairs(ReinforcementObjects) do
		if TestValid(object) then
			if object.Has_Behavior(BEHAVIOR_GHOST) then
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

function On_Reinforcement_Object_Destroyed(object)
	for i, reinforcement_object in pairs(ReinforcementObjects) do
		if reinforcement_object == object then
			table.remove(ReinforcementObjects, i)
			break
		end
	end
	
	Setup_Reinforcement_Panes()
end

function Is_Open()
	return this.Get_Current_State_Name() == "Open"
end

function Close()
	this.Set_State("Closed")
end

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

function Is_Scenario_Campaign()
	local global_script = Get_Game_Mode_Script("Strategic")
	if TestValid(global_script) then
		return global_script.Get_Async_Data("IsScenarioCampaign")
	else
		return false
	end
end

function Conditional_Show()
	if Is_Scenario_Campaign() and ReinforcementObjects then
		for _, reinforcement_object in pairs(ReinforcementObjects) do
			if reinforcement_object.Has_Behavior(BEHAVIOR_GHOST) or Enabler then
				this.ToggleButton.Set_Hidden(false)
				return true		
			end
		end
	end
	
	return false
end

Interface = {}
Interface.Is_Open = Is_Open
Interface.Close = Close
Interface.Conditional_Show = Conditional_Show