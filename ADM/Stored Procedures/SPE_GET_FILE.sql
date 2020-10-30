-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 03/03/2017
-- Description: get a file
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_FILE] 
	    @PIN_ID_FILE AS nvarchar(250) = NULL
AS   
	SELECT 
		file_stream,
		name
	FROM ADM.FS_FILE_SYSTEM
	WHERE stream_id = @PIN_ID_FILE

