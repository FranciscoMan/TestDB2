﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 4/04/2017
-- Description: get all WORKS ORDERS to Get All Work orders screen
-- =============================================
-- 07/24/2018 GVT Add the new column for the number of new pieces after work order completed
-- 10/31/2018 JDR Se agregan los parámetros para filtrar con base en un rango de fechas
-- =============================================

CREATE PROCEDURE  [PRD].[SPE_GET_ALL_WORK_ORDERS] 
	@PIN_ID_BRANCH_PLANT AS int = NULL,
	@PIN_ID_WORK_ORDER AS int = NULL,
	@PIN_NO_WORK_ORDER AS int NULL,
	@PIN_KY_STATUS AS nvarchar(50) = NULL,
	@PIN_ID_PRODUCTION_LINE AS int = NULL,
	@PIN_DT_INITIAL DATETIME = NULL,
	@PIN_DT_FINAL DATETIME = NULL,
	@PIN_XML_STATUS XML
AS  
BEGIN
	DECLARE @DT_LAST_FORM DATETIME
		, @DT_SYSTEM DATETIME = GETDATE()
	
	DECLARE @T_STATUS TABLE (
		KY_STATUS NVARCHAR(50)
	)

	IF @PIN_XML_STATUS IS NOT NULL BEGIN
		INSERT INTO @T_STATUS (KY_STATUS)
		SELECT c.value('@KY_STATUS', 'NVARCHAR(50)')
		FROM @PIN_XML_STATUS.nodes('/STATUSES/STATUS') X(C)
	END

	IF @PIN_ID_WORK_ORDER IS NOT NULL BEGIN
		SET @DT_LAST_FORM = (SELECT TOP 1 DT_FORM FROM PRD.K_FORM KF WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER AND DT_CLOSED IS NOT NULL)
	END

	DECLARE @T_WORK_ORDER TABLE (
		ID_WORK_ORDER INT
		, KY_CUSTOMER NVARCHAR(50)
		, NM_CUSTOMER NVARCHAR(200)
		, NO_WORK_ORDER INT
		, NO_ASSIGNED_TIME INT
		, NO_ASSIGNED_TIME_HRS DECIMAL(29,16)
		, ID_ITEM INT
		, KY_ITEM NVARCHAR(50)
		, NM_ITEM NVARCHAR(100)
		, ID_BRANCH_PLANT INT
		, NM_BRANCH_PLANT NVARCHAR(300)
		, ID_PRODUCTION_LINE INT
		, KY_PRODUCTION_LINE NVARCHAR(50)
		, NM_PRODUCTION_LINE NVARCHAR(300)
		, DT_WORK_ORDER DATETIME
		, DT_START_WORK_ORDER DATETIME
		, NO_RUN_QTY INT
		, NO_QTY_ADDED INT
		, NO_BOX_QTY INT
		, NM_MATERIAL NVARCHAR(200)
		, NM_COLOR NVARCHAR(100)
		, NO_LENGHT FLOAT
		, NO_WIDTH FLOAT
		, NO_THICKNESS FLOAT
		, NO_POUNDS FLOAT
		, KY_PACKAGE NVARCHAR(50)
		, PACKED INT
		, DT_REQ_DATE DATETIME
		, NO_ORDER INT
		, NO_SEQ INT
		, NO_HRS_LABOR_MACHINE INT
		, NO_QTY_SKID FLOAT
		, DT_ORDER DATETIME
		, NO_SHIPING_WEIGHT_PER_HR FLOAT
		, KY_UPC NVARCHAR(20)
		, KY_STATUS NVARCHAR(50)
		, ID_WORK_ORDER_ORIGIN INT
		, ID_PALLET INT
		, DT_CLOSE_WORK_ORDER DATETIME
		, DT_LAST_FORM DATETIME
		, NM_WORK_ORDER_STATUS VARCHAR(85)
		, NO_SAVED_SKIDS INT
	)

	INSERT INTO @T_WORK_ORDER (
		ID_WORK_ORDER
		, KY_CUSTOMER
		, NM_CUSTOMER
		, NO_WORK_ORDER
		, NO_ASSIGNED_TIME
		, NO_ASSIGNED_TIME_HRS
		, ID_ITEM
		, KY_ITEM
		, NM_ITEM
		, ID_BRANCH_PLANT
		, NM_BRANCH_PLANT
		, ID_PRODUCTION_LINE
		, KY_PRODUCTION_LINE
		, NM_PRODUCTION_LINE
		, DT_WORK_ORDER
		, DT_START_WORK_ORDER
		, NO_RUN_QTY
		, NO_QTY_ADDED
		, NO_BOX_QTY
		, NM_MATERIAL
		, NM_COLOR
		, NO_LENGHT
		, NO_WIDTH
		, NO_THICKNESS
		, NO_POUNDS
		, KY_PACKAGE
		, PACKED
		, DT_REQ_DATE
		, NO_ORDER
		, NO_SEQ
		, NO_HRS_LABOR_MACHINE
		, NO_QTY_SKID
		, DT_ORDER
		, NO_SHIPING_WEIGHT_PER_HR
		, KY_UPC
		, KY_STATUS
		, ID_WORK_ORDER_ORIGIN
		, ID_PALLET
		, DT_CLOSE_WORK_ORDER
		, DT_LAST_FORM
		, NM_WORK_ORDER_STATUS
		, NO_SAVED_SKIDS
	)
	SELECT KWO.ID_WORK_ORDER
		, KWO.KY_CUSTOMER
		, KWO.NM_CUSTOMER
		, KWO.NO_WORK_ORDER
		, KWO.NO_ASSIGNED_TIME
		, KWO.NO_ASSIGNED_TIME_HRS
		, KWO.ID_ITEM
		, CI.KY_ITEM
		, KWO.NM_ITEM
		, KWO.ID_BRANCH_PLANT
		, CBP.NM_BRANCH_PLANT
		, KWO.ID_PRODUCTION_LINE
		, CPL.KY_PRODUCTION_LINE
		, KWO.NM_PRODUCTION_LINE
		, KWO.DT_WORK_ORDER
		, KWO.DT_START_WORK_ORDER
		, KWO.NO_RUN_QTY
		, ISNULL(KWO.NO_QTY_ADDED, 0) AS NO_QTY_ADDED
		, KWO.NO_BOX_QTY
		, KWO.NM_MATERIAL
		, KWO.NM_COLOR
		, KWO.NO_LENGHT
		, KWO.NO_WIDTH
		, KWO.NO_THICKNESS
		, KWO.NO_POUNDS
		, KWO.KY_PACKAGE
		, KWO.PACKED
		, KWO.DT_REQ_DATE
		, KWO.NO_ORDER
		, KWO.NO_SEQ
		, KWO.NO_HRS_LABOR_MACHINE
		, KWO.NO_QTY_SKID
		, KWO.DT_ORDER
		, KWO.NO_SHIPING_WEIGHT_PER_HR
		, KWO.KY_UPC
		, KWO.KY_STATUS
		, KWO.ID_WORK_ORDER_ORIGIN
		, KWO.ID_PALLET
		, KWO.DT_CLOSE_WORK_ORDER
		, @DT_LAST_FORM AS DT_LAST_FORM
		, WOS.NM_WORK_ORDER_STATUS
		, 0 AS NO_SAVED_SKIDS
	FROM PRD.K_WORK_ORDER KWO
		INNER JOIN ADM.VW_C_WORK_ORDER_STATUS WOS
			ON KY_STATUS = WOS.KY_WORK_ORDER_STATUS
		INNER JOIN ADM.C_BRANCH_PLANT CBP
			ON KWO.ID_BRANCH_PLANT = CBP.ID_BRANCH_PLANT
		INNER JOIN PRD.C_ITEM CI
			ON KWO.ID_ITEM = CI.ID_ITEM
		INNER JOIN PRD.C_PRODUCTION_LINE CPL
			ON KWO.ID_PRODUCTION_LINE = CPL.ID_PRODUCTION_LINE
	WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR CBP.ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND CBP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT ))
		AND (@PIN_ID_WORK_ORDER IS NULL OR (@PIN_ID_WORK_ORDER IS NOT NULL AND KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER))
		AND (@PIN_NO_WORK_ORDER IS NULL OR (@PIN_NO_WORK_ORDER IS NOT NULL AND KWO.NO_WORK_ORDER = @PIN_NO_WORK_ORDER))
		AND (@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND CPL.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE))
		AND (@PIN_KY_STATUS IS NULL OR (@PIN_KY_STATUS IS NOT NULL AND KWO.KY_STATUS = @PIN_KY_STATUS ))
		AND (@PIN_DT_INITIAL IS NULL OR (@PIN_DT_INITIAL IS NOT NULL AND CAST(KWO.DT_START_WORK_ORDER AS DATE) BETWEEN CAST(@PIN_DT_INITIAL AS DATE) AND CAST(ISNULL(@PIN_DT_FINAL, @DT_SYSTEM) AS DATE) ))
		AND (@PIN_XML_STATUS IS NULL OR (@PIN_XML_STATUS IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM @T_STATUS TS WHERE KWO.KY_STATUS = TS.KY_STATUS)))
	ORDER BY DT_WORK_ORDER DESC

	; WITH T_SAVED_SKIDS AS (
		SELECT ID_WORK_ORDER, COUNT(1) AS NO_SAVED_SKIDS
		FROM PRD.K_PALLET KP
			INNER JOIN ADM.VW_C_PALLET_STATUS PS 
				ON KP.KY_STATUS = PS.KY_PALLET_STATUS 
				AND PS.FG_FOR_SAVE = 1
		WHERE EXISTS (SELECT TOP 1 1 FROM @T_WORK_ORDER TWO WHERE TWO.ID_WORK_ORDER = KP.ID_WORK_ORDER)
		GROUP BY ID_WORK_ORDER
	)
	UPDATE TWO
	SET NO_SAVED_SKIDS = TSS.NO_SAVED_SKIDS
	FROM @T_WORK_ORDER TWO
		INNER JOIN T_SAVED_SKIDS TSS
			ON TWO.ID_WORK_ORDER = TSS.ID_WORK_ORDER

	SELECT TW.ID_WORK_ORDER
		, KY_CUSTOMER
		, NM_CUSTOMER
		, NO_WORK_ORDER
		, NO_ASSIGNED_TIME
		, NO_ASSIGNED_TIME_HRS
		, ID_ITEM
		, KY_ITEM
		, NM_ITEM
		, ID_BRANCH_PLANT
		, NM_BRANCH_PLANT
		, ID_PRODUCTION_LINE
		, KY_PRODUCTION_LINE
		, NM_PRODUCTION_LINE
		, DT_WORK_ORDER
		, DT_START_WORK_ORDER
		, NO_RUN_QTY
		, NO_QTY_ADDED
		, NO_BOX_QTY
		, NM_MATERIAL
		, NM_COLOR
		, NO_LENGHT
		, NO_WIDTH
		, NO_THICKNESS
		, NO_POUNDS
		, KY_PACKAGE
		, PACKED
		, DT_REQ_DATE
		, TW.NO_ORDER
		, NO_SEQ
		, NO_HRS_LABOR_MACHINE
		, NO_QTY_SKID
		, DT_ORDER
		, NO_SHIPING_WEIGHT_PER_HR
		, KY_UPC
		, TW.KY_STATUS
		, ID_WORK_ORDER_ORIGIN
		, ID_PALLET
		, DT_CLOSE_WORK_ORDER
		, DT_LAST_FORM
		, NM_WORK_ORDER_STATUS
		, NO_SAVED_SKIDS
		,ID_QA27
	FROM @T_WORK_ORDER TW
	INNER JOIN PRD.K_QA27 Q ON Q.ID_QA27= (SELECT TOP 1 ID_QA27 FROM PRD.K_QA27 WHERE ID_WORK_ORDER=TW.ID_WORK_ORDER ORDER BY ID_QA27 DESC)

	ORDER BY DT_WORK_ORDER DESC

END

