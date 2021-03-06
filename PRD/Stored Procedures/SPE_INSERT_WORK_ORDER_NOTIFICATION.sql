﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- Create date: 01/30/2019
-- Description: Insert notification from tool change report
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_INSERT_WORK_ORDER_NOTIFICATION] 
	@XML_RESULT XML = '' OUT
	, @PIN_ID_WORK_ORDER INT
	, @PIN_DS_MESSAGE NVARCHAR(500)
	, @PIN_KY_USER_APP NVARCHAR(50)
	, @PIN_NM_PROGRAM NVARCHAR(50)
	
AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
   	BEGIN TRY
		DECLARE @V_EXIST_TRAN BIT = 0
			, @DT_SYSTEM DATETIME = GETDATE()

		IF (@@TRANCOUNT = 0) BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	



		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')

		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1) BEGIN
			COMMIT	
		END
	END TRY
	BEGIN CATCH		
		--IF IT OCCURS A ERROR IN THIS BLOCK THE TRANSACTIO GET CANCELED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1) BEGIN
			ROLLBACK
		END
			
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())
			
	END CATCH
END

