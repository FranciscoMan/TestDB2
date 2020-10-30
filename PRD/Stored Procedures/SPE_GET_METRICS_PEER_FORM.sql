﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Vitek - 2019
-- Author: AA.
-- CREATE date: 28/03/2020
-- Description: get all metrics per form
-- =============================================
-- 08/12/2019 JDR KY_VARIABLE_ACQUISITION_TYPE column added
-- 03/17/2020 Added columns to use this SP as guide to Data Collection to build 2 forms: SOC (comming soon) and Product Reading. by AA
-- 06/17/2020 Added section BP10 to recycle this SP. by AA
-- =============================================
CREATE PROCEDURE  [PRD].[SPE_GET_METRICS_PEER_FORM] 
		@PIN_ID_FORM_METRIC AS INT = NULL,
		@PIN_ID_METRIC AS INT = NULL,
		@PIN_ID_FORM AS INT = NULL,
		@PIN_ID_K_FORM AS INT = NULL, -- USING BY BRANCH BP12 (NEW FEATURE)
		@PIN_ID_BRANCH_PLANT AS INT = NULL 
AS   
	-- DECLARE VARIABLES... 
	DECLARE @PIN_LAST_QA INT
	      , @PIN_WO INT
		  , @PIN_CURRENT_QA INT
		  , @COUNTER INT
		  , @FLAG_ONCE VARCHAR(50)

IF (@PIN_ID_K_FORM IS NULL)
	BEGIN
	SET @FLAG_ONCE = 'ONCE'
	END
ELSE 
	BEGIN
			--IF (@PIN_ID_BRANCH_PLANT = (SELECT ID_BRANCH_PLANT FROM ADM.C_BRANCH_PLANT WHERE KY_BRANCH_PLANT = 'BP21')) --EXAMPLE, BP21 LIKE BP10
			--BEGIN
						-- LOOKUP FOR WORK ORDER.
					 SELECT @PIN_CURRENT_QA = ID_QA27, 
							@PIN_WO = ID_WORK_ORDER
					 FROM PRD.K_FORM WHERE ID_K_FORM = @PIN_ID_K_FORM --AND ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT

	 					-- FIRST, CHECK IF THE TABLE HAS DATA.
					SET @COUNTER = (SELECT COUNT(*) FROM PRD.K_FORM WHERE ID_WORK_ORDER = @PIN_WO
					                AND ID_FORM = @PIN_ID_FORM) -- ADDED?

					-- GET YOUR LAST REGISTER TO COMPARE CURRENT QA TO LAST QA.
					 SET @PIN_LAST_QA =(SELECT TOP 1 ID_QA27 FROM
										(SELECT TOP 2 ID_QA27
										FROM PRD.K_FORM WHERE ID_WORK_ORDER = @PIN_WO 
										AND ID_FORM = @PIN_ID_FORM --ADDED ? 
										ORDER BY ID_K_FORM DESC) SMT
										ORDER BY ID_QA27 DESC)

					 IF (@COUNTER = 1) -- THEN IT'S THE FIRST TIME IF THE COUNTER MARK 1.
						BEGIN
						SET @FLAG_ONCE = 'ONCE'
						END
					 ELSE -- THEN, YOU HAVE MORE REGISTERS. TIME TO COMPARE QAs.
						 BEGIN
							IF (@PIN_LAST_QA = @PIN_CURRENT_QA ) -- SAME WO, SAME QA
								BEGIN
								SET @FLAG_ONCE = NULL
								END
								ELSE -- SAME WO, DIFFERENT QA, FIRST TIME TO VIEW ONCE.
								BEGIN
								SET @FLAG_ONCE = 'ONCE' 
								END
						 END
			--END
	END

	--IT'S TIME TO SEND YOUR DATA!
	SELECT CFM.ID_FORM_METRICS,
		   CF.ID_FORM
		 , CF.NM_FORM
		 , CM.ID_METRICS
		 , CM.NM_METRICS
		 , CFM.FG_VALIDATE_METRICS
		 , CFM.KY_VARIABLE_ACQUISITION_TYPE
		 , CM.KY_FIELD_TYPE
		 , CM.XML_FIELD_SETTINGS

		FROM PRD.C_FORM_METRICS CFM
		JOIN PRD.C_FORM CF ON CFM.ID_FORM = CF.ID_FORM AND CF.FG_ACTIVE = 1
		JOIN PRD.C_METRICS CM ON CFM.ID_METRICS = CM.ID_METRICS

  	   WHERE (@PIN_ID_FORM_METRIC IS NULL OR (@PIN_ID_FORM_METRIC IS NOT NULL AND CFM.ID_FORM = @PIN_ID_FORM_METRIC)) AND 
			 (@PIN_ID_METRIC IS NULL OR (@PIN_ID_METRIC IS NOT NULL AND CM.ID_METRICS = @PIN_ID_METRIC)) AND
			 (@PIN_ID_FORM IS NULL OR (@PIN_ID_FORM IS NOT NULL AND CF.ID_FORM = @PIN_ID_FORM)) AND
			 CFM.KY_VARIABLE_ACQUISITION_TYPE IN ('ALWAYS', 'RANDOM', 'EVEN', 'ODD', @FLAG_ONCE) AND
			 (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND CF.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))