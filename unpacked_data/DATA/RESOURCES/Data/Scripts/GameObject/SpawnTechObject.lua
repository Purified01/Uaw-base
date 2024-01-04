-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SpawnTechObject.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/SpawnTechObject.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 39964 $
--
--          $DateTime: 2006/03/24 21:45:18 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBehaviors")

local my_behavior = {
	Name = _REQUIREDNAME
}

local function Behavior_Init()
end

local function Behavior_Service()

end

local function Behavior_Health_At_Zero()
	local tlevel = 1

	local ttable = DROP_ITEM_LIST[tlevel]
	local tsize = table.getn(ttable)
	local drop_item = ttable[GameRandom(1, tsize)]
	
	Create_Generic_Object(drop_item, Object, Object.Get_Owner())
end


-- This line must be at the bottom of the file.
--my_behavior.Init = Behavior_Init
--my_behavior.Service = Behavior_Service
my_behavior.Health_At_Zero = Behavior_Health_At_Zero
Register_Behavior(my_behavior)
