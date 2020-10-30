-- =============================================
-- Author:		Julio Díaz
-- Create date: 12/02/2016
-- Description:	Get datetime from banch plant time zone
-- =============================================
CREATE FUNCTION [dbo].[F_GETDATE] (
	@PIN_ID_BRANCH_PLANT INT
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @FE_SYSTEM AS DATETIME = DATEADD(HOUR, -1, GETDATE())
	RETURN @FE_SYSTEM
END