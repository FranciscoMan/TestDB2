﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 08/03/2017
-- Description: Delete a defect category
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_DELETE_DEFECT_CATEGORY]
	@XML_RESULT		  XML = '' OUT  ,      --0 TO ERROR AND 1 TO CORRECT
	@PIN_ID_DEFECT_CATEGORY AS int, 
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
		--DELETE THE REGISTER ON THE SQL TABLE ADM.C_DEPARTMENT
		DELETE FROM PRD.C_DEFECT_CATEGORY
		WHERE [ID_DEFECT_CATEGORY] = @PIN_ID_DEFECT_CATEGORY
				

		--WE RETURN A VARIABLE THAT INDICATES THAT EVERYTHING WAS PERFORMED OKAY.
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Se eliminó la categoria satisfactoriamente', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfully deleted category', 'EN')
		
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

