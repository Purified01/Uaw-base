if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MarkerTrigger.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MarkerTrigger.lua $
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

--
-- This is a pretty simple trigger script.
-- It just listens for any object entering a box of 100 meters centered on the marker
--
-- 4/29/2005 10:50:24 AM -- BMH
--


--
-- Definitions -- This function is called once when the script is first created.
--
-- @since 4/29/2005 10:51:40 AM -- BMH
-- 
function Definitions()

   -- Object isn't valid at this point so don't do any operations that
   -- would require it.  State_Init is the first chance you have to do
   -- operations on Object

	-- half-width of the box around our object.
	object_trap_size = 50
   
	DebugMessage("%s -- In Definitions", tostring(Script))
		
	Define_State("State_Init", State_Init);
	Define_State("State_Object_In_Range", State_Object_In_Range);

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

		-- Bring down the re-inforcements.
		BlockOnCommand(Reinforce_Unit(reinforce_type, Object.Get_Position(), caught_object.Get_Owner()))
		-- Spawn_Unit(reinforce_type, Object.Get_Position(), caught_object.Get_Owner())
		
		-- Sleep for 60 seconds then reset the trap.
		Sleep(60)

		-- Go back to State_Init to reset the trap.
		Set_Next_State("State_Init")
		
	elseif message == OnUpdate then
		-- DebugMessage("%s -- State_Object_In_Range(OnUpdate)", tostring(Script))
	elseif message == OnExit then
		-- DebugMessage("%s -- State_Object_In_Range(OnExit)", tostring(Script))
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
      Object.Event_Object_In_Range(object_in_range_handler, 50)

		reinforce_type = Find_Object_Type("Rebel_Tank_Buster_Squad")
		plex_type = Find_Object_Type("Plex_Soldier")

	elseif message == OnUpdate then
		-- DebugMessage("%s -- State_Init(OnUpdate)", tostring(Script))
		-- Do nothing
	elseif message == OnExit then
		-- DebugMessage("%s -- State_Init(OnExit)", tostring(Script))
		-- Do nothing
	end

end


--
-- object_in_range_handler -- Our object in range callback handler.  Passed into the 
--				Object.Event_Object_In_Range function during State_Init.
-- 
-- @param object GameObject of the object that entered our box
-- @since 4/29/2005 10:51:40 AM -- BMH
-- 
function object_in_range_handler(prox_obj, object)

	if object.Get_Type() ~= plex_type then
		return
	end
	-- DebugMessage("%s -- Object %s in range.", tostring(Script), tostring(object))

	-- Cancel the object in range event from signaling anymore.	
	Object.Cancel_Event_Object_In_Range(object_in_range_handler)

	-- gotcha!
	caught_object = object;

	-- Advance our state to Object_In_Range
  	Set_Next_State("State_Object_In_Range")
end

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Advance_State = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
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
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
