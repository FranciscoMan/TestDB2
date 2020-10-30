﻿
-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 18/08/2017
-- Description: get authorizer for a production line
-- =============================================


CREATE PROCEDURE    [PRD].[SPE_GET_PRODUCTION_LINE_AUTHORIZERS] 
        @PIN_ID_BRANCH_PLANT AS INT = NULL

AS   

	DECLARE @XML_CONFIGURATION XML = (SELECT TOP 1 XML_CONFIGURATION FROM ADM.S_CONFIGURATION)
		--, @ID_BRANCH_PLANT INT = (SELECT TOP 1 ID_BRANCH_PLANT FROM PRD.C_PRODUCTION_LINE WHERE ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE)
		, @ID_BRANCH_PLANT INT = @PIN_ID_BRANCH_PLANT


	DECLARE @T_POSITIONS TABLE (
		ID_POSITION INT
	)

	INSERT INTO @T_POSITIONS (ID_POSITION)
	SELECT T.C.value('@ID_POSITION', 'INT')
	FROM @XML_CONFIGURATION.nodes('/CONFIGURATIONS/ESPECIFIC_CONFIGURATION/BRANCH_PLANT[@ID_BRANCH_PLANT = sql:variable("@ID_BRANCH_PLANT")]/PRODUCTION_LINE_AUTHORIZERS/POSITION') T(C)

	SELECT CU.KY_USER, CE.NM_FIRST_NAME, CE.NM_LAST_NAME, CE.NM_FIRST_NAME + ' ' + CE.NM_LAST_NAME AS NM_COMPLETE_NAME, CP.NM_POSITION
	FROM ADM.C_POSITION CP
		INNER JOIN ADM.C_EMPLOYEE CE
			ON CP.ID_POSITION = CE.ID_POSITION
		INNER JOIN ADM.C_USER CU
			ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE
	WHERE EXISTS (SELECT TOP 1 1 FROM @T_POSITIONS TP WHERE CP.ID_POSITION = TP.ID_POSITION)
