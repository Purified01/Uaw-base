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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/TacticalRetreat.lua 
--
--    Original Author: Maria Teruel
--
--          DateTime: 2006/09/08 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")
require("PGBase")

local my_behavior = {
	Name = _REQUIREDNAME
}


-- ------------------------------------------------------------------------------------------------------------------
-- Behavior_Init()
-- ------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	TakeOffDestination = nil
	TacticalRetreatRange = 0.0
	Owner = nil -- hero that owns this transport!
	MaximumPopCapAllowed = 0
	CurrentPopCap = 0
	Retreating = false -- this is only set to true when the transport has taken off and is heading to the take off destination
	FailedToGarrison = {}
end



-- ------------------------------------------------------------------------------------------------------------------
-- Behavior_First_Service()
-- ------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	if Object then
		Object.Register_Signal_Handler(On_Transport_Death, "OBJECT_HEALTH_AT_ZERO")
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Behavior_Service()
-- ------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	if not TestValid(Owner) then
		return
	end

	if not Retreating then
		if not RetreatingObjects and Object.Is_Landed() then
			Start_Scanning_For_Forces()
		elseif RetreatingObjects then
			Stop_Scanning_For_Forces()
			
			local any_ungarrisoned = false
			for _, object in pairs(RetreatingObjects) do
				if TestValid(object) then
					if object.Get_Garrison() ~= Object then 
					
						any_ungarrisoned = true
						
						if FailedToGarrison[object]==nil then
							FailedToGarrison[object] = GetCurrentTime() + 5.0
						end
						
						if not object.Is_Moving() then
							object.Clear_Attack_Target()
							object.Enter_Garrison(Object)
						end
					else
						FailedToGarrison[object] = nil
					end
				end
			end	

			local leave_now = true
			-- after a few seconds  take off anyway			
			for _, unit in pairs (RetreatingObjects) do
				if TestValid(unit) and FailedToGarrison[unit] and ( Owner == unit or FailedToGarrison[unit] < GetCurrentTime() ) then
					leave_now = false
				end
			end
			
			if not any_ungarrisoned or leave_now then
				Retreat_Initiated()
			end
		end
	elseif not Object.Has_Active_Orders() then
		Finalize_Retreat()
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Retreat_Initiated()
-- ------------------------------------------------------------------------------------------------------------------
function Retreat_Initiated()
	Object.Unlock_Current_Orders()
	Object.Move_To(Find_Nearest_Map_Edge(Object))
	Object.Lock_Current_Orders()
	Retreating = true
end



-- ------------------------------------------------------------------------------------------------------------------
-- Retrieve_Retreat_Data()
-- ------------------------------------------------------------------------------------------------------------------
function Retrieve_Retreat_Data()
	local ans = {}
	table.insert(ans, Owner)
	table.insert(ans, TacticalRetreatRange)
	table.insert(ans, TakeOffDestination)
	
	return ans
end

-- ------------------------------------------------------------------------------------------------------------------
-- Set_Retreat_Data( ... )
-- ------------------------------------------------------------------------------------------------------------------
function Set_Retreat_Data(retreat_zone_radius, transport_owner, max_popcap_val)
	
	TacticalRetreatRange = retreat_zone_radius
	Owner = transport_owner -- hero that owns this transport!
	MaximumPopCapAllowed = max_popcap_val
	
	Object.Lock_Current_Orders()
	Object.Set_Selectable(false)

	if TestValid(Owner) then
		Owner.Stop()
		Owner.Set_Selectable(false)
		Owner.Register_Signal_Handler(On_Transport_Owner_Death, "OBJECT_HEALTH_AT_ZERO")
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Start_Scanning_For_Forces()
-- ------------------------------------------------------------------------------------------------------------------
function Start_Scanning_For_Forces()
	-- to make sure we always have the hero on board, add it to the list right away (this also helps keep the pop cap valid!)
	RetreatingObjects = {}
	RetreatingObjects[Owner] = Owner
	Owner.Clear_Attack_Target()
	Owner.Enter_Garrison(Object)
	Object.Event_Object_In_Range(Behavior_Object_In_Range, TacticalRetreatRange) 
	
	--Don't modify pop cap here - heroes don't take up pop cap in global games.
end

function Stop_Scanning_For_Forces()
	Object.Cancel_Event_Object_In_Range(Behavior_Object_In_Range)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Behavior_Object_In_Range()
-- ------------------------------------------------------------------------------------------------------------------
function Behavior_Object_In_Range(prox_object, object)

	-- only objects with locomotor behavior can get added!.
	if not Valid_Object(object) then
		return
	end
	
	if object == Owner then 
		return
	end
		
	-- Update the pop cap count!.
	if object.Get_Type().Object_Is_Hero() == true then
		return
	end
	
	if object.Has_Behavior(BEHAVIOR_HARD_POINT) then
		local parent_object = object.Get_Highest_Level_Hard_Point_Parent()
		
		if TestValid(parent_object) then 
			if Valid_Object(parent_object) then
				object = parent_object
			else
				-- this object is not valid!
				return
			end
		end
	end
	
	if not RetreatingObjects[object] then
		RetreatingObjects[object] = object
		CurrentPopCap = CurrentPopCap + object.Get_Type().Get_Unit_Pop_Cap()
		object.Register_Signal_Handler(On_Transport_Member_Death, "OBJECT_HEALTH_AT_ZERO")
		object.Stop()
		object.Set_Selectable(false)
		object.Clear_Attack_Target()
		object.Enter_Garrison(Object)
	end
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Valid_Object()
-- ------------------------------------------------------------------------------------------------------------------
function Valid_Object(object)

	if not TestValid(object) then 
		return false
	end
	
	if object.Get_Owner() ~= Object.Get_Owner() then 
		return false
	end
	
	if not object.Get_Type().Get_Base_Type().Get_Type_Value("Is_Strategic_Buildable_Type") then
		return false
	end
	
	if object.Has_Behavior(BEHAVIOR_GROUND_STRUCTURE) then
		return false
	end
	
	-- do we have enough pop cap!?
	local predicted_pop_cap = CurrentPopCap + object.Get_Type().Get_Unit_Pop_Cap()
	if predicted_pop_cap > MaximumPopCapAllowed then 
		return false
	end
	
	return true
end



-- ------------------------------------------------------------------------------------------------------------------
-- Finalize_Retreat()
-- ------------------------------------------------------------------------------------------------------------------
function Finalize_Retreat()
	if Retreating == false then
		return
	end
	
	-- Execute the retreat commnad which deals with transitioning to Strategic Mode.
	if Retreat_From_Tactical(RetreatingObjects) then
		if TestValid(Object) then 
			Object.Despawn()
		end
	else
		--The retreat failed.  Destroy the transport with damage so that we kill its contents
		Object.Take_Damage(BIG_FLOAT, "Damage_Default")
	end		
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Transport_Owner_Death()
-- ------------------------------------------------------------------------------------------------------------------
function On_Transport_Owner_Death()
	
	-- destroy the transport!
	if TestValid(Object) then 
		Object.Take_Damage(BIG_FLOAT, "Damage_Default")
	end
end


function On_Transport_Member_Death(unit)
	CurrentPopCap = CurrentPopCap - unit.Get_Type().Get_Unit_Pop_Cap()
	RetreatingObjects[unit] = nil
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Transport_Death()
-- ------------------------------------------------------------------------------------------------------------------
function On_Transport_Death()
	if not RetreatingObjects then
		return
	end

	for _, object in pairs(RetreatingObjects) do
		if TestValid(object) then
			if object.Get_Garrison() ~= Object then 
				object.Stop()
				object.Set_Selectable(true)
			end
		end
	end		
end




-- This line must be at the bottom of the file.
-- ------------------------------------------------------------------------------------------------------------------
my_behavior.First_Service = Behavior_First_Service
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
