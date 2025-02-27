if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[21] = true
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[177] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[103] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[165] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/Cinematic_Marker_Controller.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/Cinematic_Marker_Controller.lua $
--
--    Original Author: Dan Etter
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

--When player units move near this object its spawn behavior becomes enabled

function Definitions()
	--obj_type = trigger_obj.Get_Type() DO NOT DO THIS
	Define_State("State_Init", State_Init);
	
	cinematic_offset = 1
end

function State_Init(message)
	if message == OnEnter then		
		novus = Find_Player("Novus")
		Change_Local_Faction("Novus")
		novus.Give_Money(100000)
		Create_Thread("Sleepy_Time")
	end
end

function Sleepy_Time()
	
	Sleep(20)
	Lock_Controls(1)
	
	if cinematic_offset == 0 then
		constructor_00 = Find_Hint("NOVUS_CONSTRUCTOR","constructor00")		
		tower_loc = Find_Hint("MARKER_GENERIC","towerloc")
		Register_Prox(tower_loc, Prox_Move_Constructor, 50, novus)
		Novus_Build_Structure(constructor_00, "Novus_Signal_Tower", tower_loc.Get_Position())
	elseif cinematic_offset == 1 then
		facility_0 = Find_Hint("NOVUS_ROBOTIC_ASSEMBLY","facility0")
		facility_1 = Find_Hint("NOVUS_ROBOTIC_ASSEMBLY","facility1")
		
		Tactical_Enabler_Begin_Production(facility_0, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_0, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_0, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		
		Sleep(2)
		
		Tactical_Enabler_Begin_Production(facility_1, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_1, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_1, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		
		Sleep(30)
		
		Lock_Controls(0)
	end
end

function Novus_Build_Structure(constructor, structure_type_name, position)

	local beacon_type = Find_Object_Type(structure_type_name).Get_Type_Value("Tactical_Buildable_Beacon_Type")
	local beacon = Create_Generic_Object(beacon_type, position, constructor.Get_Owner())
	constructor.Activate_Ability("Novus_Tactical_Build_Structure_Ability", true, beacon)

end

function Prox_Move_Constructor(prox_obj, trigger_obj)
	obj_type = trigger_obj.Get_Type()
	--MessageBox("Prox_Tripped by: %s", tostring(trigger_obj))
	if obj_type == Find_Object_Type("NOVUS_SIGNAL_TOWER")	then	
		prox_obj.Cancel_Event_Object_In_Range(Prox_Move_Constructor)
		Create_Thread("Flow_Constructor")
	end
end


function Flow_Constructor()
	Sleep(1)
	move_loc = Find_First_Object("Marker_Cinematic_Lua_Script")
	Full_Speed_Move(constructor_00, move_loc.Get_Position())
	Sleep(5)
	Lock_Controls(0)
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	Advance_State = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	Clear_Hint_Tracking_Map = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Drop_In_Spawn_Unit = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	Formation_Attack = nil
	Formation_Attack_Move = nil
	Formation_Guard = nil
	Formation_Move = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Achievement_Buff_Display_Model = nil
	Get_Current_State = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Get_Next_State = nil
	Get_Player_By_Faction = nil
	Hunt = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGAchievementAward_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Persist_Online_Achievements = nil
	Player_Earned_Offline_Achievements = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Remove_From_Table = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Set_Local_User_Applied_Medals = nil
	Set_Next_State = nil
	Set_Objective_Text = nil
	Set_Online_Player_Info_Models = nil
	Show_Earned_Offline_Achievements = nil
	Show_Earned_Online_Achievements = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	SpawnList = nil
	Spawn_Dialog_Box = nil
	Strategic_SpawnList = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	UI_Close_All_Displays = nil
	UI_Enable_For_Object = nil
	UI_On_Mission_End = nil
	UI_On_Mission_Start = nil
	UI_Pre_Mission_End = nil
	UI_Set_Loading_Screen_Background = nil
	UI_Set_Loading_Screen_Faction_ID = nil
	UI_Set_Loading_Screen_Mission_Text = nil
	UI_Set_Region_Color = nil
	UI_Start_Flash_Button_For_Unit = nil
	UI_Stop_Flash_Button_For_Unit = nil
	UI_Update_Selection_Abilities = nil
	Update_Offline_Achievement = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
