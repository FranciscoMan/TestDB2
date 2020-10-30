﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- Create date: 09/18/2018
-- Description: Get readings for report
-- =============================================
-- 11/06/2018 JDR The query is rewritten to deliver the results according to version 2.1 of the report, check mail 11/05/2018
-- 12/03/2018 JDR Out-of-range columns are added
-- 09/30/2020 Maintenance by AA
-- =============================================
CREATE PROCEDURE  [PRD].[SPE_GET_RPT_READINGS]
	@PIN_DT_INITIAL DATE
	, @PIN_DT_FINAL DATE
	, @PIN_CHARACTERISTIC VARCHAR(50) 
	, @PIN_ID_PRODUCTION_LINE INT
	, @PIN_KY_ITEM NVARCHAR(50)
	, @PIN_ID_BRANCH_PLANT INT
AS
BEGIN
	DECLARE @FG_LINE_OPT VARCHAR(80) = NULL
	 IF(@PIN_ID_BRANCH_PLANT = 17)
	 BEGIN
		SET @FG_LINE_OPT = 'LINE_OPT'
	 END

	SELECT @PIN_ID_PRODUCTION_LINE = NULLIF(@PIN_ID_PRODUCTION_LINE, 0)
		--, @PIN_ID_WORK_ORDER = NULLIF(@PIN_ID_WORK_ORDER, NULL)
		, @PIN_KY_ITEM = NULLIF(@PIN_KY_ITEM, '')

	; WITH T_READINGS AS (
			SELECT 
			ISNULL(REPLACE(KS.KY_SHIFT_TIME, 'SF-', ''), (SELECT TOP 1 SHIFT_WORD FROM ADM.C_CALENDAR  C WHERE    KQ.DT_INITIAL_TIME   BETWEEN  C.CALENDAR_DATE AND DATEADD(HOUR, 12,C.CALENDAR_DATE ))) AS KY_SHIFT_TIME   
			, KWO.ID_WORK_ORDER
			, KWO.KY_CUSTOMER
			, KWO.NM_CUSTOMER
			, CI.KY_ITEM
			, CI.NM_ITEM
			, KP.NO_PALLET
			, CM.NM_METRICS
			, VCP.KY_PROCESS
			, KF.DT_FORM
			, KF.DT_CLOSED
			, KF.KY_STATUS_FORM
			, LS.KY_USER_APP_CREATION   
			, CPL.NM_PRODUCTION_LINE
			, KP.DT_INITIAL_TIME
			, CASE @PIN_CHARACTERISTIC
			WHEN 'Length' THEN  LS.NO_LENGTH_VALUE
			WHEN 'Width' THEN  LS.NO_WIDTH_VALUE
			WHEN 'Weight' THEN LS.NO_WEIGHT_VALUE
			ELSE  LS.NO_THICKNESS_VALUE  END  AS FINISHED_VALUE
			, XML_METRICS_VALUE.value('(/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'NVARCHAR(MAX)') AS NOMINAL_VALUE
			, CASE XML_METRICS_VALUE.value('(/FIELD_TYPES/@HYSTERESIS)[1]', 'NVARCHAR(20)')
							WHEN 'ABS' THEN 
								CASE WHEN XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'FLOAT') 
									BETWEEN XML_METRICS_VALUE.value('(/FIELD_TYPES/@LOWER_LIMIT)[1]', 'FLOAT') 
										AND XML_METRICS_VALUE.value('(/FIELD_TYPES/@UPPER_LIMIT)[1]', 'FLOAT') 
									THEN XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'FLOAT') 
									ELSE 0
								END
							WHEN 'PCT' THEN
								 XML_METRICS_VALUE.value('(/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'FLOAT') * 
								 (1 + (XML_METRICS_VALUE.value('(/FIELD_TYPES/@UPPER_LIMIT)[1]', 'FLOAT') / 100))
							WHEN 'REL' THEN
								 XML_METRICS_VALUE.value('(/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'FLOAT') +
								 XML_METRICS_VALUE.value('(/FIELD_TYPES/@UPPER_LIMIT)[1]', 'FLOAT')
							ELSE 0
						END AS UPPER_LIMIT
			, CASE XML_METRICS_VALUE.value('(/FIELD_TYPES/@HYSTERESIS)[1]', 'NVARCHAR(20)')
							WHEN 'ABS' THEN 
								CASE WHEN XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'FLOAT') 
									BETWEEN XML_METRICS_VALUE.value('(/FIELD_TYPES/@LOWER_LIMIT)[1]', 'FLOAT') 
										AND XML_METRICS_VALUE.value('(/FIELD_TYPES/@UPPER_LIMIT)[1]', 'FLOAT') 
									THEN XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'FLOAT') 
									ELSE 0
								END
							WHEN 'PCT' THEN
								XML_METRICS_VALUE.value('(/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'FLOAT') * (1 -
								(XML_METRICS_VALUE.value('(/FIELD_TYPES/@LOWER_LIMIT)[1]', 'FLOAT') / 100))
							WHEN 'REL' THEN
								 XML_METRICS_VALUE.value('(/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'FLOAT') - 
								 XML_METRICS_VALUE.value('(/FIELD_TYPES/@LOWER_LIMIT)[1]', 'FLOAT')
							ELSE 0
						END AS LOWER_LIMIT
			,  XML_METRICS_VALUE.value('(/FIELD_TYPES/@HYSTERESIS)[1]', 'NVARCHAR(20)') AS HYSTERESIS
			, KFM.ID_K_FORM
		FROM PRD.K_WORK_ORDER KWO
			INNER JOIN ADM.C_BRANCH_PLANT CBP
				ON KWO.ID_BRANCH_PLANT = CBP.ID_BRANCH_PLANT 
			INNER JOIN PRD.C_ITEM CI
				ON CI.ID_ITEM = KWO.ID_ITEM
			INNER JOIN PRD.K_PALLET KP
				ON KWO.ID_WORK_ORDER = KP.ID_WORK_ORDER
			INNER JOIN PRD.K_QA27 KQ
				ON KP.ID_QA27 = KQ.ID_QA27
			INNER JOIN PRD.K_SHIFT KS
				ON KQ.ID_SHIFT = KS.ID_SHIFT
			INNER JOIN PRD.C_PRODUCTION_LINE CPL
				ON KS.ID_PRODUCTION_LINE = CPL.ID_PRODUCTION_LINE
			INNER JOIN ADM.VW_C_PROCESS VCP
				ON VCP.KY_PROCESS IN ('QUALITY', 'MANUFACTURE')
			LEFT JOIN PRD.K_FORM KF 
				ON KF.ID_WORK_ORDER = KWO.ID_WORK_ORDER
				AND KF.ID_PALLET = KP.ID_PALLET
				AND KF.KY_PROCESS_TYPE = VCP.KY_PROCESS
			LEFT JOIN ADM.C_USER CU
				ON CU.KY_USER = KF.KY_USER_APP_UPDATE
			LEFT JOIN PRD.K_FORM_METRICS KFM 
				ON KF.ID_K_FORM = KFM.ID_K_FORM
				AND KF.KY_STATUS_FORM != 'CANCELLED' AND
				KFM.XML_METRICS_VALUE.value('(/FIELD_TYPES/@FIELD_TYPE)[1]', 'NVARCHAR(20)') = 'NUMERICBOX'
		LEFT JOIN PRD.C_METRICS CM
				ON CM.ID_METRICS = KFM.ID_METRICS 
				INNER JOIN LAB.K_SAMPLE LS ON LS.NO_WORK_ORDER = KWO.ID_WORK_ORDER  


		WHERE 
		    LS.KY_USER_APP_UPDATE IS NOT NULL AND 
			KFM.XML_METRICS_VALUE.value('(/FIELD_TYPES/@READING_VALUE)[1]', 'NVARCHAR(20)') IS NOT NULL AND 
		    --CM.NM_METRICS =  CASE WHEN @PIN_CHARACTERISTIC IS NULL THEN 'Weight' ELSE @PIN_CHARACTERISTIC END  AND
		    CAST(KP.DT_INITIAL_TIME AS DATE) BETWEEN @PIN_DT_INITIAL AND @PIN_DT_FINAL
			AND (@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND KS.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE))
			AND (@PIN_KY_ITEM IS NULL OR (@PIN_KY_ITEM IS NOT NULL AND CI.KY_ITEM = @PIN_KY_ITEM))
			AND (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND CBP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
			AND (@PIN_CHARACTERISTIC IS NULL OR  (@PIN_CHARACTERISTIC  IS NOT NULL AND  CM.NM_METRICS = @PIN_CHARACTERISTIC))
	    )

	SELECT TR.KY_SHIFT_TIME
		, TR.ID_WORK_ORDER
		, TR.KY_CUSTOMER
		, TR.NM_CUSTOMER
		, TR.KY_ITEM
		, TR.NM_ITEM
		, TR.NO_PALLET
		, TR.NM_METRICS
		, TR.KY_PROCESS
		, CONVERT(DATE, TR.DT_CLOSED) AS DT_CLOSED
		, CONVERT(VARCHAR, CONVERT(TIME, TR.DT_CLOSED), 108) AS TIME
		, TR.KY_STATUS_FORM
		, TR.KY_USER_APP_CREATION AS NM_USER
		, TR.NM_PRODUCTION_LINE
		, TR.FINISHED_VALUE AS FINISHED_VALUE
		, CONVERT(VARCHAR,CONVERT(DECIMAL(10,4),TR.NOMINAL_VALUE)) AS NOMINAL_VALUE
		, CONVERT(VARCHAR,CONVERT(DECIMAL(10,4),TR.LOWER_LIMIT)) AS LOWER_LIMIT
		, CONVERT(VARCHAR,CONVERT(DECIMAL(10,4),TR.UPPER_LIMIT)) AS UPPER_LIMIT
		, TR.HYSTERESIS
	FROM T_READINGS TR
	ORDER BY TR.DT_INITIAL_TIME, TR.NO_PALLET, TR.DT_FORM
END