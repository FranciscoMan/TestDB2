-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 20/04/2017
-- Description: get all form process
-- =============================================
CREATE PROCEDURE  [PRD].[SPE_GET_FORM_PROCESS] 
		@PIN_ID_PROCESS AS int = NULL,
		@PIN_KY_PROCESS AS nvarchar(300) = NULL,
        @PIN_NM_PROCESS AS nvarchar(50) = NULL

AS   
		  SELECT VP.ID_PROCESS,
				 VP.KY_PROCESS,
				 VP.NM_PROCESS
			FROM [ADM].[VW_C_PROCESS] VP
					
		   WHERE (@PIN_ID_PROCESS IS NULL OR (@PIN_ID_PROCESS IS NOT NULL AND VP.ID_PROCESS= @PIN_ID_PROCESS )) AND 
				 (@PIN_KY_PROCESS IS NULL OR (@PIN_KY_PROCESS IS NOT NULL AND VP.KY_PROCESS = @PIN_KY_PROCESS )) AND 
				 (@PIN_NM_PROCESS IS NULL OR (@PIN_NM_PROCESS IS NOT NULL AND VP.NM_PROCESS = @PIN_NM_PROCESS))

