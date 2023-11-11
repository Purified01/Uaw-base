-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/FloatyText.lua#6 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/FloatyText.lua $
--
--    Original Author: Mike Lytle
--
--            $Author: James_Yarrow $
--
--            $Change: 80706 $
--
--          $DateTime: 2007/08/13 09:24:43 $
--
--          $Revision: #6 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGUICommands")

function On_Init()
	local data = this.Get_User_Data()

	if data then
		
		--This is regular floaty text scene
		if type(data) ~= "table" then 
			local amount = this.Get_User_Data()
			this.Text.Set_Text( Get_Localized_Formatted_Number(amount))
		
		--This is Sell floaty text scene	
		else 
			local sell_data = this.Get_User_Data()
			local amount = sell_data[1]
			local color_r, color_g, color_b, color_a
			local w_text
			
			if (#sell_data >= 5) then
				color_r = sell_data[2]
				color_g = sell_data[3]
				color_b = sell_data[4]
				color_a = sell_data[5]
			end
			
			if amount < 0 then	
				w_text = Create_Wide_String("-")
			else
				w_text = Create_Wide_String("+")
			end
			
			if not color_r then
				this.Text.Set_Tint( 0,1,0,1) -- green
			else
				this.Text.Set_Tint( color_r, color_g, color_b, color_a)
			end
			
			w_text.append( Get_Localized_Formatted_Number(amount) )
			this.Text.Set_Text(w_text)
		end		
	end
end

