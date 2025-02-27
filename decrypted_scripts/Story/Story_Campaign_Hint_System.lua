if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[19] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Hint_System.lua#9 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Story/Story_Campaign_Hint_System.lua $
--
--    Original Author: Rick Donnelly
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGHintSystem")
require("PGHintSystemDefs")

-- Don't pool story scripts.
ScriptPoolCount = 0


function On_Construction_Complete(obj, constructor)
	if TestValid(obj) then	
		if obj.Get_Owner() == Find_Player("local") then
			obj_type = obj.Get_Type()
			
			PGHintSystemDefs_Init()
			PGHintSystem_Init()
			
			-- Novus Construction Hints
			if obj_type == Find_Object_Type("NOVUS_REFLEX_TROOPER") then
				Add_Attached_Hint(obj, 40)

			elseif obj_type == Find_Object_Type("NOVUS_ROBOTIC_INFANTRY") then
				Add_Attached_Hint(obj, 41)

			elseif obj_type == Find_Object_Type("NOVUS_VARIANT") then
				Add_Attached_Hint(obj, 42)

			elseif obj_type == Find_Object_Type("NOVUS_AMPLIFIER") then
				Add_Attached_Hint(obj, 43)

			elseif obj_type == Find_Object_Type("NOVUS_ANTIMATTER_TANK") then
				Add_Attached_Hint(obj, 44)

			elseif obj_type == Find_Object_Type("NOVUS_CONSTRUCTOR") then
				Add_Attached_Hint(obj, 45)

			elseif obj_type == Find_Object_Type("NOVUS_DERVISH_JET") then
				Add_Attached_Hint(obj, 46)

			elseif obj_type == Find_Object_Type("NOVUS_FIELD_INVERTER") then
				Add_Attached_Hint(obj, 47)
				
			elseif obj_type == Find_Object_Type("NOVUS_HACKER") then
				Add_Attached_Hint(obj, 49)

			elseif obj_type == Find_Object_Type("NOVUS_CORRUPTOR") then
				Add_Attached_Hint(obj, 48)


			-- Hierarchy Construction Hints
			elseif obj_type == Find_Object_Type("ALIEN_BRUTE") then
				Add_Attached_Hint(obj, 17)

			elseif obj_type == Find_Object_Type("ALIEN_GLYPH_CARVER") then
				Add_Attached_Hint(obj, 18)

			elseif obj_type == Find_Object_Type("ALIEN_GRUNT") then
				Add_Attached_Hint(obj, 19)

			elseif obj_type == Find_Object_Type("ALIEN_LOST_ONE") then
				Add_Attached_Hint(obj, 20)

			elseif obj_type == Find_Object_Type("ALIEN_CYLINDER") then
				Add_Attached_Hint(obj, 21)

			elseif obj_type == Find_Object_Type("ALIEN_DEFILER") then
				Add_Attached_Hint(obj, 22)

			elseif obj_type == Find_Object_Type("ALIEN_FOO_CORE") then
				Add_Attached_Hint(obj, 23)

			elseif obj_type == Find_Object_Type("ALIEN_SUPERWEAPON_REAPER_TURRET") then
				Add_Attached_Hint(obj, 24)

			elseif obj_type == Find_Object_Type("ALIEN_RECON_TANK") then
				Add_Attached_Hint(obj, 25)
				
				
			-- Masari Construction Hints
			elseif obj_type == Find_Object_Type("MASARI_FIGMENT") then
				Add_Attached_Hint(obj, 60)

			elseif obj_type == Find_Object_Type("MASARI_SEEKER") then
				Add_Attached_Hint(obj, 61)

			elseif obj_type == Find_Object_Type("MASARI_SKYLORD") then
				Add_Attached_Hint(obj, 62)

			elseif obj_type == Find_Object_Type("MASARI_ARCHITECT") then
				Add_Attached_Hint(obj, 66)

			elseif obj_type == Find_Object_Type("MASARI_AVENGER") then
				Add_Attached_Hint(obj, 67)

			elseif obj_type == Find_Object_Type("MASARI_DISCIPLE") then
				Add_Attached_Hint(obj, 68)

			elseif obj_type == Find_Object_Type("MASARI_SEER") then
				Add_Attached_Hint(obj, 69)

			elseif obj_type == Find_Object_Type("MASARI_ENFORCER") then
				Add_Attached_Hint(obj, 70)

			elseif obj_type == Find_Object_Type("MASARI_PEACEBRINGER") then
				Add_Attached_Hint(obj, 71)

			elseif obj_type == Find_Object_Type("MASARI_SENTRY") then
				Add_Attached_Hint(obj, 72)
			end
		end
	
		-- Check for Story construction events.
		if Story_On_Construction_Complete then
			Story_On_Construction_Complete(obj, constructor)
		end
	end	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	Activate_Independent_Hint = nil
	BlockOnCommand = nil
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
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	Notify_Attached_Hint_Created = nil
	On_Remove_Xbox_Controller_Hint = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Hint_Context_Scene = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
	Set_Achievement_Map_Type = nil
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
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
