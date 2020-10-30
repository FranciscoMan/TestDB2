-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 03/03/2017
-- Description: get a file
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_DOCUMENT] 
	    @PIN_ID_DOCUMENT AS UNIQUEIDENTIFIER
AS   
	SELECT stream_id AS ID_STREAM
		, name AS NM_DOCUMENT
		, file_type AS NB_FILE_TYPE
		, cached_file_size AS NO_FILE_SIZE
		, file_stream AS FS_FILE_STREAM
	FROM ADM.FS_DOCUMENT_MANAGEMENT
	WHERE stream_id = @PIN_ID_DOCUMENT

