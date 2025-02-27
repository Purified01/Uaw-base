if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[128] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/ResearchPanel.lua 
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/06/07 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- MANAGES ALL THE RESEARCH TREES (different tabs in the research panel) for the player

require("PGCommands")
require("ResearchTreeOffensive_Scene")

ResearchTreesTable = {}

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	
	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	ResearchTreesTable = {}
	
	if ResearchPanel == nil then
		return
	end
	
	-- hide panel components.
	ResearchPanel.TreeQuad.Set_Hidden(true)
	ResearchPanel.ExitPanelButton.Set_Hidden(true)
	ResearchPanel.TechDescQuad.Set_Hidden(true)
	ResearchPanel.TechDescText.Set_Hidden(true)
	ResearchPanel.TechReqQuad.Set_Hidden(true)
	ResearchPanel.TechReqText.Set_Hidden(true)
	
	-- Register event handlers
	ResearchPanel.Register_Event_Handler("Button_Clicked", ResearchPanel.ExitPanelButton, On_Close_Panel)
	
	ResearchPanel.Register_Event_Handler("Set_Tech_Requirement_Text", nil, Set_Tech_Requirement_Text)
	ResearchPanel.Register_Event_Handler("Clear_Tech_Requirement_Text", nil, Clear_Tech_Requirement_Text)
	
	ResearchPanel.Register_Event_Handler("Set_Tech_Description_Text", nil, Set_Tech_Description_Text)
	ResearchPanel.Register_Event_Handler("Clear_Tech_Description_Text", nil, Clear_Tech_Description_Text)
	
	ResearchPanel.Register_Event_Handler("Initialize_Tree_Scenes", nil, Initialize_Tree_Scene)
	Set_Scene(ResearchPanel)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- Open_Panel
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Open_Panel()

	if ResearchPanel.TreeQuad.Get_Hidden() == true then
		ResearchPanel.TreeQuad.Set_Hidden(false)
		ResearchPanel.ExitPanelButton.Set_Hidden(false)
		ResearchPanel.TechDescQuad.Set_Hidden(false)
		ResearchPanel.TechReqQuad.Set_Hidden(false)
		
		-- Display the Offensive tree
		--Raise_Event_Immediate_All_Scenes("Display_Tree", {})
		Display_Tree()
		Play_SFX_Event("GUI_Generic_Open_Window")
	else
		Close_Panel()
	end
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- On_Update
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()
	Track_Progress()
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- On_Close_Panel
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Close_Panel(event, source)
	Close_Panel()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- Close_Panel
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Close_Panel()
	ResearchPanel.TreeQuad.Set_Hidden(true)
	ResearchPanel.ExitPanelButton.Set_Hidden(true)
	ResearchPanel.TechDescQuad.Set_Hidden(true)
	ResearchPanel.TechDescText.Set_Hidden(true)
	ResearchPanel.TechReqQuad.Set_Hidden(true)
	ResearchPanel.TechReqText.Set_Hidden(true)
	
	-- Hide the trees
	--Raise_Event_Immediate_All_Scenes("Hide_Tree", {})
	Hide_Tree()
	Play_SFX_Event("GUI_Generic_Close_Window")
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- Set_Tech_Requirement_Text
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Tech_Requirement_Text(event, source, text)
	ResearchPanel.TechReqText.Set_Hidden(false)
	ResearchPanel.TechReqText.Set_Text(Get_Game_Text("TEXT_TECH_REQUIREMENTS"))
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- Clear_Tech_Requirement_Text
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Clear_Tech_Requirement_Text(event, source)
	ResearchPanel.TechReqText.Set_Hidden(true)
	ResearchPanel.TechReqText.Set_Text("")
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- Set_Tech_Description_Text
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Tech_Description_Text(event, source, text)
	ResearchPanel.TechDescText.Set_Hidden(false)
	ResearchPanel.TechDescText.Set_Text(text)
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.08.2006
-- Clear_Tech_Description_Text
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Clear_Tech_Description_Text(event, source)
	ResearchPanel.TechDescText.Set_Hidden(true)
	ResearchPanel.TechDescText.Set_Text("")
end


-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------
-- TODO : code to manage the different tabs in the panel!
-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------

Interface = {}
Interface.Open_Panel = Open_Panel
Interface.Close_Panel = Close_Panel 
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
