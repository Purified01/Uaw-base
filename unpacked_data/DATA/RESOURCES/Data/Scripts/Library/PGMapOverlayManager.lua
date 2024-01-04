-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGMapOverlayManager.lua#31 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGMapOverlayManager.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 86742 $
--
--          $DateTime: 2007/10/25 17:52:13 $
--
--          $Revision: #31 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGMO_Tooltip")
require("PGMO_Start_Marker")
require("PGMO_Neutral_Structure_Marker")
require("GUI_Tooltip")


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- There is no BUI file associated with this system.  It can be attached to
-- any scene that needs to manage overlay information on a map that it is
-- displaying.
-------------------------------------------------------------------------------
function PGMO_Initialize()  -- JOE DELETE: , start_pos_quads, neutral_structure_quads)

	-- Requires
	PGMO_Tooltip_Init()
	PGMO_Start_Marker_Init()
	PGMO_Neutral_Structure_Marker_Init()
	
	-- Constants
	PGMO_MARKER_SIZE_STANDARD = Declare_Enum(1)
	PGMO_MARKER_SIZE_SMALL = Declare_Enum()
	
	-- Variables
	GUI_Tooltip_Constants()
	if (not TestValid(_PGMOTooltip)) then
		_PGMOTooltip = Create_Embedded_Scene("GUI_Tooltip", this, "PGMO_GUI_Tooltip")
	end
	_PGMOTooltip.Set_Wrapper_Handle(_PGMOTooltip)
	_PGMOTooltip.Set_View_State(VIEW_STATE_TEXT_ONLY)
	_PGMOTooltip.Set_Hidden(true)
	_PGMOTooltip.Bring_To_Front()
	_PGMOMarkerSize = SIZE_STANDARD
	_PGMOEnabled = false
	_PGMOInteractive = false
	_PGMONumPlayers = 0
	_PGMOStartMarkerCoords = nil
	_PGMONeutralStructureMarkerCoords = nil
	_PGMOScreenJustification = SCREEN_JUSTIFY_CENTER
	_PGMOTooltip.Set_Screen_Justification(_PGMOScreenJustification)
	if (_PGMOStartMarkerPool == nil) then
		_PGMOStartMarkerPool = {}
	end
	if (_PGMONeutralStructureMarkerPool == nil) then
		_PGMONeutralStructureMarkerPool = {}
	end
	
	_PGMO_Set_All_Visible(false)
	
	_PGMO_Refresh_UI()
	
	this.Register_Event_Handler("PGMO_Mouse_On_Marker", nil, PGMO_Mouse_On_Marker)
	this.Register_Event_Handler("PGMO_Mouse_Off_Marker", nil, PGMO_Mouse_Off_Marker)
	this.Register_Event_Handler("PGMO_Mouse_Clicked_Marker", nil, PGMO_Mouse_Clicked_Marker)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Set_Interactive(value)

	_PGMOInteractive = value
	
	for _, handle in ipairs(_PGMOStartMarkerPool) do
		handle.Set_Interactive(_PGMOInteractive)
	end
	
	for _, handle in ipairs(_PGMONeutralStructureMarkerPool) do
		handle.Set_Interactive(_PGMOInteractive)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Resize_Start_Marker_Pool(num_required)
	_PGMO_Create_Markers(num_required, _PGMOStartMarkerPool, "PGMO_Start_Marker")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Resize_Neutral_Structure_Marker_Pool(num_required)
	_PGMO_Create_Markers(num_required, _PGMONeutralStructureMarkerPool, "PGMO_Neutral_Structure_Marker")
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Set_Marker_Size(size)
	_PGMOMarkerSize = size
	_PGMO_Update_Markers(_PGMOStartMarkerPool)
	_PGMO_Update_Markers(_PGMONeutralStructureMarkerPool)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Create_Markers(num_required, pool, scene)

	local pool_size = #pool
	
	-- If we already have enough markers, do nothing.
	local enough = (pool_size >= num_required)
	if (enough) then
		return
	end

	-- Create the required markers.
	local delta = num_required - pool_size
	for i = 1, num_required do
		local id = i + pool_size
		local scene_name = scene .. tostring(id)
		local handle = Create_Embedded_Scene(scene, this, scene_name)
		handle.Set_ID(id)
		handle.Set_Screen_Justification(_PGMOScreenJustification)
		if (_PGMOMarkerSize == PGMO_MARKER_SIZE_STANDARD) then
			handle.Set_Size_Standard()
		else
			handle.Set_Size_Small()
		end
		table.insert(pool, handle)
	end
	
	_PGMOTooltip.Bring_To_Front()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Update_Markers(pool)

	for _, handle in ipairs(pool) do
		handle.Set_Screen_Justification(_PGMOScreenJustification)
		if (_PGMOMarkerSize == PGMO_MARKER_SIZE_STANDARD) then
			handle.Set_Size_Standard()
		else
			handle.Set_Size_Small()
		end
	end
	
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Refresh_UI()
	-- Currently do nothing
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Show()
	_PGMO_Position_Markers()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Hide()
	_PGMO_Set_All_Visible(false)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Set_Enabled(value)
	if (value == _PGMOEnabled) then
		return
	end
	_PGMOEnabled = value
	if (not value) then
		_PGMOTooltip.Set_Hidden(true)
		_PGMO_Set_All_Visible(false)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Get_Enabled()
	return _PGMOEnabled
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Set_All_Visible(value)

	for _, handle in ipairs(_PGMOStartMarkerPool) do
		handle.Set_Hidden(not value)
	end
	
	for _, handle in ipairs(_PGMONeutralStructureMarkerPool) do
		handle.Set_Hidden(not value)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Set_All_Start_Markers_Visible(value)

	for _, handle in ipairs(_PGMOStartMarkerPool) do
		handle.Set_Hidden(not value)
	end
	
	_PGMO_Refresh_UI()
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Set_All_Neutral_Structure_Markers_Visible(value)

	for _, handle in ipairs(_PGMONeutralStructureMarkerPool) do
		handle.Set_Hidden(not value)
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Place_Start_Marker(index, world_pos)
	_PGMOStartMarkerPool[index].Set_Hidden(false)
	_PGMOStartMarkerPool[index].Set_Screen_Position(world_pos.x, world_pos.y)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Place_Neutral_Structure_Marker(index, world_pos)
	_PGMONeutralStructureMarkerPool[index].Set_Hidden(false)
	_PGMONeutralStructureMarkerPool[index].Set_Screen_Position(world_pos.x, world_pos.y)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Enable_Neutral_Structure(index, world_pos)
	if (_PGMOEnabled) then
		_PGMONeutralStructureQuads[index].Set_Hidden(false)
		_PGMONeutralStructureQuads[index].Set_Screen_Position(world_pos.x, world_pos.y)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Disable_Neutral_Structure(index)
	if (_PGMOEnabled) then
		_PGMONeutralStructureQuads[index].Set_Hidden(true)
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Position_Markers()

	-- If no preview map has been bound yet, don't do anything.
	if (_PGMOMapPreviewQuad == nil) then
		return
	end
	

	-- Start Markers
	if ((_PGMONumPlayers >= 1) and (_PGMOStartMarkerCoords ~= nil)) then
	
		for i = 1, _PGMONumPlayers do
			local world_pos = _PGMO_Get_World_Pos(_PGMOMapPreviewQuad, _PGMOStartMarkerCoords[i])
			_PGMO_Place_Start_Marker(i, world_pos)
		end
		
	end
	
	-- Neutral Structures
	if (_PGMONeutralStructureMarkerCoords ~= nil) then
	
		for i = 1, #_PGMONeutralStructureMarkerCoords do
			local world_pos = _PGMO_Get_World_Pos(_PGMOMapPreviewQuad, _PGMONeutralStructureMarkerCoords[i])
			_PGMO_Place_Neutral_Structure_Marker(i, world_pos)
		end
		
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Set_Justification(justification)
	_PGMOScreenJustification = justification

	for _, handle in ipairs(_PGMOStartMarkerPool) do
		handle.Set_Screen_Justification(justification)
	end
	
	for _, handle in ipairs(_PGMONeutralStructureMarkerPool) do
		handle.Set_Screen_Justification(justification)
	end
	
	_PGMOTooltip.Set_Screen_Justification(justification)

	_PGMO_Position_Markers()
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Mouse_Move()
	_PGMOTooltip.Update_Position()
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Mouse_On_Marker(event_label, source, marker_type)

	local pos = {}
	pos.x, pos.y, pos.w, pos.h = source.Get_World_Bounds()
	local x_pos = pos.x + pos.w
	local y_pos = pos.y
	
	local text = Create_Wide_String("INVALID")
	if (marker_type == PGMO_MARKER_TYPE_START) then
		text = Get_Game_Text("TEXT_MULTIPLAYER_START_MARKER")
	elseif (marker_type == PGMO_MARKER_TYPE_NEUTRAL_STRUCTURE) then
		text = Get_Game_Text("TEXT_MULTIPLAYER_CAPTURABLE_STRUCTURE")
	end
	
	local model = {}
	model.text_body = text
	_PGMOTooltip.Set_Model(model)
	_PGMOTooltip.Set_Hidden(false)
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Mouse_Off_Marker(event_label, source, marker_type)
	_PGMOTooltip.Set_Hidden(true)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Mouse_Clicked_Marker(event_label, source, marker_type)
	if (_PGMOInteractive) then
		if (PGMO_On_Start_Marker_Clicked ~= nil) then
			PGMO_On_Start_Marker_Clicked(source)
		end
	end
end


-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Clear()
	_PGMONumPlayers = 0
	_PGMOStartMarkerCoords = nil
	_PGMONeutralStructureCoords = nil
	_PGMOTooltip.Set_Hidden(true)
	_PGMO_Set_All_Start_Markers_Visible(false)
	for _, handle in ipairs(_PGMOStartMarkerPool) do
		handle.Set_Seat_Assignment(-1)
		handle.Set_Seat_Color()
	end
end

-------------------------------------------------------------------------------
-- Binds the overlay to a specific map preview quad, including the 
-- proper positioning of the markers on it.
-------------------------------------------------------------------------------
function PGMO_Bind_To_Quad(map_preview_quad)

	if (map_preview_quad ~= nil) then
		_PGMOMapPreviewQuad = map_preview_quad
	end
	
	_PGMO_Position_Markers()
	
end
	
-------------------------------------------------------------------------------
-- Sets up the start marker data model underlying the map overlay.
-------------------------------------------------------------------------------
function PGMO_Set_Start_Marker_Model(num_players, position_coords)

	_PGMONumPlayers = num_players
	_PGMOStartMarkerCoords = position_coords
	
	if (_PGMOStartMarkerCoords == nil) then
		return
	end

	-- Do some validation
	local errors = {}
	if (_PGMOStartMarkerCoords == nil) then
		table.insert(errors, "Map Error:  No start marker positions found.")
		return false, errors
	end
	
	local num_coords = 0
	for _, pos in pairs(_PGMOStartMarkerCoords) do
		num_coords = num_coords + 1
	end
	if (_PGMONumPlayers ~= num_coords) then
		table.insert(errors, "Map Error:  Map player count does not match the number of start markers found.")
		return false, errors
	end
	
	-- Make sure we have enough markers in the pool.
	_PGMO_Resize_Start_Marker_Pool(num_coords)

	-- We're good
	_PGMO_Set_All_Start_Markers_Visible(false)
	_PGMOSeatAssignments = {}
	--_PGMO_Set_Default_Textures()
	
	_PGMO_Position_Markers()
	
	--_PGMO_Refresh_UI()
	--[[for id, quad in ipairs(_PGMOStartPosQuads) do
	
		local seat = PGMO_Get_Seat_Assignment(id)
		if (seat ~= nil) then
			quad.Set_Texture(_PGMO_SEAT_TEXTURES[seat])
		end

	end--]]
	
	return true

end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Set_Neutral_Structure_Marker_Model(position_coords)

	_PGMONeutralStructureMarkerCoords = position_coords
	
	if (_PGMONeutralStructureMarkerCoords == nil) then
		return
	end

	-- Do some checking
	local errors = {}
	if (position_coords == nil) then
		table.insert(errors, "Map Error:  No neutral structure positions found.")
		return false, errors
	end
	
	local num_coords = 0
	for _, pos in pairs(position_coords) do
		num_coords = num_coords + 1
	end
	
	-- Make sure we have enough markers in the pool
	_PGMO_Resize_Neutral_Structure_Marker_Pool(num_coords)
	

	-- We're good
	_PGMO_Set_All_Neutral_Structure_Markers_Visible(false)
	
	_PGMO_Position_Markers()
	
	return true
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Assign_Start_Position(start_marker_id, seat, color)

	if ((not _PGMOEnabled) or (not _PGMOInteractive)) then
		return
	end

	-- First clear this seat from the assignments (each seat can only claim one start position).
	_PGMO_Clear_Seat(seat)
	local handle = _PGMOStartMarkerPool[start_marker_id]
	handle.Set_Seat_Assignment(seat)
	handle.Set_Seat_Color(color)
	
end
 
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Save_Start_Position_Assignments(user_data)

	_PGMOSavedStartPosUserData = user_data
	_PGMOSavedStartPositionAssignments = {}

	for index, handle in ipairs(_PGMOStartMarkerPool) do
		local dao = {}
		dao.seat = handle.Get_Seat_Assignment()
		dao.color = handle.Get_Seat_Color()
		dao.hidden = handle.Get_Hidden()
		_PGMOSavedStartPositionAssignments[index] =  dao
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Get_Saved_Start_Pos_User_Data()
	return _PGMOSavedStartPosUserData
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Restore_Start_Position_Assignments()

	for index, handle in ipairs(_PGMOStartMarkerPool) do
		local dao = _PGMOSavedStartPositionAssignments[index]
		handle.Set_Seat_Assignment(dao.seat)
		handle.Set_Seat_Color(dao.color)
		handle.Set_Hidden(dao.hidden)
	end
	
end

-------------------------------------------------------------------------------
-- Currently unused.  May be useful in the future but for now
-- DefaultLandScript handles random position assignment.
-------------------------------------------------------------------------------
function PGMO_Assign_Random_Start_Position(seat)

	-- First clear this seat from the assignments (each seat can only claim one start position).
	_PGMO_Clear_Seat(seat)
	
	for _, handle in ipairs(_PGMOStartMarkerPool) do
		if (handle.Get_Seat_Assignment() == -1) then
			handle.Set_Seat_Assignment(seat)
			handle.Set_Seat_Color()
			break
		end
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Get_Assignment_Count()
	
	local count = 0
	
	for i = 1, _PGMONumPlayers do
		local handle = _PGMOStartMarkerPool[i]
		local seat = handle.Get_Seat_Assignment()
		if (handle.Get_Seat_Assignment() ~= -1) then
			count = count + 1
		end
	end
	
	return count
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Clear_Start_Positions() 
	for id, handle in ipairs(_PGMOStartMarkerPool) do
		PGMO_Clear_Start_Position(id) 
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Clear_Start_Position(start_marker_id) 
	local handle = _PGMOStartMarkerPool[start_marker_id]
	handle.Set_Seat_Assignment(-1)
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Clear_Start_Position_By_Seat(seat) 
	_PGMO_Clear_Seat(seat)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Get_Seat_Assignment(id)
	return (_PGMOStartMarkerPool[id].Get_Seat_Assignment())
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Is_Seat_Assigned(seat)

	for i = 1, _PGMONumPlayers do
		local handle = _PGMOStartMarkerPool[i]
		if (handle.Get_Seat_Assignment() == seat) then
			return true
		end
	end
	
	return false
	 
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Get_Start_Marker_ID(source)
	return source.Get_ID()
end
   
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Get_Start_Marker_ID_From_Seat(seat)

	for i = 1, _PGMONumPlayers do
		local handle = _PGMOStartMarkerPool[i]
		if (handle.Get_Seat_Assignment() == seat) then
			return handle.Get_ID()
		end	
	end
	
	return nil
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Get_World_Pos(map_preview_quad, coords)

	local prev = {}
	prev.x, prev.y, prev.w, prev.h = map_preview_quad.Get_World_Bounds()
	
	local relative_x = coords.x * prev.w
	local relative_y = coords.y * prev.h
	
	local world_coords = {}
	world_coords.x = prev.x + relative_x
	world_coords.y = (prev.y + prev.h) - relative_y		-- Y starts from the bottom.
	
	return world_coords

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PGMO_Clear_Seat(seat)

	for i = 1, _PGMONumPlayers do
		local handle = _PGMOStartMarkerPool[i]
		local id = handle.Get_ID()
		local curr_seat = handle.Get_Seat_Assignment()
		if (seat == curr_seat) then
			PGMO_Clear_Start_Position(id)
		end
	end
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PGMO_Set_Seat_Color(seat, color)

	for i = 1, _PGMONumPlayers do
		local handle = _PGMOStartMarkerPool[i]
		local id = handle.Get_ID()
		local curr_seat = handle.Get_Seat_Assignment()
		if (seat == curr_seat) then
			handle.Set_Seat_Color(color)
		end
	end
	
end
