-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Novus_Tactical_Command_Bar.lua#25 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Novus_Tactical_Command_Bar.lua $
--
--    Original Author: Chris_Brooks
--
--            $Author: Evan_Pipho $
--
--            $Change: 81652 $
--
--          $DateTime: 2007/08/23 15:31:16 $
--
--          $Revision: #25 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("Tactical_Command_Bar_Common")
require("Novus_Patch_Queue_Manager")


MODE_INVALID = -1
MODE_CONSTRUCTION = 1 -- can make buildings
MODE_SELECTION = 2    -- can control units
Mode = MODE_CONSTRUCTION

-- ---------------------------------------------------------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------------------------------------------------------
function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	Player = Find_Player("local")
	
	if Player == nil then 
		MessageBox("the player is nil")
	else
		Scene.FactionText.Set_Text(Player.Get_Faction_Display_Name())
	end

	CloseHuds = false
	UpdatingSelection = false
	
	-- JLH 01.04.2007
	-- Population of the achievement buff window (only available in multiplayer).
	Scene.Register_Event_Handler("Set_Achievement_Buff_Display_Model", nil, On_Set_Achievement_Buff_Display_Model)

	--We need tab orders before we set up the patch menu
	Init_Tab_Orders()

	-- The Patch Queue Manager takes care of updating the Patch Queue properly, also, it is the interface to the patches menu!.
	-- Do this before the common Init since that can call into the patch menu.
	Init_Patch_Queue_Manager()	

	Init_Tactical_Command_Bar_Common(Scene, Player)
	
	-- Update the scene now!
	On_Update()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Update_Faction_Specific_UI
-- ------------------------------------------------------------------------------------------------------------------
function Update_Faction_Specific_UI()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Process_Build_Queue_Button_Clicked
-- ------------------------------------------------------------------------------------------------------------------
function Process_Build_Queue_Button_Clicked()
	if CommandBarEnabled == false then return end
	Display_Patch_Menu(false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- On_Update
-- ------------------------------------------------------------------------------------------------------------------
function On_Update()

	-- Are there any huds open!?
	local close_huds, credits_changed = Update_Common_Scene()
	
	CloseHuds =  close_huds 
			 or this.Research_Tree.Is_Open()
			 or Update_Patch_Queue_Manager(credits_changed)
	
	-- Handle showing the novus patch menu 
	Update_Patch_Queue_Manager(credits_changed)
end

-- ------------------------------------------------------------------------------------------------------------------
-- On_Research_Tree_Open
-- ------------------------------------------------------------------------------------------------------------------
function On_Research_Tree_Open()
	-- if the patch menu is up, close it
	Display_Patch_Menu(false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Close_All_Specific_Displays
-- ------------------------------------------------------------------------------------------------------------------
function Close_All_Specific_Displays()
	if CommandBarEnabled == false then return end
	Display_Patch_Menu(false)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Maria 08.09.2006
-- Hide_All_Faction_Specific_UI 
-- ------------------------------------------------------------------------------------------------------------------
function Hide_All_Faction_Specific_UI(onoff)
	if CommandBarEnabled == false then return end
	if onoff == true then
		Display_Patch_Menu(false)
	end
end



-- ------------------------------------------------------------------------------------------------------------------
-- Hide_Faction_Specific_Buttons
-- ------------------------------------------------------------------------------------------------------------------
function Hide_Faction_Specific_Buttons()
	if CommandBarEnabled == false then return end
	if UpdatingSelection == false  then 
		-- Hide patches	
		Display_Patch_Menu(false)
	end
end

-- ------------------------------------------------------------------------------------------------------------------
-- Disable_Faction_GUI_For_Replay
-- ------------------------------------------------------------------------------------------------------------------
function Disable_Faction_GUI_For_Replay()

end