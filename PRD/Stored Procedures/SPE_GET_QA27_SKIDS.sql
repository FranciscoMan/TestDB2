﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 12/03/2018
-- Description: Get pallets by dates
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_QA27_SKIDS]
	 @PIN_ID_BRANCH_PLANT AS INT = NULL
	,@PIN_ID_WORK_ORDER	AS INT = NULL
	,@PIN_ID_QA27	AS INT = NULL
	
AS   
	SELECT KP.ID_PALLET
		, KP.NO_PALLET
		, KP.KY_STATUS
		, CPS.NM_PALLET_STATUS
		, KP.DT_INITIAL_TIME
		, KP.DT_FINAL_TIME
		, KP.NO_QUANTITY
		, WO.ID_WORK_ORDER
		, WO.NO_WORK_ORDER
		, WO.NM_ITEM
		, CPS.FG_FOR_SAVE
		, CPS.KY_TEMP_STATUS
		, KP.ID_QA27
		--, CASE
		--	WHEN CPS.KY_TEMP_STATUS IN ('R', 'A') THEN CPS.KY_TEMP_STATUS
		--	WHEN KP.DT_FINAL_OPERATION_TIME IS NULL THEN 'W'
		--	ELSE 'A'
		--END AS KY_TEMP_STATUS
	FROM PRD.K_PALLET KP
		INNER JOIN ADM.VW_C_PALLET_STATUS CPS 
			ON CPS.KY_PALLET_STATUS = KP.KY_STATUS
		LEFT JOIN PRD.K_WORK_ORDER WO 
			ON WO.ID_WORK_ORDER = KP.ID_WORK_ORDER
		LEFT JOIN PRD.K_QA27 QA 
			ON QA.ID_QA27 = KP.ID_QA27
	WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND WO.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
	  AND (@PIN_ID_WORK_ORDER IS NULL OR (@PIN_ID_WORK_ORDER IS NOT NULL AND WO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER))
	  AND (@PIN_ID_QA27 IS NULL OR (@PIN_ID_QA27 IS NOT NULL AND KP.ID_QA27 = @PIN_ID_QA27))
	ORDER BY KP.NO_PALLET ASC
