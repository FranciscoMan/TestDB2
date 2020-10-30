---- =============================================
---- Proyecto: Plaskolite
---- Copyright (c) - Acrux - 2017
---- Author: Javier Diaz Barron
---- CREATE date: 05/06/2017
---- Description: get user and employee by position
---- =============================================
--
CREATE PROCEDURE    [PRD].[SPE_GET_EMPLOYEE_BY_POSITION] 
	    @PIN_XML_POSITIONS XML = NULL
AS   


	SELECT
		CE.NM_FIRST_NAME ,
		CE.NM_LAST_NAME ,
		(CE.NM_FIRST_NAME + ' ' + CE.NM_LAST_NAME ) NM_COMPLETE_NAME,
		CU.KY_USER,
		CE.ID_EMPLOYEE,
		CP.ID_POSITION,
		(CASE WHEN d.value('@KY_TYPE_POSITION', 'VARCHAR(10)') = 'F' THEN 'FIRST' ELSE 'BACKUP' END) AS KY_TYPE_POSITION,
		ISNULL(CU.KY_EMAIL, 'USER@EXAMPLE.COM') AS KY_EMAIL
	FROM ADM.C_EMPLOYEE CE
		INNER JOIN ADM.C_USER CU 
			ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE
			AND CU.FG_ACTIVE = 1
			AND CE.FG_ACTIVE = 1
		INNER JOIN ADM.C_POSITION CP 
			ON CP.ID_POSITION = CE.ID_POSITION
		INNER JOIN @PIN_XML_POSITIONS.nodes('POSITIONS/POSITION') AS T(d) 
			ON d.value('@ID_POSITION', 'INT') = CP.ID_POSITION


