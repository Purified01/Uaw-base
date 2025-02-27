if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[109] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Hint_Text.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Hint_Text.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGHintSystemDefs")
require("PGHintSystem")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	PGHintSystemDefs_Init()
	PGHintSystem_Init()
	Register_Hint_Context_Scene(Hint_Text.Get_Containing_Scene())			-- Set the scene which all hints will be attached to / removed from.

	-- ********* GUI INIT **************
	DISMISSAL_TIMEOUT = 5
	HINT_BG_GUTTER = 0.035
	HINT_CLOSE_BUTTON_WIDTH = 0.038 

	Scene = nil
	HintID = nil
	DataModel = nil
	IsShowing = true
	DismissalTimer = -1
	DismissalCountdown = -1
	DefaultVerticalDelta = 0

	--Start_Dismissal_Countdown()
	
	this.Register_Event_Handler("Resize_Hint_Text_Window", nil, Resize_Text_Window)		
	
	--Begin hidden until text is ready to be rendered (may take a couple of frames)
	this.Set_Hidden(true)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	IsShowing = false
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	IsShowing = true
	Start_Dismissal_Countdown()
	-- Play a 2D sound
	Play_SFX_Event("GUI_Hint_Text_Shown")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Close_Clicked(event_name, source)
	IsShowing = false
	Dismiss_Hint()	
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Disable_Hints_Clicked(event, source, game_object)
	MessageBox("NIY")
	--Set_Hint_System_Enabled(false)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Mouse_On(event_name, source)
	DismissalCountdown = -1
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Mouse_Off(event_name, source)
	DismissalCountdown = DISMISSAL_TIMEOUT
	DismissalTimer = GetCurrentTime()
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
function Refresh_UI()
	--Hint_Text.Title_Text.Set_Text(DataModel.Name)
	Hint_Text.Body_Text.Set_Text(DataModel.Text)
end   

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function Reset_Text_Window()
	Hint_Text.Body_Text.Set_World_Bounds(DefaultTextX, DefaultTextY, DefaultTextW, DefaultTextH)
	Hint_Text.Frame.Set_World_Bounds(DefaultBGX, DefaultBGY, DefaultBGW, DefaultBGH)
	Hint_Text.Quad_Close.Set_World_Bounds(DefaultClsX, DefaultClsY, DefaultClsW, DefaultClsH)
end
	
------------------------------------------------------------------------------
-- Given the dimensions of the text block for the hint, resize the containing
-- art so that it fits snugly against the text.
------------------------------------------------------------------------------
function Resize_Text_Window()

	local text_width = Hint_Text.Body_Text.Get_Text_Width()
	local text_height = Hint_Text.Body_Text.Get_Text_Height()
	local txtx, txty, txtw, txth = Hint_Text.Body_Text.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = Hint_Text.Frame.Get_World_Bounds()
	local clsx, clsy, clsw, clsh = Hint_Text.Quad_Close.Get_World_Bounds()
	
	if text_width == 0 or text_height == 0 then
		--Text not ready yet.  Try again later
		this.Raise_Event("Resize_Hint_Text_Window", nil, nil)
		return
	end	
	
	-- Width
	-- Adjust the left side of the background to match the width of the text.
	local new_bgw = text_width + HINT_BG_GUTTER + HINT_CLOSE_BUTTON_WIDTH
	local bgw_delta = DefaultBGW - new_bgw
	
	-- Height
	-- We want to keep the upper bounds in place and move the lower bounds to accomodate.
	local new_bgh = text_height + HINT_BG_GUTTER
	local bgh_delta = DefaultBGH - new_bgh
	
	-- Horizontal adjustments
	local new_bgx = DefaultBGX + bgw_delta
	local new_txtx = DefaultTextX + bgw_delta
	
	-- Vertical adjustments
	local new_txty = txty + DefaultVerticalDelta
	local new_bgy = bgy + DefaultVerticalDelta
	local new_clsy = clsy + DefaultVerticalDelta

	Hint_Text.Body_Text.Set_World_Bounds(new_txtx, new_txty, txtw, text_height)
	Hint_Text.Frame.Set_World_Bounds(new_bgx, new_bgy, new_bgw, new_bgh)
	Hint_Text.Quad_Close.Set_World_Bounds(clsx, new_clsy, clsw, clsh)
	
	--Hint is now ready for display
	this.Set_Hidden(false)
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
--
-------------------------------------------------------------------------------
function Start_Dismissal_Countdown()
	DismissalCountdown = DISMISSAL_TIMEOUT
	DismissalTimer = GetCurrentTime()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Dismiss_Hint()
	if (DataModel ~= nil) then
		Remove_Independent_Hint(DataModel.Id)
		Invoke_Hint_Dismissal_Callback(DataModel.Id)
		-- Play a 2D sound
		Play_SFX_Event("GUI_Hint_Text_Closed")
	end
end


-------------------------------------------------------------------------------
-- On_Close_Button_Pushed
-------------------------------------------------------------------------------
function On_Close_Button_Pushed(event, source)
	Play_SFX_Event("GUI_Generic_Button_Select")
end

-------------------------------------------------------------------------------
-- Call to set the parent scene of this icon.
-------------------------------------------------------------------------------
function Set_Model(hint_id)
	HintID = hint_id
	DataModel = HintSystemMap[HintID]
	Reset_Text_Window()
	Refresh_UI()
	
	--Schedule resize of the text window for the next update (text size won't be available until then)
	this.Raise_Event("Resize_Hint_Text_Window", nil, nil)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Model_ID()
	return HintID
end

-------------------------------------------------------------------------------
-- Call to tell if this hint text is currently visible.
-------------------------------------------------------------------------------
function Is_Showing()
	return IsShowing
end

-------------------------------------------------------------------------------
-- Call to set the parent scene of this icon.
-------------------------------------------------------------------------------
function Set_Scene(scene)
	Scene = scene
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Mark_Default_World_Bounds()
	DefaultTextX, DefaultTextY, DefaultTextW, DefaultTextH = Hint_Text.Body_Text.Get_World_Bounds()
	DefaultBGX, DefaultBGY, DefaultBGW, DefaultBGH = Hint_Text.Frame.Get_World_Bounds()
	DefaultClsX, DefaultClsY, DefaultClsW, DefaultClsH = Hint_Text.Quad_Close.Get_World_Bounds()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Default_Vertical_Position(ypos)
	DefaultVerticalDelta = ypos - DefaultClsY
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Get_Model_ID = Get_Model_ID
Interface.Is_Showing = Is_Showing
Interface.Set_Scene = Set_Scene
Interface.Mark_Default_World_Bounds = Mark_Default_World_Bounds
Interface.Set_Default_Vertical_Position = Set_Default_Vertical_Position

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
