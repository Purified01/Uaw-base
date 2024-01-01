-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGLogging.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGLogging.lua $
--
--    Original Author: Andre Arsenault
--
--            $Author: Andre_Arsenault $
--
--            $Change: 61352 $
--
--          $DateTime: 2007/01/23 18:35:25 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

-- PGLogging provides some convenient functions for printing to logfiles. It allows
-- each script to define its own logfile, for ease of viewing while running live
-- (with the aid of a 'tail' app) and debugging after the fact.


----------------------- Global Variables -----------------------

-- By default, calling the 'log' function will dump its text to AILog.txt
-- If you want to use a different logfile in your script, just assign a new
-- value to this global in your script's Definitions() function.
LOGFILE_NAME = "DefaultLog.txt"


-- To suppress any output from calling the 'log' function, just set this
-- global to false.
DEBUGGING = true



----------------------- Library Functions -----------------------

-- log - Custom logging function for this script.
function log (...)
	if not DEBUGGING then return end
	_CustomScriptMessage(LOGFILE_NAME, string.format(...))
end

-- show_table - Utility function for displaying the contents of a table
-- but using the custom 'log' function for the output.
-- ex: table.foreach(my_table, show_table)
function show_table (k, v)
	log( tostring(k) .. " " .. tostring(v) )
end

