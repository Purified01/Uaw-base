-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/WalkerPuzzle.lua#45 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/WalkerPuzzle.lua $
--
--    Original Author: Oksana Kubushyna
--
--            $Author: Brian_Hayes $
--
--            $Change: 82761 $
--
--          $DateTime: 2007/09/04 18:43:34 $
--
--          $Revision: #45 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")
require("WalkerPuzzleCommon")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	--create the matrix
	HP_Callback_Registration_Table = {}
	Production_Callback_Registration_Table = {}
	Common_Puzzle_Init()
	
	Object_Is_Dead = false
	Walker_About_To_Die = false
	
	Number_HP_Destruction_Threads = 0
	Number_Core_Destruction_Threads = 0
	Air_Spike_Count = 0
	
	
	Death_Sequence_Level = 0
	HARDPOINTS_DEATH_SEQUENCE_TABLE = {	
		[1] = 
		{ 
			[Find_Object_Type("PROTO_WALKER_HABITAT_LEG_HP00")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_LEG_HP01")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_LEG_HP02")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_LEG_HP03")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_HP00")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_HP01")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_HP02")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_HP03")] = true,
		},
			
		[2] = 
		{ 
-- 			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_DAMAGED_HP00")] = true,
-- 			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_DAMAGED_HP01")] = true,
-- 			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_DAMAGED_HP02")] = true,
-- 			[Find_Object_Type("PROTO_WALKER_HABITAT_BACK_DAMAGED_HP03")] = true,
		},
			
		[3] = 
		{ 
			[Find_Object_Type("PROTO_WALKER_HABITAT_COOLING_HP00")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_COOLING_HP01")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_COOLING_HP02")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_COOLING_HP03")] = true,
			[Find_Object_Type("PROTO_WALKER_HABITAT_CAP")] = true
		},
		
		
		--[4] = 
		--{
		--	["PROTO_WALKER_HABITAT_CROWN"] = true
		--},
		
		
		
		--[5] = 
		--{ 
		--	["PROTO_WALKER_HABITAT_CORE"] = true
		--}	
		
	}
	
	

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()

	-- Make sure we're made aware when hardpoints are added to the walker
	Object.Register_Signal_Handler(my_behavior.On_HP_Attached, "OBJECT_HARDPOINT_ATTACHED")
	Object.Register_Signal_Handler(my_behavior.On_Production_Complete, "OBJECT_TACTICAL_CONSTRUCTION_COMPLETE")
	

	Core_Hard_Point = Object.Find_All_Hard_Points_Of_Type("Proto_Walker_Habitat_Core")
	Crown_Hard_Point = Object.Find_All_Hard_Points_Of_Type("Proto_Walker_Habitat_Crown")

	if Crown_Hard_Point and TestValid(Crown_Hard_Point[1]) then
		Crown_Hard_Point = Crown_Hard_Point[1]
	else
		MessageBox("Unable to find %s on %s!", "Proto_Walker_Habitat_Crown", tostring(Object));
		Crown_Hard_Point = nil
	end
	
	if Core_Hard_Point and TestValid(Core_Hard_Point[1]) then
		Core_Hard_Point = Core_Hard_Point[1]
	else
		MessageBox("Unable to find %s on %s!", "Proto_Walker_Habitat_Core", tostring(Object));
		Core_Hard_Point = nil
	end
	
	if Core_Hard_Point and Crown_Hard_Point then
		Core_Hard_Point.Make_Invulnerable(true)
		Crown_Hard_Point.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
		
		Core_Hard_Point.Enable_Behavior(BEHAVIOR_GUI, false)
		Crown_Hard_Point.Enable_Behavior(BEHAVIOR_GUI, false)
		
	end 
	
	
	HP_DESTRUCTION_FRAME = {
		[Core_Hard_Point] = 206,
		[Crown_Hard_Point] = 210
	}

	local player = nil

	HP_BUILDABLE_HARD_POINTS = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_HABITAT_LEG_HP00").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	local back_hps = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_HABITAT_BACK_HP00").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)

	-- Add the buildable hardpoints to the death sequence 1 table.
	Table_Merge(HARDPOINTS_DEATH_SEQUENCE_TABLE[1], HP_BUILDABLE_HARD_POINTS)

	MONITOR_DESTRUCTION_OF_HARDPOINTS = {}
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP00 = { 
		current_killed_count = 0, 
		destroy_parent_on_killed_count = 2,
		play_cinematic_anim_hp = true
	}
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP01 = 
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP00
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP02 = 
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP00
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP03 = 
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_HABITAT_COOLING_HP00

--    DISABLE_GUI_FOR_HP = {
--    -- ["ALIEN_WALKER_HABITAT_BACK_HP01"] = true,
--    -- ["ALIEN_WALKER_HABITAT_BACK_HP02"] = true,
--    }
		
--    ENABLE_GUI_FOR_PARENT_OF_DESTROYED_HP = {
--       --["ALIEN_WALKER_HABITAT_BACK_PLASMA_TURRET"] = true,
--       ["ALIEN_WALKER_HABITAT_LIGHTNING_TURRET"] = true
--    }
	
--
--    for name,_ in pairs(DISABLE_GUI_FOR_HP) do
--       local hp = Find_First_Object(name)
--       if hp then
--          hp.Enable_Behavior(BEHAVIOR_GUI, false)
--       end
--    end
--
--
	--Only certain points can be targeted initially.
--    HP_INITIALLY_VULNERABLE = {
--       ["ALIEN_WALKER_HABITAT_LIGHTNING_TURRET"] = true,
--       ["ALIEN_WALKER_HABITAT_BACK_PLASMA_TURRET"] = true,
--       ["ALIEN_WALKER_HABITAT_SHIELD_HP"] = true
--    }

	HP_INITIALLY_VULNERABLE = {
		["PROTO_WALKER_HABITAT_BACK_HP00"] = true,
		["PROTO_WALKER_HABITAT_BACK_HP01"] = true,
		["PROTO_WALKER_HABITAT_BACK_HP02"] = true,
		["PROTO_WALKER_HABITAT_BACK_HP03"] = true,
		["PROTO_WALKER_HABITAT_LEG_HP00"] = true,
		["PROTO_WALKER_HABITAT_LEG_HP01"] = true,
		["PROTO_WALKER_HABITAT_LEG_HP02"] = true,
		["PROTO_WALKER_HABITAT_LEG_HP03"] = true
	}
	
	-- death of any attached hp will make these vulnerable
--    HP_MADE_VULNERABLE_BY_DEATH_OF_CHILD_HP = {
--       ["PROTO_WALKER_HABITAT_BACK_HP00"] = true,
--       ["PROTO_WALKER_HABITAT_BACK_HP01"] = true,
--       ["PROTO_WALKER_HABITAT_BACK_HP02"] = true,
--       ["PROTO_WALKER_HABITAT_BACK_HP03"] = true,
--       ["PROTO_WALKER_HABITAT_LEG_HP00"] = true,
--       ["PROTO_WALKER_HABITAT_LEG_HP01"] = true,
--       ["PROTO_WALKER_HABITAT_LEG_HP02"] = true,
--       ["PROTO_WALKER_HABITAT_LEG_HP03"] = true
--    }

	HP_MADE_INVULNERABLE_BY_ATTACHMENT = 
	{
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP00"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP01"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP02"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP03"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP00_EMPTY"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP01_EMPTY"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP02_EMPTY"] = true,
		["PROTO_WALKER_HABITAT_BACK_DAMAGED_HP03_EMPTY"] = true,
		["PROTO_WALKER_HABITAT_COOLING_DAMAGED_HP00"] = true,
		["PROTO_WALKER_HABITAT_COOLING_DAMAGED_HP01"] = true,
		["PROTO_WALKER_HABITAT_COOLING_DAMAGED_HP02"] = true,
		["PROTO_WALKER_HABITAT_COOLING_DAMAGED_HP03"] = true,
		["PROTO_WALKER_HABITAT_CROWN_DAMAGED"] = true,
		["PROTO_WALKER_HABITAT_CAP"] = true,
		["PROTO_WALKER_HABITAT_LEG_DAMAGE"] = true,
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
	if new_obj.Get_Type().Get_Name() == "PROTO_WALKER_HABITAT_HP_ARC_TRIGGER" then
		Air_Spike_Count = Air_Spike_Count + 1
	end

	if Air_Spike_Count == 1 then
		Object.Set_Targeting_Priorities("Alien_Habitat_Walker_With_Air_Spike_Target_Priority")
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
		
--	local new_obj_name = new_obj.Get_Type().Get_Name()
--	local damage_table = MONITOR_DESTRUCTION_OF_HARDPOINTS[new_obj_name]
--	if damage_table then
--		new_obj.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
--	end
	
--	call_table = HP_Callback_Registration_Table[new_obj.Get_Type()]
--	if call_table then
--		-- someone requested we monitor this HP type, so register for signal
--		new_obj.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
--	end
	
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
	
	-- for now just assume we need to destroy the parent... later here will be additional conditions
	-- and we will need to check which conditionds this destroyed hp belongs to
	local damage_table = MONITOR_DESTRUCTION_OF_HARDPOINTS[source.Get_Type().Get_Name()]
	if damage_table then
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
	end

	if Walker_About_To_Die then
		return
	end

	-- Switch our targeting priorites when the air spike is added so we can attack air targets.
	if source.Get_Type().Get_Name() == "PROTO_WALKER_HABITAT_HP_ARC_TRIGGER" then
		if Air_Spike_Count > 0 then
			Air_Spike_Count = Air_Spike_Count - 1
		end
	end

	if Air_Spike_Count == 0 then
		Object.Set_Targeting_Priorities("Alien_Habitat_Walker_Target_Priority")
	end

	
	local parent_hp = source.Get_Hard_Point_Parent()
	if parent_hp then	
		if HP_BUILDABLE_HARD_POINTS[source.Get_Type()] then
			if parent_hp and parent_hp ~= Object then
				parent_hp.Enable_Behavior(BEHAVIOR_GUI, true)
				parent_hp.Make_Invulnerable(false)
				parent_hp.Set_Cannot_Be_Killed(false)
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
					Destroy_Walker_Object(root_hardpoint, Final_Blow_Player, Final_Blow_Object_Type) 
					Sleep(1)
				end
			end
		end
	end

end


function Thread_Walker_Destroy_Hardpoint_Chain( root_hardpoint)
	
	Kill_HP_Chain_Recursive(root_hardpoint)
	
	Number_HP_Destruction_Threads = Number_HP_Destruction_Threads - 1
end





function Thread_Walker_Destroy_HP_On_Frame(hp, frame, sleep_time)
	
	Number_Core_Destruction_Threads = Number_Core_Destruction_Threads+1

	if sleep_time then Sleep(sleep_time) end
	
	if TestValid(hp) and TestValid(Object) then	
		--kill the hardpoint only if it's in the death table at current death sequence level
		Destroy_Walker_Object(hp, Final_Blow_Player, Final_Blow_Object_Type)   -- kill it
	end
	
	Number_Core_Destruction_Threads = Number_Core_Destruction_Threads-1
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
   
	for level, _ in pairs(HARDPOINTS_DEATH_SEQUENCE_TABLE) do
		
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

	Create_Thread("Thread_Walker_Destroy_HP_On_Frame",  Core_Hard_Point)
	Create_Thread("Thread_Walker_Destroy_HP_On_Frame",  Crown_Hard_Point, 0.2)
	Sleep(0.0001)
		
	while Number_Core_Destruction_Threads > 0 do
		Sleep(0.0001)
	end

	local frame, name = Object.Get_Active_Animation_Frame()
	if name == "Anim_Cinematic" then 
		BlockOnCommand(anim_block)
	end
	
	ServiceRate = old_rate
	--ok, all the hardpoints gone, destroy the unit itself
	Object.Set_In_Limbo(false)
	Destroy_Walker_Object(Object, Final_Blow_Player, Final_Blow_Object_Type)   -- kill it
end



-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.On_HP_Attached = Behavior_On_HP_Attached
my_behavior.On_HP_Destroyed = Behavior_On_HP_Destroyed
my_behavior.On_HP_Detached = Behavior_On_HP_Detached
my_behavior.On_Production_Complete = Behavior_On_Production_Complete
my_behavior.Clean_Up = Common_Puzzle_Clean_Up

-- my_behavior.Get_Num_Monitored_HP_Killed = Behavior_Get_Num_Monitored_HP_Killed

-- my_behavior.Object_In_Range = Behavior_Object_In_Range
-- my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
