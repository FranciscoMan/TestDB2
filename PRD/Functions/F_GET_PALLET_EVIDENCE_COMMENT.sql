﻿
-- =============================================
-- Author:		Juan De Dios Pérez
-- Create date: 27/02/2017
-- Description:	Function to return the evidence by pallet
-- =============================================
CREATE FUNCTION [PRD].[F_GET_PALLET_EVIDENCE_COMMENT]
(
	 @PIN_ID_PALLET INT
)
RETURNS XML
AS
BEGIN

	DECLARE @XML_COMMENT XML,
	 @XML_EVIDENCE XML,
	 @XML_RESULT XML


	SET @XML_COMMENT = (
		SELECT ID_PALLET_COMMENT AS "@ID_PALLET_COMMENT" 
			, ID_PALLET AS "@ID_PALLET"
			, DS_COMMENT AS "@DS_COMMENT"
			, DT_COMMENT AS "@DT_COMMENT"
			FROM PRD.K_PALLET_COMMENT
			WHERE ID_PALLET = @PIN_ID_PALLET
		FOR XML PATH ('COMMENT'), ROOT ('COMMENTS')
	)

		SET @XML_EVIDENCE = (
		SELECT 
			  KPE.ID_PALLER_EVIDENCE AS "@ID_PALLET_EVIDENCE" 
			, KPE.ID_PALLET AS "@ID_PALLET"
			, KPE.ID_FILE AS "@ID_FILE"
			, KPE.DT_PALLET_EVIDENCE AS "@DT_PALLET_EVIDENCE"
			, FS.file_stream AS "@FILE_STREAM"
			, FS.name as "@NAME"
			, 'U' AS "@KY_STATUS"
			FROM [PRD].[K_PALLET_EVIDENCE] KPE
		LEFT OUTER JOIN ADM.FS_FILE_SYSTEM FS ON KPE.ID_FILE = FS.stream_id
		WHERE KPE.ID_PALLET = @PIN_ID_PALLET
		FOR XML PATH ('EVIDENCE'), ROOT ('EVIDENCES')
	)


	SET @XML_RESULT = (
		SELECT 
			 @XML_COMMENT
		   , @XML_EVIDENCE
		FOR XML PATH ('CATALOGS')
	)


	RETURN @XML_RESULT

END
