﻿-- ====================================== =======
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 3/08/2018
-- Description: get all issues DOWN TIME
-- =============================================
-- 11/30/2018 JDR The query is changed to include the issues that are present during the registration of the QA27 while it is alive on the turn
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_QA27_ISSUES_DOWN_TIME] 
	@PIN_ID_QA27 AS INT = NULL
AS   
	
	DECLARE @DT_SYSTEM DATETIME = GETDATE()

	SELECT KI.ID_ISSUE
		, KI.DT_ISSUE AS DT_CONFIRMED
		, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE()) AS DT_ISSUE_CLOSED
		, DATEDIFF(MINUTE,KI.DT_CONFIRMED, KI.DT_ISSUE_CLOSED) AS MIN_ISSUE_DURING
		, CEILING( CAST(DATEDIFF(MINUTE,KI.DT_CONFIRMED, KI.DT_ISSUE_CLOSED) AS DECIMAL(12,2)) / 30.00 ) AS NO_SPACES_OCUPED
	FROM PRD.K_WORK_ORDER KWO
		INNER JOIN PRD.K_QA27 KQ
			ON KWO.ID_WORK_ORDER = KQ.ID_WORK_ORDER
			AND KQ.ID_QA27 = @PIN_ID_QA27
		INNER JOIN PRD.K_ISSUE KI
			ON KI.ID_WORK_ORDER = KQ.ID_WORK_ORDER
				AND KI.FG_LINE_DOWN = 1
				AND (KI.DT_ISSUE BETWEEN KQ.DT_INITIAL_TIME AND ISNULL(KQ.DT_FINAL_TIME, @DT_SYSTEM)
					OR ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM) BETWEEN KQ.DT_INITIAL_TIME AND ISNULL(KQ.DT_FINAL_TIME, @DT_SYSTEM)
					OR KQ.DT_INITIAL_TIME BETWEEN KI.DT_ISSUE AND ISNULL(KI.DT_ISSUE_CLOSED, @DT_SYSTEM)
				)
