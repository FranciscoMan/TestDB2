﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 27/04/2018
-- Description: Get the catalog helps
-- ============================================
CREATE PROCEDURE    [ADM].[SPE_GET_HELP]
	@PIN_ID_HELP			AS int = NULL,
	@PIN_KY_HELP			AS nvarchar(50) = NULL,
	@PIN_NM_HELP			AS nvarchar(300) = NULL,
	@PIN_ID_HELP_FATHER		AS int = NULL,
	@PIN_KY_HELP_FATHER		AS nvarchar(50) = NULL,
	@PIN_NM_HELP_FATHER		AS nvarchar(300) = NULL,
	@PIN_DS_SEARCH 			AS nvarchar(300) = NULL
AS   
BEGIN

		SELECT  CH.ID_HELP,
				CH.KY_HELP,
				CH.NM_HELP,
				CASE WHEN @PIN_ID_HELP IS NOT NULL THEN CH.XML_HELP ELSE NULL END AS XML_HELP,
				HF.ID_HELP AS ID_HELP_FATHER,
				HF.KY_HELP AS KY_HELP_FATHER,
				HF.NM_HELP AS NM_HELP_FATHER
		FROM ADM.C_HELP CH
   LEFT JOIN ADM.C_HELP HF ON CH.ID_HELP_FATHER = HF.ID_HELP
	   WHERE (@PIN_ID_HELP IS NULL OR (@PIN_ID_HELP IS NOT NULL AND CH.ID_HELP = @PIN_ID_HELP))
	     AND (@PIN_KY_HELP IS NULL OR (@PIN_KY_HELP IS NOT NULL AND CH.KY_HELP = @PIN_KY_HELP))
		 AND (@PIN_NM_HELP IS NULL OR (@PIN_NM_HELP IS NOT NULL AND CH.NM_HELP = @PIN_NM_HELP))
		 AND (@PIN_ID_HELP_FATHER IS NULL OR (@PIN_ID_HELP_FATHER IS NOT NULL AND HF.ID_HELP = @PIN_ID_HELP_FATHER))
		 AND (@PIN_KY_HELP_FATHER IS NULL OR (@PIN_KY_HELP_FATHER IS NOT NULL AND HF.KY_HELP = @PIN_KY_HELP_FATHER))
		 AND (@PIN_NM_HELP_FATHER IS NULL OR (@PIN_NM_HELP_FATHER IS NOT NULL AND HF.NM_HELP = @PIN_NM_HELP_FATHER))
		 AND (@PIN_DS_SEARCH IS NULL OR (@PIN_DS_SEARCH IS NOT NULL AND (UPPER(CH.NM_HELP) LIKE '%' +UPPER(@PIN_DS_SEARCH)+ '%' 
																	  OR UPPER(CAST(CH.XML_HELP AS VARCHAR(MAX))) LIKE '%'+@PIN_DS_SEARCH+'%' 
																		)
										)
			 )
	ORDER BY CH.KY_HELP


END

