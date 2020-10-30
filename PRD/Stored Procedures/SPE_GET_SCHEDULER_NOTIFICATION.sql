﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CREATE date: 2017/06/07
-- Description: Get scheduler notification 
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_SCHEDULER_NOTIFICATION]	 
	@ID_WORK_ORDER AS int, 
	@KY_PROCESS NVARCHAR(50),
	@ID_PRODUCTION_LINE INT,
	@PIN_ID_BRANCH_PLANT INT 
AS   
BEGIN				

	DECLARE @ID_BRANCH_PLANT INT 	 
	DECLARE @ID_POSITION_SCHEDULER INT
	--SELECT * FROM ADM.S_CONFIGURATION			
	--SELECT @ID_POSITION_SCHEDULER=6
		
	DECLARE @XML_BRANCH_PLANT XML = (SELECT TOP 1 XML_CONFIGURATION.query('/CONFIGURATIONS[1]/ESPECIFIC_CONFIGURATION[1]/BRANCH_PLANT[@ID_BRANCH_PLANT= sql:variable("@PIN_ID_BRANCH_PLANT") ][1]/QUALITY_PROCESS[1]') FROM ADM.S_CONFIGURATION)

	SELECT @ID_POSITION_SCHEDULER = T.C.value('@ID_POSITION', 'INT')
	FROM @XML_BRANCH_PLANT.nodes('/QUALITY_PROCESS/SCHEDULER') T(C)

	PRINT @ID_POSITION_SCHEDULER

	SELECT 	 
		 WO.ID_WORK_ORDER
		,NO_WORK_ORDER
		,KY_PROCESS
		,CP.KY_TELEGRAM
		,CP.KY_EMAIL
		,CU.KY_USER
		,NM_FORM
		,CASE 
			WHEN @KY_PROCESS='SCHEDULER'
				THEN REPLACE(REPLACE(ISNULL(DS_BODY,''),'@LINE',ISNULL(WO.NM_PRODUCTION_LINE,'')),'@NO_WORK_ORDER',WO.NO_WORK_ORDER) 
			ELSE
			 DS_BODY
		 END DS_BODY
		,DS_TITLE
		,DS_SUBJECT
		,NM_URL
		,NM_URL_PARAMETERS
		,PN.NO_WIDTH
		,NO_HEIGHT
		,FG_EMAIL
		,FG_TELEGRAM
		,FG_ALERT
		,FG_FORM
	FROM PRD.K_WORK_ORDER WO 
	--INNER JOIN PRD.C_PRODUCTION_LINE PL ON PL.ID_PRODUCTION_LINE = WO.ID_PRODUCTION_LINE
	  INNER JOIN PRD.VW_C_PROCESS_NOTIFICATION PN ON PN.KY_PROCESS=@KY_PROCESS
	INNER JOIN ADM.C_POSITION CP ON CP.ID_POSITION = @ID_POSITION_SCHEDULER
	INNER JOIN ADM.C_EMPLOYEE CE ON CE.ID_POSITION = CP.ID_POSITION AND CE.FG_ACTIVE =1 AND CE.ID_BRANCH_PLANT = CP.ID_BRANCH_PLANT
	INNER JOIN ADM.C_USER CU ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE AND CU.ID_BRANCH_PLANT = CP.ID_BRANCH_PLANT
	WHERE 
		WO.ID_WORK_ORDER=@ID_WORK_ORDER
		--AND PL.ID_PRODUCTION_LINE =@ID_PRODUCTION_LINE

END

