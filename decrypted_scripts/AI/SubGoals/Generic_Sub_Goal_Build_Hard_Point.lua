-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Sub_Goal_Build_Hard_Point.lua#12 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Sub_Goal_Build_Hard_Point.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 84877 $
--
--          $DateTime: 2007/09/26 14:44:48 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

function Compute_Desire()
	--This is a sub goal.  Once it's been activated by another goal it remains desirable, but
	--it never becomes active on its own.
	if Goal.Is_Active() then
		return 1.0
	else
		return 0.0
	end
end

function Score_Unit(unit)
	--Once we're ready to build we'll recruit a single tactical enabler that's capable of
	--producing the required object type.
	if not required_cash or not construction_type then
		return 0.0
	end

	if Goal.Get_Resources() < required_cash then
		return 0.0
	end

	local tf = Goal.Get_Task_Force()
	if tf and tf.Get_Total_Unit_Count() > 0 then
		return 0.0
	end

	if TestValid(Target) then
		if Target.Get_Game_Object() ~= unit then
			return 0.0
		end
	end

	if unit.Get_Can_Build_Hard_Point(construction_type) then
		return 1.0
	end
	
	return 0.0
end

function On_Activate()

	type_to_build = nil
	build_count = nil
	required_cash = nil
	Create_Thread("Prepare_To_Build")
	
end

function Prepare_To_Build()

	local user_data = Goal.Get_User_Data()
	if type(user_data) == "table" then
		type_to_build = user_data[1]
		build_count = user_data[2] 
		if not build_count then
			build_count = 1
		end
	else
		type_to_build = user_data
		build_count = 1
	end
	
	if not TestValid(type_to_build) then
		log("Generic_Sub_Goal_Build_Hard_Point was given bad userdata: type_to_build=%s, build_count=%s (userdata=%s)", tostring(type_to_build), tostring(build_count), tostring(user_data))
		return
	end

	Fix_Tactical_Dependencies(Player, Goal, type_to_build)
	
	--Most of the rest of the work is done using the under-construction version of the hard point
	construction_type = type_to_build.Get_Type_Value("Tactical_Under_Construction_Object_Type")

	--Secure cash for the build. 
	required_cash = construction_type.Get_Tactical_Build_Cost() * build_count
	
	-- do not request partial payments as this can jam AI
	while required_cash > Player.Get_Credits() do
		Sleep(2.0)
	end
	
	while required_cash > 0.0 do
		required_cash = required_cash - Goal.Request_Resources(required_cash, false)
		Sleep(1)
	end
	
	--Keep this thread alive so that it doesn't exit and cause the goal to be prematurely killed.
	--Also periodically re-check the dependencies so that we don't get blocked if something vanishes
	--after our initial check.
	while true do
		Sleep(10)
		Fix_Tactical_Dependencies(Player, Goal, type_to_build)
	end
end

function Build_Thread(tf)

	for _ = 1, build_count - 1 do
		tf.Build_Hard_Point(construction_type)
	end
	--Only block on the last build order.  Assuming we don't have strange build time rules the others should be done
	--by the time this one is.
	BlockOnCommand(tf.Build_Hard_Point(construction_type))
	ScriptExit()
end

function Service()
	if Goal.Get_Task_Force() then
		Goal.Claim_Units("Build_Thread")
	end
end