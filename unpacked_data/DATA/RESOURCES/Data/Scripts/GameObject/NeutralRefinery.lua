-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/NeutralRefinery.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/NeutralRefinery.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 86524 $
--
--          $DateTime: 2007/10/24 11:53:36 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")
require("PGUICommands")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

-- ResourcesPerSecond : This is set by xml script

	if ResourcesPerSecond == nil then
		ResourcesPerSecond = 0.0
	end		
	
	LastCheckTime = GetCurrentTime()
	NextCheckTime = LastCheckTime + 1.0

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	
	local tm = GetCurrentTime()
	
	if tm >= NextCheckTime then
			
		if TestValid( Object ) then 
		
			local owner = Object.Get_Owner()
			if owner ~= nil then
				-- All factions now get income
				local time_passed = tm - LastCheckTime
				local resources = ResourcesPerSecond * time_passed
				
 				local faction = owner.Get_Faction_Name()
 				if faction == "MASARI" then
 					resources = resources / 10.0
 				end
				
				owner.Add_Raw_Materials( resources,  Object)
				
				-- round up for prints
				resources = resources + 0.5
				
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Resource_Harvested", nil, {Object, Object, resources})
			end
		end

		LastCheckTime = tm
		NextCheckTime = LastCheckTime + 1.0
	
	end
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service

Register_Behavior(my_behavior)
