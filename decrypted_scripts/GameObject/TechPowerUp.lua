LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/TechPowerUp.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/TechPowerUp.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}


local function Behavior_First_Service()
	-- MessageBox("%s -- %s::Behavior_Init for %s", tostring(Script), my_behavior.Name, tostring(Object))
	if Object then 
		Object.Event_Object_In_Range(my_behavior.Object_In_Range, TECH_POWERUP_RETRIEVAL_RANGE) 
		Object.Get_GUI_Scene().Raise_Event("Start_Tech_Object_Retrieval",Object, {0,""} )
	end
end

local function Behavior_Service()

	if TestValid(TechLockObject) then
		if Object.Get_Distance(TechLockObject) > TECH_POWERUP_RETRIEVAL_RANGE then
			TechLockObject.Get_Script().Call_Function("Tech_Powerup_Retrieval_Failed", Object)
			TechLockObject = nil
		end
	end
	
	if not highlighted then
		if Object.Get_Position() == last_position then
			Object.Highlight_Small(true, -85)
			highlighted = true
		end
	
		last_position = Object.Get_Position()
	end
end

function Tech_Powerup_Lock_Retrieval(lock_object)
	TechLockObject = lock_object
end


local function Behavior_Object_In_Range(prox_object, object)

	if TestValid(TechLockObject) then
		return
	end
	
	local player = object.Get_Owner()
	--if player ~= Object.Get_Owner() then
			--MessageBox("%s -- %s caught", tostring(Object), tostring(object))
	
			local obj_script = object.Get_Script()
			if obj_script then
				obj_script.Call_Function("Tech_Powerup_In_Range", Object)
			end
	--end
end



-- This line must be at the bottom of the file.
my_behavior.First_Service = Behavior_First_Service
--my_behavior.Init = Behavior_Init
my_behavior.Object_In_Range = Behavior_Object_In_Range
my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
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
