-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Davalos Romero
-- CRETAE date: 16/12/2019
-- Description: Look for overtimes from a push report, by ID_PUSH_REPORT
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_K_PR_OVERTIMES]
      @PIN_ID_PUSH_REPORT INT
  AS
  BEGIN
    SELECT pr.ID_PUSH_REPORT, pr_ov.NM_NAME, pr_ov.NM_REASON, pr_ov.NM_SCHEDULE
    FROM PRD.K_PUSH_REPORT pr
    INNER JOIN PRD.K_PR_OVERTIME pr_ov ON pr.ID_PUSH_REPORT = pr_ov.ID_PUSH_REPORT
    WHERE pr.ID_PUSH_REPORT = @PIN_ID_PUSH_REPORT
  END -- END PROCEDURE
