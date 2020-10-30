﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CRETAE date: 09/03/2017
-- Description: Insert or update a new C_LIST_CATALOG
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_INSERT_UPDATE_LIST_CATALOG] 
    	  @XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
			@PIN_ID_LIST_CATALOG AS int = NULL,
			@PIN_KY_LIST_CATALOG AS nvarchar(50) = NULL,
			@PIN_NM_LIST_CATALOG AS nvarchar(300) = NULL,
			@PIN_DS_LIST_CATALOG AS nvarchar(500) = NULL,
			@PIN_FG_ACTIVE AS bit = NULL
		  , @PIN_KY_USER_APP AS nvarchar(50)
		  , @PIN_NM_PROGRAM AS nvarchar(50)
		  , @PIN_TYPE_TRANSACTION CHAR(1)             --I=INSERT   U=UPDATE

AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	,@DT_SYSTEM DATETIME = GETDATE()

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
			--WE INSERT THE REGISTER ON THE TABLE  ADM.C_DEPARTMENT
			INSERT INTO ADM.C_LIST_CATALOG
						 ([KY_LIST_CATALOG]
						, [NM_LIST_CATALOG]
						, [DS_LIST_CATALOG]
						, [FG_ACTIVE]
						, [DT_CREATION]
						, [KY_USER_APP_CREATION]
						, [NM_PROGAM_CREATE]
					)
			VALUES
					     (@PIN_KY_LIST_CATALOG
						, @PIN_NM_LIST_CATALOG
						, @PIN_DS_LIST_CATALOG
						, @PIN_FG_ACTIVE
						, @DT_SYSTEM
						, @PIN_KY_USER_APP
						, @PIN_NM_PROGRAM

					)			
		END ELSE BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_DEPARTMENT
			UPDATE ADM.C_LIST_CATALOG
			SET
   				  [KY_LIST_CATALOG] = @PIN_KY_LIST_CATALOG
				, [NM_LIST_CATALOG] = @PIN_NM_LIST_CATALOG
				, [DS_LIST_CATALOG] =@PIN_DS_LIST_CATALOG
				, [FG_ACTIVE] = @PIN_FG_ACTIVE
				, [DT_UPDATE] =@DT_SYSTEM
				, [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP
				, [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM
			       
			WHERE [ID_LIST_CATALOG] = @PIN_ID_LIST_CATALOG
									
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
