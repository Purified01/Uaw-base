-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Alien_Configure_Science_Walker.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/LandMode/Alien_Configure_Science_Walker.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 85508 $
--
--          $DateTime: 2007/10/04 16:01:54 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
ScriptShouldCRC = true

function Compute_Desire()
	
	if not TestValid(Target) then
		Goal.Suppress_Goal()
		return 0.0
	end
	
	if not Is_Player_Of_Faction(Player, "ALIEN") and not Is_Player_Of_Faction(Player, "ALIEN_ZM06_KAMALREX") then
		Goal.Suppress_Goal()
		return 0.0
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
	
	if object_target.Get_Type() ~= Find_Object_Type("Alien_Walker_Science") then
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
	
	local arc_type = Find_Object_Type("Alien_Walker_Science_HP_Arc_Trigger")
	local foo_type = Find_Object_Type("Alien_Walker_Science_HP_Foo_Chamber")
	
	while TestValid(walker_object) do 
		
		-- alien cash is hard to manage try to keep a reserve
		if Player.Get_Credits() > 2500.0 then
		
			-- Build 2 x arc trigger
			if not Player.Is_Object_Type_Locked( arc_type ) and Get_Hard_Point_Count(arc_type) < 2 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, arc_type )
			end		

			-- Build a foo 1x
			if not Player.Is_Object_Type_Locked( foo_type ) and Get_Hard_Point_Count(foo_type) < 1 then
				Goal.Activate_Sub_Goal( "Generic_Sub_Goal_Build_Hard_Point", Target, foo_type )
			end		
			
		end

		Sleep(1)
		
	end
end

function On_Walker_Damaged(tf, walker, attacker, projectile_type, hard_point, deliberate)

	--Configure the walker based on what we get hit by.
	--Note that since we're using sub-goals we'll be building at most one of each type of hard point
	--at once (may or may not be a good thing)

--	if TestValid(projectile_type) then
--		if projectile_type.Is_Affected_By_Missile_Shield() then
--			Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Science_Scramble_Shield_HP"))
--		end
--	end

	if not TestValid(attacker) then
		return
	end
	
--	if attacker.Is_Category("Piloted") then
--		Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Science_HP_Plasma_Cannon"))
--	end
		
--	if Is_Player_Of_Faction(attacker.Get_Owner(), "NOVUS") then
--		Goal.Activate_Sub_Goal("Generic_Sub_Goal_Build_Hard_Point", Target, Find_Object_Type("Alien_Walker_Science_HP_EM_Field_Generator"))
--	end
	
end
