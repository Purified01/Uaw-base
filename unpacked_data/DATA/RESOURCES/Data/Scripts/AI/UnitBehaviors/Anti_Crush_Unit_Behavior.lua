-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Anti_Crush_Unit_Behavior.lua#15 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Anti_Crush_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 84404 $
--
--          $DateTime: 2007/09/20 13:10:30 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")

function Check_For_Crushers(object, search_range, kite_range, crush_defense )

	local obj_list = {}
	
	-- the following is a global used by defensiveAI
	AntiCrushUnitBehaviorActionTaken = false

	if AIDefensiveIsRetreating then
		return false, obj_list
	end

	if not Object.Get_Owner().Get_Allow_AI_Unit_Behavior() then
		return false, obj_list
	end
	
	if not TestValid(object) or object.Is_Phased() or not object.Is_AI_Recruitable() or not object.Can_Move() then
		return false, obj_list
	end

	if object.Is_Flying() and object.Get_Attribute_Value( "Is_Grounded" ) == 0 then
		return false, obj_list
	end

	local player = object.Get_Owner()
	if not TestValid(player) then
		return false, obj_list
	end
	
	if player.Get_Difficulty() == "Difficulty_Easy" then
		return false, obj_list
	end

	obj_list = Find_All_Objects_Of_Type( object, search_range, "~Insignificant + Stationary + ~Resource + ~Resource_INST + ~Bridge | CanAttack" )
	
	if not crush_defense or crush_defense >= 99.0 then
		return false, obj_list
	end
	
	if player.Get_Difficulty() ~= "Difficulty_Hard" and GameRandom(0,100) < 80 then
		return false, obj_list
	end
	
	local final_obj_list = {}
	
	for _,unit in pairs(obj_list) do
		if TestValid(unit) then
			if player.Is_Enemy(unit.Get_Owner()) and not unit.Is_Phased() and not unit.Is_Death_Clone() and not unit.Is_Cloaked() then
				if not unit.Is_Flying() or unit.Get_Attribute_Value( "Is_Grounded" ) ~= 0 then
					if unit.Has_Behavior(BEHAVIOR_HARD_POINT) then
						local parent = unit.Get_Highest_Level_Hard_Point_Parent()
						if TestValid(parent) then
							final_obj_list[parent]=parent	
						end
					else
						final_obj_list[unit]=unit	
					end
				end
			end
		end
	end
	
	local best_distance = 999999.0
	local close_crusher = nil
	
	for _,unit in pairs(final_obj_list) do
		if TestValid(unit) then
			-- can it crush us?
			local enemy_type = unit.Get_Type()
			if TestValid(enemy_type) and unit.Can_Move() then
				local crush_value = enemy_type.Get_Type_Value("Crush_Power")
				if crush_value ~= nil and crush_value > crush_defense then
					local xextent = enemy_type.Get_Hard_Coord_Radius()
					local distance = object.Get_Distance( unit )
					distance = distance - xextent
					if distance < best_distance then
						best_distance = distance
						close_crusher = unit
					end
				end
			end
		end
	end
	
	if TestValid(close_crusher)then
		if best_distance < kite_range * 0.8 then
			local xextent = close_crusher.Get_Type().Get_Hard_Coord_Radius()
			local def_pos = Project_Position(close_crusher, object, kite_range + xextent, 40.0 - GameRandom(0.0, 80.0))
			object.Move_To(def_pos)
		end
		
		if best_distance < kite_range then
			AntiCrushUnitBehaviorActionTaken = true
			return true, final_obj_list
		end

		return false, final_obj_list
	end

	return false, final_obj_list
	
end

function Check_To_Crush(object, obj_list, crush_range, crush_attack )

	if AIDefensiveIsRetreating then
		return false
	end

	if not TestValid(object) or crush_attack <= 0.0 or obj_list == nil or object.Is_Phased() or not object.Is_AI_Recruitable() then
		return false
	end

	if object.Is_Flying() and object.Get_Attribute_Value( "Is_Grounded" ) == 0 then
		return false
	end

	local player = object.Get_Owner()
	if not TestValid(player) then
		return false
	end

	if player.Get_Difficulty() == "Difficulty_Easy" then
		return false
	end

	if player.Get_Difficulty() ~= "Difficulty_Hard" and GameRandom(0,100) < 60 then
		return false
	end

	local crusher_type = object.Get_Type()
	
	if not TestValid(crusher_type) then
		return false
	end

	local crusher_radius = crusher_type.Get_Hard_Coord_Radius()

	local best_distance = crush_range
	local close_crushee = nil
	
	if TestValid(CrushTarget) then
		local best_distance = object.Get_Distance( CrushTarget ) * 0.7
		local close_crushee = CrushTarget 
	else
		CrushTarget = nil
		CrushTargetPosition = nil
	end
	
	for _,unit in pairs(obj_list) do
		if TestValid(unit) and player.Is_Enemy(unit.Get_Owner()) then
			-- can we crush it
			local enemy_type = unit.Get_Type()
			if TestValid(enemy_type) and ( not GenericVehicle.CrushStationaryOnly or not unit.Can_Move() ) then
				local crush_value = enemy_type.Get_Type_Value("Crush_Defense")
				if crush_value ~= nil and crush_value < crush_attack then
					local distance = object.Get_Distance( unit )
					if distance < best_distance then
						best_distance = distance
						close_crushee = unit
					end
				end
			end
		end
	end

	if TestValid(close_crushee) then
		-- project through target
		local att_pos = Project_Position( object, close_crushee, best_distance + 10.0 + crusher_radius + GenericVehicle.MoveThroughDistance )
		local issue_move_order = true
		if TestValid(CrushTargetPosition) and Object.Is_Moving() and not GenericVehicle.CrushAlwaysDoMove then
			if CrushTargetPosition.Get_Distance( att_pos ) < 5.0 + crusher_radius / 4 then
				issue_move_order = false
			end
		end
		if issue_move_order then
			object.Move_To(att_pos)
			CrushTargetPosition = att_pos
		end
		CrushTarget = close_crushee
		AntiCrushUnitBehaviorActionTaken = true
		if Object.Is_Category("Huge") then
			Sleep(15.0)
		end
		return true
	end

	return false
	
end
