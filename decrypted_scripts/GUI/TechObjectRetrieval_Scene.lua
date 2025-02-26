LUA_PREP = true

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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/TechObjectRetrieval_Scene.lua 
--
--            Author: Maria Teruel
--
--          DateTime: 2006/03/30 15:27:16 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

TechItemName = ""

-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 03.30.2006
-- Initialize the Scene
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	TechItemName = ""

	TechObjectRetrieval_Scene.Set_Hidden(true)
	
	-- Register to hear when the research progress bar should be created/canceled.
	TechObjectRetrieval_Scene.Register_Event_Handler("Start_Tech_Object_Retrieval", nil, Start_Tech_Object_Retrieval)
	TechObjectRetrieval_Scene.Register_Event_Handler("Tech_Object_Retrieval_Failed", nil, Tech_Object_Retrieval_Failed)
	TechObjectRetrieval_Scene.Register_Event_Handler("Tech_Object_Retrieval_Completed", nil, Tech_Object_Retrieval_Completed)
	
end



-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 03.30.2006
-- Start the Retrieval of the Tech Object
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function Start_Tech_Object_Retrieval(event, source, duration, techItemName)
	
	if duration ~= 0  and techItemName ~= "" then
	
		TechItemName = techItemName
		
		TechObjectRetrieval_Scene.Text_1.Set_Text("Retrieving Tech Item\n"..TechItemName)
		
		TechObjectRetrieval_Scene.Clock_1.Set_Filled(1.0)
		TechObjectRetrieval_Scene.Clock_1.Set_Target(0.0, duration)
		
		TechObjectRetrieval_Scene.Set_Hidden(false)
	end
	
end


-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 03.30.2006
-- Finsih the retrieval of the tech object
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function Tech_Object_Retrieval_Completed()

	if Object and not TechObjectRetrieval_Scene.Get_Hidden() then
		TechObjectRetrieval_Scene.Text_1.Set_Text("")
		TechObjectRetrieval_Scene.Set_Hidden(true)
	end
	
end


-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARIA 03.30.2006
-- Cancel the retrieval of the tech object
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
function Tech_Object_Retrieval_Failed(event, source)

	if Object and not TechObjectRetrieval_Scene.Get_Hidden() then
		TechObjectRetrieval_Scene.Clock_1.Set_Filled(0.0)
		TechObjectRetrieval_Scene.Text_1.Set_Text("")
		TechObjectRetrieval_Scene.Set_Hidden(true)		
	end
	
end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	Declare_Enum = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
