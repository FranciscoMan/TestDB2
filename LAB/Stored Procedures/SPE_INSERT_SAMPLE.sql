﻿-- =============================================
-- Proyect: Plaskolite
-- Author: Julio Díaz
-- Create date: 24/04/2018
-- Description: Inserts a sample to laboratory samples repository
-- =============================================
CREATE PROCEDURE    [LAB].[SPE_INSERT_SAMPLE]
	@XML_RESULT XML OUT
	, @PIN_NO_SAMPLE INT
	, @PIN_NO_PALLET INT
	, @PIN_NO_WORK_ORDER INT
	, @PIN_ID_FORM INT
	, @PIN_KY_USER NVARCHAR(50)
	, @PIN_NM_PROGRAM NVARCHAR(50)
AS

BEGIN
	DECLARE @V_EXIST_TRAN BIT = 0
		,@DT_SYSTEM DATETIME = GETDATE()
		,@V_KY_ITEM INT
   	BEGIN TRY
		
		IF (@@TRANCOUNT = 0) BEGIN		--VERIFIES THAT EXISTS AN OPEN TRANSACTION
			
			BEGIN TRANSACTION
			SET @V_EXIST_TRAN = 1		--SETS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT

		END	
		
		INSERT INTO LAB.K_SAMPLE (
			NO_SAMPLE
			, NO_PALLET
			, NO_WORK_ORDER
			, ID_FORM
			, KY_SAMPLE_STATUS
			, DT_CREATION
			, KY_USER_APP_CREATION
			, NM_PROGRAM_CREATE
		)
		SELECT @PIN_NO_SAMPLE
			, @PIN_NO_PALLET
			, @PIN_NO_WORK_ORDER
			, @PIN_ID_FORM
			, ''
			, @DT_SYSTEM
			, @PIN_KY_USER
			, @PIN_NM_PROGRAM

		-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
		-- IF THERE IS A TRANSACTION IN THIS BLOCK, IT WILL BE ERASED

		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			COMMIT
	END TRY
	BEGIN CATCH
		
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			ROLLBACK
			
	    SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())

	END CATCH
END
