-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/Test_All_Pips_RAD_072707.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/Test_All_Pips_RAD_072707.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Elie_Arabian $
--
--            $Change: 78964 $
--
--          $DateTime: 2007/07/30 15:45:57 $
--
--          $Revision: #3 $
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
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)

	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_hi_science = "AI_Science_Officer_Pip_Head.alo"
	pip_hi_comm = "AI_Comm_Officer_Pip_Head.alo"
	pip_hi_grunt = "AI_Grunt_Pip_Head.alo"

	pip_col_moore = "MH_Moore_pip_head.alo"
	pip_ma_comm_officer = "Mi_comm_officer_pip_head.alo"
	pip_marine = "Mi_marine_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_chopper = "Mi_airforce_pip_head.alo"

	pip_viktor = "NH_Viktor_pip_Head.alo"
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	pip_altea = "ZH_Altea_Pip_head.alo"
	pip_charos = "ZH_Charos_pip_Head.alo"
	pip_zessus = "ZH_Zessus_Pip_head.alo"
	pip_disciple = "ZI_Disciple_pip_head.alo"
	pip_architect = "ZI_Architect_Pip_head.alo"
		
end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		Create_Thread("Thread_Show_PIPs")
	end
end

function Thread_Show_PIPs()
   Sleep(1)
   
   while true do 
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Mirabel"} )
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"The Founder"} )
		BlockOnCommand(Queue_Talking_Head(pip_founder, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Vertigo"} )
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Comm Officer"} )
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "HIE01_SCENE02_06"))
		
		Sleep(1)
  		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Science Officer"} )
		BlockOnCommand(Queue_Talking_Head(pip_novscience, "HIE01_SCENE02_06"))

	
   end
   
   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Orlok"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE02_06"))
   
   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Kamal"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Hierarchy Science Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_hi_science, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Hierarchy Comm Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_hi_comm, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Hierarchy Grunt"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_hi_grunt, "HIE01_SCENE02_06"))


   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Moore"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_col_moore, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Military Comm Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_ma_comm_officer, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Marine"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_marine, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Woolard"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_woolard, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Military Chopper Pilot"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_chopper, "HIE01_SCENE02_06"))


   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Viktor"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_viktor, "HIE01_SCENE02_06"))

   

   

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Science Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_novscience, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Novus Comm Officer"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_novcomm, "HIE01_SCENE02_06"))


   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Altea"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_altea, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Charos"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_charos, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Zessus"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_zessus, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Masari Disciple"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_disciple, "HIE01_SCENE02_06"))

   -- Sleep(1)
  	-- Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Masari Architect"} )
	-- BlockOnCommand(Queue_Talking_Head(pip_architect, "HIE01_SCENE02_06"))

end











