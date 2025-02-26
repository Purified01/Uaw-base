LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Skirmish_Sub_Goal_Build_Research_Suite.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/AI/SubGoals/Generic_Skirmish_Sub_Goal_Build_Research_Suite.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGUICommands")
--require("Novus_Player")
--require("Alien_Player")
--require("Masari_Player")

ScriptShouldCRC = true

local minimum_cash = 3500.0

function Compute_Desire()
	--This is a sub goal.  Once it's been activated by another goal it remains desirable, but
	--it never becomes active on its own.
	if Goal.Is_Active() then
		return 1.0
	else
		return 0.0
	end
end

function Score_Unit(unit)

	return 0.0

end

function On_Activate()

	if Is_Player_Of_Faction(Player, "MASARI") then
		minimum_cash = 350.0
	end

	Create_Thread("Research_Thread")

end

function Research_Thread()

	player_script = Player.Get_Script()
	
	research_node_description = Goal.Get_User_Data()
	research_node_data = player_script.Call_Function("Retrieve_Node_Data", research_node_description[1], research_node_description[2])
	
	if research_node_data.Completed then
		ScriptExit()
	elseif research_node_data.StartResearchTime ~= -1 then
		--Already under construction.  Just wait for it.
		while not research_node_data.Completed do
			Sleep(1)
			research_node_data = player_script.Call_Function("Retrieve_Node_Data", research_node_description[1], research_node_description[2])
		end
	elseif not research_node_data.Enabled then
		--Try to fix this!
		node_index = research_node_description[2]
		if node_index > 1 then
			lower_research_node_data = player_script.Call_Function("Retrieve_Node_Data", research_node_description[1], node_index - 1)
			if not lower_research_node_data.Completed then
				BlockOnCommand(Goal.Activate_Sub_Goal("Generic_Skirmish_Sub_Goal_Build_Research_Suite", nil, {research_node_description[1], node_index - 1}))
				
				--Provided our attempt to meet the prereqs worked we should go ahead and try again to build
				lower_research_node_data = player_script.Call_Function("Retrieve_Node_Data", research_node_description[1], node_index - 1)
				if lower_research_node_data.Completed then
					Research_Thread()
				end
				ScriptExit()
			end
		end
		
		--Something else is preventing research.  Give up?
			
	else

		-- wait till we are enabled before we spend the cash
		while not research_node_data.Enabled do
			Sleep(5.0)
		end

		-- don't even try to research if we have less than minimum_cash credits
		while Player.Get_Credits() < minimum_cash do
			Sleep(5.0)
		end
	
		required_cash = research_node_data.ResearchCost
		
		while required_cash > 0.0 do
			required_cash = required_cash - Goal.Request_Resources(required_cash, false)
			Sleep(1)
		end		
	
		while true do
		
			player_script.Call_Function("Start_Research", {research_node_description[1], research_node_description[2]})			
			research_node_data = player_script.Call_Function("Retrieve_Node_Data", research_node_description[1], research_node_description[2])
		
			if research_node_data.StartResearchTime ~= -1 or research_node_data.Completed then
				break
			else
				Sleep(2.0)
			end
		end
	
		Goal.Spend_Resources(research_node_data.ResearchCost)
		
		while not research_node_data.Completed do
			Sleep(1)
			research_node_data = player_script.Call_Function("Retrieve_Node_Data", research_node_description[1], research_node_description[2])
		end
	end		
	
	ScriptExit()	
		
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Burn_All_Objects = nil
	Calculate_Task_Force_Speed = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Describe_Target = nil
	DesignerMessage = nil
	Dialog_Box_Common_Init = nil
	Dirty_Floor = nil
	Disable_UI_Element_Event = nil
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	Find_Builder_Hard_Point = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Distance_Based_Unit_Score = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
	String_Split = nil
	Suppress_Nearby_Goals = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Verify_Resource_Object = nil
	WaitForAnyBlock = nil
	show_table = nil
	Kill_Unused_Global_Functions = nil
end
