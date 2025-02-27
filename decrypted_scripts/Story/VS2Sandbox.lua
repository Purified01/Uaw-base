if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[12] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[53] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/VS2Sandbox.lua#6 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/VS2Sandbox.lua $
--
--    Original Author: Steve Copeland
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

require("PGStateMachine")
require("PGSpawnUnits")
require("PGMoveUnits")
require("UIControl")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")


---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)

end



---------------------------------------------------------------------------------------------------
------ STATES	    -------------------------------------------------------------------------------



function State_Init(message)
	if message == OnEnter then
	
		-- Initialize various aspects of the scenario.
		--DebugBreak()

		state_start_time = GetCurrentTime()

		player_alien = Find_Player("Alien")
		player_novus = Find_Player("Novus")
		player_military = Find_Player("Military")
		

		FogOfWar.Reveal_All(player_alien)
		FogOfWar.Reveal_All(player_novus)
		FogOfWar.Reveal_All(player_military)


		-- Find starting set of alien units, then keep this updated by events that add units.
		-- Remove dead units before making use of the list.
		alien_units = Find_All_Parent_Units("Infantry | Vehicle | Air", player_alien)
		alien_walkers = Find_All_Parent_Units("Walker", player_alien)
		novus_units = Find_All_Parent_Units("Infantry | Vehicle | Air | Hero", player_novus)
		military_units = Find_All_Parent_Units("Infantry | Vehicle | Air | Hero", player_military)

		-- Ignore the dummy hero, who is necessary to trigger the invasion.
		alien_hero = Find_First_Object("Alien_Hero")
		if not TestValid(alien_hero) then
			MessageBox("invalid alien hero")			
		end
		alien_hero.Hide(true)

		-- Put all novus units on guard
		for i, unit in pairs(novus_units) do
			unit.Guard_Target(unit.Get_Position())
		end
		
		-- Put all military units on guard
		for i, unit in pairs(military_units) do
			unit.Guard_Target(unit.Get_Position())
		end

		
	end
end

---------------------------------------------------------------------------------------------------
------ GLOBAL EVENTS -------------------------------------------------------------------------------

function On_Construction_Complete(obj)

	-- Add constructed units to the running lists
	if obj.Get_Owner() == player_alien then
	
		if obj.Get_Type() == Find_Object_Type("Alien_Walker_Habitat") then
			table.insert(alien_walkers, obj)
		else
			table.insert(alien_units, obj)
		end
	end
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
	Commit_Profile_Values = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Drop_In_Spawn_Unit = nil
	Enable_UI_Element_Event = nil
	Formation_Attack = nil
	Formation_Attack_Move = nil
	Formation_Guard = nil
	Formation_Move = nil
	Full_Speed_Move = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Current_State = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Next_State = nil
	Hunt = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	Notify_Attached_Hint_Created = nil
	Objective_Complete = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PGHintSystem_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Remove_From_Table = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Next_State = nil
	Set_Objective_Text = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
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
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
