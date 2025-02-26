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

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Walker_HardPoint_Scene.lua#15 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Walker_HardPoint_Scene.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 93547 $
--
--          $DateTime: 2008/02/16 17:47:02 $
--
--          $Revision: #15 $
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
	Set_GUI_Variable("CursorOverReticle", false)
	
	-- MARIA TODO!!!
	Set_GUI_Variable("HPSubSelectModeActive", false)
	this.Reticle.Set_Hidden(false)	
	this.Reticle.Hide_A_Button_Overlay(true)
	
	-- Register for mouse events on the reticle.
	this.Register_Event_Handler("Selectable_Icon_Clicked", this.Reticle, On_HP_Reticle_Left_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Right_Clicked", this.Reticle, On_HP_Reticle_Right_Clicked)
	this.Register_Event_Handler("Selectable_Icon_Right_Double_Clicked", this.Reticle, On_HP_Reticle_Right_Double_Clicked)
	
	this.Register_Event_Handler("HP_Sub_Selection_Changed", nil, On_HP_Sub_Selection_Changed)
	
	this.Register_Event_Handler("Gamepad_Cursor_Over_Reticle",nil, On_Gamepad_Cursor_Over_Reticle)
	this.Register_Event_Handler("Gamepad_Cursor_Off_Reticle", nil, On_Gamepad_Cursor_Off_Reticle)
	
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
	
		this.Register_Event_Handler("Start_Walker_Customization_Mode", nil, On_Start_Walker_Customization_Mode)	
		this.Register_Event_Handler("End_Walker_Customization_Mode", nil, On_End_Walker_Customization_Mode)	
		this.Register_Event_Handler("HP_Selection_Changed", nil, On_HP_Selection_Changed)	
		
		-- Since the menu scene is heavy, we only attach it to this scene if the HP is customizable and 
		-- is owned by the local player.
		-- We will also listen for change in Ownership to make sure the menu scene is added whenever 
		-- the object is owned by the local player.
		local scene_initial_size = {}
		scene_initial_size.x, scene_initial_size.y, scene_initial_size.w, scene_initial_size.h = this.Get_World_Bounds()
		Set_GUI_Variable("SceneOriginalSize", scene_initial_size)
		
		if Object.Get_Owner() == Find_Player("local") then
			Attach_HP_Configuration_Menu_Scene()
		else
			Object.Register_Signal_Handler(On_Owner_Changed, "OBJECT_OWNER_CHANGED", this)			
		end			
	end
	
	-- For debugging purposes we need to update the UI whenever the faction changes.
	this.Register_Event_Handler("Faction_Changed", nil, On_Owner_Changed)	
	
	Set_GUI_Variable("Initialized", true)
	Set_GUI_Variable("LastServiceTime", nil)
	
	LetterBoxModeOn = false
	this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	
	--Need to know about selection changes so we can update cursor context on the reticle
	Set_GUI_Variable("MouseOverReticle", false)
	this.Register_Event_Handler("Selection_Changed", nil, On_Selection_Changed)
	this.Register_Event_Handler("Reset_Last_Service", nil, On_Reset_Last_Service)

	this.Reticle.Set_Tab_Order(0)
	
	-- For walkers that are spawned customized.
	local existing_hp_table = Object.Get_All_Hard_Points()
	if existing_hp_table then
		for _, hp in pairs(existing_hp_table) do
			On_Hard_Point_Attached(Object, hp)
		end
	end	
	
	this.BackQuad.Set_Hidden(true)
end
	
-- -------------------------------------------------------------------------------------------------------------------------------------
-- Attach_HP_Configuration_Menu_Scene
-- -------------------------------------------------------------------------------------------------------------------------------------
function Attach_HP_Configuration_Menu_Scene()
	if not TestValid(this.ConfigurationMenu) then
		local new_scene = this.Create_Embedded_Scene("Gamepad_HP_Configuration_Radial_Menu_Scene", "ConfigurationMenu")	
		
		-- A right click anywhere translates to a cancel construction request.
		this.Register_Event_Handler("Buy_Menu_Right_Clicked", this.ConfigurationMenu, On_Cancel_Construction)
		
		-- Initialize the menu for this socket object.
		this.ConfigurationMenu.Init_Radial_Menu_Scene(Object)
		
		-- We also have to scale the thnigy
		local orig_size = Get_GUI_Variable("SceneOriginalSize")
		local curr_size = {}
		curr_size.x, curr_size.y, curr_size.w, curr_size.h = this.Get_World_Bounds()
		local new_scene_bds = {}
		new_scene_bds.x, new_scene_bds.y, new_scene_bds.w, new_scene_bds.h = new_scene.Get_World_Bounds()
		new_scene.Set_World_Bounds(new_scene_bds.x, new_scene_bds.y, new_scene_bds.w*(curr_size.w/orig_size.w), new_scene_bds.h*(curr_size.h/orig_size.h))
		
		-- Maria 02.16.2008 Per bug #998 (petro db)
		-- When the scene gets created on Init it is created at the upper left corner and then moved, if the attached scene is not created on init
		-- it will be created at the left uppermost corner but won't be moved unless we tell it so. (Note: if the embedded scene gets attached on
		-- init the whole thing will be positioned properly).
		new_scene.Set_Screen_Position(this.Get_Screen_Position())
	end	
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Owner_Changed
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Owner_Changed()
	if Object.Get_Owner() == Find_Player("local") then 
		Attach_HP_Configuration_Menu_Scene()
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
-- On_Reticle_Inactive - Make sure we reset any old sate and then update the reticle data accordingly
-- ------------------------------------------------------------------------------------------------------------------
function On_Reticle_Inactive()
	Reset_Reticle_State(true)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Reticle_State
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Reticle_State(all_states)
	
	if not Get_GUI_Variable("CanBeCustomized") then 
		return
	end
	
	if not this or not TestValid(this.Reticle) then 
		return 
	end
	
	-- default = false
	if not all_states then 
		all_states = false 
	end
	
	if this.Reticle.Is_Selected() then 
		-- reset its sort value!
		this.Set_Sort_To_Front(false)
		-- de-select it
		this.Reticle.Set_Selected(false) 
		-- shrink the reticle back
		this.Reticle.Play_Animation("Zoom_Out", false)
		-- Close the radial menu if it is open.
		
		if TestValid(this.ConfigurationMenu) then 
			this.ConfigurationMenu.Close()
			this.BackQuad.Set_Hidden(true)
		end
	end
	
	if all_states then 
		if Get_GUI_Variable("Minimized") then 
			this.Reticle.Play_Animation_Backwards("Minimize", false)
		end
		
		Set_GUI_Variable("Minimized", false)
		this.Set_Hidden(true)
	end	
	
	if not TestValid(Get_GUI_Variable("UnderConstructionObject")) then 
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
	
	if TestValid(new_selection) then 
		if Get_Parent_Object_Pointer() ~= parent_object then 
			return
		end
		
		-- reset the non-selected reticle(s)
		if Object ~= new_selection then 
			Reset_Reticle_State()
			this.Reticle.Play_Animation("Minimize", false)
			Set_GUI_Variable("Minimized", true)
			Set_GUI_Variable("CooldownLeft", 0)
			Set_GUI_Variable("Customizing", false)
			
			if TestValid(this.ConfigurationMenu) then 
--				this.ConfigurationMenu.Enable_Menu(true)
				this.ConfigurationMenu.Close()
				this.BackQuad.Set_Hidden(true)
			end
			
			-- For the controller, we want the reticles to be hidden when a configuration menu is open!.
			this.Set_Hidden(true)
			Set_GUI_Variable("EnforceHiddenState", true)
		else
			-- Make sure we are unhidden!.
			this.Set_Hidden(false)
		
			-- Maria 12.12.2007: If we don't enable the scene, updating the focus in the Build Menu will fail
			-- because the parent scene will be disabled.  So, by enabling it here we ensure that the focus will
			-- be set properly when the Build menu is displayed.
			this.Enable(true)
			
			-- Now that the scene is unhidden update the focus for the customization menu.
			if TestValid(this.ConfigurationMenu) and this.ConfigurationMenu.Is_Menu_Open() then
				this.ConfigurationMenu.Set_Focus()	
			end		
		
			if not this.Reticle.Is_Selected() then 
				this.Set_Sort_To_Front(true)
				
				-- Make sure the reticle is zoomed in!
				this.Reticle.Play_Animation("Zoom_In", false)
				
				-- Set this reticle as Selected (the reticle won't shrink while Selected)
				this.Reticle.Set_Selected(true)
			end
			Set_GUI_Variable("Customizing", true)
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Construction_Progress
-- ------------------------------------------------------------------------------------------------------------------
function Update_Construction_Progress()
	this.Reticle.Set_Clock_Filled(1.0 - Get_Valid_Socket_Object().Get_Tactical_Build_Percent_Done())
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

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Cooldown_Progress
-- ------------------------------------------------------------------------------------------------------------------
function Update_Cooldown_Progress()
	local cooldown_left = 1.0 - Object.Get_Socket_Build_Cooldown_Progress()
	if cooldown_left > 0 then
		-- Update the clock contents
		this.Reticle.Set_Clock_Filled(cooldown_left)
		Set_GUI_Variable("LastCooldownLeft", cooldown_left)
		if TestValid(this.ConfigurationMenu) and this.ConfigurationMenu.Is_Menu_Enabled() == true then 
			this.ConfigurationMenu.Enable_Menu(false)
		end		
	elseif Get_GUI_Variable("LastCooldownLeft") ~= 0 then
		Set_GUI_Variable("LastCooldownLeft", 0)
		this.Reticle.Set_Clock_Filled(cooldown_left)	
		if TestValid(this.ConfigurationMenu) then 
			this.ConfigurationMenu.Enable_Menu(true)
		end
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
-- This is equivalent to On_Update and it is only processed whenever the scene is in its active state.
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
	Set_GUI_Variable("LastServiceTime", last_time)
	
	if force_update then
		nice_service_time = true
	end	
	
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
			elseif Get_GUI_Variable("Customizing") == true then 
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
	
		if Get_GUI_Variable("SellModeActive") == true then
			-- RIGHT CLICKING ANYWHERE, CANCELS THE CLICK/SELL MODE.
			-- This will cause Sell Mode to be canceled!.
			Raise_Event_All_Scenes("End_Sell_Mode", {})
			return
		else
			Process_Cancel_Construction_Request()
		end
	end	
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Cancel_Construction
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Cancel_Construction(_, _)
	Process_Cancel_Construction_Request()
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_HP_Reticle_Right_Double_Clicked
-- -------------------------------------------------------------------------------------------------------------------------------------
function Process_Cancel_Construction_Request()
	if not Get_GUI_Variable("CanBeCustomized") then 
		return 
	end
	
	if TestValid(Get_GUI_Variable("UnderConstructionObject")) then 
		if Object.Can_Cancel_Build() then 
			Send_GUI_Network_Event("Network_Cancel_Build_Hard_Point", { Object, local_player })
		else 
			Play_SFX_Event("GUI_Generic_Bad_Sound") 
		end
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_HP_Reticle_Right_Double_Clicked
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_HP_Reticle_Right_Double_Clicked(event, source)
	local owner = Object.Get_Owner()
	local local_player = Find_Player("local")
	if owner.Is_Enemy(local_player) then
		if this.Get_Mouse_Pointer() == 15 then
			GUI_Attack_Target_Object_With_Selected_Objects(Get_Valid_Socket_Object(), "No_Formup");
		end
	end	
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_HP_Sub_Selection_Changed
-- Whenever a HP is sub-selected we have to proceed as we would if the player had left clicked on the hp.  That is, 
-- we need to open the sub-selected hp's customization menu and close any other menu that may be open.
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_HP_Sub_Selection_Changed(_, _)
	Process_Open_Customization_Menu_Request(true) -- true = activate_subselection
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Maria 08.16.2006
-- Single left click on an walker hard point selects the walker. 
-- We have clicked on a hard point.  If we are the local player, we must select the parent object.
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_HP_Reticle_Left_Clicked(event, source)
	Process_Open_Customization_Menu_Request(false)
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Get_Parent_Object_Pointer
-- -------------------------------------------------------------------------------------------------------------------------------------
function Get_Parent_Object_Pointer()
	
	local parent_object = Get_GUI_Variable("HighestLevelHPParent")
	if not TestValid(parent_object) then
		parent_object = Object.Get_Highest_Level_Hard_Point_Parent()
		Set_GUI_Variable("HighestLevelHPParent", parent_object)
	end
	return parent_object
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Process_Open_Customization_Menu_Request
-- -------------------------------------------------------------------------------------------------------------------------------------
function Process_Open_Customization_Menu_Request(activate_subselection)
	if Object.Get_Owner() == Find_Player("local") then

		-- If we are in Custmization mode let us not allow the hard point to be individually selected for 
		-- we cannot keep its reticle up if we move away from the walker (which happens when we try to make
		-- a build selection for the specified socket.
		--if not WalkerCustomizationModeOn then 
		-- usual left click on a socket/hard point
		Hard_Point_Left_Clicked( {Get_Valid_Socket_Object()} )
		-- Maria 12.13.2007
		-- For now, the customization menu should only come up if the walker is selected,  Otherwise, it becomes very difficult to 
		-- select the walker without opening any of the hard point menus.
		local parent_object = Get_Parent_Object_Pointer()
		
		-- Maria 12.15.2007
		-- If activate_subselection == true then we are requesting to open the menu from code and we know the 
		-- walker object is selected.  thus, we can bypass the selected check.  this is necessay because in certain
		-- cases the hp sub selection changed event may be processed before the select event that deals with selecting the 
		-- walker.  Then, we have to make sure we open the menu regardless of the selection state of the parent walker.
		if TestValid(parent_object) and (activate_subselection or parent_object.Is_Selected()) then
			if Get_GUI_Variable("CanBeCustomized") and not Get_GUI_Variable("SellModeActive") then
				Set_GUI_Variable("HPSubSelectModeActive", activate_subselection)
				Possibly_Setup_Hardpoint_For_Configuration()
			end		
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
		-- we have to let the handler know that a HP configuration menu is open!
		Controller_Set_HP_Configuration_Menu_Active(false)		
		
	else 
		-- MAKE SURE WE ARE ACTIVE!
		if this.Get_Current_State_Name() ~= "active" then
			this.Set_State("active")
		end
		
		this.Set_Hidden(false)
		this.Enable(true)
		
		local parent_object = Get_Parent_Object_Pointer()
		if not TestValid(parent_object) then 
			return 
		end
		
		-- if we are not already in customization mode, let's start it!.
		if not Get_GUI_Variable("WalkerCustomizationModeOn") then 
			Raise_Event_All_Scenes("Start_Walker_Customization_Mode", {parent_object})		
		end
		
		-- open the build options for this hard-point socket
		if TestValid(this.ConfigurationMenu) then 
			this.ConfigurationMenu.Display_Menu()	
			this.BackQuad.Set_Hidden(false)
		end	
		
		-- There may be some other reticle selected so let us reset it!.
		Raise_Event_All_Scenes("HP_Selection_Changed", {Object, parent_object})
		
		-- we have to let the handler know that a HP configuration menu is open!
		Controller_Set_HP_Configuration_Menu_Active(true, parent_object)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Gamepad_Cursor_Over_Reticle
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Gamepad_Cursor_Over_Reticle(event, source)

	if TestValid(Object) ~= true then return end

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
	else
		if Get_GUI_Variable("SellModeActive") then
			if Get_Valid_Socket_Object().Can_Object_Be_Sold() then
				this.Set_Mouse_Pointer(29)
			else
				this.Set_Mouse_Pointer(30)
			end
		else
			this.Set_Mouse_Pointer(0)
		end
	end
	Set_GUI_Variable("CursorOverReticle", true)
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Gamepad_Cursor_Off_Reticle
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Gamepad_Cursor_Off_Reticle(event, source)
	this.Reticle.Clear_Key_Focus()
	Set_GUI_Variable("CursorOverReticle", false)
end


-- ************************************************************************************************************** --
--		 		HARD-POINT CUSTOMIZATION FUNCTIONS						          --
-- ************************************************************************************************************** --
-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Start_Walker_Customization_Mode - If this hard point is already selected, then its customization menu will
-- pop up.
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Start_Walker_Customization_Mode(event, source, source_walker)
	if Object.Get_Owner() == Find_Player("local") then
		-- Maria 12.11.2007
		-- For the gamepad version, customization can only be done over the currently selected walker so let's not
		-- set all other walkers in customization mode, just the one the player is currently customizing.
		if Get_GUI_Variable("HighestLevelHPParent") and Get_Parent_Object_Pointer() == source_walker then
			if Get_GUI_Variable("CanBeCustomized") == false then return end
			Set_GUI_Variable("WalkerCustomizationModeOn", true)
			-- We do not want this thiss to rescale while in this mode (we want them all the same size!)
			-- So let's set its size to its maximum and disable rescaling.
			this.Set_Scale(CUSTOMIZATION_SCALE)
			this.Set_Enable_Rescaling(false)
		end
	end		
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_End_Walker_Customization_Mode - 
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_End_Walker_Customization_Mode(event, source)
	if Object.Get_Owner() == Find_Player("local") then
		Set_GUI_Variable("HPSubSelectModeActive", false)
		
		if not Get_GUI_Variable("CanBeCustomized") then 
			return 
		end
		
		Set_GUI_Variable("WalkerCustomizationModeOn", false)
		-- Enable rescaling
		Reset_Reticle_State(true)
		this.Set_Enable_Rescaling(true)		
	end
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
	end

	if this.Get_Current_State_Name() == "active" then
		-- let us force an update so that we don't have the clock/health popping.
		Update_Reticle_Data(true) -- true = force update
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
		
		if TestValid(this.ConfigurationMenu) then
			local built_type = new_hard_point.Get_Type().Get_Type_Value("Tactical_Buildable_Constructed")
			this.ConfigurationMenu.Update_Buttons_Overlay(new_hard_point.Get_Type().Get_Type_Value("Tactical_Buildable_Constructed"))
		end
	
	elseif new_hard_point.Has_Behavior(40) then
	
		local parent = Object.Get_Highest_Level_Hard_Point_Parent()
		if parent ~= nil then 
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Hard_Point_Attachment", nil, {parent})			
		end
		
		-- Update the Constructed object pointer.
		Set_GUI_Variable("ConstructedObject", new_hard_point)
		
		-- Make sure we clear the under constructuion object spot!.
		Set_GUI_Variable("UnderConstructionObject", nil)	

		if TestValid(this.ConfigurationMenu) then
			this.ConfigurationMenu.Update_Buttons_Overlay()
		end		
	end	
	
	Update_Reticle_Display(true) -- true = force update.	
end


-- NEEDED TO UPDATE THE SPECIAL AB. BUTTONS WHEN THE WALKER IS SELECTED
-- -----------------------------------------------------------------------------------------------------
-- On_Detach_Hard_Point(generator,  data)
-- IMPORTANT: GENERATOR = object built on the socket
-- -----------------------------------------------------------------------------------------------------	
function On_Detach_Hard_Point(object_to_detach)
	
	if TestValid(object_to_detach) then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Hard_Point_Detachment", nil, {Get_Parent_Object_Pointer(), object_to_detach})
		object_to_detach.Unregister_Signal_Handler(On_Detach_Hard_Point, this)			
	end	
	
	-- NOTE: if we are building a HP on top of an existing one we will get the HP attachement signal for the new HP before we get the HP 
	-- detachement signal for the old one.  Hence, we have to be careful clearing the object pointers here to make sure we don't override any 
	-- data set by the Attach HP signal.	
	if object_to_detach.Has_Behavior(39) then 
		local existing_uc_object = Get_GUI_Variable("UnderConstructionObject")
		if TestValid(existing_uc_object) and existing_uc_object == object_to_detach then
			Set_GUI_Variable("UnderConstructionObject", nil)
			if TestValid(this.ConfigurationMenu) then
				this.ConfigurationMenu.Update_Buttons_Overlay()
			end
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
-- On_Hard_Point_Attached
-- ------------------------------------------------------------------------------------------------------
function On_Selection_Changed()
	if not Get_GUI_Variable("CursorOverReticle") then
		return
	end
	
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

