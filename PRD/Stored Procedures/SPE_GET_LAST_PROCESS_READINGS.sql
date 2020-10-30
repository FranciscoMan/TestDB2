-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Díaz
-- CREATE date: 01/30/2019
-- Description: Get last 'n' SOC readings
-- =============================================
-- 02/07/2020: Changes in get last readings. Now you can search by individual id_k_form.  by AA
-- =============================================
-- 07/22/2020 : Changes in get last readings. Now you can search a lot of k_forms no matter what Work Order has... 
CREATE PROCEDURE [PRD].[SPE_GET_LAST_PROCESS_READINGS]
	 -- @PIN_ID_K_FORM INT,
	  @PIN_XML_K_FORMS AS XML = NULL -- A ver si funciona esta wea :v
AS   
BEGIN		
	; WITH T_LAST_FORMS AS (
		SELECT  
		      KF.ID_K_FORM
			, KF.DT_FORM
			, KF.DT_CLOSED
			, KF.KY_PROCESS_TYPE
			, KF.ID_PRODUCTION_LINE
			, KF.KY_STATUS_FORM
			, KF.ID_PALLET
			, KF.ID_FORM
			, CI.KY_ITEM
			, KF.KY_USER_APP_UPDATE
			, KF.ID_WORK_ORDER
		FROM PRD.K_FORM KF
			INNER JOIN PRD.K_WORK_ORDER KWO
				ON KF.ID_WORK_ORDER = KWO.ID_WORK_ORDER
			INNER JOIN PRD.C_ITEM CI
				ON KWO.ID_ITEM = CI.ID_ITEM
			
		WHERE  KF.KY_PROCESS_TYPE = 'PROCESS'
			AND KF.KY_STATUS_FORM = 'CAPTURED'
			AND KF.ID_K_FORM IN (SELECT  x.ref.value('@ID_K_FORM', 'INT') ID_METRIC FROM @PIN_XML_K_FORMS.nodes('/FORMS/FORM') x(ref))
	)
	SELECT KLF.ID_K_FORM
		, CM.ID_METRICS
		, CM.NM_METRICS
		, KFM.XML_METRICS_VALUE
		, CM.XML_FIELD_SETTINGS
		, KFM.XML_METRICS_VALUE.value('(FIELD_TYPES/@FINISHED_VALUE)[1]', 'varchar(80)') AS FINISHED_VALUE
		, KFM.XML_METRICS_VALUE.value('(FIELD_TYPES/@CATALOG_VALUE)[1]', 'varchar(80)') AS CATALOG_VALUE
		, KFM.XML_METRICS_VALUE.value('(FIELD_TYPES/@DS_CATALOG_VALUE)[1]', 'varchar(80)') AS DS_CATALOG_VALUE
		, KLF.DT_FORM
		, KLF.DT_CLOSED
		, KP.NO_PALLET
		, KLF.KY_PROCESS_TYPE
		, CM.NO_ORDER
		, KLF.KY_ITEM
		, KLF.KY_USER_APP_UPDATE
		, KLF.ID_WORK_ORDER
	FROM T_LAST_FORMS KLF
		INNER JOIN PRD.K_FORM_METRICS KFM
			ON KLF.ID_K_FORM = KFM.ID_K_FORM
		INNER JOIN PRD.C_METRICS CM
			ON CM.ID_METRICS = KFM.ID_METRICS
		LEFT JOIN PRD.C_FORM_METRICS CFM
			ON CFM.ID_METRICS = CM.ID_METRICS
			AND CFM.ID_FORM = KLF.ID_FORM
		LEFT JOIN PRD.K_PALLET KP
			ON KLF.ID_PALLET = KP.ID_PALLET
	
	ORDER BY KLF.DT_FORM, CM.NO_ORDER DESC

END
