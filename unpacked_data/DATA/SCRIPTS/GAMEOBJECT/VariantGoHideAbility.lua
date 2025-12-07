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
local Delay_Timer = 0.0
local Time_Reset = false
local Has_Not_Activated_Variant_Mode = true
local Go_Hide_Was_Activated = false
local Random_Position = nil
local Original_Position = nil
local Has_Moved_To_Random_Position = false

--------------------------------------------------------------------------------
-- FUNCTION: Behavior_Init
--------------------------------------------------------------------------------
local function Behavior_Init()
    Delay_Timer = 0.0
    Time_Reset = false
    Has_Not_Activated_Variant_Mode = true
    Go_Hide_Was_Activated = false
    Random_Position = nil
    Original_Position = nil
    Has_Moved_To_Random_Position = false
end

--------------------------------------------------------------------------------
-- FUNCTION: Behavior_Service
--------------------------------------------------------------------------------
local function Behavior_Service()
    -- Safety check
    if not TestValid(Object) then
        return
    end

    if Object.Has_Ability("Variant_Phase_Self_Ability") 
        and Object.Is_Ability_Active("Variant_Phase_Self_Ability") then
        Go_Hide_Was_Activated = true
        Object.Activate_Ability("Variant_Phase_Self_Ability", false)
    end

    if Go_Hide_Was_Activated then
        -- Get the unit's current position once when ability is activated
        if not TestValid(Original_Position) then
            Original_Position = Object.Get_Position()
        end
        
        -- Calculate dynamic radius based on nearby allies
        if not TestValid(Random_Position) then
            local dynamic_radius = Calculate_Dynamic_Radius()
            Random_Position = Generate_Random_Position_In_Radius(Object, dynamic_radius)
        end
        
        -- Move to the random position if we haven't done so already
        if TestValid(Random_Position) and not Has_Moved_To_Random_Position then
            Object.Move_To(Random_Position)
            Has_Moved_To_Random_Position = true
        end
        
        -- Check if we've reached the destination or stopped moving
        if Has_Moved_To_Random_Position then
            local distance_to_target = 999999.0
            
            if TestValid(Random_Position) then
                distance_to_target = Object.Get_Distance(Random_Position)
            end
            
            -- Activate camouflage if we're close to target (within 50 units) OR if unit stopped moving
            if distance_to_target <= 50.0 or not Object.Is_Moving() then
                -- Activate the camouflage mode ability
                --[[
                if Object.Has_Ability("Novus_Variant_Toggle_Weapon_Ability") 
                    and not Object.Is_Ability_Active("Novus_Variant_Toggle_Weapon_Ability") then
                    Object.Activate_Ability("Novus_Variant_Toggle_Weapon_Ability", true)
                end
                ]]--
                
                -- Reset all flags
                Go_Hide_Was_Activated = false
                Random_Position = nil
                Original_Position = nil
                Has_Moved_To_Random_Position = false
            end
        end
    end
    
    Sleep(0.1)
end

--------------------------------------------------------------------------------
-- FUNCTION: Calculate_Dynamic_Radius
-- Calculates the movement radius based on nearby allied units that can attack
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FUNCTION: Calculate_Dynamic_Radius
-- Calculates the movement radius based on nearby allied units that can attack
-- Uses area-based calculation to ensure even distribution density
--------------------------------------------------------------------------------
function Calculate_Dynamic_Radius()
    local base_radius = 300.0  -- Default radius when no allies around
    local ally_count = 0
    
    -- Get the owning player for alliance checks
    local owning_player = Object.Get_Owner()
    if not TestValid(owning_player) then
        return base_radius
    end
    
    -- Find all objects that can attack within 180 unit radius
    local can_attack_objects = Find_All_Objects_Of_Type(Object, 180.0, "CanAttack")
    
    if can_attack_objects then
        for _, attacker in pairs(can_attack_objects) do
            if TestValid(attacker) and attacker.Get_Owner() then
                local unit_type = attacker.Get_Type()
                
                -- Check if it's an ally and not a resource collector
                if attacker.Get_Owner().Is_Ally(owning_player) 
                    and not unit_type.Get_Type_Value("Is_Resource_Collector")
                    and attacker ~= Object then  -- Don't count ourselves
                    
                    ally_count = ally_count + 1
                end
            end
        end
    end
    
    -- Calculate area-based radius to maintain even distribution density
    -- Base area when alone
    local base_area = 3.14159 * base_radius * base_radius  -- π × r²
    
    -- Area for a unit with 250 sight radius
    local unit_sight_radius = 250.0
    local unit_area = 3.14159 * unit_sight_radius * unit_sight_radius
    
    -- Total area = base area + (number of allies × unit area)
    local total_area = base_area + (ally_count * unit_area)
    
    -- Convert back to radius: r = √(area/π)
    local final_radius = (total_area / 3.14159) ^ 0.5  -- Square root using ^0.5
    
    return final_radius
end


--------------------------------------------------------------------------------
-- FUNCTION: Generate_Random_Position_In_Radius
-- Uses Project_Position with random angles like in the AI examples
--------------------------------------------------------------------------------
function Generate_Random_Position_In_Radius(unit, radius)
    if not TestValid(unit) then
        return nil
    end
    
    -- Generate random angle (0 to 360 degrees) and random distance
    local angle = GameRandom.Get_Float(0.0, 360.0)
    local distance = GameRandom.Get_Float(0.0, radius)
    
    -- Use Project_Position like in the defensive AI example
    local new_position = Project_Position(unit, unit, distance, angle)
    
    return new_position
end

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Registration
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- This line must be at the bottom of the file.
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
