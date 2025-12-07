--The comment below is used for saying what parts of the code are cut out smart reaper content:

-- Lobotomized comment

if (LuaGlobalCommandLinks) == nil then
    LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[109] = true
LuaGlobalCommandLinks[18] = true
LuaGlobalCommandLinks[51] = true
LUA_PREP = true

-- $Id: VariantPhaseDelayedActivation.lua
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, LLC
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- /** @file */

require("PGBehaviors")

local my_behavior = {
    Name = _REQUIREDNAME
}

-- Global variables
local Has_Given_Move_Order = false

--------------------------------------------------------------------------------
-- FUNCTION: Behavior_Init
--------------------------------------------------------------------------------
local function Behavior_Init()
    -- Reset the move-order flag on initialization
    Has_Given_Move_Order = false
end

--------------------------------------------------------------------------------
-- FUNCTION: Behavior_Service
--------------------------------------------------------------------------------
local function Behavior_Service()
    -- Safety check
    if not TestValid(Object) then
        return
    end

    -- On first service call, issue a move order 50 units to the north
    if not Has_Given_Move_Order then
        -- Calculate a position 50 units to the north (angle 0°)
        local target_position = Project_Position(Object, Object, 500.0, 0.0)
        Object.Move_To(target_position)
        Has_Given_Move_Order = true
    end

    -- Delay further checks for 30 seconds to avoid repeated moves
    Sleep(30.0)
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
Register_Behavior(my_behavior)

function Kill_Unused_Global_Functions()
    -- Automated kill list.
    Abs = nil
    BlockOnCommand = nil
    Calc_Score = nil
    Clamp = nil
    DebugBreak = nil
    DebugPrintTable = nil
    Debug_Switch_Sides = nil
    Declare_Enum = nil
    DesignerMessage = nil
    Dirty_Floor = nil
    Find_All_Parent_Units = nil
    Is_Player_Of_Faction = nil
    Max = nil
    Min = nil
    OutputDebug = nil
    Remove_Invalid_Objects = nil
    Simple_Round = nil
    Sort_Array_Of_Maps = nil
    String_Split = nil
    SyncMessage = nil
    SyncMessageNoStack = nil
    TestCommand = nil
    WaitForAnyBlock = nil
    Kill_Unused_Global_Functions = nil
end
