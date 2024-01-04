-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Dummy_Idle_Threads.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Dummy_Idle_Threads.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Andre_Arsenault $
--
--            $Change: 59726 $
--
--          $DateTime: 2006/12/18 17:47:33 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


-- Makes the ai idle threads accessible so one can be named as the <Idle_AI_Thread_Name> by AIBehaviorType.
require("AIIdleThreads")

-- This behavior doesn't actually do anything useful beyond including AIIdleThreads.lua 
local my_behavior = 
{
	Name = _REQUIREDNAME
}

Register_Behavior(my_behavior)
