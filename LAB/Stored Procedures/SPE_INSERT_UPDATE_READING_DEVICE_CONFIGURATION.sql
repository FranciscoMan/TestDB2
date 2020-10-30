﻿CREATE PROCEDURE  [LAB].[SPE_INSERT_UPDATE_READING_DEVICE_CONFIGURATION]
    @XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
	@PIN_ID INT = null,
	@FG_STATUS BIT = null,
	@FG_ENABLED BIT = null,
	@NM_REASON varchar(200) = null
AS
BEGIN
 BEGIN TRY
	UPDATE LAB.K_READING_DEVICE_CONFIGURATION SET
    FG_STATUS = @FG_STATUS,
	FG_ENABLED =@FG_ENABLED,
	NM_REASON=@NM_REASON
	WHERE ID = @PIN_ID;

	-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
END TRY

BEGIN CATCH	

DECLARE @KY_ERROR INT  = 	ERROR_NUMBER()
		DECLARE @ERROR_MESSAGE NVARCHAR(250)  = 	 ERROR_MESSAGE()
	
	    SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		
END CATCH


END