if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[127] = true
LuaGlobalCommandLinks[193] = true
LuaGlobalCommandLinks[192] = true
LuaGlobalCommandLinks[95] = true
LUA_PREP = true

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	this.Register_Event_Handler("Button_Clicked", this.Controls.AudioOptionsButton, Audio_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.GameOptionsButton, Game_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.VideoOptionsButton, Video_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.KeyboardOptionsButton, Keyboard_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.Controls.BackButton, Hide_Dialog)
	this.Register_Event_Handler("Button_Clicked", this.Controls.GamepadButton, Gamepad_Clicked)
	this.Register_Event_Handler("Component_Unhidden", this, Display_Dialog)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, Hide_Dialog)

	this.Controls.AudioOptionsButton.Set_Tab_Order(Declare_Enum(0))
	this.Controls.VideoOptionsButton.Set_Tab_Order(Declare_Enum())
	this.Controls.KeyboardOptionsButton.Set_Tab_Order(Declare_Enum())
	this.Controls.GamepadButton.Set_Tab_Order(Declare_Enum())
	this.Controls.GameOptionsButton.Set_Tab_Order(Declare_Enum())
	this.Controls.BackButton.Set_Tab_Order(Declare_Enum())

	Display_Dialog()
	-- Maria 08.17.2007
	-- Force an update right here since otherwise buttons that should be hidden will be displayed
	-- in betweent the time this call and the On_Update calls are made.
	On_Update()
end


------------------------------------------------------------------------
-- Play_Mouse_On_SFX
------------------------------------------------------------------------
function Play_Mouse_On_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
	end
end

------------------------------------------------------------------------
-- Play_Select_SFX
------------------------------------------------------------------------
function Play_Select_SFX(event, source)
	if source and source.Is_Enabled() == true then 
		if source == this.Controls.BackButton then 
			Play_SFX_Event("GUI_Main_Menu_Back_Select")
		else
			Play_SFX_Event("GUI_Main_Menu_Button_Select")
		end
	end
end



function Audio_Clicked(event_name, source)
	Spawn_Dialog("Audio_Options_Dialog", true)
end

function Game_Clicked(event_name, source)
	Spawn_Dialog("Gameplay_Options_Dialog", true)
end

function Video_Clicked(event_name, source)
	Spawn_Dialog("Video_Options_Dialog", true)
end

function Keyboard_Clicked(event_name, source)
	Spawn_Dialog("Keyboard_Configuration_Dialog", true)
end

function Gamepad_Clicked(event_name, source)
	Spawn_Dialog("Gamepad_ButtonMap", true)
end

function Display_Dialog()
	if not Is_Audio_Initialized() then
		this.Controls.AudioOptionsButton.Enable(false)
	end
end

function Hide_Dialog(event_name, source)
	GUI_Dialog_Raise_Parent()
end

function On_Update()
	if not Is_Xbox() then
		if last_gamepad_state == Is_Gamepad_Active() then
			if Is_Gamepad_Active() then
				this.Controls.KeyboardOptionsButton.Enable(false)
				this.Controls.KeyboardOptionsButton.Set_Hidden(true)
				this.Controls.GamepadButton.Set_Hidden(false)
				this.Controls.GamepadButton.Enable(true)
			else --gamepad unplugged
				this.Controls.GamepadButton.Enable(false)
				this.Controls.GamepadButton.Set_Hidden(true)
				this.Controls.KeyboardOptionsButton.Set_Hidden(false)
				this.Controls.KeyboardOptionsButton.Enable(true)
			end
		end
	else
		this.Controls.KeyboardOptionsButton.Enable(false)
		this.Controls.KeyboardOptionsButton.Set_Hidden(true)
		this.Controls.GamepadButton.Set_Hidden(false)
		this.Controls.GamepadButton.Enable(true)
	end	
	
	last_gamepad_state = Is_Gamepad_Active()
end
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
