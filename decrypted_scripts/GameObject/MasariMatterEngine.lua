if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[210] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MasariMatterEngine.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/MasariMatterEngine.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 94569 $
--
--          $DateTime: 2008/03/04 17:24:35 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")
require("PGUICommands")
require("PGCommands")
require("PGBase")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

-- The following are set by xml script
-- ResourcesPerTimeBlock: how many resource processed per time block
-- ResourcesTimeSeconds: how many seconds between each processing
-- IncreaseResourcesStorage: how much each of these increase resources by

	if MatterEngine == nil then
		MatterEngine = {}
	end

	if MatterEngine.ResourcesPerTimeBlock == nil then
		MatterEngine.ResourcesPerTimeBlock = 1.0
	end		

	if MatterEngine.ResourcesTimeSeconds == nil then
		MatterEngine.ResourcesTimeSeconds = 1.0
	end
	
	if MatterEngine.ResourcesStorage == nil then
		MatterEngine.ResourcesStorage = 100.0
	end
	
	LastCheckTime = GetCurrentTime()
	NextCheckTime = LastCheckTime + MatterEngine.ResourcesTimeSeconds
	RegisterWithNewOwner = -1.0
	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Matter_Owner_Change: The owner has changed, register with the new owner
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Matter_Owner_Change(object)
	if TestValid(Object) then
		local player = Object.Get_Owner()
		if player ~= nil then
			local player_script = player.Get_Script()
			if player_script ~= nil then 
				player_script.Call_Function("Register_Matter_Engine_With_Control", Object)
			end
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Matter_Owner_Change: The owner has changed, register with the new owner
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Matter_Signal_Health_Zero()

	local engine_value = Object.Get_Attribute_Value("Harvest_Material_Add") + MatterEngine.ResourcesStorage

	local owner = Object.Get_Owner()
	if TestValid(owner) then
		player_script = owner.Get_Script()
		if player_script ~= nil then
		
			local resource_min = owner.Get_Baseline_Bank_Capacity()
			if resource_min <= 0.0 then
				return
			end
			local lost = engine_value
			local current_raw_materials = owner.Get_Raw_Materials()	
			if current_raw_materials - lost < resource_min then
				lost = current_raw_materials - resource_min
			end
			
			if lost > 0.0 then
				owner.Add_Raw_Materials( -lost )
			end
			
		end
	end
	
end
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()

	-- tell Register_Matter_Engine that we are a matter engine
	Matter_Owner_Change()
	
	-- we will need to re-register if the owner changes (although the previous owner will delete us so we don't have to do that)
	Object.Register_Signal_Handler(Matter_Signal_Owner_Change, "OBJECT_OWNER_CHANGED")
	Object.Register_Signal_Handler(Matter_Signal_Health_Zero, "OBJECT_HEALTH_AT_ZERO")
	Object.Register_Signal_Handler(Matter_Signal_Health_Zero, "OBJECT_SOLD")
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Matter_Owner_Change: The owner has changed get ready to register with the new owner
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Matter_Signal_Owner_Change(object)
	-- we want to want till our next service other wise we will end up getting deleted after we register
	-- i.e. let the old owner get the owner change signal first before we register our new owner
	RegisterWithNewOwner = GetCurrentTime() + 0.5
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	
	local tm = GetCurrentTime()

	if RegisterWithNewOwner > 0.0 and tm >= RegisterWithNewOwner then
		Matter_Owner_Change()
		RegisterWithNewOwner = -1.0
	end
	
	if tm >= NextCheckTime then
		if TestValid( Object ) and (MatterEngine.MustBeOfFaction == nil or Is_Player_Of_Faction(Object.Get_Owner(), MatterEngine.MustBeOfFaction) ) then
		
			local owner = Object.Get_Owner()
			if owner ~= nil then
				local time_passed = tm - LastCheckTime
				-- Maria 06.09.2007 - shouldn't this "ResourcesPerTimeBlock" be a modifier? 
				local resources = MatterEngine.ResourcesPerTimeBlock * ( time_passed / MatterEngine.ResourcesTimeSeconds )
				local harvest_add = Object.Get_Attribute_Value("Harvest_Material_Add")
				if harvest_add ~= nil then -- and harvest_add > 0.0 then (removing this so I can STOP the collection by making the resources amount negative ... how HACKY is this?!)
					resources = resources * ( 1.0 + harvest_add )
				end
				local cur_resources = owner.Get_Raw_Materials()
				
				if resources > 0.0 then 
					player_script = owner.Get_Script()
					if player_script ~= nil then
						local maximum_resources = player_script.Call_Function("Get_Maximum_Tactical_Resources", nil )
						if cur_resources > maximum_resources then
							-- we have more than maximum already, can't collect any more
							resources = 0.0
						elseif cur_resources + resources > maximum_resources then
							resources = maximum_resources - cur_resources
						end
					end
					
					if resources > 0.0 then
						owner.Add_Raw_Materials( resources, Object )
						-- Let the UI know we've harvested a resource...
						-- show near value (i.e round)
						local show_resources = resources + 0.5
						Create_Generic_Object_With_GUI_Data(Find_Object_Type("Resource_Floaty"), Object.Get_Position(), Object.Get_Owner(), show_resources)
					end
				end				
			end
		end
		LastCheckTime = tm
		NextCheckTime = LastCheckTime + MatterEngine.ResourcesTimeSeconds	
	end
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service

Register_Behavior(my_behavior)
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
	Debug_Switch_Sides = nil
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
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
