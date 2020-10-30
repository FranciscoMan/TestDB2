-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Davalos Romero
-- CRETAE date: 07/12/2017
-- Description: Insert or update a new Push Report with his production lines, items, materials, ocurrences and overtimes
-- 
-- Use of Paremeters (using id instead):
-- @PIN_ID_PRODUCTION_LINE: 'line2,line4,line5...' (lineId) --> (int)
-- @PIN_ID_ITEM: 'item7,line2,anotherItem,line2...' (itemId,lineId) --> (int,int)
-- @PIN_ID_MATERIAL: 'mat44,item7,line2,mat55,item?,line?...' (matID,itemId,lineId) --> (int,int,int)
-- @PIN_NO_PERCENTAGE: 'matPer,item7,line2,matPer,item?,line?...' (matPercentage,itemId,lineId) --> (int,int,int)
-- @PIN_NM_OCURRENCE: 'ocurrence1,reason,ocurrence2,reason...' (nm_ocurrence, nm_reason) --> (varchar,varchar)
-- @PIN_NM_OVERTIME: 'overtime1,reason,date1,overtime2,reason2,date2' (nm_overtime, nm_reason, dateOvertime) --> (varchar,varchar,date)
-- @PIN_TYPE_TRANSACTION: (varchar) --> ('I' = insert)
-- @PIN_FG_OVERWRITE: (bool) --> (true = overwrites report if it already exists; false = it doesn't insert if the report exists)
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_INSERT_UPDATE_K_PUSH_REPORT]
			@XML_RESULT XML = '' OUT,									-- 0 means error
			@PIN_DT_DATE_REPORT AS DATETIME = NULL,
			@PIN_NM_SHIFT AS VARCHAR(20) = NULL,
			@PIN_ID_PRODUCTION_LINE VARCHAR(MAX) = NULL,
			@PIN_ID_ITEM VARCHAR(MAX) = NULL,
			@PIN_ID_MATERIAL VARCHAR(MAX) = NULL,
			@PIN_NO_PERCENTAGE VARCHAR(MAX) = NULL,
			@PIN_NM_OCURRENCE VARCHAR(MAX) = NULL,
			@PIN_NM_OVERTIME VARCHAR(MAX) = NULL,
			@PIN_TYPE_TRANSACTION CHAR(1),
			@PIN_FG_OVERWRITE BIT					-- Overwrite a report if it already exists, 1 overwrite, 0 no overwrite
	AS
	BEGIN
		DECLARE @V_EXIST_TRAN BIT = 0
		BEGIN TRY
			IF (@@TRANCOUNT = 0)
			BEGIN
				BEGIN TRANSACTION 
				SET @V_EXIST_TRAN = 1
			END

			IF (@PIN_TYPE_TRANSACTION = 'I')
			BEGIN
				-- Getting KY_SHIFT (SHIFT [1||2]) from the NM_SHIFT (SHIFT [A||B||C||D])
				DECLARE @KY_SHIFT_CONVERTED VARCHAR(50)

				IF(@PIN_NM_SHIFT LIKE '%A' OR @PIN_NM_SHIFT LIKE '%C')
					SET @KY_SHIFT_CONVERTED = 'SF-1'
				ELSE
					SET @KY_SHIFT_CONVERTED = 'SF-2'

				-- Verify if that Push Report exists
				DECLARE @V_FG_REPORT_EXISTS BIT = (
					SELECT COUNT(*)
					FROM PRD.K_PUSH_REPORT pr
					WHERE pr.DT_DATE_REPORT = @PIN_DT_DATE_REPORT AND pr.KY_SHIFT = @KY_SHIFT_CONVERTED	
				)

				-- If exists we delete it
				IF(@V_FG_REPORT_EXISTS = 1 AND @PIN_FG_OVERWRITE = 1)
				BEGIN
					DELETE FROM PRD.K_PUSH_REPORT 
					WHERE DT_DATE_REPORT = @PIN_DT_DATE_REPORT AND KY_SHIFT = @KY_SHIFT_CONVERTED
				END

				IF((@V_FG_REPORT_EXISTS = 0) OR (@V_FG_REPORT_EXISTS = 1 AND @PIN_FG_OVERWRITE = 1))
				BEGIN
						-- Borramos las tablas temporales si existen
					IF OBJECT_ID('tempdb..#TEMP_K_PR_PRODUCTION_LINE') IS NOT NULL
						DROP TABLE #TEMP_K_PR_PRODUCTION_LINE
					IF OBJECT_ID('tempdb..#TEMP_K_PR_ITEM') IS NOT NULL
						DROP TABLE #TEMP_K_PR_ITEM
					IF OBJECT_ID('tempdb..#TEMP_K_PR_MAT_ID') IS NOT NULL
						DROP TABLE #TEMP_K_PR_MAT_ID
					IF OBJECT_ID('tempdb..#TEMP_K_PR_MAT_NO') IS NOT NULL
						DROP TABLE #TEMP_K_PR_MAT_NO
					IF OBJECT_ID('tempdb..#TEMP_K_PR_OCURRENCE') IS NOT NULL
						DROP TABLE #TEMP_K_PR_OCURRENCE
					IF OBJECT_ID('tempdb..#TEMP_K_PR_OVERTIME') IS NOT NULL
						DROP TABLE #TEMP_K_PR_OVERTIME

					-- Creacion de la tabla temporal #TEMP_K_PR_PRODUCTION_LINE, para guardar todos los tokens líneas. tomadas de la variable @PIN_ID_PRODUCTION
					CREATE TABLE #TEMP_K_PR_PRODUCTION_LINE (
						ID_INDEX INT IDENTITY(1,1) PRIMARY KEY,
						TOKEN VARCHAR(80)
					)
					INSERT INTO #TEMP_K_PR_PRODUCTION_LINE
					SELECT NAME AS 'TOKEN'
					FROM splitstring(@PIN_ID_PRODUCTION_LINE)

					-- Creacion de la tabla temporal #TEMP_K_PR_ITEM, para guardar todos los tokens items de una línea. tomados de la variable @PIN_ID_ITEM 
					CREATE TABLE #TEMP_K_PR_ITEM (
						ID_INDEX INT IDENTITY(1,1) PRIMARY KEY,
						TOKEN VARCHAR(80)
					)
					INSERT INTO #TEMP_K_PR_ITEM
					SELECT NAME AS 'TOKEN'
					FROM splitstring(@PIN_ID_ITEM)

					-- Creacion de la tabla temporal #TEMP_K_PR_MATERIAL_ID, para guardar todos los tokens material de un item. tomados de la variable @PIN_ID_MATERIAL
					CREATE TABLE #TEMP_K_PR_MAT_ID (
						ID_INDEX INT IDENTITY(1,1) PRIMARY KEY,
						TOKEN VARCHAR(80)
					)
					INSERT INTO #TEMP_K_PR_MAT_ID
					SELECT NAME AS 'TOKEN'
					FROM splitstring(@PIN_ID_MATERIAL)

					-- Creacion de la tabla temporal #TEMP_K_PR_MATERIAL_PER, para guardar todos los tokens porcentaje material de un item. tomados de la variable @PIN_NO_MATERIAL
					CREATE TABLE #TEMP_K_PR_MAT_NO (
						ID_INDEX INT IDENTITY(1,1) PRIMARY KEY,
						TOKEN VARCHAR(80)
					)
					INSERT INTO #TEMP_K_PR_MAT_NO
					SELECT NAME AS 'TOKEN'
					FROM splitstring(@PIN_NO_PERCENTAGE)

					-- Creacion de la tabla temporal #TEMP_K_PR_OCURRENCE, para guardar todos los tokens ocurrencia de un reporte. tomados de la variable @PIN_NM_OCURRENCE
					CREATE TABLE #TEMP_K_PR_OCURRENCE (
						ID_INDEX INT IDENTITY(1,1) PRIMARY KEY,
						TOKEN VARCHAR(80)
					)
					INSERT INTO #TEMP_K_PR_OCURRENCE
					SELECT NAME AS 'TOKEN'
					FROM splitstring(@PIN_NM_OCURRENCE)

					-- Creacion de la tabla temporal #TEMP_K_PR_OVERTIME, para guardar todos los overtime de un reporte. tomados de la variable @PIN_NM_OVERTIME
					CREATE TABLE #TEMP_K_PR_OVERTIME (
						ID_INDEX INT IDENTITY(1,1) PRIMARY KEY,
						TOKEN VARCHAR(80)
					)
					INSERT INTO #TEMP_K_PR_OVERTIME
					SELECT NAME AS 'TOKEN'
					FROM splitstring(@PIN_NM_OVERTIME)

					-- Declaramos las variables para contar el número de registros de cada tabla temporal
					DECLARE
						@V_ROWS_TEMP_PRODUCTION_LINES INT = (
							(SELECT COUNT(*) FROM #TEMP_K_PR_PRODUCTION_LINE)
						),
						@V_ROWS_TEMP_ITEMS INT = (
							(SELECT COUNT(*) FROM #TEMP_K_PR_ITEM)/2  -- dividimos entre dos, por que cada dos registros conforman una línea
						),
						@V_ROWS_TEMP_MAT_ID INT = (
							(SELECT COUNT(*) FROM #TEMP_K_PR_MAT_ID)/3  -- dividimos entre tres, por que cada tres registros conforman un id material
						),
						@V_ROWS_TEMP_MAT_NO INT = (
							(SELECT COUNT(*) FROM #TEMP_K_PR_MAT_NO)/3  -- dividimos entre tres, por que cada tres registros conforman un porcentaje material
						),
						@V_ROWS_TEMP_OCURRENCE INT = (
							(SELECT COUNT(*) FROM #TEMP_K_PR_OCURRENCE)/2  -- dividimos entre dos, por que cada dos registros conforman una ocurrencia en el reporte
						),
						@V_ROWS_TEMP_OVERTIME INT = (
							(SELECT COUNT(*) FROM #TEMP_K_PR_OVERTIME)/3  -- dividimos entre dos, por que cada tres registros conforman un retraso en el reporte
						)

					INSERT INTO PRD.K_PUSH_REPORT (
						DT_DATE_REPORT,
						KY_SHIFT
					) 
					VALUES (
						@PIN_DT_DATE_REPORT,
						@KY_SHIFT_CONVERTED
					)
					-- Obtenemos el id autoincremental
					DECLARE @V_ID_PUSH_REPORT INT = (
						SELECT IDENT_CURRENT('PRD.K_PUSH_REPORT')
					)

					-- VARIABLES TO CAST A STRING TO INT
					DECLARE @STRING_LINE_ID VARCHAR(MAX)
					DECLARE @CASTED_LINE_ID INT
					DECLARE @INDEX_LINE INT = 1 --Comenzamos en el primer registro

					WHILE (@INDEX_LINE <= @V_ROWS_TEMP_PRODUCTION_LINES)
					BEGIN
						-- Tomamos el registro "n" y lo guardamos en una cadena
						SET @STRING_LINE_ID = (SELECT TOKEN FROM (
							SELECT
								TOKEN,
								ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
							FROM #TEMP_K_PR_PRODUCTION_LINE -- la tabla temporal de la que queremos sacar token
						) AS foo
						WHERE ROW_N = @INDEX_LINE)
						-- Casteamos la cadena a int
						SET @CASTED_LINE_ID = CAST(@STRING_LINE_ID AS INT)

						-- insertamos la linea
						INSERT INTO PRD.K_PR_PRODUCTION_LINE (
							ID_PUSH_REPORT,
							ID_PRODUCTION_LINE
						)
						VALUES (
							@V_ID_PUSH_REPORT,
							@CASTED_LINE_ID
						)
						-- Obtenemos el id autoincremental de la linea actual
						DECLARE @V_ID_PR_PRODUCTION_LINE INT = (
							SELECT IDENT_CURRENT('PRD.K_PR_PRODUCTION_LINE')
						)

						DECLARE @STRING_ITEM_ID VARCHAR(MAX)
						DECLARE @STRING_ITEM_LINE_ID VARCHAR(MAX)
						DECLARE @CASTED_ITEM_ID INT
						DECLARE @CASTED_ITEM_LINE_ID INT
						DECLARE @INDEX_ITEM INT = 1

						WHILE (@INDEX_ITEM <= @V_ROWS_TEMP_ITEMS)
						BEGIN
							-- Tomamos el registro "n" y lo guardamos en la cadena del item
							SET @STRING_ITEM_ID = (SELECT TOKEN FROM (
								SELECT
									TOKEN,
									ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
								FROM #TEMP_K_PR_ITEM TEMP -- la tabla temporal de la que queremos sacar token
							) AS foo
							WHERE ROW_N = ((@INDEX_ITEM*2)-1)) -- -1 para obtener el id del item y -0 para obtener el id de la linea del item
							-- Tomamos el registro "n" y lo guardamos en la cadena de la linea del item
							SET @STRING_ITEM_LINE_ID = (SELECT TOKEN FROM (
								SELECT
									TOKEN,
									ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
								FROM #TEMP_K_PR_ITEM -- la tabla temporal de la que queremos sacar token
							) AS foo
							WHERE ROW_N = (@INDEX_ITEM*2)) -- -1 para obtener el id del item y -0 para obtener el id de la linea del item
							-- Casteamos las cadenas a int
							SET @CASTED_ITEM_ID = CAST(@STRING_ITEM_ID AS INT)
							SET @CASTED_ITEM_LINE_ID = CAST(@STRING_ITEM_LINE_ID AS INT)


							IF(@CASTED_ITEM_LINE_ID = @CASTED_LINE_ID)
							BEGIN
								INSERT INTO PRD.K_PR_ITEM (
									ID_PR_PRODUCTION_LINE,
									ID_ITEM
								)
								VALUES (
									@V_ID_PR_PRODUCTION_LINE,
									@CASTED_ITEM_ID
								)
								-- Obtenemos el id autoincremental del item actual
								DECLARE @V_ID_PR_ITEM INT = (
									SELECT IDENT_CURRENT('PRD.K_PR_ITEM')
								)

								DECLARE @STRING_MAT_ID VARCHAR(MAX) -- para el id del material
								DECLARE @STRING_MAT_NO VARCHAR(MAX) -- para el porcentaje del material
								DECLARE @STRING_MAT_ITEM_ID VARCHAR(MAX)
								DECLARE @STRING_MAT_LINE_ID VARCHAR(MAX)
								DECLARE @CASTED_MAT_ID VARCHAR(MAX)
								DECLARE @CASTED_MAT_NO VARCHAR(MAX)
								DECLARE @CASTED_MAT_ITEM_ID VARCHAR(MAX)
								DECLARE @CASTED_MAT_LINE_ID VARCHAR(MAX)
								DECLARE @INDEX_MAT INT = 1

								WHILE (@INDEX_MAT <= @V_ROWS_TEMP_MAT_ID)
								BEGIN
									-- Tomamos el registro "n" y lo guardamos en la cadena del material id
											SET @STRING_MAT_ID = (SELECT TOKEN FROM (
												SELECT
													TOKEN,
													ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
												FROM #TEMP_K_PR_MAT_ID TEMP -- la tabla temporal de la que queremos sacar token
											) AS foo
											WHERE ROW_N = ((@INDEX_MAT*3)-2)) -- -2 para obtener el id del mat y -1 para obtener el id del item y -2 para el id de la linea
									-- Tomamos el registro "n" y lo guardamos en la cadena del material porcentaje
									SET @STRING_MAT_NO = (SELECT TOKEN FROM (
												SELECT
													TOKEN,
													ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
												FROM #TEMP_K_PR_MAT_NO TEMP -- la tabla temporal de la que queremos sacar token
											) AS foo
											WHERE ROW_N = ((@INDEX_MAT*3)-2)) -- -2 para obtener el id del mat y -1 para obtener el id del item y -2 para el id de la linea
									-- Tomamos el registro "n" y lo guardamos en la cadena item del material
											SET @STRING_MAT_ITEM_ID = (SELECT TOKEN FROM (
												SELECT
													TOKEN,
													ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
												FROM #TEMP_K_PR_MAT_ID TEMP -- la tabla temporal de la que queremos sacar token
											) AS foo
											WHERE ROW_N = ((@INDEX_MAT*3)-1)) -- -2 para obtener el id del mat y -1 para obtener el id del item y -2 para el id de la linea
									-- Tomamos el registro "n" y lo guardamos en la cadena linea del material
											SET @STRING_MAT_LINE_ID = (SELECT TOKEN FROM (
												SELECT
													TOKEN,
													ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
												FROM #TEMP_K_PR_MAT_ID TEMP -- la tabla temporal de la que queremos sacar token
											) AS foo
											WHERE ROW_N = ((@INDEX_MAT*3)-0)) -- -2 para obtener el id del mat y -1 para obtener el id del item y -2 para el id de la linea
									-- Casteamos las cadenas a int
									SET @CASTED_MAT_ID = CAST(@STRING_MAT_ID AS INT)
									SET @CASTED_MAT_NO = CAST(@STRING_MAT_NO AS INT)
									SET @CASTED_MAT_ITEM_ID = CAST(@STRING_MAT_ITEM_ID AS INT)
									SET @CASTED_MAT_LINE_ID = CAST(@STRING_MAT_LINE_ID AS INT)

									IF(@CASTED_MAT_LINE_ID = @CASTED_LINE_ID AND @CASTED_MAT_ITEM_ID = @CASTED_ITEM_ID)
									BEGIN
										INSERT INTO PRD.K_PR_MATERIAL(
											ID_PR_ITEM,
											ID_MATERIAL,
											NO_PERCENTAGE
										)
										VALUES (
											@V_ID_PR_ITEM,
											@CASTED_MAT_ID,
											@CASTED_MAT_NO
										)
									END
									SET @INDEX_MAT = @INDEX_MAT + 1 -- Incrementamos el contador de materiales
								END -- END WHILE, MATS
							END 
							SET @INDEX_ITEM = @INDEX_ITEM + 1 -- Incrementamos el contador de items
						END -- END WHILE, ITEMS
						SET @INDEX_LINE = @INDEX_LINE + 1 -- Incrementamos el contador de lineas
					END -- END WHILE, LINES

					DECLARE @STRING_OCURRENCE_NAME VARCHAR(255)
					DECLARE @STRING_OCURRENCE_REASON VARCHAR(255)
					DECLARE @INDEX_OCURRENCE INT = 1

					WHILE (@INDEX_OCURRENCE <= @V_ROWS_TEMP_OCURRENCE)
					BEGIN
						-- Tomamos el registro "n" y lo guardamos en la cadena del nombre de ocurrencia
						SET @STRING_OCURRENCE_NAME = (SELECT TOKEN FROM (
							SELECT
								TOKEN,
								ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
							FROM #TEMP_K_PR_OCURRENCE TEMP -- la tabla temporal de la que queremos sacar token
						) AS foo
						WHERE ROW_N = ((@INDEX_OCURRENCE*2)-1)) -- -1 para obtener el nombre de ocurrencia y -0 para obtener la razón de ocurrencia
						-- Tomamos el registro "n" y lo guardamos en la cadena de la razón de ocurrencia
						SET @STRING_OCURRENCE_REASON = (SELECT TOKEN FROM (
							SELECT
								TOKEN,
								ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
							FROM #TEMP_K_PR_OCURRENCE TEMP -- la tabla temporal de la que queremos sacar token
						) AS foo
						WHERE ROW_N = ((@INDEX_OCURRENCE*2)-0)) -- -1 para obtener el nombre de ocurrencia y -0 para obtener la razón de ocurrencia

						-- PUSH REPORT'S Ocurrence insertion
						INSERT INTO PRD.K_PR_OCURRENCE(
							ID_PUSH_REPORT,
							NM_NAME,
							NM_REASON
						)
						VALUES (
							@V_ID_PUSH_REPORT,
							@STRING_OCURRENCE_NAME,
							@STRING_OCURRENCE_REASON
						)

						SET @INDEX_OCURRENCE = @INDEX_OCURRENCE + 1 -- Incrementamos el contador de ocurrencias
					END -- END WHILE, OCURRENCE

					DECLARE @STRING_OVERTIME_NAME VARCHAR(255)
					DECLARE @STRING_OVERTIME_REASON VARCHAR(255)
					DECLARE @STRING_OVERTIME_DATE VARCHAR(100)
					DECLARE @INDEX_OVERTIME INT = 1

					WHILE (@INDEX_OVERTIME <= @V_ROWS_TEMP_OVERTIME)
					BEGIN
						-- Tomamos el registro "n" y lo guardamos en la cadena de nombre de overtime
						SET @STRING_OVERTIME_NAME = (SELECT TOKEN FROM (
							SELECT
								TOKEN,
								ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
							FROM #TEMP_K_PR_OVERTIME TEMP -- la tabla temporal de la que queremos sacar token
						) AS foo
						WHERE ROW_N = ((@INDEX_OVERTIME*3)-2)) -- -2 para obtener el nombre de overtime y -1 para obtener la razón de overtime y -0 para la fecha
						-- Tomamos el registro "n" y lo guardamos en la cadena de razón de overtime
						SET @STRING_OVERTIME_REASON = (SELECT TOKEN FROM (
							SELECT
								TOKEN,
								ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
							FROM #TEMP_K_PR_OVERTIME TEMP -- la tabla temporal de la que queremos sacar token
						) AS foo
						WHERE ROW_N = ((@INDEX_OVERTIME*3)-1)) -- -2 para obtener el nombre de overtime y -1 para obtener la razón de overtime y -0 para la fecha
						-- Tomamos el registro "n" y lo guardamos en la cadena de fecha de overtime
						SET @STRING_OVERTIME_DATE = (SELECT TOKEN FROM (
							SELECT
								TOKEN,
								ROW_NUMBER() OVER (ORDER BY ID_INDEX ASC) AS ROW_N
							FROM #TEMP_K_PR_OVERTIME TEMP -- la tabla temporal de la que queremos sacar token
						) AS foo
						WHERE ROW_N = ((@INDEX_OVERTIME*3)-0)) -- -2 para obtener el nombre de overtime y -1 para obtener la razón de overtime y -0 para la fecha

						INSERT INTO PRD.K_PR_OVERTIME (
							ID_PUSH_REPORT,
							NM_NAME,
							NM_REASON,
							NM_SCHEDULE
						)
						VALUES (
							@V_ID_PUSH_REPORT,
							@STRING_OVERTIME_NAME,
							@STRING_OVERTIME_REASON,
							@STRING_OVERTIME_DATE
						)

						SET @INDEX_OVERTIME = @INDEX_OVERTIME + 1 -- Incrementamos el contador de overtime
					END -- END WHILE, OVERTIME
				END -- END IF WITH OVERWRITE
			END -- END INSERTION
				
			SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
			SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
			SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
			IF(@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			BEGIN
				COMMIT
			END
		END TRY
		BEGIN CATCH
			IF(@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
				BEGIN
					ROLLBACK
				END
			DECLARE @KY_ERROR INT	= ERROR_NUMBER()
			DECLARE @ERROR_MESSAGE VARCHAR(250) = ERROR_MESSAGE()
			
			SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, @KY_ERROR, 'ERROR')
			SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR,'Ocurrió un error al procesar el registro')
			SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		END CATCH
	END


