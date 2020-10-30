﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 06/03/2017
-- Description: get all positions 
-- =============================================


CREATE PROCEDURE    [ADM].[SPE_GET_POSITION] 
	    @PIN_ID_POSITION AS int = NULL,
        @PIN_KY_POSITION AS nvarchar(50) = NULL,
        @PIN_NM_POSITION AS nvarchar(300) = NULL,
        @PIN_DS_POSITION AS nvarchar(500) = NULL,
        --@PIN_XML_PHONE AS XML = NULL,
        @PIN_KY_EMAIL AS nvarchar(500) = NULL,
        @PIN_KY_TELEGRAM AS nvarchar(15) = NULL,
		@PIN_ID_BRANCH_PLANT AS int = NULL,
		@PIN_XML_POSITIONS AS XML = NULL

AS   

	DECLARE @T_POSITIONS AS TABLE (ID_POSITION INT);


	IF @PIN_XML_POSITIONS IS NULL BEGIN

		INSERT INTO @T_POSITIONS
		SELECT ID_POSITION
		FROM ADM.C_POSITION

	END
	ELSE BEGIN

		INSERT INTO @T_POSITIONS
		SELECT c.value('@ID_POSITION','INT')
		FROM @PIN_XML_POSITIONS.nodes('/POSITIONS/POSITION') t(c)

	END



	SELECT 
	    CP.ID_POSITION,
        CP.KY_POSITION,
        CP.NM_POSITION,
        CP.DS_POSITION,
        --CP.XML_PHONE,
        CP.KY_EMAIL,
        CP.KY_TELEGRAM,
		CP.ID_BRANCH_PLANT,
		BP.KY_BRANCH_PLANT,
		ISNULL(BP.NM_BRANCH_PLANT,'All') as NM_BRANCH_PLANT,
		cp.ID_DEPARTMENT,
		D.KY_DEPARTMENT,
		D.NM_DEPARTMENT
	FROM [ADM].[C_POSITION] CP
		INNER JOIN @T_POSITIONS TP ON CP.ID_POSITION = TP.ID_POSITION
		LEFT OUTER JOIN ADM.C_BRANCH_PLANT BP ON BP.ID_BRANCH_PLANT = CP.ID_BRANCH_PLANT
		LEFT OUTER JOIN ADM.C_DEPARTMENT D ON D.ID_DEPARTMENT = CP.ID_DEPARTMENT
	WHERE (@PIN_ID_POSITION IS NULL OR (@PIN_ID_POSITION IS NOT NULL AND CP.[ID_POSITION] = @PIN_ID_POSITION)) AND 
			(@PIN_KY_POSITION IS NULL OR (@PIN_KY_POSITION IS NOT NULL AND CP.[KY_POSITION] = @PIN_KY_POSITION)) AND 
			(@PIN_NM_POSITION IS NULL OR (@PIN_NM_POSITION IS NOT NULL AND CP.[NM_POSITION] = @PIN_NM_POSITION)) AND 
    		(@PIN_DS_POSITION IS NULL OR (@PIN_DS_POSITION IS NOT NULL AND CP.[DS_POSITION] = @PIN_DS_POSITION)) AND 
			(@PIN_KY_EMAIL IS NULL OR (@PIN_KY_EMAIL IS NOT NULL AND CP.[KY_EMAIL] = @PIN_KY_EMAIL)) AND
			(@PIN_KY_TELEGRAM IS NULL OR (@PIN_KY_TELEGRAM IS NOT NULL AND CP.[KY_TELEGRAM] = @PIN_KY_TELEGRAM)) AND
			(@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND (CP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT  OR CP.ID_BRANCH_PLANT IS NULL)))

