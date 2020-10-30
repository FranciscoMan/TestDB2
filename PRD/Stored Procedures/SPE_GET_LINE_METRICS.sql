﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez 
-- CREATE date: 27/04/2017
-- Description: get all metrics per production line
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_LINE_METRICS] 
	    @PIN_ID_PRODUCTION_LINE INT = NULL,
	    @PIN_ID_METRICS INT = NULL,
		@PIN_ID_BRANCH_PLANT INT
AS   

SELECT 
	   LC.[ID_LINE_METRIC]
      ,NEWID() AS ID_ASSISTANT
      ,LC.[ID_PRODUCTION_LINE]
      ,PL.[KY_PRODUCTION_LINE]
      ,PL.[NM_PRODUCTION_LINE]
      ,PL.[DS_PRODUCTION_LINE]
      ,PL.[FG_ACTIVE]
      ,PL.[ID_PRODUCTION_LINE_TYPE]
      ,PL.[ID_BRANCH_PLANT]
      ,PL.[NO_POUNDS_PER_HOUR]
      ,LC.[ID_METRICS]
	  ,M.[KY_METRICS]
	  ,M.[NM_METRICS]
	  ,M.[KY_FIELD_TYPE]
	  ,M.[FG_ENABLED]
	  ,CASE WHEN M.[FG_ENABLED] =1 THEN 'Yes' ELSE 'No' END KY_ENABLED
	  ,M.[FG_REQUIRED]
	  ,CASE WHEN M.[FG_REQUIRED] =1 THEN 'Yes' ELSE 'No' END KY_REQUIRED
	  ,M.[DS_TOOLTIP]
      ,LC.[XML_FIELD_SETTINGS]
	  ,LC.[XML_FIELD_SETTINGS].value('(/SETTINGS/FIELD_TYPES/@NOMINAL_VALUE)[1]', 'NVARCHAR(MAX)') as NOMINAL_VALUE
	  --,LC.ID_DEVICE_METRICS
	  --,DM.NO_REGISTER
	  --,DM.[KY_MODBUS_DATATYPE]
   --   ,DM.[KY_SCALING_TYPE]
   --   ,DM.[NO_RAW_HI]
   --   ,DM.[NO_RAW_LO]
   --   ,DM.[NO_SCALE_HI]
   --   ,DM.[NO_SCALE_LO]
   --   ,DM.[FG_CLAMP_HI]
   --   ,DM.[FG_CLAMP_LO]
	  --,D.[ID_DEVICE]
	  --,D.[NO_IP]
   --   ,D.[NO_PORT]
  FROM [PRD].[C_LINE_METRIC] LC
  LEFT OUTER JOIN PRD.C_PRODUCTION_LINE PL ON PL.ID_PRODUCTION_LINE = LC.ID_PRODUCTION_LINE
  LEFT OUTER JOIN PRD.C_METRICS M ON M.ID_METRICS = LC.ID_METRICS
  --LEFT OUTER JOIN [PRD].[C_DEVICE_METRICS] DM ON DM.ID_DEVICE_METRICS = LC.ID_DEVICE_METRICS 
  --LEFT OUTER JOIN [PRD].[C_DEVICE] D ON DM.ID_DEVICE = D.ID_DEVICE 
	WHERE 
		(@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND 
		LC.[ID_PRODUCTION_LINE] = @PIN_ID_PRODUCTION_LINE)) AND 
		(@PIN_ID_METRICS IS NULL OR (@PIN_ID_METRICS IS NOT NULL AND LC.ID_METRICS = @PIN_ID_METRICS))
	    AND 
		(@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND PL.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
	ORDER BY PL.ID_PRODUCTION_LINE DESC