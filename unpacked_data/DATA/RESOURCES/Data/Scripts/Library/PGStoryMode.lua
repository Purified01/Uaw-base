-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGStoryMode.lua#8 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGStoryMode.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 68909 $
--
--          $DateTime: 2007/04/26 11:52:14 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")

function Story_AI_Request_Build_Units(player, type_to_build, number_to_build)
	return player.Activate_AI_Goal("Generic_Sub_Goal_Build_Unit", nil, { type_to_build, number_to_build })
end

function Story_AI_Request_Build_Structure_Or_Walker(player, type_to_build, position)
	return player.Activate_AI_Goal("Generic_Sub_Goal_Build_Structure", position, type_to_build)
end

function Story_AI_Request_Build_Hard_Point(player, type_to_build, on_unit, number_to_build)
	if not number_to_build then
		number_to_build = 1
	end
	
	return player.Activate_AI_Goal("Generic_Sub_Goal_Build_Hard_Point", on_unit, { type_to_build, number_to_build })
end

function Maintain_Base(player, layout_name)
	if layout_name then
		player.Set_Preferred_Base_Layout(layout_name)
	end
	return Create_Thread("Maintain_Base_Internal",  player)
end

function Maintain_Base_Internal(player)
	while true do	
		local structure_type = player.Recommend_Next_Structure()
		if TestValid(structure_type) then
			--Don't block on the goal.  That way we can build in parallel where possible
			Story_AI_Request_Build_Structure_Or_Walker(player, structure_type, nil)
		end
		
		Sleep(3)
	end
end


--
-- Retrieve the Master Unit Goal Controller for the given AI Player.
--
function Get_Master_Unit_Goal_Controller(player)
	local max_tries = 10
	local num_tries = 0
	local ai_goal_controller = nil
	while num_tries < max_tries do
		ai_goal_controller = player.Get_Goal_Script_By_Name("Master_Unit_Goal_Controller")
		if ai_goal_controller ~= nil then
			return ai_goal_controller
		end
		Sleep(1)
		num_tries = num_tries + 1
	end
	return nil
end

--
-- Make the AI favor attacking its enemies. Will involve some scouting to locate those enemies,
-- and will still defend its base if attacked (though it may not have many units left there).
--
function Story_AI_Set_Aggressive_Mode(player)
	local ai_goal_controller = Get_Master_Unit_Goal_Controller(player)
	if not ai_goal_controller then
		return false
	end
	return ai_goal_controller.Call_Function("Set_Aggressive_Mode")
end


--
-- Make the AI favor sitting back in its base and defending. It will still have some units out
-- harvesting resources with some units protecting those harvesters, but it won't be plotting
-- the demise of its enemies.
--
function Story_AI_Set_Defensive_Mode(player)
	local ai_goal_controller = Get_Master_Unit_Goal_Controller(player)
	if not ai_goal_controller then
		return false
	end
	return ai_goal_controller.Call_Function("Set_Defensive_Mode")
end


--
-- Make the AI favor exploring the map. It will send many small groups of units all over the map.
-- It will fight a few small skirmish battles but it won't make concerted pushes against its
-- enemies.
--
function Story_AI_Set_Scouting_Mode(player)
	local ai_goal_controller = Get_Master_Unit_Goal_Controller(player)
	if not ai_goal_controller then
		return false
	end
	return ai_goal_controller.Call_Function("Set_Scouting_Mode")
end


--
-- Let the AI do its own thing. It will decide whether to attack/defend/explore as appropriate.
--
function Story_AI_Set_Autonomous_Mode(player)
	local ai_goal_controller = Get_Master_Unit_Goal_Controller(player)
	if not ai_goal_controller then
		return false
	end
	return ai_goal_controller.Call_Function("Set_Autonomous_Mode")
end

--
-- Have the AI attempt to maintain a collection of units.  The format for specifying the collection is:
-- UnitPoolDef = {}
-- UnitPoolDef[Find_Object_Type("Alien_Grunt")] = 5
-- UnitPoolDef[Find_Object_Type("Alien_Defiler") = 2
-- etc.
--
function Maintain_Unit_Pool(player, unit_pool_def)
	if not Lib_UnitPoolDef then
		Lib_UnitPoolDef = {}
	end
	
	if not Lib_MaintainUnitPoolThreads then
		Lib_MaintainUnitPoolThreads = {}
	end
	
	Lib_UnitPoolDef[player] = unit_pool_def
	if Lib_MaintainUnitPoolThreads[player] then
		Create_Thread.Kill(Lib_MaintainUnitPoolThreads[player])
	end
	Lib_MaintainUnitPoolThreads[player] = Create_Thread("Maintain_Unit_Pool_Internal", player)
end

function Maintain_Unit_Pool_Internal(player)
	local unit_pool_def = Lib_UnitPoolDef[player]
	
	while true do
		for unit_type, desired_count in pairs(unit_pool_def) do
			local current_and_under_construction_units = PG_Find_All_Objects_Of_Type(unit_type.Get_Name(), player)
			local num_instances_in_build_queues = PG_Count_Num_Instances_In_Build_Queues(unit_type, player)
			local existing_count = #current_and_under_construction_units + num_instances_in_build_queues
			
			if existing_count < desired_count then
				if TestValid(unit_type.Get_Type_Value("Tactical_Buildable_Beacon_Type")) then
					player.Activate_AI_Goal("Generic_Sub_Goal_Build_Structure", nil, { unit_type, desired_count - existing_count })
				elseif unit_type.Has_Behavior(BEHAVIOR_HARD_POINT, "Land") then
					player.Activate_AI_Goal("Generic_Sub_Goal_Build_Hard_Point", nil, { unit_type, desired_count - existing_count })
				else
					player.Activate_AI_Goal("Generic_Sub_Goal_Build_Unit", nil, { unit_type, desired_count - existing_count })
				end
			end
						
			Sleep(3)
		end
	end
end