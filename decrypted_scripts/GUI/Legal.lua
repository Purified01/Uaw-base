if (LuaGlobalCommandLinks) == nil then
	LuaGlobalCommandLinks = {}
end
LuaGlobalCommandLinks[112] = true
LuaGlobalCommandLinks[79] = true
LuaGlobalCommandLinks[192] = true
LUA_PREP = true

-- $Id: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Legal.lua#15 $
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
--              $File: //depot/Projects/Invasion_360/Run/Data/Scripts/GUI/Legal.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Brian_Hayes $
--
--            $Change: 93153 $
--
--          $DateTime: 2008/02/12 11:04:35 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

ScriptPoolCount = 0

function On_Init()
	this.Register_Event_Handler("Movie_Finished", this.LogoMovie, On_Movie_Finished)
	this.Register_Event_Handler("Closing_All_Displays", nil, On_Skip_Movie)

	this.Register_Event_Handler("Controller_A_Button_Up", nil, On_Skip_Movie)
	this.Register_Event_Handler("Controller_B_Button_Up", nil, On_Skip_Movie)
	this.Register_Event_Handler("Controller_Start_Button_Up", nil, On_Skip_Movie)	
	this.LogoMovie.Set_Tab_Order(0)
	this.Focus_First()
		
	if (BETA_BUILD) then

		MovieData = {
							{ Movie="blank.bik", Text="", CanSkip=false, Surround=false },
							{ Movie="Sega_Logo.bik", Text="TEXT_SEGA_LEGAL", CanSkip=false, Surround=false },
							{ Movie="PetroglyphLogo.bik", Text="TEXT_PETROGLYPH_LEGAL", CanSkip=true, Surround=false },
							{ Movie="Creative.bik", Text="TEXT_SOUND_BLASTER_LEGAL", CanSkip=true, Surround=false },
							{ Movie="NVidia.bik", Text="TEXT_NVIDIA_LEGAL", CanSkip=true, Surround=false },
						}
						
	else
		if not Is_Xbox() then		
			MovieData = {
								{ Movie="blank.bik", Text="", CanSkip=false, Surround=false },
								{ Movie="Sega_Logo.bik", Text="TEXT_SEGA_LEGAL", CanSkip=false, Surround=false },
								{ Movie="PetroglyphLogo.bik", Text="TEXT_PETROGLYPH_LEGAL", CanSkip=true, Surround=false },
								{ Movie="Creative.bik", Text="TEXT_SOUND_BLASTER_LEGAL", CanSkip=true, Surround=false },
								{ Movie="NVidia.bik", Text="TEXT_NVIDIA_LEGAL", CanSkip=true, Surround=false },
								{ Movie="Trailer.bik", Text="", CanSkip=true, Surround=false },
							}
		else
			MovieData = {
								{ Movie=Get_Ratings_Movie_For_Locale(), Text="", CanSkip=false, Surround=false },
								{ Movie="Sega_Logo.bik", Text="TEXT_SEGA_LEGAL", CanSkip=false, Surround=true },
								{ Movie="PetroglyphLogo.bik", Text="TEXT_PETROGLYPH_LEGAL", CanSkip=true, Surround=true },
								{ Movie="Trailer.bik", Text="", CanSkip=true, Surround=true },
							}
		end
						
	end
				
	MovieIndex = 0
	Register_Video_Commands()
	local settings = VideoSettingsManager.Get_Current_Settings()
	local width = settings.Screen_Width
	local height = settings.Screen_Height	
	
	local movie_height = (width / height) / (16.0 / 9.0)
	local y_offset = (1.0 - movie_height) / 2.0;

	this.LogoMovie.Set_World_Bounds(0.0, y_offset, 1.0, movie_height)
	
	IsDone = false
	On_Movie_Finished()
end

function Get_Ratings_Movie_For_Locale()
	if Locale == 0 then
		--0 is USA
		return "ESRB.bik"
	else
		return "PEGI.bik"
	end
end

function On_Movie_Finished()
	MovieIndex = MovieIndex + 1
	ResetLastControllerInputTime();		

	local any_set = false
	local movie_data = MovieData[MovieIndex]
	if not movie_data then
		--All done
		IsDone = true
		this.End_Modal()
		this.LogoMovie.Set_Hidden(true)
		this.LegalText.Set_Hidden(true)
		this.LoadModel.Set_Hidden(false)
		return
	end		
	
	this.LogoMovie.Set_Surround(movie_data.Surround)
	this.LogoMovie.Set_Movie(movie_data.Movie)
	this.LegalText.Set_Text(movie_data.Text)	
end

function On_Skip_Movie()
	local movie_data = MovieData[MovieIndex]
	if movie_data and movie_data.CanSkip then
		this.LogoMovie.Stop()
		On_Movie_Finished()
	end
end

function Is_Done()
	return IsDone
end

Interface = {}
Interface.Start_Movie_Sequence = On_Movie_Finished
function Kill_Unused_Global_Functions()
	-- Automated kill list.
	Kill_Unused_Global_Functions = nil
end
