if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Global_Conquest_Net_Dialog.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Global_Conquest_Net_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 93567 $
--
--          $DateTime: 2008/02/18 02:49:38 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")

ScriptPoolCount = 0


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	IsShowing = true
	DebugMessage("LUA_LOBBY: Showing modal CtW net dialog...")

	-- ********* GUI INIT **************
	
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Cancel_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, On_Quickmatch_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Cancel_Clicked)

	-- ********* GUI INIT **************
	
	this.Scriptable_1.Set_Tab_Order(0)
	
	-- whenever this scene is displayed we need to make sure it gets the key focus so that it can 
	-- properly handle the controller events is registered for (otherwise, the parent scene will get
	-- to handle them which is BAD!!!!)
	this.Focus_First()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Button_Select")
	end
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Hidden()
	IsShowing = false
	DebugMessage("LUA_LOBBY: Hiding modal CtW net dialog...")
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Component_Shown()
	IsShowing = true
	DebugMessage("LUA_LOBBY: Showing modal CtW net dialog...")
	-- whenever this scene is displayed we need to make sure it gets the key focus so that it can 
	-- properly handle the controller events is registered for (otherwise, the parent scene will get
	-- to handle them which is BAD!!!!)
	this.Focus_First()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Cancel_Clicked(event_name, source)
	Global_Conquest_Net_Dialog.Get_Containing_Scene().Raise_Event_Immediate("On_Back_Out", nil, {})
	IsShowing = false
	if (Global_Conquest_Net_Dialog ~= nil) then
        Global_Conquest_Net_Dialog.Get_Containing_Component().Set_Hidden(true)
		this.End_Modal()
    end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Go_Clicked(event_name, source)
	Global_Conquest_Net_Dialog.Get_Containing_Scene().Raise_Event_Immediate("On_Go", nil, {})
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Quickmatch_Clicked(event_name, source)
	Global_Conquest_Net_Dialog.Get_Containing_Scene().Raise_Event_Immediate("On_Quickmatch", nil, {})
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

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Quickmatch_Button_Visible(visible)
	Global_Conquest_Net_Dialog.Scriptable_1.Button_Quickmatch.Set_Hidden(not visible)
	Global_Conquest_Net_Dialog.Scriptable_1.Quad_Quickmatch.Set_Hidden(not visible)
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
function Set_Title(title)
	Global_Conquest_Net_Dialog.Scriptable_1.Text_Title.Set_Text(title)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Message(message)
	Global_Conquest_Net_Dialog.Scriptable_1.Text_Message.Set_Text(message)
end

-------------------------------------------------------------------------------
-- Call to tell if this hint text is currently visible.
-------------------------------------------------------------------------------
function Is_Showing()
	return IsShowing
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Title = Set_Title
Interface.Set_Message = Set_Message
Interface.Is_Showing = Is_Showing
Interface.Set_Quickmatch_Button_Visible = Set_Quickmatch_Button_Visible

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Play_Alien_Steam = nil
	Play_Click = nil
	Prepare_Fadeout = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
