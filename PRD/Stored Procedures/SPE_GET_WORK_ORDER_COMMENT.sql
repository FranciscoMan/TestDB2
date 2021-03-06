﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 05/06/2018
-- Description: get all work orders comments
-- =============================================
-- 12/27/2018 JDR FG_ACTIVE and KY_ACTIVE columns added
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_COMMENT] 
	    @PIN_ID_WORK_ORDER_COMMENT AS int = NULL,
	    @PIN_ID_WORK_ORDER AS int = NULL,
		@PIN_ID_BRANCH_PLANT AS INT = NULL
AS   
	SELECT 
		WOC.ID_WORK_ORDER_COMMENT
      , WO.ID_WORK_ORDER
	  , WO.NO_WORK_ORDER
	  , WOC.DS_COMMENT
      , WOC.DT_COMMENT
	  , WO.NM_PRODUCTION_LINE
	  , WO.KY_STATUS AS KY_STATUS_WORK_ORDER
	  , CU.NM_USER
	  , CU.KY_USER
	  , CE.ID_POSITION
	  , WOC.FG_ACTIVE
	  , CASE WHEN WOC.FG_ACTIVE = 1 THEN 'Yes' ELSE 'No' END AS KY_ACTIVE
	FROM PRD.K_WORK_ORDER WO
		INNER JOIN PRD.K_WORK_ORDER_COMMENT WOC 
			ON WO.ID_WORK_ORDER = WOC.ID_WORK_ORDER
		INNER JOIN ADM.C_USER CU 
			ON WOC.KY_USER_APP_CREATION = CU.KY_USER
		LEFT JOIN ADM.C_EMPLOYEE CE
			ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE
			AND CE.FG_ACTIVE = 1
	WHERE (@PIN_ID_WORK_ORDER_COMMENT IS NULL OR (@PIN_ID_WORK_ORDER_COMMENT IS NOT NULL AND WOC.ID_WORK_ORDER_COMMENT = @PIN_ID_WORK_ORDER_COMMENT)) 
		AND (@PIN_ID_WORK_ORDER IS NULL OR (@PIN_ID_WORK_ORDER IS NOT NULL AND WO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER)) 
		AND (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND WO.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
	ORDER BY WOC.DT_COMMENT DESC

