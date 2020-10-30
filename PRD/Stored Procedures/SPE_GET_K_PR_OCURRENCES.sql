-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Davalos Romero
-- CRETAE date: 16/12/2019
-- Description: Look for ocurrences from a push report, by ID_PUSH_REPORT
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_K_PR_OCURRENCES]
      @PIN_ID_PUSH_REPORT INT
  AS
  BEGIN
    SELECT pr.ID_PUSH_REPORT, pr_oc.NM_NAME, pr_oc.NM_REASON
    FROM PRD.K_PUSH_REPORT pr
    INNER JOIN PRD.K_PR_OCURRENCE pr_oc ON pr.ID_PUSH_REPORT = pr_oc.ID_PUSH_REPORT
    WHERE pr.ID_PUSH_REPORT = @PIN_ID_PUSH_REPORT
  END -- END PROCEDURE
