﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Ivan Guerrero
-- CREATE date: 01/15/2018
-- Description: Get specific issue record to modify time values
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_ISSUE_RECORD]
	@PIN_ID_ISSUE AS int = NULL
AS
BEGIN
	
	DECLARE @DT_SYSTEM DATETIME = GETDATE()

	DECLARE @T_EVENTS TABLE (
			ID_PRODUCTION_LINE INT 
		, DT_CLOSED_EVENT DATETIME
		, KY_EVENT_TYPE NVARCHAR(20)
	)

	DECLARE @T_ISSUE_RECORD TABLE (
		ID_ISSUE INT NOT NULL		
		, ID_WORK_ORDER INT NOT NULL		
		, NM_PRODUCTION_LINE NVARCHAR(300) NOT NULL
		, ID_PROBLEM_CODE INT NOT NULL
		, NM_PROBLEM_CODE NVARCHAR(100) NOT NULL
		, XML_POSITIONS_INVOLVED XML 
		, DT_ISSUE DATETIME
		, DT_ISSUE_CLOSED DATETIME
		, NO_TIME_BEFORE_HELP INT
		, FG_LINE_DOWN BIT		
		, DT_MIN_START DATETIME
		, DT_MAX_START DATETIME
		, DT_MIN_END DATETIME
		, DT_MAX_END DATETIME
	)

	DECLARE @T_ISSUE_DT_MIN_MAX TABLE (
		ID_WORK_ORDER INT NOT NULL
		, ID_PRODUCTION_LINE INT NOT NULL	
		, DT_MIN_START DATETIME
		, DT_MAX_END DATETIME
	)

	; WITH T_PARAM_ISSUE AS (
		SELECT KI.ID_ISSUE
			, KI.ID_WORK_ORDER
			, KI.ID_QA27
			, KI.DT_ISSUE
			, ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) AS DT_ISSUE_CLOSED
		FROM PRD.K_ISSUE KI
		WHERE KI.ID_ISSUE = @PIN_ID_ISSUE
	), T_WORK_ORDER AS (
		SELECT
			WO.ID_WORK_ORDER
			, WO.ID_PRODUCTION_LINE
			, WO.DT_START_WORK_ORDER
			, QA.ID_QA27
			, QA.KY_STATUS KY_STATUS_QA27
			, WO.KY_STATUS KY_STATUS_WO
			, QA.DT_INITIAL_TIME
			, ISNULL((SELECT TOP 1 DT_FORM FROM PRD.K_FORM WHERE ID_WORK_ORDER = WO.ID_WORK_ORDER AND KY_PROCESS_TYPE = 'MANUFACTURE' AND KY_STATUS_FORM = 'CAPTURED' ORDER BY DT_FORM DESC), @DT_SYSTEM) AS DT_LAST_FORM
			, ROW_NUMBER() OVER (PARTITION BY WO.ID_PRODUCTION_LINE ORDER BY WO.ID_PRODUCTION_LINE ASC, QA.DT_INITIAL_TIME DESC) AS NO_ROW
			, TPI.DT_ISSUE
			, TPI.DT_ISSUE_CLOSED
		FROM PRD.K_WORK_ORDER WO
			INNER JOIN T_PARAM_ISSUE TPI
				ON WO.ID_WORK_ORDER = TPI.ID_WORK_ORDER
			INNER JOIN PRD.K_QA27 QA
				ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER
				AND TPI.DT_ISSUE BETWEEN QA.DT_INITIAL_TIME AND ISNULL(QA.DT_FINAL_TIME, @DT_SYSTEM)
		WHERE WO.ID_WORK_ORDER = TPI.ID_WORK_ORDER 
			AND WO.KY_STATUS NOT IN ('SCHEDULED', 'SKIPPED')
	) 
	
	INSERT INTO @T_ISSUE_DT_MIN_MAX (
		ID_WORK_ORDER
		, ID_PRODUCTION_LINE
		, DT_MIN_START
		, DT_MAX_END
	) 
	SELECT ID_WORK_ORDER
		, ID_PRODUCTION_LINE
		, DT_ISSUE
		, ISNULL(DT_ISSUE_CLOSED, @DT_SYSTEM)
	FROM T_WORK_ORDER 
	WHERE NO_ROW = 1

	; WITH T_MANUFACTURE_FORMS AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY TWO.ID_PRODUCTION_LINE ORDER BY TWO.ID_PRODUCTION_LINE, ISNULL(KF.DT_CLOSED, @DT_SYSTEM) DESC) AS NO_ROW
			, TWO.ID_PRODUCTION_LINE
			, ISNULL(KF.DT_CLOSED, @DT_SYSTEM) AS DT_CLOSED
		FROM PRD.K_FORM KF
			INNER JOIN @T_ISSUE_DT_MIN_MAX TWO
				ON KF.ID_WORK_ORDER = TWO.ID_WORK_ORDER
				AND KF.DT_FORM < TWO.DT_MIN_START
				AND KF.KY_PROCESS_TYPE = 'MANUFACTURE'
	), T_ISSUES AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY TWO.ID_PRODUCTION_LINE ORDER BY TWO.ID_PRODUCTION_LINE, ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) DESC) AS NO_ROW
			, TWO.ID_PRODUCTION_LINE
			, ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) AS DT_CLOSED
		FROM PRD.K_ISSUE KI
			INNER JOIN @T_ISSUE_DT_MIN_MAX TWO
				ON KI.ID_WORK_ORDER = TWO.ID_WORK_ORDER
				AND KI.DT_ISSUE < TWO.DT_MIN_START					
	), T_EVENTS AS (
		SELECT ID_PRODUCTION_LINE, DT_CLOSED, 'FORMS' AS KY_EVENT_TYPE FROM T_MANUFACTURE_FORMS WHERE NO_ROW = 1 UNION ALL
		SELECT ID_PRODUCTION_LINE, DT_CLOSED, 'ISSUE' AS KY_EVENT_TYPE FROM T_ISSUES WHERE NO_ROW = 1
	), T_LAST_EVENT AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY TE.ID_PRODUCTION_LINE ORDER BY TE.ID_PRODUCTION_LINE, TE.DT_CLOSED DESC) AS NO_ROW
			, ID_PRODUCTION_LINE
			, DT_CLOSED AS DT_CLOSED_EVENT
			, KY_EVENT_TYPE
		FROM T_EVENTS TE
	)

	UPDATE @T_ISSUE_DT_MIN_MAX
	SET DT_MIN_START = TLE.DT_CLOSED_EVENT
	FROM @T_ISSUE_DT_MIN_MAX TIS
		INNER JOIN T_LAST_EVENT TLE
			ON TLE.ID_PRODUCTION_LINE = TIS.ID_PRODUCTION_LINE
			AND NO_ROW = 1

	; WITH T_MANUFACTURE_FORMS AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY TWO.ID_PRODUCTION_LINE ORDER BY TWO.ID_PRODUCTION_LINE, ISNULL(KF.DT_CLOSED, @DT_SYSTEM) ASC) AS NO_ROW
			, TWO.ID_PRODUCTION_LINE
			, ISNULL(KF.DT_FORM, @DT_SYSTEM) AS DT_CLOSED
		FROM PRD.K_FORM KF
			INNER JOIN @T_ISSUE_DT_MIN_MAX TWO
				ON KF.ID_WORK_ORDER = TWO.ID_WORK_ORDER
				AND KF.DT_FORM > TWO.DT_MIN_START
				AND KF.KY_PROCESS_TYPE = 'MANUFACTURE'
	), T_ISSUES AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY TWO.ID_PRODUCTION_LINE ORDER BY TWO.ID_PRODUCTION_LINE, ISNULL(KI.DT_ISSUE, @DT_SYSTEM) ASC) AS NO_ROW
			, TWO.ID_PRODUCTION_LINE
			, ISNULL(KI.DT_ISSUE, @DT_SYSTEM) AS DT_CLOSED
		FROM PRD.K_ISSUE KI
			INNER JOIN @T_ISSUE_DT_MIN_MAX TWO
				ON KI.ID_WORK_ORDER = TWO.ID_WORK_ORDER
				AND KI.DT_ISSUE > TWO.DT_MIN_START
				AND KI.ID_ISSUE != @PIN_ID_ISSUE
	), T_EVENTS AS (
		SELECT ID_PRODUCTION_LINE, DT_CLOSED, 'FORMS' AS KY_EVENT_TYPE FROM T_MANUFACTURE_FORMS WHERE NO_ROW = 1 UNION ALL
		SELECT ID_PRODUCTION_LINE, DT_CLOSED, 'ISSUE' AS KY_EVENT_TYPE FROM T_ISSUES WHERE NO_ROW = 1
	), T_NEXT_EVENT AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY TE.ID_PRODUCTION_LINE ORDER BY TE.ID_PRODUCTION_LINE, TE.DT_CLOSED ASC) AS NO_ROW
			, ID_PRODUCTION_LINE
			, DT_CLOSED AS DT_CLOSED_EVENT
			, KY_EVENT_TYPE
		FROM T_EVENTS TE
	) 


	UPDATE @T_ISSUE_DT_MIN_MAX
	SET DT_MAX_END = TNE.DT_CLOSED_EVENT
	FROM @T_ISSUE_DT_MIN_MAX TIS
	INNER JOIN T_NEXT_EVENT TNE
	ON TNE.ID_PRODUCTION_LINE = TIS.ID_PRODUCTION_LINE
	AND NO_ROW = 1
		
	; WITH T_ISSUE_RECORD AS (
		SELECT	KI.ID_ISSUE			
			, KI.ID_WORK_ORDER				
			, PL.NM_PRODUCTION_LINE			
			, KI.ID_PROBLEM_CODE
			, PC.NM_PROBLEM_CODE	
			, KI.XML_POSITIONS_INVOLVED					
			, KI.DT_ISSUE		
			, KI.DT_ISSUE_CLOSED		
			, KI.NO_TIME_BEFORE_HELP		
			, KI.FG_LINE_DOWN				
		FROM PRD.K_ISSUE KI				
			LEFT JOIN PRD.C_PROBLEM_CODE PC 
				ON KI.ID_PROBLEM_CODE = PC.ID_PROBLEM_CODE		
			LEFT JOIN PRD.C_PRODUCTION_LINE PL 
				ON PL.ID_PRODUCTION_LINE = KI.ID_PRODUCTION_LINE					
		WHERE (@PIN_ID_ISSUE IS NULL OR (@PIN_ID_ISSUE IS NOT NULL AND KI.ID_ISSUE = @PIN_ID_ISSUE))
	)	
	INSERT INTO @T_ISSUE_RECORD(
		ID_ISSUE	
		, ID_WORK_ORDER	
		, NM_PRODUCTION_LINE
		, ID_PROBLEM_CODE
		, NM_PROBLEM_CODE
		, XML_POSITIONS_INVOLVED
		, DT_ISSUE
		, DT_ISSUE_CLOSED
		, NO_TIME_BEFORE_HELP
		, FG_LINE_DOWN	
		, DT_MIN_START
		, DT_MAX_START
		, DT_MIN_END
		, DT_MAX_END
	) SELECT 
		ID_ISSUE	
		, TIR.ID_WORK_ORDER	
		, NM_PRODUCTION_LINE
		, ID_PROBLEM_CODE
		, NM_PROBLEM_CODE
		, XML_POSITIONS_INVOLVED
		, DT_ISSUE
		, ISNULL(DT_ISSUE_CLOSED, @DT_SYSTEM)
		, NO_TIME_BEFORE_HELP
		, FG_LINE_DOWN			
		, TID.DT_MIN_START
		, ISNULL(DT_ISSUE_CLOSED, @DT_SYSTEM)
		, DT_ISSUE 
		, ISNULL(TID.DT_MAX_END, @DT_SYSTEM)
	FROM T_ISSUE_RECORD TIR
		, @T_ISSUE_DT_MIN_MAX TID
 
	SELECT ID_ISSUE	
		, ID_WORK_ORDER	
		, NM_PRODUCTION_LINE
		, ID_PROBLEM_CODE
		, NM_PROBLEM_CODE
		, XML_POSITIONS_INVOLVED
		, DT_ISSUE
		, DT_ISSUE_CLOSED
		, NO_TIME_BEFORE_HELP
		, FG_LINE_DOWN	
		, DT_MIN_START
		, DT_MAX_START
		, DT_MIN_END
		, DT_MAX_END		
	FROM @T_ISSUE_RECORD
	
END

