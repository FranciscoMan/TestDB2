﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright: VITEK
-- Author: DANIEL RM
-- CRETAE date: 24/08/2019
-- Description: 
-- =============================================


CREATE PROCEDURE    [PRD].[SPE_INSERT_UPDATE_ISSUE_30_MINUTES] 
	@XML_RESULT XML = '' OUT	-- --0 TO ERROR AND 1 TO CORRECT

	, @PIN_KY_ISSUE AS UNIQUEIDENTIFIER  = NULL
	, @PIN_ID_ISSUE AS INT = NULL
	, @PIN_ID_QA27 AS INT = NULL
	, @PIN_ID_WORK_ORDER AS INT = NULL
	, @PIN_ID_PROBLEM_AREA AS INT = NULL  
	, @PIN_NM_PROBLEM_AREA AS NVARCHAR(100) = NULL
	, @PIN_ID_PROBLEM_CODE AS INT = NULL
	, @PIN_NM_PROBLEM_CODE AS NVARCHAR(100) = NULL
	, @PIN_DS_SYMPTOM AS NVARCHAR(max) = NULL
	, @PIN_XML_POSITIONS_INVOLVED AS XML = NULL
	, @PIN_KY_USER_INVOLVED AS NVARCHAR(50) = NULL
	, @PIN_DS_ISSUE_EXPLANATION_OPEN AS NVARCHAR(MAX) = NULL
	, @PIN_DT_ISSUE AS DATETIME = NULL
	, @PIN_FG_CONFIRMED AS BIT = NULL
	, @PIN_DT_CONFIRMED AS DATETIME =  NULL
	, @PIN_ID_DEFECT_CATEGORY AS INT =  NULL
	, @PIN_DS_EXPLANATION_EVENT_CLOSED AS NVARCHAR(MAX) =  NULL
	, @PIN_DT_ISSUE_CLOSED AS DATETIME = NULL
	, @PIN_KY_STATUS AS  NVARCHAR(50) = NULL
	, @PIN_NO_TIME_BEFORE_HELP AS INT = NULL
	, @PIN_FG_LINE_DOWN AS BIT = NULL
	, @PIN_KY_USER_APP AS NVARCHAR(50)
	, @PIN_NM_PROGRAM AS NVARCHAR(50)
	, @PIN_TYPE_TRANSACTION CHAR(1)             --I=INSERT   U=UPDATE

AS 
BEGIN  


   	BEGIN TRY
		----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
		DECLARE @V_EXIST_TRAN BIT = 0
			, @DT_SYSTEM DATETIME = GETDATE()
			, @XML_NOTIFICATIONS XML = N'<NOTIFICATIONS><MESSAGE BODY="TELEGRAM MESSAGE"/></NOTIFICATIONS>'
			, @XML_NOTIFICATION_FORM XML = N'<NOTIFICATIONS><RECIPIENTS></RECIPIENTS></NOTIFICATIONS>'
			, @MESSAGE_TELEGRAM nvarchar(500)
			, @NM_PRODUCTION_LINE NVARCHAR(20)
			, @NM_LEADMAN NVARCHAR(100)
			, @ID_BRANCH_PLANT INT
			, @XML_FORM XML
			, @XML_RECIPIENTS XML
			, @XML_RECIPIENTS_USERS XML
			, @V_ID_PRODUCTION_LINE AS  int = NULL
			, @V_KY_NOTIFICATION_ORIGIN AS NVARCHAR(20) = 'ISSUE'
			, @V_KY_NOTIFICATION_STATUS AS NVARCHAR(20) = 'CLOSED'
			, @V_ID_NOTIFICATION AS  int = NULL
			--, @V_ID_PRODUCTION_LINE INT
			, @V_IPS_CREATE_FORM NVARCHAR(20)

		IF @@TRANCOUNT = 0 BEGIN
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	

		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION = 'I' BEGIN

			--WE INSERT THE REGISTER ON THE TABLE  prd.K_ISSUE
			IF NOT EXISTS (SELECT 1 FROM PRD.K_ISSUE KI WHERE KI.ID_WORK_ORDER = @PIN_ID_WORK_ORDER AND KI.KY_STATUS IN ('CHANGE_SHIFT', 'HOLD_ON', 'CREATED')) BEGIN 

				SELECT @V_ID_PRODUCTION_LINE = ID_PRODUCTION_LINE
					, @ID_BRANCH_PLANT = ID_BRANCH_PLANT
				FROM PRD.K_WORK_ORDER 
				WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

				INSERT INTO PRD.K_ISSUE (
					KY_ISSUE
					, ID_QA27
					, ID_WORK_ORDER
					, ID_PRODUCTION_LINE
					, ID_PROBLEM_AREA
					, ID_PROBLEM_CODE
					, DS_SYMPTOM
					, XML_POSITIONS_INVOLVED
					, KY_USER_INVOLVED 
					, DS_ISSUE_EXPLANATION_OPEN
					, DT_ISSUE
					, FG_CONFIRMED
					, DT_CONFIRMED
					, ID_DEFECT_CATEGORY
					, DS_EXPLANATION_EVENT_CLOSED
					, DT_ISSUE_CLOSED 
					, KY_STATUS
					, FG_LINE_DOWN
					, DT_CREATION
					, KY_USER_APP_CREATION
					, NM_PROGAM_CREATE
				) VALUES ( 
					NULL
					, @PIN_ID_QA27
					, @PIN_ID_WORK_ORDER
					, @V_ID_PRODUCTION_LINE
					, @PIN_ID_PROBLEM_AREA
					, @PIN_ID_PROBLEM_CODE
					, @PIN_DS_SYMPTOM
					, @PIN_XML_POSITIONS_INVOLVED
					, @PIN_KY_USER_INVOLVED
					, @PIN_DS_ISSUE_EXPLANATION_OPEN
					, @PIN_DT_ISSUE
					, @PIN_FG_CONFIRMED
					, NULL
					, @PIN_ID_DEFECT_CATEGORY
					, @PIN_DS_EXPLANATION_EVENT_CLOSED
					, DATEADD(MINUTE, 30,@PIN_DT_ISSUE) 
					, @PIN_KY_STATUS
					, @PIN_FG_LINE_DOWN
					, @DT_SYSTEM 
					, @PIN_KY_USER_APP 
					, @PIN_NM_PROGRAM
				)

				SET @PIN_ID_ISSUE = SCOPE_IDENTITY()

				-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
				SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')		
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT,CAST(@PIN_ID_ISSUE AS NVARCHAR(10)), 'ID_ISSUE')		

			END ELSE BEGIN

				-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
				SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'WARNING')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Ya existe un tiempo muerto creado / pendiente para esta work order. Si no le aparece la pantalla contacte a su administradpr de sistema', 'ES')
				SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'There is already a pending timeout for this work order. If the screen does not appear, contact your system administrator', 'EN')		
				--SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT,CAST(@PIN_ID_ISSUE AS NVARCHAR(10)), 'ID_ISSUE')	
			END	

		END ELSE BEGIN

			-- UPDATES THE REGISTER ON THE TABLE
			IF @PIN_KY_STATUS = 'CHANGE_SHIFT' BEGIN 

				UPDATE  PRD.K_QA27 
				SET KY_STATUS = 'COMPLETE'
					, DT_UPDATE = @DT_SYSTEM
					, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
					, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
				WHERE ID_QA27 = @PIN_ID_QA27;

				SELECT @V_ID_PRODUCTION_LINE = ID_PRODUCTION_LINE
					, @ID_BRANCH_PLANT = ID_BRANCH_PLANT
				FROM PRD.K_WORK_ORDER 
				WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

				IF @V_ID_PRODUCTION_LINE IS NOT NULL BEGIN 
					UPDATE PRD.K_SHIFT
					SET FG_STATUS = 0,
						DT_UPDATE = @DT_SYSTEM,
						KY_USER_APP_UPDATE = @PIN_KY_USER_APP,
						NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
					WHERE ID_PRODUCTION_LINE = @V_ID_PRODUCTION_LINE AND KY_USER = @PIN_KY_USER_APP
						AND FG_STATUS = 1
				END

				UPDATE PRD.K_ISSUE
				SET KY_STATUS = @PIN_KY_STATUS,
					DT_UPDATE = @DT_SYSTEM,
					KY_USER_APP_UPDATE = @PIN_KY_USER_APP,
					NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
				WHERE ID_ISSUE = @PIN_ID_ISSUE;

				SELECT TOP 1 @XML_NOTIFICATIONS = XML_PROCESS_CONFIGURATION
					, @V_ID_NOTIFICATION = ID_NOTIFICATION 
				FROM PRD.K_NOTIFICATION_PROCESS
				WHERE ID_NOTIFICATION_REFERENCE = @PIN_ID_ISSUE
					AND KY_NOTIFICATION_ORIGIN = 'ISSUE'
					AND KY_PROCESS_TYPE = 'FORM'

				IF @XML_NOTIFICATIONS IS NOT NULL BEGIN
					SET @XML_NOTIFICATIONS.modify('replace value of (/NOTIFICATIONS/RECIPIENTS/RECIPIENT/@STATUS)[1] with sql:variable("@V_KY_NOTIFICATION_STATUS")'); 

					EXEC PRD.SPE_UPDATE_NOTIFICATION_STATUS 
					''
					,@V_ID_NOTIFICATION
					,'CLOSED'
					,''
					,0
					,@XML_NOTIFICATIONS
					,@PIN_KY_USER_APP
					,@PIN_NM_PROGRAM

				END
			END ELSE BEGIN
			------------------------------------------IF THE USER CONFIRM A LOST TIME EVENT-------------------------------------------------------
				IF @PIN_FG_CONFIRMED = 1 BEGIN

					SELECT @ID_BRANCH_PLANT = ID_BRANCH_PLANT
						  ,@V_ID_PRODUCTION_LINE = ID_PRODUCTION_LINE
					FROM PRD.K_WORK_ORDER 
					WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER

					UPDATE  PRD.K_ISSUE SET
						FG_CONFIRMED  = @PIN_FG_CONFIRMED
						, DT_CONFIRMED  = @DT_SYSTEM
						, KY_USER_INVOLVED  = @PIN_KY_USER_INVOLVED
						, KY_STATUS  = @PIN_KY_STATUS
						, DT_UPDATE =@DT_SYSTEM
						, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
						, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
					WHERE ID_ISSUE = @PIN_ID_ISSUE

					------GET IP ASOCIATED TO PRODUCTION LINE, GET THE FIRST

					; WITH T_FIRST_PRODUCTION_LINE AS( 
						SELECT ROW_NUMBER() OVER(PARTITION BY ID_PRODUCTION_LINE ORDER BY ID_PRODUCTION_LINE_IP) ROWNUMBER
							,CIP.NO_IP
							,CIP.ID_PRODUCTION_LINE
						FROM PRD.C_PRODUCTION_LINE_IP CIP
					)
					SELECT @V_IPS_CREATE_FORM = IPS.NO_IP
					FROM T_FIRST_PRODUCTION_LINE IPS
					WHERE IPS.ROWNUMBER = 1
						AND IPS.ID_PRODUCTION_LINE = @V_ID_PRODUCTION_LINE

					SET @XML_RECIPIENTS_USERS = (
						SELECT @PIN_KY_USER_APP  AS "@TO",
						'SEND'  AS "@STATUS",
						'0' AS "@ATTEMPT_NUMBER",
						'' AS "@ERROR",
						@V_ID_PRODUCTION_LINE AS "@ID_PRODUCTION_LINE",
						@V_IPS_CREATE_FORM AS "@IP_CREATE_FORM"
						FOR XML PATH ('RECIPIENT')
					)

					SET @XML_FORM = (
						SELECT 'WorkOrders' AS "@NAME",
						'/PRD/AddEventLostTime.aspx' AS "@URL",
						'Close unproductive time' AS "@TITLE",
						--'900' AS "@WIDTH",
						'600' AS "@HEIGHT",
						CONCAT('?ID_ISSUE=',CAST(@PIN_ID_ISSUE AS NVARCHAR(10)),'&KY_STATUS=',@PIN_KY_STATUS) AS "@URL_PARAMETERS"
						FOR XML PATH ('FORM')
					)

					DECLARE @XML_PARAMETERS XML 
					
					SET @XML_PARAMETERS = (
						SELECT * FROM (
						SELECT 'ID_ISSUE' AS '@KY_PARAMETER', CONVERT(NVARCHAR(100), @PIN_ID_ISSUE) AS '@KY_VALUE' UNION ALL
						SELECT 'KY_STATUS' AS '@KY_PARAMETER',  @PIN_KY_STATUS AS '@KY_VALUE'
						) T 
						FOR XML PATH('PARAMETER'), ROOT('PARAMETERS')
					)

					SET @XML_FORM.modify('insert sql:variable("@XML_PARAMETERS") into (/FORM)[1]')

					SET @XML_NOTIFICATION_FORM.modify('insert sql:variable("@XML_RECIPIENTS_USERS") into (/NOTIFICATIONS/RECIPIENTS)[1]') ;
					SET @XML_NOTIFICATION_FORM.modify('insert sql:variable("@XML_FORM") into (/NOTIFICATIONS)[1]') ;

					EXEC PRD.SPE_INSERT_NOTIFICATION 
						''
						, 1
						, @PIN_KY_USER_APP
						, 'FORM'
						, 'SEND'
						, @XML_NOTIFICATION_FORM
						, @DT_SYSTEM
						, NULL
						, NULL
						, @ID_BRANCH_PLANT
						, @PIN_ID_ISSUE
						, @V_KY_NOTIFICATION_ORIGIN
						, NULL
						, 1
						, 0
						, @PIN_KY_USER_APP
						, @PIN_NM_PROGRAM

				END ELSE BEGIN

					UPDATE  PRD.K_ISSUE
					SET ID_DEFECT_CATEGORY  = @PIN_ID_DEFECT_CATEGORY
						, DS_EXPLANATION_EVENT_CLOSED  = @PIN_DS_EXPLANATION_EVENT_CLOSED
						, DT_ISSUE_CLOSED  = @DT_SYSTEM
						, KY_STATUS  = @PIN_KY_STATUS
						, NO_TIME_BEFORE_HELP = @PIN_NO_TIME_BEFORE_HELP
						, DT_UPDATE =@DT_SYSTEM
						, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
						, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
					WHERE ID_ISSUE = @PIN_ID_ISSUE

					DELETE KS FROM PRD.K_SCALING KS WHERE EXISTS (SELECT TOP 1 1 FROM PRD.K_SCALING_PROCESS KSP WHERE KSP.ID_ISSUE = @PIN_ID_ISSUE AND KSP.ID_SCALING_PROCESS = KS.ID_SCALING_PROCESS)
					DELETE FROM PRD.K_SCALING_PROCESS WHERE ID_ISSUE = @PIN_ID_ISSUE

					UPDATE PRD.K_WORK_ORDER
					SET KY_STATUS = 'RUNNING'
						, DT_UPDATE = @DT_SYSTEM
						, KY_USER_APP_UPDATE = @PIN_KY_USER_APP
						, NM_PROGRAM_UPDATE = @PIN_NM_PROGRAM
					WHERE ID_WORK_ORDER = @PIN_ID_WORK_ORDER
				END
			END
			-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
			SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
			SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
			SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')		
			SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT,CAST(@PIN_ID_ISSUE AS NVARCHAR(10)), 'ID_ISSUE')	


		END
		------

		---- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		--SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		--SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		--SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')		
		--SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT,CAST(@PIN_ID_ISSUE AS NVARCHAR(10)), 'ID_ISSUE')		
		-- IF THERE IS A TRANSACTION IN THIS BLOCK, IT WILL BE ERASED
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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error while processing the register.')
		
		EXECUTE ADM.SPE_RAISE_ERROR
			
	END CATCH
END

