﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 21/03/2017
-- Description: It gets all roles with its functions
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_ROLE]
	@PIN_ID_ROLE AS INT = NULL
AS   
BEGIN
	DECLARE @ID_ROLE INT
		, @KY_ROLE NVARCHAR(30)
		, @NM_ROLE NVARCHAR(100)
		, @FG_ACTIVE BIT
		, @XML_AUTORIZATION XML

	SELECT @ID_ROLE = CR.ID_ROLE
		, @KY_ROLE = CR.KY_ROLE
		, @NM_ROLE = CR.NM_ROLE
		, @FG_ACTIVE = CR.FG_ACTIVE
	FROM ADM.C_ROLE CR
	WHERE CR.ID_ROLE = @PIN_ID_ROLE

	SET @XML_AUTORIZATION = (
		SELECT SF.ID_FUNCTION AS "@ID_FUNCTION"
			, SF.KY_FUNCTION AS "@KY_FUNCTION"
			, SF.KY_TYPE_FUNCTION AS "@KY_TYPE_FUNCTION"
			, SF.ID_PARENT_FUNCTION AS "@ID_PARENT_FUNCTION"
			, SF.NM_FUNCTION AS "@NM_FUNCTION"
			, CASE WHEN CRF.ID_FUNCTION IS NOT NULL THEN 1 ELSE 0 END AS "@FG_SELECTED"
		FROM ADM.S_FUNCTION SF
			LEFT JOIN ADM.C_ROLE_FUNCTION CRF
				ON SF.ID_FUNCTION = CRF.ID_FUNCTION
				AND CRF.ID_ROLE = @PIN_ID_ROLE
		FOR XML PATH ('FUNCTION'), ROOT ('FUNCTIONS')
	)

	SELECT ISNULL(@ID_ROLE, -1) AS ID_ROLE
		, @KY_ROLE AS KY_ROLE
		, @NM_ROLE AS NM_ROLE
		, ISNULL(@FG_ACTIVE, 0) AS FG_ACTIVE
		, @XML_AUTORIZATION AS XML_AUTORIZATION
END

