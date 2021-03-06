﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CRETAE date: 19/05/2018
-- Description: Import all items from JDEdwards
-- =============================================
-- Modified by: Daniel Dávalos
-- Added @NO_RESULT (Output variable)
-- =============================================

CREATE PROCEDURE [PRD].[SPE_IMPORT_ITEMS_FROM_JDEDWARDS]		
	@XML_RESULT XML = '' OUT
	, @NO_RESULT INT = 0 OUT
	, @PIN_KY_USER_APP AS NVARCHAR(50)
	, @PIN_NM_PROGRAM AS NVARCHAR(50)
AS 
BEGIN  
	----WE DECLARE THE STARTED VARIABLE THAT INDICATES IF WE WILL HAVE A TRANSACTION ON SPE
	DECLARE @V_EXIST_TRAN BIT = 0
	,@DT_SYSTEM DATETIME = GETDATE()

   	BEGIN TRY
		--WE VERIFY THAT EXISTS A WORKING TRANSACTION
		IF (@@TRANCOUNT = 0) BEGIN
			--IN CASE THAT THE TRANSACTION DOESNT START
			BEGIN TRANSACTION
			--IT EDITS THE VARIABLE THAT INDICATES THAT THE TRANSACTION START IN THIS BLOCK TO CANCEL IN ANY MOMENT
			SET @V_EXIST_TRAN = 1
		END	

		DECLARE @NO_ITEMS_INSERTED INT
			, @NO_ITEMS_NOT_INSERTED INT
			, @XML_ADDITIONAL_DATA XML

		CREATE TABLE #T_ITEM  (
			ID_ITEM INT
			, KY_ITEM NVARCHAR(50)
			, NM_ITEM NVARCHAR(100)
			, DS_ITEM NVARCHAR(1000)
			, FG_ACTIVE BIT
			, NO_PIECES_PER_PALLET INT
			, NO_POUNDS_PER_ITEM DECIMAL (20,10)
			, NO_SAMPLE INT
			, KY_SAMPLE_UNIT NCHAR(10)
			, KY_UPC NVARCHAR(20)
			, DS_NOTES_JDEDWARDS NVARCHAR(1000)
			, DT_CREATION DATETIME
			, KY_USER_APP_CREATION NVARCHAR(50)
			, NM_PROGAM_CREATE NVARCHAR(50)
		)

		INSERT INTO #T_ITEM (ID_ITEM
			, KY_ITEM
			, NM_ITEM
			, DS_ITEM
			, FG_ACTIVE
			, NO_PIECES_PER_PALLET
			, NO_POUNDS_PER_ITEM
			, NO_SAMPLE
			, KY_SAMPLE_UNIT
			, KY_UPC
			, DS_NOTES_JDEDWARDS
			, DT_CREATION
			, KY_USER_APP_CREATION
			, NM_PROGAM_CREATE
		)
		SELECT VCIJ.ID_ITEM
			, VCIJ.KY_ITEM
			, VCIJ.NM_ITEM
			, VCIJ.DS_ITEM
			, 1
			, VCIJ.NO_SKID_QTY
			, VCIJ.NO_POUNDS_PER_ITEM
			, 3
			, 'PENCENT'
			, VCIJ.KY_UPC
			, VCIJ.DS_NOTES_JDEDWARDS
			, @DT_SYSTEM
			, @PIN_KY_USER_APP
			, @PIN_NM_PROGRAM
		FROM PRD.VW_C_ITEM_JDEDWARDS VCIJ

		INSERT INTO PRD.C_ITEM (ID_ITEM
			, KY_ITEM
			, NM_ITEM
			, DS_ITEM
			, FG_ACTIVE
			, NO_PIECES_PER_PALLET
			, NO_POUNDS_PER_ITEM
			, NO_SAMPLE
			, KY_SAMPLE_UNIT
			, KY_UPC
			, DS_NOTES_JDEDWARDS
			, DT_CREATION
			, KY_USER_APP_CREATION
			, NM_PROGAM_CREATE
		)
		SELECT ID_ITEM
			, KY_ITEM
			, NM_ITEM
			, DS_ITEM
			, FG_ACTIVE
			, NO_PIECES_PER_PALLET
			, NO_POUNDS_PER_ITEM
			, NO_SAMPLE
			, KY_SAMPLE_UNIT
			, KY_UPC
			, DS_NOTES_JDEDWARDS
			, DT_CREATION
			, KY_USER_APP_CREATION
			, NM_PROGAM_CREATE
		FROM #T_ITEM TI
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM PRD.C_ITEM CI WHERE CI.ID_ITEM = TI.ID_ITEM)
			AND ISNULL(NO_POUNDS_PER_ITEM, 0) > 0

		SET @NO_ITEMS_INSERTED = @@ROWCOUNT

		SELECT @NO_ITEMS_NOT_INSERTED = COUNT(1) 
		FROM #T_ITEM TI
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM PRD.C_ITEM CI WHERE CI.ID_ITEM = TI.ID_ITEM)
			AND ISNULL(NO_POUNDS_PER_ITEM, 0) <= 0

		SET @XML_ADDITIONAL_DATA = (
			SELECT @NO_ITEMS_INSERTED AS '@NO_ITEMS_INSERTED'
				, @NO_ITEMS_NOT_INSERTED AS '@NO_ITEMS_NOT_INSERTED'
			FOR XML PATH('RESULTS')
		)

		-- WE BACK A RETURN VARIABLE THAT INDICATES ALL WAS PERFORMED OKAY 
		SET @NO_RESULT = 1
		SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso exitoso', 'ES')
		SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successful Process', 'EN')

		SET @XML_RESULT = DBO.F_ERROR_INSERT_DATA(@XML_RESULT, @XML_ADDITIONAL_DATA)


		-- IF THERE IS A TRANSACTION IN THIS BLOCK, IT WILL BE ERASED
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			COMMIT	
	END TRY
	BEGIN CATCH
		--IF IT OCCURS A ERROR IN THIS BLOCK THE TRANSACTIO GET CANCELED
		
		IF (@@TRANCOUNT > 0 AND @V_EXIST_TRAN = 1)
			ROLLBACK

		SET @NO_RESULT = 0
		SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())

		EXEC ADM.SPE_RAISE_ERROR

	END CATCH
END
