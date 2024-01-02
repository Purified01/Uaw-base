require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Button_Clicked", this.CampaignControls.NovusButton, Novus_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.CampaignControls.HierarchyButton, Hierarchy_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.CampaignControls.MasariButton, Masari_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.CampaignControls.BackButton, Hide_Dialog)

	this.Register_Event_Handler("Button_Clicked", this.DifficultyControls.EasyButton, Easy_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.DifficultyControls.MediumButton, Medium_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.DifficultyControls.HardButton, Hard_Clicked)

	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Closing_All_Displays", nil, Hide_Dialog)

	this.CampaignControls.NovusButton.Set_Tab_Order(Declare_Enum(0))
	this.CampaignControls.HierarchyButton.Set_Tab_Order(Declare_Enum())
	this.CampaignControls.MasariButton.Set_Tab_Order(Declare_Enum())
	this.CampaignControls.BackButton.Set_Tab_Order(Declare_Enum())
	this.DifficultyControls.EasyButton.Set_Tab_Order(Declare_Enum())
	this.DifficultyControls.MediumButton.Set_Tab_Order(Declare_Enum())
	this.DifficultyControls.HardButton.Set_Tab_Order(Declare_Enum())

	this.Set_Hidden(false)
	Display_Dialog()

	Difficulty = Difficulty_Medium
	Select_Difficulty_Button()
end


------------------------------------------------------------------------
-- Play_Mouse_Over_Button_SFX
------------------------------------------------------------------------
function Play_Mouse_Over_Button_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Button_Select_SFX
------------------------------------------------------------------------
function Play_Button_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		if source == this.CampaignControls.BackButton then 
			Play_SFX_Event("GUI_Main_Menu_Back_Select")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
	end
end


function Display_Dialog()
	if not Novus_Campaign_Complete then
		this.CampaignControls.HierarchyButton.Enable(false)
	end

	if not Hierarchy_Campaign_Complete then
		this.CampaignControls.MasariButton.Enable(false)
	end
end

function Hide_Dialog()
	-- Hide this dialog
	this.Set_Hidden(true)

	-- Release the input focus
	this.End_Modal()
end

function Select_Difficulty(difficulty)
	Deselect_Difficulty_Button()
	Difficulty = difficulty
	Select_Difficulty_Button()
end

function Select_Difficulty_Button()
	local button = Get_Button_From_Difficulty(Difficulty)
	button.Set_Tint(0.75, 1, 0.75, 1)
end

function Deselect_Difficulty_Button()
	local button = Get_Button_From_Difficulty(Difficulty)
	button.Set_Tint(1, 1, 1, 1)
end

function Get_Button_From_Difficulty(difficulty)
	if difficulty == Difficulty_Easy then
		return this.DifficultyControls.EasyButton
	elseif difficulty == Difficulty_Medium then
		return this.DifficultyControls.MediumButton
	elseif difficulty == Difficulty_Hard then
		return this.DifficultyControls.HardButton
	end
end

function Easy_Clicked(event_name, source)
	Select_Difficulty(Difficulty_Easy)
end

function Medium_Clicked(event_name, source)
	Select_Difficulty(Difficulty_Medium)
end

function Hard_Clicked(event_name, source)
	Select_Difficulty(Difficulty_Hard)
end

function Novus_Clicked(event_name, source)
	Start_Campaign("NOVUS_Story_Campaign", Difficulty)
end

function Hierarchy_Clicked(event_name, source)
	Start_Campaign("Hierarchy_Story_Campaign", Difficulty)
end

function Masari_Clicked(event_name, source)
	Start_Campaign("MASARI_Story_Campaign", Difficulty)
end
