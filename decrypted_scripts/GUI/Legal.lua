-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Legal.lua#7 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/GUI/Legal.lua $
--
--    Original Author: Justin Fic
--
--            $Author: Joe_Howes $
--
--            $Change: 84946 $
--
--          $DateTime: 2007/09/27 12:23:47 $
--
--          $Revision: #7 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")

function On_Init()
	this.Register_Event_Handler("Movie_Finished", this.LogoMovie, On_Movie_Finished)
	this.Register_Event_Handler("Closing_All_Displays", nil, On_Skip_Movie)

	OutputDebug("JOE::::   Doing movie table: Build: %s", tostring(BETA_BUILD))
		
	if (BETA_BUILD) then

		MovieData = {
							{ Movie="blank.bik", Text="", CanSkip=false },
							{ Movie="Sega_Logo.bik", Text="TEXT_SEGA_LEGAL", CanSkip=false },
							{ Movie="PetroglyphLogo.bik", Text="TEXT_PETROGLYPH_LEGAL", CanSkip=true },
							{ Movie="Creative.bik", Text="TEXT_SOUND_BLASTER_LEGAL", CanSkip=true },
							{ Movie="NVidia.bik", Text="TEXT_NVIDIA_LEGAL", CanSkip=true },
						}
						
	else
					
		MovieData = {
							{ Movie="blank.bik", Text="", CanSkip=false },
							{ Movie="Sega_Logo.bik", Text="TEXT_SEGA_LEGAL", CanSkip=false },
							{ Movie="PetroglyphLogo.bik", Text="TEXT_PETROGLYPH_LEGAL", CanSkip=true },
							{ Movie="Creative.bik", Text="TEXT_SOUND_BLASTER_LEGAL", CanSkip=true },
							{ Movie="NVidia.bik", Text="TEXT_NVIDIA_LEGAL", CanSkip=true },
							{ Movie="Trailer.bik", Text="", CanSkip=true },
						}
						
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

function On_Movie_Finished()
	MovieIndex = MovieIndex + 1

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