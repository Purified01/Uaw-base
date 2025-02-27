if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Novus_Robotic_Infantry.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Novus_Robotic_Infantry.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Anti_Crush_Unit_Behavior")

ScriptShouldCRC = true

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	--Disable autofire of this ability since it self-destructs the infantry team
	Object.Set_Single_Ability_Autofire("Robotic_Infantry_Swarm", false)
	
	OurType = Object.Get_Type()
	
	if not TestValid(OurType) then
		ScriptExit()	
	end

	CrushDefense = OurType.Get_Type_Value("Crush_Defense")
	if CrushDefense == nil then
		CrushDefense = 999.0	-- bad value
	end

	ServiceRate = 1.05

end

local function Behavior_Service()

	--Re-enable autofire for AI once health gets low.
	if Object.Get_Owner().Is_AI_Player() then
		if Object.Get_Health() <= 0.5 then
			
			if Object.Is_AI_Recruitable() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() then
				Object.Set_Single_Ability_Autofire("Robotic_Infantry_Swarm", true)
				if Kamikaze() then
					return
				end
			end
		end
		
		if Check_For_Crushers(Object,140.0,100.0,CrushDefense) then
			ServiceRate = 0.37
		else
			ServiceRate = 1.05
		end
		
	end
	
end

function Kamikaze()

	player = Object.Get_Owner()
	if not TestValid(owner) then
		return false
	end

	local obj_list = Find_All_Objects_Of_Type( Object, 250.0, "Piloted | HardPoint | Stationary" )
	if obj_list then
		for _,unit in pairs(obj_list) do
			if TestValid(unit) then
				local enemy_type = unit.Get_Type()
				if TestValid(enemy_type) then
					local xextent = enemy_type.Get_Hard_Coord_Radius()
					if Object.Get_Distance(unit) <= 180.0 + xextent and player.Is_Enemy(unit.Get_Owner()) and not unit.Is_Category("Resource_INST | Resource | Hero | Huge | Flying") and not unit.Is_Phased() then
						Object.Activate_Ability("Robotic_Infantry_Swarm",true,unit)
						return true
					end
				end
			end
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
