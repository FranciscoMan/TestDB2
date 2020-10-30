﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 14/03/2017
-- Description: get all C_ITEM
-- =============================================
-- 13/12/2017 JDR XML parameter added to return all items within the xml structure
-- 09/27/2018 JDR FG_ACTIVE column was added
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_ITEMS] 
	@PIN_ID_ITEM AS int = NULL
	, @PIN_KY_ITEM AS nvarchar(50) = NULL
	, @PIN_NM_ITEM AS nvarchar(300) = NULL
	, @PIN_DS_ITEM AS nvarchar(500) = NULL
	, @PIN_FG_ACTIVE AS bit = NULL
	, @PIN_XML_ITEMS AS XML = NULL

AS   

	DECLARE @T_ITEMS TABLE (
		ID_ITEM INT
	)

	IF @PIN_XML_ITEMS IS NOT NULL BEGIN
		INSERT INTO @T_ITEMS (ID_ITEM) SELECT x.value('@ID_ITEM', 'INT') FROM @PIN_XML_ITEMS.nodes('/ITEMS/ITEM') T(x)
	END

	SELECT CI.ID_ITEM
		, CI.KY_ITEM
		, CI.NM_ITEM
		, CI.DS_ITEM
		, CI.NO_POUNDS_PER_ITEM
		, CI.KY_UPC
		, CI.DS_NOTES_JDEDWARDS
		, CASE CI.FG_ACTIVE WHEN 1 THEN 'Yes' ELSE 'No' END AS KY_ACTIVE
		, CI.FG_ACTIVE
		, ISNULL(CI.NO_PIECES_PER_SKID, 0) AS NO_PIECES_PER_SKID
		, CI.FG_FILM_TRACK
	FROM PRD.C_ITEM CI
	WHERE (@PIN_ID_ITEM IS NULL OR (@PIN_ID_ITEM IS NOT NULL AND CI.ID_ITEM = @PIN_ID_ITEM )) AND 
		(@PIN_KY_ITEM IS NULL OR (@PIN_KY_ITEM IS NOT NULL AND CI.KY_ITEM = @PIN_KY_ITEM )) AND 
		(@PIN_NM_ITEM IS NULL OR (@PIN_NM_ITEM IS NOT NULL AND CI.NM_ITEM = @PIN_NM_ITEM )) AND 
		(@PIN_DS_ITEM IS NULL OR (@PIN_DS_ITEM IS NOT NULL AND CI.DS_ITEM = @PIN_DS_ITEM )) AND 
		(@PIN_FG_ACTIVE IS NULL OR (@PIN_FG_ACTIVE IS NOT NULL AND CI.FG_ACTIVE = @PIN_FG_ACTIVE)) AND
		(@PIN_XML_ITEMS IS NULL OR (@PIN_XML_ITEMS IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM @T_ITEMS TI WHERE TI.ID_ITEM = CI.ID_ITEM)))
	ORDER BY CI.KY_ITEM ASC

