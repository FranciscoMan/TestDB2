﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CRETAE date: 04/04/2017
-- Description: Insert or update a Work Order
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_RUN_NEXT_WORK_ORDER] 
	@XML_RESULT XML = '' OUT
	, @PIN_ID_WORK_ORDER AS int
	, @PIN_KY_STATUS_QA27 AS NVARCHAR(50)
	, @PIN_KY_STATUS_WORK_ORDER AS NVARCHAR(50)
	, @PIN_NO_WORK_ORDER_ORIGIN AS NVARCHAR(20)
	, @PIN_ID_WORK_ORDER_ORIGIN AS int
	, @PIN_NO_PALLET_ORIGIN AS NVARCHAR(20)
	, @PIN_ID_PALLET_ORIGIN AS int
	, @PIN_KY_USER_APP AS nvarchar(50)
	, @PIN_NM_PROGRAM AS nvarchar(50)
	, @PIN_TYPE_TRANSACTION CHAR(1) --I=INSERT   U=UPDATE

AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
		, @DT_SYSTEM DATETIME = GETDATE()
	
   	BEGIN TRY
		IF (@@TRANCOUNT = 0) BEGIN
			BEGIN TRANSACTION
			SET @V_EXIST_TRAN = 1
		END	

		DECLARE @ID_PRODUCTION_LINE INT 
			, @ID_BRANCH_PLANT INT 
		
		SELECT TOP 1 @ID_PRODUCTION_LINE = ID_PRODUCTION_LINE 
			, @ID_BRANCH_PLANT = ID_BRANCH_PLANT
		FROM PRD.K_WORK_ORDER WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

		DECLARE @ID_SHIFT INT = (SELECT TOP 1 ID_SHIFT FROM PRD.K_SHIFT WHERE ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE AND FG_STATUS = 1)

		DECLARE @FG_WORK_ORDER_RUNNING BIT = CASE WHEN EXISTS (SELECT TOP 1 1 FROM PRD.K_WORK_ORDER WHERE KY_STATUS = 'RUNNING' AND ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE) THEN 1 ELSE 0 END

		DECLARE @FG_QA27_RUNNING BIT = CASE WHEN EXISTS (SELECT TOP 1 1 FROM PRD.K_QA27 KQ WHERE EXISTS (SELECT TOP 1 1 FROM PRD.K_SHIFT KS WHERE KS.ID_SHIFT = KQ.ID_SHIFT AND KS.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE) AND KQ.KY_STATUS = 'RUNNING') THEN 1 ELSE 0 END

		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION = 'I' BEGIN

			IF @FG_WORK_ORDER_RUNNING = 0 AND @FG_QA27_RUNNING = 0 BEGIN
				UPDATE PRD.K_WORK_ORDER
				SET KY_STATUS = @PIN_KY_STATUS_WORK_ORDER,
					DT_START_WORK_ORDER = @DT_SYSTEM,
					ID_WORK_ORDER_ORIGIN = @PIN_ID_WORK_ORDER_ORIGIN,
					ID_PALLET = @PIN_ID_PALLET_ORIGIN,
					KY_USER_APP_UPDATE = @PIN_KY_USER_APP,
					NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
				WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER
		

				INSERT INTO PRD.K_QA27 (
					ID_WORK_ORDER
					, KY_SHIFT
					, ID_SHIFT
					, NO_ORDER
					, DT_INITIAL_TIME
					, KY_STATUS
					, DT_QA27
					, ID_LEADMAN
					, NM_LEADMAN	
					, DT_CREATION
					, KY_USER_APP_CREATION
					, NM_PROGAM_CREATE
				)
				SELECT @PIN_ID_WORK_ORDER
					, VS.KY_SHIFT
					, @ID_SHIFT
					, 0
					, @DT_SYSTEM
					, @PIN_KY_STATUS_QA27
					, @DT_SYSTEM
					, CU.ID_EMPLOYEE
					, CU.NM_USER
					, @DT_SYSTEM
					, @PIN_KY_USER_APP
					, @PIN_NM_PROGRAM
				FROM ADM.C_USER CU
					INNER JOIN ADM.VW_C_SHIFT VS 
						ON CAST(@DT_SYSTEM AS TIME) BETWEEN VS.INITIAL_SHIFT_TIME AND VS.FINAL_SHIFT_TIME
				WHERE CU.KY_USER = @PIN_KY_USER_APP

			-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
				SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
			END ELSE BEGIN
				-- WE BACK A RETURN VARIABLE THAT INDICATES THERE ARE SOME WARNINGS
				SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'WARNING')

				IF @FG_QA27_RUNNING = 1 BEGIN
					SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Ya hay un registro QA27 corriendo', 'ES')
					SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'There is already a QA27 record running', 'EN')
				END

				IF @FG_WORK_ORDER_RUNNING = 1 BEGIN
					SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Ya hay una orden de trabajo corriendo en esta línea, la pantalla se refrescará y si no aparece en la sección "Running work order" contacte a su supervisor.', 'ES')
					SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'There is already a work order running on this line, the screen will refresh and if it does not appear in the "Running work order" section, contact your supervisor.', 'EN')
				END

				DECLARE @E_DS_LOG NVARCHAR(1000) = 'There is an attempt to start the work order number ' + CONVERT(NVARCHAR(20), @PIN_ID_WORK_ORDER) + ' on line ' + CONVERT(NVARCHAR(20), @ID_PRODUCTION_LINE) + ' without having finished the previous one'

				EXECUTE PRD.SPE_INSERT_LOG
					@LOG_TYPE = 'WARNING'
					, @DS_LOG = @E_DS_LOG
					, @XML_REFERENCE = @XML_RESULT
					, @ID_BRANCH_PLANT = @ID_BRANCH_PLANT
					, @KY_USER_APP = @PIN_KY_USER_APP
					, @NM_PROGAM = @PIN_NM_PROGRAM
					, @PIN_TYPE_TRANSACTION = 'I'


			END

		END 
		
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

