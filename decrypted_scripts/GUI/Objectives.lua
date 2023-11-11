-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Objectives.lua#17 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Objectives.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Evan_Pipho $
--
--            $Change: 89236 $
--
--          $DateTime: 2007/12/06 16:03:41 $
--
--          $Revision: #17 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGObjectives")
require("PGDebug")
require("PGUICommands")

-- Table of info for each objective's gui (which will include the text, checkbox, and check)
ObjectivesGUI = {}

Showing = false
ShowTime = 0.0
SHOW_DURATION = 4.0 -- How long the objectives stay visible for, before disappearing automatically

OrigMaxY = 0
OrigFrameHeight = 0

-- ---------------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	ObjectivesGUI = {}
	Showing = false
	ShowTime = 0.0
	
	Init_Objectives()

	local texts = Find_GUI_Components(Scene, "Objective")
	local checkboxes = Find_GUI_Components(Scene, "obj_box0")
	local checks = Find_GUI_Components(Scene, "obj_box_check0")

	-- Find all GUI elements.
	for index, text in pairs(texts) do
		local gui = {}
		gui.text = text
		gui.checkbox = checkboxes[index]
		gui.check = checks[index]
		table.insert(ObjectivesGUI, gui)
		
		gui.text.Set_Hidden(true)
		gui.text.Set_PreRender(true)
		gui.checkbox.Set_Hidden(true)
		gui.check.Set_Hidden(true)
		
		-- Store original bounds.
		local text_bounds = {}
		text_bounds.x, text_bounds.y, text_bounds.w, text_bounds.h = gui.text.Get_World_Bounds()
		gui.text.Set_User_Data(text_bounds)
		
		local checkbox_bounds = {}
		checkbox_bounds.x, checkbox_bounds.y, checkbox_bounds.w, checkbox_bounds.h = gui.checkbox.Get_World_Bounds()
		gui.checkbox.Set_User_Data(checkbox_bounds)
		
		local check_bounds = {}
		check_bounds.x, check_bounds.y, check_bounds.w, check_bounds.h = gui.check.Get_World_Bounds()
		gui.check.Set_User_Data(check_bounds)
	end
	
	-- ARTISTS CAN USE THIS VALUES TO TUNE HOW LONG THE CHANGE OF COLOR TAKES
	-- AND WHAT THE FLASHY AND DEFAULT COLORS SHOULD BE!!!!!
	-- -------------------------------------------------------------------------------------
	OBJECTIVES_TEXT_COLOR_FADE_DURATION = 1.0 
	START_TINT = {r = 0, g = 0, b = 0, a = 0} -- white!
	END_TINT = {r = 1, g = 1, b = 0, a = 1}	-- YELLOW!
	-- -------------------------------------------------------------------------------------
	
	DELTA_TINT = 
			{	
				r = END_TINT.r - START_TINT.r, 
				g = END_TINT.g - START_TINT.g, 
				b = END_TINT.b - START_TINT.b,
				a = END_TINT.a - START_TINT.a
			}
	
	Show()
	FlashingText = {}
	Scene.Frame.Set_Hidden(true)
end



-- ---------------------------------------------------------------------------------------------------------------------------
-- On_First_Service
-- ---------------------------------------------------------------------------------------------------------------------------
function On_First_Service()
	On_Objectives_Changed()
	if (Is_Multiplayer_Skirmish() or Is_Single_Player_Skirmish()) ~= true then
		Add_Objectives_Listener(Script, "On_Objectives_Changed")
	end
	
	Scene.Set_State("Running")
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Objectives_Table_Sort_Compare - 
-- ---------------------------------------------------------------------------------------------------------------------------
function Objectives_Table_Sort_Compare(index1, index2)
	return index1 < index2
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- On_Objectives_Changed - called when code says objectives have changed
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Objectives_Changed(adding, remove_obj_at_idx)
	local objectives = Get_Objectives()
	--MessageBox("On_Objectives_Changed...\n"..TableToString(objectives))
	
	if remove_obj_at_idx and FlashingText[remove_obj_at_idx] then
		FlashingText[remove_obj_at_idx] = nil
	end
	
	local sort_table = {}
	for index,_ in pairs(objectives) do
		table.insert(sort_table, index)
	end
	table.sort(sort_table, Objectives_Table_Sort_Compare)

	if #sort_table <= 0 then
		-- reset the flashing text list!.
		FlashingText = {}
	end

	if update_display == false then 
		return 
	end
	
	local gui_index = 1
	local y_offset = 0
	local max_y = OrigMaxY
	
	for _, index in pairs(sort_table) do
		local objective = objectives[index]
		if objective then
			
			local gui = ObjectivesGUI[gui_index]
			gui.text.Set_Text(objective.text)
			gui.text.Set_Hidden(false)
			gui.checkbox.Set_Hidden(false)
			
			if objective.checked then
				gui.check.Set_Hidden(false)
			else
				gui.check.Set_Hidden(true)
			end
			
			if adding == true and not FlashingText[gui_index] then
				gui.text.Set_Tint(START_TINT.r, START_TINT.g, START_TINT.b, START_TINT.a)
				FlashingText[gui_index] = {AnimStartTime = GetCurrentTime()}
			end
			
			-- Reposition it
			local text_bounds = gui.text.Get_User_Data()
			local checkbox_bounds = gui.checkbox.Get_User_Data()
			local check_bounds = gui.check.Get_User_Data()

			-- Use the actual size of the text after wrapping to resize the text gui element.
			-- RECAL: Text_Height is given in world bounds, therefore all other bounds must be relative to the world!!!!!
			local text_height = gui.text.Get_Text_Height()
			if text_height < text_bounds.h then
				text_height = text_bounds.h
			end
			
			-- Reposition everything
			gui.text.Set_World_Bounds(text_bounds.x, text_bounds.y + y_offset, text_bounds.w, text_height)
			gui.checkbox.Set_World_Bounds(checkbox_bounds.x, checkbox_bounds.y + y_offset, checkbox_bounds.w, checkbox_bounds.h)
			gui.check.Set_World_Bounds(check_bounds.x, check_bounds.y + y_offset, check_bounds.w, check_bounds.h)
			
			-- Whatever amount we're adding to the height of the text, everything below this point
			-- needs to shift down by that amount
			y_offset = y_offset + (text_height - text_bounds.h)
			
			max_y = text_bounds.y + y_offset + text_height
			
			-- Out of slots to place stuff in?
			gui_index = gui_index + 1
			if gui_index > table.getn(ObjectivesGUI) then
				break
			end
		end
	end

	-- Hide unused slots
	while gui_index <= table.getn(ObjectivesGUI) do
		local gui = ObjectivesGUI[gui_index]
		gui.text.Set_Hidden(true)
		gui.checkbox.Set_Hidden(true)
		gui.check.Set_Hidden(true)
	
		gui_index = gui_index + 1
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------
-- On_Update -- we need to update the 'color' animation for the recently added objective lines!.
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Update(event, source)
	if Showing then
		local curr_time = GetCurrentTime()
		local delete = {}
		for index, anim_data in pairs(FlashingText) do
			local gui = ObjectivesGUI[index]
			if anim_data.AnimStartTime + OBJECTIVES_TEXT_COLOR_FADE_DURATION > curr_time then
				local time_elapsed = (curr_time - anim_data.AnimStartTime)/OBJECTIVES_TEXT_COLOR_FADE_DURATION
				local new_rgb = 
						{
							r = START_TINT.r + (DELTA_TINT.r*time_elapsed), 
							g = START_TINT.g + (DELTA_TINT.g*time_elapsed),
							b = START_TINT.b + (DELTA_TINT.b*time_elapsed),
							a = START_TINT.a + (DELTA_TINT.a*time_elapsed)
						}
				-- keep 'disolving' the tint.				
				gui.text.Set_Tint(new_rgb.r, new_rgb.g, new_rgb.b, new_rgb.a)
			elseif not anim_data.Done then
				-- we are done!.
				gui.text.Set_Tint(END_TINT.r, END_TINT.g, END_TINT.b, END_TINT.a)
				anim_data.Done = true
			end		
		end
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- On_Update - 
-- ---------------------------------------------------------------------------------------------------------------------------
--[[ DISABLED FOR NOW  --CSB 5/16/2006
function On_Update()
	if Showing then
		local now = GetCurrentTime()
		if now - ShowTime >= SHOW_DURATION then
			Hide()
		end
	end
end
--]]


-- ---------------------------------------------------------------------------------------------------------------------------
-- Show - 
-- ---------------------------------------------------------------------------------------------------------------------------
function Show()
	if not Showing then
		Scene.Set_Hidden(false)
		Showing = true
		ShowTime = GetCurrentTime()
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------
-- Hide - 
-- ---------------------------------------------------------------------------------------------------------------------------
function Hide()
	if Showing then
		Scene.Set_Hidden(true)
		Showing = false
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------
-- Toggle - toggle whether objectives are visible
-- ---------------------------------------------------------------------------------------------------------------------------
function Toggle()
--[[ DISABLED FOR NOW - CSB 5/16/2006
	if not Showing then
		Show()
	else
		Hide()
	end
--]]
end


Interface = {}
Interface.Toggle = Toggle