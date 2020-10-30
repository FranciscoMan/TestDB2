﻿CREATE TABLE [PRD].[C_ITEM] (
    [ID_ITEM]              INT              NOT NULL,
    [KY_ITEM]              NVARCHAR (50)    NOT NULL,
    [NM_ITEM]              NVARCHAR (100)   NOT NULL,
    [DS_ITEM]              NVARCHAR (1000)  NULL,
    [FG_ACTIVE]            BIT              CONSTRAINT [DF_C_ITEM_FG_ACTIVE] DEFAULT ((1)) NOT NULL,
    [NO_PIECES_PER_PALLET] INT              NULL,
    [NO_POUNDS_PER_ITEM]   DECIMAL (20, 10) NULL,
    [NO_SAMPLE]            INT              CONSTRAINT [DF_C_ITEM_NO_SAMPLE] DEFAULT ((3)) NOT NULL,
    [KY_SAMPLE_UNIT]       NCHAR (10)       CONSTRAINT [DF_C_ITEM_KY_SAMPLE_UNIT] DEFAULT (N'PERCENT') NOT NULL,
    [KY_UPC]               NVARCHAR (20)    NULL,
    [DS_NOTES_JDEDWARDS]   NVARCHAR (1000)  NULL,
    [NO_PIECES_PER_SKID]   INT              NULL,
    [DT_CREATION]          DATETIME         NOT NULL,
    [DT_UPDATE]            DATETIME         NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50)    NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50)    NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50)    NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50)    NULL,
    [FG_FILM_TRACK]        BIT              NULL,
    CONSTRAINT [PK_C_ITEM] PRIMARY KEY CLUSTERED ([ID_ITEM] ASC)
);


GO
CREATE TRIGGER [PRD].[TR_CUD_ITEMS] ON  PRD.C_ITEM AFTER INSERT,UPDATE,DELETE
AS 
BEGIN

DECLARE @XML_CATALOG AS XML,
		@XML_VALUES AS XML,
		@XML_REFERENCE AS XML,
		@KY_CATALOG AS NVARCHAR(100) = 'ITEM',
		@DS_MESSAGE AS NVARCHAR(100) = 'NOT ACTION',
		@KY_ACTION NVARCHAR(10),
		@KY_ACTION_INSERT NVARCHAR(10) = 'INSERT',
		@KY_ACTION_UPDATE NVARCHAR(10) = 'UPDATE',
		@KY_ACTION_DELETE NVARCHAR(10) = 'DELETE',
		@NO_AFFECTED_RECORDS INT = 0,
		@KY_USER NVARCHAR(50),
		@NM_PROGRAM NVARCHAR(50),
		@DT_AFFECTED DATETIME
BEGIN TRY

	SET @KY_ACTION = (
		SELECT CASE 
			WHEN EXISTS(SELECT TOP 1 1 FROM inserted) AND EXISTS(SELECT TOP 1 1 FROM deleted) THEN @KY_ACTION_UPDATE --IF SO, THEN UPDATE
			WHEN EXISTS(SELECT TOP 1 1 FROM inserted) THEN @KY_ACTION_INSERT
			WHEN EXISTS(SELECT TOP 1 1 FROM deleted) THEN @KY_ACTION_DELETE
		END
	)

	------------------------------------------------ UPDATE
	IF @KY_ACTION = @KY_ACTION_UPDATE BEGIN

		SET @XML_VALUES = (
			SELECT 
				  I.ID_ITEM AS "@ID_ITEM" 
				, I.KY_ITEM AS "@KY_ITEM_NEW"
				, I.NM_ITEM AS "@NM_ITEM_NEW"
				, I.DS_ITEM AS "@DS_ITEM_NEW"
				--, I.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT_NEW"
				, I.FG_ACTIVE AS "@FG_ACTIVE_NEW"
				, D.KY_ITEM AS "@KY_ITEM_OLD"
				, D.NM_ITEM AS "@NM_ITEM_OLD"
				, D.DS_ITEM AS "@DS_ITEM_OLD"
				--, D.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT_OLD"
				, D.FG_ACTIVE AS "@FG_ACTIVE_OLD"
				FROM inserted I
					INNER JOIN deleted D
						ON I.ID_ITEM = D.ID_ITEM
			FOR XML PATH ('UPDATED')
		)

		SELECT @NO_AFFECTED_RECORDS = COUNT(*) FROM inserted
		SELECT TOP 1 @DS_MESSAGE = 'The item ' + NM_ITEM + ', with id ' + CONVERT( NVARCHAR(10),ID_ITEM) + ' has been updated correctly' 
			, @KY_USER = KY_USER_APP_UPDATE
			, @NM_PROGRAM = NM_PROGRAM_UPDATE
			, @DT_AFFECTED = DT_UPDATE
		FROM inserted

		IF @NO_AFFECTED_RECORDS > 1
			SET @DS_MESSAGE = CONVERT(NVARCHAR(10), @NO_AFFECTED_RECORDS) + ' items has been updated correctly'

	END

	-------------------------------------------------- INSERT
	IF @KY_ACTION = @KY_ACTION_INSERT BEGIN
		SET @XML_VALUES = (
		   SELECT i.ID_ITEM AS "@ID_ITEM" 
				, i.KY_ITEM AS "@KY_ITEM_NEW"
				, i.NM_ITEM AS "@NM_ITEM_NEW"
				, i.DS_ITEM AS "@DS_ITEM_NEW"
				--, I.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT_NEW"
				, i.FG_ACTIVE AS "@FG_ACTIVE_NEW"
				FROM inserted i
			FOR XML PATH ('INSERTED')
		)
		
		SELECT @NO_AFFECTED_RECORDS = COUNT(*) FROM inserted
		SELECT TOP 1 @DS_MESSAGE = 'The item ' + NM_ITEM + ', with id ' + CONVERT( NVARCHAR(10),ID_ITEM) + ' has been inserted correctly' 
			, @KY_USER = KY_USER_APP_CREATION
			, @NM_PROGRAM = NM_PROGAM_CREATE
			, @DT_AFFECTED = DT_CREATION
		FROM inserted

		IF @NO_AFFECTED_RECORDS > 1
			SET @DS_MESSAGE = CONVERT(NVARCHAR(10), @NO_AFFECTED_RECORDS) + ' items has been inserted'

		IF @NO_AFFECTED_RECORDS = 0
			SET @DS_MESSAGE = '0 items has been inserted'

	END

	------------------------------------------------ DELETE
	IF @KY_ACTION = @KY_ACTION_DELETE BEGIN
		SET @XML_VALUES = (
		   SELECT d.ID_ITEM AS "@ID_ITEM" 
				, d.KY_ITEM AS "@KY_ITEM_OLD"
				, d.NM_ITEM AS "@NM_ITEM_OLD"
				, d.DS_ITEM AS "@DS_ITEM_OLD"
				--, d.ID_BRANCH_PLANT AS "@ID_BRANCH_PLANT_NEW"
				, d.FG_ACTIVE AS "@FG_ACTIVE_OLD"
				FROM deleted d
			FOR XML PATH ('DELETED')
		)
		
		SELECT @NO_AFFECTED_RECORDS = COUNT(*) FROM deleted
		SELECT TOP 1 @DS_MESSAGE = 'The item ' + NM_ITEM + ', with id ' + CONVERT( NVARCHAR(10),ID_ITEM) + ' has been deleted correctly' 
			, @KY_USER = KY_USER_APP_CREATION
			, @NM_PROGRAM = NM_PROGAM_CREATE
			, @DT_AFFECTED = GETDATE()
		FROM deleted

		IF @NO_AFFECTED_RECORDS > 1
			SET @DS_MESSAGE = CONVERT(NVARCHAR(10), @NO_AFFECTED_RECORDS) + ' items has been deleted correctly'
	END

	SET @XML_CATALOG = (
		SELECT  
			@KY_CATALOG AS "@CATALOG" 
			, @XML_VALUES
		FOR XML PATH ('CATALOG')
	)
	
	SET @XML_REFERENCE = (
		SELECT  
			@XML_CATALOG
		FOR XML PATH ('REFERENCE')
	)


	INSERT INTO [PRD].[K_LOG]([DS_LOG],[XML_REFERENCE],DT_CREATION,KY_USER_APP_CREATION,NM_PROGAM_CREATE)
	SELECT @DS_MESSAGE + ' - ' + ISNULL(@KY_ACTION, ''), @XML_REFERENCE, ISNULL(@DT_AFFECTED, GETDATE()), ISNULL(@KY_USER, 'NOT_IDENTIFIED'), ISNULL(@NM_PROGRAM, 'NOT IDENTIFIED');

END TRY
BEGIN CATCH  
	EXEC ADM.SPE_RAISE_ERROR
END CATCH; 
	
END