-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGDebug.lua#8 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGDebug.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 67089 $
--
--          $DateTime: 2007/04/03 20:40:58 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////


function DebugEventAlert(event, params)
	message = tostring(Script) .. ": handled event " .. tostring(event)
	
	function AppendParameter(ival, parameter)
		message = message .. "\nParameter " .. tostring(ival) .. ": " .. tostring(parameter)
	end
	
	table.foreachi(params, AppendParameter)
	
	MessageBox(message)
end

function MessageBox(...)
	_MessagePopup(string.format(...))
end

function ScriptMessage(...)
	_ScriptMessage(string.format(...))
end

function SyncMessage(...)
	_SyncMessage(DumpCallStack())
	_SyncMessage(string.format(...))
end

function SyncMessageNoStack(...)
	_SyncMessage(string.format(...))
end

function DesignerMessage(...)
	_CustomScriptMessage("DesignerLog.txt", string.format(...))
end

function DebugMessage(...)
	_ScriptMessage(string.format(...))
end

function OutputDebug(...)
	_OuputDebug(string.format(...))
end

function ScriptError(...)
	outstr = string.format(...)
	_OuputDebug(outstr .. "\n")
	_ScriptMessage(outstr)
	outstr = DumpCallStack()
	_OuputDebug(outstr .. "\n")
	_ScriptMessage(outstr)
	ScriptExit()
end

function DebugPrintTable(unit_table)
	DebugMessage("%s -- unit table contents:", tostring(Script))
	for key, obj in pairs(unit_table) do
		DebugMessage("%s -- \t\t** unit:%s", tostring(Script), tostring(obj))
	end
end

-- Dump a table out to a string
function TableToString(unit_table, indent)
	if not indent then indent = 0 end
	
	local out = ""
	for key, obj in pairs(unit_table) do
		-- Indent
		for i = 1,indent do
			out = out .. "  "
		end
		
		if type(obj) == "table" then 
			out = out .. tostring(key) .. ":\n"
			out = out .. TableToString(obj, indent+1)
		else
			out = out .. tostring(key) .. " = " .. tostring(obj) .. "\n"
		end
	end
	return out
end

function DebugBreak()
	_DebugBreak()
end

