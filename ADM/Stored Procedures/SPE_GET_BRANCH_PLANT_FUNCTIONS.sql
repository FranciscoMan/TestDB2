-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Daniel Dávalos Romero
-- CREATE date: 16/06/2020
-- Description: get all defined functions by branch plant
-- =============================================
CREATE PROCEDURE  [ADM].[SPE_GET_BRANCH_PLANT_FUNCTIONS] 
	  @PIN_ID_BRANCH_PLANT AS INT = NULL

AS   
BEGIN
	IF(@PIN_ID_BRANCH_PLANT IS NULL)
	BEGIN
		SELECT 
		func.ID_FUNCTION,
		func.KY_FUNCTION,
		func.NM_FUNCTION,
		func.KY_TYPE_FUNCTION,
		func.ID_PARENT_FUNCTION,
		func.NM_URL,
		func.XML_CONFIGURATION,
		func.NO_ORDER,
		func.ID_BRANCH_PLANT
		FROM [ADM].[C_BRANCH_PLANT_FUNCTION] func
		ORDER BY func.ID_PARENT_FUNCTION ASC
	END
	ELSE 
	BEGIN
		SELECT 
		func.ID_FUNCTION,
		func.KY_FUNCTION,
		func.NM_FUNCTION,
		func.KY_TYPE_FUNCTION,
		func.ID_PARENT_FUNCTION,
		func.NM_URL,
		func.XML_CONFIGURATION,
		func.NO_ORDER,
		func.ID_BRANCH_PLANT
		FROM [ADM].[C_BRANCH_PLANT_FUNCTION] func
		WHERE func.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT
		ORDER BY func.ID_PARENT_FUNCTION ASC
	END
END
