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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Masari_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 93510 $
--
--          $DateTime: 2008/02/16 10:09:35 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Gamepad_Tactical_Command_Bar_Common")


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
	
	-- JLH 01.04.2007
	-- Population of the achievement buff window (only available in multiplayer).
	Scene.Register_Event_Handler("Set_Achievement_Buff_Display_Model", nil, On_Set_Achievement_Buff_Display_Model)

	Init_Tab_Orders()

	EM_Button = this.FactionButtons.Carousel.ElementalModeButton
	EM_Button.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_MASARI_ELEMENTAL_MODE_BUTTON", false, "TEXT_UI_TACTICAL_MASARI_ELEMENTAL_MODE_BUTTON_DESCRIPTION"}})	
	EM_Button.Set_Hidden(false)	
	this.Register_Event_Handler("Selectable_Icon_Clicked", EM_Button, On_Elemental_Button_Clicked)
	
	-- the clock should be green
	Red = {1.0, 0.0, 0.0, 110.0/255.0}
	Green = {0.0, 1.0, 0.0, 110.0/255.0}
	CurrentTint = nil

	Init_Tactical_Command_Bar_Common(Scene, Player)

		--Set the correct sell button texture
	if TestValid(SellButton) then
		SellButton.Set_Texture("i_icon_sell_masari.tga")
	end
		
	this.CommandBar.BuildButtons.Set_Tab_Order(TAB_ORDER_BUILDING_BUTTONS)
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Process_Build_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------------------------
function Process_Build_Queue_Button_Clicked()
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Hide_Faction_Specific_Buttons
-- ------------------------------------------------------------------------------------------------------------------------------------
function Hide_Faction_Specific_Buttons()
	-- close any specific components that are open.
end


-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Faction_Specific_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Faction_Specific_Menu()
	if CommandBarEnabled == false then return end
	End_Sell_Mode()
	
	local player = Find_Player( "local" )
	if player == nil then return end
	
	-- this is equivalent to clicking on the EM_Button!
	if not TestValid(EM_Button) or not EM_Button.Is_Button_Enabled() or EM_Button.Get_Hidden() then return end
	
	Send_GUI_Network_Event("Networked_Mode_Switch", { player, EM_Button.Get_User_Data() })	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()

	-- Are there any huds open!?
	local close_huds, credits_changed = Update_Common_Scene()
	CloseHuds = close_huds or this.Research_Tree.Is_Open()
	
	Update_Elemental_Mode_Button()	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays(event, source)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Elemental_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Elemental_Button_Clicked( event, source )
	local player = Find_Player( "local" )
	
	if player == nil then
		return
	end
	
	End_Sell_Mode()

	Send_GUI_Network_Event("Networked_Mode_Switch", { player, source.Get_User_Data() })
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Elemental_Mode_Button
-- ------------------------------------------------------------------------------------------------------------------
function Update_Elemental_Mode_Button()

	if LocalPlayer == nil then
		EM_Button.Set_Hidden(true)
	end
	
	if Is_Player_Of_Faction(LocalPlayer, "MASARI") == true  then
		
		if not IsLetterboxMode and ControllerDisplayingResearchAndFactionUI then
			EM_Button.Set_Hidden(false) 
		end
		
		local curr_mode = EM_Button.Get_User_Data()
		
		local is_in_fire = StringCompare( LocalPlayer.Get_Elemental_Mode(), "Fire" )
		local is_in_ice = StringCompare( LocalPlayer.Get_Elemental_Mode(), "Ice" )
		
		if is_in_fire then
			EM_Button.Set_Texture( "i_icon_masari_elemental_mode_fire.tga" )
			
			-- Clicking on the button will change modes, so if it is fire now, clicking on the button should set it to Ice
			if curr_mode ~= "Ice" then 
				EM_Button.Set_User_Data("Ice")
			end
			
		elseif is_in_ice then
			EM_Button.Set_Texture( "i_icon_masari_elemental_mode_ice.tga" )
			
			-- Clicking on the button will change modes, so if it is ice now, clicking on the button should set it to Fire
			if curr_mode ~= "Fire" then 
				EM_Button.Set_User_Data("Fire")
			end
		else
			EM_Button.Set_Texture( "i_icon_medic.tga" )
			EM_Button.Set_User_Data("")
		end
		
		local transition_percent = LocalPlayer.Get_Elemental_Mode_Transition_Percent()
		if transition_percent == 1.0 then
			-- if the transition is over, we may need to display the cooldown time!.
			local cooldown_percent = LocalPlayer.Get_Elemental_Mode_Cooldown_Percent()
			if cooldown_percent == 1.0 then 
				EM_Button.Set_Clock_Filled( 0.0 )
			else
				-- set the clock fill to whatever percent the cooldown is up to!.	
				Set_Clock_Format(Red, true)
				EM_Button.Set_Clock_Filled( 1.0 - cooldown_percent )				
			end
			
		else
			Set_Clock_Format(Green, false)
			EM_Button.Set_Clock_Filled( 1.0 - transition_percent )
		end
			
	else
		EM_Button.Set_Hidden(true) 	
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Clock_Format
-- ------------------------------------------------------------------------------------------------------------------
function Set_Clock_Format(color_table, clockwise)
	-- Make sure the clock is green!.
	if CurrentTint ~= color_table then 
		CurrentTint = color_table
		-- Update the clock tint!.
		EM_Button.Set_Clock_Tint(CurrentTint)	
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Faction_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Faction_GUI_For_Replay()
	EM_Button.Enable(false)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Faction_Has_Queue_Type -- Does this faction have the specific build queue type
-- ------------------------------------------------------------------------------------------------------------------
function Faction_Has_Queue_Type(queue_type)
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
	Get_Last_Tactical_Parent = nil
	Get_Selected_Unit_Type_For_Button_Index = nil
	Hot_Key_Activate_Unit_Ability = nil
	Init_Control_Group_Textures_Prefix_Map = nil
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
	Toggle_Faction_Specific_Menu = nil
	Update_Mouse_Buttons = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
