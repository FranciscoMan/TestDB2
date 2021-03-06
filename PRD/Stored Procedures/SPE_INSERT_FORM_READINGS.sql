﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- Create date: 23/02/2018
-- Description: Insert Form Readings
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_INSERT_FORM_READINGS]
		  @XML_RESULT XML = '' OUT    -- --0 TO ERROR AND 1 TO CORRECT
		, @PIN_ID_K_FORM INT
		, @PIN_XML_READINGS XML
		, @PIN_KY_USER_APP NVARCHAR(50)
		, @PIN_NM_PROGRAM NVARCHAR(50)
	  	, @PIN_TYPE_TRANSACTION CHAR(1)  --I=INSERT   U=UPDATE
AS 
BEGIN  

   	BEGIN TRY
		----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE	
		DECLARE @V_EXIST_TRAN BIT = 0			
			, @DT_SYSTEM DATETIME = GETDATE()

		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) BEGIN
			--IN CASE THAT THE TRANSACTION HAVE NOT BEEN STARTED
			BEGIN TRANSACTION 
			--IT SETS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1

		END

		CREATE TABLE #T_FORM_METRICS  (
			ID_METRICS INT
			, XML_METRICS_VALUE XML
		)

		INSERT INTO #T_FORM_METRICS (ID_METRICS, XML_METRICS_VALUE)
		SELECT c.value('@ID_METRICS', 'INT') AS ID_METRICS
			, c.query('.') AS XML_METRICS_VALUE
		FROM @PIN_XML_READINGS.nodes('/METRICS/FIELD_TYPES') T(c)

		IF @PIN_TYPE_TRANSACTION = 'I' BEGIN

			UPDATE PRD.K_FORM SET KY_STATUS_FORM = 'SAVED' WHERE ID_K_FORM = @PIN_ID_K_FORM

			INSERT INTO PRD.K_FORM_METRICS (ID_K_FORM, ID_METRICS, XML_METRICS_VALUE, DT_CREATION, KY_USER_APP_CREATION, NM_PROGAM_CREATE)
			SELECT @PIN_ID_K_FORM AS ID_K_FORM
				, TFM.ID_METRICS
				, TFM.XML_METRICS_VALUE
				, @DT_SYSTEM
				, @PIN_KY_USER_APP
				, @PIN_NM_PROGRAM
			FROM #T_FORM_METRICS TFM
			WHERE NOT EXISTS (SELECT TOP 1 1 FROM PRD.K_FORM_METRICS KFM WHERE KFM.ID_K_FORM = @PIN_ID_K_FORM AND KFM.ID_METRICS = TFM.ID_METRICS)

		END

	--	-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')			
	--	-- IF THERE IS A TRANSACTION IN THIS BLOCK, IT WILL BE ERASED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			COMMIT			
	 
	END TRY
	BEGIN CATCH		
	--	--IF IT OCCURS A ERROR IN THIS BLOCK THE TRANSACTIO GET CANCELED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			ROLLBACK
			
		DECLARE @KY_ERROR INT  = 	ERROR_NUMBER()
		DECLARE @ERROR_MESSAGE NVARCHAR(250)  =ERROR_MESSAGE()						
	    SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		
			
	END CATCH
END

