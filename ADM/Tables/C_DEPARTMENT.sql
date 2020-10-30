﻿CREATE TABLE [ADM].[C_DEPARTMENT] (
    [ID_DEPARTMENT]        INT            IDENTITY (1, 1) NOT NULL,
    [KY_DEPARTMENT]        NVARCHAR (50)  NOT NULL,
    [NM_DEPARTMENT]        NVARCHAR (300) NOT NULL,
    [DS_DEPARTMENT]        NVARCHAR (500) NOT NULL,
    [FG_ACTIVE]            BIT            CONSTRAINT [DF_C_DEPARTMENT_FG_ACTIVE] DEFAULT ((1)) NOT NULL,
    [ID_BRANCH_PLANT]      INT            NULL,
    [DT_CREATION]          DATETIME       NOT NULL,
    [DT_UPDATE]            DATETIME       NULL,
    [KY_USER_APP_CREATION] NVARCHAR (50)  NOT NULL,
    [KY_USER_APP_UPDATE]   NVARCHAR (50)  NULL,
    [NM_PROGAM_CREATE]     NVARCHAR (50)  NOT NULL,
    [NM_PROGRAM_UPDATE]    NVARCHAR (50)  NULL,
    CONSTRAINT [PK_C_DEPARTMENT] PRIMARY KEY CLUSTERED ([ID_DEPARTMENT] ASC),
    CONSTRAINT [FK_C_DEPARTMENT_C_BRANCH_PLANT] FOREIGN KEY ([ID_BRANCH_PLANT]) REFERENCES [ADM].[C_BRANCH_PLANT] ([ID_BRANCH_PLANT])
);


GO
CREATE TRIGGER [ADM].[TR_CUD_DEPARTMENT] ON  [ADM].[C_DEPARTMENT] AFTER INSERT,UPDATE,DELETE
AS 
BEGIN

DECLARE @XML_CATALOG AS XML,
		@XML_VALUES AS XML,
		@XML_REFERENCE AS XML,
		@KY_CATALOG AS NVARCHAR(100) = 'DEPARTMENT',
		@DS_MESSAGE AS NVARCHAR(100),
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
				I.ID_DEPARTMENT AS "@ID_DEPARTMENT" 
				, I.KY_DEPARTMENT AS "@KY_DEPARTMENT_NEW"
				, I.NM_DEPARTMENT AS "@NM_DEPARTMENT_NEW"
				, I.DS_DEPARTMENT AS "@DS_DEPARTMENT_NEW"
				, I.FG_ACTIVE AS "@FG_ACTIVE_NEW"
				, D.KY_DEPARTMENT AS "@KY_DEPARTMENT_OLD"
				, D.NM_DEPARTMENT AS "@NM_DEPARTMENT_OLD"
				, D.DS_DEPARTMENT AS "@DS_DEPARTMENT_OLD"
				, D.FG_ACTIVE AS "@FG_ACTIVE_OLD"
				FROM inserted I
					INNER JOIN deleted D
						ON I.ID_DEPARTMENT = D.ID_DEPARTMENT
			FOR XML PATH ('UPDATED')
		)

		SELECT @NO_AFFECTED_RECORDS = COUNT(*) FROM inserted
		SELECT TOP 1 @DS_MESSAGE = 'The department ' + NM_DEPARTMENT + ', with id ' + CONVERT( NVARCHAR(10),ID_DEPARTMENT) + ' has been updated correctly' 
			, @KY_USER = KY_USER_APP_UPDATE
			, @NM_PROGRAM = NM_PROGRAM_UPDATE
			, @DT_AFFECTED = DT_UPDATE
		FROM inserted

		IF @NO_AFFECTED_RECORDS > 1
			SET @DS_MESSAGE = CONVERT(NVARCHAR(10), @NO_AFFECTED_RECORDS) + ' departments has been updated correctly'

	END

	-------------------------------------------------- INSERT
	IF @KY_ACTION = @KY_ACTION_INSERT BEGIN
		SET @XML_VALUES = (
			SELECT i.ID_DEPARTMENT AS "@ID_DEPARTMENT" 
				, i.KY_DEPARTMENT AS "@KY_DEPARTMENT_NEW"
				, i.NM_DEPARTMENT AS "@NM_DEPARTMENT_NEW"
				, i.DS_DEPARTMENT AS "@DS_DEPARTMENT_NEW"
				, i.FG_ACTIVE AS "@FG_ACTIVE_NEW"
				FROM inserted i
			FOR XML PATH ('INSERTED')
		)
		
		SELECT @NO_AFFECTED_RECORDS = COUNT(*) FROM inserted
		SELECT TOP 1 @DS_MESSAGE = 'The department ' + NM_DEPARTMENT + ', with id ' + CONVERT( NVARCHAR(10),ID_DEPARTMENT) + ' has been inserted correctly' 
			, @KY_USER = KY_USER_APP_CREATION
			, @NM_PROGRAM = NM_PROGAM_CREATE
			, @DT_AFFECTED = DT_CREATION
		FROM inserted

		IF @NO_AFFECTED_RECORDS > 1
			SET @DS_MESSAGE = CONVERT(NVARCHAR(10), @NO_AFFECTED_RECORDS) + ' departments has been inserted correctly'
	END

	------------------------------------------------ DELETE
	IF @KY_ACTION = @KY_ACTION_DELETE BEGIN
		SET @XML_VALUES = (
			SELECT d.ID_DEPARTMENT AS "@ID_DEPARTMENT" 
				, d.KY_DEPARTMENT AS "@KY_DEPARTMENT_OLD"
				, d.NM_DEPARTMENT AS "@NM_DEPARTMENT_OLD"
				, d.DS_DEPARTMENT AS "@DS_DEPARTMENT_OLD"
				, d.FG_ACTIVE AS "@FG_ACTIVE_OLD"
				FROM deleted d
			FOR XML PATH ('DELETED')
		)
		
		SELECT @NO_AFFECTED_RECORDS = COUNT(*) FROM deleted
		SELECT TOP 1 @DS_MESSAGE = 'The department ' + NM_DEPARTMENT + ', with id ' + CONVERT( NVARCHAR(10),ID_DEPARTMENT) + ' has been deleted correctly' 
			, @KY_USER = KY_USER_APP_CREATION
			, @NM_PROGRAM = NM_PROGAM_CREATE
			, @DT_AFFECTED = GETDATE()
		FROM deleted

		IF @NO_AFFECTED_RECORDS > 1
			SET @DS_MESSAGE = CONVERT(NVARCHAR(10), @NO_AFFECTED_RECORDS) + ' departments has been deleted correctly'
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
	SELECT @DS_MESSAGE, @XML_REFERENCE, @DT_AFFECTED, @KY_USER, @NM_PROGRAM;

END TRY
BEGIN CATCH  
	ROLLBACK;  
END CATCH; 
	
END