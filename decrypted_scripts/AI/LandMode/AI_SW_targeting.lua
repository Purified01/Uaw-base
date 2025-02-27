if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[197] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[18] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[163] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/AI_SW_targeting.lua#14 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/AI_SW_targeting.lua $
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

require("PGBaseDefinitions")
require("PGAICommands")
require("PGBase")
require("PGUICommands")

local player_script = nil
ScriptShouldCRC = true

function Compute_Desire()

	if not Is_Player_Of_Faction(Player, "MASARI") and not Is_Player_Of_Faction(Player, "NOVUS") and not Is_Player_Of_Faction(Player, "ALIEN") then
		--Goal.Suppress_Goal()
		return -2.0
	end

	-- Only start the goal with the nil object
	if Target then
	
		--Goal.Suppress_Goal()
		return -1.0
	end

	

	-- must keep desire up
	return 1.0
	
end

function Score_Unit(unit)
	
	return 0.0
		
end

function Service()

end

function On_Activate()

	if player_script == nil then
		player_script = Player.Get_Script()
	end
	
	Create_Thread("Monitor_Superweapons")

	BackupTarget = nil
	TimeWeaponReady = 0.0
	ImportantTargetTypes = {}
	NextSWCheckTime = 0.0

	local temp_type = Find_Object_Type("Novus_Power_Router")	
	if TestValid(temp_type) then
		table.insert(ImportantTargetTypes,temp_type)
	end
	temp_type = Find_Object_Type("Alien_Superweapon_Mass_Drop")	
	if TestValid(temp_type) then
		table.insert(ImportantTargetTypes,temp_type)
	end
	temp_type = Find_Object_Type("Novus_Superweapon_Gravity_Bomb")	
	if TestValid(temp_type) then
		table.insert(ImportantTargetTypes,temp_type)
	end
	temp_type = Find_Object_Type("Novus_Superweapon_EMP")	
	if TestValid(temp_type) then
		table.insert(ImportantTargetTypes,temp_type)
	end
	temp_type = Find_Object_Type("Masari_Elemental_Controller")	
	if TestValid(temp_type) then
		table.insert(ImportantTargetTypes,temp_type)
	end

end

function Monitor_Superweapons()

	if player_script == nil then
		-- total error
		ScriptExit()
	end

	while true do
	
		local sw_object, sw_time, sw_name
		
		sw_object = player_script.Call_Function("SW_Get_Ready_Weapon",nil)
		
		if TestValid(sw_object.Object) and sw_object.WeaponName ~= nil and sw_object.Object.Is_AI_Recruitable() then
			if TimeWeaponReady == 0.0 then
				TimeWeaponReady = GetCurrentTime()
			end
			Target_And_Fire_SW(sw_object.Object, sw_object.WeaponName)
		end
	
		Sleep(1.5)
	
	end
end

function Important_Target(unit)
	
	if unit.Is_Category("Huge + CanAttack") then
		return true
	end
	
	local unit_type = unit.Get_Type()
	if not TestValid(unit_type) then
		return false
	end
	
	if unit_type.Get_Type_Value("Is_Command_Center") then
		return true
	end
		
	local b_type = unit_type.Get_Base_Type()
	
	for _, i_type in pairs (ImportantTargetTypes) do
		if i_type == b_type then
			return true
		end
	end
	
	return false
	
end

function Target_And_Fire_SW(sw_object, sw_name)

	local weapon_type = Find_Object_Type(sw_name)
	if not TestValid(weapon_type) then
		-- failed
		Sleep(5.0)
		return	
	end
	
	-- easy never fires sw
	if Player.Get_Difficulty() == "Difficulty_Easy" then
	
		Sleep(5.0)
		return	
			
	elseif Player.Get_Difficulty() ~= "Difficulty_Hard" and GameRandom(0,100) < 80 then

		-- if no hard then sleep for a while (most of the time)
		Sleep(15.0)
		return	
	else
		-- wait a bit
		Sleep(5.0)
	end
	

	local radius = weapon_type.Get_Type_Value("TSW_Area_Effect_Radius")
	if radius == nil or radius < 50.0 then
		-- error
		radius = 50.0	
	end

	if NextSWCheckTime < GetCurrentTime() then
	
		NextSWCheckTime = GetCurrentTime() + 6.0
		BackupTarget = nil
		BackupTarget = {}
	
		local obj_list = Find_All_Objects_Of_Type( "Stationary + ~ Bridge + ~Resource + ~Resource_INST + ~Insignificant | Huge + ~ Bridge + ~Resource + ~Resource_INST" )
		
		local target_list = {}
		local count = 1
		
		if obj_list then
			for _,unit in pairs(obj_list) do
				if TestValid(unit) and Player.Is_Enemy(unit.Get_Owner()) and not unit.Is_Phased() then
					target_list[count] = unit
					count = count + 1
				end
			end
		end
		
		if #target_list > 0 then
			
			-- look for best target area
			local best_score = 0.0
			local best_position = nil
			local best_target = nil
			local temp_count = 0.0

			for _,unit in pairs(target_list) do
			
				if not TestValid(sw_object) then
					-- it died during a sleep
					return
				end
			
				if TestValid(unit) then
					-- look in a couple of positions for a target
					temp_count = temp_count + 1
					
					local score = GameRandom.Get_Float(0.0,Score_Position(target_list, unit.Get_Position(), radius))
					if score > best_score then
						best_score = score
						best_position = unit.Get_Position()
						best_target = unit
					end 
					
					for angle = 0, 360.0, 45.0 do
						local position = Project_Position(unit,sw_object,radius * 0.8, angle)
						if TestValid(position) then
							score = GameRandom.Get_Float(0.0,Score_Position(target_list, position, radius))
							if score > best_score then
								best_score = score
								best_position = position
								best_target = unit
							end 
						end
					end

					if Important_Target(unit) then
						table.insert(BackupTarget,unit)
					end
					
					if temp_count >= 10 then
						Sleep(0.5)
						temp_count = 0.0
					end
					
				end
			end
			
			if TestValid(best_position) and not best_target.Is_Fogged(Player,true) then
				-- launch sw !!!
				-- Call the player script directly rather than using a GUI event (makes
				-- sure that the launch takes place in the proper thread)
				local player_script = Player.Get_Script()
				if TestValid(player_script) then
					player_script.Call_Function("Launch_Superweapon", weapon_type, best_position)
				end
				TimeWeaponReady = 0.0
				return
			end
		end
	end

	if not TestValid(sw_object) then
		-- it died during a sleep
		return
	end

	-- don't wait too long to fire, hit an important target if we have to
	if GetCurrentTime() - TimeWeaponReady > 10.0 and BackupTarget and #BackupTarget > 0 then
	
		local best_target = nil
		local best_target_value = 0.0
		
		for _,unit in pairs(BackupTarget) do
			if TestValid(unit) and not unit.Is_Fogged(Player,true) then
				local score = GameRandom(1,100)		
				if score > best_target_value then
					best_target_value = score
					best_target= unit
				end
			end
		end

		if TestValid(best_target) then
			-- launch sw !!!
			-- Call the player script directly rather than using a GUI event (makes
			-- sure that the launch takes place in the proper thread)
			local player_script = Player.Get_Script()
			if TestValid(player_script) then
				player_script.Call_Function("Launch_Superweapon", weapon_type, best_target.Get_Position())
			end			
			TimeWeaponReady = 0.0
		end
		
	end
	
end


---------------------------------------------------
-- Score_Position : score this target position
---------------------------------------------------
function Score_Position(target_list, position, radius)

	local count = 0
	
	if TestValid(position) then
		for _,t_unit in pairs(target_list) do
			if TestValid(t_unit) and t_unit.Get_Distance(position) <= radius then
				count = count + 1
				if t_unit.Is_Category("Huge + CanAttack") then
					-- go after walkers
					count = count + 3
				elseif t_unit.Is_Category("CanAttack") then
					-- go after turrets
					count = count + 1
				end
			end
		end
	end

	return count
	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Burn_All_Objects = nil
	Calculate_Task_Force_Speed = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Describe_Target = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Distance_Based_Unit_Score = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
