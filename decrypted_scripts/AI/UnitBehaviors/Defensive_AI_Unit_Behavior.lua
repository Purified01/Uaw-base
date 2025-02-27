if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[18] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Defensive_AI_Unit_Behavior.lua#13 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Defensive_AI_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	FriendlyStructureList = {}
	CommandCenter = nil
	AIDefensiveIsRetreating = false
	AIDefensiveIsActing = false
	
	if not DefensiveAI then
		DefensiveAI = {}
	end
	
	if not DefensiveAI.KillTurret then
		DefensiveAI.KillTurret = false
	end
		
	if not DefensiveAI.KillTurretRange then
		DefensiveAI.KillTurretRange = 0.0
	end
				
	RunDistance = 400.0
	if DefensiveAI.RunDistance then
		RunDistance = DefensiveAI.RunDistance
	end

	RunHealth = 0.0
	if DefensiveAI.RunHealth then
		RunHealth = DefensiveAI.RunHealth
	end

	LastHealth = Object.Get_Health()
	
	DefensiveAICaptureList = nil
	DefensiveThreadID = nil
	DefensiveAIRetreatPosition = nil
	
	RedirectionTurretType = Find_Object_Type("Novus_Redirection_Turret")
	
	ObjectList = {}
	
	if DefensiveAI.AttackCatMinRange == nil then
		DefensiveAI.AttackCatMinRange = 0.0
	end
	
	LastRunFromTarget = nil
	
end

local function Behavior_Service()

	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and ( DefensiveAI.UsableByAI or Object.Is_AI_Recruitable() ) then
		if not DefensiveThreadID then
			DefensiveThreadID = Create_Thread("Defensive_Thread")
		end
	elseif DefensiveThreadID then
		Create_Thread.Kill(DefensiveThreadID)
		DefensiveThreadID = nil
	end
end

--Thread this so that the slow service rate doesn't interfere with other LUA behaviors
function Defensive_Thread()
	while true do

		Find_Command_Center()
		
		Object.Prevent_Opportunity_Fire(false)
		if not AntiCrushUnitBehaviorActionTaken then
		
			ObjectList = Find_All_Objects_Of_Type( Object, 350.0, "CanAttack + ~Resource + ~Resource_INST | Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST" )
		
			if not Unit_Activate_Ability() then
				if not Should_Retreat() or ( DefensiveAI.AttackCatRetreatHealth and Object.Get_Health() >= DefensiveAI.AttackCatRetreatHealth ) then
					if not DefensiveAI.AttackCat or not Attack_Category(DefensiveAI.AttackCat,DefensiveAI.AttackCatExclude,DefensiveAI.AttackCatMinRange) then
						if not AIDefensiveIsRetreating and (not DefensiveAI.AttackStationary or not Attack_Category("Stationary",nil,75.0)) then
							if Check_for_Enemy() then
								Redirect_Turret()
							end
							
							Check_To_Capture()
						end
					end
				end
			end
			
		end
		
		LastHealth = Object.Get_Health()
		
		Sleep( 2.0 + GameRandom.Get_Float(0.0,0.3) )
		
	end
end

function Unit_Activate_Ability()

	if DefensiveAI.Abilities and #DefensiveAI.Abilities > 0 then

		local player = Object.Get_Owner()
		if not TestValid(player) then
			-- bad player skip all other checks
			return true
		end

		for _, ability in pairs (DefensiveAI.Abilities) do
			local count = 0.0
			if ability.Name and Object.Is_Ability_Ready(ability.Name) then
	
				if ObjectList then
					for _, unit in pairs (ObjectList) do
						if TestValid( unit ) and player.Is_Enemy(unit.Get_Owner()) then
							local range = Object.Get_Distance(unit)
							local target_type = unit.Get_Type()
							if TestValid(target_type) and not unit.Is_Cloaked() and not unit.Is_Death_Clone() and not unit.Is_Phased() and
							(not ability.Category or unit.Is_Category(ability.Category)) and (not ability.ExcludeCategory or not unit.Is_Category(ability.ExcludeCategory)) and
							range <= ability.Range and ( not ability.NoCollectors or not target_type.Get_Type_Value("Is_Resource_Collector") ) then
								count = count + 1
								if not ability.Count or count >= ability.Count then
									Object.Activate_Ability(ability.Name,true,Object.Get_Position())
									AIDefensiveIsActing = true
									return true
								end
							end
						end
					end
				end
	
			end
			
		end
	end
	
	return false
end

function Attack_Category( target_cat, exclude_cat, min_range )

	local player = Object.Get_Owner()
	if not TestValid(player) then
		-- bad player skip all other checks
		return true
	end

	local att_target = Object.Get_Current_Attack_Object()
	
	if TestValid(att_target) and not att_target.Is_Cloaked() and not att_target.Is_Death_Clone() and
	not att_target.Is_Phased() and Object.Is_Suitable_Target(att_target, false, true) and player.Is_Enemy(att_target.Get_Owner()) and
	att_target.Is_Category(target_cat) and (not exclude_cat or not att_target.Is_Category(exclude_cat)) then
		return true
	end

	local best_rating = 0.0
	local best_target = nil

	if ObjectList then
		for _, unit in pairs (ObjectList) do
			if TestValid( unit ) and player.Is_Enemy(unit.Get_Owner()) then
				if not unit.Is_Cloaked() and not unit.Is_Death_Clone() and not unit.Is_Phased() and Object.Is_Suitable_Target(unit, false, true) and
				unit.Is_Category(target_cat) and (not exclude_cat or not unit.Is_Category(exclude_cat)) then

					local range = unit.Get_Distance(Object)
					local value = 250.0 - range
					if unit.Is_Category("CanAttack") then
						if range < min_range then
							-- allow other behaviors
							return false
						end
						value = value * 2
					end
					
					if value > best_rating then
						best_rating = value
						best_target = unit
					end
					
				end
			end
		end
	end
	
	if TestValid(best_target) then
		Object.Code_Compliant_Attack_Target(best_target)
		AIDefensiveIsActing = true
		return true
	end
	
	return false
	
end

function Find_Command_Center()

	if not TestValid(CommandCenter) or CommandCenter.Get_Owner() ~= Object.Get_Owner() then
		local obj_list = Find_All_Objects_Of_Type( Object.Get_Owner(), "Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST" )
		if obj_list then
			for _, unit in pairs (obj_list) do
				if TestValid( unit ) then
					local unit_type = unit.Get_Type()
					if TestValid( unit_type ) then
						if unit_type.Get_Type_Value("Is_Command_Center") then
							CommandCenter = unit
							return
						end
					end
				end
			end
		end
	end
	
end

function Should_Retreat()

	AIDefensiveIsRetreating = false
	AIDefensiveIsActing = false

	local hero = Object.Is_Category("Hero")
	local command_center_valid = false
	
	if TestValid(CommandCenter) then
		command_center_valid = true
	end
	
	if not hero and not command_center_valid then
		DefensiveAIRetreatPosition = nil
		return false
	end

	if command_center_valid and Object.Get_Distance(CommandCenter) < RunDistance then
		DefensiveAIRetreatPosition = nil
		return false
	end

	local health = Object.Get_Health()
	local cur_time = GetCurrentTime()
	
	-- add a check so that heroes always retreat early in the battle
	if health >= RunHealth and ( not hero or health >= 1.0 or cur_time > 180.0 ) then
		if Object.Is_AI_Recruited() then
			DefensiveAIRetreatPosition = nil
			return false
		end
		
		if RunHealth <= 0.7 and health > 0.7 and not Object.Is_Flying() then
			DefensiveAIRetreatPosition = nil
			return false
		end	

		if health >= 1.0 then
			DefensiveAIRetreatPosition = nil
			return false
		end
	end
	
	-- run for home
	AIDefensiveIsRetreating = true
	if command_center_valid and ( health > 0.2 or not hero ) then
		Object.Move_To(CommandCenter)
		Sleep(1.0)
		DefensiveAIRetreatPosition = CommandCenter.Get_Position()
	else
		local player = Object.Get_Owner()
		if not TestValid(player) then
			DefensiveAIRetreatPosition = nil
			return false
		end

		-- On easy and medium mode reduce this chance
		-- easy fight to the death
		if player.Get_Difficulty() == "Difficulty_Easy" and cur_time < 180.0 then
			DefensiveAIRetreatPosition = nil
			return false
		end

		-- medium fight to the death most of the time
		-- if we are past 4 minutes
		if player.Get_Difficulty() ~= "Difficulty_Hard" and cur_time > 240.0 and GameRandom(0,100) < 80 then
			DefensiveAIRetreatPosition = nil
			return false
		end

		local run_from = Object.Get_Attack_Target()
		local obj_distance = 999999.0

		if TestValid(LastRunFromTarget) then
			run_from = LastRunFromTarget
			obj_distance = Object.Get_Distance(LastRunFromTarget)
		end
	
		if not TestValid(run_from) or obj_distance > 200.0 then
			if ObjectList then
				for _, unit in pairs (ObjectList) do
					if TestValid(unit) then
						if player.Is_Enemy(unit.Get_Owner()) then
							if not unit.Is_Cloaked() and not unit.Is_Death_Clone() and not unit.Is_Phased() then
								local enemy_rg = unit.Get_Distance(Object)
								if not unit.Is_Category("CanAttack") then
									enemy_rg = enemy_rg * 2.0
								end
								if enemy_rg < obj_distance then
									obj_distance = enemy_rg
									run_from = unit
								end
							end
						end
					end
				end
			end
		end

		local att_obj = run_from

		if not TestValid(run_from) then
			run_from = Object
		elseif run_from.Is_Category("CanAttack") then
			LastRunFromTarget = run_from
		end

		local best_distance = 0.0
		local best_position = nil
		
		for angle = -90.0, 90.0, 45.0 do
			local run_pos = Project_Position(run_from, Object, 2000.0 )
			if TestValid(run_pos) then
				local run_distance = run_pos.Get_Distance(run_from)
				if run_distance > best_distance then
					best_distance = run_distance
					best_position = run_pos
				end
			end
		end
		
		-- keep running to original retreat position if we have no target or near object
		if TestValid(DefensiveAIRetreatPosition) and not TestValid(att_obj) then
			best_position = DefensiveAIRetreatPosition
		end
		
		if TestValid(best_position) then
			Object.Move_To(best_position)
			Sleep(1.0)
			DefensiveAIRetreatPosition = best_position
		end
		
	end

	return true

end

function Check_for_Enemy()

	-- the following is a global set by anti-crush, if true it is dodging or crushing, both of which are higher priority than this
	if AntiCrushUnitBehaviorActionTaken then
		-- true is to check for redicretion turrets
		return false
	end
	
	if DefensiveAI.NoAttacking then
		return false
	end

	local our_type = Object.Get_Type()
	if not TestValid(our_type) then
		return false
	end

	local att_target = Object.Get_Current_Attack_Object()

	local player = Object.Get_Owner()
	if not TestValid(player) then
		return false
	end

	local is_hero_taking_damage = false
	local cur_health  = Object.Get_Health()
	if DefensiveAI.IgnoreHealth or ( LastHealth > cur_health and ( cur_health <= 0.25 or Object.Is_Category("Hero") or DefensiveAI.AllwaysAttack ) ) then
		is_hero_taking_damage = true
	end
	
	local max_target_distance = our_type.Get_Type_Value("Targeting_Max_Attack_Distance")
	if not max_target_distance then
		max_target_distance = 10.0
	end
	
	if TestValid(att_target) and att_target.Is_Category("CanAttack") then
		-- already involved in a battle and attacking something that is armed and in range
		-- but allow killing of redirection turrets
		return true
	end

	if not is_hero_taking_damage and Object.Is_AI_Recruited() and not DefensiveAI.AlwaysAttack then
		-- true is to attack towers
		return true
	end

	local obj_list = nil
	--if is_hero_taking_damage and not DefensiveAI.IgnoreHealth then
--		obj_list = Find_All_Objects_Of_Type( Object,"CanAttack", 440.0 )
--	else
--		obj_list = Find_All_Objects_Of_Type( Object,"Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST | CanAttack", 440.0 )
--	end
	
	local target = nil
	local target_range = 999999.0

	local range_to_com = 0.0
	if TestValid(CommandCenter) then
		range_to_com = Object.Get_Distance(CommandCenter)
	end
	
	if ObjectList then
		for _, unit in pairs (ObjectList) do
			if TestValid(unit) then
				if player.Is_Enemy(unit.Get_Owner()) then
					if not unit.Is_Cloaked() and not unit.Is_Death_Clone() and not unit.Is_Phased() and Object.Is_Suitable_Target(unit, false, true) then
						local range = Object.Get_Distance(unit)
						if range_to_com <= 600.0 or (range < 300.0 and range < target_range) then
							target = unit
							target_range = range
						end
					end
				elseif player == unit.Get_Owner() and unit.Is_Category("Stationary | Huge + CanAttack") then
					if FriendlyStructureList[unit] == nil then
						FriendlyStructureList[unit]={}
						FriendlyStructureList[unit].Unit=unit
						FriendlyStructureList[unit].LastHealth = unit.Get_Health()
					end
				end
			end
		end
	end
	
	-- search for enemy near damaged structure?
	if target == nil then

		local protect_list = {}
		local count = 1
		local help_range = 550.0
		if DefensiveAI.AllwaysAttack then
			help_range = 400.0
		end

		for _, unit_info in pairs (FriendlyStructureList) do
			local unit = unit_info.Unit
			if TestValid(unit) and unit.Get_Owner() == player and Object.Get_Distance(unit) < help_range then
				
				if unit_info.LastHealth > unit.Get_Health() then
					protect_list[count]=unit
					count = count + 1
				end
				
				unit_info.LastHealth = unit.Get_Health()
				
			else
				FriendlyStructureList[unit]=nil
			end
		end

		if #protect_list > 0 then
			protect_index = GameRandom(1,#protect_list)
			
			local protect_unit = protect_list[protect_index]
			
			local obj_list = Find_All_Objects_Of_Type( protect_unit,"CanAttack", 350.0 )
			
			if obj_list then
				for _, unit in pairs (obj_list) do
					if TestValid(unit) then
						if player.Is_Enemy(unit.Get_Owner()) and Object.Is_Suitable_Target(unit, false, true) and not unit.Is_Cloaked() and not unit.Is_Phased() then
							local range = Object.Get_Distance(unit)
							if range < target_range then
								target = unit
								target_range = range
							end
						end
					end
				end
			end
			
		end
		
	end
	
	if TestValid(target) then
	
		if Object.Is_Category("Huge") and target_range > 50.0 and target_range > max_target_distance * 0.8 then
			Object.Move_To(target.Get_Position())
			AIDefensiveIsActing = true
			-- KDB Give the walker time to move as re-issuing commands to a walker really messes up its movement (bug?)
			Sleep(15.0)
		else
			Object.Code_Compliant_Attack_Target(target)
			AIDefensiveIsActing = true
		end
		
		if target.Get_Type() == RedirectionTurretType then
			return true
		end
		
		return false
			
	end
		
	return true
		
end

function Redirect_Turret()

	if DefensiveAI and DefensiveAI.KillTurret ~= nil and DefensiveAI.KillTurret and not AIDefensiveIsRetreating and not AntiCrushUnitBehaviorActionTaken then
	
		local obj_list = Find_All_Objects_Of_Type( Object,"Novus_Redirection_Turret", 250.0 )

		local target = nil
		local target_range = 999999.0

		local player = Object.Get_Owner()
		if not TestValid(player) then
			return
		end
		
		if obj_list then
			for _, unit in pairs (obj_list) do
				if TestValid(unit) then
					if player.Is_Enemy(unit.Get_Owner()) and Object.Is_Suitable_Target(unit, false, true) then
						if not unit.Is_Cloaked() and not unit.Is_Phased() then
							local range = Object.Get_Distance(unit)
							if range < target_range then
								target = unit
								target_range = range
							end
						end
					end
				end
			end
		end
		
		if TestValid(target) then
		
			AIDefensiveIsActing = true
			Object.Prevent_Opportunity_Fire(true)
			if target_range > DefensiveAI.KillTurretRange then
				-- get under redirect field range
				local pos = Project_Position(target,Object,DefensiveAI.KillTurretRange,45.0-GameRandom(0.0,90.0))
				if pos then
					Object.Clear_Attack_Target()
					Object.Parameterized_Move_Order(pos,"No_Formup")
				end
			else
				local att_target = Object.Get_Attack_Target()
				if att_target ~= target then
					Object.Clear_Attack_Target()
				end
				Object.Code_Compliant_Attack_Target(target)
			end
			
		end
	end

end

---------------------------------------------------------------------
-- Check_To_Capture : see if this units is made to capture and if so is there something to capture
---------------------------------------------------------------------
function Check_To_Capture()

	if AntiCrushUnitBehaviorActionTaken then
		return
	end

	local att_target = Object.Get_Current_Attack_Object()
	
	if TestValid(att_target) then
		return
	end
	
	if DefensiveAI.CaptureAbility == nil then
		return
	end

	if Object.Is_Ability_Active(DefensiveAI.CaptureAbility) or not Object.Is_Ability_Ready(DefensiveAI.CaptureAbility) then
		return
	end

	-- build capture list once
	if DefensiveAICaptureList == nil then
	
		DefensiveAICaptureList = {}
		
		local obj_list = Find_All_Objects_Of_Type( "Stationary" )	
	
		for _, unit in pairs (obj_list) do
			if TestValid(unit) then
				local obj_type = unit.Get_Type()
				if TestValid(obj_type) and obj_type.Get_Type_Value("Seconds_To_Capture") > 0.0 then
					table.insert(DefensiveAICaptureList,unit)
				end
			end
		end
	end
	
	if DefensiveAICaptureList ~= nil and #DefensiveAICaptureList > 0 then

		local player = Object.Get_Owner()
		if not TestValid(player) then
			return
		end
	
		local best_neutral = nil
		local neutral_range = 500.0
		if not Object.Is_AI_Recruited() and GameRandom(1,100) == 50 then
			-- a small chance to find far away neutrals
			neutral_range = 4000.0
		end
		
		for index, unit in pairs (DefensiveAICaptureList) do
			if TestValid(unit) then
				if player ~= unit.Get_Owner() then
					local range = Object.Get_Distance(unit)
					if range < neutral_range then
						neutral_range = range
						best_neutral = unit
					end
				end
			else
				table.remove(DefensiveAICaptureList,index)
			end
		end
		
		if TestValid(best_neutral) then
			AIDefensiveIsActing = true
			if neutral_range < 100.0 then
				Object.Clear_Attack_Target()
				Object.Stop()
				Object.Activate_Ability(DefensiveAI.CaptureAbility,true,best_neutral)				
			else
				Object.Clear_Attack_Target()
				Object.Move_To(best_neutral)
				Sleep(1.0)
			end
		end
		
	end
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
