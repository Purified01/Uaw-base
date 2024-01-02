-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/GlobalRepairBehavior.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/GlobalRepairBehavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Mike_Lytle $
--
--            $Change: 80582 $
--
--          $DateTime: 2007/08/10 14:23:47 $
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

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Get_Megaweapon_Cooldown
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Get_Megaweapon_Cooldown()
	local ret = {}
	ret.EndTime = RepairEndCooldown
	ret.StartTime = RepairStartCooldown
	return ret
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Legal_Megaweapon_Target
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Legal_Megaweapon_Target(region)
	return Object.Get_Owner().Is_Ally(region.Get_Owner())
end

function Get_Weapon_Type()
	return "Repair"
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
