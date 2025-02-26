if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[8] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Enemy_SW_Timer.lua 
--
--    Original Author: Maria Teruel
--
--          Date: 2007/07/02
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGFactions")
require("PGColors")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	if not TestValid(this) then return end
	
	PGColors_Init_Constants()
	PGFactions_Init()
	
	Color = this.Group.PlayerColorQuad
	Color.Set_Tint(0)
	Symbol = this.Group.FactionSymbolQuad
	MouseOverQuad = this.Group.MouseOverQuad
	MouseOverQuad.Set_Hidden(true)
	
	Icons = {}
	
	SWIcons = {}
	SWIcons = Find_GUI_Components(this.Group, "SW")
	
	for i = 1, #SWIcons do
		local icon = SWIcons[i]
		if TestValid(icon) then
			icon.Clock.Set_Tint(1.0, 0.0, 0.0, 120.0/255.0)
			icon.Clock.Set_Filled(0.0)
			icon.Set_Hidden(true)		
		end	
	end
	
	MouseOverSceneHoverTime = 0.3
	DisplayTooltipTime = nil
	DisplayingTooltip = false
	
	WeaponTypesList= {}
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_SW_Data
-- ------------------------------------------------------------------------------------------------------------------
function Set_SW_Data(player, use_player_color, sw_data)

	if not player or use_player_color == nil or not sw_data then 
		return
	end
	
	local sw_icon_index = 1
	
	local weapon_tooltips = Create_Wide_String("")
	for weapon_type_name, weapon_state_table in pairs(sw_data) do
		-- NOTE: 	the data in weapon_state_table is as follows
		--		table[1] = is enabler present
		--		table[2] = can fire (ie is weapon enabled)
		--		table[3] = progress data
		-- 		table[4] = count
		--		table[5] = number ready to fire
		--		table[6] = enabler associated to this weapon (we need it for tooltip purposes!)
		--		table[7] = total cooldown time
		
		local this_weapon_tooltip_txt = Create_Wide_String("")
		local is_enabler_present = weapon_state_table[1]
		local is_enabled = weapon_state_table[2]
		local progress = weapon_state_table[3]
		local owning_enabler = weapon_state_table[6]
		local total_cooldown = weapon_state_table[7]
		
		if is_enabler_present then
			
			local icon = SWIcons[sw_icon_index]
			icon.Set_User_Data(weapon_type_name)
			icon.Set_Hidden(false)
			
			icon.Quad.Set_Texture(Find_Object_Type(weapon_type_name).Get_Icon_Name())
			
			if TestValid(owning_enabler) then 
				this_weapon_tooltip_txt.append(Create_Wide_String("\n"))	
				this_weapon_tooltip_txt.append(owning_enabler.Get_Type().Get_Display_Name())
				this_weapon_tooltip_txt.append(Create_Wide_String(": "))			
			end
			
			if progress == 1.0 then
				-- Novus SW may be unpowered and remain disabled until they get power back.  
				-- So let's not display the clock full and not moving until their cooldown/warm up starts.
				icon.Clock.Set_Filled(0.0)
			else
				icon.Clock.Set_Filled(progress)
			end
			
			if progress == 0.0 or progress == 1.0 then
				if is_enabled then
					-- TEXT_ID_TOOLTIP_READY 
					this_weapon_tooltip_txt.append(Get_Game_Text("TEXT_ID_TOOLTIP_READY"))
					weapon_tooltips.append(this_weapon_tooltip_txt)
				else
					this_weapon_tooltip_txt.append(Get_Game_Text("TEXT_ID_TOOLTIP_NOT_READY"))
					weapon_tooltips.append(this_weapon_tooltip_txt)
				end
			else
				local time_remaining = total_cooldown*progress
				-- convert this into nice time
				this_weapon_tooltip_txt.append(Get_Localized_Formatted_Number.Get_Time(time_remaining))
				weapon_tooltips.append(this_weapon_tooltip_txt)
			end
			
			-- Is this weapon enabled?
			icon.DisabledQuad.Set_Hidden(is_enabled)
			
			-- let's move to the next slot!.
			sw_icon_index = sw_icon_index + 1		
			
			if sw_icon_index > #SWIcons then 
				break
			end			
		end
	end
	
	for idx = sw_icon_index, #SWIcons do
		local icon = SWIcons[idx]
		icon.Set_Hidden(true)
		icon.Clock.Set_Filled(0.0)		
	end
	
	if sw_icon_index ~= 1 then 
		-- Maria 07.06.2007
		-- For E3 we are not displaying the faction symbol!.
		-- I will comment this out for now and once design decides on the final path for this functionality I will clean up the code
		-- and bui files accordingly.
		--[[
		-- Set the symbol of the faction as one of the backgrounds
		Symbol.Set_Texture(PGFactionNameToFactionTexture[player.Get_Faction_Name()])
		]]--
		
		if use_player_color then 
			Color.Set_Tint(player.Get_Color())
		end

		local tooltip_wstrg = Get_Game_Text("TEXT_PLAYER")
		tooltip_wstrg.append(Create_Wide_String(" "))
		tooltip_wstrg.append(player.Get_Display_Name())
		
		tooltip_wstrg.append(weapon_tooltips)
		this.Set_Tooltip_Data({'custom', tooltip_wstrg})
		if DisplayingTooltip then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {this.Get_Tooltip_Data()})
		end
	end	
end



-- ------------------------------------------------------------------------------------------------------------------
-- Set_MW_Data
-- ------------------------------------------------------------------------------------------------------------------
function Set_MW_Data(player, use_player_color, weapon_object)

	if not TestValid(weapon_object) then
		return
	end

	local time_remaining = nil
	local progress = nil
	local script = weapon_object.Get_Script()
	if script ~= nil then
		local megaweapon_cooldown_data = script.Get_Async_Data("MegaweaponCooldown")
		if megaweapon_cooldown_data.EndTime > 0.0 then
			time_remaining = megaweapon_cooldown_data.EndTime - GetCurrentTime()
			if time_remaining <= 0.0 then
				time_remaining = nil
			else
				progress = time_remaining/megaweapon_cooldown_data.CooldownTime
			end			
		end
	end
	
	local icon = SWIcons[1]
	if not TestValid(icon) then
		return
	end
	icon.Set_Hidden(false)
	icon.Quad.Set_Texture(weapon_object.Get_Type().Get_Icon_Name())
	
	local this_weapon_tooltip_txt = Create_Wide_String("\n")
	this_weapon_tooltip_txt.append(weapon_object.Get_Type().Get_Display_Name())
	this_weapon_tooltip_txt.append(Create_Wide_String(": "))	
	
	if time_remaining then
		icon.Clock.Set_Filled(progress)
		-- convert this into nice time
		this_weapon_tooltip_txt.append(Get_Localized_Formatted_Number.Get_Time(time_remaining))
	else
		icon.Clock.Set_Filled(0.0)
		-- TEXT_ID_TOOLTIP_READY 
		this_weapon_tooltip_txt.append(Get_Game_Text("TEXT_ID_TOOLTIP_READY"))
	end
	
	-- Is this weapon enabled?
	icon.DisabledQuad.Set_Hidden((time_remaining == nil))
	
	if use_player_color then 
		Color.Set_Tint(player.Get_Color())
	end

	local tooltip_wstrg = Get_Game_Text("TEXT_PLAYER")
	tooltip_wstrg.append(Create_Wide_String(": "))
	tooltip_wstrg.append(player.Get_Display_Name())
	
	tooltip_wstrg.append(this_weapon_tooltip_txt)
	this.Set_Tooltip_Data({'custom', tooltip_wstrg})
	
	if DisplayingTooltip then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {this.Get_Tooltip_Data()})
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Mouse_Over_Timer - Set from the bui file
-- ------------------------------------------------------------------------------------------------------------------
function Mouse_Over_Timer(event, source)
	MouseOverQuad.Set_Hidden(false)
	DisplayingTooltip = false
	if this.Get_Tooltip_Data() then
		DisplayTooltipTime = GetCurrentTime() + MouseOverSceneHoverTime		
	else
		-- make sure the countdown for the tooltip is niled!
		DisplayTooltipTime = nil		
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Mouse_Off_Timer - Set from the bui file
-- ------------------------------------------------------------------------------------------------------------------
function Mouse_Off_Timer(event, source)
	MouseOverQuad.Set_Hidden(true)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, {})
	DisplayTooltipTime = nil
	DisplayingTooltip = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update - Set from the bui file
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()
	if DisplayTooltipTime and DisplayTooltipTime <= GetCurrentTime() then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {this.Get_Tooltip_Data()})
		DisplayTooltipTime = nil
		DisplayingTooltip = true
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- INTERFACE ---------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_SW_Data = Set_SW_Data
Interface.Set_MW_Data = Set_MW_Data
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Chat_Color_Index = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Localized_Faction_Name = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGColors_Init = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
