
-- =============================================
-- Author:		Gabriel Vázquez Torres
-- Create date: 21/07/2018
-- Description:	Get the real value of the width for the extrusion report
-- =============================================
CREATE FUNCTION [PRD].[GET_PCS_REPORT]
(
	-- Add the parameters for the function here
	@PIN_NO_WEB_WIDTH DECIMAL(13,5),
	@PIN_NO_LENGTH DECIMAL(13,5),
	@PIN_NO_WIDTH DECIMAL(13,5)
)
RETURNS INT
AS
BEGIN

	-- Declare the return variable here
	DECLARE @NO_REAL_LENGHT AS DECIMAL(13,5), @NO_REAL_WIDTH AS DECIMAL(13,5), @NO_PERCENT_LENGHT AS DECIMAL(13,5), @NO_PERCENT_WIDTH AS DECIMAL(13,5)
	DECLARE @NO_REPORT_PCS AS INT

	IF @PIN_NO_WEB_WIDTH > 0 BEGIN

	-- Add the T-SQL statements to compute the return value here
		SET @NO_REAL_LENGHT = (FLOOR(@PIN_NO_WEB_WIDTH / @PIN_NO_LENGTH) * @PIN_NO_LENGTH)
		SET @NO_REAL_WIDTH = (FLOOR(@PIN_NO_WEB_WIDTH / @PIN_NO_WIDTH) * @PIN_NO_WIDTH)  

		SET @NO_PERCENT_LENGHT = @NO_REAL_LENGHT / @PIN_NO_WEB_WIDTH
		SET @NO_PERCENT_WIDTH = @NO_REAL_WIDTH / @PIN_NO_WEB_WIDTH

		IF @NO_PERCENT_LENGHT > @NO_PERCENT_WIDTH
			SET @NO_REPORT_PCS =FLOOR(@PIN_NO_WEB_WIDTH / @PIN_NO_LENGTH)
		ELSE
			SET @NO_REPORT_PCS = FLOOR(@PIN_NO_WEB_WIDTH / @PIN_NO_WIDTH)

	END ELSE BEGIN

		SET @NO_REPORT_PCS = 0
	END

	-- Return the result of the function
	RETURN @NO_REPORT_PCS

END