﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Vitek - 2019
-- Author: AA, DDR.
-- CREATE date: 11/05/2019
-- Description: get Customer samples
-- =============================================

CREATE PROCEDURE  [ADM].[SPE_GET_CUSTOMER_SAMPLES] 
	@PIN_ID_FORM AS INT = NULL,
	@PIN_ID_CUSTOMER_SAMPLE AS INT = NULL,
	@PIN_KY_CUSTOMER AS NVARCHAR(20) = NULL,
	@PIN_NO_LENGTH_SAMPLE AS INT = NULL,
	@PIN_KY_SAMPLE_UNIT AS NVARCHAR(10) = NULL
	
AS  
	SELECT CS.ID_CUSTOMER_SAMPLE,
		   CS.ID_FORM,
		   CS.KY_CUSTOMER,
		   CS.NO_LENGTH_SAMPLE,
		   CS.KY_SAMPLE_UNIT,
		   VSU.NM_SAMPLE_UNIT
	FROM ADM.C_CUSTOMER_SAMPLES CS
	JOIN ADM.VW_C_SAMPLE_UNIT VSU ON CS.KY_SAMPLE_UNIT = VSU.KY_SAMPLE_UNIT
	WHERE CS.ID_FORM = @PIN_ID_FORM AND
	(@PIN_ID_CUSTOMER_SAMPLE IS NULL OR (@PIN_ID_CUSTOMER_SAMPLE IS NOT NULL AND CS.ID_CUSTOMER_SAMPLE = @PIN_ID_CUSTOMER_SAMPLE)) AND
	(@PIN_KY_CUSTOMER IS NULL OR (@PIN_KY_CUSTOMER IS NOT NULL AND CS.KY_CUSTOMER = @PIN_KY_CUSTOMER)) AND
	(@PIN_NO_LENGTH_SAMPLE IS NULL OR (@PIN_NO_LENGTH_SAMPLE IS NOT NULL AND CS.NO_LENGTH_SAMPLE = @PIN_NO_LENGTH_SAMPLE)) AND
	(@PIN_KY_SAMPLE_UNIT IS NULL OR (@PIN_KY_SAMPLE_UNIT IS NOT NULL AND CS.KY_SAMPLE_UNIT = @PIN_KY_SAMPLE_UNIT))
	ORDER BY CS.KY_CUSTOMER

