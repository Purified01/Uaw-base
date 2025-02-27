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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Novus_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 93510 $
--
--          $DateTime: 2008/02/16 10:09:35 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Gamepad_Tactical_Command_Bar_Common")



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
	UpdatingSelection = false
	
	-- JLH 01.04.2007
	-- Population of the achievement buff window (only available in multiplayer).
	Scene.Register_Event_Handler("Set_Achievement_Buff_Display_Model", nil, On_Set_Achievement_Buff_Display_Model)

	--We need tab orders before we set up the patch menu
	Init_Tab_Orders()

	if TestValid(this.FactionButtons) then 
		if TestValid(this.FactionButtons.Carousel) then 
			if TestValid(this.FactionButtons.Carousel.PatchButton) then 
				PatchButton = this.FactionButtons.Carousel.PatchButton
				PatchButton.Set_Texture("i_icon_n_patch_purchase.tga")
				this.Register_Event_Handler("Selectable_Icon_Clicked", PatchButton, Toggle_Patches_Menu_Display)
				PatchButton.Set_Tooltip_Data({'ui', {"TEXT_UI_TACTICAL_NOVUS_PATCH_MENU", false, "TEXT_UI_TACTICAL_NOVUS_PATCH_MENU_DESCRIPTION"}})
			end
		end	
	end
	FlashPatchButton = false
	
	this.Register_Event_Handler("Update_Patch_Queue_Size", nil, On_Update_Patch_Queue_Size)
	this.Register_Event_Handler("On_Patch_Queueing_Complete", nil, On_Patch_Queueing_Complete)
	
	PatchMenu = this.NovusPatchMenu
	PatchMenu.Init_Patches_Menu()
	PatchMenu.Set_Tab_Order(TAB_ORDER_FACTION_SPECIFIC_BUTTON)
	
	-- The Patch Queue Manager takes care of updating the Patch Queue properly, also, it is the interface to the patches menu!.
	-- Do this before the common Init since that can call into the patch menu.
	--Init_Patch_Queue_Manager()	

	Init_Patches_Progress_Display()
	
	Init_Tactical_Command_Bar_Common(Scene, Player)
	
	-- We may be loading a game so let's ee if there are slots enabled already!
	local player = Find_Player("local")
 	if player then 
		local script = player.Get_Script()
 		if script then 
 			Update_Queue_Size(script.Get_Async_Data("AvaialableQueueSlots"))
 		end
	end
	
		--Set the correct sell button texture
	if TestValid(SellButton) then			
		SellButton.Set_Texture("i_icon_n_sell.tga")
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Patches_Progress_Display
-- ------------------------------------------------------------------------------------------------------------------
function Init_Patches_Progress_Display()
	if not TestValid(this.PatchesProgressDisplay) then 
		return
	end
	
	PPDisplay = this.PatchesProgressDisplay
	
	PPDScenes = Find_GUI_Components(PPDisplay, "Patch")
	
	for _, scene in pairs(PPDScenes) do
		scene.Clock.Set_Tint(0.0, 1.0, 0.0, 150.0/255.0)
		scene.Set_Hidden(true)
	end
	
	-- hide the display, this will get updated from the patch menu manager.
	PPDisplay.Set_Hidden(true)
	
	PATCH_STATE_ACTIVE = Declare_Enum(0)
	PATCH_STATE_INACTIVE = Declare_Enum()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Patches_Progress_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Patches_Progress_Display()
	local player = Find_Player("local")
	if not player then return end
	
	local script = player.Get_Script()
	if not script then return end
	
	-- Update the state of the queue based on the current size and active patches!.
	local active_patches_data = script.Get_Async_Data("CachedActivePatchesData")
	
	local scene_index = 1
	for i = 1, #active_patches_data do 	
		local data = active_patches_data[i]
		
		-- active_patches_data[1] = type
		-- active_patches_data[2] = is the patch object valid? (it may have expired)
		-- active_patches_data[3] = if a valid object and it has duration, what's its time left?	
		local p_type = data[1]
		
		if p_type then
			local display = PPDScenes[scene_index]
			display.Set_Hidden(false)
			
			local texture_name = p_type.Get_Icon_Name()
			display.PatchQuad.Set_Texture(texture_name)
			
			local patch_active_state = PATCH_STATE_ACTIVE
			local is_object_valid = data[2]
			if is_object_valid == true and data[3] >= 0 then 
				display.Clock.Set_Filled(data[3])
			elseif is_object_valid == false then
				display.Clock.Set_Filled(0.0)
				patch_active_state = PATCH_STATE_INACTIVE
			end

			if patch_active_state == PATCH_STATE_ACTIVE then 
				display.PatchQuad.Set_Render_Mode(2)
			else
				display.PatchQuad.Set_Render_Mode(16)
			end
			
			scene_index = scene_index + 1
			
			if scene_index > #PPDScenes then
				break
			end
		end		
	end	
	
	-- there's at least one patch displaying, unhide the whole scene (so that there's a background)
	if scene_index > 1 then 
		PPDisplay.Set_Hidden(false)
	end
	
	-- Hide the scenes that are not being used!.	
	for i = scene_index, #PPDScenes do
		local display = PPDScenes[i]
		display.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Patch_Menu
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Patch_Menu()
	-- Now close the menu.
	PatchMenu.Set_Hidden(true)
	
	if ControllerDisplayingResearchAndFactionUI then 
		FactionButtons.Enable(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Patch_Queueing_Complete -- We cannot wait for the nice service time in the common command
-- bar so we are forcing an update here so that we can finally hide the animated quads in the menu.
-- ------------------------------------------------------------------------------------------------------------------
function On_Patch_Queueing_Complete(_, _, player)
	if player ~= Find_Player("local") then 
		return
	end
	
	PatchMenu.Process_Patch_Queueing_Complete()
	
	-- Now close the menu.
	-- PatchMenu.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_Patch_Queue_Size
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Patch_Queue_Size(_, _, player, new_size)
	if player == Find_Player("local") then
		Update_Queue_Size(new_size)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Size
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_Size(new_size)
	PatchMenu.Update_Queue_Size(new_size)	
	
	if new_size < 1 then
		PatchMenu.Set_Hidden(true)
	end
	
	-- Hide the button if the player cannot access the patches menu.
	PatchButton.Set_Hidden(new_size < 1)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Toggle_Patches_Menu_Display
-- ------------------------------------------------------------------------------------------------------------------
function Toggle_Patches_Menu_Display(event, source)
	
	End_Sell_Mode()
	
	-- Close all displays
	Hide_Research_Tree()
	
	-- close common displays.
	Close_All_Displays(false)
	
	local display = PatchMenu.Get_Hidden()
	PatchMenu.Set_Hidden(not PatchMenu.Get_Hidden())
	if display then 
		PatchMenu.Enable(true)
		FactionButtons.Enable(false)
	end	
	
	FlashPatchButton	= false	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Process_Build_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function Process_Build_Queue_Button_Clicked()
	if CommandBarEnabled == false then return end
	PatchMenu.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()

	-- Are there any huds open!?
	local close_huds, credits_changed = Update_Common_Scene()
	
	CloseHuds =  close_huds 
			 or this.Research_Tree.Is_Open()
			 or PatchMenu.Update_Scene(credits_changed)
	
	-- Update the flash state of the Patch button.
	if FlashPatchButton and not PatchButton.Get_Hidden() then 
		PatchButton.Start_Flash()
	else
		PatchButton.Stop_Flash()
	end
	
	Update_Patches_Progress_Display()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Tree_Open
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Tree_Open()
	-- if the patch menu is up, close it
	PatchMenu.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays()
	if CommandBarEnabled == false then return end
	if TestValid(PatchMenu) then 
		PatchMenu.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Maria 08.09.2006
-- Hide_All_Faction_Specific_UI 
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Faction_Specific_UI(onoff)
	if CommandBarEnabled == false then return end
	if onoff == true then
		PatchMenu.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Faction_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Faction_GUI_For_Replay()
	PatchButton.Enable(false)
	PatchMenu.Enable(false)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Faction_Has_Queue_Type -- Does this faction have the specific build queue type
-- ------------------------------------------------------------------------------------------------------------------
function Faction_Has_Queue_Type(queue_type)
	return true
end

-- ------------------------------------------------------------------------------------------------------------------
-- Faction_On_Controller_B_Button -- faction specific B button gui traversal
-- ------------------------------------------------------------------------------------------------------------------
function Faction_On_Controller_B_Button()
	if not  PatchMenu.Get_Hidden() then
		Hide_Patch_Menu()
		return true
	end
	return false
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
	Update_Mouse_Buttons = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
