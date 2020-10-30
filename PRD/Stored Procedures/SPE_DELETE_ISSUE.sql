﻿-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan De Dios Pérez
-- CREATE date: 07/04/2017
-- Description: Delete a pallet
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_DELETE_ISSUE]
	@XML_RESULT		  XML = '' OUT  ,      --0 TO ERROR AND 1 TO CORRECT
	@PIN_ID_ISSUE AS int, 
	@PIN_KY_USER_APP_CREATE AS nvarchar(50), --USUARIO QUE MANDA A ELIMINAR EL REGISTRO
	@PIN_NM_PROGRAM_CREATE AS nvarchar(50) -- PROGRAMA DONDE EL USUARIO MANDA ELIMINAR EL REGISTRO
AS   
BEGIN
	--WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	BEGIN TRY		   			
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) 
		BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	
		--DELETE THE REGISTER ON THE SQL TABLE PRD.C_PLC

		DELETE FROM PRD.K_NOTIFICATION_PROCESS 
		 WHERE ID_NOTIFICATION_REFERENCE = @PIN_ID_ISSUE 
		   AND KY_NOTIFICATION_ORIGIN = 'ISSUE'

		DELETE FROM PRD.K_NOTIFICATIONS_SENDED
		 WHERE ID_NOTIFICATION_REFERENCE = @PIN_ID_ISSUE 
		   AND KY_NOTIFICATION_ORIGIN = 'ISSUE'

		DELETE KS
		  FROM PRD.K_SCALING KS
		  JOIN PRD.K_SCALING_PROCESS KSP ON KS.ID_SCALING_PROCESS = KSP.ID_SCALING_PROCESS
		 WHERE KSP.ID_ISSUE = @PIN_ID_ISSUE

		DELETE PRD.K_SCALING_PROCESS
		 WHERE ID_ISSUE = @PIN_ID_ISSUE

		DELETE FROM PRD.K_ISSUE
		 WHERE ID_ISSUE = @PIN_ID_ISSUE


		--WE RETURN A VARIABLE THAT INDICATES THAT EVERYTHING WAS PERFORMED OKAY.
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Se eliminó el issue satisfactoriamente', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfully deleted issue', 'EN')
		
		--IN THIS BLOCK ALL TRANSACTIONS WILL DELETED
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

