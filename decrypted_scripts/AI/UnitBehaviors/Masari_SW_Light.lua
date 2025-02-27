if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Masari_SW_Light.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Masari_SW_Light.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGBehaviors")
require("PGUICommands")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	-- Try not to edit ServiceRate - it affects all LUA behaviors for this unit
	
  	Get_Game_Mode_GUI_Scene().Raise_Event("Network_Select_Super_Weapon", nil, {Object})

end

local function Behavior_Service()

	obj_list = Find_All_Objects_Of_Type( Object, 400.0, "Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST | CanAttack" )
	
	local best_target = nil
	local best_target_val = 999999.0
	
	local player = Object.Get_Owner()
	if not TestValid(player) then
		return
	end
	
	if obj_list then
		for _,unit in pairs(obj_list) do
			if TestValid(unit) then
				if player.Is_Enemy(unit.Get_Owner()) and not unit.Is_Category("Resource_INST | Resource") and not unit.Is_Phased() then
					if not unit.Is_Flying() or unit.Get_Attribute_Value( "Is_Grounded" ) ~= 0 or (unit.Get_Health() < 0.2 and unit.Get_Health_Value() < 100.0) then
						local target
						if unit.Has_Behavior(68) then
							local target = unit.Get_Highest_Level_Hard_Point_Parent()
						else
							target = unit
						end
						
						if TestValid(target) then
							local distance = Object.Get_Distance(target)
							if not target.Is_Category("Stationary") then
								distance = distance * 4.0
							end
							
							if distance < best_target_val then
								best_target_val = distance
								best_target = target
							end
						end
					end
				end
			end
		end
	end
	
	
	if TestValid(best_target) then
		Object.Move_To(best_target)
	end

	Sleep(1.5)
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
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
	Simple_Round = nil
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
