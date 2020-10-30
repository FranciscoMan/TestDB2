﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan Pérez
-- CREATE date: 23/02/2017
-- Description: Get the authentication from user
-- ============================================
-- 2017 03 31 JDR The property ID_BRANCH_PLANT is changed to return null if the user is not associated with any branch plant
-- 2017-06-12 JDB it added the name of position and key
-- 08/02/2018 JDR ID_ROLE column added
-- =============================================
CREATE PROCEDURE  [ADM].[SPE_GET_USER_AUTHENTICATION]
	@PIN_KY_USER AS NVARCHAR(50) = NULL
	,@PIN_KY_PASSWORD AS NVARCHAR(50) = NULL
	,@PIN_KY_AUTHENTICATION AS NVARCHAR(50) = NULL
AS   
BEGIN
	DECLARE @KY_AUTHENTICATION NVARCHAR(50) = @PIN_KY_AUTHENTICATION
		, @XML_AUTHORIZATION XML
	--DECLARE @PIN_ID_EMPRESA INT  = NULL
	--	SET @PIN_ID_EMPRESA = (SELECT [ADM].[F_OBTIENE_ID_EMPRESA](@PIN_KY_USER))

	;WITH T_USUARIO AS (
		SELECT TOP 1 
			  CU.KY_USER
			, CU.NM_USER
			, CU.NM_PASSWORD
			, CU.KY_EMAIL
			, CU.FG_ACTIVE
			, CR.ID_ROLE
			, CR.NM_ROLE
			, ISNULL(CU.ID_EMPLOYEE,0) AS ID_EMPLOYEE
			, ISNULL(CP.ID_POSITION,0) AS ID_POSITION
			, CU.ID_BRANCH_PLANT
			, BP.KY_BRANCH_PLANT
			, ISNULL(BP.NM_BRANCH_PLANT,'PLASKOLITE') AS NM_BRANCH_PLANT
			, FS.file_stream
			, CP.KY_POSITION
			, CP.NM_POSITION
		FROM ADM.C_USER CU
			LEFT JOIN ADM.C_ROLE CR
				ON CU.ID_ROLE = CR.ID_ROLE
			LEFT OUTER JOIN ADM.C_EMPLOYEE CE ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE
			LEFT OUTER JOIN ADM.C_POSITION CP ON CP.ID_POSITION = CE.ID_POSITION
			LEFT OUTER JOIN ADM.C_BRANCH_PLANT BP ON BP.ID_BRANCH_PLANT = CU.ID_BRANCH_PLANT
			LEFT OUTER JOIN FS_FILE_SYSTEM FS ON FS.stream_id = BP.ID_FILE
		WHERE CU.KY_USER = @PIN_KY_USER
		AND CR.FG_ACTIVE = 1
	)

	

	SELECT @KY_AUTHENTICATION AS KY_AUTHENTICATION
		, @XML_AUTHORIZATION AS XML_AUTHORIZATION
		, TU.KY_USER
		, TU.NM_USER
		, TU.NM_PASSWORD
		, TU.KY_EMAIL
		, TU.FG_ACTIVE
		, TU.ID_ROLE
		, TU.NM_ROLE
		, TU.ID_EMPLOYEE
		, TU.ID_POSITION as ID_POSITION--, TU.ID_PUESTO 
		, TU.NM_POSITION
		, TU.ID_BRANCH_PLANT as ID_BRANCH_PLANT 
		, 'BP'+ ISNULL(TU.KY_BRANCH_PLANT,'-ALL') as KY_BRANCH_PLANT
		, TU.NM_BRANCH_PLANT
		, TU.file_stream AS LOGOTYPE
		, TU.KY_POSITION AS KY_POSITION
		, TU.NM_POSITION AS NM_POSITION
		, CONVERT(XML, ( 
			SELECT  SF.KY_FUNCTION AS '@KY_FUNCTION'
				, SF.KY_TYPE_FUNCTION AS '@KY_TYPE_FUNCTION'
				, SF.ID_FUNCTION AS '@ID_FUNCTION'
				, SF.ID_PARENT_FUNCTION AS '@ID_PARENT_FUNCTION'
				, SF.NM_FUNCTION AS '@NM_FUNCTION'
				, SF.NM_URL AS '@NM_URL'
				, SF.NO_ORDER AS '@NO_ORDER'
				, SF.XML_CONFIGURATION
			FROM ADM.S_FUNCTION SF
				INNER JOIN ADM.C_ROLE_FUNCTION CRF
					ON SF.ID_FUNCTION = CRF.ID_FUNCTION
				INNER JOIN T_USUARIO TU
					ON TU.ID_ROLE = CRF.ID_ROLE
				ORDER BY SF.NO_ORDER
			FOR XML PATH ('FUNCTION'), ROOT('FUNCTIONS')
		)) AS XML_DATA
	FROM T_USUARIO TU
END
