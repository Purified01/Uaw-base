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
--             File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/TacticalBaseBuildersManager.lua
--
--    Original Author: Maria Teruel
--
--          DateTime: 2007/05/16
--
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGBase")
require("PGUICommands")
require("PGVectorMath")

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Tactical_Base_Builders_Manager
-- ------------------------------------------------------------------------------------------------------------------
function Init_Tactical_Base_Builders_Manager()
	BuildersList = {}
	BuildersCount = 0
	SelectedBuilder = nil
	TetherBuilder = nil
	Script.Set_Async_Data("SelectedBuilder", SelectedBuilder)
	Script.Set_Async_Data("BuildersCount", BuildersCount)
	
	NumberVisited = 0
	
	ButtonClickedTime = nil
	RESET_VISITED_BUILDERS_DELAY = 4.0
end

-- ------------------------------------------------------------------------------------------------------------------
-- Add_Builder -- Add this builder to the list!.
-- ------------------------------------------------------------------------------------------------------------------
function Add_Builder(builder)
	if not TestValid(builder) or BuildersList == nil then 
		return
	end

	-- only add builders if they are not mind controlled!.  NOTE that this function will
	-- also get called whenever the object changes owner (which can be caused by the builder
	-- getting mind controlled by another player!)
	if builder.Get_Attribute_Value( "Is_Mind_Controlled" ) <= 0 then 
		table.insert(BuildersList, {Object = builder, Visited = false})
	end
	BuildersCount = #BuildersList
	Script.Set_Async_Data("BuildersCount", BuildersCount)
	builder.Register_Signal_Handler(On_Builder_Destroyed, "OBJECT_SOLD")
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Builder_Destroyed
-- ------------------------------------------------------------------------------------------------------------------
function On_Builder_Destroyed(builder)
	Remove_Builder(builder)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Remove_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Remove_Builder(builder)

	if not TestValid(builder) then return end
	if not BuildersList then return end
	
	for index=table.getn(BuildersList), 1, -1 do
		local list_builder = BuildersList[index].Object
		if TestValid(list_builder) and list_builder == builder then
			table.remove(BuildersList, index)
			break;
		end
	end
	
	if builder == SelectedBuilder then 
		SelectedBuilder = nil
	end
	
	if builder == TetherBuilder then 
		TetherBuilder = nil
	end
	
	Script.Set_Async_Data("SelectedBuilder", SelectedBuilder)
	BuildersCount = #BuildersList
	Script.Set_Async_Data("BuildersCount", BuildersCount)
	
	if #BuildersList <= 0 then
		ButtonClickedTime = nil
	end
	
	builder.Unregister_Signal_Handler(On_Builder_Destroyed)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Builders_List
-- ------------------------------------------------------------------------------------------------------------------
function Update_Builders_List()
	if ButtonClickedTime and #BuildersList > 0 then
		if GetCurrentTime() - ButtonClickedTime >= RESET_VISITED_BUILDERS_DELAY then
			Reset_Visited_States()
			SelectedBuilder = nil
			TetherBuilder = nil		
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Sort_Builders_List
-- ------------------------------------------------------------------------------------------------------------------
function Sort_Builders_List()
	
	NumberVisited = 0
	
	local all_builders = BuildersList
	local last_idle_index = 0
	BuildersList = {}
	local non_idle_builders = {}
	for _, builder_data in pairs(all_builders) do
		local object = builder_data.Object
		if TestValid(object) then 
			if object.Is_Idle() then
				table.insert(BuildersList, builder_data)
			else
				table.insert(non_idle_builders, builder_data)			
			end
			
			if builder_data.Visited then
				NumberVisited = NumberVisited + 1
			end
		end
	end
	last_idle_index = #BuildersList
	for _, builder_data in pairs(non_idle_builders) do
		table.insert(BuildersList, builder_data)
	end
	
	return last_idle_index
end

-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Visited_States
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Visited_States()
	for _, builder_data in pairs(BuildersList) do
		local builder = builder_data.Object
		if builder then 
			builder_data.Visited = false		
		end
	end
	NumberVisited = 0
end

-- ------------------------------------------------------------------------------------------------------------------
-- Select_Next_Idle_Builder
-- ------------------------------------------------------------------------------------------------------------------
function Select_Next_Idle_Builder(target_position, select_all)

	if not target_position then return end
	
	ButtonClickedTime = GetCurrentTime()
	
	-- Make sure we have builders!.
	local num_builders = #BuildersList
 	if num_builders <= 0 then 
		-- Reset any tracking data.
		SelectedBuilder = nil
		TetherBuilder = nil
		NumberVisited = 0		
		return 
	end
	
	local last_idle_index = Sort_Builders_List()
	
	if not select_all and NumberVisited == num_builders then
		Reset_Visited_States()
		if TestValid(TetherBuilder) then
			target_position = TetherBuilder.Get_Position()
		end
	elseif TestValid(SelectedBuilder) then 
		target_position = SelectedBuilder.Get_Position()
	end
	
 	local min_distance = BIG_FLOAT
 	local builders = {}
	local closest_builder = nil
	local best_idx = -1
	
	-- First search through the idle builders!.
	for id = 1,  last_idle_index do
		local builder_data = BuildersList[id]
 		local builder = builder_data.Object
 		if TestValid(builder) and (select_all == true or (num_builders == 1 or builder ~= SelectedBuilder)) then
			
			if not select_all then  -- cycle through the idle builders
				if (not all_visited and builder_data.Visited == false) or (all_visited and builder_data.Visited == true) then 
					local dist = Vector.distance2(builder.Get_Position(), target_position)
					if dist < min_distance then
						min_distance = dist
						closest_builder = builder
						best_idx = id
					end
				end
			else
				table.insert(builders, builder)				
			end			
		end
  	end
	
	-- If we couldn't find a valid builder to choose, let's go through the non-idle builders!.
	if not select_all and not closest_builder then 
		-- However, we want the non-idle builder closest to the tether builder
		if TestValid(TetherBuilder) then
			target_position = TetherBuilder.Get_Position()
		end
		
		for id = last_idle_index + 1,  num_builders do
			local builder_data = BuildersList[id]
			local builder = builder_data.Object
			if TestValid(builder) and (select_all == true or (num_builders == 1 or builder ~= SelectedBuilder)) then
				
				if not select_all then  -- cycle through the idle builders
					if (not all_visited and builder_data.Visited == false) or (all_visited and builder_data.Visited == true) then 
						local dist = Vector.distance2(builder.Get_Position(), target_position)
						if dist < min_distance then
							min_distance = dist
							closest_builder = builder
							best_idx = id
						end
					end
				else
					table.insert(builders, builder)				
				end			
			end
		end
	end 
 
	if not select_all and TestValid(closest_builder) then 
		table.insert(builders, closest_builder)
		BuildersList[best_idx].Visited = not all_visited
		SelectedBuilder = closest_builder
	else	
		SelectedBuilder = nil
		Reset_Visited_States()
	end
	
	if NumberVisited == 0 then
		TetherBuilder = SelectedBuilder
	end
	
	Script.Set_Async_Data("SelectedBuilder", SelectedBuilder)
	return builders
end 
  
  

