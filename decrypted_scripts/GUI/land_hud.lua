-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/land_hud.lua#9 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/land_hud.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 56145 $
--
--          $DateTime: 2006/10/10 16:42:59 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.

IsInit = false

function On_Init()

	-- Variable initialization.  This needs to be done within the body of a function to avoid problems when this script is pooled
	IsInit = false

	land_hud.Register_Event_Handler("Mission_Text_User_Event", nil, Mission_Text_User_Event)
	land_hud.MissionText.Set_Hidden(true)
	land_hud.Set_Hidden(true)
	
end

function Mission_Text_User_Event( event_name, source, bool_use_gui, header_text, user_message, briefing_text01, briefing_text02, briefing_text03, briefing_text04, status_text, bool_hide_background, bool_victory, bool_defeat)
	
	if bool_use_gui == true then
		land_hud.Set_Hidden(false)
	end
	
	if user_message == nil or user_message == "" then
		land_hud.MissionText.Set_Text("")
		land_hud.MissionText.Set_Hidden(true)
	else
		land_hud.MissionText.Set_Hidden(false)
		land_hud.MissionText.Set_Text(user_message)

	end
	
	if header_text == nil or header_text == "" then
		land_hud.MissionHeader.Set_Text("")
		land_hud.MissionHeader.Set_Hidden(true);
	else
		land_hud.MissionHeader.Set_Hidden(false)
		land_hud.MissionHeader.Set_Text(header_text);
	end
	
	if briefing_text01 == nil or briefing_text01 == "" then
		land_hud.MissionBriefing01.Set_Text("")
		land_hud.MissionBriefing01.Set_Hidden(true);
	else
		land_hud.MissionBriefing01.Set_Hidden(false)
		land_hud.MissionBriefing01.Set_Text(briefing_text01);
	end
	
	if briefing_text02 == nil or briefing_text02 == "" then
		land_hud.MissionBriefing02.Set_Text("")
		land_hud.MissionBriefing02.Set_Hidden(true);
	else
		land_hud.MissionBriefing02.Set_Hidden(false)
		land_hud.MissionBriefing02.Set_Text(briefing_text02);
	end
	
	if briefing_text03 == nil or briefing_text03 == "" then
		land_hud.MissionBriefing03.Set_Text("")
		land_hud.MissionBriefing03.Set_Hidden(true);
	else
		land_hud.MissionBriefing03.Set_Hidden(false)
		land_hud.MissionBriefing03.Set_Text(briefing_text03);
	end
	
	if briefing_text04 == nil or briefing_text04 == "" then
		land_hud.MissionBriefing04.Set_Text("")
		land_hud.MissionBriefing04.Set_Hidden(true);
	else
		land_hud.MissionBriefing04.Set_Hidden(false)
		land_hud.MissionBriefing04.Set_Text(briefing_text04);
	end
	
	if status_text == nil or status_text == "" then
		land_hud.TransmissionStatus.Set_Text("")
		land_hud.TransmissionStatus.Set_Hidden(true);
	else
		land_hud.TransmissionStatus.Set_Hidden(false)
		land_hud.TransmissionStatus.Set_Text(status_text);
	end
	
	if bool_hide_background == true then
		land_hud.Background.Set_Hidden(true)
	else
		land_hud.Background.Set_Hidden(false)
	end
	
	if bool_victory == true then
		land_hud.MissionVictory.Set_Hidden(false)
		land_hud.MissionVictory.Set_Text("Well done, Commander!\nWe are victorious!")
	else
		land_hud.MissionVictory.Set_Hidden(true)
	end
	
	if bool_defeat == true then
		land_hud.MissionDefeat.Set_Hidden(false)
		land_hud.MissionDefeat.Set_Text("You have been defeated...please try again.")
	else
		land_hud.MissionDefeat.Set_Hidden(true)
	end

end


function On_Update()

	if IsInit == false then
		On_Init()
		IsInit = true
	end
	

end


