﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CREATE date: 12/05/2018
-- Description: get all Readings from pallet
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_READINGS_FROM_SAMPLES] 
	@PIN_ID_WORK_ORDER INT = NULL,
	@PIN_ID_PALLET INT = NULL,
	@PIN_ID_K_FORM INT = NULL
AS   

DECLARE @ID_PRODUCTION_LINE INT
	, @ID_ITEM INT

IF NOT EXISTS (
	SELECT KR.ID_K_READING
		, KR.KY_STATUS
		, KMR.ID_K_METRICS_READINGS
		, KMR.ID_METRICS
		, KMR.NO_VALUE
		, KMR.KY_STATUS_READING
		, KR.ID_K_FORM
	FROM PRD.K_READINGS KR 
		INNER JOIN PRD.K_METRICS_READINGS KMR 
			ON KMR.ID_K_READING = KR.ID_K_READING
	WHERE KMR.KY_STATUS_READING ='ACCEPTED' 
		AND KR.ID_WORK_ORDER = @PIN_ID_WORK_ORDER 
		AND (@PIN_ID_K_FORM IS NULL OR (@PIN_ID_K_FORM IS NOT NULL AND KR.ID_K_FORM = @PIN_ID_K_FORM)) 
		--AND (@PIN_ID_PALLET IS NULL OR (@PIN_ID_PALLET IS NOT NULL AND KR.ID_PALLET = @PIN_ID_PALLET AND KR.ID_K_FORM IS NULL))
		AND (@PIN_ID_PALLET IS NULL OR (@PIN_ID_PALLET IS NOT NULL AND KR.ID_INSPECTION_SKID = @PIN_ID_PALLET AND KR.ID_K_FORM IS NULL))
) BEGIN

	SELECT TOP 1 @ID_PRODUCTION_LINE = KWO.ID_PRODUCTION_LINE
		, @ID_ITEM = KWO.ID_ITEM
	FROM PRD.K_WORK_ORDER KWO
	WHERE KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
	
	EXEC [PRD].[SPE_INSERT_UPDATE_K_READINGS] 
		@ID_WORK_ORDER = @PIN_ID_WORK_ORDER
		,@ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
		,@ID_ITEM = @ID_ITEM
		,@ID_PALLET = NULL --@PIN_ID_PALLET
		,@ID_INSPECTION_SKID = @PIN_ID_PALLET
		,@ID_K_FORM = @PIN_ID_K_FORM
		,@XML_READINGS = NULL
		,@KY_STATUS = 'ACCEPTED'
		,@FG_PROTABLE = 0
		,@FG_MICROMETER	= 0
		,@FG_GLOSS = 0
		,@FG_LIGHT_TRANSMISSION = 0
		,@PIN_KY_USER_APP = 'ND'
		,@PIN_NM_PROGRAM = 'GET READINGS STORE PROCEDURE'
		,@PIN_TYPE_TRANSACTION = 'I'
END

	SELECT KR.ID_K_READING
		, KR.KY_STATUS
		, KMR.ID_K_METRICS_READINGS
		, KMR.ID_METRICS
		, KMR.NO_VALUE
		, KMR.KY_STATUS_READING
		, KR.ID_K_FORM
	FROM PRD.K_READINGS KR 
		INNER JOIN PRD.K_METRICS_READINGS KMR 
			ON KMR.ID_K_READING = KR.ID_K_READING
	WHERE KMR.KY_STATUS_READING ='ACCEPTED' 
		AND KR.ID_WORK_ORDER = @PIN_ID_WORK_ORDER 
		AND (@PIN_ID_K_FORM IS NULL OR (@PIN_ID_K_FORM IS NOT NULL AND KR.ID_K_FORM = @PIN_ID_K_FORM)) 
		--AND (@PIN_ID_PALLET IS NULL OR (@PIN_ID_PALLET IS NOT NULL AND KR.ID_PALLET = @PIN_ID_PALLET AND KR.ID_K_FORM IS NULL))
		AND (@PIN_ID_PALLET IS NULL OR (@PIN_ID_PALLET IS NOT NULL AND KR.ID_INSPECTION_SKID = @PIN_ID_PALLET AND KR.ID_K_FORM IS NULL))
