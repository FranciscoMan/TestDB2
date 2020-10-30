
-- =============================================
-- Author:		Julio Díaz
-- Create date: 9/12/2015
-- Description:	Function to insert data which comes from db 
-- =============================================
CREATE FUNCTION [dbo].[F_ERROR_INSERT_DATA]
(
	-- Add the parameters for the function here
	@PIN_XML_HEADER XML
	,@PIN_XML_DATA XML
)
RETURNS XML
AS
BEGIN

	DECLARE @XML_RESULT XML = @PIN_XML_DATA

	IF @PIN_XML_HEADER.exist('/RESULT/DATOS') <> 1
		SET @PIN_XML_HEADER.modify('insert <DATA /> into (/RESULT)[1]');

	SET @PIN_XML_HEADER.modify('insert sql:variable("@XML_RESULT") into (/RESULT/DATA)[1]') ;

	SET @XML_RESULT = @PIN_XML_HEADER

	RETURN @XML_RESULT

END




