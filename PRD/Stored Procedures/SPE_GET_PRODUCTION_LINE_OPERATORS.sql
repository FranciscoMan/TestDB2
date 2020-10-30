
-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 14/08/2017
-- Description: Get all production line authorized operators.
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_PRODUCTION_LINE_OPERATORS] 
	    @PIN_ID_PRODUCTION_LINE AS int = NULL

AS   

	SELECT CPLO.ID_PRODUCTION_LINE_OPERATOR
		, CPLO.ID_EMPLOYEE
		, CPLO.ID_PRODUCTION_LINE
		, CE.KY_EMPLOYEE
		, CE.NM_FIRST_NAME
		, CE.NM_LAST_NAME
	FROM PRD.C_PRODUCTION_LINE_OPERATOR CPLO
		INNER JOIN ADM.C_EMPLOYEE CE
			ON CPLO.ID_EMPLOYEE = CE.ID_EMPLOYEE
	WHERE CPLO.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE

