-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGMovieCommands.lua#15 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGMovieCommands.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Mike_Lytle $
--
--            $Change: 84741 $
--
--          $DateTime: 2007/09/25 11:09:21 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")

function Hero_Movie_Finished_Callback(hero_object)

	for idx, b_obj in pairs (MovieBlockTable) do
		if b_obj.Hero == hero_object then
			b_obj.FinishedFlag = true
			table.remove(MovieBlockTable, idx)
			return
		end
	end
	
end

function Stop_Hero_Movie(hero_object)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Stop_Hero_Movie", nil, {hero_object} )
end

function Start_Hero_Movie(hero_object, movie_file)
	
	if not TestValid(hero_object) then
		MessageBox("Movie player didn't receive a valid hero for %s; playing nothing", movie_file)
		return
	end

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

	 -- Determine if the speech event has already been added.
	for _, b_obj in pairs (MovieBlockTable) do
		if b_obj.Hero == hero_object then
			return nil
		end
	end

	local block_object = {}

	-- Set up a blocking object for movie playing
	block_object.Hero = hero_object
	block_object.FinishedFlag = false
	block_object.ResultValue = true
	block_object.MovieFile = movie_file

	block_object.IsFinished = 
		function ()
			return block_object.FinishedFlag
		end

	block_object.Result = 
		function ()
			return block_object.ResultValue
		end

	table.insert(MovieBlockTable, block_object)
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Start_Hero_Movie", nil, {hero_object, movie_file, Script, "Hero_Movie_Finished_Callback"} )
	return block_object
end

function Talking_Head_Finished_Callback(hero_object)
	for idx, b_obj in pairs (TalkingHeadBlockTable) do
		if b_obj.SpeechEvent == hero_object then
			b_obj.FinishedFlag = true
			table.remove(TalkingHeadBlockTable, idx)
			return
		end
	end
end

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

	-- Determine if the speech event has already been added.
	for _, b_obj in pairs (TalkingHeadBlockTable) do
		if b_obj.SpeechEvent == speech_event_name then
			return nil
		end
	end

	-- Set up a blocking object for movie playing
	local block_object = {}

	block_object.Hero = hero_object
	block_object.FinishedFlag = false
	block_object.ResultValue = true
	block_object.SpeechEvent = speech_event_name
	block_object.Pip = pip_index

	block_object.IsFinished = 
		function ()
			return block_object.FinishedFlag
		end

	block_object.Result = 
		function ()
			return block_object.ResultValue
		end

	table.insert(TalkingHeadBlockTable, block_object)

	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Queue_Talking_Head", nil, {hero_object, speech_event_name, pip_index, Script, "Talking_Head_Finished_Callback", } )
	return block_object
end

function Set_PIP_Model(pip_index, model_name)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_PIP_Model", nil, {pip_index, model_name} )
end

function Flush_PIP_Queue()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Flush_PIP_Queue", nil, nil)	
end

function Movie_Commands_Post_Load_Callback()

	-- Make sure that all the talking heads are re-enabled.
	for _, b_obj in pairs (TalkingHeadBlockTable) do
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Queue_Talking_Head", nil, {b_obj.Hero, b_obj.SpeechEvent, b_obj.Pip, Script, "Talking_Head_Finished_Callback", } )
 	end

	for _, b_obj in pairs (MovieBlockTable) do
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Start_Hero_Movie", nil, {b_obj.Hero, b_obj.MovieFile, Script, "Hero_Movie_Finished_Callback"} )
 	end


end