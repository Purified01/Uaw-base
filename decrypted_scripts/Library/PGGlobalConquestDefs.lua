-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGGlobalConquestDefs.lua#16 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGGlobalConquestDefs.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 87062 $
--
--          $DateTime: 2007/10/31 14:42:26 $
--
--          $Revision: #16 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGFactions")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGGlobalConquestDefs_Init()

	PGFactions_Init()

	-- Versioning
	PG_GLOBAL_CONQUEST_FORMAT_VERSION_MAJOR = 1
	PG_GLOBAL_CONQUEST_FORMAT_VERSION_MINOR = 2

	-- Shading
	PG_GLOBAL_CONQUEST_UNCONQUERED_TINT = { 0.3, 0.3, 0.3, 1.0 }
	PG_GLOBAL_CONQUEST_SELECT_TINT = { 0.8, 0.8, 0.8, 1.0 }

	PG_GLOBAL_CONQUEST_SHADE_SETS = {}

	local shade_set = {}
	shade_set.ConqueredTint = { 0.08, 0.23, 0.25, 1.0 }
	shade_set.UnconqueredTint = PG_GLOBAL_CONQUEST_UNCONQUERED_TINT
	shade_set.SelectTint = { 0.43, 1.0, 1.0, 1.0 }
	PG_GLOBAL_CONQUEST_SHADE_SETS[PG_FACTION_NOVUS] = shade_set

	shade_set = {}
	shade_set.ConqueredTint = { 0.25, 0.06, 0.04, 1.0 }
	shade_set.UnconqueredTint = PG_GLOBAL_CONQUEST_UNCONQUERED_TINT
	shade_set.SelectTint = { 1.0, 0.2, 0.2, 1.0 }
	PG_GLOBAL_CONQUEST_SHADE_SETS[PG_FACTION_ALIEN] = shade_set

	shade_set = {}
	shade_set.ConqueredTint = { 0.27, 0.27, 0.10, 1.0 }
	shade_set.UnconqueredTint = PG_GLOBAL_CONQUEST_UNCONQUERED_TINT
	shade_set.SelectTint = { 1.0, 1.0, 0.53, 1.0 }
	PG_GLOBAL_CONQUEST_SHADE_SETS[PG_FACTION_MASARI] = shade_set


	-- The Regions (per faction).
	PGGlobalConquestRegionLabels = nil		-- Populated by _PG_GC_Create_Region_List()
	_PGDefaultGlobalConquestRegions = _PG_GC_Create_Default_Region_Set()

end

-------------------------------------------------------------------------------
-- Accessor for the basis global conquest regions store.  There is one set
-- of regions for each faction.
-------------------------------------------------------------------------------
function Get_Default_Global_Conquest_Regions()
	return _PGDefaultGlobalConquestRegions
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PG_GC_Create_Clean_Region_Set()
	return _PG_GC_Create_Default_Region_Set()
end

-------------------------------------------------------------------------------
-- Creates a default region set.
-------------------------------------------------------------------------------
function _PG_GC_Create_Default_Region_Set()

	local region_set = {}

	-- File version
	region_set.FormatVersionMajor = PG_GLOBAL_CONQUEST_FORMAT_VERSION_MAJOR
	region_set.FormatVersionMinor = PG_GLOBAL_CONQUEST_FORMAT_VERSION_MINOR

	-- One list per faction
	region_set[PG_FACTION_NOVUS] = _PG_GC_Create_Region_List()
	region_set[PG_FACTION_ALIEN] = _PG_GC_Create_Region_List()
	region_set[PG_FACTION_MASARI] = _PG_GC_Create_Region_List()
	
	-- Per-faction meta-data
	region_set[PG_FACTION_NOVUS].MetaData = _PG_GC_Create_Meta_Data()
	region_set[PG_FACTION_ALIEN].MetaData = _PG_GC_Create_Meta_Data()
	region_set[PG_FACTION_MASARI].MetaData = _PG_GC_Create_Meta_Data()

	return region_set
	
end

-------------------------------------------------------------------------------
-- Creates and returns an array of all regions on the globe with associated 
-- data.
-------------------------------------------------------------------------------
function _PG_GC_Create_Region_List()

	local region
	local region_list = {}
	RegionSequence = 1

	-- *** NORTH AMERICA ***
	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_22", "Great beer.", "22", "M22_Appalachia")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_23", "Great food.", "23", "M23_Gulf_Coast")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_24", "Great food.", "24", "M24_Midwest")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_26", "Great wine.", "26", "M26_Pacific_Northwest")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_27", "Great museums.", "27", "M27_Sierra_Nevada")
	table.insert(region_list, region)


	-- *** CENTRAL AMERICA ***
	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_34", "Great wine.", "34", "M34_Anahuac")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_35", "Great beer.", "35", "M35_Central_America")
	table.insert(region_list, region)


	-- *** SOUTH AMERICA ***
	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_29", "Great food.", "29", "M29_Brazillian_Highlands")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_30", "Great wine.", "30", "M30_Altiplano")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_31", "Great museums.", "31", "M31_Amazon_Basin")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_33", "Great food.", "33", "M33_Guiana")
	table.insert(region_list, region)


	-- *** EUROPE ***
	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_1", "Great beer.", "1", "M01_British_Isles")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_3", "Great museums.", "3", "M03_Western_Europe")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_4", "Great food.", "4", "M04_Eastern_Europe")
	table.insert(region_list, region)


	-- *** AFRICA ***
	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_15", "Great wine.", "15", "M15_Middle_East")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_16", "Great food.", "16", "M16_Sahara")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_17", "Great museums.", "17", "M17_East_Africa")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_18", "Great wine.", "18", "M18_North_Africa")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_20", "Great beer.", "20", "M20_Congo")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_21", "Great food.", "21", "M21_South_Africa")
	table.insert(region_list, region)


	-- *** ASIA ***
	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_7", "Great museums.", "7", "M07_Turkestan")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_8", "Great food.", "8", "M08_Eastern_Siberia")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_9", "Great wine.", "9", "M09_Tibetan_Plateau")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_11", "Great beer.", "11", "M11_Kamchatka")
	table.insert(region_list, region)

	region = Create_Base_Global_Conquest_Definition("TEXT_REGION_13", "Great food.", "13", "M13_Indochina")
	table.insert(region_list, region)


	-- Build a simple table which lists all the labels.
	if (PGGlobalConquestRegionLabels == nil) then
		PGGlobalConquestRegionLabels = {}
		for _, region in ipairs(region_list) do
			table.insert(PGGlobalConquestRegionLabels, region.Label)
		end
	end

	return region_list

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PG_GC_Create_Meta_Data()
	local meta_data = {}
	meta_data.GlobalConquerCount = 0
	return meta_data
end

-------------------------------------------------------------------------------
-- Return a base definition that will fill out all the stuff that has to be
-- in every definition.
-------------------------------------------------------------------------------
function Create_Base_Global_Conquest_Definition(name, desc, label, map)

	local def = {}
	def.Index = RegionSequence
	RegionSequence = RegionSequence + 1
	def.ConqueredStatus = false

	if (name ~= nil) then
		def.Name = Get_Game_Text(name)
	end

	if (desc ~= nil) then
		def.Description = desc
	end

	if (label ~= nil) then
		def.Label = label
	end

	if (map ~= nil) then
		def.Map = map
	end
	
	def.ConquerAttempts = 0

	return def

end

-------------------------------------------------------------------------------
-- Makes sure that the region is formatted as expected by the current 
-- version of the region system.
--
-- Return value is true if the definition is up-to-date, false otherwise.
-- 	If false, it should be re-persisted as soon as possible.
-------------------------------------------------------------------------------
function Validate_Region_Definitions(regions)

	-- If the version matches, we know the format is good.
	if ((regions.FormatVersionMajor == PG_GLOBAL_CONQUEST_FORMAT_VERSION_MAJOR) and
		(regions.FormatVersionMinor == PG_GLOBAL_CONQUEST_FORMAT_VERSION_MINOR)) then
		return true
	end

	-- We create a new table in order to prune regions which do not appear in the authoritative list.
	local new_regions = {}

	-- REGION FORMAT UPDATE CODE GOES HERE.
	-- Make sure the basics are overridden by the latest definition of the table
	-- For dev, just clobber the old stuff.
	new_regions = _PG_GC_Create_Default_Region_Set()

	DebugMessage("Regions are now up to date.")
	return false, new_regions

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function PG_GC_Create_Props_From_Lobby(root_map)
	-- For now the incoming table should be formatted properly, but in the
	-- future we may need to perform some kind of translation.
	return root_map
end

-------------------------------------------------------------------------------
-- All we get back from the server are the essentials of conquer status and 
-- global conquer tallies per faction.  The GC lobby display needs all the 
-- other information that needs to be associated with the regions, so we
-- need to start with the authoritative definitions here, and just overwrite
-- the essential progress fields with what came back from the server.
-------------------------------------------------------------------------------
function PG_GC_Merge_Regions_From_Load(stripped)

	local base = _PG_GC_Create_Default_Region_Set()
	
	for faction_id, faction_data in pairs(base) do
	
		if ((faction_id ~= "FormatVersionMajor") and (faction_id ~= "FormatVersionMinor")) then
		
			-- Set the meta data.
			faction_data.MetaData.GlobalConquerCount = stripped[faction_id].MetaData.GlobalConquerCount
			
			-- Set the conquer flag for each region.
			for region_index, region in pairs(faction_data) do
				if (region_index ~= "MetaData") then
					region.ConqueredStatus = stripped[faction_id][region_index].ConqueredStatus
				end
			end
		
		end

	end
	
	return base
	
end


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- [JLH 6/7/2007]:  FOR NOW DO NOT DELETE THE FUNCTIONS BELOW.
-- We now persist global conquest progress to the XLive backend, but there may be a need to persist non-critical
-- data to disk as well, in which case we will need the functionality provided below.
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- All that gets saved to disk is the boolean flag telling whether each region
-- is conquered or not.  In order to be useful at the display layer, we merge
-- that data with all the other per-region required data.
-------------------------------------------------------------------------------
--[[function PG_GC_Merge_Regions_From_Load(stripped)

	local merged = _PG_GC_Create_Default_Region_Set()

	_PG_GC_Merge_Region_List(merged[PG_FACTION_NOVUS], stripped[PG_FACTION_NOVUS])
	_PG_GC_Merge_Region_List(merged[PG_FACTION_ALIEN], stripped[PG_FACTION_ALIEN])
	_PG_GC_Merge_Region_List(merged[PG_FACTION_MASARI], stripped[PG_FACTION_MASARI])
	merged.MetaData = stripped.MetaData

	return merged

end--]]

-------------------------------------------------------------------------------
-- Merges the ConqueredStatus flag values from "stripped" into "merged".
-------------------------------------------------------------------------------
--[[function _PG_GC_Merge_Region_List(merge_list, stripped_list)

	for i, region in pairs(merge_list) do
		local map = stripped_list[merge_list[i].Label]
		merge_list[i].ConqueredStatus = map.ConqueredStatus
		merge_list[i].ConquerAttempts = map.ConquerAttempts
	end

end--]]

-------------------------------------------------------------------------------
-- All that gets saved to disk is the boolean flag telling whether each region
-- is conquered or not.
-------------------------------------------------------------------------------
--[[function PG_GC_Strip_Regions_For_Save(merged)

	local stripped = {}

	stripped.FormatVersionMajor = merged.FormatVersionMajor
	stripped.FormatVersionMinor = merged.FormatVersionMinor

	stripped[PG_FACTION_NOVUS] = _PG_GC_Strip_Region_List(merged[PG_FACTION_NOVUS])
	stripped[PG_FACTION_ALIEN] = _PG_GC_Strip_Region_List(merged[PG_FACTION_ALIEN])
	stripped[PG_FACTION_MASARI] = _PG_GC_Strip_Region_List(merged[PG_FACTION_MASARI])
	
	stripped.MetaData = merged.MetaData

	return stripped

end--]]

-------------------------------------------------------------------------------
-- Merges the ConqueredStatus flag values from "stripped" into "merged".
-------------------------------------------------------------------------------
--[[function _PG_GC_Strip_Region_List(merged_list)

	local strip_list = {}

	for i, region in pairs(merged_list) do
		strip_list[i] = {}
		strip_list[merged_list[i].Label] = {
			ConqueredStatus = merged_list[i].ConqueredStatus,
			ConquerAttempts = merged_list[i].ConquerAttempts,
		}
	end

	return strip_list

end--]]

