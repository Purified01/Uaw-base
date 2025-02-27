if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[159] = true
LuaGlobalCommandLinks[20] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[8] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/Patch_Control.lua#19 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/Patch_Control.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Nader_Akoury $
--
--            $Change: 97253 $
--
--          $DateTime: 2008/04/21 16:31:33 $
--
--          $Revision: #19 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGCommands")
require("PGBase")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Patch_Control - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Patch_Control()
	if not Player then return end
	
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	-- List of existing patch enablers
	PatchEnablersList = {}
	
	-- Data pertaining the current patches.
	QueueSize = 0
	ActivePatches = {}
	PatchTypeToData = {}
	
	-- Cooldown data
	CooldownData = {}
	CooldownPercentLeft = 0.0
	CooldownDuration = Player.Get_Patch_Queueing_Cooldown_Seconds()
	
	-- Cached tables for easy access from non-synchronized scripts
	CachedPatchMenu = {}
	CachedActivePatchesData = {}

	Script.Set_Async_Data("CooldownPercentLeft", CooldownPercentLeft)
	Script.Set_Async_Data("CooldownData", CooldownData)
	Script.Set_Async_Data("ActivePatches", ActivePatches)
	Script.Set_Async_Data("PatchTypeToData", PatchTypeToData)
	Script.Set_Async_Data("CachedPatchMenu", CachedPatchMenu)
	Script.Set_Async_Data("CachedActivePatchesData", CachedActivePatchesData)
	
	NumberPoweredEnablers = 0
	Script.Set_Async_Data("AvaialableQueueSlots", NumberPoweredEnablers)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Register_Patch_Enabler
-- ------------------------------------------------------------------------------------------------------------------
function Register_Patch_Enabler(enabler)
	if TestValid(enabler) then
		local is_in_list, idx = Is_In_List(enabler)
		if  is_in_list == false then 
			enabler.Register_Signal_Handler(Unregister_Patch_Enabler, "OBJECT_SOLD")
			enabler.Register_Signal_Handler(On_Powered_State_Changed, "OBJECT_POWERED_STATE_CHANGED")			
			table.insert(PatchEnablersList, enabler)
			
			if enabler.Get_Attribute_Integer_Value("Is_Powered") ~= 0 then 
				Increase_Powered_Enablers_Count()				
			end
		end	
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Unregister_Patch_Enabler
-- ------------------------------------------------------------------------------------------------------------------
function Unregister_Patch_Enabler(enabler)
	
	if not TestValid(enabler) then return end
	
	local is_in_list, idx = Is_In_List(enabler)
	if is_in_list == true then 
		table.remove(PatchEnablersList, idx)
		
		if enabler.Get_Attribute_Integer_Value("Is_Powered") ~= 0 then 
			Decrease_Powered_Enablers_Count()
		end
		enabler.Unregister_Signal_Handler(Unregister_Patch_Enabler)		
		enabler.Unregister_Signal_Handler(On_Powered_State_Changed)		
	end	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Increase_Powered_Enablers_Count
-- ------------------------------------------------------------------------------------------------------------------
function Increase_Powered_Enablers_Count()
	NumberPoweredEnablers = NumberPoweredEnablers +1
	
	-- do we need to enable a new queue slot? - The maximun number of slots is 2, however, 
	-- in order to have them both available we need to have at least 2 patch enabling structures!
	if NumberPoweredEnablers >  0 and NumberPoweredEnablers <= 2 then
	
		-- we need to update the UI for the local player only!!!!!.
		Get_Game_Mode_GUI_Scene().Raise_Event("Update_Patch_Queue_Size", nil, {Player, NumberPoweredEnablers} )
		QueueSize = NumberPoweredEnablers
		Script.Set_Async_Data("AvaialableQueueSlots", QueueSize)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Decrease_Powered_Enablers_Count
-- ------------------------------------------------------------------------------------------------------------------
function Decrease_Powered_Enablers_Count()
	if NumberPoweredEnablers <= 0 then
		return
	end
	NumberPoweredEnablers = NumberPoweredEnablers - 1
	
	-- do we need to disable any queue slot?
	if NumberPoweredEnablers <=  1 then 
		-- we need to update the UI for the local player only!!!!!.
		Get_Game_Mode_GUI_Scene().Raise_Event("Update_Patch_Queue_Size", nil, {Player, NumberPoweredEnablers} )
		QueueSize = NumberPoweredEnablers
		Script.Set_Async_Data("AvaialableQueueSlots", QueueSize)
		Update_Active_Patches_Data()
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Powered_Enablers_Count
-- ------------------------------------------------------------------------------------------------------------------
function On_Powered_State_Changed(object)
	if TestValid(object) then 
		-- make sure this guy belongs to our list!!!!
		if Is_In_List(object) == false then 
			MessageBox("Patch object should be in list!")
			Register_Patch_Enabler(object)
			return
		end
		
		if object.Get_Attribute_Integer_Value("Is_Powered") ~= 0 then 
			Increase_Powered_Enablers_Count()
		elseif NumberPoweredEnablers > 0 then 
			Decrease_Powered_Enablers_Count()
		end
	end	
end




-- ------------------------------------------------------------------------------------------------------------------
-- Is_In_List
-- ------------------------------------------------------------------------------------------------------------------
function Is_In_List(new_enabler)
	if TestValid(new_enabler) then
		for idx, enabler in pairs(PatchEnablersList) do
			if enabler == new_enabler then 
				return true, idx
			end
		end
	end
	return false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Cached_Patch_Menu -- Since we cannot access this data via Call_Function from the 
-- Menu UI Scripts, we need to make sure we update this data on service so that is always readily
-- available and 'fresh'!.
-- ------------------------------------------------------------------------------------------------------------------
function Update_Cached_Patch_Menu()
	-- By design, all enabling structures offer the same choice list.
	-- Therefore, we must make sure that we have at least on enabler registered!.
	CachedPatchMenu = {}
	Script.Set_Async_Data("CachedPatchMenu", CachedPatchMenu)
	if NumberPoweredEnablers <= 0 then return end
	
	local enabler = PatchEnablersList[1]
	if TestValid(enabler) then 
		
		CachedPatchMenu = enabler.Get_Tactical_Enabler_Supported_Patches(Player)
		if CachedPatchMenu == nil then CachedPatchMenu = {} end
		
		-- Each entry in menu contains a patch_data table with the following information:
		-- patch_data[1] = patch type
		-- patch_data[2] = can_produce
		-- patch_data[3] = enough_credits
		-- patch_data[4] = build cost
		-- patch_data[5]  = patch_duration
		-- let's arrange the info in a way that will make is easier to access!
		for _, patch_data in pairs(CachedPatchMenu) do
			local p_type = patch_data[1]
			if p_type ~= nil then 
				PatchTypeToData[p_type] = { CanBuild = (patch_data[2] and patch_data[3]), Cost = patch_data[4], Duration = patch_data[5]}
			end
		end		
	end	

	Script.Set_Async_Data("PatchTypeToData", PatchTypeToData)
	Script.Set_Async_Data("CachedPatchMenu", CachedPatchMenu)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Get_Patch_Cooldown_Rate_Multiplier
-- ------------------------------------------------------------------------------------------------------------------
function Get_Patch_Cooldown_Rate_Multiplier()
	-- All the patch enablers have this attribute set to the same value, therefore
	-- their modified value will be the same so it is sufficient to query the first
	-- available enabler!.	
	if #PatchEnablersList <= 0 then return 0 end
	local enabler = PatchEnablersList[1]
	
	if TestValid(enabler) then
	
		local modifier = enabler.Get_Attribute_Value("Patch_Cooldown_Time_Modifier")
		if modifier == -1.0 then 
			return 1e+018
		else
			return (1.0/(1.0+modifier))		
		end
		
	end
	
	return 0
end


-- ------------------------------------------------------------------------------------------------------------------
-- Can_Build_Patch_Of_Type
-- ------------------------------------------------------------------------------------------------------------------
function Can_Build_Patch_Of_Type(p_type)
	-- If we are in cooldown time, then nothing can be built!
	if CooldownData.CooldownTimeLeft and CooldownData.CooldownTimeLeft > 0.0 then return end
	
	-- First check to see whether the player can produce and afford this guy!.
	local data = PatchTypeToData[p_type]
	if data.CanBuild == false then return false end

	-- If we don't have any queue slots available then we can't build patches
	if QueueSize <= 0 then return false end
	
	-- Now, we have to make sure there is no other valid active patch of this type!!!!.
	return (not Is_There_Active_Patch_Of_Type(p_type))
end


-- ------------------------------------------------------------------------------------------------------------------
-- Is_There_Active_Patch_Of_Type
-- ------------------------------------------------------------------------------------------------------------------
function Is_There_Active_Patch_Of_Type(p_type)
	for _, data in pairs(ActivePatches) do
		if data.Type and data.Type == p_type then	
			if TestValid(data.Object) then 
				return true
			end
		end
	end
	return false
end

-- ------------------------------------------------------------------------------------------------------------------
-- Build_Patch
-- ------------------------------------------------------------------------------------------------------------------
function Build_Patch(object_type)

	local object = nil
	if QueueSize <= 0 then return object end

	if TestValid(object_type) then
		-- check that we can actually build the patch!
		if Can_Build_Patch_Of_Type(object_type) == false then return end
		
		-- Build the patch
		object = Spawn_Unit(object_type, Create_Position(), Player)
	
		if TestValid(object) then
		
			-- deduct the cost of this patch from the player's credits (if applicable)
			local cost = 0.0
			if PatchTypeToData[object_type] then 
				cost = PatchTypeToData[object_type].Cost
			else
				local mssg = Create_Wide_String("Don't have the data for patch type ")
				mssg.append(object_type.Get_Display_Name())
				mssg.append(Create_Wide_String(" in the PatchTypeToData map??????"))
				MessageBox(mssg)
			end
			
			if cost > 0.0 then 
				Player.Add_Credits(-cost)
			end
			
			-- put in Que, remove other patches as needed
			Queue_Patch(object)
			
			-- Setup the cooldown timer!
			CooldownData = {}
			CooldownData.LastCooldownUpdateTime = GetCurrentTime()	
			CooldownData.CooldownTimeLeft = CooldownDuration 
			CooldownPercentLeft = 1.0
			Script.Set_Async_Data("CooldownPercentLeft", CooldownPercentLeft)
			Script.Set_Async_Data("CooldownData", CooldownData)
			
			Get_Game_Mode_GUI_Scene().Raise_Event("On_Patch_Queueing_Complete", nil, {Player})			
		end		
	end	
	
	return object
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Specific_Controls
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Specific_Controls()
	Update_Patch_Control()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Patch_Control
-- ------------------------------------------------------------------------------------------------------------------
function Update_Patch_Control()
	-- We need to have this menu updated at all times given that we cannot only pull it out whenever the 
	-- UI Scene needs to refresh it (this is due to the fact that this is a sync'd script and the UI ones 
	-- are not!.
	Update_Cached_Patch_Menu()
	-- As above, this timer needs to be used by a UI Scene so we must update it here so that its value 
	-- can be queried at any time!
	Update_Cooldown_Timer()
	-- Update the progress of the active patches and update the cached data as well (needed for use in UI scenes)
	Update_Active_Patches_Data()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Patch_Lock_State_Changed
-- ------------------------------------------------------------------------------------------------------------------
function Patch_Lock_State_Changed()
	Update_Cached_Patch_Menu()
	
	local game_mode_scene = Get_Game_Mode_GUI_Scene()
	
	if game_mode_scene then 
		-- Some UI Scenes may need to update their displays so let them know that the data has changed!
		game_mode_scene.Raise_Event("Patch_Lock_State_Changed", nil, {Player} )
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Is_Cooling_Down
-- ------------------------------------------------------------------------------------------------------------------
function Is_Cooling_Down()
	return (CooldownData.CooldownTimeLeft and CooldownData.CooldownTimeLeft > 0.0)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Cooldown_Timer
-- ------------------------------------------------------------------------------------------------------------------
function Update_Cooldown_Timer()
	if NumberPoweredEnablers <= 0 then
	
		if Is_Cooling_Down() == true then 
			Reset_Patch_Cooldown()
		end
		
		return
	end
	
	if CooldownData.CooldownTimeLeft and CooldownData.CooldownTimeLeft > 0.0 then 
		
		if CooldownDuration > 0 then 
			
			-- Get the rate multiplier, which modifies how fast/slow the time passes!, ie, it modifies the elapsed time!
			local cooldown_rate_mult = Get_Patch_Cooldown_Rate_Multiplier()
			
			-- update the end time!.
			local curr_time = GetCurrentTime()
			local elapsed = curr_time - CooldownData.LastCooldownUpdateTime
			elapsed = elapsed*cooldown_rate_mult
			
			if elapsed > CooldownData.CooldownTimeLeft then 
				elapsed = CooldownData.CooldownTimeLeft
			end
			
			CooldownData.CooldownTimeLeft = CooldownData.CooldownTimeLeft - elapsed			
			
			if CooldownData.CooldownTimeLeft <= 0 then 
				-- the cooldown has expired.
				Reset_Patch_Cooldown()
				return
			end
			
			CooldownData.LastCooldownUpdateTime = curr_time
			CooldownPercentLeft = CooldownData.CooldownTimeLeft/CooldownDuration
			Script.Set_Async_Data("CooldownPercentLeft", CooldownPercentLeft)
			Script.Set_Async_Data("CooldownData", CooldownData)
		end		
	end	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Patch_Cooldown
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Patch_Cooldown()
	CooldownData.CooldownTimeLeft = 0.0
	CooldownData.LastCooldownUpdateTime = 0.0
	CooldownPercentLeft = 0.0	
	Script.Set_Async_Data("CooldownPercentLeft", CooldownPercentLeft)
	Script.Set_Async_Data("CooldownData", CooldownData)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Queue_Patch
-- ------------------------------------------------------------------------------------------------------------------
function Queue_Patch(object)

	-- QUEUEING ENTAILS: REMOVE TAIL, PUSH HEAD OVER AND ADD HEAD.
	
	if TestValid(object) then
		local queue_slots_used = #ActivePatches
		if (queue_slots_used >= QueueSize) and (QueueSize > 0) then
			-- we need to relocate patches!, that is: we must remove the tail, move the head over and add the new patch to the
			-- front of the queue.
			local patch_type_to_remove = ActivePatches[QueueSize].Type
		
			if patch_type_to_remove then
				local patch_object = ActivePatches[QueueSize].Object
				
				-- destroy this object!.
				if TestValid(patch_object) then 
					patch_object.Despawn()
				end
			end	

			-- remove this entry from the table of Active patches (remove head)
			table.remove(ActivePatches, QueueSize)
		end
		
		-- now go ahead and add this patch to the end of the list! (insert tail)
		local p_type = object.Get_Type()
		-- By inserting at the head, we push everything towards the end of the queue!
		table.insert(ActivePatches, 1,{ Type = p_type,  Object = object, SpawnTime = GetCurrentTime()})
		Update_Active_Patches_Data(true)
	end
	Script.Set_Async_Data("ActivePatches", ActivePatches)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Queue_Contents
-- ------------------------------------------------------------------------------------------------------------------
function Update_Queue_Contents()
	-- nothing to do if the numbers match up
	if #ActivePatches <=  QueueSize then return end
	
	-- oops! we have more active patches than the queue size allows for so we have to start purging the queue
	-- to even things up!. NOTE: note, we purge starting at the tail!.
	local q_slot = #ActivePatches
	while #ActivePatches >  QueueSize do
		local patch_data = ActivePatches[q_slot]
		
		if patch_data and patch_data.Type then 
			-- destroy this object!.
			if TestValid(patch_data.Object) then 
				-- KDB don't destroy reboot patches as they reduce patch queuesize to 0
				local patch_type = patch_data.Object.Get_Type()
				if not TestValid(patch_type) or patch_type.Get_Name() ~= "NOVUS_PATCH_REBOOT" then
					patch_data.Object.Despawn()
				end
			end
		end
		-- remove this entry from the table of Active patches 
		table.remove(ActivePatches, q_slot)
		q_slot = #ActivePatches
	end
	Script.Set_Async_Data("ActivePatches", ActivePatches)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Active_Patches_Data
-- ------------------------------------------------------------------------------------------------------------------
function Update_Active_Patches_Data()

	-- Update the number of active patches based on the number of queue slots available.
	Update_Queue_Contents()
	
	CachedActivePatchesData = {}
	
	-- we must update the progress of this guys if they have a predetermined duration period!.
	local time_left
	for i = 1, #ActivePatches do
		local data = ActivePatches[i]
		if data.Type then 			
			time_left = 0.0		
			-- do it only for patches with a valid object.
			local valid_patch_object = true
			if not TestValid(data.Object) then
				valid_patch_object = false
			end
			
			if valid_patch_object then 
				-- not all patches have a determined duration period!.
				local duration = PatchTypeToData[data.Type].Duration
				if duration and duration > 0.0 then 
					local end_time = data.SpawnTime + duration
					time_left = end_time - GetCurrentTime()
					time_left = time_left/duration
				
					if time_left < 0.0 then time_left = 0.0 end
					if time_left > 1.0 then time_left = 1.0 end
				end
			end
			data.TimeLeft = time_left			
			table.insert(CachedActivePatchesData, { [1] = data.Type, [2] = valid_patch_object, [3] = data.TimeLeft})
		end
	end	
	Script.Set_Async_Data("CachedActivePatchesData", CachedActivePatchesData)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Faction_Specific_Controls
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Faction_Specific_Controls()
	Init_Patch_Control()
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
	Reset_Faction_Specific_Controls = nil
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
	Update_Faction_Specific_Controls = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
