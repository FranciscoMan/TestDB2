﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 03/05/2017
-- Description: get all devices metrics
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_DEVICE_METRICS] 
	    @PIN_ID_DEVICE_METRICS AS int = NULL,
	    @PIN_ID_DEVICE AS int = NULL,
	    @PIN_ID_METRICS AS int = NULL,
        @PIN_NO_REGISTER AS nvarchar(50) = NULL


AS   
		SELECT 	    
	    PM.ID_DEVICE_METRICS ,
	    NEWID()  AS ID_ASSISTANT,
        PM.ID_DEVICE ,
        PM.ID_METRICS ,
		D.KY_DEVICE,
		D.NM_DEVICE,
        CM.KY_METRICS  ,
        CM.NM_METRICS ,
        PM.NO_REGISTER ,
        PM.KY_MODBUS_DATATYPE ,
		VWMD.NM_MODBUS_DATATYPE
      ,	 PM.[KY_SCALING_TYPE]
	  ,	 VST.[NM_SCALING_TYPE]
	  ,	 PM.[NO_RAW_HI]
      ,  PM.[NO_RAW_LO]
      ,  PM.[NO_SCALE_HI]
      ,  PM.[NO_SCALE_LO]
      ,  PM.[FG_CLAMP_HI]
      ,  PM.[FG_CLAMP_LO]
		FROM PRD.C_DEVICE_METRICS PM
			LEFT OUTER JOIN ADM.VW_C_MODBUS_DATATYPE VWMD ON VWMD.KY_MODBUS_DATATYPE = PM.KY_MODBUS_DATATYPE
			LEFT OUTER JOIN [ADM].[VW_SCALING_TYPE] VST ON VST.KY_SCALING_TYPE= PM.KY_SCALING_TYPE
			LEFT OUTER JOIN PRD.C_METRICS CM ON CM.ID_METRICS = PM.ID_METRICS
			LEFT OUTER JOIN PRD.C_DEVICE D ON D.ID_DEVICE = PM.ID_DEVICE
	WHERE (@PIN_ID_DEVICE_METRICS IS NULL OR (@PIN_ID_DEVICE_METRICS IS NOT NULL AND PM.[ID_DEVICE_METRICS] = @PIN_ID_DEVICE_METRICS)) AND 
			(@PIN_ID_DEVICE IS NULL OR (@PIN_ID_DEVICE IS NOT NULL AND PM.[ID_DEVICE] = @PIN_ID_DEVICE)) AND 
			(@PIN_ID_METRICS IS NULL OR (@PIN_ID_METRICS IS NOT NULL AND PM.[ID_METRICS] = @PIN_ID_METRICS)) AND 
			(@PIN_NO_REGISTER IS NULL OR (@PIN_NO_REGISTER IS NOT NULL AND PM.[NO_REGISTER] = @PIN_NO_REGISTER))

