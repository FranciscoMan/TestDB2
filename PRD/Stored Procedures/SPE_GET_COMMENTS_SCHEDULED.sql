﻿
CREATE PROCEDURE    [PRD].[SPE_GET_COMMENTS_SCHEDULED]
@PIN_ID_WORK_ORDER INT
AS
BEGIN
SELECT WOC.DS_COMMENT, U.NM_USER AS KY_USER_APP_CREATION, DT_COMMENT  FROM PRD.K_WORK_ORDER_COMMENT WOC 
INNER JOIN ADM.C_USER U ON U.KY_USER=  WOC.KY_USER_APP_CREATION
WHERE KY_TYPE_COMMENT = 'SCHEDULER' AND ID_WORK_ORDER = @PIN_ID_WORK_ORDER
END
