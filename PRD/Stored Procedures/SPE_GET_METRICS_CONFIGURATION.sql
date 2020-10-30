-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CREATE date: 21/06/2017
-- Description: GET METRICS OF CONFIGURATION (PROCESS_METRICS)
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_METRICS_CONFIGURATION] 
	@ID_BRANCH_PLANT NVARCHAR(5) = NULL
AS
	
	
	DECLARE @XML_CONFIGURATION XML , @XML_BRANCH_PLANT_SELECTED XML
	
	SELECT @XML_CONFIGURATION =XML_CONFIGURATION FROM ADM.S_CONFIGURATION

	SELECT 				 
		 @XML_BRANCH_PLANT_SELECTED=msgs.msg.query('.')
	FROM @XML_CONFIGURATION.nodes('CONFIGURATIONS/ESPECIFIC_CONFIGURATION/child::node()') msgs(msg)	
	WHERE msgs.msg.value('@ID_BRANCH_PLANT', 'nvarchar(max)') = ISNULL(@ID_BRANCH_PLANT,'ALL')
	
	SELECT				 
		 CM.ID_METRICS
		,msgs.msg.value('local-name(.)', 'nvarchar(max)') NM_METRICS_CONFIGURATION
		,CM.KY_METRICS
		,CM.NM_METRICS		
		,msgs.msg.query('.') XML_POSITIONS
	FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/PROCESS_METRICS/child::node()') msgs(msg)  
	INNER JOIN PRD.C_METRICS CM ON CM.ID_METRICS = msgs.msg.value('@ID_METRICS', 'nvarchar(max)')

