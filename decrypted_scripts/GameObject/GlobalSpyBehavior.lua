if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[1] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/GlobalSpyBehavior.lua#15 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/GlobalSpyBehavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- The following need to be set in XML
-- GlobalSpyTimeToNextLevel	... amount of time needed to raise a level
-- GlobalMaxSpyLevel				... max spy level amount (through raises)
-- GlobalStartSpyLevel			... starting spy level
-- GlobalSpyCoolDown				... cool down time before ability can be used again
-- GlobalSpyTime					... amount of time the ability (spying) will remain active

SpyCoolDown = 0.0
SpyRaiseLeveTime = 0.0
SpyDoneTime = 0.0
SpyRegion = nil
SpyLevel = 0
SpyLevelMinimum = 0
SpyStartCoolTime = 0

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

	SpyCoolDown = 0.0
	SpyRaiseLeveTime = 0.0
	SpyDoneTime = 0.0
	SpyRegion = nil
	SpyLevel = 0
	SpyLevelMinimum = 0
	SpyStartCoolTime = 0
	Script.Set_Async_Data("WeaponType", "Spy")
	Script.Set_Async_Data("MegaweaponTargetsEnemies", true)
	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()

	-- tell Register_Patch_Builder that we have spy capability
	
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Spy"} )
	Raise_Game_Event("Global_Spy_Ready", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()

	if SpyCoolDown > 0.0 or SpyRaiseLeveTime > 0.0 or SpyDoneTime > 0.0 then
	
		local tm = GetCurrentTime()
		
		if SpyCoolDown > 0.0 and tm >= SpyCoolDown then
			SpyCoolDown	= 0.0
			-- The spy system is ready again
			Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Ready", nil, {Object, "Spy"} )
			Raise_Game_Event("Global_Spy_Ready", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
		end
		
		if SpyRaiseLeveTime > 0.0 and tm >= SpyRaiseLeveTime then
			local spy_level = SpyLevel + 1
			Set_Spy_Level( SpyRegion, spy_level )
			if SpyLevel < GlobalMaxSpyLevel then
				SpyRaiseLeveTime = tm + GlobalSpyTimeToNextLevel
			else
				SpyRaiseLeveTime = 0.0
			end
		end
		
		if SpyDoneTime > 0.0 and tm >= SpyDoneTime then
			Set_Spy_Level( nil, 0 )	-- cancel spying
		end
	end
	
	local cd_data = {}
	cd_data.EndTime = SpyCoolDown
	cd_data.StartTime = SpyStartCoolTime
	Script.Set_Async_Data("MegaweaponCooldown", cd_data)	
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Refresh_After_Mode_Switch
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Refresh_After_Mode_Switch()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Spy"} )
	if SpyCoolDown > 0 then
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Spy"})	
	end		
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Fire_Megaweapon_At_Region
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Fire_Megaweapon_At_Region( region )

	local tm = GetCurrentTime()

	local is_countered = false
	local region_cc = region.Get_Command_Center()
	local upgrades = {}
	if TestValid(region_cc) then
		upgrades = region_cc.Get_Strategic_Structure_Socket_Upgrades()
	end
	
	for _, hard_point in pairs(upgrades) do
		if Is_Spy_Counter(hard_point) then
			is_countered = true
		end
	end

	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Spy"} )
	SpyCoolDown = tm + GlobalSpyCoolDown
	SpyDoneTime = tm + GlobalSpyTime
	SpyStartCoolTime 	= tm
	
	if is_countered then
		region.Attach_Particle_Effect(SpyCounteredEffectName, "earth_sign")
		Raise_Game_Event("Global_Spy_Blocked", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
	else
		Set_Spy_Level( region, GlobalStartSpyLevel )
		
		if GlobalSpyTimeToNextLevel > 0.0 then
			SpyRaiseLeveTime = tm + GlobalSpyTimeToNextLevel
		else
			SpyRaiseLeveTime = 0.0
		end
		SpyParticleObject = region.Attach_Particle_Effect(SpyEffectName, "earth_sign")
		Raise_Game_Event("Global_Spy_Activated", Object.Get_Owner(), Object.Get_Position(), Object.Get_Type())
	end
	
end

function Is_Spy_Counter(object)
	if not SpyDefenseTypeTable then
		SpyDefenseTypeTable = {}
		SpyDefenseTypeTable[Find_Object_Type("Alien_Abduction_Core_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Alien_Creation_Core_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Alien_Foundation_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Alien_Theory_Core_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Masari_Atlatea_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Masari_Key_Inspiration_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Masari_Element_Magnet_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Masari_Will_Processor_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Novus_Material_Center_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Novus_Nanocenter_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Novus_Megacorp_Center_Block_Spying_Upgrade")] = true
		SpyDefenseTypeTable[Find_Object_Type("Novus_R_and_D_Center_Block_Spying_Upgrade")] = true
	end
		
	return SpyDefenseTypeTable[object.Get_Type()]	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Set_Spy_Level
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Spy_Level( region, spy_level )
	if region ~= nil then
	
		if SpyRegion ~= nil and SpyRegion ~= region then
			-- cancel other region
			local current_level = SpyRegion.Get_Strategic_FOW_Level( Object ) - SpyLevel
			if current_level < SpyLevelMinimum then
				current_level = SpyLevelMinimum
			end
			SpyRegion.Set_Strategic_FOW_Level( Object, current_level )
			SpyRegion.Get_GUI_Scenes()[1].Raise_Event("Global_Spy_Level_Changed", nil, nil)
			SpyLevel = 0
			SpyRegion = nil
		end
		
		local new_level = region.Get_Strategic_FOW_Level( Object )
		if SpyRegion ~= nil and region == SpyRegion then
			new_level = new_level + spy_level - SpyLevel
		else
			new_level = new_level + spy_level
		end
		
		SpyLevel = spy_level
		SpyRegion = region
		if new_level < SpyLevelMinimum then
			new_level = SpyLevelMinimum
		end
		SpyRegion.Set_Strategic_FOW_Level( Object, new_level )
		SpyRegion.Get_GUI_Scenes()[1].Raise_Event("Global_Spy_Level_Changed", nil, nil)
		
	else
		-- cancel spying	
		if SpyRegion ~= nil and SpyLevel > 0 then
			local current_level = SpyRegion.Get_Strategic_FOW_Level(Object) - SpyLevel
			if current_level < SpyLevelMinimum then
				current_level = SpyLevelMinimum
			end
			SpyRegion.Set_Strategic_FOW_Level( Object, current_level )
			SpyRegion.Get_GUI_Scenes()[1].Raise_Event("Global_Spy_Level_Changed", nil, nil)
		end
		
		if TestValid(SpyParticleObject) then
			SpyParticleObject.Despawn()
		end
		
		SpyLevel = 0
		SpyRegion = nil
		SpyDoneTime = 0.0 
		SpyRaiseLeveTime = 0.0
	end
end

function Debug_Force_Complete()
	SpyCoolDown = 0
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Ready", nil, {Object, "Spy"} )
end

local function Behavior_Post_Load_Game()
	Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Registration", nil, {Object, "Spy"} )
	if SpyCoolDown > 0 then
		Get_Game_Mode_GUI_Scene().Raise_Event("Global_Megaweapon_Not_Ready", nil, {Object, "Spy"})	
	end	
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
