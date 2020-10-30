﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Aideé Alvarez.
-- CREATE date: 02/06/2020
-- Description: GET 10 WORK ORDERS WITH THEIR DATA TO USE LAST_READINGS SPE.
-- =============================================

CREATE PROCEDURE [PRD].[SPE_GET_10_WORK_ORDERS]
	@PIN_ID_ITEM AS INT = NULL
AS
BEGIN
-- SE DECLARA UNA VARIABLE DE TABLA PARA BÚSQUEDAS RÁPIDAS.
		 DECLARE @AUX_1 TABLE (WO INT, ITEM INT, PROD_LINE INT)
		--DECLARE @PIN_ID_ITEM INT = 16912
	-- SE OBTIENE EL TOP 10 DE LAS WORK ORDER QUE TIENEN EL MISMO ID_ITEM ORDENADOS DE MANERA DESCENDENTE.
	INSERT INTO @AUX_1	SELECT TOP 10 ID_WORK_ORDER, ID_ITEM,ID_PRODUCTION_LINE FROM PRD.K_WORK_ORDER WHERE ID_ITEM = @PIN_ID_ITEM
	                    ORDER BY ID_WORK_ORDER DESC
	 -- SELECT * FROM @AUX_1 ORDER BY WO ASC -- SELECT DE PRUEBA
SELECT DISTINCT
  TMP.WO, I.KY_ITEM AS ITEM,
  LAST_VALUE(KF.DT_CREATION) 
	OVER (PARTITION BY KF.DT_CREATION ORDER BY KF.DT_CREATION DESC) AS DT_CREATION
	, KF.ID_K_FORM, QA.NM_LEADMAN
FROM PRD.K_FORM KF
INNER JOIN @AUX_1 TMP  ON KF.ID_WORK_ORDER = TMP.WO
INNER JOIN PRD.C_ITEM  I ON  I.ID_ITEM = TMP.ITEM 
INNER JOIN PRD.K_QA27 QA ON QA.ID_QA27 = KF.ID_QA27
WHERE TMP.WO IN (SELECT WO FROM @AUX_1) AND KF.ID_FORM = 3 AND KF.KY_STATUS_FORM = 'CAPTURED' --AND QA.NM_LEADMAN IS NOT NULL
ORDER BY TMP.WO DESC

END

