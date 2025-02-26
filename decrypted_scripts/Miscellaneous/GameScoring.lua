if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[75] = true
LuaGlobalCommandLinks[114] = true
LuaGlobalCommandLinks[98] = true
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[52] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/GameScoring.lua#25 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/Miscellaneous/GameScoring.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Brian_Hayes $
--
--            $Change: 92565 $
--
--          $DateTime: 2008/02/05 18:21:36 $
--
--          $Revision: #25 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgcommands")
require("PGAchievementsCommon")
require("PGOfflineAchievementDefs")
require("PGOnlineAchievementDefs")
require("PGGlobalConquestDefs")

-- Don't pool...
ScriptPoolCount = 0
ScriptShouldCRC = true;

--
-- Base_Definitions -- sets up the base variable for this script.
--
-- @since 3/15/2005 3:55:03 PM -- BMH
-- 
function Base_Definitions()
	GameScoringMessage("%s -- In Base_Definitions", tostring(Script))

	Common_Base_Definitions()

	ServiceRate = 10
	
	frag_index = 1
	death_index = 2
	GameStartTime = 0
	ResultsTable = nil
	GCProps = {}
	Script.Set_Async_Data("GameOver", true)
	
	CampaignGame = false
	
	Reset_Stats()

	if Definitions then
		Definitions()
	end
	
	Reset_Player_Info_Table()

	-- Achievements
	PGAchievementsCommon_Init()
	--PGOfflineAchievementDefs_Init()
	PGOnlineAchievementDefs_Init()

	-- Global Conquest
	PGGlobalConquestDefs_Init()
end

--
-- main script function.  Does event pumps and servicing.
--
-- @since 3/15/2005 3:55:03 PM -- BMH
-- 
function main()
	DebugMessage("GameScoring -- In main.")
	
	if GameService then
		while 1 do
			GameService()
			PumpEvents()
		end
	end
	
	ScriptExit()
end


--
-- Reset the Tactical mode game stats.
--
-- @since 3/15/2005 3:56:43 PM -- BMH
-- 
function Reset_Tactical_Stats()
	GameScoringMessage("GameScoring -- Resetting tactical stats.")
	-- [frag|death][playerid][object_type][build_count, credits_spent, combat_power]
	TacticalKillStatsTable = {[frag_index] = {}, [death_index] = {}}
	TacticalTeamKillStatsTable = {[frag_index] = {}, [death_index] = {}}
	
	-- [playerid][regionname][object_type][build_count, credits_spent, combat_power]
	TacticalBuildStatsTable = {}
	
	-- a dirty hack to reset tactical script registry values
	ResetTacticalRegistry()
end


function GameScoringMessage(...)
	_ScriptMessage(string.format(...))
	_OuputDebug(string.format(...) .. "\n")
end


--
-- Reset all the stats and player lists.
--
-- @since 3/15/2005 3:56:43 PM -- BMH
-- 
function Reset_Stats()
	GameScoringMessage("GameScoring -- Resetting stats.")
	
	Reset_Tactical_Stats()
	-- [frag|death][playerid][object_type][build_count, credits_spent, combat_power]
	StrategicKillStatsTable = {[frag_index] = {}, [death_index] = {}}

	-- [playerid][regionname][object_type][build_count, credits_spent, combat_power]
	StrategicBuildStatsTable = {}

	-- [playerid][object_type][neutralized_count]
	StrategicNeutralizedTable = {}

	-- [playerid][region][sacked_count, lost_count]
	StrategicConquestTable = {}
	
	PlayerTable = {}
	PlayerQuitTable = {}
	PlayerEliminatedTable = {}
	PlayersEliminated = 0
end


function ResetTacticalRegistry()
	DebugMessage("Resetting Allow_AI_Controlled_Fog_Reveal to 1 (allowed)")
	GlobalValue.Set("Allow_AI_Controlled_Fog_Reveal", 1)
end


--
-- Update our GameStats table with build stats
--
-- @param stat_table    stat table to update
-- @param region        region where the object was produced
-- @param object_type   the object type that was just produced
-- @since 3/18/2005 3:48:32 PM -- BMH
-- 
function Update_Build_Stats_Table(stat_table, region, object_type, owner, build_cost)

	Update_Player_Table(owner)

	if region then
		region_type = region.Get_Type()
		region_name = region_type.Get_Name()
	else 
		region_type = 1
		region_name = "Unknown"
	end
	
	combat_power = object_type.Get_Combat_Rating()
	score_value = object_type.Get_Score_Cost_Credits()
	owner_id = owner.Get_ID()

	GameScoringMessage("GameScoring -- %d produced %s at %s.", owner_id, object_type.Get_Name(), region_name)
	
	player_entry = stat_table[owner_id]
	if player_entry == nil then player_entry = {} end
	
	region_entry = player_entry[region_type]
	if region_entry == nil then region_entry = {} end

	type_entry = region_entry[object_type]
	if type_entry == nil then 
		type_entry = {build_count = 1, combat_power = combat_power, build_cost = build_cost, score_value = score_value}
	else
		type_entry.build_count = type_entry.build_count + 1
		type_entry.combat_power = type_entry.combat_power + combat_power
		type_entry.build_cost = type_entry.build_cost + build_cost
		type_entry.score_value = type_entry.score_value + score_value
	end
	
	region_entry[object_type] = type_entry
	player_entry[region_type] = region_entry
	stat_table[owner_id] = player_entry

end


--
-- Print out the current build statistics for all the players.
--
-- @param stat_table    stats table to display.
-- @since 3/21/2005 10:34:07 AM -- BMH
-- 
function Print_Build_Stats_Table(stat_table)

	GameScoringMessage("GameScoring -- Build Stats dump.")
	
	totals_table = {}
	
	for owner_id, player_entry in pairs(stat_table) do
		build_count = 0
		cost_count = 0
		power_count = 0
		score_count = 0

		GameScoringMessage("\tPlayer %d:", owner_id)
		for region_type, region_entry in pairs(player_entry) do
			if region_type == 1 then
				GameScoringMessage("\t\t%20s:", "Tactical")
			else
				GameScoringMessage("\t\t%20s:", region_type.Get_Name())
			end
			for object_type, type_entry in pairs(region_entry) do
				GameScoringMessage("\t\t%40s: %d : %d : $%d : %d", object_type.Get_Name(), type_entry.build_count, type_entry.combat_power, type_entry.build_cost, type_entry.score_value)
				build_count = build_count + type_entry.build_count
				cost_count = cost_count + type_entry.build_cost
				power_count = power_count + type_entry.combat_power
				score_count = score_count + type_entry.score_value
			end
		end
		
		GameScoringMessage("\tTotal Builds: %d : %d : $%d : %d", build_count, power_count, cost_count, score_count)
		totals_table[owner_id] = {build_count = build_count, cost_count = cost_count, power_count = power_count, score_count = score_count}
	end
end


--
-- Print out the current statistics for all the players.
--
-- @param stat_table    stats table to display.
-- @since 3/15/2005 5:55:55 PM -- BMH
-- 
function Print_Stat_Table(stat_table)

	frag_table = {}

	GameScoringMessage("Frags:")
	for k,v in pairs(stat_table[frag_index]) do

		tkills = 0
		tpower = 0
		tscore = 0
		
		GameScoringMessage("\tPlayer %d:", PlayerTable[k].Get_ID())
		for kk,vv in pairs(v) do
			GameScoringMessage("\t%40s: %d : %d : %d", kk.Get_Name(), vv.kills, vv.combat_power, vv.score_value)
			tkills = tkills + vv.kills
			tpower = tpower + vv.combat_power
			tscore = tscore + vv.score_value
		end
		
		GameScoringMessage("\tTotal Frags: %d : %d : %d", tkills, tpower, tscore)
		frag_table[k] = {kills = tkills, combat_power = tpower, score_value = tscore}
	end
	
	death_table = {}
	
	GameScoringMessage("Deaths:")
	for k,v in pairs(stat_table[death_index]) do
	
		tkills = 0
		tpower = 0
		tscore = 0
		
		GameScoringMessage("\tPlayer %d:", PlayerTable[k].Get_ID())
		for kk,vv in pairs(v) do
			GameScoringMessage("\t%40s: %d : %d : %d", kk.Get_Name(), vv.kills, vv.combat_power, vv.score_value)
			tkills = tkills + vv.kills
			tpower = tpower + vv.combat_power
			tscore = tscore + vv.score_value
		end
		
		GameScoringMessage("\tTotal Deaths: %d : %d : %d", tkills, tpower, tscore)
		death_table[k] = {kills = tkills, combat_power = tpower, score_value = tscore}
	end

	for k,player in pairs(PlayerTable) do
		ft = frag_table[k]
		dt = death_table[k]
		if ft == nil or ft.combat_power == 0 then
			GameScoringMessage("\tPlayer %d, Weighted Kill Ratio: 0.0", player.Get_ID())
		elseif dt == nil or dt.combat_power == 0 then
			GameScoringMessage("\tPlayer %d, Weighted Kill Ratio: %d", player.Get_ID(), ft.combat_power)
		else
			GameScoringMessage("\tPlayer %d, Weighted Kill Ratio: %f", player.Get_ID(), ft.combat_power / dt.combat_power)
		end
	end
end


--
-- Script service function.  Just prints out the current stats.
--
-- @since 3/15/2005 3:56:43 PM -- BMH
-- 
function GameService()

	GameScoringMessage("GameScoring -- Tactical Stats dump.")
	Print_Stat_Table(TacticalKillStatsTable)
	GameScoringMessage("GameScoring -- Strategic Stats dump.")
	Print_Stat_Table(StrategicKillStatsTable)

	Print_Build_Stats_Table(StrategicBuildStatsTable)
	Print_Build_Stats_Table(TacticalBuildStatsTable)
end

--
-- Updates the table of players for the current game.
--
-- @param player    player object to add to our table of players
-- @since 3/15/2005 3:56:43 PM -- BMH
-- 
function Update_Player_Table(player)

	if player == nil then return end
	
	ent = PlayerTable[player.Get_ID()]
	if ent == nil then
		PlayerTable[player.Get_ID()] = player
	end
	ent = nil
end


--
-- Update our GameStats table with victim, killer info.
--
-- @param stat_table    stat table to update
-- @param object        the object that was destroyed
-- @param killer        the player that killed this object
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Update_Kill_Stats_Table(stat_table, object, killer)

	if TestValid(object) == false or TestValid(object.Get_Owner()) == false or TestValid(killer) == false  then
		return
	end
	
	Update_Player_Table(killer)
	Update_Player_Table(object.Get_Owner())

	object_type = object.Get_Game_Scoring_Type()
	score_value = object.Get_Game_Scoring_Type().Get_Score_Cost_Credits()
	combat_power = object.Get_Game_Scoring_Type().Get_Combat_Rating()
	build_cost = object.Get_Game_Scoring_Type().Get_Build_Cost()
	killer_id = killer.Get_ID()
	owner_id = object.Get_Owner().Get_ID()

	-- Make sure the killer and owner are valid players
	if not Is_Valid_Player(object.Get_Owner()) or not Is_Valid_Player(killer) then return end
	

	GameScoringMessage("GameScoring -- Object: %s, was killed by Player: %d.", object_type.Get_Name(), killer_id)
	
	-- Update frags
	frag_entry = stat_table[frag_index]
	if frag_entry == nil then frag_entry = {} end

	-- Make sure killer is not the same player as the object
	if not killer.Is_Ally(object.Get_Owner()) then
	
		entry = frag_entry[killer_id]
		if entry == nil then entry = {} end

		pe = entry[object_type]
		if pe == nil then 
			pe = {kills = 1, combat_power = combat_power, build_cost = build_cost, score_value = score_value}
		else
			pe.kills = pe.kills + 1
			pe.combat_power = pe.combat_power + combat_power
			pe.build_cost = pe.build_cost + build_cost
			pe.score_value = pe.score_value + score_value
		end
	
		entry[object_type] = pe
		frag_entry[killer_id] = entry
		stat_table[frag_index] = frag_entry
		
	end

	-- Update deaths
	death_entry = stat_table[death_index]
	if death_entry == nil then death_entry = {} end

	entry = death_entry[owner_id]
	if entry == nil then entry = {} end

	pe = entry[object_type]
	if pe == nil then 
		pe = {kills = 1, combat_power = combat_power, build_cost = build_cost, score_value = score_value}
	else
		pe.kills = pe.kills + 1
		pe.combat_power = pe.combat_power + combat_power
		pe.build_cost = pe.build_cost + build_cost
		pe.score_value = pe.score_value + score_value
	end
	
	entry[object_type] = pe
	death_entry[owner_id] = entry
	stat_table[death_index] = death_entry

end

function Is_Valid_Player(player)
	return TestValid(player) and player.Is_Valid() and (player.Is_AI_Player() or player.Is_Human())
end


----------------------------------------
--
--      E V E N T   H A N D L E R S
--
----------------------------------------


--
-- This event is triggered on a game mode start.
--
-- @param mode_name    name of the new mode (ie: Strategic, Land, Space)
-- @since 3/15/2005 3:58:59 PM -- BMH
-- 
function Game_Mode_Starting_Event(mode_name, is_multiplayer)
	LastModeName = mode_name

	if StringCompare(mode_name, "Strategic") then
		-- Strategic Campaign
		CampaignGame = true
		Reset_Stats()
		GameStartTime = GetCurrentTime.Frame()
	--elseif StringCompare(mode_name, "Land") then
	elseif CampaignGame == false then
		-- Send the client table to the game mode script for processing.
		if (is_multiplayer and ProcessedMultiplayerClientTable == nil) then
			ProcessedMultiplayerClientTable = true
			local client_table = GameScoringManager.Get_Player_Info_Table()
			if (client_table ~= nil) then
				Get_Game_Mode_Script().Call_Function("Set_Multiplayer_Client_Models", client_table)
			end
		end
		-- Skirmish tactical
		Reset_Stats()
		GameStartTime = GetCurrentTime.Frame()
	elseif CampaignGame == true then
		-- Strategic transition to Tactical.
		Reset_Tactical_Stats()
	end
	Script.Set_Async_Data("GameOver", false)
	LastWasCampaignGame = CampaignGame
end

--
-- Notify scoring manager of research completion
--
function Notify_Achievement_System_Of_Research_Completed( player, branch)

	GameScoringManager.Notify_Achievement_System_Of_Research_Completed( player, branch)
	
end

--
-- This event is triggered on a game mode end.
--
-- @param mode_name    name of the old mode (ie: Strategic, Land, Space)
-- @since 3/15/2005 3:58:59 PM -- BMH
-- 
function Game_Mode_Ending_Event(mode_name)
	LastWasCampaignGame = CampaignGame
	if StringCompare(mode_name, "Strategic") then
		CampaignGame = false
	elseif CampaignGame == false then
		Raise_Event_All_Scenes("Multiplayer_Game_Mode_Ending", nil)
	else
		-- Tactical transition to Strategic.
		Script.Set_Async_Data("GameOver", false)
	end
end


--
-- This event is triggered when a player is eliminated.
--
-- @param player		the player that just eliminated
-- @since 8/30/2007 12:00:54 PM -- NSA
-- 
function Player_Eliminated_Event(player)

	Update_Player_Table(player)

	if player == nil then return end
	
	local player_count = 0
	local ctable = GameScoringManager.Get_Player_Info_Table()
	for _, player in pairs(ctable.ClientTable) do
		player_count = player_count + 1
	end

	PlayerEliminatedTable[player.Get_ID()] = player_count - PlayersEliminated
	PlayersEliminated = PlayersEliminated + 1
end

--
-- This event is triggered when a player quits the game.
--
-- @param player		the player that just quit
-- @since 8/25/2005 10:00:54 AM -- BMH
-- 
function Player_Quit_Event(player)

	Update_Player_Table(player)

	if player == nil then return end
	
	PlayerQuitTable[player.Get_ID()] = true
end


--
-- This event is triggered when a unit is destroyed in a tactical game mode.
--
-- @param object        the object that was destroyed
-- @param killer        the player that killed this object
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Tactical_Unit_Destroyed_Event(object, killer)
	Update_Kill_Stats_Table(TacticalKillStatsTable, object, killer)
end


--
-- This event is triggered when a unit is destroyed in the strategic game mode.
--
-- @param object        the object that was destroyed
-- @param killer        the player that killed this object
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Strategic_Unit_Destroyed_Event(object, killer)
	Update_Kill_Stats_Table(StrategicKillStatsTable, object, killer)
	Update_Kill_Stats_Table(TacticalTeamKillStatsTable, object, killer)
end


--
-- This event is triggered when production has begun on an item at a given region
--
-- @param region        the region that will produce this object
-- @param object_type   the object type scheduled for production
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Strategic_Production_Begin_Event(region, object_type)

--Track credits spent
end


--
-- This event is triggered when production has been prematurely canceled
-- on an item at a given region
--
-- @param region        the region that was producing this object
-- @param object_type   the object type that got canceled
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Strategic_Production_Canceled_Event(region, object_type)

--Track credits spent
end


--
-- This event is triggered when production has finished in a tactical mode
--
-- @param object_type   the object type that was just built
-- @param player			the player that built the object.
-- @param location		the location that built the object(could be nil)
-- @since 8/22/2005 6:11:07 PM -- BMH
-- 
function Tactical_Production_End_Event(object_type, player, location)
	Update_Build_Stats_Table(TacticalBuildStatsTable, location, object_type, player, object_type.Get_Tactical_Build_Cost())
end


--
-- This event is triggered when production has finished on an item at a given region
--
-- @param region        the region that produced this object
-- @param object        the object that was just created
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Strategic_Production_End_Event(region, object)

	if object.Get_Type == nil then
		-- object must be a GameObjectTypeWrapper not a GameObjectWrapper if it doesn't 
		-- have a Get_Type function.
		Update_Build_Stats_Table(StrategicBuildStatsTable, region, object, region.Get_Owner(), object.Get_Build_Cost())
	else
		-- object points to the GameObjectWrapper that was just created.
		Update_Build_Stats_Table(StrategicBuildStatsTable, region, object.Get_Game_Scoring_Type(), region.Get_Owner(), object.Get_Game_Scoring_Type().Get_Build_Cost())
	end
end


function fake_get_owner()
	return fake_object_player
end

function fake_get_type()
	return fake_object_type
end

function fake_is_valid()
	return true
end

--
-- This event is triggered when the level of a starbase changes
--
-- @param region        the region where the starbase is located
-- @param old_type      the old starbase type
-- @param new_type      the new starbase type
-- @since 3/15/2005 4:10:19 PM -- BMH
-- 
function Strategic_Starbase_Level_Change(region, old_type, new_type)

	GameScoringMessage("GameScoring -- %s Starbase changed from %s to %s.", region.Get_Type().Get_Name(), tostring(old_type), tostring(new_type))
	
	if old_type == nil then return end
	if new_type ~= nil then return end
	
	fake_object_type = old_type
	fake_object_player = region.Get_Owner()
	fake_object = {}
	fake_object.Get_Owner = fake_get_owner
	fake_object.Get_Type = fake_get_type
	fake_object.Get_Game_Scoring_Type = fake_get_type
	fake_object.Is_Valid = fake_is_valid
	Strategic_Unit_Destroyed_Event(fake_object, region.Get_Final_Blow_Player())
end


--
-- This event is called when a region changes faction in strategic mode
--
-- @param region	      The region object
-- @param newplayer		The new owner player of this region.
-- @param oldplayer		The old owner player of this region.
-- @since 6/20/2005 8:37:53 PM -- BMH
-- 
function Strategic_Region_Faction_Change(region, newplayer, oldplayer)

	-- Update the player table.
	Update_Player_Table(newplayer)
	Update_Player_Table(oldplayer)
	
	local newid = newplayer.Get_ID()
	local oldid = oldplayer.Get_ID()

	GameScoringMessage("GameScoring -- %s changed control from %d to %d.", region.Get_Type().Get_Name(), oldid, newid)

   -- Update the sacked count for the new owner.
	local entry = StrategicConquestTable[newid]
	if entry == nil then entry = {} end

	local pe = entry[region]
	if pe == nil then 
		pe = {sacked_count = 1, lost_count = 0}
	else
		pe.sacked_count = pe.sacked_count + 1
	end
	
	entry[region] = pe
	StrategicConquestTable[newid] = entry
	
   -- Update the lost count for the old owner.
	entry = StrategicConquestTable[oldid]
	if entry == nil then entry = {} end

	pe = entry[region]
	if pe == nil then 
		pe = {sacked_count = 0, lost_count = 1}
	else
		pe.lost_count = pe.lost_count + 1
	end

	entry[region] = pe
	StrategicConquestTable[oldid] = entry
end


--
-- This event is called when a hero is neutralized by another hero in strategic mode
--
-- @param hero_type	The hero that was just neutralized
-- @param killer		The hero that just neutralized the above hero.
-- @since 3/21/2005 1:43:44 PM -- BMH
-- 
function Strategic_Neutralized_Event(hero_type, killer)

	Update_Player_Table(killer.Get_Owner())

	killer_id = killer.Get_Owner().Get_ID()

	entry = StrategicNeutralizedTable[killer_id]
	if entry == nil then entry = {} end

	pe = entry[hero_type]
	if pe == nil then 
		pe = {neutralized = 1}
	else
		pe.neutralized = pe.neutralized + 1
	end
	
	entry[hero_type] = pe
	StrategicNeutralizedTable[killer_id] = entry

end

--
-- TODO: This function updates the table of Live player kill stats.
--
-- @param stat_table		the stat table we should pull stats from
-- @param player			the player who's stats we need to update.
-- @since 3/29/2005 5:14:42 PM -- BMH
-- 
function Update_Live_Kill_Stats(stat_table, build_stats, player)
	Live_Player_Stats = {}
	frag_table = {}
	
	Live_Player_Stats.faction = player.Get_Faction_Name()
end

--
-- This function updates the table of Live player stats.
--
-- @param player		the player who's stats we need to update.
-- @since 3/29/2005 5:14:42 PM -- BMH
-- 
function Update_Live_Player_Stats(player)
	Update_Player_Table(player)

	if LastWasCampaignGame == true then
		GameScoringMessage("Live dumping StrategicKillStatsTable")
		Update_Live_Kill_Stats(StrategicKillStatsTable, StrategicBuildStatsTable, player)
	else
		GameScoringMessage("Live dumping TacticalKillStatsTable")
		Update_Live_Kill_Stats(TacticalKillStatsTable, TacticalBuildStatsTable, player)
	end
	
end

function Get_Current_Winner_By_Score()
	return WinnerID
end

--
-- Function that passes the local client table to the GameScoringManager
-- so that it can be made available to in-game scripts.  This is split
-- out from the Player_Info_Tables because the player info data needs to 
-- be synchronized among clients, whereas the local client info cannot be.
--
-- @since 16/20/2006 3:59 AM -- JLH
-- 
function Set_Local_Client_Table(table)
	GameScoringManager.Set_Local_Client_Table(table)
end

--
-- Function that gets the local client table from the GameScoringManager
-- so that it can be made available to in-game scripts.  This is split
-- out from the Player_Info_Tables because the player info data needs to 
-- be synchronized among clients, whereas the local client info cannot be.
--
-- @since 16/20/2006 3:59 AM -- JLH
-- 
function Get_Local_Client_Table()
	return GameScoringManager.Get_Local_Client_Table()
end

--
-- Return the ClientTable of all clients in the game.
-- @since 1/16/2007 7:40:40 PM -- BMH
-- 
function Get_Player_Info_Table()
	return GameScoringManager.Get_Player_Info_Table()
end

--
-- Reset the player info table.
-- @since 5/28/2007 1:55:51 PM -- BMH
-- 
function Reset_Player_Info_Table()
	local player_info_table = 
	{
		ClientTable = {},
		PlayerDisplayModel = {},
		FactionDisplayModel = {},
		BuffDisplayModel = {},
		BuffLabelModel = {}
	}

	GameScoringManager.Set_Player_Info_Table(player_info_table, false)
end

function Get_Game_Script_Data_Table()
	return GameScoringManager.Get_Game_Script_Data_Table()
end

function Set_Game_Script_Data_Table(table)
	if table then
		GameScoringManager.Set_Game_Script_Data_Table(table)
	end
end

function Update_GFW_Live_Stats()

	local game_script_data = Get_Game_Script_Data_Table()
	if (game_script_data == nil) then
		GameScoringMessage("GameScoring -- Cannot get game script data from code.  Unable to post live end game stats.")
		return 
	end
	if ((game_script_data.GameOptions == nil) or (game_script_data.GameOptions.is_lan == true)) then
		GameScoringMessage("GameScoring -- Not an internet or GC game.  Not posting live end game stats.")
		return 
	end 

	Register_Net_Commands()
	Net.MM_Update_Stats(Get_Battle_End_Results_Table(), false, true)
	
end

function Get_Battle_End_Results_Table()
	return ResultsTable
end

function Battle_End_Results_Rank_Compare(player1_table, player2_table)
	return player1_table.rank < player2_table.rank
end

function Record_End_Game_Stats(winner)

	-- TODO:  Record the current GameFrame number, FrameSynchronizer.Current_Frame_CRC, GameRunningTime

	local winner_common_addr = nil
	GameScoringMessage("GameScoring -- Game has ended.  %s is the winner!!", tostring(winner))
	Script.Set_Async_Data("GameOver", true)
	-- Create the global results table.
	ResultsTable = {}

	-- Oksana: notify achievement system that victory condition has occured.
	GameScoringManager.Notify_Achievement_System_Of_Victory(winner)

	if (Get_Game_Mode() == "Strategic") then
		local player = Find_Player("local")
		local playerID = player.Get_ID()

		if player == winner then
			ResultsTable.winner = true
		end

		ResultsTable.units_destroyed = 0
		ResultsTable.buildings_destroyed = 0
		ResultsTable.heroes_destroyed = 0

		-- [frag|death][playerid][object_type][build_count, credits_spent, combat_power]
		player_frags = StrategicKillStatsTable[frag_index][playerID]
		if player_frags ~= nil then
			for object_type, frag_stats in pairs(player_frags) do
				if object_type.Has_Behavior(99) then
					ResultsTable.buildings_destroyed = ResultsTable.buildings_destroyed + frag_stats.kills
				elseif object_type.Object_Is_Hero() then
					ResultsTable.heroes_destroyed = ResultsTable.heroes_destroyed + frag_stats.kills
				else
					ResultsTable.units_destroyed = ResultsTable.units_destroyed + frag_stats.kills
				end
			end
		end

		if ResultsTable.winner then
			GameScoringMessage("GameScoring -- Player: %d Won Campaign!", player.Get_ID())
		else
			GameScoringMessage("GameScoring -- Player: %d Lost Campaign!", player.Get_ID())
		end
	elseif not CampaignGame then
		-- Grab the client table
		local ctable = GameScoringManager.Get_Player_Info_Table()
		if ctable == nil or ctable.ClientTable == nil then
			GameScoringMessage("GameScoring -- Error: No client table in Record_End_Game_Stats!")
			return
		end
	
		local player_count = 0
		for _, player in pairs(ctable.ClientTable) do
			player_count = player_count + 1
		end

		for _, client in pairs(ctable.ClientTable) do
			local player_results_table = { }
			local player = Find_Player(client.PlayerID)
			player_results_table.live_rank = 0
			if player == winner then
				player_results_table.winner = true
				winner_common_addr = client.common_addr
				player_results_table.live_rank = 1
				player_results_table.rank = 1
			else
				player_results_table.rank = PlayerEliminatedTable[client.PlayerID]

				if player_results_table.rank == nil then
					player_results_table.rank = PlayersEliminated
				elseif PlayersEliminated ~= player_count - 1 then
					player_results_table.rank = player_results_table.rank - (player_count - PlayersEliminated - 1)
				end
			end
			player_results_table.player = player
			player_results_table.faction = player.Get_Faction_Name()
			player_results_table.common_addr = client.common_addr
			player_results_table.game_time = GetCurrentTime.Frame()
			player_results_table.team = client.team
			player_results_table.units_destroyed = 0
			player_results_table.buildings_destroyed = 0
			player_results_table.heroes_destroyed = 0

			-- [frag|death][playerid][object_type][build_count, credits_spent, combat_power]
			player_frags = TacticalKillStatsTable[frag_index][client.PlayerID]
			if player_frags ~= nil then
				for object_type, frag_stats in pairs(player_frags) do
					if object_type.Has_Behavior(99) then
						player_results_table.buildings_destroyed = player_results_table.buildings_destroyed + frag_stats.kills
					elseif object_type.Object_Is_Hero() then
						player_results_table.heroes_destroyed = player_results_table.heroes_destroyed + frag_stats.kills
					else
						player_results_table.units_destroyed = player_results_table.units_destroyed + frag_stats.kills
					end
				end
			end
			GameScoringMessage("GameScoring -- Player: %d, Rank: %d, LiveRank: %d", player_results_table.player.Get_ID(), player_results_table.rank, player_results_table.live_rank)
			table.insert(ResultsTable, player_results_table)
		end

		-- Sort the table based on ranks
		table.sort(ResultsTable, Battle_End_Results_Rank_Compare)

		-- Make sure we have Net commands
		if Net == nil then Register_Net_Commands() end

		-- Global Conquest winner
		if (GCProps ~= nil and GameScoringManager.Is_Global_Conquest_Game()) then
			Register_Net_Commands()
			Net.Set_GC_Props(GCProps, false, true)
		end
		
		-- Update achievement stats
		-- Must be called before Update_GFW_Live_Stats
		Net.Finalize_Multiplayer_Achievement_System()
		
		-- If the game is ranked, update some live stats.
		if (GameScoringManager.Is_Ranked_Game() and (not(GameScoringManager.Is_Global_Conquest_Game()))) then
			Update_GFW_Live_Stats()
		end
		
	end
end

--
-- Send the global conquest properties up for storage.
-- @since 6/20/2007 5:00:00 PM -- JLH
-- 
function Set_GC_Props(player_id, common_addr, region_data)
	GCProps[common_addr] = {}
	GCProps[common_addr].player_id = player_id
	GCProps[common_addr].region_data = region_data
end

function Set_Is_Global_Conquest_Game(value)
	GameScoringManager.Set_Is_Global_Conquest_Game(value)
end

function Set_Is_Ranked_Game(value)
	GameScoringManager.Set_Is_Ranked_Game(value)
end

function Set_Is_Custom_Multiplayer_Game(value)
	GameScoringManager.Set_Is_Custom_Multiplayer_Game(value)
end

function Set_Is_Disconnect_Detected(value)
	GameScoringManager.Set_Is_Disconnect_Detected(value)
end
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
	Dirty_Floor = nil
	Find_All_Parent_Units = nil
	Get_Current_Winner_By_Score = nil
	Get_Default_Global_Conquest_Regions = nil
	Get_Faction_Numeric_Form = nil
	Get_Faction_Numeric_Form_From_Localized = nil
	Get_Faction_String_Form = nil
	Get_Last_Tactical_Parent = nil
	Get_Localized_Faction_Name = nil
	Get_Locally_Applied_Medals = nil
	Max = nil
	Min = nil
	OutputDebug = nil
	PGOfflineAchievementDefs_Init = nil
	PG_Count_Num_Instances_In_Build_Queues = nil
	PG_GC_Create_Clean_Region_Set = nil
	PG_GC_Create_Props_From_Lobby = nil
	PG_GC_Merge_Regions_From_Load = nil
	Process_Tactical_Mission_Over = nil
	Register_Death_Event = nil
	Register_Prox = nil
	Register_Timer = nil
	Remove_Invalid_Objects = nil
	Set_Local_User_Applied_Medals = nil
	Simple_Mod = nil
	Simple_Round = nil
	Sleep = nil
	Sort_Array_Of_Maps = nil
	Strategic_Starbase_Level_Change = nil
	String_Split = nil
	SyncMessage = nil
	SyncMessageNoStack = nil
	TestCommand = nil
	Update_Live_Player_Stats = nil
	Use_Ability_If_Able = nil
	Validate_Achievement_Definition = nil
	Validate_Region_Definitions = nil
	WaitForAnyBlock = nil
	Kill_Unused_Global_Functions = nil
end

