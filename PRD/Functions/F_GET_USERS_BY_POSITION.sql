﻿
-- =============================================
-- Author:		Juan De Dios Pérez
-- Create date: 11/05/2017
-- Description:	Function to return the users by position
-- =============================================
CREATE FUNCTION [PRD].[F_GET_USERS_BY_POSITION]
(
	 @PIN_ID_FIRST_LEVEL_POSITION INT, @PIN_ID_SECOND_LEVEL_POSITION_REJECTION INT,@PIN_ID_THIRD_LEVEL_POSITION_REJECTION INT
)
RETURNS XML
AS
BEGIN

	DECLARE @XML_USERS XML,
	 @XML_RESULT XML


	SET @XML_USERS = (
	SELECT 
	CU.[KY_USER] AS "@KY_USER" ,
	CU.[NM_USER] AS "@NM_USER" ,
	CP.ID_POSITION AS "@ID_POSITION" ,
	CP.KY_POSITION AS "@KY_POSITION" ,
	CP.NM_POSITION AS "@NM_POSITION" 
	FROM ADM.C_USER CU
	LEFT OUTER JOIN ADM.C_ROLE CR ON CR.ID_ROLE = CU.ID_ROLE
	LEFT OUTER JOIN ADM.C_EMPLOYEE CE ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE
	LEFT OUTER JOIN ADM.C_POSITION CP ON CP.ID_POSITION = CE.ID_POSITION
	LEFT OUTER JOIN ADM.C_BRANCH_PLANT BP ON BP.ID_BRANCH_PLANT = CU.ID_BRANCH_PLANT
	WHERE CP.ID_POSITION IN 
	(
	@PIN_ID_FIRST_LEVEL_POSITION,
	@PIN_ID_SECOND_LEVEL_POSITION_REJECTION,
	@PIN_ID_THIRD_LEVEL_POSITION_REJECTION)
		FOR XML PATH ('USER'), ROOT ('USERS')
	)


	SET @XML_RESULT = (
		SELECT 
			 @XML_USERS
		FOR XML PATH ('CATALOGS')
	)

	RETURN @XML_RESULT

END