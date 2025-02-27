if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Yes_No_Ok_Dialog.lua#15 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/gamepad_Yes_No_Ok_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 92970 $
--
--          $DateTime: 2008/02/08 16:20:47 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	-- Constants
	VIEW_MODE_YES_NO	= Declare_Enum(1)
	VIEW_MODE_OK		= Declare_Enum()
	VIEW_MODE_MESSAGE	= Declare_Enum()
	
	-- Variables
	DataModel = nil
	ViewMode = VIEW_MODE_OK
	UserData = nil

	TEXT_YES = Get_Game_Text("TEXT_YES")
	TEXT_NO = Get_Game_Text("TEXT_NO")
	TEXT_OKAY = Get_Game_Text("TEXT_BUTTON_OK")

	BG_GUTTER = 0.035

	-- Events
	this.Register_Event_Handler("Controller_A_Button_Up", nil, On_Yes_Clicked)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_No_Clicked)
	this.Register_Event_Handler("Controller_X_Button_Up", nil, On_Ok_Clicked)
	this.Register_Event_Handler("Controller_Back_Button_Up", nil, On_Back_Clicked)
	this.Register_Event_Handler("Closing_All_Displays", nil, Close_Dialog)
	this.Register_Event_Handler("Resize_GUI_Elements", nil, Resize_GUI_Elements)		
	
	this.Scriptable_1.Set_Tab_Order(0)
	
--	Yes_No_Ok_Dialog.Start_Modal()

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
function On_Hidden()
	this.End_Modal()
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Shown()
	this.Focus_First()
end

-------------------------------------------------------------------------------
-- Maps to "right" in a custom message.
-------------------------------------------------------------------------------
function On_Yes_Clicked(event_name, source)

	if ViewMode == VIEW_MODE_YES_NO or (DataModel and DataModel.Override == true) then
	
		-- Does the caller want the dialog to remain up and modal and blocking input in the scene behind?
		if ((DataModel.Keep_Modal_On_Event == nil) or (DataModel.Keep_Modal_On_Event ~= DataModel.Button_Right_Text)) then
		
			-- The caller just wants the dialog dismissed.
			this.End_Modal()
			Yes_No_Ok_Dialog.Get_Containing_Component().Set_Hidden(true)
			
		end
		
		Yes_No_Ok_Dialog.Get_Containing_Scene().Raise_Event_Immediate("On_YesNoOk_Yes_Clicked", nil, {})
		
	end
	
end

-------------------------------------------------------------------------------
-- Maps to "left" in a custom message.
-------------------------------------------------------------------------------
function On_No_Clicked(event_name, source)

	if ViewMode == VIEW_MODE_YES_NO or (DataModel and DataModel.Override == true) then
	
		-- Does the caller want the dialog to remain up and modal and blocking input in the scene behind?
		if ((DataModel.Keep_Modal_On_Event == nil) or (DataModel.Keep_Modal_On_Event ~= DataModel.Button_Left_Text)) then
	
			-- The caller just wants the dialog dismissed.
			this.End_Modal()
			Yes_No_Ok_Dialog.Get_Containing_Component().Set_Hidden(true)
			
		end
		
		Yes_No_Ok_Dialog.Get_Containing_Scene().Raise_Event_Immediate("On_YesNoOk_No_Clicked", nil, {})
		
	end
	
end

-------------------------------------------------------------------------------
-- Maps to "middle" in a custom message.
-------------------------------------------------------------------------------
function On_Ok_Clicked(event_name, source)

	if ViewMode == VIEW_MODE_OK or (DataModel and DataModel.Override == true) then
	
		-- Does the caller want the dialog to remain up and modal and blocking input in the scene behind?
		if ((DataModel.Keep_Modal_On_Event == nil) or (DataModel.Keep_Modal_On_Event ~= DataModel.Button_Middle_Text)) then
		
			-- The caller just wants the dialog dismissed.
			this.End_Modal()
			Yes_No_Ok_Dialog.Get_Containing_Component().Set_Hidden(true)
					
		end
		
		Yes_No_Ok_Dialog.Get_Containing_Scene().Raise_Event_Immediate("On_YesNoOk_Ok_Clicked", nil, {})

	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Back_Clicked(event_name, source)

	-- The caller just wants the dialog dismissed.
	this.End_Modal()
	Yes_No_Ok_Dialog.Get_Containing_Component().Set_Hidden(true)
					
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

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Close_Dialog()
	this.End_Modal()
	Yes_No_Ok_Dialog.Get_Containing_Component().Set_Hidden(true)
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI()

	if (DataModel == nil or DataModel.Message == nil or DataModel.Message == "") then
		Yes_No_Ok_Dialog.Text_Message.Set_Text("INVALID")
	else
		Yes_No_Ok_Dialog.Text_Message.Set_Text(DataModel.Message)
	end

	if DataModel == nil or DataModel.Override == nil then
		Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Text(TEXT_YES)
		Yes_No_Ok_Dialog.Buttons.Button_No.Set_Text(TEXT_NO)
		Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Text(TEXT_OKAY)
		if (ViewMode == VIEW_MODE_OK) then
			Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_A.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_No.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_B.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_X.Set_Hidden(false)
		elseif (ViewMode == VIEW_MODE_YES_NO) then
			Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_A.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_No.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_B.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_X.Set_Hidden(true)
		else
			Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_A.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_No.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_B.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_X.Set_Hidden(true)
		end
	else
		if DataModel.Button_Right_Text == nil or DataModel.Button_Right_Text == "" then
			Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_A.Set_Hidden(true)
		else
			Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_A.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_Yes.Set_Text(DataModel.Button_Right_Text)
		end

		if DataModel.Button_Left_Text == nil or DataModel.Button_Left_Text == "" then
			Yes_No_Ok_Dialog.Buttons.Button_No.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_B.Set_Hidden(true)
		else
			Yes_No_Ok_Dialog.Buttons.Button_No.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_B.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_No.Set_Text(DataModel.Button_Left_Text)
		end

		if DataModel.Button_Middle_Text == nil or DataModel.Button_Middle_Text == "" then
			Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Hidden(true)
			Yes_No_Ok_Dialog.Buttons.Button_X.Set_Hidden(true)
		else
			Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_X.Set_Hidden(false)
			Yes_No_Ok_Dialog.Buttons.Button_Ok.Set_Text(DataModel.Button_Middle_Text)
		end
	end

	--Schedule resize of the text window for the next update (text size won't be available until then)
	this.Raise_Event("Resize_GUI_Elements", nil, nil)
end

------------------------------------------------------------------------------
-- Given the dimensions of the text block for the hint, resize the containing
-- art so that it fits snugly against the text.
------------------------------------------------------------------------------
function Resize_GUI_Elements()

	local text_width = this.Text_Message.Get_Text_Width()
	local text_height = this.Text_Message.Get_Text_Height()

	local txtx, txty, txtw, txth = this.Text_Message.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = this.Frame.Get_World_Bounds()
	local butx, buty, butw, buth = this.Buttons.Get_World_Bounds()
	
	if text_width == 0 or text_height == 0 then
		--Text not ready yet.  Try again later
		this.Raise_Event("Resize_GUI_Elements", nil, nil)
		return
	end	
	
	-- Height
	-- We want to keep the upper bounds in place and move the lower bounds to accomodate.
	local new_bgh = text_height + BG_GUTTER
	local new_buty = buty

	-- Only add the buttons to the frame height if at least one is visible
	if this.Buttons.Button_X.Get_Hidden() == false or
		this.Buttons.Button_A.Get_Hidden() == false or
		this.Buttons.Button_B.Get_Hidden() == false then
		new_bgh = new_bgh + buth + BG_GUTTER
		new_buty = txty + text_height + BG_GUTTER
	end

	this.Text_Message.Set_World_Bounds(txtx, txty, txtw, text_height)
	this.Buttons.Set_World_Bounds(butx, new_buty, butw, buth)
	this.Frame.Set_World_Bounds(bgx, bgy, bgw, new_bgh)
	
	--Hint is now ready for display
	this.Set_Hidden(false)
	this.Focus_First()
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
function Set_Yes_No_Mode()
	ViewMode = VIEW_MODE_YES_NO
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Ok_Mode()
	ViewMode = VIEW_MODE_OK
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Message_Mode()
	ViewMode = VIEW_MODE_MESSAGE
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Model(model)
	DataModel = model
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Checkbox_Visible(value)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_User_Data(user_data)
	UserData = user_data
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_User_Data()
	return UserData
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Checkbox_State()
	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Yes_No_Mode = Set_Yes_No_Mode
Interface.Set_Ok_Mode = Set_Ok_Mode
Interface.Set_Message_Mode = Set_Message_Mode
Interface.Set_Model = Set_Model
Interface.Set_Checkbox_Visible = Set_Checkbox_Visible
Interface.Set_User_Data = Set_User_Data
Interface.Get_User_Data = Get_User_Data
Interface.Get_Checkbox_State = Get_Checkbox_State

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
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
