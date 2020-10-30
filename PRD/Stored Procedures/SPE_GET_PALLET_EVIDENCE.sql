-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CREATE date: 31/05/2017
-- Description: get all evidence of pallet

-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_PALLET_EVIDENCE] 
	    @NO_WORK_ORDER INT	    
AS   

	SELECT 
	  KP.NM_QUALITY_INSPECTOR_AGREEMENT
	, KP.NO_PALLET
	, UPPER(FS.name) FILE_NAME
	, UPPER(FS.file_type) FILE_TYPE
	, FS.file_stream [FILE]
	FROM PRD.K_WORK_ORDER WO 
	INNER JOIN PRD.K_PALLET KP ON KP.ID_WORK_ORDER = WO.ID_WORK_ORDER
	INNER JOIN PRD.K_PALLET_EVIDENCE KPE ON KPE.ID_PALLET = KP.ID_PALLET
	INNER JOIN ADM.FS_FILE_SYSTEM FS ON KPE.ID_FILE = FS.stream_id
	WHERE WO.NO_WORK_ORDER=@NO_WORK_ORDER

