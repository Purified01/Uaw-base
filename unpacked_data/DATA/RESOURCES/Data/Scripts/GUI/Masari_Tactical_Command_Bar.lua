-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Masari_Tactical_Command_Bar.lua#35 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Masari_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Maria_Teruel $
--
--            $Change: 84782 $
--
--          $DateTime: 2007/09/25 14:27:28 $
--
--          $Revision: #35 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Tactical_Command_Bar_Common")


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
	
	Init_Tab_Orders()
	
	-- JLH 01.04.2007
	-- Population of the achievement buff window (only available in multiplayer).
	Scene.Register_Event_Handler("Set_Achievement_Buff_Display_Model", nil, On_Set_Achievement_Buff_Display_Model)

	ElementalMode = this.ElementalMode
	EM_Button = ElementalMode.Button
	local key_map_txt = Get_Game_Command_Mapped_Key_Text("COMMAND_ACTIVATE_FACTION_SPECIFIC_QUEUE", 1)
	if key_map_txt == nil then 
		key_map_txt = false
	end
	EM_Button.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_MASARI_ELEMENTAL_MODE_BUTTON", key_map_txt, "TEXT_UI_TACTICAL_MASARI_ELEMENTAL_MODE_BUTTON_DESCRIPTION"}})	
	
	EM_Button.Set_Tab_Order(TAB_ORDER_FACTION_SPECIFIC_BUTTON)
	-- the clock should be green
	Red = {1.0, 0.0, 0.0, 110.0/255.0}
	Green = {0.0, 1.0, 0.0, 110.0/255.0}
	CurrentTint = nil
	EM_Overlay = ElementalMode.ButtonOverlay
	ElementalMode.Set_Hidden(false)	
	
	Init_Tactical_Command_Bar_Common(Scene, Player)
	
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
	
	EM_Button.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_MASARI_ELEMENTAL_MODE_BUTTON", key_map_txt, "TEXT_UI_TACTICAL_MASARI_ELEMENTAL_MODE_BUTTON_DESCRIPTION"}})	
end


-- ------------------------------------------------------------------------------------------------------------------------------------
-- Process_Build_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------------------------
function Process_Build_Queue_Button_Clicked()
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------------------------
function Update_Faction_Specific_UI()
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
	if not TestValid(EM_Button) or not EM_Button.Is_Enabled() or EM_Button.Get_Hidden() then return end
	
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
-- Maria 08.09.2006
-- Hide_All_Faction_Specific_UI -- Attached to HOT KEY VK_W
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Faction_Specific_UI(onoff)
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
		ElementalMode.Set_Hidden(true) 
	end
	
	if Is_Player_Of_Faction(LocalPlayer, "MASARI") == true  then
		
		if IsLetterboxMode  then
			ElementalMode.Set_Hidden(true) 
		else
			ElementalMode.Set_Hidden(false) 
		end
		
		local curr_mode = EM_Button.Get_User_Data()
		
		local is_in_fire = StringCompare( LocalPlayer.Get_Elemental_Mode(), "Fire" )
		local is_in_ice = StringCompare( LocalPlayer.Get_Elemental_Mode(), "Ice" )
		
		if is_in_fire then
			EM_Button.Set_Texture( "i_icon_masari_elemental_mode_fire.tga" )
			EM_Overlay.Set_Texture("Masari_dark_overlay.tga")
			
			-- Clicking on the button will change modes, so if it is fire now, clicking on the button should set it to Ice
			if curr_mode ~= "Ice" then 
				EM_Button.Set_User_Data("Ice")
			end
			
		elseif is_in_ice then
			EM_Button.Set_Texture( "i_icon_masari_elemental_mode_ice.tga" )
			EM_Overlay.Set_Texture("Masari_light_overlay.tga")
			
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
		ElementalMode.Set_Hidden(true) 	
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
		-- Update the direction of the clock sweep
		EM_Button.Set_Clockwise( clockwise )
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Faction_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Faction_GUI_For_Replay()
	this.ElementalMode.Enable(false)
end