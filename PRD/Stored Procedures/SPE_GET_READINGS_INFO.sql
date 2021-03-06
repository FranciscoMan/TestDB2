﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Daniel Davalos Romero
-- CREATE date: 24/08/2020
-- Description: Get general readings info from an
-- specific work order, it can can filter by Form type
-- =============================================

CREATE PROCEDURE  [PRD].[SPE_GET_READINGS_INFO]
	@PIN_BP INT = NULL,
	@PIN_IP VARCHAR(40) = NULL
AS   

SELECT
	-- ID Work Order
	--@PIN_ID_WORK_ORDER AS ID_WORK_ORDER,
	wo.ID_WORK_ORDER, 
	wo.DT_START_WORK_ORDER, 
	wo.DT_WORK_ORDER, 
	cpl.ID_BRANCH_PLANT,
	cpl.NM_PRODUCTION_LINE,
	-- ID FORM
	(
	SELECT TOP 1 ID_FORM 
	FROM PRD.C_FORM WHERE ID_FORM = 1
	) AS ID_FORM,
	-- KY_FORM
	(
	SELECT TOP 1 KY_FORM 
	FROM PRD.C_FORM WHERE ID_FORM = 1
	) AS KY_FORM,
	-- NM_FORM
	(
	SELECT TOP 1 NM_FORM 
	FROM PRD.C_FORM WHERE ID_FORM = 1 
	) AS NM_FORM,
	-- Numero de mediciones
	(
	SELECT COUNT(kfo.ID_WORK_ORDER) 
	FROM PRD.K_FORM kfo 
	WHERE ID_WORK_ORDER = wo.ID_WORK_ORDER AND  kfo.ID_FORM =1
		
	) AS NO_FORMS,
	-- Fecha ultima medicion
	(
	SELECT TOP 1 kfo.DT_CLOSED
	FROM PRD.K_FORM kfo
	WHERE 
		ID_WORK_ORDER = wo.ID_WORK_ORDER AND 
		KY_STATUS_FORM = 'CAPTURED' AND
		 kfo.ID_FORM = 1
	ORDER BY DT_CLOSED DESC
	) AS DT_LAST_READING,
	-- Last user in Last QA27
	(
	SELECT TOP 1 s.KY_USER
	FROM PRD.K_QA27 qa
	INNER JOIN PRD.K_SHIFT s ON qa.ID_SHIFT = s.ID_SHIFT
	WHERE qa.ID_WORK_ORDER = wo.ID_WORK_ORDER
	ORDER BY qa.DT_QA27 DESC
	)AS QA27_USER,
	-- DT_QA27
	(
	SELECT TOP 1 qa.DT_QA27
	FROM PRD.K_QA27 qa
	WHERE qa.ID_WORK_ORDER = wo.ID_WORK_ORDER
	ORDER BY qa.DT_QA27 DESC
	) AS DT_QA27,
	-- FG_EMAIL_SENDED
	--(
	--SELECT TOP 1 qa.FG_EMAIL_SENDED
	--FROM PRD.K_QA27 qa
	--WHERE qa.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
	--ORDER BY qa.DT_QA27 DESC
	--)
	


	CASE WHEN   DATEDIFF(MINUTE, GETDATE(), (SELECT TOP 1 s.DT_START_SHIFT
	FROM PRD.K_QA27 qa
	INNER JOIN PRD.K_SHIFT s ON qa.ID_SHIFT = s.ID_SHIFT
	WHERE qa.ID_WORK_ORDER = wo.ID_WORK_ORDER
	ORDER BY qa.DT_QA27 DESC )) > 360 AND EXISTS (
	SELECT TOP 1 kfo.DT_CLOSED
	FROM PRD.K_FORM kfo
	 INNER JOIN PRD.K_QA27 qa ON qa.ID_QA27 = kfo.ID_QA27
	WHERE 
		qa.ID_WORK_ORDER = wo.ID_WORK_ORDER AND 
		kfo.KY_STATUS_FORM = 'CAPTURED' AND
		 kfo.ID_FORM = 1
	ORDER BY DT_CLOSED DESC
	)
	

	 THEN 0 ELSE 1 END 


	AS FG_EMAIL_SENDED
FROM 
PRD.C_PRODUCTION_LINE_IP plip
INNER JOIN PRD.C_PRODUCTION_LINE cpl ON plip.ID_PRODUCTION_LINE = cpl.ID_PRODUCTION_LINE AND cpl.FG_ACTIVE = 1
INNER JOIN ADM.C_BRANCH_PLANT bp ON bp.ID_BRANCH_PLANT = cpl.ID_BRANCH_PLANT
INNER JOIN PRD.K_WORK_ORDER wo ON cpl.ID_PRODUCTION_LINE = wo.ID_PRODUCTION_LINE AND wo.KY_STATUS = 'RUNNING'
WHERE plip.NO_IP= @PIN_IP AND cpl.ID_BRANCH_PLANT = @PIN_BP
