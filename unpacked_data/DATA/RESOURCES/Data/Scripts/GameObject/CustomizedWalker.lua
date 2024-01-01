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
--             File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/CustomizedWalker.lua 
--
--    Original Author: Maria Teruel
--
--          Date: 2006/11/02
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	ServiceRate = 0.001
	LastService = nil
end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
	-- Attach the specified hard points.
	if not TestValid(Object) then 
		return 
	end

	if HARD_POINT_CONFIGURATION_TABLE == nil then 
		return
	end

	local hard_points_table = Object.Get_All_Hard_Points()
	
	if hard_points_table == nil then
		if Object.Has_Behavior(BEHAVIOR_TACTICAL_BUILD_OBJECTS) then
			hard_points_table = {}
			table.insert(hard_points_table, Object)
		end
	end
	
	if hard_points_table then 
		-- Get the configuration table and build the hard points on the object!
		for _, socket in pairs(hard_points_table) do
			local hard_point_to_build = HARD_POINT_CONFIGURATION_TABLE[socket.Get_Type().Get_Name()]
			if hard_point_to_build ~= nil then 
				local hp_type = Find_Object_Type(hard_point_to_build)
				Build_Hard_Point(socket, hp_type)
			end
		end	
	end
	
	for objtype, hptobuild in pairs(HARD_POINT_CONFIGURATION_TABLE) do
		if objtype == Object.Get_Type().Get_Name() then
			Build_Hard_Point(Object, hptobuild)
			break
		end
	end
end
 

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Build_Hard_Point 
-- --------------------------------------------------------------------------------------------------------------------------------------------
function Build_Hard_Point(socket_object, type_to_build)
	if socket_object == nil then
		MessageBox("CustomizedWalker.lua::Build_Hard_Point: The socket object is nil.")
		return false
	end
	
	if type_to_build ~= nil then
		return( socket_object.Create_And_Attach_Hard_Point( type_to_build ) )
	else
		MessageBox("CustomizedWalker.lua::Build_Hard_Point: The type to build is nil.")
		return false
	end
end



-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
-- my_behavior.Service = Behavior_Service
--my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
