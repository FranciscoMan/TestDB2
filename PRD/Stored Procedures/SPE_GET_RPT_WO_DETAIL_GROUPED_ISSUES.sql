﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 29/05/2017
-- Description: Report Work Order Detail 
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_RPT_WO_DETAIL_GROUPED_ISSUES]
	@ACCION NVARCHAR(50)
   ,@NO_WORK_ORDER INT 		
   , @DT_WORK_ORDER DATE
   , @KY_SHIFT NVARCHAR(20)
AS   
BEGIN

		; WITH T_ISSUES_TIME AS (
			SELECT KQ.ID_QA27
				, CAST(KQ.DT_INITIAL_TIME AS DATE) DT_QA27
				, VCS.NM_SHIFT
				, CASE WHEN CT.KY_CODE_TYPE = 'DEV' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_DEV
				, CASE WHEN CT.KY_CODE_TYPE = 'DCHG' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_DCHG
				, CASE WHEN CT.KY_CODE_TYPE = 'OTHER' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_OTHER
				, CASE WHEN CT.KY_CODE_TYPE = 'RCHG' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_RCHG
				, CASE WHEN CT.KY_CODE_TYPE = 'SMNT' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_SMNT
				, CASE WHEN CT.KY_CODE_TYPE = 'UMNT' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_UMNT
				, CASE WHEN CT.KY_CODE_TYPE = 'IDLE' THEN ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) ELSE 0 END NO_MINUTES_IDLE
				, ISNULL(DATEDIFF(MINUTE, KI.DT_ISSUE, ISNULL(KI.DT_ISSUE_CLOSED, GETDATE())), 0) AS NO_MINUTES_ISSUE
				, DATEDIFF(MINUTE, KQ.DT_INITIAL_TIME, ISNULL(KQ.DT_FINAL_TIME, GETDATE())) NO_MINUTES_PROD
			FROM PRD.K_ISSUE KI
				INNER JOIN PRD.C_PROBLEM_CODE PC 
					ON PC.ID_PROBLEM_CODE = KI.ID_PROBLEM_CODE
					AND KI.ID_WORK_ORDER = @NO_WORK_ORDER
				INNER JOIN PRD.K_QA27 KQ
					ON KI.ID_QA27 = KQ.ID_QA27
					AND KQ.ID_WORK_ORDER = @NO_WORK_ORDER
				INNER JOIN ADM.VW_C_SHIFT VCS
					ON KQ.KY_SHIFT = VCS.KY_SHIFT
				INNER JOIN ADM.VW_C_CODE_TYPE CT 
					ON CT.KY_CODE_TYPE = PC.KY_CODE_TYPE
			WHERE (@DT_WORK_ORDER IS NULL OR (@DT_WORK_ORDER BETWEEN CAST(KI.DT_ISSUE AS DATE) AND CAST(ISNULL(KI.DT_ISSUE_CLOSED, GETDATE()) AS DATE)))
		), T_QA27 AS (
			SELECT ID_QA27
				, DT_QA27
				, ISNULL(REPLACE(KS.KY_SHIFT_TIME, 'SF-', ''), VCS.NM_SHIFT) AS NM_SHIFT
				, DATEDIFF(MINUTE, KQ.DT_INITIAL_TIME, ISNULL(KQ.DT_FINAL_TIME, GETDATE())) NO_MINUTES_PROD
			FROM PRD.K_QA27 KQ
				INNER JOIN ADM.VW_C_SHIFT VCS
					ON KQ.KY_SHIFT = VCS.KY_SHIFT
					AND KQ.ID_WORK_ORDER = @NO_WORK_ORDER
				INNER JOIN PRD.K_WORK_ORDER KWO
					ON KWO.ID_WORK_ORDER = KQ.ID_WORK_ORDER
				INNER JOIN PRD.K_SHIFT KS
					ON KS.ID_PRODUCTION_LINE = KWO.ID_PRODUCTION_LINE
					AND KQ.DT_INITIAL_TIME BETWEEN KS.DT_START_SHIFT AND ISNULL(KS.DT_END_SHIFT, GETDATE())
			WHERE (@DT_WORK_ORDER IS NULL OR (@DT_WORK_ORDER = CAST(KQ.DT_INITIAL_TIME AS DATE)))
		)
		SELECT TQ.ID_QA27
			, TQ.DT_QA27
			, TQ.NM_SHIFT
			, ISNULL(SUM(ISNULL(TIC.NO_MINUTES_PROD, TQ.NO_MINUTES_PROD)) - ISNULL(SUM(TIC.NO_MINUTES_ISSUE), 0), 0) / 60.0 AS NO_SUM_MINUTES_PROD
			, ISNULL(SUM(TIC.NO_MINUTES_DEV), 0) / 60.0 AS NO_SUM_MINUTES_DEV
			, ISNULL(SUM(TIC.NO_MINUTES_DCHG), 0) / 60.0 AS NO_SUM_MINUTES_DCHG
			, ISNULL(SUM(TIC.NO_MINUTES_OTHER), 0) / 60.0 AS NO_SUM_MINUTES_OTHER
			, ISNULL(SUM(TIC.NO_MINUTES_RCHG), 0) / 60.0 AS NO_SUM_MINUTES_RCHG
			, ISNULL(SUM(TIC.NO_MINUTES_SMNT), 0) / 60.0 AS NO_SUM_MINUTES_SMNT
			, ISNULL(SUM(TIC.NO_MINUTES_UMNT), 0) / 60.0 AS NO_SUM_MINUTES_UMNT
			, ISNULL(SUM(TIC.NO_MINUTES_IDLE), 0) / 60.0 AS NO_SUM_MINUTES_IDLE
			, ISNULL(SUM(TIC.NO_MINUTES_ISSUE), 0) / 60.0 AS NO_SUM_MINUTES_ISSUE
			, ISNULL(MIN(TQ.NO_MINUTES_PROD), 0) / 60.0 AS NO_SUM_TOTAL
		FROM T_QA27 TQ
			LEFT JOIN  T_ISSUES_TIME TIC
				ON TQ.ID_QA27 = TIC.ID_QA27
		GROUP BY TQ.ID_QA27, TQ.DT_QA27, TQ.NM_SHIFT
		ORDER BY TQ.DT_QA27, TQ.NM_SHIFT
	END

