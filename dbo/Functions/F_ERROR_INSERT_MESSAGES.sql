
-- =============================================
-- Author:		Juan De Dios Pérez
-- Create date: 27/02/2017
-- Description:	Function to insert the error messages
-- =============================================
CREATE FUNCTION [dbo].[F_ERROR_INSERT_MESSAGES]
(
	-- Add the parameters for the function here
	@PIN_XML_HEADER XML
	,@PIN_DS_MESSAGE NVARCHAR(500)
	,@PIN_KY_IDIOM NVARCHAR(20)
)
RETURNS XML
AS
BEGIN

	DECLARE @XML_RESULT XML
	SET @XML_RESULT = (
		SELECT @PIN_KY_IDIOM AS "@KY_IDIOM" 
			, @PIN_DS_MESSAGE AS "@DS_MESSAGE"
		FOR XML PATH ('MESSAGE')
	)

	IF @PIN_XML_HEADER.exist('/RESULT/MESSAGES') <> 1
		SET @PIN_XML_HEADER.modify('insert <MESSAGES /> into (/RESULT)[1]');

	SET @PIN_XML_HEADER.modify('insert sql:variable("@XML_RESULT") into (/RESULT/MESSAGES)[1]') ;

	SET @XML_RESULT = @PIN_XML_HEADER

	RETURN @XML_RESULT

END




