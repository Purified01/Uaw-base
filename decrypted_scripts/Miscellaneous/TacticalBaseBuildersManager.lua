if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[189] = true
LuaGlobalCommandLinks[109] = true
LUA_PREP = true

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
	
 	local min_distance = 1e+018
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
  
  

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Init_Tactical_Base_Builders_Manager = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	PG_Vector_Add = nil
	PG_Vector_Multiply_Scalar = nil
	PG_Vector_Normalize = nil
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
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Builders_List = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
