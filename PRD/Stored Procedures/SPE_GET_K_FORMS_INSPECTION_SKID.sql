﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 27/05/2018
-- Description: get form saved by wo,form,id_production_line,idkform to QUALITY form
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_K_FORMS_INSPECTION_SKID]
	  @ID_WORK_ORDER INT = NULL 
	, @ID_FORM INT = NULL 
	, @ID_PRODUCTION_LINE INT = NULL 
	, @ID_K_FORM INT = NULL 
	, @KY_PROCESS NVARCHAR(50) = NULL
AS

	DECLARE @DT_LAST_FORM DATETIME = NULL

	SET @DT_LAST_FORM = (SELECT TOP 1 DT_FORM FROM PRD.K_FORM KF WHERE ID_WORK_ORDER = @ID_WORK_ORDER AND KF.KY_PROCESS_TYPE = @KY_PROCESS AND DT_CLOSED IS NOT NULL ORDER BY DT_FORM DESC)


	SELECT CF.KY_FORM
		, CF.NM_FORM
		, CF.NO_FREQUENCE
		, DA.NM_DATA_ACQUISITION_ORIGIN	
		, ISNULL(KF.KY_STATUS_FORM,'NOT_SAVED') KY_STATUS_K_FORM
		, VCP.NM_PROCESS
		, KF.DT_FORM
		, KF.DT_CLOSED
		, KF.ID_BRANCH_PLANT
		, WO.NO_WORK_ORDER
		, KF.ID_K_FORM	
		, CF.ID_FORM
		, KIS.NO_PALLET
		, WO.NM_PRODUCTION_LINE
		, WO.NM_ITEM
		, WO.ID_ITEM
		, CI.KY_ITEM
		, WO.NO_LENGHT
		, WO.NO_WIDTH
		, CS.KY_CUSTOMER
		, @DT_LAST_FORM AS DT_LAST_FORM
		--, CS.NO_LENGTH_SAMPLE AS NO_LENGTH_SAMPLE_CUSTOMER
		--, VUSC.KY_SAMPLE_UNIT AS KY_SAMPLE_UNIT_CUSTOMER
		--, VUSC.NM_SAMPLE_UNIT AS NM_SAMPLE_UNIT_CUSTOMER
		, CF.KY_PROCESS
		, WO.ID_WORK_ORDER_ORIGIN
		, CASE WHEN CS.KY_CUSTOMER IS NOT NULL	
					THEN 
						CS.NO_LENGTH_SAMPLE
					ELSE 
						ISNULL(CF.NO_SAMPLE,0)
			    END AS NO_SAMPLE
		, CASE WHEN CS.KY_CUSTOMER IS NOT NULL	
					THEN 
						VUSC.NM_SAMPLE_UNIT
					ELSE
						ISNULL(VUS.NM_SAMPLE_UNIT, 'Pcs')
			    END AS NM_SAMPLE_UNIT
	FROM PRD.K_WORK_ORDER WO
		INNER JOIN PRD.C_ITEM CI  ON WO.ID_ITEM = CI.ID_ITEM
		INNER JOIN PRD.K_FORM KF ON KF.ID_WORK_ORDER = WO.ID_WORK_ORDER --OR (KF.ID_PRODUCTION_LINE = WO.ID_PRODUCTION_LINE AND KF.KY_PROCESS_TYPE = 'PROCESS')
		INNER JOIN PRD.C_FORM CF ON CF.ID_FORM = KF.ID_FORM		
		INNER JOIN ADM.VW_C_SAMPLE_UNIT VUS ON CF.KY_SAMPLE_UNIT = VUS.KY_SAMPLE_UNIT
		INNER JOIN ADM.VW_C_PROCESS VCP ON VCP.KY_PROCESS = CF.KY_PROCESS
		INNER JOIN ADM.VW_C_DATA_ACQUISITION_ORIGIN DA ON DA.ID_DATA_ACQUISITION_ORIGIN = CF.ID_DATA_ACQUISITION_ORIGIN
		--LEFT JOIN PRD.K_PALLET KP ON KF.ID_PALLET = KP.ID_PALLET
		LEFT JOIN PRD.K_INSPECTION_SKID KIS ON KF.ID_INSPECTION_SKID = KIS.ID_INSPECTION_SKID
		LEFT JOIN ADM.C_CUSTOMER_SAMPLES CS ON CF.ID_FORM = CS.ID_FORM
		LEFT JOIN ADM.VW_C_SAMPLE_UNIT VUSC ON CS.KY_SAMPLE_UNIT = VUSC.KY_SAMPLE_UNIT
	WHERE KF.KY_STATUS_FORM NOT IN ('CANCELLED') AND
		(@ID_WORK_ORDER IS NULL OR (@ID_WORK_ORDER IS NOT NULL AND WO.ID_WORK_ORDER = @ID_WORK_ORDER)) AND
		(@ID_K_FORM IS NULL OR (@ID_K_FORM IS NOT NULL AND KF.ID_K_FORM = @ID_K_FORM))

