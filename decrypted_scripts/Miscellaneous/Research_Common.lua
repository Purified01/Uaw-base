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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/Novus_Packaged_Research_Tree.lua 
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/10/05 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
	

require("PGAchievementAward")
require("PGOnlineAchievementDefs")
	
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init_Research_Common
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Research_Common(tactical_only_game)

	IsTacticalOnlyGame = tactical_only_game
	
	IsDEFCONMode = Initialize_DEFCON()
	if (ResearchTimeModifier == nil) then
		ResearchTimeModifier = 1	 
	end
	
	if ResearchFacilitiesCount == nil then
		ResearchFacilitiesCount = 0
	end
	
	PlayerTypesListInitialized = false
	ResearchOrderList = {} -- this table will contain the direction and index of the suites as they are being researched
	SuitesBeingResearched = {}
	
	NUMBER_OF_SUITES_PER_PATH = 4
	CurrentDEFCONLevel = 0
	
	Init_Suite_Number_To_Suite_Text_Map()	
	Init_Type_To_Tree_Location_Map()
	
	BlockedResearch = {}
	BlockedResearch["A"] = false
	BlockedResearch["B"] = false
	BlockedResearch["C"] = false
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init_Suite_Number_To_Suite_Text_Map
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Suite_Number_To_Suite_Text_Map()
	if not SuiteNumberToSuiteText then
		SuiteNumberToSuiteText = {}
	end
	
	SuiteNumberToSuiteText[1] = Get_Game_Text("TEXT_RESEARCH_SUITE_1")
	SuiteNumberToSuiteText[2] = Get_Game_Text("TEXT_RESEARCH_SUITE_2")
	SuiteNumberToSuiteText[3] = Get_Game_Text("TEXT_RESEARCH_SUITE_3")
	SuiteNumberToSuiteText[4] = Get_Game_Text("TEXT_RESEARCH_SUITE_4")
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ResearchTimeModifier
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Research_Time_Modifier(value)
	ResearchTimeModifier = value
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set_Current_DEFCON_Level
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Current_DEFCON_Level(defcon_lvl)
	CurrentDEFCONLevel = defcon_lvl
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_DEFCON
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Initialize_DEFCON()

	-- Maria 07.25.2007: This time needs to be a TINY bit smaller than the real DEFCON_COUNTDOWN.
	-- In fact, we need this to be so because we have to make sure the undergoing research is completed before the
	-- new research is started.  If we set both values to be the same, the new research will be started before the 
	-- previous DEFCON level's research is completed.(when modifying this value make sure you modify its equivalent
	-- in Research_Common.lua)
	-- ALWAYS MAKE IT 0.5 SECONDS LESS THAN THE REGULAR COUNTDOWN TO ENSURE RESEARCH
	-- FROM THE LAST DEFCON LEVEL IS COMPLETED BEFORE THE NEW ONE STARTS!!!!!.
	DEFCON_COUNTDOWN = 119.5 -- In seconds
	
	Register_Game_Scoring_Commands()
	-- Is DEFCON enabled from the multiplayer lobby?
	local script_data = GameScoringManager.Get_Game_Script_Data_Table()
	if script_data and script_data.is_defcon_game then
		return true
	end
	
	return false
	
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init_Type_To_Tree_Location_Map
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Type_To_Tree_Location_Map()
	
	TypeToTreeLocationMap = {}
	
	if PathToBranchMap then
	
		for _, res_path in pairs(PathToBranchMap) do
		
			local path_string = Create_Wide_String("")
			path_string.append(Branches[res_path].Name)
			
			for _, suite in pairs(res_path) do			
				
				if table.getn(suite.UnlocksTypes) ~= 0 then
					for _, obj_type_data in pairs(suite.UnlocksTypes) do
						if obj_type_data.ObjectType then
							local this_suite_text = Create_Wide_String("")
							this_suite_text.append(path_string)
							this_suite_text.append(Create_Wide_String(", "))
							this_suite_text.append(SuiteNumberToSuiteText[suite.Index])
							TypeToTreeLocationMap[obj_type_data.ObjectType] = this_suite_text
						end
					end
				end	
				
				if suite.UnlocksPatches and table.getn(suite.UnlocksPatches) ~= 0 then
					for _, patch_data in pairs(suite.UnlocksPatches) do
						if patch_data.ObjectType then
							local this_suite_text = Create_Wide_String("")
							this_suite_text.append(path_string)
							this_suite_text.append(Create_Wide_String(", "))
							this_suite_text.append(SuiteNumberToSuiteText[suite.Index])
							TypeToTreeLocationMap[patch_data.ObjectType] = this_suite_text
						end
					end				
				end				
			end	
		end
		
	end

	Script.Set_Async_Data("TypeToTreeLocationMap", TypeToTreeLocationMap)
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Retrieve_Branch_Textures
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Retrieve_Branch_Textures()
	local out_table = {}
	table.insert(out_table, Branches["A"].Icon)
	table.insert(out_table, Branches["B"].Icon)
	table.insert(out_table, Branches["C"].Icon)
	return out_table
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Retrieve_Tree_Data - This function is invoked to initialize the research tree scene - The only information the scene needs is: List of nodes that
-- are available (enabled/completed).  For each of those nodes the info needed is: List of types/abilities/etc to lock/unlock, the location of the node
--  (i.e., direction and suite index), 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Retrieve_Tree_Data()
	if not PathToBranchMap then return end
	
	local ans = {}
	if PathToBranchMap["A"] then ans = Retrieve_Branch_Data(PathToBranchMap["A"], ans) end
	if PathToBranchMap["B"] then ans = Retrieve_Branch_Data(PathToBranchMap["B"], ans) end
	if PathToBranchMap["C"] then ans = Retrieve_Branch_Data(PathToBranchMap["C"], ans) end
	
	return ans
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Retrieve_Branch_Data
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Retrieve_Branch_Data(branch, out_table)

	local branch_name
	for _, suite in pairs(branch) do
		local suite_texture
		
		if suite.Completed == true then
			suite_texture = suite.TextureMap[2]
		else
			suite_texture = suite.TextureMap[1]			
		end
		
		local research_time = Apply_Research_Time_Modifiers(suite.TotalResearchTime)
		local research_cost = suite.ResearchCost
		
		if branch_name == nil then 
			branch_name = Branches[suite.Path].Name
		end
		
		local suite_name = Create_Wide_String("")
		suite_name.append(branch_name)
		suite_name.append(Create_Wide_String(": "))
		suite_name.append(Get_Game_Text("TEXT_RESEARCH_SUITE_"..suite.Index))

		local unlock_gens = {}
		local unlock_pats = {}
		local unlock_effs = {}
		local lock_gens = {}

		if suite.UnlocksGenerators ~= nil then
			unlock_gens = suite.UnlocksGenerators
		end

		if suite.UnlocksPatches ~= nil then 
			unlock_pats = suite.UnlocksPatches
		end
		
		if suite.UnlocksEffects ~= nil then 
			unlock_effs = suite.UnlocksEffects
		end
		
		if suite.LocksGenerators ~= nil then 
			lock_gens = suite.LocksGenerators
		end
		
		local entry = 
		{
			suite.Path,
			suite.Index, 
			suite.Enabled, 
			suite.Completed,
			
			-- Types
			suite.UnlocksTypes,
			
			-- Unit abilities
			suite.UnlocksUnitAbilities,
			
			-- Special Abilities
			suite.UnlocksSpecialAbilities,
			
			-- Generators to unlock
			unlock_gens,
			
			-- Effects 
			unlock_effs,
			
			-- Generators to lock
			lock_gens,
			
			-- Patches
			unlock_pats,
			
			suite.StartResearchTime,
			research_time,
			suite_texture,
			suite_name,
			research_cost
		}
		
		--EMP 7/24/07
		--Added so that the research tree can go to sleep and the button can still update
		if suite.StartResearchTime ~= -1 then
			if IsDEFCONMode then 
				Script.Set_Async_Data("ResearchTotalTime", DEFCON_COUNTDOWN)
			else
				Script.Set_Async_Data("ResearchTotalTime", research_time)
			end
			Script.Set_Async_Data("ResearchStartTime", suite.StartResearchTime)
		end	
		table.insert(out_table, entry)		
	end	
	
	return out_table
end

-- -----------------------------------------
-- JSY 11.3.2006
-- Retrieve_Node_Data
-- -----------------------------------------
function Retrieve_Node_Data(path, node_index)
	local branch_table = PathToBranchMap[path]
	local suite_name = "Suite"..node_index
	return branch_table[suite_name]
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.07.2006
-- Update_Locked_Objects_List
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Locked_Objects_List()
	
	-- NOTE: those types that are not available are set to disabled instead of locked so that we can grey out their buttons!
	-- (otherwise they won't be given as part of the list of buildable types!)
	for _, res_path in pairs(PathToBranchMap) do
		if res_path ~= nil then 
		
			local suite_table = {}
		
			for _, suite in pairs(res_path) do 
				suite_table[suite.Index] = suite
			end
			
			for index=1, table.getn(suite_table), 1 do
				local temp_suite = suite_table[ index ]
				
				if temp_suite.Completed == true then 
					if table.getn(temp_suite.UnlocksTypes) ~= 0 then
						Lock_Types(temp_suite.UnlocksTypes, false)
					end
					
					-- Unlock UNIT Abilities
					if table.getn(temp_suite.UnlocksUnitAbilities) ~= 0 then
						Lock_Unit_Abilities(temp_suite.UnlocksUnitAbilities, false)
					end
					
					-- Lock UNIT Abilities
					if table.getn(temp_suite.LocksUnitAbilities) ~= 0 then
						Lock_Unit_Abilities(temp_suite.LocksUnitAbilities, true)
					end
					
					-- Unlock SPECIAL Abilities
					if table.getn(temp_suite.UnlocksSpecialAbilities) ~= 0 then 
						Lock_Special_Abilities(temp_suite.UnlocksSpecialAbilities, false)
					end
					
					-- Lock SPECIAL Abilities
					if table.getn(temp_suite.LocksSpecialAbilities) ~= 0 then 
						Lock_Special_Abilities(temp_suite.LocksSpecialAbilities, true)
					end
					
					-- Unlock EFFECT Generators
					if temp_suite.UnlocksGenerators ~= nil and table.getn(temp_suite.UnlocksGenerators) ~= 0 then 
						Lock_Generators(temp_suite.UnlocksGenerators, false)
					end
					
					-- lock EFFECT Generators
					if temp_suite.LocksGenerators ~= nil and table.getn(temp_suite.LocksGenerators) ~= 0 then 
						Lock_Generators( temp_suite.LocksGenerators, true )
					end

					-- Unlock EFFECTs
					if temp_suite.UnlocksEffects ~= nil and table.getn(temp_suite.UnlocksEffects) ~= 0 then 
						Lock_Effects(temp_suite.UnlocksEffects, false)
					end
					
					-- lock EFFECTs
					if temp_suite.LocksEffects ~= nil and table.getn(temp_suite.LocksEffects) ~= 0 then 
						Lock_Effects( temp_suite.LocksEffects, true )
					end
					
					-- Unlock PATCHES
					if temp_suite.UnlocksPatches and table.getn(temp_suite.UnlocksPatches) ~= 0 then 
						Lock_Types(temp_suite.UnlocksPatches, false)
					end

					-- special items
					if temp_suite.ElementalModeModifer ~= nil then
						Player.Add_To_Elemental_Mode_Speed_Modifer( temp_suite.ElementalModeModifer )
					end
					
					
				else -- not enabled
					if table.getn(temp_suite.UnlocksTypes) ~= 0 then
						Lock_Types(temp_suite.UnlocksTypes, true)		
					end
					
					-- TODO:
					-- Lock UNIT Abilities
					if table.getn(temp_suite.UnlocksUnitAbilities) ~= 0 then
						Lock_Unit_Abilities(temp_suite.UnlocksUnitAbilities, true)
					end
					
					-- Unlock UNIT Abilities
					if table.getn(temp_suite.LocksUnitAbilities) ~= 0 then
						Lock_Unit_Abilities(temp_suite.LocksUnitAbilities, false)
					end
					
					-- Lock SPECIAL Abilities
					if table.getn(temp_suite.UnlocksSpecialAbilities) ~= 0 then 
						Lock_Special_Abilities(temp_suite.UnlocksSpecialAbilities, true)
					end
					
					-- Unlock SPECIAL Abilities
					if table.getn(temp_suite.LocksSpecialAbilities) ~= 0 then 
						Lock_Special_Abilities(temp_suite.LocksSpecialAbilities, false)
					end
					
					-- Unlock EFFECT Generators
					if temp_suite.UnlocksGenerators ~= nil and table.getn(temp_suite.UnlocksGenerators) ~= 0 then 
						Lock_Generators(temp_suite.UnlocksGenerators, true )
					end
					
					-- lock EFFECT Generators
					if temp_suite.LocksGenerators ~= nil and table.getn(temp_suite.LocksGenerators) ~= 0 then 
						Lock_Generators( temp_suite.LocksGenerators, false )
					end

					-- Unlock EFFECTs
					if temp_suite.UnlocksEffects ~= nil and table.getn(temp_suite.UnlocksEffects) ~= 0 then 
						Lock_Effects(temp_suite.UnlocksEffects, true )
					end
					
					-- lock EFFECTs
					if temp_suite.LocksEffects ~= nil and table.getn(temp_suite.LocksEffects) ~= 0 then 
						Lock_Effects( temp_suite.LocksEffects, false )
					end
					
					-- Lock PATCHES
					if temp_suite.UnlocksPatches and table.getn(temp_suite.UnlocksPatches) ~= 0 then 
						Lock_Types(temp_suite.UnlocksPatches, true)
					end
					
				end
			end
		end
	end
	
	if Player.Is_Build_Types_List_Initialized() == false then
		Player.Set_Research_Tree_Initialized(true)
		PlayerTypesListInitialized = true
	end
	
	Update_Nodes_State()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lock_Effects
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Lock_Effects(effects_table, lock_unlock)
	for _, effect_params in pairs(effects_table) do
		local effect_name = effect_params.EffectName
		if effect_params.EffectName and Player.Is_Effect_Locked(effect_params.EffectName) ~= lock_unlock then
			Player.Lock_Effect(effect_params.EffectName, lock_unlock)
		end
		
		-- KDB required for linked locking unlocking Note has to be outside the check as this is called by other branches
		-- used for locking effects that are lower in the tech tree that were unlocked by research
		if effect_name and effect_params.LockThisEffect ~= nil and not lock_unlock and not Player.Is_Effect_Locked(effect_params.EffectName) then 
			Player.Lock_Effect( effect_params.LockThisEffect, true )
		end
		
	end
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lock_Generators
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Lock_Generators(effects_table, lock_unlock)
	for _, effect_params in pairs(effects_table) do
		local effect_name = effect_params.EffectName
		if effect_params.EffectName and Player.Is_Generator_Locked(effect_params.EffectName) ~= lock_unlock then
			Player.Lock_Generator(effect_params.EffectName, lock_unlock)			
		end
		
		-- KDB required for linked locking unlocking Note has to be outside the check as this is called by other branches
		-- used for locking generators that are lower in the tech tree that were unlocked by research
		if effect_name and not lock_unlock and effect_params.LockThisGenerator ~= nil and not Player.Is_Generator_Locked( effect_params.LockThisGenerator ) then 
			Player.Lock_Generator( effect_params.LockThisGenerator, true )
		end
		
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lock_Unit_Abilities
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Lock_Unit_Abilities(abilities_table, lock_unlock)

	-- For unlocking, unit abilities are defined as sub-tables with various descriptive entries.
	-- For locking, unit abilities may simply be a table of strings.
	-- Let's handle both cases.
	if abilities_table[1] ~= nil and abilities_table[1].TypeName and abilities_table[1].AbilityName ~= nil then
		-- Sub-tables with entries method.
		for _, ab_params in pairs(abilities_table) do
			if Player.Is_Unit_Ability_Locked(ab_params.AbilityName, RESEARCH) ~= lock_unlock then
				Player.Lock_Unit_Ability(ab_params.TypeName, ab_params.AbilityName, lock_unlock, RESEARCH)
			end
		end
	elseif abilities_table[1] ~= nil and abilities_table[1].TypeName then
		-- Straight table of strings method.
		for _, ab_name in pairs(abilities_table) do
			if Player.Is_Unit_Ability_Locked(ab_name, RESEARCH) ~= lock_unlock then
				Player.Lock_Unit_Ability(ab_params.TypeName, ab_name, lock_unlock, RESEARCH)
			end
		end
	else
		MessageBox("Aborting: invalid data -> The syntax for LocksUnitAbilities and UnlocksUnitAbilities tables has changed so make sure your addition complies with the new style!!!!. THANKS!")
	end
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lock_Special_Abilities
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Lock_Special_Abilities(special_abilities_table, lock_unlock)

	-- Special abilities are always defined as sub-tables, but they may contain either named
	-- entries or unnamed entries. Handle both cases until we're converted over to the named
	-- entries method.
	if special_abilities_table[1] ~= nil and special_abilities_table[1].AbilityName ~= nil then
		-- Named entries method.
		for _, sab_params in pairs(special_abilities_table) do
			if Player.Get_Special_Ability_Type_Lock(sab_params.ObjectType, sab_params.AbilityName) ~= lock_unlock then
				Player.Set_Special_Ability_Type_Lock(sab_params.ObjectType, sab_params.AbilityName, lock_unlock)
			end
		end
	else
		-- Unnamed entries method.
		for _, sab_data in pairs(special_abilities_table) do
			local obj_type = sab_data[1]
			local ab_name = sab_data[2]
			
			if Player.Get_Special_Ability_Type_Lock(obj_type, ab_name) ~= lock_unlock then
				Player.Set_Special_Ability_Type_Lock(obj_type, ab_name, lock_unlock)
			end	
		end
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.09.2006
-- Lock_Types
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Lock_Types(types_table, lock_unlock)
	for _, type_params in pairs(types_table) do
		if not PlayerTypesListInitialized or Player.Is_Object_Type_Locked(type_params.ObjectType, RESEARCH) ~= lock_unlock then
			if type_params.ObjectType == nil then 
				MessageBox("%s -- OjectType associated with TextID: %s in research tree is NIL!!", tostring(Script), type_params.DescriptionTextID)
			else
				Player.Lock_Object_Type(type_params.ObjectType, lock_unlock, RESEARCH)
			end
		end
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Cancel_Research -- Process the start of research by updating the proper node's info!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Cancel_Research(node_info)
	-- node_info[1] = path, node_info[2] = node index

	if node_info ~= nil  then
		
		local path = node_info[1]
		local node_index = node_info[2]
		
		if node_index == nil then
			MessageBox("Invalid node index:  nil")
			return
		end
		
		local dir_table = PathToBranchMap[path]
		local suite_name = "Suite"..node_index
		local node = dir_table[suite_name]
		
		-- NOTE: there are 2 different cases to consider
		-- CASE 1: The player wants to cancel research under way
		-- CASE 2: The player wants to undo completed research (thus he will lose all that was granted to him by researching this suite)
		if node.Completed == true then
			-- CASE 2
			-- Research can be undone only it the suite is the top most suite on its path.
			if node.Index ~= NUMBER_OF_SUITES_PER_PATH then	
				local nxt_suite_idx = node.Index + 1
				suite_name = "Suite"..nxt_suite_idx
				local nxt_node = dir_table[suite_name]
				
				if not nxt_node or nxt_node.Completed == true or nxt_node.StartResearchTime ~= -1 then
					-- we cannot undo the research for the specified node!.
					return
				end
			end		

			-- Go ahead and undo the research for this node.
			Undo_Research_For_Suite(node.Path, node.Index)	
						
		elseif node.StartResearchTime ~= -1 then
			-- CASE 1: The player wants to cancel research under way
			-- make sure the suite to be cancelled coincides with the one under research
			local found_suite = false
			for idx = 1, #SuitesBeingResearched do
				local suite = SuitesBeingResearched[idx]
				if suite and not suite.DeletePending and suite.Path == node.Path and suite.Index == node.Index then
					node.StartResearchTime = -1
					node.Enabled = false
					
					if not IsDEFCONMode then 
						-- we must refund the player the money paid for the research of this suite!
						Player.Add_Credits(node.ResearchCost)
					end	
					
					-- just go ahead and cancel research
					table.remove(SuitesBeingResearched, idx)
					found_suite = true
				end	
				Raise_Game_Event("Research_Cancel", Player, nil, nil)				
			end
			
			if not found_suite then
				MessageBox("????? there is more than one suite under research!?!?!?!?!?")
				return
			end
		else 
			-- invalid situation, do nothing
			return
		end
		
		Update_Nodes_State()
		
		local game_mode_scene = Get_Game_Mode_GUI_Scene()
		if game_mode_scene then
			game_mode_scene.Raise_Event_Immediate("Update_Tree_Scenes", nil, {Player})
			game_mode_scene.Raise_Event("Research_Canceled", nil, {Player}) --EMP 7/24/07
		end	
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Start_Research -- Process the start of research by updating the proper node's info!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Start_Research(node_info)
	-- node_info[1] = path, node_info[2] = node index

	if node_info ~= nil  then
		
		local path = node_info[1]
		local node_index = node_info[2]
		
		if node_index == nil then
			MessageBox("Invalid node index:  nil")
			return
		end
		
		local dir_table = PathToBranchMap[path]
		local suite_name = "Suite"..node_index
		local node = dir_table[suite_name]
		
		if node.Completed == true then
			-- this node has already been researched, do nothing
			return			
		elseif node.StartResearchTime == -1 then
			-- CASE 1: The player wants to start research on this node
			-- If not in DEFCON mode, we can only start research if there's no research underway
			-- If in DEFCON mode, we can only start research if it is along the same level as the current DEFCON level
			
			if Get_Active_Research_Count() > 0 then 
				if not IsDEFCONMode then
					-- there's research under way so we cannot start new research
					return
				elseif node_index ~= CurrentDEFCONLevel then
					return
				end				
			end
			
			if (IsDEFCONMode == false) then 
				-- JSY: don't charge AI players - they'll charge themselves.
				if not Player.Is_AI_Player() then
					-- we must make sure the player has enough money to pay for the research of this node.
					local cost = node.ResearchCost
					local money = Player.Get_Credits()
					if node.ResearchCost > money then 
						--Oksana: notify game event system of this event
						Raise_Game_Event("Research_Funds", Player)
						return
					end
					
					-- go ahead and deduct the research cost from the player's credits.
					Player.Add_Credits(-node.ResearchCost)
				end
			end
			
			node.Enabled = true
			-- We are in the clear, go ahead and start the research for this node.
			node.StartResearchTime = GetCurrentTime.Frame()
			table.insert(SuitesBeingResearched, node)
			
			if not IsDEFCONMode then
				-- Notify the player that research is underway.
				Raise_Game_Event("Research_Start", Player)
			end
		else
			-- invalid situation, do nothing
			return
		end
		
		Update_Nodes_State()
		Get_Game_Mode_GUI_Scene().Raise_Event("Research_Started", nil, {Player} )  --EMP 7/24/07
	end
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Undo_Research_For_Suite - Undo the research for a suite whose research has already been completed!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Undo_Research_For_Suite(suite_path, suite_index)
	
	if suite_path == nil or suite_index == nil then
		return
	end
	
	local found = false
	local list_index = -1
	for idx = 1, table.getn(ResearchOrderList) do
		local suite_loc = ResearchOrderList[idx]
		if suite_loc[1] == suite_path and suite_loc[2] == suite_index then
			found = true
			list_index = idx
			break
		end
	end
	
	if found == true then
		table.remove(ResearchOrderList, list_index)
		
		local dir_table = PathToBranchMap[suite_path]
		local suite_name = "Suite"..suite_index
		local node = dir_table[suite_name]
		
		-- Reset the state of the node
		node.Enabled = false
		node.Completed = false
		node.StartResearchTime = -1
		
		Update_Locked_Objects_List()
		Raise_Game_Event("Research_Undo", Player, nil, nil)
		
	else
		MessageBox("Undo_Research_For_Suite: The suite with path = %s and Index = %s does not belong to the list", suite_loc[1], suite_loc[2])
	end
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Research_Progress
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Research_Progress()
	if #SuitesBeingResearched > 0 then
		local indeces_complete = nil
		for idx = 1, #SuitesBeingResearched do
			local suite = SuitesBeingResearched[idx]
			if suite then
				local total_research_time = Apply_Research_Time_Modifiers(suite.TotalResearchTime)
				if (IsDEFCONMode) then
					total_research_time = DEFCON_COUNTDOWN
				end
				
				if suite.StartResearchTime + total_research_time <= GetCurrentTime.Frame() then
					if not indeces_complete then 
						indeces_complete = {}
					end
					table.insert(indeces_complete, idx)
					suite.DeletePending = true
					
					-- research for this node is complete.
					Research_Complete(idx)
				end
			end
		end
		
		if indeces_complete then
			for _, index_val in pairs(indeces_complete) do
				local suite = SuitesBeingResearched[index_val]
				-- reset the delete pending state!
				if suite then 
					suite.DeletePending = false
				end
				table.remove(SuitesBeingResearched, index_val)
			end
		end		
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get_Active_Research_Count 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Get_Active_Research_Count()
	local count = 0
	if SuitesBeingResearched then
		for _, suite in pairs(SuitesBeingResearched) do
			if not suite.DeletePending then 
				count = count + 1
			end
		end
	end
	return count
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Research_Complete 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Research_Complete(suite_being_researched_idx)
	
	if suite_being_researched_idx and suite_being_researched_idx > #SuitesBeingResearched then
		return
	end
	
	local suite = SuitesBeingResearched[suite_being_researched_idx]
	if suite then 
		Research_Complete_Node(suite.Path, suite.Index)	
		
		-- if we are in DEFCON mode let's not broadcast this for we will be notified of DEFCON advancement which
		-- implies tech advancement
		-- Oksana: notify player of completed research
		if not IsDEFCONMode then 
			Raise_Game_Event("Research_Completed", Player)		
		end

		--Oksana: notify achievement system
		local scoring_script = Get_Game_Scoring_Script()
		if (scoring_script ~= nil) then 
			scoring_script.Call_Function("Notify_Achievement_System_Of_Research_Completed", Player, suite.Path )
		end
		
		-- Maria 05.29.2007 - We want the research icon to flash for a while after the research has been completed.
		Get_Game_Mode_GUI_Scene().Raise_Event("Research_Complete", nil, {Player})
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Process_Research_Complete 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Process_Research_Complete()
	-- we want to complete all the research under way.
	local indeces_complete = nil
	for idx = #SuitesBeingResearched, 1, -1 do
		local suite = SuitesBeingResearched[idx]
		if not indeces_complete then 
			indeces_complete = {}
		end
		
		table.insert(indeces_complete, idx)
		suite.DeletePending = true
		Research_Complete(idx)
	end	
	
	if indeces_complete then
		for _, index_val in pairs(indeces_complete) do
			local suite = SuitesBeingResearched[index_val]
			-- reset the delete pending state!
			if suite then 
				suite.DeletePending = false
			end
			table.remove(SuitesBeingResearched, index_val)
		end
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Research_Complete_Node 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Research_Complete_Node(node_path, node_index)
	local node = PathToBranchMap[node_path]["Suite"..node_index]
	node.Enabled = true
	node.Completed = true
	node.StartResearchTime = -1
	table.insert(ResearchOrderList, {node.Path, node.Index})
	Update_Locked_Objects_List()	
end



-- -------------------------------------------------------------------------------------------------------------------------
-- Get_Research_List_Tail
-- -------------------------------------------------------------------------------------------------------------------------
function Get_Research_List_Tail()
	local num_elts = table.getn(ResearchOrderList)
	
	if num_elts == 0 then
		return nil
	end
	
	return ResearchOrderList[num_elts]
end


-- -------------------------------------------------------------------------------------------------------------------------
-- Research_Facility_Removed
-- -------------------------------------------------------------------------------------------------------------------------
function Research_Facility_Removed()
	
	--  For M11 we do not require research facilities for research in tactical only games!
	if ((IsTacticalOnlyGame == true) and (IsDEFCONMode == false)) then 
		return
	end
	
	if ResearchFacilitiesCount > 0 then
		ResearchFacilitiesCount = ResearchFacilitiesCount - 1
		Update_Nodes_State()
	end
end


-- -------------------------------------------------------------------------------------------------------------------------
-- Research_Facility_Added
-- -------------------------------------------------------------------------------------------------------------------------
function Research_Facility_Added()

	--  For M11 we do not require research facilities for research in tactical only games!
	if ((IsTacticalOnlyGame == true) and (IsDEFCONMode == false)) then 
		return
	end
	
	ResearchFacilitiesCount = ResearchFacilitiesCount + 1
	Update_Nodes_State()
end



-- -------------------------------------------------------------------------------------------------------------------------
-- Update_Nodes_State - set the proper ones to enabled,let the tree scene know of this change so that it
-- updates its state!.
-- -------------------------------------------------------------------------------------------------------------------------
function Update_Nodes_State()

	-- If we are not yet initialized bail out!.
	if not ResearchOrderList then 
		return 
	end
	
	local active_research = Get_Active_Research_Count()
	
	if IsTacticalOnlyGame  and ( ResearchFacilitiesCount == nil or ResearchFacilitiesCount == 0 ) then
		ResearchFacilitiesCount = 12 -- this allows us to advance research all suites in the tree as long as there's no research under way!
	end
	
	local active_and_completed_research_count = table.getn(ResearchOrderList) + active_research
	
	--Cap research points
	local research_points = ResearchFacilitiesCount
	-- Maria: In DEFCON mode we want to research all the suites!.
	if not IsDEFCONMode and research_points > MAX_RESEARCH_POINTS then
		research_points = MAX_RESEARCH_POINTS
	elseif IsDEFCONMode and research_points > MAX_RESEARCH_POINTS_DEFCON then
		research_points = MAX_RESEARCH_POINTS_DEFCON
	end
	
	if research_points > active_and_completed_research_count then
		-- If there's a whole tier enabled waiting for the player to choose which suite to start research on, then do nothing
		-- until the player completes research on whichever suite he decides.  Else, enable the next available tier so that the
		-- player can choose.
		-- if there's research under way, wait until it's over to enable the next tier, if any
		if active_research > 0 then
			Enable_Top_Most_Tier(false)
		else
			Enable_Top_Most_Tier(true)
		end
		
	elseif research_points == active_and_completed_research_count then
		-- If there's a whole tier enabled waiting for the player to choose which suite to start research on, then 
		-- disable all those buttons for he has not enough facilities to support their research.  Else, do nothing
		Enable_Top_Most_Tier(false)	
	else
		if IsTacticalOnlyGame then 
			MessageBox("OOOPS! ... should not be here! ... See Maria.")
			return
		end
		
		-- There are not enough research facilities to support the current number of enabled suites then:
		-- First disable any tier that has been enabled and is waiting on the player to make a research decision
		-- Start UNDOING research from nodes in the ResearchOrderList (top first) until the number of Researched Suites Count
		-- equals the research_points.
		Enable_Top_Most_Tier(false)	
		
		if active_research > 0 then
			local curr_idx = #SuitesBeingResearched
			while curr_idx > 0 and active_and_completed_research_count > research_points do
				-- cancel the latest started research
				local suite = SuitesBeingResearched[curr_idx]
				if suite and not suite.DeletePending then 					
					-- Cancel research
					local node = PathToBranchMap[suite.Path]["Suite"..suite.Index]
					if node ~= nil then 
						node.Enabled = false
						node.StartResearchTime = -1
					end
					table.remove(SuitesBeingResearched,curr_idx) 
					active_and_completed_research_count = active_and_completed_research_count - 1
					
					curr_idx = #SuitesBeingResearched
				end
			end			
		end
		
		while active_and_completed_research_count > research_points do
			-- Undo research (starting at the latest) until the number of active and completed research equals that 
			-- of the research facilities for this player.
			local node_to_cancel = Get_Research_List_Tail()
			-- Go ahead and undo the research for this node.
			Undo_Research_For_Suite(node_to_cancel[1], node_to_cancel[2])	
			active_and_completed_research_count = table.getn(ResearchOrderList)
		end	
	end
	
	local CachedTreeDataForGUI = Retrieve_Tree_Data()
	local CachedBranchTexturesForGUI = Retrieve_Branch_Textures()
	local CachedPointsDataForGUI = {}
	CachedPointsDataForGUI[0] = active_and_completed_research_count
	CachedPointsDataForGUI[1] = research_points
	CachedPointsDataForGUI[2] = MAX_RESEARCH_POINTS
	
	Script.Set_Async_Data("CachedBranchTexturesForGUI", CachedBranchTexturesForGUI)
	Script.Set_Async_Data("CachedTreeDataForGUI", CachedTreeDataForGUI)
	Script.Set_Async_Data("CachedPointsDataForGUI", CachedPointsDataForGUI)
	
	local game_mode_scene = Get_Game_Mode_GUI_Scene()
	if game_mode_scene then
		game_mode_scene.Raise_Event_Immediate("Update_Tree_Scenes", nil, {Player})
	end	
end

-- -------------------------------------------------------------------------------------------------------------------------
-- Block_Research_Branch
-- -------------------------------------------------------------------------------------------------------------------------

function Block_Research_Branch( group, on_off_group, refresh )

	BlockedResearch[group] = on_off_group
	
	if refresh then
		Update_Nodes_State()
		
		local game_mode_scene = Get_Game_Mode_GUI_Scene()
		if game_mode_scene then
			game_mode_scene.Raise_Event_Immediate("Update_Tree_Scenes", nil, {Player})
		end
		
	end

end

-- -------------------------------------------------------------------------------------------------------------------------
-- Research_Facility_Added
-- -------------------------------------------------------------------------------------------------------------------------
function Enable_Top_Most_Tier(onoff)
	
	local suite_name
	local node = nil
	for node_index = 1, 4 do
		suite_name = "Suite"..node_index
		node = PathToBranchMap["A"][suite_name]
		
		if node.Completed == false and node.StartResearchTime == -1 then -- i.e. is not under research
			if BlockedResearch[node.Path] then
				node.Enabled = false
			else
				node.Enabled = onoff
			end
			
			if onoff == true then -- make sure the higher tiers are disabled!
				for i = node_index + 1, 4 do
					PathToBranchMap["A"]["Suite"..i].Enabled = false
				end
			end
			
			break			
		end
	end
	
	for node_index = 1, 4 do
		suite_name = "Suite"..node_index
		node = PathToBranchMap["B"][suite_name]
		
		if node.Completed == false and node.StartResearchTime == -1 then -- i.e. is not under research
			if BlockedResearch[node.Path] then
				node.Enabled = false
			else
				node.Enabled = onoff
			end
			
			if onoff == true then -- make sure the higher tiers are disabled!
				for i = node_index + 1, 4 do
					PathToBranchMap["B"]["Suite"..i].Enabled = false
				end
			end
			
			break
		end
	end
	
	for node_index = 1, 4 do
		suite_name = "Suite"..node_index
		node = PathToBranchMap["C"][suite_name]
		
		if node.Completed == false and node.StartResearchTime == -1 then -- i.e. is not under research
			if BlockedResearch[node.Path] then
				node.Enabled = false
			else
				node.Enabled = onoff
			end
			
			if onoff == true then -- make sure the higher tiers are disabled!
				for i = node_index + 1, 4 do
					PathToBranchMap["C"]["Suite"..i].Enabled = false
				end
			end
			
			break
		end
	end
end

-- -------------------------------------------------------------------------------------------------------------------------
-- Reset_Research_Tree
-- -------------------------------------------------------------------------------------------------------------------------
function Reset_Research_Tree()

	local node_to_cancel = Get_Research_List_Tail()
	while node_to_cancel ~= nil do
		-- Undo all research (starting at the latest).  Doing it in this fashion ensures that
		-- the undo happens in the proper order and doesn't skip any nodes.
		Undo_Research_For_Suite(node_to_cancel[1], node_to_cancel[2])	
		node_to_cancel = Get_Research_List_Tail()
	end	
	
	Init_Research_Tree(IsTacticalOnlyGame)
	Update_Nodes_State()
end

-- -------------------------------------------------------------------------------------------------------------------------
-- Apply_Research_Time_Modifiers
-- -------------------------------------------------------------------------------------------------------------------------
function Apply_Research_Time_Modifiers(original_time)

	original_time = original_time * ResearchTimeModifier

	--Discount research time when fighting at a location that has a research structure
	if not Is_Campaign_Game() then
		return original_time
	end
	
	local region = Get_Conflict_Location()
	if not TestValid(region) then
		return original_time
	end
	
	local command_center = region.Get_Command_Center()
	if not TestValid(command_center) then
		return original_time
	end
	
	if command_center.Get_Type().Get_Type_Value("Enables_Research") then
		return original_time * 0.75
	else
		return original_time
	end
end


-- -------------------------------------------------------------------------------------------------------------------------
-- Pre_Save_Callback
-- -------------------------------------------------------------------------------------------------------------------------
function Pre_Save_Callback()
	Script.Set_Async_Data("CachedTreeDataForGUI", nil)
end


-- -------------------------------------------------------------------------------------------------------------------------
-- Post_Save_Callback
-- -------------------------------------------------------------------------------------------------------------------------
function Post_Save_Callback()
	Update_Nodes_State()
end


-- -------------------------------------------------------------------------------------------------------------------------
-- Post_Load_Callback
-- -------------------------------------------------------------------------------------------------------------------------
function Post_Load_Callback()
	Initialize_Branch_Data()
	Init_Suite_Number_To_Suite_Text_Map()
	Init_Type_To_Tree_Location_Map()
	Update_Nodes_State()
end
