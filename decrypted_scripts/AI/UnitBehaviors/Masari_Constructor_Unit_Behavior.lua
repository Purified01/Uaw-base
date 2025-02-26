if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[113] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[18] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Masari_Constructor_Unit_Behavior.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/UnitBehaviors/Masari_Constructor_Unit_Behavior.lua $
--
--    Original Author: Keith Brors
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

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
	MostDamagedValue = 2.0
	
--	Object.Event_Object_In_Range( Unit_Filter, Masari_Constructor.HEAL_RANGE )
	
	OurId = tostring( Object.Get_ID() )
	
	LookForCommandCenterTime = 0.0
	CommandCenter = nil
	RecruitTime = 0.0
	WasRecruited = false
	
	ConstructionObject = nil
	ConstructionDistance = Masari_Constructor.HEAL_RANGE
	IdleTime = 0.0
	CurrentHealTarget = nil
	ActiveConstructionObject = nil
	OtherArchitects = {}
	
	ServiceRate = 0.75
	
	StartRadius = 350.0
	EndRadius = Masari_Constructor.HEAL_RANGE
	IncreaseRadius = 150.0
	SearchRadius = StartRadius
	LastSearchRadius = 0.0
	
	MaximumHelpers = 2.0
	AIThreadID = nil
	MatterType = Find_Object_Type("Masari_Elemental_Collector")
	OwningPlayer = Object.Get_Owner()
	
end

local function Behavior_Service()

	OwningPlayer = Object.Get_Owner()

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
		Sleep(2.0)
		return
	end
	
	if AIDefensiveIsRetreating then
		Sleep(2.0)
		return
	end
	
	-- if we are even trying to flow don't change our action !
	if Object.Is_Flowing( true ) then
		Sleep(1.0)
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
	if Object.Is_AI_Recruited() and ( cur_time < RecruitTime + 1.0 or (TestValid(q_att_target) and (q_att_target.Has_Behavior(39) or q_att_target.Has_Behavior(70)) ) ) then
		Clear_Info_And_Sleep(1.0)
		return
	end 
	
	if Object.Is_Ability_Active(Masari_Constructor.BUILD_ABILITY) then
		if TestValid(att_target) then
			ActiveConstructionObject = att_target
			if Number_Builders(att_target) > Masari_Constructor.MAX_BUILDERS then
				ActiveConstructionObject = nil
				Object.Activate_Ability(Masari_Constructor.BUILD_ABILITY,false)
				Object.Clear_Attack_Target()
			end
		end
		
		Clear_Info_And_Sleep(1.0)
		return
	end
	
	-- if we are targeting a build object we are done	
	if TestValid( att_target ) then
		if att_target.Has_Behavior(39) or att_target.Has_Behavior(70) then
			ActiveConstructionObject = att_target
			Clear_Info_And_Sleep(1.0)
			return
		end			
	end
	
	-- check for objects needing construction
	if TestValid( ConstructionObject ) and ( ActiveConstructionObject == ConstructionObject or Number_Builders( ConstructionObject ) < Masari_Constructor.MAX_BUILDERS ) then
		ActiveConstructionObject = ConstructionObject
		Object.Activate_Ability(Masari_Constructor.BUILD_ABILITY,true,ConstructionObject)
		Clear_Info_And_Sleep(2.0)
		return
	elseif TestValid( CommandCenter ) and Object.Get_Distance( CommandCenter ) > Masari_Constructor.HEAL_RANGE then
		-- too far from command center
		Object.Parameterized_Move_Order( CommandCenter.Get_Position(), "No_Formup")
		Clear_Info_And_Sleep(2.0)
		return
	else
		-- should we heal something?
		-- already healing		
	
		if Object.Is_Ability_Active(Masari_Constructor.HEAL_ABILITY) or Object.Is_Ability_Active("Masari_Architect_Assist_Attack_Capable_Structure_Ability") or 
			Object.Is_Ability_Active("Masari_Architect_Assist_Harvesting_Structure_Ability") then
			if not TestValid(CurrentHealTarget) or (CurrentHealTarget.Get_Health() >= 1.0 and CurrentHealTarget.Get_Building_Object_Type(true) == nil) and not Has_Attack_Target(CurrentHealTarget) then
				Object.Activate_Ability("Masari_Architect_Assist_Harvesting_Structure_Ability",false)
				Object.Activate_Ability("Masari_Architect_Assist_Attack_Capable_Structure_Ability",false)
				Object.Activate_Ability(Masari_Constructor.HEAL_ABILITY,false)
				Object.Clear_Attack_Target()
				Clear_Info_And_Sleep( 2.0 )
			else
				Clear_Info_And_Sleep( 2.0, false, false )
			end
			return
		elseif Object.Is_Ability_Active("Masari_Architect_Assist_Structure_Ability") then
		
			local queued_build_list = nil
			if TestValid(CurrentHealTarget) then
				queued_build_list = CurrentHealTarget.Tactical_Enabler_Get_Queued_Objects()
			end
			local building_unit = false
			
			if queued_build_list ~= nil and #queued_build_list > 0 then
				building_unit = true
			end
		
			if not TestValid(CurrentHealTarget) or ( CurrentHealTarget.Get_Health() >= 1.0 and CurrentHealTarget.Get_Building_Object_Type(true) == nil and 
				not building_unit) then
					Object.Activate_Ability("Masari_Architect_Assist_Structure_Ability",false)
					Object.Clear_Attack_Target()
				Clear_Info_And_Sleep( 2.0 )
			else
				Clear_Info_And_Sleep( 2.0, false, false )
			end
			return
		end
			
		if TestValid(MostDamagedObject) and Number_Healers(MostDamagedObject) < MaximumHelpers then
			
			if Object.Get_Distance( MostDamagedObject ) < Masari_Constructor.ABILITY_RANGE * 3.0 then
				local sleep_time = 2.0
				if MostDamagedObject.Get_Health() >= 1.0 then
					-- assisting a build so sleep longer
					sleep_time = 10.0
				end
--				if MostDamagedObject.Is_Category("Stationary") then
--					if MostDamagedObject.Is_Category("CanAttack") then
--						Object.Activate_Ability("Masari_Architect_Assist_Attack_Capable_Structure_Ability",true,MostDamagedObject)
--					elseif MostDamagedObject.Get_Type().Get_Base_Type() == Find_Object_Type("Masari_Elemental_Collector") then
--						Object.Activate_Ability("Masari_Architect_Assist_Harvesting_Structure_Ability",true,MostDamagedObject)
--					else
--						Object.Activate_Ability("Masari_Architect_Assist_Structure_Ability",true,MostDamagedObject)
--					end
--				else
--					Object.Activate_Ability(Masari_Constructor.HEAL_ABILITY,true,MostDamagedObject)
--				end

				-- This was fixed so we can now attack our own structures
				Object.Code_Compliant_Attack_Target( MostDamagedObject )
				
				CurrentHealTarget = MostDamagedObject
				
				Clear_Info_And_Sleep( sleep_time, false, false )
				return
			elseif TestValid( CommandCenter ) and MostDamagedObject.Get_Distance( Object ) < Masari_Constructor.HEAL_RANGE then
				local position = Project_Position(MostDamagedObject,Object,Masari_Constructor.ABILITY_RANGE,0.0)
				Object.Parameterized_Move_Order( position, "No_Formup")
				Clear_Info_And_Sleep(1.0, false)
				return
			end	
		end
	end
			
	if cur_time > IdleTime and TestValid( CommandCenter ) then
		local distance = Object.Get_Distance( CommandCenter )
		if distance > Masari_Constructor.ABILITY_RANGE * 2.0 then
			Object.Parameterized_Move_Order( CommandCenter.Get_Position(), "No_Formup")
			Clear_Info_And_Sleep(2.0)
			return
		end
	end
			
	Clear_Info_And_Sleep(1.0, true, true, false )
end

function Clear_Info_And_Sleep( sleep_time, idle, kill_heal_target, sleep_full )

	if not TestValid(ActiveConstructionObject) or
		(
			not ActiveConstructionObject.Has_Behavior(39) and
			not ActiveConstructionObject.Has_Behavior(70)
		)
	then
		if ActiveConstructionObject ~= nil then
			ActiveConstructionObject = nil
		end
	end

	AllyUnits = {}
	AllyCount = 0
	MostDamagedObject = nil
	MostDamagedValue = 2.0
	ConstructionObject = ActiveConstructionObject
	ConstructionDistance = Masari_Constructor.HEAL_RANGE
	if idle == nil or not idle then
		IdleTime = GetCurrentTime() + 5.0
	end
	
	if kill_heal_target == nil or kill_heal_target then
		CurrentHealTarget = nil
	end
	
	if sleep_full == nil or sleep_full or ( SearchRadius >= EndRadius and GameRandom(0.0,100.0) < 50.0 ) then
		Sleep_Full( sleep_time )
	else
		Object.Event_Object_In_Range( Unit_Filter, SearchRadius )
		LastSearchRadius = SearchRadius
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

function Unit_Filter(self_obj, trigger_obj)

	if TestValid(trigger_obj) and Object ~= trigger_obj then 

		if trigger_obj.Is_Category("Resource | Resource_INST") then
			return
		end

		local trigger_type = trigger_obj.Get_Type()
		if not TestValid(trigger_type) then
			return
		end
		
		trigger_type = trigger_type.Get_Base_Type()
		
		if trigger_obj.Get_Owner() == Object.Get_Owner() and TestValid( trigger_type ) then
			if trigger_type.Get_Type_Value("Is_Command_Center") then
				CommandCenter = trigger_obj
			end
			
			if trigger_type.Get_Type_Value("Is_Tactical_Base_Builder") then
				OtherArchitects[trigger_obj] = trigger_obj
			end
		end
		
		if not TestValid(ActiveConstructionObject) and trigger_obj.Get_Owner() == Object.Get_Owner() and
			( 
				trigger_obj.Has_Behavior(39) or
				trigger_obj.Has_Behavior(70)
			) and
			not trigger_obj.Has_Behavior(68) and
			Number_Builders(trigger_obj) < Masari_Constructor.MAX_BUILDERS
		then
			local distance = Object.Get_Distance( trigger_obj )
			if  distance < ConstructionDistance then
				ConstructionDistance = distance
				ConstructionObject = trigger_obj
				return
			end
		end

		if trigger_obj.Get_Owner() == Object.Get_Owner() and ( not TestValid (CommandCenter ) or
			CommandCenter.Get_Distance( trigger_obj ) <= Masari_Constructor.HEAL_RANGE or
			Object.Get_Distance( trigger_obj ) <= Masari_Constructor.ABILITY_RANGE ) then
			
			if not AllyUnits[trigger_obj] then
				
				AllyUnits[trigger_obj] = trigger_obj
				AllyCount = AllyCount + 1
					
				if trigger_obj.Is_Category("Stationary | Piloted | Small + Organic") and 
					not trigger_obj.Has_Behavior(39) and
					not trigger_obj.Has_Behavior(70) and
					Number_Healers( trigger_obj ) < 2
				then

					local health = trigger_obj.Get_Health() + 1.0
					
					-- fake buildings constructing things with a slightly lower health
					-- or upgrading
					if health >= 2.0 then
						local queued_build_list = trigger_obj.Tactical_Enabler_Get_Queued_Objects()
						if queued_build_list ~= nil and #queued_build_list > 0 then
							local distance = Object.Get_Distance(trigger_obj)
							if distance > 0.0 then
								health = health - 0.1 / distance
							end
						elseif trigger_obj.Get_Building_Object_Type(true) ~= nil then
							local distance = Object.Get_Distance(trigger_obj)
							if distance > 0.0 then
								health = health - 0.3 / distance
							end
						elseif trigger_obj.Is_Category("CanAttack + Stationary") then
							local att_target = trigger_obj.Get_Current_Attack_Object()
							if TestValid(att_target) then
								local distance = Object.Get_Distance(trigger_obj)
								if distance > 0.0 then
									health = health - 0.5 / distance
								end
							end
						elseif trigger_type == MatterType and TestValid(OwningPlayer) and OwningPlayer.Get_Credits() < 500.0 then
							local distance = Object.Get_Distance(trigger_obj)
							if distance > 0.0 then
								health = health - 0.2 / distance
							end
						end
					end
					if health > 1.0 and health < MostDamagedValue then
						MostDamagedObject = trigger_obj
						MostDamagedValue = health
					end
				end
				
			end
		end
	end
	
end

function Has_Attack_Target(object)

	if not object.Is_Category("CanAttack") then
		return false
	end
	
	local att_target = object.Get_Attack_Target()
	if TestValid(att_target) then
		return true
	end
	
	return false
	
end

function Number_Builders( object )

	local num = 0

	for _, builder in pairs (OtherArchitects) do
		if TestValid( builder ) then
			local b_script = builder.Get_Script()
			if b_script ~= nil then
				local building = b_script.Get_Variable("ActiveConstructionObject")
				if building == object then
					num = num + 1
				end
			end
		elseif builder ~= nil then
			OtherArchitects[builder] = nil
		end
	end
	
	return num
	
end

function Number_Healers( object )
	local num = 0
	
	for _, builder in pairs (OtherArchitects) do
		if TestValid( builder ) then
			local b_script = builder.Get_Script()
			if b_script ~= nil then
				local building = b_script.Get_Variable("CurrentHealTarget")
				if building == object then
					num = num + 1
				end
			end
		elseif builder ~= nil then
			OtherArchitects[builder] = nil
		end
	end
	
	return num
	
end

my_behavior.First_Service = Behavior_First_Service
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Mid_Point = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
