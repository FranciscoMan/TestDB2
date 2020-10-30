﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 4/04/2017
-- Description: get WORKS ORDERS
-- =============================================
-- 26/12/2017 JDR Filter by ID_PRODUCTION_LINE added
-- 11/03/2018 JDR Last captured form date & time column added
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDERS] 
	@PIN_ID_BRANCH_PLANT AS int = NULL,
	@PIN_ID_WORK_ORDER AS int = NULL,
	@PIN_KY_STATUS AS nvarchar(50) = NULL,
	@PIN_KY_CUSTOMER AS nvarchar(50)= NULL,
	@PIN_NM_CUSTOMER AS nvarchar(200)= NULL,
	@PIN_NO_WORK_ORDER AS int NULL,
	@PIN_NO_ASSIGNED_TIME AS INT = NULL,
	@PIN_ID_ITEM AS int =NULL,
	@PIN_NM_ITEM AS nvarchar(200)= NULL,
	@PIN_ID_PRODUCTION_LINE AS int = NULL,
	@PIN_NM_PRODUCTION_LINE AS nvarchar(200)= NULL,
	@PIN_DT_WORK_ORDER AS datetime = NULL,
	@PIN_NO_RUN_QTY AS int = NULL,
	@PIN_NO_BOX_QTY AS int = NULL,
	@PIN_NM_MATERIAL AS nvarchar(200) = NULL,
	@PIN_NM_COLOR AS nvarchar(100) = NULL,
	@PIN_NO_LENGHT AS float = NULL,
	@PIN_NO_WIDTH AS float = NULL,
	@PIN_NO_THICKNESS AS float = NULL
AS  
BEGIN
	DECLARE @DT_LAST_FORM DATETIME,
		    @V_NO_LENGTH_SAMPLE_QUALITY_FORM AS INT,
		    @V_NM_SAMPLE_UNIT_QUALITY_FORM AS NVARCHAR(20),
		    @V_KY_SAMPLE_UNIT_QUALITY_FORM AS NVARCHAR(20)


	SELECT TOP 1
		@V_NO_LENGTH_SAMPLE_QUALITY_FORM = CF.NO_SAMPLE,
		@V_NM_SAMPLE_UNIT_QUALITY_FORM = VUS.NM_SAMPLE_UNIT,
		@V_KY_SAMPLE_UNIT_QUALITY_FORM = VUS.KY_SAMPLE_UNIT
	FROM PRD.C_FORM CF
		JOIN ADM.VW_C_SAMPLE_UNIT VUS 
			ON CF.KY_SAMPLE_UNIT = VUS.KY_SAMPLE_UNIT
	WHERE CF.KY_PROCESS = 'QUALITY'

	IF @PIN_ID_WORK_ORDER IS NOT NULL BEGIN
		SET @DT_LAST_FORM = (SELECT TOP 1 DT_FORM FROM PRD.K_FORM KF WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER AND DT_CLOSED IS NOT NULL)
	END

	SELECT KWO.ID_WORK_ORDER, 
		KWO.KY_CUSTOMER
		, KWO.NM_CUSTOMER
		, KWO.NO_WORK_ORDER
		, KWO.NO_ASSIGNED_TIME
		, KWO.NO_ASSIGNED_TIME_HRS
		, KWO.ID_ITEM
		, CI.KY_ITEM
		, KWO.NM_ITEM
		, KWO.ID_BRANCH_PLANT
		, CBP.NM_BRANCH_PLANT
		, KWO.ID_PRODUCTION_LINE
		, CPL.KY_PRODUCTION_LINE
		, KWO.NM_PRODUCTION_LINE
		, KWO.DT_WORK_ORDER
		, KWO.DT_START_WORK_ORDER
		, KWO.NO_RUN_QTY
		, KWO.NO_BOX_QTY
		, KWO.NM_MATERIAL
		, KWO.NM_COLOR
		, KWO.NO_LENGHT
		, KWO.NO_WIDTH
		, KWO.NO_THICKNESS
		, KWO.NO_POUNDS
		, KWO.KY_PACKAGE
		, KWO.PACKED
		, KWO.DT_REQ_DATE
		, KWO.NO_ORDER
		, KWO.NO_SEQ
		, KWO.NO_HRS_LABOR_MACHINE
		, KWO.NO_QTY_SKID
		, KWO.DT_ORDER
		, KWO.NO_SHIPING_WEIGHT_PER_HR
		, KWO.KY_UPC
		, KWO.KY_STATUS
		, KWO.ID_WORK_ORDER_ORIGIN
		, KWO.ID_PALLET
		, KWO.DT_CLOSE_WORK_ORDER
		, @DT_LAST_FORM AS DT_LAST_FORM
		, CASE WHEN CUSTOMER.KY_CUSTOMER IS NOT NULL	
					THEN 
						CUSTOMER.NO_LENGTH_SAMPLE_CUSTOMER
					ELSE 
						ISNULL(@V_NO_LENGTH_SAMPLE_QUALITY_FORM,0)
			    END
					AS NO_SAMPLE
		, CASE WHEN CUSTOMER.KY_CUSTOMER IS NOT NULL	
					THEN 
						CUSTOMER.NM_SAMPLE_UNIT_CUSTOMER
					ELSE
						ISNULL(@V_NM_SAMPLE_UNIT_QUALITY_FORM, 'Pcs')
			    END AS NM_SAMPLE_UNIT
		,WOS.NM_WORK_ORDER_STATUS
	FROM PRD.K_WORK_ORDER KWO
		INNER JOIN ADM.VW_C_WORK_ORDER_STATUS WOS 
			ON KY_STATUS = WOS.KY_WORK_ORDER_STATUS
			AND KWO.KY_STATUS != 'COMPLETE'
	--JOIN PRD.K_QA27 KQA ON KWO.ID_WORK_ORDER = KQA.ID_WORK_ORDER
		INNER JOIN ADM.C_BRANCH_PLANT CBP 
			ON KWO.ID_BRANCH_PLANT = CBP.ID_BRANCH_PLANT
		LEFT JOIN PRD.C_ITEM CI 
			ON KWO.ID_ITEM = CI.ID_ITEM
		LEFT JOIN PRD.C_PRODUCTION_LINE CPL 
			ON KWO.ID_PRODUCTION_LINE = CPL.ID_PRODUCTION_LINE
		LEFT JOIN (SELECT 
							   CS.KY_CUSTOMER,
							   CS.NO_LENGTH_SAMPLE AS NO_LENGTH_SAMPLE_CUSTOMER,
							   VUSC.KY_SAMPLE_UNIT AS KY_SAMPLE_UNIT_CUSTOMER,
							   VUSC.NM_SAMPLE_UNIT AS NM_SAMPLE_UNIT_CUSTOMER,
							   CF.KY_PROCESS
						  FROM (SELECT TOP 1 * 
								  FROM PRD.C_FORM C
								 WHERE C.KY_PROCESS = 'QUALITY'
						      ) CF
						  JOIN ADM.VW_C_SAMPLE_UNIT VUS ON CF.KY_SAMPLE_UNIT = VUS.KY_SAMPLE_UNIT
					 LEFT JOIN ADM.C_CUSTOMER_SAMPLES CS ON CF.ID_FORM = CS.ID_FORM
					 LEFT JOIN ADM.VW_C_SAMPLE_UNIT VUSC ON CS.KY_SAMPLE_UNIT = VUSC.KY_SAMPLE_UNIT
					) CUSTOMER ON KWO.KY_CUSTOMER = CUSTOMER.KY_CUSTOMER

	WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR CBP.ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND CBP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT )) AND 
	(@PIN_ID_WORK_ORDER IS NULL OR (@PIN_ID_WORK_ORDER IS NOT NULL AND KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER)) AND
	(@PIN_NO_WORK_ORDER IS NULL OR (@PIN_NO_WORK_ORDER IS NOT NULL AND KWO.NO_WORK_ORDER = @PIN_NO_WORK_ORDER)) AND
	(@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND CPL.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE)) AND
	(@PIN_KY_STATUS IS NULL OR (@PIN_KY_STATUS IS NOT NULL AND KWO.KY_STATUS = @PIN_KY_STATUS ))
			
	ORDER BY DT_WORK_ORDER ASC
END

