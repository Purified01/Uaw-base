if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[120] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[163] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Tooltip_Scene.lua 
--
--   	   Author: Maria Teruel
--
--          DateTime: 2006/10/30
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("KeyboardGameCommands")

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	if this == nil then return end
	
	Initialize_Tooltip_Types()
	Initialize_Floating_Tooltip()
	
	ExpandedTooltip = this.ExpandedTooltip
	ExpandedTooltip.Close()

	-- Keep track of the tooltip's latest display object.
	GameObjectID = nil
	UITextID = nil
	CurrentType = nil
	CurrentTooltipInfo = nil
	IsAltAbility = false
	TooltipDirty = false
	IsLetterBoxMode = false
	PIPMoviePlaying = false
	CurrentGameCommand = nil	
	
	-- Mousing over an object for more than a specified amount of time displays the object's 
	-- expanded tooltip.
	TooltipActivationTime = nil
	ExpandedTooltipActivationDelay = 0.5
	SortToFront = false
	
	-- Tooltips that belong to objects should not display the expanded tooltip of they don't belong to the
	-- local player
	TooltipOwner = nil
	DisplayResources = true
	IsCapturableObject = false
	
	VerticalMargin = 10.0/768.0
	HorizontalMargin = 10.0/1024.0
	
	-- needed since the walker HP config. menu gets sorted on top of the Tactical command bar.
	this.Register_Event_Handler("Sort_Scene_To_Front", nil, On_Sort_Scene_To_Front)
	
	POP_CAP_CATEGORY_NONE = Declare_Enum(-1)
	POP_CAP_CATEGORY_WALKER = Declare_Enum(0)
	
	TooltipReadyDelay = -1
	ExpandedTooltipReadyDelay = -1
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Floating_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Floating_Tooltip()
	
	-- We are going to be re-positioning the floating tooltip based on the mouse position so we need to know
	-- the parent scene's size.
	FloatingTooltip = this.FloatingTooltip
	FloatingTooltip.Set_Hidden(true)
	-- Un-wrapping text as per bug #1388
	FloatingTooltip.Text.Set_Word_Wrap(false)
	SceneWidth = this.Get_Width()
	SceneHeight = this.Get_Height()
	
	-- Store the original bounds of the text display.
	txt_bounds = {}
	txt_bounds.x, txt_bounds.y, txt_bounds.w, txt_bounds.h = FloatingTooltip.Text.Get_Bounds()
	-- make the minimum height to 1 line
	txt_bounds.h = 1.0/128.0
	
	FloatingTooltip.Text.Set_User_Data(txt_bounds)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Tooltip_Types
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Tooltip_Types()
	TooltipTypeToTooltipMethodMap = {}
	TooltipTypeToTooltipMethodMap['object'] = Make_Tooltip_For_Object
	TooltipTypeToTooltipMethodMap['type'] = Make_Tooltip_For_Type
	TooltipTypeToTooltipMethodMap['ability'] = Make_Tooltip_For_Ability
	TooltipTypeToTooltipMethodMap['ui'] = Make_Tooltip_For_UI
	TooltipTypeToTooltipMethodMap['custom'] = Make_Tooltip
	TooltipTypeToTooltipMethodMap['patch_queue'] = Make_Tooltip_For_Patch_Queue
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Sort_Scene_To_Front 
-- ------------------------------------------------------------------------------------------------------------------
function On_Sort_Scene_To_Front(event, source, true_false)
	if true_false == nil then return end
	this.Set_Sort_To_Front(true_false)
	SortToFront = true_false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Tooltip 
-- ------------------------------------------------------------------------------------------------------------------
function Display_Tooltip(tooltip_data)
	if tooltip_data == nil then 
		return
	end
	
	-- NOTE: tooltip_data[1] = tooltip type (object, type, UI)
	--	     tooltip_data[2] = data (object, type, ui elt. text_id)
	if tooltip_data[1] == nil or tooltip_data[2] == nil then 
		return
	end
	
	if IsLetterBoxMode then
		return
	end
	
	--If this is a brand new tooltip (indicated by a hidden floating tooltip)
	--then we must hide the expanded tooltip so that it's not showing old info.
	if this.Get_Hidden() or FloatingTooltip.Get_Hidden() then
		this.ExpandedTooltip.Hide_Display(true)
	end	
	
	if TooltipTypeToTooltipMethodMap[tooltip_data[1]] ~= nil then 
		TooltipTypeToTooltipMethodMap[tooltip_data[1]](tooltip_data[2])
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Make_Tooltip_For_Patch_Queue
-- We have to make a special tooltip for these guys because the floating and expanded tooltip
-- may need to display totaly unrelated information!. 
-- ------------------------------------------------------------------------------------------------------------------
function Make_Tooltip_For_Patch_Queue(tooltip_data)
	-- tooltip_data[1] = floating tooltip data
	-- tooltip_data[2] = expanded tooltip data
	-- the expanded tooltip must show different data
	Make_Tooltip_For_UI(tooltip_data[1], tooltip_data[2])
end

-- ------------------------------------------------------------------------------------------------------------------
-- Make_Tooltip_For_Type - called when the mouse is over a build button in the tactical command bar.
-- Thus the button raises the event passing its associated build type as a parameter.
-- ------------------------------------------------------------------------------------------------------------------
function Make_Tooltip_For_Type(type_data)

	-- type_data = object_type, cost, build_time, warm_up_time, cooldown_time
	local object_type = type_data[1]
	local cost = -1.0
	local build_time = -1.0 
	local build_rate = -1.0
	local warm_up_time = -1.0
	local cooldown_time = -1.0
	local life_build_cap = -1.0
	local life_build_count = 0.0
	local curr_build_cap = -1.0
	local curr_build_count = 0.0
	local pop_cap_category = POP_CAP_CATEGORY_NONE
	local additional_lock_info = false
	local data_size = #type_data
	if data_size >=2 then cost = type_data[2] end
	if data_size >= 3 then build_time = type_data[3] end
	if data_size >= 4 then build_rate = type_data[4] end
	if data_size >= 5 then warm_up_time = type_data[5] end
	if data_size >= 6 then cooldown_time = type_data[6] end
	if data_size >= 7 then life_build_cap = type_data[7] end
	if data_size >= 8 then life_build_count = type_data[8] end	
	if data_size >= 9 then curr_build_cap = type_data[9] end
	if data_size >= 10 then curr_build_count = type_data[10] end
	if data_size >= 11 then pop_cap_category = type_data[11] end
	if data_size >= 12 then additional_lock_info = type_data[12] end
	
	-- NOTE: warm_up_time and cooldown_time are used for superweapons, patches and others.
	if object_type == nil then 
		return
	end
	
	if object_type.Has_Behavior(39) then
		object_type = object_type.Get_Tactical_Buildable_Constructed_Type()
		if object_type == nil then 
			return
		end
	end
	
	End_Tooltip()
	local w_desc = Get_Game_Text('TEXT_UI_TACTICAL_BUILD_BUTTON')
	local w_append = object_type.Get_Display_Name()
	if w_append.empty() == true then
		w_append = Create_Wide_String("")
	end
		
	if Replace_Token(w_desc, w_append, 1) == nil then 
		w_desc.append(w_append)
	end
	
	local build_cap_reached = (life_build_cap and life_build_count and (life_build_cap == life_build_count))
	build_cap_reached = build_cap_reached or (curr_build_cap and curr_build_count and (curr_build_cap == curr_build_count))
	
	if build_cap_reached then
		w_desc.append(Create_Wide_String("\n"))
		if pop_cap_category == POP_CAP_CATEGORY_WALKER then
			w_desc.append(Get_Game_Text("TEXT_ID_TOOLTIP_WALKER_BUILD_CAP_REACHED"))
		else
			w_desc.append(Get_Game_Text("TEXT_ID_TOOLTIP_BUILD_CAP_REACHED"))
		end	
	end
	
	-- Tooltip data: tooltip mode, type, cost, build time, warm up time, cooldown time.
	CurrentTooltipInfo = { 'type', {object_type, cost, build_time, build_rate, warm_up_time, cooldown_time, life_build_cap, life_build_count, curr_build_cap, curr_build_count, pop_cap_category, additional_lock_info}}	
	
	CurrentType = object_type
	
	Make_Tooltip(w_desc)
	TooltipActivationTime = GetCurrentTime()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Make_Tooltip_For_Ability - Called when the mouse is over an ability button
-- ------------------------------------------------------------------------------------------------------------------
function Make_Tooltip_For_Ability(tooltip_data)
	-- tooltip_data[1] = object associated to this ability
	-- tooltip_data[2] = ability name (needed to obtain the ability name CRC)
	-- tooltip_data[3] = ability text id
	-- tooltip_data[4] = ability desc text id
	-- tooltip_data[5] = ability category text id
	-- tooltip_data[6] = cooldown time remaining
	-- tooltip_data[7] = game command assigned to this ability (for hotkey activation)
	-- tooltip_data[8] = if applicable (eg cylinder) list of types to spawn
	if tooltip_data == nil then return end	
	local name_string = Create_Wide_String("")
	if TestValid(tooltip_data[1]) then
		name_string.append(tooltip_data[1].Get_Type().Get_Display_Name())
		name_string.append(Create_Wide_String("\n"))
	end
	
	name_string.append(Get_Game_Text(tooltip_data[3]))
	local display_string = Create_Wide_String("")
	display_string.append(name_string)
	if tooltip_data[7] then
		key_map_text = Create_Wide_String(" [ ")
		key_map_text.append(tooltip_data[7])
		key_map_text.append(Create_Wide_String(" ]"))
		display_string.append(key_map_text)
	end	
	
	CurrentTooltipInfo = {'ability', {name_string, tooltip_data[1], tooltip_data[2], tooltip_data[4], tooltip_data[5], tooltip_data[8]}}
	if tooltip_data[6] and tooltip_data[6] > 0 then
		display_string.append(Create_Wide_String("\n"))
		local time_string = Get_Localized_Formatted_Number.Get_Time(tooltip_data[6])
		display_string.append(Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), time_string, 0))
	end
	CurrentGameCommand = tooltip_data[7]
	ModeOverride = nil
	
	Make_Tooltip(display_string)
	TooltipActivationTime = GetCurrentTime()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Make_Tooltip_For_UI - called when the mouse is over a queue button in the tactical command bar.
-- The parameter corresponds to the TEXT ID assigned to the queue button the mouse is over.
-- ------------------------------------------------------------------------------------------------------------------
function Make_Tooltip_For_UI(tooltip_data, expanded_tooltip_override)
	--tooltip_data[1] = ui_text_id
	--tooltip_data[2] = game_command
	--tooltip_data[3] = description text id (some ui elements will have an expanded tooltip and this is what will be used to populate it)
	local ui_text_id = tooltip_data[1]
	
	if ui_text_id == nil then 
		CurrentGameCommand = nil
		return
	end
	
	if ui_text_id ~= UITextID then 
		End_Tooltip()
		UITextID = ui_text_id
		local text = Get_Game_Text(ui_text_id)
		local display_strg = Create_Wide_String("")
		display_strg.append(text)
		-- If this tooltip displays a hotkey mapping, add it now.
		if #tooltip_data >= 2 and tooltip_data[2] then
			key_map_text = Create_Wide_String(" [ ")
			key_map_text.append(tooltip_data[2])
			key_map_text.append(Create_Wide_String(" ]"))
			display_strg.append(key_map_text)
		end

		if #tooltip_data >= 3 and tooltip_data[3] then
			CurrentTooltipInfo = { 'ui', {text, tooltip_data[3]}}	
			TooltipActivationTime = GetCurrentTime()			
		end
		
		HideFloatyTooltipOnExpandedTooltipDisplay = false
		if #tooltip_data >= 4 then
			HideFloatyTooltipOnExpandedTooltipDisplay = tooltip_data[4]			
		end
		
		if expanded_tooltip_override then
			CurrentTooltipInfo = expanded_tooltip_override
		end
		
		Make_Tooltip(display_strg)	
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Tooltip_Dirty - Called when the mouse is over a game object in tactical mode.
-- ------------------------------------------------------------------------------------------------------------------
function On_Tooltip_Dirty(object)
	if TestValid(object) and (object.Get_ID() == GameObjectID) then
		TooltipDirty = true
		if CurrentTooltipInfo then
			Make_Tooltip_For_Object({object, CurrentTooltipInfo[3], CurrentTooltipInfo[4], CurrentTooltipInfo[5]})
		else
			Make_Tooltip_For_Object({object})
		end		
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Make_Tooltip_For_Object - Called when the mouse is over a game object in tactical mode.
-- ------------------------------------------------------------------------------------------------------------------
function Make_Tooltip_For_Object(tooltip_data)

	-- tooltip_data[1] = object
	--tooltip_data[2] = game_command
	--tooltip_data[3] = mode override?
	--tooltip_data[4] = extra text
	object = tooltip_data[1]
	if not TestValid(object) then return end
	local build_list = {}
	
	local display_text = true
	if (object.Get_ID() ~= GameObjectID) or TooltipDirty then
	
		if (object.Get_ID() ~= GameObjectID) then
			local old_object = nil
			if GameObjectID ~= nil then 
				old_object = Get_Object_From_ID(GameObjectID)
			end
			
			if TestValid(old_object) then 
				old_object.Unregister_Signal_Handler(On_Tooltip_Dirty, this)
			end
		end
		
		local is_valid_resource = false
		if object.Has_Behavior(143) then 
			local player = Find_Player("local")
			if player and object.Get_Type().Resource_Is_Valid_For_Faction(player) then 
				
				--Oksana: no tooltip for objetcs that are supposed to be resources but are all drained out
				if object.Resource_Get_Resource_Units() <= 0 then
					return
				end			
				is_valid_resource = true
			end
		end
		
		-- if this object has a text id we must show its tooltip.
		if object.Requires_Tooltip_Display() == false then 
			if not is_valid_resource then 
				return
			end
			
			-- for resource objects with no text id we only show their resource value.
			display_text = false
		end
		
		local update_activation_time = true
		if TooltipDirty then 
			if TooltipActivationTime == nil then 
				-- the expanded tooltip is already displaying so we have to update it!.
				TooltipActivationTime  = GetCurrentTime() - ExpandedTooltipActivationDelay
			end		
			update_activation_time = false
		end
		
		-- Only turn on the tooltip if the object can be seen in the FOW
		if TestValid(object) and Is_Fogged( Find_Player("local"), object ) == false then
			if not TooltipDirty then 
				End_Tooltip()
			
				if #tooltip_data >= 2 then
					CurrentGameCommand = tooltip_data[2]
				end
				
				if #tooltip_data >=3 then 
					ModeOverride = tooltip_data[3]
				end				
			end
			
			local obj_type = object.Get_Type()
			if object.Has_Behavior(22) then 
				obj_type = object.Get_Original_Object_Type()
			end
			
			local tooltip_text_data_map
			local object_text = Create_Wide_String("")
			if display_text == true then 
				tooltip_text_data_map = object.Get_Object_Tooltip_Display_Text()
				object_text.append(tooltip_text_data_map.DisplayName)
				-- If this tooltip displays a hotkey mapping, add it now.
				if CurrentGameCommand then
					key_map_text = Create_Wide_String(" [ ")
					key_map_text.append(CurrentGameCommand)
					key_map_text.append(Create_Wide_String(" ]"))
					object_text.append(key_map_text)
				end				
			end
			
			-- only store this information if the object requires the display of an expanded tooltip.
			-- those objects are the only ones that have TooltipBehaviorType, so let's check for that.
			if obj_type.Requires_Expanded_Tooltip_Display() == true then 
				local display_name
				local desc_txt
				local hp_type
				if not tooltip_text_data_map then
					tooltip_text_data_map = object.Get_Object_Tooltip_Display_Text()				
				end
				
				-- NOTE: if we don't have this data, we set it to false so that the size of the table is always the same!
				-- Otherwise, we cannot know which values we are passing when they actually exist.
				if not tooltip_text_data_map.AttachedHPType then
					tooltip_text_data_map.AttachedHPType = false
				end
				if not tooltip_text_data_map.ParentObject then
					tooltip_text_data_map.ParentObject = false
				end
				CurrentTooltipInfo = { 'object',  {object, tooltip_text_data_map.DisplayName, tooltip_text_data_map.DescriptionText, build_list, tooltip_text_data_map.AttachedHPType, tooltip_text_data_map.ParentObject}}				
				
				--Save off the extra data so that we can rebuild the tooltip exactly in response to On_Tooltip_Dirty.
				--These entries in CurrentTooltipInfo are not used by the expanded tooltip
				CurrentTooltipInfo[3] = tooltip_data[2]
				CurrentTooltipInfo[4] = tooltip_data[3]
				CurrentTooltipInfo[5] = tooltip_data[4]
			else
				CurrentTooltipInfo = { 'object', false, tooltip_data[2], tooltip_data[3], tooltip_data[4]}				
			end
			
			local extra_text = tooltip_data[4]
			if extra_text then
				object_text.append(Create_Wide_String("\n"))
				object_text.append(extra_text)
			end
			
			local debug_text = object.Get_Debug_Tooltip_Text()
			if debug_text.empty() == false then 
				object_text.append(object.Get_Debug_Tooltip_Text())
			end
			
			GameObjectID = object.Get_ID()
			object.Register_Signal_Handler(On_Tooltip_Dirty, "OBJECT_TOOLTIP_DIRTY", this)
			
			Make_Tooltip(object_text, object, is_valid_resource)
			TooltipOwner = object.Get_Owner()
			IsCapturableObject = (object.Get_Attribute_Value( "Can_Be_Captured" ) ~= 0)
			if update_activation_time then 
				TooltipActivationTime = GetCurrentTime()
			end
		else
			End_Tooltip()
		end
		TooltipDirty = false
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Make_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Make_Tooltip(w_string_display, object, is_valid_resource)
	if w_string_display == nil then 
		return
	end
	
	this.Enable(true)
	
	local append_w_string = Create_Wide_String("")
	if TestValid(object) then

		local resources = 0
		if object.Has_Behavior(143) == true then
			resources = object.Resource_Get_Resource_Units()
		end
		if resources > 0 then
			if is_valid_resource and DisplayResources then
				append_w_string.append(Get_Game_Text("TEXT_HEADER_RESOURCES"))
				append_w_string.append(Get_Localized_Formatted_Number(Dirty_Floor(resources)))
			end
		elseif object.Get_Tooltip_Requires_Health_Display() then
			-- for building beacons we don't want to show the health so that we don't mislead the user. (recall: 
			-- beacons have a health of 1 so that they are killed automatically, therefore there's no need to
			-- track their healths.
			local object_health = object.Get_Health()
			if object_health > 0 then
				local health_string = Get_Game_Text("TEXT_HEADER_HEALTH")
				Replace_Token(health_string, Get_Localized_Formatted_Number(Dirty_Floor(object_health * 100.0)), 0)
				append_w_string.append(health_string)
			end
			
			--Show current DMA level if any.
			local current_dma_level = object.Get_Attribute_Value("Current_DMA_Level")
			local max_dma_level = object.Get_Attribute_Value("DMA_Max")
			if max_dma_level and current_dma_level and max_dma_level > 0 and current_dma_level > 0 then
				dma_percent = current_dma_level / max_dma_level
				local dma_string = Get_Game_Text("TEXT_HEADER_DMA")
				Replace_Token(dma_string, Get_Localized_Formatted_Number(Dirty_Floor(dma_percent * 100.0)), 0)
				if not append_w_string.empty() then
					append_w_string.append(Create_Wide_String("\n"))
				end
				append_w_string.append(dma_string)
			end
		end
	end
	
	if w_string_display.empty() == false and append_w_string.empty() == false then	
		w_string_display.append(Create_Wide_String("\n"))
	end
	
	if Replace_Token(w_string_display, append_w_string, 1) ~= true then 
		w_string_display.append(append_w_string)
	end
	
	-- MLL: Don't display tooltip if no string to show.
	if w_string_display.empty() then
		End_Tooltip()
		return
	end
	
	-- Let us make the text object change its width based on its contents.
	FloatingTooltip.Text.Set_Text(w_string_display)	
	
	if TooltipDirty then
		TooltipReadyDelay = 0
	else
		--Have to delay the actual display of the tooltip by a frame to make
		--sure that the text is ready to report its size properly	
		TooltipReadyDelay = 1
	end
	ExpandedTooltipReadyDelay = -1	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Position_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Position_Scene()

	if FloatingTooltip.Get_Hidden() then
		return
	end

	-- Resize the quad according to the text it contains:
	local txt_bounds = FloatingTooltip.Text.Get_User_Data()
	
	-- Use the actual size of the text after wrapping to resize the text gui element.
	local text_height = FloatingTooltip.Text.Get_Text_Height() / SceneHeight
	if text_height and text_height < txt_bounds.h then
		text_height = txt_bounds.h
	end
	
	local text_width = FloatingTooltip.Text.Get_Text_Width() / SceneWidth
	if text_width and text_width < txt_bounds.w then
		text_width = txt_bounds.w
	end	

	FloatingTooltip.Text.Set_Bounds(txt_bounds.x + HorizontalMargin, txt_bounds.y + VerticalMargin, text_width, text_height)
	local frame_width = text_width + (10.0*HorizontalMargin)
	local frame_height = text_height + (6.0*VerticalMargin)
	FloatingTooltip.BackQuad.Set_Bounds(txt_bounds.x - (4.0*HorizontalMargin), txt_bounds.y - (2.0*VerticalMargin), frame_width, frame_height)
	
	local screen_pos = Get_Cursor_Screen_Position()
	
	-- Reposition everything
	local mouse_x_pos = screen_pos[1]
	local mouse_y_pos = screen_pos[2]

	local mouse_size_x = 40.0/1024.0
	local mouse_size_y = 30.0/768.0
	
	if Is_Player_Of_Faction( Find_Player("local"), "ALIEN") then 
		-- the alien frame has bigger margins for it is not oblong, so we must make up for it with the size of the mouse
		-- to make sure the tooltip is closer to it like in the other factions.
		mouse_size_x = 20.0/1024.0
		mouse_size_y = 20.0/768.0		
	end
	
	-- before we proceed, let's make sure the scene is going to show on the screen by placing it on the rightmost lower end of the mouse cursor.
	local x_coord = mouse_x_pos + mouse_size_x
	local y_coord = mouse_y_pos + mouse_size_y
	
	-- Now we need to adjust the coordinates to make sure the tooltip doesn't fall off the screen!
	local right_edge = x_coord + frame_width * SceneWidth
	local bottom_edge = y_coord + frame_height * SceneHeight
	
	if (right_edge > 1.0) and (bottom_edge > 1.0) then
		-- We want to position the tooltip so that its lower_right corner lies
		-- at the cursor position.
		-- Let's fix the x-coordinate
		x_coord = mouse_x_pos - frame_width * SceneWidth
		-- just take it a bit from the tip of the cursor
		x_coord = x_coord -2.0/1024.0
		
		-- Now let's fix the y-coordinate
		y_coord = mouse_y_pos - frame_height * SceneHeight
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
	FloatingTooltip.Set_Screen_Position(x_coord, y_coord)
end


-- ------------------------------------------------------------------------------------------------------------------
-- End_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function End_Tooltip()

	if this.Get_Hidden() then
		return
	end
	
	if GameObjectID ~= nil then 
		
		local object = Get_Object_From_ID(GameObjectID)
		if TestValid(object) then 
			object.Unregister_Signal_Handler(On_Tooltip_Dirty, this)
		end
	end
	
	GameObjectID = nil
	UITextID = nil
	CurrentType = nil
	CurrentTooltipInfo = nil
	
	FloatingTooltip.Set_Hidden(true)
	TooltipActivationTime = nil
	ExpandedTooltip.Close()
	
	this.Enable(false)	
	
	TooltipDirty = false
	TooltipOwner = nil
	CurrentGameCommand = nil
	
	TooltipReadyDelay = -1
	ExpandedTooltipReadyDelay = -1
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()

	if IsLetterBoxMode then
		return
	end
	
	if GameObjectID ~= nil then 
		local object = Get_Object_From_ID(GameObjectID)
		if object == nil then 
			End_Tooltip()
			return
		elseif Is_Fogged( Find_Player("local"), object ) then
			End_Tooltip()
			return
		end				
	end
	
	--Have to delay the actual display of the tooltip by a frame to make
	--sure that the text is ready to report its size properly
	if TooltipReadyDelay == 0 then
		FloatingTooltip.Set_Hidden(false)
		TooltipReadyDelay = -1
	elseif TooltipReadyDelay > 0 then
		TooltipReadyDelay = TooltipReadyDelay - 1
	end
	
	Position_Scene()
	
	if CurrentTooltipInfo ~= nil and CurrentTooltipInfo[2] and (UITextID or GameObjectID == nil or TooltipOwner == Find_Player("local") or IsCapturableObject) then 
		-- if applicable, open the expanded tooltip display
		Display_Expanded_Tooltip()		
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Display_Expanded_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Display_Expanded_Tooltip()
	
	if PIPMoviePlaying then return end
	
	if ExpandedTooltipReadyDelay == 0 then
		ExpandedTooltip.Finalize_Display()
		ExpandedTooltipReadyDelay = -1
	elseif ExpandedTooltipReadyDelay > 0 then
		ExpandedTooltipReadyDelay = ExpandedTooltipReadyDelay - 1
	elseif TooltipActivationTime == nil then
		return
	elseif TooltipActivationTime + ExpandedTooltipActivationDelay <= GetCurrentTime() then 	
		if CurrentTooltipInfo ~= nil then 
			ExpandedTooltip.Prepare_Display(SortToFront, CurrentTooltipInfo)
			if HideFloatyTooltipOnExpandedTooltipDisplay then
				FloatingTooltip.Set_Hidden(true)
			end
			-- reset the activation time
			TooltipActivationTime = nil
			-- reset all other flags
			HideFloatyTooltipOnExpandedTooltipDisplay = false
			
			ExpandedTooltipReadyDelay = 1
		end
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_Open
-- ------------------------------------------------------------------------------------------------------------------
function Is_Open()
	return not FloatingTooltip.Get_Hidden()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Letterbox_Mode
-- ------------------------------------------------------------------------------------------------------------------
function Set_Letterbox_Mode(on_off)
	IsLetterBoxMode = on_off
	if IsLetterBoxMode then	
		End_Tooltip()
		this.ExpandedTooltip.Hide_Display(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Resources
-- ------------------------------------------------------------------------------------------------------------------
function Update_Resources()

	if not GameObjectID then 
		return false
	end

	object = Get_Object_From_ID(GameObjectID)
	if object.Has_Behavior(143) then 
		local player = Find_Player("local")
		if player and object.Get_Type().Resource_Is_Valid_For_Faction(player) and object.Resource_Get_Resource_Units() > 0 then 
			return true, object
		end
	end
	
	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Display_Tooltip_Resources
-- ------------------------------------------------------------------------------------------------------------------
function Set_Display_Tooltip_Resources(on_off)
	if DisplayResources == on_off then
		return
	end
	
	DisplayResources = on_off
	
	local update_resources, curr_object = Update_Resources()
	if update_resources and TestValid(curr_object) then
		On_Tooltip_Dirty(curr_object)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Pip_Movie_Playing
-- ------------------------------------------------------------------------------------------------------------------
function Set_Pip_Movie_Playing(on_off)
	PIPMoviePlaying = on_off
	
	if PIPMoviePlaying then 
		-- Hide the expanded tooltip
		TooltipActivationTime = nil
		ExpandedTooltip.Hide_Display(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.End_Tooltip = End_Tooltip
Interface.Display_Tooltip = Display_Tooltip
Interface.Is_Open = Is_Open
Interface.Set_Letterbox_Mode = Set_Letterbox_Mode
Interface.Set_Display_Tooltip_Resources = Set_Display_Tooltip_Resources
Interface.Set_Pip_Movie_Playing = Set_Pip_Movie_Playing
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Find_All_Parent_Units = nil
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

