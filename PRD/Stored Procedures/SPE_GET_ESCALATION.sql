﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CREATE date: 20/04/2017
-- Description: get all scaled by form or issue
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_ESCALATION] 
	 @PIN_ID_BRANCH_PLANT INT = NULL
	,@PIN_ID_ISSUE INT = NULL
	,@PIN_ID_FORM INT = NULL
	,@PIN_ID_PALLET INT = NULL
	,@PIN_ID_K_FORM INT = NULL
	,@KY_PROCESS NVARCHAR(50) = NULL

AS   

	DECLARE @KY_SCALING_STATUS_HOLD_ON NVARCHAR(10) = 'HOLD_ON'

	DECLARE @T_SCALINGS TABLE (
		ID_SCALING INT
		, ID_K_FORM INT
		, ID_ISSUE INT
		, ID_FORM INT
		, ID_PALLET INT
		, ID_BRANCH_PLANT INT
		, ID_BRANCH_PLANT_POSITION INT
		, NO_LEVEL INT
		, NO_FREQUENCY INT
		, NO_TIME_HOLD_ON INT
		, KY_PROCESS NVARCHAR(50)
		, KY_RECIPIENTS XML
		, KY_TELEGRAM NVARCHAR(15)
		, KY_EMAIL NVARCHAR(500)
		, DT_START_SCALING DATETIME
		, KY_SCALING_STATUS NVARCHAR(10)
		, NM_FORM NVARCHAR(10)
		, DS_BODY NVARCHAR(500)
		, NM_TITLE NVARCHAR(100)
		, NM_SUBJECT NVARCHAR(200)
		, KY_URL NVARCHAR(500)
		, KY_URL_PARAMETERS NVARCHAR(1000)
		, XML_URL_PARAMETERS XML
		, NO_WINDOW_WIDTH NVARCHAR(5)
		, NO_WINDOW_HEIGHT NVARCHAR(5)
		, FG_TELEGRAM NVARCHAR(1)
		, FG_EMAIL NVARCHAR(1)
		, FG_ALERT NVARCHAR(1)
		, FG_FORM NVARCHAR(1)
		, KY_USER NVARCHAR(50)
		, NM_PROGRAM NVARCHAR(50)
		, ID_PRODUCTION_LINE INT
	)

	DECLARE @T_USER_SCALING TABLE (
		ID_SCALING INT
		, ID_SCALING_PROCESS INT
		, ID_POSITION INT
		, KY_USER NVARCHAR(50)
	)

	DECLARE @TB_IPS_PRODUCTION_LINE TABLE (
		 ROWNUMBER INT
		, NO_IP NVARCHAR(20)
		, ID_PRODUCTION_LINE INT
	)

	INSERT INTO @T_USER_SCALING (ID_SCALING, ID_SCALING_PROCESS, ID_POSITION, KY_USER)
	SELECT KS.ID_SCALING
		, KS.ID_SCALING_PROCESS
		, CP.ID_POSITION
		, CU.KY_USER

	FROM PRD.K_SCALING KS
		INNER JOIN PRD.K_SCALING_PROCESS KPS 
			ON KPS.ID_SCALING_PROCESS = KS.ID_SCALING_PROCESS
		INNER JOIN ADM.C_POSITION CP 
			ON CP.ID_POSITION = KS.ID_POSITION
		INNER JOIN ADM.C_EMPLOYEE CE 
			ON CE.ID_POSITION = CP.ID_POSITION AND CE.FG_ACTIVE = 1 
				AND CE.ID_BRANCH_PLANT = CP.ID_BRANCH_PLANT
		INNER JOIN ADM.C_USER CU 
			ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE 
				AND CU.ID_BRANCH_PLANT = CP.ID_BRANCH_PLANT
	WHERE KPS.ID_ISSUE IS NOT NULL --= @PIN_ID_ISSUE
		--AND CP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT

		INSERT INTO @TB_IPS_PRODUCTION_LINE
		SELECT IPS.ROWNUMBER, IPS.NO_IP, IPS.ID_PRODUCTION_LINE
		FROM (
			SELECT ROW_NUMBER() OVER(PARTITION BY ID_PRODUCTION_LINE ORDER BY ID_PRODUCTION_LINE_IP) ROWNUMBER
	           , CIP.NO_IP
			   , CIP.ID_PRODUCTION_LINE
 			FROM PRD.C_PRODUCTION_LINE_IP CIP
		) IPS 
		WHERE IPS.ROWNUMBER = 1


	INSERT INTO @T_SCALINGS (
		ID_SCALING
		, ID_K_FORM
		, ID_ISSUE
		, ID_FORM
		, ID_PALLET
		, ID_BRANCH_PLANT
		, ID_BRANCH_PLANT_POSITION
		, NO_LEVEL
		, NO_FREQUENCY
		, KY_PROCESS
		, NO_TIME_HOLD_ON
		, KY_RECIPIENTS
		, KY_TELEGRAM
		, KY_EMAIL
		, DT_START_SCALING
		, KY_SCALING_STATUS
		, NM_FORM
		, DS_BODY
		, NM_TITLE
		, NM_SUBJECT
		, KY_URL
		, KY_URL_PARAMETERS
		, XML_URL_PARAMETERS
		, NO_WINDOW_WIDTH
		, NO_WINDOW_HEIGHT
		, FG_TELEGRAM
		, FG_EMAIL
		, FG_ALERT
		, FG_FORM
		, KY_USER
		, NM_PROGRAM
		, ID_PRODUCTION_LINE
	)
	SELECT DISTINCT				-- RETRIEVE ISSUES ESCALATIONS
		KS.ID_SCALING
		, KSP.ID_K_FORM
		, KSP.ID_ISSUE	 
		, NULL AS ID_FORM
		, NULL ID_PALLET
		, KSP.ID_BRANCH_PLANT
		, CP.ID_BRANCH_PLANT ID_BRANCH_PLANT_POSITION
		, KS.NO_LEVEL
		, 0 AS NO_FRECUENCY
		, '' KY_PROCESS	
		, KS.NO_TIME_HOLD_ON			
		, '<RECIPIENTS>' + (CASE 				
			WHEN KS.NO_LEVEL = 1
				THEN (SELECT KY_USER AS "@TO" FROM ADM.C_USER WHERE ID_EMPLOYEE = QA.ID_LEADMAN FOR XML PATH('RECIPIENT')) 
			ELSE
				(SELECT CU.KY_USER AS "@TO" FROM ADM.C_EMPLOYEE CE 
					INNER JOIN ADM.C_USER CU ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE AND CU.ID_BRANCH_PLANT = CE.ID_BRANCH_PLANT
				WHERE CE.ID_POSITION =CP.ID_POSITION
				FOR XML PATH('RECIPIENT'))
			END) + '</RECIPIENTS>' KY_USER
		, CP.KY_TELEGRAM
		, CP.KY_EMAIL
		, KS.DT_START_SCALING
		, KS.KY_STATUS
		, CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NM_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT NM_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END NM_FORM
		, CASE 
			WHEN KS.NO_LEVEL = 1 THEN 
				REPLACE(
						REPLACE(
								REPLACE(
									REPLACE(
												(SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
											,'@NM_PRODUCTION_LINE',ISNULL(WO.NM_PRODUCTION_LINE,''))
											,'@NM_LEADMAN',ISNULL(QA.ID_LEADMAN,''))
											,'@PIN_NM_PROBLEM_CODE',ISNULL(PA.NM_PROBLEM_AREA,''))
											,'@PIN_NM_PROBLEM_AREA',ISNULL(PC.NM_PROBLEM_CODE,''))
			ELSE REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING'),'@USER_INVOLVED',KI.KY_USER_INVOLVED),'@LINE',WO.NM_PRODUCTION_LINE)
		END BODY			
		, CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT DS_TITLE FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT DS_TITLE FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END TITLE
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT DS_SUBJECT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT DS_SUBJECT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END SUBJECT
		,CASE  
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NM_URL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT NM_URL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END URL			
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN REPLACE((SELECT NM_URL_PARAMETERS FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED'),'@NM_URL_PARAMETERS',KI.ID_ISSUE)
			ELSE (SELECT NM_URL_PARAMETERS FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END URL_PARAMETERS
		, (SELECT 'ID_ISSUE' AS '@KY_PARAMETER', KI.ID_ISSUE AS '@KY_VALUE' FOR XML PATH('PARAMETER'), ROOT ('PARAMETERS')) AS XML_PARAMETERS		
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NO_WIDTH FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT NO_WIDTH FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END NO_WIDTH			
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NO_HEIGHT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT NO_HEIGHT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END NO_HEIGHT
		,CASE 
			WHEN CP.KY_TELEGRAM IS NULL THEN 0
			WHEN KS.NO_LEVEL = 1 THEN (SELECT FG_TELEGRAM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT FG_TELEGRAM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END FG_TELEGRAM			
		,CASE 
			WHEN CP.KY_EMAIL IS NULL THEN 0
			WHEN KS.NO_LEVEL = 1 THEN (SELECT FG_EMAIL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT FG_EMAIL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END FG_EMAIL
		,CASE 
			WHEN US.KY_USER IS NULL THEN 0
			WHEN KS.NO_LEVEL = 1 THEN (SELECT FG_ALERT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT FG_ALERT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END FG_ALERT						
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT FG_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_CREATED')
			ELSE (SELECT FG_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING')
		END FG_FORM			
		, KI.KY_USER_APP_CREATION USER_CREATION
		, KI.NM_PROGAM_CREATE PROGRAM_CREATION
		, WO.ID_PRODUCTION_LINE
	FROM PRD.K_SCALING_PROCESS KSP
		INNER JOIN PRD.K_SCALING KS 
			ON KS.ID_SCALING_PROCESS = KSP.ID_SCALING_PROCESS 
				AND KS.KY_STATUS = @KY_SCALING_STATUS_HOLD_ON
		INNER JOIN PRD.K_ISSUE KI 
			ON KI.ID_ISSUE= KSP.ID_ISSUE
		INNER JOIN PRD.K_WORK_ORDER WO 
			ON WO.ID_WORK_ORDER = KI.ID_WORK_ORDER
		INNER JOIN ADM.C_POSITION CP 
			ON CP.ID_POSITION = KS.ID_POSITION
		LEFT JOIN @T_USER_SCALING US 
			ON US.ID_SCALING = KS.ID_SCALING
		INNER JOIN PRD.C_PROBLEM_AREA PA 
			ON PA.ID_PROBLEM_AREA = KI.ID_PROBLEM_AREA
		INNER JOIN PRD.C_PROBLEM_CODE PC 
			ON PC.ID_PROBLEM_CODE = KI.ID_PROBLEM_CODE
		INNER JOIN PRD.K_QA27 QA 
			ON QA.ID_QA27 = KI.ID_QA27
	WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND KSP.ID_BRANCH_PLANT= @PIN_ID_BRANCH_PLANT)) AND
		(@PIN_ID_ISSUE IS NULL OR (@PIN_ID_ISSUE IS NOT NULL AND KSP.ID_ISSUE = @PIN_ID_ISSUE))				

	UNION ALL

	SELECT DISTINCT			-- RETRIEVE FORM ESCALATIONS
		KS.ID_SCALING
		,KSP.ID_K_FORM
		,NULL AS ID_ISSUE	 
		,KSP.ID_FORM
		,NULL AS ID_PALLET
		,KSP.ID_BRANCH_PLANT
		,CP.ID_BRANCH_PLANT ID_BRANCH_PLANT_POSITION
		,KS.NO_LEVEL
		,CF.NO_FREQUENCE
		,CF.KY_PROCESS
		,KS.NO_TIME_HOLD_ON
		,'<RECIPIENTS>' + (SELECT CU.KY_USER AS "@TO" FROM ADM.C_EMPLOYEE CE 
				INNER JOIN ADM.C_USER CU ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE AND CU.ID_BRANCH_PLANT = CE.ID_BRANCH_PLANT
			WHERE CE.ID_POSITION =CP.ID_POSITION
			FOR XML PATH('RECIPIENT')
			) + '</RECIPIENTS>' KY_RECIPIENTS
		,CP.KY_TELEGRAM
		,CP.KY_EMAIL
		,KS.DT_START_SCALING
		,KS.KY_STATUS
		, CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NM_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT NM_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END NM_FORM
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN 
					REPLACE(
						REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM'),'@USER_INVOLVED',ISNULL(QA.NM_LEADMAN,'')),
								'@LINE',ISNULL(WO.NM_PRODUCTION_LINE,'')
								)
			ELSE REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM'),'@USER_INVOLVED',QA.NM_LEADMAN),'@LINE',WO.NM_PRODUCTION_LINE)
		END BODY			
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT DS_TITLE FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT DS_TITLE FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END TITLE			
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT DS_SUBJECT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT DS_SUBJECT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END NM_SUBJECT
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NM_URL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT NM_URL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END URL			
		, NULL AS URL_PARAMETERS			
		, NULL AS XML_URL_PARAMETERS
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NO_WIDTH FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT NO_WIDTH FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END NO_WIDTH			
		,CASE 
			WHEN KS.NO_LEVEL = 1 THEN (SELECT NO_HEIGHT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT NO_HEIGHT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END NO_HEIGHT
		,CASE 
			WHEN CP.KY_TELEGRAM IS NULL THEN 0
			WHEN KS.NO_LEVEL = 1 THEN (SELECT FG_TELEGRAM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT FG_TELEGRAM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END FG_TELEGRAM			
		,CASE 
			WHEN CP.KY_EMAIL IS NULL THEN 0
			WHEN KS.NO_LEVEL = 1 THEN (SELECT FG_EMAIL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
			ELSE (SELECT FG_EMAIL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM')
		END FG_EMAIL
		, (SELECT FG_ALERT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='ISSUE_SCALING') FG_ALERT						
		, (SELECT FG_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='FORM') FG_FORM		
		, K.KY_USER_APP_CREATION USER_CREATION
		, K.NM_PROGAM_CREATE PROGRAM_CREATION
		, WO.ID_PRODUCTION_LINE
	FROM PRD.K_SCALING_PROCESS KSP
		INNER JOIN PRD.K_SCALING KS 
			ON KS.ID_SCALING_PROCESS = KSP.ID_SCALING_PROCESS 
			AND KS.KY_STATUS = @KY_SCALING_STATUS_HOLD_ON
		INNER JOIN PRD.K_FORM K 
			ON K.ID_K_FORM = KSP.ID_K_FORM
		INNER JOIN PRD.K_WORK_ORDER WO 
			ON WO.ID_WORK_ORDER = K.ID_WORK_ORDER
		INNER JOIN PRD.K_QA27 QA 
			ON QA.ID_QA27 = K.ID_QA27
		LEFT JOIN @T_SCALINGS US 
			ON US.ID_SCALING = KS.ID_SCALING
		INNER JOIN PRD.C_FORM CF 
			ON CF.ID_FORM = KSP.ID_FORM				
		INNER JOIN ADM.C_POSITION CP 
			ON CP.ID_POSITION = KS.ID_POSITION 
	WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND KSP.ID_BRANCH_PLANT= @PIN_ID_BRANCH_PLANT)) AND
		(@PIN_ID_FORM IS NULL OR (@PIN_ID_FORM IS NOT NULL AND KSP.ID_FORM = @PIN_ID_FORM)) AND 
		(@PIN_ID_K_FORM IS NULL OR (@PIN_ID_K_FORM IS NOT NULL AND KSP.ID_K_FORM = @PIN_ID_K_FORM))

	UNION ALL	
				
		SELECT DISTINCT			-- RETRIEVE CLOSE PALLET ESCALATIONS
			 KS.ID_SCALING
			,KSP.ID_K_FORM
			,NULL ID_ISSUE	 
			,NULL ID_FORM
			,KP.ID_PALLET
			,KSP.ID_BRANCH_PLANT
			,CP.ID_BRANCH_PLANT ID_BRANCH_PLANT_POSITION
			,KS.NO_LEVEL
			,NULL NO_FREQUENCE
			,NULL KY_PROCESS
			,KS.NO_TIME_HOLD_ON
			,'<RECIPIENTS>' + (SELECT CU.KY_USER AS "@TO" FROM ADM.C_EMPLOYEE CE 
						INNER JOIN ADM.C_USER CU ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE AND (CU.ID_BRANCH_PLANT = CE.ID_BRANCH_PLANT or CU.ID_BRANCH_PLANT is NULL)
					WHERE CE.ID_POSITION =CP.ID_POSITION
					FOR XML PATH('RECIPIENT')
					) + '</RECIPIENTS>' KY_USER
			,CP.KY_TELEGRAM
			,CP.KY_EMAIL
			,KS.DT_START_SCALING
			,KS.KY_STATUS
			,(SELECT NM_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																				CASE 
																					WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																						THEN 'OPEN_PALLET' 
																					WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																						THEN 'CLOSE_PALLET' 
																					WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																						THEN 'CLOSE_PALLET_SCALING' 																																																																		
																					WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																						THEN 'VERDICT'  
																					WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																						THEN 'VERDICT_SCALING'
																					WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																						THEN 'MBR_RESOLUTION'
																					WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																						THEN 'MBR_RESOLUTION_SCALING'
																				END) NM_FORM
			,CASE
				WHEN @KY_PROCESS = 'OPEN_PALLET' AND KS.NO_LEVEL = 1 THEN REPLACE(REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='OPEN_PALLET'),'@NM_LEADMAN',ISNULL(KP.NM_LEADMAN,'')),'@NO_PALLET',ISNULL(KP.NO_PALLET,'')),'@NM_PRODUCTION_LINE',ISNULL(WO.ID_PRODUCTION_LINE,''))
				WHEN @KY_PROCESS = 'CLOSE_PALLET' AND KS.NO_LEVEL = 1 THEN REPLACE(REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='CLOSE_PALLET'),'@NM_LEADMAN',ISNULL(KP.NM_LEADMAN,'')),'@NO_PALLET',ISNULL(KP.NO_PALLET,'')),'@NM_PRODUCTION_LINE',ISNULL(WO.ID_PRODUCTION_LINE,''))
				WHEN @KY_PROCESS = 'CLOSE_PALLET' AND KS.NO_LEVEL > 1 THEN REPLACE(REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='CLOSE_PALLET_SCALING'),'@QUALITY_INSPECTOR',ISNULL(KP.NM_QUALITY_INSPECTOR_AGREEMENT,'')),'@PIN_NO_PALLET',ISNULL(KP.NO_PALLET,'')),'@NM_PRODUCTION_LINE',ISNULL(WO.ID_PRODUCTION_LINE,''))
				WHEN @KY_PROCESS='VERDICT' AND KS.NO_LEVEL = 1 THEN REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='VERDICT'),'@QUALITY_INSPECTOR',ISNULL(KP.NM_QUALITY_INSPECTOR_AGREEMENT,'')),'@NO_PALLET',ISNULL(KP.NO_PALLET,''))
				WHEN @KY_PROCESS='VERDICT' AND KS.NO_LEVEL > 1 THEN REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='VERDICT_SCALING'),'@NO_PALLET',ISNULL(KP.NO_PALLET,'')),'@NM_PRODUCTION_LINE',ISNULL(WO.ID_PRODUCTION_LINE,''))
				WHEN @KY_PROCESS='MBR_RESOLUTION' AND KS.NO_LEVEL = 1 THEN REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='MBR_RESOLUTION'),'@QUALITY_INSPECTOR',ISNULL(KP.NM_QUALITY_INSPECTOR_AGREEMENT,'')),'@NO_PALLET',ISNULL(KP.NO_PALLET,''))
				WHEN @KY_PROCESS='MBR_RESOLUTION' AND KS.NO_LEVEL > 1 THEN REPLACE(REPLACE((SELECT DS_BODY FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS='MBR_RESOLUTION_SCALING'),'@QUALITY_INSPECTOR',ISNULL(KP.NM_QUALITY_INSPECTOR_AGREEMENT,'')),'@NO_PALLET',ISNULL(KP.NO_PALLET,''))
			 END BODY
			,(SELECT DS_TITLE FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET'
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END) TITLE
			,(SELECT DS_SUBJECT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET'
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END) SUBJECT
			,(SELECT NM_URL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END) URL
			,(SELECT NM_URL_PARAMETERS 
				FROM PRD.VW_C_PROCESS_NOTIFICATION 
				WHERE KY_PROCESS = CASE 
					WHEN KP.KY_STATUS='WORKING' AND KS.NO_LEVEL =1 THEN 'OPEN_PALLET'
					WHEN KP.KY_STATUS='INSPECTED' AND KS.NO_LEVEL =1 THEN 'CLOSE_PALLET'
					WHEN KP.KY_STATUS='INSPECTED' AND KS.NO_LEVEL > 1 THEN 'CLOSE_PALLET_SCALING'
					WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1 THEN 'VERDICT'
					WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1 THEN 'VERDICT_SCALING'
					WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1 THEN 'MBR_RESOLUTION'
					WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1 THEN 'MBR_RESOLUTION_SCALING'
				END
			) URL_PARAMETERS 
			, NULL AS XML_URL_PARAMETERS
			,(SELECT NO_WIDTH FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END) NO_WIDTH 
			,(SELECT NO_HEIGHT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END) NO_HEIGHT
			,(SELECT FG_TELEGRAM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END)  FG_TELEGRAM
			,(SELECT FG_EMAIL FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'  
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END)  FG_EMAIL
			,(SELECT FG_ALERT FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END) FG_ALERT	
			,(SELECT FG_FORM FROM PRD.VW_C_PROCESS_NOTIFICATION WHERE KY_PROCESS=
																					CASE 
																						WHEN KP.KY_STATUS='WORKING'  AND KS.NO_LEVEL =1
																							THEN 'OPEN_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL =1
																							THEN 'CLOSE_PALLET' 
																						WHEN KP.KY_STATUS='INSPECTED'  AND KS.NO_LEVEL > 1
																							THEN 'CLOSE_PALLET_SCALING' 																																													
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL = 1
																							THEN 'VERDICT'  
																						WHEN KP.KY_STATUS='NON_CONFORMANCE' AND KS.NO_LEVEL > 1
																							THEN 'VERDICT_SCALING'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL = 1
																							THEN 'MBR_RESOLUTION'
																						WHEN KP.KY_STATUS='HOLD_ON' AND KS.NO_LEVEL > 1
																							THEN 'MBR_RESOLUTION_SCALING'
																					END)  FG_FORM	
			,KSP.KY_USER_APP_CREATION USER_CREATION
			,KSP.NM_PROGAM_CREATE PROGRAM_CREATION	
			,WO.ID_PRODUCTION_LINE	
		FROM PRD.K_SCALING_PROCESS KSP
			INNER JOIN PRD.K_SCALING KS 
				ON KS.ID_SCALING_PROCESS= KSP.ID_SCALING_PROCESS AND KS.KY_STATUS=@KY_SCALING_STATUS_HOLD_ON
			INNER JOIN PRD.K_PALLET KP 
				ON KP.ID_PALLET = KSP.ID_PALLET				
			INNER JOIN PRD.K_WORK_ORDER WO 
				ON WO.ID_WORK_ORDER = KP.ID_WORK_ORDER
			INNER JOIN ADM.C_POSITION CP 
				ON CP.ID_POSITION = KS.ID_POSITION --AND CPC.ID_BRANCH_PLANT = CPC.ID_BRANCH_PLANT
		WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND KSP.ID_BRANCH_PLANT= @PIN_ID_BRANCH_PLANT)) AND
			(@PIN_ID_PALLET IS NULL OR (@PIN_ID_PALLET IS NOT NULL AND KSP.ID_PALLET = @PIN_ID_PALLET)) 
			

	SELECT TS.ID_SCALING
		, TS.ID_K_FORM
		, TS.ID_ISSUE
		, TS.ID_FORM
		, TS.ID_PALLET
		, TS.ID_BRANCH_PLANT
		, TS.ID_BRANCH_PLANT_POSITION
		, TS.NO_LEVEL
		, TS.NO_FREQUENCY
		, TS.KY_PROCESS
		, TS.NO_TIME_HOLD_ON
		, TS.KY_RECIPIENTS
		, TS.KY_TELEGRAM
		, TS.KY_EMAIL
		, TS.DT_START_SCALING
		, TS.KY_SCALING_STATUS
		, TS.NM_FORM
		, TS.DS_BODY
		, TS.NM_TITLE
		, TS.NM_SUBJECT
		, TS.KY_URL
		, TS.KY_URL_PARAMETERS
		, TS.XML_URL_PARAMETERS
		, TS.NO_WINDOW_WIDTH
		, TS.NO_WINDOW_HEIGHT
		, TS.FG_TELEGRAM
		, TS.FG_EMAIL
		, TS.FG_ALERT
		, TS.FG_FORM
		, TS.KY_USER
		, TS.NM_PROGRAM
		, TS.ID_PRODUCTION_LINE
		, IPS.NO_IP
	FROM @T_SCALINGS TS
	JOIN @TB_IPS_PRODUCTION_LINE IPS ON TS.ID_PRODUCTION_LINE = IPS.ID_PRODUCTION_LINE
