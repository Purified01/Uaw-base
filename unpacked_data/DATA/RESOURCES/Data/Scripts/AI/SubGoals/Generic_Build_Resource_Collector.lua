-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Build_Resource_Collector.lua#5 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Build_Resource_Collector.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 76451 $
--
--          $DateTime: 2007/07/12 14:55:55 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGLogging")

ScriptShouldCRC = true

---------------------- Script Globals ----------------------

function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIResourceLog.txt"
end



---------------------- Goal Events and Queries ----------------------


function Compute_Desire()
	
	if not Target then
		Goal.Suppress_Goal()
		return 0.0
	end

	--Centering a plan to build a resource structure on an enemy object is almost
	--certainly a bad plan.
	if Target.Is_Enemy(Player) then
		Goal.Suppress_Goal()
		return 0.0
	end

	local collector_type = Get_Resource_Collector_Type()
	if not collector_type then
		return 0.0
	end
	
	--Anything neutral or friendly is fine though.  The important questions are whether the position
	--it defines has a useful quantity of resources nearby and whether we already have something collecting
	--in the area.
	
	local resource_collection_center = Target
	if build_position then
		resource_collection_center = build_position
	end	
	
	local resource_collection_radius = collector_type.Get_Type_Value("Resource_Depot_Collection_Radius")
	local existing_collectors = Find_All_Objects_Of_Type(collector_type, Player, resource_collection_center, 1.1 * resource_collection_radius)
	if existing_collectors and #existing_collectors > 0 then
		return 0.0
	end	
	
	if not Goal.Is_Active() then
		existing_collectors = Find_All_Objects_Of_Type(collector_type.Get_Type_Value("Tactical_Under_Construction_Object_Type"), Player, resource_collection_center, 1.1 * resource_collection_radius)
		if existing_collectors and #existing_collectors > 0 then
			return 0.0
		end	
		
		existing_collectors = Find_All_Objects_Of_Type(collector_type.Get_Type_Value("Tactical_Buildable_Beacon_Type"), Player, resource_collection_center, 1.1 * resource_collection_radius)
		if existing_collectors and #existing_collectors > 0 then
			return 0.0
		end
	end
	
	local resource_list = Find_Resource_Objects(resource_collection_center, resource_collection_radius)
	if Calculate_Total_Resource_Value(resource_list) < 500 then
		return 0.0
	end
	
	return 1.0
end

function Score_Unit(unit)
	
	return 0.0
	
end

function On_Activate()
	if not Get_Resource_Collector_Type() then
		return
	end
	
	build_position = Goal.Create_Custom_Target(Target)
	Create_Thread("Build_Thread")
	local collector_type = Get_Resource_Collector_Type()
	Suppress_Nearby_Goals(build_position, collector_type.Get_Type_Value("Resource_Depot_Collection_Radius"), "Generic_Build_Resource_Collector", 5)
end

function Service()
	local collector_type = Get_Resource_Collector_Type()
	Suppress_Nearby_Goals(build_position, collector_type.Get_Type_Value("Resource_Depot_Collection_Radius"), "Generic_Build_Resource_Collector", 5)
end

function Build_Thread()
	log("Generic_Build_Resource_Collector: Activating Generic_Sub_Goal_Build_Structure at location %s", Describe_Target(build_position))
	BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Structure", build_position, Get_Resource_Collector_Type()))
	ScriptExit()

end

function Get_Resource_Collector_Type()

	if Is_Player_Of_Faction(Player, "NOVUS") then
		return Find_Object_Type("Novus_Input_Station")
	elseif Is_Player_Of_Faction(Player, "ALIEN") or Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		-- Maria 1.11.07 - Commenting this out given that we are cutting the 
		-- Material Conduit, Material Relay and Gatherer from the game at this point.
		--return Find_Object_Type("Alien_Material_Conduit")
		  return nil
	elseif Is_Player_Of_Faction(Player, "MILITARY") then
		return Find_Object_Type("Military_Supply_Depot")
	elseif Is_Player_Of_Faction(Player, "MASARI") then
		--???
		return nil
	end
	
	--Oh dear.  We shouldn't be here...

end

function Calculate_Total_Resource_Value(resource_objects)

	if not resource_objects then
		return 0.0
	end
	
	local total_value = 0.0
	for _, resource in pairs(resource_objects) do
		total_value = total_value + resource.Get_Type().Get_Type_Value("Resource_Units")
	end
	
	return total_value

end
