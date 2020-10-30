-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Daniel Dávalos Romero
-- CREATE date: 24/06/2020
-- Description: Get assigned functions to an specific position
-- =============================================
CREATE PROCEDURE  [ADM].[SPE_GET_FUNCTIONS_BY_POSITION]
	@PIN_ID_POSITION AS INT
AS   
BEGIN
	SELECT 
		posFun.ID_FUNCTION, 
		bpFun.NM_FUNCTION, 
		bpFun.KY_TYPE_FUNCTION
	FROM ADM.C_POSITION pos
	INNER JOIN ADM.C_POSITION_FUNCTION posFun ON pos.ID_POSITION = posFun.ID_POSITION
	INNER JOIN ADM.C_BRANCH_PLANT_FUNCTION bpFun ON bpFun.ID_FUNCTION = posFun.ID_FUNCTION
	WHERE pos.ID_POSITION = @PIN_ID_POSITION
	ORDER BY posFun.ID_FUNCTION ASC
END
