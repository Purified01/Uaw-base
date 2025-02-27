if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[187] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Alien_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 93153 $
--
--          $DateTime: 2008/02/12 11:04:35 $
--
--          $Revision: #23 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Tactical_Command_Bar_Common")


MODE_INVALID = -1
MODE_CONSTRUCTION = 1 -- can make buildings
MODE_SELECTION = 2    -- can control units
Mode = MODE_CONSTRUCTION


-- ---------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Player = Find_Player("local")
	
	if Player == nil then 
		MessageBox("the player is nil")
	else
		Scene.FactionText.Set_Text(Player.Get_Faction_Display_Name())
	end
	
	CloseHuds = false
		
	-- Maria 06.19.2006 - button to display the list of walker blueprints
	BlueprintsListButton = Scene.BlueprintsListButton
	BlueprintsListButton.Set_Hidden(true)
	BlueprintsListButton.Set_Texture("i_icon_a_blueprint.tga")
	local key_map_txt = Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE", 1)
	if key_map_txt == nil then 
		key_map_txt = false
	end
	
	BlueprintsListButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_BLUEPRINTS_LIST", key_map_txt, "TEXT_UI_TACTICAL_BLUEPRINTS_LIST_DESCRIPTION"}})	
	
	Scene.Register_Event_Handler("Selectable_Icon_Clicked", BlueprintsListButton, On_Blueprints_List_Button_Clicked)
	BlueprintMenuManager = Scene.AlienBlueprintMenuManager
	BlueprintMenuManager.Init_Blueprints_Menu()
	BlueprintMenuManager.Set_Hidden(true)
	BlueprintMenuManager.Set_Tab_Order(0)
	
	-- Maria 07.07.2006
	-- Start flashing the blueprints list button, research has been completed so there may be new build options available!
	Scene.Register_Event_Handler("UI_Start_Flash_Blueprint_Button", nil, UI_Start_Flash_Blueprint_Button)
	
	-- We need to know when we are in customization mode so that we bring up the darkening curtain.
	Scene.Register_Event_Handler("Start_Walker_Customization_Mode", nil, On_Start_Walker_Customization_Mode)
	Scene.Register_Event_Handler("End_Walker_Customization_Mode", nil, On_End_Walker_Customization_Mode)	
	Scene.Register_Event_Handler("HP_Selection_Changed", nil, On_Start_Customizing_Hardpoint)	
	WalkerConfigurationData = nil
	
	-- JLH 01.04.2007
	-- Population of the achievement buff window (only available in multiplayer).
	Scene.Register_Event_Handler("Set_Achievement_Buff_Display_Model", nil, On_Set_Achievement_Buff_Display_Model)

	Init_Tab_Orders()

	Init_Tactical_Command_Bar_Common(Scene, Player)
	
	FactionSpecificMenuButton = BlueprintsListButton
	FactionSpecificMenuButton.Set_Tab_Order(TAB_ORDER_FACTION_SPECIFIC_BUTTON)
	
	-- Update the scene now!
	On_Update()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Specific_Tooltip_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Specific_Tooltip_Data()
	local key_map_txt = Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE", 1)
	if key_map_txt == nil then 
		key_map_txt = false
	end
	
	BlueprintsListButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_BLUEPRINTS_LIST", key_map_txt, "TEXT_UI_TACTICAL_BLUEPRINTS_LIST_DESCRIPTION"}})	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Specific_UI(on_off)
	BlueprintMenuManager.Set_Hidden(not on_off)
	
	if on_off and BlueprintMenuManager.Is_List_Open() then
		BlueprintMenuManager.Refresh_Focus()
		return false
	end
	return true
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Customization_Mode_On
-- ------------------------------------------------------------------------------------------------------------------
function Is_Customization_Mode_On()
	return CustomizationModeOn
end


-- ------------------------------------------------------------------------------------------------------------------
-- Get_HP_Being_Configured
-- ------------------------------------------------------------------------------------------------------------------
function Get_HP_Being_Configured()
	if WalkerConfigurationData then 
		return WalkerConfigurationData.Object
	end
	return nil
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Start_Walker_Customization_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_Start_Walker_Customization_Mode(event, source, walker)
	if CommandBarEnabled == false then return end
	CustomizationModeOn = true
	WalkerConfigurationData = {}
	WalkerConfigurationData.Parent = walker
	-- The queue manager may be open so we close it down!
	QueueManager.Close()	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_End_Walker_Customization_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_End_Walker_Customization_Mode(event, source)
	CustomizationModeOn = false
	WalkerConfigurationData = nil
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Start_Customizing_Hardpoint
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Start_Customizing_Hardpoint(event, source, hard_point, parent)
	if CommandBarEnabled == false then return end
	if not hard_point and WalkerConfigurationData then 
		WalkerConfigurationData.Object = nil
	else
		WalkerConfigurationData = {}
		WalkerConfigurationData.Object = hard_point
		WalkerConfigurationData.Parent = parent
		CustomizationModeOn = true
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Blueprints_List_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Blueprints_List_Button_Clicked(event, source)	
	if CommandBarEnabled == false then return end
	
	End_Sell_Mode()
	
	if source.Get_Hidden() == true or source.Is_Button_Enabled() == false then 
		return
	end
	
	Update_Walker_Customization_Mode(false)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Walker_Customization_Mode
-- ------------------------------------------------------------------------------------------------------------------
function Update_Walker_Customization_Mode(force_open)

	-- force_open = true -> if it is open do not close it.
	if BlueprintsListButton.Is_Flashing() == true then
		BlueprintsListButton.Stop_Flash()
	end
	
	if BlueprintMenuManager.Get_Hidden() == true then
		BlueprintMenuManager.Set_Hidden(false)
	end
	
	local active = force_open
	if force_open or BlueprintMenuManager.Is_List_Open() == false then
		-- The queue manager may be open so we close it down!
		QueueManager.Close()
		
		-- Close down the tree if opened!
		Hide_Research_Tree()
		
		if not force_open then
			active = BlueprintMenuManager.Display_Walker_List()
		end	
		
	elseif not force_open then
		BlueprintMenuManager.Hide_Menu()
	end
	
	if active then 
		-- We are now in HP customization mode so let's announce that to all pertinent scenes
		Raise_Event_Immediate_All_Scenes("Start_Walker_Customization_Mode", nil)
		CustomizationModeOn = true
	elseif not force_open then
		-- Reset HP customization mode
		Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)
	end
	
	BuildModeOn = active
	if Mode == MODE_CONSTRUCTION and CurrentSelectionNumTypes == 1 and #CurrentConstructorsList > 0 then 
		-- if there's only constructor(s) selected, we want to be able to go back to its build menu is no other selection order is issued.
		-- If more than one constructor and we go back with no new selection, then we will go back to the ability buttons.
		Setup_Mode_Construction()	
	else -- if there's more than one constructor or no constructor selected, then just update the selection mode dislpay.
		Mode = MODE_SELECTION
		Setup_Mode_Selection()
	end
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Hide_Faction_Specific_Buttons
-- ------------------------------------------------------------------------------------------------------------------------------------
function Hide_Faction_Specific_Buttons(event, soruce)
	-- close any specific components that are open.
end


-- ------------------------------------------------------------------------------------------------------------------
-- Process_Build_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function Process_Build_Queue_Button_Clicked()
	if BlueprintMenuManager.Is_List_Open() == true then
		-- close the list!
		BlueprintMenuManager.Hide_Menu()	
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Specific_UI()
	
	if CustomizationModeOn == true or BlueprintMenuManager.Is_Scene_Hidden() == false or BlueprintMenuManager.Is_List_Open() == true then
		BlueprintMenuManager.Hide_Menu(CustomizationModeOn)	
	end	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()

	local close_huds, credits_changed = Update_Common_Scene()
	
	Update_Blueprint_Menu()
	
	-- Are there any huds open!?
	CloseHuds = close_huds 
			  or BlueprintMenuManager.Is_List_Open() 
			  or (not BlueprintMenuManager.Is_Scene_Hidden()) 
			  or this.Research_Tree.Is_Open()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Tree_Open
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Tree_Open()

	BlueprintMenuManager.Hide_Menu(true)
	if CustomizationModeOn == true then 
		Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Blueprint_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Update_Blueprint_Menu()

	local local_player = Find_Player("local")
	if Is_Player_Of_Faction(local_player, "Proto") == false then
		BlueprintsListButton.Set_Hidden(true)
		
		if BlueprintMenuManager.Is_List_Open() == true then
			BlueprintMenuManager.Hide_Menu()	
		end		
		return
	end
	
	if BlueprintMenuManager ~= nil and BlueprintMenuManager.Is_Initialized() == true then
		local update = BlueprintMenuManager.Update()
		if update == true then  -- ie. no enablers!
			BlueprintsListButton.Set_Hidden(true)
		else
			if not IsLetterboxMode then
				BlueprintsListButton.Set_Hidden(false)
			else
				BlueprintsListButton.Set_Hidden(true)
			end
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Maria 
-- UI_Start_Flash_Blueprint_Button
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Blueprint_Button(event, source)

	if BlueprintMenuManager.Is_List_Open() == false and BlueprintsListButton.Get_Hidden() == false then
		BlueprintsListButton.Start_Flash()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays()

	if BlueprintMenuManager.Is_List_Open() == true or BlueprintMenuManager.Is_Scene_Hidden() == false then
		BlueprintMenuManager.Hide_Menu()
	end
	
	Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)	
end



-- ------------------------------------------------------------------------------------------------------------------
-- Maria 08.09.2006
-- Hide_All_Faction_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Faction_Specific_UI(onoff)

	if onoff == true then -- i.e., hide
		-- Close all the huds first and then hide them!
		if BlueprintMenuManager.Is_List_Open() == true or BlueprintMenuManager.Is_Scene_Hidden() == false then
			BlueprintMenuManager.Hide_Menu()
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Faction_Specific_Menu_Open
-- ------------------------------------------------------------------------------------------------------------------
function Is_Faction_Specific_Menu_Open()
	if not TestValid(BlueprintMenuManager) then return false end
	return BlueprintMenuManager.Is_List_Open()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Faction_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Faction_GUI_For_Replay()
	if AlienBlueprintMenuManager then
		AlienBlueprintMenuManager.Enable(false)
	end
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Activate_Superweapon_By_Index = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	Commit_Profile_Values = nil
	Controller_Display_Specific_UI = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Define_Retry_State = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Hero_Button = nil
	GUI_Cancel_Talking_Head = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Pool_Free = nil
	Get_Button_Index_For_Unit_Type = nil
	Get_Chat_Color_Index = nil
	Get_GUI_Variable = nil
	Get_HP_Being_Configured = nil
	Get_Last_Tactical_Parent = nil
	Get_Selected_Unit_Type_For_Button_Index = nil
	Is_Customization_Mode_On = nil
	Max = nil
	Min = nil
	Mission_Text_User_Event = nil
	Notify_Attached_Hint_Created = nil
	On_Mouse_Off_Hero_Button = nil
	On_Mouse_Over_Hero_Button = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGColors_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Post_Load_Game = nil
	Process_Tactical_Mission_Over = nil
	Radar_Map_Hide_Terrain = nil
	Radar_Map_Show_Terrain = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Show_Retry_Dialog = nil
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
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
