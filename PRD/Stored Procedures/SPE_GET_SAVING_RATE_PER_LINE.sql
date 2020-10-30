-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Díaz
-- CREATE date: 09/25/2018
-- Description: Get production line saving rate
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_SAVING_RATE_PER_LINE]	
	@PIN_DT_INITIAL_DATE AS DATETIME = NULL,
	@PIN_XML_PRODUCTION_LINES AS XML = NULL

AS   
BEGIN		

	SELECT ID_PRODUCTION_LINE
		, NO_PRD_LBS
		, NO_SVD_LBS
	FROM PRD.F_GET_PRODUCED_LBS_PER_LINE (@PIN_XML_PRODUCTION_LINES, @PIN_DT_INITIAL_DATE)

END

