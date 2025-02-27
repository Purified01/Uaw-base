if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Player_List_Tooltip.lua
--
--    Original Author: Maria Teruel
--
--          Date: 2007/07/21
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

------------------------------------------------------------------------
-- Init_Tooltip
------------------------------------------------------------------------
function Init_Tooltip()
	Tooltip = this.Tooltip
	Tooltip.Set_Hidden(true)
	Tooltip.Text.Set_Word_Wrap(true)
	
	-- Since we are going to be positioning the scene after resizing its components, we have to store
	-- the original bounds of it so that we can reset them everytime we re-size & re-position the whole thing.
	local scene_bds = {}
	scene_bds.x, scene_bds.y, scene_bds.w, scene_bds.h = Tooltip.Get_World_Bounds()
	Tooltip.Set_User_Data(scene_bds)
	
	-- Store the original bounds of the text display.
	local txt_bounds = {}
	txt_bounds.x, txt_bounds.y, txt_bounds.w, txt_bounds.h = Tooltip.Text.Get_World_Bounds()
	txt_bounds.h = 5.0/768.0
	
	VerticalMargin = 20.0/768.0
	HorizontalMargin = 20.0/1024.0
	
	Tooltip.Text.Set_User_Data(txt_bounds)
	TooltipActive = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Display_Buff_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function On_Display_Buff_Tooltip(_, source, display_strg)
	if not TestValid(source) then 
		return
	end
	
	local data = source.Get_User_Data()
	if #data < 2 then -- this guy doesn't have enough data.
		return 
	end
	
	local text_id = data[2]
	if text_id then 
		Display_Tooltip(text_id)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Display_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Display_Tooltip(text_id)
	if text_id == nil then
		return
	end
	
	TooltipActive = true
	Tooltip.Set_Hidden(false)
	Tooltip.Text.Set_Text(Get_Game_Text(text_id))	
	Position_Tooltip()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Position_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Position_Tooltip()

	-- First re-set the location of the whole scene.
	local orig_bds = Tooltip.Get_User_Data()
	Tooltip.Set_World_Bounds(orig_bds.x, orig_bds.y, orig_bds.w, orig_bds.h)
	
	-- Resize the quad according to the text it contains:
	local txt_bounds = Tooltip.Text.Get_User_Data()
	
	-- Use the actual size of the text after wrapping to resize the text gui element.
	local text_height = Tooltip.Text.Get_Text_Height()
	if text_height and text_height < txt_bounds.h then
		text_height = txt_bounds.h
	end
	
	local text_width = Tooltip.Text.Get_Text_Width()
	if text_width and text_width < txt_bounds.w then
		text_width = txt_bounds.w
	end	

	Tooltip.Text.Set_World_Bounds(txt_bounds.x + (text_width/2.0), txt_bounds.y, text_width, text_height)
	
	local frame_w = text_width + HorizontalMargin
	local frame_h = text_height + VerticalMargin	
	Tooltip.Frame.Set_World_Bounds(txt_bounds.x + (text_width/2.0) - (HorizontalMargin/2.0), txt_bounds.y - (VerticalMargin/2.0), frame_w, frame_h)
	
	local screen_pos = Get_Cursor_Screen_Position()
	
	-- Reposition everything
	local mouse_x_pos = screen_pos[1]
	local mouse_y_pos = screen_pos[2]

	-- before we proceed, let's make sure the scene is going to show on the screen by placing it on the rightmost lower end of the mouse cursor.
	local x_coord = mouse_x_pos + (35.0/1024.0)
	local y_coord = mouse_y_pos + (45.0/768.0)
	
	-- Now we need to adjust the coordinates to make sure the tooltip doesn't fall off the screen!
	local right_edge = x_coord + frame_w
	local bottom_edge = y_coord + frame_h
	
	if (right_edge > 1.0) and (bottom_edge > 1.0) then
		-- We want to position the tooltip so that its lower_right corner lies
		-- at the cursor position.
		-- Let's fix the x-coordinate
		x_coord = mouse_x_pos - frame_w
		-- just take it a bit from the tip of the cursor
		x_coord = x_coord -2.0/1024.0
		
		-- Now let's fix the y-coordinate
		y_coord = mouse_y_pos - frame_h
		-- just take it a bit from the tip of the cursor
		y_coord = y_coord -2.0/768.0		
	elseif (right_edge > 1.0) then
		local delta = right_edge - 1.0
		-- make it move a bit away from the edge of the screen
		delta = delta + 2.0/1024.0
		x_coord = x_coord - delta
	elseif (bottom_edge > 1.0) then
		local delta = bottom_edge - 1.0
		-- make it move a bit away from the edge of the screen
		delta = delta + 2.0/768.0
		y_coord = y_coord - delta
	end	
	
	-- Just position the tooltip at the obtained screen location!.
	Tooltip.Set_Screen_Position(x_coord, y_coord)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_End_Buff_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function On_End_Buff_Tooltip(_, _)
	TooltipActive = false
	Tooltip.Set_Hidden(true)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Update_Tooltip()
	if TooltipActive then 
		Position_Tooltip()
	end
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Init_Tooltip = nil
	On_Display_Buff_Tooltip = nil
	On_End_Buff_Tooltip = nil
	Update_Tooltip = nil
	Kill_Unused_Global_Functions = nil
end
