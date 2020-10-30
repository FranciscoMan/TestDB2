-- =============================================
-- Author:		Gabriel Vázquez Torres
-- Create date: 26/05/2018
-- Description:	Get all ip allowed by production line
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_PRODUCTION_LINE_IP]
	-- Add the parameters for the stored procedure here
	@PIN_ID_PRODUCTION_LINE_IP AS INT = NULL,
	@PIN_ID_PRODUCTION_LINE AS INT = NULL,
	@PIN_NO_IP AS NVARCHAR(40) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [ID_PRODUCTION_LINE_IP]
		  ,[ID_PRODUCTION_LINE]
		  ,[NO_IP]
	FROM [PRD].[C_PRODUCTION_LINE_IP] PLI
	WHERE
		(@PIN_ID_PRODUCTION_LINE_IP IS NULL OR (@PIN_ID_PRODUCTION_LINE_IP IS NOT NULL AND PLI.ID_PRODUCTION_LINE_IP = @PIN_ID_PRODUCTION_LINE_IP)) AND
		(@PIN_ID_PRODUCTION_LINE IS NULL OR (@PIN_ID_PRODUCTION_LINE IS NOT NULL AND PLI.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE)) AND
		(@PIN_NO_IP IS NULL OR (@PIN_NO_IP IS NOT NULL AND PLI.NO_IP = @PIN_NO_IP))

END

