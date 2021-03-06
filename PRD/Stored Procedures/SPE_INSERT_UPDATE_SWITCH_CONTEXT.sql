﻿-- ================================================================
-- Proyecto: Plaskolite v2
-- Copyright (c) - Vitek - 2020
-- Author: Cynthia Aideé Alvarez.
-- CREATE date: 03/02/2020
-- Description: INSERT UPDATE SWITCH CONTEXT.
-- =================================================================
CREATE PROCEDURE   [PRD].[SPE_INSERT_UPDATE_SWITCH_CONTEXT]
	  @XML_RESULT				XML             = '' OUT
	, @PIN_NM_SWITCH		    AS NVARCHAR(80) = NULL
	, @PIN_FG_SWITCH            AS BIT          = NULL
	, @PIN_ID_BRANCH_PLANT INT
	--, @PIN_NM_BRANCH_PLANT NVARCHAR(80)
	, @PIN_DT_CREATION		    AS DATETIME     = NULL
	, @PIN_DT_UPDATE		    AS DATETIME     = NULL
	, @PIN_KY_USER_APP_CREATION AS NVARCHAR(50) = NULL
	, @PIN_KY_USER_APP_UPDATE   AS NVARCHAR(50) = NULL
	, @PIN_TYPE_TRANSACTION     AS CHAR(1)      = NULL -- I or U
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
							INSERT INTO PRD.C_SWITCH_CONTEXT(
							  NM_SWITCH  
							 ,FG_SWITCH 
							 ,DT_CREATION
							 ,KY_USER_APP_CREATION 
							) VALUES(
							  @PIN_NM_SWITCH
							 ,@PIN_FG_SWITCH
							 ,@PIN_DT_CREATION
							 ,@PIN_KY_USER_APP_CREATION
							)
						END ELSE 
							   BEGIN -- IT IS AN UPDATE.
									UPDATE PRD.C_SWITCH_CONTEXT SET
									  FG_SWITCH = @PIN_FG_SWITCH
									, DT_UPDATE = @PIN_DT_UPDATE
									, KY_USER_APP_UPDATE = @PIN_KY_USER_APP_UPDATE
									WHERE NM_SWITCH = @PIN_NM_SWITCH AND ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT
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



