-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/GlobeBehavior.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/GlobeBehavior.lua $
--
--    Original Author: Oksana Kubushyna
--
--            $Author: Keith_Brors $
--
--            $Change: 55994 $
--
--          $DateTime: 2006/10/05 15:36:10 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- get these from xml

GlobalFOWMask={}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

	-- get all the global FOW enum
	Register_Global_FOW_Enums()

	-- The following defines what items are available at what level
	GlobalFOWMask[1] = GlobalFOWOwner + GlobalFOWLabel
	GlobalFOWMask[2] = GlobalFOWOwner + GlobalFOWLabel + GlobalFOWCommand
	GlobalFOWMask[3] = GlobalFOWOwner + GlobalFOWLabel + GlobalFOWCommand + GlobalFOWHero + GlobalFOWArmy
	GlobalFOWMask[4] = GlobalFOWOwner + GlobalFOWLabel + GlobalFOWCommand + GlobalFOWHero + GlobalFOWArmy + GlobalFOWInfo

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- First Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_First_Service()
		
	-- Set the fow masks

	local num_items = table.getn(GlobalFOWMask)
	
	for index = 1, num_items do
		local mask = GlobalFOWMask[index]
		GlobalFOW.Set_Global_FOW_By_Level(Object,index,mask)
	end
	
end

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.First_Service = Behavior_First_Service
Register_Behavior(my_behavior)
