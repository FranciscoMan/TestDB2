﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Javier Diaz Barron
-- CRETAE date: 19/06/2017
-- Description: Insert or update a READINGS
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_INSERT_UPDATE_K_READINGS] 
     @XML_RESULT XML = '' OUT     -- --0 TO ERROR AND 1 TO CORRECT
	,@ID_K_READINGS INT = NULL
	,@ID_WORK_ORDER INT= NULL
	,@ID_PRODUCTION_LINE INT =NULL
	,@ID_ITEM INT=NULL
	,@ID_PALLET INT = NULL
	,@ID_INSPECTION_SKID INT = NULL
	,@ID_K_FORM INT = NULL
	,@XML_READINGS XML	 =NULL
	,@KY_STATUS NVARCHAR(50)=NULL
	,@FG_PROTABLE	BIT = 0
	,@FG_MICROMETER	BIT = 0
	,@FG_GLOSS	BIT = 0
	,@FG_LIGHT_TRANSMISSION BIT = 0
	,@PIN_KY_USER_APP AS nvarchar(50)
	,@PIN_NM_PROGRAM AS nvarchar(50)
	,@PIN_TYPE_TRANSACTION CHAR(1)  --I=INSERT   U=UPDATE

AS 
BEGIN  
		
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	,@CFE_SISTEMA DATETIME = GETDATE()
	,@V_NO_PALLET AS INT 

    
	CREATE TABLE #T_SAMPLES  (
		ID_METRIC INT,
		NO_VALUE float,
		KY_STATUS_READING NVARCHAR(30)
	)
    	BEGIN TRY
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) 
		BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	
		--WE VERIFY IF THE SPE IS GOING TO EXECUTE A UPDATE OR INSERT
		IF @PIN_TYPE_TRANSACTION='I'
	    	BEGIN

			SELECT @V_NO_PALLET = KP.NO_PALLET 
			FROM PRD.K_PALLET KP
			WHERE KP.ID_PALLET = @ID_PALLET

			IF @V_NO_PALLET IS NULL
			BEGIN
				SELECT @V_NO_PALLET = KP.NO_PALLET 
				  FROM PRD.K_INSPECTION_SKID KP
				  WHERE KP.ID_INSPECTION_SKID = @ID_INSPECTION_SKID
			END


			INSERT INTO #T_SAMPLES
			SELECT SAMPLES.ID_METRIC,
				   ISNULL(SAMPLES.NO_VALUE,0) AS NO_VALUE,
				   SAMPLES.KY_STATUS
			FROM (
						SELECT KS.ID_WIDTH_METRIC AS ID_METRIC,
							   KS.NO_WIDTH_VALUE AS NO_VALUE,
							   KS.KY_SAMPLE_STATUS AS KY_STATUS
						FROM  LAB.K_SAMPLE KS
						WHERE KS.NO_WORK_ORDER = @ID_WORK_ORDER
						  AND ((@ID_K_FORM IS NULL AND KS.NO_PALLET = @V_NO_PALLET)  OR (@ID_K_FORM IS NOT NULL AND ( KS.ID_FORM = @ID_K_FORM)))

							UNION ALL
						  SELECT 
							   KS.ID_LENGTH_METRIC,
							   KS.NO_LENGTH_VALUE,
							   KS.KY_SAMPLE_STATUS
						FROM  LAB.K_SAMPLE KS
						WHERE KS.NO_WORK_ORDER = @ID_WORK_ORDER
						  AND ((@ID_K_FORM IS NULL AND KS.NO_PALLET = @V_NO_PALLET)  OR (@ID_K_FORM IS NOT NULL AND ( KS.ID_FORM = @ID_K_FORM)))

						  UNION ALL

						  SELECT
							   KS.ID_THICKNESS_METRIC,
							   KS.NO_THICKNESS_VALUE,
							   KS.KY_SAMPLE_STATUS
						FROM  LAB.K_SAMPLE KS
						WHERE KS.NO_WORK_ORDER = @ID_WORK_ORDER
						  AND ((@ID_K_FORM IS NULL AND KS.NO_PALLET = @V_NO_PALLET)  OR (@ID_K_FORM IS NOT NULL AND ( KS.ID_FORM = @ID_K_FORM)))
						  UNION ALL
						   SELECT 
							   KS.ID_LIGHT_TRANSMISSION_METRIC,
							   KS.NO_LIGHT_TRANSMISSION_VALUE,
							   KS.KY_SAMPLE_STATUS
						FROM  LAB.K_SAMPLE KS
						WHERE KS.NO_WORK_ORDER = @ID_WORK_ORDER
						  AND ((@ID_K_FORM IS NULL AND KS.NO_PALLET = @V_NO_PALLET)  OR (@ID_K_FORM IS NOT NULL AND ( KS.ID_FORM = @ID_K_FORM)))
						  UNION ALL
						   SELECT 
							   KS.ID_GLOSS_METRIC,
							   KS.NO_GLOSS_VALUE,
							   KS.KY_SAMPLE_STATUS
						FROM  LAB.K_SAMPLE KS
						WHERE KS.NO_WORK_ORDER = @ID_WORK_ORDER
						  AND ((@ID_K_FORM IS NULL AND KS.NO_PALLET = @V_NO_PALLET)  OR (@ID_K_FORM IS NOT NULL AND ( KS.ID_FORM = @ID_K_FORM)))
						  UNION ALL
						SELECT 
							   KS.ID_WEIGHT_METRIC,
							   KS.NO_WEIGHT_VALUE,
							   KS.KY_SAMPLE_STATUS
						FROM  LAB.K_SAMPLE KS
						WHERE KS.NO_WORK_ORDER = @ID_WORK_ORDER
						  AND ((@ID_K_FORM IS NULL AND KS.NO_PALLET = @V_NO_PALLET)  OR (@ID_K_FORM IS NOT NULL AND ( KS.ID_FORM = @ID_K_FORM)))

					) SAMPLES
				WHERE SAMPLES.ID_METRIC IS NOT NULL AND SAMPLES.ID_METRIC > 0

			--WE INSERT THE REGISTER ON THE TABLE  PRD.K_READINGS
			INSERT INTO PRD.K_READINGS
						 (
						  ID_WORK_ORDER, 
						  ID_PRODUCTION_LINE, 
						  ID_ITEM, 
						  ID_PALLET, 
						  ID_INSPECTION_SKID,
						  ID_K_FORM, 
						  KY_STATUS, 
						  FG_PROTABLE, 
						  FG_MICROMETER, 
						  FG_GLOSS, 
						  FG_LIGHT_TRANSMISSION, 
						  DT_READINGS,
						  DT_CREATION, 						  
						  KY_USER_APP_CREATION, 						  
						  NM_PROGAM_CREATE

					)
				SELECT
					 @ID_WORK_ORDER
					,@ID_PRODUCTION_LINE
					,@ID_ITEM
					,@ID_PALLET
					,@ID_INSPECTION_SKID
					,@ID_K_FORM					
					,@KY_STATUS
					,@FG_PROTABLE
					,@FG_MICROMETER
					,@FG_GLOSS
					,@FG_LIGHT_TRANSMISSION
					,@CFE_SISTEMA
					,@CFE_SISTEMA
					,@PIN_KY_USER_APP
					,@PIN_NM_PROGRAM	
					
				SET @ID_K_READINGS = SCOPE_IDENTITY()	
				
				INSERT INTO PRD.K_METRICS_READINGS (ID_K_READING, ID_METRICS, NO_VALUE,KY_STATUS_READING, DT_CREATION, KY_USER_APP_CREATION, NM_PROGAM_CREATE)
				SELECT 
					@ID_K_READINGS,
					TS.ID_METRIC, 
					TS.NO_VALUE, 
					TS.KY_STATUS_READING,					
					@CFE_SISTEMA,
					@PIN_KY_USER_APP,
					@PIN_NM_PROGRAM
			FROM #T_SAMPLES TS
																
										

		END ELSE BEGIN
			-- WE UPDATE THE REGISTER ON THE TABLE ADM.C_DEPARTMENT
			UPDATE PRD.K_READINGS
			SET   				  
				  [ID_K_FORM]=@ID_K_FORM			
				, [KY_STATUS]=@KY_STATUS			
				, [DT_UPDATE] =@CFE_SISTEMA
				, [KY_USER_APP_UPDATE] = @PIN_KY_USER_APP
				, [NM_PROGRAM_UPDATE] = @PIN_NM_PROGRAM
			       
			WHERE [ID_K_READING] = @ID_K_READINGS
									
		END
		-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')
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
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES( @KY_ERROR, 'There was an error processing the register')
		
			
	END CATCH
END

