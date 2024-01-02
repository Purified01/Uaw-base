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
--              File: //depot/Projects/Invasion/Run/Data/Scripts/Gui/Expanded_Tooltip_Scene.lua 
--
--            Author: Maria_Teruel
--
--          DateTime: 2007/03/07
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBase")
require("SpecialAbilities")

-- ------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------
function On_Init()
	if this == nil then return end
	
	-- VERY IMPORTANT!!! we need to initialize the list of special abilities manually!.
	Initialize_Special_Abilities(false) -- false == do not init the key mapping data for the abilities!.
	
	CurrentTooltipData = nil
	-- TOOLTIP MODES:
	-- Object: the tooltip display was originated by the mouse being over an object
	-- Type: the tooltip display was originated by the mouse being over a component that has a type assigned to it
	-- Research: the tooltip display was originated by the mouse being over a component of the research tree
	-- Upgrade: the tooltip display was originated by the mouse being over an upgrade button
	-- Ability: the tooltip display was originated by the mouse being over an ability button
	CurrentTooltipMode = nil

	-- Do not do this before the first service for the values will be wrong.  Indeed, the parent scene has not been updated yet
	-- and the world bounds are off
	--[[
	Initialize_Name_Insert()
	Initialize_Cost_Time_Pop_Insert()
	Initialize_GoodAgainst_VulnerableTo_Insert()
	Initialize_Description_Insert()
	]]--
	
	POP_CAP_CATEGORY_NONE = Declare_Enum(-1)
	POP_CAP_CATEGORY_WALKER = Declare_Enum(0)
	Init_Methods_Table()
	
	LowerMarginHeight = 4.0/768.0
	
	CurrentSceneHeight = nil
	SceneHeight = this.Get_Height()
	UpgradesHeaderStrg = Get_Game_Text("TEXT_TOOLTIP_UPGRADES")
	GoodAgainstHeaderStrg = Get_Game_Text("TEXT_TOOLTIP_GOOD_AGAINST")
	VulnerableToHeaderStrg = Get_Game_Text("TEXT_TOOLTIP_VULNERABLE_TO")
	ResearchedUpgradesHeaderStrg = Get_Game_Text("TEXT_TOOLTIP_RESEARCHED_UPGRADES")
	Initialized = false
	IsCampaignGame = Is_Campaign_Game()
	
	PATCH_STATE_ACTIVE = Declare_Enum(0)
	PATCH_STATE_INACTIVE = Declare_Enum()
	
	this.Register_Event_Handler("Animation_Finished", this, On_Animation_Finished)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Animation_Finished
-- ------------------------------------------------------------------------------------------------------------------
function On_Animation_Finished()
	Hide_Display(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Name_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Name_Insert()
	Name = this.Name
	Name.Text.Set_Word_Wrap(true)
	Name.Text.Set_PreRender(true)
	local bds = {}
	bds.x, bds.y, bds.w, bds.h = Name.Get_World_Bounds()
	bds.h = 2.0/768.0 -- min = 2 lines
	Name.Set_User_Data(bds)	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Cost_Time_Pop_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Cost_Time_Pop_Insert()
	Pop = this.CostTimePop
	local bds = {}
	bds.x, bds.y, bds.w, bds.h = Pop.Get_World_Bounds()
	Pop.Set_User_Data(bds)	
	Init_Cost_Time_Pop_Values()
	Pop.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Cost_Time_Pop
-- ------------------------------------------------------------------------------------------------------------------
function Init_Cost_Time_Pop_Values()
	Cost = Pop.CostText
	Cost.Set_Text("")
	Cost.Set_PreRender(false)
	CostQuad = Pop.CostQuad
	
	Time = Pop.TimeText
	Time.Set_Text("")
	Time.Set_PreRender(true)
	TimeQuad = Pop.TimeQuad
	
	PopTxt = Pop.PopText
	PopTxt.Set_Text("")
	PopTxt.Set_PreRender(true)
	PopQuad = Pop.PopQuad	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_GoodAgainst_VulnerableTo_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_GoodAgainst_VulnerableTo_Insert()
	GAVT = this.GAgainstVTo
	GAVT.Text.Set_Word_Wrap(true)
	GAVT.Text.Set_PreRender(true)
	local bds = {}
	--store the scene bounds so that we can resize and relocate it
	bds.x, bds.y, bds.w, bds.h = GAVT.Get_World_Bounds()
	bds.h = 2.0/768.0 -- min = 2 lines
	GAVT.Set_User_Data(bds)	
	-- compute the text margin
	GAVT.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Build_Cap_Inserts
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Build_Cap_Inserts()
	Initialize_Current_Build_Cap_Insert()
	Initialize_Lifetime_Build_Cap_Insert()	
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Current_Build_Cap_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Current_Build_Cap_Insert()
	if not TestValid(this.CurrBuildCapTxt) then 
		return 
	end
	
	CurrBuildCap = this.CurrBuildCapTxt
	CurrBuildCap.Set_Word_Wrap(true)
	CurrBuildCap.Set_PreRender(true)
	local bds = {}
	--store the scene bounds so that we can resize and relocate it
	bds.x, bds.y, bds.w, bds.h = CurrBuildCap.Get_World_Bounds()
	bds.h = 2.0/768.0 -- min = 2 lines
	CurrBuildCap.Set_User_Data(bds)	
	-- compute the text margin
	CurrBuildCap.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Lifetime_Build_Cap_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Lifetime_Build_Cap_Insert()
	if not TestValid(this.LifetimeBuildCapTxt) then 
		return 
	end
	
	LifeBuildCap = this.LifetimeBuildCapTxt
	LifeBuildCap.Set_Word_Wrap(true)
	LifeBuildCap.Set_PreRender(true)
	local bds = {}
	--store the scene bounds so that we can resize and relocate it
	bds.x, bds.y, bds.w, bds.h = LifeBuildCap.Get_World_Bounds()
	bds.h = 2.0/768.0 -- min = 2 lines
	LifeBuildCap.Set_User_Data(bds)	
	-- compute the text margin
	LifeBuildCap.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Additional_Lock_Info_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Additional_Lock_Info_Insert()
	if not TestValid(this.LockInfoText) then
		return
	end

	LockInfo = this.LockInfoText
	LockInfo.Set_Word_Wrap(true)
	LockInfo.Set_PreRender(true)
	local bds = {}
	--store the scene bounds so that we can resize and relocate it
	bds.x, bds.y, bds.w, bds.h = LifeBuildCap.Get_World_Bounds()
	bds.h = 2.0/768.0 -- min = 2 lines
	LockInfo.Set_User_Data(bds)	
	-- compute the text margin
	LockInfo.Set_Hidden(true)	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Initialize_Description_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Initialize_Description_Insert()
	Desc = this.Description
	Desc.Text.Set_Word_Wrap(true)
	Desc.Text.Set_PreRender(true)
	local bds = {}
	--store the scene bounds so that we can resize and relocate it
	bds.x, bds.y, bds.w, bds.h = Desc.Get_World_Bounds()
	
	local _, f_y, _, f_h = this.Frame.Get_World_Bounds()
	LowerMarginHeight = f_y + f_h - (bds.y + bds.h)
	bds.h = 2.0/768.0 -- min = 4 lines 
	Desc.Set_User_Data(bds)		
	Desc.Set_Hidden(true)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Init_Methods_Table
-- ------------------------------------------------------------------------------------------------------------------
function Init_Methods_Table()
	TooltipModeToDisplayFunctionMap = {}
	TooltipModeToDisplayFunctionMap['object'] = Update_Object_Tooltip 
	TooltipModeToDisplayFunctionMap['type'] = Update_Type_Tooltip
	TooltipModeToDisplayFunctionMap['ability'] = Update_Ability_Tooltip
	TooltipModeToDisplayFunctionMap['ui'] = Update_UI_Tooltip
end

-- ------------------------------------------------------------------------------------------------------------------
-- Setup_Display
-- ------------------------------------------------------------------------------------------------------------------
function Setup_Display(tooltip_info)

	if Initialized == false then 
		Initialize_Name_Insert()
		Initialize_Cost_Time_Pop_Insert()
		Initialize_Build_Cap_Inserts()
		Initialize_GoodAgainst_VulnerableTo_Insert()
		Initialize_Description_Insert()
		Initialize_Additional_Lock_Info_Insert()
		Initialized = true
	end
	
	-- NOTE: tooltip_info = {tooltip_mode, tooltip_name_text, target_type}
	CurrentTooltipMode = tooltip_info[1]
	TooltipModeToDisplayFunctionMap[CurrentTooltipMode](tooltip_info[2])
	-- Update the Name insert.
	Set_Name()
	
	-- If applicable, update the cost, build/cooldown time, pop cap insert
	Set_Cost_Time_Pop_Info()
	
	-- If applicable, update the build limit information for this object/type
	Set_Build_Cap_Text()
	
	-- If applicable, update the text that displays special case reasons why something is disabled.
	Set_Additional_Lock_Info()
	
	-- If applicable, update the Good Against-VulnerableTo insert
	Set_Good_Against_Vulnerable_To_Text()
	
	-- Update the description text for this object/type.
	Set_Description_Text()
	
	local f_x, f_y, f_w, f_h = this.Frame.Get_World_Bounds()
	this.Frame.Set_World_Bounds(f_x, f_y, f_w, CurrentSceneHeight + LowerMarginHeight)
	this.Stop_Animation()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_UI_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Update_UI_Tooltip(tooltip_data)
	if not tooltip_data then 
		return
	end
	
	-- tooltip_data[1] = name of the ui component.
	-- tooltip_data[2] = text id for the description of this component.
	CurrentTooltipData = {}
	if #tooltip_data >= 1 then
		CurrentTooltipData.Name = tooltip_data[1]
	end
	
	if #tooltip_data >= 2 then
		CurrentTooltipData.DescriptionText = Get_Game_Text(tooltip_data[2])
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Object_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Update_Object_Tooltip(tooltip_data)
	-- For objects:
	-- tooltip_data = name, type
	
	CurrentTooltipData = {}
	CurrentTooltipData.Object = tooltip_data[1]
	if not TestValid(CurrentTooltipData.Object) then
		return
	end
	
	CurrentTooltipData.Type = CurrentTooltipData.Object.Get_Type()
	if CurrentTooltipData.Type ~= nil then
		-- Get the list of build requirements if available.
		local res_upgrades = CurrentTooltipData.Type.Get_Tooltip_Researched_Upgrades_Text(CurrentTooltipData.Object)
		if res_upgrades and res_upgrades.empty() == false then 
			CurrentTooltipData.ResearchedUpgrades = res_upgrades
		end
	else
		return
	end
	
	if #tooltip_data >= 2 then
		CurrentTooltipData.Name = tooltip_data[2]
	else
		return
	end
	
	if #tooltip_data >= 3 then
		CurrentTooltipData.DescriptionText = tooltip_data[3]
	end
	
	if #tooltip_data >= 5 and tooltip_data[5] ~= false then
		CurrentTooltipData.AttachedHPType = tooltip_data[5]
	end
	
	if #tooltip_data >= 6 and tooltip_data[6] ~= false then
		CurrentTooltipData.ParentObject = tooltip_data[6]
	end

	
	if CurrentTooltipData.ParentObject then
		CurrentTooltipData.UpgradesList = CurrentTooltipData.ParentObject.Get_Updated_Buildable_Hardpoints_List()
	elseif CurrentTooltipData.Object then
		CurrentTooltipData.UpgradesList = CurrentTooltipData.Object.Get_Updated_Buildable_Hardpoints_List()
		CurrentTooltipData.AddCategoryPrefix = true
	end
	
	CurrentTooltipData.IsHardPointSocket = (CurrentTooltipData.Type.Has_Behavior(BEHAVIOR_HARD_POINT) and CurrentTooltipData.Type.Has_Behavior(BEHAVIOR_TACTICAL_BUILD_OBJECTS))
	CurrentTooltipData.BuildCost = -1.0
	CurrentTooltipData.BuildTime = -1.0
	CurrentTooltipData.WarmUpTime =  -1.0
	CurrentTooltipData.CooldownTime = -1.0
	CurrentTooltipData.IsAbilityData = false
	CurrentTooltipData.Ability = nil
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Type_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Update_Type_Tooltip(tooltip_data)
	-- For types:
	-- tooltip_data = name, type, build_cost, build_time, warm_up_time, cooldown_time
	CurrentTooltipData = {}
	CurrentTooltipData.Type = tooltip_data[1]
	if CurrentTooltipData.Type ~= nil then
		CurrentTooltipData.Name = CurrentTooltipData.Type.Get_Display_Name()
		
		-- Get the list of build requirements if available.
		local reqs = CurrentTooltipData.Type.Get_Production_Requirements_Text(Find_Player("local"))
		if reqs and reqs.empty() == false then 
			CurrentTooltipData.BuildRequirements = reqs
		end
	else
		return
	end
	
	local data_size = #tooltip_data
	
	if data_size >= 2 then 
		CurrentTooltipData.BuildCost = tooltip_data[2]
	end
	
	if data_size >= 3 then 
		CurrentTooltipData.BuildTime = tooltip_data[3]
	end
	
	if data_size >= 4 then 
		CurrentTooltipData.BuildRate = tooltip_data[4]
	end
	
	if data_size >= 5 then 
		CurrentTooltipData.WarmUpTime = tooltip_data[5]
	end
	if data_size >= 6 then 
		CurrentTooltipData.CooldownTime = tooltip_data[6]	
	end
	
	if data_size >= 7 then 
		CurrentTooltipData.LifeBuildCap = tooltip_data[7]	
	end
	
	if data_size >= 8 then 
		CurrentTooltipData.LifeBuildCount = tooltip_data[8]	
	end	
	
	if data_size >= 9 then 
		CurrentTooltipData.CurrBuildCap = tooltip_data[9]	
	end
	
	if data_size >= 10 then 
		CurrentTooltipData.CurrBuildCount = tooltip_data[10]	
	end
	
	if data_size >= 11 then 
		CurrentTooltipData.PopCapCategory = tooltip_data[11]	
	end
	
	if data_size >= 12 then
		CurrentTooltipData.AdditionalLockInfo = tooltip_data[12]
	end
	
	if data_size >= 13 then
		CurrentTooltipData.PatchActiveState = tooltip_data[13]
	end
	
	CurrentTooltipData.IsHardPointSocket = false
	CurrentTooltipData.IsAbilityData = false
	CurrentTooltipData.Ability = nil
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Ability_Tooltip
-- ------------------------------------------------------------------------------------------------------------------
function Update_Ability_Tooltip(tooltip_data)
	-- tooltip_data[1] = ability name text
	-- tooltip_data[2] = object associated to this ability
	-- tooltip_data[3] = ability name (as needed to retrieve NameCRC)
	-- tooltip_data[4] = ability desc. text id
	-- tooltip_data[5] = ability category text id
	-- tooltip_data[6] = if applicable (eg cylinder) list of types to spawn
	
	if not TestValid(tooltip_data[2]) then return end
	
	CurrentTooltipData = {}
	CurrentTooltipData.IsAbilityData = true
	CurrentTooltipData.Name = tooltip_data[1]
	CurrentTooltipData.Type = tooltip_data[2].Get_Type()
	CurrentTooltipData.Ability = {}
	CurrentTooltipData.Ability.Name = tooltip_data[3]
	CurrentTooltipData.Ability.Object = tooltip_data[2]
	CurrentTooltipData.Ability.DescTextID = tooltip_data[4]
	CurrentTooltipData.Ability.CategoryTextID = tooltip_data[5]
	if #tooltip_data >= 6 then
		local types_list = tooltip_data[6]
		if types_list and #types_list > 0 then 
			CurrentTooltipData.Ability.SpawnsType = Find_Object_Type(types_list[1])
		end
	end
	
	if CurrentTooltipData.Ability.Object then
		-- we need to retrieve the recharge seconds and the credits needed (if applicable)
		local ab_data = CurrentTooltipData.Ability.Object.Get_Unit_Ability_Data(CurrentTooltipData.Ability.Name)
		if ab_data then
			if #ab_data >= 1 then
				CurrentTooltipData.CooldownTime = ab_data[1]
			end
			if #ab_data >= 2 then
				CurrentTooltipData.BuildCost = ab_data[2]
			end			
		end		
	end
	
	CurrentTooltipData.BuildTime = -1.0
	CurrentTooltipData.WarmUpTime = -1.0	
	CurrentTooltipData.IsHardPointSocket = false
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Name
-- ------------------------------------------------------------------------------------------------------------------
function Set_Name()
	local name_txt = Create_Wide_String("")
	
	if CurrentTooltipData.Type ~= nil then 
		local add_category_prefix = (CurrentTooltipMode == 'type' or (CurrentTooltipData.IsHardPointSocket == true and CurrentTooltipData.UpgradesList and #CurrentTooltipData.UpgradesList > 0 and CurrentTooltipData.AddCategoryPrefix == true) )
		if  add_category_prefix then  
			-- Get the  specific tooltip category from the type itself
			name_txt = CurrentTooltipData.Type.Get_Tooltip_Category_Text()
		elseif CurrentTooltipData.IsAbilityData == true and CurrentTooltipData.Ability.CategoryTextID ~= "" then
			name_txt = Get_Game_Text(CurrentTooltipData.Ability.CategoryTextID)
		end
	end
	
	if Replace_Token(name_txt, CurrentTooltipData.Name, 1) == nil then 
		if CurrentTooltipMode == 'type' and not name_txt.empty() then 
			name_txt.append(Create_Wide_String(" "))
		end
		name_txt.append(CurrentTooltipData.Name)
	end
	
	-- If this is a patch, append its active state to its name!.
	if CurrentTooltipData.PatchActiveState == PATCH_STATE_ACTIVE then
		if not name_txt.empty() then 
			-- Append the string (ACTIVE) to the patch's name
			local app_strg = Create_Wide_String(" (")
			app_strg.append(Get_Game_Text("TEXT_ACTIVE_PATCH"))
			app_strg.append(Create_Wide_String(")"))
			name_txt.append(app_strg)
		end
	elseif CurrentTooltipData.PatchActiveState == PATCH_STATE_INACTIVE then
		-- Append the string (INACTIVE) to the patch's name
		if not name_txt.empty() then 
			-- Append the string (ACTIVE) to the patch's name
			local app_strg = Create_Wide_String(" (")
			app_strg.append(Get_Game_Text("TEXT_EXPIRED_PATCH"))
			app_strg.append(Create_Wide_String(")"))
			name_txt.append(app_strg)
		end
	end	
	
	local display_text = Create_Wide_String("")
	display_text.append(name_txt)
	Name.Text.Set_Text(display_text)
	Name.Set_Hidden(false)
	Resize_Name_Insert()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Resize_Name_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Resize_Name_Insert()
	-- Update the current height to be this chunk's (y+h)
	local orig_bds = Name.Get_User_Data()
	if orig_bds == nil then 
		return
	end			

	-- Use the actual size of the text after wrapping to resize the frame around the text.
	local text_height = Name.Text.Get_Text_Height()
	if text_height < orig_bds.h then 
		text_height = orig_bds.h
	end
	
	Name.Set_World_Bounds(orig_bds.x, orig_bds.y, orig_bds.w, text_height)	
	CurrentSceneHeight = orig_bds.y + text_height
end

-- ------------------------------------------------------------------------------------------------------------------
-- Update_Cost_Time_Pop_Info
-- ------------------------------------------------------------------------------------------------------------------
function Set_Cost_Time_Pop_Info()

	local time = CurrentTooltipData.BuildTime
	if time and time <= 0 then
		time = CurrentTooltipData.CooldownTime
	end
	
	local pop_cap = 0	
	if CurrentTooltipData.IsAbilityData == true and CurrentTooltipData.Ability.SpawnsType ~= nil then 
		pop_cap = CurrentTooltipData.Ability.SpawnsType.Get_Unit_Pop_Cap()
	elseif CurrentTooltipData.IsAbilityData == false then
		local type = nil
		if CurrentTooltipData.ParentObject then
			type = CurrentTooltipData.ParentObject.Get_Type()
		else
			type = CurrentTooltipData.Type
		end	
		
		--Heroes have no pop cap in campaign modes
		if IsCampaignGame and type.Is_Hero() then
			pop_cap = 0
		else
			pop_cap = type.Get_Unit_Pop_Cap()
		end
	end
	
	local cost = CurrentTooltipData.BuildCost
	local hide = true
	if cost and cost > 0 then 
		CostQuad.Set_Hidden(false)
		Cost.Set_Text(Get_Localized_Formatted_Number(cost))
	else
		-- Hide the cost display.
		CostQuad.Set_Hidden(true)
		Cost.Set_Text("") 
	end
	hide = hide and (not cost or cost <= 0)
	
	if time and time > 0 then 
	
		TimeQuad.Set_Hidden(false)
		Time.Set_Text(Get_Localized_Formatted_Number.Get_Time(time))
		
		if CurrentTooltipData.BuildRate and CurrentTooltipData.BuildRate ~= -1.0 then
			-- build rate < 1.0 set the font color to red
			if CurrentTooltipData.BuildRate < 1.0 then
				Time.Set_Tint(1.0, 0.0, 0.0, 1.0)
			elseif CurrentTooltipData.BuildRate == 1.0 then -- build rate == 1.0 set the font color to white
				Time.Set_Tint(1.0, 1.0, 1.0, 1.0)
			else -- build rate > 1.0 set the font color to green
				Time.Set_Tint(0.0, 1.0, 0.0, 1.0)
			end
		else -- default tint is white
			Time.Set_Tint(1.0, 1.0, 1.0, 1.0)		
		end		
	else
		Time.Set_Text("") 
		TimeQuad.Set_Hidden(true)
	end
	hide = hide and (not time or time <= 0)
	
	if pop_cap and pop_cap > 0 then 
		PopQuad.Set_Hidden(false)
		PopTxt.Set_Text(Get_Localized_Formatted_Number(pop_cap))
	else
		PopQuad.Set_Hidden(true)
		PopTxt.Set_Text("") 		
	end
	hide = hide and (not pop_cap or pop_cap <= 0)
	
	if hide == false then 
		local bds = Pop.Get_User_Data()	
		Pop.Set_World_Bounds(bds.x, CurrentSceneHeight, bds.w, bds.h)
		CurrentSceneHeight = CurrentSceneHeight + bds.h
		Pop.Set_Hidden(false)
	else
		Pop.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Build_Cap_Text
-- ------------------------------------------------------------------------------------------------------------------
function Set_Build_Cap_Text()
	Set_Current_Build_Cap()
	Set_Lifetime_Build_Cap()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Lifetime_Build_Cap
-- ------------------------------------------------------------------------------------------------------------------
function Set_Lifetime_Build_Cap()
	if not TestValid(LifeBuildCap) then return end	
	
	local cap_reached = false
	local is_walker_category = false
	if CurrentTooltipData.LifeBuildCap and CurrentTooltipData.LifeBuildCap ~= -1.0 then
		-- set the text, resize it
		if CurrentTooltipData.LifeBuildCount ~= nil then
			is_walker_category = (CurrentTooltipData.PopCapCategory and CurrentTooltipData.PopCapCategory == POP_CAP_CATEGORY_WALKER)
			cap_reached = (CurrentTooltipData.LifeBuildCap == CurrentTooltipData.LifeBuildCount)
			if cap_reached then 
				-- Display the build cap in red to convey the fact that the limit has been reached!
				LifeBuildCap.Set_Tint(1.0, 0.0, 0.0, 1.0)
			elseif is_walker_category then
				LifeBuildCap.Set_Tint(1.0, 1.0, 0.0, 1.0)
			else
				LifeBuildCap.Set_Tint(0.0, 1.0, 0.0, 1.0)
			end
			
			local text_strg
			local fraction = Get_Game_Text("TEXT_FRACTION")
			if is_walker_category then
				text_strg = Get_Game_Text("TEXT_ID_TOOLTIP_WALKER_LIFETIME_BUILD_LIMIT")
			else
				text_strg = Get_Game_Text("TEXT_ID_TOOLTIP_LIFETIME_BUILD_LIMIT")
			end
			
			Replace_Token(fraction, Get_Localized_Formatted_Number(CurrentTooltipData.LifeBuildCount), 0)
			Replace_Token(fraction, Get_Localized_Formatted_Number(CurrentTooltipData.LifeBuildCap), 1)
			
			if not Replace_Token(text_strg, fraction, 1) then
				text_strg.append(fraction)
			end
			
			if not text_strg.empty() then 
				text_strg.append(Create_Wide_String("\n"))
				LifeBuildCap.Set_Text(text_strg)
				Resize_Lifetime_Build_Cap_Insert()	
				LifeBuildCap.Set_Hidden(false)
			else
				LifeBuildCap.Set_Hidden(true)
			end			
		else
			-- hide
			LifeBuildCap.Set_Hidden(true)
		end
	else
		-- hide
		LifeBuildCap.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Resize_Lifetime_Build_Cap_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Resize_Lifetime_Build_Cap_Insert()
	-- Update the current height to be this chunk's (y+h)
	local orig_bds = LifeBuildCap.Get_User_Data()
	if orig_bds == nil then 
		return
	end			

	-- Use the actual size of the text after wrapping to resize the frame around the text.
	local text_height = LifeBuildCap.Get_Text_Height()
	if text_height < orig_bds.h then 
		text_height = orig_bds.h
	end
	
	-- resize based on the text height and relocate the scene based on the current height.
	LifeBuildCap.Set_World_Bounds(orig_bds.x, CurrentSceneHeight, orig_bds.w, text_height)
	CurrentSceneHeight = CurrentSceneHeight + text_height	
end



-- ------------------------------------------------------------------------------------------------------------------
-- Set_Current_Build_Cap
-- ------------------------------------------------------------------------------------------------------------------
function Set_Current_Build_Cap()
	if not TestValid(CurrBuildCap) then return end	
	
	local cap_reached = false
	local is_walker_category = false
	if CurrentTooltipData.CurrBuildCap and CurrentTooltipData.CurrBuildCap ~= -1.0 then
		-- set the text, resize it
		if CurrentTooltipData.CurrBuildCount ~= nil then
			is_walker_category = (CurrentTooltipData.PopCapCategory and CurrentTooltipData.PopCapCategory == POP_CAP_CATEGORY_WALKER)
			cap_reached = (CurrentTooltipData.CurrBuildCap == CurrentTooltipData.CurrBuildCount)
			if cap_reached then 
				-- Display the build cap in red to convey the fact that the limit has been reached!
				CurrBuildCap.Set_Tint(1.0, 0.0, 0.0, 1.0)
			elseif is_walker_category then 
				CurrBuildCap.Set_Tint(1.0, 1.0, 0.0, 1.0)
			else
				CurrBuildCap.Set_Tint(0.0, 1.0, 0.0, 1.0)
			end
			
			local text_strg
			if is_walker_category then 
				text_strg = Get_Game_Text("TEXT_ID_TOOLTIP_WALKER_BUILD_LIMIT") 
			else
				text_strg = Get_Game_Text("TEXT_ID_TOOLTIP_BUILD_LIMIT")
			end
			
			local fraction = Get_Game_Text("TEXT_FRACTION")
			Replace_Token(fraction, Get_Localized_Formatted_Number(CurrentTooltipData.CurrBuildCount), 0)
			Replace_Token(fraction, Get_Localized_Formatted_Number(CurrentTooltipData.CurrBuildCap), 1)
			
			if not Replace_Token(text_strg, fraction, 1) then
				text_strg.append(fraction)
			end
			
			if not text_strg.empty() then 
				text_strg.append(Create_Wide_String("\n"))
				CurrBuildCap.Set_Text(text_strg)
				Resize_Current_Build_Cap_Insert()	
				CurrBuildCap.Set_Hidden(false)
			else
				CurrBuildCap.Set_Hidden(true)
			end			
		else
			-- hide
			CurrBuildCap.Set_Hidden(true)
		end	
	else
		-- hide
		CurrBuildCap.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Resize_Current_Build_Cap_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Resize_Current_Build_Cap_Insert()
	-- Update the current height to be this chunk's (y+h)
	local orig_bds = CurrBuildCap.Get_User_Data()
	if orig_bds == nil then 
		return
	end			

	-- Use the actual size of the text after wrapping to resize the frame around the text.
	local text_height = CurrBuildCap.Get_Text_Height()
	if text_height < orig_bds.h then 
		text_height = orig_bds.h
	end
	
	-- resize based on the text height and relocate the scene based on the current height.
	CurrBuildCap.Set_World_Bounds(orig_bds.x, CurrentSceneHeight, orig_bds.w, text_height)
	CurrentSceneHeight = CurrentSceneHeight + text_height	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Additional_Lock_Info
-- ------------------------------------------------------------------------------------------------------------------
function Set_Additional_Lock_Info()
	if not TestValid(LockInfo) then return end

	if CurrentTooltipData.AdditionalLockInfo then
		LockInfo.Set_Text(CurrentTooltipData.AdditionalLockInfo)
		Resize_Additional_Lock_Info_Insert()
		LockInfo.Set_Hidden(false)
	else
		LockInfo.Set_Hidden(true)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Resize_Additional_Lock_Info_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Resize_Additional_Lock_Info_Insert()
	-- Update the current height to be this chunk's (y+h)
	local orig_bds = LockInfo.Get_User_Data()
	if orig_bds == nil then 
		return
	end			

	-- Use the actual size of the text after wrapping to resize the frame around the text.
	local text_height = LockInfo.Get_Text_Height()
	if text_height < orig_bds.h then 
		text_height = orig_bds.h
	end
	
	-- resize based on the text height and relocate the scene based on the current height.
	LockInfo.Set_World_Bounds(orig_bds.x, CurrentSceneHeight, orig_bds.w, text_height)
	CurrentSceneHeight = CurrentSceneHeight + text_height	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Set_Good_Against_Vulnerable_To_Text
-- ------------------------------------------------------------------------------------------------------------------
function Set_Good_Against_Vulnerable_To_Text()

	local type_to_check
	if CurrentTooltipData.AttachedHPType then
		type_to_check = CurrentTooltipData.AttachedHPType
	else	
		type_to_check = CurrentTooltipData.Type
	end
	
	if not type_to_check then 
		GAVT.Set_Hidden(true)
		return 
	end
	
	local text_strg = Create_Wide_String("")
	if CurrentTooltipData.IsAbilityData == false then 
		local good_against_text = type_to_check.Get_Tooltip_Good_Against_Text()
		if good_against_text then
			local string_to_append = Create_Wide_String("")
			string_to_append.append(GoodAgainstHeaderStrg)
			string_to_append.append(Create_Wide_String(" "))
			string_to_append.append(good_against_text)
			string_to_append.append(Create_Wide_String("\n"))
			text_strg.append(string_to_append)
		end	
		
		local vulnerable_to_text = type_to_check.Get_Tooltip_Vulnerable_To_Text()
		if vulnerable_to_text then
			local string_to_append = Create_Wide_String("")
			string_to_append.append(VulnerableToHeaderStrg)
			string_to_append.append(Create_Wide_String(" "))
			string_to_append.append(vulnerable_to_text)		
			string_to_append.append(Create_Wide_String("\n"))		
			text_strg.append(string_to_append)
		end	
	end
	
	if text_strg.empty() == false then 
		text_strg.append(Create_Wide_String("\n"))
		GAVT.Text.Set_Text(text_strg)
		Resize_GAVT_Insert()	
		GAVT.Set_Hidden(false)
	else
		GAVT.Set_Hidden(true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- Resize_GAVT_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Resize_GAVT_Insert()
	-- Update the current height to be this chunk's (y+h)
	local orig_bds = GAVT.Get_User_Data()
	if orig_bds == nil then 
		return
	end			

	-- Use the actual size of the text after wrapping to resize the frame around the text.
	local text_height = GAVT.Text.Get_Text_Height()
	if text_height < orig_bds.h then 
		text_height = orig_bds.h
	end
	
	-- resize based on the text height and relocate the scene based on the current height.
	GAVT.Set_World_Bounds(orig_bds.x, CurrentSceneHeight, orig_bds.w, text_height)
	CurrentSceneHeight = CurrentSceneHeight + text_height	
end



-- ------------------------------------------------------------------------------------------------------------------
-- Set_Description_Text
-- ------------------------------------------------------------------------------------------------------------------
function Set_Description_Text()
	
	local text = Create_Wide_String("")
	
	if not CurrentTooltipData.IsAbilityData then
		if CurrentTooltipData.DescriptionText then
			text.append(CurrentTooltipData.DescriptionText)
		else
			text.append(CurrentTooltipData.Type.Get_Tooltip_Description_Text( CurrentTooltipData.Object))
		end
	elseif CurrentTooltipData.Ability.DescTextID ~= "" then 
		text.append(Get_Game_Text(CurrentTooltipData.Ability.DescTextID))
	end
	
	if not text or text.empty() == true then 
		text.append(Create_Wide_String("The TooltipBehaviorType data for this object has not been set.\n You must specify the tooltip category text id and the description text id.\n\n\n"))
	end
		
	if CurrentTooltipData.UpgradesList ~= nil and #CurrentTooltipData.UpgradesList > 0 then 
		local w_append = Create_Wide_String("\n")
		if CurrentTooltipData.IsHardPointSocket == false then
			w_append.append(Create_Wide_String("\n"))
			w_append.append(UpgradesHeaderStrg)	
		end
		w_append.append(Create_Wide_String("\n"))
		
		for idx, type in pairs(CurrentTooltipData.UpgradesList) do
			w_append.append(Create_Wide_String(" - "))
			w_append.append(type.Get_Display_Name())
			if idx < #CurrentTooltipData.UpgradesList then
				w_append.append(Create_Wide_String("\n"))
			end
		end
		
		if Replace_Token(text, w_append, 1) == nil then 
			text.append(w_append)
		end
	end
	
	-- Display any researched upgrades this unit can obtain.
	if CurrentTooltipData.ResearchedUpgrades ~= nil then
		local res_upgrades_strg = Create_Wide_String("\n\n")
		res_upgrades_strg.append(ResearchedUpgradesHeaderStrg)
		res_upgrades_strg.append(Create_Wide_String("\n"))
		res_upgrades_strg.append(CurrentTooltipData.ResearchedUpgrades)
		text.append(res_upgrades_strg)
	end
	
	-- Display any production requirements this type may be associated to.
	if CurrentTooltipData.BuildRequirements then
		local reqs_strg = Create_Wide_String("\n\n")
		reqs_strg.append(CurrentTooltipData.BuildRequirements)
		text.append(reqs_strg)
	end
	
	if text.empty() == false then
		Desc.Text.Set_Text(text)
		Resize_Description_Insert()
		Desc.Set_Hidden(false)
	else
		Desc.Set_Hidden(true)	
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Resize_Description_Insert
-- ------------------------------------------------------------------------------------------------------------------
function Resize_Description_Insert()
	-- Update the current height to be this chunk's (y+h)
	local orig_bds = Desc.Get_User_Data()
	if orig_bds == nil then 
		return
	end			

	-- Use the actual size of the text after wrapping to resize the frame around the text.
	local text_height = Desc.Text.Get_Text_Height()
	if text_height < orig_bds.h then 
		text_height = orig_bds.h
	end
	
	-- resize based on the text height and relocate the scene based on the current height.
	Desc.Set_World_Bounds(orig_bds.x, CurrentSceneHeight, orig_bds.w, text_height)
	CurrentSceneHeight = CurrentSceneHeight + text_height	
end


-- ------------------------------------------------------------------------------------------------------------------
-- Reset_Data
-- ------------------------------------------------------------------------------------------------------------------
function Reset_Data()
	CurrentTooltipMode= nil
	CurrentTooltipData = nil
	CurrentSceneHeight = nil
end


-- ------------------------------------------------------------------------------------------------------------------
-- Display (Interface)
-- ------------------------------------------------------------------------------------------------------------------
function Display(sort_to_front, tooltip_info)
	if sort_to_front == nil or tooltip_info == nil then return end
	this.Set_Hidden(false)
	this.Set_Sort_To_Front(sort_to_front)
	Setup_Display(tooltip_info)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Close (Interface)
-- ------------------------------------------------------------------------------------------------------------------
function Close()
	this.Play_Animation("Close", false)
	Reset_Data()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Display (Interface)
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Display(on_off)
	this.Set_Hidden(on_off)
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Display = Display
Interface.Close = Close
Interface.Hide_Display = Hide_Display
