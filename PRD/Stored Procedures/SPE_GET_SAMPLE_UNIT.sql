-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 20/04/2017
-- Description: get all Sample units
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_SAMPLE_UNIT] 
		@PIN_ID_SAMPLE_UNIT AS int = NULL,
		@PIN_KY_SAMPLE_UNIT AS nvarchar(300) = NULL,
        @PIN_NM_SAMPLE_UNIT AS nvarchar(50) = NULL

AS   
		  SELECT VSU.ID_SAMPLE_UNIT,
				 VSU.KY_SAMPLE_UNIT,
				 VSU.NM_SAMPLE_UNIT
			FROM [ADM].[VW_C_SAMPLE_UNIT] VSU
					
		   WHERE (@PIN_ID_SAMPLE_UNIT IS NULL OR (@PIN_ID_SAMPLE_UNIT IS NOT NULL AND VSU.ID_SAMPLE_UNIT = @PIN_ID_SAMPLE_UNIT )) AND 
				 (@PIN_KY_SAMPLE_UNIT IS NULL OR (@PIN_KY_SAMPLE_UNIT IS NOT NULL AND VSU.KY_SAMPLE_UNIT = @PIN_KY_SAMPLE_UNIT )) AND 
				 (@PIN_NM_SAMPLE_UNIT IS NULL OR (@PIN_NM_SAMPLE_UNIT IS NOT NULL AND VSU.NM_SAMPLE_UNIT = @PIN_NM_SAMPLE_UNIT))

