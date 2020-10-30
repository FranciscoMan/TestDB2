﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) -VITEK - 2020
-- Author: DELLC
-- CREATE date: 09/24/2020
-- Description: Get work orders by production line
-- =============================================
-- Rev Addon 125
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_BY_PRODUCTION_LINE] 
	@PIN_ID_PRODUCTION_LINE INT
	,@PIN_KY_STATUS_WORK_ORDER XML
AS
BEGIN


DECLARE @T_WORK_ORDER_STATUS TABLE (
		KY_WORK_ORDER_STATUS NVARCHAR(20)
	)

	INSERT INTO @T_WORK_ORDER_STATUS (KY_WORK_ORDER_STATUS)
	SELECT x.ref.value('@KY_STATUS', 'VARCHAR(20)') KY_STATUS_WORK_ORDER 
	FROM @PIN_KY_STATUS_WORK_ORDER.nodes('/STATUS/ST') x(ref)

	SELECT KWO.ID_BRANCH_PLANT
		, (SELECT TOP 1 QA.ID_QA27 FROM PRD.K_QA27 QA WHERE  QA.ID_WORK_ORDER = KWO.ID_WORK_ORDER ORDER BY QA.ID_QA27 DESC) AS  ID_QA27
		, KWO.ID_WORK_ORDER
		, CI.ID_ITEM
		, CI.KY_ITEM
		, CI.DS_ITEM
		, KWO.NM_CUSTOMER
		, KWO.NO_RUN_QTY + KWO.NO_QTY_ADDED AS NO_RUN_QTY
		, KWO.DT_WORK_ORDER
		, KWO.DT_UPDATE  AS DT_CLOSE_WORK_ORDER
		-- quit flag
		, COALESCE((SELECT COUNT(*) FROM PRD.K_INSPECTION_SKID KIS
		INNER JOIN PRD.K_PALLET KP ON KP.ID_WORK_ORDER = KIS.ID_WORK_ORDER AND KP.NO_PALLET = KIS.NO_PALLET
		WHERE KIS.ID_WORK_ORDER = KWO.ID_WORK_ORDER 
		AND KP.KY_STATUS IN (SELECT KY_PALLET_STATUS FROM ADM.VW_C_PALLET_STATUS  VWPS WHERE VWPS.KY_TEMP_STATUS = 'A')),0) AS NO_SKIDS_SAVED
		, KWO.NO_QTY_ADDED
		, KWO.NO_QTY_SKID
		, KWO.KY_STATUS
		--, KWO.NM_MATERIAL
		--, KWO.NM_COLOR
		,(CEILING((NO_RUN_QTY + NO_QTY_ADDED) / NO_QTY_SKID))+ COALESCE((SELECT COUNT(*) FROM PRD.K_INSPECTION_SKID KIS
		INNER JOIN PRD.K_PALLET KP ON KP.ID_WORK_ORDER = KIS.ID_WORK_ORDER AND KP.NO_PALLET = KIS.NO_PALLET
		WHERE KIS.ID_WORK_ORDER = KWO.ID_WORK_ORDER 
		AND KP.KY_STATUS IN (SELECT KY_PALLET_STATUS FROM ADM.VW_C_PALLET_STATUS  VWPS WHERE VWPS.KY_TEMP_STATUS = 'R')),0) AS NO_TOTAL_SKIDS
		, KWO.NO_ORDER
		, (SELECT NM_TRANSITION AS li
			FROM PRD.K_WORK_ORDER_TRANSITIONS WOT
			WHERE WOT.ID_WORK_ORDER = KWO.ID_WORK_ORDER
			FOR XML RAW (''), ROOT ('ul'), ELEMENTS
		) AS XML_TRANSITIONS
		
		, CU.KY_USER
		, ISNULL(CONVERT(DECIMAL(13,2), NULLIF(CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'NVARCHAR(100)'), '')), CI.NO_POUNDS_PER_ITEM) POUNDS_PER_ITEM
		, COALESCE((SELECT COUNT(*) FROM PRD.K_INSPECTION_SKID KIS
		INNER JOIN PRD.K_PALLET KP ON KP.ID_WORK_ORDER = KIS.ID_WORK_ORDER AND KP.NO_PALLET = KIS.NO_PALLET
		WHERE KIS.ID_WORK_ORDER = KWO.ID_WORK_ORDER 
		AND KP.KY_STATUS IN (SELECT KY_PALLET_STATUS FROM ADM.VW_C_PALLET_STATUS  VWPS WHERE VWPS.KY_TEMP_STATUS = 'H')),0) AS SKIDS_ON_HOLD
		,
		COALESCE((SELECT COUNT(*) FROM PRD.K_INSPECTION_SKID KIS
		INNER JOIN PRD.K_PALLET KP ON KP.ID_WORK_ORDER = KIS.ID_WORK_ORDER AND KP.NO_PALLET = KIS.NO_PALLET
		WHERE KIS.ID_WORK_ORDER = KWO.ID_WORK_ORDER 
		AND KP.KY_STATUS IN (SELECT KY_PALLET_STATUS FROM ADM.VW_C_PALLET_STATUS  VWPS WHERE VWPS.KY_TEMP_STATUS = 'R')),0) AS SKIDS_REJECTED
	
	FROM PRD.K_WORK_ORDER KWO
		INNER JOIN PRD.C_ITEM CI
			ON KWO.ID_ITEM = CI.ID_ITEM
		INNER JOIN ADM.C_BRANCH_PLANT CBP
			ON KWO.ID_BRANCH_PLANT = CBP.ID_BRANCH_PLANT
		LEFT JOIN PRD.C_ITEM_CHARACTERISTIC CIC
			ON CIC.ID_ITEM = CI.ID_ITEM
			AND CIC.ID_METRICS = CBP.ID_WEIGHT_METRIC
		LEFT JOIN PRD.K_QA27 KQ
			ON KWO.ID_WORK_ORDER = KQ.ID_WORK_ORDER
			AND KQ.KY_STATUS = KWO.KY_STATUS
			AND KQ.ID_QA27 = (SELECT TOP 1 ID_QA27 FROM PRD.K_QA27 WHERE ID_WORK_ORDER = KWO.ID_WORK_ORDER ORDER BY ID_QA27 DESC ) 
		LEFT JOIN ADM.C_USER CU
			ON KQ.ID_LEADMAN = CU.ID_EMPLOYEE
			AND CU.FG_ACTIVE = 1
	WHERE KWO.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE AND  KWO.KY_STATUS IN  (SELECT KY_WORK_ORDER_STATUS FROM @T_WORK_ORDER_STATUS)
	ORDER BY  KWO.KY_STATUS, KWO.NO_ORDER  DESC
	
	
	
	

END
