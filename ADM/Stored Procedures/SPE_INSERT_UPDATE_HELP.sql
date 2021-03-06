﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares	
-- CRETAE date: 27/04/2018
-- Description: Insert or update a help
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_INSERT_UPDATE_HELP] 
	@XML_RESULT				XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
	@PIN_ID_HELP			AS int = NULL,
	@PIN_KY_HELP			AS nvarchar(50) = NULL,
	@PIN_NM_HELP			AS nvarchar(300) = NULL,
	@PIN_XML_HELP			AS xml = NULL,
	@PIN_ID_HELP_FATHER		AS int = NULL,
	@PIN_KY_USER_APP		AS nvarchar(50),
	@PIN_NM_PROGRAM			AS nvarchar(50),
	@PIN_TYPE_TRANSACTION	CHAR(1)             --I=INSERT   U=UPDATE

AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	,@CFE_SISTEMA DATETIME = GETDATE()

    	BEGIN TRY
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) 
		BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	
		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION='I'
	    	BEGIN
			--WE INSERT THE REGISTER ON THE TABLE  ADM.C_EMPLOYEE
			INSERT INTO ADM.C_HELP
					   ( 
						 [KY_HELP],
						 [NM_HELP],
						 [XML_HELP],
						 [ID_HELP_FATHER],
						 [DT_CREATION],
						 [KY_USER_APP_CREATION],
						 [NM_PROGRAM_CREATE]
					)
			VALUES
					     (
						  @PIN_KY_HELP,
						  @PIN_NM_HELP,
						  @PIN_XML_HELP,
						  @PIN_ID_HELP_FATHER,
						  @CFE_SISTEMA,
						  @PIN_KY_USER_APP,
						  @PIN_NM_PROGRAM
					)			
		END ELSE BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_EMPLOYEE
			UPDATE ADM.C_HELP 
			   SET [KY_HELP] =@PIN_KY_HELP,
				   [NM_HELP] =@PIN_NM_HELP,
				   [XML_HELP] =@PIN_XML_HELP,
				   [ID_HELP_FATHER] = @PIN_ID_HELP_FATHER,
				   [DT_UPDATE] =@CFE_SISTEMA,
				   [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP,
				   [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM
			WHERE [ID_HELP] =@PIN_ID_HELP
									
		END
		-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
		-- IF THERE IS A TRANSACTION IN THIS BLOCK, IT WILL BE ERASED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			COMMIT	
	END TRY
	BEGIN CATCH		
		--IF IT OCCURS A ERROR IN THIS BLOCK THE TRANSACTIO GET CANCELED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			ROLLBACK
			
		DECLARE @KY_ERROR INT  = 	ERROR_NUMBER()
		DECLARE @ERROR_MESSAGE NVARCHAR(250)  = 	 ERROR_MESSAGE()
	
	    SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
		--SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
		--SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,@ERROR_MESSAGE)
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, @ERROR_MESSAGE)
		
			
	END CATCH
END

