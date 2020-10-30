﻿CREATE PROCEDURE  [PRD].[SPE_INSERT_UPDATE_SWITCH_REPORT]
    @XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
	@PIN_NM_REPORT varchar(100) = null,
	@PIN_FG_SWITCH BIT = null,
	@PIN_KY_BRANCH_PLANT varchar(50) = null,
	@PIN_TYPE_TRANSACTION     AS CHAR(1)      = NULL -- I or U
	
AS
BEGIN
		DECLARE @V_EXIST_TRAN BIT = 0

					BEGIN TRY
					-- VERIFY THAT EXIST A TRANSACTION.
					IF (@@TRANCOUNT = 0)
						BEGIN
						-- IN CASE THAT THE TRANSACTION DOESN'T WORK, WE INITIALIZE THE VARIABLE.
							BEGIN TRANSACTION 
								SET @V_EXIST_TRAN = 1
						END
					IF (@PIN_TYPE_TRANSACTION = 'I')
						BEGIN
							INSERT INTO PRD.C_SWITCH_REPORT(
							  NM_REPORT  
							 ,FG_SWITCH
							 ,KY_BRANCH_PLANT
							) VALUES(
							  @PIN_NM_REPORT
							 ,@PIN_FG_SWITCH
							 ,@PIN_KY_BRANCH_PLANT 
							)
						END ELSE 
							   BEGIN -- IT IS AN UPDATE.
									UPDATE PRD.C_SWITCH_REPORT SET
									  FG_SWITCH = @PIN_FG_SWITCH
									WHERE NM_REPORT = @PIN_NM_REPORT
								END
                SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
				
				IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
					COMMIT	
				END TRY
					BEGIN CATCH		
					--IF IT OCCURS A ERROR IN THIS BLOCK THE TRANSACTION GET CANCELED
					IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
						ROLLBACK
			
					DECLARE @KY_ERROR INT				  = ERROR_NUMBER()
					DECLARE @ERROR_MESSAGE NVARCHAR(250)  = ERROR_MESSAGE()
	
					SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
					SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
					SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')	
				   END CATCH
				
	END
