-- ================================================================
-- Proyecto: Plaskolite v2
-- Copyright (c) - Vitek - 2020
-- Author: Cynthia Aideé Alvarez.
-- CREATE date: 01/15/2020
-- Description: INSERT TABLE SHIFT_FOREMAN BY SHIFT TIME.
-- =================================================================

CREATE PROCEDURE   [PRD].[SPE_INSERT_SHIFT_FOREMAN]
		@XML_RESULT XML  = '' OUT
		, @PIN_KY_SHIFT_TIME AS VARCHAR(80) = NULL -- SF-1 OR SF-2
		, @PIN_KY_USER AS NVARCHAR(80) = NULL        
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
							INSERT INTO PRD.K_SHIFT_FOREMAN(
								KY_SHIFT_TIME,
								KY_USER, 
								DT_SYSTEM
							)VALUES(
								@PIN_KY_SHIFT_TIME,
								@PIN_KY_USER,
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
