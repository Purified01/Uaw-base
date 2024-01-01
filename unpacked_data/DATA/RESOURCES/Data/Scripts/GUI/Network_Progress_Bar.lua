-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Network_Progress_Bar.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Network_Progress_Bar.lua $
--
--    Original Author: Joe Howes
--
--            $Author: James_Yarrow $
--
--            $Change: 85546 $
--
--          $DateTime: 2007/10/04 18:29:28 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")
require("PGNetwork")
require("PGColors")


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N I T I A L I Z A T I O N
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function On_Init()

	DebugMessage("Progress Bar Initialized!!!")

	ComponentShowing = true
	Progressing = false

	CurrentProgress = 0.0
	Register_Net_Commands()
	Timer = Net.Get_Time()

	Network_Progress_Bar.Set_Bounds(0, 0, 1, 1)
	Network_Progress_Bar.Progress_Bar.Set_Filled(CurrentProgress)

	-- Event handlers
	Network_Progress_Bar.Register_Event_Handler("Update_Network_Progress", nil, Update_Network_Progress)
	Network_Progress_Bar.Register_Event_Handler("Update_Network_Progress_Message", nil, Update_Network_Progress_Message)

	-- TO RAISE THE EVENTS....
	--Raise_Event_Immediate_All_Scenes("Update_Network_Progress", {})
	--Raise_Event_Immediate_All_Scenes("Update_Network_Progress_Message", {})

end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- E X T E R N A L   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Update_Network_Progress()
	if (ComponentShowing == false) then
		return
	end
	CurrentProgress = CurrentProgress + 0.1
	if (CurrentProgress > 1.0) then
		CurrentProgress = 0.0
	end
	Network_Progress_Bar.Progress_Bar.Set_Filled(CurrentProgress)
end

function Update_Network_Progress_Message(arg1, arg2)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   E V E N T   C A L L B A C K S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function On_Update()

	if (ComponentShowing == false) then
		return
	end

	if (Progressing == false) then
		return
	end

	local tmp = Net.Get_Time()
	if ((tmp - Timer) > 1.0) then
		Timer = tmp
		Update_Network_Progress()
	end

end

function On_Component_Shown()
	CurrentProgress = 0.0
	Timer = Net.Get_Time()
	ComponentShowing = true
end

function On_Component_Hidden()
	Stop()
	ComponentShowing = false
end

function On_Cancel_Clicked()
	this.Get_Containing_Scene().Raise_Event_Immediate("Network_Progress_Bar_Cancelled", nil, {})
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   D I S P L A Y   F U N C T I O N S
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Start()
	CurrentProgress = 0.0
	Progressing = true
	this.Start_Modal()
	
	--Default is to show the cancel button, so make sure it's
	--back on in the case of a previous call to hide.
	this.Button_Cancel.Set_Hidden(false)	
end

function Stop()
	Progressing = false
	CurrentProgress = 0.0
	this.End_Modal()
end

function Set_Message(message)
	Network_Progress_Bar.Text_Message.Set_Text(message)
end

function Hide_Cancel_Button()
	this.Button_Cancel.Set_Hidden(true)
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G U I   R E A D   F U N C T I O N S 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- G E N E R I C   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- L A N   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I N T E R N E T   N E T W O R K I N G
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------
function Is_Busy()
	return Progressing
end


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- I N T E R F A C E
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
Interface = {}
Interface.Start = Start
Interface.Stop = Stop
Interface.Set_Message = Set_Message
Interface.Is_Busy = Is_Busy
Interface.Hide_Cancel_Button = Hide_Cancel_Button
