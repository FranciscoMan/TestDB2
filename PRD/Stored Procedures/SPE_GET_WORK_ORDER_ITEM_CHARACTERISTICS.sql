﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CREATE date: 02/07/2018
-- Description: get all characteristics for work order item
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_ITEM_CHARACTERISTICS] 
	@PIN_ID_ITEM INT = NULL,
	@PIN_ID_METRICS INT = NULL,
	@PIN_ID_WORK_ORDER INT = NULL

AS   

	DECLARE @XML_CONFIGURATION XML = (SELECT TOP 1 XML_CONFIGURATION FROM ADM.S_CONFIGURATION),
			@NO_ALPHA NUMERIC(36,2),
			@NO_HYPOTHESIZED_MEAN_DIFFERENCE NUMERIC(36,2),
			@NO_SAMPLES INT

	SELECT @XML_CONFIGURATION = XML_CONFIGURATION FROM ADM.S_CONFIGURATION;

	SELECT @NO_ALPHA = d.value('@NO_ALPHA', 'NUMERIC(36,2)')
		 , @NO_HYPOTHESIZED_MEAN_DIFFERENCE = d.value('@NO_HYPOTHESIZED_MEAN_DIFFERENCE', 'NUMERIC(36,2)')
		 , @NO_SAMPLES = d.value('@NO_SAMPLES', 'INT')
	FROM @XML_CONFIGURATION.nodes('CONFIGURATIONS/TEST_T/SET_UP') AS T(d)


	SELECT  IC.[ID_ITEM_CHARACTERISTIC]
		  , NEWID() AS ID_ASSISTANT
		  , IC.[ID_ITEM]
		  , I.[KY_ITEM]
		  , I.[NM_ITEM]
		  , I.[DS_ITEM]
		  , IC.[ID_METRICS]
		  , M.[KY_METRICS]
		  , M.[NM_METRICS]
		  , M.[KY_FIELD_TYPE]
		  , M.[FG_ENABLED]
		  , CASE WHEN M.[FG_ENABLED] =1 THEN 'Yes' ELSE 'No' END KY_ENABLED
		  , M.[FG_REQUIRED]
		  , CASE WHEN M.[FG_REQUIRED] =1 THEN 'Yes' ELSE 'No' END KY_REQUIRED
		  , M.[DS_TOOLTIP]
		  , IC.[XML_FIELD_SETTINGS]
		 -- , CASE PRD.F_GET_TEST_T (@NO_ALPHA, @NO_HYPOTHESIZED_MEAN_DIFFERENCE, @NO_SAMPLES, @PIN_ID_WORK_ORDER, IC.ID_METRICS)
			--	WHEN 1 THEN 'YES'
			--	WHEN 0 THEN 'NO'
			--	WHEN -1 THEN 'ND'
			--	ELSE 'NA'
			--END AS KY_T_TEST_RESULT
		  , 'NA' AS KY_T_TEST_RESULT
	FROM [PRD].[C_ITEM_CHARACTERISTIC] IC
		LEFT OUTER JOIN PRD.C_ITEM I ON I.ID_ITEM = IC.ID_ITEM
		LEFT OUTER JOIN PRD.C_METRICS M ON M.ID_METRICS = IC.ID_METRICS
	WHERE 
		(@PIN_ID_ITEM IS NULL OR (@PIN_ID_ITEM IS NOT NULL AND IC.[ID_ITEM] = @PIN_ID_ITEM)) AND
		(@PIN_ID_METRICS IS NULL OR (@PIN_ID_METRICS IS NOT NULL AND IC.ID_METRICS = @PIN_ID_METRICS))

