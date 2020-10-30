﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CRETAE date: 06/03/2017
-- Description: Insert or update a new position
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_INSERT_UPDATE_POSITION] 
    	    @XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
			@PIN_ID_POSITION AS int = NULL,
			@PIN_KY_POSITION AS nvarchar(50) = NULL,
			@PIN_NM_POSITION AS nvarchar(300) = NULL,
			@PIN_DS_POSITION AS nvarchar(500) = NULL,
			@PIN_KY_DS_AREA AS nvarchar(500) = NULL,
			@PIN_KY_TELEGRAM AS nvarchar(15) = NULL,
			@PIN_ID_BRANCH_PLANT AS int = NULL,
			@PIN_ID_DEPARTMENT AS int = NULL
		  , @PIN_KY_EMAIL AS NVARCHAR(100) = NULL
		  , @PIN_KY_USER_APP_CREATE AS nvarchar(50)
		  , @PIN_KY_USER_APP_UPDATE AS nvarchar(50)
		  , @PIN_NM_PROGRAM_CREATE AS nvarchar(50)
		  , @PIN_NM_PROGRAM_UPDATE AS nvarchar(50)
		  , @PIN_TYPE_TRANSACTION CHAR(1)             --I=INSERT   U=UPDATE

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
			--WE INSERT THE REGISTER ON THE TABLE  ADM.C_POSITION
			INSERT INTO ADM.C_POSITION
					   (  [KY_POSITION]
						, [NM_POSITION]
						, [DS_POSITION]
						--, [DS_AREA]
						, [ID_DEPARTMENT]
						, [KY_TELEGRAM]
						, [ID_BRANCH_PLANT]
						, KY_EMAIL
						, [DT_CREATION]
						, [KY_USER_APP_CREATION]
						, [NM_PROGAM_CREATE]
					)
			VALUES
					     (@PIN_KY_POSITION
						, @PIN_NM_POSITION
						, @PIN_DS_POSITION
						--, @PIN_KY_DS_AREA
						, @PIN_ID_DEPARTMENT
						, @PIN_KY_TELEGRAM
						, @PIN_ID_BRANCH_PLANT
						, @PIN_KY_EMAIL
						, @CFE_SISTEMA
						, @PIN_KY_USER_APP_CREATE
						, @PIN_NM_PROGRAM_CREATE
					)			
		END ELSE BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_POSITION
			UPDATE ADM.C_POSITION SET
   				  [KY_POSITION] = @PIN_KY_POSITION
				, [NM_POSITION] = @PIN_NM_POSITION
				, [DS_POSITION] =@PIN_DS_POSITION
				--, [DS_AREA] = @PIN_KY_DS_AREA
				, [ID_DEPARTMENT] = @PIN_ID_DEPARTMENT
				, [KY_TELEGRAM] = @PIN_KY_TELEGRAM
				, [ID_BRANCH_PLANT] = @PIN_ID_BRANCH_PLANT
				, KY_EMAIL = @PIN_KY_EMAIL
				, [DT_UPDATE] =@CFE_SISTEMA
				, [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP_UPDATE
				, [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM_UPDATE
			WHERE [ID_POSITION] = @PIN_ID_POSITION
									
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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		
			
	END CATCH
END

