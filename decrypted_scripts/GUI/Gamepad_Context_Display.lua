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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Context_Display.lua 
--
--            Author: Maria Teruel
--
--          DateTime: 2007/09/18 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("Gamepad_Contexts_Data")

-- -------------------------------------------------------------------------------------------------------------------
-- On_Init
-- -------------------------------------------------------------------------------------------------------------------
function On_Init()

	LEFT_DISPLAY = Declare_Enum(0)
	RIGHT_DISPLAY = Declare_Enum()
	CENTER_DISPLAY = Declare_Enum()
	
	-- --------------------------------------------------------------------------------------------------------------------
	-- Store the buttons here in the order they should be displayed so that we don't have to sort them while updating the display!.
	ContextSideToSortedTriggers = {}
	ContextSideToSortedTriggers[LEFT_DISPLAY] = {}
	ContextSideToSortedTriggers[LEFT_DISPLAY][1] = {'LT'} -- appears below the next trigger display
	ContextSideToSortedTriggers[LEFT_DISPLAY][2] = {'LB'} -- appears on top!.

	ContextSideToSortedTriggers[CENTER_DISPLAY] = {}
	ContextSideToSortedTriggers[CENTER_DISPLAY][1] = {'B'}
	ContextSideToSortedTriggers[CENTER_DISPLAY][2] = {'Dpad' , 'DpadUp',  'DpadDown'}
	
	ContextSideToSortedTriggers[RIGHT_DISPLAY] = {}
	ContextSideToSortedTriggers[RIGHT_DISPLAY][1] = {'RT'} -- appears below the next trigger display
	ContextSideToSortedTriggers[RIGHT_DISPLAY][2] = {'RB'} -- appears on top!.
	-- --------------------------------------------------------------------------------------------------------------------	
	
	LContexts = Find_GUI_Components(this.Left, "Context")
	for index, context in pairs(LContexts) do
		context.Set_Hidden(true)
		-- each context has a trigger associated with it.
		if index <= #ContextSideToSortedTriggers[LEFT_DISPLAY] then
			context.Set_User_Data(ContextSideToSortedTriggers[LEFT_DISPLAY][index])
		end
	end
	
	CContexts = Find_GUI_Components(this.Center, "Context")
	for index, context in pairs(CContexts) do
		context.Set_Hidden(true)
		-- each context has a trigger associated with it.
		if index <= #ContextSideToSortedTriggers[CENTER_DISPLAY] then
			context.Set_User_Data(ContextSideToSortedTriggers[CENTER_DISPLAY][index])
		end
	end
	
	RContexts = Find_GUI_Components(this.Right, "Context")
	for index, context in pairs(RContexts) do
		context.Set_Hidden(true)
		-- each context has a trigger associated with it.
		if index <= #ContextSideToSortedTriggers[RIGHT_DISPLAY] then
			context.Set_User_Data(ContextSideToSortedTriggers[RIGHT_DISPLAY][index])
		end
	end
	
	-- --------------------------------------------------------------------------------------------------------------------
	ContextSideToContextsTable = {}
	ContextSideToContextsTable[LEFT_DISPLAY] = LContexts
	ContextSideToContextsTable[RIGHT_DISPLAY] = RContexts
	ContextSideToContextsTable[CENTER_DISPLAY] = CContexts	
	-- ------------------------------------------------------------------------------------------------------------------------
	
	GamepadButtonsToTexturesMap = {}
	GamepadButtonsToTexturesMap['LB'] 		= "Gamepad_Controller_LBumper.tga"
	GamepadButtonsToTexturesMap['RB'] 		= "Gamepad_Controller_RBumper.tga"
	GamepadButtonsToTexturesMap['LT'] 		= "Gamepad_Controller_LTrigger.tga"
	GamepadButtonsToTexturesMap['RT'] 		= "Gamepad_Controller_RTrigger.tga"
	GamepadButtonsToTexturesMap['A']   		= "Gamepad_A_Button.tga"
	GamepadButtonsToTexturesMap['B']   		= "Gamepad_B_Button.tga"
	GamepadButtonsToTexturesMap['Dpad'] 		= "d_pad.tga"
	GamepadButtonsToTexturesMap['DpadUp'] 	= "d_pad_up.tga"
	GamepadButtonsToTexturesMap['DpadDown'] 	= "d_pad_down.tga"
	
	GamepadButtonsToTexturesMap['X']   		= "Gamepad_X_Button.tga"
	GamepadButtonsToTexturesMap['Y']  		 = "Gamepad_Y_Button.tga"	
	-- -------------------------------------------------------------------------------------------------------------------------
	
	GamepadCurrentContexts = nil
	Init_Gamepad_Contexts_Data()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Context_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Context_Display(contexts_table)
	if not contexts_table then 
		return
	end	
	GamepadCurrentContexts = contexts_table
	
	-- Start filling up the LEFT context displays. (Trigger first, then bumper)
	Update_Display(LEFT_DISPLAY)
	
	-- Start filling up the CENTER context displays. (B button only for now)
	Update_Display(CENTER_DISPLAY)
	
	-- Now, fill up the RIGHT context displays. (Trigger first, then bumper)
	Update_Display(RIGHT_DISPLAY)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Display(LRC_display)

	local context_scenes = ContextSideToContextsTable[LRC_display]
	if not context_scenes then 
		return 
	end
	
	if ContextSideToSortedTriggers[LRC_display] then
		for _, context_scene in pairs(context_scenes) do
			local scene_triggers = context_scene.Get_User_Data()
			local found_trigger = false
			for _, scene_trigger in pairs(scene_triggers) do
				if GamepadCurrentContexts[scene_trigger] then
					local context_data = GamepadContextToDisplayData[GamepadCurrentContexts[scene_trigger]]
					if context_data then 
						context_scene.Set_Hidden(false)
						-- Set the texture for the trigger assigned to this context.
						local trigger_texture = GamepadButtonsToTexturesMap[scene_trigger]
						if trigger_texture then 
							context_scene.Quad.Set_Texture(trigger_texture)
						end
					
						-- Set the text assigned to this context.
						if context_data.TextID then
							context_scene.Text.Set_Text(context_data.TextID)
						else
							context_scene.Text.Set_Text("")
						end	
						found_trigger = true
						break
					end
				end	
			end				
			
			if not found_trigger then
				context_scene.Set_Hidden(true)
			end
		end		
	end
end


-- -------------------------------------------------------------------------------------
-- INTERFACE
-- -------------------------------------------------------------------------------------
Interface = {}
Interface.Update_Context_Display = Update_Context_Display

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
