
-- =============================================
-- Author:		Juan De Dios Pérez
-- Create date: 27/02/2017
-- Description:	Function to create the error message's header 
-- =============================================
CREATE FUNCTION [dbo].[F_ERROR_CREATE_HEADER]
(
	-- Add the parameters for the function here
	 @PIN_NO_AFFECTED_REGISTERS INT
	,@PIN_NO_ERROR INT
	,@PIN_KY_TYPE_ERROR NVARCHAR(10)
)
RETURNS XML
AS
BEGIN

	DECLARE @XML_RESULT XML
	SET @XML_RESULT = (
		SELECT @PIN_NO_AFFECTED_REGISTERS AS "@NO_AFFECTED_REGISTERS" 
			, @PIN_NO_ERROR AS "@NO_ERROR"
			, @PIN_KY_TYPE_ERROR AS "@KY_TYPE_ERROR"
		FOR XML PATH ('RESULT')
	)

	RETURN @XML_RESULT

END



