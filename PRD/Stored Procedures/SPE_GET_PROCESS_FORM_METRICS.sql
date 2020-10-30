-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 10/01/2018
-- Description: Get process Form Metrics by production line
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_PROCESS_FORM_METRICS] 
	@PIN_ID_PRODUCTION_LINE INT
	, @PIN_ID_FORM INT

AS

SELECT CFM.ID_FORM_METRICS
	, CFM.ID_METRICS
	, CFM.KY_VARIABLE_ACQUISITION_TYPE
FROM PRD.C_LINE_METRIC CLM
	INNER JOIN PRD.C_FORM_METRICS CFM
		ON CLM.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE
		AND CLM.ID_METRICS = CFM.ID_METRICS
		AND CFM.ID_FORM = @PIN_ID_FORM
	INNER JOIN PRD.C_FORM CF
		ON CFM.ID_FORM = CF.ID_FORM
		AND CF.KY_PROCESS = 'PROCESS'

