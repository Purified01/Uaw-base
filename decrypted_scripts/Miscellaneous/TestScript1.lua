LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/TestScript1.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/TestScript1.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

function Definitions()

   --DebugBreak()

	DesignerMessage("%s -- In Definitions", tostring(Script))

	ServiceRate = 1
		
	Define_State("State_Init", State_Init);
	Define_State("State_Object_In_Range", State_Object_In_Range);

end


-- Test_Func_One --
function Test_Func_One()

   ival = 0
   while ival < 10 do
      ival = ival + 1
   end

end

--
-- State_Object_In_Range -- We've caught an object.
-- 
-- @param message The message describing our progression through this state.  OnEnter, OnUpdate, OnExit.
-- @since 4/29/2005 10:51:40 AM -- BMH
-- 
function State_Object_In_Range(message)
	if message == OnEnter then
		DesignerMessage("%s -- State_Object_In_Range(OnEnter), Caught %s", tostring(Script), tostring(caught_object))

		-- Sleep for 60 seconds then reset the trap.
		Sleep(60)

		-- Go back to State_Init to reset the trap.
		Set_Next_State("State_Init")
		
	elseif message == OnUpdate then
		-- DebugMessage("%s -- State_Object_In_Range(OnUpdate)", tostring(Script))
	elseif message == OnExit then
		DesignerMessage("%s -- State_Object_In_Range(OnExit)", tostring(Script))
	end
end


--
-- State_Init -- The Init state.  Set our trap to catch an object.
-- 
-- @param message The message describing our progression through this state.  OnEnter, OnUpdate, OnExit.
-- @since 4/29/2005 10:51:40 AM -- BMH
-- 
function State_Init(message)

	if message == OnEnter then
      -- When an object enters within 50 meters call our event.
		DesignerMessage("%s -- State_Init(OnEnter)", tostring(Script))

	elseif message == OnUpdate then
      Sleep(2)
		DebugMessage("%s -- State_Init(OnUpdate)", tostring(Script))
		-- Do nothing
	elseif message == OnExit then
		DesignerMessage("%s -- State_Init(OnExit)", tostring(Script))
		-- Do nothing
	end

end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Advance_State = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Current_State = nil
	Get_Last_Tactical_Parent = nil
	Get_Next_State = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_From_Table = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Test_Func_One = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
