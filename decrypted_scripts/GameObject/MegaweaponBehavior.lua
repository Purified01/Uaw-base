if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[1] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MegaweaponBehavior.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MegaweaponBehavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #14 $
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
	WeaponStartCooldown = GetCurrentTime()
	WeaponEndCooldown = WeaponStartCooldown + MEGAWEAPON_DATA.COOLDOWN_TIME
	Script.Set_Async_Data("WeaponType", "Offensive")
	Script.Set_Async_Data("MegaweaponTargetsEnemies", true)
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Offensive"} )
	
	--Start with cooldown active
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Offensive"})	
	
	Raise_Game_Event("Mega_Weapon_Built", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type() )
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	local time = GetCurrentTime()
	if WeaponEndCooldown > 0 and time >= WeaponEndCooldown then
		WeaponEndCooldown = 0
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Ready", nil, {Object, "Offensive"} )
		Raise_Game_Event("Mega_Weapon_Ready", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type() )
	end
	local cd_data = {}
	cd_data.EndTime = WeaponEndCooldown
	cd_data.StartTime = WeaponStartCooldown
	Script.Set_Async_Data("MegaweaponCooldown", cd_data)	
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Refresh_After_Mode_Switch
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Refresh_After_Mode_Switch()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Offensive"} )
	if WeaponEndCooldown > 0 then
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Offensive"})	
	end	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Fire_Megaweapon_At_Region
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Fire_Megaweapon_At_Region(region)
	local time = GetCurrentTime()
	if time >= WeaponEndCooldown then
		WeaponStartCooldown = time
		WeaponEndCooldown = WeaponStartCooldown + MEGAWEAPON_DATA.COOLDOWN_TIME
		
		Create_Thread("Megaweapon_Firing_Thread", region)
		
		Raise_Game_Event("Mega_Weapon_Launched", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type() )
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Offensive"})
	end
end

function Megaweapon_Firing_Thread(region)
	--Play the firing animation on the megaweapon icon
	local weapon_icon =	Object.Get_Global_Icon()
	local block = weapon_icon.Play_Animation("Anim_Attack", false)
	block.Register_Callback(Animation_Finished)
	BlockOnCommand(block)
	weapon_icon.Play_Animation("Anim_Idle", true)
	
	local is_countered = false
	local region_cc = region.Get_Command_Center()
	local upgrades = nil
	if TestValid(region_cc) then
		upgrades = region_cc.Get_Strategic_Structure_Socket_Upgrades()
	end
	
	if upgrades then
		for _, hard_point in pairs(upgrades) do
			if Is_Megaweapon_Counter(hard_point) then
				is_countered = true
			end
		end
	end
	
	if is_countered then
		Raise_Game_Event("Mega_Weapon_Countered", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
		
		--Play the appropriate counter effect on the target region.
		local counter_effect = region.Attach_Particle_Effect(MEGAWEAPON_DATA.COUNTERED_EFFECT, "earth_sign")
		if MEGAWEAPON_DATA.COUNTERED_EFFECT then
			block = counter_effect.Play_Animation(MEGAWEAPON_DATA.COUNTERED_ANIMATION, false)
			BlockOnCommand(block)
			block.Register_Callback(Animation_Finished)
			counter_effect.Despawn()
		end	
	else
		--Nuke the region! 
		local explosion = region.Attach_Particle_Effect(MEGAWEAPON_DATA.EXPLOSION_EFFECT, "earth_sign")
		if MEGAWEAPON_DATA.EXPLOSION_ANIMATION then
			block = explosion.Play_Animation(MEGAWEAPON_DATA.EXPLOSION_ANIMATION, false)
			BlockOnCommand(block)
			block.Register_Callback(Animation_Finished)
			explosion.Despawn()
		end
		
		--Only apply the logical effects after the visuals are complete, to do otherwise looks funny and,
		--worse, can end up destroying the effect by changing the ownership of the region.
		if upgrades then
			for _, hard_point in pairs(upgrades) do
				if TestValid(hard_point) then
					hard_point.Take_Damage(MEGAWEAPON_DATA.STRUCTURE_DAMAGE, MEGAWEAPON_DATA.DAMAGE_TYPE)
				end
			end
		end
	
		if TestValid(region_cc) then
			region_cc.Take_Damage(MEGAWEAPON_DATA.STRUCTURE_DAMAGE, MEGAWEAPON_DATA.DAMAGE_TYPE)
		end
	
		--Outright destroy any command center under construction
		if region.Is_Command_Center_Under_Construction() then
			region.Cancel_Command_Center_Construction()
		end	
	
		local fleet_count = region.Get_Number_Of_Fleets_Contained()
		for i = 1, fleet_count do
			local fleet = region.Get_Fleet_At(i - 1)
			if TestValid(fleet) then
				local fleet_member_count = fleet.Get_Contained_Object_Count()
				for j = 1, fleet_member_count do
					local fleet_member = fleet.Get_Fleet_Unit_At_Index(j)
					fleet_member.Take_Damage(MEGAWEAPON_DATA.UNIT_DAMAGE, MEGAWEAPON_DATA.DAMAGE_TYPE)
				end
			end
		end
		
		--Also apply splotchy damage to the region damage persistence map.
		region.Apply_Noisy_Environmental_Persistence_Damage(MEGAWEAPON_DATA.TERRAIN_DAMAGE)
		
	end
end

function Animation_Finished()
	--Make sure we get an update ASAP
	LastService = nil
end

function Debug_Force_Complete()
	WeaponEndCooldown = 0
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Ready", nil, {Object, "Offensive"} )
	Raise_Game_Event("Mega_Weapon_Ready", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type() )
end

local function Behavior_Post_Load_Game()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Offensive"} )
	if WeaponEndCooldown > 0 then
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Offensive"})	
	end	
end

function Is_Megaweapon_Counter(object)
	if not MegaweaponDefenseTypeTable then
		MegaweaponDefenseTypeTable = {}
		MegaweaponDefenseTypeTable[Find_Object_Type("Alien_Abduction_Core_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Alien_Foundation_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Alien_Theory_Core_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Masari_Atlatea_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Masari_Element_Magnet_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Masari_Will_Processor_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Novus_Material_Center_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Novus_Megacorp_Center_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Novus_R_and_D_Center_Megaweapon_Countermeasure_Upgrade")] = true
	end
		
	return MegaweaponDefenseTypeTable[object.Get_Type()]	
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
my_behavior.Refresh_After_Mode_Switch = Behavior_Refresh_After_Mode_Switch
my_behavior.Post_Load_Game = Behavior_Post_Load_Game
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
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
