﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 01/11/2019
-- Description: Get work order cartons
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_CARTONS_GROUPED] 
	@PIN_ID_WORK_ORDER INT
	, @PIN_ID_QA27 INT

AS   

SELECT KWOC.ID_CARTON
	, KWOC.KY_CARTON
	, KWOC.NM_CARTON
	, KWOC.DS_CARTON
	, KWOC.ID_ITEM
	, KWOC.ID_WORK_ORDER
	, SUM(KWOC.NO_SCRAP) AS NO_SUM_SCRAP
	, SUM(KWOC.NO_USAGE) AS NO_SUM_USAGE
FROM PRD.C_ITEM CI 
	INNER JOIN PRD.C_CARTON_ITEM CCI
		ON CI.ID_ITEM = CCI.ID_ITEM
	INNER JOIN PRD.K_WORK_ORDER KWO
		ON KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
		AND KWO.ID_ITEM = CI.ID_ITEM
	LEFT JOIN PRD.K_WORK_ORDER_CARTON KWOC
		ON KWOC.ID_WORK_ORDER = KWO.ID_WORK_ORDER
		AND KWOC.ID_ITEM = KWO.ID_ITEM
		AND CCI.ID_CARTON = KWOC.ID_CARTON
		AND (@PIN_ID_QA27 IS NULL OR (@PIN_ID_QA27 IS NOT NULL AND KWOC.ID_QA27 = @PIN_ID_QA27))
GROUP BY KWOC.ID_CARTON
	, KWOC.KY_CARTON
	, KWOC.NM_CARTON
	, KWOC.DS_CARTON
	, KWOC.ID_ITEM
	, KWOC.ID_WORK_ORDER

