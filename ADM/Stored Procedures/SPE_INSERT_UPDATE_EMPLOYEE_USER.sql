﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Plaskolite - 2020
-- Author: Daniel Dávalos Romero
-- CRETAE date: 10/03/2017
-- Description: Insert or update a new employee with his respective user
-- =============================================
-- =============================================

CREATE PROCEDURE  [ADM].[SPE_INSERT_UPDATE_EMPLOYEE_USER]
			
			-- Employee Params (ADM.C_EMPLOYEE) -->
			@PIN_KY_EMPLOYEE AS nvarchar(50) = NULL,
			@PIN_NM_FIRST_NAME AS nvarchar(300) = NULL,
			@PIN_NM_LAST_NAME AS nvarchar(500) = NULL,
			@PIN_XML_PHONE AS xml = NULL,
			@PIN_ID_POSITION AS int = NULL,
			-- User Params (ADM.C_USER) -->
			@PIN_KY_USER AS nvarchar(50) = NULL,
			--@PIN_NM_USER AS nvarchar(300) = NULL,  -- Se construye con @PIN_NM_FIRST_NAME Y @PIN_NM_LAST_NAME
			@PIN_NM_PASSWORD AS nvarchar(100) = NULL,
			@PIN_DT_CHANGE_PASSWORD AS DATETIME = NULL,
			@PIN_KY_CHANGE_PASSWORD AS nvarchar(100) = NULL,
			@PIN_FG_CHANGE_PASSWORD AS BIT = NULL,
			--@PIN_DT_INACTIVE AS DATETIME = NULL,	-- 
			-- Shared Params -->
			@PIN_ID_EMPLOYEE AS INT = NULL,
			@XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
			@NO_RESULT INT = 0 OUT,
			@PIN_ID_BRANCH_PLANT AS INT = NULL,
			@PIN_KY_EMAIL AS nvarchar(500) = NULL,
			@PIN_FG_ACTIVE AS BIT =NULL,
			@PIN_KY_USER_APP_CREATE AS nvarchar(50) = NULL,
			@PIN_KY_USER_APP_UPDATE AS nvarchar(50) = NULL,
			@PIN_NM_PROGRAM_CREATE AS nvarchar(50) = NULL,
			@PIN_NM_PROGRAM_UPDATE AS nvarchar(50) = NULL,
			@PIN_TYPE_TRANSACTION CHAR(1)            --I=INSERT   U=UPDATE
AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	,@CDT_SISTEMA DATETIME = GETDATE()
	,@V_NM_USER NVARCHAR(300) = CONCAT(@PIN_NM_FIRST_NAME, ' ' ,@PIN_NM_LAST_NAME)

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
			INSERT INTO ADM.C_EMPLOYEE
					( 
						 [KY_EMPLOYEE]
						,[NM_FIRST_NAME]
						,[NM_LAST_NAME]
						,[XML_PHONE]
						,[KY_EMAIL]
						,[ID_BRANCH_PLANT]
						,[ID_POSITION]
						,[FG_ACTIVE]
						,[DT_CREATION]
						,[KY_USER_APP_CREATION]
						,[NM_PROGAM_CREATE]
					)
			VALUES
					(
						  @PIN_KY_EMPLOYEE
						, @PIN_NM_FIRST_NAME
						, @PIN_NM_LAST_NAME
						, @PIN_XML_PHONE
						, @PIN_KY_EMAIL
						, @PIN_ID_BRANCH_PLANT
						, @PIN_ID_POSITION
						, @PIN_FG_ACTIVE
						, @CDT_SISTEMA
						, @PIN_KY_USER_APP_CREATE
						, @PIN_NM_PROGRAM_CREATE
					)	
					
			DECLARE @V_ID_EMPLOYEE INT = (
				SELECT IDENT_CURRENT('ADM.C_EMPLOYEE')
			)

			--WE INSERT THE REGISTER ON THE TABLE  ADM.C_USER
			INSERT INTO ADM.C_USER
					(
						  [KY_USER]
						, [NM_USER]
						, [KY_EMAIL]
						, [NM_PASSWORD]
						, [DT_CHANGE_PASSWORD]
						, [KY_CHANGE_PASSWORD]
						, [FG_CHANGE_PASSWORD]
						, [ID_ROLE]
						, [ID_EMPLOYEE]
						, [FG_ACTIVE]
						, [ID_BRANCH_PLANT]
						, [DT_INACTIVE]
						, [DT_CREATION]
						, [KY_USER_APP_CREATION]
						, [NM_PROGAM_CREATE]
					)
			VALUES
					(  
							LTRIM(RTRIM(@PIN_KY_USER)),
							@V_NM_USER,
							@PIN_KY_EMAIL,
							@PIN_NM_PASSWORD,
							@PIN_DT_CHANGE_PASSWORD,
							@PIN_KY_CHANGE_PASSWORD,
							@PIN_FG_CHANGE_PASSWORD,
							1,	-- ID_ROLE DEFAULT, ONLY TO KEEP WORKING "SPE_GET_USER_AUTHENTICATION"
							@V_ID_EMPLOYEE,
							@PIN_FG_ACTIVE,
							@PIN_ID_BRANCH_PLANT,
							CASE WHEN @PIN_FG_ACTIVE = 0 THEN @CDT_SISTEMA ELSE NULL END,
						    @CDT_SISTEMA,
						    @PIN_KY_USER_APP_CREATE,
							@PIN_NM_PROGRAM_CREATE
					)			
		END 
		ELSE BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_EMPLOYEE
			UPDATE ADM.C_EMPLOYEE SET
   				  [KY_EMPLOYEE] = @PIN_KY_EMPLOYEE
				, [NM_FIRST_NAME] = @PIN_NM_FIRST_NAME
				, [NM_LAST_NAME] =@PIN_NM_LAST_NAME
				, [XML_PHONE] = @PIN_XML_PHONE
				, [KY_EMAIL] = @PIN_KY_EMAIL
				, [ID_BRANCH_PLANT] = @PIN_ID_BRANCH_PLANT
				, [ID_POSITION] = @PIN_ID_POSITION
				, [FG_ACTIVE] = @PIN_FG_ACTIVE
				, [DT_UPDATE] =@CDT_SISTEMA
				, [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP_UPDATE
				, [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM_UPDATE
			WHERE [ID_EMPLOYEE] = @PIN_ID_EMPLOYEE

			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_USER
			UPDATE ADM.C_USER SET
					      --[KY_USER] = LTRIM(RTRIM(@PIN_KY_USER))
						[NM_USER] =@V_NM_USER
						, [KY_EMAIL]=@PIN_KY_EMAIL
						, [NM_PASSWORD] = CASE WHEN @PIN_FG_CHANGE_PASSWORD = 1 THEN @PIN_NM_PASSWORD ELSE [NM_PASSWORD]END
						, [DT_CHANGE_PASSWORD]=@PIN_DT_CHANGE_PASSWORD
						, [KY_CHANGE_PASSWORD]=@PIN_KY_CHANGE_PASSWORD
						, [FG_CHANGE_PASSWORD]=@PIN_FG_CHANGE_PASSWORD
						, [ID_EMPLOYEE]=@PIN_ID_EMPLOYEE
						, [FG_ACTIVE]=@PIN_FG_ACTIVE
						, [ID_BRANCH_PLANT]=@PIN_ID_BRANCH_PLANT
						, [DT_INACTIVE]=CASE WHEN @PIN_FG_ACTIVE = 0 THEN @CDT_SISTEMA ELSE DT_INACTIVE END
						, [DT_UPDATE] =@CDT_SISTEMA
						, [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP_UPDATE
						, [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM_UPDATE
			WHERE [KY_USER] = @PIN_KY_USER
									
		END
		-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		IF (@PIN_KY_USER IS NULL OR @PIN_KY_USER = '')
			SET @NO_RESULT = 2
		ELSE
			SET @NO_RESULT = 1
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
		SET @NO_RESULT = 0
	    SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		
	END CATCH
END
