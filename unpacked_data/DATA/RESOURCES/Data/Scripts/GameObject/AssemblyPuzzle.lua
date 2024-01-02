-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AssemblyPuzzle.lua#24 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/AssemblyPuzzle.lua $
--
--    Original Author: Oksana Kubushyna
--
--            $Author: Mike_Lytle $
--
--            $Change: 88294 $
--
--          $DateTime: 2007/11/26 15:13:37 $
--
--          $Revision: #24 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")
require("WalkerPuzzleCommon")

local my_behavior = {
	Name = _REQUIREDNAME
}


-- Assembly Hardpoint heirarchy
-- + = Replacement hardpoint when destroyed.
--
-- BASE
--    CROWN
--       CORE									-- Only damageable once at least one of the two shields (L and R), have been destroyed
--       +CORE_DESTROYED
--
--       FACE_CAP 							-- SOCKET - (destroyed reveals the core's hard point reticle but does not make it vulnerable)
--       +FACE_CAP_DESTROYED
--
--       LEFT_ARM_00 						-- SOCKET
--       +LEFT_ARM_00_DESTROYED
--       LEFT_ARM_01 						-- SOCKET
--       +LEFT_ARM_01_DESTROYED
--
--       RIGHT_ARM_00 						-- SOCKET
--       +RIGHT_ARM_00_DESTROYED
--       RIGHT_ARM_01 						-- SOCKET
--       +RIGHT_ARM_01_DESTROYED
--
--       SHIELD_LEFT 						-- Only damageable once 2 left sockets have been destroyed
--       +SHIELD_LEFT_DESTROYED
--       SHIELD_RIGHT 						-- Only damageable once 2 right sockets have been destroyed
--       +SHIELD_RIGHT_DESTROYED
--
--    LEG_HP00 								-- SOCKET
--    +LEG_DAMAGE
--    LEG_HP01 								-- SOCKET
--    +LEG_DAMAGE
--    LEG_HP02 								-- SOCKET
--    +LEG_DAMAGE
--    LEG_HP03 								-- SOCKET
--    +LEG_DAMAGE

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	--create the matrix
	HP_Callback_Registration_Table = {}
	Production_Callback_Registration_Table = {}
	Air_Spike_Count = 0
	Common_Puzzle_Init()
	
	Object_Is_Dead = false
	
	Number_HP_Destruction_Threads = 0
	Walker_About_To_Die = false
	
	
	Death_Sequence_Level = 0
	HARDPOINTS_DEATH_SEQUENCE_TABLE = {	
		[1] = 
		{ 
		-- Empty list that get's filled with purchased hardpoints.
		},
		[2] = 
		{ 
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEG_HP00")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEG_HP01")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEG_HP02")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEG_HP03")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEFT_ARM_00")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_RIGHT_ARM_00")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_FACE_CAP")] = true		
		},
			
		[3] = 
		{ 
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_SHIELD_LEFT")] = true,
			[Find_Object_Type("ALIEN_WALKER_ASSEMBLY_SHIELD_RIGHT")] = true,
		}
	}
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()

	-- Make sure we're made aware when hardpoints are added to the walker
	Object.Register_Signal_Handler(my_behavior.On_HP_Attached, "OBJECT_HARDPOINT_ATTACHED")
	Object.Register_Signal_Handler(my_behavior.On_Production_Complete, "OBJECT_TACTICAL_CONSTRUCTION_COMPLETE")
	

	Core_Hard_Point = Object.Find_All_Hard_Points_Of_Type("Alien_Walker_Assembly_Core")
	Crown_Hard_Point = Object.Find_All_Hard_Points_Of_Type("Alien_Walker_Assembly_Crown")

	if Crown_Hard_Point and TestValid(Crown_Hard_Point[1]) then
		Crown_Hard_Point = Crown_Hard_Point[1]
	else
		MessageBox("Unable to find %s on %s!", "Alien_Walker_Assembly_Crown", tostring(Object));
		Crown_Hard_Point = nil
	end
	
	if Core_Hard_Point and TestValid(Core_Hard_Point[1]) then
		Core_Hard_Point = Core_Hard_Point[1]
	else
		MessageBox("Unable to find %s on %s!", "Alien_Walker_Assembly_Core", tostring(Object));
		Core_Hard_Point = nil
	end
	
	if Core_Hard_Point and Crown_Hard_Point then
		Core_Hard_Point.Make_Invulnerable(true)
		Crown_Hard_Point.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	end 
	
	
	HP_DESTRUCTION_FRAME = {
		[Core_Hard_Point] = 206,
		[Crown_Hard_Point] = 210
	}

	local player = nil

	HP_BUILDABLE_HARD_POINTS = Index_To_Key_Table(Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEG_HP00").Get_Tactical_Hardpoint_Upgrades(player, true, true))

	local back_hps = Index_To_Key_Table(Find_Object_Type("ALIEN_WALKER_ASSEMBLY_LEFT_ARM_00").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)
	back_hps = Index_To_Key_Table(Find_Object_Type("ALIEN_WALKER_ASSEMBLY_FACE_CAP").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)

	-- Add the buildable hardpoints to the death sequence 1 table.
	Table_Merge(HARDPOINTS_DEATH_SEQUENCE_TABLE[1], HP_BUILDABLE_HARD_POINTS)

	-- Kill the walker when the core is destroyed.
	MONITOR_DESTRUCTION_OF_HARDPOINTS = {}
	MONITOR_DESTRUCTION_OF_HARDPOINTS.ALIEN_WALKER_ASSEMBLY_CORE = { 
		current_killed_count = 0, 
		destroy_parent_on_killed_count = 1
	}

	-- Make the left shield vulnerable once the left arm has been destroyed
	MONITOR_DESTRUCTION_OF_HARDPOINTS.ALIEN_WALKER_ASSEMBLY_LEFT_ARM_00 = { 
		current_killed_count = 0, 
		objects_to_make_vulnerable = { [Find_Object_Type("ALIEN_WALKER_ASSEMBLY_SHIELD_LEFT")] = true },
		make_objects_vulnerable_on_killed_count = 1
	}
	

	-- Make the left shield vulnerable once the left arm has been destroyed
	MONITOR_DESTRUCTION_OF_HARDPOINTS.ALIEN_WALKER_ASSEMBLY_RIGHT_ARM_00 = { 
		current_killed_count = 0, 
		objects_to_make_vulnerable = { [Find_Object_Type("ALIEN_WALKER_ASSEMBLY_SHIELD_RIGHT")] = true },
		make_objects_vulnerable_on_killed_count = 1
	}

	CORE_DESTRUCTION_MONITOR  = {
		shields = {
			["ALIEN_WALKER_ASSEMBLY_SHIELD_RIGHT"] = true,
			["ALIEN_WALKER_ASSEMBLY_SHIELD_LEFT"] = true
		},
		cap = { ["ALIEN_WALKER_ASSEMBLY_FACE_CAP"] = true },
		shields_down_ct = 0,
		core_revealed = false,
		core_vulnerable = false
	}
	
	
	HP_INITIALLY_VULNERABLE = {
		["ALIEN_WALKER_ASSEMBLY_LEFT_ARM_00"] = true,
		["ALIEN_WALKER_ASSEMBLY_RIGHT_ARM_00"] = true,
		["ALIEN_WALKER_ASSEMBLY_FACE_CAP"] = true,
		["ALIEN_WALKER_ASSEMBLY_LEG_HP00"] = true,
		["ALIEN_WALKER_ASSEMBLY_LEG_HP01"] = true,
		["ALIEN_WALKER_ASSEMBLY_LEG_HP02"] = true,
		["ALIEN_WALKER_ASSEMBLY_LEG_HP03"] = true
	}
	
	HP_MADE_INVULNERABLE_BY_ATTACHMENT = 
	{
		["ALIEN_WALKER_ASSEMBLY_CORE_DESTROYED"] = true,
		["ALIEN_WALKER_ASSEMBLY_FACE_CAP_DESTROYED"] = true,
		["ALIEN_WALKER_ASSEMBLY_LEFT_ARM_00_DESTROYED"] = true,
		["ALIEN_WALKER_ASSEMBLY_RIGHT_ARM_00_DESTROYED"] = true,
		["ALIEN_WALKER_ASSEMBLY_SHIELD_LEFT_DESTROYED"] = true,
		["ALIEN_WALKER_ASSEMBLY_SHIELD_RIGHT_DESTROYED"] = true,
		["ALIEN_WALKER_ASSEMBLY_CROWN_DAMAGED"] = true,
		["ALIEN_WALKER_ASSEMBLY_LEG_DAMAGE"] = true,
	}
	
	--We will mointor destruction manually
	Object.Make_Invulnerable(true)
	Object.Set_Cannot_Be_Killed(true)
	
	-- Find all existing HP and listen for their destruction if required
	local hardpoints = Object.Get_All_Hard_Points()
	if hardpoints then
		for _, hp in pairs(hardpoints) do
		
			--JSY: Disable GUI behavior by default.  That way our possible call to Enable_Behavior below is not
			--in danger of undoing somebody else's call to disable (e.g. story script)
			hp.Enable_Behavior(BEHAVIOR_GUI, false)		
		
			-- Assign vulnerability
			if HP_INITIALLY_VULNERABLE[hp.Get_Type().Get_Name()] then
				hp.Enable_Behavior(BEHAVIOR_GUI, true)
				hp.Make_Invulnerable(false)
				hp.Set_Cannot_Be_Killed(false)
			else
				hp.Make_Invulnerable(true)
				hp.Set_Cannot_Be_Killed(true)
			end
		end
		for _, hp in pairs(hardpoints) do
			my_behavior.On_HP_Attached(Object, hp)
		end
	end
	
end
 
 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- A new HP has been attached to the object - check if we are interested in monitoring this hardpoint
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_On_HP_Attached(source, new_obj)
	if source == nil then
		return
	end

	--eh... just register all of them!
	new_obj.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	
	-- Maria 11.28.2006 - the hp has been sold and thus detached from the socket!
	new_obj.Register_Signal_Handler(my_behavior.On_HP_Detached, "OBJECT_HARDPOINT_DETACHED")

	if HP_MADE_INVULNERABLE_BY_ATTACHMENT[new_obj.Get_Type().Get_Name()] then
		new_obj.Make_Invulnerable(true)
		new_obj.Set_Cannot_Be_Killed(true)
	end

	-- Switch our targeting priorites when the air spike is added so we can attack air targets.
	if new_obj.Get_Type().Get_Name() == "ALIEN_WALKER_ASSEMBLY_HP_ARC_TRIGGER" then
		Air_Spike_Count = Air_Spike_Count + 1
	end

	if Air_Spike_Count == 1 then
		Object.Set_Targeting_Priorities("Alien_Assembly_Walker_With_Air_Spike_Target_Priority")
	end

	local parent_hp = new_obj.Get_Hard_Point_Parent()
	if parent_hp then	
		if HP_BUILDABLE_HARD_POINTS[new_obj.Get_Type()] then
			if parent_hp and parent_hp ~= Object then
				parent_hp.Enable_Behavior(BEHAVIOR_GUI, false)
				parent_hp.Make_Invulnerable(true)
				parent_hp.Set_Cannot_Be_Killed(true)
			end
		end 
	end

	if Walker_About_To_Die then
		new_obj.Set_Selectable(false)
		new_obj.Set_In_Limbo(true)
	end
		
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- A  HP of interest has been destroyed - see if it's time to destroy the parent
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_On_HP_Destroyed(source)
	
	for hp_type, call_table in pairs(HP_Callback_Registration_Table) do
		if source.Get_Type() == hp_type then 
			for _, call_item in pairs(call_table) do
				call_item[1].Call_Function(call_item[2], source)
			end
		end
	end

	if Walker_About_To_Die then
		return
	end

	-- Switch our targeting priorites when the air spike is added so we can attack air targets.
	if source.Get_Type().Get_Name() == "ALIEN_WALKER_ASSEMBLY_HP_ARC_TRIGGER" then
		if Air_Spike_Count > 0 then
			Air_Spike_Count = Air_Spike_Count - 1
		end
	end

	if Air_Spike_Count == 0 then
		Object.Set_Targeting_Priorities("Alien_Assembly_Walker_Target_Priority")
	end

	local parent_hp = source.Get_Hard_Point_Parent()
	local hp_type = source.Get_Type()
	local hp_name = hp_type.Get_Name()
	
	-- for now just assume we need to destroy the parent... later here will be additional conditions
	-- and we will need to check which conditionds this destroyed hp belongs to
	local damage_table = MONITOR_DESTRUCTION_OF_HARDPOINTS[hp_name]
	if damage_table and damage_table.destroy_parent_on_killed_count then
		damage_table.current_killed_count = damage_table.current_killed_count + 1
		
		-- Play over-heating effect
		if damage_table.play_cinematic_anim_hp == true and Crown_Hard_Point then
				Crown_Hard_Point.Play_Animation("Anim_Cinematic", true, damage_table.current_killed_count-1)
		end
			
		--shall we kill the parent?
		if damage_table.destroy_parent_on_killed_count > 0 and not Object_Is_Dead then
			if damage_table.current_killed_count == damage_table.destroy_parent_on_killed_count then
				Object_Is_Dead = true
				
				Final_Blow_Info = source.Get_Final_Blow_Info()
				if Final_Blow_Info then
					if Final_Blow_Info[1] then
						Final_Blow_Player =  Final_Blow_Info[1]
					end
					
					if Final_Blow_Info[2] then
						Final_Blow_Object_Type =  Final_Blow_Info[2]
					end
				end
				
				Create_Thread("Thread_Walker_Death")
			end
		end
	elseif damage_table and damage_table.make_objects_vulnerable_on_killed_count then
		damage_table.current_killed_count = damage_table.current_killed_count + 1
	
		-- Play over-heating effect
		if damage_table.play_cinematic_anim_hp == true and Crown_Hard_Point then
				Crown_Hard_Point.Play_Animation("Anim_Cinematic", true, damage_table.current_killed_count-1)
		end
		
		-- make other object vulnerable now?
		if damage_table.make_objects_vulnerable_on_killed_count > 0 and not Object_Is_Dead then
			if damage_table.current_killed_count == damage_table.make_objects_vulnerable_on_killed_count then
				for type,_ in pairs(damage_table.objects_to_make_vulnerable) do
					local hp = Object.Find_All_Hard_Points_Of_Type(type)
					if hp and TestValid(hp[1]) then
						hp = hp[1]
						hp.Enable_Behavior(BEHAVIOR_GUI, true)
						hp.Make_Invulnerable(false)
						hp.Set_Cannot_Be_Killed(false)					
					else
						MessageBox("Unable to find %s on %s!", tostring(type), tostring(Object));
					end
				end
			end
		end
	elseif CORE_DESTRUCTION_MONITOR.shields[hp_name] or CORE_DESTRUCTION_MONITOR.cap[hp_name] then		
		
		if CORE_DESTRUCTION_MONITOR.core_vulnerable == false or CORE_DESTRUCTION_MONITOR.core_revealed == false then
			if CORE_DESTRUCTION_MONITOR.shields[hp_name] then
				CORE_DESTRUCTION_MONITOR.shields[hp_name] = nil
				CORE_DESTRUCTION_MONITOR.shields_down_ct = CORE_DESTRUCTION_MONITOR.shields_down_ct + 1
			elseif CORE_DESTRUCTION_MONITOR.cap[hp_name] then 
				-- the cap is down so let's reveal the core's UI
				CORE_DESTRUCTION_MONITOR.cap[hp_name] = nil	
				Core_Hard_Point.Enable_Behavior(BEHAVIOR_GUI, true)			
				CORE_DESTRUCTION_MONITOR.core_revealed = true
			end
			
			-- if the cap is down and at least one of the shields is down we make it vulnerable.
			if CORE_DESTRUCTION_MONITOR.core_vulnerable == false and 
			   CORE_DESTRUCTION_MONITOR.core_revealed == true and 
			   CORE_DESTRUCTION_MONITOR.shields_down_ct >= 2 then 
				Core_Hard_Point.Make_Invulnerable(false)
				Core_Hard_Point.Set_Cannot_Be_Killed(false)
				CORE_DESTRUCTION_MONITOR.core_vulnerable = true
			end
		end
	end
	
	if parent_hp then	
		if HP_BUILDABLE_HARD_POINTS[hp_type] then
			if parent_hp and parent_hp ~= Object then
				parent_hp.Enable_Behavior(BEHAVIOR_GUI, true)
				parent_hp.Make_Invulnerable(false)
				parent_hp.Set_Cannot_Be_Killed(false)
			end
		end
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- A  HP of interest has been detached from the parent
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_On_HP_Detached(source)
	-- this signal is sent when the object has been sold and thus does not exist on the socket anymore.
	-- Since at attachement we disabled the socket's GUI behavior, we need to enable it back on detachement to 
	-- keep the disable count balanced.
	local parent_hp = source.Get_Hard_Point_Parent()
	if parent_hp then	
		if HP_BUILDABLE_HARD_POINTS[source.Get_Type()] then
			if parent_hp and parent_hp ~= Object then
				parent_hp.Enable_Behavior(BEHAVIOR_GUI, true)
			end
		end 
	end
end


function Kill_HP_Chain_Recursive( root_hardpoint )
	if TestValid(root_hardpoint) then	
		
		local attached_hardpoints = root_hardpoint.Get_All_Hard_Points()
		if attached_hardpoints then
			for _, hp in pairs(attached_hardpoints) do
				if TestValid(hp) and hp.Get_Hard_Point_Parent() == root_hardpoint then
					Kill_HP_Chain_Recursive(hp)
				end
			end
		end
			
		if TestValid(root_hardpoint) then	
		
			local death_table = HARDPOINTS_DEATH_SEQUENCE_TABLE[Death_Sequence_Level]
			if death_table then
				local root_parent = root_hardpoint.Get_Hard_Point_Parent()
				if death_table[root_hardpoint.Get_Type()] or ( root_parent and 
						death_table[root_parent.Get_Type()] ) then
					--kill the hardpoint only if it's in the death table at current death sequence level
					root_hardpoint.Set_In_Limbo(false)
					Destroy_Walker_Object(root_hardpoint, Final_Blow_Player, Final_Blow_Object_Type)  -- kill it
					Sleep(0.5)
				end
			end
		end
	end

end


function Thread_Walker_Destroy_Hardpoint_Chain( root_hardpoint)
	
	Kill_HP_Chain_Recursive(root_hardpoint)
	
	Number_HP_Destruction_Threads = Number_HP_Destruction_Threads - 1
end



function Thread_Walker_Death()

	Object.Suspend_Locomotor(true)
	Object.Prevent_All_Fire(true)
	Object.Set_Selectable(false)
	Object.Set_In_Limbo(true)
	Object.Enable_Behavior(BEHAVIOR_IDLE, false)

	Walker_About_To_Die = true

	-- stop all production on this walker
	Object.Tactical_Enabler_Stop_All_Production()

	if WalkerDeathCallbacks then
		for _,item in ipairs(WalkerDeathCallbacks) do
			item[1].Call_Function(item[2], Object)
		end
		WalkerDeathCallbacks = nil
	end

	local hardpoints = Object.Get_All_Hard_Points()
	if hardpoints then
		for _, hp in pairs(hardpoints) do
			hp.Set_Selectable(false)
			hp.Set_In_Limbo(true)
		end
	end
	
	local old_rate = ServiceRate
	ServiceRate = 0.01
	anim_block = Object.Play_Animation("Anim_Cinematic", false, 1)
   
	for level,_ in ipairs(HARDPOINTS_DEATH_SEQUENCE_TABLE) do
			
			Death_Sequence_Level = level
			hardpoints = Object.Get_All_Hard_Points()
			if hardpoints then
				for _, hp in pairs(hardpoints) do
					if TestValid(hp) then --and hp.Get_Hard_Point_Parent() == Object then
						Create_Thread("Thread_Walker_Destroy_Hardpoint_Chain",hp )
						Number_HP_Destruction_Threads = Number_HP_Destruction_Threads+1
						Sleep(0.2)
						ServiceRate = 0.01
					end
				end
			end
			
			while Number_HP_Destruction_Threads > 0 do
				Sleep(0.0001)
				ServiceRate = 0.01
			end
			
	end

	local frame, name = Object.Get_Active_Animation_Frame()
	if name == "Anim_Cinematic" then 
		BlockOnCommand(anim_block)
	end
	
	ServiceRate = old_rate
	--Ready to blow up yet?
	--ok, all the hardpoints gone, destroy the unit itself
	Object.Set_In_Limbo(false)
	Destroy_Walker_Object(Object, Final_Blow_Player, Final_Blow_Object_Type)   -- kill it
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.On_HP_Attached = Behavior_On_HP_Attached
my_behavior.On_HP_Detached = Behavior_On_HP_Detached
my_behavior.On_HP_Destroyed = Behavior_On_HP_Destroyed
my_behavior.On_Production_Complete = Behavior_On_Production_Complete
my_behavior.Clean_Up = Common_Puzzle_Clean_Up

-- my_behavior.Get_Num_Monitored_HP_Killed = Behavior_Get_Num_Monitored_HP_Killed

-- my_behavior.Object_In_Range = Behavior_Object_In_Range
-- my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
