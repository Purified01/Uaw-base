if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[73] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Hint.lua#16 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Hint.lua $
--
--    Original Author: Jonathan Burgess
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #16 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGPlayerProfile")
require("PGHintSystemDefs")
require("PGHintSystem")
require("UIControl")



function On_Init()

	PGHintSystemDefs_Init()
	
	this.Scriptable.Set_Tab_Order(1)
	
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)
	this.Register_Event_Handler("Controller_Y_Button_Up", nil, Disable_Hints)
	
	this.Register_Event_Handler("Animation_Finished", nil, On_Animation_Finished)
	
	this.Register_Event_Handler("Suspend_Hints", nil, On_Suspend_Hints)
	
	this.Scriptable.Hint_Image_01.Set_Hidden(true)
	this.Scriptable.Hint_Image_01_Frame.Set_Hidden(true)
	this.Scriptable.Hint_Image_02.Set_Hidden(true)
	this.Scriptable.Hint_Image_02_Frame.Set_Hidden(true)
	this.Scriptable.Hint_Image_03.Set_Hidden(true)
	this.Scriptable.Hint_Image_03_Frame.Set_Hidden(true)
	
	HintID = nil
	DataModel = nil
end

function On_Suspend_Hints(_, _)
	True_Hide_Dialog()
end

function Hide_Dialog()

	this.Play_Animation_Backwards("Fade_Animation", false)
	
	is_closing = true
end

function True_Hide_Dialog()

	this.Stop_Animation()
	
	this.Scriptable.Hint_Image_01.Set_Hidden(true)
	this.Scriptable.Hint_Image_01_Frame.Set_Hidden(true)
	this.Scriptable.Hint_Image_02.Set_Hidden(true)
	this.Scriptable.Hint_Image_02_Frame.Set_Hidden(true)
	this.Scriptable.Hint_Image_03.Set_Hidden(true)
	this.Scriptable.Hint_Image_03_Frame.Set_Hidden(true)

	this.Set_Hidden(true)
	this.Get_Containing_Scene().Raise_Event("Request_Hide", nil, nil)
	this.End_Modal()
	
	this.Set_State("Closed")
	
	CloseHuds = false
	Resume_Game()

	On_Remove_Xbox_Controller_Hint(HintID)
	
	-- A hint has been de-activated, let's announce this to the game mode scene.
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("Hint_Activated", nil, {false})
	end
end

function Disable_Hints()

	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Hint_System_Enabled", nil, {false, true})
	Hide_Dialog()
	
end

function Set_Hint_ID(hint_id)

	HintID = hint_id
	DataModel = HintSystemMap[HintID]
	Refresh_UI()
	
	-- A hint has been activated, let's announce this to the game mode scene.
	local scene = Get_Game_Mode_GUI_Scene()
	if scene then
		scene.Raise_Event("Hint_Activated", nil, {true})
	end
end

function Refresh_UI()

	if DataModel ~= nil then
		-- If we are updating the UI it means this hint is showing, hence, we have to make sure we set the scene
		-- in a state in which it can get Update calls so that we make sure we forcefully CLAIM focus!.
		-- this is necessary because may other applications will be trying to clear the key focus which will 
		-- cause this scene to lose it and therefore not be able to process the button presses.
		this.Set_State("Open")
		this.Focus_First()
		this.Scriptable.Hint_Text.Set_Text(DataModel.Text)
		
		if DataModel.Num_Images ~= nil and DataModel.Num_Images > 0 then
			--images to be displayed
			if DataModel.Num_Images == 1 then
				this.Scriptable.Hint_Image_02.Set_Texture(DataModel.Images[1])
				this.Scriptable.Hint_Image_02.Set_Hidden(false)
				this.Scriptable.Hint_Image_02_Frame.Set_Hidden(false)
			elseif DataModel.Num_Images == 2 then
				this.Scriptable.Hint_Image_01.Set_Texture(DataModel.Images[1])
				this.Scriptable.Hint_Image_01.Set_Hidden(false)
				this.Scriptable.Hint_Image_01_Frame.Set_Hidden(false)
				this.Scriptable.Hint_Image_03.Set_Texture(DataModel.Images[2])
				this.Scriptable.Hint_Image_03.Set_Hidden(false)			
				this.Scriptable.Hint_Image_03_Frame.Set_Hidden(false)			
			elseif DataModel.Num_Images == 3 then
				this.Scriptable.Hint_Image_01.Set_Texture(DataModel.Images[1])
				this.Scriptable.Hint_Image_01.Set_Hidden(false)
				this.Scriptable.Hint_Image_01_Frame.Set_Hidden(false)
				this.Scriptable.Hint_Image_02.Set_Texture(DataModel.Images[2])
				this.Scriptable.Hint_Image_02.Set_Hidden(false)
				this.Scriptable.Hint_Image_02_Frame.Set_Hidden(false)
				this.Scriptable.Hint_Image_03.Set_Texture(DataModel.Images[3])
				this.Scriptable.Hint_Image_03.Set_Hidden(false)
				this.Scriptable.Hint_Image_03_Frame.Set_Hidden(false)
			else
				--probably an error
			end			
		end

		this.Play_Animation("Fade_Animation", false)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update - this update is only called when the scene is in OPEN state!.
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()
	this.Focus_First()
	if ( is_closing ) then
		-- Maria 12.15.2007 (fix for bug #2800 sega db)
		-- Sometimes the hints will pop in a scene that is framed by the letterbox  (eg, while the post battle scene is
		-- up).  In that case, the animation will be paused because the letterbox animation in the command bar is paused. 
		-- Thus, since this scene is added to the command bar, the Pause_Animation call in the command bar script will 
		-- pause all animations (it trickles down the hierarchy).  In turn, all attempts at closing the hint's display will
		-- fail.  So, we have to make sure the fade animation for the hint is never paused!.
		this.Resume_Animation()
		
		-- Maria 12.15.2007
		-- Commenting this out because the best way of doing it is by registering for the Animation_Finished event.  That way
		-- we don't have to check on the sate of the animation at every frame.
		--[[
		local frame = this.Get_Animation_Frame()
		if ( frame == 0 ) then
			is_closing = false
			True_Hide_Dialog()
			return
		end
		]]--
	end

end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Animation_Finished - 
-- ------------------------------------------------------------------------------------------------------------------
function On_Animation_Finished(_, _)
	if ( is_closing ) then
		is_closing = false
		True_Hide_Dialog()
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Hint_ID = Set_Hint_ID

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
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	OutputDebug = nil
	PGHintSystem_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Objective_Text = nil
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
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Loading_Screen_Background = nil
	UI_Set_Loading_Screen_Faction_ID = nil
	UI_Set_Loading_Screen_Mission_Text = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
