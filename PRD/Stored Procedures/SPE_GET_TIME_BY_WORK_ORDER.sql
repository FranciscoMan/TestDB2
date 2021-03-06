﻿

-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - VITEK - 2019
-- Author: DELLC
-- CREATE date: 07/15/2019
-- Description: Get unproductive events time
-- =============================================
-- =============================================
CREATE PROCEDURE [PRD].[SPE_GET_TIME_BY_WORK_ORDER]
	  @MIDDLE_DATE DATETIME,
	  @ID_BP INT = NULL

AS
BEGIN    
	DECLARE  
	 @INIT DATETIME,
	 @ENDT DATETIME,
	 @TIMENOW DATETIME

	 SET @INIT = DATEADD(HOUR, -6, @MIDDLE_DATE)
	 SET @ENDT = DATEADD(HOUR, 6, @MIDDLE_DATE)
	 SET  @TIMENOW = GETDATE()

SELECT  Q.ID_QA27, W.ID_WORK_ORDER, W.ID_PRODUCTION_LINE, Q.DT_INITIAL_TIME, ISNULL(Q.DT_FINAL_TIME,@TIMENOW) AS DT_FINAL_TIME, DATEDIFF(MINUTE,DT_INITIAL_TIME,ISNULL(DT_FINAL_TIME,@TIMENOW)) AS DIFF,
(SELECT 
TOP 1 XML_METRICS_VALUE.value('(/FIELD_TYPES/@FINISHED_VALUE)[1]', 'DECIMAL(13,2)') 
FROM PRD.K_FORM_METRICS KFM INNER JOIN PRD.K_FORM KF 
ON KF.ID_K_FORM = KFM.ID_K_FORM AND KFM.ID_METRICS = 66 
AND KF.KY_STATUS_FORM = 'CAPTURED' AND KF.KY_PROCESS_TYPE = 'PROCESS' 
AND KF.ID_PRODUCTION_LINE = W.ID_PRODUCTION_LINE 
INNER JOIN PRD.K_WORK_ORDER WO ON WO.ID_WORK_ORDER=KF.ID_WORK_ORDER 
WHERE  KF.DT_CREATION <= @ENDT ORDER BY KF.DT_CREATION DESC) AS LINE_RATE,
 W.NO_POUNDS AS [WEIGHT], 
 CEILING((W.NO_RUN_QTY + W.NO_QTY_ADDED) / W.NO_QTY_SKID) - ISNULL((SELECT TOP 1 NO_PALLET  FROM PRD.K_PALLET KP WHERE KP.ID_WORK_ORDER = W.ID_WORK_ORDER ORDER BY ID_PALLET DESC),0) AS SKIDS_TO_END,
  W.NO_QTY_SKID AS QTY_SKID
FROM PRD.K_QA27 Q INNER JOIN PRD.K_WORK_ORDER W ON 
Q.ID_WORK_ORDER = W.ID_WORK_ORDER AND ID_BRANCH_PLANT= @ID_BP WHERE 
(@MIDDLE_DATE BETWEEN Q.DT_INITIAL_TIME AND CASE WHEN Q.KY_STATUS='RUNNING' THEN ISNULL(Q.DT_FINAL_TIME,@TIMENOW )  ELSE Q.DT_FINAL_TIME END) OR
(@INIT BETWEEN Q.DT_INITIAL_TIME AND CASE WHEN Q.KY_STATUS='RUNNING' THEN ISNULL(Q.DT_FINAL_TIME,@TIMENOW )  ELSE Q.DT_FINAL_TIME END) OR
(@ENDT BETWEEN Q.DT_INITIAL_TIME AND CASE WHEN Q.KY_STATUS='RUNNING' THEN ISNULL(Q.DT_FINAL_TIME,@TIMENOW )  ELSE Q.DT_FINAL_TIME END) OR
Q.DT_INITIAL_TIME BETWEEN @INIT AND @ENDT OR
(Q.KY_STATUS = 'RUNNING' AND ISNULL(Q.DT_FINAL_TIME,@TIMENOW ) BETWEEN @INIT AND @ENDT ) ORDER BY Q.DT_INITIAL_TIME DESC



END




