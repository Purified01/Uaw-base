-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienReaperTurret.lua#47 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
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
--
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienReaperTurret.lua $
--
--    Original Author: 
--
--            $Author: Keith_Brors $
--
--            $Change: 84788 $
--
--          $DateTime: 2007/09/25 15:05:17 $
--
--          $Revision: #47 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
--/** @file */

require("PGBehaviors")
require("PGUICommands")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

	OwningPlayer = Object.Get_Owner()
	
	if resource_drone_search_radius == nil then
		resource_drone_search_radius = 250.0
	end

	--Current auto-gather target
	resource_drone_target = nil
	
	--Current target's score when we first initiated attack
	resource_drone_target_score = -1.0
	resource_drone_target_resource_time = 0.0		-- started when we lock, updated when resources are collected
	resource_drone_target_resources = 0.0

	-- we may need to look further and further away
	CurrentScanRange = resource_drone_search_radius
	CombatTarget = false
	Script.Set_Async_Data("ResourceFaction", ResourceFaction)
	
	ServiceRate = 0.6
	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()

	if OwningPlayer == nil or ResourceFaction == nil then
		return	-- data not set
	end
	
	if not TestValid( Object ) then
		return
	end
	
	if not Object.Can_Move() then
		CurrentScanRange = resource_drone_search_radius
		Sleep(2.0)
		return
	end
	
	
	-- If not auto-harvesting, do nothing
	if not Can_Auto_Harvest( ) then
		Unlock_From_Target()
		Sleep(1.0)
		return
	end
	
	-- Oksana: based on new design, we now consider targeting priorities when harvesting. 
	-- THerefore, we'll need to re-scan for new higher-priority targets every so often.
	--if resource_drone_target ~= nil then
		---- If we have a valid target, don't do anything	
		--local current_attack_target = Object.Get_Attack_Target()
		--if resource_drone_target == current_attack_target then
			--return
		--end
		--
		--local queued_attack_target = Object.Get_Queued_Attack_Target()
		--if resource_drone_target == queued_attack_target then
			--return
		--end	
	--end
		--
		
	Unlock_From_Target( false )
	
	-- We are idle, so try to find a decent target :)		
	Harvest_Resources()
	
	if not TestValid( resource_drone_target ) then
		CurrentScanRange = CurrentScanRange + 300.0
	elseif CurrentScanRange > resource_drone_search_radius then
		CurrentScanRange = resource_drone_search_radius
	end
	
	Sleep(0.75)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Unlock_From_Target( clear )

	if not TestValid(resource_drone_target) or not Is_Valid_Resource( resource_drone_target ) then
		-- if our target is dead or out of resources, reset the best scores
		resource_drone_target_score = -1.0
	else
		-- Release previous target if we had a target.  
		Set_Reserved( false )
	end
	
	if clear == nil or clear then
		resource_drone_target = nil	
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
function  Can_Auto_Harvest(  )
	local auto_harvest = Object.Get_Attribute_Value("Auto_Harvest")
	-- AI Reaper Turrets can never auto-harvest.
	-- Unless they are left IDLE (i.e. not recruited)
	if OwningPlayer.Is_AI_Player() and (Object.Is_AI_Recruited() or not Object.Is_AI_Recruitable() or not Object.Get_Owner().Get_Allow_AI_Unit_Behavior()) then
		-- If auto-harvest is turned on for this AI unit, turn it off.
		if auto_harvest > 0.0 then
			Object.Activate_Ability("Reaper_Auto_Gather_Resources", false)
		end
		return false
	end
	if OwningPlayer.Is_AI_Player() then
		if auto_harvest <= 0.0 then
			Object.Activate_Ability("Reaper_Auto_Gather_Resources", true)
		end
		return true
	else
		return auto_harvest > 0.0
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Valid_Resource
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Valid_Resource( test_resource, check_targeting )
	
	--Is a valid object
	if not TestValid(test_resource) then
		return false
	end
	
	-- Is a valid resource for my faction?
	if not test_resource.Get_Type().Resource_Is_Valid_For_Faction(ResourceFaction) then
		return false
	end
	
	--Is this resource empty?
	local resource_units = test_resource.Resource_Get_Resource_Units()
	if resource_units == nil or resource_units <= 1.0 then
		return false
	end

	-- This object does not have means to attack the target (harvest it)
	-- ignore fog (2nd parameter)
	if check_targeting and not Object.Is_Suitable_Target(test_resource, true) then
		return false
	end
		
	return true
end



-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Calc_Score - Given a minimum value, a maximum value, 'score' values for each extreme, and
-- a real number, return the appropriate 'score' given the given 'value's proximity to the
-- minimum and maximum extremes.
-- This is a rip-off version of Andre's AI script
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Calc_Score(min_val, min_score, max_val, max_score, value)
	if value <= min_val then
		return min_score
	end
	if value >= max_val then
		return max_score
	end
	local range_pct = (value - min_val) / (max_val - min_val)
	local score = range_pct * (max_score - min_score) + min_score
	return score
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Score_Unit - How useful would this unit be for accomplishing our goal?
-- This is a simplified version of Andre's AI script
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Score_Unit(unit)

	if not TestValid( unit ) then
		return 0.0
	end

	-- Calculate penalty based on Targeting Priority Set for this unit
	-- JSY: restored reaper use of targeting priority - it's useful to be able to dynamically
	-- change this for missions.  We'll just make sure that the default will eat anything.
	-- Also apply targeting priority before returning zero for non-resources, otherwise we
	-- can pick units as 'combat targets' that our priority set would normally disallow.
	
	-- KDB need a fix here to ignore exclusions for human and AI players
	
	local targeting_priority_score = Object.Get_Targeting_Priority_Score(unit)
	if targeting_priority_score < 0.0 then
		return -1.0
	end

	-- Needs to be a valid harvestable resource for this unit.
	local is_valid_resource = Is_Valid_Resource(unit, true)
	if is_valid_resource == false then
		return 0.0
	end

	if unit.Has_Behavior( BEHAVIOR_BRIDGE ) then
		return 0.0
	end
	
		-- Prefer units closest to the target.
	local distance = Object.Get_Distance(unit)
--	local distance_score = Calc_Score(200.0, 1.0, 3000.0, 0.5, distance)

	-- KDB distance score was reversed, but we don't care about distance now that we
	-- have an expanding radius to 'eat'
	local distance_score = 1.0
	
	if distance > resource_drone_harvest_distance then
		distance_score = 0.5 + 0.5 / distance
	else
		distance_score = 0.5 + ( resource_drone_harvest_distance - distance ) / 10.0
	end
	
	-- Slight penalty for small resource piles.
	local resources_remaining = unit.Resource_Get_Resource_Units()
	local resource_score = 1.0
	if resources_remaining < 5000.0 then
		resource_score = 0.8
	end

	if resources_remaining >= 100.0 and unit.Is_Category("Resource_INST") and distance <= 100.0 then
		resource_score = 2.0
	elseif resources_remaining < 20.0 then
		resource_score = 0.1
	end
	
	-- We don't really need more units to harvest us if we already have one.
	-- Apply a small score penalty if we've already directed a unit to harvest us.
	local concurrency_score = 1.0
	test_reserved = Get_Reserved( unit )
	if test_reserved == nil or test_reserved[OwningPlayer.Get_ID()].Used then
		concurrency_score = 0.85
	end
		
	local score = distance_score * resource_score * concurrency_score * targeting_priority_score
	return score
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Harvest Resources
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Harvest_Resources()
		
	local resource_list = Find_All_Objects_Of_Type( Object, CurrentScanRange )
	Sleep(0.2)
	
	if resource_list == nil then
		return 
	end
		
	local best_score = -1.0
	if TestValid( resource_drone_target ) and Is_Valid_Resource( resource_drone_target, true ) then
		best_score = resource_drone_target_score + 1.0  -- Start with current target and try to keep it by adding a value
	end
	
	local best_unit = resource_drone_target			-- Give current target priority
	
	local count = 0.0
	for _,unit in pairs(resource_list) do
		
		-- We don't want to be re-computing the score for our current target. 
		-- The score of current target will diminish with time as we deplete the resources.
		-- We want the Reaper to stick to its current target as long as possible.
		if unit ~= resource_drone_target then
			if TestValid( unit ) then
				local score = Score_Unit(unit)
				if score == 0.0 and Object.Get_Owner().Is_Enemy(unit.Get_Owner()) and Object.Is_Suitable_Target(unit, false, true) then
					if Object.Get_Distance(unit) <= 150.0 then
						local combat_score = 20000.0 - Object.Get_Distance(unit)
						if combat_score > best_score then
							best_score = combat_score
							best_unit = unit
						end
					end
				else
					-- regular resource object
					if Object.Is_Suitable_Target(unit, true) and score > 0.0 and score > best_score then
						best_score = score
						best_unit = unit
					end
				end
			end
		end
		
		count = count + 1.0
		
		if count >= 25 then
			count = 0.0
			Sleep(0.1)
		end

	end
	
	if best_score >= 10000.0 then
		CombatTarget = true
	else
		CombatTarget = false
	end

	local att_target = Object.Get_Attack_Target()

	-- Activate on the new target	
	if TestValid( best_unit ) and ( CombatTarget or Is_Valid_Resource(best_unit, true) ) and ( resource_drone_target ~= best_unit or att_target ~= best_unit ) then
		
		resource_drone_target = best_unit
		resource_drone_target_resource_time = GetCurrentTime()
		resource_drone_target_score = best_score
		resource_drone_target_resources = best_unit.Resource_Get_Resource_Units()
		
		-- Claim this unit (if not a combat target)
		if not CombatTarget then
			test_reserved = Get_Reserved( resource_drone_target )
			test_reserved[OwningPlayer.Get_ID()].Used = true
			resource_drone_target.Resource_Set_Reserved_For_Harvesting(test_reserved)
		end
	
		-- stop as we have a new target
		Object.Clear_Attack_Target()
		Object.Stop()

		-- give previous target time to be sucked up
		Sleep(0.1)

		if not TestValid( best_unit ) then
			-- target is dead
			resource_drone_target = nil
			resource_drone_target_score = -1.0
			return
		end
	
		-- Issue standard attack. Reaper will activate appropriate ability when in range.
		Object.Code_Compliant_Attack_Target(best_unit)
		
		-- wait to see if the target takes
		Sleep(0.1)
		
		-- make sure auto harvest is still on
		Object.Activate_Ability("Reaper_Auto_Gather_Resources", true)
		
		att_tgt = Object.Get_Attack_Target()
		
		if not TestValid( best_unit ) then
			-- target is dead
			resource_drone_target = nil
			resource_drone_target_score = -1.0
			return
		end
		
		if att_tgt == nil then
			-- can't lock on. move towards target
			local position = Project_Position( best_unit, Object, resource_drone_harvest_distance )
			if position == nil then
				-- target is dead
				resource_drone_target = nil
				resource_drone_target_score = -1.0
				return
			end
			
			Object.Move_To( position )
			Sleep(0.1)
			-- make sure auto harvest is still on
			Object.Activate_Ability("Reaper_Auto_Gather_Resources", true)
		end

	else
		if TestValid( resource_drone_target ) then
			local resources = resource_drone_target.Resource_Get_Resource_Units()
			if resources ~= resource_drone_target_resources then
				resource_drone_target_resource_time = GetCurrentTime()
				resource_drone_target_resources = resources
			elseif GetCurrentTime() > resource_drone_target_resource_time + 15.0 then
				-- too long, free up the target
				resource_drone_target = nil
				resource_drone_target_score = -1.0
				Object.Activate_Ability("Reaper_Harvest_Resource_Ability",false)
				Object.Clear_Attack_Target()
			end
		end
	end
	
end

  
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Get_Reserved()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Get_Reserved( my_resource )
	if TestValid( my_resource ) and not CombatTarget then
	
		local reserved
		local changed = false
		local pid = OwningPlayer.Get_ID()

		reserved = my_resource.Resource_Get_Reserved_For_Harvesting()
		
		if reserved == nil then
			reserved = {}
			changed = true
		end
		if reserved[pid] == nil then
			reserved[pid] = {}
			reserved[pid].Used = false
			changed = true
		end
		
		if changed then
			my_resource.Resource_Set_Reserved_For_Harvesting(reserved)
		end
		
		return reserved
		
	end
	
	return nil
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Set_Reserved()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Reserved( on_off )
	if TestValid( resource_drone_target ) and not CombatTarget then
	
		local reserved
		
		reserved = Get_Reserved( resource_drone_target )
		
		if reserved ~= nil then

			reserved[OwningPlayer.Get_ID()].Used = on_off
			resource_drone_target.Resource_Set_Reserved_For_Harvesting(reserved)
			
		end
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Zero Health handler
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Health_At_Zero()

	Unlock_From_Target( )

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Harvest_Resources = Harvest_Resources
my_behavior.Is_Valid_Resource = Is_Valid_Resource
my_behavior.Health_At_Zero = Behavior_Health_At_Zero
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
