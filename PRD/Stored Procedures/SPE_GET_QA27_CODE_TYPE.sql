-- ====================================== =======
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 08/03/2018
-- Description: get all QA27 PER CODE TYPE 
-- =============================================
-- 12/12/218 JDR KY_GROUP column is added
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_QA27_CODE_TYPE]
		@PIN_ID_QA27 AS INT = NULL,
		@PIN_NO_GROUP AS NVARCHAR(1) = NULL
AS   

	SELECT CT.ID_CODE_TYPE
		, CT.KY_CODE_TYPE
		, CT.NM_CODE_TYPE
		, CT.DS_CODE_TYPE
		, CT.KY_GROUP
	FROM ADM.VW_C_CODE_TYPE CT
	WHERE (@PIN_NO_GROUP IS NULL OR (@PIN_NO_GROUP IS NOT NULL AND CT.KY_GROUP = @PIN_NO_GROUP))
	ORDER BY CT.NO_ORDER

