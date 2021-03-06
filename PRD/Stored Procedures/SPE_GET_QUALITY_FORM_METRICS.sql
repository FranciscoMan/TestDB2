﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 10/01/2018
-- Description: Get Quality Form Metrics by work order
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_QUALITY_FORM_METRICS] 
	@PIN_ID_WORK_ORDER INT = NULL
	, @PIN_ID_FORM INT 
	   
AS   

SELECT CFM.ID_FORM_METRICS
	, CFM.ID_METRICS
	, CFM.KY_VARIABLE_ACQUISITION_TYPE
FROM PRD.K_WORK_ORDER KWO
	INNER JOIN PRD.C_ITEM_CHARACTERISTIC CIC
		ON KWO.ID_ITEM = CIC.ID_ITEM
		AND KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
	INNER JOIN PRD.C_FORM CF
		ON CF.ID_FORM = @PIN_ID_FORM
		AND CF.KY_PROCESS = 'QUALITY'
	INNER JOIN PRD.C_FORM_METRICS CFM
		ON CFM.ID_FORM = CF.ID_FORM
		AND CFM.ID_METRICS = CIC.ID_METRICS
	INNER JOIN PRD.C_FORM_PRODUCTION_LINE CFPL
		ON KWO.ID_PRODUCTION_LINE = CFPL.ID_PRODUCTION_LINE
		AND CF.ID_FORM = CFPL.ID_FORM

