if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[155] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[123] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Walker_HardPoint_Scene.lua#27 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Walker_HardPoint_Scene.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 92709 $
--
--          $DateTime: 2008/02/07 11:33:41 $
--
--          $Revision: #27 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Maria 12.13.2007
	-- IMPORTANT: The Object is always a base hard point socket!!!!!!.
	
	if not TestValid(Object) or not this then 
		return
	end
	
	
	--EMP 7/25/07
	--Events for disabling walker hardpoint GUI when hidden
	this.Register_Event_Handler("Component_Hidden", this, Disable_UI_Element_Event)
	this.Register_Event_Handler("Component_Unhidden", this, Enable_UI_Element_Event)
	
	-- When in customization mode, the reticles are displayed bigger.
	CUSTOMIZATION_SCALE = 1.0	
	
	-- Let's keep track of what's being built or has already been built on this socket.
	Set_GUI_Variable("UnderConstructionObject", nil)
	Set_GUI_Variable("ConstructedObject", nil)
	
	-- when a build is completed on a socket, there's a cooldown period during which nothing can be built on it again!.
	-- If the build menu is showing, we will display the cooldown as a red clock on top of the reticle and we will disable 
	-- all options.
	Set_GUI_Variable("LastCooldownLeft", 0)
	Set_GUI_Variable("Customizing", false)
	
	this.Reticle.Set_Hidden(false)
	this.ConfigurationMenu.Init_Radial_Menu_Scene(Object)
	
	-- Register for mouse events on the reticle.
	this.Register_Event_Handler("Selectable_Icon_Clicked", this.Reticle, On_HP_Reticle_Left_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Right_Clicked", this.Reticle, On_HP_Reticle_Right_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Right_Double_Clicked", this.Reticle, On_HP_Reticle_Right_Double_Clicked)
	this.Register_Event_Handler("Mouse_Over_Selectable_Icon", this.Reticle, On_Mouse_Over_HP_Reticle)
	this.Register_Event_Handler("Mouse_Off_Selectable_Icon", this.Reticle, On_Mouse_Off_HP_Reticle)
	
	Set_GUI_Variable("WalkerCustomizationModeOn", false)
	Set_GUI_Variable("HighestLevelHPParent", nil)
	Set_GUI_Variable("Minimized", false)
	Set_GUI_Variable("ReticleOverlayUpdated", false)
	
	-- we need to know whether we are in SellMode or not so that we can process reticle clicks properly!
	Set_GUI_Variable("SellModeActive", false)
	this.Register_Event_Handler("Refresh_Sell_Mode", nil, On_Refresh_Sell_Mode)
	
	-- Maria 12.13.2007: not all sockets can build objects on them (eg. the cooling nodes of a habitat walker, etc)
	local can_be_customized = Object.Has_Behavior(38)
	Set_GUI_Variable("CanBeCustomized", can_be_customized)
	
	-- Set the clock tint to red
	CooldownTint = {1.0, 0.0, 0.0, 110.0/255.0}
	BuildProgressTint = {0.0, 1.0, 0.0, 110.0/255.0}
	Reset_Clock_State()
	
	EmptySocketTexture = "i_alien_hp_center_ring_qust.tga"
	
	if can_be_customized then
		Object.Register_Signal_Handler(On_Hard_Point_Attached, "OBJECT_HARDPOINT_ATTACHED", this)
		Object.Register_Signal_Handler(On_Owner_Changed, "OBJECT_OWNER_CHANGED", this)		
		
		this.Register_Event_Handler("Start_Walker_Customization_Mode", nil, On_Start_Walker_Customization_Mode)	
		this.Register_Event_Handler("End_Walker_Customization_Mode", nil, On_End_Walker_Customization_Mode)	
		this.Register_Event_Handler("HP_Selection_Changed", nil, On_HP_Selection_Changed)	
		
		-- Make sure we always enable the GUI behavior of this guy if it is a socket that can build
		-- HPs.
		Object.Enable_Behavior(85, true)
	end
	
	-- Set the tooltip data for this reticle.
	this.Reticle.Set_Tooltip_Data({'object', {Object}})
	
	Set_GUI_Variable("Initialized", true)
	Set_GUI_Variable("LastServiceTime", nil)
	
	LetterBoxModeOn = false
	this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	
	--Need to know about selection changes so we can update cursor context on the reticle
	Set_GUI_Variable("MouseOverReticle", false)
	this.Register_Event_Handler("Selection_Changed", nil, On_Selection_Changed)
	this.Register_Event_Handler("Reset_Last_Service", nil, On_Reset_Last_Service)
	
	-- For walkers that are spawned customized.
	local existing_hp_table = Object.Get_All_Hard_Points()
	if existing_hp_table then
		for _, hp in pairs(existing_hp_table) do
			On_Hard_Point_Attached(Object, hp)
		end
	end	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Owner_Changed
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Owner_Changed()
	if TestValid(this.ConfigurationMenu) then
		this.ConfigurationMenu.Owner_Changed()
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Reset_Last_Service
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Reset_Last_Service(event, source, val)
	Set_GUI_Variable("LastServiceTime", 0)
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(event, source, on_off)
	LetterBoxModeOn = on_off
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Refresh_Sell_Mode
-- ------------------------------------------------------------------------------------------------------------------
function On_Refresh_Sell_Mode(event, source, on_off)
	if Object.Get_Owner() == Find_Player("local") then 
		Set_GUI_Variable("SellModeActive", on_off)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Update_this_Data
-- ------------------------------------------------------------------------------------------------------------------
function On_Update_Scene_Data(event, source, object, custommode_onoff, minimized, sell_mode_active)
	
	Set_GUI_Variable("SellModeActive", sell_mode_active)
	
	if Get_GUI_Variable("CanBeCustomized") == false then 
		return
	end
	
	if not TestValid(object) then 
		return 
	end
	
	if Object ~= object then 
		return 
	end
	
	if not Get_GUI_Variable("HighestLevelHPParent") then 
		Set_GUI_Variable("HighestLevelHPParent", Object.Get_Highest_Level_Hard_Point_Parent())
	end
	
	Set_GUI_Variable("WalkerCustomizationModeOn", custommode_onoff)
	Set_GUI_Variable("Minimized", minimized)
	
	if Get_GUI_Variable("WalkerCustomizationModeOn") == true then 
		this.Set_Scale(CUSTOMIZATION_SCALE)
		this.Set_Enable_Rescaling(false)
	else
		this.Set_Enable_Rescaling(true)
	end

	if Get_GUI_Variable("Minimized") then 
		this.Reticle.Play_Animation("Minimize", false)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Reticle_Inactive - Make sure we reset any old sate and then update the reticle data accordingly
-- ------------------------------------------------------------------------------------------------------------------
function On_Reticle_Inactive()
	Reset_Reticle_State(true)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Reticle_State
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Reticle_State(all_states)
	
	if Get_GUI_Variable("CanBeCustomized") == false then 
		return
	end
	
	if not this or not TestValid(this.Reticle) then return end
	
	-- default = false
	if not all_states then all_states = false end
	
	if this.Reticle.Is_Selected() == true then 
		-- reset its sort value!
		this.Set_Sort_To_Front(false)
		-- de-select it
		this.Reticle.Set_Selected(false) 
		-- shrink the reticle back
		this.Reticle.Play_Animation("Zoom_Out", false)
		-- Close the radial menu if it is open.
		this.ConfigurationMenu.Close()
	end
	
	if all_states == true then 
		if Get_GUI_Variable("Minimized") then 
			this.Reticle.Play_Animation_Backwards("Minimize", false)
		end
		
		Set_GUI_Variable("Minimized", false)
	end	
	
	if not Get_GUI_Variable("UnderConstructionObject") then 
		-- Make sure the clock is empty
		this.Reticle.Set_Clock_Filled(0.0)
		Set_GUI_Variable("LastCooldownLeft", 0)
	end
	Set_GUI_Variable("Customizing", false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_HP_Selection_Changed
-- ------------------------------------------------------------------------------------------------------------------
function On_HP_Selection_Changed(event, source, new_selection, parent_object)
	
	if not Get_GUI_Variable("CanBeCustomized") then 
		return 
	end
	
	if new_selection == nil then 
		-- reset all reticles for there's no new choice!
		Reset_Reticle_State(true) -- true = reset all states
		
		-- We are resetting all the hp states so let's display those that were hidden!.
		this.Set_Hidden(false)
		Set_GUI_Variable("EnforceHiddenState", false)
	else
		if Get_GUI_Variable("HighestLevelHPParent") ~= parent_object then 
			return
		end
		
		-- reset the non-selected reticle(s)
		if Object ~= new_selection then 
			Reset_Reticle_State()
			this.Reticle.Play_Animation("Minimize", false)
			Set_GUI_Variable("Minimized", true)
			Set_GUI_Variable("CooldownLeft", 0)
			Set_GUI_Variable("Customizing", false)
			this.ConfigurationMenu.Enable_Menu(true)
			-- For the controller, we want the reticles to be hidden when a configuration menu is open!.
			this.Set_Hidden(true)
			Set_GUI_Variable("EnforceHiddenState", true)
		else
			if not this.Reticle.Is_Selected() then 
				this.Set_Sort_To_Front(true)
				
				-- Make sure the reticle is zoomed in!
				this.Reticle.Play_Animation("Zoom_In", false)
				
				-- Set this reticle as Selected (the reticle won't shrink while Selected)
				this.Reticle.Set_Selected(true)
			end
			Set_GUI_Variable("Customizing", true)
			
			-- Force an update so that the clock is properly updated and it doesnt pop up if
			-- the cooldown is running.
			Update_Reticle_Data(true) -- true = force update.			
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Construction_Progress
-- ------------------------------------------------------------------------------------------------------------------
function Update_Construction_Progress()
	this.Reticle.Set_Clock_Filled(1.0 - Get_Valid_Socket_Object().Get_Tactical_Build_Percent_Done())
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Cooldown_Progress
-- ------------------------------------------------------------------------------------------------------------------
function Update_Cooldown_Progress()
	local cooldown_left = 1.0 - Object.Get_Socket_Build_Cooldown_Progress()
	if cooldown_left > 0 then
		-- Update the clock contents
		this.Reticle.Set_Clock_Filled(cooldown_left)
		Set_GUI_Variable("LastCooldownLeft", cooldown_left)
		if this.ConfigurationMenu.Is_Menu_Enabled() == true then 
			this.ConfigurationMenu.Enable_Menu(false)
		end		
	elseif Get_GUI_Variable("LastCooldownLeft") ~= 0 then
		Set_GUI_Variable("LastCooldownLeft", 0)
		this.Reticle.Set_Clock_Filled(cooldown_left)	
		this.ConfigurationMenu.Enable_Menu(true)
	end				
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Health_Display
-- ------------------------------------------------------------------------------------------------------------------
function Update_Health_Display()
	-- Update the reticle's health bar 
	this.Reticle.Set_Health(Get_Valid_Socket_Object().Get_Hull())
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Reticle_Data - The this is active so we must update its state/data.
-- ------------------------------------------------------------------------------------------------------------------
function Update_Reticle_Data(force_update)

	if LetterBoxModeOn then
		if not this.Get_Hidden() then 
			this.Set_Hidden(true)
		end
	elseif this.Get_Hidden() and not Get_GUI_Variable("EnforceHiddenState") then 
		this.Set_Hidden(false)
	end

	local last_time = Get_GUI_Variable("LastServiceTime")
	local cur_time = GetCurrentTime()
	local nice_service_time = false
	if last_time == nil then 
		last_time = cur_time - 1
	end

	if cur_time - last_time > 1 then
		last_time = cur_time
		nice_service_time = true
	end
	
	if force_update then
		nice_service_time = true
	end
	
	Set_GUI_Variable("LastServiceTime", last_time)
	
	if TestValid(Object) and Get_GUI_Variable("Initialized") and nice_service_time then
		if not TestValid(Get_GUI_Variable("HighestLevelHPParent")) then
			Set_GUI_Variable("HighestLevelHPParent", Object.Get_Highest_Level_Hard_Point_Parent())
		end
		
		-- do we need to display the crown reticle overlay?
		Update_Reticle_Overlay()
		
		if TestValid(this.Reticle) then 
			Update_Health_Display()
			
			if TestValid(Get_GUI_Variable("UnderConstructionObject")) then 
				-- if we are on object under construction we must update our progress.
				Update_Construction_Progress()					
			elseif Get_GUI_Variable("Customizing") then 
				-- are we customizing (ie have the build menu open) this socket?
				-- if so, let's update the build cooldown (if any)
				Update_Cooldown_Progress()
			end
		end
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Reticle_Overlay
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Reticle_Overlay()
	
	if Get_GUI_Variable("ReticleOverlayUpdated") then 
		return 
	end
	
	if TestValid(Object) then 
		-- If we are a leg hard point, we don't need the crown overlay!
		local socket_type_name = Object.Get_Type().Get_HP_Socket_Type()
		if socket_type_name then
			local leg_hp = (string.find(socket_type_name, "Leg_") ~= nil)
			this.Reticle.Show_Crown_Overlay(not leg_hp)		
		end
		Set_GUI_Variable("ReticleOverlayUpdated", true)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_HP_Reticle_Right_Clicked
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_HP_Reticle_Right_Clicked(event, source)
	local owner = Object.Get_Owner()
	local local_player = Find_Player("local")
	if owner.Is_Enemy(local_player) then
		if this.Get_Mouse_Pointer() == 15 then
			GUI_Attack_Target_Object_With_Selected_Objects(Get_Valid_Socket_Object())
		end
	elseif owner == local_player then 
	
		if Get_GUI_Variable("SellModeActive") then
			-- RIGHT CLICKING ANYWHERE, CANCELS THE CLICK/SELL MODE.
			-- This will cause Sell Mode to be canceled!.
			Raise_Event_All_Scenes("End_Sell_Mode", {})
			return
		else
			if not Get_GUI_Variable("CanBeCustomized") then
				return 
			end
			
			if Get_GUI_Variable("WalkerCustomizationModeOn") and TestValid(Get_GUI_Variable("UnderConstructionObject")) then 
				if Object.Can_Cancel_Build() then 
					Send_GUI_Network_Event("Network_Cancel_Build_Hard_Point", { Object, local_player })
				else 
					Play_SFX_Event("GUI_Generic_Bad_Sound") 
				end
			end
		end
	end	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Get_Valid_Socket_Object
-- -------------------------------------------------------------------------------------------------------------------------------------
function Get_Valid_Socket_Object()
	if TestValid(Get_GUI_Variable("UnderConstructionObject")) then
		return Get_GUI_Variable("UnderConstructionObject")
	elseif TestValid(Get_GUI_Variable("ConstructedObject")) then
		return Get_GUI_Variable("ConstructedObject")
	end
	
	return Object
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Get_Valid_Socket_Object
-- -------------------------------------------------------------------------------------------------------------------------------------
function Get_Valid_Socket_Object()
	if TestValid(Get_GUI_Variable("UnderConstructionObject")) then
		return Get_GUI_Variable("UnderConstructionObject")
	elseif TestValid(Get_GUI_Variable("ConstructedObject")) then
		return Get_GUI_Variable("ConstructedObject")
	end
	
	return Object
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_HP_Reticle_Right_Double_Clicked
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_HP_Reticle_Right_Double_Clicked(event, source)
	local owner = Object.Get_Owner()
	local local_player = Find_Player("local")
	if owner.Is_Enemy(local_player) then
		if this.Get_Mouse_Pointer() == 15 then
			-- The hierarchy of the sockets is such that whatever is built (or being built) on the socket
			-- takes damage.  The socket can only be attacked if it is empty.
			GUI_Attack_Target_Object_With_Selected_Objects(Get_Valid_Socket_Object(), "No_Formup");
		end
	end	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Maria 08.16.2006
-- Single left click on an walker hard point selects the walker. 
-- We have clicked on a hard point.  If we are the local player, we must select the parent object.
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_HP_Reticle_Left_Clicked(event, source)

	if Object.Get_Owner() == Find_Player("local") then

		-- If we are in Custmization mode let us not allow the hard point to be individually selected for 
		-- we cannot keep its reticle up if we move away from the walker (which happens when we try to make
		-- a build selection for the specified socket.
		--if not WalkerCustomizationModeOn then 
		-- usual left click on a socket/hard point
		Hard_Point_Left_Clicked( {Get_Valid_Socket_Object()} )
		if Get_GUI_Variable("CanBeCustomized") and not Get_GUI_Variable("SellModeActive") then
			Possibly_Setup_Hardpoint_For_Configuration()
		end		
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Possibly_Setup_Hardpoint_For_Configuration
-- -------------------------------------------------------------------------------------------------------------------------------------
function Possibly_Setup_Hardpoint_For_Configuration()
	
	if not Get_GUI_Variable("CanBeCustomized") then 
		return 
	end
	
	if this.Reticle.Is_Selected() == true then 
		-- There may be some other reticle selected so let us reset it!.
		Raise_Event_All_Scenes("HP_Selection_Changed", nil)
	else -- if not Object.Has_Behavior(39) then 
		
		if not Get_GUI_Variable("HighestLevelHPParent") then 
			Set_GUI_Variable("HighestLevelHPParent", Object.Get_Highest_Level_Hard_Point_Parent())
		end
		
		if not TestValid(Get_GUI_Variable("HighestLevelHPParent")) then 
			return 
		end
		
		-- if we are not already in customization mode, let's start it!.
		if not Get_GUI_Variable("WalkerCustomizationModeOn") then 
			Raise_Event_All_Scenes("Start_Walker_Customization_Mode", {Get_GUI_Variable("HighestLevelHPParent")})		
		end
		
		-- open the build options for this hard-point socket
		this.ConfigurationMenu.Display_Menu()	
		
		-- There may be some other reticle selected so let us reset it!.
		Raise_Event_All_Scenes("HP_Selection_Changed", {Object, Get_GUI_Variable("HighestLevelHPParent")})
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over_HP_Reticle
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Over_HP_Reticle(event, source)
	local owner = Object.Get_Owner()
	local local_player = Find_Player("local")
	local valid_socket_object = Get_Valid_Socket_Object()
	if owner.Is_Enemy(local_player) then
		--Verify that something in the selection list can attack this hard point
		local selected_objects = Get_Selected_Objects()
		local can_attack = false
		for _, selected_object in pairs(selected_objects) do
			if selected_object.Is_Suitable_Target(valid_socket_object) then
				can_attack = true
				break
			end
		end
		if can_attack then
			this.Set_Mouse_Pointer(15)
		else
			this.Set_Mouse_Pointer(0)
		end
	else
		if Get_GUI_Variable("SellModeActive") then
			if valid_socket_object.Can_Object_Be_Sold() then
				this.Set_Mouse_Pointer(29)
			else
				this.Set_Mouse_Pointer(30)
			end
		else
			this.Set_Mouse_Pointer(0)
		end
	end
	this.Reticle.Play_Animation("Zoom_In", false)	
	Set_GUI_Variable("MouseOverReticle", true)
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_HP_Reticle
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off_HP_Reticle(event, source)
	if Object.Get_Owner() == Find_Player("local") then
		if not this.Reticle.Is_Selected() then 
			if Get_GUI_Variable("Minimized") then 
				this.Reticle.Play_Animation("Minimize", false)
			else
				this.Reticle.Play_Animation("Zoom_Out", false)
			end
		end
	else
		this.Reticle.Play_Animation("Zoom_Out", false)
	end
	Set_GUI_Variable("MouseOverReticle", false)
end



-- ************************************************************************************************************** --
--		 		HARD-POINT CUSTOMIZATION FUNCTIONS						         --
-- ************************************************************************************************************** --
-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Start_Walker_Customization_Mode - If this hard point is already selected, then its customization menu will
-- pop up.
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Start_Walker_Customization_Mode(event, source)
	if Object.Get_Owner() == Find_Player("local") then
		if not Get_GUI_Variable("CanBeCustomized") then 
			return 
		end
		
		Set_GUI_Variable("WalkerCustomizationModeOn", true)
		-- We do not want this thiss to rescale while in this mode (we want them all the same size!)
		-- So let's set its size to its maximum and disable rescaling.
		this.Set_Scale(CUSTOMIZATION_SCALE)
		this.Set_Enable_Rescaling(false)
	end		
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_End_Walker_Customization_Mode - 
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_End_Walker_Customization_Mode(event, source)
	if Object.Get_Owner() == Find_Player("local") then
		if not Get_GUI_Variable("CanBeCustomized") then 
			return 
		end
		
		Set_GUI_Variable("WalkerCustomizationModeOn", false)
		-- Enable rescaling
		Reset_Reticle_State(true)
		this.Set_Enable_Rescaling(true)
	end
end

-- ------------------------------------------------------------------------------------------------------
-- On_Hard_Point_Attached
-- ------------------------------------------------------------------------------------------------------
function On_Hard_Point_Attached(socket, new_hard_point)
	
	if socket ~= Object then 
		MessageBox("On_Hard_Point_Attached: the incoming socket object is not the same object that owns this scene.")
		return
	end
	
	if not TestValid(new_hard_point) then 
		return
	end
	
	new_hard_point.Register_Signal_Handler(On_Detach_Hard_Point, "OBJECT_HARDPOINT_DETACHED", this)
	new_hard_point.Register_Signal_Handler(On_Detach_Hard_Point, "OBJECT_HEALTH_AT_ZERO", this)
	
	this.Reticle.Set_Texture(new_hard_point.Get_Type().Get_Icon_Name())
	
	if new_hard_point.Has_Behavior(39) then
		-- Set the clock tint to green
		this.Reticle.Set_Clock_Tint(BuildProgressTint)
	
		-- Update the Under construction object pointer.
		Set_GUI_Variable("UnderConstructionObject", new_hard_point)
		
		-- Make sure we clear the constructed object spot!.
		Set_GUI_Variable("ConstructedObject", nil)
		
	elseif new_hard_point.Has_Behavior(40) then
	
		local parent = Object.Get_Highest_Level_Hard_Point_Parent()
		if parent ~= nil then 
			local game_mode_scene = Get_Game_Mode_GUI_Scene()
			if game_mode_scene then
				game_mode_scene.Raise_Event_Immediate("Hard_Point_Attachment", nil, {parent})			
			end
		end
		
		-- Update the Constructed object pointer.
		Set_GUI_Variable("ConstructedObject", new_hard_point)
		
		-- Make sure we clear the under constructuion object spot!.
		Set_GUI_Variable("UnderConstructionObject", nil)			
	end	
	
	-- Update the Tooltip Data for this reticle
	this.Reticle.Set_Tooltip_Data({'object', {new_hard_point}})		
	
	Update_Reticle_Display()	
end


-- -----------------------------------------------------------------------------------------------------
-- Reset_Clock_State
-- -----------------------------------------------------------------------------------------------------	
function Reset_Clock_State()
	this.Reticle.Set_Clock_Tint(CooldownTint)
	this.Reticle.Set_Clock_Filled(0.0)
end

-- -----------------------------------------------------------------------------------------------------
-- Update_Reticle_Display
-- -----------------------------------------------------------------------------------------------------
function Update_Reticle_Display()

	local uc_object = TestValid(Get_GUI_Variable("UnderConstructionObject"))
	local constructed_object = TestValid(Get_GUI_Variable("ConstructedObject"))
	
	if not uc_object then
		Reset_Clock_State()
	end
	
	if not uc_object and not constructed_object then
		this.Reticle.Set_Texture(EmptySocketTexture)
		
		-- Update the Tooltip Data for this reticle
		this.Reticle.Set_Tooltip_Data({'object', {Object}})
	end

	if this.Get_Current_State_Name() == "active" then
		-- let us force an update so that we don't have the clock/health popping.
		Update_Reticle_Data(true) -- true = force update.
	end
end


-- NEEDED TO UPDATE THE SPECIAL AB. BUTTONS WHEN THE WALKER IS SELECTED
-- -----------------------------------------------------------------------------------------------------
-- On_Detach_Hard_Point(generator,  data)
-- IMPORTANT: GENERATOR = object built on the socket
-- -----------------------------------------------------------------------------------------------------	
function On_Detach_Hard_Point(object_to_detach)
	
	if TestValid(object_to_detach) then
		local game_mode_scene = Get_Game_Mode_GUI_Scene()
		if game_mode_scene then
			game_mode_scene.Raise_Event_Immediate("Hard_Point_Detachment", nil, {Get_GUI_Variable("HighestLevelHPParent"), object_to_detach})
		end
		
		object_to_detach.Unregister_Signal_Handler(On_Detach_Hard_Point, this)			
	end	
	
	-- NOTE: if we are building a HP on top of an existing one we will get the HP attachement signal for the new HP before we get the HP 
	-- detachement signal for the old one.  Hence, we have to be careful clearing the object pointers here to make sure we don't override any 
	-- data set by the Attach HP signal.	
	if object_to_detach.Has_Behavior(39) then 
		local existing_uc_object = Get_GUI_Variable("UnderConstructionObject")
		if TestValid(existing_uc_object) and existing_uc_object == object_to_detach then
			Set_GUI_Variable("UnderConstructionObject", nil)
		end
	elseif object_to_detach.Has_Behavior(40) then
		local existing_built_object = Get_GUI_Variable("ConstructedObject")
		if TestValid(existing_built_object) and existing_built_object == object_to_detach then
			Set_GUI_Variable("ConstructedObject", nil)
		end
	end
	
	Update_Reticle_Display()
end


-- ------------------------------------------------------------------------------------------------------
-- On_Selection_Changed
-- ------------------------------------------------------------------------------------------------------
function On_Selection_Changed()
	if not Get_GUI_Variable("MouseOverReticle") then
		return
	end
	
	if not TestValid(Object) then return end
	
	--Mouse is over the reticle and selection changed.  May need to
	--update cursor to reflect new selection capabilities
	local owner = Object.Get_Owner()
	local local_player = Find_Player("local")
	if owner.Is_Enemy(local_player) then
		--Verify that something in the selection list can attack this hard point
		local selected_objects = Get_Selected_Objects()
		local can_attack = false
		for _, selected_object in pairs(selected_objects) do
			if selected_object.Is_Suitable_Target(Get_Valid_Socket_Object()) then
				can_attack = true
				break
			end
		end
		if can_attack then
			this.Set_Mouse_Pointer(15)
		else
			this.Set_Mouse_Pointer(0)
		end
	end	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	On_Update_Scene_Data = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
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
	Update_SA_Button_Text_Button = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

