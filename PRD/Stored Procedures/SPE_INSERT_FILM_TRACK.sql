﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Aideé Alvarez.
-- CRETAE date: 10/22/2020
-- Description: Insert film track
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_INSERT_FILM_TRACK]
	@XML_RESULT XML = '' OUT     -- --0 TO ERROR AND 1 TO CORRECT
	, @PIN_ID_FILM_TRACK INT 
	, @PIN_ID_ITEM INT
	, @PIN_ID_QA27 INT
	, @PIN_TOP_SIDE NVARCHAR(80)
	, @PIN_BOTTOM_SIDE NVARCHAR(80)
	, @PIN_KY_USER_APP NVARCHAR(50)
	, @PIN_NM_PROGRAM NVARCHAR(50) 
	, @PIN_TYPE_TRANSACTION CHAR(1) -- I or U

AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE

	BEGIN TRY
	
		DECLARE @V_EXIST_TRAN BIT = 0
			, @DT_SYSTEM DATETIME = GETDATE()
			, @ID_PRODUCTION_LINE INT
			, @ID_SHIFT INT
			, @ID_ITEM INT
			--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) BEGIN
				--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION 
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1

		END	

		IF (@PIN_TYPE_TRANSACTION = 'I')
		BEGIN
				INSERT PRD.K_FILM_TRACK(
				ID_ITEM,
				ID_QA27,
				TOP_SIDE,
				BOTTOM_SIDE, 
				DT_CREATION,
				KY_USER_APP_CREATION, 
				NM_PROGRAM_CREATE) VALUES
				(
				@PIN_ID_ITEM,
				@PIN_ID_QA27, 
				@PIN_TOP_SIDE,
				@PIN_BOTTOM_SIDE,
				GETDATE(),
				@PIN_KY_USER_APP,
				@PIN_NM_PROGRAM
				)
		END
			ELSE -- An update
		BEGIN
				UPDATE PRD.K_FILM_TRACK SET
				TOP_SIDE            = @PIN_TOP_SIDE,
				BOTTOM_SIDE         = @PIN_BOTTOM_SIDE,
				DT_UPDATE           = GETDATE(),
				KY_USER_APP_UPDATE  = @PIN_KY_USER_APP,
				NM_PROGRAM_CREATE   = @PIN_NM_PROGRAM
				WHERE ID_FILM_TRACK = @PIN_ID_FILM_TRACK
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
			
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())

	END CATCH
END
