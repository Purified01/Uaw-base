if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[163] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGUICommands.lua#24 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGUICommands.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 93028 $
--
--          $DateTime: 2008/02/08 19:46:03 $
--
--          $Revision: #24 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


function Start_Flash(gui_object)

	local FLASH_INTERVAL = 0.25
	--Prepare a generic flash animation if we don't have one yet
	if flash_anim == nil then
		local r,g,b,_ = gui_object.Get_Tint()
		local a = 1.0
		flash_anim = Create_Animation("Flash")
		flash_anim.Add_Key_Frame("Tint", 0.0, { r, g, b, a })
		flash_anim.Add_Key_Frame("Tint", FLASH_INTERVAL, { r, g, b, 0.3 * a })
		flash_anim.Add_Key_Frame("Tint", 2.0 * FLASH_INTERVAL, { r, g, b, a })
	end
	
	--Attempt to play the flash animation.  If no such animation exists (Play fails) then
	--add our generic flash animation and play that
	if not gui_object.Play_Animation("Flash", true) then
		gui_object.Add_Animation(flash_anim)
		gui_object.Play_Animation("Flash", true)
	end

end

function Stop_Flash(gui_object)

	if Is_Flashing(gui_object) then
		gui_object.Stop_Animation()
	end

end

function Is_Flashing(gui_object)
	return gui_object.Is_Animating("Flash")
end


-- Find a bunch of GUI objects that have the same prefix, with a number after it. 
-- For example. if you have Scene.Button1 through Scene.Button12, and pass in 
-- parent=Scene and prefix="Button", you'll get back a table with those 12 buttons in it.
function Find_GUI_Components(parent, prefix)
	local index = 1
	local ret = {}
	while 1 do
		local name = string.format("%s%d", prefix, index)
		if not TestValid(parent[name]) then
			break
		end
		
		table.insert(ret, parent[name])
		index = index + 1
		
		if index > 200 then
			MessageBox("Find_GUI_Components has gone off the deep end!")
			break
		end
	end
	return ret
end

-- Turn on or off the UI scene attached to an object.
function Show_Object_Attached_UI(object, on_off)
	if not TestValid(object) then
		return
	end

	local local_player = Find_Player("local")
	local hidden =  Is_Fogged( local_player, object )

	if object.Has_Behavior(70) then
		hidden = (object.Get_Owner() ~= local_player)
	end	

    if hidden and on_off== true then
        return
    end

	local hp_parent = object.Get_Highest_Level_Hard_Point_Parent()
	if TestValid(hp_parent) then
		object = hp_parent
	end

	local scenes = object.Get_GUI_Scenes()
	if (scenes ~= nil) then
		for _, scene in ipairs(scenes) do
			if on_off then
				-- MARIA 03.06.2007 - Commenting the Enable(onoff) lines out since we are having a bug in which 
				-- a scene is active (and thus displayed) but it is flagged as disabled (namely, the NOVUS_Structure_Reticle scene).
				-- This prevents the scene from getting mouse events and updating its LastMouseOver.  Hence, if its LastMouseOver ~= NULL, 
				-- the scene hijacks all mouse events.
				scene.Enable(true)
				scene.Set_State("active")
				scene.Raise_Event("Reset_Last_Service", nil, {})
			else
				scene.Set_State("inactive")
				--scene.Enable(false)
			end			
		end
	end
	
	hp_table = object.Get_All_Hard_Points()
	
	if hp_table then
		for i,hard_point in pairs(hp_table) do
			scenes = hard_point.Get_GUI_Scenes()
			if (scenes ~= nil) then
				for _, scene in ipairs(scenes) do
					if on_off then
						scene.Enable(true)
						scene.Set_State("active")
					else
						scene.Set_State("inactive")
					--	scene.Enable(false)
					end
				end
			end
		end
	end
end

-- Raise an event to our parent, and grandparent, and so on up the chain.
function Raise_Event_All_Parents(event, source, scene, param)
	scene = scene.Get_Containing_Scene()
	while scene do
		scene.Raise_Event(event, source, param)
		scene = scene.Get_Containing_Scene()
	end
end


-- Raise an Immediate Event to our parent, and grandparent, and so on up the chain.
function Raise_Event_Immediate_All_Parents(event, source, scene, param)
	scene = scene.Get_Containing_Scene()
	while scene do
		scene.Raise_Event_Immediate(event, source, param)
		scene = scene.Get_Containing_Scene()
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------
-- Special function for GUI scripts to determine if a syncronized object's lua script has a lua behavior active
-- ---------------------------------------------------------------------------------------------------------------------------
function GUI_Does_Object_Have_Lua_Behavior(object, name)
	if TestValid(object) then
		local script_obj = object.Get_Script()
		if script_obj then
			local btable = script_obj.Get_Async_Data("ActiveBehaviorNames")
			return btable and btable[name]
		end
	end
	return false
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Tell the GameMode GUI Scene to send this network event.
-- ---------------------------------------------------------------------------------------------------------------------------
function Send_GUI_Network_Event(net_event_name, args)
	game_scene = Get_Game_Mode_GUI_Scene()
	game_scene.Raise_Event_Immediate("Send_GUI_Network_Event", nil, {net_event_name, args} )
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Common init and defines for dialog boxes.
-- ---------------------------------------------------------------------------------------------------------------------------
function Dialog_Box_Common_Init()
-- The following 3 lines are required by the lua preprocessor.  1/22/2008 3:14:28 PM -- BMH
--[[










]]--
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Free a component - hides it and puts it back into the pool for re-use.
-- ---------------------------------------------------------------------------------------------------------------------------
function GUI_Pool_Free(pool, component)
	component.Set_Hidden(true)
	table.insert(pool.unused, component)
end

function Set_GUI_Variable(name, val)
	if not GUIVariables then
		GUIVariables = {}
	end
	if not GUIVariables[this] then
		GUIVariables[this] = {}
	end
	GUIVariables[this][name] = val
end

function Get_GUI_Variable(name)
	if not GUIVariables then
		GUIVariables = {}
	end
	if not GUIVariables[this] then
		GUIVariables[this] = {}
	end	
	return GUIVariables[this][name]
end

-- Raise parent dialog if it exists -- NADER [4/13/2007]
function GUI_Dialog_Raise_Parent()
	local user_data = this.Get_User_Data()
	this.Set_Hidden(true)
	this.End_Modal()
	if user_data ~= nil and TestValid(user_data.Parent_Dialog) then
		if user_data.Parent_Dialog.Get_Hidden() then
			user_data.Parent_Dialog.Set_Hidden(false)
			user_data.Parent_Dialog.Bring_To_Front()
			user_data.Parent_Dialog.Start_Modal()
		end
		local parent = this.Get_Containing_Scene()
		if not TestValid(parent) then
			parent = this
		end
		parent.Raise_Event_Immediate("Set_Current_Modal_Dialog", nil, {user_data.Parent_Dialog})
	end
end

function Spawn_Dialog(bui_file, hide_self)
	-- End the current modality before starting a new one
	if hide_self then
		this.End_Modal()
		this.Set_Hidden(true)
	end

	local parent = this.Get_Containing_Scene()
	if not TestValid(parent) then
		parent = this
	end

	local dialog = parent[bui_file]
	if not TestValid(dialog) then
		Create_Embedded_Scene(bui_file, parent, bui_file)
		dialog = parent[bui_file]
	end
	parent.Raise_Event_Immediate("Set_Current_Modal_Dialog", nil, {dialog})

	dialog.Set_Hidden(false)
	dialog.Set_User_Data({Parent_Dialog = this})
	dialog.Bring_To_Front()
	dialog.Start_Modal()

	return dialog
end

function Spawn_Dialog_Box(params, opt_bui_file, hide_self)
	if hide_self == nil then hide_self = true end
	-- Default to the standard dialog box
	local bui_file = "DialogBox"
	if opt_bui_file then
		bui_file = opt_bui_file
	end

	local dialog = Spawn_Dialog(bui_file, hide_self)
	dialog.Dialog_Box_Init(params)
end

------------------------------------------------------------------
-- Disable_UI_Element_Event
-- Disables the source element, can be called from an event handler
------------------------------------------------------------------
function Disable_UI_Element_Event(event, source)
	if source and source.Can_Be_Disabled() then
	--	DebugMessage("Disabling UI Element %s", source.Get_Fully_Qualified_Name())
		source.Enable(false)
	end
end

------------------------------------------------------------------
-- Enable_UI_Element_Event
-- Enable the source element, can be called from an event handler
------------------------------------------------------------------
function Enable_UI_Element_Event(event, source)
	if source then
		if not source.Is_Enabled() then
		--	DebugMessage("Enabling UI Element %s", source.Get_Fully_Qualified_Name())
			source.Enable(true)
		end
	end
	-- re-disable non interactive elements if in replay mode
	if IsReplay then
		if Disable_GUI_For_Replay then
			Disable_GUI_For_Replay()
		end
	end
end

------------------------------------------------------------------
-- Safe_Set_Hidden
-- Check for validity before calling set hidden on a control
------------------------------------------------------------------
function Safe_Set_Hidden(control, hidden_flag)
	if TestValid(control) then
		control.Set_Hidden(hidden_flag)
	end
end

------------------------------------------------------------------
-- Update_SA_Button_Text_Button
-- Update the special ability tooltip and text
------------------------------------------------------------------
function Update_SA_Button_Text_Button(button, selected_objects, buttons_to_flash)
	if CommandBarEnabled == false then return end

	
	-- if we have no valid button or the button is hidden, then do nothing.
	if not button or button.Get_Hidden() == true then return end
	
	local user_data = button.Get_User_Data()
	if user_data then 
		
		-- Number of units ready to use this ability *right now*, added count here as hard points are now included
		local num_ready, count, percent_done, time_left, time_total, at_least_one_expiring
			= Get_Number_Units_Ready_For_Special_Ability(selected_objects, user_data.ability.unit_ability_name, true)
		
		-- MLL: Enable/disable the button when state changes.
		if time_left == nil then
			if count > 0 then
				button.Set_Button_Enabled(true)
			else
				button.Set_Button_Enabled(false)
			end
		end

		--Make sure we always pass a reasonable value for the time_left parameter or silly LUA will
		--compact the table down.
		if not time_left then
			time_left = 0.0
		end
		
		local tooltip_data = {}
		tooltip_data[1] = user_data.ability.AbilityOwner
		tooltip_data[2] = user_data.ability.unit_ability_name
		if user_data.active and user_data.ability.alt_icon then
			tooltip_data[3] = user_data.ability.alt_text_id
			tooltip_data[4] = user_data.ability.alt_tooltip_description_text_id		
		else
			tooltip_data[3] = user_data.ability.text_id
			tooltip_data[4] = user_data.ability.tooltip_description_text_id
		end	
		tooltip_data[5] = user_data.ability.tooltip_category_id
		tooltip_data[6] = time_left
		tooltip_data[7] = Get_Ability_Key_Mapping_Text(LocalPlayer, user_data.ability.unit_ability_name)
		tooltip_data[8] = user_data.ability.types_to_spawn
		
		
		button.Set_Tooltip_Data({'ability', tooltip_data})

		local is_toggle = (user_data.ability.action == SPECIALABILITYACTION_TOGGLE ) or
					(user_data.ability.action == SPECIALABILITYACTION_TARGET_TERRAIN_FORWARD_TOGGLE ) 
		
		if not user_data.disable_without_behavior_data and num_ready ~= count and not is_toggle then
			local wstr_fraction = Get_Game_Text("TEXT_FRACTION")
			Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(num_ready), 0)
			Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(count), 1)
			button.Set_Text(wstr_fraction)
		else
			if user_data.disable_without_behavior_data and user_data.disable_without_behavior_data ~= count then
				local wstr_fraction = Get_Game_Text("TEXT_FRACTION")
				Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(user_data.disable_without_behavior_data), 0)
				Replace_Token(wstr_fraction, Get_Localized_Formatted_Number(count), 1)
				button.Set_Text(wstr_fraction)
			else
				button.Set_Text(Get_Localized_Formatted_Number(count))
			end
		end

		if user_data.ability.hide_if_health_below then
		    if Do_Units_Have_Enough_Health(selected_objects, user_data.ability.hide_if_health_below) then
			button.Set_Button_Enabled(true)
		    else
			button.Set_Button_Enabled(false)
		    end
		end
		
		-- Update the flash state of the button as well!.
		if buttons_to_flash and buttons_to_flash[user_data.ability.text_id] then
			button.Start_Flash()
		else
			button.Stop_Flash()
		end
		
		-- Recharge clock.
		if percent_done then
			button.Set_Clock_Filled(1.0 - percent_done)
			
			if at_least_one_expiring then
				button.Set_Clock_Tint(DefaultAbilityClockTint)
			else
				button.Set_Clock_Tint(RechargingAbilityClockTint)
			end

		else
			button.Set_Clock_Filled(0.0)
		end
	end		
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Dialog_Box_Common_Init = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_GUI_Variable = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Spawn_Dialog_Box = nil
	Update_SA_Button_Text_Button = nil
	Kill_Unused_Global_Functions = nil
end
