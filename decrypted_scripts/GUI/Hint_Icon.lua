if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Hint_Icon.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Hint_Icon.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")
require("PGHintSystem")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	PGHintSystem_Init()
	
	
	-- ********* GUI INIT **************
	Scene = nil
	DataModelId = nil
	IsShowing = true
	Active = false
	IsLetterboxMode = false

	-- Event handlers
	Hint_Icon.Register_Event_Handler("On_Hint_Text_Dismissed", nil, On_Hint_Text_Dismissed)
	Hint_Icon.Register_Event_Handler("Animation_Finished", Hint_Icon.Quad_1, On_Icon_Animation_Finished)
	Hint_Icon.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	
	Register_Hint_Context_Scene(Hint_Icon.Get_Containing_Scene())
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(_, _, on_off)
	IsLetterboxMode = on_off
end

-------------------------------------------------------------------------------
-- On_Component_Hidden
-------------------------------------------------------------------------------
function On_Component_Hidden()
	IsShowing = false
end

-------------------------------------------------------------------------------
-- On_Component_Shown
-------------------------------------------------------------------------------
function On_Component_Shown()
	IsShowing = true
	
	-- If we are displayed while in Letterbox mode then do not flag the 
	-- zoom in animation to play!.
	-- Per bug #3301: Hint icon should remain in place and the same size throughout the un-letterboxing
	if not IsLetterboxMode then
		this.Play_Animation("Zoom_In", false)
	end
end

-------------------------------------------------------------------------------
-- Icon Click
-------------------------------------------------------------------------------
function On_Icon_Clicked(event_name, source)
	if not Active then 
		Activate_Independent_Hint(DataModelId)
		Invoke_Hint_Activation_Callback(DataModelId)
	else
		Dismiss_Hint()
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Hint_Text_Dismissed()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Click() 
	Play_SFX_Event("GUI_Generic_Button_Select")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Play_Alien_Steam() 
	Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Prepare_Fadeout()
	-- We can't call mapped functions from the GUI we have to go through this.
	Prepare_Fades()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function On_Icon_Animation_Finished()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Dismiss_Hint
-------------------------------------------------------------------------------
function Dismiss_Hint()
	if (DataModelId ~= nil) then
		Remove_Independent_Hint(DataModelId)
		Invoke_Hint_Dismissal_Callback(DataModelId)
		-- Play a 2D sound
		Play_SFX_Event("GUI_Hint_Text_Closed")
	end
end


-------------------------------------------------------------------------------
-- Call to tell if this hint icon is currently visible.
-------------------------------------------------------------------------------
function Is_Showing()
	return IsShowing
end

-------------------------------------------------------------------------------
-- Call to set the id of the hint to be associated with this icon.
-------------------------------------------------------------------------------
function Set_Model(model_id)
	DataModelId = model_id
end

-------------------------------------------------------------------------------
-- Call to set the parent scene of this icon.
-------------------------------------------------------------------------------
function Set_Scene(scene)
	Scene = scene
end


-------------------------------------------------------------------------------
-- Set_Active
-------------------------------------------------------------------------------
function Set_Active(on_off)
	Active = on_off
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Showing = Is_Showing
Interface.Set_Model = Set_Model
Interface.Set_Scene = Set_Scene
Interface.Set_Active = Set_Active

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
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
	Notify_Attached_Hint_Created = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Prepare_Fadeout = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
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
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
