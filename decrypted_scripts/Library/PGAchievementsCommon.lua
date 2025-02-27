if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[116] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGAchievementsCommon.lua#11 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGAchievementsCommon.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #11 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGAchievementsCommon_Init()

-- The following 3 lines are required by the lua preprocessor.  1/22/2008 3:14:28 PM -- BMH
--[[

















]]--

end


-------------------------------------------------------------------------------
-- Return a base definition that will fill out all the stuff that has to be
-- in every definition.
-------------------------------------------------------------------------------
function Create_Base_Achievement_Definition(id, faction, is_medal, is_achievement, name, texture, requirements, description, buff_label, backend_key)

	local achievement = {}
	
	achievement.Id = id	
	achievement.FormatVersionMajor = 1
	achievement.FormatVersionMinor = 1
	achievement.IsMedal = is_medal
	achievement.IsAchievement = is_achievement
	achievement.Faction = faction
	achievement.Achieved = false
	-- Medals which are not bound to a live achievement are considered achieved by default.
	if (is_medal and (not is_achievement)) then
		achievement.Achieved = true
	end
	achievement.PercentageComplete = 0

	achievement.Name = name
	achievement.Texture = texture
	achievement.Requirements = requirements
	achievement.BuffDesc = description
	achievement.BuffLabel = buff_label
	achievement.BackendKey = backend_key		-- The key that binds our script achievement to a backend-defined achievement.
												-- (for example an XLive achievement).
	
	return achievement

end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Create_Base_Increment_Achievement_Definition(id, faction, is_medal, is_achievement, completion_target, name, texture, requirements, description, buff_label, backend_key)

	-- The Basics
	local achievement = Create_Base_Achievement_Definition(id, faction, is_medal, is_achievement, name, texture, requirements, description, buff_label, backend_key)
	
	-- The Specifics
	achievement.UpdateType = 1
	achievement.IncAmtComplete = 0
	achievement.IncAmtRequired = completion_target
	
	return achievement

end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Create_Base_Boolean_Achievement_Definition(id, faction, is_medal, is_achievement, name, texture, requirements, description, buff_label, backend_key)

	-- The Basics
	local achievement = Create_Base_Achievement_Definition(id, faction, is_medal, is_achievement, name, texture, requirements, description, buff_label, backend_key)
	
	-- The Specifics
	achievement.UpdateType = 2
	
	return achievement

end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Set_Achievement_Map_Type(map, type)

	for k, v in pairs(map) do
		v.Type = type
	end

end


-------------------------------------------------------------------------------
-- Makes sure that the achievement is formatted as expected by the current 
-- version of the achievement system.
--
-- Return value is true if the definition is up-to-date, false otherwise.
-- 	If false, it should be re-persisted as soon as possible.
-------------------------------------------------------------------------------
function Validate_Achievement_Definition(def)

	-- If the version matches, we know the format is good.
	if ((def.FormatVersionMajor == 1) and
		(def.FormatVersionMinor == 1)) then
		return true
	end


	-- ACHIEVEMENT FORMAT UPDATE CODE GOES HERE.
	DebugMessage("Achievement definition for '" .. tostring(def.Name) .. "' is out of date.  Updating...")

	-- Update v1.0:
	-- Added versioning.
	def.FormatVersionMajor = 1
	def.FormatVersionMinor = 1

	DebugMessage("Achievement '" .. tostring(def.Name) .. "' is now up to date.")
	return false

end


--
-- Function that passes a multiplayer client table to the GameScoringManager
-- so that it can be made available to in-game scripts.
--
-- @since 12/20/2006 3:22 AM -- JLH
-- 
function Set_Player_Info_Table(client_table)
 
      Register_Game_Scoring_Commands()
      --Init_Offline_Achievements()
      PGOnlineAchievementDefs_Init()
      
      local player_info_table = Create_Player_Info_Table(client_table) 
      local unmutable_player_info_table = Create_Player_Info_Table(client_table)
      
      GameScoringManager.Set_Player_Info_Table(player_info_table, false)      -- Sets the table that will be used in game script.
      GameScoringManager.Set_Player_Info_Table(unmutable_player_info_table, true)   -- Sets the table that will be used to init replays.
end

 
function Create_Player_Info_Table(client_table)
     -- Build the buff models
      player_display = {}
      faction_display = {}
      buff_display = {}
      buff_label = {}
 
      -- Here we are building an array whose keys are the player ID and
      -- whose values are the entire list of buff labels from the 
      -- achievements they have chosen.  We won't care if the achievements
      -- are online or offline at this point, since all we are doing is
      -- applying the specified buffs.
      for _, client in pairs(client_table) do
            local display_list = {}
            local label_list = {}
            if (client.applied_medals ~= nil and OnlineAchievementMap ~= nil) then
                  for k, v in pairs(client.applied_medals) do
                        local achievement = OnlineAchievementMap[v]
								if (achievement ~= nil) then
									table.insert(display_list, achievement.BuffDesc)
									table.insert(label_list, achievement.BuffLabel)
								end
                  end
            end
 
            player_display[client.PlayerID] = client.name
            faction_display[client.PlayerID] = client.faction
            buff_display[client.PlayerID] = display_list
            buff_label[client.PlayerID] = label_list
 
      end
      
      local result = 
      {
            ClientTable = client_table,
            PlayerDisplayModel = player_display,
            FactionDisplayModel = faction_display,
            BuffDisplayModel = buff_display,
            BuffLabelModel = buff_label
      }     
      
      return result
 
end



function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	Create_Base_Boolean_Achievement_Definition = nil
	Create_Base_Increment_Achievement_Definition = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGAchievementsCommon_Init = nil
	Remove_Invalid_Objects = nil
	Set_Achievement_Map_Type = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
