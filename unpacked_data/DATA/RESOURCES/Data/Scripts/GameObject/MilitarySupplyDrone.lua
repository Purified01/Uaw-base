-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/MilitarySupplyDrone.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/MilitarySupplyDrone.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Mike_Lytle $
--
--            $Change: 61697 $
--
--          $DateTime: 2007/01/29 16:56:13 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
		
	-- These are set by the Supply Depot! -Eric_Y
	-- resource_drone_search_radius
	-- resource_drone_depot
	
	resource_drone_capacity = 35
	resource_drone_units = 0
	resource_drone_object = nil
	resource_drone_target = nil
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	
	--MessageBox("Military_Supply_Drone On-Line!");
	
	while(true) do
		my_behavior.Harvest_Resources()
		my_behavior.Hover_At_Base()
	end

end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Harvest Resources
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Harvest_Resources()

	while(true) do

		--DebugBreak()
		
		-- Find a valid resource object
		resource_drone_target = nil
		local resource_list = Find_Resource_Objects(resource_drone_depot,resource_drone_search_radius)
		local test_resource
		local test_resource_units
		local test_reserved
		if resource_list ~= nil then
			for _ , test_resource in pairs(resource_list) do
			
				-- check if this is a military harvestable resource
				if test_resource.Get_Script().Get_Variable("is_military_resource") then
				
					-- see if there are units left to harvest
					test_resource_units = test_resource.Get_Script().Get_Variable("resource_units")
					if test_resource_units > 0 then
						-- see if it has been reserved already
						test_reserved = test_resource.Get_Script().Get_Variable("reserved_for_harvesting")
						if test_reserved == nil or test_reserved == 0 then
							resource_drone_target = test_resource
							resource_drone_target.Get_Script().Set_Variable("reserved_for_harvesting",1)
							break
						end
						
					end
					
				end
			end
		end
		
		if resource_drone_target == nil then
			--MessageBox("Drone couldn't find resource to harvest")
			return
		end
		
		-- Fly to resource --
		BlockOnCommand(Object.Move_And_Land(resource_drone_target))
		
		-- Pick up resources --
		Sleep(5)
		if not TestValid(resource_drone_target) then
			return
		end
		
		-- Unreserve this resource
		resource_drone_target.Get_Script().Set_Variable("reserved_for_harvesting",0) 
		
		-- Remove the resource units
		test_resource_units = resource_drone_target.Get_Script().Get_Variable("resource_units") 
		if test_resource_units < resource_drone_capacity then
			resource_drone_units = test_resource_units
			resource_drone_target.Get_Script().Call_Function("Harvested", Object)
		else
			resource_drone_units = resource_drone_capacity
			resource_drone_target.Get_Script().Set_Variable("resource_units",test_resource_units - resource_drone_units)
		end
		resource_drone_target = nil
		
		-- Return to base --
		BlockOnCommand(Object.Move_And_Land(resource_drone_depot))
		
		-- Drop off resources --
		Sleep(5)
		resource_drone_depot.Get_Owner().Add_Resource_Units(resource_drone_units)
		resource_drone_units = 0
		
	end
		
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Hover_At_Base()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Hover_At_Base()
	BlockOnCommand(Object.Move_To(resource_drone_depot))
	Sleep(3)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Zero Health handler
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Health_At_Zero()

	--DebugBreak()

	if resource_drone_target ~= nil then
		resource_drone_target.Get_Script().Set_Variable("reserved_for_harvesting",0) 
		resource_drone_target = nil
	end

	if TestValid(resource_drone_depot) then
		resource_drone_depot.Get_Script().Call_Function("Military_Supply_Depot_Drone_Destroyed",Object)
	end
		
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Harvest_Resources = Harvest_Resources
my_behavior.Hover_At_Base = Hover_At_Base
my_behavior.First_Service = Behavior_First_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero

Register_Behavior(my_behavior)
