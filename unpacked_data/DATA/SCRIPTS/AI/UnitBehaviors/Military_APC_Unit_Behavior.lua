LUA_PREP = true

--/////////////////////////////////////////////////////////////////////////////////////////////////

-- MODDED_WARFARE - Defender APC AI Behavior Script.

-- This script forces the AI to use it's troop deploy ability when a valid enemy target is within range
-- For balancing it wont apply on Easy Difficulty
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Anti_Crush_Unit_Behavior")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	OurType = Object.Get_Type()
	
	if not TestValid(OurType) then
		ScriptExit()	
	end
	
	CrushDefense = OurType.Get_Type_Value("Crush_Defense")
	if CrushDefense == nil then
		CrushDefense = 999.0	-- bad value
	end

end

local function Behavior_Service()
	
	player = Object.Get_Owner()
	
	local obj_list = Find_All_Objects_Of_Type( Object, 200.0, "CanAttack + ~Resource + ~Resource_INST | Stationary + ~Insignificant + ~Bridge + ~Resource + ~Resource_INST" )
	if not player.Is_Unit_Ability_Locked("Military_APC_Marine_Ability") then
		if player.Get_Difficulty() ~= "Difficulty_Easy" then
			for _,unit in pairs(obj_list) do	
				if TestValid(unit) then
					local enemy_type = unit.Get_Type()
					if TestValid(enemy_type) then
						local xextent = enemy_type.Get_Hard_Coord_Radius()
						if Object.Get_Distance(unit) <= 200.0 + xextent and player.Is_Enemy(unit.Get_Owner()) and not unit.Is_Category("Resource_INST | Resource | Flying") and not unit.Is_Phased() then
							Object.Activate_Ability("Military_APC_Marine_Ability",true, unit)
						end
					end
				end
			end
		end
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
