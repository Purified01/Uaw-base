if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[115] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGAchievementAward.lua#10 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Library/PGAchievementAward.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #10 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
require("PGPlayerProfile")


-------------------------------------------------------------------------------
-- Require file initialization.  Global variables cannot be properly 
-- initialized due to pooling.
-------------------------------------------------------------------------------
function PGAchievementAward_Init()

	-- Disabling for now.  1/8/2007 11:19:42 AM -- BMH
	PGAchievementsEnabled = true
	PGOfflineAchievementDefs_Init()
	PGOnlineAchievementDefs_Init()
	PGPlayerProfile_Init()

	ON_EARNED_ACHIEVEMENT_LIST_DISMISS = "ON_EARNED_ACHIEVEMENT_LIST_DISMISS"

	if (OnlinePlayerInfoModels == nil) then
		OnlinePlayerInfoModels = {}
		OnlinePlayerInfoModels.ClientTable = {}
		OnlinePlayerInfoModels.PlayerDisplayModel = {}
		OnlinePlayerInfoModels.FactionDisplayModel = {}
		OnlinePlayerInfoModels.BuffDisplayModel = {}
		OnlinePlayerInfoModels.BuffLabelModel = {}
	end

	EarnedOfflineAchievements = {}
	EarnedOnlineAchievements = {}

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Set_Online_Player_Info_Models(models)
	OnlinePlayerInfoModels = models
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Achievement_Buff_Display_Model()
	local player_names = {}
	local buff_names = {}
	-- We have to prepare a table of player names AND a table of buff names because we cannot
	-- pass a map as an event argument.
	for player_id, player_name in pairs(OnlinePlayerInfoModels.PlayerDisplayModel) do
		player_name = tostring(player_name) .. " [" .. OnlinePlayerInfoModels.FactionDisplayModel[player_id] .. "]"
		table.insert(player_names, player_name)
		table.insert(buff_names, OnlinePlayerInfoModels.BuffDisplayModel[player_id])
	end
	local model = 
	{
		player_names,
		buff_names
	}
	return model
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_Offline_Achievement(achievement_id, arg1, arg2, arg3)

	if PGAchievementsEnabled ~= true then return end

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("OFFLINE_ACHIEVEMENT_AWARD:  Couldn't get the game scoring script.")
		return
	end

	local achievement = scoring_script.Call_Function("Get_Offline_Achievement_State", achievement_id)
	if (achievement.Achieved) then
		DebugMessage("OFFLINE_ACHIEVEMENT_AWARD:  Achievement '" .. tostring(achievement.Name) .. "' already achieved.  Reporting not achieved...")
		return
	end

	Update_Achievement(achievement, arg1, arg2, arg3)

	if (achievement.Achieved) then
		table.insert(EarnedOfflineAchievements, achievement)
	end

	scoring_script.Call_Function("Update_Offline_Achievement_State", achievement.Id, achievement)

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
--[[ JOE DELETE: Obsolete
function Update_Online_Achievement(player_id, achievement_id, arg1, arg2, arg3)

	local client_models = OnlinePlayerInfoModels.ClientTable

	-- If the player_id variable is nil, then the achievement should be updated for ALL players
	if (player_id == nil) then

		for id, client in pairs(client_models) do

			-- If this client has never played online, we may need to create
			-- an empty table for them.
			if (client.TotalOnlineAchievements == nil) then
				client.TotalOnlineAchievements = {}
				client.TotalOnlineAchievements[achievement_id] = OnlineAchievementMap[achievement_id]
			end

			-- Update the achievement.  If it's already achieved DO NOT TOUCH IT!!
			local achievement = client.TotalOnlineAchievements[achievement_id]
			if (achievement.Achieved == false) then
				Update_Achievement(achievement, arg1, arg2, arg3)
	
				-- Store the earned achievement.
				if (achievement.Achieved) then
					if (EarnedOnlineAchievements[id] == nil) then
						EarnedOnlineAchievements[id] = {}
					end
					table.insert(EarnedOnlineAchievements[id], achievement)
				end
			end

		end 

	else

		-- If this client has never played online, we may need to create
		-- an empty table for them.
		local client = OnlinePlayerInfoModels.ClientTable[player_id]
		if client.TotalOnlineAchievements == nil then
			client.TotalOnlineAchievements = {}
			client.TotalOnlineAchievements[achievement_id] = OnlineAchievementMap[achievement_id]
		end	

		local achievement = OnlinePlayerInfoModels.ClientTable[player_id].TotalOnlineAchievements[achievement_id]
		local achieved_before = achievement.Achieved
		Update_Achievement(achievement, arg1, arg2, arg3)

		-- Store the earned achievement.
		if (achieved_before == false and achievement.Achieved) then
			if (EarnedOnlineAchievements[player_id] == nil) then
				EarnedOnlineAchievements[player_id] = {}
			end
			table.insert(EarnedOnlineAchievements[player_id], achievement)
		end

	end

end--]]


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Persist_Online_Achievements()

	if PGAchievementsEnabled ~= true then return end

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("ONLINE_ACHIEVEMENT_AWARD:  Couldn't get the game scoring script.")
		return
	end

	local client_models = OnlinePlayerInfoModels.ClientTable

	for _, client in pairs(client_models) do
		-- If this client has never played online, we may need to create
		-- an empty table for them.
		if (client.TotalOnlineAchievements == nil) then
			client.TotalOnlineAchievements = {}
		end
		for _, achievement in ipairs(client.TotalOnlineAchievements) do
			scoring_script.Call_Function("Update_Online_Achievement_State", client.name, achievement.Id, achievement)
		end
	end

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Player_Earned_Offline_Achievements()
	return (table.getn(EarnedOfflineAchievements) > 0)
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Show_Earned_Offline_Achievements(scene)
	if (not TestValid(scene.Achievement_Won_List)) then
		local handle = scene.Create_Embedded_Scene("Achievement_Won_List", "Achievement_Won_List")
	else
		scene.Achievement_Won_List.Set_Hidden(false)
	end
	scene.Achievement_Won_List.Set_Offline_Model(EarnedOfflineAchievements)
	return scene.Achievement_Won_List
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Show_Earned_Online_Achievements(scene)
	if (not TestValid(scene.Achievement_Won_List)) then
		local handle = scene.Create_Embedded_Scene("Achievement_Won_List", "Achievement_Won_List")
	else
		scene.Achievement_Won_List.Set_Hidden(false)
	end
	scene.Achievement_Won_List.Set_Online_Model(EarnedOnlineAchievements)
	return scene.Achievement_Won_List
end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Update_Achievement(achievement, arg1, arg2, arg3)

	if (achievement.UpdateType == 1) then
		Do_Update_Increment_Achievement(achievement, arg1) 
	elseif (achievement.UpdateType == 2) then
		Do_Update_Boolean_Achievement(achievement, arg1) 
	end

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Do_Update_Increment_Achievement(achievement, inc_amt)

	achievement.IncAmtComplete = achievement.IncAmtComplete + inc_amt
	achievement.PercentageComplete = Calculate_Percentage_Complete(achievement)
	if (achievement.IncAmtComplete >= achievement.IncAmtRequired) then
		achievement.IncAmtComplete = achievement.IncAmtRequired
		achievement.PercentageComplete = 100
		achievement.Achieved = true
	end

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Do_Update_Boolean_Achievement(achievement, value)

	achievement.Achieved = value
	if (achievement.Achieved) then
		achievement.PercentageComplete = 100
	else
		achievement.PercentageComplete = 0
	end
	if (achievement.PercentageComplete >= 100) then
		achievement.PercentageComplete = 100
		achievement.Achieved = true
	end

end


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Calculate_Percentage_Complete(achievement)
	local result = (achievement.IncAmtComplete / achievement.IncAmtRequired) * 100
	if (result < 0) then
		result = 0
	elseif (result > 100) then
		result = 100
	end
	return result
end

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
function Get_Player_By_Faction(faction_string)

	for id, client in pairs(OnlinePlayerInfoModels.ClientTable) do
		if (client.faction == faction_string) then
			return id
		end
	end

	return -1

end
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Abs = nil
	BlockOnCommand = nil
	Clamp = nil
	DebugBreak = nil
	DebugPrintTable = nil
	DesignerMessage = nil
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Achievement_Buff_Display_Model = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Get_Player_By_Faction = nil
	Is_Player_Of_Faction = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGAchievementAward_Init = nil
	Persist_Online_Achievements = nil
	Player_Earned_Offline_Achievements = nil
	Remove_Invalid_Objects = nil
	Set_Local_User_Applied_Medals = nil
	Set_Online_Player_Info_Models = nil
	Show_Earned_Offline_Achievements = nil
	Show_Earned_Online_Achievements = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Offline_Achievement = nil
	Validate_Achievement_Definition = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end
