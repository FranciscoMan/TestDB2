﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 07/03/2017
-- Description: get all employees catalogs
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_EMPLOYEE_CATALOGS] 
	    @PIN_ID_EMPLOYEE AS int = NULL,
		@PIN_ID_BRANCH_PLANT AS int = NULL

AS   
	BEGIN
	DECLARE 
		@KY_EMPLOYEE AS nvarchar(50),
		@NM_FIRST_NAME AS nvarchar(300),
		@NM_LAST_NAME AS nvarchar(500),
		@KY_EMAIL AS nvarchar(500),
		@ID_BRANCH_PLANT AS int,
		@ID_POSITION AS int,
	 	--@ID_DEPARTMENT AS int,
	 	@FG_ACTIVE AS BIT

		,@XML_POSITIONS AS XML
		  --,@XML_DEPARTMENTS AS XML
		  ,@XML_BRANCHPLANTS AS XML
		  ,@XML_CATALOGS AS XML
		,@XML_PHONE AS XML


	  	SET @XML_POSITIONS = (
		SELECT 	    
		CP.ID_POSITION AS "@ID_POSITION",
        CP.KY_POSITION AS "@KY_POSITION",
        CP.NM_POSITION AS "@NM_POSITION",
        CP.DS_POSITION AS "@DS_POSITION",
        --CP.XML_PHONE AS "@CL_EMPRESA",
        CP.KY_EMAIL AS "@KY_EMAIL",
        CP.KY_TELEGRAM AS "@KY_TELEGRAM",
		CP.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT",
		BP.NM_BRANCH_PLANT AS "@NM_BRANCH_PLANT"
		FROM ADM.C_POSITION CP
		LEFT OUTER JOIN ADM.C_BRANCH_PLANT BP ON CP.ID_BRANCH_PLANT = BP.ID_BRANCH_PLANT
		WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND (CP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT  OR CP.ID_BRANCH_PLANT IS NULL))) 
		ORDER BY CP.KY_POSITION
		FOR XML PATH ('POSITION'), ROOT ('POSITIONS')
	)


	--  	SET @XML_DEPARTMENTS = (
	--	SELECT 	    
	--    --CD.ID_DEPARTMENT  AS "@ID_DEPARTMENT",
 --       CD.KY_DEPARTMENT  AS "@KY_DEPARTMENT",
 --       CD.NM_DEPARTMENT  AS "@NM_DEPARTMENT",
 --       CD.DS_DEPARTMENT  AS "@DS_DEPARTMENT",
	--	CASE CD.FG_ACTIVE WHEN 1 THEN 'Yes' ELSE 'No' END  AS "@FG_ACTIVE"
	--	FROM ADM.C_DEPARTMENT CD
	--	WHERE FG_ACTIVE = 1
	--	ORDER BY  CD.KY_DEPARTMENT
	--	FOR XML PATH ('DEPARTMENT'), ROOT ('DEPARTMENTS')
	--)


		SET @XML_BRANCHPLANTS = (
		SELECT 	    
	    BP.ID_BRANCH_PLANT  AS "@ID_BRANCH_PLANT",
        BP.KY_BRANCH_PLANT  AS "@KY_BRANCH_PLANT",
        BP.NM_BRANCH_PLANT  AS "@NM_BRANCH_PLANT",
        BP.DS_BRANCH_PLANT  AS "@DS_BRANCH_PLANT",
        BP.ID_FILE  AS "@ID_FILE"
		FROM ADM.C_BRANCH_PLANT BP
		ORDER BY BP.KY_BRANCH_PLANT
		FOR XML PATH ('BRANCHPLANT'), ROOT ('BRANCHPLANTS')
	)

	
	       SET @XML_CATALOGS = (
		SELECT @XML_POSITIONS
			, @XML_BRANCHPLANTS
			--, @XML_DEPARTMENTS
		FOR XML PATH ('CATALOGS')
	)

	SET @XML_PHONE = 
	(
		SELECT CE.XML_PHONE
		FROM ADM.C_EMPLOYEE CE
		WHERE CE.ID_EMPLOYEE = @PIN_ID_EMPLOYEE
	)
	SELECT 
		@KY_EMPLOYEE=CE.KY_EMPLOYEE,
        @NM_FIRST_NAME =CE.NM_FIRST_NAME,
        @NM_LAST_NAME =CE.NM_LAST_NAME,
		@KY_EMAIL =CE.KY_EMAIL,
		@ID_BRANCH_PLANT=CE.ID_BRANCH_PLANT,
		@ID_POSITION=CE.ID_POSITION,
		--@ID_DEPARTMENT=CD.ID_DEPARTMENT,
		@FG_ACTIVE = CE.FG_ACTIVE
		FROM ADM.C_EMPLOYEE CE
		LEFT OUTER JOIN ADM.C_BRANCH_PLANT CC ON CC.ID_BRANCH_PLANT = CE.ID_BRANCH_PLANT
		LEFT OUTER JOIN ADM.C_POSITION CP ON CP.ID_POSITION = CE.ID_POSITION
		--LEFT OUTER JOIN ADM.C_DEPARTMENT CD ON CD.ID_DEPARTMENT = CE.ID_DEPARTMENT
		WHERE CE.ID_EMPLOYEE = @PIN_ID_EMPLOYEE



		SELECT  @PIN_ID_EMPLOYEE AS ID_EMPLOYEE,
			    @KY_EMPLOYEE AS KY_EMPLOYEE,
				@NM_FIRST_NAME AS NM_FIRST_NAME,
				@NM_LAST_NAME AS NM_LAST_NAME,
				@KY_EMAIL AS KY_EMAIL,
				@ID_BRANCH_PLANT AS ID_BRANCH_PLANT,
				@ID_POSITION AS ID_POSITION ,
				--@ID_DEPARTMENT AS ID_DEPARTMENT,
				@FG_ACTIVE AS FG_ACTIVE,
				@XML_PHONE AS XML_PHONE
			  ,@XML_CATALOGS AS XML_CATALOGS
END

