﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - VITEk - 2019
-- Author: DELLC
-- CREATE date: 07/19/2019
-- Description: REPORT SKIPPED WORK ORDER 
-- =============================================[ADM].[SPE_GET_USER_CATALOGUES]
CREATE PROCEDURE    [PRD].[SPE_GET_RPT_SKIPPED_WORK_ORDER_CALIZ]
	@PIN_ID_BRANCH_PLANT AS int ,
	@PIN_DT_INITIAL AS DATE, 
	@PIN_DT_FINAL AS DATE 
AS
						BEGIN
						SELECT DISTINCT
						 W.ID_WORK_ORDER,
						 WOSL.DT_CREATION AS CREATION,
						 --Q.ID_QA27,
						 SUBSTRING(SH.KY_SHIFT_TIME , 4,1) AS [SHIFT],
						 W.ID_PRODUCTION_LINE PRODUCTION_LINE,
						 Q.NM_LEADMAN AS LEADMAN,
						 W.ID_ITEM AS ID_ITEM,
						 W.NM_ITEM AS ITEM_DESCRIPTION,
						 W.NO_RUN_QTY AS RUN_QTY,
						 W.NO_POUNDS * W.NO_QTY_SKID AS RUN_LBS,
						PA.DS_PROBLEM_AREA+' / '+PC.NM_PROBLEM_CODE AS CODE,
						WOSL.DS_EXPLANATION AS EXPLANATION,
						WOSL.KY_AUTHORIZER_USER AS USER_AUTHORIZER
						FROM PRD.K_SKIPPED_WORK_ORDER_LOG WOSL
						INNER JOIN PRD.K_QA27 Q ON WOSL.ID_QA27 = Q.ID_QA27
						INNER JOIN PRD.K_WORK_ORDER W ON Q.ID_WORK_ORDER = W.ID_WORK_ORDER
						INNER JOIN PRD.K_SHIFT SH ON Q.ID_SHIFT = SH.ID_SHIFT
						INNER JOIN PRD.K_ISSUE ISU ON W.ID_PRODUCTION_LINE = ISU.ID_PRODUCTION_LINE
						INNER JOIN PRD.C_PROBLEM_AREA PA ON ISU.ID_PROBLEM_AREA = PA.ID_PROBLEM_AREA
						INNER JOIN PRD.C_PROBLEM_CODE PC ON ISU.ID_PROBLEM_CODE = PC.ID_PROBLEM_CODE
						WHERE 
						(@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND W.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
						AND ( (@PIN_DT_INITIAL IS NULL AND @PIN_DT_FINAL IS NULL ) OR  CAST(WOSL.DT_CREATION AS DATE) BETWEEN @PIN_DT_INITIAL AND  @PIN_DT_FINAL)
						AND WOSL.DT_CREATION = ISU.DT_ISSUE
						ORDER BY WOSL.DT_CREATION
						END

