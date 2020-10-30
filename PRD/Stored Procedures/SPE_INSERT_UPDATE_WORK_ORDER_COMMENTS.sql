﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CRETAE date: 05/06/2018
-- Description: Insert or update a new work order comment
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_INSERT_UPDATE_WORK_ORDER_COMMENTS] 
	@XML_RESULT XML = '' OUT
	, @PIN_ID_WORK_ORDER_COMMENT AS INT
	, @PIN_ID_WORK_ORDER AS INT
	, @PIN_KY_TYPE_COMMENT AS NVARCHAR(50)
	, @PIN_DS_COMMENT AS NVARCHAR(MAX)
	, @PIN_DT_COMMENT AS DATETIME
	, @PIN_KY_USER_APP AS NVARCHAR(50)
	, @PIN_NM_PROGRAM AS NVARCHAR(50)
	, @PIN_TYPE_TRANSACTION CHAR(1)

AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
		, @V_DT_SYSTEM DATETIME = GETDATE()

    BEGIN TRY
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF @@TRANCOUNT = 0 BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	

		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION = 'I' BEGIN

			--WE INSERT THE REGISTER ON THE TABLE  PRD.K_WORK_ORDER_COMENT

			INSERT INTO PRD.K_WORK_ORDER_COMMENT (
				ID_WORK_ORDER
				, KY_TYPE_COMMENT
				, DS_COMMENT
				, DT_COMMENT
				, DT_CREATION
				, KY_USER_APP_CREATION
				, NM_PROGAM_CREATE
			)
			VALUES (
				@PIN_ID_WORK_ORDER
				, @PIN_KY_TYPE_COMMENT
				, @PIN_DS_COMMENT
				, @V_DT_SYSTEM
				, @V_DT_SYSTEM
				, @PIN_KY_USER_APP
				, @PIN_NM_PROGRAM
			)	
		END 
		
		IF @PIN_TYPE_TRANSACTION = 'U' BEGIN
				-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_DEPARTMENT
			UPDATE [PRD].[K_WORK_ORDER_COMMENT]
			SET DS_COMMENT = @PIN_DS_COMMENT
				--, DT_COMMENT = @V_DT_SYSTEM
				, DT_UPDATE = @V_DT_SYSTEM
				, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
				, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
			WHERE ID_WORK_ORDER_COMMENT = @PIN_ID_WORK_ORDER_COMMENT
									
		END

		IF @PIN_TYPE_TRANSACTION = 'C' BEGIN
				-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_DEPARTMENT
			UPDATE [PRD].[K_WORK_ORDER_COMMENT]
			SET FG_ACTIVE = 0
				, DT_LAST_INACTIVE = @V_DT_SYSTEM
				, DT_UPDATE = @V_DT_SYSTEM
				, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
				, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
			WHERE ID_WORK_ORDER_COMMENT = @PIN_ID_WORK_ORDER_COMMENT
									
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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,@ERROR_MESSAGE)-- 'There was an error processing the register')
		
			
	END CATCH
END

