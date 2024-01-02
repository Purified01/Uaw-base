-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Skirmish_Sub_Goal_Build_Research_Suite.lua#12 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/AI/SubGoals/Generic_Skirmish_Sub_Goal_Build_Research_Suite.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Evan_Pipho $
--
--            $Change: 85652 $
--
--          $DateTime: 2007/10/06 17:53:39 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBaseDefinitions")
require("PGAICommands")
require("PGUICommands")
require("Novus_Player")
require("Alien_Player")
require("Masari_Player")

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
		
	--		Send_GUI_Network_Event("Network_Start_Undo_Research", {Player, research_node_description[1], research_node_description[2]})
			Get_Game_Mode_GUI_Scene().Raise_Event("Network_Start_Research", nil, {Player, research_node_description[1], research_node_description[2]})	
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