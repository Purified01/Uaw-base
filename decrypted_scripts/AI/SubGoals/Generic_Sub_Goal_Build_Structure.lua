if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[161] = true
LuaGlobalCommandLinks[113] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Sub_Goal_Build_Structure.lua#13 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Sub_Goal_Build_Structure.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")

ScriptShouldCRC = true

local	glyph_carver_type = nil
local masari_lab_type = nil
local	signal_tower_type = nil
local	masari_engine_type = nil

function Compute_Desire()

	--This is a sub goal.  Once it's been activated by another goal it remains desirable, but
	--it never becomes active on its own.
	if Goal.Is_Active() then
		return 1.0
	else
		return 0.0
	end

end

function Score_Unit(unit)

	-- construction is started. aquiring units now is pointless
	if CanKillThread then
		return 0.0
	end

	if not TestValid(unit) then
		return 0.0
	end

	if not ready_to_build then
		return 0.0
	end

	if unit.Has_Behavior(141) or unit.Get_Garrison() ~= nil then
		return 0.0
	end

	local unit_type = unit.Get_Type()
	if not TestValid(unit_type) then
		return 0.0
	end

	if not unit_type.Get_Type_Value("Is_Tactical_Base_Builder") then
		return 0.0
	end
	
	local tf = Goal.Get_Task_Force()
	if tf and Already_Recruited(tf, unit) then
		return 99.0
	end
	
	local existing_units = 0
	if tf then
		existing_units = tf.Get_Total_Unit_Count()
	end
	
	if existing_units == 0 then
	
		if type_to_build ~= nil and type_to_build == masari_engine_type then
			return 5.0 + GameRandom.Get_Float(0.0,0.1)
		end

		if type_to_build ~= nil and type_to_build == signal_tower_type then
			return 5.0 + GameRandom.Get_Float(0.0,0.1)
		end

		if type_to_build ~= nil and type_to_build == power_router_type then
			return 10.0 + GameRandom.Get_Float(0.0,0.1)
		end
		
		if Target then
			distance_to_target = Target.Get_Distance(unit)
			if distance_to_target > 0.0 then
				return 1.0 + 1.0 / distance_to_target + GameRandom.Get_Float(0.0,0.1)
			else
				return 2.0 + GameRandom.Get_Float(0.0,0.1)
			end
		else
			return 2.0 + GameRandom.Get_Float(0.0,0.1)
		end
		
	elseif unit.Get_Type() == glyph_carver_type or existing_units > 0 then
		--Glyph carvers are a special case where multiple builders doesn't speed anything up, 
		--but the XML that identifies them as such is buried in the build ability so we'll just
		--check directly for the type.
		--KDB the constructors will help if nearby and idle, no need to pull in too many of them
		return 0.0
	else
		if type_to_build ~= nil and type_to_build == signal_tower_type then
			return 1.0 + Get_Distance_Based_Unit_Score(Goal.Get_Task_Force(), unit) / existing_units + GameRandom.Get_Float(0.0,0.1)
		end
		return Get_Distance_Based_Unit_Score(Goal.Get_Task_Force(), unit) / existing_units + GameRandom.Get_Float(0.0,0.1)
	end
end

function Already_Recruited( task_force, our_unit )
	
	if not task_force then
		return false
	end
	
	local unit_list = task_force.Get_Unit_Table()
	if unit_list ~= nil then
		
		for _,unit in pairs(unit_list) do
			if TestValid( unit ) and unit == our_unit then
				return true
			end
		end
	end

	return false
	
end

function On_Activate()

	type_to_build = nil
	build_count = nil
	required_cash = nil
	Create_Thread("Prepare_To_Build")
	glyph_carver_type = Find_Object_Type("Alien_Glyph_Carver")
	masari_lab_type = Find_Object_Type("Masari_Inventors_lab")
	signal_tower_type = Find_Object_Type("Novus_Signal_Tower")
	masari_engine_type = Find_Object_Type("Masari_Elemental_Collector")
	power_router_type = Find_Object_Type("Novus_Power_Router")
	KillThisThread = false
	CanKillThread = false
	ItemCost = 0.0
	
end

function Service()

	if Goal.Get_Task_Force() and #Goal.Get_Task_Force().Get_Potential_Unit_Table() > 0 and type_to_build ~= nil then
		-- only claim one at a maximum, others will help out as needed
		Goal.Claim_Units( "Build_Thread", 1, true )
	end
	
	if KillThisThread then
		-- permanently use the cash
		Goal.Spend_Resources( ItemCost )
		ScriptExit()
	end
end

function Kill_This_Sub_Goal()
	KillThisThread = true
end

function Get_Builder_Count()

	local count = 0
	
	if not CanKillThread then	
		return 1.0
	end
	
	if Goal.Get_Task_Force() then
		count = #Goal.Get_Task_Force().Get_Unit_Table()
	end
	
	return count
	
end

--------------------------------------------------------------
-- Start Place and Build
--------------------------------------------------------------
function Sub_Goal_Place_And_Build( tf, type_to_build )
	local build_angle = 0.0
	local build_position = Target

	if not build_position then
		build_position, build_angle = Player.Find_Recommended_Structure_Position_And_Angle(type_to_build)
		if not build_position then
			build_position = tf.Get_Centroid()
		end
	end
	
	if not build_angle then
		build_angle = 0.0
	end
	
	local find_block = Find_Nearest_Open_Build_Position(build_position, type_to_build, Player, build_angle)
	if find_block ~= nil then
		build_position = BlockOnCommand( find_block, 30.0 )
	else
		log("Build_Thread(): Failure in Find_Nearest_Open_Build_Position(), type = %s.",type_to_build.Get_Name())
		ScriptExit()
	end
	
	if not find_block.IsFinished() then
		log("Build_Thread(): Timeout failure in Find_Nearest_Open_Build_Position(), type = %s.",type_to_build.Get_Name())
		ScriptExit()
	end
	
	if build_position then
		if Player.Can_Produce_Object(type_to_build) then
			local block = tf.Build_Structure(type_to_build, build_position, build_angle)
			if block ~= nil then
				local build_struct = BlockOnCommand( block, 150.0 )
				-- builders freed after 150 seconds
			else
				log("Build_Thread(): Place_And_Build_Structure - Type %s can not be placed, trying random area close to target.", tostring(type_to_build))
				build_angle = 0.0
				build_position.Set_Position_X( build_position.Get_Position_X() + 20.0 - GameRandom(0.0, 40.0) )
				local find_block_two = Find_Nearest_Open_Build_Position(build_position, type_to_build, Player, build_angle)
				if find_block_two ~= nil then
				
					build_position = BlockOnCommand( find_block_two, 30.0  )
					
					if not find_block_two.IsFinished() then
						log("Build_Thread(): Timeout in 2nd Find_Nearest_Open_Build_Position() , type = %s.",type_to_build.Get_Name())
						ScriptExit()
					end
					
					if build_position then
						if Player.Can_Produce_Object(type_to_build) then
							local tf_block_two = tf.Build_Structure(type_to_build, build_position, build_angle)
							if tf_block_two ~= nil then
								BlockOnCommand( tf_block_two, 150.0 )
								-- builders freed after 150 seconds
							else
								log("Build_Thread(): Failure in 2nd tf.Build_Structure() , type = %s.",type_to_build.Get_Name())
								ScriptExit()
							end
						else
							log("Build_Thread(): Failure in 2nd Can_Produce_Object() , type = %s.",type_to_build.Get_Name())
							ScriptExit()
						end
					else
						log("Build_Thread(): Failure in 2nd build_position, type = %s.",type_to_build.Get_Name())
						ScriptExit()
					end
					
				else
					log("Build_Thread(): Failure in 2nd Find_Nearest_Open_Build_Position() , type = %s.",type_to_build.Get_Name())
					ScriptExit()
				end
			end
		else
			log("Build_Thread(): Failure in Player.Can_Produce_Object() , type = %s.",type_to_build.Get_Name())
			ScriptExit()
		end
	else
		log("Build_Thread(): No build position, type = %s.",type_to_build.Get_Name())
		ScriptExit()
	end
end

--------------------------------------------------------------
-- End Place and Build
--------------------------------------------------------------

function Build_Thread(tf)

	for _ = 1, build_count do
		--Rely on Fix_Tactical_Dependencies to sort out the lock
		while Player.Is_Object_Type_Locked(type_to_build) do
			Sleep( 0.5 )
		end

		--Secure cash for the build.
		local required_cash = type_to_build.Get_Tactical_Build_Cost() * build_count
		ItemCost = required_cash
		
		-- don't request the cash until we have it as other wise we can jam up the que with lots of open orders with small
		-- amounts of cash claimed
		while Player.Get_Credits() < required_cash and not type_to_build.Is_Category("Huge") do
			Sleep(1.0)
		end
		
		while required_cash > 0.0 do
			required_cash = required_cash - Goal.Request_Resources(required_cash, false)
			if required_cash > 0.0 then
				Sleep(0.5)
			end
		end

		CanKillThread = true
		
		-- Use our own place and build
		--		Place_And_Build_Structure(Player, tf, type_to_build, Target)
		Sub_Goal_Place_And_Build( tf, type_to_build )
		
		-- permanently use the cash
		Goal.Spend_Resources( ItemCost )

	end
			
	--This goal can end prematurely when the under construction object does not require builders for the
	--entire duration of the build.  We'd really like the goal to persist until the object is finished;
	--on the other hand we do need the builders to be released as soon as they're no longer needed.
	--We can manage for now as is, but it would be nice to resolve this issue. 		
			
	ScriptExit()
	
end

function Prepare_To_Build()

	start_time = GetCurrentTime()

	local user_data = Goal.Get_User_Data()
	if type(user_data) == "table" then
		type_to_build = user_data[1]
		build_count = user_data[2] 
		if not build_count then
			build_count = 1
		end
	else
		type_to_build = user_data
		build_count = 1
	end

	if not TestValid( type_to_build ) then
		return
	end

	--Take steps to unlock this type
	Fix_Tactical_Dependencies(Player, Goal, type_to_build)
	
	ready_to_build = true
	
	--Keep this thread alive so that it doesn't exit and cause the goal to be prematurely killed.
	--Also periodically re-check the dependencies so that we don't get blocked if something vanishes
	--after our initial check.
	while true do
		Sleep(10)
		Fix_Tactical_Dependencies(Player, Goal, type_to_build)
	end
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
