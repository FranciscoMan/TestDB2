﻿CREATE PROCEDURE   [PRD].[SPE_GET_REPORT]
@PIN_DATE AS DATE,
@PIN_SHIFT AS NVARCHAR(50)
AS
BEGIN
	SELECT * FROM PRD.SAVEREPORT WHERE DT_REPORT = @PIN_DATE AND NM_SHIFT = @PIN_SHIFT
END
