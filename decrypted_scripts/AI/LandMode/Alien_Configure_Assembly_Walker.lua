if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Alien_Configure_Assembly_Walker.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/LandMode/Alien_Configure_Assembly_Walker.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
ScriptShouldCRC = true

function Compute_Desire()
	
	if Player.Get_Player_Is_Crippled() then
		return -2.0
	end
	
	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not Is_Player_Of_Faction(Player, "ALIEN") and not Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		--Goal.Suppress_Goal()
		return -2.0
	end	
	
	if not Target.Is_Ally(Player) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	local object_target = Target.Get_Game_Object()
	if not TestValid(object_target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if object_target.Get_Type() ~= Find_Object_Type("Alien_Walker_Assembly") then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	return 1.0
end

function Score_Unit(unit)
	
	if TestValid(Target) then
		if unit == Target.Get_Game_Object() then
			return 1.0
		end
	end
	
	return 0.0
	
end

function Service()

	if not Goal.Get_Task_Force() then
		return
	end
	
	if #Goal.Get_Task_Force().Get_Potential_Unit_Table() > 0 then
		Goal.Claim_Units("Configure_Thread")
	end

end

function Get_Hard_Point_Count(hp_type)

	local num = 99
	
	if TestValid(hp_type) and TestValid(walker_object) then
	
		local walker_type = walker_object.Get_Type()
		
		if TestValid(walker_type) then
		
			num = 0
		
			local built_hps = walker_object.Find_All_Hard_Points_Of_Type(hp_type)
			local construct_hp_type = walker_type.Get_Type_Value("Tactical_Under_Construction_Object_Type")
			local construct_hps = walker_object.Find_All_Hard_Points_Of_Type(construct_hp_type)
			
			if built_hps then
				num = #built_hps
			end

			if construct_hps then
				num = num + #construct_hps
			end
		
		end
		
	end
	
	return num
	
end


function Configure_Thread(walker_tf)

	walker_tf.Register_Signal_Handler(On_Walker_Damaged, "OBJECT_DAMAGED")
	walker_object = walker_tf.Get_Unit_Table()[1]
	
	--Production plans will take care of having production pre-req hard points built.

	--Do preset configuration stuff here

	local arc_type = Find_Object_Type("Alien_Walker_Assembly_HP_Arc_Trigger")
	local rad_type = Find_Object_Type("Alien_Walker_Assembly_HP_Plasma_Cannon")
	local foo_type = Find_Object_Type("Alien_Walker_Assembly_HP_Foo_Chamber")
	local weapon_acc_type = Find_Object_Type("Alien_Walker_Assembly_HP_Heat_Sink")
	local armor_cap_type = Find_Object_Type("Alien_Walker_Assembly_HP_Face_Cap_Armor_Crown")
	local armor_crown_type = Find_Object_Type("Alien_Walker_Assembly_HP_Armor_Crown")
	
	while TestValid(walker_object) do 
	
		--If we've built a hard point with a timed ability then build a heat sink for faster recharge on the ability
--		if walker_object.Has_Hard_Point_of_Type("Alien_Walker_Assembly_HP_Plasma_Cannon_Under_Construction") or 
--			walker_object.Has_Hard_Point_of_Type("Alien_Walker_Assembly_HP_Scarn_Beam_Under_Construction") then
--			if not walker_object.Has_Hard_Point_of_Type("Alien_Walker_Habitat_HP_Heat_Sink_Under_Construction") then
--				Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Assembly_HP_Heat_Sink"))
--			end
--		end	
		
		-- Build 1 x arc trigger
		if not Player.Is_Object_Type_Locked( arc_type ) and Get_Hard_Point_Count(arc_type) < 1 then
			Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, arc_type )
		end		

		-- alien cash is hard to manage try to keep a reserve
		if Player.Get_Credits() > 1500.0 then

			-- Build an plasma cannon 2x
			if not Player.Is_Object_Type_Locked( rad_type ) and Get_Hard_Point_Count(rad_type) < 2 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, rad_type )
			end		

			-- Build a foo 1x
			if not Player.Is_Object_Type_Locked( foo_type ) and Get_Hard_Point_Count(foo_type) < 1 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, foo_type )
			end		

			-- Build cap armor x 0 to 1
			if not Player.Is_Object_Type_Locked( armor_cap_type ) and Get_Hard_Point_Count(armor_cap_type) + Get_Hard_Point_Count(armor_crown_type) < 1 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, armor_cap_type )
				Sleep(3.0)
			end
			
			-- Build crown armor x 0 to 1
			if not Player.Is_Object_Type_Locked( armor_crown_type ) and Get_Hard_Point_Count(armor_cap_type) + Get_Hard_Point_Count(armor_crown_type) < 1 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, armor_crown_type )
				Sleep(3.0)
			end		

			-- Build heat sink x 1
			if not Player.Is_Object_Type_Locked( weapon_acc_type ) and Get_Hard_Point_Count(weapon_acc_type) < 1 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, weapon_acc_type )
				Sleep(3.0)
			end		
		end

		Sleep(1.0)
		
	end
end

function On_Walker_Damaged(tf, walker, attacker, projectile_type, hard_point, deliberate)

	--Configure the walker based on what we get hit by.
	--Note that since we're using sub-goals we'll be building at most one of each type of hard point
	--at once (may or may not be a good thing)

	-- AJA 03/26/2007 - Obsolete hard point type.
	--if TestValid(projectile_type) then
	--	if projectile_type.Is_Affected_By_Missile_Shield() then
	--		Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Assembly_Scramble_Shield_HP"))
	--	end
	--end

	if not TestValid(attacker) then
		return
	end

--	if TestValid(walker_object) then
--		if not walker_object.Has_Hard_Point_of_Type("Alien_Walker_Assembly_HP_Scarn_Beam_Under_Construction") then
--			Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Assembly_HP_Scarn_Beam"))
--		end
--	end

--	if attacker.Is_Category("Piloted") then
--		Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon"))
--	elseif attacker.Is_Category("Small") then
--		Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Assembly_HP_Plasma_Cannon"))
--	end
		
	-- AJA 03/26/2007 - Obsolete hard point type.
	--if Is_Player_Of_Faction(attacker.Get_Owner(), "NOVUS") then
	--	Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Assembly_HP_EM_Field_Generator"))
	--end
	
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
	Declare_Enum = nil
	Describe_Target = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	Get_Distance_Based_Unit_Score = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
