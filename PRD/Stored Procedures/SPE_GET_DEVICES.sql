﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 29/03/2017
-- Description: get all devices
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_DEVICES] 
	    @PIN_ID_DEVICE AS int = NULL,
        @PIN_KY_DEVICE AS nvarchar(50) = NULL,
        @PIN_NM_DEVICE AS nvarchar(100) = NULL,
        @PIN_DS_DEVICE AS nvarchar(300) = NULL,
	    --@PIN_ID_PRODUCTION_LINE AS int = NULL,
	    @PIN_ID_BRANCH_PLANT AS int = NULL,
        @PIN_NO_IP AS nvarchar(50)= NULL,
        @PIN_NO_PORT AS nvarchar(10) = NULL,
        @PIN_FG_ACTIVE AS BIT = NULL


AS   
	SELECT 
	   P.[ID_DEVICE]
      ,P.[KY_DEVICE]
	  ,P.[NM_DEVICE]
      ,P.[DS_DEVICE]
   --   ,P.[ID_PRODUCTION_LINE]
	  --,PL.KY_PRODUCTION_LINE
	  --,PL.NM_PRODUCTION_LINE
      ,P.[ID_BRANCH_PLANT]
	  ,BP.KY_BRANCH_PLANT
	  ,ISNULL(BP.NM_BRANCH_PLANT,'All') AS NM_BRANCH_PLANT
      ,P.[NO_IP]
      ,P.[NO_PORT]
	  ,P.[FG_ACTIVE]
	FROM [PRD].[C_DEVICE] P
	LEFT OUTER JOIN ADM.C_BRANCH_PLANT BP ON P.ID_BRANCH_PLANT = BP.ID_BRANCH_PLANT
	--LEFT OUTER JOIN PRD.C_PRODUCTION_LINE PL ON PL.ID_PRODUCTION_LINE = P.ID_PRODUCTION_LINE
	WHERE (@PIN_ID_DEVICE IS NULL OR (@PIN_ID_DEVICE IS NOT NULL AND P.[ID_DEVICE] = @PIN_ID_DEVICE)) AND 
			(@PIN_KY_DEVICE IS NULL OR (@PIN_KY_DEVICE IS NOT NULL AND P.[KY_DEVICE] = @PIN_KY_DEVICE)) AND 
			(@PIN_DS_DEVICE IS NULL OR (@PIN_DS_DEVICE IS NOT NULL AND P.[DS_DEVICE] = @PIN_DS_DEVICE)) AND 
			(@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND P.[ID_BRANCH_PLANT] = @PIN_ID_BRANCH_PLANT)) AND
			(@PIN_NO_IP IS NULL OR (@PIN_NO_IP IS NOT NULL AND P.[NO_IP] = @PIN_NO_IP)) AND
			(@PIN_NO_PORT IS NULL OR (@PIN_NO_PORT IS NOT NULL AND P.[NO_PORT] = @PIN_NO_PORT))AND
			(@PIN_NM_DEVICE IS NULL OR (@PIN_NM_DEVICE IS NOT NULL AND P.[NM_DEVICE] = @PIN_NM_DEVICE))AND
			(@PIN_FG_ACTIVE IS NULL OR (@PIN_FG_ACTIVE IS NOT NULL AND P.[FG_ACTIVE] = @PIN_FG_ACTIVE))

