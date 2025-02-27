if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Alien_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Nader_Akoury $
--
--            $Change: 97073 $
--
--          $DateTime: 2008/04/16 17:05:08 $
--
--          $Revision: #17 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Gamepad_Tactical_Command_Bar_Common")

-- Manage the list of walkers to start hard point customization mode
require("Gamepad_Alien_Walkers_Menu_Manager")

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
	
	Init_Walkers_Menu()
	
	-- We need to know when we are in customization mode so that we bring up the darkening curtain.
	Scene.Register_Event_Handler("Start_Walker_Customization_Mode", nil, On_Start_Walker_Customization_Mode)
	Scene.Register_Event_Handler("End_Walker_Customization_Mode", nil, On_End_Walker_Customization_Mode)	
	Scene.Register_Event_Handler("HP_Selection_Changed", nil, On_Start_Customizing_Hardpoint)	
	Scene.Register_Event_Handler("Start_HP_Sub_Selection_Mode", nil, On_Start_HP_Sub_Selection_Mode)	
	
	
	WalkerConfigurationData = nil
	

	-- JLH 01.04.2007
	-- Population of the achievement buff window (only available in multiplayer).
	Scene.Register_Event_Handler("Set_Achievement_Buff_Display_Model", nil, On_Set_Achievement_Buff_Display_Model)

	Init_Tab_Orders()

	Init_Tactical_Command_Bar_Common(Scene, Player)
	
	--Set the correct sell button texture
	if TestValid(SellButton) then
		SellButton.Set_Texture("i_icon_sell_alien.tga")
	end
	
	CanActivateHPSubSelection = false	
	InHPSubSelectionMode = false
	
	-- This needs to mimic the values defined in GameControllerTacticalModeInputHandler.
	Scene.Register_Event_Handler("Set_HP_Sub_Selection_Category", nil, On_Set_HP_Sub_Selection_Category)
	INVALID_HARD_POINT = Declare_Enum(-1)
	BODY_HARD_POINT = Declare_Enum()
	LEG_HARD_POINT = Declare_Enum()
	CategoryToContextIDMap = {}
	CategoryToContextIDMap[INVALID_HARD_POINT] = GAMEPAD_CUSTOMIZE_WALKER
	CategoryToContextIDMap[BODY_HARD_POINT] = GAMEPAD_CUSTOMIZE_WALKER_UP
	CategoryToContextIDMap[LEG_HARD_POINT] = GAMEPAD_CUSTOMIZE_WALKER_DOWN
	
	HPSubSelectCategory = INVALID_HARD_POINT
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Set_HP_Sub_Selection_Category
-- ------------------------------------------------------------------------------------------------------------------
function On_Set_HP_Sub_Selection_Category(_, _, category)
	-- remove whatever the display for the last category was
	GamepadCurrentContexts[GamepadContextToDisplayData[CategoryToContextIDMap[HPSubSelectCategory]].Trigger] = nil
	
	-- Update the data with the new category
	HPSubSelectCategory = category
	
	-- Refresh the context display.
	Update_HP_Sub_Selection_Context_Display(true) -- true = force update.
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_HP_Sub_Selection_Context_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_HP_Sub_Selection_Context_Display(force_update)
	local could_activate = CanActivateHPSubSelection
	CanActivateHPSubSelection = Controller_Get_Can_Activate_HP_Sub_Selection_Mode()
	-- Walkers cannot be multiply selected so that narrows our cases!.
	if not force_update and could_activate == CanActivateHPSubSelection then
		-- nothing has changed, so get out.
		return
	end
	
	-- Maria 11.26.2007: Now that we have updated the proper values, we need not proceed if we are not displaying the context data.
	if ShowContextDisplay then 
		if HPSubSelectCategory == INVALID_HARD_POINT and CanActivateHPSubSelection then
			GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER].Trigger] = GAMEPAD_CUSTOMIZE_WALKER
		elseif HPSubSelectCategory == BODY_HARD_POINT then
			GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER_UP].Trigger] = GAMEPAD_CUSTOMIZE_WALKER_UP
		elseif HPSubSelectCategory == LEG_HARD_POINT then
			GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER_DOWN].Trigger] = GAMEPAD_CUSTOMIZE_WALKER_DOWN
		else
			-- Force a total update of the context display.
			-- First remove the data from the list.
			GamepadCurrentContexts[GamepadContextToDisplayData[GAMEPAD_CUSTOMIZE_WALKER].Trigger] = nil			
		end	

		this.GamepadContextDisplay.Update_Context_Display(GamepadCurrentContexts)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Start_HP_Sub_Selection_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_Start_HP_Sub_Selection_Mode(_, _, walker_object)
	InHPSubSelectionMode = true
	ParentObjectForHardPointSubSelection = walker_object
	Controller_Update_Context()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Controller_Display_Faction_Specific_Command_Bar
-- ------------------------------------------------------------------------------------------------------------------
function Controller_Display_Faction_Specific_Command_Bar(on_off)
	--BlueprintsListButton.Set_Hidden(not on_off)
	Update_Blueprint_Menu()
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
	QueueManager.Set_Walker_Customization_Mode_On(true)		
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_End_Walker_Customization_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_End_Walker_Customization_Mode(event, source)
	if CustomizationModeOn == false then
		return
	end
	
	CustomizationModeOn = false
	WalkerConfigurationData = nil
	QueueManager.Set_Walker_Customization_Mode_On(false)	
	
	-- This should automatically end the HP sub seleciton mode (if active)
	InHPSubSelectionMode = false
	ParentObjectForHardPointSubSelection = nil
	HPSubSelectCategory = INVALID_HARD_POINT
	
	-- Make sure all variables associated to this mode are reset!.
	Controller_Set_HP_Configuration_Menu_Active(false)
	
	-- Update the state of the UI (especially of the HP reticles now that the customization mode is off)
	Selection_Changed({})
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Start_Customizing_Hardpoint
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Start_Customizing_Hardpoint(event, source, hard_point, parent)
	if CommandBarEnabled == false then return end
	if not TestValid(hard_point) then 
		WalkerConfigurationData = {}
		CustomizationModeOn = false
	else
		WalkerConfigurationData = {}
		WalkerConfigurationData.Object = hard_point
		WalkerConfigurationData.Parent = parent
		CustomizationModeOn = true
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

end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()

	local close_huds, credits_changed = Update_Common_Scene()
	
	Update_Blueprint_Menu()
	
	-- Are there any huds open!?
	CloseHuds = close_huds 
			  or this.Research_Tree.Is_Open()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Tree_Open
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Tree_Open()
	if CustomizationModeOn == true then 
		Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Blueprint_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Update_Blueprint_Menu()

	local local_player = Find_Player("local")
	if not Is_Player_Of_Faction(local_player, "Alien") then
		Hide_Walker_Menu()	
		return
	end
	
	Update_Walkers_Menu()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays()
	Raise_Event_Immediate_All_Scenes("End_Walker_Customization_Mode", nil)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Faction_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Faction_GUI_For_Replay()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Faction_Has_Queue_Type -- Does this faction have the specific build queue type
-- ------------------------------------------------------------------------------------------------------------------
function Faction_Has_Queue_Type(queue_type)
	if queue_type == 'Air' then
		return false
	end
	return true
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	Commit_Profile_Values = nil
	Controller_Display_Faction_Specific_Command_Bar = nil
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
	Gamepad_Point_Camera_At_Next_Builder = nil
	Get_Button_Index_For_Unit_Type = nil
	Get_Chat_Color_Index = nil
	Get_GUI_Variable = nil
	Get_HP_Being_Configured = nil
	Get_Last_Tactical_Parent = nil
	Get_Selected_Unit_Type_For_Button_Index = nil
	Hot_Key_Activate_Unit_Ability = nil
	Init_Control_Group_Textures_Prefix_Map = nil
	Is_Customization_Mode_On = nil
	Is_First_Button = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Build_Button_Focus_Gained = nil
	On_Handle_BattleCam_Button_Up = nil
	On_Mouse_Off_Hero_Button = nil
	On_Mouse_Over_Hero_Button = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGColors_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Post_Load_Game = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Retry_Current_Mission = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Walker_For_Customization = nil
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
	Update_Mouse_Buttons = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
