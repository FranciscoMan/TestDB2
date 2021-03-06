﻿-- =============================================
-- Author:		DELL
-- Create date:09/03/2020
-- Description:	GET DATA SOC
-- =============================================
CREATE PROCEDURE  PRD.SPE_GET_DATA_SOC_AUTOMATIC
	-- Add the parameters for the stored procedure here
	@ID_BRANCH_PLANT INT,
	@IP VARCHAR(15)
AS
BEGIN
	
SELECT W.ID_WORK_ORDER, PL.ID_PRODUCTION_LINE, Q.ID_QA27  FROM PRD.C_PRODUCTION_LINE_IP PLIP
INNER JOIN PRD.C_PRODUCTION_LINE PL ON PLIP.ID_PRODUCTION_LINE = PL.ID_PRODUCTION_LINE AND PL.FG_ACTIVE = 1
INNER JOIN PRD.K_WORK_ORDER W ON PL.ID_PRODUCTION_LINE = W.ID_PRODUCTION_LINE AND W.KY_STATUS = 'RUNNING'
INNER JOIN PRD.K_QA27  Q ON W.ID_WORK_ORDER = Q.ID_WORK_ORDER AND Q.KY_STATUS= 'RUNNING'
WHERE PLIP.NO_IP= @IP AND PL.ID_BRANCH_PLANT = @ID_BRANCH_PLANT AND NOT EXISTS
(SELECT ID_ISSUE FROM PRD.K_ISSUE  I WHERE I.ID_PRODUCTION_LINE = PL.ID_PRODUCTION_LINE AND  I.KY_STATUS = 'HOLD_ON') AND
NOT EXISTS
(SELECT ID_K_FORM FROM PRD.K_FORM  F WHERE F.ID_QA27= Q.ID_QA27 AND  ID_FORM = 3 AND F.KY_STATUS_FORM ='CAPTURED' )

END
