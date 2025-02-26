if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[98] = true
LuaGlobalCommandLinks[124] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[22] = true
LuaGlobalCommandLinks[52] = true
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_HeroIcons.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 94671 $
--
--          $DateTime: 2008/03/05 17:07:40 $
--
--          $Revision: #32 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGUICommands")


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Hero_Icons_Init()

	SceneObject = this
	
	-- find out what game mode we are in
	IsGlobalMode = false
	if Get_Game_Mode() == "Strategic" then
		IsGlobalMode = true
	end

	-- Register to hear when Hero Icons should be created and deleted.
	SceneObject.Register_Event_Handler("Hero_Icon_Create", nil, Hero_Icon_Create)
	SceneObject.Register_Event_Handler("Hero_Icon_Delete", nil, Hero_Icon_Delete)
		
	-- Start flashing a hero icon.
	SceneObject.Register_Event_Handler("UI_Start_Flash_Hero", nil, UI_Start_Flash_Hero)

	-- Stop flashing a hero icon.
	SceneObject.Register_Event_Handler("UI_Stop_Flash_Hero", nil, UI_Stop_Flash_Hero)
	
	if TestValid(SceneObject.HeroButtons) then
 		HeroIconTable = Find_GUI_Components(SceneObject.HeroButtons, "HeroIcon")
 	else
 		HeroIconTable = Find_GUI_Components(SceneObject, "HeroIcon")
 	end

	-- If we have the carousel, the science button is there, so fetch it and add it to the front of the list for it should always
	-- be the first button.
	if TestValid(this.FactionButtons) then
		if TestValid(this.FactionButtons.Carousel) then
			if TestValid(this.FactionButtons.Carousel.ResearchButton) then
				table.insert(HeroIconTable, 1, this.FactionButtons.Carousel.ResearchButton)
			end	
		end	
	end
	
	HeroObjectToIconMap = {}
	HeroTable = {}
	IndexedHeroTable = {}

	for index, icon in pairs(HeroIconTable) do
		SceneObject.Register_Event_Handler("Selectable_Icon_Clicked", icon, On_Hero_Button_Clicked)
		SceneObject.Register_Event_Handler("Selectable_Icon_Double_Clicked", icon, On_Hero_Button_Double_Clicked)
		--Hide icon
		icon.Set_Hidden(true)
	end
	
	Update_Hero_Icons( {} )
	
	--PIP stuff
	SceneObject.Register_Event_Handler("Queue_Talking_Head", nil, GUI_Queue_Talking_Head)
	SceneObject.Register_Event_Handler("Speech_Event_Begin", nil, PIP_On_Speech_Event_Begin)
	SceneObject.Register_Event_Handler("Speech_Event_Done", nil, PIP_On_Speech_Event_Done)
	SceneObject.Register_Event_Handler("Set_PIP_Model", nil, GUI_Set_PIP_Model)
	SceneObject.Register_Event_Handler("Flush_PIP_Queue", nil, GUI_Flush_PIP_Queue)
	SceneObject.Register_Event_Handler("Finalize_PIP_Display", nil, Finalize_PIP_Display)
	
	QueuedTalkingHeads = {}
	PIPWindows = {}
	PIPWindowBackdrops = {}
	if Get_Game_Mode() == "Strategic" then
		table.insert(PIPWindows, SceneObject.AALogic_PIPWindow1.PIPWindow1)
		table.insert(PIPWindows, SceneObject.AALogic_PIPWindow2.PIPWindow2)
		table.insert(PIPWindows, SceneObject.AALogic_PIPWindow3.PIPWindow3)
		PIPWindowBackdrops = Find_GUI_Components(SceneObject, "PIPWindowBackdrop")
	else
		PIPWindows[1] = SceneObject.AALogic_TalkingHead.TalkingHead
		PIPWindowBackdrops[1] = SceneObject.TalkingHeadBackdrop
	end
	
	for _, pip_window in pairs(PIPWindows) do
		pip_window.Set_Hidden(true)
		pip_window.Set_Blend_Duration(2.0)
	end
	
	for _, backdrop in pairs(PIPWindowBackdrops) do
		backdrop.Set_Hidden(true)
		backdrop.Set_Tint(1.0, 1.0, 1.0, 0.5)
		SceneObject.Register_Event_Handler("Animation_Finished", backdrop, On_PIP_Backdrop_Anim_Finished)
	end
	
	PIPManuallyOpened = {}

	-- Prevent updating the research button progress when there is no research
	IsResearching = false
	SceneObject.Register_Event_Handler("Research_Started", nil, On_Research_Started)
	SceneObject.Register_Event_Handler("Research_Canceled", nil, On_Research_Canceled)
		
	-- Maria 05.29.2007 	- Whenever research is completed we flash the research button for a pre-determined amount of time.
	SceneObject.Register_Event_Handler("Research_Complete", nil, On_Research_Complete)
	RESEARCH_BUTTON_FLASH_DURATION = 10.0
	ResearchButtonFlashStartTime = -1.0	
	
	Init_Research_Progress_Display()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Init_Research_Progress_Display
-- ------------------------------------------------------------------------------------------------------------------
function Init_Research_Progress_Display()
	if not TestValid(this.ResearchProgressDisplay) then 
		return
	end
	
	RPDisplay = this.ResearchProgressDisplay
	-- make the clock green
	RPDisplay.Clock.Set_Tint(0.0, 1.0, 0.0, 150.0/255.0)
	-- NOTE the texture is already set from the editor.
	RPDisplay.Set_Hidden(true)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Complete
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Complete(event, source, player)
	if player ~= Find_Player("local") then 
		return
	end
	
	-- Get the button (just make sure we have a science guy!)
	local button = HeroIconTable[1]
	if not button.Get_Hero then
		return false	
	end
	local hero = button.Get_Hero()
	if not TestValid(hero) or hero.Get_Script().Get_Async_Data("IS_SCIENTIST") ~= true then
		return
	end
	
	-- if the research tree is open, don't do anything!.
	if TestValid(this.Research_Tree) and this.Research_Tree.Is_Open() == false then 
		ResearchButtonFlashStartTime = GetCurrentTime()
		-- Start flashing the button!.
		button.Start_Flash()
	end
	IsResearching = false
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Started
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Started(_, _, player, icon)
	if player ~= Find_Player("local") then 
		return
	end
	
	IsResearching = true
	
	-- Update the Research display icon with the new icon.
	if TestValid(RPDisplay) and icon then 
		RPDisplay.ResearchQuad.Set_Texture(icon)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Canceled
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Canceled(_, _, player)
	if player ~= Find_Player("local") then 
		return
	end
	
	IsResearching = false
	HeroIconTable[1].Set_Clock_Filled(0.0)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Over_Hero_Button
-- ------------------------------------------------------------------------------------------------------------------
function On_Mouse_Over_Hero_Button(event, source)
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_Hero_Button
-- ------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off_Hero_Button(event, source)
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Start_Flash_Hero
-- ------------------------------------------------------------------------------------------------------------------
function UI_Start_Flash_Hero(event, source, hero_name, duration)
	local icon = Hero_Icon_Find_By_Name(hero_name)
	if icon then
		icon.Start_Flash(duration)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- UI_Stop_Flash_Hero
-- ------------------------------------------------------------------------------------------------------------------
function UI_Stop_Flash_Hero(event, source, hero_name)
	local icon = Hero_Icon_Find_By_Name(hero_name)
	if icon then
		icon.Stop_Flash()
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Hero_Button_Clicked
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Clicked(event, button)

	local hero = button.Get_Hero()
	if not TestValid(hero) then
		return
	end
		
	if hero.Get_Script().Get_Async_Data("IS_SCIENTIST") then 
		-- the button may be flashing, if so, make it stop.
		if ResearchButtonFlashStartTime and ResearchButtonFlashStartTime ~= -1.0 then 
			button.Stop_Flash()
			ResearchButtonFlashStartTime = -1.0
		elseif FlashResearchButton then
			button.Stop_Flash()
			FlashResearchButton = false
		end		
		On_Scientist_Button_Clicked()
		
	elseif hero.Get_Script().Get_Async_Data("IS_COMM_OFFICER") then 
	
		On_Comm_Officer_Clicked(hero)
		
	elseif not HeroTable[hero].IsDummy then	
		--In strategic we don't allow selection of heroes in transit.
		if Get_Game_Mode() == "Strategic" and not TestValid(hero.Get_Region_In()) then
			return
		end
	
		local garrison = hero.Get_Garrison()
		if TestValid(garrison) and garrison.Get_Type().Get_Type_Value("Should_Hide_Garrisoned_Objects") then
			Set_Selected_Objects({garrison})
		else
			-- clicking on the hero button selects the hero
			Set_Selected_Objects({hero})
		end
	else
		Set_Selected_Objects({})
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- On_Hero_Button_Double_Clicked
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function On_Hero_Button_Double_Clicked(event, button)
	local hero = button.Get_Hero()
	if not TestValid(hero) then
		return
	end
			
	if hero.Get_Script().Get_Async_Data("IS_SCIENTIST") then 
		if On_Scientist_Button_Double_Clicked then
			On_Scientist_Button_Double_Clicked()
		end
	elseif hero.Get_Script().Get_Async_Data("IS_COMM_OFFICER") then 
		if On_Comm_Officer_Double_Clicked then
			On_Comm_Officer_Double_Clicked(hero)
		end
	else
	if Get_Game_Mode() == "Strategic" then
		local icon = hero.Get_Global_Icon()
		if TestValid(region) then
			Point_Camera_At(icon)
		else
			--Point at the fleet position when in transit
			Point_Camera_At(hero.Get_Parent_Object())
		end
	else
		Point_Camera_At(hero)
	end
	end
end



-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Hero_Object
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Hero_Object(object)
	return GUI_Does_Object_Have_Lua_Behavior(object, "HeroIcon")
end



-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Hero_Icon_Find_By_Name - Find a hero icon button by the name of the hero.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Hero_Icon_Find_By_Name(hero_name)
	hero_name = string.upper(hero_name)
	for hero, button in pairs(HeroObjectToButtonMap) do
		if TestValid(hero) and hero.Get_Type().Get_Name() == hero_name then
			return button
		end
	end
	return nil
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Hero_Icon_Create
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Hero_Icon_Create(event, source, object, priority, texture, head_model)

	-- Only care about the hero icons on the local player.
	if object.Get_Owner() ~= Find_Player("local") then return end

	if not object.Is_In_Active_Mode() then
		return
	end

	if HeroTable[object] ~= nil then
		--MessageBox("The HERO ICON already exists!!! Aborting command.")
		return
	end
	
	HeroTable[object] = {}
	HeroTable[object].Texture = texture
	HeroTable[object].Priority = priority
	HeroTable[object].HeadModel = head_model
	
	local is_science_guy = object.Get_Script().Get_Async_Data("IS_SCIENTIST")
	if is_science_guy then 
		HeroTable[object].TooltipData = {'ui', "TEXT_UI_RESEARCH_TREE_BUTTON"}
		HeroTable[object].IsDummy = true	
	else
		HeroTable[object].TooltipData = {'object', {object, }}
		HeroTable[object].IsDummy = object.Has_Behavior(160)
		
		if not object.Get_Script().Get_Async_Data("IS_COMM_OFFICER") then
			-- Needed for easy access for control group functionality.
			IndexedHeroTable[priority] = {}
			IndexedHeroTable[priority][1] = object
			IndexedHeroTable[priority][2] = texture	
		end
	end
	
	Update_Hero_Icons()
	
	if is_science_guy then 
		Controller_Update_Context()
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Hero_Icon_Delete
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Hero_Icon_Delete(event, source, object)
	Hero_Icon_Delete_Internal(object)
	Update_Hero_Icons()
end

function Hero_Icon_Delete_Internal(hero)
	local button = HeroObjectToButtonMap[hero]
	if button then
		IndexedHeroTable[HeroTable[hero].Priority] = nil
		HeroTable[hero] = nil
		HeroObjectToButtonMap[hero] = nil
		button.Set_Hidden(true)
	end	
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Is_Hero_Selected
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Is_Hero_Selected(object)
	return SelectedHeroes[object] == true
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Hero_Icons_Tooltip_Data
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Hero_Icons_Tooltip_Data()
	for _, button in pairs(HeroIconTable) do 
		local hero = button.Get_Hero()
		if TestValid(hero) then
			local data = HeroTable[hero]
			if data then 
				button.Update_Tooltip_Data(data.Priority)
			end
		end
	end		
end

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- Can_Be_Selected
-- ------------------------------------------------------------------------------------------------------------------------------------------
function Can_Be_Selected(hero)
	-- Maria 01.23.2008
	-- Since this function is only called from Update_Hero_Selection_State which in turn is only called from 
	-- the Update_Hero_Icons call, we don't need to check again for the Scientist flag, or the object being owned by the 
	-- local player or being in the active context.  In fact, all those checks are done before calling this function 
	-- from Update_Hero_Icons.  Should we need to call this function from somewhere else in the code, we wil have to 
	-- add those checks to it!!!!!.
	if hero.Get_Script().Get_Async_Data("IS_COMM_OFFICER") then
		return false
	end
	
	-- If it is respawning, we cannot select him but we can interact with this butto
	if hero.Get_Respawn_Percent() < 1 then 
		return true
	end
	
	--In strategic we don't allow selection of heroes in transit.
	if Get_Game_Mode() == "Strategic" and not TestValid(hero.Get_Region_In()) then
		return false
	end
	
	return true
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Indexed_Hero_Table
-- --------------------------------------------------------------------------------------------------------------------------------------------------
--function Update_Indexed_Hero_Table()
function Update_Hero_Selection_State(hero, data)
	if Can_Be_Selected(hero) then
		if not IndexedHeroTable[data.Priority] then
			-- Put it back in the list!.
			IndexedHeroTable[data.Priority] = {}
			IndexedHeroTable[data.Priority][1] = hero
			IndexedHeroTable[data.Priority][2] = data.Texture
			-- this hero can be selected
			IndexedHeroTable[data.Priority][3] = true
			
		elseif not IndexedHeroTable[data.Priority][3] then
			IndexedHeroTable[data.Priority][3] = true
		end
		
		-- Is this hero selected?
		IndexedHeroTable[data.Priority][4] = Is_Hero_Selected(hero)				
	elseif IndexedHeroTable[data.Priority] and IndexedHeroTable[data.Priority][3] then
		-- this hero cannot be selected
		IndexedHeroTable[data.Priority][3] = false		
		IndexedHeroTable[data.Priority][4] = false
	end		
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Hero_Icons
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Hero_Icons(selected_objects)
	
	local delete_list = {}
	for hero, data in pairs(HeroTable) do
		if TestValid(hero) == false then
			table.insert(delete_list, hero)
		elseif hero.Get_Owner() ~= LocalPlayer then 
			table.insert(delete_list, hero)
		end
	end

	for _, hero in pairs(delete_list) do
		Hero_Icon_Delete_Internal(hero)
	end
	
	local old_hero_button_map = HeroObjectToButtonMap
	HeroObjectToButtonMap = {}
	
	local update_rp_display = false
	if TestValid(RPDisplay) then -- RPDisplay = Research Progress Display
		update_rp_display = true
	end
	
	for hero, data in pairs(HeroTable) do
		if hero.Get_Owner() == LocalPlayer and hero.Is_In_Active_Context() then
			local button
			local is_scientist = hero.Get_Script().Get_Async_Data("IS_SCIENTIST")
			
			-- we want the science officer to always show up in the first slot.
			if is_scientist then 
				button = HeroIconTable[1]
				
				-- Update research progress if applicable.
				if IsResearching then
					local progress = this.Research_Tree.Get_Research_Progress()
					if progress > 0.0 then 
						button.Set_Clock_Filled(progress)
						if update_rp_display then 
							RPDisplay.Clock.Set_Filled(progress)
						end
					else
						button.Set_Clock_Filled(0.0)
						if update_rp_display then 
							RPDisplay.Clock.Set_Filled(0.0)
						end
					end
				end
				
				-- Designers may want to flash the research panel button on demand.
				if ControllerDisplayingResearchAndFactionUI and FlashResearchButton then
					button.Start_Flash()
				else
					button.Stop_Flash()
				end				
			else
				button = HeroIconTable[data.Priority + 1]
				if IsGlobalMode then
					Update_Hero_Selection_State(hero, data)
				end
			end
			
			local is_button_hidden = false
			if not IsLetterboxMode then
				if not is_scientist then
					button.Set_Hidden(false)
				end
			else
				button.Set_Hidden(true)
				is_button_hidden = true
			end
			
			-- Maria 12.03.2007
			-- If the hero is respawning, we don't want to display its health!.
			local display_health = button.Set_Hero(hero, data.Texture, data.Priority)
			if not IsGlobalMode then
				-- In tactical we display the health of all of them but not the scientist.
				display_health = not is_scientist
			end
			
			if not is_button_hidden then 
				local health = 0.0
				if display_health then 
					health = hero.Get_Hull()
				end
				
				button.Set_Health(health)
				button.Set_Selected(Is_Hero_Selected(hero))
			end
			HeroObjectToButtonMap[hero] = button
		elseif old_hero_button_map then
			--Now that we don't hide all buttons every update we need this block
			--to get rid of buttons for heroes in inactive contexts
			local button = old_hero_button_map[hero]
			if TestValid(button) then
				button.Set_Hidden(true)
			end
		end
	end
	
	-- the indexed table has been updated, so let's refresh the display (if applicable)
	if IsGlobalMode and IndexedHeroTable then
		this.HeroMenu.Refresh_Display(IndexedHeroTable)
	end
	
	-- Maria 12.03.2007
	-- If there are no heroes at all, the for loop below won't get processed and the state of the RDisplay component
	-- won't be updated!.  So, determine whether we have to hide/unhide the component here.
	if update_rp_display then 
		-- Maria 02.07.2008
		-- Per task request: Expanding the radar map should only hide the button callouts not the current patches/research and enemy superweapon timers
		-- if IsResearching and not IsRadarOpen then 
		if IsResearching then 
			RPDisplay.Set_Hidden(false)
		else
			RPDisplay.Set_Hidden(true)
		end
	end
	
	if selected_objects then
		SelectedHeroes = {}
		for _, object in pairs(selected_objects) do
			if Is_Hero_Object(object) then
				SelectedHeroes[object] = true
				local hero_icon = HeroObjectToButtonMap[object]
				if hero_icon then
					hero_icon.Stop_Flash()
				end
			end
		end
	end	
	
	-- keep track of the flashing of the research button (if any)
	if ResearchButtonFlashStartTime and ResearchButtonFlashStartTime ~= -1.0 then
		if ResearchButtonFlashStartTime + RESEARCH_BUTTON_FLASH_DURATION <= GetCurrentTime() then 
			-- Get the button (just make sure we have a science guy!)
			local button = HeroIconTable[1]
			local hero = button.Get_Hero()
			if not TestValid(hero) or hero.Get_Script().Get_Async_Data("IS_SCIENTIST") ~= true then
				return
			end
			
			-- Stop the flashing.
			button.Stop_Flash()
			
			-- Research the start time!.
			ResearchButtonFlashStartTime = -1.0
		end
	end		
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Find_Hero_Button(hero_object)
	local icon = HeroObjectToIconMap[hero_object]
	if icon then
		return icon
	else
		return nil
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- PIP handling stuff below
-- --------------------------------------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI_Queue_Talking_Head
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function GUI_Queue_Talking_Head(_, _, object_or_model, speech_event, pip_index)
	if QueuedTalkingHeads[speech_event] then
		return
	end
	
	local hero_data = HeroTable[object_or_model]
	local head_model = object_or_model
	if hero_data then
		head_model = hero_data.HeadModel
	end
	
	local pip_window = PIPWindows[pip_index]
	if not pip_window then
		ScriptError("No PIP at index %d.", pip_index)
		return
	end

	--The calling script now queues the speech event for thread safety
	QueuedTalkingHeads[speech_event] = {}
	QueuedTalkingHeads[speech_event].ObjectOrModel = object_or_model	
	QueuedTalkingHeads[speech_event].HeadModel = head_model
	QueuedTalkingHeads[speech_event].PIPIndex = pip_index
end


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function GUI_Cancel_Talking_Head(_, _, event_or_object_or_model)

	--Doesn't work yet
		
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- PIP_On_Speech_Event_Begin
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function PIP_On_Speech_Event_Begin(_, _, speech_event_name, sample_name)
	local talking_head_data = QueuedTalkingHeads[speech_event_name]
	if not IsLetterboxMode and talking_head_data then
	
		--Flash any associated hero button
		local hero_button = HeroObjectToButtonMap[talking_head_data.ObjectOrModel]
		if hero_button then
			hero_button.Start_Flash()
		end
		
		--Set the model if one was provided.  It's legal not to since it's possible
		--that the model was explicitly set in advance.
		local pip_window = PIPWindows[talking_head_data.PIPIndex]
		if not PIPManuallyOpened[talking_head_data.PIPIndex] and talking_head_data.HeadModel ~= "" then
			pip_window.Set_Model(talking_head_data.HeadModel)
			this.Raise_Event("Finalize_PIP_Display", nil, {talking_head_data.PIPIndex})
		else
			pip_window.Set_Hidden(false)
			Set_Pip_Movie_Playing(true)
			
			if PIPWindowBackdrops[talking_head_data.PIPIndex] then
				PIPWindowBackdrops[talking_head_data.PIPIndex].Stop_Animation()
				PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Hidden(false)
				PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Tint(1.0, 1.0, 1.0, 1.0)		
			end		
		end
		
		pip_window.Play_Facial_Animation(sample_name)
		pip_window.Play_Randomized_Animation("idle")
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- PIP_On_Speech_Event_Done
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function PIP_On_Speech_Event_Done(_, _, speech_event_name)
	local talking_head_data = QueuedTalkingHeads[speech_event_name]
	if talking_head_data and PipMoviePlaying then
	
		--Stop flashing any associated hero button
		local hero_button = HeroObjectToButtonMap[talking_head_data.ObjectOrModel]
		if hero_button then
			hero_button.Stop_Flash()
		end	
		
		--Stop the facial anim and close out the PIP window unless it was manually opened
		local pip_window = PIPWindows[talking_head_data.PIPIndex]
		pip_window.Stop_Facial_Animation()	
		if not PIPManuallyOpened[talking_head_data.PIPIndex] then
			pip_window.Set_Hidden(true)
			
			if IsLetterboxMode then
				--If we're letterboxed then cancel the PIP instantly rather
				--than running the animation
				Set_Pip_Movie_Playing(false)
				if PIPWindowBackdrops[talking_head_data.PIPIndex] then
					PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Hidden(true)
				end	
			else		
				if PIPWindowBackdrops[talking_head_data.PIPIndex] then
					local played = PIPWindowBackdrops[talking_head_data.PIPIndex].Play_Animation("Fade_Out", false)
					if not played then
						Set_Pip_Movie_Playing(false)
						PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Hidden(true)
					end
				end
			end
		else		
			pip_window.Play_Randomized_Animation("notalk")
			
			if PIPWindowBackdrops[talking_head_data.PIPIndex] then
				PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Tint(1.0, 1.0, 1.0, 0.5)					
			end			
		end		
	end
	
	QueuedTalkingHeads[speech_event_name] = nil
end

function On_PIP_Backdrop_Anim_Finished(_, source)
	Set_Pip_Movie_Playing(false)
	source.Set_Hidden(true)
	if TestValid(source.NoiseMovie) then
		source.NoiseMovie.Stop()
	end
end

function Finalize_PIP_Display(_, _, pip_index)
	if not IsLetterboxMode then
		local pip_window = PIPWindows[pip_index]
		if not pip_window.Is_Model_Ready() then
			SceneObject.Raise_Event("Finalize_PIP_Display", nil, {pip_index})
			return
		end
		
		pip_window.Set_Hidden(false)
		Set_Pip_Movie_Playing(true)
		
		if PIPWindowBackdrops[pip_index] then
			PIPWindowBackdrops[pip_index].Stop_Animation()
			PIPWindowBackdrops[pip_index].Set_Hidden(false)
			PIPWindowBackdrops[pip_index].Set_Tint(1.0, 1.0, 1.0, 1.0)		
			
			--Start playing the noise movie now, otherwise it may not have time to load and finalize
			--before it needs to be displayed on PIP end
			if TestValid(PIPWindowBackdrops[pip_index].NoiseMovie) then
				PIPWindowBackdrops[pip_index].NoiseMovie.Play()				
			end
		end	
	end	
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI_Set_PIP_Model
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function GUI_Set_PIP_Model(_, _, pip_index, model_name)
	local pip_window = PIPWindows[pip_index]
	local backdrop = PIPWindowBackdrops[pip_index]
	if not pip_window then
		ScriptError("No PIP at index %d.", pip_index)
		return
	end
	
	if model_name then
		PIPManuallyOpened[pip_index] = true
		pip_window.Set_Model(model_name)
		pip_window.Set_Hidden(false)
		Set_Pip_Movie_Playing(true)
		pip_window.Play_Randomized_Animation("notalk")
		
		if backdrop then
			backdrop.Set_Hidden(false)
		end
	else
		PIPManuallyOpened[pip_index] = false
		pip_window.Set_Hidden(true)
		Set_Pip_Movie_Playing(false)
		
		if backdrop then
			backdrop.Set_Hidden(true)
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI_Flush_PIP_Queue
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function GUI_Flush_PIP_Queue()
	QueuedTalkingHeads = {}
	for i, window in pairs(PIPWindows) do
		if not PIPManuallyOpened[i] then
			window.Set_Hidden(true)
			PIPWindowBackdrops[i].Set_Hidden(true)
		end
	end
	
	-- Also suspend the subtitles.
	local subtitle_object = nil
	if IsLetterboxMode or 
		(TestValid(this.FadeQuad) and not this.FadeQuad.Get_Hidden()) or
		(TestValid(this.BlankScreen) and not this.BlankScreen.Get_Hidden()) then
		subtitle_object = this.CinematicSubtitle
	else
		subtitle_object = this.Subtitle	
	end
	
	if TestValid(subtitle_object) then
		subtitle_object.Set_Text("")
		subtitle_object.Set_Hidden(true)
	end
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Post_Load_Game
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- EMP 7/24/07
-- Added to make sure that the research button would continue to update if the game was saved mid-research
function Post_Load_Game()
	if this.Research_Tree.Get_Research_Progress() > 0.0 then
		IsResearching = true
	end
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Can_Access_Research
-- We may not always have access to the research tree.
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Can_Access_Research()
	if ForceHideResearchButton then
		return false
	end
	
	local button = HeroIconTable[1]
	if TestValid(button) then 
		if button.Get_Hero == nil then
			return false	
		end	
		local hero = button.Get_Hero()
		if not TestValid(hero) or hero.Get_Script().Get_Async_Data("IS_SCIENTIST") ~= true then
			return false
		end
		
		if TestValid(this.Research_Tree) then
			return true
		end
		
		return false
	end
	return false
end


function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Can_Access_Research = nil
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
	Find_Hero_Button = nil
	GUI_Cancel_Talking_Head = nil
	GUI_Dialog_Raise_Parent = nil
	GUI_Pool_Free = nil
	Get_GUI_Variable = nil
	Get_Last_Tactical_Parent = nil
	Hero_Icons_Init = nil
	Max = nil
	Min = nil
	On_Mouse_Off_Hero_Button = nil
	On_Mouse_Over_Hero_Button = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Post_Load_Game = nil
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
	Update_Hero_Icons_Tooltip_Data = nil
	Update_SA_Button_Text_Button = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

