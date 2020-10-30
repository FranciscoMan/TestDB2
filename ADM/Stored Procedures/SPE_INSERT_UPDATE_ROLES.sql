﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Juan de dios pérez
-- CRETAE date: 21/03/2017
-- Description: Execute the insert or update process to roles
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_INSERT_UPDATE_ROLES] 
		  @XML_RESULT XML OUT     --APLICA PARA REGRESAR UN NÚMERO 0 PARA ERROR Y 1 PARA CORRECTO
    	, @PIN_ID_ROLE AS INT = NULL
		, @PIN_KY_ROLE AS NVARCHAR(30)
		, @PIN_NM_ROLE AS NVARCHAR(100)
		, @PIN_FG_ACTIVE AS BIT
		, @PIN_XML_FUNCTIONS AS XML
		, @PIN_KY_USER AS NVARCHAR(50)
		, @PIN_NM_PROGRAM AS NVARCHAR(50)
		, @PIN_TRANSACTION_TYPE CHAR(1)             --I=INSERCIÓN   A=ACTUALIZACIÓN
AS 
BEGIN  
	--SE DECLARA E INICIALIZA LA VARIABLE QUE NOS INDICARA SI GENERAMOS LA TRANSACCION EN ESTE SP
	DECLARE @V_EXIST_TRAN BIT = 0
		,@ID_ROLE INT
		,@DT_SYSTEM DATETIME = GETDATE()


    BEGIN TRY
		--SE VERIFICA SI EXISTE UNA TRANSACCION EN EJECUCION
		IF (@@TRANCOUNT = 0) BEGIN
			--EN CASO DE QUE NO SE INICIALIZA LA TRANSACCION
			BEGIN TRANSACTION
			--SE EDITA LA VARIABLE QUE INDICA QUE SE INICIO LA TRANSACCION EN ESTE BLOQUE PARA CANCELARLA SI ES NECESARIO
			SET @V_EXIST_TRAN = 1
		END

		IF @PIN_TRANSACTION_TYPE = 'I' BEGIN
			INSERT INTO ADM.C_ROLE (
				  KY_ROLE
				, NM_ROLE
				, FG_ACTIVE
				, DT_INACTIVE
				, DT_CREATION
				, KY_USER_APP_CREATION
				, NM_PROGAM_CREATE
			) VALUES (
				@PIN_KY_ROLE
				, @PIN_NM_ROLE
				, @PIN_FG_ACTIVE
				, CASE WHEN @PIN_FG_ACTIVE = 0 THEN @DT_SYSTEM ELSE NULL END
				, @DT_SYSTEM
				, @PIN_KY_USER
				, @PIN_NM_PROGRAM
			)

			SET @ID_ROLE = SCOPE_IDENTITY()

			INSERT INTO ADM.C_ROLE_FUNCTION (ID_ROLE, ID_FUNCTION)
			SELECT @ID_ROLE, n.value('@ID_FUNCTION', 'INT')
			FROM @PIN_XML_FUNCTIONS.nodes('/FUNCTIONS/FUNCTION') AS XT(n)


		END

		IF @PIN_TRANSACTION_TYPE = 'U' AND @PIN_ID_ROLE IS NOT NULL BEGIN

			SET @ID_ROLE = @PIN_ID_ROLE

			UPDATE ADM.C_ROLE
			SET KY_ROLE = @PIN_KY_ROLE
				, NM_ROLE = @PIN_NM_ROLE
				, DT_INACTIVE = CASE WHEN FG_ACTIVE = 1 AND @PIN_FG_ACTIVE = 0 THEN @DT_SYSTEM ELSE DT_INACTIVE END
				, FG_ACTIVE = @PIN_FG_ACTIVE
				, DT_UPDATE = @DT_SYSTEM
				, KY_USER_APP_UPDATE = @PIN_KY_USER
				, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
			WHERE ID_ROLE = @ID_ROLE

			DELETE FROM ADM.C_ROLE_FUNCTION WHERE ID_ROLE = @ID_ROLE

			INSERT INTO ADM.C_ROLE_FUNCTION (ID_ROLE, ID_FUNCTION)
			SELECT @ID_ROLE, n.value('@ID_FUNCTION', 'INT')
			FROM @PIN_XML_FUNCTIONS.nodes('/FUNCTIONS/FUNCTION') AS XT(n)

	END

		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
		-- EL XML DEVUELVE EL ERROR INDICADO POR SQL Y UN MSJ DE ERROR GENÉRICO

		--SI SE GENERO UNA TRANSACCION EN ESTE BLOQUE LA TERMINARA
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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the role')
		
			
	END CATCH
END





