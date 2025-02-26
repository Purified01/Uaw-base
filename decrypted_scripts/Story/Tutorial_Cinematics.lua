if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[131] = true
LuaGlobalCommandLinks[117] = true
LuaGlobalCommandLinks[119] = true
LuaGlobalCommandLinks[116] = true
LuaGlobalCommandLinks[28] = true
LuaGlobalCommandLinks[29] = true
LuaGlobalCommandLinks[39] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[69] = true
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[84] = true
LuaGlobalCommandLinks[200] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Tutorial_Cinematics.lua#12 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Tutorial_Cinematics.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #12 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Tutorial_1", State_Tutorial_1)
	Define_State("State_Tutorial_2", State_Tutorial_2)
	Define_State("State_Tutorial_3", State_Tutorial_3)
	Define_State("State_Tutorial_4", State_Tutorial_4)
	Define_State("State_Tutorial_5", State_Tutorial_5)
	Define_State("State_Tutorial_6", State_Tutorial_6)
	Define_State("State_Tutorial_7", State_Tutorial_7)
	Define_State("State_Tutorial_8", State_Tutorial_8)
	Define_State("State_Tutorial_9", State_Tutorial_9)
	Define_State("State_Tutorial_10", State_Tutorial_10)
	Define_State("State_Tutorial_11", State_Tutorial_11)
	Define_State("State_Tutorial_12", State_Tutorial_12)
	Define_State("State_Tutorial_13", State_Tutorial_13)
	Define_State("State_Tutorial_14", State_Tutorial_14)
	Define_State("State_Tutorial_15", State_Tutorial_15)
	Define_State("State_Tutorial_16", State_Tutorial_16)
	
	current_cine_thread=nil
	
	IsTutorialCampaign = true;

end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		Letter_Box_In(0)
		Stop_All_Music()
		Lock_Controls(1)
		
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Tutorial == nil then
			Quit_To_Main_Menu()
		else
			Set_Next_State(tostring(data_table.Tutorial))
			data_table.Tutorial = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
	elseif message == OnUpdate then
	end
end

function State_Tutorial_1(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_1.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_2(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_2.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_3(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_3.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_4(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_4.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_5(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_5.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_6(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_6.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_7(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_7.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_8(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_8.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_9(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_9.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_10(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_10.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_11(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_11.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_12(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_12.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_13(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_13.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_14(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_14.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_15(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_15.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_16(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_16.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function Movie(file)

	Close_Battle_Load_Dialog()
	
	--french and german need slower movie frame rates to
	--fit in the speech
	--Can't call Stop on the fake movie directly - it's not thread-safe
	if Get_Speech_Language() == "FRENCH" then
		BlockOnCommand(Play_Bink_Movie("blank.bik", false))
		Get_Game_Mode_GUI_Scene().full_screen_movie.Force_Frame_Rate(18)	
	elseif Get_Speech_Language() == "GERMAN" then
		BlockOnCommand(Play_Bink_Movie("blank.bik", false))
		Get_Game_Mode_GUI_Scene().full_screen_movie.Force_Frame_Rate(15)
	end
	if Is_Gamepad_Active() then
		file = "360_" .. file
	end
    BlockOnCommand(Play_Bink_Movie(file,true))
    Get_Game_Mode_GUI_Scene().full_screen_movie.Reset_Frame_Rate()
    current_cine_thread=nil
end

function Quit_To_Main_Menu()
	Letter_Box_Out(0)
	Lock_Controls(0)
	_Quit_Game_Now()
end

--***************************************THREADS****************************************************************************************************

function Story_Handle_Esc()
	if not EscToStartState then
		if current_cine_thread then
			Thread.Kill(current_cine_thread)
			current_cine_thread=nil
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
	Enable_UI_Element_Event = nil
	Find_All_Parent_Units = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Does_Object_Have_Lua_Behavior = nil
	GUI_Pool_Free = nil
	Get_Current_State = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Get_Next_State = nil
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
	Remove_Invalid_Objects = nil
	Reset_Objectives = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
	Set_Objective_Text = nil
	Show_Object_Attached_UI = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Spawn_Dialog_Box = nil
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
