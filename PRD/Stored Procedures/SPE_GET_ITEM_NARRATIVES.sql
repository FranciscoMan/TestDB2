-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 18/06/2018
-- Description: Get item narratives binary data
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_ITEM_NARRATIVES]
	@PIN_KY_ITEM AS nvarchar(50) = NULL

AS   

DECLARE @DS_SQL NVARCHAR(MAX) = 'SELECT TOP 1 CAST(GDTXFT AS VARBINARY(MAX)) AS FL_NARRATIVES FROM OPENQUERY (JDEPROD, ''SELECT * FROM PRODDTA.F00165 WHERE GDOBNM = ''''GT4016B'''' AND GDTXKY = ''''' + @PIN_KY_ITEM + '|'''''')'
DECLARE @T_NARRATIVES TABLE (
	FL_NARRATIVE VARBINARY(MAX)
)

INSERT INTO @T_NARRATIVES (FL_NARRATIVE)
EXEC (@DS_SQL)

SELECT FL_NARRATIVE FROM @T_NARRATIVES

