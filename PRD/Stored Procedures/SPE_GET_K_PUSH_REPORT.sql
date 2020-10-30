-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Davalos Romero
-- CRETAE date: 12/12/2019
-- Description: Search a specific push report, by his date and his shift
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_K_PUSH_REPORT]
      @PIN_DT_DATE_REPORT DATETIME,
      @PIN_KY_SHIFT VARCHAR(50)

  AS
	BEGIN
		SELECT 
      pr.ID_PUSH_REPORT,
      pr.DT_DATE_REPORT,
      pr.KY_SHIFT
    FROM PRD.K_PUSH_REPORT pr
    WHERE pr.DT_DATE_REPORT = @PIN_DT_DATE_REPORT AND pr.KY_SHIFT = @PIN_KY_SHIFT
  END -- END PROCEDURE

