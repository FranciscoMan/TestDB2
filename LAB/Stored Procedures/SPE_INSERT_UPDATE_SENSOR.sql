﻿CREATE PROCEDURE   [LAB].[SPE_INSERT_UPDATE_SENSOR]
			@XML_RESULT XML  = '' OUT,
			@NM_SENSOR  AS VARCHAR(50)  = NULL, -- DATA REQUIRED
			@KY_SENSOR  AS NVARCHAR(30) = NULL, -- DATA REQUIRED
			@IP_ADDRESS AS VARCHAR(15)  = NULL,
			@FG_ACTIVE  AS BIT		    = NULL,
			@LOCATION   AS VARCHAR(20)  = NULL, --
			@TYPE       AS NVARCHAR(40) = NULL,
			@PORT       AS VARCHAR(20)	= NULL,
			@FG_STATUS  AS BIT			= NULL,
			@PIN_TYPE_TRANSACTION CHAR(1)
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
					-- IF MY FLAG IS 'I' (INSERT), THEN:
					IF @PIN_TYPE_TRANSACTION = 'I'
						BEGIN 
						INSERT INTO LAB.K_SENSORS(
						[NM_SENSOR],
						[KY_SENSOR],
						[IP_ADDRESS],
						[FG_ACTIVE],
						[LOCATION],
						[TYPE],
						[PORT],
						[FG_STATUS]
						) 
						VALUES(
						@NM_SENSOR,
						@KY_SENSOR,
						@IP_ADDRESS,
						@FG_ACTIVE,
						@LOCATION,
						@TYPE,
						@PORT,
						@FG_STATUS
						)
				END ELSE --THEN, THE FLAG IS AN UPDATE.
							BEGIN
				-- EVERY UPDATE NEEDS THE KY_SENSOR, NOT ID_SENSOR.
						UPDATE LAB.K_SENSORS SET
						[NM_SENSOR]  = @NM_SENSOR,
						[IP_ADDRESS] = @IP_ADDRESS,
						[FG_ACTIVE]  = @FG_ACTIVE,
						[LOCATION]	 = @LOCATION,
						[TYPE]		 = @TYPE,
						[PORT]		 = @PORT,
						[FG_STATUS]	 = @FG_STATUS
						WHERE [KY_SENSOR] = @KY_SENSOR  			
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

	


	--------------------------------------------- procedimiento para actualizar el status del sensor



