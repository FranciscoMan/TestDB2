﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE   [PRD].[SPE_GET_LAST_QA27_BY_LINE]
	@DT DATETIME ,
	@ID_PROD_LINE INT

AS
BEGIN

DECLARE
 @DT_TWO_HOURS DATETIME,
 @DT_FINAL DATETIME = NULL,
 @ID_QA INT = NULL
	
SET @DT_TWO_HOURS = DATEADD(HOUR,-2,@DT)

SELECT @ID_QA = QA.ID_QA27, @DT_FINAL = QA.DT_FINAL_TIME
FROM PRD.K_WORK_ORDER WO 
INNER JOIN PRD.K_QA27 QA ON QA.ID_WORK_ORDER = WO.ID_WORK_ORDER WHERE WO.ID_PRODUCTION_LINE =   @ID_PROD_LINE
	 AND QA.DT_FINAL_TIME IS NOT NULL
	 AND (@DT_TWO_HOURS  BETWEEN QA.DT_INITIAL_TIME AND QA.DT_FINAL_TIME)

SELECT @ID_QA ID_QA27, @DT_FINAL DT_FINAL_TIME

END