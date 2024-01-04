-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Reinforcement_Pane.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Reinforcement_Pane.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 83831 $
--
--          $DateTime: 2007/09/14 13:55:45 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

function On_Init()
	this.Register_Event_Handler("Selectable_Icon_Clicked", this.BuyButton, On_Buy_Button_Clicked)

	LocalPlayer = Find_Player("local")
	
	RearmingClockTint = {1.0, 0.0, 0.0, 0.75}
	InTransitClockTint = {0.0,1.0,0.0,0.75}		
end

function Update()
	local object = Get_GUI_Variable("Object")
	if not TestValid(object) then
		return
	end
	
	if object.Get_Type().Is_Hero() then
		Update_Hero_Pane(object)
	else
		Update_Command_Center_Pane(object)
	end	
	
	local pop_cap_info = LocalPlayer.Get_Tactical_Popcap_Information()
	local available_pop = pop_cap_info.Total - pop_cap_info.Used
	if available_pop >= Get_GUI_Variable("PopValue") then
		this.PopText.Set_Font("Cost_Green")
	else 
		this.PopText.Set_Font("Cost_Red")
	end	
end

function On_Buy_Button_Clicked()
	local object = Get_GUI_Variable("Object")
	if not TestValid(object) then
		return
	end
	
	local success = false
	
	local cost = Get_GUI_Variable("ReinforcementCost")
	if cost then
		local player_cash = LocalPlayer.Get_Credits()
		if player_cash < cost then
			Play_SFX_Event("GUI_Generic_Bad_Sound")
			return
		end
	end

	if object.Get_Type().Is_Hero() then
		success = object.Get_Parent_Object().Request_Strike_Force_Reinforcement()
	else
		local enabler = Get_GUI_Variable("Enabler")
		if enabler.Get_Are_Reinforcements_In_Transit(object) then
			success = enabler.Tactical_Enabler_Deploy_Ready_Reinforcements_From(object)
		else
			success = enabler.Tactical_Enabler_Begin_Reinforcement(object, LocalPlayer)
		end
	end
	
	if success then
		LocalPlayer.Add_Credits(-cost)
	else
		Play_SFX_Event("GUI_Generic_Bad_Sound")
	end	
end

function Update_Hero_Pane(hero_object)
	local fleet = hero_object.Get_Parent_Object()
	local reinf_time = fleet.Get_Strike_Force_Reinforcement_Time()
	local time_text = Get_Localized_Formatted_Number.Get_Time(reinf_time)
	this.TimeText.Set_Text(time_text)
	local progress = fleet.Get_Strike_Force_Reinforcement_Progress()
	if progress > 0.0 and reinf_time > 0.0 then
		this.BuyButton.Set_Clock_Filled(1.0 - progress)
		this.CostIcon.Set_Hidden(true)
		this.CostText.Set_Hidden(true)
		
		this.BuyButton.Set_Clock_Tint(InTransitClockTint)
		this.BuyButton.Set_Tooltip_Data({"ui", {"TEXT_SPEECH_REINFORCEMENTS_EN_ROUTE"}})
		this.BuyButton.Set_Texture(Get_Faction_Deploy_Icon())	
	else
		this.BuyButton.Set_Clock_Filled(0.0)
		
		local cost_per_second = hero_object.Get_Type().Get_Type_Value("Reinforcement_Cost_Per_Second")
		local total_cost = reinf_time * cost_per_second
		local player_cash = LocalPlayer.Get_Credits()
		Set_GUI_Variable("ReinforcementCost", total_cost)
		if total_cost > 0.0 then
			this.CostText.Set_Hidden(false)
			this.CostIcon.Set_Hidden(false)
			this.CostText.Set_Text(Get_Localized_Formatted_Number(total_cost))
			if player_cash >= total_cost then
				this.CostText.Set_Font("Cost_Green")
			else
				this.CostText.Set_Font("Cost_Red")
			end
			
			local tooltip_text = Get_Game_Text("TEXT_TOOLTIP_REINFORCEMENTS")
			tooltip_text.append(Create_Wide_String("\n"))
			tooltip_text.append(Get_Game_Text("TEXT_REINFORCEMENT_CANCELS_PRODUCTION"))
			this.BuyButton.Set_Tooltip_Data({"custom", tooltip_text})	
			this.BuyButton.Set_Texture("i_icon_reinforcements.tga")	
		else
			this.CostIcon.Set_Hidden(true)
			this.CostText.Set_Hidden(true)
			
			this.BuyButton.Set_Tooltip_Data({"ui", {"TEXT_REINFORCE"}})	
			this.BuyButton.Set_Texture(Get_Faction_Deploy_Icon())	
		end
	end	
end

function Update_Command_Center_Pane(region_object)
	local progress = 1.0
	local enabler = Get_GUI_Variable("Enabler")	
	local reinf_time = enabler.Tactical_Enabler_Get_Reinforcement_Time(region_object)
	
	if enabler.Get_Are_Reinforcements_In_Transit(region_object) then
		Set_GUI_Variable("ReinforcementCost", 0)
		this.CostIcon.Set_Hidden(true)
		this.CostText.Set_Hidden(true)
		this.BuyButton.Set_Clock_Tint(InTransitClockTint)
		this.BuyButton.Set_Texture(Get_Faction_Deploy_Icon())	
		
		progress = enabler.Get_In_Transit_Reinforcement_Batch_Progress(region_object)
		if progress >= 1.0 then
			this.TimeIcon.Set_Hidden(true)
			this.TimeText.Set_Hidden(true)
			
			this.BuyButton.Set_Tooltip_Data({"ui", {"TEXT_REINFORCE"}})			
		else
			reinf_time = reinf_time * (1 - progress)
			this.TimeIcon.Set_Hidden(false)
			this.TimeText.Set_Hidden(false)
			
			this.BuyButton.Set_Tooltip_Data({"ui", {"TEXT_SPEECH_REINFORCEMENTS_EN_ROUTE"}})	
		end
	else
		this.CostIcon.Set_Hidden(false)
		this.CostText.Set_Hidden(false)
		local cc_object = region_object.Get_Command_Center()
		local cost = cc_object.Get_Type().Get_Type_Value("Reinforcement_Cost_To_Adjacent_Territory")
		Set_GUI_Variable("ReinforcementCost", cost)
		this.CostText.Set_Text(Get_Localized_Formatted_Number(cost))	
		local player_cash = LocalPlayer.Get_Credits()
		if player_cash >= cost then
			this.CostText.Set_Font("Cost_Green")
		else
			this.CostText.Set_Font("Cost_Red")
		end
			
		this.BuyButton.Set_Clock_Tint(RearmingClockTint)
		this.BuyButton.Set_Texture("i_icon_reinforcements.tga")	

		progress = enabler.Get_New_Reinforcement_Batch_Readiness(region_object)
		if progress >= 1.0 then				
			this.TimeIcon.Set_Hidden(false)
			this.TimeText.Set_Hidden(false)
			
			this.BuyButton.Set_Tooltip_Data({"ui", {"TEXT_TOOLTIP_REINFORCEMENTS"}})			
		else
			this.TimeIcon.Set_Hidden(true)
			this.TimeText.Set_Hidden(true)
			
			local readiness_time = (1.0 - progress) * cc_object.Get_Type().Get_Type_Value("Rearm_Time_Seconds")
			local time_string = Get_Localized_Formatted_Number.Get_Time(readiness_time)
			local tooltip_text = Replace_Token(Get_Game_Text("TEXT_HEADER_COOLDOWN"), time_string, 0)	
			this.BuyButton.Set_Tooltip_Data({"custom", tooltip_text})			
		end
	end
	local time_text = Get_Localized_Formatted_Number.Get_Time(reinf_time)
	this.TimeText.Set_Text(time_text)
	
	this.BuyButton.Set_Clock_Filled(1.0 - progress)		
end

function Set_Object(object)
	Set_GUI_Variable("Object", object)

	if TestValid(object) then
		this.NameText.Set_Text(object.Get_Type().Get_Display_Name())
		if object.Get_Type().Is_Hero() then
			this.SourceIcon.Set_Texture(object.Get_Type().Get_Icon_Name())
			local pop_value = object.Get_Parent_Object().Get_Strike_Force_Reinforcement_Pop_Cap()
			Set_GUI_Variable("PopValue", pop_value)
			this.PopText.Set_Text(Get_Localized_Formatted_Number(pop_value))

			this.PopIcon.Set_Hidden(false)
			this.PopText.Set_Hidden(false)
			this.TimeIcon.Set_Hidden(false)
			this.TimeText.Set_Hidden(false)
			
			local tooltip_text = Get_Game_Text("TEXT_TOOLTIP_REINFORCEMENTS")
			tooltip_text.append(Create_Wide_String("\n"))
			tooltip_text.append(Get_Game_Text("TEXT_REINFORCEMENT_CANCELS_PRODUCTION"))
			this.BuyButton.Set_Tooltip_Data({"custom", tooltip_text})
		else
			local cc_object = object.Get_Command_Center()
			this.SourceIcon.Set_Texture(cc_object.Get_Type().Get_Icon_Name())
			
			local pop_value = object.Get_Defense_Force_Pop_Cap()
			Set_GUI_Variable("PopValue", pop_value)
			this.PopText.Set_Text(Get_Localized_Formatted_Number(pop_value))
			
			this.PopIcon.Set_Hidden(false)
			this.PopText.Set_Hidden(false)
			this.TimeIcon.Set_Hidden(false)
			this.TimeText.Set_Hidden(false)
			
			this.BuyButton.Set_Tooltip_Data({"ui", {"TEXT_TOOLTIP_REINFORCEMENTS"}})
		end
	end
end

function Set_Enabler(enabler)
	Set_GUI_Variable("Enabler", enabler)
end

function Get_Faction_Deploy_Icon()
	if not FactionDeployIcons then
		FactionDeployIcons = {}
		FactionDeployIcons["ALIEN"] = "i_icon_a_sa_xport_unload.tga"
		FactionDeployIcons["NOVUS"] = "i_icon_n_sa_xport_unload.tga"
		FactionDeployIcons["MASARI"] = "i_icon_m_sa_xport_unload.tga"
	end
	
	return FactionDeployIcons[LocalPlayer.Get_Faction_Name()]	
end

Interface = {}
Interface.Set_Object = Set_Object
Interface.Set_Enabler = Set_Enabler
Interface.Update = Update
