﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CRETAE date: 28/05/2018
-- Description: RESCHEDULE THE SKIPPED WORK ORDER
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_RESCHEDULE_SKIP_WORK_ORDER]
	  @XML_RESULT XML = '' OUT	-- --0 TO ERROR AND 1 TO CORRECT
	, @PIN_ID_WORK_ORDER AS INT = NULL
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

		--THEN, WE NEED TO UPDATE THE STATUS OF WORK ORDER
		UPDATE PRD.K_WORK_ORDER
			SET KY_STATUS = 'SCHEDULED',
				ID_ISSUE_CAUSE_SKIPPED = NULL,
				DT_UPDATE = @DT_SYSTEM,
				KY_USER_APP_UPDATE = @PIN_KY_USER_APP,
				NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
		WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error while processing the register.')
		
		EXECUTE ADM.SPE_RAISE_ERROR
			
	END CATCH
END

