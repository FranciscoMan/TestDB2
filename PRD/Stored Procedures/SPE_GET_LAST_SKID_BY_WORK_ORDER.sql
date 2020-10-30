﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 12/19/2018
-- Description: Get last pallet by work order number
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_LAST_SKID_BY_WORK_ORDER]
	@PIN_ID_WORK_ORDER INT

AS   

	SELECT TOP 1 KWO.ID_WORK_ORDER
		, KWO.ID_PRODUCTION_LINE
		, KP.NO_PALLET
		, KP.ID_QA27
		, CASE 
			WHEN KF.KY_STATUS_FORM = 'CAPTURED' THEN CAST(0 AS BIT)
			WHEN KF.KY_STATUS_FORM = 'CANCELLED' AND KF.KY_USER_AUTHORIZED_CANCEL != 'System' THEN CAST(0 AS BIT) 
		ELSE CAST(1 AS BIT) END AS FG_READING_PENDING
		, ISNULL(KF.KY_STATUS_FORM, 'NOT_CREATED') AS KY_STATUS_FORM
		, KF.KY_USER_AUTHORIZED_CANCEL
	FROM PRD.K_WORK_ORDER KWO
		LEFT JOIN PRD.K_PALLET KP
			ON KWO.ID_WORK_ORDER = KP.ID_WORK_ORDER AND KP.KY_STATUS = 'WORKING' 
		LEFT JOIN PRD.K_FORM KF
			ON KP.ID_PALLET = KF.ID_PALLET
			AND KF.KY_PROCESS_TYPE = 'MANUFACTURE'
			AND ISNULL(KF.KY_USER_AUTHORIZED_CANCEL, '') != 'System'
	WHERE KP.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
	ORDER BY KP.NO_PALLET DESC, KF.DT_FORM DESC

