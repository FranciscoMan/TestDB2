-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- Create date: 01/02/2019
-- Description: Get work order cartons
-- =============================================
-- 09/01/2019 IGP Added field DS_CARTON in the select list to obtain carton description
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_CARTONS] 
	@PIN_ID_WORK_ORDER INT
	, @PIN_ID_QA27 INT
AS   
	SELECT ID_WO_CARTON
		, ID_CARTON
		, KY_CARTON
		, NM_CARTON
		, DS_CARTON
		, NO_USAGE
		, NO_SCRAP
		, ID_WORK_ORDER
		, ID_PRODUCTION_LINE
		, ID_QA27
		, ID_SHIFT
		, ID_ITEM
		, DT_CREATION
		, KY_USER_APP_CREATION
		, NM_PROGAM_CREATE
	FROM PRD.K_WORK_ORDER_CARTON KWOC
	WHERE KWOC.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
		AND (@PIN_ID_QA27 IS NULL OR (@PIN_ID_QA27 IS NOT NULL AND (KWOC.ID_QA27 = @PIN_ID_QA27)))

