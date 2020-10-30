﻿-- ================================================================
-- Proyecto: Plaskolite v2
-- Copyright (c) - Vitek - 2020
-- Author: Cynthia Aideé Alvarez.
-- CREATE date: 07/15/2020
-- Description: INSERT AND UPDATE FROM C_SHIFT_TIME.
-- =================================================================

CREATE PROCEDURE [ADM].[SPE_INSERT_UPDATE_SHIFT_TIME]  
	    @XML_RESULT					 XML			 = '' OUT,
		@PIN_ID_SHIFT_TIME		     AS INT          = NULL, -- PRIMARY KEY OF THE TABLE.
		@PIN_ID_SHIFT		         AS INT          = NULL, -- FOREIGN KEY...
		@PIN_KY_SHIFT                AS NVARCHAR(50) = NULL, -- KEY OF YOUR SHIFT (SF-A, SF..N)
		@PIN_KY_SHIFT_TIME           AS NVARCHAR(50) = NULL, -- KEY OF YOUR SHIFT (SF-A, SF..N)
		@PIN_NM_SHIFT_TIME           AS NVARCHAR(80) = NULL, -- SHIFT NAME ( Shift A... Shift N).
		@PIN_NM_SHIFT                AS NVARCHAR(80) = NULL, -- VALUE THAT BELONGS TO TABLE C_SHIFT.
		@PIN_NO_SHIFT_TIME		     AS INT          = NULL, -- 1 to 12.
		@PIN_INITIAL_SHIFT_TIME      AS VARCHAR(80)  = NULL, -- VALUE THAT BELONGS TO TABLE C_SHIFT.
		@PIN_FINAL_SHIFT_TIME        AS VARCHAR(80)  = NULL, -- VALUE THAT BELONGS TO TABLE C_SHIFT.
		@PIN_ID_BRANCH_PLANT         AS INT          = NULL, -- BRANCH PLANT :D
		@PIN_TYPE_TRANS              AS CHAR(1)      = NULL -- I o U 
	AS 
		BEGIN
		-- WE DECLARE A VARIABLE TO MANAGE  THE TRANSACTION IF EXIST OR NOT, AN OTHER DECLARATIONS.
				DECLARE @V_EXIST_TRAN  AS BIT = 0
				BEGIN TRY
				-- VERIFY EXIST TRANSACTION.
				IF (@@TRANCOUNT = 0)
					BEGIN
					-- IN CASE THAT THE TRANSACTION DOESN'T INIT, WE INITIALIZE THE VARIABLE.
						BEGIN TRANSACTION 
							SET @V_EXIST_TRAN = 1
					END
					IF @PIN_TYPE_TRANS = 'I'
						BEGIN 
							INSERT INTO ADM.C_SHIFT_TIME(
							 ID_SHIFT
							,KY_SHIFT
							,KY_SHIFT_TIME      
							,NM_SHIFT_TIME      
							,NM_SHIFT           
							,NO_SHIFT_TIME		
							,INITIAL_SHIFT_TIME 
							,FINAL_SHIFT_TIME   
							,ID_BRANCH_PLANT          
							) 
							VALUES(
						     @PIN_ID_SHIFT		
							,@PIN_KY_SHIFT
							,'SF-' + @PIN_KY_SHIFT_TIME       
							,@PIN_NM_SHIFT_TIME      
							,@PIN_NM_SHIFT           
							,@PIN_NO_SHIFT_TIME		
							,CONVERT(TIME, @PIN_INITIAL_SHIFT_TIME)
							,CONVERT(TIME, @PIN_FINAL_SHIFT_TIME)
							,@PIN_ID_BRANCH_PLANT     						
							)

					   END 
					   ELSE --AN UPDATE
						   BEGIN

							  UPDATE ADM.C_SHIFT_TIME SET 
					 ID_SHIFT		    =  @PIN_ID_SHIFT
					,KY_SHIFT			= @PIN_KY_SHIFT
					,KY_SHIFT_TIME      =  @PIN_KY_SHIFT_TIME      
					,NM_SHIFT_TIME      =  @PIN_NM_SHIFT_TIME      
					,NM_SHIFT           =  @PIN_NM_SHIFT  
					,NO_SHIFT_TIME		=  @PIN_NO_SHIFT_TIME	
					,INITIAL_SHIFT_TIME = CONVERT(TIME, @PIN_INITIAL_SHIFT_TIME)
					,FINAL_SHIFT_TIME   = CONVERT(TIME, @PIN_FINAL_SHIFT_TIME)   
					,ID_BRANCH_PLANT    = @PIN_ID_BRANCH_PLANT  

								WHERE ID_SHIFT_TIME = @PIN_ID_SHIFT_TIME
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

