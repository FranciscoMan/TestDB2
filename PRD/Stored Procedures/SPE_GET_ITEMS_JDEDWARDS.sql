-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 02/11/2017
-- Description: Get all items from JDEwards test database
-- =============================================
-- 18/05/2018 JDR @PIN_FG_TEST parameter deleted, @PIN_FG_NOT_IMPORTED_ONLY parameter added, Filter condition change to query all items or only those which have not been imported
-- =============================================

CREATE PROCEDURE  [PRD].[SPE_GET_ITEMS_JDEDWARDS]
	@PIN_FG_NOT_IMPORTED_ONLY AS BIT = NULL
AS   
	SELECT ID_ITEM
		, KY_ITEM
		, NM_ITEM
		, DS_ITEM
		, KY_UPC
		, NO_POUNDS_PER_ITEM
		, DS_NOTES_JDEDWARDS
	FROM PRD.VW_C_ITEM_JDEDWARDS VCIJ
	WHERE ISNULL(@PIN_FG_NOT_IMPORTED_ONLY, 0) = 0
		OR NOT EXISTS (SELECT TOP 1 1 FROM PRD.C_ITEM CI WHERE CI.ID_ITEM = VCIJ.ID_ITEM)
	ORDER BY 2
