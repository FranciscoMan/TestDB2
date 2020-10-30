-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 02/02/2018
-- Description: Get roles by document management
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_ROLES_DOCUMENT_MANAGEMENT]
	@PIN_ID_STREAM UNIQUEIDENTIFIER

AS
	SELECT CDR.ID_DOCUMENT_ROLE, CR.ID_ROLE, CR.KY_ROLE, CR.NM_ROLE
	FROM ADM.C_ROLE CR
		INNER JOIN ADM.C_DOCUMENT_ROLE CDR 
			ON CDR.ID_ROLE = CR.ID_ROLE 
			AND CDR.ID_STREAM = @PIN_ID_STREAM
			AND CR.FG_ACTIVE = 1

