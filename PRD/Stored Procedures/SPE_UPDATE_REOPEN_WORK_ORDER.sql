﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CRETAE date: 24/07/2018
-- Description: Reopen the work order
-- =============================================
-- 01/30/2019 JDR The parameter @PIN_KY_TYPE is added to indicate if parts are being added to the work order by reopening or programming
-- =============================================


CREATE PROCEDURE    [PRD].[SPE_UPDATE_REOPEN_WORK_ORDER]
	@XML_RESULT XML = '' OUT
	, @PIN_ID_WORK_ORDER AS INT
	, @PIN_NO_SKIDS_TO_OPEN AS INT
	, @PIN_KY_TYPE NVARCHAR(50)
	, @PIN_KY_USER_APP AS NVARCHAR(50)
	, @PIN_NM_PROGRAM AS NVARCHAR(50)

AS 
BEGIN  

   	BEGIN TRY
		----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
		DECLARE @V_EXIST_TRAN BIT = 0, @DT_SYSTEM DATETIME = GETDATE()

		IF @@TRANCOUNT = 0 BEGIN
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	

		DECLARE @V_NO_RUN_QTY AS INT
			, @V_NO_QTY_SKID AS INT
			, @V_DT_START_WORK_ORDER AS DATETIME
			, @V_DT_CLOSE_WORK_ORDER AS DATETIME
			, @V_NO_PIECES_TO_ADD AS INT
			, @V_NO_ROW AS INT
			, @V_KY_TYPE_DATE AS NVARCHAR(50)

		SELECT @V_DT_START_WORK_ORDER = CASE WHEN @PIN_KY_TYPE = 'REOPEN' THEN DT_START_WORK_ORDER ELSE @DT_SYSTEM END
			, @V_DT_CLOSE_WORK_ORDER = CASE WHEN @PIN_KY_TYPE = 'REOPEN' THEN DT_CLOSE_WORK_ORDER ELSE @DT_SYSTEM END
			, @V_NO_QTY_SKID = NO_QTY_SKID
			, @V_NO_RUN_QTY = NO_RUN_QTY
		FROM PRD.K_WORK_ORDER
		WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER		

		SET @V_NO_PIECES_TO_ADD = (@PIN_NO_SKIDS_TO_OPEN * @V_NO_QTY_SKID)

		SELECT @V_NO_ROW = COUNT(1)
			, @V_KY_TYPE_DATE = @PIN_KY_TYPE
		FROM PRD.K_WORK_ORDER_LOG 
		WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

		IF @PIN_KY_TYPE = 'REOPEN' BEGIN
			SET @V_KY_TYPE_DATE = CASE WHEN @V_NO_ROW = 0 THEN 'ORIGINAL' ELSE 'REOPEN' END

			UPDATE PRD.K_WORK_ORDER
			SET DT_START_WORK_ORDER = @DT_SYSTEM
				, DT_CLOSE_WORK_ORDER = NULL
				, KY_STATUS = 'SCHEDULED'
				, NO_QTY_ADDED = (NO_QTY_ADDED + @V_NO_PIECES_TO_ADD)
			WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER
		END

		INSERT INTO PRD.K_WORK_ORDER_LOG (
			ID_WORK_ORDER
			, NO_SEQUENCE
			, DT_WORK_ORDER_LOG
			, KY_TYPE_DATE
			, DT_START_WORK_ORDER
			, DT_CLOSE_WORK_ORDER
			, NO_QTY_ADDED
			, DT_CREATION
			, KY_USER_APP_CREATION
			, NM_PROGAM_CREATE
		) VALUES (
			@PIN_ID_WORK_ORDER
			, @V_NO_ROW
			, @DT_SYSTEM
			, @V_KY_TYPE_DATE
			, @V_DT_START_WORK_ORDER
			, @V_DT_CLOSE_WORK_ORDER
			, @V_NO_PIECES_TO_ADD
			, @DT_SYSTEM
			, @PIN_KY_USER_APP
			, @PIN_NM_PROGRAM
		)



		-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'La orden de trabajo se ha reabierto exitosamente.', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'The work order has been reopened successfully.', 'EN')


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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error while processing the register.')
		
		--EXECUTE ADM.SPE_RAISE_ERROR
			
	END CATCH
END

