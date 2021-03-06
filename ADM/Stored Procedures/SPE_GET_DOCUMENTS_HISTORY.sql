﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 01/02/2018
-- Description: get Document management hierarchy
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_DOCUMENTS_HISTORY] 
AS

	; WITH T_DOCUMENT_HISTORY AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY ID_DOCUMENT ORDER BY ID_DOCUMENT ASC, DT_SENDED DESC) AS NO_ROW
			, ID_DOCUMENT
			, DT_SENDED
		FROM PRD.K_DOCUMENT_HISTORY KDH
		WHERE EXISTS (SELECT TOP 1 1 FROM ADM.FS_DOCUMENT_MANAGEMENT FDM WHERE KDH.ID_DOCUMENT = FDM.stream_id)
	)

	SELECT FDM.stream_id AS ID_STREAM
		, FDM.name AS NM_FILE
		, TDH.DT_SENDED AS DT_LAST_SENT
		, CAST(TDH.DT_SENDED AS DATE) AS DT_LAST_SENT_DATE
		, CAST(TDH.DT_SENDED AS TIME) AS DT_LAST_SENT_TIME
	FROM ADM.FS_DOCUMENT_MANAGEMENT FDM
		LEFT JOIN T_DOCUMENT_HISTORY TDH
			ON FDM.stream_id = TDH.ID_DOCUMENT
			AND TDH.NO_ROW = 1
	WHERE FDM.is_directory = 0
	ORDER BY NM_FILE

