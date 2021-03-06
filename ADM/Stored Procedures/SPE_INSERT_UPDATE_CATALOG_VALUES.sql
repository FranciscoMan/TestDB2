﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CRETAE date: 09/03/2017
-- Description: Insert or update a new C_CATALOG_VALUES
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_INSERT_UPDATE_CATALOG_VALUES] 
    	  @XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
			@PIN_ID_CATALOG_VALUE AS int = NULL,
			@PIN_KY_CATALOG_VALUE AS nvarchar(50) = NULL,
			@PIN_NM_CATALOG_VALUE AS nvarchar(300) = NULL,
			@PIN_DS_CATALOG_VALUE AS nvarchar(500) = NULL,
		    @PIN_ID_LIST_CATALOG AS int = NULL
		  ,	@PIN_FG_ACTIVE AS bit = NULL
		  , @PIN_KY_USER_APP AS nvarchar(50)
		  , @PIN_NM_PROGRAM AS nvarchar(50)
		  , @PIN_ID_BRANCH_PLANT as int = null
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

				insert into D_XML_DEBUG (XML_DEBUG, DT_CREATE) values (
					(
						SELECT @@TRANCOUNT AS '@TRANCOUNT' 
						, 'yes' AS '@FG_TRANCOUNT' 
						, XACT_STATE() AS '@XACT_STATE'
						FOR XML PATH('ERROR')
					)
					, GETDATE())
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	ELSE BEGIN
				insert into D_XML_DEBUG (XML_DEBUG, DT_CREATE) values (
					(
						SELECT @@TRANCOUNT AS '@TRANCOUNT' 
						, 'NO' AS '@FG_TRANCOUNT' 
						, XACT_STATE() AS '@XACT_STATE'
						FOR XML PATH('ERROR')
					)
					, GETDATE())

		END

		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION='I'
	    	BEGIN
			--WE INSERT THE REGISTER ON THE TABLE  ADM.C_DEPARTMENT
			INSERT INTO ADM.C_VALUE_CATALOG
						 ([KY_VALUE_CATALOG]
						, [NM_VALUE_CATALOG]
						, [DS_VALUE_CATALOG]
						, [ID_LIST_CATALOG]
						, [FG_ACTIVE]
						, [DT_CREATION]
						, [KY_USER_APP_CREATION]
						, [NM_PROGAM_CREATE]
						, [ID_BRANCH_PLANT]
					)
			SELECT @PIN_KY_CATALOG_VALUE
						, @PIN_NM_CATALOG_VALUE
						, @PIN_DS_CATALOG_VALUE
						, @PIN_ID_LIST_CATALOG
						, @PIN_FG_ACTIVE
						, @CFE_SISTEMA
						, @PIN_KY_USER_APP
						, @PIN_NM_PROGRAM
						, @PIN_ID_BRANCH_PLANT

		END ELSE IF @PIN_TYPE_TRANSACTION='U' BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_DEPARTMENT
			UPDATE ADM.C_VALUE_CATALOG
			SET
   				  [KY_VALUE_CATALOG] = @PIN_KY_CATALOG_VALUE
				, [NM_VALUE_CATALOG] = @PIN_NM_CATALOG_VALUE
				, [DS_VALUE_CATALOG] =@PIN_DS_CATALOG_VALUE
				, [FG_ACTIVE] = @PIN_FG_ACTIVE
				, [DT_UPDATE] =@CFE_SISTEMA
				, [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP
				, [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM
			       
			WHERE [ID_VALUE_CATALOG] = @PIN_ID_CATALOG_VALUE
									
		END ELSE BEGIN
			-- DELETE
			delete from ADM.C_VALUE_CATALOG where ID_VALUE_CATALOG = @PIN_ID_CATALOG_VALUE
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





