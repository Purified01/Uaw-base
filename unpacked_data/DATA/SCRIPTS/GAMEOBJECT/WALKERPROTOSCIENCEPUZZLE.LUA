if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LUA_PREP = true

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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/WalkerSciencePuzzle.lua $
--
--    Original Author: Oksana Kubushyna
--
--	        Author: Maria Teruel
--
--          DateTime: 2006/09/27
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
	Air_Spike_Count = 0
	
	
	Death_Sequence_Level = 0
	HARDPOINTS_DEATH_SEQUENCE_TABLE = {	
		[1] = 
		{ 
		-- Empty list that get's filled with purchased hardpoints.
		},
		[2] = 
		{ 
			[Find_Object_Type("PROTO_WALKER_SCIENCE_LEG_HP00")] = true,
			[Find_Object_Type("PROTO_WALKER_SCIENCE_LEG_HP01")] = true,
			[Find_Object_Type("PROTO_WALKER_SCIENCE_LEG_HP02")] = true,
			
			[Find_Object_Type("PROTO_WALKER_SCIENCE_HORN_HP00")] = true,
			[Find_Object_Type("PROTO_WALKER_SCIENCE_HORN_HP01")] = true,
			[Find_Object_Type("PROTO_WALKER_SCIENCE_HORN_HP02")] = true,
		},			
		[3] = 
		{
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
	
	Crown_Hard_Point = Object.Find_All_Hard_Points_Of_Type("Proto_Walker_Science_Crown")
	Core_Hard_Point = Object.Find_All_Hard_Points_Of_Type("Proto_Walker_Science_Core")
	
	if Crown_Hard_Point and TestValid(Crown_Hard_Point[1]) then
		Crown_Hard_Point = Crown_Hard_Point[1]
		Crown_Hard_Point.Register_Signal_Handler(my_behavior.On_HP_Destroyed, "OBJECT_HEALTH_AT_ZERO")
		Crown_Hard_Point.Enable_Behavior(85, false)	
	else
		MessageBox("Unable to find %s on %s!", "PROTO_Walker_Science_Crown", tostring(Object));
		Crown_Hard_Point = nil
	end
	
	if Core_Hard_Point and TestValid(Core_Hard_Point[1]) then
		Core_Hard_Point = Core_Hard_Point[1]
	else
		MessageBox("Unable to find %s on %s!", "PROTO_Walker_Science_Core", tostring(Object));
		Core_Hard_Point = nil
	end

	HP_DESTRUCTION_FRAME = {
		[Core_Hard_Point] = 206,
		[Crown_Hard_Point] = 208
	}

	local player = nil

	HP_BUILDABLE_HARD_POINTS = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_SCIENCE_LEG_HP00").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	
	local back_hps = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_SCIENCE_LEG_HP01").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)
	back_hps = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_SCIENCE_LEG_HP02").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)
	
	back_hps = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_SCIENCE_HORN_HP00").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)
	back_hps = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_SCIENCE_HORN_HP01").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)
	back_hps = Index_To_Key_Table(Find_Object_Type("PROTO_WALKER_SCIENCE_HORN_HP02").Get_Tactical_Hardpoint_Upgrades(player, true, true))
	Table_Merge(HP_BUILDABLE_HARD_POINTS, back_hps)

	-- Add the buildable hardpoints to the death sequence 1 table.
	Table_Merge(HARDPOINTS_DEATH_SEQUENCE_TABLE[1], HP_BUILDABLE_HARD_POINTS)

	-- Kill the walker when the core is destroyed.
	MONITOR_DESTRUCTION_OF_HARDPOINTS = {}
	MONITOR_DESTRUCTION_OF_HARDPOINTS.PROTO_WALKER_SCIENCE_CORE = { 
		current_killed_count = 0, 
		destroy_parent_on_killed_count = 1
	}
		
		
	HP_INITIALLY_VULNERABLE = {
		["PROTO_WALKER_SCIENCE_LEG_HP00"] = true,
		["PROTO_WALKER_SCIENCE_LEG_HP01"] = true,
		["PROTO_WALKER_SCIENCE_LEG_HP02"] = true,
		["PROTO_WALKER_SCIENCE_HORN_HP00"] 	= true,
		["PROTO_WALKER_SCIENCE_HORN_HP01"]  = true,
		["PROTO_WALKER_SCIENCE_HORN_HP02"] 	= true,
		["PROTO_WALKER_SCIENCE_CORE"]  = true, -- even though the core is initially vulnerable. it is protected by its shield.  Only when the shield is down the core takes damage
	}
	
	HP_MADE_INVULNERABLE_BY_ATTACHMENT = 
	{
		["PROTO_WALKER_SCIENCE_LEG_DAMAGED"] = true,
		["PROTO_WALKER_SCIENCE_HORN_DAMAGED"]	= true,
		["PROTO_WALKER_SCIENCE_CROWN_DAMAGED"]	= true,
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
			hp.Enable_Behavior(85, false)		
		
			-- Assign vulnerability
			if HP_INITIALLY_VULNERABLE[hp.Get_Type().Get_Name()] then
				hp.Enable_Behavior(85, true)
				hp.Make_Invulnerable(false)
				hp.Set_Cannot_Be_Killed(false)
			else
				hp.Enable_Behavior(85, false)
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

	if HP_MADE_INVULNERABLE_BY_ATTACHMENT[new_obj.Get_Type().Get_Name()] then
		new_obj.Make_Invulnerable(true)
		new_obj.Set_Cannot_Be_Killed(true)
	end

	-- Switch our targeting priorites when the air spike is added so we can attack air targets.
	if new_obj.Get_Type().Get_Name() == "ALIEN_WALKER_SCIENCE_HP_ARC_TRIGGER" then
		Air_Spike_Count = Air_Spike_Count + 1
	end

	if Air_Spike_Count == 1 then
		Object.Set_Targeting_Priorities("Alien_Science_Walker_With_Air_Spike_Target_Priority")
	end

	local parent_hp = new_obj.Get_Hard_Point_Parent()
	if parent_hp then	
		if HP_BUILDABLE_HARD_POINTS[new_obj.Get_Type()] then
			if parent_hp and parent_hp ~= Object then
				parent_hp.Enable_Behavior(85, false)
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
	if source.Get_Type().Get_Name() == "ALIEN_WALKER_SCIENCE_HP_ARC_TRIGGER" then
		if Air_Spike_Count > 0 then
			Air_Spike_Count = Air_Spike_Count - 1
		end
	end

	if Air_Spike_Count == 0 then
		Object.Set_Targeting_Priorities("Alien_Science_Walker_Target_Priority")
	end

	local parent_hp = source.Get_Hard_Point_Parent()
	-- for now just assume we need to destroy the parent... later here will be additional conditions
	-- and we will need to check which conditionds this destroyed hp belongs to
	local damage_table = MONITOR_DESTRUCTION_OF_HARDPOINTS[source.Get_Type().Get_Name()]
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
						hp.Enable_Behavior(85, true)
						hp.Make_Invulnerable(false)
						hp.Set_Cannot_Be_Killed(false)
					else
						MessageBox("Unable to find %s on %s!", tostring(type), tostring(Object));
					end
				end
			end
		end
	end
	
	if parent_hp then	
		if HP_BUILDABLE_HARD_POINTS[source.Get_Type()] then
			if parent_hp and parent_hp ~= Object then
				parent_hp.Enable_Behavior(85, true)
				parent_hp.Make_Invulnerable(false)
				parent_hp.Set_Cannot_Be_Killed(false)
			end
		end 
		
	end
end





-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Kill_HP_Chain_Recursive
-- --------------------------------------------------------------------------------------------------------------------------------------------------
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
					Destroy_Walker_Object (root_hardpoint, Final_Blow_Player, Final_Blow_Object_Type)  -- kill it
					Sleep(0.5)
				end
			end
		end
	end

end




-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Thread_Walker_Destroy_Hardpoint_Chain
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Thread_Walker_Destroy_Hardpoint_Chain( root_hardpoint)
	Kill_HP_Chain_Recursive(root_hardpoint)
	Number_HP_Destruction_Threads = Number_HP_Destruction_Threads - 1
end




-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Thread_Walker_Destroy_HP_On_Frame
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Thread_Walker_Destroy_HP_On_Frame( hp, frame)
	
	Number_HP_Destruction_Threads = Number_HP_Destruction_Threads+1
	
	if TestValid(hp) and TestValid(Object) then	
		if HP_DESTRUCTION_FRAME[hp] then

			local frame, name = Object.Get_Active_Animation_Frame()
			while frame < HP_DESTRUCTION_FRAME[hp] do
				Sleep(0.1)
				if not TestValid(Object) then 
					Number_HP_Destruction_Threads = Number_HP_Destruction_Threads-1
					return 
				end
				frame, name = Object.Get_Active_Animation_Frame()
			end
			
			if TestValid(hp) then	
				--kill the hardpoint only if it's in the death table at current death sequence level
					Destroy_Walker_Object (hp, Final_Blow_Player, Final_Blow_Object_Type)  -- kill it
			end
		end
	end
	
	Number_HP_Destruction_Threads = Number_HP_Destruction_Threads-1
end



-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Thread_Walker_Death
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Thread_Walker_Death()

	Object.Suspend_Locomotor(true)
	Object.Prevent_All_Fire(true)
	Object.Set_Selectable(false)
	Object.Set_In_Limbo(true)
	Object.Enable_Behavior(7, false)

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
						Sleep(0.1)
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
	Destroy_Walker_Object(Object, Final_Blow_Player, Final_Blow_Object_Type)  -- kill it
end



-- --------------------------------------------------------------------------------------------------------------1-----------------------------------
-- This line must be at the bottom of the file.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
my_behavior.On_HP_Attached = Behavior_On_HP_Attached
my_behavior.On_HP_Destroyed = Behavior_On_HP_Destroyed
my_behavior.On_Production_Complete = Behavior_On_Production_Complete
my_behavior.Clean_Up = Common_Puzzle_Clean_Up

-- my_behavior.Get_Num_Monitored_HP_Killed = Behavior_Get_Num_Monitored_HP_Killed

-- my_behavior.Object_In_Range = Behavior_Object_In_Range
-- my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Debug_Switch_Sides = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Register_For_Production_Complete_Callback = nil
	Remove_Invalid_Objects = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Thread_Walker_Destroy_HP_On_Frame = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
