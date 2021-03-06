﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz  Barron
-- CREATE date: 20/06/2017
-- Description: Get work order data by user
-- =============================================
-- 05/16/2018 JTC The LENGTH_SAMPLE, NO_SAMPLE AND KY_SAMPLE_UNIT changed by the one indicated on the quality inspector forM JCTC
-- 02/21/2018 JDR The allocation of the number of samples for the thickness readings of the piece is corrected, when it is 1 skid at a time the length of the piece divided by 10 must be taken and if they are more than 1 skid at the same time it must take into account the width of the piece divided by 10
-- 02/21/2018 JDR Filter is corrected to determine the number of measurements per piece for orders that have a form created for quality inspectors
-- 22/02/2018 JDR The mechanism is changed to determine the amount of thickness measurements, now regardless of the number of open skids at the same time, it will be calculated based on the width of the piece
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_DATA_BY_USER]
	@KY_USER NVARCHAR(50) = NULL,
	@PIN_NM_POSITION NVARCHAR(30) = NULL ----'QUALITY INSPECTOR'--'OPERATOR'

AS

	DECLARE @ID_BRANCH_PLANT NVARCHAR(5)
		, @ID_POSITION_LEADMEN INT
		, @ID_PRODUCTION_LINE INT
		, @ID_QUALITY_INSPECTOR_POSITION INT
		, @ID_EMPLOYEE INT
		, @ID_METRIC_WIDTH NVARCHAR(20)
		, @ID_METRIC_LENGHT NVARCHAR(20)
		, @ID_METRIC_THICKNESS NVARCHAR(20)
		, @ID_METRIC_GLOSS NVARCHAR(20)
		, @ID_METRIC_LIGHT_TRANSMISSION NVARCHAR(20)
		, @ID_WORK_ORDER INT
		, @V_NO_LENGTH_SAMPLE_QUALITY_FORM AS INT
		, @V_KY_SAMPLE_UNIT_QUALITY_FORM AS NVARCHAR(20)

		, @V_NO_PART_READINGS_MICROMETER AS FLOAT = 10
		, @V_ID_METRIC_LENGTH AS INT
		, @V_ID_METRIC_WIDTH AS INT
	CREATE TABLE #T_METRICS_CONFIGURATION  (
		ID_METRICS NVARCHAR(20)
		, NM_METRICS_CONFIGURATION NVARCHAR(MAX)
	)

	CREATE TABLE #T_READINGS_PER_NO_SKIDS_OPEN  (
		ID_WORK_ORDER INT,
		ID_ITEM INT,
		ID_METRICS INT,
		ID_PALLET INT,
		NO_PALLETS_OPENED INT,
		NO_READINGS_MICROMETER FLOAT
	)




--******* GET BRANCH PLAN FROM EMPLOYEE ********	
	SELECT @ID_BRANCH_PLANT = ISNULL(CE.ID_BRANCH_PLANT, 1)
	FROM ADM.C_USER CU
		INNER JOIN ADM.C_EMPLOYEE CE 
			ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE
		INNER JOIN ADM.C_POSITION CP 
			ON CP.ID_POSITION = CE.ID_POSITION
	WHERE CU.KY_USER = @KY_USER AND CU.FG_ACTIVE = 1

--******* GET POSITION OF LEADMEN FROM CONFIGURATION ********		
	DECLARE @XML_CONFIGURATION XML 
		, @XML_BRANCH_PLANT_SELECTED XML
	
	SELECT @XML_CONFIGURATION = XML_CONFIGURATION 
	FROM ADM.S_CONFIGURATION

	SELECT @XML_BRANCH_PLANT_SELECTED = msgs.msg.query('.')
	FROM @XML_CONFIGURATION.nodes('CONFIGURATIONS/ESPECIFIC_CONFIGURATION/child::node()') msgs(msg)	
	WHERE msgs.msg.value('@ID_BRANCH_PLANT', 'nvarchar(max)') = @ID_BRANCH_PLANT
	
	SELECT @ID_POSITION_LEADMEN = msgs.msg.value('@ID_POSITION', 'nvarchar(max)')
		--,msgs.msg.query('.') XML_POSITIONS
	FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/QUALITY_PROCESS/OPERATOR') msgs(msg)	

	SELECT @ID_QUALITY_INSPECTOR_POSITION = msgs.msg.value('@ID_POSITION', 'nvarchar(max)')
		--,msgs.msg.query('.') XML_POSITIONS
	FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/QUALITY_PROCESS/QUALITY_INSPECTOR') msgs(msg)	

	SELECT @V_ID_METRIC_WIDTH  = msgs.msg.value('@ID_METRICS', 'INT')
	  FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/PROCESS_METRICS/WIDTH') msgs(msg)	

	SELECT @V_ID_METRIC_LENGTH = msgs.msg.value('@ID_METRICS', 'INT')
	  FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/PROCESS_METRICS/LENGHT') msgs(msg)	


	  --****** GET VALUE THINKNESS TO1 OR 2 PALLETS *********
	IF @PIN_NM_POSITION = 'QUALITY INSPECTOR' BEGIN
		INSERT INTO #T_READINGS_PER_NO_SKIDS_OPEN (
			ID_WORK_ORDER
			,ID_ITEM 
			,ID_METRICS
			,ID_PALLET 
			,NO_PALLETS_OPENED 
			,NO_READINGS_MICROMETER 
		)
		SELECT PALLETS.ID_WORK_ORDER ,
			PALLETS.ID_ITEM,
			PALLETS.ID_METRICS,
			PALLETS.ID_PALLET,
			PALLETS.NO_SKIDS_OPENED,
			CEILING(PALLETS.NOMINAL_VALUE / @V_NO_PART_READINGS_MICROMETER) AS NO_READINGS_MICROMETER
		FROM (
			SELECT DISTINCT WO.ID_WORK_ORDER
				, WO.ID_ITEM
				, CIC.ID_METRICS
				, KP.ID_INSPECTION_SKID AS ID_PALLET
				, ISNULL(KP.NO_SKIDS_OPENED, 1) NO_SKIDS_OPENED
				, CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'FLOAT') AS NOMINAL_VALUE
			FROM PRD.K_WORK_ORDER WO
				INNER JOIN PRD.K_INSPECTION_SKID KP 
					ON WO.ID_WORK_ORDER = KP.ID_WORK_ORDER
					AND KP.KY_STATUS IN ('CLOSE_PALLET', 'WORKING',  'INSPECTING')
				INNER JOIN PRD.K_FORM KF 
					ON KP.ID_INSPECTION_SKID = KF.ID_INSPECTION_SKID
					AND WO.ID_WORK_ORDER = KF.ID_WORK_ORDER  
					AND KF.KY_STATUS_FORM NOT IN ('CAPTURED','CANCELLED') AND KF.KY_PROCESS_TYPE = 'QUALITY'
				INNER JOIN PRD.C_ITEM_CHARACTERISTIC CIC 
					ON WO.ID_ITEM = CIC.ID_ITEM 
					AND (CIC.ID_METRICS = @V_ID_METRIC_WIDTH 
						--OR CIC.ID_METRICS = @V_ID_METRIC_LENGTH
					)
			--WHERE ( 
			--	(ISNULL(KP.NO_SKIDS_OPENED, 1) > 1 AND ID_METRICS = @V_ID_METRIC_WIDTH ) 
			--	OR (ISNULL(KP.NO_SKIDS_OPENED, 1) = 1 AND ID_METRICS = @V_ID_METRIC_LENGTH )
			--)
		) PALLETS

	END ELSE BEGIN
		INSERT INTO #T_READINGS_PER_NO_SKIDS_OPEN (
			ID_WORK_ORDER
			,ID_ITEM 
			,ID_METRICS
			,ID_PALLET 
			,NO_PALLETS_OPENED 
			,NO_READINGS_MICROMETER 
		)
		SELECT PALLETS.ID_WORK_ORDER
			, PALLETS.ID_ITEM
			, PALLETS.ID_METRICS
			, PALLETS.ID_PALLET
			, PALLETS.NO_PALLETS_OPENED
			, CEILING(PALLETS.NOMINAL_VALUE / @V_NO_PART_READINGS_MICROMETER) AS NO_READINGS_MICROMETER
		FROM(
			SELECT DISTINCT WO.ID_WORK_ORDER
				, WO.ID_ITEM
				, CIC.ID_METRICS
				, KP.ID_PALLET
				, ISNULL(KP.NO_PALLETS_OPENED,1) NO_PALLETS_OPENED
				, CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'FLOAT') AS NOMINAL_VALUE
			FROM PRD.K_WORK_ORDER WO
				INNER JOIN PRD.K_PALLET KP 
					ON WO.ID_WORK_ORDER = KP.ID_WORK_ORDER
				INNER JOIN PRD.C_ITEM_CHARACTERISTIC CIC 
					ON WO.ID_ITEM = CIC.ID_ITEM 
					AND (CIC.ID_METRICS = @V_ID_METRIC_WIDTH 
						--OR CIC.ID_METRICS = @V_ID_METRIC_LENGTH
					)
			WHERE WO.KY_STATUS ='RUNNING' 
				--AND (
				--	(ISNULL(KP.NO_PALLETS_OPENED,1) > 1 AND ID_METRICS = @V_ID_METRIC_WIDTH ) 
				--	OR (ISNULL(KP.NO_PALLETS_OPENED,1) = 1 AND ID_METRICS = @V_ID_METRIC_LENGTH )
				--)
		) PALLETS
	END


--******* GET EMPLOYEE OF LEADMEN  OR QUALITY INSPECTOR ********	
	SELECT @ID_EMPLOYEE = CE.ID_EMPLOYEE
	FROM ADM.C_USER CU
		INNER JOIN ADM.C_EMPLOYEE CE 
			ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE
	WHERE CU.KY_USER = @KY_USER 
		AND CU.FG_ACTIVE = 1


	SELECT TOP 1 
			@V_NO_LENGTH_SAMPLE_QUALITY_FORM  =  CF.NO_SAMPLE,
			@V_KY_SAMPLE_UNIT_QUALITY_FORM = CF.KY_SAMPLE_UNIT 
	FROM PRD.C_FORM CF
	WHERE CF.KY_PROCESS = 'QUALITY'
	 

	INSERT INTO #T_METRICS_CONFIGURATION (ID_METRICS, NM_METRICS_CONFIGURATION)
	SELECT msgs.msg.value('@ID_METRICS', 'NVARCHAR(20)') ID_METRICS
		, msgs.msg.value('local-name(.)', 'nvarchar(max)') NM_METRICS_CONFIGURATION
	FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/PROCESS_METRICS/child::node()') msgs(msg)

	SET @ID_METRIC_WIDTH = (SELECT TOP 1 ID_METRICS FROM #T_METRICS_CONFIGURATION MC WHERE MC.NM_METRICS_CONFIGURATION = 'WIDTH')
	SET @ID_METRIC_LENGHT = (SELECT TOP 1 ID_METRICS FROM #T_METRICS_CONFIGURATION MC WHERE MC.NM_METRICS_CONFIGURATION = 'LENGHT')
	SET @ID_METRIC_THICKNESS = (SELECT TOP 1 ID_METRICS FROM #T_METRICS_CONFIGURATION MC WHERE MC.NM_METRICS_CONFIGURATION = 'THICKNESS')
	SET @ID_METRIC_GLOSS = (SELECT TOP 1 ID_METRICS FROM #T_METRICS_CONFIGURATION MC WHERE MC.NM_METRICS_CONFIGURATION = 'GLOSS') 
	SET @ID_METRIC_LIGHT_TRANSMISSION = (SELECT TOP 1 ID_METRICS FROM #T_METRICS_CONFIGURATION MC WHERE MC.NM_METRICS_CONFIGURATION = 'LIGHT_TRANSMISSION')

	
--******* GET METRICS OF CONFIGURATION *******
	;WITH TB_WORK_ORDER_DATA AS (

		SELECT WO.ID_WORK_ORDER
			, WO.NO_WORK_ORDER
			, WO.ID_ITEM
			, WO.NM_ITEM
			, WO.ID_PRODUCTION_LINE
			, WO.NM_PRODUCTION_LINE	
			, @ID_EMPLOYEE ID_EMPLOYEE
			, KP.NM_QUALITY_INSPECTOR NM_EMPLOYEE
			, KP.ID_INSPECTION_SKID AS ID_PALLET--, KP.ID_PALLET
			, KP.NO_PALLET
			, 'QUALITY_INSPECTOR' AS POSITION
			, @KY_USER KY_USER
			, WO.ID_BRANCH_PLANT
			, CASE WHEN FRM_QUALITY_INSPECTOR.KY_SAMPLE_UNIT_CUSTOMER IS NOT NULL THEN FRM_QUALITY_INSPECTOR.NO_SAMPLE_CUSTOMER
				ELSE @V_NO_LENGTH_SAMPLE_QUALITY_FORM
			END AS NO_LENGHT_SAMPLE
			, CASE WHEN FRM_QUALITY_INSPECTOR.KY_SAMPLE_UNIT_CUSTOMER IS NOT NULL THEN 
				CASE WHEN FRM_QUALITY_INSPECTOR.KY_SAMPLE_UNIT_CUSTOMER = 'PENCENT' THEN 
					--CAST(CEILING(CAST((ISNULL(KP.NO_QUANTITY, CI.NO_PIECES_PER_PALLET) * FRM_QUALITY_INSPECTOR.NO_SAMPLE_CUSTOMER) AS decimal(12,2))/100) AS INT)
					CAST(CEILING(CAST((ISNULL(WO.NO_QTY_SKID, CI.NO_PIECES_PER_PALLET) * FRM_QUALITY_INSPECTOR.NO_SAMPLE_CUSTOMER) AS decimal(12,2))/100) AS INT)
				ELSE 
					FRM_QUALITY_INSPECTOR.NO_SAMPLE_CUSTOMER
				END
			ELSE 
				CASE WHEN @V_KY_SAMPLE_UNIT_QUALITY_FORM = 'PENCENT' THEN 
					--CAST(CEILING(CAST((ISNULL(KP.NO_QUANTITY, CI.NO_PIECES_PER_PALLET) * @V_NO_LENGTH_SAMPLE_QUALITY_FORM) AS decimal(12,2))/100) AS INT)
					CAST(CEILING(CAST((ISNULL(WO.NO_QTY_SKID , CI.NO_PIECES_PER_PALLET) * @V_NO_LENGTH_SAMPLE_QUALITY_FORM) AS decimal(12,2))/100) AS INT)
				ELSE 
					@V_NO_LENGTH_SAMPLE_QUALITY_FORM 
				END
			END AS NO_SAMPLE 
			, CASE WHEN FRM_QUALITY_INSPECTOR.KY_SAMPLE_UNIT_CUSTOMER IS NOT NULL THEN 
				FRM_QUALITY_INSPECTOR.KY_SAMPLE_UNIT_CUSTOMER 
			ELSE 
				@V_KY_SAMPLE_UNIT_QUALITY_FORM
			END AS KY_SAMPLE_UNIT --, CI.KY_SAMPLE_UNIT
			, '' NM_FORM
			, KF.ID_FORM--, 0 ID_FORM
			, KF.ID_K_FORM --, 0 ID_K_FORM
			, KP.KY_STATUS KY_STATUS_PALLET
			, @ID_METRIC_WIDTH AS ID_METRIC_WIDTH
			, @ID_METRIC_LENGHT AS ID_METRIC_LENGHT 
			, @ID_METRIC_THICKNESS AS ID_METRIC_THICKNESS
			, @ID_METRIC_GLOSS AS ID_METRIC_GLOSS
			, @ID_METRIC_LIGHT_TRANSMISSION AS ID_METRIC_LIGHT_TRANSMISSION
			, '' AS KY_USER_LEADMEN--, (SELECT CU.KY_USER FROM ADM.C_USER CU WHERE CU.ID_EMPLOYEE = QA.ID_LEADMAN) KY_USER_LEADMEN
			, CAST(WO.NO_WORK_ORDER as nvarchar) + ' (' + CAST(KP.NO_PALLET as nvarchar) + ')' AS KY_SELECTION
			, WO.KY_CUSTOMER
			, GETDATE() as DT_FORM
			, ISNULL(RPKO.NO_READINGS_MICROMETER, 1) AS NO_READINGS_MICROMETER
		FROM PRD.K_WORK_ORDER WO 
			INNER JOIN PRD.C_ITEM CI 
				ON CI.ID_ITEM = WO.ID_ITEM 
			INNER JOIN PRD.K_INSPECTION_SKID KP
				ON KP.ID_WORK_ORDER = WO.ID_WORK_ORDER 
				AND KP.KY_STATUS IN ('CLOSE_PALLET', 'WORKING',  'INSPECTING')
			LEFT JOIN (
				SELECT --TOP 1
					CF.ID_FORM,
					CF.KY_SAMPLE_UNIT AS KY_SAMPLE_UNIT_FORM,
					CF.NO_SAMPLE AS NO_SAMPLE_FORM,
					VUS.NM_SAMPLE_UNIT AS NM_SAMPLE_UNIT_FORM,
					CS.KY_CUSTOMER,
					CS.KY_SAMPLE_UNIT AS KY_SAMPLE_UNIT_CUSTOMER,
					CS.NO_LENGTH_SAMPLE AS NO_SAMPLE_CUSTOMER,
					VUSC.NM_SAMPLE_UNIT AS NM_SAMPLE_UNIT_CUSTOMER,
					CF.KY_PROCESS
				FROM PRD.C_FORM CF
					INNER JOIN ADM.VW_C_SAMPLE_UNIT VUS 
						ON CF.KY_SAMPLE_UNIT = VUS.KY_SAMPLE_UNIT
					LEFT JOIN ADM.C_CUSTOMER_SAMPLES CS 
						ON CF.ID_FORM = CS.ID_FORM
					LEFT JOIN ADM.VW_C_SAMPLE_UNIT VUSC 
						ON CS.KY_SAMPLE_UNIT = VUSC.KY_SAMPLE_UNIT
				WHERE CF.KY_PROCESS = 'QUALITY'
			) FRM_QUALITY_INSPECTOR 
				ON WO.KY_CUSTOMER = FRM_QUALITY_INSPECTOR.KY_CUSTOMER 
			LEFT JOIN #T_READINGS_PER_NO_SKIDS_OPEN RPKO 
				ON WO.ID_WORK_ORDER = RPKO.ID_WORK_ORDER 
				AND KP.ID_INSPECTION_SKID = RPKO.ID_PALLET
			INNER JOIN PRD.K_FORM KF 
				ON KP.ID_INSPECTION_SKID = KF.ID_INSPECTION_SKID
				AND WO.ID_WORK_ORDER = KF.ID_WORK_ORDER  
				AND KF.KY_STATUS_FORM NOT IN ('CAPTURED','CANCELLED') AND KF.KY_PROCESS_TYPE = 'QUALITY'

		WHERE NOT EXISTS (SELECT TOP 1 1 FROM PRD.K_READINGS KR WHERE KR.ID_INSPECTION_SKID = KP.ID_INSPECTION_SKID AND KR.ID_K_FORM IS NULL)
			AND EXISTS (SELECT TOP 1 1 FROM ADM.C_USER CU INNER JOIN ADM.C_EMPLOYEE CE ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE WHERE KY_USER = @KY_USER AND CE.ID_POSITION = @ID_QUALITY_INSPECTOR_POSITION)
			AND @PIN_NM_POSITION = 'QUALITY INSPECTOR'
		UNION ALL
		
		SELECT WO.ID_WORK_ORDER
			, WO.NO_WORK_ORDER
			, WO.ID_ITEM
			, WO.NM_ITEM
			, WO.ID_PRODUCTION_LINE
			, WO.NM_PRODUCTION_LINE	
			, QA.ID_LEADMAN ID_EMPLOYEE
			, QA.NM_LEADMAN NM_EMPLOYEE
			, KP.ID_PALLET
			, KP.NO_PALLET
			,'OPERATOR' /*'LEADMEN'*/ POSITION
			, @KY_USER KY_USER
			, WO.ID_BRANCH_PLANT
			, CI.NO_SAMPLE AS NO_LENGHT_SAMPLE
			, CASE WHEN CF.KY_SAMPLE_UNIT = 'PENCENT' THEN CAST(CEILING(CAST((WO.NO_BOX_QTY * CF.NO_SAMPLE) AS decimal(12,2))/100) AS INT)
				ELSE CF.NO_SAMPLE
			END AS NO_SAMPLE--,CI.NO_SAMPLE
			, CF.KY_SAMPLE_UNIT
			, CF.NM_FORM
			, CF.ID_FORM  
			, KF.ID_K_FORM 
			, KP.KY_STATUS AS KY_STATUS_PALLET  
			, @ID_METRIC_WIDTH AS ID_METRIC_WIDTH
			, @ID_METRIC_LENGHT AS ID_METRIC_LENGHT 
			, @ID_METRIC_THICKNESS AS ID_METRIC_THICKNESS
			, @ID_METRIC_GLOSS AS ID_METRIC_GLOSS
			, @ID_METRIC_LIGHT_TRANSMISSION AS ID_METRIC_LIGHT_TRANSMISSION
			, NULL KY_USER_LEADMEN
			, CAST(WO.NO_WORK_ORDER as nvarchar) AS KY_SELECTION
			, WO.KY_CUSTOMER
			, KF.DT_FORM
			, ISNULL(RPKO.NO_READINGS_MICROMETER,1) AS NO_READINGS_MICROMETER
		FROM PRD.K_WORK_ORDER WO
			INNER JOIN PRD.C_ITEM CI 
				ON CI.ID_ITEM = WO.ID_ITEM
				AND WO.KY_STATUS = 'RUNNING'
			INNER JOIN PRD.K_QA27 QA 
				ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER 
				AND QA.KY_STATUS = 'RUNNING'
				AND QA.ID_LEADMAN = @ID_EMPLOYEE	
			INNER JOIN PRD.K_SHIFT KS 
				ON KS.KY_SHIFT= QA.KY_SHIFT 
				AND KS.ID_PRODUCTION_LINE = WO.ID_PRODUCTION_LINE 
				AND KS.FG_STATUS = 1
			INNER JOIN PRD.K_PALLET KP 
				ON WO.ID_WORK_ORDER = KP.ID_WORK_ORDER --AND KP.KY_STATUS IN ('WORKING', 'INSPECTING', 'INSPECTED') --AND KP.KY_STATUS = 'WORKING' --KF.ID_PALLET = KP.ID_PALLETA
			INNER JOIN PRD.K_FORM KF 
				ON KP.ID_PALLET = KF.ID_PALLET 
				AND WO.ID_WORK_ORDER = KF.ID_WORK_ORDER  --KF.ID_K_FORM = (SELECT MIN(ID_K_FORM) FROM PRD.K_FORM KF WHERE KF.ID_WORK_ORDER = WO.ID_WORK_ORDER AND KF.DT_CLOSED IS NULL AND KF.ID_PALLET = KP.ID_PALLET)		
				AND KF.KY_STATUS_FORM NOT IN ('CAPTURED','CANCELLED')
			INNER JOIN PRD.C_FORM CF 
				ON CF.ID_FORM = KF.ID_FORM 
				AND CF.KY_PROCESS = 'MANUFACTURE'
			LEFT JOIN #T_READINGS_PER_NO_SKIDS_OPEN RPKO 
				ON WO.ID_WORK_ORDER = RPKO.ID_WORK_ORDER 
				AND KP.ID_PALLET = RPKO.ID_PALLET
		WHERE NOT EXISTS(SELECT TOP 1 1 FROM PRD.K_READINGS KR WHERE KR.ID_WORK_ORDER = WO.ID_WORK_ORDER AND KR.ID_PALLET = KP.ID_PALLET AND KR.ID_K_FORM = KF.ID_K_FORM)
		  AND @PIN_NM_POSITION = 'OPERATOR'
	)


	SELECT WO.ID_WORK_ORDER
		 , WO.NO_WORK_ORDER
		 , WO.ID_ITEM
		 , WO.NM_ITEM
		 , WO.ID_PRODUCTION_LINE
		 , WO.NM_PRODUCTION_LINE	
		 , WO.ID_EMPLOYEE
		 , WO.NM_EMPLOYEE
		 , WO.ID_PALLET
		 , WO.NO_PALLET
		 , WO.POSITION
		 , WO.KY_USER
		 , WO.ID_BRANCH_PLANT	 		
		 , WO.NO_LENGHT_SAMPLE
		 , WO.NO_SAMPLE
		 , WO.KY_SAMPLE_UNIT				 
		 , WO.NM_FORM
		 , WO.ID_FORM
		 , WO.ID_K_FORM
		 , WO.KY_STATUS_PALLET
		 , WO.ID_METRIC_WIDTH
		 , WO.ID_METRIC_LENGHT 
		 , WO.ID_METRIC_THICKNESS
		 , WO.ID_METRIC_GLOSS
		 , WO.ID_METRIC_LIGHT_TRANSMISSION
		 , WO.KY_USER_LEADMEN
		 , WO.KY_SELECTION
		 , WO.DT_FORM
		 , WO.NO_READINGS_MICROMETER
     FROM TB_WORK_ORDER_DATA WO

