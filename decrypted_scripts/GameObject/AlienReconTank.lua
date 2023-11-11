-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienReconTank.lua#10 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AlienReconTank.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Maria_Teruel $
--
--            $Change: 45048 $
--
--          $DateTime: 2006/05/25 10:34:13 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- States: [Ground], Air, MicroManage, Retreat, ArtilleryRush
local state = "Ground"

local function Behavior_Init()
	if Object then 
		Object.Event_Object_In_Range(my_behavior.Object_In_Range, DRAGONFLY_AIR_TRIGGER_RANGE, Object.Get_Owner().Get_Enemy()) 
		Object.Event_Object_In_Range(my_behavior.Artillery_In_Range, ARTILLERY_TRIGGER_RANGE, Object.Get_Owner().Get_Enemy()) 
	end
end

local function Behavior_Service()

	-- Ground is our initial state. 
	if state == "Ground" then
		nearest_infantry = Find_Nearest(Object, "MARINE")
		if (nearest_infantry and Object.Get_Distance(nearest_infantry) < 200) then 
			-- SQUASH! 
			Object.Micromanage_Retreat_From_Unit(nearest_infantry, -30)
		end
			
		
		if Object.Get_Health() < 0.5 then
			state = "MicroManage"
			
			-- Once our health drops below 50%, we're going to pull back for a few moments
			--  to get enemies targeting something else, then come back and resume fighting. 
		
			local my_position = Object.Get_Position()
			local nearest_enemy = Find_Nearest(Object, UEA_Player, true) 
		
			-- Retreat from the nearest enemy, just out of its firing range. 
			if (nearest_enemy) then
				Object.Micromanage_Retreat_From_Unit(nearest_enemy, 300)
			end
			
			Sleep(3)
			
			Object.Attack_Move(nearest_enemy)
		end
		
	-- When we're attacked by Dragonflies, we go into air mode 
	elseif state == "Air" then
		if Find_Nearest(Object, "Military_Dragonfly_UAV") == nil or Object.Get_Distance(Find_Nearest(Object, "Military_Dragonfly_UAV")) > (DRAGONFLY_AIR_TRIGGER_RANGE * 2) then
			state = "Ground"
			Object.Activate_Ability("SWITCH_TYPE", false)
		end
		
	-- The following states are for rushing artillery. The alien tank will fly over any front line, land behind the artillery, and attack. 
	elseif state == "ArtilleryRush" then
		nearest_artillery = Find_Nearest(Object, "Military_Dragoon_MTRV")
		if nearest_artillery == nil or Object.Get_Distance(nearest_artillery) > (ARTILLERY_TRIGGER_RANGE * 2) then 
			state = "Ground"
			Object.Activate_Ability("SWITCH_TYPE", false)
		elseif Object.Get_Distance(nearest_artillery) <= (ARTILLERY_TRIGGER_RANGE / 2.5) then 
			state = "OverArtillery"
		elseif Object.Has_Active_Orders() == false then
			Object.Activate_Ability("SWITCH_TYPE", false)
			Object.Attack_Move(nearest_artillery)
		end 
	elseif state == "OverArtillery" then
		nearest_artillery = Find_Nearest(Object, "Military_Dragoon_MTRV")
		if nearest_artillery == nil or Object.Get_Distance(nearest_artillery) > (ARTILLERY_TRIGGER_RANGE * 2) then 
			state = "Ground"
			Object.Activate_Ability("SWITCH_TYPE", false)
		elseif Object.Get_Distance(nearest_artillery) > (ARTILLERY_TRIGGER_RANGE / 2.49) then 
			state = "BehindArtillery"
			Object.Activate_Ability("SWITCH_TYPE", false)
			Object.Attack_Move(nearest_artillery)
		elseif Object.Has_Active_Orders() == false then
			Object.Activate_Ability("SWITCH_TYPE", false)
			Object.Attack_Move(nearest_artillery)
		end 
	elseif state == "BehindArtillery" then 
		nearest_artillery = Find_Nearest(Object, "Military_Dragoon_MTRV")
		if nearest_artillery == nil or Object.Get_Distance(nearest_artillery) > (ARTILLERY_TRIGGER_RANGE * 2) then 
			state = "Ground"
			Object.Activate_Ability("SWITCH_TYPE", false)
		end 
	
	-- Injured states. When we're hurt, we pull back a bit (micromanagement). When we're almost dead, lift off and cheese it to the nearest walker. 
	elseif state == "MicroManage" then
		if Object.Get_Health() < 0.2 then
			-- Lift off and cheese it
			state = "Retreat"
			Object.Activate_Ability("SWITCH_TYPE", true)
			
			nearest_walker = Find_Nearest(Object, "Alien_Walker_Habitat")
			if (nearest_walker) then 
	 			Object.Move_To(nearest_walker)
			end
			
		end
	elseif state == "Retreat" then
		
	end

end

local function Behavior_Object_In_Range(prox_object, object)

	if state ~= "Air" then 
		if (object.Get_Type().Get_Name() == "Military_Dragonfly_UAV") then
			state = "Air"
			Object.Activate_Ability("SWITCH_TYPE", true)
		end
	end
end

local function Artillery_In_Range(prox_object, object)
	if state ~= "ArtilleryRush" and state ~= "OverArtillery" and state ~= "BehindArtillery" then 
		if (object.Get_Type().Get_Name() == "Military_Dragoon_MTRV") then
			state = "ArtilleryRush"
			Object.Activate_Ability("SWITCH_TYPE", true)
			nearest_artillery = Find_Nearest(Object, "Military_Dragoon_MTRV")
			Object.Micromanage_Retreat_From_Unit(nearest_artillery, -200)
			--Object.Move_To(nearest_artillery)
		end
	end
end

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Object_In_Range = Behavior_Object_In_Range
my_behavior.Artillery_In_Range = Artillery_In_Range
my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
