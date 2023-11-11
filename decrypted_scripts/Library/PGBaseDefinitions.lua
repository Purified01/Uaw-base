-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGBaseDefinitions.lua#11 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Library/PGBaseDefinitions.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 76762 $
--
--          $DateTime: 2007/07/14 14:29:38 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")

BAD_WEIGHT = -1000000000000000000.0
BIG_FLOAT = 1000000000000000000.0

function Common_Base_Definitions()
	-- Clear out the thread specific values.
	ThreadValue.Reset()
	
	-- Clear out any thread events.
	GetEvent.Reset()

	TimerTable = {}
	DeathTable = {}
	ProxTable = {}
	AttackedTable = {}
	MovieBlockTable = {}
	TalkingHeadBlockTable = {}
	CurrentEvent = nil
	EventParams = nil
	block = nil
	break_block = false
	YieldCount = 0
	AITarget = nil
	Object = nil
	Target = nil
	FreeStore = nil
	PlayerObject = nil
	LastService = nil
	Budget = nil
	enemy = nil
	taskforce = nil
	tfObj = nil
	stage = nil
	UnitType = nil
	invade_status = nil
	path = nil
	InvasionActive = false
	unit = nil
	SkipHeroMovies = false
	LastService = nil
   DropInSpawnUnitTable = nil

	hide_target = nil
	healer = nil
	xfire_pos = nil
	kite_pos = nil
	friendly = nil

	ScriptShouldDeepSync = nil
	ScriptShouldDeepSyncCalls = nil
	
	block_table = {}
	
	lib_anti_idle_block = nil

	if Init_Objectives then
		Init_Objectives()
	end
	
	if Init_Victory_Condition_Constants then
		Init_Victory_Condition_Constants()
	end
end


-- base constructor
function Base_Definitions()

	Common_Base_Definitions()
	
	if Definitions then
		Definitions()
	end
end

function Evaluator_Clean_Up()
	Target = nil
	PlayerObject = nil

	if Clean_Up then
		Clean_Up()
	end
end
