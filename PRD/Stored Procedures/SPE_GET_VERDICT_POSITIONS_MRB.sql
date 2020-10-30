-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 06/15/2017
-- Description: GET POSITION OF CONFIGURATION
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_VERDICT_POSITIONS_MRB] 
	@PIN_ID_BRANCH_PLANT NVARCHAR(5)
AS
	SET @PIN_ID_BRANCH_PLANT = ISNULL(@PIN_ID_BRANCH_PLANT, 'ALL')
	
	DECLARE @XML_CONFIGURATION XML , @XML_BRANCH_PLANT_SELECTED XML
	
	SELECT @XML_CONFIGURATION =XML_CONFIGURATION FROM ADM.S_CONFIGURATION

	SELECT 				 
		 @XML_BRANCH_PLANT_SELECTED=msgs.msg.query('.')
	FROM @XML_CONFIGURATION.nodes('CONFIGURATIONS/ESPECIFIC_CONFIGURATION/child::node()') msgs(msg)	
	WHERE msgs.msg.value('@ID_BRANCH_PLANT', 'nvarchar(max)') = @PIN_ID_BRANCH_PLANT
	
	SELECT		
		msgs.msg.value('@ID_POSITION', 'INT') ID_POSITION,
		msgs.msg.value('@ID_POSITION_BACKUP', 'INT') ID_POSITION_BACKUP,
		isnull(msgs.msg.value('@FG_IS_OPTIONAL', 'BIT'),cast(0 as bit)) FG_IS_OPTIONAL,
		msgs.msg.query('.') XML_POSITIONS
	FROM @XML_BRANCH_PLANT_SELECTED.nodes('BRANCH_PLANT/QUALITY_PROCESS/POSITIONS_MBR/child::node()') msgs(msg)  --,PRD.K_PALLET KP

