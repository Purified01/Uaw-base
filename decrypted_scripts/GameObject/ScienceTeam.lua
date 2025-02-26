if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[114] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/ScienceTeam.lua#7 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GameObject/ScienceTeam.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- local function Behavior_Init()
-- end
--
-- local function Behavior_Service()
-- end
--
-- local function Behavior_Object_In_Range(prox_object, object)
-- end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Tech_Powerup_Retrieval_Failed
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Tech_Powerup_Retrieval_Failed(tech_object)

	if Tech_Retrieval_Thread_ID then
		Thread.Kill(Tech_Retrieval_Thread_ID)
	end	
	CountdownTimer = nil
	
	local scene = tech_object.Get_GUI_Scene()
	
	if scene then
		scene.Raise_Event("Tech_Object_Retrieval_Failed", tech_object, {} )		
	end
	
	Object.Play_SFX_Event("Unit_Retrieve_Fail_UEA_Science_Team")		
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Tech_Powerup_Retrieval_Finished
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Tech_Powerup_Retrieval_Finished(params)

	Tech_Retrieval_Thread_ID = Thread.Get_Current_ID()
	tech_object = params[2]
	Sleep(params[1])
	Tech_Retrieval_Thread_ID = nil
	CountdownTimer = nil
	
	local scene = tech_object.Get_GUI_Scene()
	if scene then
		scene.Raise_Event("Tech_Object_Retrieval_Completed", tech_object, {})
	end
	
	local player_script = Object.Get_Owner().Get_Script()
	if player_script then
		local research_time = SCIENCE_TEAM_RESEARCH_TIME[tech_object.Get_Type().Get_Name()]
	
		player_script.Call_Function("Acquire_Tech_Object", tech_object, research_time)
	end
	
	tech_object.Despawn()
	Object.Play_SFX_Event("Unit_Retrieve_Success_UEA_Science_Team")
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Tech_Powerup_In_Range
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Tech_Powerup_In_Range(tech_object)

	if CountdownTimer == nil then
		CountdownTimer = SCIENCE_TEAM_ANALYZE_TIME[tech_object.Get_Type().Get_Name()]
		
		if CountdownTimer then
			tech_object.Get_Script().Call_Function("Tech_Powerup_Lock_Retrieval", Object)
						
			scene = tech_object.Get_GUI_Scene()
			if scene then
				scene.Raise_Event("Start_Tech_Object_Retrieval", tech_object, {CountdownTimer, tech_object.Get_Type().Get_Name()})
			end

			-- If there is a scenario script
			game_mode_script = Get_Game_Mode_Script()
			if game_mode_script then
		
				-- Add an event for scan initiation that may be handled there.
				game_mode_script.Call_Function("On_Tech_Scan_Begin", tech_object)
			end
								
			Create_Thread("Tech_Powerup_Retrieval_Finished", { CountdownTimer, tech_object } )
			Object.Play_SFX_Event("Unit_Retrieve_Start_UEA_Science_Team")
		end
	end

end


-- This line must be at the bottom of the file.
-- my_behavior.Init = Behavior_Init
-- my_behavior.Object_In_Range = Behavior_Object_In_Range
-- my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
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
	Remove_Invalid_Objects = nil
	Simple_Round = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
