﻿
-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 06/04/2017
-- Description: get qa27 header data.
-- =============================================
-- 12/13/2018 JDR The column DT_FINAL_TIME_QA27 is added
-- 01/29/2019 JDR Queries are added to determine which will be the next QA27 record to query
-- 01/30/2019 JDR The query is added to determine which is the foreman of the QA27 record
-- 06/21/2019 The procedure was optimized so that it would give a better answer and perform the search by production line.
-- 06/25/2019 The fields are added, CARTON ITEM, USAGE, SCRAP, UPC. by patto
-- 01/16/2020 Best foreman in shift was added. by Aideé Alvarez.
-- 01/23/2020 Additional column added in last select to see what is the status of Paper Copy. by Aideé Alvarez
-- 01/27/2020 A little change in gets carton by work order. by Aideé Alvarez
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_QA27_HEADER] 
	--@PIN_KY_STATUS_WORK_ORDER AS XML
	  @PIN_ID_QA27 INT,
	  @PIN_ID_BRANCH_PLANT INT
	, @PIN_KY_NAVIGATION_ACTION NVARCHAR(30)

AS  
	/*CREATE TABLE #T_WORK_ORDER_STATUS (
		KY_WORK_ORDER_STATUS NVARCHAR(20))*/

	DECLARE @V_ID_METRIC_LENGTH AS INT
		, @V_ID_METRIC_WIDTH AS INT
		, @V_ID_METRIC_THICKNESS AS INT
		, @V_ID_METRIC_WEIGHT AS INT
		, @V_ID_WORK_ORDER AS INT
		, @V_AVG_WEIGHT_FORMS_QA27 AS DECIMAL(13,7)
		, @V_AVG_LBS_PER_HOUR_FORMS_QA27 AS FLOAT
		, @V_ID_LBS_PER_HOUR_METRIC AS INT
		, @ID_PRODUCTION_LINE INT
		, @DT_SYSTEM DATETIME = GETDATE()
		, @DT_INITIAL DATETIME
		, @DT_FINAL DATETIME
		, @ID_QA27_PREVIOUS INT
		, @ID_QA27_NEXT INT
		, @NO_SUM_LINE_RATE_PER_MINUTE DECIMAL (13,4)
		, @NO_TOTAL_MINUTES_RUNNING DECIMAL(13,4)
		, @KY_CUSTOMER NVARCHAR(50)
		, @ID_ITEM INT
		, @ID_FOREMAN INT
		, @NM_FOREMAN NVARCHAR(300)
		-- NEW FIELDS ARE ADD
		, @NM_CARTON NVARCHAR(300) 
		, @NO_USAGE INT = -1
		, @NO_SCRAP INT = -1
		, @UPC INT
		, @SHIFT_QA27 VARCHAR(80)

	SET @PIN_ID_BRANCH_PLANT = NULL

	SELECT @PIN_ID_BRANCH_PLANT = WO.ID_BRANCH_PLANT
		, @V_ID_WORK_ORDER = WO.ID_WORK_ORDER
		, @DT_INITIAL = QA.DT_INITIAL_TIME
		, @DT_FINAL = ISNULL(QA.DT_FINAL_TIME, @DT_SYSTEM)
		, @ID_PRODUCTION_LINE = KS.ID_PRODUCTION_LINE
		, @KY_CUSTOMER = WO.KY_CUSTOMER
		FROM PRD.K_QA27 QA
		INNER JOIN PRD.K_WORK_ORDER WO 
			ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER
		INNER JOIN PRD.K_SHIFT KS
			ON QA.ID_SHIFT = KS.ID_SHIFT
	WHERE QA.ID_QA27 = @PIN_ID_QA27


	--#$$%%$#%$#%$#%$#%$#%$#%$#%$#%$##%$#%$#%#%$#%$#% DEBUG 
	-- GET LAST QA27 RECORD FOR THE PRODUCTION LINE
	IF @PIN_KY_NAVIGATION_ACTION = 'PREVIOUS_BY_LINE' BEGIN
		SELECT TOP 1 @PIN_ID_QA27 = KQ.ID_QA27
		FROM PRD.K_QA27 KQ
			INNER JOIN PRD.K_SHIFT KS
				ON KQ.ID_SHIFT = KS.ID_SHIFT
		WHERE KQ.DT_INITIAL_TIME < @DT_INITIAL
			AND KS.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
		ORDER BY KQ.DT_INITIAL_TIME DESC
	END
	--GET NEXT QA27 RECORD FOR THE PRODUCTION LINE
	IF @PIN_KY_NAVIGATION_ACTION = 'NEXT_BY_LINE' BEGIN
		SELECT TOP 1 @PIN_ID_QA27 = KQ.ID_QA27
		FROM PRD.K_QA27 KQ
			INNER JOIN PRD.K_SHIFT KS
				ON KQ.ID_SHIFT = KS.ID_SHIFT
		WHERE KQ.DT_INITIAL_TIME > @DT_INITIAL
			AND KS.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
		ORDER BY KQ.DT_INITIAL_TIME ASC
	END



	SELECT @ID_ITEM = WO.ID_ITEM
	FROM PRD.K_QA27 QA
		INNER JOIN PRD.K_WORK_ORDER WO 
			ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER
	WHERE QA.ID_QA27 = @PIN_ID_QA27
	


	-- A PARTIR DE LA QA27 SE BUSCA EL FOREMAN.
	SELECT @PIN_ID_BRANCH_PLANT = WO.ID_BRANCH_PLANT
		, @V_ID_WORK_ORDER = WO.ID_WORK_ORDER
		, @DT_INITIAL = QA.DT_INITIAL_TIME
		, @DT_FINAL = ISNULL(QA.DT_FINAL_TIME, @DT_SYSTEM)
		, @ID_PRODUCTION_LINE = KS.ID_PRODUCTION_LINE
		, @ID_FOREMAN = QA.ID_FOREMAN
		, @NM_FOREMAN = QA.NM_FOREMAN
		, @SHIFT_QA27 = QA.KY_SHIFT
	FROM PRD.K_QA27 QA
		INNER JOIN PRD.K_WORK_ORDER WO 
			ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER
		INNER JOIN PRD.K_SHIFT KS
			ON QA.ID_SHIFT = KS.ID_SHIFT
	WHERE QA.ID_QA27 = @PIN_ID_QA27



	IF EXISTS (SELECT 1 FROM PRD.K_WORK_ORDER_CARTON WO_CARTON
				INNER JOIN PRD.K_WORK_ORDER WO
				ON WO.ID_WORK_ORDER = WO_CARTON.ID_WORK_ORDER	
				WHERE WO.ID_WORK_ORDER = @V_ID_WORK_ORDER)
BEGIN

 SET @NM_CARTON = (SELECT SUBSTRING( 
( 
     SELECT '|| ' + NM_VALUE_CATALOG AS 'data()' 
         FROM PRD.K_WORK_ORDER W
INNER JOIN  PRD.C_CARTON_ITEM CI ON  CI.ID_ITEM = W.ID_ITEM
INNER JOIN  ADM.C_VALUE_CATALOG CV ON CI.ID_CARTON =  CV.ID_VALUE_CATALOG
WHERE ID_WORK_ORDER = @V_ID_WORK_ORDER FOR XML PATH('') 
), 2 , 9999) As CARTON_ITEM_Q)

	SELECT @NO_SCRAP = SUM (NO_SCRAP)
	FROM PRD.K_WORK_ORDER_CARTON WO_CARTON 
	 WHERE WO_CARTON .ID_WORK_ORDER =@V_ID_WORK_ORDER GROUP BY ID_WORK_ORDER

   END
ELSE BEGIN
   SET @NM_CARTON = (SELECT SUBSTRING( 
( 
     SELECT '|| ' + NM_VALUE_CATALOG AS 'data()' 
         FROM PRD.K_WORK_ORDER W
INNER JOIN  PRD.C_CARTON_ITEM CI ON  CI.ID_ITEM = W.ID_ITEM
INNER JOIN  ADM.C_VALUE_CATALOG CV ON CI.ID_CARTON =  CV.ID_VALUE_CATALOG
WHERE ID_WORK_ORDER = @V_ID_WORK_ORDER FOR XML PATH('') 
), 2 , 9999) As CARTON_ITEM_Q)
END

	--SELECT @NM_CARTON = NM_CARTON
	--, @NO_USAGE = NO_USAGE
	--, @NO_SCRAP = NO_SCRAP
	--FROM PRD.K_WORK_ORDER_CARTON WO_CARTON
	--	INNER JOIN PRD.K_WORK_ORDER WO
	--	ON WO.ID_WORK_ORDER = WO_CARTON.ID_WORK_ORDER WHERE WO.ID_WORK_ORDER = @V_ID_WORK_ORDER

		--SELECT 
         --   @NM_CARTON = NM_CARTON, @NO_USAGE = NO_USAGE, @NO_SCRAP = NO_SCRAP
		--FROM PRD.K_WORK_ORDER_CARTON AS WOC 
		-- INNER JOIN PRD.C_CARTON_ITEM AS CCI ON WOC.ID_ITEM = CCI.ID_ITEM
		-- INNER JOIN PRD.K_WORK_ORDER WO ON WOC.ID_ITEM = WO.ID_ITEM
		-- INNER JOIN ADM.C_VALUE_CATALOG AS CVC ON CVC.KY_VALUE_CATALOG = WOC.NM_CARTON 
		  --   WHERE WO.ID_WORK_ORDER = @V_ID_WORK_ORDER



		-- AQUÍ HAY QUE HACER LA BÚSQUEDA DE LA TABLA PRD.K_FOREMAN_AUTHORIZATION 
		-- Y ACTUALIZAR EL @ID_FOREMAN y @NM_FOREMAN.	

			DECLARE       @COUNT_FOREMAN INT
						, @DT_ACTUAL  DATETIME = CONVERT (DATE, GETDATE())
						, @DT_1       DATETIME
						, @DT_2       DATETIME
						, @COUNTER    INT
				        -- , @SHIFT_QA27  VARCHAR(100) = 'SF-2' --HELPER
						--, @NM_FOREMAN VARCHAR(80) --HELPER
						-- , @ID_FOREMAN INT --HELPER
			--  HAY QUE BUSCAR EL SHIFT DE LA QA27, ASÍ SABRÉ SI ES DEL TURNO 1 O 2.
				DECLARE @INIT_TIME AS DATETIME = (SELECT INITIAL_SHIFT_TIME FROM ADM.VW_C_SHIFT
												WHERE KY_SHIFT = @SHIFT_QA27)
                DECLARE @END_TIME AS DATETIME = (SELECT FINAL_SHIFT_TIME FROM ADM.VW_C_SHIFT
												WHERE KY_SHIFT = @SHIFT_QA27)

												

			-- LE PASAMOS A LAS FECHAS INIT Y ENDT LOS INIT_TIME Y END_TIME.
				SET @DT_1 = CONVERT(DATETIME, @DT_ACTUAL) + CONVERT(DATETIME, @INIT_TIME)
				SET @DT_2 = CONVERT(DATETIME, @DT_ACTUAL) + CONVERT(DATETIME, @END_TIME)

			-- EL @COUNTER ES PARA SABER SI HAY ALGÚN REGISTRO.
				SET @COUNTER = (SELECT COUNT(*) FROM PRD.K_FOREMAN_AUTHORIZATION 
								WHERE DT_SYSTEM BETWEEN @DT_1 AND @DT_2)

			-- SELECT @ID_FOREMAN, @NM_FOREMAN , @COUNT_FOREMAN -- PRUEBAS.

-- 1. ENCUENTRA A LOS FOREMAN EN EL SHIFT CORRESPONDIENTE DE LA QA27 Y LA FECHA DEL SISTEMA ACTUAL.
	IF @ID_FOREMAN IS NULL
	BEGIN	
	IF (@COUNTER > 0) 
			BEGIN
			
				

			SELECT  TOP 1 @ID_FOREMAN = s.ID_EMPLOYEE ,
			@NM_FOREMAN =  NM_USER,
			@COUNT_FOREMAN =  s.CNT   FROM (

			SELECT CU.ID_EMPLOYEE,
						 CU.NM_USER, 
						  COUNT(*) CNT
						FROM PRD.K_FOREMAN_AUTHORIZATION  KFA
						INNER JOIN ADM.C_USER  CU ON KFA.KY_USER_FOREMAN = CU.KY_USER
						INNER JOIN ADM.C_EMPLOYEE E ON E.ID_EMPLOYEE =  CU.ID_EMPLOYEE 
						INNER JOIN ADM.C_POSITION  P ON  P.ID_POSITION = E.ID_POSITION
						WHERE KFA.DT_SYSTEM BETWEEN @DT_1 AND @DT_2
						AND KY_SHIFT = @SHIFT_QA27 AND P.ID_POSITION = 49
						GROUP BY CU.NM_USER, CU.ID_EMPLOYEE)  s GROUP BY ID_EMPLOYEE, NM_USER, CNT ORDER BY CNT DESC



			
		    END
	ELSE  -- EN ESTE CASO TODO ESTÁ VACÍa LA TABLA DE FOREMAN_AUTH, POR LO TANTO, NO HAY REGISTROS EN ESE SHIFT.
		BEGIN
		SELECT TOP 1
			 @ID_FOREMAN = CU.ID_EMPLOYEE,
			 @NM_FOREMAN = CU.NM_USER, 
			 @COUNT_FOREMAN = COUNT(*) 
			FROM PRD.K_SHIFT_FOREMAN AS KFA
			INNER JOIN ADM.C_USER AS CU ON KFA.KY_USER = CU.KY_USER
			INNER JOIN ADM.C_ROLE AS CR ON CR.ID_ROLE = CU.ID_ROLE
			WHERE KFA.DT_SYSTEM BETWEEN @DT_1 AND @DT_2
			AND KY_SHIFT_TIME = @SHIFT_QA27 AND CR.NM_ROLE = 'Setup Tech'
			GROUP BY CU.NM_USER, CU.ID_EMPLOYEE ORDER BY CU.NM_USER DESC


		--SET @ID_FOREMAN = NULL
		--SET @NM_FOREMAN = NULL
		END
	END
	
	SELECT TOP 1
		@V_ID_LBS_PER_HOUR_METRIC = CBP.ID_LBS_PER_HOUR_METRIC
		, @V_ID_METRIC_WIDTH = CBP.ID_WIDTH_METRIC
		, @V_ID_METRIC_LENGTH = CBP.ID_LENGTH_METRIC
		, @V_ID_METRIC_WEIGHT = CBP.ID_WEIGHT_METRIC
		, @V_ID_METRIC_THICKNESS = CBP.ID_THICKNESS_METRIC
	FROM ADM.C_BRANCH_PLANT CBP 
	WHERE CBP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT

	
	--INSERT INTO #T_WORK_ORDER_STATUS (KY_WORK_ORDER_STATUS)
	--SELECT x.ref.value('@KY_STATUS', 'VARCHAR(20)') KY_STATUS_WORK_ORDER FROM @PIN_KY_STATUS_WORK_ORDER.nodes('/STATUS/ST') x(ref)
	
	--SELECT @V_AVG_WEIGHT_FORMS_QA27 = AVG(KFM.XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'DECIMAL(13,4)'))
	--FROM PRD.K_FORM KF
	--	INNER JOIN PRD.K_FORM_METRICS KFM
	--		ON KF.ID_K_FORM = KFM.ID_K_FORM
	--		AND KFM.ID_METRICS = @V_ID_METRIC_WEIGHT
	--WHERE KF.KY_PROCESS_TYPE = 'MANUFACTURE'
	--	AND KF.KY_STATUS_FORM = 'CAPTURED'
	--	AND EXISTS (SELECT TOP 1 1 FROM PRD.K_QA27 KQ WHERE KQ.ID_QA27 = KF.ID_QA27 AND KQ.ID_QA27 = @PIN_ID_QA27)


		SELECT @V_AVG_WEIGHT_FORMS_QA27= AVG(KFM.XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'DECIMAL(13,7)'))
	FROM PRD.K_FORM KF
	INNER JOIN PRD.K_QA27 Q ON Q.ID_QA27=KF.ID_QA27
	INNER JOIN PRD.K_PALLET KP ON KP.ID_PALLET = KF.ID_PALLET 
	--AND Q.ID_QA27=KP.ID_QA27 
	INNER JOIN ADM.VW_C_PALLET_STATUS VCPS
			ON KP.KY_STATUS = VCPS.KY_PALLET_STATUS
			AND VCPS.FG_FOR_SAVE = 1
		INNER JOIN PRD.K_FORM_METRICS KFM
			ON KF.ID_K_FORM = KFM.ID_K_FORM
			AND KFM.ID_METRICS =  @V_ID_METRIC_WEIGHT
	WHERE KF.KY_PROCESS_TYPE = 'MANUFACTURE'
		AND KF.KY_STATUS_FORM = 'CAPTURED'
		AND Q.ID_QA27 = @PIN_ID_QA27



	--CREATE TABLE #T_LINE_RATE  (
	--	ID_PRODUCTION_LINE INT
	--	, ID_K_FORM INT
	--	, DT_FORM_CAPTURED DATETIME
	--	, DT_NEXT_FORM DATETIME
	--	, NO_LINE_RATE DECIMAL(13,2)
	--	, NO_MINUTES_DOWN_TIME INT
	--)

	--; WITH T_FORMS AS (
	--	SELECT ROW_NUMBER() OVER (PARTITION BY KF.ID_PRODUCTION_LINE ORDER BY DT_FORM DESC) AS NO_ROW
	--		, KF.ID_PRODUCTION_LINE
	--		, KF.ID_K_FORM
	--		, CASE WHEN KF.DT_CLOSED < @DT_INITIAL THEN @DT_INITIAL ELSE KF.DT_CLOSED END AS DT_CLOSED
	--	FROM PRD.K_FORM KF
	--	WHERE KF.DT_FORM < @DT_INITIAL
	--		AND KF.KY_STATUS_FORM = 'CAPTURED'
	--		AND KF.KY_PROCESS_TYPE = 'PROCESS'
	--		AND KF.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
	--)
	--INSERT INTO #T_LINE_RATE (ID_PRODUCTION_LINE, ID_K_FORM, DT_FORM_CAPTURED)
	--SELECT ID_PRODUCTION_LINE, ID_K_FORM, DT_CLOSED
	--FROM T_FORMS
	--WHERE NO_ROW = 1

	--INSERT INTO #T_LINE_RATE (ID_PRODUCTION_LINE, ID_K_FORM, DT_FORM_CAPTURED)
	--SELECT ID_PRODUCTION_LINE, ID_K_FORM, DT_CLOSED
	--FROM PRD.K_FORM KF
	--WHERE KF.DT_FORM BETWEEN @DT_INITIAL AND @DT_FINAL
	--	AND KF.KY_STATUS_FORM = 'CAPTURED'
	--	AND KF.KY_PROCESS_TYPE = 'PROCESS'
	--	AND KF.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE

	--; WITH T_FORM AS (
	--	SELECT TLR.ID_K_FORM
	--		, KFM.XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'DECIMAL(13,2)') AS NO_LINE_RATE
	--		, ISNULL(LEAD(TLR.DT_FORM_CAPTURED, 1, NULL) OVER (PARTITION BY TLR.ID_PRODUCTION_LINE ORDER BY TLR.ID_PRODUCTION_LINE, TLR.DT_FORM_CAPTURED), CASE WHEN @DT_SYSTEM < @DT_FINAL THEN @DT_SYSTEM ELSE @DT_FINAL END) AS DT_NEXT_FORM
	--	FROM #T_LINE_RATE TLR
	--		INNER JOIN PRD.K_FORM_METRICS KFM
	--			ON TLR.ID_K_FORM = KFM.ID_K_FORM
	--			AND KFM.ID_METRICS = @V_ID_LBS_PER_HOUR_METRIC
	--			AND TLR.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
	--)
	--UPDATE TLR
	--SET NO_LINE_RATE = TF.NO_LINE_RATE
	--	, DT_NEXT_FORM = TF.DT_NEXT_FORM
	--FROM #T_LINE_RATE TLR
	--	INNER JOIN T_FORM TF
	--		ON TLR.ID_K_FORM = TF.ID_K_FORM

--0000000000000000000000000000000000000000000000000000000000000000000000

		--SELECT CASE 
		--		WHEN KI.DT_ISSUE < TRL.DT_FORM_CAPTURED THEN TRL.DT_FORM_CAPTURED
		--		ELSE KI.DT_ISSUE
		--	END AS DT_ISSUE_STARTED
		--	, CASE 
		--		WHEN ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) > TRL.DT_NEXT_FORM THEN TRL.DT_NEXT_FORM
		--		ELSE ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM)
		--	END AS DT_ISSUE_ENDED
		--	, DT_FORM_CAPTURED
		--	, DT_NEXT_FORM
		--	, DT_ISSUE
		--	, ISNULL(DT_ISSUE_CLOSED, @DT_SYSTEM)
		--	, *
		--FROM @T_LINE_RATE TRL
		--	INNER JOIN PRD.K_ISSUE KI
		--		ON KI.ID_PRODUCTION_LINE = TRL.ID_PRODUCTION_LINE
		--		AND KI.ID_WORK_ORDER = @V_ID_WORK_ORDER
		--		AND KI.FG_LINE_DOWN = 1
		--		AND (KI.DT_ISSUE BETWEEN TRL.DT_FORM_CAPTURED AND TRL.DT_NEXT_FORM
		--			OR ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) BETWEEN TRL.DT_FORM_CAPTURED AND TRL.DT_NEXT_FORM
		--			OR TRL.DT_FORM_CAPTURED BETWEEN KI.DT_ISSUE AND ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM)
		--		)


	--;WITH T_DOWN_TIME AS (
	--	SELECT CASE 
	--			WHEN KI.DT_ISSUE < TRL.DT_FORM_CAPTURED THEN TRL.DT_FORM_CAPTURED
	--			ELSE KI.DT_ISSUE
	--		END AS DT_ISSUE_STARTED
	--		, CASE 
	--			WHEN ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) > TRL.DT_NEXT_FORM THEN TRL.DT_NEXT_FORM
	--			ELSE ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM)
	--		END AS DT_ISSUE_ENDED
	--		, ID_K_FORM
	--	FROM #T_LINE_RATE TRL
	--		INNER JOIN PRD.K_ISSUE KI
	--			ON KI.ID_PRODUCTION_LINE = TRL.ID_PRODUCTION_LINE
	--			AND KI.ID_WORK_ORDER = @V_ID_WORK_ORDER
	--			AND KI.FG_LINE_DOWN = 1
	--			AND (KI.DT_ISSUE BETWEEN TRL.DT_FORM_CAPTURED AND TRL.DT_NEXT_FORM
	--				OR ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) BETWEEN TRL.DT_FORM_CAPTURED AND TRL.DT_NEXT_FORM
	--				OR TRL.DT_FORM_CAPTURED BETWEEN KI.DT_ISSUE AND ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM)
	--			)
	--), T_MINUTES_DOWN_TIME AS (
	--	SELECT ID_K_FORM, SUM(DATEDIFF(MINUTE, DT_ISSUE_STARTED, DT_ISSUE_ENDED)) AS NO_MINUTES_DOWN_TIME
	--	FROM T_DOWN_TIME TDT
	--	GROUP BY ID_K_FORM
	--)
	--UPDATE TLR
	--SET NO_MINUTES_DOWN_TIME = ISNULL(TMDT.NO_MINUTES_DOWN_TIME, 0)
	--FROM #T_LINE_RATE TLR
	--	LEFT JOIN T_MINUTES_DOWN_TIME TMDT
	--		ON TLR.ID_K_FORM = TMDT.ID_K_FORM

--0000000000000000000000000000000000000000000000000000000000000000000000

	--SELECT @NO_SUM_LINE_RATE_PER_MINUTE = SUM((DATEDIFF(MINUTE, DT_FORM_CAPTURED, DT_NEXT_FORM) - NO_MINUTES_DOWN_TIME) * NO_LINE_RATE)
	--	, @NO_TOTAL_MINUTES_RUNNING = (DATEDIFF(MINUTE, MIN(DT_FORM_CAPTURED), MAX(DT_NEXT_FORM)) - SUM(NO_MINUTES_DOWN_TIME)) 
	--	, @V_AVG_LBS_PER_HOUR_FORMS_QA27 = 0 -- IT IS GOING TO BE CALCULATED AFTER THIS QUERY TO PREVENT DIV/0 ERROR
	--FROM #T_LINE_RATE

	--IF @NO_TOTAL_MINUTES_RUNNING != 0 BEGIN
	--	SET @V_AVG_LBS_PER_HOUR_FORMS_QA27 = @NO_SUM_LINE_RATE_PER_MINUTE / @NO_TOTAL_MINUTES_RUNNING
	--END

-- SELECT @NO_TOTAL_MINUTES_RUNNING=NO_LINE_RATE  FROM #T_LINE_RATE


SELECT  @V_AVG_LBS_PER_HOUR_FORMS_QA27=(SELECT 
TOP 1 XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'DECIMAL(13,2)') 
FROM PRD.K_FORM_METRICS KFM INNER JOIN PRD.K_FORM KF 
ON KF.ID_K_FORM = KFM.ID_K_FORM AND KFM.ID_METRICS = 66 
AND KF.KY_STATUS_FORM = 'CAPTURED' AND KF.KY_PROCESS_TYPE = 'PROCESS' 
AND KF.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE 
INNER JOIN PRD.K_WORK_ORDER WO ON WO.ID_WORK_ORDER=KF.ID_WORK_ORDER 
WHERE WO.ID_ITEM=@ID_ITEM AND KF.DT_CREATION <= @DT_FINAL ORDER BY KF.DT_CREATION DESC)



--KFM.XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'DECIMAL(13,2)')  FROM PRD.K_FORM KF INNER JOIN PRD.K_WORK_ORDER WO ON WO.ID_WORK_ORDER = KF.ID_WORK_ORDER
--INNER JOIN PRD.K_FORM_METRICS KFM ON kFM.ID_K_FORM = KF.ID_K_FORM INNER JOIN PRD.K_QA27 Q ON Q.ID_QA27 = KF.ID_QA27
--WHERE 
--KFM.ID_METRICS=66 AND
--ID_FORM = 3 AND WO.ID_ITEM =  @ID_ITEM AND WO.ID_PRODUCTION_LINE =@ID_PRODUCTION_LINE
--AND KF.KY_STATUS_FORM ='CAPTURED' AND KF.DT_CREATION <= @DT_INITIAL ORDER BY KF.ID_QA27 DESC

	-----



	--SELECT @NO_SUM_LINE_RATE_PER_MINUTE
	--	, @NO_TOTAL_MINUTES_RUNNING
	--	, @V_AVG_LBS_PER_HOUR_FORMS_QA27

	--SELECT * FROM @T_LINE_RATE

	;WITH T_QUANTITY AS (
		SELECT KQ.ID_QA27
			, KQ.ID_WORK_ORDER
			, KP.NO_QUANTITY AS NO_EXTR_QTY
			--, CASE WHEN VCPS.KY_TEMP_STATUS != 'R' AND (KP.DT_FINAL_OPERATION_TIME IS NOT NULL OR VCPS.KY_TEMP_STATUS = 'A') THEN KP.NO_QUANTITY ELSE 0 END AS NO_SAVED_QTY
			, CASE WHEN VCPS.FG_FOR_SAVE = 1 THEN KP.NO_QUANTITY ELSE 0 END AS NO_SAVED_QTY
		FROM PRD.K_QA27 KQ
			LEFT JOIN PRD.K_PALLET KP
				ON KQ.ID_QA27 = KP.ID_QA27
			LEFT JOIN ADM.VW_C_PALLET_STATUS VCPS
				ON KP.KY_STATUS = VCPS.KY_PALLET_STATUS
		WHERE KQ.ID_WORK_ORDER = @V_ID_WORK_ORDER
			AND KQ.ID_QA27 = @PIN_ID_QA27
	), T_GROUPED_QA_WO AS (
		SELECT ID_QA27
			, ID_WORK_ORDER
			, SUM(ISNULL(NO_EXTR_QTY, 0)) AS NO_SUM_EXTR_QTY
			, SUM(ISNULL(NO_SAVED_QTY, 0)) AS NO_SUM_SAVED_QTY
		FROM T_QUANTITY
		GROUP BY ID_QA27, ID_WORK_ORDER
	)
	SELECT QA.ID_QA27 
		, QA.DT_INITIAL_TIME AS  DT_INITIAL_TIME_QA27
		, ISNULL(QA.DT_FINAL_TIME, GETDATE()) AS DT_FINAL_TIME_QA27
		, QA.KY_STATUS
		, WO.ID_WORK_ORDER
		, WO.NO_WORK_ORDER 
		, WO.NM_CUSTOMER
		, COALESCE(@ID_FOREMAN, QA.ID_FOREMAN ) AS ID_FOREMAN
		, COALESCE(@NM_FOREMAN, QA.NM_FOREMAN) AS NM_FOREMAN
		, QA.ID_LEADMAN
		, QA.NM_LEADMAN
		, '' KY_SO_NUMBER
		, CI.ID_ITEM
		, CI.KY_ITEM
		, CI.NM_ITEM
		, CI.FG_FILM_TRACK
		, '' KY_LINE_OPT
		, KS.ID_SHIFT
		, KS.KY_SHIFT
		, KS.KY_SHIFT_TIME
		, KS.DT_START_SHIFT
		, KS.DT_END_SHIFT
		, QA.DT_INITIAL_TIME AS DT_QA27
		, PL.ID_PRODUCTION_LINE
		, PL.KY_PRODUCTION_LINE
		, PL.NM_PRODUCTION_LINE
		, WO.NO_RUN_QTY
		, WO.NO_BOX_QTY
		, WO.NM_MATERIAL
		, WO.NM_COLOR
		, @NM_CARTON AS CARTON_ITEM
		, @NO_USAGE AS NO_USAGE
		, @NO_SCRAP AS NO_SCRAP
		, CICW.ID_METRICS AS ID_METRIC_WIDTH
		, CICW.XML_FIELD_SETTINGS AS XML_FIELD_SETTINGS_WIDTH
		, (SELECT msgs.msg.value('@NOMINAL_VALUE', 'FLOAT') AS NOMINAL_VALUE FROM CICW.XML_FIELD_SETTINGS.nodes('SETTINGS/FIELD_TYPES') msgs(msg)) AS NOMINAL_VALUE_WIDTH
		, CICL.ID_METRICS AS ID_METRIC_LENGTH
		, CICL.XML_FIELD_SETTINGS AS XML_FIELD_SETTINGS_LENGTH
		, (SELECT msgs.msg.value('@NOMINAL_VALUE', 'FLOAT') AS NOMINAL_VALUE FROM CICL.XML_FIELD_SETTINGS.nodes('SETTINGS/FIELD_TYPES') msgs(msg)) AS NOMINAL_VALUE_LENGTH
		, CICT.ID_METRICS AS ID_METRIC_THICKNESS
		, CICT.XML_FIELD_SETTINGS AS XML_FIELD_SETTINGS_THICKNESS
		, (SELECT msgs.msg.value('@NOMINAL_VALUE', 'FLOAT') AS NOMINAL_VALUE FROM CICT.XML_FIELD_SETTINGS.nodes('SETTINGS/FIELD_TYPES') msgs(msg)) AS NOMINAL_VALUE_THICKNESS
		, @V_ID_METRIC_WEIGHT AS ID_METRIC_WEIGHT
		, ROUND (ISNULL(@V_AVG_WEIGHT_FORMS_QA27,WO.NO_POUNDS),4,4)  AS NOMINAL_VALUE_WEIGHT
		, CAST((ROUND(CAST(@NO_TOTAL_MINUTES_RUNNING AS float) / 30 , 0) * 30) / 60.00 AS DECIMAL(12,2)) DT_RUNNING_TIME_HOURS  --****RUNNING_TIME ****
		, @NO_TOTAL_MINUTES_RUNNING AS DT_RUNNING_TIME_MINUTES
		, ISNULL(@V_AVG_LBS_PER_HOUR_FORMS_QA27, CAST(0.00 AS FLOAT)) AS NO_POUNDS_PER_HOUR --, PL.NO_POUNDS_PER_HOUR
		, CI.NO_POUNDS_PER_ITEM
		--, ROUND((DATEDIFF(SECOND, QA.DT_INITIAL_TIME, ISNULL(QA.DT_FINAL_TIME, GETDATE())) / 3600.00) * ISNULL(@V_AVG_LBS_PER_HOUR_FORMS_QA27, CAST(0.00 AS FLOAT)) ,2) AS NO_TOTAL_LBS_PERO_HOUR_IDEAL --****TOTAL_LBS****
		, ROUND((@NO_TOTAL_MINUTES_RUNNING / 60.00) * ISNULL(@V_AVG_LBS_PER_HOUR_FORMS_QA27, CAST(0.00 AS FLOAT)) ,2) AS NO_TOTAL_LBS_PERO_HOUR_IDEAL --****TOTAL_LBS****
		, TGQW.NO_SUM_EXTR_QTY * ISNULL(CAST(@V_AVG_WEIGHT_FORMS_QA27 AS decimal(12,2)), 0.00) AS NO_TOTAL_LBS_PROD -- **** PROD_LBS ****
		, TGQW.NO_SUM_SAVED_QTY * ISNULL(CAST(@V_AVG_WEIGHT_FORMS_QA27 AS decimal(12,2)), 0.00) AS NO_TOTAL_SAVED_LBS 
		, CAST(ROUND((ISNULL( (SELECT SUM(KP.NO_QUANTITY) FROM PRD.K_PALLET KP JOIN ADM.VW_C_PALLET_STATUS PS ON PS.KY_PALLET_STATUS = KP.KY_STATUS WHERE ID_QA27 = QA.ID_QA27 AND KY_TEMP_STATUS = 'R') , 0.00) * CI.NO_POUNDS_PER_ITEM),2) AS DECIMAL(12,2)) AS NO_SCRAP_LBS -- SCRAP LBS --
		, TGQW.NO_SUM_SAVED_QTY
		, TGQW.NO_SUM_EXTR_QTY  AS NO_SUM_EXTR_QTY -- ****** PARTS EXT *****,
		, WO.KY_UPC
		, @ID_QA27_PREVIOUS AS ID_QA27_PREVIOUS
		, @ID_QA27_NEXT AS ID_QA27_NEXT
	FROM PRD.K_WORK_ORDER WO
		INNER JOIN PRD.C_PRODUCTION_LINE PL 
			ON WO.ID_PRODUCTION_LINE = PL.ID_PRODUCTION_LINE
		INNER JOIN PRD.K_QA27 QA 
			ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER 
			AND QA.ID_QA27 = @PIN_ID_QA27
		INNER JOIN PRD.C_ITEM CI 
			ON WO.ID_ITEM = CI.ID_ITEM
		LEFT JOIN PRD.C_ITEM_CHARACTERISTIC CICW
			ON CI.ID_ITEM = CICW.ID_ITEM 
			AND CICW.ID_METRICS = @V_ID_METRIC_WIDTH 		
		LEFT JOIN PRD.C_ITEM_CHARACTERISTIC CICL
			ON CI.ID_ITEM = CICL.ID_ITEM 
			AND CICL.ID_METRICS = @V_ID_METRIC_LENGTH
		LEFT JOIN PRD.C_ITEM_CHARACTERISTIC CICT
			ON CI.ID_ITEM = CICT.ID_ITEM 
			AND CICT.ID_METRICS =  @V_ID_METRIC_THICKNESS
		LEFT JOIN PRD.C_ITEM_CHARACTERISTIC CICWE
			ON CI.ID_ITEM = CICWE.ID_ITEM 
			AND CICWE.ID_METRICS =  @V_ID_METRIC_WEIGHT
		INNER JOIN PRD.K_SHIFT KS 
			ON KS.ID_SHIFT = QA.ID_SHIFT 
		INNER JOIN T_GROUPED_QA_WO TGQW
			ON TGQW.ID_WORK_ORDER =WO.ID_WORK_ORDER
		INNER JOIN PRD.K_WORK_ORDER WO_CARTON
			ON WO_CARTON.ID_WORK_ORDER = WO.ID_WORK_ORDER

	
		
