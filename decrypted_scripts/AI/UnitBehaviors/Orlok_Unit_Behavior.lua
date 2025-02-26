if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[163] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Orlok_Unit_Behavior.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Orlok_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	OrlokThreadID = nil
	LastObjList = {}
	OrlokAmmoDump = nil
	LastSiegeTarget = nil
	
	-- Make sure the gamelogic lock for his seige mode or endure mode are set to zero
	-- As these are locked when mode switching it can cause a problem in campaigns when going to the next scenario
	
	local player = Object.Get_Owner()
	if TestValid(player) then
		if player.Is_Unit_Ability_Locked("Alien_Orlok_Switch_To_Endure_Mode") and not player.Is_Unit_Ability_Locked("Alien_Orlok_Switch_To_Endure_Mode",STORY) then
			player.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Switch_To_Endure_Mode", false)	
		end
		if player.Is_Unit_Ability_Locked("Alien_Orlok_Switch_To_Siege_Mode") and not player.Is_Unit_Ability_Locked("Alien_Orlok_Switch_To_Siege_Mode",STORY) then
			player.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Switch_To_Siege_Mode", false)	
		end
	end
	

end

local function Behavior_Service()
	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not OrlokThreadID then
			OrlokThreadID = Create_Thread("Orlok_Thread")
		end
	elseif OrlokThreadID then
		Create_Thread.Kill(OrlokThreadID)
		OrlokThreadID = nil
	end
end

--Thread this so that the slow service rate doesn't interfere with other LUA behaviors
function Orlok_Thread()

	while true do

		LastObjList = {}
		
		if not AIDefensiveIsRetreating and not AntiCrushUnitBehaviorActionTaken then
			if not Look_For_And_Kill_Target() then
				Look_For_Ammo()
			end
		end
		
		Sleep(2.5)
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Valid_Resource
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Valid_Resource( test_resource, check_targeting, faction )
	
	-- Is a valid resource for my faction?
	if not test_resource.Get_Type().Resource_Is_Valid_For_Faction(faction) then
		return false
	end
	
	--Is this resource empty?
	local resource_units = test_resource.Resource_Get_Resource_Units()
	if resource_units == nil or resource_units <= 1.0 then
		return false
	end

	-- This object does not have means to attack the target (harvest it)
	-- ignore fog (2nd parameter)
	if check_targeting and not Object.Is_Suitable_Target(test_resource, true) then
		return false
	end
		
	return true
end

-------------------------------------------------------------
-- Look for some ammo to run the main gun
-------------------------------------------------------------
function Look_For_Ammo()

	local ammo = Object.Get_Ammo()

	if ammo < 5  and LastObjList then

		local best_resource = nil
		local resource_rg = 9999999.0

		local player = Object.Get_Owner()
		if not TestValid(player) then
			return true
		end
		
		local faction = player.Get_Faction_Name()
	
		if TestValid(OrlokAmmoDump) and Is_Valid_Resource(OrlokAmmoDump,true,faction) then
		
			local att_tgt = Object.Get_Current_Attack_Object()
			if att_tgt == OrlokAmmoDump then
				return
			end
			
			best_resource = OrlokAmmoDump
			resource_rg = Object.Get_Distance(OrlokAmmoDump)
		end
	
		for _, unit in pairs (LastObjList) do
			if TestValid(unit) then
				if unit.Is_Category("Resource | Resource_INST") and not unit.Is_Phased() and Is_Valid_Resource(unit,true,faction) then
					local rg = Object.Get_Distance(unit)
					if rg < resource_rg then
						resource_rg = rg
						best_resource = unit
					end
				end
			end
		end
		
		
		if TestValid(best_resource) then
			if best_resource.Is_Fogged(player,true) then
			
				if OrlokAmmoDump ~= best_resource then
					Object.Stop()
				end
				
				Object.Move_To(best_resource)
			else
				Object.Code_Compliant_Attack_Target(best_resource)
			end
			OrlokAmmoDump = best_resource
		end
		
	end
	
end

-------------------------------------------------------------
-- Look for a target and fire on it if we a) have ammo, b) aren't already firing or c) running or crushing
-------------------------------------------------------------
function Look_For_And_Kill_Target()
	
	if Object.Is_Ability_Active("Alien_Orlok_Switch_To_Siege_Mode") then
		-- acted upon don't look for ammo
		return true
	end
	
	local player = Object.Get_Owner()
	if not TestValid(player) then
		return true
	end
	
	local ammo = Object.Get_Ammo()
	
	if ammo > 0 or not TestValid(OrlokAmmoDump) then
	
		LastObjList = Find_All_Objects_Of_Type( "CanAttack + ~Flying | Stationary + ~Bridge + ~Insignificant | Resource | Resource_INST" )
		
	end
	
	if ammo > 4 and LastObjList then
		-- search for a target to fire upon
		
		if player.Get_Difficulty() == "Difficulty_Easy" and GameRandom(0,100) < 90 then
			-- 10% fire rate
			return true
		end

		if player.Get_Difficulty() ~= "Difficulty_Hard" and GameRandom(0,100) < 50 then
			-- 50% fire rate
			return true
		end

		local best_target = nil
		local target_rating = 0.0
		
		if TestValid(LastSiegeTarget) and not LastSiegeTarget.Is_Cloaked() and not LastSiegeTarget.Is_Phased() and
		not LastSiegeTarget.Is_Death_Clone() and not LastSiegeTarget.Is_Fogged(player,true) and GameRandom(1,100) <= 95 then
			best_target = LastSiegeTarget
		else
	
			for _, unit in pairs (LastObjList) do
				if TestValid(unit) then
					if player.Is_Enemy(unit.Get_Owner()) then
						if not unit.Is_Cloaked() and not unit.Is_Phased() and not unit.Is_Death_Clone() and unit.Is_Category("CanAttack | Stationary + ~Insignificant + ~Resource + ~Resource_INST") and not unit.Is_Fogged(player,true) then
							local value = GameRandom(1,100)
							if value > target_rating then
								target_rating = value
								best_target = unit
							end
						end
					end
				end
			end
			
		end
		
		if TestValid(best_target) then
			Object.Activate_Ability("Alien_Orlok_Switch_To_Siege_Mode",true,best_target.Get_Position())
			LastSiegeTarget = best_target
			return true
		end
		
	end

	return false

end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
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
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
