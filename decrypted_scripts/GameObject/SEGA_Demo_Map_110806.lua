-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SEGA_Demo_Map_110806.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SEGA_Demo_Map_110806.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Joseph_Gernert $
--
--            $Change: 57742 $
--
--          $DateTime: 2006/11/08 18:47:46 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)
	
	civ_type_list = {
		"American_Civilian_Urban_01_Map_Loiterer",
		"American_Civilian_Urban_02_Map_Loiterer",
		"American_Civilian_Urban_03_Map_Loiterer",
		"American_Civilian_Urban_04_Map_Loiterer",
		"American_Civilian_Urban_05_Map_Loiterer",
		"American_Civilian_Urban_06_Map_Loiterer",
		"American_Civilian_Urban_07_Map_Loiterer",
		"American_Civilian_Urban_08_Map_Loiterer",
		"American_Civilian_Urban_09_Map_Loiterer",
		"American_Civilian_Urban_10_Map_Loiterer",
		"American_Civilian_Urban_11_Map_Loiterer",
	}
	
	panicked_civ_spawner_list = {}
	civ_spawn_list = {}
	total_spawn_flags = 0

end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("SEGA_Demo_Map_110806 Start!!"))
		
		--MessageBox("JDG VerticalSlice -- starting unit definitions")
		uea = Find_Player("Military")
		neutral = Find_Player("Neutral")
		aliens = Find_Player("Alien")
		civilian = Find_Player("Civilian")
		novus = Find_Player("Novus")
		masari = Find_Player("Masari")
		
		if novus then FogOfWar.Reveal_All(novus) end
		if aliens then FogOfWar.Reveal_All(aliens) end
		if uea then FogOfWar.Reveal_All(uea) end
		
		camera_start = Find_Hint("MARKER_CAMERA", "camera-start")
		Point_Camera_At(camera_start)
		
		panicked_civ_spawner_list = Find_All_Objects_Of_Type("MARKER_GENERIC_PURPLE")
		total_spawn_flags = table.getn(panicked_civ_spawner_list)
		
		counter_civ_types = table.getn(civ_type_list)
		
		_CustomScriptMessage("JoeLog.txt", string.format("total_spawn_flags = %d", total_spawn_flags))
		
		Create_Thread("Thread_Spawn_Panicked_Civs")
		Make_Civilians_Panic(camera_start, 0)
	end
end

function Thread_Spawn_Panicked_Civs()

	while (true) do
		local spawn_location_roll = GameRandom(1, total_spawn_flags)
		local spawn_number_roll = GameRandom(5, 10) --spawn a max of 10 guys
		local spawn_flag = panicked_civ_spawner_list[spawn_location_roll]
		
		--fill in the spawn list
		for i=1,spawn_number_roll do
			civ_spawn_list[i] = civ_type_list[GameRandom(1,counter_civ_types)]
		end
		
		for i, civ_spawn in pairs(civ_spawn_list) do
			new_civ = Spawn_Unit(Find_Object_Type(civ_spawn), spawn_flag, civilian) 
		end
		
		Sleep(1)
		Make_Civilians_Panic(spawn_flag, 1000)
		Sleep(5)
		
	end
end







		

		

		

		


		


		



	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

