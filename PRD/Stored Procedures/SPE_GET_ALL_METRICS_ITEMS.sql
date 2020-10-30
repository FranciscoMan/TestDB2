﻿-- =============================================
-- Author:		Gabriel Vázquez Torres
-- Create date: 25/07/2018
-- Description:	Get the information from all metrics of all items
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_ALL_METRICS_ITEMS]
	-- Add the parameters for the stored procedure here
	@PIN_ID_ITEM AS INT = NULL,
	@PIN_ID_METRIC AS INT = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	;WITH T_ITEM_METRICS AS (
		SELECT 
			CI.ID_ITEM,
			CIC.ID_METRICS,
			CI.KY_ITEM, 
			CM.NM_METRICS, 
			CM.KY_FIELD_TYPE, 
			CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@CATALOG_VALUE)[1]','NVARCHAR(50)') AS NM_UNIT, 
			CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@NOMINAL_VALUE)[1]','NVARCHAR(50)') AS NO_NOMINAL_VALUE, 
			CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@UPPER_LIMIT)[1]','NVARCHAR(50)') AS NO_UPPER_LIMIT, 
			CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@LOWER_LIMIT)[1]','NVARCHAR(50)') AS NO_LOWER_LIMIT, 
			CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@HYSTERESIS)[1]','NVARCHAR(50)') AS KY_HYSTERESIS, 
			CIC.XML_FIELD_SETTINGS.value('(/SETTINGS/FIELD_TYPES/@CATALOG)[1]','INT') AS ID_CATALOG_LIST
		FROM PRD.C_ITEM CI
			INNER JOIN PRD.C_ITEM_CHARACTERISTIC CIC ON CI.ID_ITEM = CIC.ID_ITEM
			INNER JOIN PRD.C_METRICS CM ON CIC.ID_METRICS = CM.ID_METRICS
	)

	SELECT  
			TIM.ID_ITEM,
			TIM.ID_METRICS,
			TIM.KY_ITEM, 
			TIM.NM_METRICS, 
			TIM.KY_FIELD_TYPE, 
			TIM.NM_UNIT, 
			TIM.NO_NOMINAL_VALUE, 
			TIM.NO_UPPER_LIMIT, 
			TIM.NO_LOWER_LIMIT, 
			TIM.KY_HYSTERESIS, 
			TIM.ID_CATALOG_LIST,
			CLC.NM_LIST_CATALOG,
			CFT.NM_FIELD_TYPE,
			NM_HYSTERESIS_TYPE
	FROM T_ITEM_METRICS TIM
		LEFT JOIN ADM.C_LIST_CATALOG CLC ON TIM.ID_CATALOG_LIST = CLC.ID_LIST_CATALOG
		LEFT JOIN ADM.VW_C_FIELD_TYPE CFT ON TIM.KY_FIELD_TYPE = CFT.KY_FIELD_TYPE
		LEFT JOIN ADM.VW_C_HYSTERESIS_TYPE CHT ON TIM.KY_HYSTERESIS = CHT.KY_HYSTERESIS_TYPE
	WHERE
		(@PIN_ID_ITEM IS NULL OR (@PIN_ID_ITEM IS NOT NULL AND TIM.ID_ITEM = @PIN_ID_ITEM)) AND
		(@PIN_ID_METRIC IS NULL OR (@PIN_ID_METRIC IS NOT NULL AND TIM.ID_METRICS = @PIN_ID_METRIC))
	ORDER BY KY_ITEM

END

