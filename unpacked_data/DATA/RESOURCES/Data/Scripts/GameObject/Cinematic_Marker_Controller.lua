-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/Cinematic_Marker_Controller.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/Cinematic_Marker_Controller.lua $
--
--    Original Author: Dan Etter
--
--            $Author: Dan_Etter $
--
--            $Change: 78761 $
--
--          $DateTime: 2007/07/28 13:55:53 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

--When player units move near this object its spawn behavior becomes enabled

function Definitions()
	--obj_type = trigger_obj.Get_Type() DO NOT DO THIS
	Define_State("State_Init", State_Init);
	
	cinematic_offset = 1
end

function State_Init(message)
	if message == OnEnter then		
		novus = Find_Player("Novus")
		Change_Local_Faction("Novus")
		novus.Give_Money(100000)
		Create_Thread("Sleepy_Time")
	end
end

function Sleepy_Time()
	
	Sleep(20)
	Lock_Controls(1)
	
	if cinematic_offset == 0 then
		constructor_00 = Find_Hint("NOVUS_CONSTRUCTOR","constructor00")		
		tower_loc = Find_Hint("MARKER_GENERIC","towerloc")
		Register_Prox(tower_loc, Prox_Move_Constructor, 50, novus)
		Novus_Build_Structure(constructor_00, "Novus_Signal_Tower", tower_loc.Get_Position())
	elseif cinematic_offset == 1 then
		facility_0 = Find_Hint("NOVUS_ROBOTIC_ASSEMBLY","facility0")
		facility_1 = Find_Hint("NOVUS_ROBOTIC_ASSEMBLY","facility1")
		
		Tactical_Enabler_Begin_Production(facility_0, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_0, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_0, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		
		Sleep(2)
		
		Tactical_Enabler_Begin_Production(facility_1, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_1, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		Tactical_Enabler_Begin_Production(facility_1, Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"), 1, novus)
		
		Sleep(30)
		
		Lock_Controls(0)
	end
end

function Novus_Build_Structure(constructor, structure_type_name, position)

	local beacon_type = Find_Object_Type(structure_type_name).Get_Type_Value("Tactical_Buildable_Beacon_Type")
	local beacon = Create_Generic_Object(beacon_type, position, constructor.Get_Owner())
	constructor.Activate_Ability("Novus_Tactical_Build_Structure_Ability", true, beacon)

end

function Prox_Move_Constructor(prox_obj, trigger_obj)
	obj_type = trigger_obj.Get_Type()
	--MessageBox("Prox_Tripped by: %s", tostring(trigger_obj))
	if obj_type == Find_Object_Type("NOVUS_SIGNAL_TOWER")	then	
		prox_obj.Cancel_Event_Object_In_Range(Prox_Move_Constructor)
		Create_Thread("Flow_Constructor")
	end
end


function Flow_Constructor()
	Sleep(1)
	move_loc = Find_First_Object("Marker_Cinematic_Lua_Script")
	Full_Speed_Move(constructor_00, move_loc.Get_Position())
	Sleep(5)
	Lock_Controls(0)
end