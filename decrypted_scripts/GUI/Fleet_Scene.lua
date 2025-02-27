if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[9] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Fleet_Scene.lua#5 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Fleet_Scene.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 92481 $
--
--          $DateTime: 2008/02/05 12:16:28 $
--
--          $Revision: #5 $
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
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Get_Faction_Icon_Name = nil
	Kill_Unused_Global_Functions = nil
end
