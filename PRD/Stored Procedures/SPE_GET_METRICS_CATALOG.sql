﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CREATE date: 21/03/2017
-- Description: get the metrics catalog
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_METRICS_CATALOG] 
	    @ID_METRICS INT = NULL

AS   
	BEGIN

		DECLARE 
			@XML_BRANCHPLANTS XML,
			@XML_LIST_CATALOG XML,
			@XML_VALUE_CATALOG XML,
			@XML_FIELD_TYPE XML,
			@XML_HYSTERESIS XML	,
			@XML_UNITS XML,
			@KY_METRICS NVARCHAR(50),
			@NM_METRICS NVARCHAR(100),
			@KY_FIELD_TYPE NVARCHAR(10),
			@FG_ENABLED BIT,
			@FG_REQUIRED BIT,
			@DS_TOOLTIP NVARCHAR(1000),
			@ID_BRANCH_PLANT INT,
			@XML_FIELD_SETTINGS XML	,
			@ID_UNITS_CATALOG INT,
			@NO_ORDER INT
	
	
		SET @XML_BRANCHPLANTS = (SELECT 	    
			BP.ID_BRANCH_PLANT  AS "@ID_BRANCH_PLANT",
			BP.KY_BRANCH_PLANT  AS "@KY_BRANCH_PLANT",
			BP.NM_BRANCH_PLANT  AS "@NM_BRANCH_PLANT",
			BP.DS_BRANCH_PLANT  AS "@DS_BRANCH_PLANT",
			BP.ID_FILE  AS "@ID_FILE"
			FROM ADM.C_BRANCH_PLANT BP
			ORDER BY BP.KY_BRANCH_PLANT
			--WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND BP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
			FOR XML PATH ('BRANCHPLANT'), ROOT ('BRANCHPLANTS')
		)
	
	
		SET @XML_LIST_CATALOG = (
			SELECT 	    
			LC.ID_LIST_CATALOG  AS "@ID_LIST_CATALOG",
			LC.KY_LIST_CATALOG  AS "@KY_LIST_CATALOG",
			LC.NM_LIST_CATALOG  AS "@NM_LIST_CATALOG",
			LC.DS_LIST_CATALOG  AS "@DS_LIST_CATALOG"
			FROM ADM.C_LIST_CATALOG LC
			ORDER BY LC.KY_LIST_CATALOG
			--WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND BP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
			FOR XML PATH ('LIST_CATALOG'), ROOT ('LIST_CATALOGS')
		)
		
		
		SET @XML_VALUE_CATALOG = (
			SELECT 	    
			VC.ID_VALUE_CATALOG  AS "@ID_VALUE_CATALOG",
			VC.KY_VALUE_CATALOG  AS "@KY_VALUE_CATALOG",
			VC.NM_VALUE_CATALOG  AS "@NM_VALUE_CATALOG",
			VC.DS_VALUE_CATALOG  AS "@DS_VALUE_CATALOG",
			VC.ID_LIST_CATALOG   AS "@ID_LIST_CATALOG"
			FROM ADM.C_VALUE_CATALOG VC		
			WHERE FG_ACTIVE = 1
			ORDER BY VC.KY_VALUE_CATALOG
			FOR XML PATH ('VALUE_CATALOG'), ROOT ('VALUE_CATALOGS')
		)
		
		SET @XML_FIELD_TYPE = (
			SELECT 	    
			FT.ID_FIELD_TYPE  AS "@ID_FIELD_TYPE",
			FT.KY_FIELD_TYPE  AS "@KY_FIELD_TYPE",
			FT.NM_FIELD_TYPE  AS "@NM_FIELD_TYPE"		
			FROM ADM.VW_C_FIELD_TYPE FT
			ORDER BY FT.KY_FIELD_TYPE
			--WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND BP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
			FOR XML PATH ('FIELD_TYPE'), ROOT ('FIELD_TYPES')
		)
		
			
		SET @XML_HYSTERESIS = (
			SELECT 	    
			HT.ID_HYSTERESIS_TYPE  AS "@ID_HYSTERESIS_TYPE",
			HT.KY_HYSTERESIS_TYPE  AS "@KY_HYSTERESIS_TYPE",
			HT.NM_HYSTERESIS_TYPE  AS "@NM_HYSTERESIS_TYPE"		
			FROM ADM.VW_C_HYSTERESIS_TYPE HT
			ORDER BY HT.KY_HYSTERESIS_TYPE
			--WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND BP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
			FOR XML PATH ('HYSTERESIS'), ROOT ('HYSTERESIS_ROOT')
		)
		
		
		SELECT @ID_UNITS_CATALOG= ID_LIST_CATALOG FROM ADM.C_LIST_CATALOG WHERE KY_LIST_CATALOG = 'UNITS'

		SET @XML_UNITS = (
			SELECT 
				 VC.ID_VALUE_CATALOG  AS "@ID_VALUE_CATALOG"
				,VC.KY_VALUE_CATALOG  AS "@KY_VALUE_CATALOG"
				,VC.NM_VALUE_CATALOG  AS "@NM_VALUE_CATALOG"		
			FROM ADM.C_LIST_CATALOG LC 
				INNER JOIN ADM.C_VALUE_CATALOG VC ON VC.ID_LIST_CATALOG = LC.ID_LIST_CATALOG			
			WHERE LC.ID_LIST_CATALOG=@ID_UNITS_CATALOG AND LC.FG_ACTIVE = 1 AND VC.FG_ACTIVE = 1
			ORDER BY VC.KY_VALUE_CATALOG
			FOR XML PATH ('UNIT'), ROOT ('UNITS')
		)
	
		SELECT
			@KY_METRICS=KY_METRICS,
			@NM_METRICS=NM_METRICS,
			@KY_FIELD_TYPE=KY_FIELD_TYPE,
			@NO_ORDER = NO_ORDER,
			@FG_ENABLED=FG_ENABLED,
			@FG_REQUIRED=FG_REQUIRED,
			@DS_TOOLTIP=DS_TOOLTIP,
			@ID_BRANCH_PLANT=ID_BRANCH_PLANT,
			@XML_FIELD_SETTINGS=XML_FIELD_SETTINGS
		FROM PRD.C_METRICS WHERE ID_METRICS =@ID_METRICS
	
	
		
		SELECT
			@ID_METRICS AS ID_METRICS,
			@KY_METRICS AS KY_METRICS,
			@NM_METRICS AS NM_METRICS,
			@KY_FIELD_TYPE AS KY_FIELD_TYPE ,
			@FG_ENABLED AS FG_ENABLED,
			@FG_REQUIRED AS FG_REQUIRED,
			@DS_TOOLTIP AS DS_TOOLTIP,
			@ID_BRANCH_PLANT AS ID_BRANCH_PLANT,
			@NO_ORDER AS NO_ORDER,
			@XML_FIELD_SETTINGS AS XML_FIELD_SETTINGS,
			@XML_BRANCHPLANTS AS XML_BRANCHPLANTS,
			@XML_LIST_CATALOG AS XML_LIST_CATALOG,
			@XML_VALUE_CATALOG AS XML_VALUE_CATALOG,
			@XML_FIELD_TYPE AS XML_FIELD_TYPE,
			@XML_HYSTERESIS AS XML_HYSTERESIS,
			@XML_UNITS AS XML_UNITS
			
END

