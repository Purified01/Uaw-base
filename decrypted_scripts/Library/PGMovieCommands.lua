if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[174] = true
LuaGlobalCommandLinks[173] = true
LuaGlobalCommandLinks[117] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGMovieCommands.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGMovieCommands.lua $
--
--    Original Author: Brian Hayes
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

require("PGCommands")

function Queue_Talking_Head(hero_object, speech_event_name, pip_index)

	-- Make a fake block object if we want to skip hero PIP movies during development
	if SkipHeroMovies then
		block_object = {}
		block_object.IsFinished = 
			function ()
				return true
			end
		block_object.Result = 
			function ()
				return false
			end
		return block_object
	end

	if not pip_index then
		pip_index = 1
	end
	
	if not hero_object then
		hero_object = ""
	end

	Get_Game_Mode_GUI_Scene().Raise_Event("Queue_Talking_Head", nil, {hero_object, speech_event_name, pip_index})
	return Queue_Speech_Event(speech_event_name)
end

function Set_PIP_Model(pip_index, model_name)
	Get_Game_Mode_GUI_Scene().Raise_Event("Set_PIP_Model", nil, {pip_index, model_name} )
end

function Flush_PIP_Queue()
	--No parameter = cancel all.  This must be called from the game logic thread.
	Cancel_Queued_Speech_Events()
	Get_Game_Mode_GUI_Scene().Raise_Event("Flush_PIP_Queue", nil, nil)	
end

function Movie_Commands_Post_Load_Callback()

	-- Make sure that all the talking heads are re-enabled.
	for _, b_obj in pairs (TalkingHeadBlockTable) do
		Get_Game_Mode_GUI_Scene().Raise_Event("Queue_Talking_Head", nil, {b_obj.Hero, b_obj.SpeechEvent, b_obj.Pip} )
 	end

end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Movie_Commands_Post_Load_Callback = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
