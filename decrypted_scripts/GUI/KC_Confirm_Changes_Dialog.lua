if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/KC_Confirm_Changes_Dialog.lua
--
--            Author: Maria Teruel
--
--          Date: 2007/04/02
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

-- ----------------------------------------------------------------------------------------------------------------------------------
-- This is the confirmation dialog that pops up when a new key binding assignment happens to be bound to a different 
-- command.
-- ----------------------------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------
-- On_Init
-- -------------------------------------------------------------------------------
function On_Init()
	-- If reporting == true then we are just displaying a message and have no use for the cancel
	-- button!.
	Reporting = false
	
	Text = this.Text
	Text.Set_Text("")
	this.Register_Event_Handler("Closing_All_Displays", nil, On_Close_Dialog)
	this.CancelButton.Set_Text("TEXT_BUTTON_CANCEL")
	this.OkButton.Set_Text("TEXT_BUTTON_OK")
end


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


-- -------------------------------------------------------------------------------
-- Setup_Display
-- -------------------------------------------------------------------------------
function Setup_Display(text_to_display)
	
	local message
	if Reporting == false then 
		message = Get_Game_Text("TEXT_PROCEED_WITH_CHANGES")
	
		if not text_to_display then 
			message = "No text?"
		else	
			Replace_Token(message, text_to_display, 1)
		end	
	else
		message = text_to_display	
	end
	
	Text.Set_Text(message)
	
	if Reporting == true then 
		-- we want to disable the cancel button since this is only a reporting screen.
		this.CancelButton.Enable(false)
	else
		this.CancelButton.Enable(true)
	end	
end


-- -------------------------------------------------------------------------------
-- On_OK_Button_Clicked
-- -------------------------------------------------------------------------------
function On_OK_Button_Clicked(event, source)
	On_Close_Dialog(event, source, true)
end

-- -------------------------------------------------------------------------------
-- On_CANCEL_Button_Clicked
-- -------------------------------------------------------------------------------
function On_CANCEL_Button_Clicked(event, source)
	On_Close_Dialog(event, source, false)	
end

-- -------------------------------------------------------------------------------
-- On_Close_Dialog
-- -------------------------------------------------------------------------------
function On_Close_Dialog(_, _, true_false)
	
	if true_false == nil then 
		true_false = false
	end
	
	IsShowing = false
	Reporting = false
	
	if (this ~= nil) then
		this.End_Modal(true_false)
		this.Get_Containing_Component().Set_Hidden(true)
	end
end

-- -------------------------------------------------------------------------------
-- On_Component_Hidden
-- -------------------------------------------------------------------------------
function On_Component_Hidden()
	IsShowing = false
end

-------------------------------------------------------------------------------
-- On_Component_Shown
-------------------------------------------------------------------------------
function On_Component_Shown()
	IsShowing = true
end

-------------------------------------------------------------------------------
-- Is_Showing
-------------------------------------------------------------------------------
function Is_Showing()
	return IsShowing
end


-------------------------------------------------------------------------------
-- Set_Reporting_Mode
-------------------------------------------------------------------------------
function Set_Reporting_Mode()
	Reporting = true
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Showing = Is_Showing
Interface.Setup_Display = Setup_Display
Interface.Set_Reporting_Mode = Set_Reporting_Mode
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
