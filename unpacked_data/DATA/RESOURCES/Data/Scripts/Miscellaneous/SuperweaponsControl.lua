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
--             File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/SuperweaponsControl.lua
--
--    Original Author: Chris_Brooks
--
--          DateTime: 2006/11/28 18:20:14 
--
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGBase")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Superweapons_Data
-- ------------------------------------------------------------------------------------------------------------------
function Init_Superweapons_Data()
	
	-- Structures that enable the use of a given superweapon.  Each enabler has a SuperWeaponEnablerBehavior in which we 
	-- specify which weapon type is assigned to it.
	SuperweaponEnablers = {}
	
	-- Maria 11.16.2006 - since there may be several sw enablers (all of the same type), we need to know how many 
	-- different weapon types are available at all times so that we can properly update the sw buttons.
	WeaponTypeNameToCount = {} 
	WeaponTypeNameToCooldownTime = {}
	WeaponTypeNameToResourceRequirements = {}
	WeaponTypeToWeaponStateTable = {}
	Script.Set_Async_Data("WeaponTypeToWeaponStateTable", WeaponTypeToWeaponStateTable)
	SWTimerUpdateTime = GetCurrentTime()
	-- each weapon has it's own timer
	SuperweaponTimers = {}
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Superweapon_Enabler_Created
-- ------------------------------------------------------------------------------------------------------------------
function On_Superweapon_Enabler_Created(enabler, superweapon_type_name)
	if not TestValid(enabler) or SuperweaponEnablers == nil then 
		return false
	end
	
	local weapon_type = Find_Object_Type(superweapon_type_name)
	if weapon_type == nil then 
		return false
	end
	
	if WeaponTypeNameToCount[superweapon_type_name] == nil then 
		WeaponTypeNameToCount[superweapon_type_name] = 1
	else
		WeaponTypeNameToCount[superweapon_type_name] = WeaponTypeNameToCount[superweapon_type_name] + 1
	end
	
		
	-- we do this once so we do not have to be retrieving this data any more!.
	if WeaponTypeNameToCooldownTime[superweapon_type_name] == nil then 
		local cooldown = weapon_type.Get_TSW_Cooldown_Countdown_Seconds()
		if cooldown <= 0.0 then 		
			local mssg = "No cooldown set up for weapon"..tostring(weapon_type)
			MessageBox(mssg)
		end

		WeaponTypeNameToCooldownTime[superweapon_type_name] = cooldown
	end
	
	
	if WeaponTypeNameToResourceRequirements[superweapon_type_name] == nil then
		local resource_units_per_shot = weapon_type.Get_TSW_Resource_Units_Per_Shot()
		WeaponTypeNameToResourceRequirements[superweapon_type_name] = resource_units_per_shot
	end

	local can_fire = true
	local warm_up_seconds = weapon_type.Get_TSW_Warm_Up_Seconds()
	if warm_up_seconds > 0.0 then
		Set_Superweapon_Cooldown_Time( enabler, superweapon_type_name, warm_up_seconds )
		can_fire = false
	end
	
	-- Oksana: note that we set can_fire to false regardless. We need to do that so that in
	-- update function it detects a change to "ready" and sends appropriate game event
	table.insert( SuperweaponEnablers, {Object = enabler, WeaponTypeName = superweapon_type_name, CanFire = false, AnimPlaying = nil} )
	enabler.Register_Signal_Handler(On_Enabler_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	enabler.Register_Signal_Handler(On_Enabler_Destroyed, "OBJECT_SOLD")
	
	Raise_Game_Event("Super_Weapon_Built", Player, enabler.Get_Position(), Find_Object_Type(superweapon_type_name) )
	
	return true
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Enabler_Destroyed
-- ------------------------------------------------------------------------------------------------------------------
function On_Enabler_Destroyed(enabler)
	
	if enabler == nil then 
		return
	end
	
	-- update the list of enablers and weapon types alike
	Remove_SW_Enabler(enabler)
	enabler.Unregister_Signal_Handler(On_Enabler_Destroyed)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Remove_SW_Enabler
-- ------------------------------------------------------------------------------------------------------------------
function Remove_SW_Enabler(enabler)

	if not SuperweaponEnablers then 
		return
	end
	
	local found = false
	for index=table.getn(SuperweaponEnablers), 1, -1 do
		
		local enabler_data = SuperweaponEnablers[index]
		
		if enabler_data.Object == enabler then 
		
			-- remove from timers
			if SuperweaponTimers ~= nil and SuperweaponTimers[enabler_data.Object] ~= nil then
				local index = SuperweaponTimers[enabler_data.Object].Index
				if SuperweaponTimers[index] ~= nil and SuperweaponTimers[index] == enabler_data.Object then
					table.remove(SuperweaponTimers,index)
					SuperweaponTimers[enabler_data.Object]=nil
					
					for i=table.getn(SuperweaponTimers), 1, -1 do
						local weap = SuperweaponTimers[i]
						if weap ~= nil then
							SuperweaponTimers[weap].Index = i		
						end			
					end
					
				end
			end
			
			-- Also, update the weapon count for this enabler's weapon type.
			local weapon_type_name = enabler_data.WeaponTypeName
			if  WeaponTypeNameToCount[weapon_type_name] ~= nil then 
				WeaponTypeNameToCount[weapon_type_name] = WeaponTypeNameToCount[weapon_type_name] - 1
				
				if WeaponTypeNameToCount[weapon_type_name] == 0 then 
					WeaponTypeNameToCount[weapon_type_name] = nil
				end				
			else	
				MessageBox("The weapon count is not right!")
			end
			
			table.remove(SuperweaponEnablers, index)
			
			found = true
		end
	end
	
	if not found then 
		-- no message as due to masari switch types its possible to not be in the list
--		MessageBox("The dying enabler was not found in the list... weird")
		return
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Superweapon_Update
-- ------------------------------------------------------------------------------------------------------------------
function Update_Superweapons_Data()

	-- Update the list of enablers to make sure they are all valid!
	SW_Update_Enablers_List()
	
	-- first let's update the timers.
	SW_Update_Timers()
	
	-- we need to store data that may be used by the UI (if we are the local player)
	WeaponTypeToWeaponStateTable = {}
	local progress_value = 0
	local button_index = 1
	for weapon_type_name, count in pairs(WeaponTypeNameToCount) do
		
		local present, enabler = Superweapon_Enabler_Present(weapon_type_name)
		local enabled, num_can_fire = Can_Fire_Superweapon(weapon_type_name)
		local progress_data = 0.0
		
		local cooldown = 0
		--do we need to set the cooldown timer for this button?
		if count > num_can_fire then
				
			local weapon = Get_Best_SW( weapon_type_name, false )
			if weapon ~= nil and SuperweaponTimers[weapon] ~= nil and SuperweaponTimers[weapon].CoolDown > 0.0 then
				local activation = SuperweaponTimers[weapon].StartTime
				progress_data = 1.0 - (SuperweaponTimers[weapon].Progress/SuperweaponTimers[weapon].CoolDown)
				
				if progress_data > 1.0 then
					progress_data = 1.0
				elseif progress_data < 0.0 then
					progress_data = 0.0
				end
				cooldown = SuperweaponTimers[weapon].CoolDown
			end
		end
		
		WeaponTypeToWeaponStateTable[weapon_type_name] = {present, enabled, progress_data, count, num_can_fire, enabler, cooldown}
	
	end
	Script.Set_Async_Data("WeaponTypeToWeaponStateTable", WeaponTypeToWeaponStateTable)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Update_Enablers_List
-- ------------------------------------------------------------------------------------------------------------------
function SW_Update_Enablers_List()
	if SuperweaponEnablers then
		for index, enabler_data in pairs(SuperweaponEnablers) do
			if not TestValid(enabler_data.Object) then
				On_Enabler_Destroyed(enabler_data.Object)
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Object_Has_Power
-- ------------------------------------------------------------------------------------------------------------------
function SW_Object_Has_Power( object )
	if TestValid( object ) then
		if object.Has_Behavior( BEHAVIOR_POWERED ) then
			if object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
				return false
			end
		end
	end
	
	return true
end

-- ------------------------------------------------------------------------------------------------------------------
-- Can_Fire_Superweapon
-- ------------------------------------------------------------------------------------------------------------------
function Can_Fire_Superweapon(weapon_type_name)

	--First, check if we have resources to fre this weapon
	local resource_requirements = WeaponTypeNameToResourceRequirements[weapon_type_name]
	local has_enough_resources_to_fire = true
	if resource_requirements ~= nil then
		local raw_materials = Player.Get_Raw_Materials()
		
		if raw_materials < resource_requirements then
			has_enough_resources_to_fire = false
		end
	end
	--fall thru to get the weapon count

	-- virus check and power check
	-- Novus buildings will require power, if they don't have it they can't fire
	local can_fire = false
	local count = 0
	local found = false
	local cooldown_prevents_fire = false
	for index=table.getn(SuperweaponEnablers), 1, -1 do
	
		local enabler_data = SuperweaponEnablers[index]
		
		if enabler_data.WeaponTypeName == weapon_type_name then 
			
			if enabler_data.Object ~= nil then
				-- Maria 10.29.2007: (Bug entry) When Super Weapons are EMP’d, and are ready to fire, the button to activate 
				-- the super should grey out until the EMP effect has worn off
				if enabler_data.Object.Get_Attribute_Value("EMP_Stun_Effect") < 1.0 then
					-- The enabler is not EMP's so now we need to know if it has power
					has_power = SW_Object_Has_Power( enabler_data.Object )
					if has_power then
						local virus_max = enabler_data.Object.Get_Attribute_Value("Virus_At_Max")
						-- check for power here
						if ( virus_max == nil or virus_max == 0 ) then
							if ( SuperweaponTimers == nil or SuperweaponTimers[enabler_data.Object]==nil or SuperweaponTimers[enabler_data.Object].CoolDown <= 0.0 ) then
								can_fire = true
								count = count + 1
							else
								cooldown_prevents_fire = true
							end
						end
					end
				end
			end
			
			--Detect when weapon comes online and update current state
			if has_enough_resources_to_fire == true and can_fire == true and enabler_data.CanFire == false then
				Raise_Game_Event("Super_Weapon_Ready", Player, enabler_data.Object.Get_Position(), Find_Object_Type(enabler_data.WeaponTypeName) )
				enabler_data.CanFire = true
			else 
				if not has_enough_resources_to_fire or not can_fire then
					enabler_data.CanFire = false
				end
			end
			found = true
		end
	end
	
	if not found then 
		local msg = "Could not find superweapon"..weapon_type_name
		MessageBox(msg)
	end
	
	-- we don't have enough resources to fire this weapon
	if not has_enough_resources_to_fire then
		return false, count
	end	
	
	-- we cannot fire at this moment.  We'll still report that we're enabled if the only thing stopping us is cooldown
	if not can_fire then
		return cooldown_prevents_fire, count
	end	
			
	return true, count
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Timers
-- ------------------------------------------------------------------------------------------------------------------
function SW_Update_Timers()
	local curr_time = GetCurrentTime()
	local add_time = curr_time - SWTimerUpdateTime

	local total_sw=table.getn(SuperweaponTimers);

	local remove_sw = {}
--	while index ~= 0 do
	for index=1, total_sw do
		local weapon = SuperweaponTimers[index]
		
		if TestValid(weapon) then
			
			-- oksana: don't update animations or timers while there is no power.
			-- KDB added stun effect from emp to stop timers
			if SW_Object_Has_Power(weapon) and weapon.Get_Attribute_Value("EMP_Stun_Effect") < 1.0 then
				
				local cooldown = SuperweaponTimers[weapon].CoolDown
				local progress = curr_time - SWTimerUpdateTime
	
				local rate_increase = weapon.Get_Attribute_Value("Unit_Ability_Countdown_Rate_Multiplier")
				if rate_increase ~= nil and rate_increase > 1.0 then
					progress = progress * rate_increase
				end
	
				SuperweaponTimers[weapon].Progress = SuperweaponTimers[weapon].Progress+progress;
	
				local attack_time = 3.0
				if cooldown < attack_time then
					attack_time = cooldown / 2.0
				end
				local undeploy_time = (cooldown - attack_time) * 0.3
				local deploy_time = (cooldown - attack_time) * 0.7
			
				-- check for power. Timers don't advance if no power
				-- i.e. increase start time by time since last check
				-- if not SW_Object_Has_Power(weapon) then
				-- 	SuperweaponTimers[weapon].StartTime = SuperweaponTimers[weapon].StartTime + add_time
				-- end
				
				--Oksana: don't have time to move these out, overriding them here for Beta. 
				--For Masari super, there is a different set of animations for dark/light mode.
				local deploy_anim_name = "Anim_Deploy"
				local undeploy_anim_name = "Anim_Undeploy"
				local hold_anim_name = "Anim_Structure_Hold"
				local attack_anim = "Anim_Attack"
				
				if  StringCompare( Player.Get_Elemental_Mode(), "Ice" )  then
					deploy_anim_name = "Special_Start_A"
					undeploy_anim_name = "Special_End_A"
					attack_anim = "Special_Action_A"
				end
				
				
		
				-- KDB 07-03-2007 animations ... probably need something a bit better here .. i.e not hard coded ... and in the fire code
				if SuperweaponTimers[weapon].Progress >= attack_time and SW_Get_Anim(weapon) == attack_anim then
					
					SW_Play_Anim(weapon, undeploy_anim_name, false, undeploy_time)
				 
				elseif ((SuperweaponTimers[weapon].Progress >= attack_time + undeploy_time and SW_Get_Anim(weapon) == undeploy_anim_name) or SW_Get_Anim(weapon) == nil) then
					
					deploy_time = cooldown - SuperweaponTimers[weapon].Progress
					SW_Play_Anim(weapon, deploy_anim_name, false, deploy_time)
					
				end
				
				if SuperweaponTimers[weapon].Progress >= cooldown then
				
					SW_Play_Anim(weapon, hold_anim_name, true, 0.0)
					SuperweaponTimers[weapon].CoolDown = 0.0
					table.insert(remove_sw,weapon)
				end
			end
		end
	end

	-- re-index timers
	if #remove_sw > 0 then
	
		for i=table.getn(SuperweaponTimers), 1, -1 do
			for _, remove_weap in pairs(remove_sw) do
				if TestValid(remove_weap) and SuperweaponTimers[i] == remove_weap then
					-- remove this activation record from the list
					table.remove(SuperweaponTimers, i)
					SuperweaponTimers[remove_weap] = nil
				end
			end
		end
		
		-- update all the remaining indexes
		for i=table.getn(SuperweaponTimers), 1, -1 do
			local weap = SuperweaponTimers[i]
			if TestValid(weap) ~= nil then
				SuperweaponTimers[weap].Index = i		
			end			
		end
		
		
	end
	
	SWTimerUpdateTime = curr_time
end


-- ------------------------------------------------------------------------------------------------------------------
-- Force_SW_Cooldown_Complete
-- ------------------------------------------------------------------------------------------------------------------
function Force_SW_Cooldown_Complete()

	--Oksana: don't have time to move these out, overriding them here for Beta. 
	--For Masari super, there is a different set of animations for dark/light mode.
	local hold_anim_name = "Anim_Structure_Hold"
	
	--if  StringCompare( Player.Get_Elemental_Mode(), "Ice" )  then
		--hold_anim_name = "Special_Action_A"
	--end

	for index=table.getn(SuperweaponTimers), 1, -1 do
		local weapon = SuperweaponTimers[index]
		if TestValid(weapon) then
			SW_Play_Anim(weapon, hold_anim_name, true, 0.0)
			SuperweaponTimers[weapon].CoolDown = 0.0
			SuperweaponTimers[weapon].Index = 0
			-- remove this activation record from the list
			table.remove(SuperweaponTimers, index)

			for i=table.getn(SuperweaponTimers), 1, -1 do
				local weap = SuperweaponTimers[i]
				if weap ~= nil then
					SuperweaponTimers[weap].Index = i		
				end			
			end		
		end
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Superweapon_Enabler_Present - Is an enabler available for the given player and weapon type?
-- ------------------------------------------------------------------------------------------------------------------
function Superweapon_Enabler_Present(weapon_type_name)
	for index, enabler_data in pairs(SuperweaponEnablers) do
		if TestValid(enabler_data.Object) and enabler_data.Object.Get_Owner() == Player and enabler_data.WeaponTypeName == weapon_type_name then
			return true, enabler_data.Object
		end
	end
	return false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Launch_Superweapon - 
-- ------------------------------------------------------------------------------------------------------------------
function Launch_Superweapon(weapon_type, position)

	if weapon_type == nil then return end
	
	local weapon_type_name = weapon_type.Get_Name()
	if weapon_type_name == nil then return end
	
	local enabled, number_ready = Can_Fire_Superweapon(weapon_type_name)
	if enabled and number_ready > 0 then 
	
		-- Fix: must start cooldown BEFORE we spawn the object, otherwise we may 
		-- accidentaly fry ourselves and never be able to fire again
		local cool_down = WeaponTypeNameToCooldownTime[weapon_type_name]
		Set_Superweapon_Cooldown_Time( nil, weapon_type_name, cool_down, true )
	
		local sw_object = Spawn_Unit(weapon_type, position, Player, false, false)	-- 5th param is do not place as company
		if TestValid(sw_object) then
			-- Maria 06.28.2007
			-- the SW objects are made selectable so that we can add a targeting blob to them once they are spawned.
			-- In order to do this we took advantage of the functionality in SelectBehavior and thus we made them selectable.
			-- However, we don't want to have any visuals when the mouse is over nor give the opprotunity to actually select them,
			-- hence we are setting them to not selectable.
			-- KDB 07-6-2007 except the Masari_SW_Magma_channel_Weapon which is selectable
			if sw_object.Get_Type() ~= Find_Object_Type("Masari_SW_Magma_channel_Weapon") then
				sw_object.Set_Selectable(false)
			end
		end
		
		Player.Add_Raw_Materials(-WeaponTypeNameToResourceRequirements[weapon_type_name], sw_object)
		
		
		--Oksana: notify game event system of this event
		Raise_Game_Event("Super_Weapon_Launched", Player, position, weapon_type)
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Superweapon_Cooldown_Time - 
-- ------------------------------------------------------------------------------------------------------------------
function Set_Superweapon_Cooldown_Time( object, weapon_type_name, cool_down, player_fire_anim )
	
	if object == nil then
		-- find a sw of this type that is powered and not in cooldown
		object = Get_Best_SW( weapon_type_name, true )
	end
	
	local attack_anim = "Anim_Attack"
	
	if  StringCompare( Player.Get_Elemental_Mode(), "Ice" )  then
		attack_anim = "Special_Action_A"
	end
	
	if TestValid( object ) and weapon_type_name ~= nil and cool_down > 0.0 then
	
		if player_fire_anim and cool_down > 3.0 then
			SW_Play_Anim(object, attack_anim, false, 3.0)
		end
	
		local start_time = GetCurrentTime()
	
		local index = table.getn(SuperweaponTimers) + 1

		if SuperweaponTimers[object]==nil then
			-- not in table add it
			SuperweaponTimers[object]={}
			SuperweaponTimers[object].Index = 0
		end

		if SuperweaponTimers[object] ~= nil then
		
			SuperweaponTimers[object].StartTime = start_time
			SuperweaponTimers[object].CoolDown = cool_down
			SuperweaponTimers[object].Progress = 0


			local sw_ix = SuperweaponTimers[object].Index
			if  sw_ix == 0 or SuperweaponTimers[sw_ix] == nil then		
				SuperweaponTimers[object].Index=index
				SuperweaponTimers[index]=object
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Best_SW - get the neareast to being ready SW. if only_ready is true the wqeapon must be ready to fire
-- ------------------------------------------------------------------------------------------------------------------
function Get_Best_SW( weapon_type_name, only_ready )

	local best = nil
	local best_time = -1.0
	local cur_time = GetCurrentTime()
	if only_ready == nil then
		only_ready = false
	end
	for index, enabler_data in pairs(SuperweaponEnablers) do
		if (weapon_type_name == nil or enabler_data.WeaponTypeName == weapon_type_name) and TestValid(enabler_data.Object) then
			local is_online, is_cooling_down = SW_Is_Online(enabler_data.Object) 
			-- we found at least one fully charged superweapon, no need to look for more.
			if is_online and not is_cooling_down then 
				best = enabler_data.Object
				weapon_type_name = enabler_data.WeaponTypeName
				best_time = 0.0
				break
			end
			
			-- If we are allowed recharging superweapons, get the best one here
			if not only_ready and ( best_time < 0.0 or (SuperweaponTimers and SuperweaponTimers[enabler_data.Object] and SuperweaponTimers[enabler_data.Object].CoolDown - SuperweaponTimers[enabler_data.Object].Progress) < best_time ) then
				best = enabler_data.Object
				-- in case of best_time getting us here (virused sw that is ready)
				if SuperweaponTimers and SuperweaponTimers[enabler_data.Object] then
					best_time = (SuperweaponTimers[enabler_data.Object].CoolDown - SuperweaponTimers[enabler_data.Object].Progress)
				end
			end			
		end
	end
	
	return best, best_time, weapon_type_name
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- SW_Get_Cooldown_Time - get the best time for thisweapon type, -1.0 is not available 0.0 is ready
-- ------------------------------------------------------------------------------------------------------------------
function SW_Is_Online( weapon )
	
	if not TestValid(weapon) then return false end
	
	-- Check if the weapon is online.
	local is_online = SW_Object_Has_Power(weapon)
	local cooling_down = ( SuperweaponTimers ~= nil and SuperweaponTimers[weapon] ~= nil and SuperweaponTimers[weapon].CoolDown > 0.0 )
		
	if is_online then
		local virus_max = weapon.Get_Attribute_Value("Virus_At_Max")
		if ( virus_max ~= nil and virus_max ~= 0 ) then
			is_online = false					
		end
	end

	return is_online, cooling_down
end

-- ------------------------------------------------------------------------------------------------------------------
-- SW_Get_Cooldown_Time - get the best time for thisweapon type, -1.0 is not available 0.0 is ready
-- ------------------------------------------------------------------------------------------------------------------
function SW_Get_Cooldown_Time( weapon_type_name )
	local object, best_time = Get_Best_SW( weapon_type_name, false )
	
	return best_time
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- SW_Get_Cooldown_Time - get the best time for thisweapon type, -1.0 is not available 0.0 is ready
-- ------------------------------------------------------------------------------------------------------------------
function SW_Get_Ready_Weapon( weapon_type_name )
	local object, best_time, weapon_name = Get_Best_SW( weapon_type_name, true )
	
	local sw_table = {}
	sw_table.Object = object
	sw_table.WeaponName = weapon_name
	
	return sw_table

end

-- ------------------------------------------------------------------------------------------------------------------
-- SW_Get_Anim
-- ------------------------------------------------------------------------------------------------------------------
function SW_Get_Anim( sw_object )
	local enabler_data = SW_Get_Enabler_Data( sw_object )
	if enabler_data ~= nil then
		return enabler_data.AnimPlaying
	end
	
	return nil
end

-- ------------------------------------------------------------------------------------------------------------------
-- SW_Play_Anim
-- ------------------------------------------------------------------------------------------------------------------
function SW_Play_Anim( sw_object, anim_name, loop, run_time )
	local enabler_data = SW_Get_Enabler_Data( sw_object )
	if enabler_data ~= nil then
		enabler_data.AnimPlaying = anim_name
		sw_object.Play_Animation(anim_name, loop, 0, 0, run_time)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- SW_Get_Enabler_Data
-- ------------------------------------------------------------------------------------------------------------------
function SW_Get_Enabler_Data( sw_object )
	if TestValid(sw_object) then
		for _, enabler_data in pairs(SuperweaponEnablers) do
			if TestValid(enabler_data.Object) and enabler_data.Object == sw_object then
				return enabler_data
			end
		end
	end
	return nil
end
