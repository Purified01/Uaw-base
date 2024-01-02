-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/EffectSystem/EffectTargetFilter.lua#118 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/EffectSystem/EffectTargetFilter.lua $
--
--    Original Author: Bret Ambrose
--
--            $Author: Pat_Pannullo $
--
--            $Change: 76236 $
--
--          $DateTime: 2007/07/11 10:56:12 $
--
--          $Revision: #118 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGBase")
require("PGUICommands")

function Definitions()
	TargetFilterFunctions = {}
	PurifyingLight = {}
end

function Add_Target_Filter_Function( filter_function, function_key )
	TargetFilterFunctions[ function_key ] = filter_function
end



function Filter_Effect_Targets_By_Dynamic_Function( target_list, source, function_key, original_player )

	local filtered_targets = {}
	
	for _, target in pairs(target_list) do	
		if TargetFilterFunctions[ function_key ]( source, target, original_player ) then
			table.insert( filtered_targets, target )
		end
	end
	
	return filtered_targets
	
end



function Filter_Effect_Targets_By_Static_Function( target_list, source, function_ptr, original_player )

	local filtered_targets = {}
	
	for _, target in pairs(target_list) do	
		if function_ptr( source, target, original_player ) then
			table.insert( filtered_targets, target )
		end
	end
	
	return filtered_targets

end


-- ======================================================================================= 
function Test_Filter_Function( source, target )
	return target.Is_Category("Small") 
end



-- ======================================================================================= 
function Is_Enemy_Filter_Function( source, target )
	return source.Is_Enemy( target )
end

-- ======================================================================================= 
function Is_Enemy_Not_Resource_Filter_Function( source, target )
	if source.Is_Enemy( target ) then
		
		if target.Is_Category("Resource") or target.Is_Category("Resource_INST") then
			return false
		end
		
		return true
		
	end
	return false
end

-- ======================================================================================= 
function Is_Ally_Filter_Function( source, target )
	return source.Get_Owner().Is_Ally( target.Get_Owner() )
end

function Is_Ally_Not_Self_Filter_Function( source, target )
    if target.Has_Effect_By_Name( "Viral_Control_Effect" ) then
        return false
    end

	return source.Get_Owner().Is_Ally( target.Get_Owner() ) and source ~= target
end


-- ======================================================================================= 
function Novus_Signal_Filter_Function( source, target )
   return target.Get_Attribute_Value( "Affected_By_Novus_Signal" ) ~= 0 and source.Get_Owner() == target.Get_Owner()
end


-- ======================================================================================= 
function Novus_Signal_Connection_Filter_Function( source, target )
   return target.Get_Attribute_Value( "Transmits_Novus_Signal" ) ~= 0 and source.Get_Owner() == target.Get_Owner()
end


-- ======================================================================================= 
-- Oksana [7/31/2006]: Structure Builder targeting
-- ================================================================================================
function Tactical_Base_Builder_Filter_Function( source, target )
	
	local valid_target = (target.Get_Owner() == source.Get_Owner() )
	
	-- valid_target = valid_target and (target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION))
	
	return valid_target;
end

function Build_Anim_Tactical_Base_Builder_Filter_Function( source, target )
	
	local valid_target = (target.Get_Owner() == source.Get_Owner() )
	
	-- valid_target = valid_target and (target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION))
	if valid_target then
        valid_target = target.Get_Attribute_Value( "Is_Build_Anim_Finished" ) == 0
    end

	return valid_target;
end



-- ======================================================================================= 
-- Oksana [8/16/2006]: Novus Inverter Flux Overload targeting function
-- ================================================================================================
function Novus_Inverter_Flux_Overload_Targeting_Function( source, target )
	
	return  (target.Get_Type().Get_Name() == "NOVUS_FIELD_INVERTER_SHIELD_MODE")
	
end

function Novus_Inverter_Flux_Overload_Reverse_Targeting_Function( source, target )
	
	return  (target.Get_Type().Get_Name() == "NOVUS_FIELD_INVERTER")
	
end

function Novus_Inverter_Flux_Overload_Explode_Function( source, target )
   return target.Get_Attribute_Value( "Explode_Inverter" ) ~= 0 
end



-- ======================================================================================= 
-- Oksana [8/16/2006]: Novus Inverter Shield Mode Cloak targeting function
-- ================================================================================================
function Novus_Inverter_Cloak_Targeting_Function( source, target )
	
	return  target.Get_Owner().Is_Ally( source.Get_Owner() )
	
end

-- ======================================================================================= 
-- KDB [04/10/2007]: radiation cascade dissolve
-- ================================================================================================
function Radiation_Cascade_Dissolve_Target_Filter( source, target )
	
	if (target.Get_Health_Value() < 500.0 or target.Is_Category("Insignificant")) and not target.Is_Category("Hero") and target.Get_Attribute_Value("Cascade_Affected") == 0 and
		not target.Has_Behavior(BEHAVIOR_INVULNERABLE) and not target.Has_Behavior(BEHAVIOR_HARD_POINT) then
		return true
	end

	return false
	
end

-- ======================================================================================= 
-- KDB [04/10/2007]: radiation cascade damage only
-- ================================================================================================
function Radiation_Cascade_Damage_Target_Filter( source, target )
	
	if (target.Get_Health_Value() < 500.0 or target.Is_Category("Insignificant")) and not target.Is_Category("Hero") and not target.Has_Behavior(BEHAVIOR_INVULNERABLE) and
		not target.Has_Behavior(BEHAVIOR_HARD_POINT) then
		return false
	end
	
	if target.Is_Category("RadiationHelps") and target.Get_Attribute_Value("Is_Being_Dissolved") == 0 then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- KDB [04/10/2007]: radiation cascade damage and radiation
-- ================================================================================================
function Radiation_Cascade_Irradiate_Target_Filter( source, target )

	if (target.Get_Health_Value() < 500.0 or target.Is_Category("Insignificant")) and not target.Is_Category("Hero") and not target.Has_Behavior(BEHAVIOR_INVULNERABLE) and
		not target.Has_Behavior(BEHAVIOR_HARD_POINT) then
		return false
	end
	
	if not target.Is_Category("RadiationHelps") and target.Get_Attribute_Value("Is_Being_Dissolved") == 0 then
		return true
	end

	return false
	
end

-- ======================================================================================= 
-- KDB [03/28/2007]: is the unit in fire mode?
-- ================================================================================================
function Purifying_Light_Target_Filter( source, target, original_player )

	local ret = false
	
	if PurifyingLight == nil then
		PurifyingLight = {}
	end

	if original_player ~= nil and source.Is_Enemy( target )  then
	
		if PurifyingLight[original_player] == nil then
		
			PurifyingLight[original_player]= {}
			PurifyingLight[original_player].FireMode = StringCompare( original_player.Get_Elemental_Mode(), "Fire" )
			-- check only once a second
			PurifyingLight[original_player].NextCheck = GetCurrentTime() + 0.5
			
		elseif GetCurrentTime() > PurifyingLight[original_player].NextCheck then
		
			PurifyingLight[original_player].NextCheck = GetCurrentTime() + 0.5
			PurifyingLight[original_player].FireMode = StringCompare( original_player.Get_Elemental_Mode(), "Fire" )
			
		end
		
		ret = PurifyingLight[original_player].FireMode
	end
	
	return ret 	
	
end

-- ======================================================================================= 
-- KDB [03/28/2007]: is the unit in ice mode?
-- ================================================================================================
function Crippling_Shots_Target_Filter( source, target, original_player )

	local ret = false
	
	if PurifyingLight == nil then
		PurifyingLight = {}
	end

	if original_player ~= nil and source.Is_Enemy( target ) then
	
		if PurifyingLight[original_player] == nil then
		
			PurifyingLight[original_player]= {}
			PurifyingLight[original_player].FireMode = StringCompare( original_player.Get_Elemental_Mode(), "Fire" )
			-- check only once a second
			PurifyingLight[original_player].NextCheck = GetCurrentTime() + 0.5
			
		elseif GetCurrentTime() > PurifyingLight[original_player].NextCheck then
		
			PurifyingLight[original_player].NextCheck = GetCurrentTime() + 0.5
			PurifyingLight[original_player].FireMode = StringCompare( original_player.Get_Elemental_Mode(), "Fire" )
			
		end
		
		ret = ( not PurifyingLight[original_player].FireMode )
	end
	
	return ret 	
	
end


-- ======================================================================================= 
-- Oksana [03/12/07] - units that have AE damage need to check if the target is appropriate.
-- Luckily, all these units are all have same restrictions: no flying, no resources, enemy only.
-- ================================================================================================
function Crippling_Shots_Non_Flying_Enemy_Target_Filter( source, target, original_player )
	
	if not Crippling_Shots_Target_Filter() then
		return false
	end
	
	if not source.Is_Enemy( target ) then
		return false
	end
	
	if ( target.Is_Category("Flying") and target.Get_Attribute_Value( "Is_Grounded" ) == 0) then
		return false
	end
	
	
	if target.Is_Category("Resource | Resource_INST") then
		return false
	end
	
	return true
end


-- ======================================================================================= 
-- KDB [03/28/2007]: is the unit in ice mode? Used when switching types
-- ================================================================================================
function In_Ice_Mode_Filter( source, target, original_player )
	local ret = false

	if source ~= nil then
	
		local player = source.Get_Owner()
		if player ~= nil then
			ret = StringCompare( player.Get_Elemental_Mode(), "Ice" )
		end
	
	end
	
	return ret 	
	
end


function In_Fire_Mode_Filter( source, target, original_player )
	local ret = false

	if source ~= nil then
	
		local player = source.Get_Owner()
		if player ~= nil then
			ret = StringCompare( player.Get_Elemental_Mode(), "Fire" )
		end
	
	end
	
	return ret 	
	
end


-- ======================================================================================= 
-- Oksana: can this object spawn a phoenix?
-- ======================================================================================= 
function Can_Create_Phoenix( source, target, original_player )
	
	-- Phoenix can only be created in Fire mode
	if not In_Fire_Mode_Filter( source, target, original_player ) then
		return false
	end

	local is_phoenix = Is_Phoenix(source, target)	

	return not is_phoenix
end

-- ======================================================================================= 
-- Oksana: is this a phoenix?
-- ======================================================================================= 
function Is_Phoenix( source, target )
	return target.Get_Attribute_Value( "Is_Phoenix" ) ~= 0		
end


-- ======================================================================================= 
-- Maria [9/26/2006]: Alien Science Shield Recharge Funcion: the target must be the core 
--					  on the same walker as the source!
-- ================================================================================================
function Alien_Science_Shield_Recharge_Targeting_Function( source, target )
	local parent_hp = source.Get_Highest_Level_Hard_Point_Parent()

	if parent_hp == nil then
		return
	end
	
	-- target = core of the same science walker.
	if target.Get_Type().Get_Name() ~= "ALIEN_WALKER_SCIENCE_CORE" then 
		return false
	end
	
	if parent_hp ~= target.Get_Highest_Level_Hard_Point_Parent() then 
		return false
	end
	
	return true
end


--=================================================================================================
-- [10/18/2006] Elemental mines detonate by enemy proximity  - Oksana Kubushyna
--================================================================================================ 
function Masari_Elemental_Mine_Detonation_Filter_Function( source, target )
	local radius = target.Get_Attribute_Value( "Generator_Area_Effect_Radius_1" );
	
	local enemy_players = target.Get_Owner().Get_All_Enemy_Players()
	for i, enemy_player in pairs(enemy_players) do
		
		enemies = Find_Collidable_Objects(target.Get_Position(),  
										radius, 
										-1,					-- not interested in specific behaviors
										enemy_player)		-- enemy player 
										-- 1)						-- one enemy object is enough to detonate the mine
		
		
		-- we got at least one enemy unit nearby, detonate now!
		if(enemies ~= nil and table.getn(enemies) > 0) then
			
			for index, enemy_object in pairs(enemies) do
				if TestValid(enemy_object) then
					if enemy_object.Resource_Get_Resource_Units() == nil then
						if enemy_object.Get_Health() > 0 then	
							if enemy_object.Is_Phased() == false then
								if enemy_object.Is_Category("Bridge") == false then
									return true
								end
							end
						end
					end
				end
				
			end
			
			
			return false
		end
	end
	
	return false	
end



function Enemy_Structure_Filter_Function( source, target )
    if (Is_Ally_Filter_Function(source, target)) then
		return false
	end
	
	return target.Is_Category("Stationary") 
end

-- ======================================================================================= 
function Valid_EM_Field_Target( source, target )
	if target.Get_Attribute_Value( "Affected_By_Novus_Signal" ) ~= 0 and target.Get_Attribute_Value( "Novus_Signal_Tower_Boosted" ) ~= 0 and target.Get_Attribute_Value( "EM_Protection_On" ) == 0 then
		return true
	end
	return false
end

-- ======================================================================================= 
-- == The basic targeting filtering rules for all novus patches
-- =======================================================================================
function Novus_Patch_Target( source, target )
	if target.Get_Owner() == source.Get_Owner() and not target.Is_Category("Untargetable") and not target.Has_Behavior(BEHAVIOR_DEBRIS) then
		return true
	end
	return false
end

-- ======================================================================================= 
-- == for the backup system (ie. not under construction)
-- =======================================================================================
function Novus_Patch_No_Construction_Target( source, target )
	if target.Get_Owner() == source.Get_Owner() and not target.Is_Category("Untargetable") and not target.Has_Behavior(BEHAVIOR_DEBRIS) and
		not target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) then
		return true
	end
	return false
end

-- ======================================================================================= 
-- == Novus patch reboot filter
-- =======================================================================================
function Novus_Patch_Reboot_Target( source, target )
	if target.Get_Owner() == source.Get_Owner() and not target.Is_Category("Untargetable") then
		return true
	end
	if target.Get_Owner() ~= source.Get_Owner() and target.Get_Attribute_Value( "Is_Mind_Controlled" ) ~= 0 or target.Get_Attribute_Value( "Is_Walker_Mind_Controlled" ) ~= 0 then
		return true
	end
	return false
end

-- ======================================================================================= 
-- == Walker_Mind_Magnet_Target
-- =======================================================================================
function Walker_Mind_Magnet_Target( source, target )

	if target.Is_Category("Hero | Resource | Resource_INST | Stationary") then
		return false
	end

	if target.Get_Owner() ~= source.Get_Owner() and target.Get_Attribute_Value("Is_Immune_To_Mind_Control") == 0  and target.Is_Category("Organic") then
		return true
	end
	
	if target.Get_Owner() == source.Get_Owner() and target.Get_Attribute_Value("Is_Walker_Mind_Controlled") ~= 0 then
		-- keep applying effect to maintain hold
		return true		
	end
	
	return false
end

-- ======================================================================================= 
-- == Walker_AI_Magnet_Target
-- =======================================================================================
function Walker_AI_Magnet_Target( source, target )

	if target.Is_Category("Hero | Stationary | Huge | HardPoint | Resource | Resource_INST") then
		return false
	end

	if target.Get_Owner() ~= source.Get_Owner() and target.Get_Attribute_Value("Is_Immune_To_Mind_Control") == 0  and not target.Is_Category("Organic") then
		return true
	end
	
	if target.Get_Owner() == source.Get_Owner() and target.Get_Attribute_Value("Is_Walker_Mind_Controlled") ~= 0 then
		-- keep applying effect to maintain hold
		return true		
	end
	
	return false
end



function Enemy_Has_Novus_Virus_Filter_Function(source, target)

	-- Must be an enemy.
    if not Is_Enemy_Filter_Function(source, target) then
		return false
	end
	
	-- Must have level one virus or higher.
	if target.Get_Attribute_Value("Virus_Level") < 1.0 then
		return false
	end
	
	return true
end


-- ======================================================================================= 
-- == Architect_Assistance_Cap_Reached
-- =======================================================================================
--function Architect_Assistance_Cap_Reached( source, target )
--
	--if TestValid( target ) then
--
		--local num_assistants = target.Get_Attribute_Value("Number_Of_Active_Assistants")
		--if num_assistants > 2 then 
			--return true
		--end
		--return false				
	--end
	--
	--return true
--end

-- ======================================================================================= 
-- == Architect_Check_For_Unit_Building
-- =======================================================================================
function Architect_Check_For_Unit_Building( source, target )

	if TestValid( target ) then
	
		if target.Get_Attribute_Value( "Is_Mind_Controlled" ) ~= 0 then
			return false
		end
	
		---- Only certain number of Architects are allowed to activate at once
		--if Architect_Assistance_Cap_Reached(source, target) then
			--return false
		--end
		
		--We can't assit building if the structure is damaged - we will HEAL it instead.
		if Architect_Check_For_Healing( source, target ) then
			return false
		end
	
		if target.Get_Owner() == source.Get_Owner() then
			local build_queue = target.Tactical_Enabler_Get_Queued_Objects()
			if build_queue ~= nil and table.getn( build_queue ) > 0 then
				return true
			end
		end
	end
	
	return false
end


-- ======================================================================================= 
-- == Architect_Check_For_Upgrading
-- =======================================================================================
function Architect_Check_For_Upgrading( source, target )

	if TestValid( target ) then
	
		if target.Get_Attribute_Value( "Is_Mind_Controlled" ) ~= 0 then
			return false
		end
		
		---- Only certain number of Architects are allowed to activate at once
		--if Architect_Assistance_Cap_Reached(source, target) then
			--return false
		--end
		
		--We can't assit building if the structure is damaged - we will HEAL it instead.
		if Architect_Check_For_Healing( source, target ) then
			return false
		end
		
		-- Are we already assiting with unit production?
		if Architect_Check_For_Unit_Building( source, target ) then
			return false
		end
	
		-- Do we have anything under construction?
		if target.Get_Building_Object_Type(true) ~= nil then
			return true
		end
	end
	
	return false
end

-- ======================================================================================= 
-- == Architect_Check_For_Harvesting
-- =======================================================================================
function Architect_Check_For_Harvesting( source, target )

	if TestValid( target ) then
	
		if target.Get_Attribute_Value( "Is_Mind_Controlled" ) ~= 0 then
			return false
		end
		
		---- Only certain number of Architects are allowed to activate at once
		--if Architect_Assistance_Cap_Reached(source, target) then
			--return false
		--end
		
		if Architect_Check_For_Upgrading( source, target ) then
			return false
		end
		
		
		--We can't assit harvesting if the structure is damaged - we will HEAL it instead.
		if Architect_Check_For_Healing( source, target ) then
			return false
		end
			
		return true;
	end	
			
	return false
end


-- ======================================================================================= 
-- == Architect_Check_For_Healing (structures)
-- =======================================================================================
function Architect_Check_For_Healing( source, target )

	if TestValid( target ) then
		if target.Get_Attribute_Value( "Is_Mind_Controlled" ) ~= 0 then
			return false
		end
			
			---- Only certain number of Architects are allowed to activate at once
		--if Architect_Assistance_Cap_Reached(source, target) then
			--return false
		--end
	
		return Architect_Check_For_Healing_Units( source, target );		
	end
	
	return false
end




-- ======================================================================================= 
-- == Architect_Check_For_Healing_Units
-- =======================================================================================
function Architect_Check_For_Healing_Units( source, target )

	if TestValid( target ) then
		if target.Get_Attribute_Value( "Is_Mind_Controlled" ) ~= 0 then
			return false
		end
	
		if target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) then 
			return false 
		end

		if target.Has_Behavior(BEHAVIOR_TACTICAL_BUILDABLE_BEACON) then 
			return false 
		end

		if target.Get_Hull() == 1.0 then
			return false
		end

		if target.Get_Attribute_Value( "Is_Rebuildable_Avenger" ) ~= 0.0 then
			return false
		end

		return true
	end
	
	return false
end

---- ======================================================================================= 
---- == Architect_Check_For_Upgrade_HP
---- =======================================================================================
--function Architect_Check_For_Upgrade_HP( source, target )
--
	--if TestValid( target ) then
	--
		--if target.Get_Owner() == source.Get_Owner() and target.Get_Building_Object_Type( true ) == nil then
		--
			--local hp_info = target.Get_Next_Hard_Point_Tier_Upgrade()
			--
			--if hp_info ~= nil and hp_info[1] ~= nil and hp_info[2] ~= nil then
				---- there is both a socket available and a tier hard point left
				--return true
			--end
		--
		--end
	--end
	--
	--return false
--end
--
---- ======================================================================================= 
---- == Architect_Check_For_Upgrade_HP_Help
---- =======================================================================================
--function Architect_Check_For_Upgrade_HP_Help( source, target )
--
	--if TestValid( target ) then
	--
		--if target.Get_Owner() == source.Get_Owner() then
			--
			--if target.Get_Building_Object_Type( true ) ~= nil then
				---- target is building upgrading a hard point somewhere
				--return true
			--end
		--end
	--end
	--
	--return false
--end


function Non_Radiated_Resource_Filter_Function( source, target )
	
	if target.Get_Attribute_Integer_Value( "Spy_Radiated_Player_ID" ) > 0 then
        return false
    end

	
	if (target.Is_Category("Resource") or target.Is_Category("Resource_INST")) then
        return true
    end
	
	return false
end





-- ================================================================================================
-- [12/5/2006]  - Oksana Kubushyna
-- ================================================================================================
function Is_Enemy_Ground_Adverse_Effect_Generator_Filter_Function( source, target )
	
	if source.Is_Enemy( target ) == false then
		return false
	end
	
	
	if (target.Get_Attribute_Value( "Is_Ground_Adverse_Effect_Emitter" ) == 0) then
		return false
	end
	
	return true;
end



--================================================================================================
-- [12/6/2006]  - Oksana Kubushyna
--================================================================================================ 

function Nufai_Tendrils_Filter_Function( source, target )
	
	if source.Is_Enemy( target ) == false then
		return false
	end
	
	if (target.Get_Attribute_Value( "Is_Grounded" ) ~= 0) then
		return false
	end
		
	return target.Is_Flying();
end



--================================================================================================
-- [02/01/2007]  - Oksana Kubushyna
--================================================================================================ 
function Reaper_Default_Attack_Filter_Function( source, target )
	
	-- Can only target grounded units 
	if target.Is_Flying() and target.Get_Attribute_Value( "Is_Grounded" ) ~= 0 then 
		return false 
	end
	
		-- Hardpoints, structures, construction objects can't be pulled in
	if target.Has_Behavior(BEHAVIOR_HARD_POINT) then return false end
	if target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) then return false end
	if target.Has_Behavior(BEHAVIOR_TACTICAL_BUILDABLE_BEACON) then return false end
	if target.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) then return false end

	
	return true
end


--================================================================================================
-- [02/01/2007]  - Oksana Kubushyna
--================================================================================================ 
function Reaper_Default_Attack_Piloted_Unit_Filter_Function( source, target )
	
	-- Can only target grounded units 
	if target.Is_Flying() and target.Get_Attribute_Value( "Is_Grounded" ) ~= 0 then 
		return false 
	end
	
	return true
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Valid_Resource -- Custom version for targeting derived from the version in AlienReaperTurret.lua
--	                     See note in the filter function.  5/26/2007 2:39:16 PM -- BMH
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Reaper_Harvest_Is_Valid_Resource( reaper, test_resource, check_targeting )

	-- if it doesn't have a script then it's not a reaper
	local reaper_script = reaper.Get_Script()
	if not reaper_script then return false end
	resource_faction = reaper.Get_Script().Get_Async_Data("ResourceFaction")

	--Is a valid object
	if not TestValid(test_resource) then
		return false
	end
	
	-- Is a valid resource for my faction?
	if not test_resource.Get_Type().Resource_Is_Valid_For_Faction(resource_faction) then
		return false
	end
	
	--Is this resource empty?
	local resource_units = test_resource.Resource_Get_Resource_Units()
	if resource_units == nil or resource_units <= 0 then
		return false
	end

	-- This object does not have means to attack the target (harvest it)
	-- ignore fog (2nd parameter)
	if check_targeting and not reaper.Is_Suitable_Target(test_resource, true) then
		return false
	end
		
	return true
end


--================================================================================================
-- [03/10/2007]  - Oksana Kubushyna
--================================================================================================ 
function Reaper_Harvest_Resource_Filter_Function( source, target )
	
	-- Target validation MUST be the same as in LUA!!! --
	--
	-- Ideally we'd use the same function to do the validation, but we can't do a Get_Script().Call_Function()
	-- here.  This filter function can potentially be called out of sync since it's based on mouse over state.
	-- Passing a game_object as a parameter into a sync'd script's Call_Function could potentially modify the 
	-- the global state of the script and cause an OOS in multiplayer.  5/26/2007 2:44:46 PM -- BMH
	return Reaper_Harvest_Is_Valid_Resource(source, target, false)
end



--================================================================================================
-- [02/26/2007]  - Eric Yiskis
--================================================================================================ 
function Reaper_Default_Attack_Hard_Point_Filter_Function( source, target )
	
	-- Can only target grounded units 
	if target.Is_Flying() and target.Get_Attribute_Value( "Is_Grounded" ) ~= 0 then 
		return false 
	end
	
	if target.Is_Invulnerable() then
		return false
	end
	
	return true
end


--================================================================================================
-- [02/01/2007]  - Oksana Kubushyna
--================================================================================================ 
function Reaper_Abduct_Filter_Function( source, target )
	
	--Being abducted by another reaper? let the other reaper pull it in then
	if target.Get_Attribute_Value( "Is_Being_Abducted" ) ~= 0 then
		return false
	end

	return true
end


--================================================================================================
-- [02/01/2007]  - Oksana Kubushyna
--================================================================================================ 
function Reaper_Dissolve_Filter_Function( source, target )
	
	--Being abducted by another reaper? let the other reaper pull it in then
	if target.Get_Attribute_Value( "Is_Being_Dissolved" ) ~= 0 then
		return false
	end


	return true
end


-- ======================================================================================= 
-- == Common_Virus_Filter
-- =======================================================================================
function Common_Virus_Filter( source, target )

	-- Only infect things that aren't already infected.
	if target.Get_Attribute_Value( "Virus_Level" ) > 0.0 then
		return false
	end
	
	-- And aren't immune to viruses.
	if target.Get_Attribute_Value( "Is_Immune_To_Virus" ) > 0.0 then
		return false
	end
		
	-- Do not spread virus to untargetable objects.
	if target.Is_Category("Untargetable") then
		return false
	end

	return true
end

-- ======================================================================================= 
-- == Virus_Infect_Enemy_Filter
-- =======================================================================================
function Virus_Infect_Enemy_Filter( source, target )

	-- Only virally infect enemy units.
	if source.Is_Enemy( target ) == false then
		return false
	end
	
	-- And it has to pass the normal filters too.
	return Common_Virus_Filter(source, target)

end

-- ======================================================================================= 
-- == Virus_Infect_Ally_Filter
-- =======================================================================================
function Virus_Infect_Ally_Filter( source, target )

	-- Viruses only spread among objects owned by the same player.
	if target.Get_Owner() ~= source.Get_Owner() then
		return false
	end
	
	-- You can only infect an allied unit if you yourself are infected!
	if source.Get_Attribute_Value( "Virus_Level" ) < 1.0 then
		return false
	end
	
	-- And it has to pass the normal filters too.
	return Common_Virus_Filter(source, target)

end

-- ======================================================================================= 
-- == Novus_Patch_Viral_Cascade_Filter
-- =======================================================================================
function Novus_Patch_Viral_Cascade_Filter( source, target )
	
	-- Apply the viral cascade effect to any owned unit that is powered and emits power
	-- to other units. Once the viral cascade effect is applied to this power source, it
	-- will apply viruses to any enemy units that enter its power emission radius.
	if source.Get_Owner() ~= target.Get_Owner() then
		return false
	end
	if target.Get_Attribute_Integer_Value("Is_Powered") == 0 then
		return false
	end
	if target.Get_Attribute_Value("Novus_Power_Powerup_Radius") <= 0.0  then
		return false
	end
	return true
	
end

-- ======================================================================================= 
-- == Novus_Amplifier_Resonance_Beam_Target
-- =======================================================================================
function Novus_Amplifier_Resonance_Beam_Target( source, target )
	if source == target then
		return false
	end

	--Note: must have this check here as this is an AE self-propagating effect
	--and it can't rely on special ability target filtering
	if not target.Is_Category("Small | Medium | Piloted | Stationary | Hero | HardPoint") then
		return false
	end
	
	if not source.Is_Enemy(target) then
		return false
	end
	
	-- fix for walker interanls that still protected
	if target.Has_Behavior(BEHAVIOR_DEBRIS) or target.Has_Behavior(BEHAVIOR_INVULNERABLE) then
		return false
	end

	if (target.Get_Attribute_Value( "Is_Under_Resonance_Beam_Attack" ) > 4) then
		return false
	end
	
	--Passed all checks
	return true
end






-- ======================================================================================= 
-- == Reflector_Fusion_Cannon_Filter
-- =======================================================================================
function Reflector_Fusion_Cannon_Filter( source, target )

	 -- Paranoid units can fire at anything
	if (target.Get_Attribute_Value( "Is_Paranoid" ) ~= 0) then
		return true
	end
	
	if not source.Get_Hard_Point_Parent().Is_Category("Flying") then
		return false
	end	
	
	if not source.Is_Enemy( target ) then
		return false
	end	

  	if( not target.Is_Category("Flying") ) then
		return false
	end
	
	 
	if( not target.Is_Flying() ) then
		return false
	end
	 	
		
	return true

end



-- ======================================================================================= 
function Paranoia_Filter_Function( source, target )
	--Must be enemy
	if not source.Is_Enemy( target ) then
		return false
	end

	if target.Is_Category("Stationary") and not target.Is_Category("CanAttack") then
		return false
	end

	if target.Is_Category("Flying") then
		return false
	end

	if target.Is_Category("Resource") then
		return false
	end

	if target.Is_Category("Resource_INST") then
		return false
	end


	if target.Get_Attribute_Value("Is_Immune_To_Mind_Control") ~= 0 then
        return false
    end

	-- the target must have targeting behavior	
	if not target.Has_Behavior(BEHAVIOR_TARGETING) then
		return false
	end	
	
	return true	
end


-- ======================================================================================= 
-- == Alien Machine Immobilizer Target
-- =======================================================================================
function Machine_Immobilizer_Target( source, target )

	--Must be enemy
	if not source.Is_Enemy( target ) then
		return false
	end

	if (target.Is_Category("Small") == true) then
		return true
	end

	if (target.Is_Category("Medium") == true) then
		return true
	end

	if (target.Is_Category("Large + Piloted") == true) then
		return true
	end

	return false
end

-- ======================================================================================= 
-- == Alien Material Optimizer Target
-- =======================================================================================
function Material_Optimizer_Target( source, target )

	--Must be same owner
	if ( source.Get_Owner() ~= target.Get_Owner() ) then
		return false
	end

	if (target.Is_Category("Huge") == false) then
		return false
	end

	if (target.Is_Category("Piloted") == false) then
		return false
	end

	return true
end



-- ======================================================================================= 
-- == Novus_Patch_Emergency_Power_Target
-- =======================================================================================
function Novus_Patch_Emergency_Power_Target( source, target )
	if target.Get_Owner() ~= source.Get_Owner() then
		return false
	end
	if not target.Has_Behavior(BEHAVIOR_POWERED) then
		return false
	end
	return true
end



-- ======================================================================================= 
-- == Novus_Constructor_Repair_Effect_Filter
-- =======================================================================================
function Novus_Constructor_Repair_Effect_Filter( source, target )
	if not TestValid(target) then
		return false
	end
	
	if target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) then
		return false
	end
	
	local target_health = target.Get_Hull() 
	
	return target_health < 1
end

function Alien_Kamal_Rex_Abduction_Effect_Filter( source, target )

	if (target.Is_Category("Flying") == true) then
		return false
	end

	if (target.Is_Category("Stationary") == true) then
		return false
	end

	if (target.Is_Category("Bridge") == true) then
		return false
	end

	if (target.Is_Category("Hero") == true) then
		return false
	end

	if (target.Is_Category("Resource") == true) then
		return false
	end

	if (target.Is_Category("HardPoint") == true) then
		return false
	end

	if (target.Is_Category("Huge") == true) then
		return false
	end

	if (target.Is_Category("Small") == true) then
		return true
	end

	if (target.Is_Category("Medium") == true) then
		return true
	end

	if (target.Is_Category("Piloted") == true) then
		return true
	end

	return false
end




-- -----------------------------------------------------------------------------------------------------
-- Get_Basic_Unit_Type
-- -----------------------------------------------------------------------------------------------------
function Get_Basic_Object_Type(object_type)
	if object_type == nil then 
		return nil
	end	
		
	
	-- it can be a customized version so let's make sure that is the case, else, this object is invalid!
	local base_object_type = object_type.Get_Type_Value("Variant_Of_Existing_Type")
	if base_object_type then
		return Get_Basic_Object_Type(base_object_type)
	else
		return object_type
	end
	
end



-- ======================================================================================= 
-- Oksana [6/26/2007]: Masari_Sentry_Load_Avenger_Filter_Function
-- ================================================================================================
function Masari_Sentry_Load_Avenger_Filter_Function( source, target )
	
	local base_type = Get_Basic_Object_Type(target.Get_Type())
   if base_type and base_type.Get_Name() == "MASARI_AVENGER" then
		return true
	end
	return false

end


-- ======================================================================================= 
-- Oksana [6/26/2007]: Masari_Sentry_Load_Architect_Filter_Function
-- ================================================================================================
function Masari_Sentry_Load_Architect_Filter_Function( source, target )
	
	local base_type = Get_Basic_Object_Type(target.Get_Type())
   if base_type and base_type.Get_Name() == "MASARI_ARCHITECT" then
		return true
	end
	return false
	
end


-- ======================================================================================= 
-- Oksana [6/26/2007]: Masari_Sentry_Load_Disciple_Filter_Function
-- ================================================================================================
function Masari_Sentry_Load_Disciple_Filter_Function( source, target )
	
	local base_type = Get_Basic_Object_Type(target.Get_Type())
   if base_type and base_type.Get_Name() == "MASARI_DISCIPLE" then
		return true
	end
	return false
	
end

-- ======================================================================================= 
-- Oksana [6/26/2007]: Masari_Sentry_Load_Seer_Filter_Function
-- ================================================================================================
function Masari_Sentry_Load_Seer_Filter_Function( source, target )
	
	local base_type = Get_Basic_Object_Type(target.Get_Type())
   if base_type and base_type.Get_Name() == "MASARI_SEER" then
		return true
	end
	return false
	
end



-- ======================================================================================= 
-- Oksana [6/26/2007]: Can_Enter_Vehicle_Filter_Function
-- ================================================================================================
function Can_Enter_Vehicle_Filter_Function ( source, target )
	if not Is_Ally_Not_Self_Filter_Function( source, target ) then
		return false
	end
		
	--Vehicle already has a passenger, so we can't enter
	if target.Get_Attribute_Value( "Is_Passenger_Onboard" ) ~= 0 then
		return false
	end
	
	return true
end

-- ======================================================================================= 
-- Oksana [6/26/2007]: Can_Enter_Vehicle_Filter_Function
-- ================================================================================================
function Can_Vehicle_Pick_Up_Passenger_Filter_Function ( source, target )
	 if source.Has_Effect_By_Name( "Viral_Control_Effect" ) then
        return false
    end
		
	--Vehicle already has a passenger, so we can't enter
	if source.Get_Attribute_Value( "Is_Passenger_Onboard" ) ~= 0 then
		return false
	end
	
	return true
end

-- ======================================================================================= 
-- Oksana [6/25/2007]: DMA filter functions
-- ================================================================================================


function Regen_DMA_Filter_Function( source, target )
	return In_Ice_Mode_Filter(source, target)
end


function DMA_Visual_Filter_Function( source, target )
	return In_Ice_Mode_Filter(source, target)
end


function Remove_DMA_Filter_Function( source, target )
	return In_Fire_Mode_Filter(source, target)
end

-- ======================================================================================= 
-- ****************************** SHARED EFFECTS *****************************************
-- ======================================================================================= 

-- ======================================================================================= 
-- JLH [5/1/2007]:  Achievement Effect -- Leadership
-- =======================================================================================
function Achievement_Leadership_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if ((base_type == Find_Object_Type("ALIEN_GRUNT")) or
				(base_type == Find_Object_Type("MASARI_DISCIPLE")) or
				(base_type == Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"))) then
				return true
			end
		end
	
	end
	
	return false
	
end


-- ======================================================================================= 
-- JLH [5/1/2007]:  Achievement Effect -- Protector
-- =======================================================================================
function Achievement_Protector_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if ((base_type == Find_Object_Type("ALIEN_ARRIVAL_SITE")) or
				(base_type == Find_Object_Type("MASARI_FOUNDATION")) or
				(base_type == Find_Object_Type("NOVUS_REMOTE_TERMINAL"))) then
				return true
			end
		end
	
	end
	
	return false
	
end


-- ======================================================================================= 
-- JLH [5/1/2007]:  Achievement Effect -- Researcher
-- =======================================================================================
function Achievement_Researcher_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if ((base_type == Find_Object_Type("ALIEN_GRUNT")) or
				(base_type == Find_Object_Type("MASARI_DISCIPLE")) or
				(base_type == Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"))) then
				return true
			end
		end
	
	end--]]
	
	return false
	
end


-- ======================================================================================= 
-- JLH [5/1/2007]:  Achievement Effect -- Alliance
-- =======================================================================================
function Achievement_Alliance_Filter( source, target )

	if (source.Get_Owner().Is_Ally(target.Get_Owner())) then
		return true
	end
	
	return false
	
end


-- ======================================================================================= 
-- JLH [5/1/2007]:  Achievement Effect -- Raw_Power
-- =======================================================================================
function Achievement_Raw_Power_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and		-- Player's units
		(not target.Is_Category("Hero")) and				-- Not a hero
		(not target.Is_Category("Stationary"))) then
		return true
	end
	
	return false
	
end


-- ======================================================================================= 
-- ******************************* NOVUS EFFECTS *****************************************
-- ======================================================================================= 

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Nanite_Mastery
-- =======================================================================================
function Achievement_Nanite_Mastery_Filter( source, target )

	--[[ JOE DBG::::::   Funtion probably not needed...
	if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Hero_Mastery
-- =======================================================================================
function Achievement_Hero_Mastery_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and target.Is_Category("Hero")) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Weapon_Mastery
-- =======================================================================================
function Achievement_Weapon_Mastery_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and 
		target.Is_Category("Piloted") and
		(not target.Is_Category("Huge")) and
		(not target.Is_Category("Flying"))) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Flight_Mastery
-- =======================================================================================
function Achievement_Flight_Mastery_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and target.Is_Category("Flying")) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Signal_Mastery
-- =======================================================================================
function Achievement_Signal_Mastery_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if (base_type == Find_Object_Type("NOVUS_SIGNAL_TOWER")) then
				return true
			end
		end
		
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Robotic_Mastery
-- =======================================================================================
function Achievement_Robotic_Mastery_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if ((base_type == Find_Object_Type("NOVUS_VARIANT")) or
				(base_type == Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"))) then
				return true
			end
		end
		
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Science_Mastery
-- =======================================================================================
function Achievement_Science_Mastery_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end


-- ======================================================================================= 
-- ****************************** MASARI EFFECTS *****************************************
-- ======================================================================================= 

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Kinetic_Seer
-- =======================================================================================
function Achievement_Kinetic_Seer_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and		-- Player's units
		(not target.Is_Category("Stationary")) and
		(not target.Is_Category("Huge"))) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Time_Manipulator
-- =======================================================================================
function Achievement_Time_Manipulator_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Dark_Strategist
-- =======================================================================================
function Achievement_Dark_Strategist_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and
		(target.Is_Category("Piloted")) and
		(not target.Is_Category("Flying"))) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Lightbringer
-- =======================================================================================
function Achievement_Lightbringer_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and
		(target.Is_Category("Piloted")) and
		(not target.Is_Category("Flying"))) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Modular_Proficiency
-- =======================================================================================
function Achievement_Modular_Proficiency_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Masari_Protectus
-- =======================================================================================
function Achievement_Masari_Protectus_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and target.Is_Category("Hero")) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Gift_Of_The_Architect
-- =======================================================================================
function Achievement_Gift_Of_The_Architect_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end


-- ======================================================================================= 
-- ******************************* ALIEN EFFECTS *****************************************
-- ======================================================================================= 

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Bovine_Defender
-- =======================================================================================
function Achievement_Bovine_Defender_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if (base_type == Find_Object_Type("ALIEN_SUPERWEAPON_REAPER_TURRET")) then
				return true
			end
		end
		
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Assault_Specialist
-- =======================================================================================
function Achievement_Assault_Specialist_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if ((base_type == Find_Object_Type("ALIEN_WALKER_ASSEMBLY")) or
				(base_type == Find_Object_Type("ALIEN_WALKER_HABITAT")) or
				(base_type == Find_Object_Type("ALIEN_WALKER_SCIENCE"))) then
				return true
			end
		end
		
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Mutagen_Specialist
-- =======================================================================================
function Achievement_Mutagen_Specialist_Filter( source, target )

	if (target.Get_Owner() == source.Get_Owner()) then
	
		local base_type = Get_Basic_Object_Type(target.Get_Type())
		if (TestValid(base_type)) then
			if (base_type == Find_Object_Type("ALIEN_BRUTE")) then
				return true
			end
		end
		
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Quantum_Specialist
-- =======================================================================================
function Achievement_Quantum_Specialist_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and		-- Player's units
		(not target.Is_Category("Stationary")) and
		(not target.Is_Category("Huge"))) then
		return true
	end
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Socket_Emblem
-- =======================================================================================
function Achievement_Socket_Emblem_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Insignia_Of_Corruption
-- =======================================================================================
function Achievement_Insignia_Of_Corruption_Filter( source, target )

	--[[if (target.Get_Owner() == source.Get_Owner()) then
		return true
	end--]]
	
	return false
	
end

-- ======================================================================================= 
-- JLH [5/2/2007]:  Achievement Effect -- Kamals_Blessing
-- =======================================================================================
function Achievement_Kamals_Blessing_Filter( source, target )

	if ((target.Get_Owner() == source.Get_Owner()) and target.Is_Category("Hero")) then
		return true
	end
	
	return false
	
end

function Novus_Portal_Filter_Function( source, target )
	
	if target.Get_Type().Get_Name() == "NOVUS_PORTAL_PIECE_01" then
		return true
	end

	return false
	
end

