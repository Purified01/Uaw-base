-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGHintSystem.lua#31 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGHintSystem.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Maria_Teruel $
--
--            $Change: 84781 $
--
--          $DateTime: 2007/09/25 14:27:22 $
--
--          $Revision: #31 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGPlayerProfile")
require("PGHintSystemDefs")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGHintSystem_Init()

	PGHintSystemDefs_Init()
	PGPlayerProfile_Init()

	-- Registers all the GUI hint attachent functions.
	Initialize_GUI_Hint_Attachment_System()
	
	ICON_POOL_SIZE = 13
	CENTER_ANCHOR = 0.5
	X_ANCHOR = 0.97
	X_DELTA = 0.075
	X_DELTA_HALF = X_DELTA / 2
	Y_ANCHOR = 0.9
	Y_DELTA = 0.065
	Y_DELTA_HALF = Y_DELTA / 2
	HINT_TEXT_X_POS = 0.8
	HINT_TEXT_Y_POS = 0.5

	HintSystemContextScene = nil
	HintSystemIsVisible = true
	IconPoolCreated = false
	HintCount = 0
	ActiveIndependentHints = {}
	ActiveIndependentHintsByID = {}
	IndependentIconPoolHandles = {}
	AttachedGameObjectHintHandles = {}	-- Stores handles for hints attached to GameObjects
	GUIHintHandleStore = {}				-- Stores handles for GUI attached hints so they don't have to be destroyed / created.
	AttachedGUIHintQueue = {}				-- Queue that holds hints that are due to be attached to GUI elements (this array stores them in the order they have been added)
	AttachedGUIHintQueueByID = {}			-- Queue that holds hints that are due to be attached to GUI elements (this map stores them by their id)
	
	AttachedGUIHintDequeueByID = {}			-- Queue that holds attached GUI hints that have been attached to a GUI element from the queue.(this map stores them by their id)
	IndependentIconLookup = {}			-- Maps hint ids to the independent icons which are displaying them.
	IndependentHintTextHandle = nil
	HintCallbackScript = nil
	HintActivationCallback = nil
	HintDismissalCallback = nil

	-- Hint tracking is disabled by default, because several scripts will
	-- require this one, but only the Tactical Command Bar needs access to
	-- the hint tracking functions here.
	EnableHintTracking = false
	--EnableHintTracking = true

end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Initialize_GUI_Hint_Attachment_System()

	-- *** GUI HINT ATTACHMENT ***
	-- Because the methods of finding GUI elements to which we want to attach hints are
	-- so diverse, we have a system where new function must be implemented each time a
	-- new GUI class of element requires a hint.  These functions are registered in the
	-- table _PG_GUI_HINT_TARGET_FIND_LOOKUP, looked up by ID, and called at hint-creation
	-- time.
	PG_GUI_HINT_DIRECT					= Declare_Enum(1)
	PG_GUI_HINT_HERO_ICON				= Declare_Enum()
	PG_GUI_HINT_SPECIAL_ABILITY_ICON		= Declare_Enum()
	PG_GUI_HINT_SUPERWEAPON_BUTTON		= Declare_Enum()
	PG_GUI_HINT_ELEMENTAL_MODE_ICON		= Declare_Enum()

	_PG_GUI_HINT_TARGET_FIND_LOOKUP = {}
	_PG_GUI_HINT_TARGET_FIND_LOOKUP[PG_GUI_HINT_DIRECT] 				= _PG_Find_Direct_Component
	_PG_GUI_HINT_TARGET_FIND_LOOKUP[PG_GUI_HINT_HERO_ICON] 			= _PG_Find_Hero_Icon
	_PG_GUI_HINT_TARGET_FIND_LOOKUP[PG_GUI_HINT_SUPERWEAPON_BUTTON]	= _PG_Find_Superweapon_Button
	_PG_GUI_HINT_TARGET_FIND_LOOKUP[PG_GUI_HINT_SPECIAL_ABILITY_ICON] 	= _PG_Find_Special_Ability_Icon
	_PG_GUI_HINT_TARGET_FIND_LOOKUP[PG_GUI_HINT_ELEMENTAL_MODE_ICON] 	= _PG_Find_Elemental_Mode_Icon
end
	

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Register_Hint_Context_Scene(scene)

	if (this == scene) then
		-- Local scene...we can register event callbacks right on the handle.
		_PG_Hint_Register_Context_Scene(scene)
	else
		-- Foreign scene.  It will already have the callbacks registered, so we
		-- just store this handle as the event locus.
		HintSystemContextScene = scene
	end
	
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Register_Hint_Callback_Script(script)
	HintCallbackScript = script
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Register_Hint_Callback_Script", nil, {script})
end


-------------------------------------------------------------------------------
-- Adds an independent hint, unattached to any game object.  Spawns as an icon
-- at the bottom of the screen which displays the hint text when clicked.
--
-- Returns true if the hint will be shown, false otherwise.
-------------------------------------------------------------------------------
function Add_Independent_Hint(hint_id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Add_Independent_Hint", nil, {hint_id})
	return true
end


-------------------------------------------------------------------------------
-- Adds a hint attached to a game object.  Spawns as an icon which follows the
-- game object around.  When clicked, the text of the hit is displayed and can
-- be dismissed by clicking on the text.
--
-- Returns true if the hint will be shown, false otherwise.
-------------------------------------------------------------------------------
function Add_Attached_Hint(game_object, hint_id, scene)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Add_Attached_Hint", nil, {game_object, hint_id})
	return true
end


-------------------------------------------------------------------------------
-- Adds a hint attached to a GUI object.  Works just like the other type of
-- attached hint.
--
-- Returns true if the hint will be shown, false otherwise.
-------------------------------------------------------------------------------
function Add_Attached_GUI_Hint(target_find_id, target_find_arg, hint_id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Add_Attached_GUI_Hint", nil, {target_find_id, target_find_arg, hint_id})
	return true
end


-------------------------------------------------------------------------------
-- Removes an independent hint from the UI.
-------------------------------------------------------------------------------
function Activate_Independent_Hint(id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Select_Hint", nil, {id})
end


-------------------------------------------------------------------------------
-- Removes an independent hint from the UI.
-------------------------------------------------------------------------------
function Remove_Independent_Hint(id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Remove_Independent_Hint", nil, {id})
end


-------------------------------------------------------------------------------
-- Removes an attached hint from its GameObject.
-------------------------------------------------------------------------------
function Remove_Attached_Hint(id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Remove_Attached_Hint", nil, {id})
end


-------------------------------------------------------------------------------
-- Removes an independent hint from the UI.
-------------------------------------------------------------------------------
function Invoke_Hint_Activation_Callback(id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Invoke_Hint_Activation_Callback", nil, {id})
end


-------------------------------------------------------------------------------
-- Removes an attached hint from its GameObject.
-------------------------------------------------------------------------------
function Invoke_Hint_Dismissal_Callback(id)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Invoke_Hint_Dismissal_Callback", nil, {id})
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Hint_System_Enabled(value)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	
	if TestValid(HintSystemContextScene) then
		HintSystemContextScene.Raise_Event_Immediate("Set_Hint_System_Enabled", nil, {value})
	else
		--Doing this from a menu out of game.  Just set the profile value directly
		Set_Profile_Value(PP_HINT_SYSTEM_ENABLED, value)
	end
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Clear_Hint_Tracking_Map()
	HintTrackMap = {}
	Pad_Hint_Track_Map()
	Set_Profile_Value(PP_HINT_TRACK_MAP, HintTrackMap)
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Cleanup_Hint_System()
	Destroy_Hint_Icon_Pool()
	Destroy_Hint_Text()
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Destroy_Hint_Icon_Pool()
	for _, handle in ipairs(IndependentIconPoolHandles) do
		handle.Destroy()
	end
	IconPoolCreated = false
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Destroy_Hint_Text()
	IndependentHintTextHandle.Destroy()
	IndependentHintTextHandle = nil
end



-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Hide_Hint_Text()
	IndependentHintTextHandle.Set_Hidden(true)
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_Independent_Hints(removing_hint)

	--Flatten out the hints from a has by hint id into an array that aligns with our pool of hint display objects
	-- Maria: the ActiveIndependentHints map is a flat array already!.
	local hint_count = table.getn(ActiveIndependentHints)
	local y_pos = CENTER_ANCHOR - ((hint_count - 1) * Y_DELTA_HALF)
	IndependentIconLookup = {}

	local active_hint_id = nil
	if (IndependentHintTextHandle.Is_Showing()) then
		active_hint_id= IndependentHintTextHandle.Get_Model_ID()
	end
	
		
	for i = 1, ICON_POOL_SIZE do
		local handle = IndependentIconPoolHandles[i]
		if (handle ~= nil) then
			local hint = ActiveIndependentHints[i]
			if (hint == nil) then
				-- If there's no hint, hide the icon.
				handle.Set_Hidden(true)
			else
				-- If there is a hint, set it's model and show it ONLY IF the hint system is currently visible.
				handle.Set_Hidden(not HintSystemIsVisible)	-- Only unhide if the hint system is supposed to be visible.
				hint.Handle = handle
				handle.Set_Model(hint.Id)
				handle.Set_Screen_Position(X_ANCHOR, y_pos)
				
				if not removing_hint and active_hint_id and active_hint_id == hint.Id then
					handle.Set_Active(true)
					-- we must also re-position the text so that it follows the icon
					IndependentHintTextHandle.Set_Default_Vertical_Position(y_pos)
					IndependentHintTextHandle.Set_Model(active_hint_id)
				else
					handle.Set_Active(false)
				end
				
				y_pos = y_pos + Y_DELTA
				IndependentIconLookup[hint.Id] = handle
			end
		end
	end
end


-------------------------------------------------------------------------------
-- There needs to be one entry in the map for each defined hint.  On first 
-- initialization, it will probably be empty.  At any rate we pad it out.
-------------------------------------------------------------------------------
function Pad_Hint_Track_Map()

	for i = 1, HINT_SYSTEM_END do
		if (HintTrackMap[i] == nil) then
			HintTrackMap[i] = false
		end
	end

end

-------------------------------------------------------------------------------
-- Hides or shows the entire hint system.
-------------------------------------------------------------------------------
function Set_Hint_System_Visible(visible)
	if (HintSystemContextScene == nil) then
		HintSystemContextScene = Get_Game_Mode_GUI_Scene()
	end
	HintSystemContextScene.Raise_Event_Immediate("Set_Hint_System_Visible", nil, {visible})
end


-------------------------------------------------------------------------------------------------------------
-- *********************************************************************************************************
--  *************** THE FOLLOWING FUNCTIONS SHOULD NOT BE CALLED BY ANY SYSTEMS OTHER THAN: ***************
--  *************** Tactical_Command_Bar_Common.lua                                         ***************
--  *************** Any hint system management GUIs.                                        ***************
-- *********************************************************************************************************
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO INIT HINT TRACKING!!!
--
-- Hints need to be centrally instantiated, managed, and removed within 
-- a scene context.  That scene needs to be registered here before the hint
-- system can function.
-------------------------------------------------------------------------------
function _PG_Hint_Register_Context_Scene(scene)

	HintSystemContextScene = scene
	
	HintSystemIsEnabled = Get_Profile_Value(PP_HINT_SYSTEM_ENABLED, true)
	
	_PG_Initialize_Hint_Tracking()
	HintSystemContextScene.Register_Event_Handler("Set_Hint_System_Enabled", nil, _PG_Hint_Set_Hint_System_Enabled)
	HintSystemContextScene.Register_Event_Handler("Set_Hint_System_Visible", nil, _PG_Hint_Set_Hint_System_Visible)
	HintSystemContextScene.Register_Event_Handler("Register_Hint_Callback_Script", nil, _PG_Hint_Register_Callback_Script)
	HintSystemContextScene.Register_Event_Handler("Invoke_Hint_Activation_Callback", nil, _PG_Hint_Invoke_Activation_Callback)
	HintSystemContextScene.Register_Event_Handler("Invoke_Hint_Dismissal_Callback", nil, _PG_Hint_Invoke_Dismissal_Callback)
	HintSystemContextScene.Register_Event_Handler("Add_Independent_Hint", nil, On_Add_Independent_Hint)
	HintSystemContextScene.Register_Event_Handler("Add_Attached_Hint", nil, On_Add_Attached_Hint)
	HintSystemContextScene.Register_Event_Handler("Add_Attached_GUI_Hint", nil, On_Add_Attached_GUI_Hint)
	HintSystemContextScene.Register_Event_Handler("Select_Hint", nil, On_Select_Hint)
	HintSystemContextScene.Register_Event_Handler("Remove_Independent_Hint", nil, On_Remove_Independent_Hint)
	HintSystemContextScene.Register_Event_Handler("Remove_Attached_Hint", nil, On_Remove_Attached_Hint)
	HintSystemContextScene.Register_Event_Handler("Cleanup_Hint_System", nil, On_Cleanup_Hint_System)
	_PG_Hint_Create_Hint_Icon_Pool(HintSystemContextScene)
	_PG_Hint_Create_Hint_Text(HintSystemContextScene)
	
end
	

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PG_Hint_Set_Hint_System_Enabled(event, source, enabled)
	HintSystemIsEnabled = enabled
	_PG_Hint_Set_Hint_System_Visible(event, source, HintSystemIsEnabled)
	Set_Profile_Value(PP_HINT_SYSTEM_ENABLED, HintSystemIsEnabled)
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PG_Hint_Set_Hint_System_Visible(event, source, visible)

	HintSystemIsVisible = visible
	local hint_revealed = false		-- Has at least one hint been revealed?

	-- Independent hint.
	if (HintSystemIsVisible) then
		-- If we want it visible, just call a refresh.
		Refresh_Independent_Hints()
	else
		-- If we want it hidden, just hide 'em all.
		for _, handle in ipairs(IndependentIconPoolHandles) do
			handle.Set_Hidden(not HintSystemIsVisible)
			hint_revealed = true
		end
	end
	
	-- On hiding the hint system, we DO want the independent hint text window hidden.
	-- On showing the hint system, we DO NOT want the independent hint text window shown.
	-- So we just always hide it.
	IndependentHintTextHandle.Set_Hidden(true)
	
	-- Attached GameObject hints.
	for _hint_id, map in pairs(AttachedGameObjectHintHandles) do
		map.Handle.Set_Hidden(not HintSystemIsVisible)
		hint_revealed = true
	end
	
	-- Attached GUI hints.
	if (HintSystemIsVisible) then
		_PG_Hint_Refresh_GUI_Hints()
	else
		for hint_id, map in pairs(AttachedGUIHintDequeueByID) do
			map.Handle.Set_Hidden(not HintSystemIsVisible)
		end
	end
	
	if (HintSystemIsVisible and hint_revealed) then
		Play_SFX_Event("GUI_Hint_Icon_Shown")
	end
	
end

	
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PG_Hint_Create_Hint_Icon_Pool(scene)
	if (IconPoolCreated) then
		return
	end
	for i = 1, ICON_POOL_SIZE do
		local handle
		if TestValid(scene.Hints) then 
			handle = scene.Hints.Create_Embedded_Scene("Hint_Icon", ("Hint_Icon_" .. tostring(i)))
		else
			handle = scene.Create_Embedded_Scene("Hint_Icon", ("Hint_Icon_" .. tostring(i)))	
		end
		
		handle.Set_Hidden(true)
		handle.Set_Scene(scene)
		table.insert(IndependentIconPoolHandles, handle)
	end
	IconPoolCreated = true
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PG_Hint_Create_Hint_Text(scene)
	IndependentHintTextHandle = scene.Create_Embedded_Scene("Hint_Text", "Hint_Text")
	IndependentHintTextHandle.Set_Hidden(true)
	IndependentHintTextHandle.Set_Screen_Position(HINT_TEXT_X_POS, HINT_TEXT_Y_POS)
	IndependentHintTextHandle.Mark_Default_World_Bounds()
end


-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO INIT HINT TRACKING!!!
-- This is called from the tactical command bar common script to help manage
-- the hint pool.
-------------------------------------------------------------------------------
function _PG_Initialize_Hint_Tracking()
	EnableHintTracking = Get_Profile_Value(PP_HINT_TRACKING_ENABLED, true)
	_PG_Refresh_Hint_Track_Map()
end

-------------------------------------------------------------------------------
-- Gets the latest hint tracking map from the registry.
-------------------------------------------------------------------------------
function _PG_Refresh_Hint_Track_Map()
	HintTrackMap = Get_Profile_Value(PP_HINT_TRACK_MAP, {})
	Pad_Hint_Track_Map()
end


-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO INSTANTIATE AN INDEPENDENT HINT!!!
-- This is called from the tactical command bar common script to help manage
-- the hint pool.
--
-- The function you're looking for is Add_Independent_Hint() for a standard
-- hint, or Add_Attached_Hint() for a hint attached to a unit.
-------------------------------------------------------------------------------
function _PG_Hint_Add_Independent_Hint(hint_id)

	-- Make sure we have the latest hint tracking map (another thread may have clobbered it!)
	_PG_Refresh_Hint_Track_Map()
	
	if ((not HintSystemIsEnabled) or (EnableHintTracking and HintTrackMap[hint_id])) then
		return
	end

	if (HintCount >= ICON_POOL_SIZE) then
		MessageBox("TEMP WARNING:  Hint system cannot currently display any further hints.")
		return
	end
	
	-- Is the hint already up?
	if (ActiveIndependentHintsByID[hint_id] ~= nil) then
		DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Independent_Hint: Independent hint [" .. tostring(hint_id) .. "] is already up.  Ignoring...")
		return
	end

	DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Independent_Hint: Adding new independent hint [" .. tostring(hint_id) .. "]")
	local hint = HintSystemMap[hint_id]
	
	-- Maria 06.15.2007 - We want the hints to display in the order they have been added.  Hence, we'll keep a flat FIFO array with the hints as well as 
	-- a map from which we can get the hints by their ID.  Also, to make retrieval from the array faster, we will store the index in the hint data.
	hint.Index = #ActiveIndependentHints + 1
	-- Add the new hint to the array
	table.insert(ActiveIndependentHints, hint)
	-- add the new hint to the 'HintId to hint' map.
	ActiveIndependentHintsByID[hint_id] = hint
	
	Refresh_Independent_Hints()
	HintCount = HintCount + 1

	if (HintSystemIsVisible) then
		Play_SFX_Event("GUI_Hint_Icon_Shown")
	end
	
end

-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO INSTANTIATE AN ATTACHED HINT!!!
-- This is called from the tactical command bar common script to help manage
-- the hint pool.
--
-- The function you're looking for is Add_Attached_Hint().
-------------------------------------------------------------------------------
function _PG_Hint_Add_Attached_Hint(game_object, hint_id)

	-- Make sure we have the latest hint tracking map (another thread may have clobbered it!)
	_PG_Refresh_Hint_Track_Map()
	
	if ((not HintSystemIsEnabled) or (EnableHintTracking and HintTrackMap[hint_id])) then
		return
	end

	-- Is the hint already up?
	if (AttachedGameObjectHintHandles[hint_id] ~= nil) then
		DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_Hint: Attached hint [" .. tostring(hint_id) .. "] is already up.  Ignoring...")
		return
	end
	
	-- Does the game object already have a hint on it?
	for hint_id, map in pairs(AttachedGameObjectHintHandles) do
		if (map.AttachObject == game_object) then
			DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_Hint: Game object for hint [" .. tostring(hint_id) .. "] already has a hint.  Ignoring...")
			return
		end
	end
	
	DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_Hint: Adding new attached hint [" .. tostring(hint_id) .. "]")
	local handle = game_object.Add_GUI_Scene("Floating_Hint")
	handle.Set_Hidden(not HintSystemIsVisible)
	handle.Raise_Event_Immediate("On_Set_Model", nil, {hint_id})
	handle.Raise_Event_Immediate("On_Set_Game_Object", nil, {game_object})
	map = {
		Handle = handle,
		AttachObject = game_object
	}
	AttachedGameObjectHintHandles[hint_id] = map

	if (HintSystemIsVisible) then
		Play_SFX_Event("GUI_Hint_Icon_Shown")
	end
	
end


-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO INSTANTIATE AN ATTACHED GUI HINT!!!
-- This is called from the tactical command bar common script to help manage
-- the hint pool.
--
-- The function you're looking for is Add_Attached_GUI_Hint().
-------------------------------------------------------------------------------
function _PG_Hint_Add_Attached_GUI_Hint(target_find_id, target_find_arg, hint_id)

	-- Make sure we have the latest hint tracking map (another thread may have clobbered it!)
	_PG_Refresh_Hint_Track_Map()
	
	if ((not HintSystemIsEnabled) or (EnableHintTracking and HintTrackMap[hint_id])) then
		return
	end
	
	-- Is the hint already up?
	if ((AttachedGUIHintDequeueByID[hint_id] ~= nil) or (AttachedGUIHintQueueByID[hint_id] ~= nil)) then
		DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_GUI_Hint: Attached GUI hint [" .. tostring(hint_id) .. "] is already up.  Ignoring...")
		return
	end

	DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_GUI_Hint: Adding new attached GUI hint [" .. tostring(hint_id) .. "]")
	local handle = GUIHintHandleStore[hint_id]
	if (handle == nil) then
		if TestValid(HintSystemContextScene.Hints) then 
			handle = HintSystemContextScene.Hints.Create_Embedded_Scene("Floating_Hint", ("Floating_Hint_" .. hint_id))
		else
			handle = HintSystemContextScene.Create_Embedded_Scene("Floating_Hint", ("Floating_Hint_" .. hint_id))		
		end
		GUIHintHandleStore[hint_id] = handle
	end
	handle.Set_Model(hint_id)

	-- If the target is found, then we just attach the hint, otherwise we queue the hint up
	-- to be displayed later.
	local map = {
		["ID"] = target_find_id,
		["Arg"] = target_find_arg,
		["Handle"] = handle,
		["Hint_ID"] = hint_id		
	}
	
	local attach_target = _PG_Get_GUI_Target_Find_Function(target_find_id, target_find_arg)
	
	if (attach_target ~= nil) then
		map.ScreenPosition = Get_GUI_Hint_Screen_Position(attach_target)
		if (map.ScreenPosition == nil) then
			DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_GUI_Hint -- Unable to position GUI hint: " .. tostring(hint_id) .. ".  Ignoring...")
			return
		end
	
		--Match up aspect ratio response
		handle.Set_Screen_Justification(attach_target.Get_Screen_Justification())
		handle.Set_Screen_Position(map.ScreenPosition.X, map.ScreenPosition.Y)
		handle.Send_To_Back()
		map.AttachTarget = attach_target
		AttachedGUIHintDequeueByID[hint_id] = map
		
		if (HintSystemIsVisible) then
			Play_SFX_Event("GUI_Hint_Icon_Shown")
		end	
	else	
		-- Add it to the ordered array and to the map by id
		map.Index = #AttachedGUIHintQueue + 1
		table.insert(AttachedGUIHintQueue, map)
		AttachedGUIHintQueueByID[hint_id] = map
		handle.Set_Hidden(true)	
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function _PG_Hint_Refresh_GUI_Hints()

	-- If the hint system is not yet initialized, just do nothing.
	if (AttachedGUIHintQueue == nil) then
		return
	end

	-- Go through all the pending attached GUI hints and attach them to their targets if available.
	--for index, map in pairs(AttachedGUIHintQueue) do
	-- try going backwards since the hit icons will stack up and the last one will actually be the first one to click if we start at the head!.
	for index = 1, #AttachedGUIHintQueue do
		local map = AttachedGUIHintQueue[index]
		-- set the rendering order (this is necessary to keep the hint icons in the order they were added!)
		--- NOTE: the position and rest of the stuff will get set in the next loop!.
		map.Handle.Send_To_Back()
		map.PlaySFX = true
		-- add it to the map by ID.
		AttachedGUIHintDequeueByID[map.Hint_ID] = map						
	end

	-- Dequeue hints that were successfully attached, and update all dequeued hint visibility.
	for hint_id, map in pairs(AttachedGUIHintDequeueByID) do
		
		Remove_Queued_Attached_GUI_Hint_By_ID(hint_id)
		
		-- Before refreshing the hide-state of the hint, let's make sure the Attached handle is still valid!
		-- Else, we will have to re-compute it.
		local attach_target = _PG_Get_GUI_Target_Find_Function(map.ID, map.Arg)
		if attach_target ~= nil then
			if attach_target ~= map.AttachTarget then
				-- Reset the map data!!!! 
				map.ScreenPosition = Get_GUI_Hint_Screen_Position(attach_target)
				if (map.ScreenPosition == nil) then
					DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_GUI_Hint -- Unable to position GUI hint: " .. tostring(hint_id) .. ".  Ignoring...")
				else
					-- We only play the SFX for the new hints that have just been added to the dequeue list!.
					if HintSystemIsVisible and map.PlaySFX == true then
						Play_SFX_Event("GUI_Hint_Icon_Shown")
						map.PlaySFX = nil						
					end
				end
				map.Handle.Set_Screen_Position(map.ScreenPosition.X, map.ScreenPosition.Y)		
			end				
		end		
		
		map.AttachTarget = attach_target			
		if (HintSystemIsVisible) and TestValid(map.AttachTarget) then
			map.Handle.Set_Hidden(map.AttachTarget.Get_Hidden())
		else
			map.Handle.Set_Hidden(true)
		end
	end
end


-- -----------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------
function Remove_Queued_Attached_GUI_Hint_By_ID(hint_id)
	
	-- remove it from the map by ID.
	local map = AttachedGUIHintQueueByID[hint_id]
	
	if map then 
		-- First remove it from the ordered list.
		if not map.Index or  map.Index < 1 or map.Index > #AttachedGUIHintQueue then 
			DebugMessage("HINT_SYSTEM::Remove_Queued_Attached_GUI_Hint_By_ID: The queue index assigned to the attached hint [" .. tostring(hint_id) .. "] is not valid!!!.")
		end
		
		table.remove(AttachedGUIHintQueue, map.Index)
		
		-- Re-shuffle all the indeces for the remaining queued hints!!!!
		for index, map in pairs(AttachedGUIHintQueue) do
			if map then 
				map.Index = index
			end
		end
	end
	
	-- remove it from the list by IDs
	AttachedGUIHintQueueByID[hint_id] = nil
end


-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO REMOVE AN INDEPENDENT HINT!!!
-- This is called from the tactical command bar common script to help manage
-- the hint pool.
--
-- The function you're looking for is Add_Independent_Hint() for a standard
-- hint, or Add_Attached_Hint() for a hint attached to a unit.
-------------------------------------------------------------------------------
function _PG_Hint_Remove_Independent_Hint(hint_id)

	-- Maria 06.15.2007 - We need to remove the hint from the 'Hint ID to hint' map and the flat array.
	local hint = ActiveIndependentHintsByID[hint_id]
	
	if not hint then 
		DebugMessage("HINT_SYSTEM::_PG_Hint_Remove_Independent_Hint: The Independent hint [" .. tostring(hint_id) .. "] could not be found.  Ignoring....")
		return
	end
	
	if Remove_Independent_Hint_By_Index(hint.Index) == false then 
		DebugMessage("HINT_SYSTEM::_PG_Hint_Remove_Independent_Hint: The array index assigned to the independent hint [" .. tostring(hint_id) .. "] is not valid!!!.")
	end
	
	-- Now, nil out the entry in the id table!
	ActiveIndependentHintsByID[hint_id] = nil
	
	-- Go ahead and update the hints data.
	Refresh_Independent_Hints(true)

	if ( EnableHintTracking and not HintSystemMap[hint_id].IgnoreTracking ) then
		HintTrackMap[hint_id] = true
		Set_Profile_Value(PP_HINT_TRACK_MAP, HintTrackMap)
	end

	HintCount = HintCount - 1
	if (HintCount < 0) then
		HintCount = 0
	end

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Remove_Independent_Hint_By_Index(table_index)
	-- Make sure the hint has a valid index attached to it
	if not table_index or table_index < 1 or table_index > #ActiveIndependentHints then 
		return false 
	end
	
	table.remove(ActiveIndependentHints, table_index)	
	
	-- Update the hints' indeces for the configuration of the array may have changed!
	for index, hint in pairs(ActiveIndependentHints) do
		if hint then 
			hint.Index = index
		end
	end	
	return true	
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function _PG_Hint_Show_Independent_Hint_Text(hint_id)

	-- If the text of another hint is already showing, dismiss that hint.
	if (IndependentHintTextHandle.Is_Showing()) then
		local hint_id = IndependentHintTextHandle.Get_Model_ID()
		if (hint_id ~= nil) then
			_PG_Hint_Remove_Independent_Hint(hint_id)
			
			-- we have to play the close sound since this event is not going through the
			-- hint text scene.
			Play_SFX_Event("GUI_Hint_Text_Closed")
		end
	end

	local icon_handle = IndependentIconLookup[hint_id]
	if not icon_handle then return end
	
	local x, y = icon_handle.Get_Screen_Position()
	IndependentHintTextHandle.Set_Default_Vertical_Position(y)
	IndependentHintTextHandle.Set_Model(hint_id)
	IndependentHintTextHandle.Set_Hidden(false)
	icon_handle.Set_Active(true)
end


-------------------------------------------------------------------------------
-- DO NOT DIRECTLY CALL THIS FUNCTION TO REMOVE AN ATTACHED HINT!!!
-- This is called from the tactical command bar common script to help manage
-- the hint pool.
--
-- The function you're looking for is Remove_Attached_Hint().
-------------------------------------------------------------------------------
function _PG_Hint_Remove_Attached_Hint(hint_id)

	if (EnableHintTracking and not HintSystemMap[hint_id].IgnoreTracking) then
		HintTrackMap[hint_id] = true
		Set_Profile_Value(PP_HINT_TRACK_MAP, HintTrackMap)
	end

	local map = AttachedGameObjectHintHandles[hint_id]
	if (map ~= nil and map.Handle ~= nil) then
		map.Handle.Set_Hidden(true)
		map.Handle.Destroy()
	end

	handle = nil
	local map = AttachedGUIHintDequeueByID[hint_id]
	if (map ~= nil) then
		handle = map.Handle
		if (handle ~= nil) then
			handle.Set_Hidden(true)
			--handle.Destroy()		-- JOE TODO:  Unneccessary?
		end
		
		-- Finally remove it from the map by its ID
		AttachedGUIHintDequeueByID[hint_id] = nil
	end
end


-------------------------------------------------------------------------------
-- Initialize the GUI target finding function lookup.
-------------------------------------------------------------------------------
function _PG_Init_Hint_Target_Find_Lookup()
end


-------------------------------------------------------------------------------
-- Attached GUI hint target finder function lookup.
-------------------------------------------------------------------------------
function _PG_Get_GUI_Target_Find_Function(target_find_id, target_find_arg)

	if (_PG_GUI_HINT_TARGET_FIND_LOOKUP == nil) then
		_PG_Init_Hint_Target_Find_Lookup()
	end
	if (_PG_GUI_HINT_TARGET_FIND_LOOKUP[target_find_id] ~= nil) then
		return _PG_GUI_HINT_TARGET_FIND_LOOKUP[target_find_id](target_find_arg)
	end
	DebugMessage("ERROR: Unregistered GUI hint target finder ID: " .. tostring(target_find_id))
	return nil
	
end


-------------------------------------------------------------------------------
-- ATTACHED GUI HINT TARGET FINDER:
-------------------------------------------------------------------------------
function _PG_Find_Direct_Component(target_find_arg)
	return target_find_arg
end


-------------------------------------------------------------------------------
-- ATTACHED GUI HINT TARGET FINDER:
-------------------------------------------------------------------------------
function _PG_Find_Hero_Icon(target_find_arg)
	local hero_manager = HeroObjectToButtonMap[target_find_arg] 
	if TestValid(hero_manager) then 
		return hero_manager.Get_Hero_Button()
	end
	return nil
end

-------------------------------------------------------------------------------
-- ATTACHED GUI HINT TARGET FINDER:
-------------------------------------------------------------------------------
function _PG_Find_Superweapon_Button(sw_type_name)
	local sw_button = WeaponTypeNameToButton[sw_type_name]
	if TestValid(sw_button) then 
		return sw_button
	end
	return nil
end

-------------------------------------------------------------------------------
-- ATTACHED GUI HINT TARGET FINDER:
-------------------------------------------------------------------------------
function _PG_Find_Special_Ability_Icon(target_find_arg)

	for _, handle in ipairs(SpecialAbilityButtons) do
		-- Maria 06.16.2007
		-- Since the ability buttons are un-hidden in order, we can safely break 
		-- when finding the first hidden button.
		if handle.Get_Hidden() == true then break end
		
		local user_data = handle.Get_User_Data()
		if (user_data ~= nil) then
			local text_id = user_data.ability.text_id
			if (text_id == target_find_arg) then
				return handle
			end
		end
	end
	return nil
end

-- -------------------------------------------------------------------------------
-- ATTACHED GUI HINT TARGET FINDER:
-- -------------------------------------------------------------------------------
function _PG_Find_Elemental_Mode_Icon()
	if TestValid(EM_Button) then 
		return EM_Button
	end
	return nil
end

-------------------------------------------------------------------------------
-- Should only be called from the scene scripts that implement the actual
-- hints.
-------------------------------------------------------------------------------
function _PG_Hint_Register_Callback_Script(event, source, hint_callback_script)
	HintCallbackScript = hint_callback_script
end


-------------------------------------------------------------------------------
-- Should only be called from the scene scripts that implement the actual
-- hints.
-------------------------------------------------------------------------------
function _PG_Hint_Invoke_Activation_Callback(event, source, hint_id)

	-- If the hint callback has been set, we'll attempt to invoke the callback.
	if (HintCallbackScript ~= nil) then
	
		-- Is the hint callback script my current context?
		if (HintCallbackScript == Script) then
			-- The callback is in my current context...if the function is implemented, call it.
			if (Hint_Activation_Callback ~= nil) then
				-- Call it!
				Hint_Activation_Callback(hint_id)
				return
			end
		else
			-- It is outside of my current context...invoke.
			HintCallbackScript.Call_Function("Hint_Activation_Callback", hint_id)
			return
		end
		
	end	
end


-------------------------------------------------------------------------------
-- Should only be called from the scene scripts that implement the actual
-- hints.
-------------------------------------------------------------------------------
function _PG_Hint_Invoke_Dismissal_Callback(event, source, hint_id)

	-- If the hint callback has been set, we'll attempt to invoke the callback.
	if (HintCallbackScript ~= nil) then
	
		-- Is the hint callback script my current context?
		if (HintCallbackScript == Script) then
			-- The callback is in my current context...if the function is implemented, call it.
			if (Hint_Dismissal_Callback ~= nil) then
				-- Call it!
				Hint_Dismissal_Callback(hint_id)
				return
			end
		else
			-- It is outside of my current context...invoke.
			HintCallbackScript.Call_Function("Hint_Dismissal_Callback", hint_id)
			return
		end
		
	end
	
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_GUI_Hint_Screen_Position(attach_target)

	local posx, posy = Get_Attachment_Point(attach_target)
	if ((posx == nil) or (posy == nil) or (posx < 0) or (posx > 1) or (posy < 0) or (posy > 1)) then
		DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_GUI_Hint -- Unable to compute center point of GUI element.  Falling back on screen position.")
		posx, posy = attach_target.Get_Screen_Position()
	end
	if ((posx == nil) or (posy == nil)) then
		DebugMessage("HINT_SYSTEM::_PG_Hint_Add_Attached_GUI_Hint -- Unable to position GUI hint: " .. tostring(hint_id) .. ".  Ignoring...")
		return nil
	end
	local map = { X = posx, Y = posy }
	return map
		
end


-------------------------------------------------------------------------------
-- Utility function.
-------------------------------------------------------------------------------
function Get_Attachment_Point(target)
	-- Maria 06.16.2007
	-- By design, we want the attachment point to the the upper right corner.
	if (target == nil) then
		return nil
	end
	local posx, posy
	local x, y, w, h = target.Get_World_Bounds()
	posx = x + w - 10.0/1024.0 
	posy = y + 10.0/768.0
	return posx, posy
end


-------------------------------------------------------------------------------------------------------------
-- *********************************************************************************************************
--  *************** SCENE-CONTEXTED EVENT RESPONDERS. *****************************************************
-- *********************************************************************************************************
-------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 01-30-2007
-- ------------------------------------------------------------------------------------------------------------------
--[[function On_Set_Independent_Hint_Scene(event, source, scene)
	_PG_Set_Independent_Hint_Scene(scene)
end--]]

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 03-27-2007
-- Register the hint activation callback.
-- ------------------------------------------------------------------------------------------------------------------
--[[function On_Register_Hint_Activation_Callback(event, source, script, callback)
	HintActivationScript = script
	HintActivationCB = callback
end--]]

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 03-27-2007
-- Register the hint dismissal callback.
-- ------------------------------------------------------------------------------------------------------------------
--[[function On_Register_Hint_Dismissal_Callback(event, source, script, callback)
	HintDismissalScript = script
	HintDismissalCB = callback
end--]]

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 01-19-2007
-- Event response that gets fired when a script decides to add a hint to the display system.
-- ------------------------------------------------------------------------------------------------------------------
function On_Add_Independent_Hint(event, source, hint_id)
	_PG_Hint_Add_Independent_Hint(hint_id)
end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 02-14-2007
-- Event response that gets fired when a script decides to add a hint to a game object.
-- ------------------------------------------------------------------------------------------------------------------
function On_Add_Attached_Hint(event, source, game_object, hint_id)
	_PG_Hint_Add_Attached_Hint(game_object, hint_id)
end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 03-23-2007
-- Event response that gets fired when a script decides to add a hint to a GUI element.
-- ------------------------------------------------------------------------------------------------------------------
function On_Add_Attached_GUI_Hint(event, source, target_find_id, target_find_arg, hint_id)
	_PG_Hint_Add_Attached_GUI_Hint(target_find_id, target_find_arg, hint_id)
end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 01-19-2007
-- Event response that gets fired when a user clicks on a hint icon.
-- ------------------------------------------------------------------------------------------------------------------
function On_Select_Hint(event, source, hint_id)
	_PG_Hint_Show_Independent_Hint_Text(hint_id)
	--_PG_Hint_Invoke_Activation_Callback(nil, nil, hint_id)
end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 01-19-2007
-- Event response that gets fired when a user dismisses an independent hint.
-- ------------------------------------------------------------------------------------------------------------------
function On_Remove_Independent_Hint(event, source, hint_id)
	Hide_Hint_Text()
	_PG_Hint_Remove_Independent_Hint(hint_id)
end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 02-14-2007
-- Event response that gets fired when a user dismisses an attached hint.
-- ------------------------------------------------------------------------------------------------------------------
function On_Remove_Attached_Hint(event, source, hint_id)
	_PG_Hint_Remove_Attached_Hint(hint_id)
end

-- ------------------------------------------------------------------------------------------------------------------
-- JLH 01-19-2007
-- Event response that gets fired when a script calls for the cleanup of the hint system.
-- ------------------------------------------------------------------------------------------------------------------
function On_Cleanup_Hint_System(event, source, args)
	Cleanup_Hint_System()
end

function Pre_Save_Callback()
	HintSystemContextScene = nil
end

