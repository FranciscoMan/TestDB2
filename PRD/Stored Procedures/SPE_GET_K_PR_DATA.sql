-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Davalos Romero
-- CRETAE date: 16/12/2019
-- Description: get Data from a push report, by ID_PUSH_REPORT
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_K_PR_DATA]
      @PIN_ID_PUSH_REPORT INT
  AS
  BEGIN
    SELECT pr.ID_PUSH_REPORT, pr_pl.ID_PR_PRODUCTION_LINE, pr_pl.ID_PRODUCTION_LINE,
    	pr_item.ID_PR_ITEM, pr_item.ID_ITEM,
    	pr_mat.ID_PR_MATERIAL, pr_mat.ID_MATERIAL, pr_mat.NO_PERCENTAGE
    FROM PRD.K_PUSH_REPORT pr
    INNER JOIN PRD.K_PR_PRODUCTION_LINE pr_pl ON pr.ID_PUSH_REPORT = pr_pl.ID_PUSH_REPORT
    INNER JOIN PRD.K_PR_ITEM pr_item ON pr_pl.ID_PR_PRODUCTION_LINE = pr_item.ID_PR_PRODUCTION_LINE
    INNER JOIN PRD.K_PR_MATERIAL pr_mat ON pr_item.ID_PR_ITEM = pr_mat.ID_PR_ITEM
    WHERE pr.ID_PUSH_REPORT = @PIN_ID_PUSH_REPORT
  END -- END PROCEDURE
