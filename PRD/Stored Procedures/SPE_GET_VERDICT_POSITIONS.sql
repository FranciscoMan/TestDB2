﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CREATE date: 15/06/2017
-- Description: GET POSITION OF CONFIGURATION
-- =============================================
-- MODIFY: CHANGE TABLE PRD.K_PALLET TO  PRD.K_INSPECTION_SKIDS
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_VERDICT_POSITIONS] 
	@PIN_ID_PALLET INT
AS

	DECLARE @ID_BRANCH_PLANT NVARCHAR(5)
		
	SELECT @ID_BRANCH_PLANT = ISNULL(WO.ID_BRANCH_PLANT,'ALL')
	FROM PRD.K_INSPECTION_SKID KP
		INNER JOIN PRD.K_WORK_ORDER WO 
			ON WO.ID_WORK_ORDER = KP.ID_WORK_ORDER
	WHERE KP.ID_INSPECTION_SKID = @PIN_ID_PALLET

	DECLARE @XML_CONFIGURATION XML = (SELECT TOP 1 XML_CONFIGURATION FROM ADM.S_CONFIGURATION)
		, @ID_WORK_ORDER INT
		, @NO_PALLET INT


	DECLARE @T_POSITIONS TABLE (
		XML_POSITIONS XML
	)

	INSERT INTO @T_POSITIONS (
		XML_POSITIONS
	)
	SELECT c.query('.') 
	FROM @XML_CONFIGURATION.nodes('/CONFIGURATIONS/ESPECIFIC_CONFIGURATION/BRANCH_PLANT[@ID_BRANCH_PLANT=sql:variable("@ID_BRANCH_PLANT")]/QUALITY_PROCESS/POSITIONS_MBR/POSITION') T(C)

	SELECT @ID_WORK_ORDER = KIS.ID_WORK_ORDER
		, @NO_PALLET = KIS.NO_PALLET
	FROM PRD.K_INSPECTION_SKID KIS WHERE KIS.ID_INSPECTION_SKID = @PIN_ID_PALLET

	SELECT @PIN_ID_PALLET AS ID_PALLET
		, @ID_WORK_ORDER AS ID_WORK_ORDER
		, @ID_WORK_ORDER AS NO_WORK_ORDER
		, @NO_PALLET AS NO_PALLET
		, TP.XML_POSITIONS.value('(/POSITION/@ID_POSITION)[1]', 'INT') AS ID_POSITION
		, TP.XML_POSITIONS.value('(/POSITION/@ID_POSITION_BACKUP)[1]', 'INT') AS ID_POSITION_BACKUP
		, TP.XML_POSITIONS
		, ISNULL(NULLIF(CP.KY_EMAIL, ''), 'a@example.com') AS KY_EMAIL
		, CAST((SELECT CU.KY_EMAIL AS '@KY_EMAIL'
			FROM ADM.C_EMPLOYEE CE
				INNER JOIN ADM.C_USER CU
					ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE
					AND CU.FG_ACTIVE = 1
					AND NULLIF(CU.KY_EMAIL, '') IS NOT NULL
			WHERE CE.ID_POSITION = CP.ID_POSITION
			FOR XML PATH ('EMPLOYEE'), ROOT ('EMPLOYEES')) AS XML) AS XML_EMPLOYEES
	FROM @T_POSITIONS TP
		INNER JOIN ADM.C_POSITION CP
			ON CP.ID_POSITION = TP.XML_POSITIONS.value('(/POSITION/@ID_POSITION)[1]', 'INT')

