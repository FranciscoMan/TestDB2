-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Davalos Romero
-- CRETAE date: 15/01/2020
-- Description: Stored procedure that gets the newest issue from a production line, 
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_PRODUCTION_LINE_ISSUE_STATUS]
      @PIN_ID_PRODUCTION_LINE VARCHAR(50)

  AS
	BEGIN
    -- Obtenemos el evento improductivo más reciente de una línea de producción
    SELECT TOP 1 issue.ID_ISSUE, issue.ID_QA27, issue.FG_EMAIL_SENDED, issue.KY_STATUS,
      issue.DT_ISSUE, issue.DS_SYMPTOM, '' AS DS_DEFECT_CATEGORY, issue.DS_ISSUE_EXPLANATION_OPEN
    FROM PRD.K_ISSUE issue 
	   WHERE issue.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE
    ORDER BY issue.ID_ISSUE DESC
  END -- END PROCEDURE



  /*
SELECT TOP 1 issue.ID_ISSUE, issue.ID_QA27, issue.KY_STATUS, issue.DT_ISSUE, issue.DS_SYMPTOM, defect.DS_DEFECT_CATEGORY
    FROM PRD.K_ISSUE issue 
	INNER JOIN PRD.C_DEFECT_CATEGORY defect ON issue.ID_DEFECT_CATEGORY = defect.ID_DEFECT_CATEGORY
	  WHERE issue.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE
    ORDER BY issue.DT_ISSUE DESC

  */
