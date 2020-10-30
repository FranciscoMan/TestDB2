-- ================================================================
-- Proyecto: Plaskolite v2
-- Copyright (c) - Vitek - 2020
-- Author: Cynthia Aideé Alvarez.
-- CREATE date: 01/16/2020
-- Description: INSERT AUTHORIZATION BY FOREMAN. 
-- =================================================================
CREATE PROCEDURE   [PRD].[SPE_INSERT_FOREMAN_AUTHORIZATION]
	@XML_RESULT XML  = '' OUT,
	@PIN_KY_USER NVARCHAR(80),
	@PIN_KY_SHIFT VARCHAR(50)
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
						BEGIN
						INSERT INTO PRD.K_FOREMAN_AUTHORIZATION(
						KY_USER_FOREMAN,
						KY_SHIFT,
						DT_SYSTEM
						)VALUES(
						@PIN_KY_USER,
						@PIN_KY_SHIFT,
						GETDATE()
						)
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
