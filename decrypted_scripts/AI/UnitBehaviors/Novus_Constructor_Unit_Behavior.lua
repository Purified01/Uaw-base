-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Novus_Constructor_Unit_Behavior.lua#15 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/UnitBehaviors/Novus_Constructor_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Keith_Brors $
--
--            $Change: 84404 $
--
--          $DateTime: 2007/09/20 13:10:30 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("AIIdleThreads")

ScriptShouldCRC = true

--A behavior that allows AI to take advantage of opportunities to trigger point blank area effect abilities.
--May be extended in the future to divert units to optimize AE use.

local my_behavior = 
{
	Name = _REQUIREDNAME
}

local function Behavior_First_Service()

	AllyUnits = {}
	AllyCount = 0
	MostDamagedObject = nil
	MostDamagedValue = 1.0
	
--	Object.Event_Object_In_Range( Unit_Filter, Novus_Constructor.HEAL_RANGE )
	
	OurId = tostring( Object.Get_ID() )
	
	LookForCommandCenterTime = 0.0
	CommandCenter = nil
	RecruitTime = 0.0
	WasRecruited = false
	
	ConstructionObject = nil
	ConstructionDistance = Novus_Constructor.HEAL_RANGE
	IdleTime = 0.0

	StartRadius = Novus_Constructor.HEAL_RANGE / 2
	EndRadius = Novus_Constructor.HEAL_RANGE
	IncreaseRadius = Novus_Constructor.HEAL_RANGE / 4
	SearchRadius = StartRadius
	
	ObjectPlayer = nil
	AIThreadID = nil
end

local function Behavior_Service()
	if Object.Get_Owner().Is_AI_Player() and Object.Get_Owner().Get_Allow_AI_Unit_Behavior() and Object.Is_AI_Recruitable() then
		if not AIThreadID then
			AIThreadID = Create_Thread("AI_Behavior_Thread")
		end
	elseif AIThreadID then
		Create_Thread.Kill(AIThreadID)
		AIThreadID = nil
	end
end

function AI_Behavior_Thread()
	while true do
		AI_Behavior_Update()
	end
end

function AI_Behavior_Update()
	if not TestValid(Object) then
		Sleep_Full(2.0)
		return
	end

	ObjectPlayer = Object.Get_Owner()

	if not ObjectPlayer or not ObjectPlayer.Is_AI_Player() then
		Sleep_Full(2.0)
		return
	end
	
	-- if we are even trying to flow don't change our action !
	if Object.Is_Flowing( true ) then
		Sleep_Full(1.0)
		return
	end

	local q_att_target = Object.Get_Queued_Attack_Target()
	local att_target = Object.Get_Attack_Target()
	local cur_time = GetCurrentTime()

	if Object.Is_AI_Recruited() then
		if not WasRecruited then
			RecruitTime = cur_time
		end
		
		WasRecruited = true		
		
	else
		WasRecruited = false
	end

	-- give newly recruited constructors time to aquire their target	
	-- also if it has q queued target we are done
	if Object.Is_AI_Recruited() and ( cur_time < RecruitTime + 1.0 or TestValid(q_att_target) )then
		Clear_Info_And_Sleep(2.0)
		return
	end 
	
	if Object.Is_Ability_Active(Novus_Constructor.BUILD_ABILITY) then
		Clear_Info_And_Sleep(2.0)
		return
	end
	
	-- if we are targeting a build object we are done	
	if TestValid( att_target ) then
		if att_target.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) or att_target.Has_Behavior(BEHAVIOR_TACTICAL_BUILDABLE_BEACON) then
			Clear_Info_And_Sleep(2.0)
			return
		end			
	end
	
	-- check for objects needing construction
	if TestValid( ConstructionObject ) and ConstructionObject.Get_Attribute_Value("Number_Of_Assigned_Builders") < Novus_Constructor.MAX_BUILDERS then
		Object.Activate_Ability(Novus_Constructor.BUILD_ABILITY,true,ConstructionObject)
		Clear_Info_And_Sleep(2.0)
		return
	elseif TestValid( CommandCenter ) and Object.Get_Distance( CommandCenter ) > Novus_Constructor.HEAL_RANGE then
		-- too far from command center
		Object.Parameterized_Move_Order( CommandCenter.Get_Position(), "No_Formup")
		Clear_Info_And_Sleep(1.0)
		return
	else
		-- should we heal something?
		if TestValid(MostDamagedObject) then
			
			if Object.Get_Distance( MostDamagedObject ) < Novus_Constructor.ABILITY_RANGE * 1.5 then
				Object.Activate_Ability(Novus_Constructor.HEAL_ABILITY,true,MostDamagedObject)
				Clear_Info_And_Sleep(2.0)
				return
			elseif TestValid( CommandCenter ) and MostDamagedObject.Get_Distance( Object ) < Novus_Constructor.HEAL_RANGE then
				local position = Get_Mid_Point( MostDamagedObject, Object )
				Object.Parameterized_Move_Order( position, "No_Formup")
				Clear_Info_And_Sleep(2.0)
				return
			end	
		end
	end
			
	if cur_time > IdleTime and TestValid( CommandCenter ) then
		local distance = Object.Get_Distance( CommandCenter )
		if distance > Novus_Constructor.ABILITY_RANGE * 2.0 then
			Object.Parameterized_Move_Order( CommandCenter.Get_Position(), "No_Formup")
			Clear_Info_And_Sleep(2.0)
			return
		end
	end
			
	Clear_Info_And_Sleep(1.0, true, false )

end

function Clear_Info_And_Sleep( sleep_time, idle, sleep_full )

	AllyUnits = {}
	AllyCount = 0
	MostDamagedObject = nil
	MostDamagedValue = 1.0
	ConstructionObject = nil
	ConstructionDistance = Novus_Constructor.HEAL_RANGE
	if idle == nil or not idle then
		IdleTime = GetCurrentTime() + 5.0
	end
	
	if sleep_full == nil or sleep_full or ( SearchRadius >= EndRadius and GameRandom(0.0,100.0) < 50.0 ) then
		Sleep_Full( sleep_time )
	else
		Object.Event_Object_In_Range( Unit_Filter, SearchRadius )
		SearchRadius = SearchRadius + IncreaseRadius
		if SearchRadius > EndRadius then
			SearchRadius = EndRadius
		end
		Sleep( sleep_time )
	end
	
end

function Sleep_Full( sleep_time )

	Object.Cancel_Event_Object_In_Range( Unit_Filter )
	SearchRadius = StartRadius
	Sleep( sleep_time )
	
end

function Get_Mid_Point( target_obj, obj )

	local goto = target_obj.Get_Position()
	local from = obj.Get_Position()
	
	goto.Set_Position_X( (goto.Get_Position_X() + from.Get_Position_X())/2 )
	goto.Set_Position_Y( (goto.Get_Position_Y() + from.Get_Position_Y())/2 )
	
	return goto
	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Object_Has_Power
-- ------------------------------------------------------------------------------------------------------------------
function Object_Has_Power( object )
	if TestValid( object ) then
		if object.Has_Behavior( BEHAVIOR_POWERED ) then
			if object.Get_Attribute_Integer_Value( "Is_Powered" ) == 0 then
				return false
			end
		end
	end
	
	return true
end

function Unit_Filter(self_obj, trigger_obj)

	if TestValid(trigger_obj) and Object ~= trigger_obj then 

		if trigger_obj.Is_Category("Resource | Resource_INST") then
			return
		end

		local trigger_type = trigger_obj.Get_Type()
		
		if trigger_obj.Get_Owner() == ObjectPlayer and TestValid( trigger_type ) and trigger_type.Get_Type_Value("Is_Command_Center") then
			CommandCenter = trigger_obj
		end
		
		if trigger_obj.Get_Owner() == ObjectPlayer and ( trigger_obj.Has_Behavior(BEHAVIOR_TACTICAL_UNDER_CONSTRUCTION) or trigger_obj.Has_Behavior(BEHAVIOR_TACTICAL_BUILDABLE_BEACON) ) and
			not trigger_obj.Has_Behavior(BEHAVIOR_HARD_POINT) then
			local distance = Object.Get_Distance( trigger_obj )
			if  distance < ConstructionDistance and trigger_obj.Get_Attribute_Value("Number_Of_Assigned_Builders") < Novus_Constructor.MAX_BUILDERS then
				ConstructionDistance = distance
				ConstructionObject = trigger_obj
				return
			end
		end

		if trigger_obj.Get_Owner() == ObjectPlayer and ( not TestValid (CommandCenter ) or CommandCenter.Get_Distance( trigger_obj ) <= 200.0 or Object.Get_Distance( trigger_obj ) <= Novus_Constructor.ABILITY_RANGE ) then
			if not AllyUnits[trigger_obj] then
				
				AllyUnits[trigger_obj] = trigger_obj
				AllyCount = AllyCount + 1
					
				if not trigger_type.Get_Type_Value("Is_Resource_Collector") and ObjectPlayer and (ObjectPlayer.Get_Credits() > 1000.0 or not trigger_obj.Is_Category("Stationary")) and 
					Object_Has_Power(trigger_obj) then

					local health = trigger_obj.Get_Health()
					if health > 0 and health < MostDamagedValue then
						MostDamagedObject = trigger_obj
						MostDamagedValue = health
					end
				end
				
			end
		end
	end

end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)