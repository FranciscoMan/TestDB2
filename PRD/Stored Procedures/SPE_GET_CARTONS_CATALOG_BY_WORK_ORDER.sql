-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- Create date: 01/02/2019
-- Description: Get cartons an indicates if the item related to work order parameter is associated to the carton number
-- =============================================
-- 01/09/2019 IGP The column DS_VALUE_CATALOG is added to show the carton description.
-- 01/09/2019 IGP The left join relationship with PRD.C_CARTON_ITEM ON ID_VALUE_CATALOG is changed to an inner join to show only associated carton items.
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_CARTONS_CATALOG_BY_WORK_ORDER]
	@PIN_ID_WORK_ORDER INT
AS   

	DECLARE @ID_BRANCH_PLANT INT
		, @ID_ITEM INT

	SELECT TOP 1 @ID_BRANCH_PLANT = KWO.ID_BRANCH_PLANT 
		, @ID_ITEM = KWO.ID_ITEM
	FROM PRD.K_WORK_ORDER KWO
	WHERE KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER

	SELECT CVC.ID_VALUE_CATALOG AS ID_CARTON
		, CVC.KY_VALUE_CATALOG AS KY_CARTON
		, CVC.NM_VALUE_CATALOG AS NM_CARTON
		, CVC.DS_VALUE_CATALOG AS DS_CATALOG 
		, CASE WHEN CCI.ID_CARTON_ITEM IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS FG_IS_ASSOCIATED
	FROM ADM.C_VALUE_CATALOG CVC
		INNER JOIN ADM.C_BRANCH_PLANT CBP 
			ON CBP.ID_CARTON_ITEM_CATALOG = CVC.ID_LIST_CATALOG
		INNER JOIN PRD.C_CARTON_ITEM CCI
			ON CVC.ID_VALUE_CATALOG = CCI.ID_CARTON
			AND CCI.ID_ITEM = @ID_ITEM
	WHERE CBP.ID_BRANCH_PLANT = @ID_BRANCH_PLANT
	ORDER BY FG_IS_ASSOCIATED DESC, KY_CARTON ASC

