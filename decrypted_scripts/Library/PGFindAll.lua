if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGFindAll.lua#4 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGFindAll.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")



-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- RICK 12.07.2006
--
-- PG_Find_All_Objects_Of_Type(type) - This function serves as a 'virtual wrapper' for Find_All_Objects_Of_Type.
-- any objects which span a range of types (Alien_Recon_Tank and Alien_Recon_Tank_Flying for example)
-- will be returned in a single combined list. If a non spanning object type is given, it executes the normal function.
-- This function can also be used to find structures under construction combined with the intact ones of similar type.
-- It will not find and combine beacons, as those structures are not technically active yet.
--
-- Always use the base/ground unit or the completed structure as the search object to ensure success.
--
-- NOTE: The code function that we wrap (Find_All_Objects_Of_Type) supports many filter parameters beyond just
-- the object type. In order to support those additional filters (such as Player!!!), we use the variable argument
-- syntax here to mimic the flexible function call syntax of Find_All_Objects_Of_Type itself. See the wiki entry!
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------
function PG_Find_All_Objects_Of_Type(input_type, ...)

	-- Initialize the variant lookup list.
	local discovered_variant_list = {}
	local total_variant_list = {}
	local variant_count,append_count

	if variant_lookups == nil then
		variant_lookups = {}

		-- Alien Structures
		variant_lookups["Alien_Arrival_Site"] = {"Alien_Arrival_Site", "Alien_Arrival_Site_Construction"}
		variant_lookups["Alien_Gravitic_Manipulator"] = {"Alien_Gravitic_Manipulator", "Alien_Gravitic_Manipulator_Construction"}
		variant_lookups["Alien_Radiation_Spitter"] = {"Alien_Radiation_Spitter", "Alien_Radiation_Spitter_Construction"}
		variant_lookups["Alien_Superweapon_Mass_Drop"] = {"Alien_Superweapon_Mass_Drop", "Alien_Superweapon_Mass_Drop_Construction"}


		-- Alien Walkers
		variant_lookups["Alien_Walker_Assembly"] = {"Alien_Walker_Assembly", "Customized_Alien_Walker_Assembly", "Alien_Walker_Assembly_Glyph", "Customized_Alien_Walker_Assembly_Glyph"}
		variant_lookups["Alien_Walker_Habitat"] = {"Alien_Walker_Habitat", "Customized_Alien_Walker_Habitat", "Alien_Walker_Habitat_Glyph", "Customized_Alien_Walker_Habitat_Glyph"}
		variant_lookups["Alien_Walker_Science"] = {"Alien_Walker_Science", "Customized_Alien_Walker_Science", "Alien_Walker_Science_Glyph", "Customized_Alien_Walker_Science_Glyph"}


		-- Alien Units
		variant_lookups["Alien_Hero_Orlok"] = {"Alien_Hero_Orlok", "Alien_Hero_Orlok_Base", "Alien_Hero_Orlok_Endure_Mode", "Alien_Hero_Orlok_Siege_Mode"}
		variant_lookups["Alien_Superweapon_Reaper_Turret"] = {"Alien_Superweapon_Reaper_Turret", "Alien_Reaper_Turret_Beacon", "Alien_Reaper_Turret_Construction"}
		variant_lookups["Alien_Scan_Drone"] = {"Alien_Scan_Drone", "Alien_Scan_Drone_Construction"}


		-- Masari Structures
		variant_lookups["Masari_Air_Inspiration"] = {"Masari_Air_Inspiration", "Masari_Air_Inspiration_Beacon", "Masari_Air_Inspiration_Construction", "Masari_Air_Inspiration_Fire", "Masari_Air_Inspiration_Ice"}
		variant_lookups["Masari_Atlatea"] = {"Masari_Atlatea", "Masari_Atlatea_Fire", "Masari_Atlatea_Ice"}
		variant_lookups["Masari_Element_Magnet"] = {"Masari_Element_Magnet_Fire", "Masari_Element_Magnet_Ice"}
		variant_lookups["Masari_Elemental_Collector"] = {"Masari_Elemental_Collector", "Masari_Elemental_Collector_Beacon", "Masari_Elemental_Collector_Construction", "Masari_Elemental_Collector_Fire", "Masari_Elemental_Collector_Ice"}
		variant_lookups["Masari_Elemental_Controller"] = {"Masari_Elemental_Controller", "Masari_Elemental_Controller_Beacon", "Masari_Elemental_Controller_Construction", "Masari_Elemental_Controller_Fire", "Masari_Elemental_Controller_Ice"}
		variant_lookups["Masari_Foundation"] = {"Masari_Foundation","Masari_Foundation_Beacon" ,"Masari_Foundation_Construction", "Masari_Foundation_Fire", "Masari_Foundation_Ice"}
		variant_lookups["Masari_Ground_Inspiration"] = {"Masari_Ground_Inspiration","Masari_Ground_Inspiration_Beacon" , "Masari_Ground_Inspiration_Construction", "Masari_Ground_Inspiration_Fire", "Masari_Ground_Inspiration_Ice"}
		variant_lookups["Masari_Guardian"] = {"Masari_Guardian","Masari_Guardian_Beacon" ,"Masari_Guardian_Construction", "Masari_Guardian_Fire", "Masari_Guardian_Ice"}
		variant_lookups["Masari_Infantry_Inspiration"] = {"Masari_Infantry_Inspiration", "Masari_Infantry_Inspiration_Beacon", "Masari_Infantry_Inspiration_Construction", "Masari_Infantry_Inspiration_Fire", "Masari_Infantry_Inspiration_Ice"}
		variant_lookups["Masari_Inventors_Lab"] = {"Masari_Inventors_Lab","Masari_Inventors_Lab_Beacon" , "Masari_Inventors_Lab_Construction", "Masari_Inventors_Lab_Fire", "Masari_Inventors_Lab_Ice"}
		variant_lookups["Masari_Key_Inspiration"] = {"Masari_Key_Inspiration", "Masari_Key_Inspiration_Fire", "Masari_Key_Inspiration_Ice"}
		variant_lookups["Masari_Megaweapon"] = {"Masari_Megaweapon", "Masari_Megaweapon_Fire", "Masari_Megaweapon_Ice"}
		variant_lookups["Masari_Natural_Interpreter"] = {"Masari_Natural_Interpreter","Masari_Natural_Interpreter_Beacon", "Masari_Natural_Interpreter_Construction", "Masari_Natural_Interpreter_Fire", "Masari_Natural_Interpreter_Ice"}
		variant_lookups["Masari_Sky_Guardian"] = {"Masari_Sky_Guardian", "Masari_Sky_Guardian_Beacon", "Masari_Sky_Guardian_Construction", "Masari_Sky_Guardian_Fire", "Masari_Sky_Guardian_Ice"}
		variant_lookups["Masari_Will_Processor"] = {"Masari_Will_Processor", "Masari_Will_Processor_Fire", "Masari_Will_Processor_Ice"}


		-- Masari Units
		variant_lookups["Masari_Hero_Charos"] = {"Masari_Hero_Charos", "Masari_Hero_Charos_Fire", "Masari_Hero_Charos_Ice"}
		variant_lookups["Masari_Hero_Zessus"] = {"Masari_Hero_Zessus", "Masari_Hero_Zessus_Base", "Masari_Hero_Zessus_Fire", "Masari_Hero_Zessus_Ice"}
		variant_lookups["Masari_Figment"] = {"Masari_Figment", "Masari_Figment_Fire", "Masari_Figment_Ice"}
		variant_lookups["Masari_Seeker"] = {"Masari_Seeker", "Masari_Seeker_Fire", "Masari_Seeker_Ice"}
		variant_lookups["Masari_Skylord"] = {"Masari_Skylord", "Masari_Skylord_Fire", "Masari_Skylord_Ice"}
		variant_lookups["Masari_Architect"] = {"Masari_Architect","Masari_Architect_Fire","Masari_Architect_Ice"}
	--	variant_lookups["Masari_Architect"] = {"Masari_Architect", "Masari_Sentry_With_Architect"}
		variant_lookups["Masari_Seer"] = {"Masari_Seer", "Masari_Seer_Fire", "Masari_Seer_Ice"}
	--	variant_lookups["Masari_Seer"] = {"Masari_Seer", "Masari_Seer_Fire", "Masari_Seer_Ice", "Masari_Sentry_With_Seer"}
		variant_lookups["Masari_Enforcer"] = {"Masari_Enforcer", "Masari_Enforcer_Fire", "Masari_Enforcer_Ice"}
		variant_lookups["Masari_Peacebringer"] = {"Masari_Peacebringer", "Masari_Peacebringer_Fire", "Masari_Peacebringer_Ice"}

		variant_lookups["Masari_Avenger"] = {"Masari_Avenger",
														 "Masari_Avenger_Enforcer",		"Masari_Avenger_Enforcer_Fire",			"Masari_Avenger_Enforcer_Ice",
														 "Masari_Avenger_Peacebringer",	"Masari_Avenger_Peacebringer_Fire",		"Masari_Avenger_Peacebringer_Ice",
														 "Masari_Avenger_Seeker",			"Masari_Avenger_Seeker_Fire",				"Masari_Avenger_Seeker_Ice",
														 "Masari_Avenger_Sentry",			"Masari_Avenger_Sentry_Fire",				"Masari_Avenger_Sentry_Ice",
														 "Masari_Avenger_Skylord",			"Masari_Avenger_Skylord_Fire",			"Masari_Avenger_Skylord_Ice",
														 "Masari_Avenger_Figment",			"Masari_Avenger_Figment_Fire",			"Masari_Avenger_Figment_Ice"
														}

		variant_lookups["Masari_Disciple"] = {"Masari_Disciple", "Masari_Disciple_Fire", "Masari_Disciple_Ice",}

	--	variant_lookups["Masari_Disciple"] = {"Masari_Disciple", "Masari_Disciple_Fire", "Masari_Disciple_Ice",
	--			"Masari_Sentry_With_Disciple", "Masari_Sentry_With_Disciple_Fire", "Masari_Sentry_With_Disciple_Ice"}


		variant_lookups["Masari_Sentry"] = {"Masari_Sentry", "Masari_Sentry_Fire","Masari_Sentry_Ice"}


		-- Novus Structures
		variant_lookups["Novus_Aircraft_Assembly"] = {"Novus_Aircraft_Assembly", "Novus_Aircraft_Assembly_Construction", "Novus_Aircraft_Assembly_With_Scramjet_Hangar"}
		variant_lookups["Novus_Superweapon_Gravity_Bomb"] = {"Novus_Superweapon_Gravity_Bomb", "Novus_Superweapon_Gravity_Bomb_Construction", "NM01_Gravity_Bomb"}
		variant_lookups["Novus_Input_Station"] = {"Novus_Input_Station","Novus_Input_Station_Beacon", "Novus_Input_Station_Construction"}
		variant_lookups["Novus_Power_Router"] = {"Novus_Power_Router", "Novus_Power_Router_Construction"}
		variant_lookups["Novus_Redirection_Turret"] = {"Novus_Redirection_Turret", "Novus_Redirection_Turret_Construction"}
		variant_lookups["Novus_Remote_Terminal"] = {"Novus_Remote_Terminal", "Novus_Remote_Terminal_Construction"}
		variant_lookups["Novus_Robotic_Assembly"] = {"Novus_Robotic_Assembly", "Novus_Robotic_Assembly_Construction", "Novus_Robotic_Assembly_With_Instance_Generator"}
		variant_lookups["Novus_Science_Lab"] = {"Novus_Science_Lab", "Novus_Science_Center_Construction", "Novus_Science_Lab_With_Singularity_Compressor"}
		variant_lookups["Novus_Signal_Tower"] = {"Novus_Signal_Tower", "Novus_Signal_Tower_Construction"}
		variant_lookups["Novus_Superweapon_EMP"] = {"Novus_Superweapon_EMP", "Novus_Superweapon_EMP_Construction"}
		variant_lookups["Novus_Vehicle_Assembly"] = {"Novus_Vehicle_Assembly", "Novus_Vehicle_Assembly_Construction", "Novus_Vehicle_Assembly_With_Inversion_Processor", "Novus_Vehicle_Assembly_With_Resonation_Processor"}


		-- Novus Units
		variant_lookups["Novus_Hero_Founder"] = {"Novus_Hero_Founder", "Novus_Hero_Founder_Performance"}
		variant_lookups["Novus_Field_Inverter"] = {"Novus_Field_Inverter", "Novus_Field_Inverter_Shield_Mode"}
	end


	local variant_types = variant_lookups[input_type]

	-- If there are no variant types for this entry, perform a regular find.
	if variant_types == nil then
		return Find_All_Objects_Of_Type(input_type, ...)
	else
		-- Perform a compound search for variants.
		for variant_count = 1,#variant_types do
			discovered_variant_list = Find_All_Objects_Of_Type(variant_types[variant_count], ...)
			if #discovered_variant_list > 0 then
				for append_count = 1,#discovered_variant_list do
					table.insert(total_variant_list,discovered_variant_list[append_count])
				end
			end
		end
		return total_variant_list
	end

end


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
	PG_Find_All_Objects_Of_Type = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
