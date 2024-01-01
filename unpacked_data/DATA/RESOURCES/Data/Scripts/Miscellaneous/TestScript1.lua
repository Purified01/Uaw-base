-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/TestScript1.lua#4 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/TestScript1.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Eric_Yiskis $
--
--            $Change: 42308 $
--
--          $DateTime: 2006/04/27 16:30:28 $
--
--          $Revision: #4 $
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


