if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[8] = true
LuaGlobalCommandLinks[52] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Regional_Command_Center_Scene.lua 
--
--            Author: Maria Teruel
--
--          DateTime: 2006/05/31 
--
--	NOTE: Adpapted from RegionLabel.lua!
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	
	if TestValid(Object) then 
		
		Object.Register_Signal_Handler(On_CC_Construction_Canceled, "COMMAND_CENTER_CONSTRUCTION_CANCELED", this)
		Object.Register_Signal_Handler(On_Region_Owner_Changed, "OBJECT_OWNER_CHANGED", this)
		
		--Since we're listening on signals with a shared script we must hold a ref to the object wrapper
		--so it doesn't get garbage collected while another scene instance is using the script.  Ugh.
		Set_GUI_Variable("Object", Object)
	end
	
	this.CommandCenterIcon.Set_Hidden(true)
	this.CommandCenterIcon.Set_Clock_Tint({0.0, 1.0, 0.0, 110.0/255.0})
	
	this.RegionName.Set_Text(Object.Get_Type().Get_Type_Value("Text_ID"))
	
	--This applies to all scenes, so no need to use Set_GUI_Variable
	LocalPlayer = Find_Player("local")
	On_Region_Owner_Changed()
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Faction_Changed - make sure we hide all open scenes!
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Faction_Changed(event, source)
	LocalPlayer = Find_Player("local")
	On_Region_Owner_Changed()
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Region_Owner_Changed
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Region_Owner_Changed()
	if Object.Get_Owner() == LocalPlayer then
		this.Set_State("Default")
	else
		this.Set_State("Sleeping")
	end
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_CC_Construction_Canceled
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_CC_Construction_Canceled(region)
	this.CommandCenterIcon.Set_Hidden(true)	
end

--[[
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Request_Cancel_Command_Center_Construction
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Request_Cancel_Command_Center_Construction(event, source)
	Object.Cancel_Command_Center_Construction()
end
]]--


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Update
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	
	-- If we owe the region and there is no command center then we need to display the Command Center scene so the 
	-- player can build a CC.
	if Object == nil then
		return
	end
	
	Update_Command_Center_Icon(Object.Has_Command_Center(), Object.Is_Command_Center_Under_Construction())	
end

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Command_Center_Icon
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Command_Center_Icon(has_command_center, cc_under_construction)
	local ccQuad = this.CommandCenterIcon
	
	if has_command_center or not cc_under_construction then
		this.CommandCenterIcon.Set_Hidden(true)	
	elseif cc_under_construction then
		this.CommandCenterIcon.Set_Hidden(false)	
		-- Command center in progress
		local cc_type = Object.Get_Command_Center_Under_Construction_Type()
		local command_center_icon_name = cc_type.Get_Icon_Name()
		ccQuad.Set_Texture(command_center_icon_name)
		local percent = Object.Get_Command_Center_Percent_Complete()
		
		local time_in_seconds = (1.0 - percent) * cc_type.Get_Type_Value("Build_Time_Seconds")
		local tooltip_text = cc_type.Get_Display_Name()
		tooltip_text.append(Create_Wide_String("\n"))
		tooltip_text.append(Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), Get_Localized_Formatted_Number.Get_Time(time_in_seconds), 0))
		ccQuad.Set_Tooltip_Data({"custom", tooltip_text})	
		
		this.CommandCenterIcon.Set_Clock_Filled(percent)	
	end
end
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
	Get_GUI_Variable = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	On_Faction_Changed = nil
	OutputDebug = nil
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
