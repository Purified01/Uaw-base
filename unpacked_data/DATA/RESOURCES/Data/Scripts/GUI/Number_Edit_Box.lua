-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Number_Edit_Box.lua#3 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Number_Edit_Box.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Nader_Akoury $
--
--            $Change: 72723 $
--
--          $DateTime: 2007/06/09 14:28:19 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

function On_Init()
	Register_User_Event("Number_Edit_Box_Changed")
	this.Register_Event_Handler("Button_Clicked", this.ButtonUp, Up_Clicked)
	this.Register_Event_Handler("Button_Clicked", this.ButtonDown, Down_Clicked)
	this.NumberDisplay.Set_Editable(false)

	-- Setup the tab ordering
	this.ButtonUp.Set_Tab_Order(Declare_Enum(0))
	this.ButtonDown.Set_Tab_Order(Declare_Enum())

	Max_Value = 0
	Min_Value = 0
	Current_Value = 0

	Update_Value()
end

function Initialize(min_value, max_value)
	Min_Value = min_value
	Max_Value = max_value
	Current_Value = min_value

	Update_Value()
end

function Up_Clicked(event_name, source)
	if Current_Value < Max_Value then
		Current_Value = Current_Value + 1
	end
	Update_Value()
end

function Down_Clicked(event_name, source)
	if Current_Value > Min_Value then
		Current_Value = Current_Value - 1
	end
	Update_Value()
end

function Set_Value(value)
	Current_Value = value
	Update_Value()
end

function Update_Value()
	this.NumberDisplay.Set_Text(Get_Localized_Formatted_Number(Current_Value))
	this.Get_Containing_Scene().Raise_Event("Number_Edit_Box_Changed", this.Get_Containing_Component(), {Current_Value})
end

function Get_Value()
	return Current_Value
end

Interface = {}
Interface.Get_Value = Get_Value
Interface.Set_Value = Set_Value
Interface.Initialize = Initialize
