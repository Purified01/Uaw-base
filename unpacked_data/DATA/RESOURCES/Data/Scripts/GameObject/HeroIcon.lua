-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/HeroIcon.lua#16 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/HeroIcon.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Mike_Lytle $
--
--            $Change: 86619 $
--
--          $DateTime: 2007/10/24 17:32:55 $
--
--          $Revision: #16 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}


-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Init
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()
	LastService = nil
	Priority = 0
	Texture = ""
	HeadModel = ""
	
	if TestValid(Object) then 
		Owner = Object.Get_Owner()
	end

	Script.Set_Async_Data("IS_SCIENTIST", IS_SCIENTIST)
	Script.Set_Async_Data("IS_COMM_OFFICER", IS_COMM_OFFICER)
end


-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Health_At_Zero
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Health_At_Zero()
--	Register_User_Event("Hero_Icon_Delete")
	if (HERO_ICON and (TestValid(Get_Game_Mode_GUI_Scene()))) then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Hero_Icon_Delete", nil, {Object} )
	end
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_First_Service
-- --------------------------------------------------------------------------------------------------------------------
function Hero_Icon_Behavior_First_Service()
	if HERO_ICON then
		if HERO_ICON.PRIORITY then Priority = HERO_ICON.PRIORITY end
		if HERO_ICON.TEXTURE then Texture = HERO_ICON.TEXTURE end
		if HERO_ICON.HEADMODEL then HeadModel = HERO_ICON.HEADMODEL end
		
		if TestValid(Get_Game_Mode_GUI_Scene()) then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Hero_Icon_Create", nil, {Object, Priority, Texture, HeadModel} )
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Switch_Sides
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Switch_Sides()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Hero_Icon_Create", nil, {Object, Priority, Texture, HeadModel} )
end

local function Behavior_Post_Load_Game()
	-- MLL: Make sure that the icon stuff is set correctly.
	Hero_Icon_Behavior_First_Service()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Hero_Icon_Create", nil, {Object, Priority, Texture, HeadModel} )
end

-- --------------------------------------------------------------------------------------------------------------------
-- Behavior_Refresh_After_Mode_Switch
-- --------------------------------------------------------------------------------------------------------------------
local function Behavior_Refresh_After_Mode_Switch()
	-- just call Behavior_First_Service so not to duplicate code, since when coming back from a refresh we basically need to do some re-registration
	Hero_Icon_Behavior_First_Service()
end

function Get_Head_Model()
	if HERO_ICON then
		return HERO_ICON.HEADMODEL
	end
end

function Get_Priority()
	if HERO_ICON then
		return HERO_ICON.PRIORITY
	end
end


-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Hero_Icon_Behavior_First_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero
my_behavior.Delete_Pending = Behavior_Health_At_Zero
my_behavior.Switch_Sides = Behavior_Switch_Sides
my_behavior.Post_Load_Game = Behavior_Post_Load_Game
my_behavior.Refresh_After_Mode_Switch = Behavior_Refresh_After_Mode_Switch
Register_Behavior(my_behavior)
