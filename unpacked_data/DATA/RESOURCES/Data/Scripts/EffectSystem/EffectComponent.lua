-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/EffectSystem/EffectComponent.lua#21 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/EffectSystem/EffectComponent.lua $
--
--    Original Author: Bret Ambrose
--
--            $Author: Joe_Howes $
--
--            $Change: 78864 $
--
--          $DateTime: 2007/07/28 18:41:00 $
--
--          $Revision: #21 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGBase")
require("PGUICommands")



EffectComponentData = {}

function Apply_Effect_Component( source, target, original_target, apply_function_ptr, component_id )

	local component_data = {}
	
	EffectComponentData[ component_id ] = component_data
	
	apply_function_ptr( source, target, original_target, component_data )
	
end

function Unapply_Effect_Component( source, target, original_target, unapply_function_ptr, component_id )

	unapply_function_ptr( source, target, original_target, EffectComponentData[ component_id ] )
	
	EffectComponentData[ component_id ] = nil
	
end

function Test_Apply_Function( source, target, original_target, component_data )
	 
	component_data[ 1 ] = target.Add_Attribute_Modifier( "Is_Phasable", 0 )
	
end

function Test_Unapply_Function( source, target, original_target, component_data )
	
	target.Remove_Attribute_Modifier( "Is_Phasable", component_data[ 1 ] )
	 
end


function Alien_Manual_Resource_Harvesting_Apply_Function( source, target, original_target, component_data )
	 
	if TestValid( source ) and TestValid( target ) and source.Get_Script()~= nil then
		source.Get_Script().Call_Function("Begin_Manual_Resource_Harvesting", target)
	end	
end


function Alien_Manual_Resource_Harvesting_Unapply_Function( source, target, original_target, component_data )
	
	 if TestValid( source ) and TestValid( target ) and source.Get_Script()~= nil then
		source.Get_Script().Call_Function("End_Manual_Resource_Harvesting", target)
	end	
end


--=================================================================================================
-- Lock_Alien_Orlok_Siege_Endure
--================================================================================================ 
function Lock_Alien_Orlok_Endure(source, target, original_target, component_data)
	
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Switch_To_Endure_Mode", true)
	end
	
	
end

--=================================================================================================
-- Unlock_Alien_Orlok_Siege_Endure
--================================================================================================ 
function Unlock_Alien_Orlok_Endure(source, target, original_target, component_data)
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Switch_To_Endure_Mode", false)
	end
	
end




--=================================================================================================
-- Lock_Alien_Orlok_Siege_Endure
--================================================================================================ 
function Lock_Alien_Orlok_Siege(source, target, original_target, component_data)
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Switch_To_Siege_Mode", true)
	end
	
end

--=================================================================================================
-- Unlock_Alien_Orlok_Siege_Endure
--================================================================================================ 
function Unlock_Alien_Orlok_Siege(source, target, original_target, component_data)

	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Switch_To_Siege_Mode", false)
	end
end


--=================================================================================================
-- Orlok_Exit_Seige_Mode
--================================================================================================ 
function Orlok_Exit_Seige_Mode(source, target, original_target, component_data)
	if TestValid( target ) and target.Is_Ability_Active("Alien_Orlok_Switch_To_Siege_Mode") then
		-- Deactivate Siege mode as we are targeting with our crush weapon
		target.Activate_Ability("Alien_Orlok_Switch_To_Siege_Mode", false)
	end
end

--=================================================================================================
-- Lock_Alien_Orlok_Siege_Check_Ammo
--================================================================================================ 
function Lock_Alien_Orlok_Siege_Check_Ammo(source, target, original_target, component_data)
	if TestValid( target ) then
		if (target.Get_Energy() <= 0) then
			-- Deactivate Siege mode if no more ammo available
			target.Activate_Ability("Alien_Orlok_Switch_To_Siege_Mode", false)
		end		
	end
end

--=================================================================================================
-- [10/19/2006] Can't use regular death clone as we don't know the damage type that
-- caused death in advance. Can't use regular effects due to mines setup - mode-specific mines
-- derive from a base mine XML.  - Oksana Kubushyna
--================================================================================================ 
function Figment_Masary_Elemental_Mine_Spawn_Death_Clone_Apply_Function( source, target, original_target, component_data )
	 
	 if(target.Get_Type().Get_Name() == "MASARI_FIGMENT_ICE_MINE")then
		Create_Generic_Object(Find_Object_Type("MASARI_FIGMENT_ICE_MINE_EFFECT_OBJECT"), target.Get_Position(), target.Get_Owner())
		return
	 end
	 
	 if(target.Get_Type().Get_Name() == "MASARI_FIGMENT_FIRE_MINE")then
		Create_Generic_Object(Find_Object_Type("MASARI_FIGMENT_FIRE_MINE_EFFECT_OBJECT"), target.Get_Position(), target.Get_Owner())
		return
	 end
	 
	 if(target.Get_Type().Get_Name() == "MASARI_STORMCHASER_BOLT_MINE")then
		-- last parameter ("snap_to_terrain_height") is false - we want to spawn this mine effect at same position as original mine
		Create_Generic_Object(Find_Object_Type("MASARI_STORMCHASER_BOLT_MINE_EFFECT_OBJECT"), target.Get_Position(), target.Get_Owner(), false)
		return
	 end
	 
	 
end

function Figment_Masary_Elemental_Mine_Spawn_Death_Clone_Unapply_Function( source, target, original_target, component_data )
	-- nop	 
end




-- 11/10/06 JAC - Functions for tactical non-persistant upgrades
function Lock_Alien_Speed_Upgrade_Function(source, target, original_target, component_data)
	local player = source.Get_Owner()
	player.Lock_Object_Type(Find_Object_Type("ALIEN_RESEARCH_CONDUIT_UPGRADE_SPEED_HP"), true, UTILITY)
end

 
function Unlock_Alien_Speed_Upgrade_Function(source, target, original_target, component_data)
	local player = target.Get_Owner()
	player.Lock_Object_Type(Find_Object_Type("ALIEN_RESEARCH_CONDUIT_UPGRADE_SPEED_HP"), false, UTILITY)
end





-- 11/28/06 JAC - Functions for tactical non-persistant upgrades
function Lock_Novus_Speed_Upgrade_Function(source, target, original_target, component_data)
	local player = source.Get_Owner()
	player.Lock_Object_Type(Find_Object_Type("NOVUS_SCIENCE_UPGRADE_SPEED_HP"), true, UTILITY)
end

 
function Unlock_Novus_Speed_Upgrade_Function(source, target, original_target, component_data)
	local player = target.Get_Owner()
	player.Lock_Object_Type(Find_Object_Type("NOVUS_SCIENCE_UPGRADE_SPEED_HP"), false, UTILITY)
end


-- 11/28/06 JAC - Functions for tactical non-persistant upgrades
function Lock_Novus_Fire_Upgrade_Function(source, target, original_target, component_data)
	local player = source.Get_Owner()
	player.Lock_Object_Type(Find_Object_Type("NOVUS_SCIENCE_UPGRADE_FIRE_RATE_HP"), true, UTILITY)
end

 
function Unlock_Novus_Fire_Upgrade_Function(source, target, original_target, component_data)
	local player = target.Get_Owner()
	player.Lock_Object_Type(Find_Object_Type("NOVUS_SCIENCE_UPGRADE_FIRE_RATE_HP"), false, UTILITY)
end

--=================================================================================================
-- Masari_Architect_Upgrade_HP_Apply_Function: start building a auto upgrade hard point
--================================================================================================ 
function Masari_Architect_Upgrade_HP_Apply_Function(source, target, original_target, component_data)
	if TestValid( target ) then
	
		if target.Get_Owner() == source.Get_Owner() and target.Get_Building_Object_Type( true ) == nil then
		
			local hp_info = target.Get_Next_Hard_Point_Tier_Upgrade()
			
			if hp_info ~= nil and hp_info[1] ~= nil and hp_info[2] ~= nil then
				-- there is both a socket available and a tier hard point left
				-- start building the object, validate data and don't sell
				hp_info[2].Build(hp_info[1], true, false )
			end
		end
	end
end

--=================================================================================================
-- Masari_Architect_Upgrade_HP_Unapply_Function: unapply
--================================================================================================ 
function Masari_Architect_Upgrade_HP_Unapply_Function(source, target, original_target, component_data)
	-- currently does nothing
end


		

--=================================================================================================
-- Masari_Charos_Lock_Elemental_Charge_Apply_Function
--================================================================================================ 
function Lock_Masari_Charos_Blaze_Of_Glory(source, target, original_target, component_data)

	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Blaze_Of_Glory_Ability", true)
	end

	
end

--=================================================================================================
-- Masari_Charos_Lock_Elemental_Charge_Unapply_Function
--================================================================================================ 
function Unlock_Masari_Charos_Blaze_Of_Glory(source, target, original_target, component_data)
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Blaze_Of_Glory_Ability", false)
	end
	
end


--=================================================================================================
-- Masari_Charos_Lock_Elemental_Charge_Apply_Function
--================================================================================================ 
function Lock_Masari_Charos_Ice_Crystals(source, target, original_target, component_data)
	if TestValid( target ) then
		target.Get_Owner().Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Ice_Crystals_Ability", true)
	end
end

--=================================================================================================
-- Masari_Charos_Lock_Elemental_Charge_Unapply_Function
--================================================================================================ 
function Unlock_Masari_Charos_Ice_Crystals(source, target, original_target, component_data)
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Ice_Crystals_Ability", false)
	end

end

--=================================================================================================
-- Masari_Charos_Lock_Elemental_Charge_Apply_Function
--================================================================================================ 
function Lock_Masari_Charos_Elemental_Fury(source, target, original_target, component_data)
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Elemental_Fury_Ability", true)
	end
	

end

--=================================================================================================
-- Masari_Charos_Lock_Elemental_Charge_Unapply_Function
--================================================================================================ 
function Unlock_Masari_Charos_Elemental_Fury(source, target, original_target, component_data)
	
	if target.Get_Owner() then
		target.Get_Owner().Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Elemental_Fury_Ability", false)
	end
end

--=================================================================================================
-- ACHIEVEMENT BUFF:  Nanite Mastery [Novus]
--================================================================================================ 
function Apply_Achievement_Nanite_Mastery(source, target, original_target, component_data)
	
	local player = source.Get_Owner()
	player.Lock_Unit_Ability("Novus_Constructor", "Novus_Constructor_Repair_Spray_Ability_Generator", true)
	player.Lock_Generator("Novus_Constructor_Repair_Spray_Effect_Generator", true)
	player.Lock_Unit_Ability("Novus_Constructor", "Achievement_Novus_Constructor_Repair_Spray_Ability_Generator", false)
	player.Lock_Generator("Achievement_Novus_Constructor_Repair_Spray_Effect_Generator", false)

end

--=================================================================================================
-- ACHIEVEMENT BUFF:  Nanite Mastery [Novus]
--================================================================================================ 
function Unapply_Achievement_Nanite_Mastery(source, target, original_target, component_data)
	
	local player = source.Get_Owner()
	player.Lock_Unit_Ability("Novus_Constructor", "Novus_Constructor_Repair_Spray_Ability_Generator", false)
	player.Lock_Generator("Novus_Constructor_Repair_Spray_Effect_Generator", false)
	player.Lock_Unit_Ability("Novus_Constructor", "Achievement_Novus_Constructor_Repair_Spray_Ability_Generator", true)
	player.Lock_Generator("Achievement_Novus_Constructor_Repair_Spray_Effect_Generator", true)
	
end




--=================================================================================================
-- ACHIEVEMENT BUFF:  Nanite Mastery [Novus]
--================================================================================================ 
function Apply_Achievement_Gift_Of_Architect(source, target, original_target, component_data)
	
	local player = source.Get_Owner()
	player.Lock_Effect( "Achievement_Masari_Architect_Build_Effect", false )


end

--=================================================================================================
-- ACHIEVEMENT BUFF:  Nanite Mastery [Novus]
--================================================================================================ 
function Unapply_Achievement_Gift_Of_Architect(source, target, original_target, component_data)
	
	local player = source.Get_Owner()
	player.Lock_Effect( "Achievement_Masari_Architect_Build_Effect", true )
	
end





