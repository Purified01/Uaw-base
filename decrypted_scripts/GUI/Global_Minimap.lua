-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Minimap.lua#4 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Minimap.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 74452 $
--
--          $DateTime: 2007/06/26 15:18:18 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Init
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Init()
	MouseOverRegion = nil
	Regions = {}
	local all_children = this.Get_All_Children()
	for _, child in pairs(all_children) do
		local region_type = Find_Object_Type(child.Get_Name())
		if region_type then
			local region_object = Find_First_Object(region_type)
			if region_object then
				Regions[region_object] = child
				child.Set_User_Data(region_object)
				this.Register_Event_Handler("Mouse_Left_Down", child, On_Region_Mouse_Down)
				this.Register_Event_Handler("Mouse_Right_Up", child, On_Region_Mouse_Right_Up)
				this.Register_Event_Handler("Mouse_On", child, On_Mouse_On_Region)
				this.Register_Event_Handler("Mouse_Off", child, On_Mouse_Off_Region)
			end
		end
	end
	this.Register_Event_Handler("Mouse_Left_Down", this, On_Mouse_Down)
	this.Register_Event_Handler("Mouse_Left_Up", nil, On_Mouse_Up)
	this.Register_Event_Handler("Mouse_Non_Client_Left_Up", nil, On_Mouse_Up)
	
	MouseCapture = false
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Region_Mouse_Up
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Region_Mouse_Down(_, source)
	Point_Camera_At(source.Get_User_Data())
	MouseCapture = true
end

function On_Mouse_Down()
	--No region was hit, but we'll capture the mouse anyway
	MouseCapture = true
end

function On_Mouse_Up()
	MouseCapture = false
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Set_Region_Color
-- ------------------------------------------------------------------------------------------------------------------------------------
function Set_Region_Color(region, r, g, b)
	Regions[region].Set_Tint(r, g, b, 1.0)
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_On_Region
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_On_Region(event, source)
	MouseOverRegion = source.Get_User_Data()
	if MouseCapture then
		Point_Camera_At(MouseOverRegion)
	end	
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off_Region
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off_Region(event, source)
	MouseOverRegion = nil
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Get_Mouse_Over_Region
-- ------------------------------------------------------------------------------------------------------------------------------------
function Get_Mouse_Over_Region()
	return MouseOverRegion
end

-- ------------------------------------------------------------------------------------------------------------------------------------
-- On_Region_Mouse_Right_Up
-- ------------------------------------------------------------------------------------------------------------------------------------
function On_Region_Mouse_Right_Up(event, source)
	this.Get_Containing_Scene().Raise_Event_Immediate("Minimap_Region_Clicked", this.Get_Containing_Component(), { source.Get_User_Data() })
end

Interface = {}
Interface.Set_Region_Color = Set_Region_Color
Interface.Get_Mouse_Over_Region = Get_Mouse_Over_Region