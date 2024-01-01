-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Custom_Checkbox.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Custom_Checkbox.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 84606 $
--
--          $DateTime: 2007/09/24 09:21:30 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

function On_Init()
	Custom_Checkbox.Register_Event_Handler("Button_Clicked", Custom_Checkbox, On_Click)
end

function On_Click()
	if Custom_Checkbox.Get_Containing_Scene() then
		Custom_Checkbox.Get_Containing_Scene().Raise_Event_Immediate("Custom_Checkbox_Clicked", Custom_Checkbox.Get_Containing_Component(), nil)
	end
end

IsChecked = false
Enabled = true

function Set_Checked(checked)
	if IsChecked == checked then
		return
	end

	if Enabled == false then
		return
	end

	IsChecked = checked
	
	current_state = Custom_Checkbox.Get_Current_State_Name()
	if checked then
		if current_state == "Default_Off" then
			Custom_Checkbox.Set_State("Default_On")
		elseif current_state == "Mouse_Over_Off" then
			Custom_Checkbox.Set_State("Mouse_Over_On")
		elseif current_state == "Mouse_Down_Off" then
			Custom_Checkbox.Set_State("Mouse_Down_On")
		end
	else
		if current_state == "Default_On" then
			Custom_Checkbox.Set_State("Default_Off")
		elseif current_state == "Mouse_Over_On" then
			Custom_Checkbox.Set_State("Mouse_Over_Off")
		elseif current_state == "Mouse_Down_On" then
			Custom_Checkbox.Set_State("Mouse_Down_Off")
		end
	end
end

function Is_Checked()
	return IsChecked
end

function Enable(enabled)
	if enabled == Enabled then
		return
	end

	if enabled then
		if IsChecked then
			Custom_Checkbox.Set_State("Default_On")
		else
			Custom_Checkbox.Set_State("Default_Off")
		end
	else
		if IsChecked then
			Custom_Checkbox.Set_State("Disabled_On")
		else
			Custom_Checkbox.Set_State("Disabled_Off")
		end
	end
end

Interface = {}
Interface.Set_Checked = Set_Checked
Interface.Enable = Enable
Interface.Is_Checked = Is_Checked