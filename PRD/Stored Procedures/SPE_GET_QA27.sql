﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 4/04/2017
-- Description: get WORKS ORDERS
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_QA27] 
	    @PIN_ID_QA27 AS int = NULL,
		@PIN_ID_WORK_ORDER AS int = NULL,
        @PIN_KY_SHIFT AS nvarchar(50) = NULL,
		@PIN_NO_ORDER AS int = NULL,
		--@PIN_NO_ASSIGNED_TIME AS int = NULL,
		@PIN_DT_INITIAL_TIME AS datetime NULL,
		@PIN_DT_FINAL_TIME AS datetime =NULL,
		@PIN_KY_STATUS AS nvarchar(200)= NULL,
		@PIN_DT_QA27 AS datetime = NULL,
		@PIN_ID_FOREMAN AS int = NULL,
		@PIN_NM_FOREMAN AS nvarchar(100) = NULL,
		@PIN_ID_LEADMAN AS int = NULL,
		@PIN_NM_LEADMAN AS nvarchar(100) = NULL
	AS  
		 SELECT 
				KQA.ID_QA27, 
				KQA.ID_WORK_ORDER, 
				KQA.KY_SHIFT, 
				KQA.NO_ORDER, 
				--KQA.NO_ASSIGNED_TIME, 
				CONVERT(VARCHAR(10),KQA.DT_INITIAL_TIME,101) DT_INITIAL_TIME, 
				CONVERT(VARCHAR(10),KQA.DT_FINAL_TIME,101) DT_FINAL_TIME, 
				KQA.KY_STATUS, 
				CONVERT(VARCHAR(10),KQA.DT_QA27,101) DT_QA27, 
				KQA.ID_FOREMAN, 
				KQA.NM_FOREMAN, 
				CE_FOREMAN.NM_FIRST_NAME+' '+ CE_FOREMAN.NM_LAST_NAME NM_FOREMAN_COMPLETE,
				KQA.ID_LEADMAN, 
				KQA.NM_LEADMAN,
				CE_LEADMAN.NM_FIRST_NAME+' '+ CE_LEADMAN.NM_LAST_NAME NM_LEADMAN_COMPLETE
			  FROM PRD.K_WORK_ORDER KWO
   LEFT OUTER JOIN PRD.K_QA27 KQA ON KWO.ID_WORK_ORDER = KQA.ID_WORK_ORDER
   LEFT OUTER JOIN ADM.C_EMPLOYEE CE_LEADMAN ON  KQA.ID_LEADMAN = CE_LEADMAN.ID_EMPLOYEE
   LEFT OUTER JOIN ADM.C_EMPLOYEE CE_FOREMAN ON  KQA.ID_FOREMAN = CE_FOREMAN.ID_EMPLOYEE

		  WHERE (@PIN_ID_QA27 IS NULL OR (@PIN_ID_QA27 IS NOT NULL AND KQA.ID_QA27 = @PIN_ID_QA27 )) AND 
				(@PIN_ID_WORK_ORDER IS NULL OR (@PIN_ID_WORK_ORDER IS NOT NULL AND KQA.ID_WORK_ORDER = @PIN_ID_WORK_ORDER)) AND
			    (@PIN_KY_STATUS IS NULL OR (@PIN_KY_STATUS IS NOT NULL AND KQA.KY_STATUS = @PIN_KY_STATUS ))
			
	  ORDER BY KQA.NO_ORDER ASC
