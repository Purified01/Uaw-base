LUA_PREP = true

--/////////////////////////////////////////////////////////////////////////////////////////////////

-- MODDED_WARFARE - Dragoon Behavior Script.
-- This script is designed to force the AI to activate the "deploy" abilty when an enemy unit is within range.
-- 
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("Anti_Crush_Unit_Behavior")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	--OurType = Object.Get_Type()
	--
	--if not TestValid(OurType) then
	--	ScriptExit()	
	--end
	--
	--CrushDefense = OurType.Get_Type_Value("Crush_Defense")
	--if CrushDefense == nil then
	--	CrushDefense = 999.0	-- bad value
	--end

end

local function Behavior_Service()
	
	player = Object.Get_Owner()
	
	local obj_list = Find_All_Objects_Of_Type( Object, 450.0, "CanAttack + ~Resource + ~Resource_INST + ~Flying | Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST" )
	for _,unit in pairs(obj_list) do	
		if TestValid(unit) then
			local enemy_type = unit.Get_Type()
			if TestValid(enemy_type) then
				local xextent = enemy_type.Get_Hard_Coord_Radius()
				if Object.Get_Distance(unit) <= 400.0 + xextent and player.Is_Enemy(unit.Get_Owner()) and not unit.Is_Category("Resource_INST | Resource | Flying") and not unit.Is_Phased() and not unit.Is_Death_Clone() then
					Object.Activate_Ability("Dragoon_Deploy",true,unit)
					--DebugMessage("Unit: " .. tostring(unit))
					break
				end
			end
		end
	end
	
	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not ScanMTRVThreadID then
			ScanMTRVThreadID = Create_Thread("Scan_Drone_Thread")
		end
	elseif DefensiveThreadID then
		Create_Thread.Kill(ScanMTRVThreadID)
		ScanMTRVThreadID = nil
	end
end

--Thread this so that the slow service rate doesn't interfere with other LUA behaviors
function Scan_Drone_Thread()

	while true do

		if not AntiCrushUnitBehaviorActionTaken and not AIDefensiveIsRetreating then
			Check_For_Scan()
		end

		Sleep(4.0 + GameRandom.Get_Float(0.0,1.0))
		
	end

end

function Check_For_Scan()
	
	local player = Object.Get_Owner()
	if not TestValid(player) then
		return false
	end
	
	if not Object.Is_Ability_Ready(ScanDroneBehavior.AbilityName) then
		return
	end

	local can_clean_mind_control = false
	
	local best_target = nil
	local best_value = 0.0
	
	local obj_list = Find_All_Objects_Of_Type( "CanAttack + ~Resource + ~Resource_INST | Stationary + ~Bridge + ~Resource + ~Resource_INST + ~Insignificant | Hardpoint" )
	
	if obj_list then
		for _, unit in pairs (obj_list) do
			if TestValid(unit) then
				if player.Is_Enemy(unit.Get_Owner()) then
					if not unit.Is_Death_Clone() then
						if ( unit.Is_Cloaked() and (unit.Is_Category("Stationary") or GameRandom(1,100) < 5) ) or ( unit.Is_Fogged(player,true) and unit.Is_Category("Stationary") )then
							local value = GameRandom(1,10)
							if value > best_value then
								best_value = value
								best_target = unit		
							end
						elseif can_clean_mind_control and unit.Get_Attribute_Integer_Value("Object_Original_Owner_ID") == player.Get_ID() then
							local value = GameRandom(1,25)
							if value > best_value then
								best_value = value
								best_target = unit		
							end
						end
					end
				else
					local unit_type = unit.Get_Type()
					if TestValid(unit_type) and not unit.Is_Death_Clone() and unit.Get_Attribute_Value("Virus_Level") > 0.0 then
						local value = GameRandom(1,20)
						if value > best_value then
							best_value = value
							best_target = unit
						end
					end
				end
			end
		end
	end
	
	
	if TestValid(best_target) and best_value >= 4 then
		Object.Stop()
		Object.Activate_Ability(MTRVScanBehavior.AbilityName,true,best_target)
	end
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Check_To_Crush = nil
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
