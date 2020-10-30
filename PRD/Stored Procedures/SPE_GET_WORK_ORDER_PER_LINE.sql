﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 06/04/2017
-- Description: get alL WORK ORDERS PER LINE.
-- =============================================
-- 24/01/2018 JDR KY_USER column added to the projection
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_PER_LINE] 
	    @PIN_ID_BRANCH_PLANT AS int = NULL,
		@PIN_ID_PRODUCTION_LINE AS int = NULL,
		@PIN_KY_STATUS_WORK_ORDER AS XML = NULL,
		@PIN_KY_STATUS_QA27 AS nvarchar(50) = NULL,
		@PIN_KY_STATUS_PALLET AS nvarchar(50) = NULL,
		@PIN_ID_LEADMAN AS INT = NULL,
		@PIN_ID_WORK_ORDER AS INT = NULL,
		@PIN_ID_QA27 AS INT = NULL

AS  
DECLARE @T_WORK_ORDER_STATUS TABLE (
		KY_WORK_ORDER_STATUS NVARCHAR(20)
	)


DECLARE @V_WORK_ORDER_PROGRESS AS NVARCHAR(MAX) = '',
		@V_INITIAL_MESSAGE_ONE_PALLET AS NVARCHAR(MAX) = ''

IF(@PIN_ID_WORK_ORDER IS NOT NULL)
BEGIN 
	SET @V_WORK_ORDER_PROGRESS =  ( SELECT PRD.F_GET_PROGRESS_WORK_ORDER(@PIN_ID_WORK_ORDER))
END
	INSERT INTO @T_WORK_ORDER_STATUS (KY_WORK_ORDER_STATUS)
	SELECT x.ref.value('@KY_STATUS', 'VARCHAR(20)') KY_STATUS_WORK_ORDER FROM @PIN_KY_STATUS_WORK_ORDER.nodes('/STATUS/ST') x(ref)
	
	SELECT
		  NO_WORK_ORDER
		, ID_WORK_ORDER
		, ID_QA27
		, KY_USER
		, KY_CUSTOMER
		, NM_CUSTOMER
		, ID_ITEM
		, KY_ITEM
		, NM_ITEM
		, ID_PRODUCTION_LINE
		, KY_PRODUCTION_LINE
		, NM_PRODUCTION_LINE
		, NM_MATERIAL
		, NM_COLOR
		, NO_RUN_QTY
		, NO_LENGHT
		, NO_WIDTH
		, NO_THICKNESS
		, NO_ASSIGNED_TIME
		, DT_WORK_ORDER
		, DT_INITIAL_TIME
		, KY_STATUS
		, ID_PALLET
		, NO_PALLET
		, KY_STATUS_PALLET
		, NO_PALLETS
		, DS_PROGRESS_WORK_ORDER
		, DS_TRANSITIONS
	FROM (
		-- THE FIRST QUERY OLY WILL BE USED FOR RUNNING WORK ORDERS
		SELECT KWO.NO_WORK_ORDER
			, KWO.ID_WORK_ORDER
			, KQA.ID_QA27
			, CU.KY_USER
			, KWO.KY_CUSTOMER
			, KWO.NM_CUSTOMER
			, CI.ID_ITEM
			, CI.KY_ITEM
			, CI.NM_ITEM
			, CPL.ID_PRODUCTION_LINE
			, CPL.KY_PRODUCTION_LINE
			, CPL.NM_PRODUCTION_LINE
			, KWO.NM_MATERIAL
			, KWO.NM_COLOR
			,(KWO.NO_RUN_QTY + KWO.NO_QTY_ADDED) AS NO_RUN_QTY
			, KWO.NO_LENGHT
			, KWO.NO_WIDTH
			, KWO.NO_THICKNESS
			, KWO.NO_ASSIGNED_TIME NO_ASSIGNED_TIME
			, CONVERT(VARCHAR(10),KWO.DT_WORK_ORDER,101) DT_WORK_ORDER
			, CONVERT(VARCHAR, KWO.DT_WORK_ORDER, 108) DT_INITIAL_TIME
			, KWO.KY_STATUS
			--, KPA.ID_PALLET
			--, KPA.NO_PALLET
			--, KPA.KY_STATUS AS KY_STATUS_PALLET
			, 0 AS ID_PALLET
			, 0 AS NO_PALLET
			, '' AS KY_STATUS_PALLET
			,(SELECT Substring((SELECT ((', ' + RTRIM(LTRIM(KP.NO_PALLET)))) FROM PRD.K_PALLET KP WHERE KP.ID_WORK_ORDER = KWO.ID_WORK_ORDER AND KP.FG_SEND_FORM = 1 FOR XML PATH ( '' )), 3, 1000 )) AS NO_PALLETS
			, @V_WORK_ORDER_PROGRESS AS DS_PROGRESS_WORK_ORDER
			, KWO.NO_ORDER
			, 
			 (
				SELECT NM_TRANSITION AS li
				FROM PRD.K_WORK_ORDER_TRANSITIONS WOT
					WHERE WOT.ID_WORK_ORDER = KWO.ID_WORK_ORDER
				FOR XML RAW (''), ROOT ('ul'), ELEMENTS
			 ) AS DS_TRANSITIONS
		FROM PRD.K_WORK_ORDER KWO
			INNER JOIN PRD.C_ITEM CI ON KWO.ID_ITEM = CI.ID_ITEM
			INNER JOIN PRD.C_PRODUCTION_LINE CPL ON KWO.ID_PRODUCTION_LINE = CPL.ID_PRODUCTION_LINE
			INNER JOIN PRD.K_QA27 KQA ON KWO.ID_WORK_ORDER = KQA.ID_WORK_ORDER 
			 LEFT JOIN ADM.C_USER CU ON KQA.ID_LEADMAN = CU.ID_EMPLOYEE
		WHERE EXISTS (SELECT TOP 1 1 FROM @T_WORK_ORDER_STATUS TWOS WHERE TWOS.KY_WORK_ORDER_STATUS = KWO.KY_STATUS AND TWOS.KY_WORK_ORDER_STATUS = 'RUNNING')
			AND (@PIN_ID_WORK_ORDER IS NULL OR(@PIN_ID_WORK_ORDER IS NOT NULL AND KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER ))
			AND (@PIN_ID_QA27 IS NULL OR(@PIN_ID_QA27 IS NOT NULL AND KQA.ID_QA27 = @PIN_ID_QA27 ))
			AND (@PIN_ID_BRANCH_PLANT IS NULL OR(@PIN_ID_BRANCH_PLANT IS NOT NULL AND KWO.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT ))
			AND (@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND KWO.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE ))
			AND KQA.KY_STATUS = 'RUNNING'
			AND (@PIN_ID_LEADMAN IS NULL OR (@PIN_ID_LEADMAN IS NOT NULL AND KQA.ID_LEADMAN = @PIN_ID_LEADMAN ))

		UNION ALL

		-- THIS QUERY IS ONLY FOR SKIPPED WORK ORDERS
		SELECT KWO.NO_WORK_ORDER
			, KWO.ID_WORK_ORDER
			, NULL AS ID_QA27
			, '' AS KY_USER
			, KWO.KY_CUSTOMER
			, KWO.NM_CUSTOMER
			, CI.ID_ITEM
			, CI.KY_ITEM
			, CI.NM_ITEM
			, CPL.ID_PRODUCTION_LINE
			, CPL.KY_PRODUCTION_LINE
			, CPL.NM_PRODUCTION_LINE
			, KWO.NM_MATERIAL
			, KWO.NM_COLOR
			,(KWO.NO_RUN_QTY + KWO.NO_QTY_ADDED) AS NO_RUN_QTY
			, KWO.NO_LENGHT
			, KWO.NO_WIDTH
			, KWO.NO_THICKNESS
			, KWO.NO_ASSIGNED_TIME NO_ASSIGNED_TIME
			, CONVERT(VARCHAR(10),KWO.DT_WORK_ORDER,101) DT_WORK_ORDER
			, CONVERT(VARCHAR, KWO.DT_WORK_ORDER, 108) DT_INITIAL_TIME
			, KWO.KY_STATUS
			--, KPA.ID_PALLET
			--, KPA.NO_PALLET
			--, KPA.KY_STATUS AS KY_STATUS_PALLET
			, 0 AS ID_PALLET
			, 0 AS NO_PALLET
			, '' AS KY_STATUS_PALLET
			,(SELECT Substring((SELECT ((', ' + RTRIM(LTRIM(KP.NO_PALLET)))) FROM PRD.K_PALLET KP WHERE KP.ID_WORK_ORDER = KWO.ID_WORK_ORDER AND KP.FG_SEND_FORM = 1 FOR XML PATH ( '' )), 3, 1000 )) AS NO_PALLETS
			, @V_WORK_ORDER_PROGRESS AS DS_PROGRESS_WORK_ORDER
			, KWO.NO_ORDER
			,
			 (
				SELECT NM_TRANSITION AS li
				FROM PRD.K_WORK_ORDER_TRANSITIONS WOT
					WHERE WOT.ID_WORK_ORDER = KWO.ID_WORK_ORDER
				FOR XML RAW (''), ROOT ('ul'), ELEMENTS
			 ) AS DS_TRANSITIONS
		FROM PRD.K_WORK_ORDER KWO
			INNER JOIN PRD.C_ITEM CI ON KWO.ID_ITEM = CI.ID_ITEM
			INNER JOIN PRD.C_PRODUCTION_LINE CPL ON KWO.ID_PRODUCTION_LINE = CPL.ID_PRODUCTION_LINE
		WHERE EXISTS (SELECT TOP 1 1 FROM @T_WORK_ORDER_STATUS TWOS WHERE TWOS.KY_WORK_ORDER_STATUS = KWO.KY_STATUS AND TWOS.KY_WORK_ORDER_STATUS NOT IN ('RUNNING'))
			AND (@PIN_ID_WORK_ORDER IS NULL OR(@PIN_ID_WORK_ORDER IS NOT NULL AND KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER ))
			AND (@PIN_ID_BRANCH_PLANT IS NULL OR(@PIN_ID_BRANCH_PLANT IS NOT NULL AND KWO.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT ))
			AND (@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND KWO.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE ))
	) WO
	ORDER BY WO.KY_STATUS, WO.NO_ORDER, WO.ID_WORK_ORDER



/*
	SELECT KWO.NO_WORK_ORDER
		, KWO.ID_WORK_ORDER
		, KQA.ID_QA27
		, CU.KY_USER
		, KWO.KY_CUSTOMER
		, KWO.NM_CUSTOMER
		, CI.ID_ITEM
		, CI.KY_ITEM
		, CI.NM_ITEM
		, CPL.ID_PRODUCTION_LINE
		, CPL.KY_PRODUCTION_LINE
		, CPL.NM_PRODUCTION_LINE
		, KWO.NM_MATERIAL
		, KWO.NM_COLOR
		, KWO.NO_RUN_QTY
		, KWO.NO_LENGHT
		, KWO.NO_WIDTH
		, KWO.NO_THICKNESS
		, (KWO.NO_ASSIGNED_TIME + ISNULL(KWO.NO_STANDARD_TIME,0)) NO_ASSIGNED_TIME
		, CONVERT(VARCHAR(10),KWO.DT_WORK_ORDER,101) DT_WORK_ORDER
		, CONVERT(VARCHAR, KWO.DT_WORK_ORDER, 108) DT_INITIAL_TIME
		, KWO.KY_STATUS
		--, KPA.ID_PALLET
		--, KPA.NO_PALLET
		--, KPA.KY_STATUS AS KY_STATUS_PALLET
		, 0 AS ID_PALLET
		, 0 AS NO_PALLET
		, '' AS KY_STATUS_PALLET
		,(SELECT Substring((SELECT ((', ' + RTRIM(LTRIM(KP.NO_PALLET)))) FROM PRD.K_PALLET KP WHERE KP.ID_WORK_ORDER = KWO.ID_WORK_ORDER AND KP.KY_STATUS = @PIN_KY_STATUS_PALLET FOR XML PATH ( '' )), 3, 1000 )) AS NO_PALLETS
		, @V_WORK_ORDER_PROGRESS AS DS_PROGRESS_WORK_ORDER
	FROM PRD.K_WORK_ORDER KWO
		INNER JOIN PRD.C_ITEM CI 
			ON KWO.ID_ITEM = CI.ID_ITEM
		INNER JOIN PRD.C_PRODUCTION_LINE CPL 
			ON KWO.ID_PRODUCTION_LINE = CPL.ID_PRODUCTION_LINE
		LEFT OUTER JOIN PRD.K_QA27 KQA 
			ON KWO.ID_WORK_ORDER = KQA.ID_WORK_ORDER 
			--AND KQA.KY_STATUS = @PIN_KY_STATUS_QA27
		LEFT JOIN ADM.C_USER CU
			ON KQA.ID_LEADMAN = CU.ID_EMPLOYEE
		--LEFT OUTER JOIN PRD.K_PALLET KPA  ON KPA.ID_WORK_ORDER = KWO.ID_WORK_ORDER  AND KPA.KY_STATUS = @PIN_KY_STATUS_PALLET
	WHERE EXISTS (SELECT TOP 1 1 FROM @T_WORK_ORDER_STATUS TWOS WHERE TWOS.KY_WORK_ORDER_STATUS = KWO.KY_STATUS)
		AND (@PIN_ID_WORK_ORDER IS NULL OR(@PIN_ID_WORK_ORDER IS NOT NULL AND KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER ))
		AND (@PIN_ID_QA27 IS NULL OR(@PIN_ID_QA27 IS NOT NULL AND KQA.ID_QA27 = @PIN_ID_QA27 ))
		AND (@PIN_ID_BRANCH_PLANT IS NULL OR(@PIN_ID_BRANCH_PLANT IS NOT NULL AND KWO.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT ))
		AND (@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND KWO.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE ))
		AND (@PIN_KY_STATUS_QA27 IS NULL OR (@PIN_KY_STATUS_QA27 IS NOT NULL AND KQA.KY_STATUS = @PIN_KY_STATUS_QA27 ))
		AND (@PIN_ID_LEADMAN IS NULL OR (@PIN_ID_LEADMAN IS NOT NULL AND KQA.ID_LEADMAN = @PIN_ID_LEADMAN ))
	ORDER BY KWO.KY_STATUS, KWO.NO_ORDER, KWO.ID_WORK_ORDER
	*/
