-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Gui/HeroIcons.lua#66 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/HeroIcons.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 81475 $
--
--          $DateTime: 2007/08/23 11:26:24 $
--
--          $Revision: #66 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGCommands")
require("PGUICommands")


-- -----------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------
function Hero_Icons_Init(scene_object)

	SceneObject = scene_object

	-- Register to hear when Hero Icons should be created and deleted.
	SceneObject.Register_Event_Handler("Hero_Icon_Create", nil, Hero_Icon_Create)
	SceneObject.Register_Event_Handler("Hero_Icon_Delete", nil, Hero_Icon_Delete)
		
	-- Start flashing a hero icon.
	SceneObject.Register_Event_Handler("UI_Start_Flash_Hero", nil, UI_Start_Flash_Hero)

	-- Stop flashing a hero icon.
	SceneObject.Register_Event_Handler("UI_Stop_Flash_Hero", nil, UI_Stop_Flash_Hero)
	
	HeroIconTable = Find_GUI_Components(SceneObject, "HeroIcon")
	HeroObjectToIconMap = {}
	HeroTable = {}

	for index, icon in pairs(HeroIconTable) do
		SceneObject.Register_Event_Handler("Selectable_Icon_Clicked", icon, On_Hero_Button_Clicked)
		SceneObject.Register_Event_Handler("Selectable_Icon_Double_Clicked", icon, On_Hero_Button_Double_Clicked)
		
		icon.Set_Tab_Order(index + TAB_ORDER_HERO_BUTTONS)
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
	
	QueuedTalkingHeads = {}
	PIPWindows = {}
	PIPWindowBackdrops = {}
	if Get_Game_Mode() == "Strategic" then
		PIPWindows = Find_GUI_Components(SceneObject, "PIPWindow")
		PIPWindowBackdrops = Find_GUI_Components(SceneObject, "PIPWindowBackdrop")
	else
		PIPWindows[1] = SceneObject.TalkingHead
		PIPWindowBackdrops[1] = SceneObject.TalkingHeadBackdrop
	end
	
	for _, pip_window in pairs(PIPWindows) do
		pip_window.Set_Hidden(true)
		pip_window.Set_Blend_Duration(2.0)
	end
	
	for _, backdrop in pairs(PIPWindowBackdrops) do
		backdrop.Set_Hidden(true)
		backdrop.Set_Tint(1.0, 1.0, 1.0, 0.5)
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
	IsResearching = false;
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Started
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Started()
	IsResearching = true
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Canceled
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Canceled()
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
	
	if object.Get_Script().Get_Async_Data("IS_SCIENTIST") then 
		HeroTable[object].TooltipData = {'ui', "TEXT_UI_RESEARCH_TREE_BUTTON"}
		HeroTable[object].IsDummy = true	
	else
		HeroTable[object].TooltipData = {'object', {object, }}
		HeroTable[object].IsDummy = object.Has_Behavior(BEHAVIOR_GHOST)
	end
	
	Update_Hero_Icons()
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

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Update_Hero_Icons
-- --------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Hero_Icons(selected_objects)

	local is_global_mode = false
	if Get_Game_Mode() == "Strategic" then
		is_global_mode = true
	end
	
	local delete_list = {}
	for hero, data in pairs(HeroTable) do
		if TestValid(hero) == false then
			table.insert(delete_list, hero)
		elseif hero.Get_Owner() ~= Find_Player("local") then 
			table.insert(delete_list, hero)
		end
	end

	for _, hero in pairs(delete_list) do
		Hero_Icon_Delete_Internal(hero)
	end

	-- EMP Removed 7/21/07
	--for _, button in pairs(HeroIconTable) do
	--	button.Set_Hidden(true)
	--end

	local old_hero_button_map = HeroObjectToButtonMap
	HeroObjectToButtonMap = {}
	local local_player = Find_Player("local")
	for hero, data in pairs(HeroTable) do
		if hero.Get_Owner() == local_player and hero.Is_In_Active_Context() then
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
					else
						button.Set_Clock_Filled(0.0)
					end
				end
			else
				button = HeroIconTable[data.Priority + 1]
			end
			
			if button.Get_Hidden() then
				if not IsLetterboxMode then
					button.Set_Hidden(false)
				end
			else
				if IsLetterboxMode then
					button.Set_Hidden(true)
				end
			end
			
			--EMP Removed 7/21/07
			--if not IsLetterboxMode then
			--	button.Set_Hidden(false)
			--else
			--button.Set_Hidden(true)
			--end
			button.Set_Hero(hero, data.Texture, data.Priority)
			
			if is_global_mode then
				button.Set_Dummy(data.IsDummy)
			else
				button.Set_Health(hero.Get_Hull())
			end
			
			button.Set_Selected(Is_Hero_Selected(hero))
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
function GUI_Queue_Talking_Head(_, _, object_or_model, speech_event, pip_index, callback_script, callback_function)
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
	
	Queue_Speech_Event(speech_event)
	QueuedTalkingHeads[speech_event] = {}
	QueuedTalkingHeads[speech_event].ObjectOrModel = object_or_model	
	QueuedTalkingHeads[speech_event].HeadModel = head_model
	QueuedTalkingHeads[speech_event].PIPIndex = pip_index
	QueuedTalkingHeads[speech_event].CallbackScript = callback_script
	QueuedTalkingHeads[speech_event].CallbackFunction = callback_function
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
		end
		
		pip_window.Set_Hidden(false)
		Set_Pip_Movie_Playing(true)
		
		if PIPWindowBackdrops[talking_head_data.PIPIndex] then
			PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Hidden(false)
			PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Tint(1.0, 1.0, 1.0, 1.0)		
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
	if talking_head_data then
	
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
			Set_Pip_Movie_Playing(false)
			
			if PIPWindowBackdrops[talking_head_data.PIPIndex] then
				PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Hidden(true)
			end
		else		
			pip_window.Play_Randomized_Animation("notalk")
			
			if PIPWindowBackdrops[talking_head_data.PIPIndex] then
				PIPWindowBackdrops[talking_head_data.PIPIndex].Set_Tint(1.0, 1.0, 1.0, 0.5)					
			end			
		end
			
		--Inform the script that originally queued the talking head that it's done.
		if talking_head_data.CallbackScript and talking_head_data.CallbackFunction then
			talking_head_data.CallbackScript.Call_Function(talking_head_data.CallbackFunction, speech_event_name)
		end
		
		QueuedTalkingHeads[speech_event_name] = nil
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
	for event_name, _ in pairs(QueuedTalkingHeads) do
		Cancel_Queued_Speech_Events(event_name)
	end
	QueuedTalkingHeads = {}
	for i, window in pairs(PIPWindows) do
		if not PIPManuallyOpened[i] then
			window.Set_Hidden(true)
			PIPWindowBackdrops[i].Set_Hidden(true)
		end
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