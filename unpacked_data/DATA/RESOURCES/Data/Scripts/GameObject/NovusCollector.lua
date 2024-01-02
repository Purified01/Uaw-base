-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/NovusCollector.lua#32 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/NovusCollector.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Keith_Brors $
--
--            $Change: 85138 $
--
--          $DateTime: 2007/09/29 15:43:18 $
--
--          $Revision: #32 $
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
		
	-- These are set by the Supply Depot! -Eric_Y
	-- resource_drone_search_radius
	-- resource_drone_depot
	
	-- Set by object XML
	
	-- DroneCapacity
	-- ResourcesPerGrab
	-- ResourcesSecondsPerGrab
	-- ResourceLockLevel
	-- ResourceFaction
	
	-- optional xml
	
	-- ResourceDeliverySeconds
	-- ResourceDepotRequired
	-- resource_drone_search_radius
	-- ResourceGatherRange
	-- SingleResourceGrabSeconds
	-- SingleResourceCapacity
	-- ResourceHarvestAbility, this ability is activated on the harvester when the item is harvested fully
	
	resource_drone_units = 0
	resource_drone_object = nil
	resource_drone_target = nil
	
	OwningPlayer = Object.Get_Owner()
	
	if ResourceDeliverySeconds == nil then
		ResourceDeliverySeconds = 5.0
	end

	if ResourceDepotRequired == nil then
		ResourceDepotRequired = true
	end

	if resource_drone_search_radius == nil then
		resource_drone_search_radius = 250.0
	end
	
	if ResourceGatherRange == nil then
		ResourceGatherRange = 0.0
	end
	
	if SingleResourceCapacity == nil then
		SingleResourceCapacity = DroneCapacity
	end
	
	if SingleResourceGrabSeconds == nil then
		SingleResourceGrabSeconds = ResourcesSecondsPerGrab
	end
	
	CurrentResourceIsSingleResource = false

	Script.Set_Async_Data("ResourceFaction", ResourceFaction)
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	
	--MessageBox("Novus_Collector On-Line!");
	
	if OwningPlayer == nil or DroneCapacity == nil or ResourcesPerGrab == nil or ResourcesSecondsPerGrab == nil or DroneCapacity <= 0.0 or ResourcesPerGrab <= 0.0 or
		ResourcesSecondsPerGrab <= 0.0 or ResourceLockLevel == nil or ResourceFaction == nil then
			return	-- data not set
	end
	
	if Stop_Harvesting() then
		Sleep(1)
	else
		my_behavior.Harvest_Resources()
		my_behavior.Hover_At_Base()
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Stop_Moving
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Stop_Moving()
	if Stop_Harvesting() then
		return true
	end
	
	if TestValid(resource_drone_target) and ResourceGatherRange > 0.0 then
		if Object.Get_Distance( resource_drone_target.Get_Position() ) <= ResourceGatherRange then
			return true
		end
	end
	
	return false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Object_Has_Power
-- ------------------------------------------------------------------------------------------------------------------
function Collect_Object_Has_Power( object )
	if TestValid( object ) then
		if object.Has_Behavior( BEHAVIOR_POWERED ) then
			if object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
				return false
			end
		end
	end
	
	return true
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Stop_Harvesting
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Stop_Harvesting( keep_target )
	if Object.Get_Attribute_Value("No_Harvesting") ~= 0.0 then
		Set_Reserved( false )
		if not keep_target then
			resource_drone_target = nil
		end
		return true
	end

	if ResourceDepotRequired and resource_drone_depot ~= nil and not Collect_Object_Has_Power( resource_drone_depot ) then
		return true
	end
	
	return false
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Harvest Resources
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Harvest_Resources()

	while( not Stop_Harvesting() ) do
		if resource_drone_depot == nil and ResourceDepotRequired then
			--crashes when there is no resource depot
			return
		end

		--DebugBreak()
		
		-- AJA 03/19/2007 - Novus Research Item (Nanotech II): Collection Efficiency - All collectors travel faster, collect materials faster.
		-- Implementation: Collectors now have a new attribute: Resource_Seconds_Per_Grab_Multiplier. This multiplier is used to accelerate the
		-- speed at which the collectors drain resources from resource piles and single-target objects.
		local resource_seconds_per_grab_multiplier = Object.Get_Attribute_Value("Resource_Seconds_Per_Grab_Multiplier")
		--_CustomScriptMessage("ResourceTest.txt", string.format("Resource_Seconds_Per_Grab_Multiplier = %g", resource_seconds_per_grab_multiplier))

		-- Find a valid resource object
		resource_drone_target = nil
		local search_from
		if resource_drone_depot ~= nil then
			local rally_obj =  resource_drone_depot.Get_Rally_Point_Object() 
			if TestValid(rally_obj) then
				search_from = rally_obj
			else
				search_from = resource_drone_depot
			end
		else
			search_from = Object
		end
		local resource_list = Find_Resource_Objects(search_from,resource_drone_search_radius)
		local test_resource
		local test_resource_units
		local test_reserved
		if resource_list ~= nil then
			for _ , test_resource in pairs(resource_list) do
				
				-- check if this is a military harvestable resource
				if TestValid(test_resource) then
					if test_resource.Get_Type().Resource_Is_Valid_For_Faction(ResourceFaction) then
						local single_resource = test_resource.Get_Type().Get_Type_Value("Is_Single_Resource")
						test_resource_units = test_resource.Resource_Get_Resource_Units()
			       
						if test_resource_units >= 1.0 and ( not single_resource or SingleResourceCapacity >= test_resource_units ) then
						
							-- see if it has been reserved already
							test_reserved = Get_Reserved( test_resource )
							
							if test_reserved ~= nil and not test_reserved[OwningPlayer.Get_ID()].Used then
								if test_resource_units <= ResourceLockLevel or single_resource then
									test_reserved[OwningPlayer.Get_ID()].Used = true
									test_resource.Resource_Set_Reserved_For_Harvesting(test_reserved)
								end
								resource_drone_target = test_resource
								CurrentResourceIsSingleResource = single_resource
								break
							end
						end
					end
				end
			end
		end
		
		if resource_drone_target == nil then
			--MessageBox("Drone couldn't find resource to harvest")
			return
		end
	
		-- move to resource --
	--	local target_in_range = false
	--	if resource_drone_target ~= nil and ResourceGatherRange > 0.0 then
	--		if Object.Get_Distance( resource_drone_target.Get_Position() ) <= ResourceGatherRange then
	--			target_in_range = true
	--		end
	--	end

	--	if not target_in_range then
			-- Allow it to flow
			BlockOnCommand(Object.Move_To(resource_drone_target, true),-1) --,Stop_Moving)
			--if not Stop_Harvesting() then
			--	Object.Move_To(Object.Get_Position(), true)
			--end
		--end

		-- Oksana:
		-- Even if target in range, we may have a move order from collision system
		-- For example, the collector was just spawned from depot and needs to move out of it. 
		-- If we don't wait for move to complete, we may end up firing from inside the building 
		-- if the resource is close to it.
		--while Object.Is_Flying_To() == true do
		--	Sleep(1)
		--end
	
	
		if Stop_Harvesting() then
			return
		end
		
		if not TestValid(resource_drone_target) then
			return
		end
		
		-- if it has a turret point at it
		local pointed_at = Object.Point_Turret_At(resource_drone_target)
		while pointed_at ~= nil and pointed_at == false do
			Sleep(1)
			if not TestValid(resource_drone_target) then
				return
			end
			pointed_at = Object.Point_Turret_At(resource_drone_target)
		end 

		if Stop_Harvesting() then
			return
		end

		-- Show visual effects --
		local visual_effect_ability_name = "Gather_Resources_Visual_Ability"
		local object_has_visual_effect_ability = Object.Has_Ability(visual_effect_ability_name)
		if( object_has_visual_effect_ability) then
			Object.Activate_Ability(visual_effect_ability_name, true, resource_drone_target)
		end
			
		-- Pick up resources --
		if CurrentResourceIsSingleResource then
			Sleep(SingleResourceGrabSeconds * resource_seconds_per_grab_multiplier)
		else
			Sleep(ResourcesSecondsPerGrab * resource_seconds_per_grab_multiplier)
		end
		
		if not TestValid(resource_drone_target) then
			-- Hide visual effects --
			if( object_has_visual_effect_ability) then
				Object.Activate_Ability(visual_effect_ability_name, false, resource_drone_target)
			end
			return
		end
		
		while( resource_drone_target ~= nil and TestValid(resource_drone_target) and DroneCapacity > resource_drone_units ) do

			if Stop_Harvesting() then
				if( object_has_visual_effect_ability) then
					Object.Activate_Ability(visual_effect_ability_name, false)
				end
				resource_drone_units = 0
				resource_drone_target = nil
				return
			end
		
			local current_grab
			if CurrentResourceIsSingleResource then
				current_grab = resource_drone_target.Resource_Get_Resource_Units()
			else
				current_grab = DroneCapacity - resource_drone_units
				if current_grab > ResourcesPerGrab then
					current_grab = ResourcesPerGrab
				end
			end
			
			-- AJA 03/06/2007 - Novus Patch: Optimized Collection - Collecting units gain twice as much from the same amount of
			-- resource for the duration.
			-- Implementation: Each collector unit now has a "resource gain multiplier" attribute that we use to multiply each
			-- "grab" of the collected resource when "storing" it in the collector. The collector's resource limit is not affected.
			local resource_gain_multiplier = Object.Get_Attribute_Value("Collector_Resource_Gain_Multiplier")
			
			-- Remove the resource units
			test_resource_units = resource_drone_target.Resource_Get_Resource_Units()
			if test_resource_units <= current_grab then
				resource_drone_units = resource_drone_units + (test_resource_units * resource_gain_multiplier)
				--_CustomScriptMessage("ResourceTest.txt", string.format("Harvested %g = %g * %g resources", test_resource_units * resource_gain_multiplier, test_resource_units, resource_gain_multiplier))
				if ResourceHarvestAbility ~= nil then
					if( object_has_visual_effect_ability) then
						Object.Activate_Ability(visual_effect_ability_name, false)
					end
					Object.Activate_Ability(ResourceHarvestAbility, true)	
					Sleep(0.5)
				end
				if TestValid( resource_drone_target ) then
					local resource_type = resource_drone_target.Get_Type()
					if TestValid(resource_type) and not resource_type.Get_Type_Value("Is_Death_Final_ALT_State") then
						-- Just delete the object for now. Later we may have an animation for this purpose.
						-- we don't delete alt damage types
						resource_drone_target.Despawn()
					else
						resource_drone_target.Resource_Set_Resource_Units(0.0)
					end
				end
				resource_drone_target = nil
				if ResourceHarvestAbility ~= nil then
					Object.Activate_Ability(ResourceHarvestAbility, false)
				end
			else
				resource_drone_units = resource_drone_units + (current_grab * resource_gain_multiplier)
				--_CustomScriptMessage("ResourceTest.txt", string.format("Harvested %g = %g * %g resources", current_grab * resource_gain_multiplier, current_grab, resource_gain_multiplier))
				-- Maria 01.30.2007 - Using this function call,  instead of setting the variable right away, so that we can set the
				-- object's tooltip to dirty as well.
				resource_drone_target.Resource_Set_Resource_Units(test_resource_units - current_grab)
				Sleep(ResourcesSecondsPerGrab * resource_seconds_per_grab_multiplier)
			end

           			
		end	-- end while

		-- all finished
		
		-- Hide visual effects --
		if( object_has_visual_effect_ability) then
			Object.Activate_Ability(visual_effect_ability_name, false)
		end
		
		local collected_resource = resource_drone_target
		if resource_drone_target ~= nil then
			-- Unreserve this resource
			Set_Reserved( false )
			resource_drone_target = nil
		end

		if ResourceDepotRequired then
			-- Return to base --
			if not TestValid(resource_drone_depot) then
				return
			end
			BlockOnCommand(Object.Move_And_Land(resource_drone_depot, true),-1,Stop_Harvesting)
			
			--Oksana: block is released when move_to finished, but before it has landed - need to wait for it to land!
			while Object.Is_Flying_To() == true do
				Sleep(1)
			end
		end

		if Stop_Harvesting() then
			resource_drone_units = 0
			return
		end
        
  
		-- Drop off resources --
		Sleep( ResourceDeliverySeconds )
		OwningPlayer.Add_Raw_Materials(resource_drone_units, Object, collected_resource)

        -- Let the UI know we've harvested a resource...
    	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Resource_Harvested", nil, {Object, Object, resource_drone_units})


		resource_drone_units = 0
		
	end
		
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Get_Reserved()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Get_Reserved( my_resource )
	if my_resource ~= nil then
	
		local reserved
		local changed = false
		local pid = OwningPlayer.Get_ID()

		if not TestValid(my_resource) then
			return
		end
		
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
	if TestValid( resource_drone_target ) then
	
		local reserved
		
		reserved = Get_Reserved( resource_drone_target )
		
		if reserved ~= nil then

			reserved[OwningPlayer.Get_ID()].Used = on_off
			resource_drone_target.Resource_Set_Reserved_For_Harvesting(reserved)
			
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Hover_At_Base()
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Hover_At_Base()
	if ResourceDepotRequired then
		local rally_obj =  resource_drone_depot.Get_Rally_Point_Object() 
		local move_to_obj = resource_drone_depot
		if TestValid(rally_obj) then
				move_to_obj = rally_obj
		end
				
		BlockOnCommand(Object.Move_To(move_to_obj, true))
		Sleep(3)
	else
		Sleep(1)
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Our input station was destroyed, we have no purpose in life, commit suicide.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Novus_Input_Station_Destroyed(input_station)
	resource_drone_depot = nil
	Object.Take_Damage(1000000)
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Zero Health handler
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Health_At_Zero()

	--DebugBreak()

	if resource_drone_target ~= nil then
		Set_Reserved( false )
		resource_drone_target = nil
	end

	if ResourceDepotRequired and TestValid(resource_drone_depot) then
		resource_drone_depot.Get_Script().Call_Function("Novus_Collector_Destroyed",Object)
	end
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Harvest_Resources = Harvest_Resources
my_behavior.Hover_At_Base = Hover_At_Base
my_behavior.Service = Behavior_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero

Register_Behavior(my_behavior)
