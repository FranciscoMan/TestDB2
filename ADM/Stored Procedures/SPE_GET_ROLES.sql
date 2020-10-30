-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan de dios pérez
-- CREATE date: 21/03/2017
-- Description: get all roles 
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_GET_ROLES] 
	    @PIN_ID_ROLE AS int = NULL,
        @PIN_KY_ROLE AS nvarchar(50) = NULL,
        @PIN_NM_ROLE AS nvarchar(300) = NULL,
		@PIN_FG_ACTIVE AS bit = NULL,
		@PIN_DT_INACTIVE AS datetime = NULL

AS   
	SELECT 
	    CR.ID_ROLE,
        CR.KY_ROLE,
        CR.NM_ROLE,
        CR.FG_ACTIVE,
		CASE CR.FG_ACTIVE WHEN 1 THEN 'Yes' ELSE 'No' END AS KY_ACTIVE
	FROM ADM.C_ROLE CR
	WHERE (@PIN_ID_ROLE IS NULL OR (@PIN_ID_ROLE IS NOT NULL AND  CR.ID_ROLE = @PIN_ID_ROLE )) AND 
			(@PIN_KY_ROLE IS NULL OR (@PIN_KY_ROLE IS NOT NULL AND CR.KY_ROLE = @PIN_KY_ROLE )) AND 
			(@PIN_NM_ROLE IS NULL OR (@PIN_NM_ROLE IS NOT NULL AND CR.NM_ROLE = @PIN_NM_ROLE )) AND 
    		(@PIN_FG_ACTIVE IS NULL OR (@PIN_FG_ACTIVE IS NOT NULL AND CR.FG_ACTIVE = @PIN_FG_ACTIVE ))

