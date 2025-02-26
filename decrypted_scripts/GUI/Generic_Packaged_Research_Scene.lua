if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[14] = true
LuaGlobalCommandLinks[52] = true
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LuaGlobalCommandLinks[116] = true
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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/Generic_Packaged_Research_Scene.lua
--
--            Author: Maria_Teruel
--
--          DateTime: 2006/03/22 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////



--[[
	THIS SCRIPT IS USED TO MANAGE THE RESEARCH TREE SCENE (for all factions)
]]--

require("PGBase")
require("PGUICommands")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.07.2006
--
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Init()


	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Tree = {}
	ProcessingList = {}
	ButtonToNodeTable = {}	
	
	Player = Find_Player("local")
	Player_Script = Player.Get_Script()
	
	if Scene == nil then
		return
	end
	
	Scene.Set_Hidden(false)
	Scene.SuiteContentsScene.Init_Scene()
	Scene.SuiteContentsScene.Set_Hidden(true)
	
	Scene.Register_Event_Handler("Update_Tree_Scene", nil, Update_Tree_Scene)

	
	-- Set the tint to green!
	ClockTint = {0.0, 1.0, 0.0, 170.0/255.0}
	
	BackBarMargin = 4.0 / 1024.0
	
	IsTreeOpen = false
	ActiveSuiteDisplay = nil -- keeps track of the suite whose contents are being displayed so that they can be updated properly
	CurrentResearchProgress = 0.0
	IsDEFCONMode = Initialize_DEFCON()
	Init_Button_Maps()
	
	Update_Tree_Scene()	
	
	last_time = nil
	
	FlashResearchOptions = {}
end



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_DEFCON
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Initialize_DEFCON()

	-- Maria 07.25.2007: This time needs to be a TINY bit smaller than the real DEFCON_COUNTDOWN.
	-- In fact, we need this to be so because we have to make sure the undergoing research is completed before the
	-- new research is started.  If we set both values to be the same, the new research will be started before the 
	-- previous DEFCON level's research is completed. (when modifying this value make sure you modify its equivalent
	-- in Research_Common.lua)
	-- ALWAYS MAKE IT 0.5 SECONDS LESS THAN THE REGULAR COUNTDOWN TO ENSURE RESEARCH
	-- FROM THE LAST DEFCON LEVEL IS COMPLETED BEFORE THE NEW ONE STARTS!!!!!.
	DEFCON_COUNTDOWN = 119.5		-- In seconds
	
	Register_Game_Scoring_Commands()
	-- Is DEFCON enabled from the multiplayer lobby?
	local script_data = GameScoringManager.Get_Game_Script_Data_Table()
	if script_data and script_data.is_defcon_game then
		return true
	end
	return false
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init_Button_Maps
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Button_Maps()

	local tab_order_count = 1
	
	Buttons = {}
	DirAButtons = {}
	DirAButtons = Find_GUI_Components(Scene, "ButtonA")
	Initialize_Buttons(DirAButtons, tab_order_count)
	tab_order_count = tab_order_count + #DirAButtons
	
	DirBButtons = {}
	DirBButtons = Find_GUI_Components(Scene, "ButtonB")
	Initialize_Buttons(DirBButtons, tab_order_count)
	tab_order_count = tab_order_count + #DirBButtons
	
	DirCButtons = {}
	DirCButtons = Find_GUI_Components(Scene, "ButtonC")
	Initialize_Buttons(DirCButtons, tab_order_count)
	tab_order_count = tab_order_count + #DirCButtons 
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_Buttons
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Initialize_Buttons(buttons_table, tab_order_count)
	for index, button in pairs(buttons_table) do
		button.Set_Button_Enabled(false)
--		button.Set_Clockwise(false)
		button.Set_Clock_Tint(ClockTint)
		button.Set_Tab_Order( tab_order_count + index)
		table.insert(Buttons, button)
		
		if IsDEFCONMode then
			button.Hide_A_Button_Overlay(true)
		end

		-- Display/Hide Contents scene -- Mouse
		-- NOTE: we do not register for Mouse_On, Mouse_Off events becuase the Focus_Gained, Focus_Lost events
		-- trigger a selectable icon mouse on/off events, respectively.  Hence, we inlcude both cases in here.
		Scene.Register_Event_Handler("Mouse_Over_Selectable_Icon", button, On_Mouse_Over_Suite_Button)
		Scene.Register_Event_Handler("Mouse_Off_Selectable_Icon", button, On_Mouse_Off_Suite_Button)
		
		-- Start Research (if possible)
		Scene.Register_Event_Handler("Selectable_Icon_Clicked", button, On_Suite_Button_Clicked)
		
		-- Cancel Research (if possible)
		Scene.Register_Event_Handler("Selectable_Icon_Right_Clicked", button, On_Suite_Button_Right_Clicked)
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Maria 06.09.2006
-- Update_Tree_Scene
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Tree_Scene(event, source)

	Player = Find_Player("local")
	Player_Script = Player.Get_Script()
	if not Player_Script then
		return
	end
	
	local TreeData = Player_Script.Get_Async_Data("CachedTreeDataForGUI")
	if TreeData == nil then return end
	local is_campaign = Is_Campaign_Game()
	
	local points_data = Player_Script.Get_Async_Data("CachedPointsDataForGUI")
	local points_string = Get_Game_Text("TEXT_RESEARCH_POINTS")
	Replace_Token(points_string, Get_Localized_Formatted_Number(points_data[0]), 0)
	Replace_Token(points_string, Get_Localized_Formatted_Number(points_data[1]), 1)
	this.ResearchPointsText.Set_Text(points_string)
			
	-- Fill in the tree data
	-- NOTE: each entry in the table contains the following info
	-- (1) - direction = "A", "B" or "C",
	-- (2) - suite index = 1, 2, 3 or 4
	-- (3) - Bool to determine whether the suite is enabled or not
	-- (4) - Bool that determines whether research for this suite has been completed
	-- (5) - Table containing the list of TYPES this suite unlocks
	-- (6) - Table containing the list of UNIT abilities this suite unlocks
	-- (7) - Table containing the list of SPECIAL abilities this suite unlocks
	-- (8) - Table containing the list of EFFECT GENERATORS this suite UNLOCKS
	-- (9) - Table containing the list of EFFECTS this suite unlocks
	-- (10) - Table containing the list of EFFECT GENERATORS this suite LOCKS
	-- (11) - Table containing the list of PATCHES this suite unlocks (if any)
	-- (12) - Start Research Time (if any)
	-- (13) -Total Research Time assigned to this suite
	-- (14) - Name of the texture assigned to the suite's current state
	-- (15) - Name of the current suite (branch direction and suite name)
	-- (16) - Tactical Cost (if applicable)
	-- For the gamepad version we also have
	-- (17) - gamepad_display_x_overlay
	-- (18) - gamepad_display_a_overlay

	--NOTE: must reset because we only get information from the nodes that are enabled!
	Reset_Buttons()
	
	local node_info = {}
	local max_completed_index = {}
	for _, node_data in pairs(TreeData) do
		
		node_info =
				{
					NodePath = node_data[1],
					NodeIndex = node_data[2],
					Enabled = node_data[3],
					Completed = node_data[4],
					TypesList = node_data[5],
					AbilitiesList = node_data[6],
					SpecialAbilitiesList = node_data[7],
					UnlockEffectGeneratorsList = node_data[8],
					EffectsList = node_data[9],
					LockEffectGeneratorsList = node_data[10],
					PatchesList = node_data[11],
					StartResearchTime = node_data[12],
					TotalResearchTime = node_data[13],
					SuiteTexture = node_data[14],
					SuiteName = node_data[15],
					TacticalCost = node_data[16]
				}		
		
		if not node_info.Enabled then
			--points_data[0] = active_and_completed_research_count
			--points_data[1] = research_points
			--points_data[2] = MAX_RESEARCH_POINTS	
			if points_data[0] == points_data[2] then
				node_info.RequiredActionText = "TEXT_RESEARCH_CAPACITY_REACHED"
			elseif is_campaign and points_data[0] == points_data[1] then
				node_info.RequiredActionText = Player_Script.Get_Async_Data("AdditionalFacilityRequiredText")
			else
				if node_data[2] ~= 1 then
					node_info.RequiredActionText = "TEXT_RESEARCH_PREREQUISITE_RESEARCH_NEEDED"
				else
					-- Make it an empty string otherwise it will display the progress text.
					node_info.RequiredActionText = ""
				end
			end
		end
		
		local suite_button_name = "Button"..node_info.NodePath..node_info.NodeIndex
		local UI_button = Scene[suite_button_name]
		
		if ActiveSuiteDisplay ~= nil and ActiveSuiteDisplay.NodePath == node_info.NodePath and ActiveSuiteDisplay.NodeIndex == node_info.NodeIndex then
			Scene.SuiteContentsScene.Update_Display(node_info)
		end
		
		UI_button.Set_User_Data(node_info)		
		UI_button.Set_Button_Enabled(node_info.Enabled)
		UI_button.Set_Texture(node_info.SuiteTexture)
		
		-- Maria 02.05.2008
		-- If the suite has been completed research or research is under way, we expose the X overlay for the button.
		-- Otherwise, we use the A overlay
		if Is_Gamepad_Active() and not IsDEFCONMode and node_info.Enabled then
			-- node_data[17] = gamepad_display_x_overlay
			-- node_data[18] = gamepad_display_a_overlay	
			if not node_data[18] and not node_data[17] then
				UI_button.Hide_A_Button_Overlay(true)
			else
				-- Make sure the overlay is not hidden.
				UI_button.Hide_A_Button_Overlay(false)
				
				-- Now display the proper button graphics.
				if node_data[17] then
					-- display the X button overlay.
					UI_button.Use_X_Overlay(true)
				else
					-- display the A button overlay.
					UI_button.Use_X_Overlay(false)
				end
			end			
		end

		local progress = 0.0
		if node_info.StartResearchTime ~= -1 then
			progress = GetCurrentTime.Frame() - node_info.StartResearchTime
			progress = progress/node_info.TotalResearchTime
			progress = 1.0 - progress
		end
		
		if progress < 0.0 then progress = 0.0
		elseif progress > 1.0 then progress = 1.0
		end

--		EMP 7/24/07
--		Removed, not needed for main research button calcs		
--		CurrentResearchProgress = progress
		
		UI_button.Set_Clock_Filled(progress)
		
		if node_info.Completed then
			local max_index = max_completed_index[node_info.NodePath]
			if not max_index or node_info.NodeIndex > max_index then
				Update_Back_Bar(node_info.NodePath, node_info.NodeIndex, 1.0)
				max_completed_index[node_info.NodePath] = node_info.NodeIndex
			end
		end
	end
	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update(event, source)

	local cur_time = GetCurrentTime()
	local nice_service_time = false
	if last_time == nil then 
		last_time = cur_time - 1
	end

	if cur_time - last_time > 1 then
		last_time = cur_time
		nice_service_time = true
	end

	if nice_service_time then
		Refresh_Buttons()
	end
	
	--Make sure the tooltip-like info panel gets frequent updates while it's waiting
	--for text to be ready
	if nice_service_time or not Scene.SuiteContentsScene.Is_Scene_Ready() then
		Scene.SuiteContentsScene.Update_Scene()
	end

end


-- --------------------------------------------------------------------------
-- Refresh_Buttons
-- --------------------------------------------------------------------------
function Refresh_Buttons()
	for _, button in pairs(Buttons) do
		local node_info = button.Get_User_Data()
		
		if node_info ~= nil then 
			if node_info.Completed == false and node_info.StartResearchTime ~= -1 then
				-- There's research under way at this node so update its progress!.
				local progress = GetCurrentTime.Frame() - node_info.StartResearchTime
			
				if (IsDEFCONMode) then
					progress = progress/DEFCON_COUNTDOWN
				else
					progress = progress/node_info.TotalResearchTime
				end		
				
				--Update the back bar before we flip the progress
				Update_Back_Bar(node_info.NodePath, node_info.NodeIndex, progress)
				progress = 1.0 - progress
				
				if progress < 0.0 then progress = 0.0 
				elseif progress > 1.0 then progress = 1.0
				end
				
				--CurrentResearchProgress = progress
				
				button.Set_Clock_Filled(progress)
			end
			
			-- Finally, check to see if we have to flash this button or not.
			if FlashResearchOptions[node_info.NodePath] and FlashResearchOptions[node_info.NodePath][node_info.NodeIndex] then
				button.Start_Flash()
			else
				button.Stop_Flash()
			end
		end
	end
end


-- --------------------------------------------------------------------------
-- Update_Back_Bar
-- --------------------------------------------------------------------------
function Update_Back_Bar(suite, node_index, progress)
	local button_set = nil
	local bar = nil
	if suite == "A" then
		bar = this.BackBarA
		button_set = DirAButtons
	elseif suite == "B" then
		bar = this.BackBarB
		button_set = DirBButtons
	else
		bar = this.BackBarC
		button_set = DirCButtons
	end
				
	local bar_x, bar_y, _, bar_h = bar.Get_Bounds()
	local left = bar_x
	if node_index > 1 then
		local x, _, w, _ = button_set[node_index - 1].Get_Bounds()
		left = x + w + BackBarMargin
	end
	local x, _, w, _ = button_set[node_index].Get_Bounds()
	local right = x + w + BackBarMargin
	bar_w = left + progress * (right - left) - bar_x
	bar.Set_Bounds(bar_x, bar_y, bar_w, bar_h)
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over_Suite_Button
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 function On_Mouse_Over_Suite_Button(event, source)
	-- Display the Suite description scene.
	local node = source.Get_User_Data()
	
	-- update the active display data
	ActiveSuiteDisplay = {}
	ActiveSuiteDisplay= { NodePath = node.NodePath, NodeIndex =  node.NodeIndex }
	
	-- Maria 10.29.2007
	-- Before passing down the data to the Display scene, let's make sure the TotalResearchTime for this
	-- suite is updated properly (indeed, if we are in DEFCON mode the TRT is different from the one 
	-- specified in the suite definition).
	if (IsDEFCONMode) then
		node.TotalResearchTime = DEFCON_COUNTDOWN
	end
	
	-- display the contents
	Scene.SuiteContentsScene.Display_Scene_For_Suite(node)
	
 end
 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_Suite_Button
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 function On_Mouse_Off_Suite_Button(event, source)
	-- Hide the Suite description scene.
	local node = source.Get_User_Data()
	
	if ActiveSuiteDisplay ~= nil then
		if ActiveSuiteDisplay.NodePath == node.NodePath and ActiveSuiteDisplay.NodeIndex == node.NodeIndex then
			-- hide the scene
			Scene.SuiteContentsScene.Set_Hidden(true)
			-- stop any playing animations
			Scene.SuiteContentsScene.Stop_Animation()
			ActiveSuiteDisplay = nil
		end
	end
	
	
 end
 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Suite_Button_Clicked
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Suite_Button_Clicked(event, source)
	if not TestValid(source) then 
		return
	end
	
	if not source.Is_Button_Enabled() then
		return 
	end
		
	-- If possible, start researching this node.
	local node = source.Get_User_Data()
	Send_GUI_Network_Event("Network_Start_Research", {Find_Player("local"), node.NodePath, node.NodeIndex})

	if FlashResearchOptions[node.NodePath] and FlashResearchOptions[node.NodePath][node.NodeIndex] then	
		FlashResearchOptions[node.NodePath][node.NodeIndex] = nil
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Suite_Button_Right_Clicked
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Suite_Button_Right_Clicked(event, source)
	if not TestValid(source) then 
		return
	end
	
	if not source.Is_Button_Enabled() then
		return 
	end
	
	-- If possible, cancel completed or under going research for this node.
	local node = source.Get_User_Data()
	Send_GUI_Network_Event("Network_Cancel_Research", {Find_Player("local"), node.NodePath, node.NodeIndex})	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Reset_Buttons
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Reset_Buttons()
	Update_Back_Bar("A", 1, 0.0)
	Update_Back_Bar("B", 1, 0.0)
	Update_Back_Bar("C", 1, 0.0)	
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Close_Button_Clicked
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Close_Button_Clicked(event, source)
	this.Set_Hidden(true)
end

-- -------------------------------------------------------------------------------
-- On_Tree_Hidden
-- -------------------------------------------------------------------------------
function On_Tree_Hidden(event, source)
	ActiveSuiteDisplay = nil
	IsTreeOpen = false
end

-- -------------------------------------------------------------------------------
-- On_Tree_Displayed
-- -------------------------------------------------------------------------------
function On_Tree_Displayed(event, source)
	Play_SFX_Event("GUI_Generic_Open_Window")
	IsTreeOpen = true
	-- reset the focus so that the components on the newly opened scene gain focus!
	this.Enable(true)
	this.Focus_First()
end


-- -------------------------------------------------------------------------------
-- Is_Open
-- -------------------------------------------------------------------------------
function Is_Open()
	return IsTreeOpen
end


-- -------------------------------------------------------------------------------
-- Get_Research_Progress
-- -------------------------------------------------------------------------------
function Get_Research_Progress()
	local start_time = Player_Script.Get_Async_Data("ResearchStartTime")
	local total_time = Player_Script.Get_Async_Data("ResearchTotalTime")	
	if not start_time or not total_time then
		return 0.0
	end
	CurrentResearchProgress = GetCurrentTime.Frame() - start_time

	CurrentResearchProgress = CurrentResearchProgress / total_time
	CurrentResearchProgress = 1.0 - CurrentResearchProgress			
		
	if CurrentResearchProgress < 0.0 then CurrentResearchProgress = 0.0
	elseif CurrentResearchProgress > 1.0 then CurrentResearchProgress = 1.0
	end

	return CurrentResearchProgress
end

-- -------------------------------------------------------------------------------
-- Set_Flash_Research_Option
-- -------------------------------------------------------------------------------
function Set_Flash_Research_Option(branch, suite)
	
	if not FlashResearchOptions[branch] then
		FlashResearchOptions[branch] = {}
	end
	
	FlashResearchOptions[branch][suite] = true
	
	Refresh_Buttons()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Is_Open = Is_Open
Interface.Close = Close
Interface.Get_Research_Progress = Get_Research_Progress
Interface.Set_Flash_Research_Option = Set_Flash_Research_Option
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
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
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	Raise_Event_All_Parents = nil
	Raise_Event_Immediate_All_Parents = nil
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
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
