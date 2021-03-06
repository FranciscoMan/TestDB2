﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- Create date: 01/28/2019
-- Description: Insert new skid to work order that is running on production line
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_INSERT_SKID_TO_WORK_ORDER] 
	@XML_RESULT XML = '' OUT
	, @PIN_ID_WORK_ORDER INT
	, @PIN_NO_SKIDS_TO_OPEN INT
	, @PIN_KY_USER_APP NVARCHAR(50)
	, @PIN_NM_PROGRAM NVARCHAR(50)
	
AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
   	BEGIN TRY
		DECLARE @V_EXIST_TRAN BIT = 0
			, @DT_SYSTEM DATETIME = GETDATE()
			, @ID_PRODUCTION_LINE INT
			, @FG_REASSIGN_SKIDS_TO_CURRENT_QA27 BIT = 0
			, @ID_QA27_RUNNING INT
			, @NO_SECONDS_FROM_SHIFT_STARTED INT
			, @ID_LEADMAN_POSITION INT
			, @KY_LEADMAN NVARCHAR(50)
			, @NM_LEADMAN NVARCHAR(200)
			, @NO_RUN_QTY INT
			, @NO_QTY_ADDED INT
			, @NO_PCS_PER_SKID INT
			, @NO_SAVED_PCS INT
			, @NO_LAST_SKID INT

		IF (@@TRANCOUNT = 0) BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	

		CREATE TABLE #T_OPENED_SKIDS  (
			NO_ROW INT IDENTITY (1,1)
			, ID_SKID INT
			, NO_SKID INT
			, KY_STATUS NVARCHAR(20)
			, FG_CURRENT_SHIFT BIT
			, NO_SECONDS_PREVIOUS_SHIFT INT
			, ID_QA27 INT
			, ID_LEADMAN INT
			, KY_LEADMAN NVARCHAR(20)
			, NM_LEADMAN NVARCHAR(200)
		)

		CREATE TABLE #T_SKIDS_TO_INSERT (
			NO_SKID INT
			, NO_QTY_SKID INT
			, KY_STATUS NVARCHAR(20)
		)


		-- THE PARAMETERS OF CURRENT SHIFT ARE OBTAINED

		SELECT TOP 1 
		      @ID_PRODUCTION_LINE = KWO.ID_PRODUCTION_LINE
			, @ID_QA27_RUNNING = KQ.ID_QA27
			, @ID_LEADMAN_POSITION = KQ.ID_LEADMAN
			, @KY_LEADMAN = KS.KY_USER
			, @NM_LEADMAN = KQ.NM_LEADMAN
			, @ID_LEADMAN_POSITION = CE.ID_POSITION
			, @NO_SECONDS_FROM_SHIFT_STARTED = DATEDIFF(MINUTE, KS.DT_START_SHIFT, @DT_SYSTEM)
			, @NO_RUN_QTY = KWO.NO_RUN_QTY
			, @NO_QTY_ADDED = KWO.NO_QTY_ADDED
			, @NO_PCS_PER_SKID = KWO.NO_QTY_SKID
		FROM PRD.K_WORK_ORDER KWO
			INNER JOIN PRD.K_QA27 KQ
				ON KWO.ID_WORK_ORDER = KQ.ID_WORK_ORDER
				AND KQ.KY_STATUS = 'RUNNING'
			INNER JOIN PRD.K_SHIFT KS
				ON KS.ID_SHIFT = KQ.ID_SHIFT
				AND KS.FG_STATUS = 1
			INNER JOIN ADM.C_EMPLOYEE CE
				ON KQ.ID_LEADMAN = CE.ID_EMPLOYEE
		WHERE KWO.ID_WORK_ORDER = @PIN_ID_WORK_ORDER

	--SELECT @ID_PRODUCTION_LINE PROD_LINE, @ID_QA27_RUNNING QA_STATUS , @ID_LEADMAN_POSITION ID_LEADMAN,@KY_LEADMAN KY_LEAD
	--,@NM_LEADMAN NM_LEAD ,@NO_SECONDS_FROM_SHIFT_STARTED TIME_STARTED_SHIFT, @NO_RUN_QTY QTY, @NO_QTY_ADDED QTY_ADDED,
	--@NO_PCS_PER_SKID PCS_PER_SKID, @PIN_ID_WORK_ORDER WO

		-- THE SKIDS THAT ARE OPEN AND THAT SHOULD BE CLOSED DURING THIS PROCESS ARE INSERTED

		INSERT INTO #T_OPENED_SKIDS (
			ID_SKID
			, NO_SKID
			, KY_STATUS
			, FG_CURRENT_SHIFT
			, NO_SECONDS_PREVIOUS_SHIFT
			, ID_QA27
			, ID_LEADMAN
			, KY_LEADMAN
			, NM_LEADMAN
		)
		SELECT KP.ID_PALLET
			, KP.NO_PALLET
			, KP.KY_STATUS
			, KS.FG_STATUS
			, DATEDIFF(MINUTE, KP.DT_INITIAL_TIME, ISNULL(KS.DT_END_SHIFT, @DT_SYSTEM))
			, KP.ID_QA27
			, CE.ID_POSITION
			, KS.KY_USER
			, KQ.NM_LEADMAN
		FROM PRD.K_PALLET KP
			INNER JOIN PRD.K_QA27 KQ
				ON KP.ID_QA27 = KQ.ID_QA27
			INNER JOIN PRD.K_SHIFT KS
				ON KQ.ID_SHIFT = KS.ID_SHIFT
			INNER JOIN ADM.C_EMPLOYEE CE
				ON CE.ID_EMPLOYEE = KQ.ID_LEADMAN
		WHERE KP.ID_WORK_ORDER = @PIN_ID_WORK_ORDER
			AND KP.FG_SEND_FORM = 1
		ORDER BY NO_PALLET DESC


		-- IT IS DETERMINED THAT OPEN SKIDS ARE OF THE PREVIOUS SHIFT

		IF EXISTS (SELECT TOP 1 1 FROM #T_OPENED_SKIDS WHERE FG_CURRENT_SHIFT = 0) BEGIN

			-- IF THE OPEN SKIDS ARE OF THE PREVIOUS SHIFT, THE SKID LIFETIME IS DETERMINED FOR EVERY SHIFT TO ASSIGN 
			-- THEM TO THE TIME WHERE THEY HAVE LIVED THE LONGEST.

			UPDATE #T_OPENED_SKIDS
			SET ID_QA27 = CASE WHEN @NO_SECONDS_FROM_SHIFT_STARTED > NO_SECONDS_PREVIOUS_SHIFT THEN @ID_QA27_RUNNING ELSE ID_QA27 END
				, ID_LEADMAN = CASE WHEN @NO_SECONDS_FROM_SHIFT_STARTED > NO_SECONDS_PREVIOUS_SHIFT THEN @ID_LEADMAN_POSITION ELSE ID_LEADMAN END
				, KY_LEADMAN = CASE WHEN @NO_SECONDS_FROM_SHIFT_STARTED > NO_SECONDS_PREVIOUS_SHIFT THEN @KY_LEADMAN ELSE KY_LEADMAN END
				, NM_LEADMAN = CASE WHEN @NO_SECONDS_FROM_SHIFT_STARTED > NO_SECONDS_PREVIOUS_SHIFT THEN @NM_LEADMAN ELSE NM_LEADMAN END
			FROM #T_OPENED_SKIDS
		END


		-- SKID DATA IS UPDATED TO DECLARE AS CLOSED

		UPDATE KP
		SET KY_STATUS = CASE WHEN KP.KY_STATUS IN ('WORKING', 'INSPECTING', 'INSPECTED', 'NON_INSPECTED') THEN 'ACCEPTED' ELSE KP.KY_STATUS END
			, FG_SEND_FORM = 0
			, DT_FINAL_OPERATION_TIME = @DT_SYSTEM
			, ID_QA27 = TOS.ID_QA27
			, ID_LEADMAN = TOS.ID_LEADMAN
			, KY_USER_LEADMAN = TOS.KY_LEADMAN
			, NM_LEADMAN = TOS.NM_LEADMAN
			, DT_UPDATE = @DT_SYSTEM
			, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
			, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
		FROM PRD.K_PALLET KP
			INNER JOIN #T_OPENED_SKIDS TOS
				ON KP.ID_PALLET = TOS.ID_SKID
			--	WHERE EXISTS (SELECT F.ID_K_FORM FROM PRD.K_FORM F WHERE F.ID_PALLET =TOS.ID_SKID AND F.KY_STATUS_FORM = 'CAPTURED' )
		 
		

		-- DETERMINES THE AMOUNT OF SAVED PARTS CONSIDERING THE CLOSED SKIDS, AS WELL AS THE LAST SKID NUMBER

		SELECT @NO_SAVED_PCS = SUM(CASE WHEN VCPS.FG_FOR_SAVE = 1 THEN ISNULL(KP.NO_QUANTITY, 0) ELSE 0 END) 
			, @NO_LAST_SKID = MAX(KP.NO_PALLET)
		FROM PRD.K_PALLET KP
			INNER JOIN ADM.VW_C_PALLET_STATUS VCPS 
				ON VCPS.KY_PALLET_STATUS = KP.KY_STATUS 
		WHERE KP.ID_WORK_ORDER = @PIN_ID_WORK_ORDER

		-- IT IS TRIED TO INSERT THE SKIDS THAT ARE REQUESTED, IF THE AMOUNT OF SAVED PARTS IS LESS THAN REQUIRED BY THE WORK ORDER

		; WITH T_SKIDS_TO_OPEN AS (
			SELECT 1 AS NO_ROW UNION ALL
			SELECT NO_ROW + 1 FROM T_SKIDS_TO_OPEN WHERE NO_ROW < @PIN_NO_SKIDS_TO_OPEN
		)

		INSERT INTO #T_SKIDS_TO_INSERT (
			NO_SKID
			, NO_QTY_SKID
			, KY_STATUS
		)
		SELECT ISNULL(@NO_LAST_SKID, 0) + NO_ROW
			, CASE WHEN ISNULL(@NO_SAVED_PCS, 0) + (@NO_PCS_PER_SKID * NO_ROW) < (@NO_RUN_QTY + @NO_QTY_ADDED) 
			THEN @NO_PCS_PER_SKID ELSE (@NO_RUN_QTY + @NO_QTY_ADDED) - (ISNULL(@NO_SAVED_PCS, 0) + (@NO_PCS_PER_SKID * (NO_ROW - 1))) END
			, 'WORKING'
		FROM T_SKIDS_TO_OPEN
		WHERE ISNULL(@NO_SAVED_PCS, 0) + (@NO_PCS_PER_SKID * (NO_ROW - 1)) < (@NO_RUN_QTY + @NO_QTY_ADDED)

		
		-- THE STATUS OF THE SKIDS ESTABLISHED BY THE QUALITY INSPECTOR IS DETERMINED, IF THE INSPECTOR HAS ALREADY INSPECTED AND DETERMINED THE APPROVAL OF THE SKID TO BE INSERTED


		-- delete dependence inspectors module
		--UPDATE TSTI
	--	SET KY_STATUS = CASE WHEN KIS.KY_STATUS IN ('INSPECTING', 'INSPECTED', 'NON_INSPECTED') THEN TSTI.KY_STATUS ELSE KIS.KY_STATUS END
		--FROM #T_SKIDS_TO_INSERT TSTI
	--		INNER JOIN PRD.K_INSPECTION_SKID KIS
		--		ON TSTI.NO_SKID = KIS.NO_PALLET
	--			AND KIS.ID_WORK_ORDER = @PIN_ID_WORK_ORDER

		DECLARE @XML_ADDITIONAL_DATA_WO XML = (SELECT 0 AS '@FG_CLOSED_WO' FOR XML PATH('WO_DATA'))


		-- IT IS DETERMINED THAT THE AMOUNT OF PARTS REQUIRED HAS ALREADY BEEN REACHED TO CLOSE THE WORK ORDER
		-- SELECT @NO_SAVED_PCS SAVED_PCS, (@NO_RUN_QTY + @NO_QTY_ADDED) SUMA_LEL

		IF @NO_SAVED_PCS >= (@NO_RUN_QTY + @NO_QTY_ADDED) 
		BEGIN

			SET @XML_ADDITIONAL_DATA_WO = (SELECT 1 AS '@FG_CLOSED_WO' FOR XML PATH('WO_DATA'))

			UPDATE PRD.K_QA27
			SET KY_STATUS = 'COMPLETE'
				, DT_FINAL_TIME = @DT_SYSTEM
				, DT_UPDATE = @DT_SYSTEM
				, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
				, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
			WHERE ID_QA27 = @ID_QA27_RUNNING

			UPDATE PRD.K_WORK_ORDER
			SET KY_STATUS = 'COMPLETE'
				, DT_CLOSE_WORK_ORDER = @DT_SYSTEM
				, DT_UPDATE = @DT_SYSTEM
				, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
				, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
			WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER
		
		END

		-- THE SKIDS ARE INSERTED, IF THERE IS SOMETHING TO INSERT

		INSERT INTO PRD.K_PALLET (
			ID_QA27
			, ID_WORK_ORDER
			, NO_PALLET
			, NO_QUANTITY
			, DT_INITIAL_TIME
			, KY_STATUS
			, FG_SEND_FORM
			, NO_PALLETS_OPENED
			, DT_CREATION
			, KY_USER_APP_CREATION
			, NM_PROGAM_CREATE
		)
		SELECT @ID_QA27_RUNNING
			, @PIN_ID_WORK_ORDER
			, TSTI.NO_SKID
			, TSTI.NO_QTY_SKID
			, @DT_SYSTEM
			, TSTI.KY_STATUS
			, 1
			, @PIN_NO_SKIDS_TO_OPEN
			, @DT_SYSTEM
			, @PIN_KY_USER_APP
			, @PIN_NM_PROGRAM
		FROM #T_SKIDS_TO_INSERT TSTI
		ORDER BY TSTI.NO_SKID

		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')

		SET @XML_RESULT = DBO.F_ERROR_INSERT_DATA(@XML_RESULT, @XML_ADDITIONAL_DATA_WO)

		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1) BEGIN
			COMMIT	
		END
	END TRY
	BEGIN CATCH		
		--IF IT OCCURS A ERROR IN THIS BLOCK THE TRANSACTIO GET CANCELED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1) BEGIN
			ROLLBACK
		END
			
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())
			
	END CATCH
END

