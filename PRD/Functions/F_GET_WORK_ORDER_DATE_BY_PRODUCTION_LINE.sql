﻿
-- =============================================
-- Author:		Juan De Dios Pérez
-- Create date: 11/05/2017
-- Description:	Function to get the date of starting by production line
-- =============================================
CREATE FUNCTION [PRD].[F_GET_WORK_ORDER_DATE_BY_PRODUCTION_LINE]
(
	 @PIN_ID_PRODUCTION_LINE INT
)
RETURNS DATETIME
AS
BEGIN

	DECLARE @DT_START_WORK_ORDER DATETIME;
	DECLARE @DT_RETURN_DATE DATETIME;
	DECLARE @NO_MINUTES_TO_LAST INT;



	SELECT TOP 1 @DT_START_WORK_ORDER =  DT_WORK_ORDER,@NO_MINUTES_TO_LAST = NO_ASSIGNED_TIME  FROM PRD.K_WORK_ORDER
	WHERE ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE AND KY_STATUS <> 'COMPLETE'
	ORDER BY DT_WORK_ORDER DESC;

	IF @DT_START_WORK_ORDER IS NULL
		BEGIN
			SET @DT_RETURN_DATE = GETDATE()
		END
		ELSE 
		BEGIN

			SET @DT_RETURN_DATE = DATEADD(MINUTE, @NO_MINUTES_TO_LAST,@DT_START_WORK_ORDER) ;
		END

		RETURN @DT_RETURN_DATE
END
