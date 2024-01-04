-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Foo_Fighter_Unit_Behavior.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Foo_Fighter_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 84404 $
--
--          $DateTime: 2007/09/20 13:10:30 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")

ScriptShouldCRC = true

--A behavior that allows AI to take advantage of opportunities to trigger point blank area effect abilities.
--May be extended in the future to divert units to optimize AE use.

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	AllyUnits = {}
	AllyCount = 0
	TotalAllyCount = 0
	EnemyUnits = {}
	EnemyCount = 0
	TotalEnemyCount = 0
	EnemyFlyerCount = 0
	AllyDamagedCount = 0
	LowId = true
	FooCount = 0
	FooDamage = 1.0
	OtherDamage = 1.0
	
	Object.Event_Object_In_Range( Unit_Filter, FOO_FIGHTER.ABILITY_RANGE )
	
	OurId = tostring( Object.Get_ID() )

end

local function Behavior_Service()

	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then

		local heal_mode = false
		
		if AllyDamagedCount > 0 and EnemyCount < 1 then
			-- we can't do anything but heal
			heal_mode = true
		elseif EnemyFlyerCount > 0 then
			if FooCount > 1 and FooDamage <= 0.5 and LowId then
				-- 3 foo we will assign one to heal
				heal_mode = true
			elseif FooCount > 3 and FooDamage <= 0.75 and LowId then
				-- 5 foo we will assign one to heal
				heal_mode = true
			end
		elseif AllyDamagedCount > 0 then
			-- no enemy flyers
			if TotalAllyCount >= TotalEnemyCount and LowId then
				-- one healer as we are 'extra'
				heal_mode = true
			elseif TotalAllyCount * 2 >= TotalEnemyCount and ( OtherDamage <= 0.5 or FooDamage <= 0.75 ) and LowId then
				-- one healer as we have a badly damaged unit or a damaged foo core
				heal_mode = true
			elseif TotalAllyCount >= TotalEnemyCount * 2 and OtherDamage <= 0.5 then
				-- all heal we outnumber enemy greatly and we have severe damage
				heal_mode = true
			end
			
		end
		
		if heal_mode and not Object.Is_Ability_Active(FOO_FIGHTER.UNIT_ABILITY) then
			-- turn on heal
			Object.Activate_Ability(FOO_FIGHTER.UNIT_ABILITY,true)
		elseif not heal_mode and Object.Is_Ability_Active(FOO_FIGHTER.UNIT_ABILITY) then
			-- turn on attack
			Object.Activate_Ability(FOO_FIGHTER.UNIT_ABILITY,false)
		end
	else
		--Don't sleep - it will suppress any other LUA behavior attached to this unit
		--Sleep(1)
	end
	
	AllyUnits = {}
	AllyCount = 0
	TotalAllyCount = 0
	EnemyUnits = {}
	EnemyCount = 0
	TotalEnemyCount = 0
	EnemyFlyerCount = 0
	AllyDamagedCount = 0
	LowId = true
	FooCount = 0
	FooDamage = 1.0
	OtherDamage = 1.0
	
end

function Unit_Filter(self_obj, trigger_obj)

	if TestValid(trigger_obj) and Object ~= trigger_obj and not trigger_obj.Is_Category("Resource | Resource_INST") then

		if trigger_obj.Get_Owner().Is_Enemy(Object.Get_Owner()) then
			TotalEnemyCount = TotalEnemyCount + 1
		elseif trigger_obj.Get_Owner() == Object.Get_Owner() then
			TotalAllyCount = TotalAllyCount + 1
		end

		if not trigger_obj.Is_Category( FOO_FIGHTER.EXCLUDE_CATEGORY_FILTER ) then
			if trigger_obj.Get_Owner().Is_Enemy(Object.Get_Owner()) then
				if not EnemyUnits[trigger_obj] then
					EnemyUnits[trigger_obj] = trigger_obj
					EnemyCount = EnemyCount + 1
					if trigger_obj.Is_Category( "Flying" ) then
						EnemyFlyerCount = EnemyFlyerCount + 1
					end
				end
			elseif trigger_obj.Get_Owner() == Object.Get_Owner() then
				if not AllyUnits[trigger_obj] then
				
					AllyUnits[trigger_obj] = trigger_obj
					AllyCount = AllyCount + 1
					
					local health = trigger_obj.Get_Health()
					if health < 1.0 then
						AllyDamagedCount = AllyDamagedCount + 1
						if health < OtherDamage then
							OtherDamage = health
						end
					end
				
					if trigger_obj.Get_Type() == Object.Get_Type() then
						FooCount = FooCount + 1
						if health < FooDamage then
							FooDamage = health
						end
						if Object.Get_Health() < health then
							LowId = false
						else
							local other_id = tostring( trigger_obj.Get_ID() )
							if OurId > other_id and Object.Get_Health() <= health then
								LowId = false
							end
						end
					end
					
				end
			end
		end
		
	end

end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)