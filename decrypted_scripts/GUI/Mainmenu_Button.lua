-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Mainmenu_Button.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Mainmenu_Button.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Maria_Teruel $
--
--            $Change: 84606 $
--^
--          $DateTime: 2007/09/24 09:21:30 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Raise_Event_All_Scenes
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Raise_Event_All_Scenes(event_name, args)
	local num_scenes = Get_Total_Active_Scenes()
	for i=0,num_scenes-1 do
		local scene = Get_Active_Scene_At(i)
		scene.Raise_Event(event_name, nil, args)
	end
end


function On_Init()
	HasFocus = false
	Mainmenu_Button.Register_Event_Handler("Button_Clicked", Mainmenu_Button, Button_Clicked)
end

function On_Update()

end

function Play_Click_SFX()
	Play_SFX_Event("GUI_Main_Menu_Button_Select")
end

function Play_Rollover_SFX()
	Play_SFX_Event("GUI_Main_Menu_Mouse_Over")
end

function Button_Clicked()
	Raise_Event_Immediate_All_Parents("Mainmenu_Button_Clicked", Mainmenu_Button.Get_Containing_Component(), Mainmenu_Button, nil)
end

function Set_MouseOff() 
	Mainmenu_Button.Button_MouseOver.Set_Hidden(true)
end

function Set_Button_Name(str)
	Mainmenu_Button.Scriptable.Name.Set_Text(str)
end

function Enable()
	Mainmenu_Button.Set_State("Mouse_Off")
end

function Disable()
	Mainmenu_Button.Set_State("Disabled")
end

function Set_Focus_State(value)
	HasFocus = value
	if (HasFocus) then
		Mainmenu_Button.Set_State("Mouse_Over")
	else
		Mainmenu_Button.Set_State("Mouse_Off")
	end
end

Interface = {}
Interface.Set_Button_Name = Set_Button_Name
Interface.Set_MouseOff = Set_MouseOff
Interface.Enable = Enable
Interface.Disable = Disable
Interface.Set_Focus_State = Set_Focus_State
