-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/GUI_Tooltip.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/GUI_Tooltip.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 81114 $
--
--          $DateTime: 2007/08/16 17:29:18 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGColors")


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function GUI_Tooltip_Constants()

	-- Constants
	VIEW_STATE_TEXT_ONLY = Declare_Enum(1)
	VIEW_STATE_TITLE_TEXT = Declare_Enum()
	VIEW_STATE_ICON_TEXT = Declare_Enum()
	VIEW_STATE_TITLE_ICON_TEXT = Declare_Enum()
	
	H_GUTTER = 0.015
	V_GUTTER = 0.01 
	
	MINIMUM_TITLE_TEXT_WIDTH = 0.2		
	MINIMUM_TITLE_ICON_TEXT_WIDTH = 0.2		
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Init()

	GUI_Tooltip_Constants()
	PGColors_Init()
	
	-- Variables
	ViewState = VIEW_STATE_TEXT_ONLY
	DataModel = nil
	_WrapperHandle = nil
	
	-- Resizing Functions
	ResizingFunctions = {}
	ResizingFunctions[VIEW_STATE_TEXT_ONLY] = Resize_Text_Only
	ResizingFunctions[VIEW_STATE_TITLE_TEXT] = Resize_Title_Text
	ResizingFunctions[VIEW_STATE_ICON_TEXT] = Resize_Icon_Text
	ResizingFunctions[VIEW_STATE_TITLE_ICON_TEXT] = Resize_Title_Icon_Text
	
	-- Setup
	Set_View_State(VIEW_STATE_TEXT_ONLY)	-- Redundant set, but this builds the UI.
	
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI() 

	-- View State
	if (ViewState == VIEW_STATE_TEXT_ONLY) then
	
		this.Panel_Text_Only.Set_Hidden(false)
		this.Panel_Title_Text.Set_Hidden(true)
		this.Panel_Icon_Text.Set_Hidden(true)
		this.Panel_Title_Icon_Text.Set_Hidden(true)
		
	elseif (ViewState == VIEW_STATE_TITLE_TEXT) then
	
		this.Panel_Text_Only.Set_Hidden(true)
		this.Panel_Title_Text.Set_Hidden(false)
		this.Panel_Icon_Text.Set_Hidden(true)
		this.Panel_Title_Icon_Text.Set_Hidden(true)
		
	elseif (ViewState == VIEW_STATE_ICON_TEXT) then
	
		this.Panel_Text_Only.Set_Hidden(true)
		this.Panel_Title_Text.Set_Hidden(true)
		this.Panel_Icon_Text.Set_Hidden(false)
		this.Panel_Title_Icon_Text.Set_Hidden(true)
		
	elseif (ViewState == VIEW_STATE_TITLE_ICON_TEXT) then
	
		this.Panel_Text_Only.Set_Hidden(true)
		this.Panel_Title_Text.Set_Hidden(true)
		this.Panel_Icon_Text.Set_Hidden(true)
		this.Panel_Title_Icon_Text.Set_Hidden(false)
		
	end
	
	-- Data
	if (DataModel ~= nil) then
	
		if (DataModel.text_body ~= nil) then
			this.Panel_Text_Only.Text_Body.Set_Text(DataModel.text_body)
			this.Panel_Title_Text.Text_Body.Set_Text(DataModel.text_body)
			this.Panel_Icon_Text.Text_Body.Set_Text(DataModel.text_body)
			this.Panel_Title_Icon_Text.Text_Body.Set_Text(DataModel.text_body)
		end
		
		local color = PGCOLOR_WHITE_TRIPLE
		if (DataModel.text_body_color ~= nil) then
			color = PGCOLOR_BASE_COLORS[DataModel.text_body_color]
		end
		this.Panel_Text_Only.Text_Body.Set_Tint(color[PG_R],
														color[PG_G],
														color[PG_B],
														1.0)
		
		this.Panel_Title_Text.Text_Body.Set_Tint(color[PG_R],
														color[PG_G],
														color[PG_B],
														1.0)
		
		this.Panel_Icon_Text.Text_Body.Set_Tint(color[PG_R],
														color[PG_G],
														color[PG_B],
														1.0)
														
		this.Panel_Title_Icon_Text.Text_Body.Set_Tint(color[PG_R],
														color[PG_G],
														color[PG_B],
														1.0)
		
		
		if (DataModel.text_title ~= nil) then
			this.Panel_Title_Text.Text_Title.Set_Text(DataModel.text_title)
			this.Panel_Title_Icon_Text.Text_Title.Set_Text(DataModel.text_title)
		end
		
		if (DataModel.icon_texture ~= nil) then
			this.Panel_Icon_Text.Quad_Icon.Set_Texture(DataModel.icon_texture)
			this.Panel_Title_Icon_Text.Quad_Icon.Set_Texture(DataModel.icon_texture)
		end
		
	end

	-- Adjust size
	local hfunc = ResizingFunctions[ViewState]
	hfunc()

	Update_Position()

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Resize_Text_Only()

	local text_width = this.Panel_Text_Only.Text_Body.Get_Text_Width()
	local text_height = this.Panel_Text_Only.Text_Body.Get_Text_Height()
	local txtx, txty, txtw, txth = this.Panel_Text_Only.Text_Body.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = this.Frame.Get_World_Bounds()
	
	-- Width
	local new_bgw = H_GUTTER + text_width + H_GUTTER
	
	-- Height
	local new_bgh = V_GUTTER + text_height + V_GUTTER
	
	-- Positioning.  Text boxes should only grow, never shrink.
	local new_txtx = bgx + H_GUTTER
	local new_txty = bgy + V_GUTTER
	local new_txtw = Max(text_width + H_GUTTER, txtw)
	local new_txth = Max(text_height + V_GUTTER, txth)
	
	this.Panel_Text_Only.Text_Body.Set_World_Bounds(new_txtx, new_txty, new_txtw, new_txth)
	this.Frame.Set_World_Bounds(bgx, bgy, new_bgw, new_bgh)
	 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Resize_Title_Text()

	local title_width = this.Panel_Title_Text.Text_Title.Get_Text_Width()
	local title_height = this.Panel_Title_Text.Text_Title.Get_Text_Height()
	local titlex, titley, titlew, titleh = this.Panel_Title_Text.Text_Title.Get_World_Bounds()
	local text_width = this.Panel_Title_Text.Text_Body.Get_Text_Width()
	local text_height = this.Panel_Title_Text.Text_Body.Get_Text_Height()
	local txtx, txty, txtw, txth = this.Panel_Title_Text.Text_Body.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = this.Frame.Get_World_Bounds()
	
	-- Width
	local widest = Max(text_width, title_width)
	local new_bgw = H_GUTTER + widest + H_GUTTER
	
	-- Height
	local new_bgh = V_GUTTER + title_height + V_GUTTER + text_height + V_GUTTER
	
	-- Positioning.
	local new_titlew = Max(title_width + (2 * H_GUTTER), MINIMUM_TITLE_TEXT_WIDTH)
	local new_titleh = title_height + (2 * V_GUTTER)
	local new_titlex = bgx + H_GUTTER
	local new_titley = bgy + V_GUTTER
	
	local new_txtw = Max(text_width + (2 * V_GUTTER), MINIMUM_TITLE_TEXT_WIDTH)
	local new_txth = text_height + (2 * H_GUTTER)
	local new_txtx = bgx + H_GUTTER
	local new_txty = bgy + V_GUTTER + title_height + V_GUTTER
	
	this.Panel_Title_Text.Text_Title.Set_World_Bounds(new_titlex, new_titley, new_titlew, new_titleh)
	this.Panel_Title_Text.Text_Body.Set_World_Bounds(new_txtx, new_txty, new_txtw, new_txth)
	this.Frame.Set_World_Bounds(bgx, bgy, new_bgw, new_bgh)
	 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Resize_Icon_Text()

	local quadx, quady, quadw, quadh = this.Panel_Icon_Text.Quad_Icon.Get_World_Bounds()
	local text_width = this.Panel_Icon_Text.Text_Body.Get_Text_Width()
	local text_height = this.Panel_Icon_Text.Text_Body.Get_Text_Height()
	local txtx, txty, txtw, txth = this.Panel_Icon_Text.Text_Body.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = this.Frame.Get_World_Bounds()
	
	-- Width
	local new_bgw = H_GUTTER + quadw + H_GUTTER + text_width + H_GUTTER
	
	-- Height
	local tallest = Max(quadh, text_height)
	local new_bgh = V_GUTTER + tallest + V_GUTTER
	
	-- Positioning
	local new_quadx = bgx + H_GUTTER
	local new_quady = bgy + V_GUTTER
	
	local new_txtx = bgx + H_GUTTER + quadw + H_GUTTER
	local new_txty = bgy + V_GUTTER 
	local new_txtw = Max(text_width + H_GUTTER, txtw)
	local new_txth = Max(text_height + V_GUTTER, txth)
	
	this.Panel_Icon_Text.Quad_Icon.Set_World_Bounds(new_quadx, new_quady, quadw, quadh)
	this.Panel_Icon_Text.Text_Body.Set_World_Bounds(new_txtx, new_txty, new_txtw, new_txth)
	this.Frame.Set_World_Bounds(bgx, bgy, new_bgw, new_bgh)
	 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Resize_Title_Icon_Text()

	local title_width = this.Panel_Title_Icon_Text.Text_Title.Get_Text_Width()
	local title_height = this.Panel_Title_Icon_Text.Text_Title.Get_Text_Height()
	local titlex, titley, titlew, titleh = this.Panel_Title_Icon_Text.Text_Title.Get_World_Bounds()
	local quadx, quady, quadw, quadh = this.Panel_Title_Icon_Text.Quad_Icon.Get_World_Bounds()
	local text_width = this.Panel_Title_Icon_Text.Text_Body.Get_Text_Width()
	local text_height = this.Panel_Title_Icon_Text.Text_Body.Get_Text_Height()
	local txtx, txty, txtw, txth = this.Panel_Title_Icon_Text.Text_Body.Get_World_Bounds()
	local bgx, bgy, bgw, bgh = this.Frame.Get_World_Bounds()
	
	-- Width
	local widest = Max(text_width, title_width)
	local new_bgw = H_GUTTER + widest + H_GUTTER
	
	-- Height
	local new_bgh = V_GUTTER + title_height + V_GUTTER + quadh + V_GUTTER + text_height + V_GUTTER
	
	-- Positioning.
	local new_titlew = Max(title_width + (2 * H_GUTTER), MINIMUM_TITLE_ICON_TEXT_WIDTH)
	local new_titleh = title_height + (2 * V_GUTTER)
	local new_titlex = bgx + (new_bgw / 2) - (new_titlew / 2)
	local new_titley = bgy + V_GUTTER
	
	local new_quadx = bgx + (new_bgw / 2) - (quadw / 2)
	local new_quady = bgy + V_GUTTER + title_height + V_GUTTER
	
	local new_txtw = Max(text_width + (2 * V_GUTTER), MINIMUM_TITLE_ICON_TEXT_WIDTH)
	local new_txth = text_height + (2 * H_GUTTER)
	local new_txtx = bgx + (new_bgw / 2) - (new_txtw / 2)
	local new_txty = bgy + V_GUTTER + title_height + V_GUTTER + quadh + V_GUTTER
	
	this.Panel_Title_Icon_Text.Text_Title.Set_World_Bounds(new_titlex, new_titley, new_titlew, new_titleh)
	this.Panel_Title_Icon_Text.Quad_Icon.Set_World_Bounds(new_quadx, new_quady, quadw, quadh)
	this.Panel_Title_Icon_Text.Text_Body.Set_World_Bounds(new_txtx, new_txty, new_txtw, new_txth)
	this.Frame.Set_World_Bounds(bgx, bgy, new_bgw, new_bgh)
	
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Wrapper_Handle(handle) 
	_WrapperHandle = handle
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_View_State(state) 
	ViewState = state
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
function Update_Position()

	if (_WrapperHandle == nil) then
		return
	end

	local screen_pos = Get_Cursor_Screen_Position()
	
	-- Reposition everything
	local mouse_x_pos = screen_pos[1]
	local mouse_y_pos = screen_pos[2]
	
	--local thisx, thisy, thisw, thish = this.Get_Containing_Scene().Get_World_Bounds()
	local bgx, bgy, bgw, bgh = this.Frame.Get_World_Bounds()
	local finalx = mouse_x_pos
	local finaly = mouse_y_pos
	
	if ((finalx + bgw) > 1) then
		finalx = finalx - bgw 
	end
	
	_WrapperHandle.Set_Screen_Position(finalx, finaly)
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Set_View_State = Set_View_State
Interface.Update_Position = Update_Position
Interface.Set_Wrapper_Handle = Set_Wrapper_Handle
