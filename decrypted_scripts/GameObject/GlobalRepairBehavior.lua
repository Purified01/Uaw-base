if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[1] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[117] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/GlobalRepairBehavior.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/GlobalRepairBehavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- The following need to be set in XML

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	RepairStartCooldown = 0
	RepairEndCooldown = 0
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Repair"} )
	Raise_Game_Event("Global_Repair_Ready", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
	Script.Set_Async_Data("WeaponType", "Repair")
	Script.Set_Async_Data("MegaweaponTargetsEnemies", false)	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Behavior_Service
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	local time = GetCurrentTime()
	if RepairEndCooldown > 0 and time >= RepairEndCooldown then
		RepairEndCooldown = 0
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Ready", nil, {Object, "Repair"} )
		Raise_Game_Event("Global_Repair_Ready", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
	end
	local cd_data = {}
	cd_data.EndTime = RepairEndCooldown
	cd_data.StartTime = RepairStartCooldown
	Script.Set_Async_Data("MegaweaponCooldown", cd_data)
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Refresh_After_Mode_Switch
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Refresh_After_Mode_Switch()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Repair"} )
	if RepairEndCooldown > 0 then
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Repair"})	
	end	
end

local function Behavior_Post_Load_Game()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Repair"} )
	if RepairEndCooldown > 0 then
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Repair"})	
	end	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Fire_Megaweapon_At_Region
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Fire_Megaweapon_At_Region(region)
	local time = GetCurrentTime()
	if time >= RepairEndCooldown then
		region.Repair_All()
		RepairStartCooldown = time
		RepairEndCooldown = RepairStartCooldown + RepairCooldownTime
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Repair"})
		region.Attach_Particle_Effect(RepairEffectName, "earth_sign")
	end
end

function Debug_Force_Complete()
	RepairEndCooldown = 0
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Ready", nil, {Object, "Repair"} )
end

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
my_behavior.Post_Load_Game = Behavior_Post_Load_Game
my_behavior.Refresh_After_Mode_Switch = Behavior_Refresh_After_Mode_Switch
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
