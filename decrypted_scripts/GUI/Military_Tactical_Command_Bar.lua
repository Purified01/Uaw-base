-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Military_Tactical_Command_Bar.lua#9 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Military_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Maria_Teruel $
--
--            $Change: 79785 $
--
--          $DateTime: 2007/08/03 17:20:08 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Tactical_Command_Bar_Common")

MODE_INVALID = -1
MODE_CONSTRUCTION = 1 -- can make buildings
MODE_SELECTION = 2    -- can control units
Mode = MODE_CONSTRUCTION

-- ---------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Player = Find_Player("Military")
	
	if Player == nil then 
		MessageBox("the player is nil")
	else
		Scene.FactionText.Set_Text(Player.Get_Faction_Display_Name())
	end
	CloseHuds = false

	Init_Tab_Orders()

	Init_Tactical_Command_Bar_Common(Scene, Player)
	
	-- Update the scene now!
	On_Update()
end


function Hide_Faction_Specific_Buttons()
end

function Hide_Research_Tree()
end

function Update_Faction_Specific_UI()
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()
	-- Are there any huds open!?
	CloseHuds = Update_Common_Scene()
end



-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays(event, source)
end



-- ------------------------------------------------------------------------------------------------------------------
-- Maria 08.09.2006
-- Hide_All_Faction_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Faction_Specific_UI(onoff)
end



-- ------------------------------------------------------------------------------------------------------------------
-- On_Scientist_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function On_Scientist_Button_Clicked()
end