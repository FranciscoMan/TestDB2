-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 01/02/2018
-- Description: get Document management hierarchy
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_DOCUMENT_HIERARCHY] 
	@PIN_ID_FILE AS UNIQUEIDENTIFIER = NULL
	, @PIN_FG_SHOW_DIRECTORIES_ONLY BIT
AS   
	;WITH T_FILES AS (
		SELECT stream_id, name, file_type, path_locator, parent_path_locator, is_directory, ROW_NUMBER() OVER (ORDER BY PATH_LOCATOR) AS row_no
		FROM ADM.FS_DOCUMENT_MANAGEMENT
		WHERE (@PIN_FG_SHOW_DIRECTORIES_ONLY = 1 AND is_directory = 1)
			OR @PIN_FG_SHOW_DIRECTORIES_ONLY = 0
	)

	SELECT T1.stream_id AS ID_STREAM
		, T1.name AS NM_FILE
		, T1.file_type AS NM_FILE_TYPE
		, T1.row_no AS NO_ROW
		, T1.is_directory AS FG_IS_DIRECTORY
		, T2.row_no AS NO_PARENT_ROW
	FROM T_FILES T1
		LEFT JOIN T_FILES T2
			ON T2.path_locator = T1.parent_path_locator
	ORDER BY T1.NAME

