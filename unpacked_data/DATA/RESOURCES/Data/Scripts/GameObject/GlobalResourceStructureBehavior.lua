-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/GlobalResourceStructureBehavior.lua#8 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GameObject/GlobalResourceStructureBehavior.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 83904 $
--
--          $DateTime: 2007/09/14 18:22:42 $
--
--          $Revision: #8 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

--Adapted from NeutralRefinery.lua

require("PGBehaviors")
require("PGUICommands")

local my_behavior = {
	Name = _REQUIREDNAME
}

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Init()

	if Get_Game_Mode() == "Strategic" then

		CYCLE_DURATION = 30.0
		IsGlobal = true
		
		ResourcesPerCycle = GlobalResourcesPerCycle
		if ResourcesPerCycle == nil then
			ResourcesPerCycle = 0.0
		end		
		
		if GlobalResourceCap  then
			Object.Get_Owner().Add_To_Credit_Cap(GlobalResourceCap)
		end
	else 
		CYCLE_DURATION = 30.0
		IsGlobal = false

		ResourcesPerCycle = TacticalResourcesPerCycle
		if ResourcesPerCycle == nil then
			ResourcesPerCycle = 0.0
		end		
		
		if TacticalResourceCap  then
			Object.Get_Owner().Add_To_Credit_Cap(TacticalResourceCap)
		end		
	end
	
	LastCycleTime = GetCurrentTime()
	NextCycleTime = LastCycleTime + CYCLE_DURATION

end


-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Service 
-- --------------------------------------------------------------------------------------------------------------------------------------------------
local function Behavior_Service()
	
	local tm = GetCurrentTime()
	
	if tm >= NextCycleTime then	
		
		if TestValid(Object) then 
			local owner = Object.Get_Owner()
			if owner ~= nil then
				local old_credits = owner.Get_Credits()
				owner.Add_Credits(ResourcesPerCycle)
				local new_credits = owner.Get_Credits()
				local credits_added = new_credits - old_credits
				if owner == Find_Player("local") and credits_added > 0.0 then
					 local particle = Create_Generic_Object(Find_Object_Type("Resource_Floaty"), Object.Get_Position(), owner)
					 local scene = particle.Get_GUI_Scenes()[1]
					 scene.Text.Set_Text(Get_Localized_Formatted_Number(credits_added))
				end				
			end
		end

		LastCycleTime = NextCycleTime
		NextCycleTime = LastCycleTime + CYCLE_DURATION
	
	end
end

local function Behavior_First_Service()
end

local function Behavior_Delete_Pending()
	if IsGlobal then
		if GlobalResourceCap then
			local owner = Object.Get_Owner()
			if TestValid(owner) then
				Object.Get_Owner().Remove_From_Credit_Cap(GlobalResourceCap)
			end
		end
	else
		if TacticalResourceCap then
			local owner = Object.Get_Owner()
			if TestValid(owner) then
				Object.Get_Owner().Remove_From_Credit_Cap(TacticalResourceCap)
			end
		end
	end			
end

-- This line must be at the bottom of the file.
my_behavior.Init = Behavior_Init
my_behavior.Service = Behavior_Service
my_behavior.First_Service = Behavior_First_Service
my_behavior.Delete_Pending = Behavior_Delete_Pending

Register_Behavior(my_behavior)