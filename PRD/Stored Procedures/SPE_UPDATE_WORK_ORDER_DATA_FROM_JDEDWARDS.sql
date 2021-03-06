﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 01/07/2018
-- Description: Updates work order data from JD Edwards
-- =============================================

CREATE PROCEDURE  [PRD].[SPE_UPDATE_WORK_ORDER_DATA_FROM_JDEDWARDS] 
	@XML_RESULT XML = '' OUT --0 TO ERROR AND 1 TO CORRECT
	, @PIN_ID_WORK_ORDER INT
	, @PIN_KY_USER_APP_UPDATE NVARCHAR(50)
	, @PIN_NM_PROGRAM_UPDATE NVARCHAR(50)	
AS
BEGIN
	--WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	BEGIN TRY		   			
		DECLARE @V_EXIST_TRAN BIT = 0	
			, @DT_SYSTEM DATETIME = GETDATE()
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) BEGIN
			BEGIN TRANSACTION

			SET @V_EXIST_TRAN = 1
		END	

		DECLARE @NO_RUN_QTY INT
			, @ID_PRODUCTION_LINE INT
			, @NM_PRODUCTION_LINE NVARCHAR(300)

		SELECT @ID_PRODUCTION_LINE = ID_PRODUCTION_LINE
			, @NO_RUN_QTY = NO_RUN_QTY
			, @NM_PRODUCTION_LINE = NM_PRODUCTION_LINE
		FROM PRD.F_GET_WORK_ORDER_FROM_JDEDWARDS (@PIN_ID_WORK_ORDER)

		UPDATE PRD.K_WORK_ORDER
		SET ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
			, NM_PRODUCTION_LINE = @NM_PRODUCTION_LINE
			, NO_RUN_QTY = @NO_RUN_QTY
			, DT_UPDATE = @DT_SYSTEM
			, KY_USER_APP_UPDATE = @PIN_KY_USER_APP_UPDATE
			, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM_UPDATE
		WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

		CREATE TABLE #T_WORK_ORDERS  (
			ID_WORK_ORDER INT
		)

		INSERT INTO #T_WORK_ORDERS (
			ID_WORK_ORDER
		)
		SELECT KWO.ID_WORK_ORDER 
		FROM PRD.K_WORK_ORDER KWO
		WHERE KWO.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE
			AND KWO.KY_STATUS IN ('SCHEDULED', 'SKIPPED')

		UPDATE KWO
		SET NO_ORDER = W.WARESC
			, NO_SEQ = W.WARESC
			, DT_UPDATE = @DT_SYSTEM
			, KY_USER_APP_UPDATE = @PIN_KY_USER_APP_UPDATE
			, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM_UPDATE
		FROM (SELECT * FROM OPENQUERY(JDEPROD,'SELECT * FROM PRODDTA.F4801')) W
			INNER JOIN PRD.K_WORK_ORDER KWO
				ON W.WADOCO = KWO.ID_WORK_ORDER
		WHERE EXISTS (SELECT TOP 1 1 FROM #T_WORK_ORDERS TWO WHERE W.WADOCO = TWO.ID_WORK_ORDER)

		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Se Actualizo el estatus de la notificación satisfactoriamente', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfully Update of notification status', 'EN')
		
		--IN THIS BLOCK ALL TRANSACTIONS WILL DELETED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1) BEGIN
			COMMIT
		END

	END TRY
	BEGIN CATCH			
		
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1) BEGIN
			ROLLBACK
		END

		SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())

		EXECUTE ADM.SPE_RAISE_ERROR
	END CATCH
END
