-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 22/05/2018
-- Description: get all users by positions
-- Modifications:
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_GET_USER_BY_POSITIONS] 
	@PIN_XML_POSITIONS XML
AS   

BEGIN

	DECLARE @T_POSITION TABLE (
		ID_POSITION INT
	)


	INSERT INTO @T_POSITION (ID_POSITION)
	SELECT C.value('@ID_POSITION', 'INT')
	FROM @PIN_XML_POSITIONS.nodes('POSITIONS/POSITION') T(C)


	SELECT 
		  KY_USER
		, NM_USER
		, CP.NM_POSITION
		, CU.KY_EMAIL
	FROM ADM.C_USER CU
		INNER JOIN ADM.C_EMPLOYEE CE
			ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE
		INNER JOIN @T_POSITION TP
			ON CE.ID_POSITION = TP.ID_POSITION
		INNER JOIN ADM.C_POSITION CP
			ON TP.ID_POSITION = CP.ID_POSITION

END

