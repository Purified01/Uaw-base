if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Novus_Tactical_Upgrades_Menu.lua
--
--    Original Author: Maria Teruel
--
--          DateTime: 2007/02/24
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("Tactical_Upgrades_Menu")

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Faction_Display()
	Set_GUI_Variable("ControlGroupDisplayYOffset", 0.2)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Power_Icon
-- ------------------------------------------------------------------------------------------------------------------
function Update_Power_Icon()
	if TestValid(Object) and
			not Object.Has_Behavior(39) and 
			Object.Has_Behavior( 161 ) and 
			Object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 and 
			Object.Get_Owner() == Find_Player("local") then
		if not Is_Flashing(this.NoPower) then
			this.NoPower.Set_Hidden(false)
			Start_Flash(this.NoPower)
		end
	else
		Stop_Flash(this.NoPower)
		this.NoPower.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Inactive
-- ------------------------------------------------------------------------------------------------------------------
function Update_Inactive()
	if LetterBoxModeOn then
		-- if we are running a cinematic, let's not do anything (just make sure we are hidden!)
		if not this.NoPower.Get_Hidden() then
			Reset_No_Power_State()
		end
		return
	else
		Update_Power_Icon()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Reset_No_Power_State()
	Stop_Flash(this.NoPower)
	this.NoPower.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Display()
	Reset_No_Power_State()
	Update_Power_Icon()
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Enter_Active
-- ------------------------------------------------------------------------------------------------------------------
function On_Enter_Active()
	Update_Control_Group_Display(false) -- do not set the ctrl group texture here (we just need to update its hidden/unhidden state)
	Update_Active()	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
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
