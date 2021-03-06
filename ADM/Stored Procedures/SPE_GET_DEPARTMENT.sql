﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 01/03/2017
-- Description: get all departments 
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_GET_DEPARTMENT] 
	    @PIN_ID_DEPARTMENT AS int = NULL,
        @PIN_KY_DEPARTMENT AS nvarchar(50) = NULL,
        @PIN_NM_DEPARTMENT AS nvarchar(300) = NULL,
        @PIN_DS_DEPARTMENT AS nvarchar(500) = NULL,
        @PIN_FG_ACTIVE AS bit = NULL

AS   
	SELECT 
	    ID_DEPARTMENT,
        KY_DEPARTMENT,
        NM_DEPARTMENT,
        DS_DEPARTMENT,
		FG_ACTIVE
	FROM ADM.C_DEPARTMENT
	WHERE (@PIN_ID_DEPARTMENT IS NULL OR (@PIN_ID_DEPARTMENT IS NOT NULL AND [ID_DEPARTMENT] = @PIN_ID_DEPARTMENT)) AND 
			(@PIN_KY_DEPARTMENT IS NULL OR (@PIN_KY_DEPARTMENT IS NOT NULL AND [KY_DEPARTMENT] = @PIN_KY_DEPARTMENT)) AND 
			(@PIN_NM_DEPARTMENT IS NULL OR (@PIN_NM_DEPARTMENT IS NOT NULL AND [NM_DEPARTMENT] = @PIN_NM_DEPARTMENT)) AND 
    		(@PIN_DS_DEPARTMENT IS NULL OR (@PIN_DS_DEPARTMENT IS NOT NULL AND [DS_DEPARTMENT] = @PIN_DS_DEPARTMENT)) AND 
			(@PIN_FG_ACTIVE IS NULL OR (@PIN_FG_ACTIVE IS NOT NULL AND [FG_ACTIVE] = @PIN_FG_ACTIVE))





