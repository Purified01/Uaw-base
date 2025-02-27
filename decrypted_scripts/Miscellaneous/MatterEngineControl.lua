LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/MatterEngineControl.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/MatterEngineControl.lua $
--
--    Original Author: Keith Brors
--
--            $Author: James_Yarrow $
--
--            $Change: 94166 $
--
--          $DateTime: 2008/02/27 14:56:33 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGCommands")
require("PGBase")
require("PGUICommands")

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Matter_Engine_Control - called on scene creation
-- ------------------------------------------------------------------------------------------------------------------
function Init_Matter_Engine_Control()
	
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	MatterEngineOwners={}
	Script.Set_Async_Data("MatterEngineOwners", MatterEngineOwners)
	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Register_Matter_Engine_With_Control - 
-- ------------------------------------------------------------------------------------------------------------------
function Register_Matter_Engine_With_Control(object)

	if TestValid(object) then
		local player = object.Get_Owner()
		-- key == object, value == player
		if player ~= nil then
			
			object.Register_Signal_Handler(Matter_Engine_Delete_Pending, "OBJECT_DELETE_PENDING")
			object.Register_Signal_Handler(Matter_Engine_Delete_Pending, "OBJECT_OWNER_CHANGED")
	
			-- get the resource storage for this object
			local storage = 0.0
			local object_script = object.Get_Script()
			if object_script ~= nil then
				local matter_engine = object_script.Get_Variable("MatterEngine")
				if matter_engine == nil or matter_engine.ResourcesStorage == nil then
					storage = 0.0
				else
					storage = matter_engine.ResourcesStorage
				end
			end
	
			if MatterEngineOwners[player] == nil then
				MatterEngineOwners[player] = {}
				MatterEngineOwners[player].Count = 1
				MatterEngineOwners[player][1]={}
				MatterEngineOwners[player][1].Index=1
				MatterEngineOwners[player][1].Object=object
				MatterEngineOwners[player][1].Storage = storage
				MatterEngineOwners[player][object]=MatterEngineOwners[player][1]
			elseif MatterEngineOwners[player][object] == nil then
				MatterEngineOwners[player].Count = MatterEngineOwners[player].Count+1
				MatterEngineOwners[player][MatterEngineOwners[player].Count] = {}
				MatterEngineOwners[player][MatterEngineOwners[player].Count].Index=MatterEngineOwners[player].Count
				MatterEngineOwners[player][MatterEngineOwners[player].Count].Object=object
				MatterEngineOwners[player][MatterEngineOwners[player].Count].Storage = storage
				MatterEngineOwners[player][object]=MatterEngineOwners[player][MatterEngineOwners[player].Count]
			end
		end
	end

	Script.Set_Async_Data("MatterEngineOwners", MatterEngineOwners)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Matter_Engine_Delete_Pending - 
-- ------------------------------------------------------------------------------------------------------------------
function Matter_Engine_Delete_Pending(object)
	Remove_Matter_Engine(object)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Remove_Matter_Engine
-- ------------------------------------------------------------------------------------------------------------------
function Remove_Matter_Engine(object)
	if object ~= nil then
		local player = object.Get_Owner()
		if player ~= nil then
			if MatterEngineOwners[player] ~= nil and MatterEngineOwners[player][object] ~= nil then
			
				local index = MatterEngineOwners[player][object].Index
				table.remove(MatterEngineOwners[player],index)
				MatterEngineOwners[player].Count = MatterEngineOwners[player].Count -1
				
				for i=1, MatterEngineOwners[player].Count do
					MatterEngineOwners[player][i].Index = i
				end
				
				MatterEngineOwners[player][object] = nil				
			end
		end
	end
	Script.Set_Async_Data("MatterEngineOwners", MatterEngineOwners)
end

-- -------------------------------------------------------------------------------------------------------------------------
-- Pre_Save_Callback
-- -------------------------------------------------------------------------------------------------------------------------
function Pre_Save_Callback()
	Base_Pre_Save_Callback()
	Script.Set_Async_Data("MatterEngineOwners", nil)
end


-- -------------------------------------------------------------------------------------------------------------------------
-- Post_Save_Callback
-- -------------------------------------------------------------------------------------------------------------------------
function Post_Save_Callback()
	Script.Set_Async_Data("MatterEngineOwners", MatterEngineOwners)
end

function Post_Load_Callback()
	Script.Set_Async_Data("MatterEngineOwners", MatterEngineOwners)
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
	Init_Matter_Engine_Control = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Safe_Set_Hidden = nil
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
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
