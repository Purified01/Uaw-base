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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/Player_Common.lua
--
--    Original Author: Maria Teruel
--
--          DateTime: 2007/02/12
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("SuperweaponsControl")
require("TacticalBaseBuildersManager")


-- This script manages all methods that are common to all players.
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Common_Player_Definitions
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Common_Player_Definitions()

	Define_State("State_Init", State_Init);

	EnableTree = true
	CurrentGameMode = nil
	IsTacticalOnlyGame = false
	
	CachedMaximumTacticalResourcesStorage = 0
	
	MAX_RESEARCH_POINTS_STANDARD = 6
	MAX_RESEARCH_POINTS_DEFCON = 12
	
	MAX_RESEARCH_POINTS = MAX_RESEARCH_POINTS_STANDARD
	
	
	Init_Superweapons_Data()
	Init_Tactical_Base_Builders_Manager()
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- State_Init
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function State_Init(message)
	if message == OnEnter then
		
		if EnableTree == true then
			local is_tactical_only_game = ((not Is_Campaign_Game()) or Get_Is_Debug_Load_Map())
			-- Initialize all the Research/Tech Trees for this player!.
			Init_Research_Tree(is_tactical_only_game)
			
			-- Lock/Unlock the proper types according to the player's Packaged Research settings.
			Update_Locked_Objects_List()
			
		else
			Player.Set_Research_Tree_Initialized(true)	
		end
		
		Lock_Lockable_Medal_Effects()
		
		CurrentGameMode = Get_Game_Mode()
		
	elseif message == OnUpdate then
		
		if CurrentGameMode ~= nil and CurrentGameMode ~= Get_Game_Mode() then

			-- if we have changed modes, clear out the research tree (it's no longer persistent)
			-- and flush faction specific tactical state
			Reset_Research_Tree()

			CurrentGameMode = Get_Game_Mode()
		end		
		
		if EnableTree == true then 
			Update_Research_Progress()
		end
		Update_Superweapons_Data()
		
		Update_Builders_List()
		
		Update_Maximum_Tactical_Resources()
		
		if Update_Faction_Specific_Controls and CurrentGameMode ~= "Strategic" then 
			Update_Faction_Specific_Controls()
		end
	end	
end

-------------------------------------------------------------------------------
-- Lock the lockable/unlockable medals on everyone.
-- JLH 07-30-2007, KDB 08-21-2007 needs to be in player to lock properly
-------------------------------------------------------------------------------
function Lock_Lockable_Medal_Effects()

	-- MEDAL LOCK: Nanite Mastery
	Player.Lock_Unit_Ability("Novus_Constructor", "Achievement_Novus_Constructor_Repair_Spray_Ability_Generator", true)
	Player.Lock_Generator("Achievement_Novus_Constructor_Repair_Spray_Effect_Generator", true)

	-- MEDAL LOCK: Gift of the Architect
	Player.Lock_Effect( "Achievement_Masari_Architect_Build_Effect", true )
		
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Debug_Switch_Sides
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Debug_Switch_Sides()
	local game_mode_scene = Get_Game_Mode_GUI_Scene()
	if not game_mode_scene then 
		return 
	end
	
	if NumberPoweredEnablers ~= nil then 
		-- we need to update the UI for the local player only!!!!!.
		game_mode_scene.Raise_Event_Immediate("Update_Patch_Queue_Size", nil, {Player, NumberPoweredEnablers} )
	end
	
	-- Update the tree scenes.
	game_mode_scene.Raise_Event_Immediate("Update_Tree_Scenes", nil, {Player})		
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Debug_Force_Complete - When DebugKeys are enabled, the user can hit the END button to force completion of whatever
-- node is currently being researched in the tree, also, force SW cooldowns to end, etc.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Debug_Force_Complete()
	-- Force the undergoing research to complete
	Process_Research_Complete()
	-- Force the SW to complete their cooldown (if any)
	Force_SW_Cooldown_Complete()
	-- If we have patches, let's force their cooldown to end
	if Reset_Patch_Cooldown then
		Reset_Patch_Cooldown()
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Get_Maximum_Tactical_Resources -- Multiplayer safe player script query.  5/31/2007 10:23:33 AM -- BMH
-- ------------------------------------------------------------------------------------------------------------------
function Get_Maximum_Tactical_Resources()
	return CachedMaximumTacticalResourcesStorage
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Maximum_Tactical_Resources -- Multiplayer safe player script query.  5/31/2007 10:23:33 AM -- BMH
-- ------------------------------------------------------------------------------------------------------------------
function Update_Maximum_Tactical_Resources()

	-- if the player has a cap on raw materials display it.
	CachedMaximumTacticalResourcesStorage = Player.Get_Baseline_Bank_Capacity()

	if MatterEngineOwners == nil then 
	  if CachedMaximumTacticalResourcesStorage > 0 then
			return 
	 	end
		return
	end
	
	local mtable = MatterEngineOwners[Player]
   if mtable == nil then 
		if CachedMaximumTacticalResourcesStorage > 0 then
			return  
	 	end
		return
	end

	for i=1, mtable.Count do
		if TestValid( mtable[i].Object ) then
			local cur_storage = mtable[i].Storage
			local increase = mtable[i].Object.Get_Attribute_Value("Harvest_Material_Storage_Add")
			if increase ~= nil and increase > 0.0 then
				cur_storage = cur_storage * ( 1.0 + increase )
			end
			CachedMaximumTacticalResourcesStorage = CachedMaximumTacticalResourcesStorage + cur_storage
		end
	end

	-- KDB can't change resources here as it will reduce resources we don't want reduced
	--local current_raw_materials = Player.Get_Raw_Materials()
	--if  current_raw_materials > CachedMaximumTacticalResourcesStorage then
	--	Player.Add_Raw_Materials(CachedMaximumTacticalResourcesStorage - current_raw_materials)
	--end

	Script.Set_Async_Data("CachedMaximumTacticalResourcesStorage", CachedMaximumTacticalResourcesStorage)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Check for too many resources (i.e reduce them)
-- ------------------------------------------------------------------------------------------------------------------
function Resource_Overage_Check( amount_added )
	if amount_added <= 0.0 then
		return 0.0
	end
	
	Update_Maximum_Tactical_Resources()
	local max_storage = Get_Maximum_Tactical_Resources()
	if max_storage <= 0.0 then
		-- zero indicates no maximum
		return 0.0
	end
	local current_raw_materials = Player.Get_Raw_Materials()	

	local over_storage = current_raw_materials - max_storage
	
	if over_storage > 0.0 then
		if amount_added < over_storage then
			over_storage = amount_added
		end

		-- reduce amount of cash player has		
		Player.Add_Raw_Materials(-over_storage)
		
	else
		over_storage = 0.0
	end
	
	return over_storage
	
end

function Player_Reset_Faction_Specific_Controls()
	if Reset_Faction_Specific_Controls then
		Reset_Faction_Specific_Controls()
	end
end
