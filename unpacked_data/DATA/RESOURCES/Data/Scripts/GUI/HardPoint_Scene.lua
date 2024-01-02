-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/HardPoint_Scene.lua#17 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/HardPoint_Scene.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Maria_Teruel $
--
--            $Change: 75962 $
--
--          $DateTime: 2007/07/09 16:19:20 $
--
--          $Revision: #17 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Update_Reticle_Color
-- -------------------------------------------------------------------------------------------------------------------------------------
function Update_Reticle_Color()
	
	if TestValid(Object) then
	
		local hidden =  Is_Fogged( Find_Player("local"), HighestLevelHPParent )
		Scene.ReticleQuad.Set_Hidden(hidden)
			
		if hidden then
			return
		end
		
		--Tint the reticle based on current health
		local health = Object.Get_Hull()
		if health > 0.66 then
			Scene.ReticleQuad.Set_Tint(COLOR_HEALTH_GOOD.R, COLOR_HEALTH_GOOD.G, COLOR_HEALTH_GOOD.B, COLOR_HEALTH_GOOD.A)
		elseif health > 0.33 then
			Scene.ReticleQuad.Set_Tint(COLOR_HEALTH_MEDIUM.R, COLOR_HEALTH_MEDIUM.G, COLOR_HEALTH_MEDIUM.B, COLOR_HEALTH_MEDIUM.A)
		else
			Scene.ReticleQuad.Set_Tint(COLOR_HEALTH_LOW.R, COLOR_HEALTH_LOW.G, COLOR_HEALTH_LOW.B, COLOR_HEALTH_LOW.A)
		end
		
		LetterBoxModeOn = false
		this.Register_Event_Handler("Update_LetterBox_Mode_State", nil, On_Update_LetterBox_Mode_State)
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Update_LetterBox_Mode_State
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Update_LetterBox_Mode_State(event, source, on_off)
	LetterBoxModeOn = on_off
	this.Set_Hidden(on_off)
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Init
-- NOTE: This On_Init is bound to the Function Call for ComponentInitialized which in turn is associated to the Initial
-- state of the scene.  By doing it this way we only initialize the scene once (upon creation) and NOT every time it gets
-- active (which would happen if we attached the On_Init to the On_Enter call for the scene on its active state).
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Init()

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
	
	SelectedHPBuildableType = nil
	SocketContent = nil
	HighestLevelHPParent = Object.Get_Highest_Level_Hard_Point_Parent()

	if TestValid(Object) then
		if Scene ~= nil then
			Scene.Register_Event_Handler("Mouse_Right_Down", Scene.ReticleQuad, On_Reticle_Right_Clicked)			
			Scene.Register_Event_Handler("Mouse_Left_Down", Scene.ReticleQuad, On_Reticle_Left_Clicked)			
		end
	end
end


--[[		RETICLE RELATED FUNCTIONS 		]]--

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Reticle_Right_Clicked
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Reticle_Right_Clicked(event, source)
	if Object.Get_Owner().Is_Enemy(Find_Player("local")) then
		GUI_Attack_Target_Object_With_Selected_Objects(Object);
	end	
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- Maria 08.16.2006
-- Single left click on an walker hard point selects the walker. 
-- We have clicked on a hard point.  If we are the local player, we must select the parent object.
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Reticle_Left_Clicked(event, source)
	if Object.Get_Owner() == Find_Player("local") then
		Hard_Point_Left_Clicked( {Object} )
	end
end

-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_On
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_On(event, source)
	
	Start_Flash(Scene.ReticleQuad)
	
	if not Object.Has_Behavior(BEHAVIOR_HARD_POINT) then 
		return
	end
	
	if Object.Has_Behavior(BEHAVIOR_TACTICAL_SELL) then 
		-- we want to display its tooltip info!
		local tooltip_data = {'object', {Object}}
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Display_Tooltip", nil, {tooltip_data})
	end
end


-- -------------------------------------------------------------------------------------------------------------------------------------
-- On_Mouse_Off
-- -------------------------------------------------------------------------------------------------------------------------------------
function On_Mouse_Off(event, source)
	Stop_Flash(Scene.ReticleQuad)
	
	if not Object.Has_Behavior(BEHAVIOR_HARD_POINT) then 
		return
	end
	
	if Object.Has_Behavior(BEHAVIOR_TACTICAL_SELL) then 
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, {})
	end
end