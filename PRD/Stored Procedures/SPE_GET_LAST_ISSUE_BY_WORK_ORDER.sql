﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Daniel Davalos Romero
-- CREATE date: 24/08/2020
-- Description: get last issue in a work order and 
-- his respective info
-- =============================================

CREATE PROCEDURE  [PRD].[SPE_GET_LAST_ISSUE_BY_WORK_ORDER]
	@PIN_BP INT = NULL,
	@PIN_IP VARCHAR(40) = NULL

AS   
  -- Email Vars:
  --"MESSAGE"
  --"ID_BRANCH_PLANT"

-- FOR LAST UNRPODUCTIVE EVENT (ANY TYPE OF UNPRODUCTIVE EVENT LIKE 'UMNT', 'RCHG', ETC)

SELECT
    bp.ID_BRANCH_PLANT, 
    bp.KY_BRANCH_PLANT, 
    pl.ID_PRODUCTION_LINE, 
    pl.KY_PRODUCTION_LINE, 
    pl.NM_PRODUCTION_LINE, 
	wo.ID_WORK_ORDER,
	wo.DT_CREATION,
    iss.ID_ISSUE, 
    iss.KY_STATUS, 
	cpc.KY_CODE_TYPE,
   CONCAT('[',iss.DS_ISSUE_EXPLANATION_OPEN ,'] ', iss.DS_SYMPTOM) AS DS_ISSUE_EXPLANATION_OPEN, 
	iss.DT_ISSUE,
    0 AS FG_EMAIL_SENDED,
	iss.ID_PROBLEM_CODE,
    us.NM_USER
FROM 
PRD.C_PRODUCTION_LINE_IP plip
INNER JOIN PRD.C_PRODUCTION_LINE pl ON plip.ID_PRODUCTION_LINE = pl.ID_PRODUCTION_LINE AND PL.FG_ACTIVE = 1
INNER JOIN ADM.C_BRANCH_PLANT bp ON bp.ID_BRANCH_PLANT = pl.ID_BRANCH_PLANT
INNER JOIN PRD.K_WORK_ORDER wo ON PL.ID_PRODUCTION_LINE = wo.ID_PRODUCTION_LINE AND wo.KY_STATUS = 'RUNNING'
INNER JOIN PRD.K_ISSUE iss ON iss.ID_PRODUCTION_LINE = pl.ID_PRODUCTION_LINE
INNER JOIN ADM.C_USER us ON us.KY_USER = iss.KY_USER_INVOLVED
INNER JOIN PRD.C_PROBLEM_CODE cpc ON cpc.ID_PROBLEM_CODE = iss.ID_PROBLEM_CODE
WHERE plip.NO_IP= @PIN_IP AND pl.ID_BRANCH_PLANT = 	@PIN_BP AND iss.KY_STATUS = 'HOLD_ON' 
ORDER BY iss.DT_ISSUE DESC

