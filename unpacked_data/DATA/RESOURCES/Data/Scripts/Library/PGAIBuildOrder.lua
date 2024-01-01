-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGAIBuildOrder.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGAIBuildOrder.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Keith_Brors $
--
--            $Change: 90485 $
--
--          $DateTime: 2008/01/08 11:38:53 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGLogging")


---------------------- Script Globals ----------------------

--
-- All "Build Orders" follow the same format:
-- * Table containing two named entries:
--    - "Options": Table containing a number of named parameters that guide the code when executing these orders.
--    - "BuildOrder": Table containing sub-tables that each define an ObjectType to create, how many of that
--      type should be maintained at the same time, and whether the thread should exit when it reaches the
--      target number.
--
-- Always be sure when you're defining these build order tables as globals within your script that you define
-- then in the Definitions() function of your Goal. Otherwise you risk the script being reused and having the
-- table nil'd out.
SAMPLE_BUILD_ORDER = {}
LOGFILE_NAME = "AIBuildOrder.txt"

function Definitions()
	-- Override from PGLogging.lua
	LOGFILE_NAME = "AIBuildOrder.txt"

	-- Just an example of the table format you should use to define you own!
	SAMPLE_BUILD_ORDER = {
		Options = { DurationMin=60.0, DurationMax=90.0, KillThreadsWhenDone=false },
		BuildOrder = {
			{ Type="Alien_Arrival_Site",						Count=1, ExitThread=false },
			{ Type="Alien_Glyph_Carver",						Count=2, ExitThread=true },
			{ Type="Alien_Superweapon_Reaper_Turret",	Count=2, ExitThread=true },
			{ Type="Alien_Information_Conduit",			Count=1, ExitThread=false },
		}
	}

end





---------------------- Library Functions ----------------------


--
-- Maintain_Unit_Count - A handy function call that will spawn off a thread that ensures we try to maintain
-- a certain number of the given unit type on the play-field at all times. Returns the ThreadID of the
-- spawned thread.
--
function Maintain_Unit_Count(unit_type_name, unit_count, exit_thread_when_count_reached)

	-- Make sure the given type is valid.
	local unit_type = Find_Object_Type(unit_type_name)
	if not unit_type then
		log("Maintain_Unit_Count: ERROR - Unit type '%s' not found!", unit_type_name)
		return
	end
	
	-- Make sure the given count is valid.
	if unit_count <= 0 then
		log("Maintain_Unit_Count: ERROR - Unit count '%g' doesn't make sense.", unit_count)
		return
	end
	
	-- Figure out the appropriate sub-goal to produce the given unit type.
	local subgoal_name = "Generic_Sub_Goal_Build_Unit"
	if TestValid(unit_type.Get_Type_Value("Tactical_Buildable_Beacon_Type")) then
		subgoal_name = "Generic_Sub_Goal_Build_Structure"
	elseif unit_type.Has_Behavior(BEHAVIOR_HARD_POINT, "Land") then
		subgoal_name = "Generic_Sub_Goal_Build_Hard_Point"
	end
	
	-- Fire off the thread that will maintain the desired unit count.
	return Create_Thread("Maintain_Unit_Count_Thread", { unit_type_name, unit_count, subgoal_name, exit_thread_when_count_reached })
	
end


--
-- Maintain_Unit_Count_Thread - The thread function that tries to maintain a certain number of units
-- of a given type.
--
function Maintain_Unit_Count_Thread(params)

	-- This thread ID
	local thread_id = Thread.Get_Current_ID()

	-- Since thread functions can only take one parameter, we have to peel the interesting info out
	-- of the table.
	local unit_type_name = params[1]
	local target_unit_count = params[2]
	local builder_subgoal_name = params[3]
	local exit_when_count_reached = params[4]
	
	log("Maintain_Unit_Count_Thread(%s, %g, %s, %s) started (threadID:%d)", unit_type_name, target_unit_count, builder_subgoal_name, tostring(exit_when_count_reached), thread_id)
	
	-- Cache the unit type wrapper.
	local unit_type = Find_Object_Type(unit_type_name)
	if not TestValid(unit_type) then
		return
	end
	
	-- info about this thread / goal
	ThreadStatus[thread_id]={}
	ThreadStatus[thread_id].ShouldDie=false
	ThreadStatus[thread_id].Goal=Goal
	ThreadStatus[thread_id].Type=unit_type
	ThreadStatus[thread_id].BlockTable={}
	
	local count = 0
	
	-- As long as there are fewer units of the desired type out there, keep cranking them out.
	while true do

		for index=#ThreadStatus[thread_id].BlockTable, 1, -1 do
			local block = ThreadStatus[thread_id].BlockTable[index]
			if block ~= nil and ( not block.Block or block.Block.IsFinished() ) then
				table.remove(ThreadStatus[thread_id].BlockTable,index)
			end
		end

		if ThreadStatus[thread_id].ShouldDie and #ThreadStatus[thread_id].BlockTable < 1 then
			ThreadStatus[thread_id]=nil
			return
		end
		
	
		-- How many units of that type do we have right now? Include objects that are under construction.
		local current_and_under_construction_units = PG_Find_All_Objects_Of_Type(unit_type_name, Player)
		local command_add = 0
		if unit_type.Get_Type_Value("Is_Command_Center") and (current_and_under_construction_units == nil or #current_and_under_construction_units < 1.0) then
			local obj_list = Find_All_Objects_Of_Type(Player,"Stationary")
			Sleep(0.25)
			if obj_list then
				for _,unit in pairs(obj_list) do
					if TestValid( unit ) then
						local type = unit.Get_Type()
						if TestValid(type) and type.Get_Type_Value("Is_Command_Center") then
							command_add = 1.0
							break
						end
					end
				end
			end
		end
		local num_instances_in_build_queues = PG_Count_Num_Instances_In_Build_Queues(unit_type, Player)
		local current_unit_count = #current_and_under_construction_units + num_instances_in_build_queues + command_add
		-- By including the sub goal count we can be sure we don't get too many at once
		local build_many = false
		
		-- fake ending of thread by keep count high, i.e .no more building of this type
		if ThreadStatus[thread_id].ShouldDie then
			current_unit_count = 999999
		end

		if (builder_subgoal_name == "Generic_Sub_Goal_Build_Structure" and target_unit_count > 2) or target_unit_count - current_unit_count > 5 then
			-- Note that this won't be quite acturate unitil goal is finished as once the build is actually constructed it will add to the count (i.e. it will be counted twice for a while)
			-- this will speed up AI building of resource collectors
			-- and AI building of cheap units
			build_many = true
		end

		local goal_count = Get_Total_Active_Count(unit_type,target_unit_count)
		
		current_unit_count = current_unit_count + goal_count
		
		local activating = false
		
		if current_unit_count < target_unit_count then
		
			-- debug test
			if unit_type == Find_Object_Type("Novus_Input_Station") then
				local dummy = 0
			end
		
			activating = true
			local block
			local block_table = {}
			if build_many then
				local block_data = {}
				table.insert(block_data, unit_type)
				table.insert(block_data, 1)
				table.insert(block_data, count)
				block = Goal.Activate_Sub_Goal(builder_subgoal_name, nil, block_data)
				block_table.Block = block
				block_table.Name = builder_subgoal_name
				block_table.Data = block_data
			else
				local block_data = unit_type
				block = Goal.Activate_Sub_Goal(builder_subgoal_name, nil, block_data )
				block_table.Block = block
				block_table.Name = builder_subgoal_name
				block_table.Data = block_data
			end
			
			block_table.CreationTime = GetCurrentTime()
			
			if block ~= nil then
				table.insert(ThreadStatus[thread_id].BlockTable,block_table)
			end
			
			count = count + 1
		elseif exit_when_count_reached then
			ThreadStatus[thread_id]=nil
			log("Maintain_Unit_Count_Thread: %g %s's exist (>= target count of %g), exiting maintenance thread(ID:%d)", current_unit_count, unit_type_name, target_unit_count, thread_id)
			return
		end
		
		if activating then
			Sleep(1.0)
		else
			Sleep(5.0)
		end
	end
end

--
-- count active threads
--
function Get_Total_Active_Count(unit_type, maintain_number)
	
	local count = 0
	local cur_time = GetCurrentTime()

	if TestValid(unit_type) then
		for id,status in pairs(ThreadStatus) do
			if status ~= nil and status.Type == unit_type and status.BlockTable ~= nil then

				-- Might need to add a remove here for old scripts dead scripts
				
				for _,block_data in pairs(status.BlockTable) do
					if block_data.Block then
						count = count + 1
					end
					
					if cur_time - block_data.CreationTime > 90.0 or status.ShouldDie then
						-- check to see if we should kill this sub goal
						local block_script = Goal.Get_Script_For_Sub_Goal(block_data.Name,nil,block_data.Data)
						if block_script then
							local builder_num = block_script.Call_Function("Get_Builder_Count",nil)
							if builder_num and builder_num < 1.0 then
								block_script.Call_Function("Kill_This_Sub_Goal",nil)
							end
						end
					end
				end
				
			end
		end
	end
	
	return count
	
end

--
-- Execute_Build_Order - 
--
function Execute_Build_Order(build_order)

	-- Make sure we weren't given bogus data.
	if not build_order then
		log("Execute_Build_Order: ERROR - nil build_order received!")
		return
	end
	
	if ThreadStatus == nil then
		ThreadStatus = {}
	end
	
	-- Launch a thread to maintain the given unit count for each unit entry in the build order.
	local spawned_threads = {}
	for _,unit_entry in pairs(build_order.BuildOrder) do
		local thread_id = Maintain_Unit_Count(unit_entry.Type, unit_entry.Count, unit_entry.ExitThread)
		table.insert(spawned_threads, thread_id)
	end
	
	-- Wait for the Duration of the build order to expire.
	local duration = GameRandom(build_order.Options.DurationMin, build_order.Options.DurationMax)
	Sleep(duration)
	
	-- This phase of the build order is complete. Kill off all other threads if appropriate.
	-- (This will kill all the unit maintenance threads we just spawned.)
	if build_order.Options.KillThreadsWhenDone then
		log("Current build order options define KillThreadsWhenDone = true, killing spawned threads!")
		for _,id in pairs(spawned_threads) do
			if ThreadStatus[id] ~= nil then
				ThreadStatus[id].ShouldDie = true
				log("Told Thread to die thread ID:%d", id)
			else
				Thread.Kill(id)
				log("Thread Killed thread ID:%d", id)
			end
		end
	end

end

