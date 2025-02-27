if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[192] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/PGMO_Start_Marker.lua#13 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/PGMO_Start_Marker.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGColors")

ScriptPoolCount = 0


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Start_Marker_Init()

	-- Constants
	PGMO_MARKER_TYPE_START = "PGMO_MARKER_TYPE_START"
	
	-- Constants
	SIZE_STANDARD = Declare_Enum(1)
	SIZE_SMALL = Declare_Enum()
	
end

-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function On_Init()

	PGColors_Init()
	PGMO_Start_Marker_Init()
	
	-- Variables
	_ID = -1
	_Interactive = false
	_SeatAssignment = -1
	_Size = SIZE_STANDARD
	_VisiblePanel = this.Panel_Standard
	_SeatColor = 1
	
	_VisiblePanel.Quad_Fill.Set_Hidden(true)
	
	if Is_Xbox() or Is_Gamepad_Active() then 
		this.Register_Event_Handler("Key_Focus_Gained", this, On_Marker_Mouse_On)
		this.Register_Event_Handler("Key_Focus_Lost", this, On_Marker_Mouse_Off)
		this.Register_Event_Handler("Controller_A_Button_Up", nil, On_Marker_Clicked)
	end

end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Marker_Mouse_On() 

	if ( _Interactive ) then
		if (_SeatAssignment == -1) then
			_VisiblePanel.Quad_Fill.Set_Hidden(false)
			Play_SFX_Event("GUI_Main_Menu_Options_Mouse_Over")
		end
		
		if Is_Xbox() or Is_Gamepad_Active() then  
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(0, .5, .5, .5, 1)
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(1, .5, .5, .5, 1)
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(2, .5, .5, .5, 1)
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(3, .5, .5, .5, 1)
		end
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("PGMO_Mouse_On_Marker", this, {PGMO_MARKER_TYPE_START})
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Marker_Mouse_Off() 

	if (_Interactive and (_SeatAssignment == -1)) then
		_VisiblePanel.Quad_Fill.Set_Hidden(true)
	end

	if ( _Interactive ) then
		if (_SeatAssignment == -1) then
			_VisiblePanel.Quad_Fill.Set_Hidden(true)
		end
		
		if Is_Xbox() or Is_Gamepad_Active() then  
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(0, 1, 1, 1, 1)
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(1, 1, 1, 1, 1)
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(2, 1, 1, 1, 1)
			_VisiblePanel.Quad_Outline.Set_Vertex_Color(3, 1, 1, 1, 1)
		end
	end
	this.Get_Containing_Scene().Raise_Event_Immediate("PGMO_Mouse_Off_Marker", this, {PGMO_MARKER_TYPE_START})
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function On_Marker_Clicked()

	if (_Interactive) then
		this.Get_Containing_Scene().Raise_Event_Immediate("PGMO_Mouse_Clicked_Marker", this, {PGMO_MARKER_TYPE_START})
		Play_SFX_Event("GUI_Main_Menu_Options_Select")
	end
	
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


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Refresh_UI() 
	if (_Size == SIZE_STANDARD) then
		this.Panel_Standard.Set_Hidden(false)
		this.Panel_Small.Set_Hidden(true)
	elseif (_Size == SIZE_SMALL) then
		this.Panel_Standard.Set_Hidden(true)
		this.Panel_Small.Set_Hidden(false)
	end
end


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
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
function Set_ID(value) 
	_ID = value
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_ID() 
	return _ID 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Interactive(value) 
	_Interactive = value
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Seat_Assignment(value) 

	_SeatAssignment = value
	if (_SeatAssignment == nil) then
		_SeatAssignment = -1
	end
	
	if (_SeatAssignment == -1) then
		Set_Seat_Color(1)
		_VisiblePanel.Quad_Fill.Set_Hidden(true)
	elseif ((_SeatAssignment > 0) and (_SeatAssignment < 9)) then
		_VisiblePanel.Quad_Fill.Set_Hidden(false)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Seat_Color(color)

	if (_SeatAssignment == -1) then
		color = 1
	end
	
	_SeatColor = color

	local label = ({ [1] = "WHITE", [2] = "RED", [3] = "ORANGE", [4] = "YELLOW", [5] = "GREEN", [6] = "CYAN", [7] = "BLUE", [8] = "PURPLE", [9] = "GRAY", })[_SeatColor] 
	local triple = ({ YELLOW = { a = 1, b = 0.18, g = 0.87, r = 0.89, }, CYAN = { a = 1, b = 0.88, g = 0.85, r = 0.44, }, RED = { a = 1, b = 0.09, g = 0.09, r = 1, }, BLUE = { a = 1, b = 1, g = 0.59, r = 0.31, }, WHITE = { a = 1, b = 1, g = 1, r = 1, }, PURPLE = { a = 1, b = 0.82, g = 0.44, r = 1, }, ORANGE = { a = 1, b = 0.09, g = 0.58, r = 1, }, GREEN = { a = 1, b = 0.31, g = 1, r = 0.47, }, GRAY = { a = 1, b = 0.12, g = 0.12, r = 0.12, }, })[label]
	if (triple == nil) then
		triple = ({ a = 1, b = 1, g = 1, r = 1, })
	end

	_VisiblePanel.Quad_Fill.Set_Vertex_Color(0, triple["r"], triple["g"], triple["b"], 1)
	_VisiblePanel.Quad_Fill.Set_Vertex_Color(1, triple["r"], triple["g"], triple["b"], 1)
	_VisiblePanel.Quad_Fill.Set_Vertex_Color(2, triple["r"], triple["g"], triple["b"], 1)
	_VisiblePanel.Quad_Fill.Set_Vertex_Color(3, triple["r"], triple["g"], triple["b"], 1)

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Seat_Color()

	return _SeatColor

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Seat_Assignment() 
	return _SeatAssignment 
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Size_Standard()
	_Size = SIZE_STANDARD
	_VisiblePanel = this.Panel_Standard
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Size_Small()
	_Size = SIZE_SMALL
	_VisiblePanel = this.Panel_Small
	Refresh_UI()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Outline_Texture(texture)
	this.Panel_Standard.Quad_Outline.Set_Texture(texture)
	this.Panel_Small.Quad_Outline.Set_Texture(texture)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Fill_Texture(texture)
	this.Panel_Standard.Quad_Fill.Set_Texture(texture)
	this.Panel_Small.Quad_Fill.Set_Texture(texture)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Clear_Color()
	_VisiblePanel.Quad_Fill.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_ID = Set_ID
Interface.Get_ID = Get_ID
Interface.Set_Interactive = Set_Interactive
Interface.Set_Seat_Assignment = Set_Seat_Assignment
Interface.Get_Seat_Assignment = Get_Seat_Assignment
Interface.Set_Seat_Color = Set_Seat_Color
Interface.Get_Seat_Color = Get_Seat_Color
Interface.Clear_Color = Clear_Color
Interface.Set_Size_Standard = Set_Size_Standard
Interface.Set_Size_Small = Set_Size_Small
Interface.Set_Outline_Texture = Set_Outline_Texture
Interface.Set_Fill_Texture = Set_Fill_Texture
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
	Get_Chat_Color_Index = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Play_Alien_Steam = nil
	Play_Click = nil
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
