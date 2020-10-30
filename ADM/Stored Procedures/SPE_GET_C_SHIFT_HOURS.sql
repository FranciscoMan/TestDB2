-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Aideé Alvarez.
-- CREATE date: 07/15/2020.
-- Description: GET C_SHIFT_HOURS DATA.
-- =============================================
CREATE PROCEDURE  [ADM].[SPE_GET_C_SHIFT_HOURS]
AS   
	SELECT 
	ID_SHIFT_HOURS, NO_SHIFT_HOUR
	FROM ADM.VW_C_SHIFT_HOURS