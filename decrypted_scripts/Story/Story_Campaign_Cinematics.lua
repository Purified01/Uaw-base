if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[46] = true
LuaGlobalCommandLinks[84] = true
LuaGlobalCommandLinks[29] = true
LuaGlobalCommandLinks[69] = true
LuaGlobalCommandLinks[131] = true
LuaGlobalCommandLinks[28] = true
LuaGlobalCommandLinks[39] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Cinematics.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Cinematics.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 94190 $
--
--          $DateTime: 2008/02/27 16:41:49 $
--
--          $Revision: #8 $
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
	Define_State("State_Cine_1", State_Cine_1)
	Define_State("State_Cine_2", State_Cine_2)
	Define_State("State_Cine_3", State_Cine_3)
	Define_State("State_Cine_4", State_Cine_4)
	Define_State("State_Cine_5", State_Cine_5)
	Define_State("State_Cine_6", State_Cine_6)
	Define_State("State_Cine_7", State_Cine_7)
	Define_State("State_Cine_8", State_Cine_8)
	Define_State("State_Cine_9", State_Cine_9)
	Define_State("State_Cine_10", State_Cine_10)
	Define_State("State_Cine_11", State_Cine_11)
	Define_State("State_Cine_12", State_Cine_12)
	Define_State("State_Cine_13", State_Cine_13)
	Define_State("State_Cine_14", State_Cine_14)
	Define_State("State_Cine_15", State_Cine_15)
	Define_State("State_Cine_16", State_Cine_16)
	Define_State("State_Cine_17", State_Cine_17)
	Define_State("State_Cine_18", State_Cine_18)
	Define_State("State_Cine_19", State_Cine_19)
	Define_State("State_Cine_20", State_Cine_20)
	Define_State("State_Cine_21", State_Cine_21)
	Define_State("State_Cine_Campaign_Over", State_Cine_Campaign_Over)
	
	current_cine_thread=nil
	JumpToNextCine=false
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		Letter_Box_In(0)
		Stop_All_Music()
		Lock_Controls(1)
		Close_Battle_Load_Dialog()
		Set_Next_State("State_Cine_1")
	elseif message == OnUpdate then
	end
end

function State_Cine_1(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Mission_1_Intro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_2")
		end
	end
end

function State_Cine_2(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Mission_1_Outro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_3")
		end
	end
end

function State_Cine_3(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Mission_2_Midtro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_4")
		end
	end
end

function State_Cine_4(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Novus_M2_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_5")
		end
	end
end

function State_Cine_5(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Novus_M3_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_6")
		end
	end
end

function State_Cine_6(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Novus_M7_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_7")
		end
	end
end

function State_Cine_7(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Novus_M7_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_8")
		end
	end
end

function State_Cine_8(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_Intro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_9")
		end
	end
end

function State_Cine_9(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M1_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_11")
		end
	end
end

-- skip this state.  there is no HIER_M1_S4 movie
function State_Cine_10(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M1_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_11")
		end
	end
end

function State_Cine_11(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M2_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_12")
		end
	end
end

function State_Cine_12(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M4_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_13")
		end
	end
end

function State_Cine_13(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M4_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_14")
		end
	end
end

function State_Cine_14(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M5_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_15")
		end
	end
end

function State_Cine_15(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M6_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_16")
		end
	end
end

function State_Cine_16(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_M6_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_17")
		end
	end
end

function State_Cine_17(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Hierarchy_Campaign_Finale")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_18")
		end
	end
end

function State_Cine_18(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Masari_Campaign_Intro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_19")
		end
	end
end

function State_Cine_19(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Masari_M1_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_20")
		end
	end
end

function State_Cine_20(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","Masari_Campaign_Finale")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_21")
		end
	end
end

function State_Cine_21(message)
	if message == OnEnter then
		Close_Battle_Load_Dialog()
		current_cine_thread=Create_Thread("Movie","CREDITS")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_Campaign_Over")
		end
	end
end

function Movie(file)
    BlockOnCommand(Play_Bink_Movie(file,true))
    current_cine_thread=nil
end

--detects the win of NM07 and then exits to main menu
function State_Cine_Campaign_Over(message)
	if message == OnEnter then
		Letter_Box_Out(0)
		Lock_Controls(0)
		Quit_Game_Now(novus, true, true, false)
	end
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
