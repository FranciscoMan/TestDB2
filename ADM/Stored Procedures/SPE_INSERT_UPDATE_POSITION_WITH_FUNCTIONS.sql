﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Daniel Dávalos Romero
-- CRETAE date: 19/06/2020
-- Description: Stored Procedure, that inserts or updates a new position
-- with his respectives functions if it has them, otherwise, it just
-- insert or uPdate a position
-- =============================================
CREATE PROCEDURE  [ADM].[SPE_INSERT_UPDATE_POSITION_WITH_FUNCTIONS] 
		  @XML_RESULT XML = '' OUT ,    -- --0 TO ERROR AND 1 TO CORRECT
		  @PIN_ID_POSITION AS int = NULL,
		  @PIN_KY_POSITION AS nvarchar(50) = NULL,
		  @PIN_NM_POSITION AS nvarchar(300) = NULL,
		  @PIN_DS_POSITION AS nvarchar(500) = NULL,
		  @PIN_KY_DS_AREA AS nvarchar(500) = NULL,
		  @PIN_KY_TELEGRAM AS nvarchar(15) = NULL,
		  @PIN_ID_BRANCH_PLANT AS int = NULL,
		  @PIN_ID_DEPARTMENT AS int = NULL,
		  @PIN_KY_EMAIL AS NVARCHAR(100) = NULL,
		  @PIN_KY_USER_APP_CREATE AS nvarchar(50) = NULL,
		  @PIN_KY_USER_APP_UPDATE AS nvarchar(50) = NULL,
		  @PIN_NM_PROGRAM_CREATE AS nvarchar(50) = NULL,
		  @PIN_NM_PROGRAM_UPDATE AS nvarchar(50) = NULL,
		  @PIN_XML_FUNCTIONS AS XML = NULL,         -- Xml con las funciones asociadas a la posicion
		  @PIN_TRANSACTION_TYPE CHAR(1)             --I=INSERT   U=UPDATE
AS 
BEGIN  
	--SE DECLARA E INICIALIZA LA VARIABLE QUE NOS INDICARA SI GENERAMOS LA TRANSACCION EN ESTE SP
	DECLARE @V_EXIST_TRAN BIT = 0,
		@V_ID_POSITION INT,
		@DT_SYSTEM DATETIME = GETDATE()

	BEGIN TRY
		--SE VERIFICA SI EXISTE UNA TRANSACCION EN EJECUCION
		IF (@@TRANCOUNT = 0) 
		BEGIN
			--EN CASO DE QUE NO SE INICIALIZA LA TRANSACCION
			BEGIN TRANSACTION
			--SE EDITA LA VARIABLE QUE INDICA QUE SE INICIO LA TRANSACCION EN ESTE BLOQUE PARA CANCELARLA SI ES NECESARIO
			SET @V_EXIST_TRAN = 1
	END

	IF @PIN_TRANSACTION_TYPE = 'I' 
	BEGIN

		-- Insertamos la posicion
		INSERT INTO ADM.C_POSITION (
			[KY_POSITION],
			[NM_POSITION],
			[DS_POSITION],
			[ID_DEPARTMENT],
			[KY_TELEGRAM],
			[ID_BRANCH_PLANT],
			[KY_EMAIL],
			[DT_CREATION],
			[KY_USER_APP_CREATION],
			[NM_PROGAM_CREATE]
		)VALUES(
			@PIN_KY_POSITION,
			@PIN_NM_POSITION,
			@PIN_DS_POSITION,
			@PIN_ID_DEPARTMENT,
			@PIN_KY_TELEGRAM,
			@PIN_ID_BRANCH_PLANT,
			@PIN_KY_EMAIL,
			@DT_SYSTEM,
			@PIN_KY_USER_APP_CREATE,
			@PIN_NM_PROGRAM_CREATE
		)

		-- Obtenemos el id generado por la nueva posicion
		SET @V_ID_POSITION = (
			SELECT IDENT_CURRENT('ADM.C_POSITION')
		)

		-- Insertamos las funciones de la posicion
		INSERT INTO ADM.C_POSITION_FUNCTION (ID_POSITION, ID_FUNCTION)
		SELECT @V_ID_POSITION AS ID_POSITION, n.value('@ID_FUNCTION', 'INT') AS ID_FUNCTION
		FROM @PIN_XML_FUNCTIONS.nodes('/FUNCTIONS/FUNCTION') AS T(n)
	END

	IF @PIN_TRANSACTION_TYPE = 'U' AND @PIN_ID_POSITION IS NOT NULL 
	BEGIN

		-- Actualizamos la posicion
		UPDATE ADM.C_POSITION SET
   			[KY_POSITION] = @PIN_KY_POSITION,
			[NM_POSITION] = @PIN_NM_POSITION,
			[DS_POSITION] =@PIN_DS_POSITION,
			[ID_DEPARTMENT] = @PIN_ID_DEPARTMENT,
			[KY_TELEGRAM] = @PIN_KY_TELEGRAM,
			[ID_BRANCH_PLANT] = @PIN_ID_BRANCH_PLANT,
			[KY_EMAIL] = @PIN_KY_EMAIL,
			[DT_UPDATE] =@DT_SYSTEM,
			[KY_USER_APP_UPDATE] = @PIN_KY_USER_APP_UPDATE,
			[NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM_UPDATE
		WHERE [ID_POSITION] = @PIN_ID_POSITION

		-- Borramos las funciones de la posicion
		DELETE FROM ADM.C_POSITION_FUNCTION WHERE ID_POSITION = @PIN_ID_POSITION

		-- Insertamos las funciones actualizadas de la posicion
		INSERT INTO ADM.C_POSITION_FUNCTION (ID_POSITION, ID_FUNCTION)
		SELECT @PIN_ID_POSITION AS ID_POSITION, n.value('@ID_FUNCTION', 'INT') AS ID_FUNCTION
		FROM @PIN_XML_FUNCTIONS.nodes('/FUNCTIONS/FUNCTION') AS T(n)
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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the position')
	END CATCH
END