-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 09/27/2018
-- Description: Get cartons by item
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_ITEM_CARTONS] 
	@PIN_ID_ITEM AS int = NULL

AS   

	SELECT CCI.ID_CARTON_ITEM
		, CCI.ID_ITEM
		, CVC.ID_VALUE_CATALOG
		, CVC.KY_VALUE_CATALOG
		, CVC.NM_VALUE_CATALOG
	FROM PRD.C_CARTON_ITEM CCI
		INNER JOIN ADM.C_VALUE_CATALOG CVC
			ON CCI.ID_CARTON = CVC.ID_VALUE_CATALOG
	WHERE CCI.ID_ITEM = @PIN_ID_ITEM
	ORDER BY CVC.NM_VALUE_CATALOG ASC

