LUA_PREP = true

--/////////////////////////////////////////////////////////////////////////////////////////////////

-- MODDED_WARFARE - Hero Tank Repair Behavior Script.
-- This script will cause Woolard to use his repair ability when his health drops below %20
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
	
	if Object.Get_Owner().Is_AI_Player() then
		if Object.Get_Health() <= 0.2 and Object.Is_Ability_Ready("Woolard_Auto_Repair") then
			Object.Activate_Ability("Woolard_Auto_Repair",true)
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
