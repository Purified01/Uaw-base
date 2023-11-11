-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/Military_Player.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Miscellaneous/Military_Player.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 85616 $
--
--          $DateTime: 2007/10/05 19:09:23 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")

function Definitions()

	-- MessageBox("%s -- definitions", tostring(Script))

	Define_State("State_Init", State_Init);
	
	-- Map containing the tech objects retrieved by the player.
	-- KEY -> tech_object type.  VALUE -> the research time for the object
	AcquiredTechObjectsList = {}
	
	CurrentGameMode = nil
	IsTacticalOnlyGame = false
	EnableTree = false
	
end

-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 04.07.2006
-- Initialize all the Research/Tech Trees for this player!
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function State_Init(message)

	if message == OnEnter then
		-- Nothing to do...
	elseif message == OnUpdate then
	end
end



-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 04.03.2006
-- The science team has acquired a new tech object that must be stored for future research (in strategic mode)
-- Only when the object has been researched, the player gets the corresponding tech upgrade!.
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function Acquire_Tech_Object(tech_object, research_time)
	
	-- To keep track of the Research Progress, add an entry to the list of Research Timers.
	-- The key to the table is the obj type and the value is the research time associated to the specified object.
	
	-- if the entry already exists skip the process!
	if ResearchTimerTable[tech_object.Get_Type()] ~= nil then
		return
	end
	
	if ResearchTechObjectsList[tech_object.Get_Type()] == nil then
		ResearchTechObjectsList[tech_object.Get_Type()] = {}
	end 
	ResearchTechObjectsList[tech_object.Get_Type()] = { ResearchDone = false, ResearchTime = research_time }
	
	-- Add its corresponding entry in the timer table so we can keep track of the progress of the research!
	ResearchTimerTable[tech_object.Get_Type()] = { end_time = research_time }
	TotalResearchTime = TotalResearchTime + research_time
	
	-- If there is a scenario script
	game_mode_script = Get_Game_Mode_Script()
	if game_mode_script then
		-- Add an event for scan completion that may be handled there.
		game_mode_script.Call_Function("On_Tech_Acquired", tech_object)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 04.03.2006
-- This function gets called when the research of a tech object is completed.  Hence, the player gets the corresponding tech upgrade!.
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function Give_Tech(tech_object_type)

	-- Make sure everything is set properly!.
	if ResearchTechObjectsList[tech_object_type] == nil then 
		MessageBox("Military_Player.lua::Give_Tech() -- VERY BAD!!!! No entry for object %s in the Research List!!!!", tostring(tech_object_type.Get_Name()))
	end

	-- Flag the object in the list to have been successfully researched!.
	if ResearchTechObjectsList[tech_object_type].ResearchDone == false then 
		ResearchTechObjectsList[tech_object_type].ResearchDone = true
		TotalResearchTime = TotalResearchTime - ResearchTechObjectsList[tech_object_type].ResearchTime
	end

end

-- ------------------------------------------------------------------------------------------------------------------
-- Get_Builders_Count
-- ------------------------------------------------------------------------------------------------------------------
function Get_Builders_Count()
	return 0 
end