﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Díaz
-- CREATE date: 21/05/2018
-- Description: Delete a transition-metrics relationship
-- =============================================
 CREATE PROCEDURE    [PRD].[SPE_DELETE_METRICS_TRANSITION]
	@XML_RESULT XML = '' OUT  ,      --0 TO ERROR AND 1 TO CORRECT
	@PIN_ID_METRICS_TRANSITION AS int, 
	@PIN_KY_USER AS nvarchar(50), --USER WHO WANTS TO DELETE A REGISTER 
	@PIN_NM_PROGRAM AS nvarchar(50) --PROGRAM WHERE THE USER SENT TO DELETE A REGISTER
AS   
BEGIN
	--WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	BEGIN TRY		   			
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	
		--DELETE THE REGISTER ON THE SQL TABLE ADM.C_HELP
		DELETE FROM PRD.C_METRICS_TRANSITION WHERE ID_METRICS_TRANSITION = @PIN_ID_METRICS_TRANSITION
				
		--WE RETURN A VARIABLE THAT INDICATES THAT EVERYTHING WAS PERFORMED OKAY.
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Se eliminó la ayuda satisfactoriamente', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'The transaction was successfully removed.', 'EN')
		
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

