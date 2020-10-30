-- =============================================
-- Author:		DELLC
-- Create date: 04/20/2020
-- Description:	Get shift from calendar
-- =============================================
CREATE PROCEDURE   [PRD].[SPE_GET_SHIFT_CALENDAR]
	@NDATE DATETIME 
AS
BEGIN

	IF  DATEPART(HOUR, @NDATE) >=12
	SET @NDATE =  DATEADD(HOUR, 12, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) 
ELSE
	SET @NDATE =  DATEADD(HOUR, 0, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) 

SELECT * FROM ADM.C_CALENDAR WHERE CALENDAR_DATE  =@NDATE
END
