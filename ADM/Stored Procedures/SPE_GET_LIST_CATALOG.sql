﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 09/03/2017
-- Description: get alL LIST CATALOG 
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_GET_LIST_CATALOG] 
	    @PIN_ID_LIST_CATALOG AS int = NULL,
        @PIN_KY_LIST_CATALOG AS nvarchar(50) = NULL,
        @PIN_NM_LIST_CATALOG AS nvarchar(300) = NULL,
        @PIN_DS_LIST_CATALOG AS nvarchar(500) = NULL,
		@PIN_FG_ACTIVE AS bit = NULL,
		@PIN_ID_BRANCH_PLANT as int = null

AS   
	SELECT 
	    ID_LIST_CATALOG,
        KY_LIST_CATALOG,
        NM_LIST_CATALOG,
        DS_LIST_CATALOG,
		ID_BRANCH_PLANT,
		CASE FG_ACTIVE WHEN 1 THEN 'Yes' ELSE 'No' END AS KY_ACTIVE
	FROM ADM.C_LIST_CATALOG CLC	
	WHERE (@PIN_ID_LIST_CATALOG IS NULL OR (@PIN_ID_LIST_CATALOG IS NOT NULL AND UPPER(ID_LIST_CATALOG) = UPPER(@PIN_ID_LIST_CATALOG ))) AND 
			(@PIN_KY_LIST_CATALOG IS NULL OR (@PIN_KY_LIST_CATALOG IS NOT NULL AND UPPER(KY_LIST_CATALOG) = UPPER(@PIN_KY_LIST_CATALOG ))) AND 
			(@PIN_NM_LIST_CATALOG IS NULL OR (@PIN_NM_LIST_CATALOG IS NOT NULL AND UPPER(NM_LIST_CATALOG) = UPPER(@PIN_NM_LIST_CATALOG ))) AND 
    		(@PIN_DS_LIST_CATALOG IS NULL OR (@PIN_DS_LIST_CATALOG IS NOT NULL AND UPPER(DS_LIST_CATALOG) = UPPER(@PIN_DS_LIST_CATALOG ))) AND 
			(@PIN_FG_ACTIVE IS NULL OR (@PIN_FG_ACTIVE IS NOT NULL AND [FG_ACTIVE] = @PIN_FG_ACTIVE)) AND
			(@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))

