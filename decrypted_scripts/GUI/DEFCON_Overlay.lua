if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[9] = true
LuaGlobalCommandLinks[129] = true
LuaGlobalCommandLinks[128] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/DEFCON_Overlay.lua#8 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/DEFCON_Overlay.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGDebug")
require("PGCrontab")
require("PGCommands")


-------------------------------------------------------------------------------
-- Initializes those elements which are unrelated to the 
-- LAN / Internet distinction.
-------------------------------------------------------------------------------
function GUI_Init()

	PGCrontab_Init()

	-- Constants
	
	-- Variables
	DataModel = {}
	DataModel.DEFCONLevel = 5
	DataModel.DEFCONCountdown = 0
	
	Quad = this.Group.BckQuad
	DEFCONLevelToQuadColorMap = {}
	DEFCONLevelToQuadColorMap[5] = {R = 0.0,   		 G = 128.0/255.0, B = 0.0} 
	DEFCONLevelToQuadColorMap[4] = {R = 0.0,    	G = 112.0/255.0,  B = 166.0/255.0} 
	DEFCONLevelToQuadColorMap[3] = {R = 198.0/255.0, G = 198.0/255.0, B = 0.0} 
	DEFCONLevelToQuadColorMap[2] = {R = 1.0, 		G = 128.0/255.0, B = 0.0} 
	DEFCONLevelToQuadColorMap[1] = {R = 1.0, 		G = 0.0,    		B = 0.0} 

	DEFCON_Overlay.Group.FlashQuad.Set_Hidden(true)
	
	-- Event handlers	
	Refresh_UI()

end


-- --------------------------------------------------------------------------------------------------------------------
-- E V E N T S 
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function On_Update()
	PGCrontab_Update()
end


-- --------------------------------------------------------------------------------------------------------------------
-- V I E W   F U N C T I O N S
-- --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Refresh_UI()

	local level = DataModel.DEFCONLevel 
	local next_level = level - 1
	local countdown = DataModel.DEFCONCountdown 

	local wstr_defcon_level = Get_Game_Text("TEXT_DEFCON_LEVEL")
	Replace_Token(wstr_defcon_level, Get_Localized_Formatted_Number(level), 0)
	DEFCON_Overlay.Group.Text_Current_Level.Set_Text(wstr_defcon_level)
	if (level > 1) then
		local wstr_defcon_countdown = Get_Game_Text("TEXT_DEFCON_LEVEL_COUNTDOWN")
		Replace_Token(wstr_defcon_countdown, Get_Localized_Formatted_Number(next_level), 0)
		Replace_Token(wstr_defcon_countdown, Get_Localized_Formatted_Number.Get_Time(countdown), 1)
		DEFCON_Overlay.Group.Text_Countdown.Set_Text(wstr_defcon_countdown)
	else
		DEFCON_Overlay.Group.Text_Countdown.Set_Text("")
		DEFCON_Overlay.Group.CountdownFrame.Set_Hidden(true)
		DEFCON_Overlay.Group.FlashQuad.Play_Animation("Flash", true)
	end
end


-- ------------------------------------------------------------------------------------------------------------------
-- M I S C E L L A N E O U S
-- ------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Model(model)

	if (model == nil) then
		return
	end
	
	local register_timer = true
	if (model.DEFCONLevel ~= nil) then
		DataModel.DEFCONLevel = model.DEFCONLevel
		
		if DataModel.DEFCONLevel == 1 then
			-- if we have reached the last DEFCON level we won't need to update the scene any more
			-- so we don't need to register the update timer!.
			register_timer = false
		end
		
		-- Update the color of the back quad based on the current level
		-- Set it here so that it gets set only once.  If we put it in Refresh_UI it will
		-- get set for as long as the countdown lasts.
		if TestValid(Quad) then
			local rgb_table = DEFCONLevelToQuadColorMap[DataModel.DEFCONLevel]
			if rgb_table then
				Quad.Set_Tint(rgb_table.R, rgb_table.G, rgb_table.B, 1.0)
			end
		end
	end
	
	if (model.DEFCONCountdown ~= nil) then
		DataModel.DEFCONCountdown = model.DEFCONCountdown
	end
	
	Refresh_UI()
	
	if register_timer then
		PGCrontab_Schedule(Update_Countdown, 0, 1, DataModel.DEFCONCountdown)
	end	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Get_Model()
	return DataModel
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Update_Countdown()
	DataModel.DEFCONCountdown = DataModel.DEFCONCountdown - 1
	Refresh_UI()
end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
Interface = {}
Interface.Set_Model = Set_Model
Interface.Get_Model = Get_Model

function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Burn_All_Objects = nil
	Cancel_Timer = nil
	Carve_Glyph = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Find_All_Parent_Units = nil
	Get_Last_Tactical_Parent = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Use_Ability_If_Able = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
