﻿
CREATE PROCEDURE    [PRD].[SPE_INSERT_UPDATE_K_MEMBER_IN_LIST_DISTRIBUTION]

			@XML_RESULT XML = '' OUT ,   --0 TO ERROR AND 1 TO CORRECT
			@PIN_ID_MEMBER INT = NULL,
			@PIN_ID_DISTRIBUTION INT = NULL,
			@PIN_KY_USER VARCHAR(20) = NULL,
			@PIN_FG_ACTIVE BIT = NULL,
			@PIN_KY_USER_APP_CREATION VARCHAR(20) = NULL,
			@PIN_KY_USER_APP_UPDATE VARCHAR(20) = NULL,
			@PIN_NM_PROGAM_CREATE VARCHAR(50) = NULL,
			@PIN_NM_PROGRAM_UPDATE VARCHAR(50) = NULL,
			@PIN_ID_BRANCH_PLANT INT = NULL,
			@PIN_TYPE_TRANSACTION CHAR(1)     --I=INSERT   U=UPDATE

AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	,@CDT_SISTEMA DATETIME = GETDATE()

    	BEGIN TRY
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) 
		BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	
		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION='I'
	    	BEGIN
			--WE INSERT THE REGISTER ON THE TABLE  
			INSERT INTO PRD.K_MEMBER_IN_LIST_DISTRIBUTION(
						--ID_MEMBER,
						ID_DISTRIBUTION,
						KY_USER,
						FG_ACTIVE,
						KY_USER_APP_CREATION,
						NM_PROGAM_CREATE,
						ID_BRANCH_PLANT
						)
			VALUES(
						--@PIN_ID_MEMBER,
						@PIN_ID_DISTRIBUTION,
						@PIN_KY_USER,
						@PIN_FG_ACTIVE,
						@PIN_KY_USER_APP_CREATION,
						@PIN_NM_PROGAM_CREATE,
						@PIN_ID_BRANCH_PLANT
						)

END ELSE BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE 
			UPDATE PRD.K_MEMBER_IN_LIST_DISTRIBUTION SET
						ID_DISTRIBUTION = @PIN_ID_DISTRIBUTION,
						KY_USER = @PIN_KY_USER,
						FG_ACTIVE = @PIN_FG_ACTIVE,
						KY_USER_APP_UPDATE = @PIN_KY_USER_APP_UPDATE,
						NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM_UPDATE
			WHERE ID_MEMBER = @PIN_ID_MEMBER

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
			
		DECLARE @KY_ERROR INT  = 	ERROR_NUMBER()
		DECLARE @ERROR_MESSAGE NVARCHAR(250)  = 	 ERROR_MESSAGE()
	
	    SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		
			
	END CATCH
END

