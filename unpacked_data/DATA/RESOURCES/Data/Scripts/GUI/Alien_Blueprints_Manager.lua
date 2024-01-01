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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Alien_Blueprints_Manager.lua
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/07/05 11:33:19
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Blueprints_Manager - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Blueprints_Manager()
	
	if AlienBlueprintsManager == nil then
		return
	end
	
	-- For the Aliens, the walker are tactical enablers!! .... so get all the walkers by getting all the tactical enablers!.
	Walkers = {}
	
	AlienBlueprintsManager.Set_Hidden(true)
	
	-- Walker Habitat Blueprint Scene
	AlienBlueprintsManager.WalkerHabitatBlueprintScene.Set_Hidden(true)
	AlienBlueprintsManager.WalkerHabitatBlueprintScene.Initialize_Scene()
	
	-- Walker Assembly Blueprint Scene
	AlienBlueprintsManager.WalkerAssemblyBlueprintScene.Set_Hidden(true)
	AlienBlueprintsManager.WalkerAssemblyBlueprintScene.Initialize_Scene()
	
	-- Walker Science Blueprint Scene
	AlienBlueprintsManager.WalkerScienceBlueprintScene.Set_Hidden(true)
	AlienBlueprintsManager.WalkerScienceBlueprintScene.Initialize_Scene()
	
	
	WalkerTypeToBlueprintScene = {}
	WalkerTypeToBlueprintScene[Find_Object_Type("Alien_Walker_Habitat")] 	= AlienBlueprintsManager.WalkerHabitatBlueprintScene
	WalkerTypeToBlueprintScene[Find_Object_Type("Alien_Walker_Assembly")] 	= AlienBlueprintsManager.WalkerAssemblyBlueprintScene
	WalkerTypeToBlueprintScene[Find_Object_Type("Alien_Walker_Science")] 	= AlienBlueprintsManager.WalkerScienceBlueprintScene
	
	SelectedWalker = nil
	BaseWalkerType = nil	-- some walker types are derived from the original ones (the only difference is that the former are customized walkers)
					-- however, they are basically the same walker type!.. so this variable tells us what the original (most basic type) the selected walker is!
end

-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Selection
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Selection()
	-- Reset the selection for the active scene!
	if SelectedWalker ~= nil and BaseWalkerType ~= nil then
		WalkerTypeToBlueprintScene[BaseWalkerType].Reset_Selection()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Close_Scene
-- ------------------------------------------------------------------------------------------------------------------
function Close_Scene()
	
	if SelectedWalker ~= nil and BaseWalkerType ~= nil then
		WalkerTypeToBlueprintScene[BaseWalkerType].Close_Blueprint()
		SelectedWalker = nil
		BaseWalkerType = nil
	end
	
	AlienBlueprintsManager.WalkerHabitatBlueprintScene.Set_Hidden(true)
	AlienBlueprintsManager.WalkerAssemblyBlueprintScene.Set_Hidden(true)
	AlienBlueprintsManager.WalkerScienceBlueprintScene.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display_Blueprint
-- ------------------------------------------------------------------------------------------------------------------
function Open_Blueprint(object)

	if SelectedWalker ~= nil and SelectedWalker ~= object then
		if WalkerTypeToBlueprintScene[BaseWalkerType].Get_Hidden() == false then
			-- close it!
			WalkerTypeToBlueprintScene[BaseWalkerType].Close_Blueprint()
			WalkerTypeToBlueprintScene[BaseWalkerType].Set_Hidden(true)
		end
	end
	
	SelectedWalker = object
	BaseWalkerType  = Get_Basic_Walker_Type(SelectedWalker.Get_Type())
	
	if BaseWalkerType == nil then 
		return
	end
	
	WalkerTypeToBlueprintScene[BaseWalkerType].Set_Hidden(false)
	WalkerTypeToBlueprintScene[BaseWalkerType].Display_Blueprint(object)
end


-- -----------------------------------------------------------------------------------------------------
-- Get_Basic_Walker_Type
-- -----------------------------------------------------------------------------------------------------
function Get_Basic_Walker_Type(walker_object_type)
	if walker_object_type == nil then 
		return nil
	end
	
	if WalkerTypeToBlueprintScene[walker_object_type] == nil then
		-- it can be a customized version so let's make sure that is the case, else, this object is invalid!
		local base_walker_type = walker_object_type.Get_Type_Value("Variant_Of_Existing_Type")
		
		return Get_Basic_Walker_Type(base_walker_type)
	end	
	return walker_object_type
end


-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Blueprints_Manager = Init_Blueprints_Manager
Interface.Reset_Selection = Reset_Selection
Interface.Close_Scene = Close_Scene
Interface.Open_Blueprint = Open_Blueprint