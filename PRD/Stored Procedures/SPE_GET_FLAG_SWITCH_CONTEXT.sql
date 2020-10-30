-- ================================================================
-- Proyecto: Plaskolite v2
-- Copyright (c) - Vitek - 2020
-- Author: Cynthia Aideé Alvarez.
-- CREATE date: 03/02/2020
-- Description: GET FLAG SWITCH CONTEXT.
-- =================================================================
-- 06/17/2020 : Added ID_BRANCH_PLANT in our search.

CREATE PROCEDURE [PRD].[SPE_GET_FLAG_SWITCH_CONTEXT]
	@PIN_NM_SWITCH AS NVARCHAR(80) = NULL,
	@PIN_ID_BRANCH_PLANT AS INT = NULL
AS
BEGIN
	SELECT FG_SWITCH, ID_BRANCH_PLANT, NM_BRANCH_PLANT FROM PRD.C_SWITCH_CONTEXT WHERE NM_SWITCH = @PIN_NM_SWITCH 
	AND ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT
END

