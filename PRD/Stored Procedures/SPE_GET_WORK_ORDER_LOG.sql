-- =============================================
-- Author:		Gabriel Vázquez Torres
-- Create date: 25/07/2018
-- Description:	Get the data log for work order
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_WORK_ORDER_LOG]
	-- Add the parameters for the stored procedure here
	@PIN_ID_WORK_ORDER AS INT = NULL,
	@PIN_DT_WORK_ORDER_LOG_INIT AS DATETIME = NULL,
	@PIN_DT_WORK_ORDER_LOG_END AS DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	SELECT [ID_WORK_ORDER_LOG]
		  ,[ID_WORK_ORDER]
		  ,[DT_WORK_ORDER_LOG]
		  ,[NO_SEQUENCE]
		  ,[KY_TYPE_DATE]
		  ,[DT_START_WORK_ORDER]
		  ,[DT_CLOSE_WORK_ORDER]
		  ,[NO_QTY_ADDED]
	FROM [PRD].[K_WORK_ORDER_LOG]
	WHERE
		(@PIN_ID_WORK_ORDER IS NULL OR (@PIN_ID_WORK_ORDER IS NOT NULL AND ID_WORK_ORDER = @PIN_ID_WORK_ORDER)) AND
		(@PIN_DT_WORK_ORDER_LOG_INIT IS NULL OR (@PIN_DT_WORK_ORDER_LOG_INIT IS NOT NULL AND DT_WORK_ORDER_LOG BETWEEN @PIN_DT_WORK_ORDER_LOG_INIT AND @PIN_DT_WORK_ORDER_LOG_END))
	ORDER BY NO_SEQUENCE DESC

END

