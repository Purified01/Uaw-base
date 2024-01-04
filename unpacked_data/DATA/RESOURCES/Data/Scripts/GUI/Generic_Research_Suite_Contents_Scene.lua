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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/Generic_Research_Suite_Contents_Scene.lua
--
--            Author: Maria_Teruel
--
--          DateTime: 2007/03/22 
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init_Scene
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Scene()
	
	if Scene == nil then return end
	
	-- NOTE: we don't hide ourselves, we let our parent scene take care of our hidden state 
	-- otherwise we may mess up any animation on us placed from the parent scene.
	Scene.SuiteDesc.Set_Text("")
	Scene.SuiteDesc.Set_PreRender(true)
	
	TimeCostProgress = Scene.TimeCostProgress
	ProgressText = TimeCostProgress.ProgressText
--	ProgressText.Set_PreRender(true)
	
	TotalResearchTimeText = TimeCostProgress.TotalResearchTimeText
	TotalResearchTimeText.Set_Text("")
	TotalResearchTimeText.Set_PreRender(true)

	TacticalCostText = TimeCostProgress.TacticalCostText	
	TacticalCostText.Set_Text("")
	TacticalCostText.Set_PreRender(true)
	
	Init_Quad_Maps()
	
	Scene.Register_Event_Handler("Player_Credits_Changed", nil, On_Player_Credits_Changed)
	
	DisplayingSuite = nil -- keeps track of the suite (location = path, index) that is under display!.
	IsSceneOpen = false
	
	BoundsInitialized = false
	
	InnerMarginHeight = 2.0/768.0
	LowerMarginHeight = 8.0/768.0
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize_Bounds - DO NOT CALL THIS IN THE ON_INIT CALL SINCE THE PARENT SCENE MAY NOT BE INITIALIZED 
-- ALREADY.  THEREFORE, THE RELATIVE BOUNDS OBTAINED HERE WILL BE OFF!
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Initialize_Bounds()

	TCPOrigX, TCPOrigY, TCPOrigW, TCPOrigH = TimeCostProgress.Get_World_Bounds()
	BckOrigX, BckOrigY, BckOrigW, BckOrigH = this.Backdrop.Get_World_Bounds()
	AllOrigX, AllOrigY, AllOrigW, AllOrigH = this.Get_World_Bounds()
	
	for _, gui_element in pairs(TechDescriptions) do
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = gui_element.Get_World_Bounds()
		gui_element.Set_User_Data(bds)
	end
	
	for _, gui_element in pairs(TechQuads) do
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = gui_element.Get_World_Bounds()
		gui_element.Set_User_Data(bds)
	end
	
	for _, gui_element in pairs(TechBorders) do
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = gui_element.Get_World_Bounds()
		gui_element.Set_User_Data(bds)
	end	
	
	for _, gui_element in pairs(Titles) do
		local bds = {}
		bds.x, bds.y, bds.w, bds.h = gui_element.Get_World_Bounds()
		gui_element.Set_User_Data(bds)
	end		
	
	BoundsInitialized = true
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init_Quad_Maps
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Init_Quad_Maps()
	TechQuads = {}
	TechQuads = Find_GUI_Components(Scene, "TechQuad")
	for _, quad in pairs(TechQuads) do
		quad.Set_Hidden(true)	
	end
	
	TechBorders = {}
	TechBorders = Find_GUI_Components(Scene, "TechBorder")
	for _, brdr in pairs(TechBorders) do
		brdr.Set_Hidden(true)	
	end
	
	TechDescriptions = {}
	TechDescriptions = Find_GUI_Components(Scene, "TechDescription")
	for _, text in pairs(TechDescriptions) do
		text.Set_Hidden(true)
		text.Set_Text("")
		text.Set_PreRender(true)
	end
	
	Titles = {}
	Titles = Find_GUI_Components(Scene, "Title")
	for _, text in pairs(Titles) do
		text.Set_Hidden(true)
		text.Set_Text("")
		text.Set_PreRender(true)
	end
	
	if table.getn(TechQuads) ~= table.getn(TechDescriptions) then
		MessageBox("The number of TechQuads and TechDescriptions do not match")
		return
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Display
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Display(suite)
	if DisplayingSuite ~= nil then
		if DisplayingSuite.NodePath == suite.NodePath and DisplayingSuite.NodeIndex == suite.NodeIndex then
			DisplayingSuite = suite
			Update_Scene()
		end	
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Suite_Button_Clicked
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Display_Scene_For_Suite(suite_info)
	if suite_info == nil then 
		MessageBox("OOOPS!")
		return
	end

	DisplayingSuite = suite_info
	Set_Up_Scene()	
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Player_Credits_Changed
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Player_Credits_Changed(event, source)
	if IsSceneOpen and DisplayingSuite ~= nil then 
		if DisplayingSuite.TacticalCost > 0 then
			Set_Cost(DisplayingSuite.TacticalCost)		
		end
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set_Cost
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Cost(cost)

	local player = Find_Player("local")
	if player and player.Get_Credits() < cost then 
		TacticalCostText.Set_Tint(1.0, 0.0, 0.0, 1.0)
	else
		TacticalCostText.Set_Tint(0.0, 1.0, 0.0, 1.0)		
	end
	local wstr_res_cost = Get_Game_Text("TEXT_RESEARCH_COST")
	Replace_Token(wstr_res_cost, Get_Localized_Formatted_Number(DisplayingSuite.TacticalCost), 0)
	TacticalCostText.Set_Text(wstr_res_cost)

end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set_Up_Scene
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Set_Up_Scene()

	if DisplayingSuite == nil then return	end
	
	if not BoundsInitialized then 
		Initialize_Bounds()
	end
	
	Reset_Quads()

	local wstr_res_time = Get_Game_Text("TEXT_RESEARCH_TIME")
	Replace_Token(wstr_res_time, Get_Localized_Formatted_Number.Get_Time(DisplayingSuite.TotalResearchTime), 0)
	TotalResearchTimeText.Set_Text(wstr_res_time)
	
	Scene.SuiteDesc.Set_Hidden(false)
	Scene.SuiteDesc.Set_Text(DisplayingSuite.SuiteName)
	
	if DisplayingSuite.TacticalCost > 0 then
		Set_Cost(DisplayingSuite.TacticalCost)	
	end
	
	ProgressText.Set_Hidden(false)
	if DisplayingSuite.RequiredActionText then
		ProgressText.Set_Text(DisplayingSuite.RequiredActionText)
	else
		local progress = 0.0
		if DisplayingSuite.Completed == false then
			if DisplayingSuite.StartResearchTime ~= -1 then 
				progress = (GetCurrentTime.Frame() - DisplayingSuite.StartResearchTime)*100.0
				progress = progress/DisplayingSuite.TotalResearchTime
			end
		else
			progress = 100.0
		end
		local wstr_progress = Get_Game_Text("TEXT_PROGRESS_PERCENT")
		Replace_Token(wstr_progress, Get_Localized_Formatted_Number(Dirty_Floor(progress)), 0)
		ProgressText.Set_Text(wstr_progress)
	end
	
	Offset = 1
	Add_To_Display(DisplayingSuite.TypesList)
	Add_To_Display(DisplayingSuite.AbilitiesList)
	Add_To_Display(DisplayingSuite.SpecialAbilitiesList)
	Add_To_Display(DisplayingSuite.UnlockEffectGeneratorsList)
	Add_To_Display(DisplayingSuite.EffectsList)
	Add_To_Display(DisplayingSuite.LockEffectGeneratorsList)
	Add_To_Display(DisplayingSuite.PatchesList)
	IsSceneOpen = true
	
	Resize_Scene()
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Resize_Scene
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Resize_Scene()

	local display = Offset - 1
	if display < 0 or display > table.getn(TechDescriptions) then return end
	
	-- Given that World bounds are stored relative to the parent scene and we are modifying the
	-- bounds of the parent scene here, we must make sure that we reset those before working on 
	-- any world bound values of its components,
	this.Set_World_Bounds(AllOrigX, AllOrigY, AllOrigW, AllOrigH)
	
	-- Let's get the last displayed quad and get its world bounds so that we can recalculate the scene's
	-- height.
	local text = TechDescriptions[display]
	if not text then return end
	local t_bds = {}
	_, t_bds.y, _, t_bds.h = text.Get_World_Bounds()
	
	local quad = TechQuads[display]
	if not quad then return end
	local q_bds = {}
	_, q_bds.y, _, q_bds.h = quad.Get_World_Bounds()
	
	--  this value determines the y position at which to locate the TimeCostProgress scriptable.
	local highest_y_val = TCPOrigY

	if t_bds and q_bds then
		-- Maria 09.15.2007
		-- If the text height is smaller than the height of the tech quad, use the latter as the Y Offset!.
		-- Oterwise, the next components may end up overlapping this tech's space!.
		if t_bds.y + t_bds.h < q_bds.y + q_bds.h then
			highest_y_val = q_bds.y + q_bds.h
		else
			highest_y_val = t_bds.y + t_bds.h
		end
	end

	highest_y_val = highest_y_val + InnerMarginHeight 
	
	-- Now we need to relocate the TCP scriptable!.  Its new y will be given by the current lowest y value!.
	TimeCostProgress.Set_World_Bounds(TCPOrigX, highest_y_val, TCPOrigW, TCPOrigH)
	
	-- Now compute the bottom y coordinate of the resized contents.
	-- y1 = highest_y_val + TCP_h +Lmargin
	local y1 = highest_y_val + TCPOrigH +LowerMarginHeight
	local new_scene_h = y1 - AllOrigY
	--local new_scene_y = AllOrigY + (AllOrigH - new_scene_h)
	
	-- Resize the frame so that it fits around the new contents
	this.Backdrop.Set_World_Bounds(BckOrigX, BckOrigY, BckOrigW, new_scene_h)
	
	-- Now relocate the whole scene so that its bottom coords remain unchanged!.
	this.Set_World_Bounds(AllOrigX, AllOrigY, AllOrigW, AllOrigH)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add_To_Display - adds the data in the specified list to the current display
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Add_To_Display(new_list)
	
	if not new_list then return end
	
	local is_campaign_game = Is_Campaign_Game()
	
	for idx = 1, table.getn(new_list) do
		
		local table_param = new_list[idx]
		
		if table_param ~= nil and table_param.DescriptionTextID ~= nil and table_param.DescriptionTextID ~= "" then
		
			--Don't add the tooltip for heroes in a global context (it's only relevant in MP/Skirmish)
			if not is_campaign_game or not table_param.ObjectType or not table_param.ObjectType.Is_Hero() then
			
				if Offset > table.getn(TechQuads) then
					MessageBox("There are not enough quads to describe suite %s%s contents", DisplayingSuite.NodePath, DisplayingSuite.NodeIndex)
					break
				end
				
				local quad = TechQuads[Offset]
				local description_txt = TechDescriptions[Offset]
				local title_txt = Titles[Offset]
				local border = TechBorders[Offset]
				local original_world_bounds = nil
				
				-- update the title of the suite
				if table_param.TitleTextID ~= nil and table_param.TitleTextID ~= "" then
					title_txt.Set_Hidden(false)
					title_txt.Set_Text(table_param.TitleTextID)
					
					-- Maria 09.15.2007
					-- Resize the title text box to make sure all of it fits properly.
					local txt_height = title_txt.Get_Text_Height()
					original_world_bounds = title_txt.Get_User_Data()
					title_txt.Set_World_Bounds(original_world_bounds.x, original_world_bounds.y + YOffset, original_world_bounds.w, txt_height)
					
					-- Update the YOfsset used to relocate all remaining components.
					local extra_y_offset = txt_height - original_world_bounds.h
					if extra_y_offset > 0.0 then
						YOffset = YOffset + extra_y_offset + (5.0/768.0) -- this last fraction is a margin value so that the title doesn't overlap the quad!.
					end									
				end
				
				-- update the quad
				quad.Set_Hidden(false)
				quad.Set_Texture(table_param.IconName)
				original_world_bounds = quad.Get_User_Data()
				quad.Set_World_Bounds(original_world_bounds.x, original_world_bounds.y + YOffset, original_world_bounds.w, original_world_bounds.h)				
				
				border.Set_Hidden(false)
				original_world_bounds = border.Get_User_Data()
				border.Set_World_Bounds(original_world_bounds.x, original_world_bounds.y + YOffset, original_world_bounds.w, original_world_bounds.h)				
				
				-- update the text
				description_txt.Set_Hidden(false)
				description_txt.Set_Text(table_param.DescriptionTextID)
				local txt_height = description_txt.Get_Text_Height()
				original_world_bounds = description_txt.Get_User_Data()
				description_txt.Set_World_Bounds(original_world_bounds.x, original_world_bounds.y + YOffset, original_world_bounds.w, txt_height)
				
				local extra_y_offset = txt_height - original_world_bounds.h
				if extra_y_offset > 0.0 then
					YOffset = YOffset + extra_y_offset
				end
				
				Offset = Offset + 1			
			end
		end		
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Reset_Quads
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Reset_Quads()
	
	YOffset = 0.0
	
	for _, quad in pairs(TechQuads) do
		quad.Set_Hidden(true)
		local original_bounds = quad.Get_User_Data()
		quad.Set_World_Bounds(original_bounds.x, original_bounds.y, original_bounds.w, original_bounds.h)
	end
	
	for _, quad in pairs(TechBorders) do
		quad.Set_Hidden(true)
		local original_bounds = quad.Get_User_Data()
		quad.Set_World_Bounds(original_bounds.x, original_bounds.y, original_bounds.w, original_bounds.h)
	end
	
	for _, text in pairs(TechDescriptions) do
		text.Set_Hidden(true)
		text.Set_Text("")
		local original_bounds = text.Get_User_Data()
		text.Set_World_Bounds(original_bounds.x, original_bounds.y, original_bounds.w, original_bounds.h)
	end
	
	for _, text in pairs(Titles) do
		text.Set_Hidden(true)
		text.Set_Text("")
		local original_bounds = text.Get_User_Data()
		text.Set_World_Bounds(original_bounds.x, original_bounds.y, original_bounds.w, original_bounds.h)
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Scene
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Scene() 
	if DisplayingSuite ~= nil and not DisplayingSuite.RequiredActionText then
		local progress = 0.0
		if DisplayingSuite.Completed == false then
			if DisplayingSuite.StartResearchTime ~= -1 then 
				progress = (GetCurrentTime.Frame() - DisplayingSuite.StartResearchTime)*100.0
				progress = progress/DisplayingSuite.TotalResearchTime
			end
		else
			progress = 100.0
		end
		local wstr_progress = Get_Game_Text("TEXT_PROGRESS_PERCENT")
		Replace_Token(wstr_progress, Get_Localized_Formatted_Number(Dirty_Floor(progress)), 0)
		ProgressText.Set_Text(wstr_progress)
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Hide_Scene
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Hide_Scene()
	if IsSceneOpen== true then
		-- Reset all components
		Scene.SuiteDesc.Set_Text("")
		TotalResearchTimeText.Set_Text("" )
		TacticalCostText.Set_Text("")
		ProgressText.Set_Text("")
		Reset_Quads()

		-- Reset all variables
		DisplayingSuite = nil
		IsSceneOpen = false
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Init_Scene = Init_Scene
Interface.Display_Scene_For_Suite = Display_Scene_For_Suite
Interface.Hide_Scene = Hide_Scene
Interface.Update_Scene = Update_Scene
Interface.Update_Display = Update_Display
Interface.Is_Scene_Open = Is_Scene_Open
