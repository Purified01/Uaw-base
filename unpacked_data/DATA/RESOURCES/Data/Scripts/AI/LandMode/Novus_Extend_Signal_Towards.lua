-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Extend_Signal_Towards.lua#13 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Novus_Extend_Signal_Towards.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 79681 $
--
--          $DateTime: 2007/08/03 10:34:36 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "NOVUS") then
		Goal.Suppress_Goal()
		return 0.0
	end

	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not Target.Is_Ally(Player) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local object_target = Target.Get_Game_Object()
	if (not object_target) or (Target.Get_Target_Type() ~= "Game_Object") then
		Goal.Suppress_Goal()
		return 0.0
	end

	-- don't power towers that will happen automatically	
	if object_target.Get_Type() == Find_Object_Type("Novus_Signal_Tower") then
		return 0.0
	end

	-- if we have power then we are done	
	if Object_Has_Power( object_target ) then
		return 0.0
	end
	
	if object_target.Get_Owner() ~= Player then
		return 0.0
	end
	
	local transmitter_type = Find_Object_Type("Novus_Signal_Tower")
	if transmitter_type == nil then
		return 0.0
	end
	
	local signal_radius = transmitter_type.Get_Attribute_Value("Type_Novus_Power_Powerup_Radius")
	
	if not Goal.Is_Active() then
		existing_towers = Find_All_Objects_Of_Type(transmitter_type.Get_Type_Value("Tactical_Under_Construction_Object_Type"), Player, Target, signal_radius)
		if existing_towers and #existing_towers > 0 then
			return 0.0
		end	
		
		existing_towers = Find_All_Objects_Of_Type(transmitter_type.Get_Type_Value("Tactical_Buildable_Beacon_Type"), Player, Target, signal_radius)
		if existing_towers and #existing_towers > 0 then
			return 0.0
		end
	end	

	-- make sure stuff is powered !	
	return 3.0
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Object_Has_Power
-- ------------------------------------------------------------------------------------------------------------------
function Object_Has_Power( object )
	if TestValid( object ) then
		if object.Has_Behavior( BEHAVIOR_POWERED ) then
			if object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
				return false
			end
		end
	end
	
	return true
end

function Score_Unit(unit)
	return 0.0
end

function On_Activate()

	local transmitter_type = Find_Object_Type("Novus_Signal_Tower")
	
	if transmitter_type == nil then
		return
	end

	local signal_radius = transmitter_type.Get_Attribute_Value("Type_Novus_Power_Powerup_Radius")

	Create_Thread("Mark_Build_Location")
	
	Suppress_Nearby_Goals(Target, signal_radius, "Novus_Extend_Signal_Towards", 15.0)	-- can be slow to respond so keep this low
	
	if power_router_type == nil then
		power_router_type = Find_Object_Type("Novus_Power_router")
	end
	
end

function Service()

	local transmitter_type = Find_Object_Type("Novus_Signal_Tower")
	
	if transmitter_type == nil then
		return
	end

	local signal_radius = transmitter_type.Get_Attribute_Value("Type_Novus_Power_Powerup_Radius")

	Suppress_Nearby_Goals(Target, signal_radius, "Novus_Extend_Signal_Towards", 5)
	if build_position then
		Suppress_Nearby_Goals(build_position, signal_radius, "Novus_Extend_Signal_Towards", 5)
	end	
end

function Mark_Build_Location()

	local transmitter_type = Find_Object_Type("Novus_Signal_Tower")
	
	if transmitter_type == nil then
		ScriptExit()
	end

	-- check for power router, if none exit the script
	if not Have_Power_Router() then
		ScriptExit()
	end

	existing_transmitter = Find_Nearest_Signal_Transmitter(Target, Player)
	
	if not TestValid(existing_transmitter) then
		ScriptExit()
	end
	
	local target_position = Target.Get_Target_Position()
	
	if not target_position then
		ScriptExit()
	end
	
	local transmit_distance = existing_transmitter.Get_Attribute_Value("Novus_Power_Transmission_Radius")
	
	if not transmit_distance or transmit_distance < 10.0 then
		ScriptExit()
	end

	local distance_between = existing_transmitter.Get_Distance(target_position)
	
	local mid_point
	if transmit_distance < distance_between then
		mid_point = Project_Position(existing_transmitter,target_position,transmit_distance * 0.85)
	else
		mid_point = target_position
	end

	build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( mid_point, transmitter_type, Player ))
	if build_position and existing_transmitter.Get_Distance(build_position) > transmit_distance then
		mid_point = Project_Position(existing_transmitter,target_position,transmit_distance * 0.49)
		build_position = BlockOnCommand(Find_Nearest_Open_Build_Position( mid_point, transmitter_type, Player ))
	end
	
--	if TestValid(existing_transmitter) then
--		build_position = BlockOnCommand(Find_Constrained_Build_Position(Target, transmitter_type, Player, existing_transmitter, existing_transmitter.Get_Attribute_Value("Novus_Power_Transmission_Radius")))
--	else
--		build_position = Target
--	end
	
	if not build_position then
		ScriptExit()
	end
	
	build_target = Goal.Create_Custom_Target(build_position)
	Sleep(0.25)
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", build_target, transmitter_type))
	ScriptExit()

end

function Find_Nearest_Signal_Transmitter(source, player)
	
	nearest_transmitter = nil
	closest_distance = 0.0
	
	all_towers = Find_All_Objects_Of_Type("Novus_Signal_Tower", player)
	Sleep(0.25)
	for _, tower in pairs(all_towers) do
		if TestValid(tower) then
			distance = tower.Get_Distance(source)
			if not TestValid(nearest_transmitter) or distance < closest_distance then
				nearest_transmitter = tower
				closest_distance = distance
			end
		end
	end
	
	all_power_routers = Find_All_Objects_Of_Type("Novus_Power_Router", player)
	Sleep(0.25)
	for _, router in pairs(all_power_routers) do
		if TestValid(router) then
			distance = router.Get_Distance(source)
			if not TestValid(nearest_transmitter) or distance < closest_distance then
				nearest_transmitter = router
				closest_distance = distance
			end
		end
	end	
	
	return nearest_transmitter
	
end

function Have_Power_Router()
	if not TestValid(power_router_type ) then
		return false
	end
	
	all_routers = Find_All_Objects_Of_Type(power_router_type, Player)
	
	if all_routers == nil or #all_routers < 1 then
		return false
	end

	return true
	
end