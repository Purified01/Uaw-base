-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Transport_Health.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Global_Transport_Health.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 78108 $
--
--          $DateTime: 2007/07/24 11:16:07 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

function On_Init()

	-- We want to color the health bar based on the amount of health the object has at any given time
	-- NOTE: we don't set them with Set_GUI_Variable since they are static
	COLOR_HEALTH_GOOD = { }
	COLOR_HEALTH_MEDIUM = { }
	COLOR_HEALTH_LOW = { }
	
	COLOR_HEALTH_GOOD.R = 0.125
	COLOR_HEALTH_GOOD.G = 1.0
	COLOR_HEALTH_GOOD.B = 0.125
	COLOR_HEALTH_GOOD.A = 1.0

	COLOR_HEALTH_MEDIUM.R = 1.0
	COLOR_HEALTH_MEDIUM.G = 1.0
	COLOR_HEALTH_MEDIUM.B = 0.125
	COLOR_HEALTH_MEDIUM.A = 1.0

	COLOR_HEALTH_LOW.R = 1.0
	COLOR_HEALTH_LOW.G = 0.125
	COLOR_HEALTH_LOW.B = 0.125
	COLOR_HEALTH_LOW.A = 1.0
	
	local health_x, health_y, health_width, health_height = this.HealthBarQuad.Get_Bounds()
	Set_GUI_Variable("HealthX", health_x)
	Set_GUI_Variable("HealthY", health_y)
	Set_GUI_Variable("HealthWidth", health_width)
	Set_GUI_Variable("HealthHeight", health_height)
	Set_GUI_Variable("HealthOrigWidth", health_width)	
	
	if not TestValid(Object) then
		this.Set_State("Inactive")
		return
	end
	
	if Object.Get_Owner() ~= Find_Player("local") then
		this.Set_State("Inactive")
		return
	end
	
	local fleet = Object.Get_Parent_Object()
	if not TestValid(fleet) then
		this.Set_State("Inactive")
		return
	end	
end

function On_Update()
	if not TestValid(Object) then
		this.Set_State("Inactive")
		return
	end
	
	local fleet = Object.Get_Parent_Object()
	if not TestValid(fleet) then
		this.Set_State("Inactive")
		return
	end

	local health_percent = fleet.Get_Health()
	if not health_percent then
		health_percent = 0.0
	end
	local hwidth = Get_GUI_Variable("HealthOrigWidth") * health_percent
	Set_GUI_Variable("HealthWidth", hwidth)
	this.HealthBarQuad.Set_Bounds(	Get_GUI_Variable("HealthX"), 
												Get_GUI_Variable("HealthY"),
												Get_GUI_Variable("HealthWidth"), 
												Get_GUI_Variable("HealthHeight"))
							
	--Tint the health bar based on current health
	if health_percent > 0.66 then
		this.HealthBarQuad.Set_Tint(COLOR_HEALTH_GOOD.R, COLOR_HEALTH_GOOD.G, COLOR_HEALTH_GOOD.B, COLOR_HEALTH_GOOD.A)
	elseif health_percent > 0.33 then
		this.HealthBarQuad.Set_Tint(COLOR_HEALTH_MEDIUM.R, COLOR_HEALTH_MEDIUM.G, COLOR_HEALTH_MEDIUM.B, COLOR_HEALTH_MEDIUM.A)
	else
		this.HealthBarQuad.Set_Tint(COLOR_HEALTH_LOW.R, COLOR_HEALTH_LOW.G, COLOR_HEALTH_LOW.B, COLOR_HEALTH_LOW.A)
	end	
end