-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/RadarMap.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/RadarMap.lua $
--
--    Original Author: James Yarrow
--
--            $Author: oksana_kubushyna $
--
--            $Change: 67981 $
--
--          $DateTime: 2007/04/16 11:09:28 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
require("PGCommands")

function On_Init()
	this.Register_Event_Handler("Mouse_On", this, On_Mouse_Enter)
	this.Register_Event_Handler("Mouse_Off", this, On_Mouse_Exit)

	RadarMap.Attach_To_GUI_Component(this.MapQuad)
end

function On_Mouse_Enter(event, source)
	RadarMap.On_Mouse_Enter()
end

function On_Mouse_Exit(event, source)
	RadarMap.On_Mouse_Exit()	
end


Interface={}
Interface.Enable_Radar_Map = Enable_Radar_Map
Interface.Disable_Radar_Map = Disable_Radar_Map
