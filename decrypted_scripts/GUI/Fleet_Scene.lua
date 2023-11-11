-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Fleet_Scene.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Fleet_Scene.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Nader_Akoury $
--
--            $Change: 72769 $
--
--          $DateTime: 2007/06/11 11:49:36 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("Global_Icons")

function On_Click()
	if Object.Is_Fleet_Moving() then
		if not Object.Get_In_Flight_Retreat() then
			Object.On_In_Flight_Retreat()
		end
	end
end

function On_Update()
	if not Object.Is_Valid() then
		Fleet_Scene.Set_Hidden(true)
		return 
	end

	if Object.Is_Fleet_Moving() then
		Fleet_Scene.Scriptable.FleetIcon.Set_Hidden(false)
		
		local count = Object.Get_Contained_Object_Count()
		if count <= 1 then
			Fleet_Scene.Scriptable.CountText.Set_Hidden(true)
		else
			Fleet_Scene.Scriptable.CountText.Set_Hidden(false)
			Fleet_Scene.Scriptable.CountText.Set_Text(Get_Localized_Formatted_Number(count))
		end
	else
		Fleet_Scene.Scriptable.FleetIcon.Set_Hidden(true)
		Fleet_Scene.Scriptable.CountText.Set_Hidden(true)
	end
	local icon = Get_Fleet_Icon_Name(Object)
	Fleet_Scene.Scriptable.FleetIcon.Set_Texture(icon)
end

function On_Init()
	On_Update()
end
