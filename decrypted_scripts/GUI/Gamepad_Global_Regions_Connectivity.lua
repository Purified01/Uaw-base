LUA_PREP = true

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
--              File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Gamepad_Global_"Regions_Connectivity.lua
--
--            Author: Maria Teruel
--
--          Date: 2007/12/18
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


function Initialize_Region_Connectivity_Data()

	-- These values match those defined in code in ControllerDirectionType.
	CONTROLLER_DIRECTION_RIGHT 		= 0
	CONTROLLER_DIRECTION_DOWN 		= 2
	CONTROLLER_DIRECTION_LEFT 		= 4
	CONTROLLER_DIRECTION_UP 			= 6
	
	RegionConnectivity = 
	{	
		["REGION1"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region3",
				[CONTROLLER_DIRECTION_DOWN] = "Region18",
				[CONTROLLER_DIRECTION_LEFT] = "Region22",
				[CONTROLLER_DIRECTION_UP] = nil			
			},
		
		["REGION3"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region4",
				[CONTROLLER_DIRECTION_DOWN] = "Region18",
				[CONTROLLER_DIRECTION_LEFT] = "Region1",
				[CONTROLLER_DIRECTION_UP] = nil
			},

		["REGION4"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region7",
				[CONTROLLER_DIRECTION_DOWN] = "Region15",
				[CONTROLLER_DIRECTION_LEFT] = "Region3",
				[CONTROLLER_DIRECTION_UP] = nil
			},	

		["REGION7"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region8",
				[CONTROLLER_DIRECTION_DOWN] = "Region9",
				[CONTROLLER_DIRECTION_LEFT] = "Region4",
				[CONTROLLER_DIRECTION_UP] = nil
			},

		["REGION8"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region11",
				[CONTROLLER_DIRECTION_DOWN] = "Region13",
				[CONTROLLER_DIRECTION_LEFT] = "Region7",			
				[CONTROLLER_DIRECTION_UP] = nil
			},		
			
		["REGION9"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region13",
				[CONTROLLER_DIRECTION_DOWN] = nil,
				[CONTROLLER_DIRECTION_LEFT] = "Region7",
				[CONTROLLER_DIRECTION_UP] = "Region8"
			},	
		
		["REGION11"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region26",
				[CONTROLLER_DIRECTION_DOWN] = "Region13",
				[CONTROLLER_DIRECTION_LEFT] = "Region8",			
				[CONTROLLER_DIRECTION_UP] = nil
			},	
			
		["REGION13"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region34",
				[CONTROLLER_DIRECTION_DOWN] = nil,
				[CONTROLLER_DIRECTION_LEFT] = "Region9",
				[CONTROLLER_DIRECTION_UP] = "Region8"
			},
		
		["REGION15"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region9",
				[CONTROLLER_DIRECTION_DOWN] = "Region17",
				[CONTROLLER_DIRECTION_LEFT] = "Region16",
				[CONTROLLER_DIRECTION_UP] = "Region7"	
			},
		
		["REGION16"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region17",
				[CONTROLLER_DIRECTION_DOWN] = "Region20",
				[CONTROLLER_DIRECTION_LEFT] = "Region18",
				[CONTROLLER_DIRECTION_UP] = "Region4"
			},
		
		["REGION17"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region15",
				[CONTROLLER_DIRECTION_DOWN] = "Region21",
				[CONTROLLER_DIRECTION_LEFT] = "Region20",
				[CONTROLLER_DIRECTION_UP] = "Region15"
			},
			
		["REGION18"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region16",
				[CONTROLLER_DIRECTION_DOWN] = "Region20",
				[CONTROLLER_DIRECTION_LEFT] = "Region34",
				[CONTROLLER_DIRECTION_UP] = "Region1"
			},
		
		["REGION20"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region17",
				[CONTROLLER_DIRECTION_DOWN] = "Region21",
				[CONTROLLER_DIRECTION_LEFT] = "Region31",
				[CONTROLLER_DIRECTION_UP] = "Region16"
			},
			
		["REGION21"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region30",
				[CONTROLLER_DIRECTION_DOWN] = nil,
				[CONTROLLER_DIRECTION_LEFT] = "Region29",
				[CONTROLLER_DIRECTION_UP] = "Region20"
			},
		
		["REGION22"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region1",
				[CONTROLLER_DIRECTION_DOWN] = "Region23",
				[CONTROLLER_DIRECTION_LEFT] = "Region24",
				[CONTROLLER_DIRECTION_UP] = nil
			},
		
		["REGION23"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region22",
				[CONTROLLER_DIRECTION_DOWN] = "Region34",
				[CONTROLLER_DIRECTION_LEFT] = "Region27",
				[CONTROLLER_DIRECTION_UP] = "Region24"
			},
		
		["REGION24"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region22",
				[CONTROLLER_DIRECTION_DOWN] = "Region23",
				[CONTROLLER_DIRECTION_LEFT] = "Region26",
				[CONTROLLER_DIRECTION_UP] = nil
			},
			
		["REGION26"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region24",
				[CONTROLLER_DIRECTION_DOWN] = "Region27",
				[CONTROLLER_DIRECTION_LEFT] = "Region11",
				[CONTROLLER_DIRECTION_UP] = nil
			},
		
		["REGION27"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region23",
				[CONTROLLER_DIRECTION_DOWN] = "Region34",
				[CONTROLLER_DIRECTION_LEFT] = "Region13",
				[CONTROLLER_DIRECTION_UP] = "Region26"
			},
		
		["REGION29"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region21",
				[CONTROLLER_DIRECTION_DOWN] = "Region30",
				[CONTROLLER_DIRECTION_LEFT] = "Region31",
				[CONTROLLER_DIRECTION_UP] = "Region31"
			},
		
		["REGION30"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region29",
				[CONTROLLER_DIRECTION_DOWN] = nil,
				[CONTROLLER_DIRECTION_LEFT] = "Region33",
				[CONTROLLER_DIRECTION_UP] = "Region31"
			},

		["REGION31"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region29",
				[CONTROLLER_DIRECTION_DOWN] = "Region30",
				[CONTROLLER_DIRECTION_LEFT] = "Region33",
				[CONTROLLER_DIRECTION_UP] = "Region33"
			},
			
		["REGION33"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region31",
				[CONTROLLER_DIRECTION_DOWN] = "Region30",
				[CONTROLLER_DIRECTION_LEFT] = "Region35",
				[CONTROLLER_DIRECTION_UP] = "Region35"
			},
			
		["REGION34"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region35",
				[CONTROLLER_DIRECTION_DOWN] = "Region35",
				[CONTROLLER_DIRECTION_LEFT] = "Region13",
				[CONTROLLER_DIRECTION_UP] = "Region27"
			},
			
		["REGION35"] = 
			{
				[CONTROLLER_DIRECTION_RIGHT] = "Region18",
				[CONTROLLER_DIRECTION_DOWN] = "Region33",
				[CONTROLLER_DIRECTION_LEFT] = "Region13",
				[CONTROLLER_DIRECTION_UP] = "Region34"
			},
	}

end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Initialize_Region_Connectivity_Data = nil
	Kill_Unused_Global_Functions = nil
end
