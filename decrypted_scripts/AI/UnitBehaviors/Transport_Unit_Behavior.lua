-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Transport_Unit_Behavior.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Transport_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: James_Yarrow $
--
--            $Change: 85145 $
--
--          $DateTime: 2007/09/29 16:10:58 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")
require("PGLogging")

ScriptShouldCRC = true

function Invasion_Transport_Idle_Thread()
	HasBeenIdle = false
	DropPosition = nil
	DropDone = false
	StartingHealth = Object.Get_Health()
	
	if TransportBehavior == nil or TransportBehavior.EjectAbility == nil or TransportBehavior.ResourceFaction == nil then
		-- error
		DropDone = true
	end
	
	while true do
		if Object.Get_Owner().Is_AI_Player() and Object.Get_Current_Garrisoned() > 0.0 then
			-- Owner is part of TacticalRetreat script
			if TestValid(Owner) or Object.Get_Current_Garrisoned() <= 0.0 then
				DropDone = true
			else
				-- looks like we are an attack transport with a garrison
				
				-- Under attack drop off the troops
				if Object.Get_Health() < 0.6 and Object.Get_Health() < StartingHealth then
					log("Transport_Unit_Behavior: Dropping units due to damage")
					Object.Activate_Ability(TransportBehavior.EjectAbility,true)
					DropDone = true
					Sleep(2.0)
				elseif not DropDone then
					DropPosition = Find_Drop_Off_Position()
					if TestValid(DropPosition) then
						log("Transport_Unit_Behavior: Moving towards drop position")
						BlockOnCommand(Object.Move_To(DropPosition),30)	-- block for 30 seconds at max
						log("Transport_Unit_Behavior: Dropping troops after moving")
						Object.Activate_Ability(TransportBehavior.EjectAbility,true)
					else
						log("Transport_Unit_Behavior: Can't find drop location, dropping troops now.")
						Object.Activate_Ability(TransportBehavior.EjectAbility,true)
					end
					
					DropDone = true
					Sleep(5.0)
				else
					-- maybe we're positioned over terrain that prevents
					-- deployment?  If so, we'll random walk until we're clear to land
					if not Object.Is_Ability_Ready(TransportBehavior.EjectAbility) then
						local move_to_pos = Object.Get_Position()	
						local delta_x = GameRandom.Get_Float(-100, 100)
						local delta_y = GameRandom.Get_Float(-100, 100)
						move_to_pos.Set_Position_X(move_to_pos.Get_Position_X() + delta_x)
						move_to_pos.Set_Position_Y(move_to_pos.Get_Position_Y() + delta_y)
						BlockOnCommand(Object.Move_To(move_to_pos), 5)
					end
					
					-- should have dropped off troops .... keep trying
					log("Transport_Unit_Behavior: Trying to drop off troops")
					Object.Activate_Ability(TransportBehavior.EjectAbility,true)
					Sleep(5.0)
				end
			end
		end
	
		Sleep(2.0)
	end	
end

function Move_Towards_Enemy( move_distance )

	-- default is where we are at
	local position = Object.Get_Position()

	local obj_list = Find_All_Objects_Of_Type( Object, 10000.0 )
	Sleep(0.1)

	local best_score = 999999.0
	local score_obj = nil
	for _,unit in pairs(obj_list) do
		
		if TestValid( unit ) and Object.Is_Enemy(unit.Get_Owner()) and unit.Is_Category("Stationary | Hero | Huge") then
			local score = Object.Get_Distance( unit )
			if score < best_score then
				best_score = score
				score_obj = unit
			end 
		end
		
	end
	
	if TestValid(score_obj) then
		if best_score > 1000.0 then
			return Project_Position(Object,score_obj,move_distance,15.0-GameRandom(0.0,30.0))
		elseif best_score > 400.0 then
			return Project_Position(Object,score_obj,best_score/2,20.0-GameRandom(0.0,40.0))
		end
	end
	
	return position
	
end

function Find_Drop_Off_Position()

	-- default is where we are at
	local position = Object.Get_Position()

	local player = Object.Get_Owner()
	if not TestValid(player) then
		return Find_Drop_Off_Position_Resource(position)
	end
	
	local obj_list = Find_All_Objects_Of_Type( "Stationary | Huge" )
	local best_target = nil
	
	if obj_list then
		
		for _,unit in pairs(obj_list) do
			if TestValid(unit) and player.Is_Enemy(unit.Get_Owner()) then
			
				local obj_type = unit.Get_Type()
				if TestValid(obj_type) and obj_type.Get_Type_Value("Is_Command_Center") then
					best_target = unit
					break
				end
				
				if best_target == nil then
					best_target = unit
				end
				
			end
		end
		
	end
	
	if not TestValid(best_target) then
		return Find_Drop_Off_Position_Resource(position)
	end
	
	local best_position = nil
	local best_range = 0.0
	local tgt_pos = best_target.Get_Position()
	
	for angle = 0.0, 360.0, 22.5 do
		local cur_pos = Project_Position(tgt_pos,tgt_pos,3250.0,angle)
		if TestValid(cur_pos) then
			local rg = best_target.Get_Distance(cur_pos)
			if rg > best_range then
				best_position = cur_pos
				best_range = rg
			end
		end
	end
	
	if TestValid(best_position) then
		return Find_Drop_Off_Position_Resource(best_position)
	end
	
	return Find_Drop_Off_Position_Resource(position)
	
end

function Find_Drop_Off_Position_Resource(target_pos)

	-- default is where we are at
	local position = Object.Get_Position()
	if TestValid(target_pos) then
		position = target_pos
	end

	if TransportBehavior.ResourceFaction == "Masari" then

		return position
	
	else
	 	
		local obj_list = Find_All_Objects_Of_Type( Object, 1000.0 )
		Sleep(0.1)
		
		local resource_list = {}
		
		for _,unit in pairs(obj_list) do
			local score = Get_Resources( unit )
			if score >= 500.0 then
				table.insert(resource_list,unit)
			end 
		end
		
		local best_score = 0.0
		local score_obj = nil
		
		if resource_list then
			for _,unit in pairs(resource_list) do
				
				if TestValid( unit ) then
					local score = Get_Resources( unit, resource_list ) 
					if score > best_score then
						best_score = score
						score_obj = unit
					end 
				end
				
			end
		end
		
		if TestValid(score_obj) then
			return score_obj.Get_Position()
		else
		
			return position
			
		end
	end
		
	return position
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Get_Resources
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Get_Resources( test_resource, res_list )
	
	--Is a valid object
	if not TestValid(test_resource) then
		return 0.0
	end
	
	-- Is a valid resource for my faction?
	if not test_resource.Get_Type().Resource_Is_Valid_For_Faction(TransportBehavior.ResourceFaction) then
		return 0.0
	end
	
	--Is this resource empty?
	local resource_units = test_resource.Resource_Get_Resource_Units()
	if resource_units == nil or resource_units <= 0 then
		return 0.0
	end

	if res_list == nil then
		return resource_units
	end
	
	-- add in other resource objects
	for _,unit in pairs(res_list) do
		if TestValid(unit) and unit ~= test_resource and unit.Get_Distance(test_resource) < 175.0 then
			resource_units = resource_units + Get_Resources( unit ) * 0.75
		end
	end
	
	return resource_units
end


function Behavior_First_Service()
	LOGFILE_NAME = "TransportUnitBehavior.txt"
end

--Do this just to prevent complaints since we're attaching this as a behavior
local my_behavior = 
{
	Name = _REQUIREDNAME
}

my_behavior.First_Service = Behavior_First_Service

Register_Behavior(my_behavior)