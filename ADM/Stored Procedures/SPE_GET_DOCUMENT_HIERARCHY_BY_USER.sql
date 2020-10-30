-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 08/02/2018
-- Description: get Document management hierarchy by user role and production line
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_GET_DOCUMENT_HIERARCHY_BY_USER]
	@PIN_ID_FILE AS UNIQUEIDENTIFIER = NULL
	, @PIN_ID_ROLE INT
	, @PIN_ID_PRODUCTION_LINE INT
	, @PIN_KY_USER NVARCHAR(50)
AS   
BEGIN
	DECLARE @ID_PRODUCTION_LINE INT
	
	SET @ID_PRODUCTION_LINE = (
		SELECT TOP 1 ID_PRODUCTION_LINE
		FROM PRD.K_SHIFT KS 
		WHERE KS.KY_USER = @PIN_KY_USER AND KS.FG_STATUS = 1
	)
	
	;WITH T_FILES AS (
		SELECT FS.stream_id, FS.name, FS.file_type, FS.path_locator, FS.parent_path_locator, FS.is_directory, ROW_NUMBER() OVER (ORDER BY FS.PATH_LOCATOR) AS row_no
		FROM ADM.FS_DOCUMENT_MANAGEMENT FS
		WHERE is_directory = 1
			OR (
				EXISTS (SELECT TOP 1 1 FROM ADM.C_DOCUMENT_ROLE CDR WHERE FS.stream_id = CDR.ID_STREAM AND CDR.ID_ROLE = @PIN_ID_ROLE)
				AND (@ID_PRODUCTION_LINE IS NULL 
					OR (@ID_PRODUCTION_LINE IS NOT NULL AND (EXISTS (SELECT TOP 1 1 FROM ADM.C_DOCUMENT_PRODUCTION_LINE CDPL WHERE FS.STREAM_ID = CDPL.ID_STREAM AND CDPL.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE)))
					OR NOT EXISTS (SELECT TOP 1 1 FROM ADM.C_DOCUMENT_PRODUCTION_LINE CDPL WHERE FS.STREAM_ID = CDPL.ID_STREAM)
				)
				
			) 
			
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
	ORDER BY T1.[name] ASC
END

