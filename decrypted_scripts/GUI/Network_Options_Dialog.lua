-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Network_Options_Dialog.lua#3 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Network_Options_Dialog.lua $
--
--    Original Author: Joe Howes
--
--            $Author: Joe_Howes $
--
--            $Change: 60757 $
--
--          $DateTime: 2007/01/16 11:24:53 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")
require("PGDebug")

ScriptPoolCount = 0 -- UI scripts can't be pooled, for now.
DialogToOpen = nil

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Raise_Event_All_Scenes
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Raise_Event_All_Scenes(event_name, args)
	local num_scenes = Get_Total_Active_Scenes()
	for i=0,num_scenes-1 do
		local scene = Get_Active_Scene_At(i)
		scene.Raise_Event(event_name, nil, args)
	end
end


function On_Init()

	-- Button Names
	Network_Options_Dialog.Button_Refresh_Network_Info.Set_Button_Name("Refresh Network Info");
	Network_Options_Dialog.Button_UPnP_Details.Set_Button_Name("UPnP Details");
	Network_Options_Dialog.Button_Cancel.Set_Button_Name("Cancel");
	Network_Options_Dialog.Button_Default.Set_Button_Name("Default");
	Network_Options_Dialog.Button_Accept.Set_Button_Name("Accept");


	-- Populate "Quickmatch Default" combo box.
	Network_Options_Dialog.Combo_Quickmatch_Default.Add_Item("1 v 1 Campaign");
	Network_Options_Dialog.Combo_Quickmatch_Default.Add_Item("1 v 1 Land");
	Network_Options_Dialog.Combo_Quickmatch_Default.Add_Item("1 v 1 Space");
	Network_Options_Dialog.Combo_Quickmatch_Default.Set_Selected_Index(0);
	

	-- Populate "Connection Type" combo box.
	Network_Options_Dialog.Combo_Connection_Type.Add_Item("Modem");
	Network_Options_Dialog.Combo_Connection_Type.Add_Item("Broadband");
	Network_Options_Dialog.Combo_Connection_Type.Set_Selected_Index(0);
	

	-- Populate "Host Location" combo box.
	Network_Options_Dialog.Combo_Host_Location.Add_Item("[MISSING]");
	Network_Options_Dialog.Combo_Connection_Type.Set_Selected_Index(0);
	


end

function On_Update()
end

---------------------------------------
-- Keyboard Events
---------------------------------------
function On_Key_Press(event, source, key)

	--Hard code 'a' and 't' to the audio/text validation dialogs, respectively
	--[[if key == "a" then
		Open_Dialog("Audio_Validation")
	elseif key == "t" then
		Open_Dialog("Text_Validation")
	end--]]
	
end

---------------------------------------
-- LAN Lobby Button Events
---------------------------------------

function LAN_Lobby_Back_Clicked(event_name, source)

	-- JOE:: Test stuff
	--DebugMessage("JOE:: List_Games: " .. tostring(LAN_Lobby_Dialog.List_Games))
	--DebugMessage("JOE:: Rows: " .. LAN_Lobby_Dialog.List_Games.Get_Visible_Row_Count() .. "\n")
	--LAN_Lobby_Dialog.List_Games.Test_Stuff();

	--[[LAN_Lobby_Dialog.List_Games.Set_Value("Name", 0, "Name Row 0");
	LAN_Lobby_Dialog.List_Games.Set_Value("Type", 0, "Type Row 0");
	LAN_Lobby_Dialog.List_Games.Set_Value("Players", 0, "Players Row 0");
	LAN_Lobby_Dialog.List_Games.Set_Value("Map", 0, "Map Row 0");
	LAN_Lobby_Dialog.List_Games.Set_Value("Ping", 0, "Ping Row 0");--]]

	--[[for i = 0, 20 do
		LAN_Lobby_Dialog.List_Games.Add_Row();
		LAN_Lobby_Dialog.List_Games.Set_Value("Name", i, "Name Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Type", i, "Type Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Players", i, "Players Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Map", i, "Map Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Ping", i, "Ping Row " .. i);
	end
	LAN_Lobby_Dialog.List_Games.Refresh();

	for i = 0, 20 do
		LAN_Lobby_Dialog.List_Players.Add_Row();
		LAN_Lobby_Dialog.List_Players.Set_Value("Players", i, "Player " .. i);
	end
	LAN_Lobby_Dialog.List_Players.Refresh();

	for i = 0, 20 do
		LAN_Lobby_Dialog.List_Chat.Add_Row();
		LAN_Lobby_Dialog.List_Chat.Set_Value("Chat", i, "Chat line " .. i);
	end
	LAN_Lobby_Dialog.List_Chat.Refresh();--]]

	-- JOE::  The real function
    if (LAN_Lobby_Dialog ~= nil) then
        LAN_Lobby_Dialog.Get_Owner().LAN_Lobby_Dialog.Set_Hidden(true)
    end

end

function Play_Click() 
	Play_SFX_Event("GUI_Generic_Button_Select")
end

function Play_Alien_Steam() 
	Play_SFX_Event("SFX_Anim_Alien_Walker_Hydraulics")
end

function Prepare_Fadeout()
	-- We can't call mapped functions from the GUI; we have to go through this.
	Prepare_Fades()
end


-- ------------------------------------------------------------------------------------------------------------------
-- Context Functions (Functions that affect this dialog within this context).
-- ------------------------------------------------------------------------------------------------------------------
function Show()
	LAN_Lobby_Dialog.Set_Hidden(false)
end

function Hide()
	LAN_Lobby_Dialog.Set_Hidden(true)
end


-- ------------------------------------------------------------------------------------------------------------------
-- Miscellaneous functions
-- ------------------------------------------------------------------------------------------------------------------
function Test_Populate()

	--[[for i = 0, 20 do
		LAN_Lobby_Dialog.List_Games.Add_Row();
		LAN_Lobby_Dialog.List_Games.Set_Value("Name", i, "Name Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Type", i, "Type Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Players", i, "Players Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Map", i, "Map Row " .. i);
		LAN_Lobby_Dialog.List_Games.Set_Value("Ping", i, "Ping Row " .. i);
	end
	LAN_Lobby_Dialog.List_Games.Refresh();

	for i = 0, 20 do
		LAN_Lobby_Dialog.List_Players.Add_Row();
		LAN_Lobby_Dialog.List_Players.Set_Value("Players", i, "Player " .. i);
	end
	LAN_Lobby_Dialog.List_Players.Refresh();

	for i = 0, 20 do
		LAN_Lobby_Dialog.List_Chat.Add_Row();
		LAN_Lobby_Dialog.List_Chat.Set_Value("Chat", i, "Chat line " .. i);
	end
	LAN_Lobby_Dialog.List_Chat.Refresh();--]]

end

-- ------------------------------------------------------------------------------------------------------------------
-- Interface functions (accessible to other scenes)
-- ------------------------------------------------------------------------------------------------------------------
--[[Interface = {}
Interface.Show = Show
Interface.Hide = Hide--]]
