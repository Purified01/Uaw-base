-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/TestScript3.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/TestScript3.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Eric_Yiskis $
--
--            $Change: 40914 $
--
--          $DateTime: 2006/04/11 15:17:48 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

function Definitions()

	DebugMessage("%s -- In Definitions", tostring(Script))

	ServiceRate = 1
	SpawnedThread = false
		
	Define_State("State_Init", State_Init);
	Define_State("State_Object_In_Range", State_Object_In_Range);

end

function Test_Func_One()

	if not SpawnedThread then
		Create_Thread("Test_Func_Two")
		SpawnedThread = true
	end

   ival = 0
   while ival < 10 do
      ival = ival + 1
   end

end


-- For thread testing --
function Test_Func_Two()
	while true do
		ival = 0
		while ival < 10 do
			ival = ival + 1
		end
	
		Sleep(2)
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
		DebugMessage("%s -- State_Object_In_Range(OnEnter), Caught %s", tostring(Script), tostring(caught_object))

		-- Sleep for 60 seconds then reset the trap.
		Sleep(60)

		-- Go back to State_Init to reset the trap.
		Set_Next_State("State_Init")
		
	elseif message == OnUpdate then
		-- DebugMessage("%s -- State_Object_In_Range(OnUpdate)", tostring(Script))
	elseif message == OnExit then
		DebugMessage("%s -- State_Object_In_Range(OnExit)", tostring(Script))
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
		DebugMessage("%s -- State_Init(OnEnter)", tostring(Script))

	elseif message == OnUpdate then
		-- DebugMessage("%s -- State_Init(OnUpdate)", tostring(Script))
		-- Do nothing
	elseif message == OnExit then
		DebugMessage("%s -- State_Init(OnExit)", tostring(Script))
		-- Do nothing
	end

end


