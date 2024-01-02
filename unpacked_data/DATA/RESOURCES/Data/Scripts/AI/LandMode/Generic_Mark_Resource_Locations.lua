-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Generic_Mark_Resource_Locations.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Generic_Mark_Resource_Locations.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Keith_Brors $
--
--            $Change: 76451 $
--
--          $DateTime: 2007/07/12 14:55:55 $
--
--          $Revision: #10 $
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

	-- This script is redundant for the alien faction because it has its own
	-- resource gathering scripts.
	if Is_Player_Of_Faction(Player, "ALIEN") or Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		Goal.Suppress_Goal()
		return 0.0
	end

	if Target then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	return 1.0

end

function Score_Unit(unit)
	return 0.0
end

function On_Activate()
	Create_Thread("Mark_Resources")
end

function Mark_Resources()

	base_structures = Find_Objects_With_Behavior(BEHAVIOR_GROUND_STRUCTURE, Player)
	if not base_structures then
		ScriptExit()
		return
	end
	
	Sleep(1)
	base_clusters = Find_Clusters(base_structures)
	if not base_clusters then
		ScriptExit()
		return
	end
	
	Sleep(1)
	for _, base in pairs(base_clusters) do
		-- KDB large radius not really needed as novus will build towers towards resources and the others dn't care
		resource_objects = Find_Resource_Objects(base, 200.0)
		if resource_objects then
			Sleep(1)
			resource_clusters = Find_Clusters(resource_objects)
			Sleep(1)
			if resource_clusters then
				for _, resource_pile in pairs(resource_clusters) do
					custom_target = Goal.Create_Custom_Target(resource_pile)
					Sleep(1)
					log("Generic_Mark_Resource_Locations activating subgoal on target %s", Describe_Target(custom_target))
					Goal.Activate_Sub_Goal("Generic_Build_Resource_Collector", custom_target, nil)
				end
			end
		end
	end
		
	BlockOnCommand(Goal.Wait_For_All_Sub_Goals())
	ScriptExit()
end