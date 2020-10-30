﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 07/03/2017
-- Description: get all autorized_user_code
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_AUTHORIZED_USER_CODE]
	    @PIN_ID_PROBLEM_CODE AS int = NULL,
	    @PIN_ID_BRANCH_PLANT AS int = NULL


AS   
	BEGIN
	DECLARE 
		@KY_PROBLEM_CODE nvarchar(50),
		@NM_PROBLEM_CODE nvarchar(100),
		@FG_ACTIVE bit,
		@ID_BRANCH_PLANT int,
		@KY_CODE_TYPE nvarchar(10),
		@ID_PROBLEM_AREA int
	   ,@FG_CAN_SKIP_WO BIT
	   ,@XML_POSITIONS AS XML
	   ,@XML_USERS AS XML
	   ,@XML_PROBLEM_AREAS AS XML
	   ,@XML_CODE_TYPES AS XML
	   ,@XML_BRANCHPLANTS AS XML
	   ,@XML_POSITION_SCALING AS XML
	   ,@XML_CATALOGS AS XML
	   ,@XML_CODE_POSITIONS AS XML


	  	SET @XML_POSITIONS = (
		SELECT 	    
			CP.ID_POSITION AS "@ID_POSITION",
			CP.KY_POSITION AS "@KY_POSITION",
			CP.NM_POSITION AS "@NM_POSITION",
			CP.DS_POSITION AS "@DS_POSITION",
			CP.KY_EMAIL AS "@KY_EMAIL",
			CP.KY_TELEGRAM AS "@KY_TELEGRAM"
		FROM ADM.C_POSITION CP
		WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR CP.ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND CP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT )) 
		FOR XML PATH ('POSITION'), ROOT ('POSITIONS')
	    )

		SET @XML_PROBLEM_AREAS = (
		SELECT 	    
			PA.ID_PROBLEM_AREA AS "@ID_PROBLEM_AREA",
			PA.KY_PROBLEM_AREA AS "@KY_PROBLEM_AREA",
			PA.NM_PROBLEM_AREA AS "@NM_PROBLEM_AREA",
			PA.DS_PROBLEM_AREA AS "@DS_PROBLEM_AREA",
			PA.FG_ACTIVE AS "@FG_ACTIVE",
			PA.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT"
		FROM [PRD].[C_PROBLEM_AREA] PA
		WHERE PA.FG_ACTIVE = 1 
		AND (@PIN_ID_BRANCH_PLANT IS NULL OR PA.ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND PA.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT )) 
		FOR XML PATH ('PROBLEM_AREA'), ROOT ('PROBLEM_AREAS')
	    )


		SET @XML_CODE_TYPES = (
		SELECT 	    
			CT.ID_CODE_TYPE AS "@ID_CODE_TYPE"
		   ,CT.KY_CODE_TYPE AS "@KY_CODE_TYPE"
		   ,CT.NM_CODE_TYPE AS "@NM_CODE_TYPE"
		FROM [ADM].[VW_C_CODE_TYPE] CT
		FOR XML PATH ('CODE_TYPE'), ROOT ('CODE_TYPES')
		)



		SET @XML_BRANCHPLANTS = (
		SELECT 	    
			BP.ID_BRANCH_PLANT  AS "@ID_BRANCH_PLANT",
			BP.KY_BRANCH_PLANT  AS "@KY_BRANCH_PLANT",
			BP.NM_BRANCH_PLANT  AS "@NM_BRANCH_PLANT",
			BP.DS_BRANCH_PLANT  AS "@DS_BRANCH_PLANT",
			BP.ID_FILE  AS "@ID_FILE"
		FROM ADM.C_BRANCH_PLANT BP
		WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR BP.ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND BP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT )) 
		ORDER BY BP.KY_BRANCH_PLANT 
		FOR XML PATH ('BRANCHPLANT'), ROOT ('BRANCHPLANTS')
	    )


		--SET @XML_USERS = (
		--SELECT 	    
		--CU.[KY_USER] AS "@KY_USER",
		--CU.[NM_USER] AS "@NM_USER",
		--CU.[KY_EMAIL] AS "@KY_EMAIL",
		--CU.[NM_PASSWORD] AS "@NM_PASSWORD",
		--CASE CU.[FG_ACTIVE] WHEN 1 THEN 'Yes' ELSE 'No' END AS "@KY_ACTIVE",
		--CU.[FG_ACTIVE] AS "@FG_ACTIVE",
		--CU.[ID_EMPLOYEE] AS "@ID_EMPLOYEE",
		--CE.KY_EMPLOYEE AS "@KY_EMPLOYEE",
		--CONCAT ( CE.NM_FIRST_NAME, ' ',CE.NM_LAST_NAME,' ' )AS "@NM_EMPLOYEE",
		--CP.ID_POSITION AS "@ID_POSITION",
		--CP.KY_POSITION AS "@KY_POSITION",
		--CP.NM_POSITION AS "@NM_POSITION"
		--FROM ADM.C_USER CU
		--INNER JOIN ADM.C_EMPLOYEE CE ON CE.ID_EMPLOYEE = CU.ID_EMPLOYEE
		--INNER JOIN ADM.C_POSITION CP ON CE.ID_POSITION = CP.ID_POSITION
		--WHERE CU.FG_ACTIVE = 1
		--FOR XML PATH ('USER'), ROOT ('USERS')
	 --   )


		SET @XML_POSITION_SCALING = (
		SELECT 
			   NEWID() AS "@ID_ASSISTANT",
			   KPS.ID_POSITION_SCALING AS "@ID_POSITION_SCALING"
			  ,KPS.ID_PROBLEM_CODE AS "@ID_PROBLEM_CODE"
			  ,KPS.ID_POSITION AS "@ID_POSITION"
			  ,KPS.KY_LEVEL_TYPE AS "@KY_LEVEL_TYPE"
			  ,CP.KY_POSITION AS "@KY_POSITION"
			  ,CP.NM_POSITION AS "@NM_POSITION"
			  ,CP.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT"
		 FROM [PRD].[K_POSITION_SCALING] KPS
		 LEFT OUTER JOIN ADM.C_POSITION CP ON CP.ID_POSITION = KPS.ID_POSITION
		 LEFT OUTER JOIN PRD.C_PROBLEM_CODE PC ON KPS.ID_PROBLEM_CODE = PC.ID_PROBLEM_CODE
		 --LEFT OUTER JOIN ADM.C_BRANCH_PLANT BP ON BP.ID_BRANCH_PLANT = CP.ID_BRANCH_PLANT
		 WHERE  KPS.[ID_PROBLEM_CODE] = @PIN_ID_PROBLEM_CODE
	    --AND (@PIN_ID_BRANCH_PLANT IS NULL OR CP.ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND CP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT )) 
		FOR XML PATH ('POSITION_SCALING'), ROOT ('POSITIONS_SCALING')
	    )

		SET @XML_CODE_POSITIONS = (
		SELECT 	    
			CCP.ID_POSITION_CODE AS "@ID_POSITION_CODE",
			CCP.ID_PROBLEM_CODE  AS "@ID_PROBLEM_CODE",
			CCP.ID_POSITION      AS "@ID_POSITION",
			CP.KY_POSITION       AS "@KY_POSITION",
			CP.NM_POSITION		 AS "@NM_POSITION"
		FROM PRD.C_CODES_POSITION_ALERT CCP
		JOIN ADM.C_POSITION CP ON CCP.ID_POSITION = CP.ID_POSITION
		WHERE CCP.ID_PROBLEM_CODE = @PIN_ID_PROBLEM_CODE
		ORDER BY CCP.ID_POSITION_CODE
		FOR XML PATH ('POSITION_CODE'), ROOT ('POSITIONS_CODES')
	    )



		SELECT 
			 @PIN_ID_PROBLEM_CODE = PC.[ID_PROBLEM_CODE]
			,@KY_PROBLEM_CODE = PC.[KY_PROBLEM_CODE]
			,@NM_PROBLEM_CODE = PC.[NM_PROBLEM_CODE]
			,@FG_ACTIVE = PC.[FG_ACTIVE]
			,@ID_BRANCH_PLANT = PC.[ID_BRANCH_PLANT]
			,@KY_CODE_TYPE = PC.[KY_CODE_TYPE]
			,@ID_PROBLEM_AREA = PC.[ID_PROBLEM_AREA]
			,@FG_CAN_SKIP_WO = PC.FG_CAN_SKIP_WO
		 FROM PRD.C_PROBLEM_CODE PC
		 --LEFT OUTER JOIN PRD.C_PROBLEM_CODE PC ON KAUC.ID_PROBLEM_CODE = PC.ID_PROBLEM_CODE
		 WHERE PC.ID_PROBLEM_CODE = @PIN_ID_PROBLEM_CODE
		

	    SET @XML_CATALOGS = (
		SELECT @XML_POSITIONS,
			   @XML_PROBLEM_AREAS,
			   @XML_CODE_TYPES,
			   @XML_BRANCHPLANTS,
			   @XML_USERS,
			   @XML_POSITION_SCALING,
			   @XML_CODE_POSITIONS
		FOR XML PATH ('CATALOGS')
	    )


		SELECT
			   @PIN_ID_PROBLEM_CODE AS ID_PROBLEM_CODE
			  ,@KY_PROBLEM_CODE AS KY_PROBLEM_CODE
			  ,@NM_PROBLEM_CODE AS NM_PROBLEM_CODE
			  ,@FG_ACTIVE AS FG_ACTIVE
			  ,@FG_CAN_SKIP_WO AS FG_CAN_SKIP_WO
			  ,@ID_BRANCH_PLANT AS ID_BRANCH_PLANT
			  ,@KY_CODE_TYPE AS KY_CODE_TYPE
			  ,@ID_PROBLEM_AREA AS ID_PROBLEM_AREA
			  ,@XML_CATALOGS AS XML_CATALOGS
END
