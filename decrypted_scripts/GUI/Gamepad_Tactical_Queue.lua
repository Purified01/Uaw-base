if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[9] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Gamepad_Tactical_Queue.lua
--
--    Original Author: Chris_Brooks
--
--          DateTime: 2006/11/29 16:55:44 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")


-- ------------------------------------------------------------------------------------------------------------------
-- On_Init - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Queue(queue_index)

	UnitQuads = Find_GUI_Components(Scene, "Unit")
	
	LastUsedQuadndex = 0
	DefaultTexture = nil
	IndexToBoundsMap = { }
	QuanityText = { }
	HideXButton = false
	
	for idx, quad in pairs(UnitQuads) do
		IndexToBoundsMap[idx] = { }
		IndexToBoundsMap[idx].x, IndexToBoundsMap[idx].y, IndexToBoundsMap[idx].w, IndexToBoundsMap[idx].h = quad.Get_Bounds()
	end	
	
	if TestValid(this.XQuad) then 
		-- This quad will always be positioned underneath the last button in the queue.
		XQuad = this.XQuad
		XQuad.Set_Hidden(true)
		
		_, _, Xw, Xh = XQuad.Get_Bounds()
	end
	
	-- Shared clock
	-- the timers are progress timers so they should be green.
	Clock = this.Clock;
	Clock.Set_Tint(0.0, 1.0, 0.0, 110.0/255.0)		
	
	local quad = UnitQuads[1]
	
	if TestValid(quad) then
		DefaultTexture = quad.Get_Texture_Name()
	end

	QuanityText = Find_GUI_Components(this, "QuanityText")
	for _, textbox in pairs(QuanityText) do
		textbox.Set_Text("")
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_X_Button_Up
-- ------------------------------------------------------------------------------------------------------------------
function Process_X_Button_Up(_, _)
	DebugMessage("Process_X_Button_Up")
	-- Get the last button and cancel build using its data.
	Cancel_Last_Build()	
end
	
-- ------------------------------------------------------------------------------------------------------------------
-- Cancel_Last_Build
-- ------------------------------------------------------------------------------------------------------------------
function Cancel_Last_Build()
	if LastUsedQuadIndex == 0 then 
		-- no build going on, nothing to cancel
		return
	end
	
	if LastUsedQuadIndex > #UnitQuads then
		MessageBox("WRONG INDEX!!!!!")
		return
	end
	
	local quad = UnitQuads[LastUsedQuadIndex]
	if TestValid(quad) then 
		Process_Cancel_Build(quad.Get_User_Data())
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Process_Cancel_Build - 
-- ------------------------------------------------------------------------------------------------------------------
function Process_Cancel_Build(cancel_data)
	if not cancel_data or #cancel_data < 3 then
		return
	end
	
	local building = cancel_data[1]
	local build_id = cancel_data[2]
	local obj_type = cancel_data[3]
	
	if TestValid(building) then
		Send_GUI_Network_Event("Networked_Cancel_Build", { building, obj_type, build_id, 1, Find_Player("local") })
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Queue - 
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Queue()
	Scene.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Queue - 
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Queue(building, flash_building_button)

	Scene.Set_Hidden(false)

	-- Go through the objects under construction in this queue, and assign them to buttons.
	local build_queue = building.Tactical_Enabler_Get_Queued_Objects()
	if not build_queue then build_queue = {} end
	
	LastUsedQuadIndex = 0
	local quad_index = 1
	local quad_count = table.getn(UnitQuads)
	if build_queue then
		for i, build_info in pairs(build_queue) do
			local quad = UnitQuads[quad_index]
			
			quad.Set_Texture(build_info.Type.Get_Icon_Name())
			
			-- only the first one has a clock
			if quad_index == 1 then
				-- Clock
				Clock.Set_Filled( build_info.Percent_Complete )
			end
	
			-- Text (quantity)
			local quanity_text = QuanityText[quad_index]
			if TestValid(quanity_text) then
				if build_info.Quantity > 1 then
					quanity_text.Set_Text(Get_Localized_Formatted_Number(build_info.Quantity))
				else
					quanity_text.Set_Text("")
				end
			end
			
			-- Set user data to point to build id.
			quad.Set_User_Data({building, build_info.Build_ID, build_info.Type})
			
			-- Next button, please.
			LastUsedQuadIndex = quad_index
			quad_index = quad_index + 1
			if quad_index > quad_count then
				break
			end
		end
	end
	
	local is_building = (quad_index > 1)
	
	-- The X quad will always be positioned underneath the last button in the queue.
	if TestValid(XQuad) then
		if is_building and not HideXQuad then
			XQuad.Set_Hidden(false)
			-- get the last button's bounds
			local bds = IndexToBoundsMap[LastUsedQuadIndex]
			XQuad.Set_Bounds(bds.x + 0.5 * (bds.w - Xw), bds.y + bds.h - 0.5 * Xh, Xw, Xh)
			XQuad.Set_User_Data(LastUsedQuadIndex)
		else
			XQuad.Set_Hidden(true)
			XQuad.Set_User_Data(nil)		
		end
	end
	
	-- Hide any remaining buttons.
	if quad_index <= quad_count then
		for i=quad_index, quad_count do
			local quad = UnitQuads[i]
			quad.Set_Texture(DefaultTexture)
			-- Make sure we reset the text if we are not displaying this quad!!!!
			if i <= #QuanityText then
				QuanityText[i].Set_Text("")
			end
		end
	end
	
	if not is_building then
		Clock.Set_Filled(0.0)
	end	
	
	return is_building
end

function Hide_X_Button(hide)
	HideXButton = hide
	if hide then
		XQuad.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Queue = Init_Queue
Interface.Hide_Queue = Hide_Queue
Interface.Setup_Queue = Setup_Queue

-- GAMEPAD
Interface.Process_X_Button_Up = Process_X_Button_Up
Interface.Hide_X_Button = Hide_X_Button
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
